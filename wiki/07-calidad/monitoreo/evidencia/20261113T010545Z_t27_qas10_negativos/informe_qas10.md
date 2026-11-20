# SCRUM-1664 (T-27): QAS-10 Integridad, negativos de las operaciones críticas

**Fecha de la corrida:** 2026-11-13, de 01:05:45Z a 01:07Z aprox. (12 nov, hora Colombia). Corrida `e79cc70d`.
**Ambiente:** MANI-QA. Gateway `ecd9ec2`, Core `cfa503a`, Dispatch `930a15b`, Rules `3e3da57`.
**Método:** SDD §8, QAS-10. Para cada operación crítica se ejecuta con Newman, por el Gateway, un caso negativo de rol incorrecto, uno de payload inválido y uno de reintento duplicado. Cada caso verifica tres cosas: el código HTTP, que respondió la validación esperada (por el código MANI del cuerpo) y que el estado persistido no cambió. Además, en el motor se comprueban las restricciones que respaldan cada operación.
**Resultado de la corrida:** 46 PASA y 3 FALLA. Las 3 FALLA son de la capa de restricciones del motor (§4). Los 33 casos Newman pasaron: 64 aserciones, 0 fallidas.

## 1. Inventario de operaciones críticas

| # | Operación | Ruta (por el Gateway) | Quién la puede hacer | Validación (código MANI) | Respaldo en la base |
|---|---|---|---|---|---|
| 1 | Crear solicitud | `POST /api/v1/core/solicitudes` | CLIENT | `MANI-SOL-403C`, `MANI-SOL-422D`, `MANI-SOL-409K` | idempotencia por clave (repositorio) |
| 2 | Aceptar solicitud (asignación) | `POST /api/v1/dispatch/requests/{id}/accept` | ALLY | `MANI-DSP-403`, `MANI-DSP-400`; Core responde `MANI-SOL-404` y `MANI-SOL-409E` | `UPDATE` condicionado en Core (decisión 6A) |
| 3 | Aceptar cotización | `POST /api/v1/core/cotizaciones/{id}/aceptar` | CLIENT dueño | `MANI-COT-403`, `MANI-COT-404`, `MANI-COT-400`, `MANI-COT-409R` | **sin CHECK sobre `cotizacion.estado`** |
| 4 | Cancelar solicitud | `PATCH /api/v1/core/solicitudes/me/{id}/cancelar` | CLIENT dueño | `MANI-SOL-403C`, `MANI-SOL-404`, `MANI-SOL-422M`; idempotente sobre CANCELADA | **sin CHECK sobre `solicitud.estado`** |
| 5 | Pagar | `POST /api/v1/core/pagos` | CLIENT dueño | `MANI-PAG-403C`, `MANI-PAG-404`, `MANI-PAG-400`, `MANI-PAG-409A` | `ux_pago_clave_idempotencia`, `ux_pago_aprobado_por_cotizacion`, `pago_estado_check`, `ux_retencion_pago` |
| 6 | Aprobar aliado (KYC) | `PATCH /api/v1/core/aliados/{id}/verificacion` | ADMIN del tenant | `MANI-VER-403`, `MANI-VER-404`, `MANI-VER-422D`, `MANI-VER-422M`, `MANI-VER-409` | bloqueo y relectura del estado (repositorio) |
| 7 | Cambiar tarifa | `PUT /api/v1/core/tarifas/{id}` y `POST /api/v1/core/tarifas` | ADMIN del tenant | `MANI-TAR-403`, `MANI-TAR-404`, `MANI-TAR-400`, `MANI-TAR-409V`, `MANI-TAR-409R` | `ck_tarifa_referencia_valores`, `ex_tarifa_referencia_vigencia_activa`, `ux_tarifa_referencia_categoria_version` |

**Cruce con la regresión existente** (`MANI-API qa/newman/generar_coleccion.js`, 77 casos): ya había negativos de rol o de datos para crear solicitud (1072-02 a 05) y aceptar solicitud (1074-02 a 04, 06). Ninguno verificaba el estado persistido. No había negativos para cancelar, pagar, aprobar aliado ni cambiar tarifa.

## 2. Casos Newman por el Gateway

Colección: [`qa_t27/coleccion_t27_negativos.json`](coleccion_t27_negativos.json). Son 33 casos; cada uno se puede rastrear por `X-Correlation-ID` `t27-e79cc70d-<caso>`.

| Operación | Rol incorrecto | Payload inválido | Reintento duplicado | Otro tenant | Otro |
|---|---|---|---|---|---|
| Crear solicitud | aliado → `403 MANI-SOL-403C` | descripción corta → `422 MANI-SOL-422D` | misma clave → `200`, **la misma solicitud**<br>misma clave con otros datos → `409 MANI-SOL-409K` | — | — |
| Aceptar solicitud | cliente → `403 MANI-DSP-403` | id no UUID → `400 MANI-DSP-400` | el aliado ya asignado reacepta → `200` idempotente | aliado de T2 → `404 MANI-SOL-404` | solicitud CANCELADA → `409 MANI-SOL-409E` |
| Aceptar cotización | aliado → `403 MANI-COT-403` | id no UUID → `400 MANI-COT-400` | volver a aceptar → `409 MANI-COT-409R` | cliente de T2 → `404 MANI-COT-404` | — |
| Cancelar solicitud | aliado → `403 MANI-SOL-403C` | motivo de 600 caracteres → `422 MANI-SOL-422M` | cancelar una CANCELADA → `200` idempotente, sin cambios | cliente de T2 → `404 MANI-SOL-404` | — |
| Pagar | aliado → `403 MANI-PAG-403C` | cotización no UUID → `400 MANI-PAG-400`<br>campo de tarjeta → `400 MANI-PAG-400` | misma clave → `200`, **el mismo pago**<br>clave nueva → `409 MANI-PAG-409A` | cliente de T2 → `404 MANI-PAG-404` | — |
| Aprobar aliado | aliado → `403 MANI-VER-403` | decisión inválida → `422 MANI-VER-422D`<br>rechazo sin motivo → `422 MANI-VER-422M` | aprobar a uno ya VERIFICADO → `409 MANI-VER-409` | admin de T2 → `404 MANI-VER-404` | — |
| Cambiar tarifa | cliente → `403 MANI-TAR-403` | mínimo > máximo → `400 MANI-TAR-400` | crear una tarifa que se cruza con la activa → `409 MANI-TAR-409V`<br>editar una versión reemplazada → `409 MANI-TAR-409R` | admin de T2 → `404 MANI-TAR-404` | — |

**Estado persistido.** Antes y después de la colección se tomó una huella (md5 de las filas) de las solicitudes, la cotización, los pagos y su retención, el aliado y el tarifario de plomería de T1. Las **7 huellas quedaron idénticas**, y no se creó ninguna solicitud de T1 entre las dos tomas.

**Notas sobre las expectativas.** En la primera corrida (`4e542a95`, 00:59Z) hubo 3 FALLA en Newman. No eran defectos, sino expectativas mal escritas, y se corrigieron antes de la corrida que se reporta:
- Dispatch propaga el código de Core (`MANI-SOL-404`, `MANI-SOL-409E`), porque la asignación la decide Core (decisión 6A).
- Cancelar una solicitud ya CANCELADA devuelve `200` sin tocarla. Es idempotente por diseño (`PgServiceRequestRepository`).

En ambos casos el HTTP y el estado eran correctos. La evidencia de esa corrida también se archiva.

## 3. Restricciones del motor

Las pruebas corren con `mani_core_svc`, contexto de admin de T1, todo en `ROLLBACK`.

| Intento | Resultado | Lectura |
|---|---|---|
| Copiar un pago con su misma clave | `23505 ux_pago_clave_idempotencia` | PASA |
| Segunda retención para el mismo pago | `23505 ux_retencion_pago` | PASA |
| Segunda tarifa ACTIVA con la vigencia cruzada | `23P01 ex_tarifa_referencia_vigencia_activa` | PASA |
| Tarifa con `valor_min > valor_max` | `23514` (`ck_tarifa_referencia_valores`) | PASA |
| `UPDATE pago SET estado = 'INVENTADO_T27'` | `42501`: Core no puede actualizar `pago` | Protegido: Core no tiene `UPDATE`, y además existe `pago_estado_check`. El script esperaba `23514`, por eso marca FALLA |
| **`UPDATE solicitud SET estado = 'INVENTADO_T27'`** | **`UPDATE 1`: la base lo aceptó** | **FALLA** |
| **`UPDATE cotizacion SET estado = 'INVENTADO_T27'`** | **`UPDATE 1`: la base lo aceptó** | **FALLA** |

**Catálogo** (restricciones CHECK de cada tabla):

| Tabla | Tipo de `estado` | Restricciones CHECK |
|---|---|---|
| `solicitud` | text | solo `ck_solicitud_penalizacion_no_negativa` |
| `cotizacion` | text | ninguna |
| `pago` | text | `pago_estado_check`, `pago_monto_check` |
| `retencion_fondos` | text | `retencion_fondos_estado_check`, `ck_retencion_liberada_fecha`, `retencion_fondos_monto_check` |
| `liquidacion` | — | 5 (suma, comisión, bruto, neto, porcentaje) |
| `tarifa_referencia` | text | 6, incluida `ck_tarifa_referencia_estado` |

## 4. Hallazgo

`solicitud.estado` y `cotizacion.estado` son `text` y no tienen ninguna restricción CHECK. Hoy el único control de esos estados es el código de Core. Cualquier escritura de Core por fuera del caso de uso (un bug, un backfill o un script) puede dejar un estado inexistente, y la base no lo impide.

Cómo reproducirlo: con `mani_core_svc`, después de `app.set_context(T1, admin_t1, 'admin_tenant')`, `UPDATE solicitud SET estado = 'INVENTADO_T27' WHERE id = …` devuelve `UPDATE 1`. Lo mismo pasa con `cotizacion`. En la prueba se hizo en `ROLLBACK`.

Esto choca con el umbral de QAS-10 ("constraints transaccionales", "las restricciones impiden … estados incoherentes"). Para cerrarlo haría falta una migración con `CHECK (estado IN (…))` `NOT VALID` sobre ambas tablas, como se hizo con `tarifa_referencia` en la 0030. Antes hay que revisar si hay filas viejas con estados fuera del catálogo.

## 5. Estado propuesto de QAS-10

**Parcial**, por debajo del umbral solo en la capa de la base:
- **Validación de autorización:** las 7 operaciones están protegidas (100 %). Rechazan el rol incorrecto, el payload inválido, el otro tenant y el duplicado, con el código esperado y sin cambiar el estado.
- **Restricciones transaccionales:** 5 de las 7 operaciones tienen respaldo en la base. Pago y retención tienen únicos y CHECK. Tarifa tiene CHECK, exclusión y único. Crear solicitud tiene idempotencia, y la asignación hace un `UPDATE` condicionado. Faltan los CHECK de estado de **solicitud** (que afecta crear, aceptar y cancelar) y de **cotización**.

Pasa a **Cumple** cuando exista ese CHECK y se repita la §3.

## 6. Rastro en QA

Hay 6 solicitudes de prueba de cliente.t1, 3 por corrida. De ellas, 4 están CANCELADAS y 2 tienen cotización aceptada y pago simulado RETENIDO (`…6ac096bf`, `…eb1291b49`). No se cambió el tarifario de plomería de T1 (sigue en v5) ni el estado de aliado.t1.

## 7. Evidencia

| Archivo | Contenido |
|---|---|
| [`qa_t27/evidencia/t27_13nov_0104z.txt`](t27_qas10_qa.txt) | Corrida reportada: datos, huellas, salida de Newman, restricciones y catálogo. Secretos redactados |
| [`qa_t27/evidencia/t27_13nov_0059z.txt`](t27_qas10_qa_primera_corrida.txt) | Primera corrida, con las expectativas sin corregir |
| [`qa_t27/coleccion_t27_negativos.json`](coleccion_t27_negativos.json) | Colección Newman (33 casos) |
| [`qa_t27/generar_coleccion_t27.py`](scripts/generar_coleccion_t27.py), [`t27_qa.py`](scripts/t27_qa.py), [`correr_t27_qa.sh`](scripts/correr_t27_qa.sh) | Scripts para repetir la prueba (`bash qa_t27/correr_t27_qa.sh`) |

# Barrido de escenarios QAS sin medición del Sprint 6

> Evidencia de QA del Sprint 6. Resultado en el [SDD §8](../../../../02-arquitectura/SDD.md). Mantiene: QA (Santiago Hernández).

22 de noviembre de 2026, de 02:55Z a 03:05Z. Revisión de los escenarios del SDD §8 cuyo último corte era de octubre o del 4 de noviembre y que ninguna tarea del Sprint 6 volvió a medir. Los escenarios medidos en el sprint (T-41 a T-46) no se tocan.

**Fuentes:** QA (`10.43.100.141`) con `release` del 20 nov (Core `73c28f4`, Dispatch `eedb112`, Rules `348f6d9`, Gateway `ee5000c`); Prometheus de la VM de Calidad (`10.43.98.196`); el mapa de versiones de DevOps del 14 nov (`08-infraestructura/01-mapa-ambientes-y-versiones.md`); y el código de `release`. Las consultas a QA fueron de solo lectura, salvo la prueba de QAS-11, 37 y 42 (§5), que creó una cotización, un pago simulado y una solicitud cancelada; los intentos de modificar los registros inmutables corrieron dentro de una transacción que se revirtió.

**Regla de estados.** Igual que en T-43: **Parcial** cuando el umbral se cumple en parte o el método se ejecutó en parte; **No cumple** cuando falta lo que el umbral exige; **No medido** cuando el método no se pudo ejecutar, con el motivo actualizado al 22 nov.

## 1. Resultado

| QAS | Antes | Ahora | Dato del 22 nov |
|---|---|---|---|
| 02 Tolerancia a fallos | Bloqueado (20 oct) | **Parcial** | El bloqueo ya no existe: Core tiene el adaptador `mock_falla` (SCRUM-1662) para simular la caída de push, con reintento por clave de idempotencia. Sus pruebas pasan (55 de 55 en proveedores). En QA el Core corre con el proveedor por omisión (`mock`), así que la falla no se inyectó en QA. |
| 09 Protección ante fallos | Bloqueado (20 oct) | **Parcial** | KYC ya está en QA. El Storage de KYC tiene falla inyectable (`STORAGE_FALLA`, SCRUM-1662) y sus pruebas pasan. No se inyectó la falla en QA. |
| 05 Escalabilidad | No medido (21 oct) | **No medido** | Motivo actualizado: escalar con `docker compose --scale` cambia el QA compartido y es una decisión de DevOps. El umbral es el de la opción B (acta SCRUM-1684). |
| 06 Interoperabilidad | No cumple (19 oct) | **Parcial** | Ya no es 1 de 12: los contratos de `release` describen 141 operaciones (T-43) y el CI del Gateway valida los contratos (`validate:openapi`, Spectral) y corre un gate de contrato con Newman. No se verificó en este corte que el 100 % de las rutas publicadas tenga contrato; MANI-docs#81 reporta 127 de 127, sin fusionar. |
| 11 No repudio | No medido (4 nov) | **Cumple** | Se ejecutó una operación de cada tipo, incluido un pago sandbox (§5). Las filas de `evento_servicio`, `transaccion_evento` y `pago` guardan actor, rol, instante y correlation ID. `UPDATE`, `DELETE` y `TRUNCATE` sobre esos registros: rechazados por trigger o por permiso (42501), en una transacción que se revirtió. |
| 12 Accountability | Parcial (21 oct) | **Parcial** | Asignación y creación: 10 de 10 eventos con actor, rol y correlation ID (el de la petición k6). Tarifa, reglas, pagos y consultas guardan actor y correlation ID. **La aprobación de aliado no guarda actor ni correlation ID** en la base (tabla `aliado`). Cancelación no ejecutada en este corte. |
| 14 Resistencia | No cumple (4 nov) | **Cumple** | SAST sin vulnerabilidades High o Blocker en los seis repos; ZAP contra QA con 0 FAIL y las 5 alertas High de inyección SQL verificadas como falsos positivos; rate limiting con 429. Detalle e hallazgos Medium en el [informe de QAS-14](../20261122T032900Z_qas14_dast_sast/informe_qas14.md). |
| 16 Disponibilidad | No medido (19 nov) | **Cumple** | Sondas del blackbox de Prometheus, 7 días continuos (15 a 22 nov, unas 20 100 muestras por sonda). QA: Core 99,965 %, Dispatch 99,990 %, Rules 99,995 %, Gateway 99,995 %. PROD: Core 99,965 %, Dispatch, Rules y Gateway 100 %. Todas ≥ 99,9 %. No se descontaron ventanas de mantenimiento. |
| 18 Utilización de recursos | No medido (4 nov) | **No medido** | Motivo actualizado: los contenedores de QA ya tienen límites (SCRUM-1672: Core, Dispatch y Rules 1 CPU; Gateway 0,5 CPU), pero Prometheus no tiene CPU por contenedor (§2). |
| 22 Analizabilidad | Parcial (21 oct) | **Parcial** | Correlation ID: Core, Dispatch y Rules devuelven el mismo ID enviado, una sola vez, y lo generan si falta (H-07 ya no se reproduce). Logs: Gateway y Rules en JSON con el ID; **Core y Dispatch en texto plano**. |
| 23 Capacidad para ser probado | Parcial (21 oct) | **Parcial** | Recalculado el 22 nov: casos de uso críticos de Core 97,2 % en conjunto, Rules 100 %, Dispatch 86 a 94 %, con 3 casos bajo 90 %. El Gateway no exige cobertura de código nuevo y los contract tests solo son obligatorios en su CI. Detalle en `20261122T040500Z_qas23_cobertura/informe_qas23.md`. |
| 24 Adaptabilidad | No medido (4 nov) | **No cumple** | Cada ambiente usa una imagen distinta: `develop`, `staging` y `latest`, con digests diferentes (mapa del 14 nov y QA hoy: Core `438921ef…`). Las imágenes se construyen por rama, no se promueve la misma. La prueba de arranque de Flutter con otro `.env` no se hizo. |
| 25 Instalabilidad | No medido (4 nov) | **Cumple** | Script versionado de un comando: `MANI-APIGateway/infra/qa/desplegar_release_qa.sh` (PR #91). DevOps lo cronometró en 13 s (SCRUM-1674) y el despliegue de `release` del 20 nov terminó con salud en 2 min 24 s (T-42). |
| 26 Reemplazabilidad | No medido (4 nov) | **Parcial** | Push: dos adaptadores (`mock` y `mock_falla`) elegidos por configuración, con pruebas de contrato comunes; el cambio no toca dominio. Pagos: solo existe `mock`. Pruebas de proveedores 55 de 55. |
| 27 Coexistencia | No medido (4 nov) | **No medido** | Motivo actualizado: límites de CPU y memoria configurados en los 13 contenedores de QA, pero sin serie por contenedor (§2) no se puede ver si un servicio degrada a los demás. |
| 30, 31 y 32 Usabilidad | No medido (4 nov) | **No medido** | Motivo actualizado: la PO no ha elegido el método de T-45 (SCRUM-1682): prueba con 3 a 5 personas por rol o revisión heurística. |
| 37 Restricción operativa | No medido (4 nov) | **Cumple** | Matriz de 9 transiciones inválidas (§5) más las 2 de T-46: todas con su 409 o 403 y sin cambio del estado persistido. Script por el Gateway en lugar de Newman. |
| 40 Integración segura | No medido (4 nov) | **Parcial** | Timeouts: Dispatch 3 s hacia Core, Core 3 s hacia Dispatch y Rules con un reintento, proveedores 5 y 10 s. Validación de respuesta con contratos de proveedores (pruebas pasan). **Circuit breaker solo en Rules**; Core y Dispatch no lo tienen. No hubo inyección en QA. |
| 42 Idempotencia | Parcial (21 oct) | **Cumple** | Pago y creación de solicitud: el reintento devuelve el mismo registro y la base tiene uno solo; la misma clave con otro cuerpo da 409 (`MANI-PAG-409K`, `MANI-SOL-409K`) (§5). Aceptación: `isRetry: true` (T-46). Script en lugar de Newman. |
| 43 TLS | No medido (20 oct) | **Parcial** | En la VM de QA, el puerto 443 acepta TLS 1.2 y 1.3, rechaza TLS 1.1, y el 80 redirige con 301 a HTTPS. Pero el **8080 sirve la app y la API por HTTP sin TLS**, y es el puerto que se usa en QA. Desde fuera de la VM, 80 y 443 no responden (cortafuegos). PROD no se midió. |

## 2. Utilización de recursos y coexistencia (QAS-18 y 27)

Los límites existen en los 13 contenedores (`vm_qa_22nov_0257z.txt`). Para medir el uso se consultó cAdvisor en Prometheus durante las cargas de T-42 (20 nov 19:25Z a 19:45Z y 21 nov 22:43Z a 22:51Z): `container_cpu_usage_seconds_total` del job `mani_qa_cadvisor` tiene **una sola serie**, la del host, con las etiquetas `cpu`, `id`, `instance` y `ambiente`, y **sin nombre de contenedor** (`qas18_cpu_contenedores_22nov_0302z.txt`). El cAdvisor de QA no está viendo los contenedores de Docker (falta montar su socket o sus cgroups) o el scrape descarta esas series. Mientras no se corrija, QAS-18 y 27 no se pueden medir.

## 3. Hallazgos

| # | Hallazgo | QAS | Responsable sugerido |
|---|---|---|---|
| H-B-1 | El puerto 8080 de QA expone la app y la API sin TLS, en paralelo al 443. | 43 | DevOps |
| H-B-2 | Las imágenes se construyen por rama y ambiente; no se promueve la misma imagen de QA a PROD. | 24 | DevOps |
| H-B-3 | La aprobación de aliado no deja actor ni correlation ID en la base. | 12 | Equipo de Core |
| H-B-4 | Core y Dispatch registran logs en texto plano. | 22 | Equipo de Core y Dispatch |
| H-B-5 | Core y Dispatch no tienen circuit breaker; Dispatch corta a los 3 s (mismo timeout de SCRUM-1651). | 40 | Equipo de Core y Dispatch |
| H-B-6 | Pagos solo tiene el adaptador `mock`. | 26 | Equipo de Core |
| H-B-7 | El cAdvisor de QA no exporta métricas por contenedor: Prometheus solo tiene la serie del host. | 18 y 27 | DevOps |

## 4. Evidencia (esta carpeta)

- `vm_qa_22nov_0257z.txt`: puertos y TLS desde la VM, límites por contenedor, digests de QA, formato de logs, tablas con actor y correlation ID, triggers de inmutabilidad, eventos de T-46 e intentos rechazados de UPDATE, DELETE y TRUNCATE.
- `vm_calidad_prometheus_22nov_0258z.txt`: disponibilidad por sonda en 7 y 14 días.
- `qas18_cpu_contenedores_22nov_0302z.txt`: series de CPU de cAdvisor (solo la del host).
- `qas43_tls_22nov.txt`: TLS y puertos desde fuera de la VM.
- `qas22_correlacion_22nov.txt`: correlation ID por el Gateway, con y sin cabecera.
- `revision_codigo_22nov.txt`: circuit breaker, timeouts, idempotencia, códigos de conflicto, adaptadores y contract tests en `release`.
- `core_pruebas_proveedores_22nov.txt`: pruebas de proveedores y falla inyectable del Core (55 de 55).

Scripts en `scripts/`: `revisar_vm_qa.sh`, `revisar_vm_calidad.sh` y `revisar_cpu_contenedores.sh`. No guardan ni imprimen claves ni tokens.

## 5. QAS-11, 37 y 42 en QA (03:18Z a 03:20Z)

Script `correr_qas11_37_42.sh` por el Gateway (8080) con `cliente.t1` y `aliado.t1`. Sobre la solicitud `6ef93e76` de T-46 (ASIGNADA a `aliado.t1`) y una solicitud nueva (`9a0238ad`) que quedó CANCELADA. Correlation ID `qa-qas11-0318-*`. **17 de 17 casos como se esperaba.**

| QAS | Caso | Respuesta | Estado persistido |
|---|---|---|---|
| 37 | Aliado cotiza la solicitud ASIGNADA | 201 | ASIGNADA → COTIZANDO |
| 37 | Segunda cotización con una pendiente | 409 `MANI-COT-409P` | COTIZANDO, sin cambio |
| 37 | Pagar una cotización PENDIENTE | 409 `MANI-PAG-409E` | COTIZANDO, sin cambio |
| 37 | Cliente acepta la cotización | 200 | → ACEPTADA |
| 37 | Rechazar una cotización ya aceptada | 409 `MANI-COT-409R` | ACEPTADA, sin cambio |
| 37 | Cotizar una solicitud ACEPTADA | 409 `MANI-COT-409E` | ACEPTADA, sin cambio |
| 11 | Pago sandbox APROBADO (`mock`, 150 000 COP simulado) | 201 | pago `fa6b63c9` |
| 42 | Reintento del pago, misma clave y cuerpo | 200, mismo pago | 1 pago en la base |
| 42 | Misma clave, otro escenario | 409 `MANI-PAG-409K` | 1 pago en la base |
| 37 | Segundo pago con otra clave | 409 `MANI-PAG-409A` | ACEPTADA, sin cambio |
| 42 | Crear solicitud con clave | 201 | `9a0238ad` PENDIENTE |
| 42 | Reintento, misma clave y cuerpo | 200, mismo id | 1 solicitud en la base |
| 42 | Misma clave, otra descripción | 409 `MANI-SOL-409K` | 1 solicitud en la base |
| 37 | Cancelar la solicitud PENDIENTE | 200 | → CANCELADA |
| 37 | Cancelar una solicitud CANCELADA | 409 `MANI-SOL-409C` | CANCELADA, sin cambio |
| 37 | Aliado acepta una solicitud CANCELADA | 409 `MANI-SOL-409E` | CANCELADA, sin cambio |
| 37 | Aliado cotiza una CANCELADA sin estar asignado | 403 `MANI-COT-403A` | CANCELADA, sin cambio |

**Base (QAS-11).** `evento_servicio` tiene 7 filas de las dos solicitudes (creación, asignación, cotización enviada, cotización aceptada, pago registrado, creación y cancelación), todas con actor, rol y el correlation ID de la petición; el instante va en la columna `timestamp` (NOT NULL). `transaccion_evento` tiene la fila `PAGO_REGISTRADO` con actor, rol `CLIENT`, correlation ID y `created_at`. Intentos sobre estos registros, dentro de una transacción revertida:

| Intento | Resultado |
|---|---|
| `UPDATE` y `DELETE` en `evento_servicio` | Rechazados por el trigger: «evento_servicio es inmutable» (SCRUM-1656) |
| `UPDATE` y `DELETE` en `transaccion_evento` y `pago` | Rechazados por permiso (42501) |
| `TRUNCATE` de `evento_servicio` y `transaccion_evento` | Rechazados por permiso (42501) |

**Diferencia con el método del SDD.** Se usó un script Python por el Gateway en lugar de Newman; verifica código, mensaje y estado antes y después igual que la matriz prevista. En QAS-42 no se repitieron mensajes ni la orquestación.

**Datos que quedaron en QA.** La solicitud `6ef93e76` pasó a ACEPTADA con la cotización `73cecd30` y el pago simulado `fa6b63c9` (retención en garantía); la solicitud `9a0238ad` quedó CANCELADA.

Evidencia: `qas11_37_42_api_22nov_0318z.txt` (respuestas) y `qas11_37_42_base_22nov_0319z.txt` (base e intentos). Script: `correr_qas11_37_42.sh`, sin tokens ni claves.

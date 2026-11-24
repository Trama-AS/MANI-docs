# Módulo M-04 — Cotización y ejecución del servicio

[← 02 · Arquitectura](../README.md) · [Índice](../../Home.md)

**Fuente:** contrato [`docs/openapi/core.yaml`](https://github.com/Trama-AS/MANI-APIGateway/blob/develop/docs/openapi/core.yaml) 0.32.0 de MANI-APIGateway · casos de uso y repositorios de MANI-Node (`src/application/useCases/{quotes,services,additions}` y `src/infrastructure/repositories/Pg{Quote,ServiceExecution,ServiceEvent,Addition}Repository.js`) · [`SAD.md`](../SAD.md) §7.4 y §11 · [`SECUENCIAS.md`](../SECUENCIAS.md) §3 · [`ModeloDatos.md`](../ModeloDatos.md) §4.5 · [ADR-0022](../adr/ADR-0022-logica-de-negocio-en-servicios.md) · [ADR-0027](../adr/ADR-0027-alcance-supabase-cliente-flutter.md) · [ADR-0035](../adr/ADR-0035-frontera-de-asignacion-6a.md).

Esta página es de la capa **guía**: explica y ordena lo que ya está decidido y construido; no decide nada. Si contradice al contrato o al código, mandan ellos y esta página se corrige.

| Campo | Valor |
|---|---|
| **Finalidad** | Explicar en un solo lugar cómo funciona M-04: el flujo, los estados, los endpoints del Gateway, los errores `MANI-*` y dónde están sus pruebas |
| **Mantiene** | Nicolás Álvarez (desarrollo de M-04) |
| **Consume** | Desarrollo (front y Core), QA (para derivar casos y leer errores), PO (para validar el flujo) |
| **Cada cuánto se actualiza** | Cuando cambia una ruta, un estado o un código `MANI-*` del módulo |
| **Versión y fecha** | 1.0 · 2026-11-13 |
| **Corte del código** | MANI-APIGateway `develop` `229ba4d` (core.yaml 0.32.0) · MANI-Node `develop` `24fdc94` · MANI-Flutter `develop` `dceebca`, del 2026-11-12 |
| **Historia** | [SCRUM-1701](https://maniservices.atlassian.net/browse/SCRUM-1701) (T-56) |

## 1. Alcance e historias

M-04 cubre lo que pasa entre que un aliado queda asignado a una solicitud y el servicio termina: cotizar, responder la cotización, ejecutar, dejar bitácora y pedir adiciones por imprevistos. La asignación queda fuera: es de M-05 y la frontera está en [ADR-0035](../adr/ADR-0035-frontera-de-asignacion-6a.md). También quedan fuera la calificación y el cierre (M-08).

| Historia | Qué cubre | Estado en Jira |
|---|---|---|
| [SCRUM-865](https://maniservices.atlassian.net/browse/SCRUM-865) · US-04.2.1 | El aliado emite la cotización con mano de obra y materiales separados | Finalizada (Sprint 5) |
| [SCRUM-866](https://maniservices.atlassian.net/browse/SCRUM-866) · US-04.2.2 | Alerta de tarifa bidireccional frente al tarifario de Rules | Finalizada (Sprint 5) |
| [SCRUM-867](https://maniservices.atlassian.net/browse/SCRUM-867) · US-04.2.3 | El cliente acepta, rechaza o pide ajustar la cotización | Finalizada (Sprint 5) |
| [SCRUM-868](https://maniservices.atlassian.net/browse/SCRUM-868) · US-04.3.1 | El aliado marca el inicio y el fin de la ejecución | Finalizada (Sprint 5) |
| [SCRUM-869](https://maniservices.atlassian.net/browse/SCRUM-869) · US-04.3.2 | El aliado registra eventos durante la ejecución | Finalizada (Sprint 5) |
| [SCRUM-870](https://maniservices.atlassian.net/browse/SCRUM-870) · US-04.3.3 | El cliente consulta el log del servicio | Finalizada (Sprint 5) |
| [SCRUM-872](https://maniservices.atlassian.net/browse/SCRUM-872) · US-04.3.5 | El aliado pide una adición por imprevisto y el cliente decide | Finalizada (Sprint 5) |

La alerta de tarifa (866) y la cola sin conexión de eventos (873) tienen su propia página: [Alerta de tarifa y proveedores externos](alerta-de-tarifa-y-proveedores-externos.md) y [Cola de eventos sin conexión](modulo-m04-cola-sin-conexion.md). Aquí solo aparecen donde tocan el flujo.

## 2. Flujo

```text
Solicitud ASIGNADA (M-05)
  │
  ├─ Aliado: emite cotización v1 (mano de obra + materiales) ─────────► solicitud COTIZANDO
  │     Core calcula el total y la versión; el cliente recibe COTIZACION_RECIBIDA
  │
  ├─ Cliente responde la cotización PENDIENTE:
  │     acepta  ─────────────────────────────────────────────────────► solicitud ACEPTADA
  │     rechaza (con motivo) ────────────────────────────────────────► solicitud RECHAZADA
  │     pide ajuste (con comentario) ─► sigue COTIZANDO; el aliado emite v2, v3…
  │
  ├─ Aliado: marca inicio ───────────────────────────────────────────► solicitud EN_EJECUCION
  │     │
  │     ├─ Aliado: registra eventos (avance, novedad, observación, foto)
  │     ├─ Aliado: pide adición por imprevisto ─► cliente acepta o rechaza
  │     └─ Cliente: consulta el log y el total vigente
  │
  └─ Aliado: marca fin ──────────────────────────────────────────────► solicitud FINALIZADA
        Después siguen la calificación y el cierre (M-08)
```

Una categoría con flujo operativo `TARIFA_ESTANDAR` no pasa por cotización: el aliado puede marcar el inicio desde `ASIGNADA` (RF-22).

Core es el dueño del estado del servicio después de la asignación (decisión 6A, [`SAD.md`](../SAD.md) §7.4). Cada transición la hace Core en una transacción que bloquea la fila de la solicitud, registra el evento en `evento_servicio` y deja la notificación de la otra parte. La hora la pone el servidor de base de datos, nunca la app. La secuencia con Rules (validación contra el tarifario) está en [`SECUENCIAS.md`](../SECUENCIAS.md) §3.

## 3. Estados

### 3.1 Solicitud

| Desde | Acción | Quién | Hacia | Evento en `evento_servicio` |
|---|---|---|---|---|
| `ASIGNADA` o `COTIZANDO` | Emitir cotización | Aliado asignado | `COTIZANDO` | `COTIZACION_ENVIADA` |
| `COTIZANDO` | Aceptar la cotización | Cliente dueño | `ACEPTADA` | `COTIZACION_ACEPTADA` |
| `COTIZANDO` | Rechazar la cotización | Cliente dueño | `RECHAZADA` | `COTIZACION_RECHAZADA` |
| `COTIZANDO` | Pedir ajuste | Cliente dueño | `COTIZANDO` | `AJUSTE_SOLICITADO` |
| `ACEPTADA` (o `ASIGNADA` con `TARIFA_ESTANDAR`) | Marcar inicio | Aliado asignado | `EN_EJECUCION` | `INICIO_EJECUCION` |
| `EN_EJECUCION` | Marcar fin | Aliado asignado | `FINALIZADA` | `FIN_EJECUCION` |

Registrar eventos y pedir o decidir adiciones **no cambia** el estado de la solicitud.

### 3.2 Cotización

`PENDIENTE` → `ACEPTADA` | `RECHAZADA` | `AJUSTE_SOLICITADO`. Cada emisión crea una versión nueva (v1, v2…) y solo puede haber **una `PENDIENTE` a la vez**. Una versión respondida no cambia más: el historial de versiones queda visible para las dos partes.

### 3.3 Adición

`PENDIENTE` → `ACEPTADA` | `RECHAZADA`.

- Se pide solo con la solicitud `EN_EJECUCION` y una cotización aceptada.
- El cliente decide con la solicitud `EN_EJECUCION` o `FINALIZADA`.
- Solo una `PENDIENTE` a la vez.
- **Tope:** la suma de adiciones aceptadas no puede pasar del **50 %** del total de la cotización aceptada. El total vigente (cotización + adiciones aceptadas) lo calcula Core y es lo que cobra el pago (SCRUM-1432).

### 3.4 Eventos del servicio

Tipos que registra el aliado: avance (`EJECUCION_AVANCE`), novedad (`EJECUCION_NOVEDAD`) y observación (`EJECUCION_OBSERVACION`), con foto opcional.

- Se registran con la solicitud `EN_EJECUCION`.
- Un evento tomado sin conexión (873, detalle en [Cola de eventos sin conexión](modulo-m04-cola-sin-conexion.md)) trae su hora de captura (`ocurridoEn`). Entra aunque el servicio ya haya finalizado, siempre que esa hora esté entre el inicio y el fin de la ejecución. Se aceptan hasta 5 minutos de adelanto del reloj del teléfono.
- La clave de idempotencia evita duplicados al reintentar.
- El log que ve el cliente (870) es la secuencia completa de `evento_servicio`, incluidas las transiciones de la tabla 3.1, ordenada por la hora de captura (o la de registro si no la hay).

## 4. Endpoints del Gateway

Todos entran por el Gateway con el prefijo `/api/v1/core` y llevan `Authorization: Bearer <JWT>` y `X-Correlation-ID`. El aliado, el cliente y el tenant salen del token, nunca del cuerpo. Detalle de cuerpos y respuestas en [`core.yaml`](https://github.com/Trama-AS/MANI-APIGateway/blob/develop/docs/openapi/core.yaml).

| Método y ruta | Quién | Historia | Éxito |
|---|---|---|---|
| `POST /solicitudes/{id}/cotizaciones` | Aliado asignado | 865 | 201 |
| `GET /solicitudes/{id}/cotizaciones` | Cliente dueño o aliado asignado | 865, 867 | 200 |
| `POST /cotizaciones/{id}/aceptar` | Cliente dueño | 867 | 200 |
| `POST /cotizaciones/{id}/rechazar` | Cliente dueño (motivo ≥ 5 caracteres) | 867 | 200 |
| `POST /cotizaciones/{id}/ajustar` | Cliente dueño (comentario ≥ 3 caracteres) | 867 | 200 |
| `GET /cotizaciones/{id}/evaluacion-tarifa` | Cliente dueño o aliado asignado | 866 | 200 |
| `POST /solicitudes/{id}/iniciar` | Aliado asignado | 868 | 200 |
| `POST /solicitudes/{id}/finalizar` | Aliado asignado | 868 | 200 |
| `GET /solicitudes/{id}/ejecucion` | Cliente dueño o aliado asignado | 868 | 200 |
| `POST /solicitudes/{id}/eventos` | Aliado asignado | 869, 873 | 201 (200 si la clave de idempotencia ya existía) |
| `GET /solicitudes/{id}/eventos` | Cliente dueño o aliado asignado | 870 | 200 |
| `GET /solicitudes/{id}/eventos/{eventoId}/evidencia` | Cliente dueño o aliado asignado | 869, 870 | 200 (URL temporal de la foto) |
| `POST /solicitudes/{id}/adiciones` | Aliado asignado | 872 | 201 |
| `GET /solicitudes/{id}/adiciones` | Cliente dueño o aliado asignado | 872 | 200 (adiciones y total vigente) |
| `POST /adiciones/{id}/aceptar` | Cliente dueño | 872 | 200 |
| `POST /adiciones/{id}/rechazar` | Cliente dueño | 872 | 200 |

Límites que valida Core: observación del inicio o del fin, 500 caracteres; observación de un evento, 2000; texto de la respuesta a una cotización, 500; tiempo adicional de una adición, hasta 7 días.

## 5. Errores `MANI-*`

Prefijos: `COT` cotización, `EJE` ejecución, `EVT` eventos, `ADI` adiciones. En los cuatro, el número es el código HTTP y la letra final distingue el caso.

**Comunes a los cuatro prefijos:**

| Código | HTTP | Cuándo |
|---|---|---|
| `MANI-xxx-400` | 400 | Datos inválidos: id mal formado, importe o texto fuera de formato o de longitud |
| `MANI-xxx-401` | 401 | Sin sesión o con token inválido |
| `MANI-xxx-403` | 403 | El rol no puede hacer la operación |
| `MANI-xxx-404` | 404 | La solicitud, la cotización o la adición no existen **o son de otro tenant o de otro cliente**: no se distingue, para no revelar que existen |

Cualquier operación puede responder además 503 si una dependencia no está disponible, y 500 ante un error no controlado.

**Específicos:**

| Código | HTTP | Cuándo | Operación |
|---|---|---|---|
| `MANI-COT-403A` | 403 | Quien cotiza no es el aliado asignado | Emitir |
| `MANI-COT-403C` | 403 | Quien responde no es un cliente activo | Aceptar, rechazar, ajustar |
| `MANI-COT-409E` | 409 | La solicitud no está en un estado que admita la operación (emitir: `ASIGNADA` o `COTIZANDO`; responder: `COTIZANDO`) | Emitir, responder |
| `MANI-COT-409P` | 409 | Ya hay una cotización pendiente de respuesta | Emitir |
| `MANI-COT-409R` | 409 | La cotización ya fue respondida | Responder |
| `MANI-EJE-403A` | 403 | Quien marca no es el aliado asignado | Iniciar, finalizar |
| `MANI-EJE-409E` | 409 | No se puede iniciar: falta la cotización aceptada | Iniciar |
| `MANI-EJE-409I` | 409 | La ejecución ya fue iniciada | Iniciar |
| `MANI-EJE-409F` | 409 | El servicio ya fue finalizado | Iniciar, finalizar |
| `MANI-EJE-409N` | 409 | No se puede finalizar un servicio que no ha iniciado | Finalizar |
| `MANI-EVT-400F` | 400 | La hora de captura está en el futuro (más de 5 min) | Registrar evento |
| `MANI-EVT-403A` | 403 | Quien registra no es el aliado asignado | Registrar evento |
| `MANI-EVT-409E` | 409 | La solicitud no está en ejecución | Registrar evento |
| `MANI-EVT-409T` | 409 | La hora de captura cae antes del inicio o después del fin | Registrar evento sin conexión |
| `MANI-EVT-404E` | 404 | El evento no tiene foto | Evidencia |
| `MANI-ADI-400T` | 400 | La adición supera el tope del 50 % | Pedir, aceptar |
| `MANI-ADI-403A` | 403 | Quien pide no es el aliado asignado | Pedir |
| `MANI-ADI-403C` | 403 | Quien decide no es un cliente activo | Aceptar, rechazar |
| `MANI-ADI-409C` | 409 | No hay cotización aceptada sobre la cual pedir | Pedir |
| `MANI-ADI-409E` | 409 | La solicitud no admite la operación (pedir: `EN_EJECUCION`; decidir: `EN_EJECUCION` o `FINALIZADA`) | Pedir, aceptar, rechazar |
| `MANI-ADI-409P` | 409 | Ya hay una adición pendiente de decisión | Pedir |
| `MANI-ADI-409R` | 409 | La adición ya fue decidida | Aceptar, rechazar |

La app muestra el texto que envía Core, sin el código. Al corte de esta página, las secciones de M-04 todavía no muestran el detalle «Código · Ref» que [SCRUM-1643](https://maniservices.atlassian.net/browse/SCRUM-1643) añadió en otros estados de error (ver §8).

## 6. Front (MANI-Flutter)

Una sola **pantalla del servicio**, `/cliente/solicitudes/:id/cotizacion` y `/aliado/solicitudes/:id/cotizacion`, armada en `_pantallaServicio` de `lib/core/routing/app_router.dart`. Cada parte tiene su cubit y consulta a Core por su lado:

| Parte | Código | Historias |
|---|---|---|
| Cotización y respuesta | `lib/features/services/quotes/` (`CotizacionPage`, `CotizacionCubit`) | 865, 867 |
| Alerta de tarifa | `AlertaTarifaCotizacion`, bajo la cotización vigente | 866 |
| Inicio y fin | `lib/features/services/execution/` (`EjecucionSeccion`, `EjecucionCubit`) | 868 |
| Bitácora y eventos | `lib/features/services/events/` (`EventosSeccion`, `EventosCubit`, cola sin conexión solo en móvil) | 869, 870, 873 |
| Adiciones | `lib/features/services/additions/` (`AdicionesSeccion`, `AdicionesCubit`) | 872 |

El botón «Pagar» del cliente cobra el total vigente que calcula Core. La actualización en vivo sin recargar está **en revisión** en [SCRUM-1644](https://maniservices.atlassian.net/browse/SCRUM-1644) ([MANI-Flutter#136](https://github.com/Trama-AS/MANI-Flutter/pull/136)): es sondeo HTTP cada 20 s, sin Supabase Realtime (ADR-0027).

## 7. Pruebas

| Repositorio | Archivos |
|---|---|
| MANI-Node, unitarias | `tests/unit/useCases/quotes/{quoteUseCases,respondQuoteUseCase}.test.js` · `tests/unit/useCases/services/{serviceExecutionUseCase,serviceEventsUseCase,eventEvidence}.test.js` · `tests/unit/useCases/additions/additionUseCases.test.js` · `tests/unit/repositories/pg{Quote,QuoteResponse,ServiceExecution,ServiceEvent,Addition}Repository.test.js` |
| MANI-Node, rutas | `tests/integration/routes/{quotes,quoteResponse,execution,serviceEvents,eventEvidence,additions}.routes.test.js` |
| MANI-Node, PostgreSQL real (solo en CI) | `tests/integration/pg/{cotizacion,respuestaCotizacion,ejecucionServicio,eventosServicio,transaccionEvento,trazabilidadEventos,adicionServicio}.pg.test.js` |
| MANI-Flutter | `test/features/services/quotes/{cotizacion,entradas_cotizacion}_test.dart` · `test/features/services/execution/ejecucion_test.dart` · `test/features/services/events/{eventos,cola_eventos}_test.dart` · `test/features/services/additions/adiciones_test.dart` · `test/features/payments/cotizacion_boton_pago_test.dart` |
| MANI-APIGateway | Colección `postman/MANI-Core.postman_collection.json`, que corre `qa/ejecutar_newman_qa.sh` en QA |

## 8. Puntos abiertos y discrepancias

- **[`SAD.md`](../SAD.md) §12.1 contra ADR-0027.** El SAD dice que «Supabase Realtime entrega eventos mientras los participantes están conectados». [ADR-0027](../adr/ADR-0027-alcance-supabase-cliente-flutter.md) deja a Supabase en Flutter solo para autenticación, y la app actualiza por sondeo HTTP (SCRUM-1644). Se reporta aquí para que lo resuelva la responsable del SAD. Esta página no lo corrige.
- **Errores de M-04 sin «Código · Ref» en la app.** `CotizacionFailure` y las secciones de cotización, ejecución, eventos y adiciones muestran solo el texto de Core. Llevarles el detalle de [SCRUM-1643](https://maniservices.atlassian.net/browse/SCRUM-1643) es trabajo de front no planificado: se le avisa a la SM, no se crea historia desde aquí.
- **[ADR-0035](../adr/ADR-0035-frontera-de-asignacion-6a.md) sigue `Propuesto`.** La frontera entre la asignación (M-05) y este módulo rige por decisión de la Scrum Master hasta que la Mesa lo ratifique.
- **Páginas relacionadas:** [Alerta de tarifa y proveedores externos](alerta-de-tarifa-y-proveedores-externos.md) ([SCRUM-1703](https://maniservices.atlassian.net/browse/SCRUM-1703)) y [Cola de eventos sin conexión](modulo-m04-cola-sin-conexion.md) ([SCRUM-1702](https://maniservices.atlassian.net/browse/SCRUM-1702)).

## 9. Historial

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-11-13 | Versión inicial, contrastada con core.yaml 0.32.0 y el código de MANI-Node y MANI-Flutter en `develop` al 2026-11-12 ([SCRUM-1701](https://maniservices.atlassian.net/browse/SCRUM-1701)) |

# Módulo M-04 — Cola de eventos sin conexión

[← 02 · Arquitectura](../README.md) · [Índice](../../Home.md) · [Módulo M-04: cotización y ejecución](modulo-m04-cotizacion-y-ejecucion.md)

**Fuente:** MANI-Flutter `lib/features/services/events/` (`data/cola_eventos.dart`, `data/almacen_cola_eventos_io.dart`, `data/almacen_cola_eventos_web.dart`, `presentation/eventos_cubit.dart`, `presentation/eventos_seccion.dart`) y `lib/core/di/injection_container.dart` · MANI-Node `src/infrastructure/repositories/PgServiceEventRepository.js` y `db/migrations/0026_evento_servicio_ocurrido_en.sql` · contrato [`core.yaml`](https://github.com/Trama-AS/MANI-APIGateway/blob/develop/docs/openapi/core.yaml) 0.32.0, `POST /solicitudes/{id}/eventos`.

Esta página es de la capa **guía**: explica lo que ya está construido y no decide nada. Si contradice al código, manda el código y esta página se corrige.

| Campo | Valor |
|---|---|
| **Finalidad** | Explicar cómo funciona la cola de eventos sin conexión del aliado, cómo se reintenta y cuáles son sus límites |
| **Mantiene** | Nicolás Álvarez (desarrollo de M-04) |
| **Consume** | Desarrollo (front y Core), QA (casos sin conexión), PO (validar los límites que decidió) |
| **Cada cuánto se actualiza** | Cuando cambia la cola, sus límites o la validación de la hora de captura en Core |
| **Versión y fecha** | 1.0 · 2026-11-13 |
| **Corte del código** | MANI-Flutter `develop` `dceebca` · MANI-Node `develop` `24fdc94` · core.yaml 0.32.0, del 2026-11-12 |
| **Historias** | Funcionalidad: [SCRUM-873](https://maniservices.atlassian.net/browse/SCRUM-873) (US-04.3.6) · Esta página: [SCRUM-1702](https://maniservices.atlassian.net/browse/SCRUM-1702) (T-57) |

## 1. Para qué existe

Durante la ejecución, el aliado registra eventos (avance, novedad, observación, foto) en sitios donde a menudo no hay señal. Sin la cola, ese evento se perdía y había que volver a tomarlo. Con la cola, el evento queda guardado en el teléfono **con la hora en que se tomó** y se envía a Core cuando vuelve la conexión. Esa hora de captura es la oficial: la decisión es de la PO (comentario 10549 de SCRUM-873, 27-oct-2026).

**Solo en el móvil.** En la web no hay modo sin conexión (decisión de la PO): el almacén web está siempre «no disponible» y, sin red, el evento falla con su mensaje de error como cualquier otra acción.

## 2. Cómo funciona

```text
Aliado registra un evento ──► POST /solicitudes/{id}/eventos (con clave de idempotencia)
        │
        ├─ Core responde ──────────────► evento registrado (fin)
        ├─ Core rechaza (4xx) ─────────► se muestra el motivo; no se encola
        └─ falla por falta de red ─────► se encola con:
                                          clave del intento, usuario, solicitud, tipo,
                                          observación, foto y hora de captura (UTC)
                                          ▼
                              «N eventos pendientes de enviar» sobre la bitácora,
                              cada uno como «Pendiente de enviar» con su hora
```

Solo se encola cuando el envío falla por **falta de conexión**. Cualquier otra falla (permiso, datos inválidos, solicitud fuera de ejecución) se muestra enseguida y el evento no se guarda.

**Dónde se guarda.** En archivos privados de la app, en la carpeta `cola_eventos` del directorio de soporte de la aplicación. Hay un índice `cola.json` con los datos de cada evento y una foto por evento en un archivo aparte (`<clave>.foto`). Cada escritura reemplaza el índice con un archivo temporal y un `rename`, así que un cierre a mitad de camino no lo corrompe. Una fila incompleta, o cuya foto falta, se descarta: es mejor no enviarla que enviar un evento distinto al que tomó el aliado.

**De quién es.** La cola es del usuario de la sesión. Solo se envían y se muestran los eventos de ese usuario, y la cola entera se vacía cuando la sesión se cierra (`AuthChangeEvent.signedOut`).

## 3. Cómo se reintenta

La pantalla del servicio intenta enviar la cola en tres momentos:

1. **Al abrirla.** Después de cargar la bitácora.
2. **Cada 30 s** mientras queden pendientes de esa solicitud. El temporizador se apaga solo cuando no queda nada.
3. **Cuando el aliado lo pide**, con el botón de enviar pendientes que aparece junto al contador.

En cada ronda:

- Se envían **todos** los pendientes del usuario, de cualquier solicitud y **en el orden en que se registraron**. Cada uno lleva su clave de idempotencia y su hora de captura (`ocurridoEn`).
- Si un envío falla por algo **pasajero** (sin conexión, servicio no disponible, 5xx, sesión vencida o una respuesta que la app no reconoce), el evento **se queda** en la cola y la ronda se corta. El siguiente intento empieza por él, así que se conserva el orden.
- Si Core lo **rechaza** de forma definitiva (400, 403, 404 o 409), el evento **sale** de la cola y el aliado ve el motivo.
- Nunca se marca un evento como enviado sin respuesta de Core.
- Hay una sola ronda a la vez: si ya hay una en curso, la nueva espera esa.
- Si algo se envió, la bitácora se vuelve a leer y el aliado ve «Se envió 1 evento que estaba pendiente» o «Se enviaron N eventos…».

**Sin duplicados.** El evento encolado conserva la clave del intento original. Si ese intento sí había llegado a Core y solo se perdió la respuesta, Core encuentra la clave y devuelve el evento que ya tenía: **200** en lugar de 201, sin crear otro. Core revisa la clave **antes** que el estado de la solicitud, así que esto funciona aunque el servicio haya finalizado mientras el teléfono estaba sin señal.

## 4. Qué valida Core al recibirlo

La hora de captura queda en la columna `evento_servicio.ocurrido_en` (migración `0026`). La hora del servidor (`timestamp`) se sigue guardando aparte para auditoría. La bitácora se ordena por `ocurrido_en` y, en los eventos que no la tienen, por `timestamp`.

| Regla | Si no se cumple |
|---|---|
| La solicitud está `EN_EJECUCION`, o `FINALIZADA` si la hora de captura cae dentro de la ejecución | `409 MANI-EVT-409E` |
| La hora de captura no está más de **5 minutos** en el futuro (margen para el reloj del teléfono) | `400 MANI-EVT-400F` |
| La hora de captura está **entre el inicio y el fin** de la ejecución | `409 MANI-EVT-409T` |
| Quien envía es el aliado asignado | `403 MANI-EVT-403A` |

Gracias a esa ventana, un evento tomado sin señal entra **aunque el servicio ya haya finalizado** cuando el teléfono recupera la conexión, siempre que se haya tomado mientras el servicio estaba en ejecución. Un servicio cancelado nunca acepta eventos.

## 5. Límites

| Límite | Valor | Qué ve el aliado |
|---|---|---|
| Eventos en cola | **20** (decisión de la PO) | Al intentar el 21: «Tienes 20 eventos o 50 MB pendientes de enviar. Conéctate para enviarlos antes de registrar más.» El evento no se guarda |
| Tamaño de la cola | **50 MB**, sumando fotos y observaciones (decisión de la PO) | El mismo mensaje |
| Plataforma | Solo móvil | En la web el evento falla sin red, como cualquier otra acción |
| Observación | 2000 caracteres (lo valida Core) | Error de datos inválidos al enviar |

Límites de comportamiento que conviene conocer:

- **Solo se envía con una pantalla de servicio abierta.** No hay envío en segundo plano: si el aliado recupera la señal pero no abre ninguna pantalla de servicio, los eventos siguen en el teléfono. Al abrir cualquier servicio se envían los de todas las solicitudes.
- **Cerrar sesión borra la cola.** Los pendientes de ese usuario se pierden, y la app no avisa antes (ver §7).
- **Un solo motivo por ronda.** Si Core rechaza varios eventos en la misma ronda, todos salen de la cola pero el aviso muestra el motivo del primero.
- **La hora de captura es la del reloj del teléfono**, convertida a UTC. Core la acepta con hasta 5 minutos de adelanto y la rechaza si queda fuera de la ejecución.

## 6. Pruebas

| Repositorio | Archivos |
|---|---|
| MANI-Flutter | `test/features/services/events/cola_eventos_test.dart`, en tres grupos: `ColaEventos` (orden, clave y hora de captura, pasajero frente a definitivo, cola por usuario, sin rondas dobles), `AlmacenColaEnArchivos` (índice dañado o fila sin foto) y `EventosCubit sin conexión` (encolado con la clave del intento, cola llena, un rechazo distinto de la red no se encola, pendientes en la bitácora) · `test/features/services/events/eventos_test.dart` (registro y bitácora en línea) |
| MANI-Node | `tests/unit/repositories/pgServiceEventRepository.test.js` · `tests/unit/useCases/services/serviceEventsUseCase.test.js` · `tests/integration/routes/serviceEvents.routes.test.js` · `tests/integration/pg/eventosServicio.pg.test.js` (PostgreSQL real, solo en CI) |

## 7. Puntos abiertos

- **Cerrar sesión con eventos pendientes los borra sin avisar.** Es lo que pide el criterio C3 de SCRUM-873 (la cola es del usuario y se borra al cerrar su sesión), pero la app no advierte que hay pendientes antes de cerrar. Un aviso o una confirmación sería trabajo de front sin historia: se le avisa a la SM, no se crea historia desde aquí.
- **Sin envío en segundo plano.** Hoy no está pedido. Si la PO lo quiere, es una historia nueva (servicio en segundo plano en Android e iOS).

## 8. Historial

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-11-13 | Versión inicial, contrastada con MANI-Flutter y MANI-Node en `develop` al 2026-11-12 ([SCRUM-1702](https://maniservices.atlassian.net/browse/SCRUM-1702)) |

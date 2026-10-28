# Matriz de la decisión 6A — propiedad del estado del servicio

Entregable E3 de TEC-01 (SCRUM-1448). Sirve para comprobar, de un vistazo, que la decisión 6A
quedó escrita igual en todos los documentos y que cada parte técnica tiene una historia
responsable. **Esta matriz no decide nada**: refleja lo decidido el 26 de octubre de 2026 y dónde
está registrado.

- **Decisión:** Core Node es el único propietario y escritor del estado canónico del servicio,
  desde la creación y también después de la asignación. Dispatch .NET conserva la elegibilidad, la
  oferta y la decisión de asignación, y comunica el resultado a Core mediante un contrato
  idempotente. Queda prohibida la escritura directa por Dispatch de las tablas de estado del
  dominio de Core.
- **Decidió:** Sara Albarracín Niño (Scrum Master), 2026-10-26.
- **Cierra:** el pendiente P1 de SAD §7.4, abierto desde el 17 de octubre.

## Decisión → documento

| Qué afirma la decisión | Documento | Dónde | Estado |
|---|---|---|---|
| Dispatch no crea la solicitud ni escribe su estado | SAD | §7.2 Dispatch Service | Sincronizado |
| Core es dueño del estado antes y después de la asignación | SAD | §7.4, tabla «Dueño de los datos» | Sincronizado |
| Dispatch no escribe tablas de estado del dominio de Core | SAD | §7.4, «Lo que cada servicio no hace» | Sincronizado |
| El resultado de la asignación viaja por contrato, no por escritura directa | SAD | §7.4, «Flujo de RF-12 a RF-16» | Sincronizado |
| La decisión y su contrato quedan registrados, y P1 cerrado | SAD | §7.4, «Decidido» y «Contrato de asignación Dispatch → Core» | Sincronizado |
| La actualización condicional atómica la emite Core, no Dispatch | ADR-0022 | Decisión, viñetas de responsabilidad y de exclusión concurrente | Sincronizado |
| Core es el único escritor de `solicitud` | ModeloDatos | §6.1, punto abierto de DOC4-04 | Sincronizado en cuanto a propiedad; la **ubicación** de la tabla sigue abierta |
| La frontera se aplica en la base de datos | ADR-0030 | §1, propiedad de la serie de migraciones | Sin cambios: 6A no altera quién posee el esquema |
| La exclusión concurrente se resuelve con actualización condicional atómica | ADR-0016 | Decisión | Sin cambios: 6A cambia **quién la emite**, no el mecanismo |

## Decisión → contrato

| Aspecto | Definición | Dónde está especificado |
|---|---|---|
| Operación | `POST /api/v1/core/solicitudes/{id}/asignacion` | SAD §7.4 |
| Actor y tenant | JWT del aliado reenviado por Dispatch; cuerpo vacío | SAD §7.4 |
| Idempotencia | Mismo aliado repite sin efecto; responde `asignada: false` | SAD §7.4 |
| Concurrencia | `FOR UPDATE` y predicado repetido en el `UPDATE` (ADR-0016) | SAD §7.4 |
| Trazabilidad | `correlationId` propagado y registro JSON por intento (QS-12) | SAD §7.4 |
| Errores | 409 `MANI-SOL-409` / `MANI-SOL-409E`; 403 según motivo; 404; 503 sin lógica local (T2) | SAD §7.4 |

## Decisión → historia responsable

| Trabajo técnico | Historia | Dónde vive |
|---|---|---|
| Core registra la asignación que decide Dispatch | SCRUM-1403 (HU-M05-07) | MANI-Node |
| Bandeja del aliado con descripción y fotos | SCRUM-1402 (HU-M05-06) | MANI-Node |
| Complemento de la frontera de asignación | SCRUM-1404 (HU-M05-08) | MANI-Node |
| Frontera en base de datos: revocar `UPDATE` a Dispatch y retirar la política de escritura directa | SCRUM-1403 | `MANI-Node/db/migrations/0019_frontera_asignacion_6a.sql` |
| Conciliación documental de la decisión | TEC-01 (SCRUM-1448) | MANI-docs, este cambio |
| Ratificación de ADR-0030 y ADR-0016 en Mesa | TEC-12 (SCRUM-1459) | Mesa de Arquitectura |

Ningún cambio técnico se da por implementado en este documento: cada fila remite a la historia y al
repositorio donde se verifica.

## Lo que queda abierto

| Qué | Por qué no se cierra aquí | A quién corresponde |
|---|---|---|
| Ubicación física de la tabla `solicitud` (hoy bajo `despacho`) | Mover el esquema afecta DDL ya aplicado | Dueño de la serie de migraciones (ADR-0030 §1) |
| Ratificación en Mesa de ADR-0022 y ADR-0030 | Se ratificaron sin sesión de Mesa registrada, que ADR-0003 §2 exige | Mesa de Arquitectura, vía TEC-12 (SCRUM-1459) |
| Evidencia de QA de la frontera en un ambiente desplegado | Esta tarea es documental; lo verificado hasta ahora es código y migración | QA, con la subtarea de TEC-01 |

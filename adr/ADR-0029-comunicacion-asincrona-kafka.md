# ADR-0029 — Comunicación asíncrona entre servicios y adopción de Apache Kafka

- **Estado:** Propuesto — adopción diferida al Sprint 5
- **Decisión de:** comunicación entre servicios
- **Autor:** Sara Albarracín Niño
- **Fecha:** 2026-10-17
- **Jira:** ARQ-04 (SCRUM-1235)
- **Relacionado con:** ADR-0016, ADR-0017, ADR-0019, ADR-0022, ADR-0030, RNF-05, RNF-07

---

## Contexto

La planificación del Sprint 4 derivó de la decisión de mantener Node.js, Java y .NET, una base PostgreSQL compartida y **Kafka para eventos de negocio**. Sobre ese supuesto se abrieron seis tareas: ARQ-05 (Kafka en DEV y QA), ARQ-06 (esquema y versionado de eventos), ARQ-07 (publicación con *transactional outbox*), ARQ-08 (consumidores idempotentes), DOC4-05 (Infraestructura V3) y la sección de eventos de DOC4-06 (SDD V3).

Ninguna de esas tareas podía avanzar porque **la decisión nunca se registró**: no existe ADR de mensajería asíncrona en `adr/` (ADR-0017 decide Supabase Realtime y FCM/APNs para notificación al usuario, que es otra cosa: transporta eventos hacia el cliente, no integra servicios entre sí). La matriz de pruebas del Sprint 4 lo registra como brecha B-06: «Kafka sin ADR ni infraestructura».

Estado verificado el 2026-10-17, antes de decidir:

- No hay ADR de bus de eventos ni de mensajería asíncrona entre servicios.
- No hay infraestructura de Kafka en ningún ambiente (ARQ-05 sin iniciar).
- Ningún repositorio publica ni consume eventos: no hay productor, consumidor, tópico ni esquema en Core, Rules ni Dispatch.
- La integración entre servicios que **sí** existe hoy es sincrónica por HTTP y funciona: Core consume la evaluación de reglas del Rules Service con `RulesServiceHttpClient` (timeout de 3 s, un reintento, `503` si Rules no responde).
- La exclusión concurrente del despacho se resuelve con una actualización condicional atómica en PostgreSQL (ADR-0016), dentro de una transacción. No participa ningún evento.

## Alternativas

1. **Adoptar Kafka dentro del Sprint 4.** Descartada. Exige, como mínimo: infraestructura en DEV y QA con seguridad y observabilidad, esquema y versionado de eventos, publicación con outbox y consumidores idempotentes con reintentos y gestión de mensajes fallidos. Es una capacidad de infraestructura completa, y el dueño de infraestructura ya es la ruta crítica del sprint con CFG4-03 (SonarQube, Newman y Playwright sin operar en QA), que es lo que hoy impide ejecutar los 228 casos de prueba diseñados. Competir con eso cambia el cuello de botella de lugar sin resolverlo.
2. **Declarar que MANI no usará mensajería asíncrona.** Descartada. El desacoplamiento temporal entre crear una solicitud y repartirla, y entre asignar y notificar, es un problema real de este dominio; cerrar la puerta por conveniencia de un sprint sería una decisión de arquitectura tomada por calendario.
3. **Registrar la decisión ahora y diferir la adopción al Sprint 5, dejando fijados el contrato de eventos y la garantía de publicación.** Elegida.

## Decisión

**MANI adopta un bus de eventos con Apache Kafka para la integración asíncrona entre servicios, y la implementación se difiere al Sprint 5.** Durante el Sprint 4 la integración entre servicios es exclusivamente **HTTP sincrónico a través de la red interna**, con el patrón ya validado en Core → Rules: puerto declarado en el dominio, cliente en infraestructura, *timeout*, reintento solo para operaciones idempotentes y **falla cerrado** (`503` hacia el llamador, nunca degradar a lógica local).

Lo que queda fijado desde ahora, aunque no se implemente:

### 1. Eventos de negocio mínimos

| Evento | Servicio dueño (único productor) | Se emite cuando |
|---|---|---|
| `SolicitudCreada` | Core Service | una solicitud queda persistida y lista para repartirse |
| `AliadoAsignado` | Dispatch Service | la actualización condicional de ADR-0016 confirma la asignación |
| `CotizacionAceptada` | Core Service | el cliente acepta una cotización validada contra el tarifario |
| `ServicioFinalizado` | Core Service | la ejecución del servicio concluye y la solicitud pasa a `FINALIZADA` (RF-18, RF-19) |

Cada evento tiene un único productor: el servicio dueño de la capacidad según ADR-0022. Ningún servicio emite un evento de un dominio ajeno.

### 2. Sobre común y versionado

Todo evento viaja con un sobre obligatorio:

```json
{
  "event_id": "uuid",
  "event_type": "SolicitudCreada",
  "event_version": 1,
  "occurred_at": "2026-10-17T10:00:00Z",
  "tenant_id": "uuid",
  "correlation_id": "...",
  "partition_key": "uuid",
  "data": { }
}
```

- `tenant_id` es obligatorio: el aislamiento multi-tenant (RNF-01) también aplica a los eventos, y un consumidor no puede inferir el tenant del contenido.
- `correlation_id` continúa el `X-Correlation-ID` que el Gateway ya propaga, para que una transacción se pueda seguir de extremo a extremo atravesando el bus (RNF-07).
- `partition_key` fija `id_solicitud` como clave de partición común de los cuatro eventos para garantizar orden causal por solicitud.
- `event_version` se incrementa solo ante cambios incompatibles; un cambio compatible agrega campos opcionales. El esquema formal `v1` de cada evento y la política de versionado se especifican en [`architecture/CONTRATOS_EVENTOS.md`](../architecture/CONTRATOS_EVENTOS.md) (ARQ-06 / SCRUM-1237).

### 3. La publicación usa transactional outbox, obligatorio desde la primera implementación

Un servicio **no** escribe en la base y publica en el broker en dos operaciones separadas. Escribe el evento en una tabla *outbox* dentro de la misma transacción que el cambio de estado, y un proceso aparte lo publica y lo marca como enviado.

Esto no es una preferencia de estilo: `AliadoAsignado` se emite justo después de la asignación que ADR-0016 garantiza como única. Con doble escritura, una caída entre el *commit* y la publicación deja una solicitud asignada sin evento, o publica dos veces el mismo evento tras un reintento. Lo primero rompe el flujo; lo segundo produce una segunda asignación aparente, que es exactamente lo que RNF-05 prohíbe y lo que la PoC-001 se usó para demostrar que no ocurre. Los consumidores, por su parte, son idempotentes por `event_id` (ARQ-08).

### 4. Qué no cubre este ADR

La notificación al usuario final sigue gobernada por **ADR-0017** (Supabase Realtime y FCM/APNs). Este ADR decide la integración *entre servicios*; no reemplaza ni modifica ADR-0017.

## Justificación

Separar «decidir» de «implementar» resuelve el bloqueo real: las seis tareas detenidas lo estaban por falta de decisión registrada, no por falta de capacidad. Con el contrato de eventos y la garantía de publicación fijados, ARQ-06 tiene qué revisar y DOC4-05 y DOC4-06 tienen qué documentar, mientras la infraestructura se planifica para el Sprint 5 sin competir con lo que hoy impide ejecutar las pruebas.

Diferir no cuesta nada funcionalmente: ningún flujo del incremento actual necesita el bus. La integración viva es Core → Rules por HTTP, y la garantía crítica del despacho es una transacción en PostgreSQL.

## Consecuencias

### Positivas

- Desbloquea las seis tareas: tres pueden avanzar como diseño y documentación, tres quedan planificadas con alcance explícito.
- Fija el contrato de eventos antes de que existan productores, que es cuando sale barato.
- La obligación de outbox queda registrada antes de la primera implementación, y no como corrección posterior que exigiría reescribir los publicadores.
- No añade superficie operativa a un sprint con 14 PR abiertos y la ejecución de pruebas aún sin arrancar.

### Negativas

- El desacoplamiento temporal se retrasa un sprint: la creación de la solicitud y su reparto siguen acopladas en el tiempo por una llamada HTTP.
- Las tareas ARQ-05 a ARQ-08 salen del alcance del Sprint 4 y hay que reestimarlas en el Planning del Sprint 5.
- Una dependencia HTTP caída se traduce en `503` al usuario, sin posibilidad de reintento diferido. Es el comportamiento correcto por ahora (falla cerrado), pero es una limitación que el bus resolvería.
- La matriz de pruebas del Sprint 4 no cubre escenarios de eventos; QA no debe ejecutar casos de Kafka en este sprint.

## Condición de revisión

Revisar si en el Planning del Sprint 5 la capacidad de infraestructura sigue comprometida con CFG4-03 y la consolidación de ambientes, en cuyo caso el diferimiento se extiende con una fecha nueva y registrada; o si aparece un requisito de entrega garantizada o de reproceso que el camino sincrónico no pueda sostener, en cuyo caso la adopción se adelanta.

## Trazabilidad

| Elemento | Referencia |
|---|---|
| ADR relacionados | ADR-0016 (exclusión concurrente), ADR-0017 (realtime y push), ADR-0019 (SOA políglota), ADR-0022 (lógica en servicios), ADR-0030 (propiedad del esquema y frontera de datos) |
| Tareas desbloqueadas como diseño | SCRUM-1237 (ARQ-06), SCRUM-1248 (DOC4-05), SCRUM-1249 (DOC4-06) |
| Tareas diferidas al Sprint 5 | SCRUM-1236 (ARQ-05), SCRUM-1238 (ARQ-07), SCRUM-1239 (ARQ-08) |
| Brecha de QA que cierra | B-06 de la matriz de pruebas del Sprint 4 (SCRUM-1264) |
| Requisitos | RNF-01, RNF-05, RNF-07 |

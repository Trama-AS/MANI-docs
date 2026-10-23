# PoC-ARQ06 — Verificación ejecutable de esquemas y versionado de eventos (`SCRUM-1237`)

Este directorio contiene los esquemas formales **JSON Schema (Draft 2020-12)** y el verificador ejecutable para los cuatro eventos de negocio definidos en [`architecture/CONTRATOS_EVENTOS.md`](../../../02-arquitectura/CONTRATOS_EVENTOS.md):

1. `schemas/event-envelope.v1.schema.json` — Sobre común obligatorio (`event_id`, `event_type`, `event_version`, `occurred_at`, `tenant_id`, `correlation_id`, `partition_key`, `data`).
2. `schemas/solicitud-creada.v1.schema.json` — `SolicitudCreada` (`v1`, Core Service → `servicio.outbox`).
3. `schemas/aliado-asignado.v1.schema.json` — `AliadoAsignado` (`v1`, Dispatch Service → `despacho.outbox`).
4. `schemas/cotizacion-aceptada.v1.schema.json` — `CotizacionAceptada` (`v1`, Core Service → `servicio.outbox`).
5. `schemas/servicio-finalizado.v1.schema.json` — `ServicioFinalizado` (`v1`, Core Service → `servicio.outbox`).

---

## Ejecución

No requiere dependencias externas (usa el runtime estándar de Node.js `>= 20`):

```bash
node Entregas/PoC/PoC-ARQ06-esquema-versionado-eventos/validar_contratos_eventos.mjs
```

---

## Matriz de controles verificados (`C1`–`C12`)

| Caso | Qué verifica | Resultado esperado |
| :--- | :--- | :--- |
| `C1` | `SolicitudCreada v1` canónico y ruteo a `servicio.outbox` (`Core Service`) | `PASS` |
| `C2` | `AliadoAsignado v1` canónico y ruteo a `despacho.outbox` (`Dispatch Service`) | `PASS` |
| `C3` | `CotizacionAceptada v1` canónico y ruteo a `servicio.outbox` (`Core Service`) | `PASS` |
| `C4` | `ServicioFinalizado v1` canónico y ruteo a `servicio.outbox` (`Core Service`) | `PASS` |
| `C5` | Rechazo de evento sin `tenant_id` (`RNF-01`) | `PASS` (`REJECT_ENVELOPE`) |
| `C6` | Rechazo de evento sin `correlation_id` (`RNF-07`) | `PASS` (`REJECT_ENVELOPE`) |
| `C7` | Rechazo cuando `partition_key != data.id_solicitud` (orden causal por solicitud) | `PASS` (`REJECT_PARTITION_KEY`) |
| `C8` | Rechazo en `CotizacionAceptada` si `valor_total != valor_mano_obra + valor_materiales` | `PASS` (`REJECT_INVARIANT`) |
| `C9` | *Strict Producer*: rechazo de PII (`direccion`) o propiedades no declaradas en el contrato | `PASS` (`REJECT_PAYLOAD`) |
| `C10` | *Tolerant Reader*: consumidor `v1` acepta campo opcional adicional sin subir `event_version` | `PASS` (`ACCEPT`) |
| `C11` | Rechazo de cambio incompatible de tipo de dato dentro de la misma versión `v1` | `PASS` (`REJECT_PAYLOAD`) |
| `C12` | Encaminamiento controlado a DLQ ante `event_version` mayor no soportada | `PASS` (`ROUTE_TO_DLQ_UNSUPPORTED_VERSION`) |

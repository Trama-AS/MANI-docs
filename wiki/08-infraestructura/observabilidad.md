# Observabilidad

[← 04 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md) §17 · [`architecture/SAD.md`](../02-arquitectura/SAD.md) §19 · [`governance/INFRAESTRUCTURA_MANI.md`](README.md) §20 · [`adr/ADR-0006`](../02-arquitectura/adr/ADR-0006-observabilidad.md).

| Campo | Valor |
|---|---|
| **Finalidad** | Decir con qué herramientas se observa el sistema y qué debe emitir cada servicio |
| **Mantiene** | La página: Nicolás Álvarez (responsable de la carpeta). La fuente: DevOps |
| **Consume** | Desarrollo, DevOps, QA |
| **Cada cuánto se actualiza** | Cuando cambia ADR-0006 o una herramienta de observabilidad |
| **Versión y fecha** | Viva, sin número · contenido del 2026-11-13; ficha añadida el 2026-11-16 ([SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694)) |
| **Origen y destino** | Atributo de calidad (mantenibilidad) → ADR-0006 → métricas y logs → tablero |

| Herramienta | Para |
|---|---|
| **Prometheus** | Métricas: disponibilidad, latencia, throughput, errores, CPU, memoria, métricas de runtime |
| **Grafana** | Dashboards operativos |
| **Jira** | Destino de incidentes relevantes; las alertas críticas pueden generar o alimentar issues |

## Obligaciones de los servicios

- emitir **logs estructurados**;
- propagar **`correlation_id`** en requests distribuidos — es obligación arquitectónica (SAD §19) y umbral de mantenibilidad (SDD §7.5);
- exponer la telemetría necesaria para que la saturación se detecte por observabilidad, no por reporte de usuario (SDD §7.4);
- tener telemetría de las operaciones críticas antes de promover a producción (SDD §19.6).

Extender la observabilidad al Gateway y a todos los servicios es la tarea `CFG-30` del backlog de transición.

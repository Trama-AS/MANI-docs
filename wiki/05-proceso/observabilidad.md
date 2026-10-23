# Observabilidad

[← 03 · Entrega](../03-entrega/README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../07-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md) §17 · [`architecture/SAD.md`](../02-arquitectura/SAD.md) §19 · [`governance/INFRAESTRUCTURA_MANI.md`](../07-gobernanza/INFRAESTRUCTURA_MANI.md) §20 · [`adr/ADR-0006`](../02-arquitectura/adr/ADR-0006-observabilidad.md).

| Herramienta | Para |
|---|---|
| **Prometheus** | Métricas: disponibilidad, latencia, throughput, errores, CPU, memoria, métricas de runtime |
| **Grafana** | Dashboards operativos |
| **Datadog** | APM, logs centralizados, trazas y alertas |
| **Jira** | Destino de incidentes relevantes; las alertas críticas pueden generar o alimentar issues |

## Obligaciones de los servicios

- emitir **logs estructurados**;
- propagar **`correlation_id`** en requests distribuidos — es obligación arquitectónica (SAD §19) y umbral de mantenibilidad (SDD §7.5);
- exponer la telemetría necesaria para que la saturación se detecte por observabilidad, no por reporte de usuario (SDD §7.4);
- tener telemetría de las operaciones críticas antes de promover a producción (SDD §19.6).

Extender la observabilidad al Gateway y a todos los servicios es la tarea `CFG-30` del backlog de transición.

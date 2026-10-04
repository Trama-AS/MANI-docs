# Observabilidad

[← 03 · Entrega](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §17 · [`architecture/SAD.md`](../../architecture/SAD.md) §19 · [`governance/INFRAESTRUCTURA_MANI.md`](../../governance/INFRAESTRUCTURA_MANI.md) §20 · [`adr/ADR-0006`](../../adr/ADR-0006-observabilidad.md).

| Herramienta | Para |
|---|---|
| **Prometheus** | Métricas: disponibilidad, latencia, throughput, errores, CPU, memoria, métricas de runtime |
| **Grafana** | Dashboards operativos |
| **Datadog** | APM, logs centralizados, trazas y alertas |
| **Jira** | Destino de incidentes relevantes; las alertas críticas pueden generar o alimentar issues |

## Obligaciones de los servicios

- emitir **logs estructurados**;
- propagar **`correlation_id`** en requests distribuidos — es además umbral de mantenibilidad (SAD §20.4);
- exponer la telemetría necesaria para que la saturación se detecte por observabilidad, no por reporte de usuario (SAD §20.3);
- tener telemetría de las operaciones críticas antes de promover a producción (SDD §19.6).

Extender la observabilidad al Gateway y a todos los servicios es la tarea `CFG-30` del backlog de transición.

# ADR-0006 — Observabilidad distribuida y gestión de incidentes

- **Estado:** Aceptado
- **Decisión de:** operación y monitoreo
- **Relacionado con:** ADR-0004, ADR-0019

## Contexto

La arquitectura distribuida necesita métricas, logs y trazas correlacionables para diagnosticar fallos entre Gateway y servicios.

## Alternativas

1. **ELK autoalojado como solución única.** Descartada por carga operativa.
2. **Observabilidad ligada a un proveedor cloud.** Descartada por acoplamiento.
3. **Prometheus + Grafana + Datadog + Jira.** Elegida.

## Decisión

MANI utiliza:
- Prometheus para métricas;
- Grafana para dashboards;
- Datadog para logs, APM y trazas;
- `correlation_id` para seguimiento entre servicios;
- logs estructurados en JSON;
- alertas críticas vinculadas a Jira.

La instrumentación cubre NGINX/API Gateway, Java, .NET, Node.js y Kubernetes.

## Justificación

Permite diagnosticar sistemas distribuidos y medir los umbrales de calidad definidos en el SDD.

## Consecuencias

### Positivas
- Diagnóstico transversal.
- Métricas para rendimiento, disponibilidad y capacidad.

### Negativas
- Coste adicional de instrumentación y retención de telemetría.

## Condición de revisión

Revisar si se consolida el stack de observabilidad en una única plataforma sin perder capacidades.

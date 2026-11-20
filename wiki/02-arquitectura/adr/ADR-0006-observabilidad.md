# ADR-0006 — Observabilidad distribuida y gestión de incidentes

- **Estado:** `Aceptado` · **enmendado el 2026-11-13 para retirar Datadog, y la enmienda ratificada por la Scrum Master (Sara Albarracín) el 2026-11-19**, sin sesión de Mesa, por el mismo motivo que las demás de esa fecha. **La Mesa puede confirmarla o revertirla.**
- **Decisión de:** operación y monitoreo
- **Origen (declarado el 2026-11-19):** **`PROY-09`** — el proyecto exige observabilidad propia con Prometheus, Grafana y Loki. **La restricción se escribió el 2026-11-16**, después de este ADR: hasta entonces la decisión no tenía requisito detrás, y esa ausencia es la que permitió que tres documentos del proyecto se contradijeran sobre si la observabilidad existía. Compromete **QAS-22** (analizabilidad).
- **Relacionado con:** ADR-0004, ADR-0019

## Contexto

La arquitectura distribuida necesita métricas, logs y trazas correlacionables para diagnosticar fallos entre Gateway y servicios.

## Alternativas

1. **ELK autoalojado como solución única.** Descartada por carga operativa.
2. **Observabilidad ligada a un proveedor cloud.** Descartada por acoplamiento.
3. **Prometheus + Grafana + Datadog + Jira.** Elegida en su momento; **Datadog retirado por la enmienda del 2026-11-13.**
4. **Prometheus + Grafana + Jira.** Vigente desde la enmienda del 2026-11-13.

## Decisión

MANI utiliza:
- Prometheus para métricas;
- Grafana para dashboards;
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

## Enmienda del 2026-11-13 — se retira Datadog

**Decidido por la Scrum Master el 2026-11-13 y ratificado por ella misma el 2026-11-19**, sin sesión de Mesa de Arquitectura. [ADR-0003](ADR-0003-mesa-arquitectura.md) reserva la ratificación a la Mesa; no se convocó ninguna en el Sprint 6 y la enmienda ya estaba aplicada en los documentos y en la infraestructura. **La Mesa puede confirmarla o revertirla** cuando se reúna, y entonces esta ratificación y su fecha quedan en el historial como lo que fueron.

**Qué cambia.** La decisión era «Prometheus + Grafana + Datadog + Jira». Se retira **Datadog**. Quedan **Prometheus** para métricas, **Grafana** para tableros y **Jira** como destino de incidentes.

**Por qué.** La observabilidad con **Prometheus y Grafana la exige el profesor** como entregable del corte académico, y es lo que efectivamente se está desplegando. Datadog no se ha aprovisionado, no aparece en ningún ambiente y nadie lo ha operado: mantenerlo en un ADR `Aceptado` lo presentaba como decisión vigente del equipo cuando era una intención.

**El hueco que esto deja, y que no se tapa.** Datadog cubría en el papel **APM, logs centralizados y trazas**. Prometheus y Grafana **no cubren eso**: dan métricas y tableros. Tras esta enmienda, APM, logs centralizados y trazas **no tienen herramienta asignada**. Queda declarado como hueco, no como función cubierta por otra vía. Lo que sí sobrevive de la decisión original es el `correlation_id` y los logs estructurados en JSON, que son prácticas de código y no dependen de la herramienta.

**Lo que no hace esta enmienda.** No adopta Loki ni ningún sustituto: eso sería decidir sin requisito. No se retira el número ni se renumera el ADR, porque los números de ADR **no se reutilizan** (regla del registro, `README.md` §4) y porque un documento obsoleto se marca, no se borra (regla 8 de `GOBIERNO_DEL_EQUIPO.md`).

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.2 | 2026-11-19 | La enmienda que retiró Datadog queda **ratificada por la Scrum Master, sin Mesa**, junto con ADR-0036, ADR-0037 y ADR-0038. El motivo y la reversibilidad quedan escritos en el apartado de la enmienda. | Sara Albarracín |
| 1.1 | 2026-11-13 | Se retira Datadog. Quedan Prometheus, Grafana y Jira, que es lo exigido y lo que se despliega. Se declara el hueco de APM, logs y trazas en vez de darlo por cubierto. Decidido por la SM; pendiente de ratificación en Mesa. | Sara Albarracín |
| 1.0 | — | Decisión original: Prometheus + Grafana + Datadog + Jira. | — |


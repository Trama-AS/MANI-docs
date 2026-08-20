# ADR-0006: Observabilidad, Monitoreo Continuo y Gestión Automatizada de Incidentes (Prometheus, Grafana, Datadog y Jira)

- Fecha: 2026-08-19
- Sprint: 1
- Autor: Daniel Ávila (DevOps titular)
- Origen: Mesa de Arquitectura
- Revisor: Sara Albarracín (Scrum Master)

## Contexto

La arquitectura de la plataforma MANI comprende múltiples servicios distribuidos en contenedores Docker y hospedados sobre infraestructura Microsoft Azure (cliente Flutter, backend Java y backend .NET). Operar esta solución en tres ambientes (**Development**, **Testing** y **Production**) requiere:

1. **Recolección continua de métricas:** Capturar métricas operacionales a nivel de infraestructura, contenedores y endpoints (CPU, memoria, tasa de peticiones, latencia de red, errores HTTP).
2. **Visualización y tableros:** Contar con cuadros de mando claros y centralizados para supervisar la salud de cada servicio (Repo A, Repo B, Repo C) y el rendimiento general de la plataforma.
3. **APM y centralización de logs:** Disponer de trazabilidad distribuida (APM) y agregación de logs estructurados para diagnóstico rápido de errores e incidentes en producción.
4. **Bucle de retroalimentación de alertas (Feedback Loop):** Integrar los sistemas de monitoreo con la herramienta de gestión del proyecto (Jira), permitiendo que las anomalías críticas detectadas en producción generen automáticamente issues de tipo *Bug* o *Incidente* en el backlog para su priorización inmediata por el Product Owner y Scrum Master.

## Alternativas evaluadas

1. **Stack ELK (Elasticsearch, Logstash, Kibana) auto-alojado.** Descartada debido al alto consumo de recursos de memoria/cómputo y a la complejidad operativa requerida para el mantenimiento, indexación y escalabilidad de clústeres en el alcance actual del proyecto.
2. **Uso exclusivo de Azure Monitor y Application Insights.** Descartada porque acopla rígidamente la observabilidad al proveedor cloud de Azure, dificulta la correlación unificada de métricas entre entornos locales/Docker y eleva los costos de exportación y retención de telemetría hacia herramientas de terceros.
3. **Monitoreo híbrido con Prometheus (recolección de métricas), Grafana (dashboards unificados) y Datadog (APM, agregación de logs y retroalimentación de alertas hacia Jira).** Elegida.

## Decisión

Usaremos Prometheus para la recolección continua de métricas de infraestructura y contenedores, Grafana para la visualización de tableros de rendimiento por repositorio, y Datadog para APM, gestión centralizada de logs y despacho automático de alertas hacia el backlog de Jira.

## Trade-off asumido

El equipo asume la sobrecarga de instrumentar los microservicios (Java Spring/Maven y .NET) con endpoints de telemetría para Prometheus y agentes de Datadog, además de la coexistencia y configuración de dos herramientas de visualización/monitoreo (Grafana para métricas operativas y Datadog para logs/APM/alertas).

## Estado

Aceptado — última actualización: 2026-08-19

## Consecuencias

- Positivas:
  - Visibilidad integral y en tiempo real del estado de salud de los servicios Flutter, Java y .NET en todos los ambientes (Devs, Test, Prod).
  - Diagnóstico acelerado de incidentes y degradación de rendimiento gracias a trazas distribuidas (APM) y agregación de logs en Datadog.
  - Cierre del ciclo DevOps mediante retroalimentación activa: los incidentes operacionales críticos se convierten automáticamente en ítems del backlog de Jira sin depender de reportes manuales de usuarios.
  - Disponibilidad de tableros dedicados en Grafana para soporte a decisiones de arquitectura, capacidad y escalabilidad.
- Negativas:
  - Mayor consumo de recursos en contenedores por la inclusión de agentes y exportadores de telemetría.
  - Dependencia de la capa gratuita/educativa de Datadog y necesidad de gestionar cuotas de retención de logs y eventos APM.
- Neutras:
  - Se debe estandarizar el formato de logs a JSON estructurado en las aplicaciones Java y .NET para facilitar su indexación.
  - El equipo de DevOps y Scrum Master deben definir y calibrar los umbrales de alerta para evitar saturación (*alert fatigue*) en el tablero de Jira.

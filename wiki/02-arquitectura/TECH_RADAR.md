# Tech Radar — MANI

> **La figura se retiró el 2026-11-19, y el archivo no se borró.** La imagen
> [`diagrams/TechRadar.png`](diagrams/TechRadar.png) **ya no refleja el stack**: no muestra Loki, Promtail,
> Alertmanager ni los cinco exportadores, y **todavía muestra Datadog**, que se retiró el 2026-11-13. Se deja de
> mostrar en vez de presentar una imagen que contradice las listas de abajo, que son la fuente. El archivo sigue
> donde estaba, para quien quiera regenerarlo: basta rehacerlo con estas listas y volver a insertarlo aquí.

**Corte: 2026-11-16.** Este documento lista lo **vigente**: lo que está en uso hoy, lo que está en
evaluación y lo que se descartó con su motivo. No arrastra versiones anteriores; el historial de
cambios está en el log de git. La imagen quedó retirada por el mismo motivo, y el aviso está arriba.

## Sí o sí

### Plataformas
- GitHub
- Supabase
- PostgreSQL como motor de Supabase

### Lenguajes / frameworks
- Flutter / Dart
- Java
- .NET
- Node.js
- React 19 + Vite 8, **solo para `MANI-Landing`** (ver abajo)

### Infraestructura y calidad
- NGINX
- Docker / OCI
- Docker Compose, como mecanismo de despliegue de QA y PROD
- GHCR
- GitHub Actions
- SonarQube
- OWASP ZAP
- Newman
- k6
- OpenAPI
- Prometheus
- Grafana
- Grafana Loki, logs centralizados (`grafana/loki:3.1.1`)
- Promtail, recolector de logs de contenedores (`grafana/promtail:3.1.1`)
- Alertmanager, enrutado de alertas
- Exportadores de métricas: node-exporter, nginx-exporter, postgres_exporter, cAdvisor y blackbox-exporter
- Jira
- oxlint, linter de `MANI-Landing`

### Alcance de la pila de observabilidad

Prometheus, Grafana y los exportadores están **desplegados y documentados** en la VM de Calidad
(`10.43.98.196`) y en QA, con la configuración versionada en `MANI-APIGateway/monitoring/`
(ver [`wiki/08-infraestructura/05-monitoreo-y-politicas-devops.md`](../08-infraestructura/05-monitoreo-y-politicas-devops.md)).
Responden a **PROY-09**, la exigencia de observabilidad propia del proyecto.

**Loki y Promtail están desplegados pero su decisión aún no está ratificada:**
[ADR-0038](adr/ADR-0038-logs-centralizados-y-trazas-loki.md) está en estado `Propuesto` y espera
Mesa de Arquitectura. Figuran aquí como adoptados porque están en operación, no porque la decisión
esté cerrada. Lo mismo vale para la enmienda que retiró Datadog de
[ADR-0006](adr/ADR-0006-observabilidad.md), también pendiente de ratificar.

Las **trazas por spans** quedan fuera: ver «En evaluación».

### Documentación técnica
- Markdown
- Mermaid, para diagramas embebidos en los documentos
- Structurizr DSL, fuente del modelo de vistas en [`diagrams/c4/workspace.dsl`](diagrams/c4/workspace.dsl)
- Draw.io

### Alcance de React y Vite

React 19 y Vite 8 entran al radar con un alcance cerrado: la página comercial pública
`MANI-Landing` ([ADR-0028](adr/ADR-0028-nombres-repositorios-y-ambientes.md)). El cliente de
la plataforma sigue siendo Flutter, para web y móvil, y no hay un segundo frontend transaccional.

Por qué no Flutter Web para esta pieza: la landing es contenido para quien llega sin sesión y
necesita carga inicial inmediata, indexación en buscadores e interactividad ligera. Una SPA de
Flutter Web carga su motor de renderizado antes de mostrar contenido y produce poco HTML
indexable. Como la landing no comparte lógica, datos ni contratos con el cliente, usar otra
tecnología no duplica nada. Detalle en `MANI-Landing/docs/ARQUITECTURA_E_INTEGRACION.md` §1.

Si la landing empezara a necesitar datos de la plataforma, el radar se revisa: entonces aplicarían
ADR-0027 y ADR-0030, y habría que decidir si sigue en esta tecnología.

## En evaluación
- **OpenTelemetry y Grafana Tempo**, para trazas distribuidas por *spans*. **Fuera de esta fase**
  por decisión de [ADR-0038](adr/ADR-0038-logs-centralizados-y-trazas-loki.md): hoy la correlación
  entre servicios se consigue filtrando los logs de Loki por `X-Correlation-ID`, que cubre la
  necesidad de diagnóstico sin instrumentar código. Entrarían solo si un escenario de calidad o la
  Mesa lo aprueban explícitamente.
- **Kubernetes.** Es la plataforma de orquestación **objetivo** exigida por PROY-08, pero no está
  adoptada ni desplegada: la decisión sigue abierta como INFRA-01 e INFRA-02 de
  [`INFRAESTRUCTURA_MANI.md`](../06-gobernanza/INFRAESTRUCTURA_MANI.md) §25 y requiere ADR. Hoy QA y
  PROD corren con Docker sobre una máquina virtual por ambiente.

## Mejor no / descartado
- Azure / AKS como proveedor obligatorio.
- Serverpod como backend principal.
- MongoDB/NestJS como stack primario.
- GitHub Projects como backlog principal.
- **Datadog**, para APM, logs y trazas. Estaba en la decisión original de
  [ADR-0006](adr/ADR-0006-observabilidad.md) y se **retiró el 2026-11-13**: nunca se aprovisionó, no
  llegó a ningún ambiente y nadie lo operó, de modo que figuraba como decisión vigente siendo una
  intención. Su función de logs la asumió Grafana Loki.
- Lógica de negocio en funciones PL/pgSQL (ADR-0022).
- Acceso directo del cliente a PostgREST y Storage (ADR-0027).

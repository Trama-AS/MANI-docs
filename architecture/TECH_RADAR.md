# Tech Radar — MANI

[![Tech Radar de MANI: tecnologías adoptadas, en evaluación y descartadas](../diagrams/TechRadar.png)](../diagrams/TechRadar.png)

> **Figura 1 — Tech Radar.** Archivo: [`diagrams/TechRadar.png`](../diagrams/TechRadar.png). Si la imagen y las listas de abajo discrepan, manda este documento.

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
- Datadog
- Jira
- oxlint, linter de `MANI-Landing`

### Documentación técnica
- Markdown
- Mermaid, para diagramas embebidos en los documentos
- Structurizr DSL, fuente del modelo de vistas en [`diagrams/c4/workspace.dsl`](../diagrams/c4/workspace.dsl)
- Draw.io

### Alcance de React y Vite

React 19 y Vite 8 entran al radar con un alcance cerrado: la página comercial pública
`MANI-Landing` ([ADR-0028](../adr/ADR-0028-nombres-repositorios-y-ambientes.md)). El cliente de
la plataforma sigue siendo Flutter, para web y móvil, y no hay un segundo frontend transaccional.

Por qué no Flutter Web para esta pieza: la landing es contenido para quien llega sin sesión y
necesita carga inicial inmediata, indexación en buscadores e interactividad ligera. Una SPA de
Flutter Web carga su motor de renderizado antes de mostrar contenido y produce poco HTML
indexable. Como la landing no comparte lógica, datos ni contratos con el cliente, usar otra
tecnología no duplica nada. Detalle en `MANI-Landing/docs/ARQUITECTURA_E_INTEGRACION.md` §1.

Si la landing empezara a necesitar datos de la plataforma, el radar se revisa: entonces aplicarían
ADR-0027 y ADR-0030, y habría que decidir si sigue en esta tecnología.

## En evaluación
- **Kubernetes.** Es la plataforma de orquestación **objetivo** exigida por PROY-08, pero no está
  adoptada ni desplegada: la decisión sigue abierta como INFRA-01 e INFRA-02 de
  [`INFRAESTRUCTURA_MANI.md`](../governance/INFRAESTRUCTURA_MANI.md) §25 y requiere ADR. Hoy QA y
  PROD corren con Docker sobre una máquina virtual por ambiente.

## Mejor no / descartado
- Azure / AKS como proveedor obligatorio.
- Serverpod como backend principal.
- MongoDB/NestJS como stack primario.
- GitHub Projects como backlog principal.
- Lógica de negocio en funciones PL/pgSQL (ADR-0022).
- Acceso directo del cliente a PostgREST y Storage (ADR-0027).

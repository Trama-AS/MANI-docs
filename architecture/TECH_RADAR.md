# Tech Radar — MANI

[![Tech Radar de MANI: tecnologías adoptadas, en evaluación y descartadas](../diagrams/HLD/TechRadar.png)](../diagrams/HLD/TechRadar.png)

> **Figura 1 — Tech Radar.** Archivo: [`diagrams/HLD/TechRadar.png`](../diagrams/HLD/TechRadar.png). Si la imagen y las listas de abajo discrepan, manda este documento.

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

### Documentación técnica
- Markdown
- Mermaid, para diagramas embebidos en los documentos
- Structurizr DSL, fuente del modelo de vistas en [`diagrams/LLD/workspace.dsl`](../diagrams/LLD/workspace.dsl)
- Draw.io

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

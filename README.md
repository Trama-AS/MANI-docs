# TRAMA · MANI — Repositorio Central de Documentación de Arquitectura

Bienvenido al repositorio oficial de documentación técnica, arquitectura de software, gestión y gobierno del proyecto **MANI**, desarrollado por el equipo **TRAMA**.

Este repositorio centraliza y versiona todos los artefactos de diseño, requerimientos (SRS), arquitectura (SAD), registros de decisiones de arquitectura (ADRs), diagramas y entregables oficiales del sistema.

---

## 📌 Acerca del Proyecto MANI

**MANI** es una plataforma SaaS multi-tenant diseñada para la formalización, gestión operativa y despacho determinista de servicios, conectando empresas clientes con aliados calificados en diversas categorías de servicio.

### Principales Atributos de Calidad y Drivers de Diseño
- **Seguridad y Aislamiento Multi-Tenant (RNF-01 / DR-01):** Aislamiento estricto de datos a nivel de motor de persistencia mediante **Row-Level Security (RLS)** nativo en PostgreSQL (ADR-0012) e identificación criptográfica de tenant vía **JWT claims** (ADR-0018).
- **Despacho Concurrente Determinista (RNF-05 / DR-04):** Asignación atómica de solicitudes a nivel de motor de datos (ADR-0016).
- **Cobertura Geográfica por Catálogo de Zonas (REST-01 / DR-02):** Cobertura administrativa a nivel de localidad/comuna sin cálculo geoespacial en el MVP (ADR-0011).
- **DevSecOps Continuo:** Verificación estática con **SonarQube** (SAST), dinámica con **OWASP ZAP** (DAST) y suite automatizada de pruebas de aislamiento en **Newman** (ADR-0005, ADR-0015).
- **Observabilidad y Feedback Loop:** Telemetría integral con **Prometheus**, **Grafana** y **Datadog**, cerrando el bucle con creación automática de incidentes en el backlog de **Jira** (ADR-0006).

---

## 🗂️ Estructura del Repositorio

La organización del repositorio sigue la directriz formal de gestión documental establecida en **ADR-0001** y **ADR-0007**:

```
MANI-docs/
├── ADR/                       # Architectural Decision Records (ADR-0001 al ADR-0018)
├── Diagramas/                 # Repositorio central de diagramas arquitectónicos (ADR-0008)
│   └── Tecnologías/           # Diagramas de tecnologías de alto nivel (V1 y V2) y Tech Radar
├── Entregas/                  # Entregables consolidados por sprint / hito curricular
│   ├── Entrega1/              # Documento inicial de proyecto V1
│   ├── Entrega2/              # Perfil de proyecto, Backlog, SRS V1, Gobierno y Políticas V1
│   └── Entrega3/              # Documento de Herramientas, Políticas y Lineamientos V2 (MD y PDF)
├── Product/                   # Especificación de producto y arquitectura
│   ├── Analisis_de_Requerimientos.md
│   ├── Glosario_Terminos_MANI.md
│   ├── Product_Backlog_MANI_Jira_COMPLETO.csv
│   ├── SAD-MANI.md            # Software Architecture Document (ADD + ATAM)
│   └── SRS_MANI.md            # Software Requirements Specification
├── Project/                   # Gobierno del equipo, ceremonias y marcos de trabajo
│   ├── Gobierno_del_Equipo.md # Gestión del proyecto, roles, ceremonias y métricas
│   ├── Matriz_de_Herramientas.md
│   └── Temas_Mesa_Arq01.md    # Minutas y temas de la Mesa de Arquitectura
├── Perfil_de_Proyecto_MANI.md # Perfil y justificación estratégica del producto
└── README.md                  # Este documento
```

---

## 📑 Registro de Decisiones de Arquitectura (ADR)

Toda decisión técnica y de gobernanza con impacto estructural se evalúa colegiadamente en la **Mesa de Arquitectura** y se documenta formalmente bajo el formato ADR:

| ADR | Título | Estado | Autor / Rol |
| :---: | :--- | :---: | :--- |
| [ADR-0001](ADR/ADR-0001-gestion-documental.md) | Gestión documental: GitHub y OneDrive | Aceptado | Nicolás León (DevOps / PO) |
| [ADR-0002](ADR/ADR-0002-herramientas-gestion-jira.md) | Herramientas de gestión y seguimiento: Jira | Aceptado | Sara Albarracín (Scrum Master) |
| [ADR-0003](ADR/ADR-0003-mesa-de-arquitectura.md) | Creación y funcionamiento de la Mesa de Arquitectura | Aceptado | Sara Albarracín (Scrum Master) |
| [ADR-0004](ADR/ADR-0004-pipeline-cicd-promocion-ambientes.md) | Pipeline de CI/CD Multi-Repositorio y Promoción de Ambientes | Aceptado | Daniel Ávila Medina (DevOps) |
| [ADR-0005](ADR/ADR-0005-seguridad-devsecops-sast-dast.md) | Integración DevSecOps con Análisis Estático (SonarQube) y Dinámico (OWASP ZAP) | Aceptado | Daniel Ávila Medina (DevOps) |
| [ADR-0006](ADR/ADR-0006-observabilidad-monitoreo-alertas.md) | Observabilidad, Monitoreo Continuo y Gestión de Incidentes (Prometheus, Grafana, Datadog, Jira) | Aceptado | Daniel Ávila Medina (DevOps) |
| [ADR-0007](ADR/ADR-0007-documentacion-en-el-repo.md) | Estructura y Gestión de Documentación en el Repositorio | Aceptado | Camila Beltrán (Frontend) |
| [ADR-0008](ADR/ADR-0008-carpeta-de-diagramas.md) | Organización de Diagramas de Arquitectura en el Repositorio | Aceptado | Camila Beltrán (Frontend) |
| [ADR-0009](ADR/ADR-0009-politicas-de-ia.md) | Política de Uso de Inteligencia Artificial en el Proyecto | Aceptado | Camila Beltrán (Frontend) |
| [ADR-0010](ADR/ADR-0010-tech-radar.md) | Definición del Tech Radar del Proyecto | Aceptado | Camila Beltrán (Frontend) |
| [ADR-0011](ADR/ADR-0011-modelo-de-cobertura.md) | Modelo de Cobertura Geográfica del Aliado por Zonas | Aceptado | Nicolás Álvarez / Juan Sebastián Álvarez |
| [ADR-0012](ADR/ADR-0012-aislamiento-multitenant.md) | Backend en Dart, Persistencia en Supabase PostgreSQL y Aislamiento con RLS | Aceptado | Juan Sebastián Álvarez (Backend) |
| [ADR-0013](ADR/ADR-0013-almacenamiento-documentos-kyc.md) | Almacenamiento Seguro de Documentos KYC de Aliados en Supabase Storage | Aceptado | Santiago (QA / Security) |
| [ADR-0014](ADR/ADR-0014-FeatureToggle.md) | Adopción del Patrón Feature Toggle para Desacoplamiento de Despliegues | Aceptado | Juan Sebastián Álvarez (Backend) |
| [ADR-0015](ADR/ADR-0015-estrategia-pruebas-aislamiento-multitenant.md) | Estrategia de Pruebas Automatizadas para Aislamiento Multi-Tenant con Newman | Aceptado | Santiago (QA / Security) |
| [ADR-0016](ADR/ADR-0016-estrategia-despacho.md) | Estrategia de Despacho Simultáneo (Broadcast) con Asignación Atómica | Propuesto | Nicolás Álvarez (Frontend) |
| [ADR-0017](ADR/ADR-0017-mensajeria-tiempo-real.md) | Mecanismo de Mensajería y Notificaciones en Tiempo Real (Supabase Realtime) | Propuesto | Nicolás Álvarez (Frontend) |
| [ADR-0018](ADR/ADR-0018-identificacion-propagacion-tenant.md) | Identificación y Propagación de Tenant en Peticiones (Token JWT Claims vs. Header vs. Subdominio) | Aceptado | Daniel Ávila Medina (DevOps) |

---

## 🛠️ Stack Tecnológico Principal

El stack del proyecto se define formalmente en el **Tech Radar V2** (ADR-0010) y en la **Arquitectura Tecnológica de Alto Nivel V2**:

- **Cliente y Frontend Móvil:** [Flutter](https://flutter.dev) & [Dart](https://dart.dev) (multiplataforma iOS / Android).
- **Servicios de Backend:**
  - **Repo A:** App móvil cliente y aliados (Flutter / Dart).
  - **Repo B:** Microservicio de reglas de negocio empresariales (Java / Maven / Docker).
  - **Repo C:** Microservicio transaccional de alta concurrencia (.NET / C# / ACR).
  - **BaaS y Persistencia:** Supabase / PostgreSQL con Row-Level Security (RLS) nativo y Serverpod.
- **CI/CD y DevOps:** GitHub Actions, Docker, Azure Container Registry (ACR), Kubernetes (AKS).
- **Seguridad (DevSecOps):** SonarQube (SAST), OWASP ZAP (DAST), Newman / Postman (Pruebas automáticas de RLS en CI).
- **Observabilidad:** Prometheus (Métricas), Grafana (Dashboards), Datadog (APM, Logs y Alertas automáticas hacia Jira).
- **Gestión Ágil y Diseño:** Jira Software, Discord, Figma, Excalidraw.

---

## 👥 Equipo de Trabajo — TRAMA

Todos los integrantes técnicos asumen responsabilidad transversal como **Arquitectos** dentro de la **Mesa de Arquitectura** (ADR-0003):

| Integrante | Rol Principal | Segundo Rol |
| :--- | :--- | :--- |
| **Nicolás León** | Product Owner | DevOps |
| **Sara Albarracín** | Scrum Master | Frontend |
| **Daniel Ávila Medina** | DevOps | Backend |
| **Santiago** | QA & Security Testing Lead | Product Owner |
| **Juan Sebastián Álvarez (Alviz)** | Backend Lead | Frontend |
| **Camila Beltrán** | Frontend Lead | Scrum Master |
| **Nicolás Álvarez** | Frontend Lead | QA |

---

## 📜 Políticas de Gobierno y Trabajo

1. **Gestión de Ramas (Gitflow):** Rama `main` protegida (Producción), `develop` (Integración), ramas de trabajo `feature/*`, `fix/*`, `release/*` y `spike/*`. Todo cambio ingresa exclusivamente mediante Pull Request con revisión de pares y CI en verde (ADR-0004).
2. **Promoción Inmutable (*Build Once, Deploy Anywhere*):** Las mismas imágenes generadas en *Development* se promueven hacia *Testing* y *Production* sin recompilación.
3. **Uso Responsable de IA:** Regulado por **ADR-0009**. Prohibido el ingreso de información sensible o credenciales reales en modelos de IA externos. Revisión y autoría humana obligatoria en todo commit. Toda decisión arquitectónica debe ser aprobada en la Mesa de Arquitectura.

# ADR-0004: Pipeline de CI/CD Multi-Repositorio y Promoción de Ambientes (develop -> release -> main)

- Fecha: 2026-08-19
- Sprint: 1
- Autor: Daniel Avila (DevOps titular)
- Origen: Mesa de Arquitectura
- Revisor: Santiago (QA / Product Owner)

## Contexto

El proyecto MANI adopta una arquitectura desacoplada multi-repositorio compuesta por tres componentes principales: una aplicación cliente desarrollada en Flutter (Repo A), un servicio backend desarrollado en Java con Maven (Repo B) y un servicio backend desarrollado en .NET (Repo C). El equipo requiere:

1. Automatizar el ciclo de vida de compilación, ejecución de pruebas unitarias y empaquetado de artefactos para cada repositorio de forma independiente.
2. Mantener sincronizada la gestión del trabajo en Jira (Backlog con épicas, historias y bugs) con el código fuente mediante la creación automatizada de issues y ramas en GitHub al mover ítems en los tableros.
3. Establecer una estrategia formal y controlada de promoción de artefactos inmutables contenerizados (Docker / Azure Container Registry) a través de tres ambientes secuenciales: **Development (develop)**, **Testing (release)** y **Production (main)** alojados sobre infraestructura Azure.
4. Garantizar que ningún artefacto llegue a producción sin haber sido probado y promovido a través de los entornos previos con pipelines en estado satisfactorio (CI en verde).

## Alternativas evaluadas

1. **Monorepositorio con pipeline monolítico unificado.** Descartada porque acopla fuertemente el ciclo de vida y los despliegues de tecnologías heterogéneas (Flutter, Java, .NET), incrementa exponencialmente los tiempos de ejecución de CI y dificulta el versionado semántico independiente de cada microservicio.
2. **Servidor de integración continua auto-hospedado con Jenkins.** Descartada porque introduce una carga operativa considerable en aprovisionamiento, mantenimiento de agentes, parches de seguridad y administración de infraestructura que el equipo no puede absorber en este sprint frente a la integración nativa y gestionada de GitHub Actions.
3. **Pipelines independientes en GitHub Actions con sincronización de Jira vía Webhooks y promoción de imágenes contenerizadas a ambientes Devs, Test y Prod en Azure.** Elegida.

## Decisión

Usaremos GitHub Actions como motor de CI/CD multi-repositorio integrado bidireccionalmente con Jira mediante Webhooks, promoviendo artefactos inmutables contenerizados a través de los entornos secuenciales Development (Devs), Testing (Test) y Production (Prod) desplegados en Microsoft Azure.

## Trade-off asumido

El equipo asume el esfuerzo de mantener tres flujos de trabajo (`workflows`) independientes de GitHub Actions (uno por repositorio), la administración distribuida de registros de imágenes (Docker Hub para el servicio Java y Azure Container Registry para el servicio .NET), y la dependencia del servicio SaaS de GitHub Actions y Jira para la automatización operativa.

## Estado

Aceptado — última actualización: 2026-08-19

## Consecuencias

- Positivas:
  - Despliegues automatizados, reproducibles y predecibles basados en el principio de *Build Once, Deploy Anywhere* (la misma imagen compilada y testeada en Devs es la que se promueve a Test y Prod).
  - Trazabilidad de extremo a extremo: cada movimiento en el backlog de Jira desencadena la creación de issues/ramas técnicas en GitHub vía webhooks.
  - Autonomía e independencia de despliegue para los equipos de desarrollo de Flutter, Java y .NET.
  - Cumplimiento estricto del Gobierno del Equipo (§2.2 y §2.5) sobre la segregación y paso obligatorio por ambientes DEV, QA/Test y PROD.
- Negativas:
  - Mayor consumo de minutos de ejecución concurrentes en GitHub Actions.
  - Mantenimiento duplicado de configuraciones, secretos y variables de entorno segregadas por cada ambiente en los repositorios de GitHub.
- Neutras:
  - Todo desarrollador debe apegarse a la convención de ramas (`feature/*`, `fix/*`, `develop`, `release`, `main`) para no disparar ejecuciones innecesarias de CI/CD.
  - Las promociones a Testing y Producción requieren la aprobación manual (Environment Protection Rules / Gates) del rol de QA y DevOps titular respectivamente.

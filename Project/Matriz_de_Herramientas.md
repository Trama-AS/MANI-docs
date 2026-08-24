# TRAMA · MANI — Matriz de Herramientas, Tech Radar y Lineamientos V1

> 🔴 = elemento pendiente de decisión del equipo (**PROPUESTA PARA EL EQUIPO** /
> **PREGUNTA PARA EL EQUIPO**). Ninguna tecnología de producto está adoptada hasta que
> exista su ADR.

Estado del documento: **en construcción.** Este documento distingue dos naturalezas
distintas de herramienta: las de **proceso** (pueden cerrarse cuando hay decisión del
equipo) y las **tecnologías de producto** (no se adoptan sin ADR).

---

## A. Herramientas de proceso

Herramientas de gestión, seguimiento, documentación, control de código, CI/CD, pruebas,
calidad y colaboración.

| Herramienta | Uso | Justificación | Estado |
| --- | --- | --- | --- |
| **Jira** | Gestión y seguimiento del trabajo (backlog, sprints, tablero) para PO y SM | Herramienta única de gestión definida en ADR-0002 | Adoptada |
| **GitHub** | Código, elementos técnicos, **ADR en `.md`**, webhooks de CI, C4/`workspace.dsl` | Repositorio de código y ADR (ADR-0001, ADR-0002) | Adoptada |
| **OneDrive** | Documentación formal: SRS, Requerimientos, Gobierno del Equipo, Plan de Tareas, Actas | Fuente de verdad de documentos formales (ADR-0001) | Adoptada |
| **Discord** | Coordinación y ceremonias (canales por ceremonia) | Medio de coordinación del equipo; no es repositorio de decisiones | Adoptada |
| **GitHub Actions** | CI/CD (pipelines, build, checks) | Integración continua sobre el repositorio | Adoptada (proceso) |
| **Postman + Newman** | Pruebas **funcionales** de API (Newman en CI) | Verificación funcional de contratos de API | Adoptada (proceso) |
| **k6** | Pruebas de **rendimiento/carga** | Verifica concurrencia (despacho, mensajería) | Adoptada (proceso) |
| **Figma** | Diseño de interfaz y mockups | Insumo de Frontend; validación de viabilidad técnica | Adoptada (proceso) |
| **Miro / Mermaid** | Diagramas de flujo y blueprints en fase de análisis | Apoyo a requerimientos y diseño | Adoptada (proceso) |

**Herramientas evaluadas y no adoptadas como proceso:**

- **GitLab Issues** — no se adopta (ADR-0002). El rastreador es Jira.
- **Confluence** — no se adopta. La documentación formal vive en OneDrive.
- **Google Sheets** — no aplica para QA ni para ningún artefacto del proyecto. Toda hoja de
  cálculo necesaria (incluidas las matrices y registros de QA) se trabaja en **Microsoft
  Excel** y se almacena en **OneDrive** (ver Gobierno del Equipo, §1.2.1).

---

## B. Tecnologías de producto (en evaluación — NO adoptadas sin ADR)

Stack con el que eventualmente se construirá el producto. Ninguna está adoptada.

| Tecnología | Propósito propuesto | Anillo Tech Radar | Spike relacionado |
| --- | --- | --- | --- |
| **NestJS** | Framework backend | **Evaluar** | SP-01.1.1 (ligado a persistencia/backend) |
| **MongoDB** | Motor de persistencia (documental) | **Evaluar** | SP-01.1.1 |
| **Supabase** | Backend-as-a-service sobre PostgreSQL (auth, RLS, storage) | **Evaluar** | SP-01.1.1, SP-01.2.1 |
| **Flutter + Dart** | Aplicación cliente multiplataforma | **Evaluar** | 🔴 sin spike de frontend asignado todavía |
| **Kubernetes** | Orquestación de contenedores y escalado | **Adoptar** (requisito de proyecto, PROY-08) | 🔴 sin spike propio; falta ADR de la distribución/config concreta (candidato: AKS, por Azure ya fijado en ADR-0004) |
| **Docker / Docker Compose** | Contenerización de ambientes DEV/QA | **Probar** | — |
| **OpenTelemetry** | Observabilidad | **Evaluar** | 🔴 sin spike de observabilidad asignado todavía |

🔴 **OBSERVABILIDAD — PENDIENTE (actualizado 2026-08-23):** el texto de ADR-0006 adopta
Prometheus + Grafana + Datadog, pero el equipo confirma que la decisión de observabilidad
**sigue pendiente en la práctica** — no se trata como cerrada. OpenTelemetry se mantiene en
"Evaluar" mientras esto no se ratifique. No planificar instrumentación de Sprint 1 dando por
hecho ninguna de las dos opciones hasta que la Mesa lo confirme explícitamente.

**Adoptadas vía ADR-0004/0005 (no estaban en esta tabla; se listan para trazabilidad — ver
también sección de incompatibilidades más abajo):**

| Tecnología | Rol | ADR | Anillo |
| --- | --- | --- | --- |
| Java + Maven | Backend (Repo B) — requerimiento de proyecto, ver 6bis | ADR-0004 | Adoptar |
| .NET | Backend (Repo C) — requerimiento de proyecto, ver 6bis | ADR-0004 | Adoptar |
| Microsoft Azure (+ Azure Container Registry) | Infraestructura / despliegue | ADR-0004 | Adoptar |
| SonarQube | SAST | ADR-0005 | Adoptar |
| OWASP ZAP | DAST | ADR-0005 | Adoptar |

Ninguna tecnología pasa a "Adoptar" ni se le asigna número de ADR hasta que la Mesa de
Arquitectura tome la decisión correspondiente. Este documento no anticipa ADR.

---

## Tech Radar

🔴 **PROPUESTA PARA DEVOPS Y LA MESA DE ARQUITECTURA:** el Tech Radar (cuatro anillos como
mecanismo permanente de clasificación tecnológica) **todavía no es una decisión tomada y no
tiene ADR.** Corresponde a **DevOps** (Daniel Ávila, titular) llevar la propuesta a la Mesa
de Arquitectura. Mientras tanto, el equipo usa los cuatro anillos de forma informal, solo
como clasificación de trabajo:

- **Adoptar** — decisión tomada y respaldada por ADR. *(Hoy vacío en tecnologías de producto.)*
- **Probar** — se usará en un spike/PoC controlado. *(Docker/Compose.)*
- **Evaluar** — candidata; requiere spike y ADR antes de avanzar. *(NestJS, MongoDB,
  Supabase, Flutter, OpenTelemetry.)*
- **Contener** — evitar o limitar su expansión.

Regla vigente del equipo (aún no formalizada como ADR): **una tecnología no pasa a
"Adoptar" hasta que exista el ADR correspondiente.**

---

## Incompatibilidades, dependencias y contradicciones identificadas

Se registran aquí, no dentro de los requerimientos ni de las historias.

1. **MongoDB (documental, sin RLS nativo) vs. Row-Level Security / Supabase (PostgreSQL).**
   El spike SP-01.1.1 evalúa RLS como estrategia de aislamiento multi-tenant. RLS es propio
   de bases relacionales. Elegir MongoDB como motor **excluye** RLS como mecanismo de
   aislamiento. **No pueden coexistir como decisión primaria.** Se resuelve cuando la Mesa de
   Arquitectura decida, a partir de SP-01.1.1.

2. **Plan de QA asume Supabase + RLS, mientras Backend propuso MongoDB.** Misma contradicción
   del punto 1, aflorando en las herramientas de prueba. El plan de pruebas de QA debe
   esperar la decisión de persistencia antes de fijar verificación de RLS.

3. **Tres rastreadores propuestos (GitHub Projects, GitLab Issues, Jira).** Resuelto por
   ADR-0002: Jira gestión, GitHub técnico/ADR, GitLab descartado.

4. **Docker Compose vs. escalado automático — resuelto por requisito externo (2026-08-23).**
   Docker Compose no realiza autoescalado; la pregunta era si eso justificaba Kubernetes por
   atributo de calidad. Ya no aplica: **Kubernetes es requisito curricular del profesor**
   (PROY-08), no una decisión de arquitectura evaluable por driver técnico. Lo que sigue
   🔴 pendiente es el ADR de **cómo** (distribución concreta — candidato natural AKS, dado
   que ADR-0004 ya fija Azure — y su configuración de nodos/escalado), no el **si**.

5. **Confluence/Jira (documentación, propuesta PO) vs. OneDrive + GitHub.** Resuelto por
   ADR-0001/0002: OneDrive documentos formales, GitHub ADR/código, Confluence descartado.

6bis. **🔴 Java y .NET son requerimiento de proyecto (constraint externo), no elección
   arquitectónica libre.** Confirmado por el equipo (2026-08-23): el proyecto exige usar
   Java y .NET en algún módulo del backend; el diseño de solución parte de esa base, no la
   evalúa como una alternativa más frente a NestJS. Esto es lo que explica el Repo B
   (Java/Maven) y Repo C (.NET) de ADR-0004. **Lo que sigue sin cerrar es el alcance
   exacto, no "cuál stack":**
   - Esta tabla sigue listando **NestJS** en "Evaluar", ligado a SP-01.1.1 (aislamiento
     multi-tenant, crítico, bloquea Sprint 1), sin que ningún documento aclare si NestJS
     sigue vigente para algún módulo adicional o si queda retirado del Tech Radar porque el
     requerimiento de proyecto ya cubre Java+.NET.
   - Ningún documento de requerimientos (Análisis de Requerimientos, SRS) registra este
     constraint como requisito de proyecto trazable — solo vive en el contexto de
     ADR-0004. Debe documentarse como requerimiento de proyecto (Análisis de Requerimientos,
     nueva entrada PROY-07) para que quede escrito y no dependa de que alguien lo recuerde.
   - SP-01.1.1 (aislamiento multi-tenant) debe re-dirigirse explícitamente a Java+.NET (o a
     cuál de los dos, si el aislamiento vive en una sola capa) antes de que su resultado
     alimente el diseño de datos de Sprint 1.
   **Para Mesa:** ratificar el alcance de NestJS (¿queda para algún módulo o se retira del
   Tech Radar?) y confirmar a qué módulo(s) exactos aplica Java y a cuáles .NET.

6. **Herramientas de diagramación (Miro/Mermaid/Figma) vs. modelo C4.** Para el SDD se usará
   un framework de modelado (C4 / 4+1). 🔴 **PREGUNTA PARA LA MESA:** ¿herramienta de C4
   (p. ej. Structurizr/`workspace.dsl` ya referenciado) se decide en la fase de diseño?
   Pendiente; no es de este sprint.

---

## Observación DevSecOps / Security Testing

**Actualización (ADR-0005, 2026-08-19):** SAST y DAST quedan resueltos — **SonarQube**
(análisis estático, en los flujos de GitHub Actions) y **OWASP ZAP** (análisis dinámico
automatizado sobre el ambiente de Testing). Postman + Newman cubren pruebas funcionales y k6
pruebas de carga; ninguna de las dos resuelve Security Testing, de ahí la necesidad de
SonarQube/ZAP.

🔴 **PENDIENTE — sigue sin cerrar (no lo resuelve ADR-0005):**

- **Análisis de dependencias** (vulnerabilidades en librerías) — sin herramienta definida.
- **Gestión de secretos** (no exponer credenciales en repositorio ni pipelines) — sin
  herramienta definida.

Queda como evaluación pendiente del equipo; el ADR correspondiente se crea únicamente cuando
la Mesa de Arquitectura tome la decisión.

---

## Matriz por integrante y etapa DevSecOps (estado actual, en evaluación)

| Integrante | Rol | Etapa DevSecOps | Herramienta propuesta | Naturaleza |
| --- | --- | --- | --- | --- |
| Sara Albarracín | Scrum Master | Plan | Jira + OneDrive | Proceso — adoptada |
| Juan Sebastián Álvarez (Alviz) | Backend | Code / Build | NestJS + MongoDB | Producto — **Evaluar** |
| Camila Beltrán | Frontend | Code / Build | Flutter + Dart (+ Figma) | Producto — **Evaluar** |
| Nicolás Álvarez | Frontend | Code / Build | Flutter + Dart | Producto — **Evaluar** |
| Santiago | QA | Test / Security Testing | Postman + Newman + k6 + emulador | Proceso — adoptada; 🔴 falta Security Testing |
| Daniel Ávila | DevOps | Release/Deploy/Operate/Monitor | GitHub Actions + Docker/Compose + Kubernetes (obligatorio, PROY-08) + observabilidad 🔴 pendiente | Mixto — proceso adoptado; orquestación obligatoria (falta ADR de distribución); observabilidad sin ratificar |
| Nicolás León | Product Owner | Requirements/MockUps | Jira + Figma + Miro + Mermaid | Proceso — adoptada |

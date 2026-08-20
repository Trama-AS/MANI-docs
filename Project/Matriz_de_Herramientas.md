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
| **Kubernetes** | Orquestación de contenedores y escalado | **Evaluar** | 🔴 pendiente definir driver (§ Tech Radar) |
| **Docker / Docker Compose** | Contenerización de ambientes DEV/QA | **Probar** | — |
| **OpenTelemetry** | Observabilidad | **Evaluar** | 🔴 sin spike de observabilidad asignado todavía |

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
  Supabase, Flutter, Kubernetes, OpenTelemetry.)*
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

4. **Docker Compose vs. escalado automático.** Docker Compose **no realiza autoescalado**.
   La tecnología en evaluación para orquestación y escalado es **Kubernetes**.
   🔴 **PROPUESTA / PUNTO PENDIENTE PARA LA MESA DE ARQUITECTURA:** definir el **driver o
   atributo de calidad** (¿escalabilidad? ¿disponibilidad? ¿elasticidad de carga?) que
   justifique formalmente Kubernetes. Sin driver, Kubernetes sería sobrearquitectura. No se
   cierra ni se asigna ADR hasta que la Mesa lo decida.

5. **Confluence/Jira (documentación, propuesta PO) vs. OneDrive + GitHub.** Resuelto por
   ADR-0001/0002: OneDrive documentos formales, GitHub ADR/código, Confluence descartado.

6. **Herramientas de diagramación (Miro/Mermaid/Figma) vs. modelo C4.** Para el SDD se usará
   un framework de modelado (C4 / 4+1). 🔴 **PREGUNTA PARA LA MESA:** ¿herramienta de C4
   (p. ej. Structurizr/`workspace.dsl` ya referenciado) se decide en la fase de diseño?
   Pendiente; no es de este sprint.

---

## Observación DevSecOps / Security Testing

El proyecto establece un enfoque **DevSecOps** y las actividades de QA incluyen **Security
Testing**, pero **actualmente no existen herramientas de seguridad propuestas**. Postman
cubre pruebas funcionales de API y k6 pruebas de carga; ninguna resuelve por sí sola el
Security Testing.

🔴 **PREGUNTA PARA QA / DEVOPS / MESA DE ARQUITECTURA:** ¿qué herramientas o mecanismos se
usarán para cubrir, como mínimo?

- **SAST** (análisis estático de código).
- **Análisis de dependencias** (vulnerabilidades en librerías).
- **Gestión de secretos** (no exponer credenciales en el repositorio ni en pipelines).

No se selecciona todavía ninguna herramienta definitiva: queda como **evaluación pendiente
del equipo**. El ADR correspondiente se crea únicamente cuando la Mesa de Arquitectura tome
la decisión.

---

## Matriz por integrante y etapa DevSecOps (estado actual, en evaluación)

| Integrante | Rol | Etapa DevSecOps | Herramienta propuesta | Naturaleza |
| --- | --- | --- | --- | --- |
| Sara Albarracín | Scrum Master | Plan | Jira + OneDrive | Proceso — adoptada |
| Juan Sebastián Álvarez (Alviz) | Backend | Code / Build | NestJS + MongoDB | Producto — **Evaluar** |
| Camila Beltrán | Frontend | Code / Build | Flutter + Dart (+ Figma) | Producto — **Evaluar** |
| Nicolás Álvarez | Frontend | Code / Build | Flutter + Dart | Producto — **Evaluar** |
| Santiago | QA | Test / Security Testing | Postman + Newman + k6 + emulador | Proceso — adoptada; 🔴 falta Security Testing |
| Daniel Ávila | DevOps | Release/Deploy/Operate/Monitor | GitHub Actions + Docker/Compose + OpenTelemetry (+ 🔴 Kubernetes) | Mixto — proceso adoptado; orquestación en evaluación |
| Nicolás León | Product Owner | Requirements/MockUps | Jira + Figma + Miro + Mermaid | Proceso — adoptada |

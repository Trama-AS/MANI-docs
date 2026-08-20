# TRAMA · MANI — Gobierno del Equipo

Documento único de gobierno: fusiona lo que antes eran el Marco de Decisiones y las
Políticas de Trabajo DevSecOps. Cubre **Gestión del Proyecto** y **Gestión de Desarrollo**
(políticas técnicas y DevSecOps) en un solo lugar.

| Campo | Valor |
| --- | --- |
| Proyecto | MANI |
| Responsable del documento | Sara Albarracín (Scrum Master), con apoyo de Daniel Ávila (DevOps titular) para la sección 2 |
| Vigencia | Se aprueba como línea base en el Planning que abre Sprint 1 |

> 🔴 = pendiente de decisión del equipo o **PREGUNTA PARA EL EQUIPO** / **PROPUESTA PARA EL
> EQUIPO**. Este documento se presenta como artefacto vigente del proyecto, no como registro
> de correcciones o cambios sobre versiones anteriores.

## 0. Propósito y reglas de uso

1. **Lo que no está aquí, no se exige.** Ninguna calificación, sanción o rechazo puede
   apoyarse en una regla no escrita en este documento.
2. **Lo que está aquí, se cumple.** Las excepciones se registran como decisión explícita,
   con responsable y fecha, en el acta de la ceremonia correspondiente.
3. **Este documento se modifica solo en retrospectiva**, con acuerdo del equipo, y aplica al
   sprint siguiente, nunca al sprint en curso ni retroactivamente.

---

# 1. Gestión del Proyecto

## 1.1 Equipo, roles y autoridad de decisión

### 1.1.1 Integrantes y roles

| Integrante | Rol principal | Segundo rol |
| --- | --- | --- |
| Sara Albarracín | Scrum Master | Frontend |
| Juan Sebastián Álvarez (Alviz) | Backend | Frontend |
| Camila Beltrán | Frontend | Scrum Master |
| Nicolás Álvarez | Frontend | QA |
| Santiago | QA | Product Owner |
| Daniel Ávila | DevOps | Backend |
| Nicolás León | Product Owner | DevOps |

**Arquitecto es una responsabilidad transversal:** todos los integrantes técnicos son
Arquitectos y forman parte de la **Mesa de Arquitectura**, con independencia de su rol
principal o secundario (ADR-0003).

🔴 **PREGUNTA PARA EL EQUIPO — titularidad DevOps:** confirmar que Daniel Ávila es DevOps
**titular** para toda decisión de repositorio/CI-CD/release, y que Nicolás León (DevOps
secundario) apoya sin ser el titular de esas decisiones.

### 1.1.2 Definiciones operativas de los roles

| Rol | Definición | Responsabilidad | Evidencia |
| --- | --- | --- | --- |
| Scrum Master | Facilita Scrum, promueve acuerdos, elimina impedimentos, mejora la efectividad | Reportes de sprint, seguimiento, ceremonias, gestión de Issues, uso correcto de Jira y Discord | Informe de sprint, registro de ceremonias, seguimiento de Issues, acuerdos de retro |
| Backend | Lógica de negocio, servicios, API, integraciones, datos | Implementa según patrones, seguridad, calidad y arquitectura aprobada | PR, pruebas, doc. de API |
| Frontend | Interfaz y su funcionamiento | Evalúa viabilidad de mockups, implementa componentes, cumple criterios y accesibilidad | PR, capturas/demos, pruebas de interfaz |
| QA | Aseguramiento de calidad, incluido **Security Testing** en el enfoque DevSecOps | Plan de pruebas por sprint, herramientas de prueba, verificación de criterios, registro de defectos | Plan de pruebas, casos, resultados, defectos |
| DevOps | Configuración técnica, automatización, CI/CD, ambientes; construye/ajusta la sección 2 de este documento | Repositorios, ramas, permisos, pipelines, secretos, ambientes, despliegue | Workflows, configuraciones, historial de despliegues |
| Product Owner | Representa al cliente/negocio, maximiza valor, administra el backlog; **aprueba los documentos** | Define y prioriza requerimientos, criterios de aceptación, Sprint Goal, valida incrementos | Backlog priorizado, historias, criterios, aprobaciones documentales |

### 1.1.3 Autoridad de decisión

D = decide · C = consultado antes · I = informado después

| Tipo de decisión | PO | SM | DevOps | QA | Desarrollo |
| --- | :---: | :---: | :---: | :---: | :---: |
| Prioridad y orden del backlog | D | C | I | I | I |
| Alcance del sprint (Planning) | D | C | C | C | C |
| Aceptación del incremento (Review) | D | I | I | C | I |
| Estimación en puntos | C | C | C | C | D |
| Diseño técnico y arquitectura (ADR, en la Mesa) | C | C | C | C | D* |
| Configuración de repositorio, CI/CD y secretos | I | C | D | I | C |
| Criterios de aceptación de una historia | D | C | I | C | I |
| Definition of Done y criterios de rechazo | C | C | C | D | C |
| Reglas de proceso, ceremonias y este documento | C | D | C | C | C |
| Umbrales de indicadores | C | D | C | C | C |
| Declarar un Issue bloqueante | I | D | C | C | C |
| Liberar a `main` (release) | C | C | D | C | I |
| **Aprobación de documentos del proyecto** | **D** | C | I | C | I |

\* La arquitectura la decide la **Mesa de Arquitectura** (todos los técnicos como
Arquitectos), no una sola persona. El SM facilita la ceremonia; no es dueño del contenido.

**Regla de aprobación documental.** El **PO aprueba todos los documentos del proyecto** y
puede comentar antes de aprobarlos. El SRS tiene además un revisor que comenta antes de la
aprobación del PO.

**Regla de desempate.** Si dos roles con autoridad concurrente no convergen en 24 horas, la
decisión escala al PO si es de producto y al SM si es de proceso. La decisión escalada se
registra en `#general` con una línea: decisión, motivo y fecha.

## 1.2 Gestión documental

### 1.2.1 Distribución de la documentación

**GitHub** (código y ADR): código, elementos técnicos de desarrollo, **ADR en `.md`**,
webhooks de CI, C4/`workspace.dsl`.

**OneDrive** (documentos formales): SRS, Análisis de Requerimientos, este documento de
Gobierno del Equipo, Plan de Tareas, Actas, documentación funcional y documentos
administrativos/académicos. Toda hoja de cálculo necesaria para la gestión del proyecto —
incluidas las de QA — se trabaja en **Microsoft Excel** y se almacena en **OneDrive**.
**Google Sheets no hace parte del esquema documental del proyecto.**

🔴 **NOTA DE SCRUM PARA QA:** Para mantener una única fuente documental y evitar dispersión
de información, las matrices, registros y artefactos tabulares de QA deberán trabajarse en
Microsoft Excel y almacenarse en OneDrive. Google Sheets no hará parte del esquema documental
del proyecto.

**Jira:** gestión y seguimiento del trabajo (backlog, sprints, tablero) para PO y SM.
El **Scrum Master no usa GitHub como herramienta de gestión de su rol.**

### 1.2.2 Qué se documenta, dónde y quién

| Documento | Ubicación | Responsable | Cuándo se actualiza |
| --- | --- | --- | --- |
| Gobierno del Equipo (este documento) | OneDrive | Scrum Master (sección 1) + DevOps (sección 2) | En retrospectiva |
| Instructivo de configuración | GitHub `/docs` | DevOps | Al cambiar la configuración |
| Modelo C4 | GitHub `/docs/c4` | Mesa de Arquitectura (rotativo) | Al cambiar contenedores/componentes |
| ADR | GitHub `/docs/adr/ADR-NNNN` (`.md`) | Redactor rotativo de la Mesa | Al tomar la decisión, nunca después |
| Estrategia y matrices de pruebas (Excel) | OneDrive | QA | Al cambiar niveles/herramientas |
| Análisis de Requerimientos | OneDrive | PO | Al cambiar necesidades/requerimientos |
| SRS | OneDrive | PO (elabora), revisor definido (comenta), PO (aprueba) | Al cambiar requisitos |
| Product Backlog | Jira | PO | Continuo |
| Plan de Tareas | OneDrive | Scrum Master | Por sprint |
| Informe de sprint | OneDrive (Excel) | Scrum Master | Al cierre de cada sprint |

## 1.3 Ceremonias, comunicación y priorización

### 1.3.1 Espacios por ceremonia (Discord + Jira)

| Canal / espacio | Propósito | Regla |
| --- | --- | --- |
| `#daily` | Reporte diario escrito y registro de **Issues** (incluye impedimentos/bloqueos reales) | Formato en §1.3.2 |
| `#mesa-arquitectura` | Convocatorias, fichas y actas de la Mesa de Arquitectura | Toda decisión produce ADR |
| `#sprint-planning` | Convocatoria y CHECK-IN del Sprint Planning | Solo el SM publica CHECK-IN |
| `#retro-back` | Reporte escrito de retrospectiva y CHECK-IN | Solo el SM publica CHECK-IN |
| `#desarrollo`, `#qa`, `#devops`, `#gestion-de-proyectos` | Discusión técnica por área | Las conclusiones se suben al issue/ADR |
| `#github-actividad`, `#github-ci` | Eventos de issues/PR/CI (webhook) | Solo lectura; los humanos no escriben |

**Regla de canal único de verdad.** Discord/Jira coordinan; no son repositorio de
decisiones. Toda conclusión que afecte código o alcance se escribe en el issue (Jira) o en un
ADR (GitHub). Lo que solo existe en un chat, no existe.

### 1.3.2 Formato de reportes escritos

**Daily (en `#daily`)** — un mensaje por persona:
- **Trabajo realizado:** qué terminé desde el último reporte (con referencia al issue).
- **Trabajo siguiente:** en qué trabajaré hasta el próximo daily (con issue).
- **Trabajo compartido:** menciono explícitamente a quién(es), si trabajé acompañado.
- **Issues:** issues abiertos o en curso que me afectan.
- **Impedimentos o bloqueos reales:** ninguno | descripción del bloqueo + a quién necesito.

Un mensaje sin *Trabajo realizado*, *Trabajo siguiente* e *Issues/Impedimentos* no cuenta
para el indicador de cumplimiento del daily.

**Retrospectiva (reporte escrito)** — un mensaje por persona con cuatro bloques: *Bien*,
*Mejorar*, *Aprendizaje*, *Duda*. Debe contener los cuatro bloques para ser válido.

### 1.3.3 Ceremonias

| Ceremonia | Frecuencia | Duración | Convoca | Asistencia |
| --- | --- | --- | --- | --- |
| Sprint Planning | Inicio de sprint | 2 h (virtual) | SM + PO | Todo el equipo |
| Daily | Diaria (hábiles) | Reporte escrito | SM | Todo el equipo |
| Sprint Review | Cierre de sprint | 1 h (en clase, con el profesor) | PO | Todo el equipo + profesor |
| Retrospectiva | Cierre de sprint | 1 h + reporte escrito | SM | Todo el equipo |
| Mesa de Arquitectura | Según necesidad | ~1 h | SM (facilita) | Todo el equipo (Arquitectos) |

**Mesa de Arquitectura:** preparación con ficha 24 h antes y mínimo dos alternativas reales;
quórum de 5 de 7; 20 min por decisión; un integrante argumenta en contra; ADR numerado por
decisión, redactor rotativo distinto al proponente; el disenso queda documentado. Ningún
acuerdo se aprueba sin alternativas ni sin el requisito que lo justifica. Toda Mesa que tome
una decisión arquitectónica produce ADR.

El CHECK-IN se habilita al inicio de la ceremonia y se cierra al finalizar. Registrar
asistencia sin participar se considera alteración del registro y se revisa en retrospectiva.

### 1.3.4 Tiempos de respuesta y gestión de Issues

| Situación | Plazo |
| --- | --- |
| Mención directa en canal de trabajo | 6 horas hábiles |
| Solicitud de revisión de PR | 24 horas hábiles |
| Issue con impedimento/bloqueo (en `#issues`) | Reconocimiento del SM ≤ 4 h hábiles; respuesta de involucrado ≤ 6 h hábiles |
| Fallo de CI en `develop` | Atención inmediata (< 4 h) del autor del último merge |

**Terminología: Impediments → Issues.** La gestión general se centraliza en **Issues**.
Cuando exista un bloqueo real, se reporta en el bloque correspondiente del daily y se
registra como Issue con causa, impacto, responsable requerido y acción esperada.

### 1.3.5 Priorización y estimación

- **Priorización del backlog:** decide el PO, consultando al SM; ver escala de prioridad en
  el Product Backlog (Crítica / Alta / Media / Baja).
- **Estimación:** decide el equipo de Desarrollo, en puntos de historia (Fibonacci); sin
  consenso, se resuelve por Planning Poker facilitado por el SM.

### 1.3.6 Cohesión y bienestar del equipo

Mecanismo sencillo, no invasivo, de seguimiento a la **salud y cohesión del equipo**:
cohesión, comunicación, colaboración, carga percibida, bienestar durante el sprint e
identificación temprana de factores humanos que puedan afectar el trabajo colectivo. No mide
el "ánimo" ni afecta la nota; alimenta las acciones de mejora de la retrospectiva.

## 1.4 Marco de medición

### 1.4.1 Composición de la nota

`TOTAL = 0.60 × Nota de equipo + 0.40 × Nota individual de proceso`
Escala 1–5: 1 insuficiente · 2 por debajo · 3 cumple · 4 supera · 5 referente.

### 1.4.2 Fuentes de datos

Los insumos provienen de **Jira, GitHub, GitHub Actions y Discord** y los bots definidos. No
se modifican manualmente sin justificación y trazabilidad interna del propio indicador.
Cuando exista ajuste manual, el informe conserva el valor original, el ajustado, la causa,
quién autoriza y la fecha.

🔴 **PROPUESTA PARA DEVOPS/SM:** validar antes del cierre de Sprint 1 que los indicadores se
puedan extraer desde Jira (o Jira + GitHub).

### 1.4.3 Indicadores de equipo (60 %)

| # | Indicador | Fórmula | Meta | Peso |
| --- | --- | --- | --- | --- |
| E1 | Predictibilidad del sprint | completado ÷ comprometido × 100 | 85–110 % | 0.25 |
| E2 | Estabilidad del flujo (CFD) | días sin superar WIP ÷ días hábiles × 100 | ≥ 85 % | 0.20 |
| E3 | Cycle time p85 | percentil 85 In Progress→Done | ≤ sprint anterior | 0.15 |
| E4 | Aceptación sin retrabajo | aceptados sin devolución ÷ entregados × 100 | ≥ 85 % | 0.15 |
| E5 | Tasa de retrabajo | horas de corrección ÷ horas totales × 100 | ≤ 15 % | 0.15 |
| E6 | Defectos escapados | bugs tras aceptación/liberación | ≤ 2 | 0.10 |

E1 se evalúa por la **desviación en puntos porcentuales respecto a 100 %**. Nota de equipo
≥ 4.0.

### 1.4.4 Indicadores individuales de proceso (40 %)

| # | Indicador | Fórmula | Fuente | Peso |
| --- | --- | --- | --- | --- |
| I1 | Fiabilidad del compromiso | puntos propios Done ÷ puntos propios comprometidos | Jira | 0.30 |
| I2 | Participación en revisión de código | revisiones emitidas ÷ PR de otros abiertos | GitHub | 0.25 |
| I3 | Cumplimiento de la DoD | elementos propios que cumplen DoD ÷ presentados como terminados | Jira + QA | 0.20 |
| I4 | Trazabilidad (Issues/bloqueos) | issues bien documentados y gestionados ÷ total × 100 | `#issues` + issue | 0.15 |
| I5 | Asistencia a ceremonias | asistidas ÷ programadas | Discord (CHECK-IN) | 0.10 |

**Ajuste por rol.** PO y SM, en su rol principal, no producen código de forma obligatoria y
no generan datos comparables para I1 ni I3; su nota se calcula sobre I2, I4 e I5,
renormalizando pesos. Cuando ejercen un segundo rol técnico y asumen desarrollo, los
indicadores técnicos aplican solo a esos elementos.

### 1.4.5 Umbrales de KPIs

**Equipo**

| Indicador | 5 | 4 | 3 | 2 | 1 |
| --- | --- | --- | --- | --- | --- |
| E1 Predictibilidad — desviación \|r−100\| | ≤ 10 pp | ≤ 20 pp | ≤ 30 pp | ≤ 45 pp | > 45 pp |
| E2 Estabilidad (CFD) | ≥ 95 % | ≥ 90 % | ≥ 85 % | ≥ 70 % | < 70 % |
| E3 Cycle time p85 | ≤ 3 d | ≤ 5 d | ≤ 8 d | ≤ 12 d | > 12 d |
| E4 Aceptación sin retrabajo | ≥ 95 % | ≥ 85 % | ≥ 75 % | ≥ 60 % | < 60 % |
| E5 Tasa de retrabajo | ≤ 5 % | ≤ 10 % | ≤ 15 % | ≤ 25 % | > 25 % |
| E6 Defectos escapados | 0 | 1 | 2 | 3–4 | ≥ 5 |

**Individuales**

| Indicador | 5 | 4 | 3 | 2 | 1 |
| --- | --- | --- | --- | --- | --- |
| I1 Fiabilidad | ≥ 95 % | ≥ 85 % | ≥ 70 % | ≥ 50 % | < 50 % |
| I2 Revisión de código | ≥ 0.80 | ≥ 0.60 | ≥ 0.40 | ≥ 0.20 | < 0.20 |
| I3 Cumplimiento DoD | ≥ 95 % | ≥ 85 % | ≥ 75 % | ≥ 60 % | < 60 % |
| I4 Trazabilidad (Issues) | 100 % | ≥ 90 % | ≥ 75 % | ≥ 50 % | < 50 % |
| I5 Asistencia | 100 % | ≥ 90 % | ≥ 75 % | ≥ 60 % | < 60 % |

El Sprint 1 funciona como línea base; la recalibración se aprueba en retrospectiva y aplica
desde el sprint siguiente.

### 1.4.6 Estado general del sprint

- **Verde:** carry-over ≤ 10 %, Sprint Goal cumplido, sin bloqueo crítico sin gestión.
- **Amarillo:** carry-over > 10 % y ≤ 25 %, o Sprint Goal en riesgo (definir acciones).
- **Rojo:** carry-over > 25 %, Sprint Goal incumplido, bloqueo crítico no resuelto o trabajo
  trasladado durante tres o más sprints.

**Control de cambios.** Toda modificación de roles, umbrales, fórmulas, fuentes o criterios
se registra en retrospectiva con fecha, responsables y sprint de entrada en vigencia.

---

# 2. Gestión de Desarrollo

Políticas técnicas y de **DevSecOps**. Responsable de construcción/ajuste: Daniel Ávila
(DevOps titular), con apoyo de Nicolás León (DevOps secundario).

## 2.1 Flujo DevSecOps por etapas

| Etapa | Actividad | Responsable | Herramienta (estado) |
| --- | --- | --- | --- |
| Plan | Backlog, sprint, tablero | PO / SM | Jira (adoptada) |
| Code | Desarrollo backend/frontend | Backend / Frontend | 🔴 stack en evaluación (ver Matriz de Herramientas) |
| Build | Compilación/empaquetado | DevOps | Docker / Compose (probar); GitHub Actions |
| Test | Pruebas funcionales y de carga | QA | Postman + Newman (func.), k6 (carga) |
| **Security** | **Security Testing** | QA + DevOps | 🔴 sin herramienta definida (ver §2.4) |
| Release | Liberación a `main` | DevOps titular | GitHub Actions |
| Deploy | Despliegue a ambientes | DevOps | Docker; 🔴 Kubernetes en evaluación |
| Operate/Monitor | Operación y observabilidad | DevOps | OpenTelemetry (evaluar) |

## 2.2 Ambientes

Ambientes contemplados: **DEV, QA, PROD**. Configuración y promoción entre ambientes a cargo
de DevOps.

🔴 **PROPUESTA PARA LA MESA DE ARQUITECTURA:** definir el driver de orquestación/escalado
antes de decidir sobre **Kubernetes**. Docker Compose no realiza autoescalado; si el
atributo de calidad lo exige, se evalúa Kubernetes con su ADR cuando la Mesa lo decida.

## 2.3 Repositorio, ramas y Pull Requests

- **Ramas:** `main` (release), `develop` (integración), `feature/US-xx-descripcion`,
  `fix/…`, `spike/SP-xx-…`. 🔴 **PROPUESTA PARA DEVOPS:** confirmar nomenclatura exacta antes
  del Sprint 1 (la DoD exige que la rama cumpla la nomenclatura).
- **Pull Request:** todo cambio entra por PR aprobado; CI en verde; al menos una revisión de
  otro integrante.
- Un fallo de CI en `develop` se atiende de inmediato (< 4 h) por el autor del último merge.
- **Liberación a `main`:** la decide DevOps titular.

## 2.4 Security Testing, dependencias y gestión de secretos

El enfoque del proyecto es **DevSecOps** y QA incluye Security Testing, pero **no hay
herramienta definida todavía**. Cobertura mínima requerida:

- **SAST** — análisis estático de código.
- **Análisis de dependencias** — vulnerabilidades en librerías.
- **Gestión de secretos** — no exponer credenciales en el repositorio ni en pipelines.

🔴 **PREGUNTA PARA QA / DEVOPS / MESA DE ARQUITECTURA:** ¿qué se usará para cada una de estas
tres coberturas? Queda como evaluación pendiente; ninguna herramienta se cierra aún.

## 2.5 Contenedores y despliegues

Contenerización de ambientes DEV/QA con Docker/Docker Compose. Orquestación y escalado
(Kubernetes) permanecen en evaluación (§2.2). Ningún despliegue a PROD ocurre sin pasar por
DEV y QA con CI en verde.

## 2.6 ADR y documentación técnica

- Toda decisión técnica costosa de revertir se registra como ADR **antes** de implementarse,
  con contexto, alternativas, decisión, trade-off y consecuencias.
- Un ADR no se borra ni se edita: si la decisión cambia, se escribe uno nuevo que declare
  `supersedes ADR-NNNN`.
- ADR en GitHub `/docs/adr/` en `.md`; **la autoría rota** entre integrantes en cada Mesa.
- Ningún ADR se anticipa antes de que la Mesa tome la decisión correspondiente.

## 2.7 Definition of Ready (DoR)

Una historia entra al Planning solo si tiene: criterios de aceptación en BDD, prioridad,
clase, estimación propuesta y sin spike bloqueante abierto.

🔴 **PROPUESTA PARA EL EQUIPO:** adoptar esta DoR desde Sprint 1.

## 2.8 Definition of Done (DoD)

Ningún elemento es Done con pruebas pendientes, documentación incompleta, defectos abiertos o
criterios incumplidos.

- **Funcionales:** criterios verificados, aceptación del PO cuando corresponda.
- **Técnicos:** integrado por PR aprobado, rama con nomenclatura correcta, CI en verde.
- **De calidad:** QA ejecuta/valida pruebas, sin defectos abiertos que impidan la entrega.
- **Documentales:** documentación técnica/API/usuario/arquitectura actualizada cuando el
  cambio lo exige.
- **De gestión:** issue, PR, pruebas y aceptación vinculados en Jira.

## 2.9 Gestión del incremento

- **Incremento entregado:** trabajo integrado que cumple la DoD, validado y liberable.
  Evidencia: ítem en estado Done, fecha, PR, evidencias de prueba, aceptación del PO.
- **Incremento no entregado:** comprometido en Planning que no llegó a Done. El responsable
  documenta la causa; el SM registra el impacto; el PO re-prioriza. No cuenta como parcial.
- **Sprint destino:** sprint futuro al que se reasigna lo no completado, analizado en retro y
  priorizado por el PO en el Planning siguiente.

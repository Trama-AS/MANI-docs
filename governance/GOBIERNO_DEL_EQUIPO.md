# TRAMA · MANI — Gobierno del Equipo

**Proyecto:** MANI — Plataforma Multi-Tenant de Formalización y Gestión de Servicios  
**Organización:** TRAMA · Ingeniería de Software  
**Documento:** Gobierno del Equipo  
**Responsable:** Scrum Master  
**Ámbito:** Gestión del proyecto y reglas de trabajo  
**Documento vivo:** sin número de versión; la vigente es la de `main`  

---

## 1. Propósito y reglas de uso

Este documento establece **cómo trabaja el equipo MANI**: roles, autoridad, ceremonias, comunicación, seguimiento, métricas, Definition of Ready, Definition of Done y gobierno de decisiones.

No define arquitectura, infraestructura ni herramientas técnicas en detalle. Esos temas viven en:

- `POLITICAS_DEVOPS_HERRAMIENTAS.md`
- `INFRAESTRUCTURA_MANI.md`
- SAD, SDD, ADR y Tech Radar.

### Reglas de gobierno

1. **Lo que no está documentado no se exige.**
2. **Lo acordado se cumple durante su vigencia.**
3. Las excepciones deben quedar registradas con responsable, motivo y fecha.
4. Los cambios de reglas de proceso se aprueban en retrospectiva y aplican al sprint siguiente.
5. Las decisiones técnicas estructurales se toman en Mesa de Arquitectura y se registran mediante ADR.
6. Ninguna conversación informal sustituye un artefacto oficial.

---

# 2. Equipo, roles y autoridad

## 2.1 Integrantes y roles

| Integrante | Rol principal | Segundo rol |
|---|---|---|
| Sara Albarracín | Scrum Master | Frontend |
| Juan Sebastián Álvarez | Backend | Frontend |
| Camila Beltrán | Frontend | Scrum Master |
| Nicolás Álvarez | Frontend | QA |
| Santiago | QA | Product Owner |
| Daniel Ávila | DevOps | Backend |
| Nicolás León | Product Owner | DevOps |

Todos los integrantes técnicos participan transversalmente como **Arquitectos** dentro de la Mesa de Arquitectura.

Daniel Ávila actúa como **DevOps titular** para repositorios, CI/CD, release, configuración de ambientes y operación técnica. Nicolás León participa como DevOps secundario.

## 2.2 Responsabilidades operativas

| Rol | Responsabilidad principal | Evidencia esperada |
|---|---|---|
| Scrum Master | Facilitar Scrum, seguimiento, impedimentos y mejora de proceso | Informes, ceremonias, acuerdos, métricas |
| Product Owner | Priorizar backlog, definir valor, aceptar incrementos y aprobar documentación | Backlog, criterios, aprobaciones |
| Backend | Servicios, APIs, integraciones, lógica y datos | PR, pruebas, documentación técnica |
| Frontend | Interfaz, integración cliente y experiencia de usuario | PR, demos, pruebas UI |
| QA | Aseguramiento de calidad y Security Testing | Planes, casos, resultados, defectos |
| DevOps | Repositorios, CI/CD, secretos, ambientes, despliegues y operación | Workflows, reglas, configuración, historial |
| Mesa de Arquitectura | Decisiones estructurales y ADR | ADR y actas de decisión |

## 2.3 Autoridad de decisión

D = decide · C = consultado · I = informado

| Tipo de decisión | PO | SM | DevOps | QA | Desarrollo |
|---|:---:|:---:|:---:|:---:|:---:|
| Prioridad del backlog | D | C | I | I | I |
| Alcance del sprint | D | C | C | C | C |
| Aceptación del incremento | D | I | I | C | I |
| Estimación | C | C | C | C | D |
| Arquitectura / ADR | C | C | C | C | D* |
| Repositorios / CI/CD / secretos | I | C | D | I | C |
| Criterios de aceptación | D | C | I | C | I |
| Definition of Done | C | C | C | D | C |
| Reglas de proceso | C | D | C | C | C |
| Umbrales de indicadores | C | D | C | C | C |
| Declarar bloqueo relevante | I | D | C | C | C |
| Liberar a producción | C | C | D | C | I |
| Aprobar documentación | D | C | I | C | I |

\* Las decisiones de arquitectura corresponden a la Mesa de Arquitectura, no a una persona individual.

### Regla de desempate

Si dos responsables con autoridad concurrente no convergen en 24 horas:

- producto → escala al PO;
- proceso → escala al SM;
- arquitectura → vuelve a Mesa de Arquitectura.

La decisión queda registrada.

---

# 3. Gestión documental

## 3.1 Fuentes de verdad

| Tema | Fuente |
|---|---|
| Requerimientos | SRS |
| Arquitectura | SAD |
| Diseño detallado | SDD |
| Modelo de datos / DDL / DD | Modelo de Datos |
| Decisiones técnicas | ADR |
| C4 | `diagrams/LLD/workspace.dsl` |
| Tecnologías vigentes | `TECH_RADAR.md` |
| Gobierno y proceso | Este documento |
| DevOps y herramientas | `POLITICAS_DEVOPS_HERRAMIENTAS.md` |
| Infraestructura | `INFRAESTRUCTURA_MANI.md` |
| Backlog y sprints | Jira |

## 3.2 Ubicación

### GitHub / MANI-Docs
Documentación técnica versionable:

- SRS;
- SAD;
- SDD;
- modelo de datos;
- ADR;
- diagramas;
- `diagrams/LLD/workspace.dsl`;
- políticas DevOps;
- infraestructura;
- README técnico.

### OneDrive
Artefactos administrativos o académicos cuando corresponda:

- actas;
- informes;
- entregables administrativos;
- matrices Excel;
- evidencias formales.

### Jira
Gestión del trabajo:

- backlog;
- épicas;
- historias;
- tareas;
- bugs;
- sprints;
- seguimiento.

### Discord
Coordinación operativa. Una decisión que solo existe en chat no se considera formalizada.

---

# 4. Ceremonias y comunicación

## 4.1 Canales

| Espacio | Propósito |
|---|---|
| `#daily` | Reporte diario |
| `#mesa-arquitectura` | Convocatorias y decisiones de arquitectura |
| `#sprint-planning` | Planning |
| `#retro-back` | Retrospectiva |
| `#desarrollo` | Discusión técnica |
| `#qa` | Pruebas y defectos |
| `#devops` | CI/CD, ambientes y operación |
| `#gestion-de-proyectos` | Coordinación de gestión |
| `#github-actividad` / `#github-ci` | Eventos automáticos |

## 4.2 Daily

Cada integrante reporta:

- **Trabajo realizado**
- **Trabajo siguiente**
- **Trabajo compartido**
- **Issues**
- **Impedimentos o bloqueos**

Un reporte incompleto no cuenta para el indicador correspondiente.

## 4.3 Retrospectiva

Cada reporte contiene:

- Bien
- Mejorar
- Aprendizaje
- Duda

## 4.4 Ceremonias

| Ceremonia | Frecuencia | Duración referencial | Convoca |
|---|---|---:|---|
| Sprint Planning | Inicio del sprint | 2 h | SM + PO |
| Daily | Días hábiles | escrito | SM |
| Sprint Review | Cierre | 1 h | PO |
| Retrospectiva | Cierre | 1 h + reporte | SM |
| Mesa de Arquitectura | Según necesidad | ~1 h | SM facilita |

---

# 5. Mesa de Arquitectura

La Mesa de Arquitectura se utiliza para decisiones técnicas costosas de revertir.

Reglas:

1. ficha de preparación antes de la sesión;
2. mínimo dos alternativas reales;
3. quórum mínimo de 5 de 7 integrantes;
4. al menos una persona argumenta en contra de la opción preferida;
5. el redactor del ADR debe ser distinto del proponente cuando sea viable;
6. el disenso se documenta;
7. toda decisión arquitectónica produce un ADR;
8. los ADR históricos no se eliminan;
9. si una decisión cambia, el ADR anterior pasa a `Superseded`.

---

# 6. Gestión de Issues e impedimentos

## 6.1 Tiempos de respuesta

| Situación | Plazo |
|---|---|
| Mención directa en canal de trabajo | ≤ 6 horas hábiles |
| Solicitud de revisión de PR | ≤ 24 horas hábiles |
| Bloqueo relevante | reconocimiento SM ≤ 4 h; respuesta involucrado ≤ 6 h |
| Fallo de CI en rama compartida | atención prioritaria del autor o responsable |

## 6.2 Registro

Un Issue bloqueante debe registrar:

- causa;
- impacto;
- responsable requerido;
- acción esperada;
- estado;
- resolución.

---

# 7. Priorización y estimación

## 7.1 Priorización

El PO decide el orden del Product Backlog.

Escala:

- Crítica
- Alta
- Media
- Baja

## 7.2 Estimación

El equipo de Desarrollo estima en puntos de historia utilizando Fibonacci.

Si no hay consenso, se utiliza Planning Poker facilitado por el SM.

---

# 8. Definition of Ready (DoR)

Una historia puede entrar a Planning cuando tenga, como mínimo:

- descripción comprensible;
- criterios de aceptación;
- prioridad;
- clasificación;
- estimación propuesta;
- dependencias conocidas;
- sin spike bloqueante abierto que impida desarrollarla.

---

# 9. Definition of Done (DoD)

Ningún elemento se considera `Done` con pruebas pendientes, documentación requerida incompleta, defectos bloqueantes abiertos o criterios incumplidos.

## 9.1 Funcional

- criterios de aceptación verificados;
- comportamiento esperado demostrado;
- aceptación del PO cuando aplique.

## 9.2 Técnico

- cambios integrados mediante Pull Request;
- revisión técnica realizada;
- CI en verde;
- contratos/API actualizados cuando aplica.

## 9.3 Calidad

- QA ejecutó o validó las pruebas requeridas;
- no existen defectos que impidan la entrega;
- gates técnicos exigibles superados.

## 9.4 Documentación

Se actualizan los artefactos afectados:

- API;
- arquitectura;
- modelo de datos;
- instructivos;
- ADR, cuando corresponda.

## 9.5 Gestión

Issue, PR, pruebas y aceptación quedan vinculados en Jira/GitHub cuando corresponda.

---

# 10. Gestión del incremento

### Incremento entregado
Trabajo integrado que cumple DoD, está validado y es liberable.

### Incremento no entregado
Trabajo comprometido que no llegó a Done.

Debe registrarse:

- causa;
- impacto;
- estado;
- decisión de replanificación.

El PO reprioriza el trabajo no completado en el siguiente Planning.

---

# 11. Métricas del proyecto

## 11.1 Composición

`TOTAL = 0.60 × Nota de equipo + 0.40 × Nota individual de proceso`

Escala:

- 1: insuficiente
- 2: por debajo
- 3: cumple
- 4: supera
- 5: referente

## 11.2 Indicadores de equipo

| ID | Indicador | Fórmula / criterio | Meta |
|---|---|---|---|
| E1 | Predictibilidad | completado / comprometido | 85–110 % |
| E2 | Estabilidad del flujo | días sin superar WIP / días hábiles | ≥ 85 % |
| E3 | Cycle time p85 | percentil 85 In Progress → Done | ≤ sprint anterior |
| E4 | Aceptación sin retrabajo | aceptados sin devolución / entregados | ≥ 85 % |
| E5 | Retrabajo | horas corrección / horas totales | ≤ 15 % |
| E6 | Defectos escapados | bugs tras aceptación/liberación | ≤ 2 |

## 11.3 Indicadores individuales

| ID | Indicador | Fuente |
|---|---|---|
| I1 | Fiabilidad del compromiso | Jira |
| I2 | Participación en revisión | GitHub |
| I3 | Cumplimiento DoD | Jira + QA |
| I4 | Trazabilidad de Issues | Jira / canales |
| I5 | Asistencia a ceremonias | registro de ceremonias |

PO y SM se evalúan únicamente sobre indicadores aplicables a su rol principal. Si asumen trabajo técnico, los indicadores técnicos se aplican sobre ese trabajo.

## 11.4 Estado general del sprint

- **Verde:** carry-over ≤ 10 %, Sprint Goal cumplido y sin bloqueo crítico sin gestión.
- **Amarillo:** carry-over > 10 % y ≤ 25 %, o Sprint Goal en riesgo.
- **Rojo:** carry-over > 25 %, Sprint Goal incumplido, bloqueo crítico no resuelto o trabajo trasladado durante tres o más sprints.

---

# 12. Cohesión y bienestar

La retrospectiva puede recoger información sobre:

- comunicación;
- colaboración;
- carga percibida;
- bienestar;
- factores humanos que afecten el trabajo.

Esta información se utiliza para acciones de mejora y no sustituye métricas objetivas de entrega.

---

# 13. Control de cambios

Toda modificación de:

- roles;
- reglas;
- indicadores;
- fórmulas;
- fuentes;
- ceremonias;
- DoR;
- DoD;

se registra con:

- fecha;
- responsable;
- justificación;
- sprint de entrada en vigencia.

Los cambios técnicos no se duplican aquí: se actualizan en Políticas DevOps, Infraestructura o ADR según corresponda.

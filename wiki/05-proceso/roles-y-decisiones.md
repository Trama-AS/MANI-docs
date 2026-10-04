# Roles y decisiones

[← 05 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/GOBIERNO_DEL_EQUIPO.md`](../../governance/GOBIERNO_DEL_EQUIPO.md) §2 y §5 · [`adr/ADR-0003`](../../adr/ADR-0003-mesa-arquitectura.md).

Ninguna persona es dueña de un documento ni de una decisión: la autoridad es del **rol**, y las decisiones estructurales son de la **Mesa de Arquitectura**, no de un individuo.

## Equipo

| Integrante | Rol principal | Segundo rol |
|---|---|---|
| Sara Albarracín | Scrum Master | Frontend |
| Juan Sebastián Álvarez | Backend | Frontend |
| Camila Beltrán | Frontend | Scrum Master |
| Nicolás Álvarez | Frontend | QA |
| Santiago | QA | Product Owner |
| Daniel Ávila | DevOps | Backend |
| Nicolás León | Product Owner | DevOps |

Todos los integrantes técnicos participan como **Arquitectos** en la Mesa de Arquitectura. Daniel Ávila es DevOps titular (repositorios, CI/CD, release, ambientes, operación) y Nicolás León DevOps secundario.

## Quién decide qué

`D` decide · `C` consultado · `I` informado (`GOBIERNO_DEL_EQUIPO.md` §2.3):

| Decisión | PO | SM | DevOps | QA | Desarrollo |
|---|:--:|:--:|:--:|:--:|:--:|
| Prioridad del backlog | **D** | C | I | I | I |
| Alcance del sprint | **D** | C | C | C | C |
| Aceptación del incremento | **D** | I | I | C | I |
| Estimación | C | C | C | C | **D** |
| Arquitectura / ADR | C | C | C | C | **D\*** |
| Repositorios / CI/CD / secretos | I | C | **D** | I | C |
| Criterios de aceptación | **D** | C | I | C | I |
| Definition of Done | C | C | C | **D** | C |
| Reglas de proceso | C | **D** | C | C | C |
| Umbrales de indicadores | C | **D** | C | C | C |
| Declarar bloqueo relevante | I | **D** | C | C | C |
| Liberar a producción | C | C | **D** | C | I |
| Aprobar documentación | **D** | C | I | C | I |

\* Corresponde a la **Mesa de Arquitectura**, no a una persona individual.

## Desempate

Si dos responsables con autoridad concurrente no convergen en **24 horas**: producto escala al **PO**, proceso al **SM**, arquitectura vuelve a **Mesa de Arquitectura**. La decisión queda registrada.

## Mesa de Arquitectura

Para decisiones técnicas costosas de revertir. Reglas (`GOBIERNO_DEL_EQUIPO.md` §5):

1. ficha de preparación antes de la sesión;
2. mínimo dos alternativas reales;
3. **quórum mínimo de 5 de 7**;
4. al menos una persona argumenta en contra de la opción preferida;
5. el redactor del ADR distinto del proponente cuando sea viable;
6. el disenso se documenta;
7. toda decisión produce un **ADR**;
8. los ADR históricos no se eliminan;
9. una decisión que cambia deja el ADR anterior en `Superseded`.

Ver [Decisiones ADR](../02-arquitectura/decisiones-adr.md) para el índice y los estados.

## Control de cambios de reglas

Modificar roles, reglas, indicadores, fórmulas, fuentes, ceremonias, DoR o DoD se registra con fecha, responsable, justificación y **sprint de entrada en vigencia** (`GOBIERNO_DEL_EQUIPO.md` §13). Los cambios técnicos no se duplican ahí: se actualizan en Políticas DevOps, Infraestructura o ADR.

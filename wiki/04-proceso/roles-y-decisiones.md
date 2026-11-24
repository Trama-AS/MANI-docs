# Roles y decisiones

[← 04 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §2 y §5 · [`adr/ADR-0003`](../02-arquitectura/adr/ADR-0003-mesa-arquitectura.md).

| Campo | Valor |
|---|---|
| **Finalidad** | Decir quién decide qué, cómo se desempata y cómo funciona la Mesa de Arquitectura |
| **Mantiene** | La página: Nicolás Álvarez (responsable de la carpeta). La fuente: Scrum Master |
| **Consume** | Todo el equipo |
| **Cada cuánto se actualiza** | Cuando el equipo acuerda un cambio de rol o de regla |
| **Versión y fecha** | Viva, sin número · contenido y ficha del 2026-11-16 ([SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694)) |
| **Origen y destino** | Rol → autoridad sobre un artefacto → decisión registrada (acta o ADR) |

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

> **La fila del Product Owner está desactualizada en la fuente.** `GOBIERNO_DEL_EQUIPO.md` §2.1 lleva una enmienda pendiente del 2026-11-11: el backlog vigente designa a **Camila Beltrán** como PO (por ejemplo, «Camila (PO) lo valida» en las tareas del Sprint 6). La tabla de arriba copia la de la fuente y no se reescribe aquí: el cambio de rol lo acuerda el equipo. Mientras tanto, quien valida y acepta como PO es Camila Beltrán.

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
8. un ADR absorbido por otro se retira del registro, si su decisión vive íntegra en el que lo absorbe y el retiro queda listado en [Decisiones ADR](../02-arquitectura/SAD.md#24-registro-de-decisiones-arquitectónicas); los números no se reutilizan;
9. una decisión que cambia deja el ADR anterior en `Superseded`.

Ver [Decisiones ADR](../02-arquitectura/SAD.md#24-registro-de-decisiones-arquitectónicas) para el índice y los estados.

## Control de cambios de reglas

Modificar roles, reglas, indicadores, fórmulas, fuentes, ceremonias, DoR o DoD se registra con fecha, responsable, justificación y **sprint de entrada en vigencia** (`GOBIERNO_DEL_EQUIPO.md` §13). Los cambios técnicos no se duplican ahí: se actualizan en Políticas DevOps, Infraestructura o ADR.

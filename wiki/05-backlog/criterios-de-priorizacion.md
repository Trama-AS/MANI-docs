# Criterios de priorización del backlog

[← 05 · Backlog](README.md) · [Índice](../Home.md)

| | |
|---|---|
| **Versión** | 1.0 |
| **Fecha** | 2026-11-10 |
| **Finalidad** | Explicar quién ordena el backlog y con qué criterios, para que dos personas ordenen igual un mismo conjunto de ítems |
| **Lo mantiene** | Nicolás León (suplente: Nicolás Álvarez); la prioridad la decide la Product Owner |
| **Lo consumen** | Product Owner, Scrum Master y quien estima o planifica |
| **Se actualiza** | En cada refinamiento; revisar al cerrar un sprint |
| **Origen** | [Roles y decisiones](../04-proceso/roles-y-decisiones.md), [Jira y trazabilidad](../04-proceso/jira-y-trazabilidad.md) y la prioridad real de los 78 ítems del [backlog del 9-nov](backlog-9-nov.md) |
| **Destino** | El orden del tablero y el alcance de cada sprint |
| **Historia en Jira** | [SCRUM-1695](https://maniservices.atlassian.net/browse/SCRUM-1695) (HU-WIKI-07) |

## Quién decide

Lo fija [`GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §2.3: **la Product Owner decide la prioridad del backlog**; la Scrum Master es consultada; DevOps, QA y Desarrollo son informados. El alcance del sprint también lo decide la PO. Si dos responsables no convergen en 24 horas, producto escala a la PO.

## Escala

Jira usa cuatro niveles. Equivalen a la escala del proceso (Crítica, Alta, Media, Baja):

| Jira | Escala del proceso | En el backlog del 9-nov |
|---|---|---:|
| Highest | Crítica | 3 |
| High | Alta | 29 |
| Medium | Media | 34 |
| Low | Baja | 12 |

## Criterios que se aplican

**Lo que sigue describe cómo quedó la prioridad en el backlog del 9-nov; no es una regla nueva, y la PO lo confirma o lo cambia.** Se ordena de arriba abajo: un ítem se coloca según el primer criterio que cumple.

1. **Bloquea el despliegue o el cierre del incremento.** Lleva la etiqueta `cierre-s5` o es un prerrequisito de ambiente. Ejemplo: `SCRUM-1638`, desplegar en PROD el front v1.0.4 (Highest).
2. **Toca dinero, aislamiento entre tenants o seguridad.** Un error aquí tiene el mayor costo y el menor margen de arreglo. Ejemplos: pagos (`SCRUM-1653`, High), políticas RLS (`SCRUM-1659`, High).
3. **Es un defecto reportado por QA sobre algo ya entregado.** Se atiende antes que lo nuevo del mismo módulo. Ejemplos: `SCRUM-1633` a `SCRUM-1637`.
4. **Estabilidad bajo carga.** Lo que mantiene el sistema en pie con usuarios reales. Ejemplo: `SCRUM-1651`, pool de conexiones de Core (Highest).
5. **Desbloquea el diagnóstico o el trabajo de otros.** Ejemplo: `SCRUM-1643` desbloquea el diagnóstico de `SCRUM-1634` y `SCRUM-1635`.
6. **Esfuerzo bajo con efecto visible.** Se adelanta frente a otro de igual prioridad.
7. **Mejora de calidad o de experiencia sin riesgo para lo anterior.** Va al final (Medium o Low). Ejemplo: la etapa 3 de UX, `SCRUM-1647` (Low), que además depende de la etapa 2.

## Qué no es un criterio

- **Quién lo pidió con más insistencia.** Lo decide el orden anterior, no el volumen.
- **Que sea fácil de programar,** salvo como desempate del criterio 6.
- **Que ya esté empezado.** Un ítem a medias no sube por eso.

## Estimación

El equipo de Desarrollo estima en puntos de historia con Fibonacci; sin consenso, Planning Poker facilitado por la SM ([Jira y trazabilidad](../04-proceso/jira-y-trazabilidad.md)). Los ítems del 9-nov traen el esfuerzo como Bajo, Medio o Alto en su descripción, que no sustituye a los puntos.

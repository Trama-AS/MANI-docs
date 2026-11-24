# Jira y trazabilidad

[← 04 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** el tablero `SCRUM` de Jira · [`adr/ADR-0002`](../02-arquitectura/adr/ADR-0002-jira-github.md) · [`governance/GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §3 y §9.5 · [`backlog/BACKLOG_MANI.md`](../05-backlog/BACKLOG_MANI.md) §4 y §5.

| Campo | Valor |
|---|---|
| **Finalidad** | Decir qué vive en Jira y qué en GitHub, cómo se enlazan, qué estados tiene un ítem y cómo se registra un bloqueo |
| **Mantiene** | La página: Nicolás Álvarez (responsable de la carpeta). La fuente: Scrum Master |
| **Consume** | Todo el equipo |
| **Cada cuánto se actualiza** | Cuando cambia el flujo del tablero o una regla de trazabilidad |
| **Versión y fecha** | Viva, sin número · contenido y ficha del 2026-11-16 ([SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694)) |
| **Origen y destino** | Requisito del SRS → épica → historia → rama → PR → prueba → aceptación |

## Reparto de herramientas

| Herramienta | Qué vive ahí |
|---|---|
| **Jira** | Backlog, épicas, historias, tareas, bugs, sprints y seguimiento. Es la fuente del trabajo |
| **GitHub** | Código, Pull Requests, issues técnicos, CI/CD y documentación técnica versionable |
| **OneDrive** | Actas, informes, entregables administrativos, matrices y evidencias formales |
| **Discord** | Coordinación operativa. **Una decisión que sólo existe en chat no está formalizada** |

GitHub Projects está **descartado** como backlog principal ([Tech Radar](../02-arquitectura/TECH_RADAR.md)).

## Cadena de trazabilidad

```text
RF/RNF del SRS
  → Épica en Jira
     → Historia (US-XX) o tarea (CFG-XX, DOC-XX) o spike (SP-XX)
        → Subtarea (incluidas las -Mn de migración)
           → Rama feature/US-XX-… o fix/BUG-XX-…
              → Pull Request con referencia Jira
                 → Pruebas y evidencia
                    → Aceptación
```

Issue, PR, pruebas y aceptación quedan vinculados en Jira/GitHub cuando corresponda (`GOBIERNO_DEL_EQUIPO.md` §9.5).

## Estados y transiciones

Así está configurado el tablero `SCRUM` (leído de Jira el 2026-11-16). Esta sección describe el tablero; no crea reglas.

| Estado | Categoría | Qué significa en la práctica | Quién lo mueve |
|---|---|---|---|
| **Tareas por hacer** | Por hacer | Nadie la ha empezado | Estado inicial |
| **En curso** | En curso | La persona asignada trabaja en ella | La persona asignada, al empezar |
| **En revisión** | En curso | El trabajo está en un PR o entregado y espera revisión, QA o validación del PO | La persona asignada o quien integra el PR, con la evidencia en un comentario |
| **Finalizada** | Listo | Cumple el [DoD](dor-y-dod.md) | Quien acepta: QA para el DoD y el PO para la aceptación ([Roles y decisiones](roles-y-decisiones.md)) |
| **Reabierta** | En curso | Estaba finalizada y una prueba mostró que un criterio no se cumple | QA, con la evidencia |

- **Las cuatro transiciones son globales:** desde cualquier estado se puede pasar a «Por hacer», «En curso», «In Review» o «Listo». El tablero no impide un salto; lo impide el [DoD](dor-y-dod.md).
- **Un estado en Jira no acredita nada por sí solo** ([Jerarquía de fuentes](../Home.md#2-jerarquía-de-fuentes), punto 8). Por eso cada cambio de estado va con un comentario que enlaza el PR, el commit o la evidencia.
- **Un PR integrado no cierra la historia** ([Pull requests](pull-requests.md)). En el Sprint 6, además, las tareas con video de validación no pasan a «Finalizada» sin el visto bueno de la PO ([Videos de validación](videos-de-validacion.md)).
- **No se cambia `Done` a `To Do`** para representar trabajo nuevo (regla 2 de la transición, más abajo). Lo que falla después de finalizar se abre como defecto ([Reporte de fallas](reporte-de-fallas.md)) o se reabre con evidencia.

En los Sprints 4 y 5 se usó además el estado `blocked` para un ítem detenido por otro. En el Sprint 6 un bloqueo se marca con la etiqueta `bloqueado` y se lleva en [`REGISTRO_BLOQUEOS.md`](../06-gobernanza/REGISTRO_BLOQUEOS.md); ningún ítem del sprint está en el estado `blocked` (consulta del 2026-11-16).

## Enlaces de bloqueo

Cuando un ítem no puede avanzar hasta que otro termine, se enlazan en Jira con el tipo **Blocks**: el que bloquea «blocks» y el bloqueado «is blocked by».

- El enlace se crea el día en que se detecta la dependencia y va con un comentario que dice qué falta exactamente.
- Cuando la dependencia se resuelve, **el enlace se retira** y se comenta. Un enlace obsoleto hace que el tablero siga mostrando un bloqueo que ya no existe.
- El enlace no reemplaza el registro: el bloqueo relevante lo declara la Scrum Master y queda en [`REGISTRO_BLOQUEOS.md`](../06-gobernanza/REGISTRO_BLOQUEOS.md), con escalamiento a los 2 días hábiles.

**Ejemplo del Sprint 5.** [SCRUM-866](https://maniservices.atlassian.net/browse/SCRUM-866) (alerta de tarifa) estuvo en `blocked`, enlazada como bloqueada por SCRUM-885 (tarifario) y SCRUM-1462 (motor de reglas). Cuando los dos se integraron a `develop` el 4 de noviembre, la historia salió del bloqueo con un comentario que lo explicaba y siguió a «En curso» y «En revisión». Dos de sus enlaces (hacia SCRUM-1240 y SCRUM-1462) ya eran obsoletos y seguían en Jira el 2026-11-16: retirarlos es parte de [SCRUM-1706](https://maniservices.atlassian.net/browse/SCRUM-1706).

## Registro de un bloqueo

Un issue bloqueante debe registrar: causa · impacto · responsable requerido · acción esperada · estado · resolución (`GOBIERNO_DEL_EQUIPO.md` §6.2). Plazos en [Ceremonias y tiempos](../06-gobernanza/ceremonias-y-tiempos.md).

## Reglas de la transición vigente

Del backlog V4 §4, aplicables a cómo se toca Jira hoy:

1. **No borrar issues antiguos.**
2. **No cambiar `Done` a `To Do`** para representar la migración.
3. La transición de plataforma va en `EP-09` como tareas `CFG-` y el spike `SP-05`, ya decidido. La serie no es continua: hoy son 23 tareas, `CFG-23` está partida en `CFG-23a`, `CFG-23b` y `CFG-23c`, y los números `18`, `19`, `21`, `24`, `25`, `30`, `31` y `32` no existen. La lista viva está en el backlog §4.
4. La documentación va en `EP-10` como tareas `DOC-`; la lista viva está en el backlog §4.
5. El trabajo funcional de migración va como **subtareas `-Mn` colgando de la historia original**, sin tocar su estado histórico.
6. Las historias nuevas que exige el SRS (`HU-N-01 … HU-N-05`) van bajo su épica funcional, no bajo EP-09.
7. Lo que sale de alcance se marca `Won't Do` o `Cancelled` **conservando la razón y la referencia al SRS**.

Detalle y clasificaciones en [Backlog §10](../05-backlog/BACKLOG_MANI.md#10-registro-de-la-transición-v4).

## Priorización y estimación

- El **PO decide el orden** del Product Backlog. Escala: Crítica, Alta, Media, Baja.
- El equipo de Desarrollo estima en **puntos de historia con Fibonacci**; sin consenso, Planning Poker facilitado por el SM.

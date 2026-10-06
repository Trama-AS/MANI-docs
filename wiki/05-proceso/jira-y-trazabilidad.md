# Jira y trazabilidad

[← 05 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** [`adr/ADR-0002`](../../adr/ADR-0002-jira-github.md) · [`governance/GOBIERNO_DEL_EQUIPO.md`](../../governance/GOBIERNO_DEL_EQUIPO.md) §3 y §9.5 · [`product/BACKLOG_MANI.md`](../../product/BACKLOG_MANI.md) §8.

## Reparto de herramientas

| Herramienta | Qué vive ahí |
|---|---|
| **Jira** | Backlog, épicas, historias, tareas, bugs, sprints y seguimiento. Es la fuente del trabajo |
| **GitHub** | Código, Pull Requests, issues técnicos, CI/CD y documentación técnica versionable |
| **OneDrive** | Actas, informes, entregables administrativos, matrices y evidencias formales |
| **Discord** | Coordinación operativa. **Una decisión que sólo existe en chat no está formalizada** |

GitHub Projects está **descartado** como backlog principal ([Tech Radar](../../architecture/TECH_RADAR.md)).

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

## Registro de un bloqueo

Un issue bloqueante debe registrar: causa · impacto · responsable requerido · acción esperada · estado · resolución (`GOBIERNO_DEL_EQUIPO.md` §6.2). Plazos en [Ceremonias y tiempos](ceremonias-y-tiempos.md).

## Reglas de la transición vigente

Del backlog V4 §8, aplicables a cómo se toca Jira hoy:

1. **No borrar issues antiguos.**
2. **No cambiar `Done` a `To Do`** para representar la migración.
3. La transición de plataforma va en `EP-09` como `CFG-15 … CFG-40` y el spike `SP-05`.
4. La documentación va en `EP-10` como `DOC-25 … DOC-28`.
5. El trabajo funcional de migración va como **subtareas `-Mn` colgando de la historia original**, sin tocar su estado histórico.
6. Las historias nuevas que exige el SRS (`HU-N-01 … HU-N-05`) van bajo su épica funcional, no bajo EP-09.
7. Lo que sale de alcance se marca `Won't Do` o `Cancelled` **conservando la razón y la referencia al SRS**.

Detalle y clasificaciones en [Transición V4](../06-backlog/transicion-v4.md).

## Priorización y estimación

- El **PO decide el orden** del Product Backlog. Escala: Crítica, Alta, Media, Baja.
- El equipo de Desarrollo estima en **puntos de historia con Fibonacci**; sin consenso, Planning Poker facilitado por el SM.

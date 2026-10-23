# Sprint 4 — Indicadores y acuerdos

**Entregable:** SM4-01 (SCRUM-1242) · **Corte de datos:** 2026-10-18

Los indicadores de este documento se derivan de Jira y del repositorio `MANI-Docs`, no de
estimaciones. Cada tabla dice de dónde sale. Lo que no es derivable de una herramienta —acuerdos de
ceremonia, decisiones de retrospectiva— está marcado como **pendiente de registrar** y debe
completarlo quien facilitó la sesión: inventarlo aquí lo volvería no auditable.

---

## 1. Estado del sprint

**Fuente:** Jira, `project = SCRUM AND sprint in openSprints()`, 53 ítems.

| Estado | Ítems | Participación |
|---|---|---|
| Done | 16 | 30% |
| In Review | 1 | 2% |
| In Progress | 25 | 47% |
| blocked | 6 | 11% |
| To Do | 5 | 9% |

**Lectura.** Con 30% en `Done` y 47% en `In Progress`, el riesgo del sprint no es el volumen de
trabajo sin empezar —solo 9% sigue en `To Do`— sino la **acumulación en curso**: casi la mitad del
sprint está abierto simultáneamente. Un 11% bloqueado sobre un 30% terminado significa que, por
cada tres ítems cerrados, hay uno detenido esperando a otro.

---

## 2. Carga por persona

**Fuente:** Jira, mismo corte.

| Persona | Done | In Review | In Progress | blocked | To Do | Total |
|---|---|---|---|---|---|---|
| nicolas leon | 0 | 0 | 11 | 0 | 1 | 12 |
| Juan Sebastián Álvarez | 4 | 0 | 1 | 1 | 4 | 10 |
| Sara Albarracín | 2 | 1 | 5 | 0 | 0 | 8 |
| Daniel Ávila | 5 | 0 | 1 | 1 | 0 | 7 |
| Santiago | 1 | 0 | 5 | 0 | 0 | 6 |
| José Nicolás Álvarez | 2 | 0 | 1 | 3 | 0 | 6 |
| María Camila Beltrán | 2 | 0 | 1 | 1 | 0 | 4 |

**Dos señales que conviene mirar en la Review:**

1. **Nicolás León concentra 11 ítems en curso y ninguno terminado.** Es el 44% de todo el trabajo
   en progreso del equipo en una sola persona. O el trabajo está subdividido de más, o hay un
   impedimento no registrado como tal.
2. **José Nicolás tiene 3 de sus 6 ítems bloqueados**, la mayor proporción del equipo. El detalle
   de esos bloqueos está en SM4-02 (SCRUM-1243).

---

## 3. Entregables documentales

**Fuente:** `MANI-Docs`, estado de Pull Requests al corte.

| Indicador | Valor |
|---|---|
| PR totales en el repositorio | 42 |
| PR fusionados | 35 |
| PR abiertos | 5 |
| PR cerrados sin fusionar | 2 |
| PR con clave `[SCRUM-<id>]` en el título | 30 de 42 — **71%** |

El 29% sin clave incumple la convención de ADR-0025. El desglose y el plan de corrección están en
SM4-02.

**ADR emitidos o enmendados durante el sprint:** ADR-0029 (comunicación asíncrona), ADR-0030
(propiedad del esquema y frontera de datos), ADR-0031 (política JWT), ADR-0032 (modelo de
identidad, propuesto en PR #39 sin fusionar).

---

## 4. Ceremonias

| Ceremonia | Estado del registro |
|---|---|
| Planning | **pendiente de registrar** — fecha, asistentes, alcance comprometido |
| Dailies | **pendiente de registrar** — cadencia efectiva y ausencias |
| Review | **pendiente de registrar** — fecha, demo presentada, asistentes externos |
| Retrospectiva | **pendiente de registrar** — hallazgos y acciones con responsable |

La preparación de la Review tiene tarea propia y está bloqueada: DOC4-08 (SCRUM-1251, presentación)
y DOC4-09 (SCRUM-1252, demo técnico).

---

## 5. Acuerdos del sprint

**Pendiente de registrar.** Un acuerdo de equipo sin fecha, responsable y criterio de verificación
no es un acuerdo. Formato sugerido para completarlo:

| # | Acuerdo | Responsable | Vence | Cómo se verifica |
|---|---|---|---|---|
| 1 | | | | |

Los acuerdos que **sí** quedaron registrados como decisión formal durante el sprint están en los
ADR listados en §3; no se duplican aquí.

---

## 6. Qué falta para cerrar este entregable

1. Completar §4 y §5 con el registro real de las ceremonias.
2. Recalcular §1 y §2 en la fecha de la Review: este corte es del 2026-10-18 y el sprint sigue
   abierto.

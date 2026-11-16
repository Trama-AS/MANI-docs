# Ceremonias y tiempos de respuesta

[← 04 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §4, §6 y §10.

| Campo | Valor |
|---|---|
| **Finalidad** | Decir qué ceremonias tiene el equipo, por qué canal se trabaja y en cuánto tiempo se responde |
| **Mantiene** | La página: Nicolás Álvarez (responsable de la carpeta). La fuente: Scrum Master |
| **Consume** | Todo el equipo |
| **Cada cuánto se actualiza** | Cuando cambia una ceremonia, un canal o un plazo en `GOBIERNO_DEL_EQUIPO.md` |
| **Versión y fecha** | Viva, sin número · contenido del 2026-10-22; ficha añadida el 2026-11-16 ([SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694)) |
| **Origen y destino** | Regla de gobierno → ceremonia → reporte (*daily*, retrospectiva) → indicador del sprint |

## Ceremonias

| Ceremonia | Frecuencia | Duración referencial | Convoca |
|---|---|---|---|
| Sprint Planning | Inicio del sprint | 2 h | SM + PO |
| Daily | Días hábiles | escrito | SM |
| Sprint Review | Cierre | 1 h | PO |
| Retrospectiva | Cierre | 1 h + reporte | SM |
| Mesa de Arquitectura | Según necesidad | ~1 h | SM facilita |

## Daily

Cada integrante reporta: **trabajo realizado · trabajo siguiente · trabajo compartido · issues · impedimentos o bloqueos**.

Un reporte incompleto **no cuenta** para el indicador correspondiente.

## Retrospectiva

Cada reporte contiene: **bien · mejorar · aprendizaje · duda**. Es donde se aprueban los cambios de reglas de proceso, que aplican al sprint siguiente.

## Canales

| Canal | Propósito |
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

## Tiempos exigibles

| Situación | Plazo |
|---|---|
| Mención directa en canal de trabajo | ≤ 6 horas hábiles |
| Solicitud de revisión de PR | ≤ 24 horas hábiles |
| Bloqueo relevante | reconocimiento del SM ≤ 4 h; respuesta del involucrado ≤ 6 h |
| Fallo de CI en rama compartida | atención prioritaria del autor o responsable |

## Trabajo no completado

El trabajo comprometido que no llegó a `Done` se registra con causa, impacto, estado y decisión de replanificación; el PO lo reprioriza en el siguiente Planning (`GOBIERNO_DEL_EQUIPO.md` §10). No se maquilla cerrándolo.

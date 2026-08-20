# ADR-0002· Herramientas de gestión: Jira y retiro de GitHub como herramienta de gestión del SM

- **Estado:** Aceptado
- **Fecha:** 2026-08-17 (Mesa de Arquitectura)
- **Redactor asignado:** Nicolás León (rol secundario DevOps) — 🔴 ver PREGUNTA en README
- **Decisión de:** proceso

## Contexto

Coexistían tres rastreadores: GitHub Projects (SM), GitLab Issues (propuesto por el SM) y
Jira/Confluence (propuesto por el PO). Los indicadores de proceso se alimentaban de GitHub,
lo que generaba dependencia cruzada y ambigüedad sobre la herramienta de gestión.

## Decisión

- **Jira** es la herramienta de gestión y seguimiento para **PO y Scrum Master**.
- **OneDrive** para la documentación formal (ver ADR-0001).
- El **Scrum Master ya no usa GitHub como herramienta de gestión de su rol.**
- **GitHub** se conserva para código, elementos técnicos y ADR. Los espacios/artefactos
  técnicos ya implementados en GitHub (issues técnicos, webhooks de CI, `github-actividad`)
  se **conservan por ahora**; tras uno o más sprints se evaluará si la gestión se centraliza
  totalmente en Jira.
- **GitLab** no se adopta como rastreador.

## Alternativas evaluadas

1. **Todo en GitHub Projects.** Descartada: mezcla gestión de proyecto con gestión técnica
   y ata los indicadores a una sola API.
2. **GitLab Issues.** Descartada: rompería las fuentes de indicadores ya montadas y agrega
   una herramienta sin justificación.
3. **Jira para gestión + GitHub para lo técnico/ADR.** **Elegida.**

## Trade-off asumido

Convivencia temporal de dos entornos (Jira para gestión, GitHub para técnico) mientras se
migra. Los indicadores de proceso deben re-mapear su fuente desde GitHub hacia Jira; ese
re-mapeo queda como tarea de DevOps/SM.

## Consecuencias

- El Gobierno del Equipo actualiza fuentes de datos de los indicadores.
- El Plan de Tareas incluye la reconfiguración de tableros en Jira.
  🔴 **PROPUESTA PARA EL EQUIPO:** validar que los indicadores I1–I5 y E1–E6 puedan
  extraerse de Jira (o del combo Jira + GitHub) antes de cerrar el Sprint 1, para no evaluar
  sobre una fuente que aún no produce los datos.

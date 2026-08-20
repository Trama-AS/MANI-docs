# ADR-0001 · Gestión documental: GitHub y OneDrive

- **Estado:** Aceptado
- **Fecha:** 2026-08-17 (Mesa de Arquitectura)
- **Redactor asignado:** Nicolás León (rol secundario DevOps) — 🔴 ver PREGUNTA en README
- **Decisión de:** proceso / gobierno documental

## Contexto

El equipo tenía documentación dispersa (Drive, GitHub, Confluence propuesto por el PO) y
sin regla única de dónde vive cada artefacto. Esto rompía la trazabilidad y generaba
ambigüedad sobre la fuente de verdad de cada documento.

## Decisión

Se define una distribución única:

**GitHub** (`/docs/` y repositorio de código)

- Código y elementos técnicos directamente relacionados con desarrollo.
- **ADR en formato `.md`**, en `/docs/adr/`.
- Elementos técnicos que ya se gestionan allí y que se decida conservar temporalmente
  (issues técnicos, workflows, C4/`workspace.dsl`).

**OneDrive**

- SRS, Análisis de Requerimientos, Gobierno del Equipo,
  Plan de Tareas, Actas, documentación funcional y documentos administrativos/académicos.

## Alternativas evaluadas

1. **Todo en GitHub.** Descartada: los documentos formales y administrativos no aportan
   valor versionado línea a línea y saturan el repositorio.
2. **Confluence + Jira para documentación.** Descartada: agrega una herramienta más y su
   costo/licenciamiento no se justifica frente a OneDrive ya disponible.
3. **GitHub para ADR/código + OneDrive para documentos formales.** **Elegida.**

## Trade-off asumido

La documentación formal en OneDrive no queda bajo control de versiones tipo Git. La
trazabilidad de cambios se apoya en las herramientas y repositorios definidos, no en
tablas de historial dentro de cada documento.

## Consecuencias

- Los ADR se escriben y viven en GitHub como `.md`.
- El resto de la documentación formal se mantiene en OneDrive.
- El Gobierno del Equipo refleja esta distribución.

# Estructura de MANI-Docs

[← 04 · Repositorios](README.md) · [Índice](../Home.md)

**Fuente:** árbol real del repositorio · [`adr/ADR-0001`](../../adr/ADR-0001-gestion-documental.md) · [`governance/GOBIERNO_DEL_EQUIPO.md`](../../governance/GOBIERNO_DEL_EQUIPO.md) §3.

## Árbol actual

```text
MANI-Docs/
├── README.md                      presentación técnica del proyecto
├── CONTRIBUTING.md                resumen del proceso de contribución
├── product/
│   ├── SRS.md                            requerimientos (fuente de verdad)
│   ├── BACKLOG_MANI_V4_TRANSICION.md     criterio de transición legible
│   └── BACKLOG_MANI_V4_TRANSICION.csv    inventario importable a Jira
├── architecture/
│   ├── SAD.md                     arquitectura; referencia los diagramas DHL
│   ├── SDD.md                     diseño detallado; referencia las vistas C4
│   ├── ModeloDatos.md             conceptual, lógico, físico, DDL, diccionario y DW
│   ├── workspace.dsl              modelo C4 en Structurizr DSL (fuente de los C4)
│   └── TECH_RADAR.md              tecnologías adoptadas, en evaluación y descartadas
├── adr/                           ADR-0001 … ADR-0021
├── governance/
│   ├── GOBIERNO_DEL_EQUIPO.md            roles, autoridad, ceremonias, DoR/DoD, métricas
│   ├── POLITICAS_DEVOPS_HERRAMIENTAS.md  ramas, PR, CI/CD, pruebas, seguridad, secretos
│   └── INFRAESTRUCTURA_MANI.md           ambientes, Supabase, red, backups, decisiones abiertas
├── diagrams/
│   ├── ALTO_NIVEL/                DHL.png · Infra.png · TechRadar.png — los referencia el SAD
│   └── C4Model/                   vistas exportadas desde workspace.dsl (SVG)
├── Entregas/                      entregables por corte académico (PDF y Markdown)
└── wiki/                          esta wiki: navegación y reglas derivadas
```

## Dónde va cada cosa

| Si vas a documentar… | Va en |
|---|---|
| Un requisito nuevo o cambiado | `product/SRS.md` |
| Una decisión técnica costosa de revertir | un ADR nuevo en `adr/` |
| Una vista C4 o un cambio de componentes | `diagrams/C4Model/workspace.dsl` y la sección correspondiente del SDD |
| Un cambio de arquitectura de alto nivel | `architecture/SAD.md` (+ actualizar el DHL si cambia el dibujo) |
| Tablas, DDL, diccionario o modelo dimensional | `architecture/ModeloDatos.md` |
| Una regla de proceso del equipo | `governance/GOBIERNO_DEL_EQUIPO.md` |
| Una regla de ramas, PR, CI/CD, pruebas o secretos | `governance/POLITICAS_DEVOPS_HERRAMIENTAS.md` |
| Ambientes, Supabase, red o backups | `governance/INFRAESTRUCTURA_MANI.md` |
| Una tecnología que entra o sale | `architecture/TECH_RADAR.md` |
| Backlog, historias, sprints | **Jira**, no este repositorio |
| Actas, informes y evidencias administrativas | **OneDrive**, no este repositorio |
| Navegación, resumen o guía de consulta | esta `wiki/` |

## Qué no se hace aquí

- No se duplican decisiones completas entre SRS, SAD, SDD, ADR, políticas e infraestructura (`README.md` §16).
- No se eliminan ADR históricos: una decisión que cambia produce un ADR nuevo y el anterior pasa a `Superseded`.
- La wiki no introduce reglas propias: si un dato no está en un documento, no se documenta como vigente ([Home](../Home.md) §4).

> El árbol que describe `README.md` §13 (`Product/`, `Architecture/`, `ADR/`, `Project/`, `DevOps/`, `Infrastructure/`, `Diagramas/`, y `MANI_Modelo_de_Datos.md`) no coincide con el árbol real de arriba. Está listado en [Riesgos y puntos abiertos](../02-arquitectura/riesgos-y-puntos-abiertos.md) como hueco documental.

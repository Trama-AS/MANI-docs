# Estructura de MANI-Docs

[← 04 · Repositorios](README.md) · [Índice](../Home.md)

**Fuente:** árbol real del repositorio · [`adr/ADR-0001`](../../adr/ADR-0001-gestion-documental.md) · [`governance/GOBIERNO_DEL_EQUIPO.md`](../../governance/GOBIERNO_DEL_EQUIPO.md) §3.

## Árbol actual

```text
MANI-Docs/
├── README.md                             presentación técnica del proyecto
├── CONTRIBUTING.md                       resumen del proceso de contribución
├── product/
│   ├── SRS.md                            requerimientos (fuente de verdad)
│   └── BACKLOG_MANI.md                   criterio de transición legible
├── architecture/
│   ├── SAD.md                            arquitectura, drivers y riesgos
│   ├── SDD.md                            diseño detallado, vistas y UMBRALES de calidad
│   ├── ModeloDatos.md                    conceptual, lógico, físico, DDL, diccionario, DW y cobertura de RF
│   ├── TECH_RADAR.md                     tecnologías adoptadas, en evaluación y descartadas
│   └── COMUNICACION_SERVICIOS_GATEWAY.md topología de comunicación y enrutamiento
├── adr/                                  ADR-0001 … ADR-0023, más ADR-0027
├── governance/
│   ├── GOBIERNO_DEL_EQUIPO.md            roles, autoridad, ceremonias, DoR/DoD, métricas
│   ├── POLITICAS_DEVOPS_HERRAMIENTAS.md  ramas, PR, CI/CD, pruebas, seguridad, secretos
│   └── INFRAESTRUCTURA_MANI.md           ambientes, Supabase, red, backups, decisiones abiertas
├── diagrams/
│   ├── HLD/                              landscape, infraestructura y Tech Radar
│   ├── LLD/
│   │   ├── workspace.dsl                 modelo Structurizr: la fuente de las vistas
│   │   └── Software/                     vistas exportadas que incrusta el SDD
│   └── ModeloDatos.png
├── Entregas/                             HISTÓRICO académico; no es fuente de verdad
└── wiki/                                 esta wiki: navegación
```

**`Entregas/` es un histórico.** Contiene los entregables por corte académico, incluidas copias en
Markdown de SRS, SAD, SDD, modelo de datos, backlog, infraestructura y políticas que ya divergieron
de los documentos vivos. No se consulta para resolver una duda ni para implementar, y su numeración
de ADR no es la vigente ([Decisiones ADR](../02-arquitectura/decisiones-adr.md#numeración)).

## Dónde va cada cosa

| Si vas a documentar… | Va en |
|---|---|
| Un requisito nuevo o cambiado | `product/SRS.md` |
| Una decisión técnica costosa de revertir | un ADR nuevo en `adr/` |
| Una vista o un cambio de componentes | `diagrams/LLD/workspace.dsl` y la sección correspondiente del SDD; el inventario de vistas es SDD §4.0 |
| Un cambio de arquitectura de alto nivel | `architecture/SAD.md` (+ regenerar el diagrama si cambia el dibujo) |
| Un umbral de calidad o un escenario de QA | `architecture/SDD.md` §7 y §8, y **solo ahí** |
| Tablas, DDL, diccionario o modelo dimensional | `architecture/ModeloDatos.md` |
| Una regla de proceso del equipo | `governance/GOBIERNO_DEL_EQUIPO.md` |
| Una regla de ramas, PR, CI/CD, pruebas o secretos | `governance/POLITICAS_DEVOPS_HERRAMIENTAS.md` |
| Ambientes, Supabase, red o backups | `governance/INFRAESTRUCTURA_MANI.md` |
| Una tecnología que entra o sale | `architecture/TECH_RADAR.md` |
| Backlog, historias, sprints | **Jira**, no este repositorio |
| Actas, informes y evidencias administrativas | **OneDrive**, no este repositorio |
| Navegación, resumen o guía de consulta | esta `wiki/` |

## Qué no se hace aquí

- No se duplican decisiones completas entre SRS, SAD, SDD, ADR, políticas e infraestructura (`README.md` §14).
- No se repiten umbrales: viven solo en el SDD §7 y §8.
- No se edita nada en `Entregas/`: es histórico.
- No se eliminan ADR históricos: una decisión que cambia produce un ADR nuevo y el anterior pasa a `Superseded`.
- La wiki no introduce reglas propias: si un dato no está en un documento, no se documenta como vigente ([Home](../Home.md) §4).


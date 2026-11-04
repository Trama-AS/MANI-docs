# Estructura de MANI-Docs

[← 04 · Repositorios](README.md) · [Índice](../Home.md)

**Fuente:** árbol real del repositorio · [`adr/ADR-0001`](../02-arquitectura/adr/ADR-0001-gestion-documental.md) · [`governance/GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §3.

## Árbol actual

Todo el contenido vive bajo `wiki/`, numerado por área. Los nombres `product/`, `architecture/`, `adr/`, `governance/` y `diagrams/` en la raíz **ya no existen**: aparecen todavía como prefijo en algunas citas antiguas y equivalen a la carpeta numerada correspondiente.

```text
MANI-Docs/
├── README.md                      presentación técnica del proyecto
├── CONTRIBUTING.md                resumen del proceso de contribución
├── Entregas/                      entregables por corte académico, histórico congelado
└── wiki/
    ├── Home.md                    índice de la wiki
    ├── 01-producto/               SRS.md (fuente de verdad), visión, requisitos, actores
    ├── 02-arquitectura/
    │   ├── SAD.md                 arquitectura; referencia los diagramas DHL
    │   ├── SDD.md                 diseño detallado; referencia las vistas C4
    │   ├── ModeloDatos.md         conceptual, lógico, físico, DDL, diccionario y DW
    │   ├── SECUENCIAS.md          secuencias de los flujos principales
    │   ├── CONTRATOS_EVENTOS.md   esquemas y versionado de los eventos de negocio
    │   ├── COMUNICACION_SERVICIOS_GATEWAY.md  enrutamiento y reglas servicio ↔ servicio
    │   ├── TECH_RADAR.md          tecnologías adoptadas, en evaluación y descartadas
    │   ├── guia/                  páginas de lectura que ordenan los documentos
    │   ├── adr/                   26 ADR, ADR-0001 a ADR-0034 con huecos
    │   ├── expedientes/           evidencia fechada de una tarea o de una Mesa
    │   └── diagrams/              estructura de ADR-0008
    │       ├── c4/                workspace.dsl + contexto/ contenedores/ componentes/ codigo/
    │       ├── datos/             ModeloDatos.png
    │       ├── despliegue/        despliegue-prod.png · infraestructura.png
    │       ├── flujos/            flujos de negocio y dinamicos/
    │       ├── MOCKUPS/           mockups de interfaz — fuera de ADR-0008
    │       └── TechRadar.png      lo referencia el TECH_RADAR — fuera de ADR-0008
    ├── 03-repositorios/           multirepo, versionado y esta página
    ├── 04-proceso/                ramas, PR, CI/CD, ambientes, DoR/DoD, trabajo con IA
    ├── 05-backlog/                BACKLOG_MANI.md y el libro de módulos
    ├── 06-gobernanza/
    │   ├── GOBIERNO_DEL_EQUIPO.md            roles, autoridad, ceremonias, DoR/DoD, métricas
    │   ├── POLITICAS_DEVOPS_HERRAMIENTAS.md  ramas, PR, CI/CD, pruebas, seguridad, secretos
    │   ├── INFRAESTRUCTURA_MANI.md           ambientes, Supabase, red, backups
    │   └── DOCUMENTO_INFRAESTRUCTURA_V3.md   topología, inventario, perímetro y runbook
    └── 07-calidad/                reportes de QA, PoC, actas y evidencias de sprint
```

Las cuatro capas de `02-arquitectura/` y la regla de qué va en cada una están en su [README](../02-arquitectura/README.md).

## Dónde va cada cosa

| Si vas a documentar… | Va en |
|---|---|
| Un requisito nuevo o cambiado | `wiki/01-producto/SRS.md` |
| Una decisión técnica costosa de revertir | un ADR nuevo en `wiki/02-arquitectura/adr/` |
| Una vista C4 o un cambio de componentes | `wiki/02-arquitectura/diagrams/c4/workspace.dsl` y la sección correspondiente del SDD |
| Un cambio de arquitectura de alto nivel | `wiki/02-arquitectura/SAD.md` (+ actualizar el DHL si cambia el dibujo) |
| Tablas, DDL, diccionario o modelo dimensional | `wiki/02-arquitectura/ModeloDatos.md` |
| La evidencia fechada de una tarea, una auditoría o una Mesa | `wiki/02-arquitectura/expedientes/`, con su identificador Jira en el nombre |
| Una regla de proceso del equipo | `wiki/06-gobernanza/GOBIERNO_DEL_EQUIPO.md` |
| Una regla de ramas, PR, CI/CD, pruebas o secretos | `wiki/06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md` |
| Ambientes, Supabase, red o backups | `wiki/06-gobernanza/INFRAESTRUCTURA_MANI.md` |
| Una tecnología que entra o sale | `wiki/02-arquitectura/TECH_RADAR.md` |
| Backlog, historias, sprints | **Jira**, no este repositorio |
| Actas, informes y evidencias administrativas | **OneDrive**, no este repositorio |
| Navegación, resumen o guía de consulta | esta `wiki/` |

## Qué no se hace aquí

- No se duplican decisiones completas entre SRS, SAD, SDD, ADR, políticas e infraestructura (`README.md` §16).
- Una decisión que cambia produce un ADR nuevo y el anterior pasa a `Superseded`, y se mantiene hasta que su contenido se absorba. Desde la enmienda del 2026-10-23 a las reglas 8 y 9 de la Mesa, un ADR absorbido por otro **sí** se retira del registro: su decisión vive íntegra en el que lo absorbe, que lo declara en su cabecera, y su número no se reutiliza ([Decisiones ADR](../02-arquitectura/guia/decisiones-adr.md)).
- La wiki no introduce reglas propias: si un dato no está en un documento, no se documenta como vigente ([Home](../Home.md) §4).


# 05 · Backlog

[← Índice de la wiki](../Home.md)

**Fuente:** [`BACKLOG_MANI.md`](BACKLOG_MANI.md) · [`adr/ADR-0002`](../02-arquitectura/adr/ADR-0002-jira-github.md).

> **Jira es la fuente del trabajo.** Esta carpeta no lo duplica: fija los criterios con los que se acepta y explica en qué orden se ejecuta.

Esta carpeta tiene **tres archivos y nada más**: este índice, el backlog y el libro de módulos. Todo lo que antes eran documentos o páginas sueltas es ahora una sección del backlog, y se cita por su número de sección.

## Los tres archivos

| Archivo | De qué responde |
|---|---|
| [`BACKLOG_MANI.md`](BACKLOG_MANI.md) | **Backlog único.** Cierre del Sprint 4 y plan del Sprint 5 (§0), épicas e historias (§1–§2), registro del Sprint 3 (§3–§4), documentos relacionados (§5), criterios de aceptación y DoD del Sprint 4 (§6), criterios de US-02.1.1 (§7), backlog técnico en GitHub e issues propuestos (§8), cobertura de lo que falta frente a verificación de lo que ya está (§9) y registro de la transición V4 (§10) |
| [`MANI_MODULOS_SERVICIOS_Y_BACKLOG_S5.xlsx`](MANI_MODULOS_SERVICIOS_Y_BACKLOG_S5.xlsx) | Libro de módulos M-01 a M-13, servicios de negocio, matriz módulo × servicio, backlog del Sprint 5 por bloques VAL, CONS y TEC, guion de videos, cobertura del producto y, en las hojas 18 a 20, los criterios de aceptación en forma de tabla filtrable |
| `README.md` | Este índice |

## Qué se absorbió y dónde quedó

| Antes | Ahora |
|---|---|
| `backlog/CRITERIOS_ACEPTACION_SPRINT4.md` | [§6](BACKLOG_MANI.md#6-criterios-de-aceptación-y-dod-de-las-historias-priorizadas-del-sprint-4) |
| `backlog/CRITERIOS_ACEPTACION_US-02.1.1.md` | [§7](BACKLOG_MANI.md#7-criterios-de-aceptación-de-us-0211-sobre-el-camino-gateway---core) |
| `backlog/BACKLOG_GITHUB_SPRINT4_PROPUESTA.md` | [§8](BACKLOG_MANI.md#8-backlog-técnico-en-github-estado-verificado-e-issues-propuestos-del-cierre-del-sprint-4) |
| `transicion-v4.md` y `orden-de-ejecucion.md` | [§10](BACKLOG_MANI.md#10-registro-de-la-transición-v4), como registro histórico del Sprint 3 |
| `backlog/MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md` | [`07-calidad/`](../07-calidad/MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md), porque es material de QA |

**El orden de ejecución vigente no está en §10.** §10.5 es el orden del Sprint 3, ya ejecutado. El del Sprint 5 está en la hoja `12 Backlog S5 resumen` del libro de módulos.

## Los criterios de aceptación, en el libro

Las §6 y §7 son el texto normativo; las hojas 18 a 20 del libro son la misma cosa en forma de tabla, para filtrar por historia, por responsable o por caso de prueba. Si difieren, **manda el documento**.

| Hoja | Contenido | Filas |
|---|---|---|
| `18 Criterios transversales S4` | T1 a T10, con su origen. Aplican a todas las historias | 10 |
| `19 Criterios por historia S4` | Una fila por criterio: historia, RF, responsable, enunciado, quién acepta, qué subtarea de QA verifica y qué casos de la matriz lo cubren | 69, sobre 17 historias |
| `20 Criterios US-02.1.1` | Escenarios A1 a A4 y B1 a B6 con sus pasos, más las 7 condiciones de aceptación | 16 escenarios |

> El estado real de cada capacidad y de cada defecto lo manda [07-calidad](../07-calidad/README.md), no el tablero de Jira. La §9 del backlog aplica esa regla: «cerrado» no es «verificado».

## Regla principal

**Una historia o tarea histórica marcada `Done` no se reabre sólo porque cambió la arquitectura.** Se conserva su evidencia. Si necesita adaptación se crea:

- una **subtarea `-Mn`** colgada de la propia historia, o
- una tarea **`CFG`** en EP-09, o
- un **bug de regresión**.

Así no se borra trabajo real ni se finge que la migración ya ocurrió.

## Punto de partida real

Backlog V4 §3: la arquitectura anterior **no es un backend que haya que mover de lenguaje**. Es un cliente Flutter hablando directo con Supabase y la lógica de negocio en ~32 funciones PL/pgSQL. Por tanto:

1. la migración consiste en **crear el backend que no existe y sacar al cliente de la base de datos**;
2. los riesgos *Lógica de negocio en Flutter* y *Acceso directo indiscriminado a Supabase* del SAD §23 están mal calibrados y su corrección es la tarea `DOC-28`.

## Qué se conserva

Supabase, Auth, RLS y aislamiento multi-tenant · registro y aprobación de aliados · registro de cliente · categorías · creación de solicitud · exclusión concurrente · las PoC de despacho, identidad y Storage/KYC · pipelines, GHCR, secretos y promoción de ambientes · seeds multi-tenant · documentación y diagramas consolidados.

Ese trabajo **cambia de ubicación**, no se desecha: la lógica se reimplementa en Rules (Java), Dispatch (.NET) y Core Service (Node.js), y el cliente deja de invocarla ([ADR-0022](../02-arquitectura/adr/ADR-0022-logica-de-negocio-en-servicios.md)).

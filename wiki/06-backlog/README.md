# 06 · Backlog

[← Índice de la wiki](../Home.md)

**Fuente:** [`product/BACKLOG_MANI_V4_TRANSICION.md`](../../product/BACKLOG_MANI_V4_TRANSICION.md) y su CSV · [`adr/ADR-0002`](../../adr/ADR-0002-jira-github.md).

> **Jira es la fuente del trabajo.** Esta carpeta no lo duplica: explica cómo se lee el backlog V4 de transición y en qué orden se ejecuta.

| Página | Tema |
|---|---|
| [Transición V4](transicion-v4.md) | Clasificaciones, dónde va cada tarea, cambios de alcance |
| [Orden de ejecución](orden-de-ejecucion.md) | Secuencia obligada y qué bloquea qué |

## Regla principal

**Una historia o tarea histórica marcada `Done` no se reabre sólo porque cambió la arquitectura.** Se conserva su evidencia. Si necesita adaptación se crea:

- una **subtarea `-Mn`** colgada de la propia historia, o
- una tarea **`CFG`** en EP-09, o
- un **bug de regresión**.

Así no se borra trabajo real ni se finge que la migración ya ocurrió.

## Punto de partida real

Backlog V4 §3: la arquitectura anterior **no es un backend que haya que mover de lenguaje**. Es un cliente Flutter hablando directo con Supabase y la lógica de negocio en ~32 funciones PL/pgSQL. Por tanto:

1. la migración consiste en **crear el backend que no existe y sacar al cliente de la base de datos**;
2. los riesgos KI-01 y KI-02 del SAD están mal calibrados y su corrección es la tarea `DOC-28`.

## Qué se conserva

Supabase, Auth, RLS y aislamiento multi-tenant · registro y aprobación de aliados · registro de cliente · categorías · creación de solicitud · exclusión concurrente · las PoC de despacho, identidad y Storage/KYC · pipelines, GHCR, secretos y promoción de ambientes · seeds multi-tenant · documentación y diagramas consolidados.

Ese trabajo **cambia de ubicación**, no se desecha: parte de la lógica se mueve a Gateway, Rules (Java), Dispatch (.NET), Core (Node) y Availability (Node), y el cliente deja de invocarla.

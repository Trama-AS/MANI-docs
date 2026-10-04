# Riesgos y puntos abiertos

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SAD.md`](../../architecture/SAD.md) §23 · [`architecture/SDD.md`](../../architecture/SDD.md) §16 · [`governance/INFRAESTRUCTURA_MANI.md`](../../governance/INFRAESTRUCTURA_MANI.md) §25 · [`product/BACKLOG_MANI_V4_TRANSICION.md`](../../product/BACKLOG_MANI_V4_TRANSICION.md) §3, §4.1 y §4.2.

Esta página existe para que nadie —persona o asistente— «resuelva» en un PR algo que el equipo todavía no decidió.

## Architectural killers (SAD §23)

| ID | Riesgo |
|---|---|
| KI-01 | Lógica de negocio en Flutter |
| KI-02 | Acceso directo indiscriminado a Supabase |
| KI-03 | Servicios excesivamente pequeños |
| KI-04 | Dependencias síncronas largas |
| KI-05 | Pérdida de aislamiento multi-tenant |
| KI-06 | Doble asignación |
| KI-07 | Consultas analíticas sobre OLTP |
| KI-08 | Complejidad políglota |

**Corrección registrada:** el backlog V4 §3 documenta que KI-01 y KI-02 están mal calibrados en el SAD vigente. La lógica de negocio no está en Flutter, sino en ~32 funciones PL/pgSQL; lo que hay en Flutter son casos de uso que orquestan llamadas RPC. Corregir SAD y SDD es la tarea `DOC-28`.

## Decisiones abiertas

| ID | Decisión pendiente | Dónde se registra |
|---|---|---|
| `SP-05` | Si los servicios **reescriben** la lógica PL/pgSQL o la **invocan**. Bloquea la estimación de todo el trabajo funcional de migración | Backlog V4 §4.1; resultado se registra en ADR (`DOC-26`) |
| `INFRA-01` | Hosting de Kubernetes | `INFRAESTRUCTURA_MANI.md` §25 |
| `INFRA-02` | Topología final del clúster | `INFRAESTRUCTURA_MANI.md` §25 |
| `CFG-31` | Hosting y topología concretos, como tarea ejecutable | Backlog V4 §4.2 |

Hasta que exista decisión sobre Kubernetes (Políticas DevOps §12): no se inventan nodos, no se fija proveedor, no se documenta capacidad como definitiva, y Docker Compose sobre VMs sigue siendo el mecanismo operativo. **No se asume AKS ni Azure.**

## Riesgos de mayor impacto de la transición

Backlog V4 §4.2 los señala como los tres no contemplados antes y de mayor riesgo:

- **`CFG-23`** — las políticas RLS derivan tenant y usuario de `auth.uid()` porque hoy el llamador es el cliente. Con un servicio `service-role` como llamador, **dejan de aislar**. Es el punto que puede tumbar RNF-01.
- **`CFG-36`** — el artefacto web publicado hoy incluye la `SUPABASE_ANON_KEY`: cualquiera puede llamar a PostgREST directamente y sólo RLS lo contiene. Hay que sacarla del bundle y rotarla.
- **`CFG-38`** — hay 13 ramas vivas con trabajo sin fusionar en `MANI-Flutter`. Sin reconciliarlas primero, el trabajo funcional se ejecuta sobre una base incompleta.

Además, `US-04.1.4` concentra el mayor riesgo de regresión funcional: la exclusión concurrente la garantiza hoy la transacción de PostgreSQL y hay que decidir dónde vive la atomicidad y revalidar el PoC-001.

## Huecos documentales localizados

Detectados al navegar este repositorio. **No alteran ninguna decisión**; se listan para que quien consulte no los confunda con errores de la wiki.

| Hueco | Detalle |
|---|---|
| Ruta de `workspace.dsl` | `README.md` §13 y `GOBIERNO_DEL_EQUIPO.md` §3.1 lo citan sin ruta; el archivo vive en [`diagrams/C4Model/workspace.dsl`](../../diagrams/C4Model/workspace.dsl) |
| `MANI_Modelo_de_Datos.md` | `README.md` §13 y `GOBIERNO_DEL_EQUIPO.md` §3.1 lo citan con ese nombre; el archivo real es [`architecture/ModeloDatos.md`](../../architecture/ModeloDatos.md), al que SAD y SDD ya apuntan |
| `docs/governance/POLITICA_USO_IA.md` | Citado por ADR-0009 como su sustituto; no existe. La política vigente es Políticas DevOps §18 |
| Estructura de `README.md` §13 | Describe `Product/`, `Architecture/`, `ADR/`, `Project/`, `DevOps/`, `Infrastructure/`, `Diagramas/`; el árbol real es el de [Estructura de MANI-Docs](../04-repositorios/estructura-de-mani-docs.md) |
| ADR-0022..ADR-0026 | Referenciados por `DOC-27` como recuperables; no están en `adr/` |
| `architecture_context.txt` | `DOC-25` pide actualizarlo; no está en este repositorio |

Cerrar cualquiera de estos huecos es trabajo de EP-10 en Jira, no una edición improvisada.

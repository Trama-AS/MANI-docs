# Riesgos y puntos abiertos

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SAD.md`](../../architecture/SAD.md) §23 · [`architecture/SDD.md`](../../architecture/SDD.md) §16 · [`governance/INFRAESTRUCTURA_MANI.md`](../../governance/INFRAESTRUCTURA_MANI.md) §25 · [`product/BACKLOG_MANI.md`](../../product/BACKLOG_MANI.md) §3, §4.1 y §4.2.

Esta página existe para que nadie —persona o asistente— «resuelva» en un PR algo que el equipo todavía no decidió.

## Riesgos arquitectónicos (SAD §23)

Los riesgos se nombran, no se numeran: el SAD §23 es la fuente y cada uno trae su riesgo y su control.

| Riesgo | Control (SAD §23) |
|---|---|
| Lógica de negocio en Flutter | Mover la lógica al backend |
| Acceso directo indiscriminado a Supabase | Servicios como frontera principal; RLS como defensa adicional |
| Servicios excesivamente pequeños | Dividir por capacidad de negocio, no por operación CRUD |
| Dependencias síncronas largas | Eventos para efectos secundarios y circuit breaker |
| Pérdida de aislamiento multi-tenant | JWT + autorización + RLS + pruebas automatizadas |
| Doble asignación | Exclusión atómica en PostgreSQL |
| Consultas analíticas sobre OLTP | Data Warehouse separado |
| Complejidad políglota | Contratos estandarizados, CI/CD homogéneo y límites claros por servicio |

**Corrección registrada:** el backlog V4 §3 documenta que los dos primeros están mal calibrados en el SAD vigente. La lógica de negocio no está en Flutter, sino en ~32 funciones PL/pgSQL; lo que hay en Flutter son casos de uso que orquestan llamadas RPC. Corregir SAD y SDD es la tarea `DOC-28`.

## Decisiones abiertas

| ID | Decisión pendiente | Dónde se registra |
|---|---|---|
| `INFRA-01` | Hosting de Kubernetes | `INFRAESTRUCTURA_MANI.md` §25 |
| `INFRA-02` | Topología final del clúster | `INFRAESTRUCTURA_MANI.md` §25 |

**Ya decidido — `SP-05`.** Si los servicios reescriben la lógica PL/pgSQL o la invocan. **Resuelto en la daily del 2026-10-05: la lógica se reescribe en los servicios.** Registrado en [`adr/ADR-0022`](../../adr/ADR-0022-logica-de-negocio-en-servicios.md) (tarea `DOC-26`, cerrada). El ADR está en estado **Propuesto**: pasarlo a Aceptado requiere sesión formal de la Mesa (Gobierno §2.6). Ya no bloquea ninguna estimación.

Hasta que exista decisión sobre Kubernetes (Políticas DevOps §12): no se inventan nodos, no se fija proveedor, no se documenta capacidad como definitiva, y Docker Compose sobre VMs sigue siendo el mecanismo operativo. **No se asume AKS ni Azure.**

## Riesgos de mayor impacto de la transición

Backlog V4 §4.2 los señala como los tres no contemplados antes y de mayor riesgo:

- **`CFG-23a`, `CFG-23b` y `CFG-23c`** — las políticas RLS derivan tenant y usuario de `auth.uid()` porque hoy el llamador es el cliente. Con un servicio `service-role` como llamador, **dejan de aislar**. Es el punto que puede tumbar RNF-01.
- **`CFG-36`** — el artefacto web publicado hoy incluye la `SUPABASE_ANON_KEY`: cualquiera puede llamar a PostgREST directamente y sólo RLS lo contiene. Hay que sacarla del bundle y rotarla.
- **`CFG-38`** — había 13 ramas vivas con trabajo sin fusionar en `MANI-Frontend`. **Mitigado el 2026-10-07**: todas quedaron fusionadas en `develop` o reemplazadas por un PR posterior, y `develop` es la base única ([detalle](../04-repositorios/multirepo.md#reconciliación-de-ramas-de-mani-flutter-cfg-38)).

Además, `US-04.1.4` concentra el mayor riesgo de regresión funcional: la exclusión concurrente la garantiza hoy la transacción de PostgreSQL y hay que decidir dónde vive la atomicidad y revalidar el PoC-001.

## Huecos documentales localizados

Detectados al navegar este repositorio. **No alteran ninguna decisión**; se listan para que quien consulte no los confunda con errores de la wiki.

| Hueco | Detalle |
|---|---|
| `docs/governance/POLITICA_USO_IA.md` | Citado por ADR-0009 como su sustituto; no existe. La política vigente es Políticas DevOps §18 |
| ADR-0022..ADR-0026 | Referenciados por `DOC-27` como recuperables; no están en `adr/` |
| `architecture_context.txt` | `DOC-25` pide actualizarlo; no está en este repositorio |

Cerrar cualquiera de estos huecos es trabajo de EP-10 en Jira, no una edición improvisada.

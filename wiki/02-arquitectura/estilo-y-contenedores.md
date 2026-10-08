# Estilo y contenedores

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SAD.md`](../../architecture/SAD.md) §4–§7 y §21 · [`architecture/SDD.md`](../../architecture/SDD.md) §2–§3 · [`adr/ADR-0019`](../../adr/ADR-0019-arquitectura-soa-poliglota.md) · [`adr/ADR-0023`](../../adr/ADR-0023-consolidacion-repositorios-ambientes.md).

## Decisiones de línea base

Fijadas en [`SDD.md`](../../architecture/SDD.md) §2.1, que es su fuente:

| Tema | Decisión |
|---|---|
| Ambientes | 3: DEV → QA → PROD |
| DEV | máquinas personales, con Docker local |
| QA y PROD | una VM por ambiente, con Docker |
| Orquestación | **abierta**: Kubernetes es el objetivo de PROY-08, no el estado actual |
| Repositorios | Multi-repo, seis |
| Persistencia | Supabase como plataforma administrada |
| Motor de base de datos | PostgreSQL provisto por Supabase |
| Aislamiento multi-tenant | JWT + autorización en servicios + RLS |
| Contenedores | Docker / OCI |
| CI/CD | GitHub Actions |

**Supabase y PostgreSQL no son alternativas distintas:** Supabase es la plataforma administrada y PostgreSQL su motor relacional.

## Contenedores

```text
Usuarios
   ↓
Flutter Web / Mobile        ← presentación e interacción, sin reglas de negocio
   │
   ├─ HTTPS ─→ NGINX API Gateway   ← entrada única, routing y políticas transversales
   │              ↓
   │           Rules (Java) · Dispatch (.NET) · Core (Node.js)
   │              ↓
   │           Supabase: PostgreSQL + RLS · Storage
   │              ↓
   │           Integraciones: FCM/APNs · operador de pagos (2.º incremento)
   │
   ├─ HTTPS ─→ Supabase Auth       sesión y JWT
   └─ WSS  ←─  Supabase Realtime   eventos de mensajería
```

**Tres servicios de negocio.** La cobertura y la disponibilidad son un dominio del Core Service:
no tienen repositorio, desplegable, esquema ni vista de componentes propios
([ADR-0023](../../adr/ADR-0023-consolidacion-repositorios-ambientes.md)).

## Responsabilidad por servicio

El detalle de qué RF atiende cada servicio está en [`SAD.md`](../../architecture/SAD.md) §7, y el
dueño de cada esquema de datos en [`ModeloDatos.md`](../../architecture/ModeloDatos.md) §13. Resumen
para orientarse:

| Servicio | Runtime | De qué es dueño |
|---|---|---|
| **Rules Service** | Java | reglas por tenant, ranking y tarifario · esquema `reglas` |
| **Dispatch Service** | .NET | solicitudes, despacho y asignación · esquema `despacho` |
| **Core Service** | Node.js | identidad, clientes y sitios, aliados y KYC, catálogo, cobertura y disponibilidad, ciclo del servicio, comunicaciones y reportes · esquemas `core`, `servicio`, `comunicaciones`, `pagos` |

Notas que evitan errores de implementación:

- Rules **no** guarda reglas fijas por tenant en código: las lee de persistencia (SAD §7.1).
- Rules **evalúa** el tarifario; **Core escribe** la cotización. Rules no escribe `servicio.cotizacion` (ModeloDatos §13).
- Dispatch consulta la elegibilidad por la **API** del Core Service, nunca leyendo su esquema.
- Core puede dividirse internamente por dominios, pero **no** se convierte cada CRUD en un servicio independiente (SAD §7.3, riesgo KI-03).
- La primera aceptación válida se confirma con actualización condicional atómica; las siguientes reciben `409 Conflict` (SAD §7.2).

## Acceso del cliente a Supabase

**No hay excepciones.** El cliente Flutter alcanza Supabase por exactamente dos caminos
([SAD §8.3](../../architecture/SAD.md), [SDD §2.2](../../architecture/SDD.md)):

| Camino | Para qué |
|---|---|
| `Flutter → Supabase Auth` | sesión, registro y refresco del JWT |
| `Flutter ← Supabase Realtime` | recepción de eventos de mensajería; es **transporte**, no acceso a datos |

Están retirados del cliente `.from()`, `.rpc()` y `.storage.from()`
([ADR-0027](../../adr/ADR-0027-alcance-supabase-cliente-flutter.md)). La consulta de
disponibilidades **no** es una excepción: entra por el Gateway al Core Service como cualquier otra
lectura de negocio ([ADR-0022](../../adr/ADR-0022-logica-de-negocio-en-servicios.md)).

La lógica de negocio vive en los servicios, no en el cliente ni en funciones PL/pgSQL (ADR-0022).

## Patrones

El catálogo completo está en [`SDD.md`](../../architecture/SDD.md) §5 y §6. Qué driver del SRS
resuelve cada patrón está en [`SAD.md`](../../architecture/SAD.md) §21.

Dos reglas que conviene no olvidar al implementar:

- el **Gateway no implementa reglas de dominio**;
- **event-driven aplica solo a efectos secundarios** —notificación, auditoría, analítica—, no para
  coordinar el flujo principal del ciclo del servicio.

Un patrón nuevo con impacto estructural pasa por [Mesa de Arquitectura](../05-proceso/roles-y-decisiones.md) y produce un ADR.

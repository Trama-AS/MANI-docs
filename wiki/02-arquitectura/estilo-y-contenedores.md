# Estilo y contenedores

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SAD.md`](../../architecture/SAD.md) §4–§7 y §21 · [`architecture/SDD.md`](../../architecture/SDD.md) §3 y §4.2 · [`adr/ADR-0019`](../../adr/ADR-0019-arquitectura-soa-poliglota.md).

## Decisiones de línea base

Fijadas en SDD §2.2 para que ADR, diagramas y despliegue no se contradigan:

| Tema | Decisión |
|---|---|
| Ambientes | 3: DEV → TEST/QA → PROD |
| Repositorios | Multi-repo |
| Persistencia | Supabase como plataforma administrada |
| Motor de base de datos | PostgreSQL provisto por Supabase |
| Aislamiento multi-tenant | JWT + autorización en servicios + RLS |
| Orquestación | Kubernetes |
| Contenedores | Docker / OCI |
| CI/CD | GitHub Actions |

**Supabase y PostgreSQL no son alternativas distintas:** Supabase es la plataforma administrada y PostgreSQL su motor relacional.

## Contenedores

```text
Usuarios
   ↓
Flutter Web / Mobile        ← presentación e interacción, sin reglas de negocio
   ↓ HTTPS
NGINX API Gateway           ← entrada única, routing y políticas transversales
   ↓
Rules (Java) · Dispatch (.NET) · Core (Node.js)
   ↓
Supabase: Auth · PostgreSQL + RLS · Storage · Realtime
   ↓
Integraciones: FCM/APNs · operador de pagos (2.º incremento)
```

## Responsabilidad por servicio

| Servicio | Runtime | Responsable de |
|---|---|---|
| **Rules Service** | Java | RF-02 evaluación de reglas por tenant · RF-13 ranking · RF-16 validación contra tarifario · RF-22 rangos tarifarios · parte de RNF-02 y RNF-10 |
| **Dispatch Service** | .NET | RF-12 coordinación operacional de solicitudes · RF-14 aceptación/rechazo · RNF-03 idempotencia · RNF-05 exclusión concurrente · estados de asignación · auditoría del despacho |
| **Core Services** | Node.js | RF-01 tenants · RF-03/RF-04 identidad y acceso · RF-05/RF-06 aliados y KYC · RF-07 cobertura del aliado · RF-08/RF-09 clientes y sitios · RF-10/RF-11 categorías · RF-12 elegibilidad por categoría y zona, horarios y disponibilidad (soporte a RNF-07) · RF-15, RF-17, RF-18, RF-19 · RF-20/RF-21 comunicación · RF-23 reportes · RF-24..RF-28 cuando se implementen |

Notas que evitan errores de implementación:

- Rules **no** guarda reglas fijas por tenant en código: las lee de persistencia (SAD §7.1).
- Core puede dividirse internamente por dominios, pero **no** se convierte cada CRUD en un servicio independiente (SAD §7.3, riesgo KI-03). La disponibilidad es uno de esos dominios internos, no un servicio desplegable.
- La primera aceptación válida se confirma con actualización condicional atómica; las siguientes reciben `409 Conflict` (SAD §7.2).

## Patrones

**Arquitectónicos** (SAD §21, SDD §5): SOA · API Gateway · Layered Architecture interna · Repository / Ports and Adapters · event-driven **sólo para efectos secundarios**, no para coordinar el flujo principal.

**De diseño** (SAD §22, SDD §6): se aplican según el documento; un patrón nuevo con impacto estructural pasa por [Mesa de Arquitectura](../05-proceso/roles-y-decisiones.md).

## Excepción transitoria vigente

SDD §2.1: el diagrama de alto nivel muestra acceso directo de Flutter a Supabase para disponibilidades. Es **excepción transitoria**, no estado objetivo. Mientras exista:

- no se implementan reglas de negocio en Flutter;
- no se exponen tablas sin controles de acceso;
- todo acceso directo queda protegido por RLS y limitado a operaciones simples autorizadas;
- la evolución objetivo es `Flutter → API Gateway → Core Services (dominio de disponibilidad) → Supabase`.

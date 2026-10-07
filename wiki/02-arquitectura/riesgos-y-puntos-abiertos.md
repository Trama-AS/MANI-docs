# Riesgos y puntos abiertos

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SAD.md`](../../architecture/SAD.md) §23 · [`architecture/SDD.md`](../../architecture/SDD.md) §16 · [`governance/INFRAESTRUCTURA_MANI.md`](../../governance/INFRAESTRUCTURA_MANI.md) §25 · [`product/BACKLOG_MANI.md`](../../product/BACKLOG_MANI.md) §3 y §4.

Esta página existe para que nadie —persona o asistente— «resuelva» en un PR algo que el equipo todavía no decidió.

## Architectural killers

El registro con el efecto y el control de cada riesgo está en [`SAD.md`](../../architecture/SAD.md)
§23; dónde se materializa el control en el diseño, en [`SDD.md`](../../architecture/SDD.md) §16.

| ID | Riesgo | Estado |
|---|---|---|
| KI-01 | Lógica de negocio en Flutter | **en cierre** por ADR-0022 |
| KI-02 | Acceso directo indiscriminado a Supabase | **en cierre** por ADR-0022 y ADR-0027 |
| KI-03 | Servicios excesivamente pequeños | controlado: disponibilidades es módulo, no desplegable (ADR-0023) |
| KI-04 | Dependencias síncronas largas | controlado por diseño |
| KI-05 | Pérdida de aislamiento multi-tenant | **abierto y vigilado** — ver `CFG-23` abajo |
| KI-06 | Doble asignación | controlado por exclusión atómica |
| KI-07 | Consultas analíticas sobre OLTP | controlado: DW desacoplado |
| KI-08 | Complejidad políglota | controlado: tres servicios, CI/CD homogéneo |

**KI-01 y KI-02 estaban mal calibrados** en versiones anteriores del SAD. La lógica de negocio no
estaba solo en Flutter: estaba repartida entre el cliente y ~32 funciones PL/pgSQL.
[ADR-0022](../../adr/ADR-0022-logica-de-negocio-en-servicios.md) corrige el diagnóstico y decide la
salida. KI-01 se cierra cuando la última historia `-M2`/`-M3` retire la lógica del cliente; KI-02,
cuando `CFG-35` confirme que el cliente ya no usa `.rpc()`, `.from()` ni `.storage.from()`.

## Decisiones abiertas

| ID | Decisión pendiente | Dónde se registra |
|---|---|---|
| `INFRA-01` | Plataforma y hosting de orquestación: si es Kubernetes y con qué proveedor y dimensionamiento | [`INFRAESTRUCTURA_MANI.md`](../../governance/INFRAESTRUCTURA_MANI.md) §25 |
| `INFRA-02` | Topología final: nodos, namespaces o clusters por ambiente, ingress y networking | [`INFRAESTRUCTURA_MANI.md`](../../governance/INFRAESTRUCTURA_MANI.md) §25 |
| `CFG-31` | Hosting y topología concretos, como tarea ejecutable | Backlog §4 |

Hasta que exista decisión sobre la orquestación (Políticas DevOps §12): no se inventan nodos, no se
fija proveedor, no se documenta capacidad como definitiva y **no se asume AKS ni Azure**. Docker
sobre VM es el mecanismo de despliegue vigente de QA y PROD, no un paso intermedio hacia algo ya
elegido.

### Ya cerradas — no se reabren sin ADR

| Tema | Resuelto por |
|---|---|
| Si los servicios reescriben la lógica PL/pgSQL o la invocan (`SP-05`) | **Reescriben.** [ADR-0022](../../adr/ADR-0022-logica-de-negocio-en-servicios.md) |
| Si el cliente conserva acceso directo a Supabase | **No,** salvo Auth y Realtime. [ADR-0027](../../adr/ADR-0027-alcance-supabase-cliente-flutter.md) |
| Cuántos repositorios y servicios desplegables hay | **Seis repositorios, tres servicios de negocio.** [ADR-0023](../../adr/ADR-0023-consolidacion-repositorios-ambientes.md) |
| Nombres de los ambientes y dónde corren | **DEV, QA y PROD**; DEV local, QA y PROD en VM con Docker. [ADR-0023](../../adr/ADR-0023-consolidacion-repositorios-ambientes.md) |
| Registro de imágenes | **GHCR.** `INFRAESTRUCTURA_MANI.md` §25 |

## Riesgos de mayor impacto de la transición

- **`CFG-23`** — las políticas RLS derivan tenant y usuario de `auth.uid()` porque hoy el llamador es el cliente. Con un servicio `service-role` como llamador, **dejan de aislar**. Es el punto que puede tumbar RNF-01. Mitigación prevista: los servicios aplican autorización por tenant tomando el claim del JWT, RLS queda como defensa adicional y el aislamiento se acredita con los casos cross-tenant de `CFG-23c` (ADR-0015).
- **`CFG-36`** — el artefacto web publicado hoy incluye la `SUPABASE_ANON_KEY`: cualquiera puede llamar a PostgREST directamente y sólo RLS lo contiene. Hay que sacarla del bundle y rotarla.
- **`CFG-38`** — hay 13 ramas vivas con trabajo sin fusionar en `MANI-Frontend`. Sin reconciliarlas primero, el trabajo funcional se ejecuta sobre una base incompleta.
- **Caída de la VM del ambiente** — con Docker sobre una sola máquina no hay recuperación a nivel de host: la caída de la VM tumba el ambiente. Es una limitación del estado actual, registrada en ADR-0023, y se levanta cuando se cierre `INFRA-01`.

`US-04.1.4` concentra el mayor riesgo de regresión funcional: la exclusión concurrente la garantiza hoy la transacción de PostgreSQL, y con ADR-0022 la emite Dispatch. Hay que revalidar el PoC-001.

## Huecos documentales localizados

**No alteran ninguna decisión**; se listan para que quien consulte no los confunda con errores de la wiki.

| Hueco | Detalle |
|---|---|
| `docs/governance/POLITICA_USO_IA.md` | Citado por ADR-0009 como su sustituto; no existe. La política vigente es Políticas DevOps §18 |
| ADR-0024, ADR-0025, ADR-0026 | Nunca se emitieron. El hueco está explicado en [Decisiones ADR](decisiones-adr.md#numeración) y no se reutilizan |
| `architecture_context.txt` | `DOC-25` pide actualizarlo; no está en este repositorio |
| Vistas de secuencia y de despliegue de QA | Definidas en [`workspace.dsl`](../../diagrams/LLD/workspace.dsl) y **pendientes de exportar** a PNG; el SDD §4.6 y §9.1 describen el flujo en texto |

Cerrar cualquiera de estos huecos es trabajo de EP-10 en Jira, no una edición improvisada.

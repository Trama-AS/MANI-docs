# Trazabilidad de integración — eventos, contratos y despliegue

**Entregable:** ARQ-10 (SCRUM-1241) · **Sprint 4** · **Corte de datos:** 2026-10-18

Este documento no decide nada. Recoge en un solo lugar la cadena **evento o contrato → servicio →
artefacto desplegado → ADR que lo decide → tarea que lo implementa**, para que una revisión pueda
seguirla sin abrir siete documentos. Donde algo no existe todavía, lo dice en lugar de omitirlo.

Fuentes: [`ADR-0029`](../adr/ADR-0029-comunicacion-asincrona-kafka.md),
[`ADR-0030`](../adr/ADR-0030-propiedad-esquema-y-frontera-de-datos.md),
[`CONTRATOS_EVENTOS`](CONTRATOS_EVENTOS.md),
[`SAD`](SAD.md) §7.4 y §12, [`SDD`](SDD.md) §2.1,
[`ModeloDatos`](ModeloDatos.md) §6.3 y §7,
[`COMUNICACION_SERVICIOS_GATEWAY`](COMUNICACION_SERVICIOS_GATEWAY.md),
[`DOCUMENTO_INFRAESTRUCTURA_V3`](../governance/DOCUMENTO_INFRAESTRUCTURA_V3.md).

---

## 1. Estado de la integración al cierre del Sprint 4

| Plano | Mecanismo vigente hoy | Mecanismo objetivo | Decide |
|---|---|---|---|
| Servicio ↔ servicio | HTTP sincrónico por red interna, **falla cerrado** (`503`, sin degradar a lógica local) | Bus de eventos Apache Kafka | ADR-0029, ADR-0030 §2 |
| Servicio → usuario final | Supabase Realtime + FCM/APNs | sin cambio | ADR-0017, SAD §12.1 |
| Cliente → backend | Flutter → API Gateway → servicio | sin cambio | ADR-0027 |
| Servicio ↔ base | Rol por esquema, escritura exclusiva del dueño | separación física de bases | ADR-0012, ADR-0030, `ModeloDatos` §6.3 |

**No hay broker desplegado.** Ninguna capacidad del Sprint 4 depende de consumo asíncrono.

---

## 2. Eventos de negocio

### 2.1 Matriz de trazabilidad

| Evento | Productor | Outbox | Consumidores previstos | Estado | Tarea |
|---|---|---|---|---|---|
| `SolicitudCreada` | Core Service | `servicio.outbox` | Dispatch (broadcast), DW | esquema `v1` y versionado definidos ([`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md)), sin publicar | ARQ-06 (SCRUM-1237) |
| `AliadoAsignado` | Dispatch Service | `despacho.outbox` | Core (notificación), DW | esquema `v1` y versionado definidos ([`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md)), sin publicar | ARQ-06 (SCRUM-1237) |
| `CotizacionAceptada` | Core Service | `servicio.outbox` | Dispatch, DW | esquema `v1` y versionado definidos ([`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md)), sin publicar | ARQ-06 (SCRUM-1237) |
| `ServicioFinalizado` | Core Service | `servicio.outbox` | Core (calificación RF-19 / cierre), DW | esquema `v1` y versionado definidos ([`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md)), sin publicar | ARQ-06 (SCRUM-1237) |

Cada evento tiene **un solo productor**, que es el servicio dueño de la capacidad según SAD §7.4 y
ADR-0022. Ningún servicio emite un evento de un dominio ajeno.

### 2.2 Sobre común

Definido en ADR-0029 §2 y especificado formalmente en [`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md) §3, persistido en las columnas que documenta `ModeloDatos` §8:

| Campo del sobre | Columna del outbox | Por qué es obligatorio |
|---|---|---|
| `event_id` | `id_evento` | clave de deduplicación del consumidor idempotente |
| `event_type` | `tipo_evento` | enrutamiento y `CHECK` por esquema productor |
| `event_version` | `version_evento` | sube solo ante cambio incompatible |
| `occurred_at` | `fecha_ocurrencia` | momento del hecho, no de la publicación |
| `tenant_id` | `id_tenant` | RNF-01 también aplica a los eventos; no se infiere del contenido |
| `correlation_id` | `correlation_id` | continúa el `X-Correlation-ID` del Gateway (RNF-07) |
| `partition_key` | `clave_particion` | `id_solicitud`; garantiza orden causal por solicitud |
| `data` | `payload` | estado propio del agregado, nunca datos de otro dominio |

### 2.3 Cadena de tareas y qué falta

| Tarea | Alcance | Estado | Bloqueo |
|---|---|---|---|
| ARQ-04 (SCRUM-1235) | ADR-0029 | **cerrada**, PR #36 fusionado | — |
| ARQ-06 (SCRUM-1237) | esquema y versionado de eventos | **entregada** en [`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md) + JSON Schemas verificables | — |
| ARQ-07 (SCRUM-1238) | publicación confiable | ejecutable con alcance «escribe al outbox» | ninguno |
| ARQ-05 (SCRUM-1236) | Kafka en DEV y QA | **diferida al Sprint 5** | condicionada al cierre de CFG4-02 |
| ARQ-08 (SCRUM-1239) | consumidores idempotentes | **diferida al Sprint 5** | depende de ARQ-05 |

---

## 3. Contratos de integración HTTP

Patrón único, ya implementado en Core → Rules y fijado por ADR-0030 §2:

- puerto declarado en el dominio y cliente en infraestructura;
- `timeout` explícito; reintento **solo** en operaciones idempotentes;
- propagación de `X-Tenant-Id`, `X-User-Role` y `X-Correlation-ID` tomados del claim verificado,
  **nunca del cuerpo** de la petición;
- **falla cerrado**: si la dependencia no responde, `503` al llamador, sin valor por omisión.

| Llamador | Llamado | Para qué | Alternativa prohibida |
|---|---|---|---|
| Dispatch | Core | elegibilidad por categoría y zona | leer `core.aliado_cobertura` o `core.disponibilidad` |
| Dispatch | Rules | orden del listado | leer `reglas.tarifario` |
| Dispatch | Core | notificación al usuario | integrar FCM/APNs por su cuenta |
| Core | Rules | veredicto de tarifa | escribir `reglas.*` |
| Rules | — | devuelve veredicto; **Core** escribe `fuera_de_rango` | escribir `servicio.cotizacion` |

El enrutamiento perimetral y los estándares transversales están en
[`COMUNICACION_SERVICIOS_GATEWAY`](COMUNICACION_SERVICIOS_GATEWAY.md) §3 y §4. La frontera es
exigible por el motor: ningún rol de servicio tiene `SELECT` sobre un esquema ajeno
(`ModeloDatos` §6.3).

---

## 4. Despliegue

La topología, el inventario de máquinas, el perímetro NGINX y el runbook están en
[`DOCUMENTO_INFRAESTRUCTURA_V3`](../governance/DOCUMENTO_INFRAESTRUCTURA_V3.md) §3 a §9. Aquí solo la
trazabilidad de qué artefacto responde por cada pieza de integración:

| Pieza de integración | Dónde vive | Documento |
|---|---|---|
| Punto único de entrada y enrutamiento | NGINX API Gateway | Infraestructura V3 §5, Comunicación §3 |
| Validación de JWT y propagación de claims | Gateway + servicios | Infraestructura V3 §5, ADR-0018, ADR-0031 |
| Persistencia compartida por ambiente | PostgreSQL/Supabase, una base por ambiente | Infraestructura V3 §6, CFG4-02 (SCRUM-1254) |
| Cadena de calidad | SonarQube, Newman, Playwright | Infraestructura V3 §7, CFG4-03 |
| Promoción de imágenes | GHCR, DEV → QA → PROD | Infraestructura V3 §8 |
| **Broker de eventos** | **no desplegado** | ADR-0029; ARQ-05 difiere a Sprint 5 |
| **Relay del outbox** | **no implementado** | ADR-0029 §3; rol `mani_relay` ya especificado en `ModeloDatos` §6.3 |

---

## 5. Puntos abiertos

1. **Ubicación de `solicitud`.** La tabla está bajo el esquema `despacho`, pero SAD §7.4 asigna a
   Core la creación de la solicitud. Declarado en `ModeloDatos` §6.1; lo resuelve el dueño de la
   serie de migraciones (ADR-0030 §1).
2. **Los roles de base no están aplicados.** `ModeloDatos` §6.3 especifica los seis roles y sus
   `GRANT`; falta emitirlos como migración en la serie de Core y verificarlos en DEV y QA.
3. **Consumidores sin designar.** La columna «consumidores previstos» de §2.1 refleja el diseño,
   no un compromiso de implementación: ARQ-08 los fijará cuando el broker exista.

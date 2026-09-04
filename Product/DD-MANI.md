# MANI DD (Documento de Diseño)

**Empresa:** TRAMA · Ingeniería de Software
**Producto:** MANI — plataforma multi-tenant de formalización de operaciones de servicio
**Documento:** DD V2
**Estado:** Borrador para revisión
**Fecha de esta versión:** 2026-09-03

## Historial de versiones

| Versión | Momento | Cambios principales |
|---|---|---|
| **V1** | Sprint 2, 2026-09-03 | Primera versión del DD: vista de componentes, reglas de diseño, trazabilidad RF → entidad → ADR. Publicado junto con `Modelo_Datos_MANI.md` (explicación del diagrama UML). |
| **V2** | Sprint 2, 2026-09-03 | Se había fusionado brevemente con `Modelo_Datos_MANI.md` en un solo archivo; se separan de nuevo a pedido del equipo. Este documento vuelve a ser solo el DD (componentes + reglas de diseño); el detalle entidad por entidad del modelo de datos vive únicamente en `Product/Modelo_Datos_MANI.md`. |

## Índice

1. [Propósito y alcance](#1-propósito-y-alcance)
2. [Trazabilidad SRS → SAD → DD](#2-trazabilidad-srs--sad--dd)
3. [Vista de componentes](#3-vista-de-componentes)
4. [Modelo de datos — remisión](#4-modelo-de-datos--remisión)
5. [Reglas de diseño críticas](#5-reglas-de-diseño-críticas)
6. [Trazabilidad RF → entidad → ADR](#6-trazabilidad-rf--entidad--adr)
7. [Fuera de alcance de este DD](#7-fuera-de-alcance-de-este-dd)
8. [Convenciones del modelo](#8-convenciones-del-modelo)

---

## 1. Propósito y alcance

Este documento especifica el **cómo** de MANI a nivel de diseño de solución: los
componentes de software y las reglas de diseño que un desarrollador necesita para
implementar el MVP (EP-01..EP-06). No repite decisiones ya tomadas en el SAD
(`Product/SAD-MANI.md`) ni en los ADR — las referencia por código. Tampoco repite el
detalle entidad por entidad del modelo de datos — eso vive en `Product/Modelo_Datos_MANI.md`,
el único documento que muestra el diagrama UML y lo explica.

- **No es** una especificación de qué debe hacer el sistema — eso vive en el SRS
  (`Product/SRS_MANI.md`).
- **No es** el análisis de drivers/killers/trade-offs de alto nivel — eso vive en el SAD.
- **No es** el catálogo de entidades ni la explicación del diagrama de clases — eso vive
  en `Product/Modelo_Datos_MANI.md`. Este DD fija las **reglas** que ese modelo implementa
  y el mapeo de capacidades de negocio a componentes técnicos.

Alcance: **MVP únicamente** (RF-01 a RF-23). El 2º incremento (RF-24 a RF-28: pagos,
quejas, comercialización, administración avanzada) se menciona en §7 pero no se diseña.

## 2. Trazabilidad SRS → SAD → DD

```
SRS (qué)  →  SAD (drivers, killers, escenarios de calidad, C4 contenedores)  →  DD (cómo: componentes y reglas) + Modelo de Datos (entidades)  →  ADR (por qué esta opción y no otra)
```

Este DD consume:

- `Product/SRS_MANI.md` — RF-01..RF-23, RNF-01..RNF-11, REST-01..REST-05.
- `Product/SAD-MANI.md` §7 — actores y capacidades de negocio (arquitectura de negocio).
- `Product/SAD-MANI.md` §"Vista de Contenedores" — C4 Nivel 2, stack de cada contenedor.
- ADR-0011 (cobertura), ADR-0012 (backend/persistencia/RLS), ADR-0013 (storage KYC),
  ADR-0016 (despacho), ADR-0017 (mensajería), ADR-0018 (identificación de tenant),
  ADR-0021 (consolidación de stack backend), ADR-0022 (proveedor de identidad).

No introduce entidades, actores ni reglas que no existan ya en esos documentos.

## 3. Vista de componentes

Mapeo de las capacidades de negocio (SAD §7.3) a los contenedores técnicos ya
ratificados en el C4 de Nivel 2 (SAD "Vista de Contenedores") y en PROY-07:

| Capacidad de negocio | Módulo (SRS) | Componente técnico | ADR / stack |
|---|---|---|---|
| Gestión de tenants y aislamiento | M-01 | Backend Serverpod (Dart) + Supabase Postgres/RLS | ADR-0012, ADR-0018 |
| Autenticación y control de acceso | M-01 | Supabase Auth (IdP) + middleware JWT en cada servicio | ADR-0018, ADR-0022 |
| Directorio de aliados / KYC | M-02 | Backend Serverpod + Supabase Storage (bucket único, ruta `tenant_id/aliado_id/…`) | ADR-0013 |
| Directorio de clientes y sitios | M-03 | Backend Serverpod + Supabase Postgres | ADR-0012 |
| Catálogo y cobertura | M-04 | Backend Serverpod; catálogo de zonas global de solo lectura | ADR-0011 |
| Despacho y asignación | M-05..M-08 | Backend Serverpod (`UPDATE` condicional atómico) | ADR-0016 |
| Cotización y ajuste | M-05..M-08 | Backend Serverpod | — |
| Ejecución y trazabilidad (log) | M-05..M-08 | Backend Serverpod, tabla `EventoServicio` append-only | RNF-04 |
| Calificación bidireccional | M-05..M-08 | Backend Serverpod | RF-19 |
| Mensajería y notificaciones | M-09 | Supabase Realtime (Broadcast) + FCM/APNs | ADR-0017 |
| Tarifario y reportes de desviación | M-11 | Backend Serverpod + Supabase Postgres | RF-22, RF-23 |
| Reglas de negocio empresariales | — | Repo B — microservicio Java | ADR-0004, PROY-07 |
| Transaccional de alta concurrencia | — | Repo C — microservicio .NET | ADR-0004, PROY-07 |

> ✅ **Nota heredada del SAD (KI-02, cerrado):** ADR-0004/0005/0006 (Java/.NET/Azure) y
> ADR-0012 (Dart/Serverpod/Supabase) parecían Aceptados a la vez y mutuamente
> excluyentes. ADR-0021 (2026-09-03) aclaró el alcance sin declarar `supersedes`: los tres
> backends coexisten porque gobiernan módulos distintos — Serverpod/Supabase es la
> persistencia e identidad principal (este DD la asume como tal), Java (Repo B) y .NET
> (Repo C) son los módulos adicionales exigidos por PROY-07. Ver ADR-0005 y ADR-0012 para
> las notas de alcance cruzadas.

## 4. Modelo de datos — remisión

El modelo de datos lógico completo (18 entidades, diagrama de clases UML, cardinalidades
justificadas, entidad por entidad) **no se repite en este DD**. Vive en un único
documento: `Product/Modelo_Datos_MANI.md`, que muestra el diagrama de
`Diagramas/Modelo-Datos/dd-modelo-datos_uml-clases-mani_v1.mmd` (+ `.png`) y lo explica.

Regla de aislamiento que ese modelo implementa (RNF-01, ADR-0012, ADR-0018): toda entidad
que representa un dato operativo de un tenant lleva una columna `tenant_id`, protegida por
una política RLS. `Tenant` y `Zona` son la excepción (ver Modelo_Datos_MANI.md §4).

## 5. Reglas de diseño críticas

Cada regla referencia el ADR que la origina; no se reinterpretan aquí, se traducen a
consecuencias directas sobre el modelo de datos (`Product/Modelo_Datos_MANI.md`).

### 5.1 Identificación de tenant no falsificable (ADR-0018)

El `tenant_id` de cada fila **nunca** se recibe como parámetro editable del cliente. Se
extrae server-side de `app_metadata.tenant_id` del JWT verificado. Las políticas RLS
comparan ese valor contra la columna `tenant_id` de la tabla. Ningún endpoint de
escritura acepta `tenant_id` en el body de la petición.

### 5.2 Aislamiento de documentos KYC (ADR-0013)

Un único bucket de Supabase Storage; la ruta de cada objeto es
`tenant_id/aliado_id/documento.ext`. La política RLS de `storage.objects` compara ambos
segmentos de la ruta contra el `tenant_id` del JWT y el `aliado_id` del usuario
autenticado (si su rol es `aliado`) o contra cualquier aliado de su propio tenant (si su
rol es `admin_tenant`). Corolario de diseño: **ningún componente construye esa ruta a
mano fuera de una única función de utilidad del backend** — evita el riesgo residual que
el propio ADR-0013 reconoce (KI-05 del SAD).

### 5.3 Modelo de cobertura (ADR-0011)

- `Zona` es un catálogo global, jerárquico (`zona_padre_id`), con ciclo de vida por
  `estado` (activa/desactivada) — nunca se elimina una fila.
- `CoberturaAliado` y `Sitio.zona_id` son la única fuente de verdad de ubicación; no
  existen columnas de latitud/longitud en el MVP.
- `Solicitud.zona_id` es un **snapshot** de la zona del sitio al momento de creación, no
  una referencia recalculada — así una desactivación posterior de la zona no corrompe el
  histórico de servicios ya registrados.
- El match de RF-12 es `Sitio.zona_id = CoberturaAliado.zona_id` (igualdad de UUID),
  filtrado además por `AliadoCategoria` y por `estado_verificacion = 'aprobado'` del
  aliado.

### 5.4 Despacho atómico y exactamente una asignación (ADR-0016, RNF-05)

No existe una tabla de "ofertas" por aliado: el broadcast se resuelve directamente sobre
`Solicitud` con una actualización condicional:

```sql
UPDATE solicitud
SET estado = 'assigned', aliado_id = :aliado_actual, updated_at = now()
WHERE id = :solicitud_id
  AND estado = 'pending'
  AND aliado_id IS NULL;
```

Si la sentencia afecta 1 fila, ese aliado ganó. Si afecta 0, ya fue tomada — el backend
responde "ya no disponible" sin tocar la fila. Esto también resuelve RNF-03
(idempotencia): un reintento del mismo aliado afecta 0 filas la segunda vez.

> 🟡 ADR-0016 está en estado **Propuesto**, con Disenso y Quórum sin completar (KI-10 del
> SAD). Este DD adopta su decisión propuesta porque es la única alternativa evaluada
> compatible con RNF-05; si la Mesa la revierte, este §5.4 debe revisarse junto con el
> diagrama.

### 5.5 Mensajería y notificaciones (ADR-0017)

`Mensaje` se persiste en Postgres y se distribuye a los clientes conectados vía Supabase
Realtime (modo Broadcast) sobre el mismo canal autorizado por RLS. `Notificacion` registra
el envío de un push (FCM/APNs) cuando el destinatario no tiene conexión activa — es un
registro de auditoría de entrega, no el mecanismo de entrega en sí.

> 🟡 ADR-0017 también está **Propuesto y condicionado** a ADR-0012 (ya aceptado). Igual
> que en §5.4, este DD asume su decisión propuesta como vigente.

### 5.6 Idempotencia en operaciones críticas (RNF-03)

Además del `UPDATE` condicional de §5.4, `Calificacion` impone una restricción de
unicidad `(solicitud_id, autor_id)` a nivel de base de datos — un doble toque del botón
de calificar no puede producir dos filas, sin necesidad de lógica adicional en el backend.

## 6. Trazabilidad RF → entidad → ADR

| RF | Entidad(es) principal(es) | ADR relacionado |
|---|---|---|
| RF-01 | `Tenant` | — |
| RF-02 | `Tenant` (config), `CategoriaServicio`, `TarifaReferencia` | — |
| RF-03 | `Usuario` | ADR-0018, ADR-0022 |
| RF-04 | `Usuario` (delegado a Supabase Auth) | ADR-0022 |
| RF-05 | `Aliado`, `DocumentoKYC` | ADR-0013 |
| RF-06 | `Aliado.estado_verificacion`, `DocumentoKYC` | ADR-0013 |
| RF-07 | `CoberturaAliado`, `Zona` | ADR-0011 |
| RF-08 | `Cliente` | — |
| RF-09 | `Sitio` | ADR-0011 |
| RF-10 | `CategoriaServicio` | — |
| RF-11 | `AliadoCategoria` | — |
| RF-12 | `Solicitud`, `CoberturaAliado`, `AliadoCategoria` | ADR-0011 |
| RF-13 | `Solicitud` (orden calculado, no persistido) | — |
| RF-14 | `Solicitud.estado`, `Solicitud.aliado_id` | ADR-0016 |
| RF-15 | `Cotizacion` | — |
| RF-16 | `Cotizacion`, `TarifaReferencia` | — |
| RF-17 | `Cotizacion.estado`, `Cotizacion.version` | — |
| RF-18 | `EventoServicio` | — |
| RF-19 | `Calificacion` | — |
| RF-20 | `Mensaje`, `Notificacion` | ADR-0017 |
| RF-21 | `Mensaje` (consulta) | ADR-0017 |
| RF-22 | `TarifaReferencia` | — |
| RF-23 | `Cotizacion` + `TarifaReferencia` (reporte de desviación) | — |

## 7. Fuera de alcance de este DD

- **2º incremento (RF-24..RF-28):** `Pago`, `Liquidacion`, `Queja` y las entidades de
  comercialización/métricas no se modelan en este corte — dependen del operador de pagos
  aún no seleccionado (SRS §3.2) y del cierre de REST-03/RNF-06/RNF-11.
- **Modelo físico (DDL, índices, particionamiento):** este DD y `Modelo_Datos_MANI.md`
  fijan el modelo lógico; el DDL ejecutable y las decisiones de indexación para RNF-07
  (concurrencia) son responsabilidad de la fase de implementación y no se congelan aquí.
- **Modelo de dominio conceptual de negocio** (`Product/SAD-MANI.md` §7.6): ese diagrama
  es de nivel de negocio, sin tipos de dato ni claves; no se sustituye por este DD, que es
  el nivel técnico equivalente y coexiste con él.

## 8. Convenciones del modelo

- Claves primarias: `id` (UUID) en todas las entidades.
- Claves foráneas: `<entidad>_id`.
- Toda entidad tenant-scoped incluye `tenant_id` como primera columna después de `id`.
- Fechas: `created_at` / `updated_at` en UTC; los campos de negocio con fecha propia
  (`fecha_alta`, `fecha_carga`, `fecha_declaracion`) se nombran explícitamente.
- Enumerados de estado se representan como `string` en el diagrama lógico; el tipo físico
  (enum de Postgres vs. `check constraint`) se decide en DDL, no en este documento.

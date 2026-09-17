# MANI — Modelo de Datos y Diccionario de Datos

**Empresa:** TRAMA · Ingeniería de Software
**Producto:** MANI — plataforma multi-tenant de formalización de operaciones de servicio
**Documento:** Modelo de Datos V4 — modelo relacional normalizado, diccionario de datos,
patrones de diseño de flujo de datos y capa analítica (Data Warehouse). Sin diagrama:
este documento se lee y se aplica solo con las tablas de abajo.
**Estado:** Borrador para revisión
**Fecha de esta versión:** 2026-09-16

## Historial de versiones

| Versión | Momento | Cambios principales |
|---|---|---|
| **V1** | Sprint 2, 2026-09-03 | Publicado junto con `DD-MANI.md`: este documento explicaba el diagrama, el DD fijaba componentes y reglas. |
| **V2** | Sprint 2, 2026-09-03 | Se separan de nuevo a pedido del equipo — había confusión con `Product/ModeloDatos.md` (propuesta de otro integrante, alcance de backlog completo, notación ER, nunca ratificada por la Mesa). |
| **V3** | Sprint 3, 2026-09-16 | Cierra SCRUM-936: agrega el DDL físico (`Product/DDL_MANI.sql`), generado a partir de este documento (nunca al revés). |
| **V4** | Sprint 3, 2026-09-16 | Consolidación: se elimina `Product/ModeloDatos.md` (versión incoherente con este documento y con el SAD — alcance distinto, notación distinta, nunca ratificada) y el diagrama UML (`Diagramas/Modelo-Datos/*.mmd`/`.png`). Este documento pasa a ser la única fuente del modelo de datos, explicado por completo en tablas (sin diagrama), con normalización justificada, patrones de diseño de datos, y una capa de Data Warehouse para análisis. Único documento de modelo de datos + diccionario de datos + este párrafo de coherencia con el SAD. |

> Este documento reemplaza tanto al antiguo diagrama UML como a `Product/ModeloDatos.md`.
> No coexiste ninguna otra versión del modelo de datos en el repositorio — si aparece una,
> es un duplicado obsoleto y debe eliminarse, no fusionarse.

## Índice

1. [Principios de diseño y alcance](#1-principios-de-diseño-y-alcance)
2. [Contexto de microservicios y propiedad de los datos](#2-contexto-de-microservicios-y-propiedad-de-los-datos)
3. [Modelo relacional normalizado — diccionario de datos por módulo](#3-modelo-relacional-normalizado--diccionario-de-datos-por-módulo)
4. [Normalización: forma normal y excepciones documentadas](#4-normalización-forma-normal-y-excepciones-documentadas)
5. [Cardinalidades y relaciones](#5-cardinalidades-y-relaciones)
6. [Patrones de diseño de flujo de datos aplicados](#6-patrones-de-diseño-de-flujo-de-datos-aplicados)
7. [Data Warehouse — capa analítica](#7-data-warehouse--capa-analítica)
8. [Qué queda fuera de este modelo](#8-qué-queda-fuera-de-este-modelo)
9. [DDL — fuente física para DEV y QA](#9-ddl--fuente-física-para-dev-y-qa)
10. [Trazabilidad](#10-trazabilidad)

---

## 1. Principios de diseño y alcance

Alcance: **MVP únicamente** (RF-01 a RF-23, SRS_MANI.md). No modela el 2º incremento
(Pago, Liquidacion, Queja, Campaña — RF-24..RF-28, ver §8). Fuente:
`Product/SRS_MANI.md`, ADR-0011, ADR-0012, ADR-0013, ADR-0016, ADR-0017, ADR-0018. No
introduce entidades, actores ni reglas que no existan ya en esos documentos.

Principios que gobiernan cada decisión de este modelo:

1. **Normalización por defecto (3FN), desnormalización solo documentada.** Toda entidad
   se diseña en Tercera Forma Normal salvo que exista una razón de rendimiento explícita
   y escrita (§4) — nunca una desnormalización implícita o "porque sí".
2. **Aislamiento multi-tenant como propiedad del esquema, no de la aplicación.** El
   patrón es *shared database, shared schema, discriminador `tenant_id`* reforzado con
   Row-Level Security nativa (ADR-0012, ADR-0018) — no bases ni esquemas separados por
   tenant en el MVP (ver §2 sobre por qué, y KI-06 del SAD sobre el límite de ese enfoque).
3. **El diseño lógico manda; el físico se deriva.** Este documento es la fuente. El DDL
   ejecutable (`Product/DDL_MANI.sql`, §9) se genera a partir de este documento — un
   cambio de modelo se decide y se escribe aquí primero, nunca al revés.
4. **Separar lo transaccional de lo analítico.** El esquema de §3 está optimizado para
   escritura consistente y aislamiento por tenant (OLTP); las preguntas analíticas
   (tendencias, reportes multi-tenant agregados, series de tiempo) no se resuelven contra
   ese esquema — se resuelven en el Data Warehouse de §7.

## 2. Contexto de microservicios y propiedad de los datos

MANI no es un monolito de datos: el backend se reparte en tres servicios con
responsabilidades distintas (`Product/DD-MANI.md` §3, ADR-0004, ADR-0012, ADR-0021):

| Servicio | Responsabilidad | ¿Dueño de datos propios en el MVP? |
|---|---|---|
| **Backend Serverpod (Dart) + Supabase Postgres** | Persistencia, identidad, todo el ciclo del servicio | **Sí — es el único dueño de datos del MVP.** Todas las entidades de §3 viven aquí. |
| **Módulo Java (Repo B)** | Reglas de negocio empresariales | No. Consume datos del backend Serverpod vía API con *token relay* (ADR-0018) — no mantiene su propia base de datos en el MVP. |
| **Módulo .NET (Repo C)** | Transaccional de alta concurrencia | No. Misma relación que Java: consumidor, no dueño, en el MVP. |

**Por qué un solo dueño de datos y no *database-per-service* todavía:** la práctica
recomendada en microservicios es que cada servicio sea dueño exclusivo de su propia base
de datos, para no acoplar servicios a través del esquema. MANI no aplica esa práctica
todavía porque Java y .NET, en el MVP, no tienen su propio ciclo de vida de datos
transaccionales — son procesadores de reglas/lógica sobre datos cuyo ciclo de vida
completo (creación, consulta, cierre) pertenece al ciclo del servicio, dueño de
Serverpod/Postgres (ADR-0012). Introducir bases separadas para Java/.NET sin que tengan
entidades propias sería *sobre-ingeniería* sin driver que la exija (ver también la
premisa de simplicidad de ADR-0021, que resuelve KI-02 sin fragmentar innecesariamente el
modelo de datos).

**Punto de evolución explícito (no una decisión tomada):** si en el 2º incremento Java o
.NET necesitan datos con ciclo de vida propio (p. ej. reglas de comisión versionadas
gestionadas íntegramente por Java, o el motor transaccional de pagos en .NET), la
recomendación de este documento es aplicar *database-per-service* en ese momento —
esquema propio por servicio, comunicación entre servicios por API/eventos, nunca por
`JOIN` cruzado de base de datos — y traer los datos resultantes al Data Warehouse (§7) de
la misma forma que los de Postgres, no como una excepción. Esto queda como recomendación
de diseño, no como ADR — debe pasar por la Mesa de Arquitectura si se activa.

## 3. Modelo relacional normalizado — diccionario de datos por módulo

Convenciones (idénticas a `Product/DD-MANI.md` §13 y a `Product/DDL_MANI.sql`):
PK `id` (UUID) en toda entidad; FK `<entidad>_id`; toda entidad tenant-scoped lleva
`tenant_id` como segunda columna, protegida por RLS (ver §6.2) — excepto `Tenant` y
`Zona`, marcadas **‹global›** porque son catálogos de plataforma, no datos de un tenant.

### 3.1 Plataforma y acceso (M-01)

**TENANT** ‹global› — la empresa suscrita a MANI. Raíz del modelo.

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `nombre` | string | No | |
| `slug` | string | No | Único. Identificador legible usado en pre-autenticación (`X-Tenant-Slug`, ADR-0018) |
| `estado` | string | No | Activo/inactivo — lo mueve el admin. de plataforma |
| `fecha_alta` | datetime | No | |

**USUARIO** — identidad y rol, 1:1 con `auth.users` de Supabase (ADR-0022).

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | **Sí** | Único caso de `tenant_id` opcional: nulo solo para `admin_plataforma`, que opera fuera de cualquier tenant |
| `email` | string | No | |
| `rol` | string | No | `admin_plataforma` \| `admin_tenant` \| `aliado` \| `cliente` — viaja en `app_metadata.rol` del JWT junto al `tenant_id` |
| `estado` | string | No | |
| `created_at` | datetime | No | |

Por qué `Usuario` es una entidad separada de `Aliado`/`Cliente`: un mismo login puede
necesitar distintos perfiles operativos. `Usuario` concentra identidad y rol; `Aliado` y
`Cliente` concentran los datos propios de cada perfil de negocio — relación `0..1` en
ambos sentidos porque un usuario tiene como máximo un perfil de cada tipo (nunca ambos a
la vez en el MVP).

### 3.2 Directorio de aliados y clientes (M-02/M-03)

**ALIADO**

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | |
| `usuario_id` | UUID (FK → Usuario) | No | |
| `tipo` | string | No | `persona_natural` \| `empresa` \| `empleado_directo` (RF-05) |
| `nombre_razon_social` | string | No | |
| `estado_verificacion` | string | No | `pendiente` \| `aprobado` \| `rechazado` — lo mueve la bandeja de verificación (RF-06) |
| `created_at` | datetime | No | |

**DOCUMENTO_KYC**

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | |
| `aliado_id` | UUID (FK → Aliado) | No | |
| `tipo_documento` | string | No | Configurable por tenant (RNF-10) — no es enum fijo |
| `ruta_storage` | string | No | Patrón fijo `tenant_id/aliado_id/documento.ext` (ADR-0013) |
| `estado` | string | No | |
| `fecha_carga` | datetime | No | |

**CLIENTE**

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | |
| `usuario_id` | UUID (FK → Usuario) | No | |
| `tipo` | string | No | `persona_natural` \| `empresa` (RF-08) |

### 3.3 Catálogo y cobertura (M-04)

**ZONA** ‹global› — catálogo jerárquico ciudad → localidad/comuna → barrio (ADR-0011 §1);
solo lectura para los tenants, global de la plataforma.

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `nivel` | string | No | ciudad \| localidad/comuna \| barrio |
| `nombre` | string | No | |
| `zona_padre_id` | UUID (FK → Zona) | Sí | Autorreferencia — jerarquía de 3 niveles |
| `estado` | string | No | `activa` \| `desactivada` — nunca se elimina una fila (ADR-0011 §5) |

**SITIO**

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | |
| `cliente_id` | UUID (FK → Cliente) | No | |
| `zona_id` | UUID (FK → Zona) | No | Obligatoria: "sin zona no origina solicitud" (ADR-0011 §2.3) |
| `direccion` | string | No | |
| `reglas` | JSON | Sí | Condiciones libres del sitio (p. ej. horario de acceso, RF-09) |
| `created_at` | datetime | No | |

**COBERTURA_ALIADO** «asociación N:M aliado↔zona»

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | Denormalizado a propósito — ver §4 |
| `aliado_id` | UUID (FK → Aliado) | No | |
| `zona_id` | UUID (FK → Zona) | No | |
| `fecha_declaracion` | datetime | No | |

**CATEGORIA_SERVICIO**

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | |
| `nombre` | string | No | |
| `estado` | string | No | Activable/desactivable por tenant (RF-10) |
| `flujo_operativo` | string | Sí | |

**ALIADO_CATEGORIA** «asociación N:M aliado↔categoría»

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | Mismo criterio de denormalización que Cobertura_Aliado |
| `aliado_id` | UUID (FK → Aliado) | No | |
| `categoria_id` | UUID (FK → CategoriaServicio) | No | |

**TARIFA_REFERENCIA**

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | |
| `categoria_id` | UUID (FK → CategoriaServicio) | No | |
| `valor_min` | decimal | No | |
| `valor_tipico` | decimal | No | |
| `valor_max` | decimal | No | Alimenta la alerta de RF-16 y el reporte de RF-23 |

### 3.4 Ciclo del servicio (M-05..M-08)

**SOLICITUD** — entidad núcleo.

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | |
| `cliente_id` | UUID (FK → Cliente) | No | |
| `sitio_id` | UUID (FK → Sitio) | No | |
| `categoria_id` | UUID (FK → CategoriaServicio) | No | |
| `zona_id` | UUID (FK → Zona) | No | **Snapshot** de `Sitio.zona_id` al crear — ver §4 |
| `aliado_id` | UUID (FK → Aliado) | Sí | Nulo hasta la asignación atómica (ADR-0016) |
| `estado` | string | No | `pending → assigned → in_progress → closed`, con `cancelled` como salida alterna |
| `created_at` | datetime | No | |
| `updated_at` | datetime | No | |

**COTIZACION**

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | |
| `solicitud_id` | UUID (FK → Solicitud) | No | |
| `aliado_id` | UUID (FK → Aliado) | No | |
| `valor_mano_obra` | decimal | No | Siempre separado de materiales (RF-15) |
| `valor_materiales` | decimal | No | |
| `estado` | string | No | `pendiente` \| `aceptada` \| `rechazada` \| `ajuste_solicitado` |
| `version` | int | No | Cada ajuste crea una nueva versión — ver §6.3 (versioning pattern) |
| `created_at` | datetime | No | |

**EVENTO_SERVICIO** «log inmutable»

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | |
| `solicitud_id` | UUID (FK → Solicitud) | No | |
| `actor_id` | UUID (FK → Usuario) | No | Cualquier rol autenticado puede generar un evento |
| `tipo_evento` | string | No | |
| `descripcion` | string | Sí | |
| `timestamp` | datetime | No | Append-only (RNF-04) — ver §6.1 |

**CALIFICACION**

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | |
| `solicitud_id` | UUID (FK → Solicitud) | No | |
| `autor_id` | UUID (FK → Usuario) | No | |
| `destinatario_id` | UUID (FK → Usuario) | No | |
| `puntaje` | int | No | Rango: pendiente de fijar (fase de implementación) |
| `comentario` | string | Sí | |
| `created_at` | datetime | No | Único por `(solicitud_id, autor_id)` — máx. 2 filas por solicitud |

### 3.5 Comunicación (M-09)

**MENSAJE**

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | |
| `solicitud_id` | UUID (FK → Solicitud) | No | Siempre asociado a una solicitud (RF-20) |
| `remitente_id` | UUID (FK → Usuario) | No | |
| `contenido` | string | No | |
| `created_at` | datetime | No | |
| `leido_at` | datetime | Sí | |

**NOTIFICACION**

| Campo | Tipo | Null | Notas |
|---|---|---|---|
| `id` | UUID | No | PK |
| `tenant_id` | UUID (FK → Tenant) | No | |
| `usuario_id` | UUID (FK → Usuario) | No | |
| `tipo` | string | No | |
| `canal` | string | No | `push` \| `realtime` (ADR-0017) |
| `payload` | JSON | Sí | |
| `enviado_at` | datetime | No | Registro de auditoría de entrega, no el mecanismo en sí |
| `leido_at` | datetime | Sí | |

## 4. Normalización: forma normal y excepciones documentadas

Todas las entidades de §3 cumplen 3FN: cada atributo no clave depende de la clave
completa y solo de ella, y no hay dependencias transitivas (p. ej. `Solicitud` no repite
`nombre_razon_social` del cliente, `Sitio` no repite datos de `Zona`). Dos excepciones se
aceptan **de forma explícita**, con su costo y su mitigación declarados — no son errores:

| Excepción | Dónde | Costo | Por qué se acepta |
|---|---|---|---|
| `tenant_id` denormalizado | `CoberturaAliado`, `AliadoCategoria` (ya derivable vía `aliado_id → Aliado.tenant_id`) | Redundancia de una columna, riesgo de inconsistencia si se escribe mal | La política RLS de esas tablas se evalúa sin `JOIN` extra contra `Aliado` en la ruta más caliente del producto (RF-12/RF-13, RNF-07) — el costo de mantenerla consistente (siempre se copia del mismo `Aliado` en el mismo `INSERT`) es menor que el costo de un `JOIN` adicional en cada consulta de despacho |
| `Solicitud.zona_id` como snapshot de `Sitio.zona_id` | `Solicitud` | Dos columnas pueden divergir en el tiempo (zona del sitio hoy vs. zona en que se creó la solicitud) | Es la divergencia deseada: si se desactiva una zona después, el histórico de la solicitud no debe corromperse — es un snapshot intencional, no una copia por descuido |

Ninguna otra tabla repite datos derivables de otra tabla vía FK.

## 5. Cardinalidades y relaciones

| Relación | Cardinalidad | Por qué |
|---|---|---|
| `Usuario` → `Aliado` / `Cliente` | `1` → `0..1` | Un usuario tiene como máximo un perfil de cada tipo; ninguno es obligatorio al registrarse |
| `Solicitud` → `Cotizacion` | `1` → `0..*` | El bucle de ajuste (RF-17) puede generar más de una versión de cotización |
| `Solicitud` → `Calificacion` | `1` → `0..2` | Exactamente cero, una o dos calificaciones — nunca más, solo dos partes posibles |
| `Aliado` ↔ `Zona` vía `CoberturaAliado` | `0..*` ↔ `0..*` | Tabla puente porque la relación tiene datos propios (fecha de declaración) |
| `Zona` → `Zona` (`zona_padre_id`) | `0..1` → `0..*` | Jerarquía de 3 niveles; la raíz (ciudad) no tiene padre |
| `Sitio` → `Zona` | `0..*` → `1` | Todo sitio tiene exactamente una zona obligatoria (ADR-0011 §2.3) |
| `Tenant` → `Usuario`/`Aliado`/`Cliente`/`CategoriaServicio` | `1` → `0..*` | Todo dato operativo cuelga de un tenant, salvo `Tenant` y `Zona` |

## 6. Patrones de diseño de flujo de datos aplicados

Cada patrón de esta sección está aplicado en al menos una tabla de §3 — no son teoría
suelta, son la explicación de por qué cada tabla se ve como se ve.

### 6.1 Append-only log (event sourcing parcial)

`EventoServicio` nunca se actualiza ni se borra — solo `INSERT`. Es el registro de
auditoría del ciclo del servicio (RNF-04) y, a nivel físico, revoca `UPDATE`/`DELETE` en
el motor (`Product/DDL_MANI.sql`), no solo por convención de código. Es "parcial" porque
el estado actual de `Solicitud`/`Cotizacion` no se reconstruye leyendo el log (a
diferencia de event sourcing puro) — el log es complementario a las tablas de estado, no
su reemplazo.

### 6.2 Multi-tenancy: shared schema + discriminador + RLS

Patrón de aislamiento elegido (ADR-0012, ADR-0018) entre las tres alternativas conocidas
de multi-tenancy (base separada, esquema separado, esquema compartido con discriminador):
toda tabla tenant-scoped lleva `tenant_id` y una política RLS que lo compara contra el
JWT verificado — nunca contra un valor que el cliente pueda enviar. Es el patrón de menor
costo operativo para el volumen de tenants aún desconocido (KI-06 del SAD), a costa de
que el motor evalúe una política en cada consulta (trade-off TO-01 del SAD, mitigado con
índices por `tenant_id`, ya presentes en `Product/DDL_MANI.sql`).

### 6.3 Versionado por insersión, no por sobrescritura

`Cotizacion.version` incrementa con cada ajuste (RF-17) creando una **fila nueva**, nunca
un `UPDATE` sobre la fila anterior. El historial completo de la negociación queda
disponible para auditoría sin lógica adicional — es el mismo principio que el append-only
log de §6.1, aplicado a una entidad que sí tiene un "estado actual" (la última versión).

### 6.4 Snapshot en el momento de la transacción

`Solicitud.zona_id` copia el valor de `Sitio.zona_id` al crearse, en vez de resolverlo
por `JOIN` cada vez que se lee la solicitud. Evita que un cambio posterior en el dato
de origen (`Sitio`) altere el significado de un hecho ya ocurrido (§4).

### 6.5 Tablas puente con datos propios, no relaciones N:M "vacías"

`CoberturaAliado` y `AliadoCategoria` existen como tablas propias — no como una simple
tabla de unión de dos columnas — porque la relación en sí tiene un dato (fecha de
declaración) que no pertenece a ninguna de las dos entidades que conecta.

### 6.6 Estado lógico en vez de borrado físico (soft state)

`Zona.estado` (`activa`/`desactivada`) reemplaza al `DELETE`: una zona nunca se elimina,
porque solicitudes históricas ya la referencian (ADR-0011 §5). El mismo principio aplica
a `Aliado.estado_verificacion` y `CategoriaServicio.estado` — desactivar, no borrar,
preserva la integridad referencial del histórico.

### 6.7 Idempotencia como restricción de esquema, no solo de aplicación

La unicidad `(solicitud_id, autor_id)` en `Calificacion` y `(solicitud_id, version)` en
`Cotizacion` son restricciones `UNIQUE` de base de datos (`Product/DDL_MANI.sql`), no
reglas que la aplicación deba recordar validar — un reintento de red o un doble toque de
botón choca contra la restricción del motor antes de poder duplicar una fila
(`Product/DD-MANI.md` §7 desarrolla el comportamiento HTTP correspondiente).

## 7. Data Warehouse — capa analítica

🟡 **Propuesto — no ratificado por la Mesa de Arquitectura.** Se documenta aquí el diseño
recomendado para que, cuando el equipo lo priorice, no arranque desde cero.

### 7.1 Por qué un Data Warehouse separado y no reportes sobre el OLTP

El esquema de §3 está optimizado para transacciones cortas y aisladas por tenant (OLTP):
`RLS` en cada fila, escrituras concurrentes, un `JOIN` mínimo por consulta. Una pregunta
analítica típica ("cotizaciones fuera de rango por categoría en los últimos 6 meses, en
todos los tenants") requiere agregaciones y `JOIN`s de gran volumen que compiten por los
mismos recursos que el tráfico transaccional — exactamente el trade-off TO-01 del SAD,
pero para consultas mucho más pesadas. La práctica recomendada, y la que seguimos aquí,
es separar la carga: el DWH resuelve preguntas analíticas, el OLTP resuelve transacciones.
Además, en un backend de varios servicios (§2), un DWH es el único lugar donde tiene
sentido cruzar datos de más de un servicio sin acoplarlos por `JOIN` de base de datos
directo entre ellos.

### 7.2 Modelo dimensional (esquema estrella)

**Tablas de hechos:**

| Tabla de hechos | Grano | Métricas | Dimensiones relacionadas |
|---|---|---|---|
| `fact_solicitud` | 1 fila por solicitud cerrada o cancelada | tiempo hasta asignación, tiempo hasta cierre, ¿cancelada? | tenant, cliente, aliado, categoría, zona, tiempo |
| `fact_cotizacion` | 1 fila por versión de cotización | valor mano de obra, valor materiales, ¿fuera de rango?, número de versión | tenant, aliado, categoría, tiempo |
| `fact_calificacion` | 1 fila por calificación | puntaje | tenant, solicitud, autor, tiempo |

**Tablas de dimensión:**

| Dimensión | Origen (OLTP) | Notas |
|---|---|---|
| `dim_tenant` | `Tenant` | Incluye atributos lentamente cambiantes (SCD tipo 2) si el nombre/estado del tenant cambia |
| `dim_cliente` | `Cliente` | |
| `dim_aliado` | `Aliado` | |
| `dim_categoria` | `CategoriaServicio` | |
| `dim_zona` | `Zona` | Conserva la jerarquía ciudad/localidad/barrio como columnas planas para *drill-down* sin recursión |
| `dim_tiempo` | Generada | Calendario estándar (día, semana, mes, trimestre) |

`tenant_id` se mantiene como atributo en **cada** tabla de hechos y dimensión relevante
— el aislamiento multi-tenant no se relaja en la capa analítica: un reporte para el
tenant A nunca debe poder filtrarse para mostrar filas del tenant B. La capa de BI que
consuma el DWH debe aplicar el mismo filtro por `tenant_id` que RLS aplica en el OLTP
(vía política de la herramienta de BI o una vista materializada por tenant).

### 7.3 Estrategia de carga (ETL/ELT)

- **Origen:** Postgres/Supabase (OLTP, §3) es la única fuente en el MVP; si Java/.NET
  adoptan *database-per-service* (§2), sus datos entran al DWH por el mismo mecanismo,
  nunca por acceso directo cruzado entre bases operativas.
- **Mecanismo recomendado:** *Change Data Capture* (CDC) sobre la replicación lógica de
  Postgres (Supabase la expone) en vez de consultas `SELECT` periódicas de alto costo
  contra el OLTP — respeta el principio de §7.1 (no competir con el tráfico
  transaccional) y captura eventos casi en tiempo real en vez de solo el estado final.
  Alternativa más simple para un primer corte: carga incremental por lote (ELT nocturno)
  filtrando por `updated_at`/`created_at`, aceptable si la frecuencia de reporte es diaria.
- **Transformación:** las tablas de hechos se derivan calculando las métricas de §7.2
  (p. ej. `tiempo_hasta_asignacion = assigned_at - created_at`) en la carga, no en cada
  consulta de reporte.
- **Frecuencia:** a definir por la Mesa según el uso real de los reportes (RF-23 ya pide
  un reporte bajo demanda sobre el OLTP directamente — QS-15 del SAD — que sigue siendo
  válido para volúmenes bajos; el DWH es para cuando ese patrón deje de escalar).

### 7.4 Fuera de este documento

Elección concreta de motor de DWH (p. ej. un esquema analítico separado en el mismo
Postgres vs. un motor columnar dedicado), herramienta de orquestación ETL/ELT, y
herramienta de BI: son decisiones de infraestructura que deben pasar por un spike y un
ADR propio antes de implementarse (PROY-05), igual que se hizo con ADR-0012.

## 8. Qué queda fuera de este modelo (y por qué)

- **Coordenadas geográficas (lat/long):** deliberadamente ausentes. REST-01 y ADR-0011
  descartan el radio geográfico; el modelo depende de la igualdad de `zona_id`, no de
  cálculo geoespacial.
- **Tabla de "ofertas" de despacho:** no existe una entidad intermedia entre `Solicitud`
  y los aliados notificados por el broadcast. ADR-0016 resuelve la asignación
  directamente sobre `Solicitud.aliado_id` con un `UPDATE` condicional.
- **Entidades de pago/liquidación/quejas (2º incremento):** ver `Product/DD-MANI.md` §12.
- **Bases de datos separadas por microservicio (`database-per-service`):** documentado
  como recomendación futura en §2, no como estado actual.
- **Reglas de diseño y vista de componentes:** viven en `Product/DD-MANI.md`, no aquí.

## 9. DDL — fuente física para DEV y QA

El modelo lógico de §3 se materializa, sin traducción intermedia, en
`Product/DDL_MANI.sql`. Ese archivo **es** el DDL que se aplica en los ambientes `dev` y
`qa`/`staging` (`Product/DD-MANI.md` §9) — no es un boceto; es el mismo script que corre
la migración. Regla de consistencia: cualquier cambio a una entidad de §3 (columna,
cardinalidad, enumerado) se decide y se escribe primero en este documento, y en el mismo
PR se refleja en `DDL_MANI.sql` — nunca al revés.

- **Aislamiento multi-tenant aplicado:** cada tabla de §3 salvo `Tenant` y `Zona` lleva
  `ALTER TABLE ... ENABLE ROW LEVEL SECURITY` + una política `tenant_isolation_<tabla>`
  (§6.2), sin excepciones ni variantes por tabla.
- **Enumerados:** solo se fijan como `CHECK` los valores ya enumerados de forma explícita
  en §3; el resto queda `text` abierto, marcado `-- valor abierto`.
- **Log inmutable:** `evento_servicio` revoca `UPDATE`/`DELETE` a nivel de motor (§6.1).
- **Fuera de este DDL:** `Pago`, `Liquidacion`, `Queja`, el 2º incremento (§8), y el Data
  Warehouse de §7 (queda pendiente de ADR propio antes de tener DDL).

## 10. Trazabilidad

`RF-01..RF-23 (SRS V3) → ADR-0011/0012/0013/0016/0017/0018 → modelo relacional normalizado (§3) → Product/DDL_MANI.sql (DDL ejecutado en dev/qa) → Data Warehouse (§7, propuesto, pendiente de ADR)`

| Artefacto | Relación con este documento |
|---|---|
| `Product/SRS_MANI.md` | Origen de cada RF citado en §3 |
| `Product/SAD-MANI.md` §7.6 | Modelo de dominio *conceptual* de negocio — nivel superior, sin tipos de dato; no se confunde con este documento |
| `Product/DD-MANI.md` | Reglas de diseño que este modelo implementa, vista de componentes |
| `Product/DDL_MANI.sql` | DDL físico — mismo esquema que corre en `dev` y `qa` (§9) |
| ADR-0011, ADR-0012, ADR-0013, ADR-0016, ADR-0017, ADR-0018 | Decisiones técnicas que originan cada regla de §3-§6 |

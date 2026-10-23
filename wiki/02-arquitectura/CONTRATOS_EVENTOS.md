# Contratos y versionado de eventos de negocio — `SolicitudCreada`, `AliadoAsignado`, `CotizacionAceptada` y `ServicioFinalizado`

**Entregable:** ARQ-06 (SCRUM-1237) · **Sprint 4** · **Fecha:** 2026-10-18  
**Responsable:** Juan Sebastián Álvarez Rodríguez  
**Fuentes normativas:** [`ADR-0029`](adr/ADR-0029-comunicacion-asincrona-kafka.md), [`ADR-0030`](adr/ADR-0030-propiedad-esquema-y-frontera-de-datos.md), [`ADR-0016`](adr/ADR-0016-despacho-concurrencia.md), [`SAD.md`](SAD.md) §7.4 y §12.2, [`SDD.md`](SDD.md) §2.1, [`ModeloDatos.md`](ModeloDatos.md) §6.3, §7 y §8, [`TRAZABILIDAD_INTEGRACION.md`](TRAZABILIDAD_INTEGRACION.md).  
**Artefacto de verificación ejecutable:** [`Entregas/PoC/PoC-ARQ06-esquema-versionado-eventos/`](../../qa/PoC/PoC-ARQ06-esquema-versionado-eventos/README.md)

---

## 1. Propósito y alcance

[`ADR-0029`](adr/ADR-0029-comunicacion-asincrona-kafka.md) adoptó Apache Kafka como bus de integración asíncrona entre servicios (con despliegue diferido al Sprint 5), estableció el sobre común obligatorio y fijó la publicación mediante *transactional outbox* desde la primera implementación. Este documento cierra **ARQ-06 (`SCRUM-1237`)** especificando:

1. El catálogo canónico de los **cuatro eventos de negocio del ciclo de vida del servicio**: `SolicitudCreada`, `AliadoAsignado`, `CotizacionAceptada` y `ServicioFinalizado`.
2. El esquema formal (`event_version = 1`) del sobre común y del objeto `data` de cada evento, alineado columna a columna con `servicio.outbox`, `despacho.outbox` y las tablas operacionales de [`ModeloDatos.md`](ModeloDatos.md).
3. Las reglas de particionamiento, aislamiento multi-tenant (`RNF-01`), correlación extremo a extremo (`RNF-07`) y frontera de datos (`ADR-0030` §2).
4. La política de **versionado semántico de eventos**, clasificación de cambios compatibles frente a incompatibles, regla de *Tolerant Reader* y protocolo de transición entre versiones (`vN` → `vN+1`).

---

## 2. Catálogo de eventos, propiedad y topología de publicación

Cada evento tiene **un único servicio productor**, que coincide con el dueño de la capacidad de negocio según [`ADR-0022`](adr/ADR-0022-logica-de-negocio-en-servicios.md) y [`SAD.md`](SAD.md) §7.4. Ningún servicio emite eventos de un dominio ajeno ni escribe en un outbox fuera de su esquema ([`ModeloDatos.md`](ModeloDatos.md) §6.1 y §13).

| Evento (`event_type`) | Versión vigente | Productor único | Tabla Outbox | Tópico Kafka objetivo | Clave de partición (`clave_particion`) | Disparador de negocio | Consumidores previstos |
| :--- | :---: | :--- | :--- | :--- | :--- | :--- | :--- |
| **`SolicitudCreada`** | `1` | Core Service | `servicio.outbox` | `mani.servicio.solicitud-creada.v1` | `id_solicitud` | La solicitud queda persistida en estado `CREADA` y lista para evaluación de elegibilidad y reparto (RF-12). | Dispatch Service (orquestación de reparto), Data Warehouse (`dw.fact_solicitud`). |
| **`AliadoAsignado`** | `1` | Dispatch Service | `despacho.outbox` | `mani.despacho.aliado-asignado.v1` | `id_solicitud` | La actualización condicional atómica de `ADR-0016` confirma que un único aliado aceptó la solicitud (`ACEPTADA`, RF-14, RNF-05). | Core Service (apertura de conversación RF-20 y notificación al cliente/aliado vía `ADR-0017`), Data Warehouse (`dw.fact_asignacion`). |
| **`CotizacionAceptada`** | `1` | Core Service | `servicio.outbox` | `mani.servicio.cotizacion-aceptada.v1` | `id_solicitud` | El cliente acepta una cotización previamente contrastada contra el tarifario del tenant (`ACEPTADA`, RF-15, RF-16, RF-17). | Dispatch Service (sincronización de estado operativo), Data Warehouse (`dw.fact_cotizacion`). |
| **`ServicioFinalizado`** | `1` | Core Service | `servicio.outbox` | `mani.servicio.servicio-finalizado.v1` | `id_solicitud` | La ejecución del servicio concluye y la solicitud transita a `FINALIZADA` (RF-18), habilitando la calificación bidireccional (RF-19). | Core Service (apertura de ventana de calificación `US-04.4.1` y cierre diferido de conversación RF-21), Data Warehouse (`dw.fact_solicitud`). |

### 2.1 Orden causal por solicitud y clave de partición

Los cuatro eventos comparten **`clave_particion = id_solicitud`**, incluso cuando el agregado modificado es una fila hija (`id_asignacion` en `AliadoAsignado` o `id_cotizacion` en `CotizacionAceptada`).

- **Razón arquitectónica:** Kafka garantiza orden de entrega únicamente dentro de una misma partición. Usar `id_solicitud` como clave de partición asegura que toda la secuencia de una misma solicitud (`SolicitudCreada` → `AliadoAsignado` → `CotizacionAceptada` → `ServicioFinalizado`) llegue en orden causal a cualquier consumidor sin imponer un cuello de botella de orden global entre solicitudes distintas.

---

## 3. Sobre común obligatorio (`EventEnvelope v1`)

Todo evento persistido en `servicio.outbox` o `despacho.outbox` y publicado por el proceso relay (`mani_relay`) viaja envuelto en la siguiente estructura canónica:

```json
{
  "event_id": "a7f4c912-3d19-4e82-9a11-7e83d1b04c21",
  "event_type": "SolicitudCreada",
  "event_version": 1,
  "occurred_at": "2026-10-18T15:30:00.000Z",
  "tenant_id": "11111111-1111-4111-8111-111111111111",
  "correlation_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "partition_key": "9b2e4d10-81c4-4f22-b890-33e019c71a01",
  "data": {}
}
```

### 3.1 Mapeo entre el sobre JSON y las tablas Outbox

| Campo en el sobre JSON | Tipo JSON / Formato | Columna en `*.outbox` | Tipo SQL | Regla de integridad y propósito |
| :--- | :--- | :--- | :--- | :--- |
| `event_id` | `string` (`uuid` v4) | `id_evento` | `UUID PK` | Identificador único global del evento. Es la clave obligatoria de deduplicación en los consumidores idempotentes (`ARQ-08`). |
| `event_type` | `string` (`enum`) | `tipo_evento` | `VARCHAR(60) CHECK` | Restringido por `CHECK` según el esquema productor: `('SolicitudCreada','CotizacionAceptada','ServicioFinalizado')` en `servicio.outbox` y `('AliadoAsignado')` en `despacho.outbox`. |
| `event_version` | `integer` (`>= 1`) | `version_evento` | `SMALLINT NOT NULL` | Versión mayor del esquema de `data`. Inicia en `1` y solo se incrementa ante cambios incompatibles (§5). |
| `occurred_at` | `string` (`date-time` UTC) | `fecha_ocurrencia` | `TIMESTAMPTZ NOT NULL` | Instante exacto de la transacción de negocio en base de datos, **no** el instante en que el relay publica en Kafka (`fecha_publicacion`). |
| `tenant_id` | `string` (`uuid`) | `id_tenant` | `UUID NOT NULL FK` | Obligatorio (`RNF-01`). Todo consumidor valida y aplica contexto de tenant a partir de este campo; está prohibido inferir el tenant inspeccionando `data`. |
| `correlation_id` | `string` (`uuid`) | `correlation_id` | `UUID NOT NULL` | Propaga el encabezado `X-Correlation-ID` originado en el API Gateway (`RNF-07`) para trazabilidad distribuida entre peticiones HTTP y eventos asíncronos. |
| `partition_key` | `string` (`uuid`) | `clave_particion` | `UUID NOT NULL` | Siempre igual a `id_solicitud`. El relay lo utiliza como `Message.key` al publicar en el tópico Kafka. |
| `data` | `object` | `payload` | `JSONB NOT NULL` | Carga útil de dominio sujeta al esquema de `(event_type, event_version)`. Además, `id_agregado` se almacena como columna indexable en `*.outbox` y coincide con el identificador primario dentro de `data`. |

---

## 4. Especificación de esquemas por evento (`event_version: 1`)

###Principios de diseño del `payload` (`data`)
1. **Frontera de datos estricta (`ADR-0030` §2):** El evento transporta únicamente identificadores estables (`UUID`), estados canónicos, marcas de tiempo e importes propios del agregado que cambió. Nunca incluye datos privados de otro esquema ni PII sensible (dirección física textual, reglas de acceso al inmueble, teléfono o documento de identidad).
2. **Alineación con el modelo dimensional (`ModeloDatos.md` §9–§11):** Cada evento incluye las claves naturales (`id_solicitud`, `id_categoria`, `id_zona`, `id_aliado`, `id_cliente`) y métricas operativas (`segundos_respuesta`, `valor_mano_obra`, `valor_materiales`, `fuera_de_rango`) necesarias para poblar `dw.fact_solicitud`, `dw.fact_asignacion` y `dw.fact_cotizacion` sin consultas adicionales.

---

### 4.1 `SolicitudCreada` (`event_version: 1`)

- **Productor:** Core Service (`servicio.outbox`)
- **Columna `id_agregado` en outbox:** `data.id_solicitud`
- **Columna `clave_particion` en outbox:** `data.id_solicitud`
- **Requisitos relacionados:** RF-12, RNF-01, RNF-07

#### Contrato de `data`

| Campo | Tipo | Requerido | Restricciones / Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `id_solicitud` | `string` (`uuid`) | Sí | `== partition_key` | Identificador único de la solicitud creada. |
| `id_cliente` | `string` (`uuid`) | Sí | FK lógica a `core.cliente` | Cliente solicitante dentro del mismo `tenant_id`. |
| `id_sitio` | `string` (`uuid`) \| `null` | Sí (nullable) | FK lógica a `core.sitio_servicio` | Identificador del sitio registrado cuando aplica (RF-09); `null` si se usó dirección puntual. |
| `id_categoria` | `string` (`uuid`) | Sí | FK lógica a `core.categoria` | Categoría activa del servicio solicitado (RF-10). |
| `id_zona` | `string` (`uuid`) | Sí | FK lógica a `core.zona` | Zona geográfica normalizada para cruce exacto de cobertura (ADR-0011, RF-07). |
| `flujo_operativo` | `string` (`enum`) | Sí | `'COTIZACION_ABLE'` \| `'TARIFA_ESTANDAR'` | Flujo operativo configurado en la categoría al momento de crear la solicitud. |
| `requiere_cotizacion_previa` | `boolean` | Sí | Coherente con `flujo_operativo` | Indica si el servicio debe pasar por fase de cotización antes de ejecutarse. |
| `fecha_servicio` | `string` (`date-time`) \| `null` | Sí (nullable) | ISO-8601 UTC o `null` | Fecha/hora programada solicitada por el cliente, o `null` para atención inmediata. |
| `estado` | `string` (`enum`) | Sí | Constante `'CREADA'` | Estado inicial canónico de la solicitud (`ModeloDatos.md` §7). |
| `fecha_creacion` | `string` (`date-time`) | Sí | ISO-8601 UTC | Marca de tiempo de creación persistida en la solicitud. |

> **Exclusión deliberada de PII:** `descripcion`, `direccion` y `reglas_acceso` **no** se publican en el bus de eventos ni en el Data Warehouse (`ModeloDatos.md` §12). Dispatch solo requiere `(tenant_id, id_solicitud, id_categoria, id_zona, fecha_servicio)` para orquestar la elegibilidad.

#### Ejemplo canónico (`SolicitudCreada v1`)

```json
{
  "event_id": "a7f4c912-3d19-4e82-9a11-7e83d1b04c21",
  "event_type": "SolicitudCreada",
  "event_version": 1,
  "occurred_at": "2026-10-18T15:30:00.000Z",
  "tenant_id": "11111111-1111-4111-8111-111111111111",
  "correlation_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "partition_key": "9b2e4d10-81c4-4f22-b890-33e019c71a01",
  "data": {
    "id_solicitud": "9b2e4d10-81c4-4f22-b890-33e019c71a01",
    "id_cliente": "22222222-2222-4222-8222-222222222222",
    "id_sitio": "33333333-3333-4333-8333-333333333333",
    "id_categoria": "44444444-4444-4444-8444-444444444444",
    "id_zona": "55555555-5555-4555-8555-555555555555",
    "flujo_operativo": "COTIZACION_ABLE",
    "requiere_cotizacion_previa": true,
    "fecha_servicio": "2026-10-19T14:00:00.000Z",
    "estado": "CREADA",
    "fecha_creacion": "2026-10-18T15:30:00.000Z"
  }
}
```

---

### 4.2 `AliadoAsignado` (`event_version: 1`)

- **Productor:** Dispatch Service (`despacho.outbox`)
- **Columna `id_agregado` en outbox:** `data.id_asignacion`
- **Columna `clave_particion` en outbox:** `data.id_solicitud`
- **Requisitos relacionados:** RF-14, RNF-05, ADR-0016, ADR-0021

#### Contrato de `data`

| Campo | Tipo | Requerido | Restricciones / Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `id_asignacion` | `string` (`uuid`) | Sí | PK de `despacho.asignacion` | Identificador único del registro de asignación ganador. |
| `id_solicitud` | `string` (`uuid`) | Sí | `== partition_key` | Solicitud asignada. |
| `id_aliado` | `string` (`uuid`) | Sí | FK lógica a `core.aliado` | Aliado que ganó la aceptación concurrente atómica (`ADR-0016`). |
| `id_categoria` | `string` (`uuid`) | Sí | FK lógica a `core.categoria` | Categoría de la solicitud asignada (requerida por `dw.fact_asignacion`). |
| `id_zona` | `string` (`uuid`) | Sí | FK lógica a `core.zona` | Zona de la solicitud asignada (requerida por `dw.fact_asignacion`). |
| `estado_asignacion` | `string` (`enum`) | Sí | Constante `'ACEPTADA'` | Estado confirmado en `despacho.asignacion`. |
| `estado_solicitud` | `string` (`enum`) | Sí | `'ASIGNADA'` \| `'ACEPTADA'` | Nuevo estado operacional de la solicitud tras la asignación. |
| `fecha_asignacion` | `string` (`date-time`) | Sí | ISO-8601 UTC | Momento en que se ofreció/registró la asignación inicial. |
| `fecha_respuesta` | `string` (`date-time`) | Sí | ISO-8601 UTC (`>= fecha_asignacion`) | Momento exacto de confirmación del aliado ganador. |
| `segundos_respuesta` | `integer` | Sí | `>= 0` | Tiempo de respuesta en segundos (`dw.fact_asignacion.segundos_respuesta`). |

#### Ejemplo canónico (`AliadoAsignado v1`)

```json
{
  "event_id": "b8e5d023-4e20-4f93-8b22-8f94e2c15d32",
  "event_type": "AliadoAsignado",
  "event_version": 1,
  "occurred_at": "2026-10-18T15:31:15.000Z",
  "tenant_id": "11111111-1111-4111-8111-111111111111",
  "correlation_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "partition_key": "9b2e4d10-81c4-4f22-b890-33e019c71a01",
  "data": {
    "id_asignacion": "66666666-6666-4666-8666-666666666666",
    "id_solicitud": "9b2e4d10-81c4-4f22-b890-33e019c71a01",
    "id_aliado": "77777777-7777-4777-8777-777777777777",
    "id_categoria": "44444444-4444-4444-8444-444444444444",
    "id_zona": "55555555-5555-4555-8555-555555555555",
    "estado_asignacion": "ACEPTADA",
    "estado_solicitud": "ASIGNADA",
    "fecha_asignacion": "2026-10-18T15:30:05.000Z",
    "fecha_respuesta": "2026-10-18T15:31:15.000Z",
    "segundos_respuesta": 70
  }
}
```

---

### 4.3 `CotizacionAceptada` (`event_version: 1`)

- **Productor:** Core Service (`servicio.outbox`)
- **Columna `id_agregado` en outbox:** `data.id_cotizacion`
- **Columna `clave_particion` en outbox:** `data.id_solicitud`
- **Requisitos relacionados:** RF-15, RF-16, RF-17, RF-22, RF-23

#### Contrato de `data`

| Campo | Tipo | Requerido | Restricciones / Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `id_cotizacion` | `string` (`uuid`) | Sí | PK de `servicio.cotizacion` | Identificador único de la cotización aceptada. |
| `id_solicitud` | `string` (`uuid`) | Sí | `== partition_key` | Solicitud a la que pertenece la cotización. |
| `id_aliado` | `string` (`uuid`) | Sí | FK lógica a `core.aliado` | Aliado emisor de la cotización. |
| `id_categoria` | `string` (`uuid`) | Sí | FK lógica a `core.categoria` | Categoría tarifada (requerida por `dw.fact_cotizacion`). |
| `id_tarifa` | `string` (`uuid`) \| `null` | Sí (nullable) | FK lógica a `reglas.tarifario` | Tarifa de referencia utilizada por Rules al evaluar el rango (RF-16). |
| `valor_mano_obra` | `number` | Sí | `>= 0` (2 decimales) | Importe correspondiente a mano de obra (`servicio.cotizacion.valor_mano_obra`, RF-15). |
| `valor_materiales` | `number` | Sí | `>= 0` (2 decimales) | Importe correspondiente a materiales (`servicio.cotizacion.valor_materiales`, RF-15). |
| `valor_total` | `number` | Sí | `== valor_mano_obra + valor_materiales` | Importe total aceptado (`ck_cotizacion_total`). |
| `moneda` | `string` | Sí | ISO-4217 `CHAR(3)` (ej. `'COP'`) | Moneda de la cotización. |
| `fuera_de_rango` | `boolean` | Sí | Veredicto de Rules Service | `true` si la cotización aceptada superó o quedó por debajo del rango de referencia (RF-16, RF-23). |
| `estado` | `string` (`enum`) | Sí | Constante `'ACEPTADA'` | Estado confirmado en `servicio.cotizacion` (RF-17). |
| `fecha_aceptacion` | `string` (`date-time`) | Sí | ISO-8601 UTC | Momento en que el cliente aceptó la cotización. |

#### Ejemplo canónico (`CotizacionAceptada v1`)

```json
{
  "event_id": "c9f6e134-5f31-4a04-9c33-9a05f3d26e43",
  "event_type": "CotizacionAceptada",
  "event_version": 1,
  "occurred_at": "2026-10-18T15:45:00.000Z",
  "tenant_id": "11111111-1111-4111-8111-111111111111",
  "correlation_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "partition_key": "9b2e4d10-81c4-4f22-b890-33e019c71a01",
  "data": {
    "id_cotizacion": "88888888-8888-4888-8888-888888888888",
    "id_solicitud": "9b2e4d10-81c4-4f22-b890-33e019c71a01",
    "id_aliado": "77777777-7777-4777-8777-777777777777",
    "id_categoria": "44444444-4444-4444-8444-444444444444",
    "id_tarifa": "99999999-9999-4999-8999-999999999999",
    "valor_mano_obra": 85000.00,
    "valor_materiales": 35000.00,
    "valor_total": 120000.00,
    "moneda": "COP",
    "fuera_de_rango": false,
    "estado": "ACEPTADA",
    "fecha_aceptacion": "2026-10-18T15:45:00.000Z"
  }
}
```

---

### 4.4 `ServicioFinalizado` (`event_version: 1`)

- **Productor:** Core Service (`servicio.outbox`)
- **Columna `id_agregado` en outbox:** `data.id_solicitud`
- **Columna `clave_particion` en outbox:** `data.id_solicitud`
- **Requisitos relacionados:** RF-18, RF-19 (`US-04.4.1` / `SCRUM-874`), RF-21

#### Contrato de `data`

| Campo | Tipo | Requerido | Restricciones / Dominio | Descripción |
| :--- | :--- | :---: | :--- | :--- |
| `id_solicitud` | `string` (`uuid`) | Sí | `== partition_key` | Solicitud cuya ejecución concluyó. |
| `id_cliente` | `string` (`uuid`) | Sí | FK lógica a `core.cliente` | Cliente receptor del servicio (habilitado para emitir calificación `rol_autor = 'CLIENTE'`). |
| `id_aliado` | `string` (`uuid`) | Sí | FK lógica a `core.aliado` | Aliado ejecutor del servicio (habilitado para emitir calificación `rol_autor = 'ALIADO'`). |
| `id_categoria` | `string` (`uuid`) | Sí | FK lógica a `core.categoria` | Categoría del servicio finalizado (`dw.fact_solicitud`). |
| `id_zona` | `string` (`uuid`) | Sí | FK lógica a `core.zona` | Zona donde se prestó el servicio (`dw.fact_solicitud`). |
| `id_cotizacion` | `string` (`uuid`) \| `null` | Sí (nullable) | FK lógica a `servicio.cotizacion` | Cotización aceptada asociada, o `null` cuando operó bajo `TARIFA_ESTANDAR` sin cotización previa. |
| `valor_acordado` | `number` \| `null` | Sí (nullable) | `>= 0` o `null` | Valor total acordado del servicio para cierre operativo y liquidación. |
| `moneda` | `string` \| `null` | Sí (nullable) | ISO-4217 `CHAR(3)` o `null` | Moneda del `valor_acordado` (obligatoria si `valor_acordado` no es `null`). |
| `estado_anterior` | `string` (`enum`) | Sí | Constante `'EN_EJECUCION'` | Estado inmediato anterior registrado en `servicio.historial_solicitud` (RF-18). |
| `estado_nuevo` | `string` (`enum`) | Sí | Constante `'FINALIZADA'` | Estado final de ejecución alcanzado. |
| `habilita_calificacion` | `boolean` | Sí | Constante `true` | Señal explícita de apertura de la calificación bidireccional (RF-19). |
| `fecha_finalizacion` | `string` (`date-time`) | Sí | ISO-8601 UTC | Momento exacto de cierre de la ejecución. |

#### Ejemplo canónico (`ServicioFinalizado v1`)

```json
{
  "event_id": "d0a7f245-6a42-4b15-8d44-0b16a4e37f54",
  "event_type": "ServicioFinalizado",
  "event_version": 1,
  "occurred_at": "2026-10-18T17:10:00.000Z",
  "tenant_id": "11111111-1111-4111-8111-111111111111",
  "correlation_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "partition_key": "9b2e4d10-81c4-4f22-b890-33e019c71a01",
  "data": {
    "id_solicitud": "9b2e4d10-81c4-4f22-b890-33e019c71a01",
    "id_cliente": "22222222-2222-4222-8222-222222222222",
    "id_aliado": "77777777-7777-4777-8777-777777777777",
    "id_categoria": "44444444-4444-4444-8444-444444444444",
    "id_zona": "55555555-5555-4555-8555-555555555555",
    "id_cotizacion": "88888888-8888-4888-8888-888888888888",
    "valor_acordado": 120000.00,
    "moneda": "COP",
    "estado_anterior": "EN_EJECUCION",
    "estado_nuevo": "FINALIZADA",
    "habilita_calificacion": true,
    "fecha_finalizacion": "2026-10-18T17:10:00.000Z"
  }
}
```

---

## 5. Política de versionado y evolución de esquemas

El campo `event_version` del sobre común representa la **versión mayor** del contrato del evento (`SMALLINT` >= 1). No se usan versiones menores (`1.1`) en el sobre porque un cambio compatible no altera la interpretación de los consumidores existentes.

### 5.1 Clasificación de cambios

| Tipo de modificación en `data` o en el sobre | Clasificación | Efecto en `event_version` | Efecto en el nombre del tópico Kafka |
| :--- | :--- | :---: | :--- |
| Agregar un campo opcional (`nullable` o con valor por omisión documentado) en `data` | **Compatible** (*Backward / Forward Compatible*) | Se mantiene en `N` | Se mantiene `mani.<dominio>.<evento>.vN` |
| Agregar un nuevo evento al catálogo (`event_type` nuevo) | **Compatible** | Inicia en `1` | Nuevo tópico `mani.<dominio>.<nuevo-evento>.v1` |
| Eliminar un campo existente (requerido u opcional) de `data` | **Incompatible** (*Breaking*) | Sube a `N + 1` | Nuevo tópico `mani.<dominio>.<evento>.v(N+1)` |
| Renombrar una propiedad existente de `data` | **Incompatible** (*Breaking*) | Sube a `N + 1` | Nuevo tópico `mani.<dominio>.<evento>.v(N+1)` |
| Cambiar el tipo primitivo, formato o unidad de medida de un campo (ej. `segundos_respuesta` a milisegundos) | **Incompatible** (*Breaking*) | Sube a `N + 1` | Nuevo tópico `mani.<dominio>.<evento>.v(N+1)` |
| Convertir un campo opcional en obligatorio sin valor por omisión | **Incompatible** (*Breaking*) | Sube a `N + 1` | Nuevo tópico `mani.<dominio>.<evento>.v(N+1)` |
| Cambiar el significado semántico o las invariantes de un campo (ej. romper `valor_total = mano_obra + materiales`) | **Incompatible** (*Breaking*) | Sube a `N + 1` | Nuevo tópico `mani.<dominio>.<evento>.v(N+1)` |

### 5.2 Regla de emisión estricta y lectura tolerante (*Strict Producer / Tolerant Reader*)

1. **Productor estricto (*Strict Producer*):** Antes de insertar en `servicio.outbox` o `despacho.outbox` dentro de la transacción de negocio, el servicio productor valida que el sobre y `data` cumplan todos los campos requeridos, formatos e invariantes de la versión vigente, sin emitir campos no declarados en el contrato (`additionalProperties: false` en el esquema del productor).
2. **Consumidor tolerante (*Tolerant Reader*):** Todo servicio consumidor ignora propiedades adicionales desconocidas dentro de `data` cuando `event_version` coincide con una versión soportada. Esto permite agregar campos opcionales en el productor sin desplegar simultáneamente a los consumidores.
3. **Falla controlada ante versión desconocida:** Si un consumidor recibe un evento con un `event_version` mayor al que soporta, **no** intenta adivinar la estructura ni descarta silenciosamente el mensaje: registra el rechazo con `correlation_id`, `tenant_id`, `event_id` y `event_version`, y encamina el mensaje a la cola de mensajes fallidos (*Dead Letter Queue*, `mani.dlq.<servicio-consumidor>`) para reproceso una vez actualizado el consumidor (`ARQ-08`).

### 5.3 Protocolo de migración ante un cambio incompatible (`vN` → `vN+1`)

Dado que el ecosistema MANI es multi-repositorio (`MANI-Node`, `MANI-Java`, `MANI-.NET`) y los despliegues por servicio son independientes (`ADR-0004`), un cambio incompatible nunca se aplica mediante corte abrupto (*big-bang*):

1. **Paso 1 — Registro contractual en `MANI-docs`:** Se añade la especificación `v(N+1)` en este documento y su archivo JSON Schema en `Entregas/PoC/PoC-ARQ06-esquema-versionado-eventos/schemas/`, manteniendo `vN` marcada como *Deprecated (ventana de retiro: 1 sprint)*.
2. **Paso 2 — Actualización previa de consumidores (*Consumer-First Deployment*):** Los servicios consumidores se actualizan primero para aceptar tanto `event_version = N` como `event_version = N + 1` (mediante un adaptador/*upcaster* de `vN` → `v(N+1)` en la capa de entrada del consumidor).
3. **Paso 3 — Conmutación del productor:** Una vez desplegados todos los consumidores en QA y PROD, el servicio productor pasa a escribir `version_evento = N + 1` en su tabla `outbox`.
4. **Paso 4 — Drenado y retiro de `vN`:** Cuando `SELECT COUNT(*) FROM <esquema>.outbox WHERE version_evento = N AND fecha_publicacion IS NULL` es `0` y expira la ventana de retención del tópico `vN`, se elimina el soporte de `vN` en el sprint siguiente.

---

## 6. Garantías de aislamiento, idempotencia y verificación

| Garantía | Regla exigible sobre el contrato | Referencia |
| :--- | :--- | :--- |
| **Aislamiento multi-tenant** | Ningún evento es válido sin `tenant_id` (`UUID`). El consumidor ejecuta `withTenantContext(event.tenant_id, ...)` (`ADR-0032`) antes de tocar persistencia. | RNF-01, ADR-0012, ADR-0029 §2, ADR-0032 |
| **Exclusión concurrente y no duplicación de negocio** | `AliadoAsignado` se inserta en `despacho.outbox` en la misma transacción que gana el `UPDATE` condicional de `ADR-0016`. Si el relay reintenta y entrega dos veces el mismo mensaje, el consumidor deduplica por `event_id`. | RNF-05, ADR-0016, ADR-0029 §3 |
| **Trazabilidad extremo a extremo** | `correlation_id` es obligatorio y preserva el `X-Correlation-ID` de la petición HTTP que disparó el cambio de estado. | RNF-07, ADR-0006 |
| **Integridad del esquema Outbox** | `servicio.outbox` admite exclusivamente `('SolicitudCreada','CotizacionAceptada','ServicioFinalizado')` y `despacho.outbox` admite exclusivamente `('AliadoAsignado')`. | ModeloDatos.md §7 y §8 |

### 6.1 Verificación ejecutable

En [`Entregas/PoC/PoC-ARQ06-esquema-versionado-eventos/`](../../qa/PoC/PoC-ARQ06-esquema-versionado-eventos/README.md) se versionan los 5 archivos JSON Schema (`event-envelope.v1.schema.json` y los 4 esquemas `v1` por evento) junto con el verificador ejecutable `validar_contratos_eventos.mjs`, que comprueba 18 aserciones positivas y negativas de contrato, invariantes de dominio y reglas de compatibilidad de versiones.

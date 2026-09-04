# MANI — Modelo de Datos y Diccionario de Datos (DD) — v2 (Backlog completo)

**Autor:** Nicolás Álvarez (Frontend / QA)
**Fuente:** Product_Backlog_General_INVEST.md — cubre las 8 épicas completas, no solo MVP.
**Estado:** Propuesta para presentar — pendiente de validación de la Mesa de Arquitectura.

> El modelo se divide en 3 bloques para que sea legible: **Core** (EP-01 a EP-06, el MVP),
> **Financiero** (EP-07, pagos) y **Soporte/Comercialización** (EP-08). Las entidades
> compartidas (TENANT, USUARIO, SOLICITUD) se repiten como referencia visual en cada bloque.

---

## Bloque 1 — Core: Tenant, Actores, Catálogo y Ciclo del Servicio (EP-01 a EP-06)

```mermaid
erDiagram
    TENANT ||--o{ USUARIO : "tiene"
    TENANT ||--o{ ALIADO : "registra"
    TENANT ||--o{ CLIENTE : "registra"
    TENANT ||--o{ CATEGORIA : "define"
    TENANT ||--o{ TARIFA : "configura"

    USUARIO ||--o{ USUARIO_ROL : "tiene"
    ROL ||--o{ USUARIO_ROL : "asignado_en"
    USUARIO ||--o| ALIADO : "es"
    USUARIO ||--o| CLIENTE : "es"

    ALIADO ||--o{ DOCUMENTO_ALIADO : "adjunta"
    ALIADO ||--o{ ZONA_COBERTURA : "declara"
    ALIADO ||--o{ ALIADO_CATEGORIA : "atiende"
    CATEGORIA ||--o{ ALIADO_CATEGORIA : "es_atendida_por"

    CLIENTE ||--o{ SITIO : "administra"

    CATEGORIA ||--o{ SOLICITUD : "clasifica"
    CLIENTE ||--o{ SOLICITUD : "crea"
    SITIO ||--o{ SOLICITUD : "ubica"
    SOLICITUD ||--o{ SOLICITUD_ALIADO_NOTIF : "difunde_a"
    ALIADO ||--o{ SOLICITUD_ALIADO_NOTIF : "recibe"
    SOLICITUD ||--o| ALIADO : "asigna_a"

    SOLICITUD ||--o| COTIZACION : "genera"
    COTIZACION ||--o{ ADICION_COTIZACION : "amplia_con"
    SOLICITUD ||--o{ EVENTO_EJECUCION : "registra"
    SOLICITUD ||--o| UBICACION_TIEMPO_REAL : "rastrea"
    SOLICITUD ||--o| CANCELACION : "puede_tener"
    SOLICITUD ||--o{ CALIFICACION : "cierra_con"
    SOLICITUD ||--o{ MENSAJE : "conversa_en"
    USUARIO ||--o{ MENSAJE : "envia"
    USUARIO ||--o{ NOTIFICACION : "recibe"

    CATEGORIA ||--o{ TARIFA : "referencia"

    TENANT {
        uuid id PK
        string nombre
        string nit
        string dominio
        enum estado "activo | inactivo | suspendido"
        datetime fecha_registro
    }
    USUARIO {
        uuid id PK
        uuid tenant_id FK
        string email
        string password_hash
        enum estado
        bool terminos_aceptados "US-02.3.2, Habeas Data"
        datetime fecha_aceptacion_terminos
    }
    ROL {
        uuid id PK
        string nombre
    }
    ALIADO {
        uuid id PK
        uuid tenant_id FK
        uuid usuario_id FK
        enum tipo "persona_natural | empresa | empleado_directo"
        string nombre_razon_social
        enum estado_verificacion
        bool disponible "US-02.1.6, pausa temporal"
    }
    DOCUMENTO_ALIADO {
        uuid id PK
        uuid aliado_id FK
        string tipo_documento
        string url_archivo
        enum estado
    }
    ZONA_COBERTURA {
        uuid id PK
        uuid aliado_id FK
        string zona
    }
    CLIENTE {
        uuid id PK
        uuid tenant_id FK
        uuid usuario_id FK
        enum tipo "persona_natural | empresa"
    }
    SITIO {
        uuid id PK
        uuid cliente_id FK
        string direccion
        text reglas_contextuales "US-02.2.3"
    }
    CATEGORIA {
        uuid id PK
        uuid tenant_id FK
        string nombre
        enum estado
    }
    ALIADO_CATEGORIA {
        uuid aliado_id FK
        uuid categoria_id FK
    }
    TARIFA {
        uuid id PK
        uuid tenant_id FK
        uuid categoria_id FK
        decimal valor_min
        decimal valor_tipico
        decimal valor_max
    }
    SOLICITUD {
        uuid id PK
        uuid tenant_id FK
        uuid cliente_id FK
        uuid sitio_id FK
        uuid categoria_id FK
        uuid aliado_asignado_id FK
        enum estado "pending|assigned|in_progress|completed|cancelled"
        text fotos_descripcion "US-04.1.1"
        datetime fecha_creacion
    }
    SOLICITUD_ALIADO_NOTIF {
        uuid id PK
        uuid solicitud_id FK
        uuid aliado_id FK
        enum respuesta "pendiente|aceptada|rechazada"
    }
    COTIZACION {
        uuid id PK
        uuid solicitud_id FK
        decimal mano_obra
        decimal materiales
        bool fuera_de_rango
        enum estado "pendiente|aceptada|rechazada|ajuste_solicitado"
    }
    ADICION_COTIZACION {
        uuid id PK
        uuid cotizacion_id FK
        text motivo "US-04.3.5, imprevisto"
        decimal monto
        enum estado "pendiente|aprobada|rechazada"
    }
    EVENTO_EJECUCION {
        uuid id PK
        uuid solicitud_id FK
        string tipo_evento
        text descripcion
        bool sincronizado "US-04.3.6, offline-first"
        datetime fecha
    }
    UBICACION_TIEMPO_REAL {
        uuid solicitud_id PK
        decimal lat
        decimal lng
        datetime ultima_actualizacion
    }
    CANCELACION {
        uuid id PK
        uuid solicitud_id FK
        string motivo
        bool penalizacion_aplicada "US-04.5.2"
        decimal monto_penalizacion
    }
    CALIFICACION {
        uuid id PK
        uuid solicitud_id FK
        uuid autor_id FK
        uuid destinatario_id FK
        int puntaje
        text comentario
    }
    MENSAJE {
        uuid id PK
        uuid solicitud_id FK
        uuid autor_id FK
        text contenido
        string canal "realtime, ADR-0017"
    }
    NOTIFICACION {
        uuid id PK
        uuid usuario_id FK
        string tipo
        string canal "push FCM/APNs | in-app"
        bool leido
    }
erDiagram
    SOLICITUD ||--o| TRANSACCION : "se_paga_con"
    TRANSACCION ||--o| LIQUIDACION : "se_liquida_en"
    ALIADO ||--o{ LIQUIDACION : "recibe"

    TRANSACCION {
        uuid id PK
        uuid solicitud_id FK
        decimal monto
        string medio_pago "tarjeta | PSE"
        enum estado "retenido_garantia|liberado|reembolsado"
        datetime fecha_pago
        datetime fecha_liberacion_programada "US-07.1.5, 24h sin disputas"
        string url_comprobante "US-07.1.3, PDF"
        bool inmutable "US-07.1.2, no editable tras creación"
    }
    LIQUIDACION {
        uuid id PK
        uuid transaccion_id FK
        uuid aliado_id FK
        decimal comision "configurable por tenant, RF-25"
        decimal monto_neto
        datetime fecha
    }
erDiagram
    SOLICITUD ||--o| QUEJA : "puede_generar"
    QUEJA ||--o| DISPUTA : "puede_escalar_a"
    TRANSACCION ||--o| DISPUTA : "se_resuelve_en"
    TENANT ||--o{ CAMPANA : "crea"
    CAMPANA ||--o{ CAMPANA_CANJE : "es_canjeada_en"
    USUARIO ||--o{ CAMPANA_CANJE : "canjea"

    QUEJA {
        uuid id PK
        uuid solicitud_id FK
        uuid cliente_id FK
        text descripcion
        enum estado "abierto|en_revision|resuelto"
        datetime fecha
    }
    DISPUTA {
        uuid id PK
        uuid queja_id FK
        uuid transaccion_id FK
        enum fallo "reembolso_total|reembolso_parcial|pago_aliado"
        decimal monto_resuelto
        uuid resuelto_por FK "admin_tenant"
        datetime fecha_resolucion
    }
    CAMPANA {
        uuid id PK
        uuid tenant_id FK
        string codigo_descuento
        datetime fecha_inicio
        datetime fecha_fin
    }
    CAMPANA_CANJE {
        uuid id PK
        uuid campana_id FK
        uuid usuario_id FK
        datetime fecha_canje
    }
**Nota:** `TRANSACCION` modela el escrow directamente en el `estado` (queda `retenido_garantia`
al aceptar la cotización, RF-24/US-07.1.4, y pasa a `liberado` tras 24h sin disputa o por
resolución manual de una `DISPUTA`, ver Bloque 3). El campo `inmutable` es una bandera de
diseño: en la implementación real esto se traduce en que la tabla no permite UPDATE, solo
INSERT de nuevos estados (append-only), para cumplir RNF-04.

## Bloque 3 — Soporte y Comercialización (EP-08)

```mermaid
erDiagram
    SOLICITUD ||--o| QUEJA : "puede_generar"
    QUEJA ||--o| DISPUTA : "puede_escalar_a"
    TRANSACCION ||--o| DISPUTA : "se_resuelve_en"
    TENANT ||--o{ CAMPANA : "crea"
    CAMPANA ||--o{ CAMPANA_CANJE : "es_canjeada_en"
    USUARIO ||--o{ CAMPANA_CANJE : "canjea"

    QUEJA {
        uuid id PK
        uuid solicitud_id FK
        uuid cliente_id FK
        text descripcion
        enum estado "abierto|en_revision|resuelto"
        datetime fecha
    }
    DISPUTA {
        uuid id PK
        uuid queja_id FK
        uuid transaccion_id FK
        enum fallo "reembolso_total|reembolso_parcial|pago_aliado"
        decimal monto_resuelto
        uuid resuelto_por FK "admin_tenant"
        datetime fecha_resolucion
    }
    CAMPANA {
        uuid id PK
        uuid tenant_id FK
        string codigo_descuento
        datetime fecha_inicio
        datetime fecha_fin
    }
    CAMPANA_CANJE {
        uuid id PK
        uuid campana_id FK
        uuid usuario_id FK
        datetime fecha_canje
    }
```

**Nota sobre métricas (US-08.3.1):** el dashboard operativo (servicios completados, ingresos,
aliados activos) **no se modela como tabla propia** — es una vista/reporte calculado sobre
`SOLICITUD`, `TRANSACCION` y `ALIADO` ya existentes. Modelarlo como tabla física duplicaría
datos y rompería la fuente única de verdad.

---

## Diccionario de Datos — Bloque Financiero y Soporte (nuevas entidades vs. v1)

### TRANSACCION
| Campo | Tipo | Descripción | RF |
|---|---|---|---|
| estado | enum | `retenido_garantia` al pagar, `liberado` a las 24h sin disputa o `reembolsado` si hay fallo en contra | RF-24, US-07.1.4/5 |
| fecha_liberacion_programada | datetime | Se calcula al crear la transacción (fecha_pago + 24h) | US-07.1.5 |
| inmutable | bool | Marca de diseño: la fila no se edita, solo se agregan nuevas transacciones/estados | RNF-04, US-07.1.2 |
| url_comprobante | string | PDF descargable del pago | US-07.1.3 |

### LIQUIDACION
| Campo | Tipo | Descripción | RF |
|---|---|---|---|
| comision | decimal | Porcentaje/valor configurable por tenant | RF-25 |
| monto_neto | decimal | Lo que efectivamente recibe el aliado tras comisión | RF-25, US-07.2.2 |

### QUEJA / DISPUTA
| Campo | Tipo | Descripción | RF |
|---|---|---|---|
| queja.estado | enum | abierto / en_revision / resuelto | RF-26, US-08.1.2 |
| disputa.fallo | enum | Decisión del admin del tenant sobre los fondos en escrow | US-08.1.3 |
| disputa.resuelto_por | uuid FK | Admin de tenant que emite el fallo (trazabilidad) | US-08.1.3 |

### CAMPANA / CAMPANA_CANJE
| Campo | Tipo | Descripción | RF |
|---|---|---|---|
| codigo_descuento | string | Código que el cliente redime | RF-27, US-08.2.2 |
| campana_canje | tabla puente | Registra cada canje individual, para medir ROI | US-08.2.2 |

---

## Nuevas entidades del Bloque Core (vs. v1, agregadas por el backlog INVEST)

| Entidad | Por qué se agregó | Historia |
|---|---|---|
| ADICION_COTIZACION | El aliado puede pedir cobro extra por imprevisto durante la ejecución, separado de la cotización original | US-04.3.5 |
| UBICACION_TIEMPO_REAL | Tracking en vivo del aliado en camino — se modela aparte de EVENTO_EJECUCION porque se actualiza con alta frecuencia y no es un evento discreto | US-04.3.4 |
| CANCELACION | Cancelar antes de ejecución y penalización si el aliado ya iba en camino | US-04.5.1, US-04.5.2 |
| EVENTO_EJECUCION.sincronizado | Soporte offline-first: evidencias se guardan localmente y se sincronizan al recuperar señal | US-04.3.6 |
| USUARIO.terminos_aceptados | Aceptación de T&C y Habeas Data (Ley 1581) en el registro | US-02.3.2 |
| ALIADO.disponible | El aliado se marca "no disponible" temporalmente sin borrar su perfil | US-02.1.6 |

---

## Resumen: qué queda fuera intencionalmente

- **CFG-01.1 a CFG-01.7** (repos, Supabase, CI/CD, SAD) son tareas de infraestructura, no
  entidades de datos — no aparecen en el modelo.
- **Métricas (US-08.3.1)** se resuelven por consulta/vista, no por tabla nueva.
- El **historial de servicios** (US-04.6.1/6.2) es una consulta filtrada sobre `SOLICITUD`,
  no una entidad aparte.

*Documento de apoyo — no reemplaza el ADR ni el paso por la Mesa de Arquitectura si se
formaliza como decisión de modelo de datos.*

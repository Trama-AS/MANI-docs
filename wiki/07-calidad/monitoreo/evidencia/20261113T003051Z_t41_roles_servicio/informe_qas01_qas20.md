# SCRUM-1678 (T-41): QAS-01 y QAS-20 con mani_core_svc y mani_dispatch_svc

**Fecha de la corrida:** 2026-11-13 00:30:51Z a 00:32:24Z (12 nov, hora Colombia)
**Ambiente:** MANI-QA (VM 10.43.100.141, Supabase QA por el pooler, puerto 5432)
**Responsable:** Santiago (QA)
**Método:** SDD §8 (QAS-01 y QAS-20) y §8.12 (seis casos cross-tenant, con verificación por el Gateway y en el motor)
**Resultado de la corrida:** 37 verificaciones PASA, 0 FALLA, 0 REVISAR

## 1. Por qué se repite

La medición del 5 nov dejó QAS-01 y QAS-20 en **Parcial**. Esa medición es anterior al despliegue de TEC-21, que se hizo el 5 nov a las 19:05Z (0037 y 0038) y a las 20:14Z (0039). Antes de ese despliegue, Core y Dispatch conectaban como `postgres`, de modo que RLS y los `GRANT` de los roles no se ejercían. Esta corrida se hace con las conexiones reales de cada servicio.

## 2. Condiciones de la corrida

| Elemento | Valor |
|---|---|
| Gateway | `ecd9ec2` |
| Core | `cfa503a` |
| Dispatch | `930a15b` |
| Rules | `3e3da57` |
| Migraciones | 0037, 0038 y 0039 aplicadas (`schema_migrations`) |
| Conexión de Core | `mani_core_svc.<ref>` (`DATABASE_URL`) |
| Conexión de Dispatch | `mani_dispatch_svc.<ref>` (`DISPATCH_DB_CONNECTION`) |
| `db/verify/0037_verificar_sin_bypassrls.sql` | "TEC-21: roles y políticas conformes"<br>ambos roles con LOGIN y sin SUPERUSER ni BYPASSRLS<br>ninguna política TO public en tablas con `tenant_id`<br>Core y Dispatch conectados con su propio rol (3 y 2 sesiones) |
| Datos | tenants T1 y T2 del seed `seed_qa_multitenant.sql`, con las 6 cuentas `*.t1` y `*.t2`<br>2 solicitudes de prueba, una por tenant, que quedaron CANCELADAS al final |

Todas las verificaciones del motor corren en transacciones que terminan en ROLLBACK.

## 3. QAS-01 Confidencialidad

**Umbral:** 100 % de accesos cross-tenant rechazados.

| Caso | Por el Gateway (token de T2 sobre recurso de T1) | En el motor (`mani_core_svc`, contexto T1, sin `WHERE tenant_id`) |
|---|---|---|
| 1 Lectura de otro tenant | `404 MANI-SOL-404` | sitio y solicitud de T2 por id: 0 filas |
| 2 Listado | `200` sin la solicitud de T1 | 32 tablas leídas, 0 con filas de otro tenant |
| 3 Escritura en otro tenant | `404 MANI-COT-404` | INSERT con `tenant_id` de T2: `42501` RLS<br>UPDATE que pasa una fila de T1 a T2: `42501` RLS<br>UPDATE de una fila de T2: 0 filas |
| 4 Borrado o cancelación ajena | `404 MANI-SOL-404`; la solicitud sigue PENDIENTE | DELETE por id de T2: 0 filas |
| 5 Token alterado | `401` en el Gateway | sin `set_context`: 0 filas y `UPDATE 0`<br>claim corrupto: 0 filas<br>`set_context` sin tenant: `MANI-RLS-400` (`22023`) |
| 6 KYC de otro tenant | `404 MANI-VER-404` | aliado de T1: ve solo su `documento_kyc` (1, 0 ajenos)<br>admin de T1: 4 visibles, 0 de T2<br>Storage `{T2}/…`: `42501` |

| Propiedad | Resultado |
|---|---|
| P1 El contexto no se hereda | Con contexto se ven 33 filas; en la transacción siguiente, sin contexto, 0 |
| P3 Frontera de Dispatch | Ver QAS-20 |
| P4 Rol en la aceptación | Un cliente que intenta aceptar recibe `403 MANI-DSP-403`.<br>Un aliado de T1 que intenta aceptar una solicitud de T2 recibe `404`, y la solicitud de T2 sigue PENDIENTE |
| P5 Un cliente no fabrica contexto | `authenticated` y `anon` no tienen EXECUTE sobre `app.set_context` |

**Correlación:** la corrida API del caso 1 es `t41-8186c9948a`; cada caso tiene su propio `cid` en la evidencia.

**`documento_legal`:** con contexto T1 se ven 2 filas que no son de T1. Ambas tienen `tenant_id NULL` y son `TERMS_AND_CONDITIONS` 1.0 y `PRIVACY_POLICY` 1.0, documentos globales activos. Según el criterio acordado, es un comportamiento legítimo, no una fuga. Ninguna fila de T2 es visible.

**Estado propuesto:** **Cumple**. Pasaron todos los casos, por el Gateway y en el motor. Es la primera medición en la que RLS opera con el rol real de Core, que era el criterio de cierre de SCRUM-1334.

**Limitaciones:**
- La segunda parte del caso 4 ("un DELETE sin WHERE solo alcanza T1") no se pudo ejecutar: la llave foránea `solicitud_sitio_id_fkey` la rechaza (`23503`). Sí se verificó el DELETE por id de T2.
- El subcaso "aliado A pide el KYC del aliado B del mismo tenant" no se puede probar, porque el seed tiene un solo aliado por tenant.
- En Storage, `mani_core_svc` no tiene permiso sobre el esquema `storage` (`42501`). Eso deniega todo acceso, pero no ejercita la política `kyc_isolation` con ese rol.

## 4. QAS-20 Modularidad (frontera de datos)

**Umbral:** ningún servicio accede directamente a tablas de otro dominio.

**Escrituras y lecturas prohibidas con `mani_dispatch_svc`:** todas fueron rechazadas con `42501 permission denied`.

| Intento | Resultado |
|---|---|
| INSERT en `notificacion` (P3) | rechazado |
| UPDATE en `aliado` (P3) | rechazado |
| SELECT en `aliado` (P3) | rechazado |
| SELECT en `notificacion` (P3) | rechazado |
| UPDATE en `solicitud` (decisión 6A, migración 0019) | rechazado |
| INSERT en `cotizacion` | rechazado |
| DELETE en `pago` | rechazado |

**Escritura permitida:** INSERT en `solicitud_rechazo`. Se insertó 1 fila, que luego se revirtió.

**Privilegios efectivos de `mani_dispatch_svc`:**

| Tabla | Privilegios |
|---|---|
| `solicitud` | lectura |
| `solicitud_rechazo` | lectura y alta |
| `tenant` | lectura |
| `zona` | lectura |

Coincide con ADR-0030 y con la decisión 6A. `mani_core_svc` no tiene privilegios sobre `solicitud_rechazo`, la tabla de Dispatch. Core tiene 35 tablas en lectura y 32 en escritura de 38, todas de su dominio o catálogos.

**Código de Dispatch** (`930a15b`, 42 archivos `.cs` fuera de pruebas): no hay SQL sobre tablas de Core. Solo usa `solicitud_rechazo` (INSERT y SELECT) y `solicitud` (SELECT) en `PostgresSolicitudAssignmentRepository.cs`.

**Comparación con el 5 nov:** el conteo de privilegios era el mismo (Dispatch: 4 en lectura y 1 en escritura), pero entonces no se ejercía porque los servicios conectaban como `postgres`. Ahora el rechazo ocurre en el motor con la conexión real de Dispatch.

**Estado propuesto:** **Cumple** para la frontera Core–Dispatch.

**Limitaciones:**
- Rules (`3e3da57`) también está en el alcance de QAS-20 según el SDD, pero T-41 solo pide los roles de Core y Dispatch. Su rol de base de datos no se revisó aquí.
- La búsqueda en el código es por nombres de tabla en SQL. No es una auditoría completa de las consultas.

## 5. Evidencia

| Archivo | Contenido |
|---|---|
| [`t41_qas01_qas20_qa.txt`](t41_qas01_qas20_qa.txt) | corrida completa en QA: precondiciones, Gateway, motor y limpieza; secretos redactados |
| [`qas20_codigo_dispatch.txt`](qas20_codigo_dispatch.txt) | búsqueda de tablas de Core en el código de Dispatch |
| [`scripts/correr_t41_qa.sh`](scripts/correr_t41_qa.sh), [`t41_qa.py`](scripts/t41_qa.py), [`qas01_motor.sql`](scripts/qas01_motor.sql), [`qas20_frontera.sql`](scripts/qas20_frontera.sql), [`qas20_tablas_core_en_dispatch.sh`](scripts/qas20_tablas_core_en_dispatch.sh) | scripts reproducibles (`bash qa_t41/correr_t41_qa.sh`) |

## 6. Pendiente de cierre (requiere confirmación)

- Comentario en SCRUM-1678 con este resultado y la transición que corresponda.
- Actualizar la columna Resultado del SDD §8 (QAS-01 y QAS-20) y subir la evidencia a `wiki/07-calidad/` en MANI-docs, por PR que acepta Sara.
- No hay fallas, así que no hay que abrir ningún bug tipo Error.

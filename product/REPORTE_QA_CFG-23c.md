# Reporte QA de CFG-23c (SCRUM-1105): aislamiento cross-tenant con el Core como llamador

| Campo | Valor |
|---|---|
| Tarea | SCRUM-1105 (CFG-23c), épica EP-09, subtareas SCRUM-1173 a SCRUM-1177 |
| Objetivo de la tarea | Los seis casos de aislamiento de ADR-0015 y de `governance/POLITICAS_DEVOPS_HERRAMIENTAS.md` §13.4 ejecutados en QA, con resultado de rechazo o ausencia de datos y con el Core como llamador |
| Camino | Supabase Auth (login, ADR-0027) y Flutter o Newman -> NGINX Gateway -> Core Node -> Supabase |
| Autor | Santiago (QA) |
| Corte | 7 de octubre de 2026, 17:30 (Bogotá). Plazo extendido por la Scrum Master hasta la noche del mismo día |
| Estado del documento | En revisión (Pull Request). Pendiente de aprobación de la Scrum Master |
| Casos fuente | rgB1 a rgB6 de `product/PLAN_REGRESION_US-02.1.1-M4.md` §5 y escenarios B1 a B6 de `product/CRITERIOS_ACEPTACION_US-02.1.1.md` §6 (`MANI-docs` `main`). No se reescriben aquí |

## 1. Resultado

| Concepto | Resultado |
|---|---|
| Casos ejecutados en QA con el Core como llamador | **0 de 6.** No ejecutados |
| Aislamiento multi-tenant por el camino nuevo | **No acreditado** |
| DoD de SCRUM-1105 (100 % ejecutado, defectos en Jira, reporte aprobado y socializado) | **No cumplido** |
| Lo que sí se entrega | Matriz de datos (1173); colección Newman para el Gateway con los seis casos y sus controles positivos (1174 y 1175); script SQL de RLS como defensa adicional; validación local del Core de `develop` en memoria; este reporte con hallazgos y bloqueos (1177) |

Este reporte no afirma que el aislamiento funcione en QA. Dice qué se verificó, dónde, con qué evidencia y qué quedó sin verificar.

## 2. Por qué no se ejecutó en QA

| Bloqueo | Ticket | Responsable | Estado al corte |
|---|---|---|---|
| El Core no está desplegado en QA: el repositorio solo tiene el entorno `dev`; no existe `qa`. `main` de Node sigue revertida (`19595d9`) y el CD solo despliega desde `main` | CFG-20 (SCRUM-1100), CFG-27 (1108), CFG-28 (1107) | Juan, Daniel | En revisión / En curso |
| El código nuevo del Core vive en `develop` (`200c3b9`); su PR a `main` (Node #13) tiene cambios pedidos | SCRUM-1065 (M2) | Juan | En revisión |
| El Gateway `main` (`e312793`) no tiene las correcciones de CFG-16 (CORS sin `X-Tenant-Slug`); Gateway #3 y #4 tienen cambios pedidos | CFG-16 (SCRUM-1099) | Juan | En revisión |
| El contrato no define endpoints de estado, de documentos KYC (listar, modificar, borrar) ni de acceso temporal al documento; tampoco el código de rechazo cross-tenant (403 o 404) | CFG-16 (PA-29), CFG-23a (PA-09) | Juan, Sara | Abierto |
| Modelo de identidad en base de datos y políticas RLS versionadas | CFG-23a (SCRUM-1103), CFG-23b (SCRUM-1104) | Sara, Daniel | Por hacer, fuera del sprint |
| Alineación de JWT entre Supabase Auth, Gateway y Core | CFG-22 (SCRUM-1102) | Daniel | Por hacer |
| Controles positivos de B3 y B4 (si el aliado puede reemplazar o retirar un documento PENDIENTE) | PA-08 | Nicolás León (PO) | Abierto |

## 3. Fuentes y cortes

| Fuente | Corte |
|---|---|
| `MANI-Node` | `develop` `200c3b9` (7 oct 15:50); `main` `19595d9`. CI de `develop` en verde |
| `MANI-Flutter` | `develop` `658b4b6` (envía `X-Tenant-Slug` con el slug) |
| `MANI-APIGateway` | `main` `e312793`; PR #2 (SCRUM-1110), #3 y #4 (CFG-16) abiertos |
| `MANI-docs` | `main` `ae8fe7e` (incluye criterios y plan de regresión de US-02.1.1 y el plan de EP-02) |
| Jira | SCRUM-1105 En curso; 1173 a 1177 Por hacer; estados de dependencias de la sección 2 |
| ADR | ADR-0012, 0013, 0015, 0018, 0022 y 0027 |

## 4. Resultado por caso

Regla de lectura (CRITERIOS §6): el rechazo es 403 o 404, o ausencia total de datos ajenos; nunca 200 con datos del otro tenant. Cada negativo solo vale si su control positivo pasa en la misma corrida.

"Local" significa: Core de `develop` `200c3b9` en memoria (`NODE_ENV=test`, sin Supabase), en esta máquina, detrás de un proxy que imita el `location /api/v1/core/` de nginx. Prueba la lógica de autorización del Core, no QA, no ES256 real y no RLS.

| Caso | Escenario | En QA | Validación local | Qué falta para ejecutarlo en QA |
|---|---|---|---|---|
| 1. Lectura | rgB1 | No ejecutado | Parcial. `/profiles/me` con el mismo `sub` y un token firmado de otro tenant da **404 sin datos**; el control positivo da 200 con el propio tenant | Core en QA. La lectura del estado de un aliado ajeno necesita `{{ruta_estado}}` (CFG-16, PA-29) |
| 2. Listado | rgB2 | No ejecutado | No aplica: no hay endpoint de listado | `{{ruta_documentos}}` (CFG-16, PA-29) |
| 3. Escritura | rgB3 | No ejecutado | Variante de inserción (3b): registro con `X-Tenant-Slug` del tenant 1 y `tenant_id` del tenant 2 en el cuerpo da **201 con perfil y token del tenant 1**; el tenant del cuerpo se ignora. `X-Tenant-Id` (id en lugar de slug) da 400; slug inexistente da 400 `TENANT_NOT_FOUND`. Modificar el documento ajeno: no aplica, no hay endpoint | `{{ruta_documentos}}` y `{{ruta_estado}}` (CFG-16); PA-08 para el control positivo |
| 4. Borrado | rgB4 | No ejecutado | No aplica: no hay endpoint de borrado | `{{ruta_documentos}}` (CFG-16); PA-08 |
| 5. Token | rgB5 | No ejecutado | **8 de 9 variantes de rechazo pasan.** 401 `TOKEN_INVALID` para `tenant_id` reescrito, firma basura, otra clave, `alg: none`, HS512, claims en la raíz sin `app_metadata` y usuario sin tenant; 401 `TOKEN_EXPIRED` para token vencido. **Falla:** sin `Authorization` responde 401 sin el campo `code` (A-07). Control positivo: 200 | Core en QA con `SUPABASE_URL` (el camino ES256 por JWKS no se ejercitó en local) y CFG-22 |
| 6. KYC | rgB6 | No ejecutado | Lado de la carga: campo fuera de la lista blanca y MIME no permitido dan 400 `VALIDATION_ERROR`; la carga válida da 201. El acceso posterior al documento no aplica: no hay endpoint | `{{ruta_acceso_documento}}` y `{{ttl_url_firmada}}` (CFG-23a, PA-09). Camino directo a Storage: N1 a N11 de `mani-aislamiento` más `cliente.t2`, con acceso a QA |

Evidencia local: 17 verificaciones con un script contra el Core (16 pasan) y una corrida de la colección con Newman. Los archivos de evidencia no contienen tokens ni credenciales y quedan fuera del repositorio hasta decidir la ubicación de la colección (sección 6). Pruebas unitarias del Core en el mismo commit: 120 de 120 en verde; lint sin errores.

## 5. Hallazgos

### 5.1 Hallazgos del reporte de M4 (SCRUM-1062), estado al corte

Los IDs son los del reporte de trabajo de M4 (SCRUM-1062), todavía no publicado. Ninguno está verificado en QA.

| ID | Hallazgo | Estado en `develop` `200c3b9` | Cómo se comprobó |
|---|---|---|---|
| H-01 | `signInWithPassword` sobre el cliente compartido de service-role | Corregido en código: cliente desechable con la llave publicable | Lectura de `SupabaseAuthIdentityService.js` y pruebas unitarias |
| H-02 | Sin compensación si falla un paso tras `createUser` | Corregido en código (commit "B3 compensacion/rollback") | Lectura y pruebas unitarias |
| H-03 | `/profiles/me` devolvía el perfil demo a cualquier token | Corregido: `SupabaseProfileRepository` filtra por `tenant_id`; el repositorio en memoria ya no tiene perfil de respaldo | Local (rgB1: 404 entre tenants) y lectura |
| H-04 | Core solo HS256; la PoC de CFG-12 registró ES256 | Corregido en código: HS256 y ES256 por JWKS; claims solo desde `app_metadata` | Local para HS256 y anti-spoofing; ES256 solo por lectura |
| H-05 | CD sin depender de CI, secreto JWT público de respaldo | Corregido en código según el commit; el CD sigue sin entorno `qa` | Lectura de `config/index.js`; Actions |
| H-06 | `X-Tenant-Slug` resuelto con `findById` y `X-Tenant-Id` aceptado | Corregido: `findBySlug` y sin fallback a `X-Tenant-Id` | Local (rgB3b y rgA3) |
| H-07 | `upload.any()` sin lista blanca | Corregido: lista blanca de campos, MIME y número de archivos | Local (rgB6) |
| H-08 | Flutter enviaba `X-Tenant-Id` | Corregido en Flutter `develop` `658b4b6` (envía el slug) | Lectura |
| H-10 | CORS del Gateway `main` sin `X-Tenant-Slug` | **Abierto** en `main`; corregido solo en la rama CFG-16, sin fusionar | Lectura de `nginx.conf` |

### 5.2 Hallazgos propios de CFG-23c

| ID | Hallazgo | Severidad | Caso | Evidencia | Dueño y ticket |
|---|---|---|---|---|---|
| A-01 | El Core se conecta a Supabase con service_role, que tiene BYPASSRLS. Para sus llamadas, RLS no es defensa adicional (ADR-0012, KI-05 de ADR-0022): la única barrera es la autorización del propio Core. La subida a Storage tampoco pasa por `kyc_isolation` | Alta (riesgo de diseño) | Todos | `SupabaseClientFactory.js`; bloque 0 y 2 de `verificar_rls_defensa_adicional.sql` (por ejecutar) | Sara, CFG-23a (SCRUM-1103) |
| A-02 | El contrato no tiene endpoints para los casos 1 (estado), 2, 3, 4 y 6 (acceso al documento). Esos casos no tienen recurso en el Core | Alta (bloqueo) | rgB1 a rgB4, rgB6 | `docs/openapi/core.yaml` | Juan, CFG-16 (SCRUM-1099) |
| A-08 | Las políticas versionadas no aíslan `documento_kyc` por tenant: `database/init/04-supabase-rls-and-functions.sql` crea `SELECT USING (true)` e `INSERT WITH CHECK (true)`, y ninguna migración las reemplaza. Sin embargo, la evidencia de septiembre en QA (`aislamiento-adr0015`, `aislamiento-cfg13-restaurada`) sí muestra aislamiento. Inferencia: QA tiene políticas aplicadas a mano que no están en el repositorio, y un ambiente reconstruido desde el repositorio quedaría sin aislamiento | Alta | rgB1 a rgB4 (camino directo) | Lectura de `database/` y `supabase/` en Flutter `develop`; bloque 0.c del SQL confirma o descarta | Daniel, CFG-23b (SCRUM-1104) |
| A-03 | `GET /tenants` responde sin autenticación con todos los tenants (id, nombre, slug, estado) | Media (por decidir) | rgB2 | Local: 200 con 4 tenants sin token | PO y Juan |
| A-07 | Sin `Authorization`, `/profiles/me` responde 401 sin el campo `code`; el contrato pide `UNAUTHORIZED`. El controlador corta antes del manejador de errores | Baja | rgB5 | Local (rgB5-N5) y Newman | Juan, SCRUM-1065 |
| A-09 | `X-Correlation-ID` lo emiten nginx (`add_header`) y Node (`setHeader`): la respuesta por el Gateway puede llevar el encabezado duplicado | Baja | Trazabilidad | Lectura de `nginx.conf` y `correlationId.middleware.js`; no ejecutado por el Gateway real | Daniel y Juan |

## 6. Entregables

| Subtarea | Entregable | Archivo |
|---|---|---|
| SCRUM-1173 | Matriz de tenants, actores por rol, registros e IDs; variables de entorno por nombre; orden de resiembra | Anexo A de este documento |
| SCRUM-1174 | Casos 1 a 5 por el Gateway, cada negativo con control positivo; marcadores pendientes atados a su ticket; rgB5 y 3b completos | `mani_aislamiento_gateway.postman_collection.json` (carpetas 00 a 05) |
| SCRUM-1175 | Caso 6 por el Gateway (carga y acceso) y complemento del camino directo con `cliente.t2` | Misma colección, carpeta 06 |
| SCRUM-1176 | Sin ejecución en QA. Validación local como sustituto parcial | Sección 4 |
| SCRUM-1177 | Este reporte; hallazgos para Jira | `product/REPORTE_QA_CFG-23c.md` |
| Complemento | RLS como defensa adicional, para ejecutar en QA | `verificar_rls_defensa_adicional.sql` |

La colección y el script SQL son borradores de trabajo y no se incluyen en este Pull Request: se versionan en el repositorio que se acuerde.

Notas sobre la colección:
- 7 carpetas y 47 solicitudes. Las que dependen de un marcador `PENDIENTE_<ticket>` se saltan solas hasta que el marcador se complete.
- Credenciales y tokens solo por variables de entorno. El JSON de Newman se redacta con `MANI-Flutter/qa/newman/redactar_evidencia.mjs` antes de guardarlo.
- Ubicación final pendiente: `MANI-Flutter/qa/newman` (donde vive la suite actual), `MANI-Node/postman` en un archivo aparte (el generador desde el OpenAPI no lo sobrescribe) o `MANI-APIGateway`. Se decide con Juan (QA-03) y Daniel.

## 7. Cumplimiento del DoD de SCRUM-1105

| Criterio | Estado |
|---|---|
| 100 % de los casos ejecutados en QA | No cumplido: 0 de 6 |
| Defectos documentados en Jira | Pendiente: hallazgos listos en la sección 5; se registran con confirmación |
| Reporte de PoC/QA aprobado y socializado | Pendiente de aprobación de la Scrum Master |

## 8. Propuesta de cierre

1. Aceptar este entregable como cierre parcial de SCRUM-1105: 1173, 1174 y 1175 entregadas; 1177 entregada con este reporte.
2. Llevar la ejecución (1176) al Incremento 2, condicionada a: Core desplegado en QA, Gateway con CFG-16 fusionado, endpoints de A-02 en el contrato y CFG-23a y CFG-23b aplicados.
3. Subir la prioridad de CFG-22, CFG-23a y CFG-23b para el Incremento 2: sin ellas el aislamiento no se puede acreditar y las regresiones de US-02.1.2 y US-02.2.1 (backlog §3.6) quedan sin base.
4. Ejecutar en QA el script SQL (bloques 0 y 1) cuanto antes: confirma o descarta A-08 sin depender del Core.
5. Ninguna función PL/pgSQL queda autorizada para retirarse por este reporte (ADR-0022).

## Anexo A. Matriz de datos de prueba (SCRUM-1173)

| Campo | Valor |
|---|---|
| Tarea | SCRUM-1173 (CFG-23c-1), subtarea de SCRUM-1105 |
| Estado | No se aplicó ni se verificó en QA |
| Corte | 7 de octubre de 2026, 17:15 (Bogotá) |
| Fuentes | `MANI-Flutter` `develop` `658b4b6`: `supabase/seed/seed_qa_multitenant.sql` (CFG-04), `supabase/poc-cfg12/20_seed_identidad.sql` (CFG-12), `supabase/poc-cfg13/20_seed_storage.sql` (CFG-13), `supabase/seed/README.md` |

La infraestructura de base de datos está migrando de `MANI-Flutter` a `MANI-APIGateway` (SCRUM-1110: PR 2 del Gateway, abierto, que la recibe con blobs idénticos, y PR 35 de Flutter, abierto, que la retira). Mientras los dos no se fusionen, la ruta vigente es la de `MANI-Flutter` `develop`.

### A.1 Tenants

| Marcador | Id | Slug | Nombre | Estado |
|---|---|---|---|---|
| `tenant_t1` / `slug_t1` | `10000000-0000-4000-8000-000000000011` | `acme-servicios` | ACME Servicios | ACTIVO |
| `tenant_t2` / `slug_t2` | `10000000-0000-4000-8000-000000000021` | `nova-mantenimiento` | Nova Mantenimiento | ACTIVO |
| `slug_inexistente` | No existe | `tenant-que-no-existe` | | |

Los dos tenants comparten la zona Chapinero a propósito (decisión del seed de CFG-04): una fuga de aislamiento se ve de inmediato y no queda oculta por un filtro geográfico.

No hay un tenant inactivo en el seed. Si un caso lo necesita, se crea en la corrida y se borra al final; no se agrega al seed compartido sin acordarlo con Daniel.

### A.2 Actores

`usuario.id` es igual a `auth.users.id`. Todas las cuentas de CFG-04 tienen `tenant_id`, `user_role` y `rol` en `raw_app_meta_data`, que es donde el Core de `develop` (`200c3b9`) lee los claims.

| Actor | Correo | Tenant | Rol (`usuario.rol`) | `usuario.id` | Fila de negocio | Casos |
|---|---|---|---|---|---|---|
| `admin.t1` | `admin.t1@qa.mani.test` | t1 | ADMIN_TENANT | `30000000-0000-4000-8000-000000000011` | | rgB2 (control positivo), rgB6 (P2) |
| `cliente.t1` | `cliente.t1@qa.mani.test` | t1 | CLIENTE | `30000000-0000-4000-8000-000000000012` | cliente `40000000-0000-4000-8000-000000000011` | rgB6 (N7: un cliente no ve KYC) |
| `aliado.t1` | `aliado.t1@qa.mani.test` | t1 | ALIADO | `30000000-0000-4000-8000-000000000013` | aliado `50000000-0000-4000-8000-000000000011`, VERIFICADO | Actor principal de rgB1 a rgB6 |
| `hook.t1` | `hook.t1@cfg12.mani.test` | t1 | ALIADO | `30000000-0000-4000-8000-c00000000011` | Sin fila en `aliado` | rgB6 (N6: otro aliado del mismo tenant) |
| `admin.t2` | `admin.t2@qa.mani.test` | t2 | ADMIN_TENANT | `30000000-0000-4000-8000-000000000021` | | Comprobación posterior de rgB3 y rgB4; rgB6 (N1b, N2b, N3b) |
| `cliente.t2` | `cliente.t2@qa.mani.test` | t2 | CLIENTE | `30000000-0000-4000-8000-000000000022` | cliente `40000000-0000-4000-8000-000000000021` | rgB6 (nuevo: cliente de otro tenant, PA-10) |
| `aliado.t2` | `aliado.t2@qa.mani.test` | t2 | ALIADO | `30000000-0000-4000-8000-000000000023` | aliado `50000000-0000-4000-8000-000000000021`, VERIFICADO | Atacante de rgB1 a rgB6 |
| `hook.t2` | `hook.t2@cfg12.mani.test` | t2 | CLIENTE | `30000000-0000-4000-8000-c00000000021` | Sin fila en `cliente` | Reserva |
| `huerfano` | `huerfano@cfg12.mani.test` | Ninguno | CLIENTE | `30000000-0000-4000-8000-c00000000091` | | rgB5 (token sin `tenant_id`: debe dar 401) |
| `sin.perfil` | `sin.perfil@cfg12.mani.test` | Ninguno | Sin fila en `usuario` | `30000000-0000-4000-8000-c00000000092` | | rgB5 (token sin claims) |
| `anonimo` | | | | | | rgB5 (sin `Authorization`), rgB6 (N8) |

Hallazgo para PA-10: `cliente.t2` sí existe en el seed de CFG-04. A la colección `mani-aislamiento` solo le falta su login; no hace falta sembrar nada nuevo.

### A.3 Registros por tenant

| Dato | Tenant 1 | Tenant 2 |
|---|---|---|
| `documento_kyc` (CFG-12) | `a0000000-0000-4000-8000-c00000000011` | `a0000000-0000-4000-8000-c00000000021` |
| Ruta en Storage (CFG-13, bucket `kyc-documentos`) | `<tenant_t1>/<usuario aliado.t1>/cedula.pdf` | `<tenant_t2>/<usuario aliado.t2>/cedula.pdf` |
| `categoria_servicio` | `60000000-0000-4000-8000-000000000011` (Plomeria) | `60000000-0000-4000-8000-000000000021` (Electricidad) |
| `sitio` | `70000000-0000-4000-8000-000000000011` | `70000000-0000-4000-8000-000000000021` |
| `aliado_categoria` | `80000000-0000-4000-8000-000000000011` | `80000000-0000-4000-8000-000000000021` |
| `cobertura_aliado` | `90000000-0000-4000-8000-000000000011` | `90000000-0000-4000-8000-000000000021` |

La ruta de Storage usa `usuario_id`, igual que el Core de `develop` (`{tenant_id}/{user_id}/`). ADR-0013 dice `aliado_id`; ese choque es PA-04 y sigue abierto.

### A.4 Datos que crea la corrida

| Dato | Para qué | Limpieza |
|---|---|---|
| Aliado nuevo por `POST /auth/register/ally` en t1 (correo `reg.<timestamp>@qa.mani.test`) | Control positivo de la variante 3b y camino Gateway de rgB6 | Borrar el usuario de Auth y sus filas al terminar (admin de Supabase o script de limpieza; no lo hace la colección) |
| Intento de registro en t1 con `tenant_id` de t2 en el cuerpo | Variante 3b | No debe crear nada en t2. Si crea algo, es el defecto y se conserva como evidencia |
| Objetos `intruso-*.pdf` en Storage | Casos N4, N5 y N6c del camino directo | La carpeta de limpieza de `mani-aislamiento` |

### A.5 Variables de entorno

Solo se nombran. Los valores se inyectan al ejecutar y nunca se versionan ni se pegan en chats.

| Variable | Uso |
|---|---|
| `url_gateway` | Base del Gateway de QA (todavía no existe un host QA) |
| `supabase_url` | Login por Supabase Auth (ADR-0027) y camino directo |
| `anon_key` | Cabecera `apikey` del login y del camino directo |
| `password` | Contraseña de las cuentas del seed (está en el seed; no se copia aquí) |
| `token_expirado` | Token real vencido, capturado en una corrida anterior |
| `jwt_secret_ajeno` | Clave cualquiera para firmar el token "con otra clave" de rgB5 |

### A.6 Orden para resembrar QA

Según `supabase/seed/README.md`:
1. `seed_qa_multitenant.sql`.
2. `poc-cfg12/20_seed_identidad.sql`.
3. `poc-cfg13/20_seed_storage.sql`.
4. `qa/storage/cargar_kyc.mjs`.
5. `verificar_aislamiento.sql`.
6. `database/verify/11-normalizacion-dominios.sql`.

El seed de CFG-04 borra todo lo que cuelga de sus dos tenants, así que los pasos 2 a 4 se repiten siempre después del 1.

Si CFG-23a (SCRUM-1103) cambia el modelo de identidad, esta matriz se revisa antes de ejecutar.

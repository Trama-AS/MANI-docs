# CFG-23a.1 — Inventario de políticas RLS que dependen de `auth.uid()`

- **Jira:** SCRUM-1195 (subtarea de CFG-23a, SCRUM-1103)
- **Autor:** Juan Sebastián Álvarez Rodríguez
- **Fecha:** 2026-10-17
- **Estado:** Para revisión
- **Insumo de:** [ADR-0032](../../adr/ADR-0032-identidad-de-servicio-en-base-de-datos.md) (CFG-23a.2) y [diseño del modelo](02-diseno-modelo-identidad.md) (CFG-23a.3)

## 1. Alcance y fuente

Inventario de las políticas RLS, las tablas sin RLS y las funciones `SECURITY DEFINER` que resuelven identidad con `auth.uid()`, y de **cómo se conecta cada servicio**, que es lo que decide si alguna de ellas se evalúa.

| Fuente | Versión revisada |
|---|---|
| Esquema vigente: `MANI-APIGateway/database/init/04-supabase-rls-and-functions.sql` y `database/migrations/001`–`008` | `main` @ `9874e93` |
| Serie viva según ADR-0030: `MANI-Node/db/migrations/0001` (en `develop`) y `0002`–`0004` (en PR) | ramas al 2026-10-17 |
| Código de acceso a datos: `MANI-Node/src/infrastructure`, `MANI-.NET/Infrastructure` | ramas al 2026-10-17 |

Es un inventario **del repositorio**. El catálogo real de QA no coincide con él: `tenant_isolation_solicitud` existe en QA (DD V2 §8.1) y no está en ninguna migración. La [consulta del anexo A](#anexo-a-consulta-para-confirmar-contra-el-catálogo-de-qa) confirma el estado real y debe correrse en QA antes de CFG-23b.

## 2. Hallazgo principal: ningún servicio pasa por RLS

El enunciado de CFG-23a («RLS deja de filtrar por `auth.uid()` cuando el llamador es un servicio») se queda corto. Con las credenciales actuales **las políticas no se evalúan en absoluto**: `service_role` y `postgres` tienen `BYPASSRLS`, así que da igual qué devuelva `auth.uid()`.

| Camino de datos | Cliente | Credencial | ¿Se evalúa RLS? |
|---|---|---|---|
| Core, repositorios Supabase (`usuario`, `aliado`, `aliado_categoria`, `categoria_servicio`, `tenant`, `documento_kyc`) | `@supabase/supabase-js` (`SupabaseClientFactory`) | `SUPABASE_SERVICE_ROLE_KEY` → rol `service_role` | **No** (`BYPASSRLS`) |
| Core, transacción de categorías del aliado (`TransactionalAliadoCategoriaRepository`) | `pg` (`PgPoolFactory`) | `DATABASE_URL` → rol `postgres` | **No** (`BYPASSRLS` en Supabase) |
| Core, documentos KYC en Storage (`SupabaseFileStorageService`) | supabase-js Storage | `service_role` | **No**: `kyc_isolation` no aplica |
| Dispatch, elegibilidad y aceptación (`PostgresAllyRepository`, `PostgresDispatchPublisher`) | Npgsql | `DATABASE_URL` → `postgres` | **No** |
| Rules | — | sin acceso a base de datos (ADR-0022) | No aplica |
| Flutter legado (`supabase_flutter`, en retiro por CFG-35/36) | PostgREST | `anon` + JWT del usuario → `authenticated` | **Sí**: es el único camino donde RLS opera hoy |

La migración 008 lo deja escrito: «Core Node escribe con la service role (que salta RLS)». Hoy la autorización por tenant en código es la **única** defensa para todo el tráfico de servicios, que es lo que ADR-0022 registró como KI-05.

Se verificó en PostgreSQL 16 con los mismos roles y funciones que Supabase ([PoC, caso L1](../../Entregas/PoC/PoC-CFG23a-identidad-servicio-rls/README.md)): `service_role` con claims del tenant T1 lee las filas de T1 y de T2.

## 3. Políticas vigentes en el repositorio

Quince políticas vigentes en el repositorio, una más que solo existe en QA y dos más en un PR. «Fuente del tenant» es de dónde sale el tenant que la política compara.

| # | Tabla | Política | Op. | `TO` | Predicado | Fuente del tenant | Fuente del usuario | Origen |
|---|---|---|---|---|---|---|---|---|
| 1 | `tenant` | Lectura pública de tenants | SELECT | public | `true` | — | — | init/04 |
| 2 | `categoria_servicio` | Lectura pública de categorias | SELECT | public | `true` | **ninguna**: todas las categorías de todos los tenants | — | init/04 |
| 3 | `usuario` | Usuarios pueden insertar su propio registro | INSERT | public | `auth.uid() = id` | ninguna | `auth.uid()` | init/04 |
| 4 | `usuario` | Usuarios pueden ver su propio registro | SELECT | public | `auth.uid() = id` | ninguna (implícita por el usuario) | `auth.uid()` | init/04 |
| 5 | `aliado` | Aliados pueden insertar su propio registro | INSERT | public | `auth.uid() = usuario_id` | **ninguna**: no comprueba `tenant_id` de la fila | `auth.uid()` | init/04 |
| 6 | `aliado` | Aliados pueden ver su propio perfil | SELECT | public | `auth.uid() = usuario_id` | ninguna | `auth.uid()` | init/04 |
| 7 | `documento_kyc` | Aliados pueden subir sus documentos KYC | INSERT | public | **`true`** | ninguna | ninguna | init/04 |
| 8 | `documento_kyc` | Aliados pueden consultar sus documentos KYC | SELECT | public | **`true`** | ninguna | ninguna | init/04 |
| 9 | `aliado_categoria` | Aliado lee sus propias categorias | SELECT | public | `aliado_id IN (aliado WHERE usuario_id = auth.uid())` | implícita por el aliado | `auth.uid()` | 004 (retira las dos `true` de init/04) |
| 10–13 | `storage.objects` (bucket `solicitudes`) | solicitudes_subir/actualizar/borrar/leer_propias | I/U/D/S | authenticated | `foldername[1] = auth.uid()` | **ninguna** | `auth.uid()` | 006 |
| 14 | `storage.objects` (bucket `kyc-documentos`) | `kyc_isolation` | ALL | authenticated | carpeta = tenant del claim **y** (carpeta = `auth.uid()` **o** rol `admin_tenant`) | **claim** `app_metadata.tenant_id` | `auth.uid()` | 007 |
| 15 | `aliado_ausencia` | Aliado lee sus propias ausencias | SELECT | public | `tenant_id` = claim **y** aliado propio | **claim** | `auth.uid()` | 008 |
| 16 | `solicitud` | `tenant_isolation_solicitud` | ALL | **public** | `tenant_id` = claim | claim | — | **no versionada**: solo en QA (DD V2 §8.1) |
| 17–18 | `documento_legal`, `consentimiento_usuario` | lectura del tenant o globales; consentimientos propios | SELECT | public | `tenant_id IS NULL OR` = claim (y `usuario_id = auth.uid()`) | claim | `auth.uid()` | `MANI-Node` 0004, **en PR** (SCRUM-856) |

Lectura del cuadro:

- **Once políticas (3–6, 9–13 y parte de 14–15) resuelven al usuario con `auth.uid()`.** Las 3–6 y 9–13 no comparan `tenant_id`: el aislamiento por tenant es implícito («es mi fila»), lo que basta para el usuario final pero no ofrece nada a un llamador que actúa en nombre de un tenant.
- **Solo 14 y 15 (y 16 en QA, 17–18 en PR) toman el tenant del claim**, que es el patrón al que hay que llegar. SCRUM-1334 reporta «0 políticas»; buscó `request.jwt.claims`/`current_setting`, pero estas leen el claim por `auth.jwt()`, que lee ese mismo GUC.
- **7 y 8 están abiertas**: con la `SUPABASE_ANON_KEY` del bundle (CFG-36) cualquiera lee e inserta filas de `documento_kyc` de cualquier tenant (rutas de Storage incluidas, que son datos de habeas data). Comprobado en la PoC, caso L2. Es independiente del llamador servicio y es la exposición más grave del inventario.
- **Ninguna política restringe `TO`** salvo las de Storage: las demás valen para `public`, incluido `anon`.

## 4. Tablas sin RLS

Veinte tablas de negocio, todas con `tenant_id` (salvo `tenant` y `zona`). Con los *default privileges* de Supabase (`GRANT ALL` sobre `public` a `anon` y `authenticated`), **una tabla sin RLS es legible y escribible por PostgREST con la clave anónima.**

| RLS habilitada en el repositorio | Con políticas | Sin políticas (deniega a todo rol sin `BYPASSRLS`) |
|---|---|---|
| Sí (9) | `tenant`, `categoria_servicio`, `usuario`, `aliado`, `aliado_categoria`, `documento_kyc`, `aliado_ausencia` | `solicitud_rechazo` (005), `solicitud_foto` (006) |

| RLS **no** habilitada en el repositorio (11) |
|---|
| `zona`, `cliente`, `sitio`, `tarifa_referencia`, `cobertura_aliado`, `solicitud`\*, `cotizacion`, `mensaje`, `evento_servicio`, `calificacion`, `notificacion` |

\* `solicitud` tiene RLS en QA por la política no versionada 16.

Ninguna tabla tiene `FORCE ROW LEVEL SECURITY`: el dueño (`postgres`) la salta aunque perdiera `BYPASSRLS`.

## 5. Funciones `SECURITY DEFINER` que derivan identidad de `auth.uid()`

`SECURITY DEFINER` omite RLS por diseño: estas funciones hacen su propio filtrado tomando tenant y usuario de `auth.uid()` contra `usuario`. Son la lógica PL/pgSQL que ADR-0022 manda retirar a medida que las historias `-M2` la reemplazan. **Los servicios no las invocan**; siguen concedidas a `authenticated`, es decir, al camino Flutter legado.

| Migración | Funciones | Concedida a |
|---|---|---|
| init/04 | `registrar_aliado_persona_natural(p_usuario_id, p_tenant_id, …)` | **`anon`**, authenticated, service_role |
| 002 | `_ver_tenant_admin_actual`, `listar_aliados_verificacion`, `obtener_aliado_verificacion`, `resolver_verificacion_aliado` | authenticated |
| 003 | `_cat_tenant_admin_actual`, `listar_categorias_admin`, `crear_categoria_servicio` | authenticated |
| 004 | `_cat_aliado_actual`, `listar_categorias_tenant`, `obtener_mis_categorias`, `guardar_mis_categorias` (+ trigger `_cat_validar_tenant_aliado_categoria`) | authenticated |
| 005 | `_sol_aliado_actual`, `listar_solicitudes_aliado`, `aceptar_solicitud`, `rechazar_solicitud` | authenticated |
| 006 | `_solc_cliente_actual`, `listar_categorias_cliente`, `listar_mis_sitios`, `buscar_zonas_cliente`, `crear_solicitud` | authenticated |

`registrar_aliado_persona_natural` es la excepción peligrosa: concedida a `anon` y con `p_tenant_id` y `p_usuario_id` como **parámetros**, permite a cualquiera con la clave anónima crear usuarios y aliados en cualquier tenant. Contradice la regla anti-spoofing de las propias migraciones («ninguna función recibe tenant_id»).

## 6. Conciliación con SCRUM-1334

| SCRUM-1334 dice | El inventario encuentra |
|---|---|
| 28 políticas usan `auth.uid()` | 28 **ocurrencias**: 11 en políticas, 10 en funciones `SECURITY DEFINER`, 7 en comentarios |
| 0 políticas toman el tenant del claim | 2 vigentes (`kyc_isolation`, ausencias), 1 en QA sin versionar, 2 en PR |
| `auth.uid()` deja de filtrar con el servicio | Peor: con `service_role`/`postgres` **no se evalúa ninguna política** |
| — | No registradas: `documento_kyc` abierta a `anon` (políticas 7–8), `registrar_aliado_persona_natural` concedida a `anon`, 11 tablas sin RLS expuestas a la clave anónima |

Se propone actualizar SCRUM-1334 con estos datos y abrir defectos aparte para las tres exposiciones no registradas: no dependen del modelo de identidad y pueden cerrarse antes de CFG-23b.

## Anexo A. Consulta para confirmar contra el catálogo de QA

Solo lectura; no expone valores. Correrla en el SQL Editor de QA y adjuntar el resultado a CFG-23b.

```sql
-- 1. Políticas reales
SELECT schemaname, tablename, policyname, cmd, roles, qual, with_check
FROM pg_policies WHERE schemaname IN ('public', 'storage') ORDER BY 1, 2, 3;

-- 2. RLS por tabla
SELECT c.relname, c.relrowsecurity AS rls, c.relforcerowsecurity AS force_rls
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relkind = 'r' ORDER BY 1;

-- 3. Roles con los que conectan los servicios
SELECT rolname, rolbypassrls, rolsuper FROM pg_roles
WHERE rolname IN ('postgres', 'service_role', 'authenticated', 'anon') ORDER BY 1;

-- 4. Tablas sin RLS a las que anon puede escribir
SELECT c.relname FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relkind = 'r' AND NOT c.relrowsecurity
  AND has_table_privilege('anon', c.oid, 'INSERT') ORDER BY 1;

-- 5. Funciones SECURITY DEFINER ejecutables por anon
SELECT p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public' AND p.prosecdef AND has_function_privilege('anon', p.oid, 'EXECUTE');
```

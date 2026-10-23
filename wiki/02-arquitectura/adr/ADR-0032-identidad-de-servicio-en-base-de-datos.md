# ADR-0032 — Identidad en base de datos cuando el llamador es un servicio

- **Estado:** Propuesto (revisión de arquitectura aprobada en PR #39; pendiente de acta de Mesa de Arquitectura, CFG-23a.4)
- **Decisión de:** persistencia y seguridad multi-tenant
- **Autor:** Juan Sebastián Álvarez Rodríguez
- **Revisor:** Sara Albarracín Niño (revisión aprobada en `MANI-docs` PR #39, conforme a ADR-0003)
- **Fecha:** 2026-10-17
- **Jira:** CFG-23a (SCRUM-1103), subtarea SCRUM-1196
- **Relacionado con:** ADR-0012, ADR-0015, ADR-0016, ADR-0018, ADR-0022 (KI-05), ADR-0029, ADR-0030, ADR-0031
- **Defectos que cierra junto con CFG-23b/23c:** SCRUM-1334 (BUG-SEC-02)
- **Evidencia:** [inventario CFG-23a.1](../CFG-23a/01-inventario-rls.md), [diseño CFG-23a.3](../CFG-23a/02-diseno-modelo-identidad.md), [PoC](../../../qa/PoC/PoC-CFG23a-identidad-servicio-rls/README.md)

---

## Contexto

ADR-0012 adopta RLS por `tenant_id` como defensa en profundidad, y ADR-0022 convierte a los servicios en la única frontera de acceso a datos. Las políticas vigentes se escribieron para el cliente Flutter que llamaba a PostgREST con el JWT del usuario: identifican al usuario con `auth.uid()` y, en su mayoría, ni siquiera comparan `tenant_id`.

El inventario de CFG-23a.1 encontró que el problema es mayor que el que nombra la tarea:

1. **Con las credenciales actuales ninguna política se evalúa.** Core usa `service_role` (supabase-js) y `postgres` (`pg`), y Dispatch usa `postgres` (Npgsql). Los dos roles tienen `BYPASSRLS`. Hoy la autorización por tenant en código es la única defensa del tráfico de servicios (KI-05).
2. **No existe un punto único de donde leer el tenant.** Once políticas usan `auth.uid()`, dos leen el claim con `auth.jwt()` y una más, solo en QA, sin versionar.
3. **Hay exposiciones independientes del llamador:** `documento_kyc` tiene `USING (true)` para `anon`, `registrar_aliado_persona_natural` está concedida a `anon` y recibe el tenant por parámetro, y once tablas no tienen RLS.

Hay que decidir de dónde toma cada política el tenant y el usuario cuando quien consulta es Core o Dispatch, sin perder el aislamiento del camino PostgREST mientras siga existiendo.

## Alternativas

1. **Mantener `service_role`/`postgres` y confiar solo en la autorización de los servicios.** Es el estado actual. Descartada: deja RLS como documentación y no como defensa, contra ADR-0012. Un `WHERE tenant_id` olvidado se convierte en una fuga directa.
2. **Reenviar el JWT del usuario y acceder solo por PostgREST.** El servicio crea el cliente supabase-js con el `Authorization` del usuario, y PostgREST establece `role` y `request.jwt.claims`, así que las políticas operan sin cambios en el motor. Descartada **como mecanismo único** por cuatro razones:
   - no cubre las transacciones `pg` (categorías del aliado, SCRUM-1071) ni el `UPDATE` condicional de Dispatch en Npgsql (ADR-0016);
   - no hay JWT en los flujos pre-autenticación (registro, ADR-0018) ni en los consumidores asíncronos (ADR-0029);
   - ataría a Rules y Dispatch a PostgREST.

   Se **admite como adaptador transitorio** de Core, porque produce exactamente el mismo estado de sesión que la alternativa elegida.
3. **Un GUC propio por servicio (`SET LOCAL app.tenant_id = …`).** Descartada: crea dos fuentes de verdad, el claim para PostgREST/Storage/Realtime y el GUC para servicios. Cada política tendría que contemplar ambas y `auth.uid()` seguiría vacío para los servicios.
4. **Base o esquema por tenant.** Ya descartada en ADR-0012 por sobrecarga operativa.
5. **Roles de servicio sin `BYPASSRLS` que establecen, por transacción, los claims verificados en `request.jwt.claims`; las políticas leen solo de ahí.** **Elegida.**

## Decisión

### 1. Una sola fuente de identidad dentro del motor

Toda política toma tenant, usuario y rol **exclusivamente** de `request.jwt.claims`, a través de tres funciones del esquema `app`:

| Función | Devuelve | Si falta o es inválido |
|---|---|---|
| `app.tenant_id()` | `app_metadata.tenant_id::uuid` | `NULL` |
| `app.user_id()` | `sub::uuid` (equivale a `auth.uid()`) | `NULL` |
| `app.user_role()` | `lower(app_metadata.user_role)` | `NULL` |

Es el mismo GUC que PostgREST establece al recibir un JWT y que `auth.uid()`/`auth.jwt()` ya leen. Una política escrita así funciona igual para un servicio y para PostgREST. `NULL` nunca iguala a un `tenant_id`, de modo que la ausencia de contexto deniega en vez de abrir.

Ninguna política nueva usa `auth.uid()`, `auth.jwt()`, un parámetro de función ni una columna enviada por el cliente como fuente de tenant.

### 2. De dónde lo toma el servicio, por tipo de flujo

El servicio nunca toma el tenant del cuerpo, de la ruta ni de la consulta (ADR-0018, ADR-0030 §2).

| Flujo | `tenant_id` | `user_id` | `user_role` |
|---|---|---|---|
| Petición autenticada vía Gateway | `X-Tenant-Id` (claim verificado por el Gateway, ADR-0031) o la verificación propia del JWT en Core | `X-User-Id` / `sub` | `X-User-Role` / `app_metadata.user_role` |
| Llamada interna entre servicios (patrón ADR-0030 §2) | `X-Tenant-Id` que reenvía el llamador, tomado de su claim verificado | `X-User-Id` | `X-User-Role` |
| Pre-autenticación (registro de aliado o cliente, ADR-0018) | tenant resuelto por Core desde `X-Tenant-Slug` | id recién creado en Supabase Auth; se fija **después** de crear la identidad y **antes** de escribir | el rol que se registra |
| Asíncrono (consumidor Kafka, ADR-0029) | tenant del evento, que el productor tomó de su claim | usuario del evento, si lo hay | `servicio`: no satisface políticas de propiedad |

No existe un contexto de plataforma o multi-tenant en tiempo de ejecución. Una operación que necesite ver varios tenants no se resuelve con este modelo y exige un ADR propio.

### 3. Un rol de base de datos por servicio

- `mani_core_svc` y `mani_dispatch_svc`: `LOGIN`, `NOBYPASSRLS`, no superusuario, **no dueños** de las tablas y **no miembros de `authenticated`**, para no heredar el `GRANT ALL` de los *default privileges* de Supabase.
- Cada rol recibe `GRANT` solo sobre las tablas de su dominio según ADR-0022/0030 (conciliado con [`ModeloDatos.md` §6.3](../ModeloDatos.md), que documenta además los roles operativos `mani_relay`, `mani_migrator` y `mani_dw_reader`). Así la frontera de datos queda impuesta también por el motor: Dispatch recibe `permission denied` en `notificacion`.
- **Alcance de Rules Service (`mani_rules_svc`):** En el incremento actual (US-03.1.1-M6, `MANI-Java`), las reglas evaluables y los *overrides* por tenant (`mani.rules.category.tenants.<tenantId>.*`) residen en la configuración del servicio (`application.yml` / variables de entorno) y Rules **no se conecta a PostgreSQL** (ADR-0022); Core persiste `tarifa_referencia` y consume a Rules por HTTP (ADR-0030 §2). Por tanto, `mani_rules_svc` no se crea en CFG-23b. Si en un incremento futuro se decide persistir los *overrides* o el tarifario directamente desde Rules en el esquema `reglas` (`ModeloDatos.md` §6.3), deberá enmendarse este ADR para habilitar `mani_rules_svc` con las mismas restricciones (`NOBYPASSRLS`, `app.set_context` obligatorio y `GRANT` exclusivo sobre `reglas`).
- Ambos roles activos reciben `USAGE` sobre el esquema `auth` y `EXECUTE` sobre `auth.uid()`/`auth.jwt()`, que las políticas evalúan con el rol del llamador.
- **Dependencia operativa con DevOps:** Las contraseñas son secretos por ambiente (`/opt/mani/.env.{dev,qa,prod}`, ADR-0031 §5) y nunca se versionan. La migración de CFG-23b crea los roles con `NOLOGIN`, y operaciones (DevOps) les asigna `LOGIN PASSWORD` y actualiza el `DATABASE_URL` de cada servicio fuera de git antes de activar el paso 5 en QA/PROD.

### 4. El contexto se establece por transacción y solo con `app.set_context`

- Toda operación de un servicio sobre la base corre dentro de una transacción explícita.
- Su **primera sentencia** es `SELECT app.set_context(tenant_id, user_id, user_role)`, que escribe `request.jwt.claims` con `is_local = true` y rechaza un contexto sin tenant (`MANI-RLS-400`).
- Quedan **prohibidos** en código de servicio `set_config('request.jwt.claims', …, false)`, `SET` sin `LOCAL` y cualquier asignación de sesión. Con un pool, la siguiente petición heredaría el tenant anterior (control negativo P2 de la PoC).
- `app.set_context` solo es ejecutable por los roles de servicio, nunca por `anon` ni `authenticated`.
- El mecanismo es compatible con un pool en modo transacción (Supavisor, puerto 6543). Fuera de una transacción el contexto dura una sola sentencia y la siguiente ve 0 filas, lo que es falla cerrada y no fuga.

### 5. Forma de las políticas

- `ENABLE` **y** `FORCE ROW LEVEL SECURITY` en toda tabla con `tenant_id`, para que ni el dueño la salte.
- `TO` explícito con los roles que acceden a la tabla, **nunca `public`**.
- Patrón base: `USING (tenant_id = app.tenant_id()) WITH CHECK (tenant_id = app.tenant_id())`.
- Donde el dominio lo exige se agrega propiedad o rol. Por ejemplo:
  - KYC: el propio aliado o el `admin_tenant` del mismo tenant (DD V2 §8.2);
  - aceptar una solicitud: rol `aliado` (corrige H-02/KI-13).
- Toda tabla nueva nace con esto en la misma migración (ADR-0030).

### 6. Uso restringido de las credenciales con `BYPASSRLS`

| Credencial | Uso permitido | Prohibido |
|---|---|---|
| `postgres` | migraciones de `MANI-Node/db/migrations` y operación auditada | tráfico de aplicación |
| `service_role` (`SUPABASE_SERVICE_ROLE_KEY`) | API de administración de Supabase Auth (crear usuario) y Storage | `.from()` / `.rpc()` sobre tablas |

En Storage, Core sigue usando `service_role` porque Storage no ofrece otra vía de servidor. Toda ruta de objeto debe empezar por el tenant del contexto (`{tenant_id}/{user_id}/…`), y este es el riesgo residual que se acepta y que CFG-23c debe probar explícitamente en el caso 6 intentando acceder a una ruta de Storage de **otro tenant** (`{T2}/…`), no solo de otro aliado del mismo tenant.

### 7. Camino PostgREST mientras exista

Flutter legado, y Core si usa el adaptador transitorio de la alternativa 2, entra como `authenticated` con su JWT. Las mismas políticas, con `authenticated` en su `TO`, le aplican sin una rama aparte (PoC P6).

### 8. Exposiciones que no esperan a CFG-23b

Por ser independientes del modelo, se corrigen en una migración previa (`MANI-Node/db/migrations/0005_cerrar_exposiciones_rls.sql` y `db/verify/0005_verificar_exposiciones.sql`, entregada en `MANI-Node` PR #28 bajo SCRUM-1334):

1. revocar `EXECUTE` de `registrar_aliado_persona_natural` y `registrar_aliado_empresa` a `PUBLIC`, `anon` y `authenticated`;
2. eliminar las políticas `USING (true)` / `WITH CHECK (true)` de `documento_kyc`;
3. habilitar RLS en las once tablas que no la tienen (conservando lectura pública únicamente en el catálogo geográfico global `zona`). Sin políticas, deniegan a `anon`/`authenticated` y no rompen nada en uso:
   - los servicios siguen con `BYPASSRLS` hasta CFG-23b;
   - Flutter (`develop` al 2026-10-17) no hace `.from()` ni Realtime sobre tablas: solo invoca `listar_aliados_verificacion`, `listar_categorias_admin` y `listar_solicitudes_aliado`, que son `SECURITY DEFINER`.

## Justificación

La alternativa 5 es la única que devuelve a RLS su papel de defensa en profundidad para **todos** los caminos de datos, PostgREST, `pg` y Npgsql, con una sola definición de política. Reutiliza el GUC que Supabase ya lee, así que las políticas vigentes de claim (`kyc_isolation`, ausencias) y el patrón V2 de DD V2 §8.1 encajan sin reescribirse. Falla cerrado por construcción. Y convierte la frontera de datos de ADR-0030 en algo que el motor verifica, en vez de algo que solo se revisa en un PR.

La PoC lo verificó en PostgreSQL 16 con roles y funciones equivalentes a Supabase: aísla los seis casos de Políticas DevOps §13.4, deniega sin contexto o con claims corruptos, no filtra contexto entre transacciones de un pool y reproduce la fuga actual como línea base.

## Consecuencias

### Positivas

- RLS vuelve a operar para el tráfico de servicios. Un filtro por tenant olvidado en código lo detiene el motor, que es el supuesto de ADR-0015/QAS-01.
- Una política única para servicios y PostgREST, y `auth.uid()` vuelve a funcionar dentro de una transacción de servicio.
- La frontera de datos entre servicios (ADR-0030) queda impuesta por `GRANT`.
- Se corrige H-02/KI-13 en la política de aceptación sin tocar la exclusión concurrente (ADR-0016).

### Negativas

- **Refactor en Core:** los repositorios que hoy usan `.from()` con `service_role` deben pasar a `pg` con transacción o al adaptador transitorio con el JWT reenviado. Es trabajo de CFG-23b y de las historias `-M2` en curso.
- **Disciplina transaccional:** cada acceso a datos abre una transacción y fija contexto. Mitigación: un único helper por servicio (`withTenantContext`) y una regla de revisión que rechace accesos fuera de él.
- **Latencia:** una sentencia adicional por transacción. Debe medirse en la ruta de QAS-03 (p95 ≤ 500 ms).
- **Operación:** dos roles y sus secretos por ambiente; Storage sigue con `service_role` como riesgo residual acotado.
- **Convivencia:** las funciones `SECURITY DEFINER` heredadas siguen omitiendo RLS hasta que ADR-0022 las retire.

## Verificación

- CFG-23c ejecuta en QA los seis casos de Políticas DevOps §13.4 a través del Gateway (incluyendo en el caso 6 el intento de acceso a una ruta de Storage `{T2}/…` de otro tenant) **y** una verificación en el motor: con el rol de servicio y un tenant equivocado, la consulta devuelve 0 filas, no solo un rechazo previo del servicio (criterio de cierre de SCRUM-1334).
- La consulta del anexo A del inventario, corrida en QA, no devuelve tablas con `tenant_id` sin RLS, ni políticas `TO public` de aislamiento, ni funciones `SECURITY DEFINER` ejecutables por `anon`.

## Disenso registrado

Sin disenso en la revisión de arquitectura previa (PR #39 aprobado por Sara Albarracín Niño con tres observaciones incorporadas en §3, §6 y §8); pendiente de ratificación en el acta de Mesa de Arquitectura (CFG-23a.4).

## Condición de revisión

Revisar si se adopta una base por servicio (revisaría ADR-0012 y este ADR); si la medición de QAS-03 muestra un incumplimiento atribuible al contexto por transacción; si Supabase ofrece otro mecanismo de identidad para conexiones de servidor; o si aparece un caso de uso legítimo multi-tenant en tiempo de ejecución.

## Trazabilidad

| Elemento | Referencia |
|---|---|
| ADR relacionados | ADR-0012, ADR-0015, ADR-0016, ADR-0018, ADR-0022 (KI-05), ADR-0029, ADR-0030, ADR-0031 |
| Documentos que precisa | DD V2 §8.1 y §8.2, SDD QAS-01, Políticas DevOps §13.4 |
| Tareas | CFG-23a (SCRUM-1103) y subtareas SCRUM-1195 a SCRUM-1198 |
| Tareas que desbloquea | CFG-23b (SCRUM-1104), CFG-23c (SCRUM-1105) |
| Defectos | SCRUM-1334 (BUG-SEC-02), SCRUM-1333 (JWT sin verificar firma) |
| Requisitos | RNF-01, QAS-01 |

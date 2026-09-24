# SCRUM-971 — Verificacion de terreno de identidad y claims de tenant

- **Ticket padre:** SCRUM-929 (CFG-12) — PoC de identidad y propagacion de claims
- **Ejecutado:** 2026-09-22, SQL Editor del proyecto QA `hpsxdotaizzclkeufzct` (MANI-QA)
- **Scripts que produjeron esta salida:** `supabase/poc-cfg12/00_verificar_terreno.sql`
  (version legible, bloque por bloque) y `supabase/poc-cfg12/01_resumen_terreno.sql`
  (version operativa, una sola consulta) del repositorio de codigo
  `Trama-AS/MANI-Flutter`, rama `feature/SCRUM-929-poc-claims-tenant`. Por ADR-0001 los
  scripts ejecutables viven alla y este informe aqui (ADR-0007).
- **Rol de ejecucion:** `postgres` (dashboard) — bypassa RLS, correcto para introspeccion
- **Motor:** PostgreSQL 17.6 · `read committed` · `max_connections = 60` · pgcrypto 1.3

## Veredicto

**La PoC puede proceder, pero no como estaba planteada.** El ambiente sirve para medir
—RLS esta vivo y con politicas, a diferencia de lo que encontro SCRUM-1039— y la tabla
`usuario` tiene lo que el hook necesita leer.

Hay **un bloqueante** que obliga a ampliar el alcance de la Fase 1, **dos subtareas que
cambian de naturaleza** porque el modelo o el ambiente no admiten lo que pedian, y
**cuatro hallazgos** sobre el estado del aislamiento que exceden a CFG-12.

## Lo que habilita la PoC

| Verificacion | Resultado | Consecuencia |
| --- | --- | --- |
| `usuario.tenant_id` | `uuid`, NULLABLE, FK a `tenant` ON DELETE CASCADE | El hook tiene de donde leer el tenant. Nullable ademas hace nativo el caso borde "usuario sin tenant" |
| `usuario.rol` | `text`, NOT NULL | El hook tiene de donde leer el rol |
| `usuario.id` = `auth.users.id` | 57 de 57 usuarios de Auth tienen fila en `public.usuario` | El hook puede resolver por `event->>'user_id'`. Sin esta correspondencia no tendria por donde entrar |
| Hook ya existente | 0 filas en `pg_proc` | La Fase 1 se escribe desde cero, no hay duplicacion |
| RLS sobre `public` | 18 tablas, 18 politicas, **ninguna con RLS y cero politicas** | El ambiente no esta en el estado que encontro SCRUM-1039. La suite de acceso cruzado puede dar un verde con significado |
| Predicado de las politicas | `tenant_id = ((auth.jwt() -> 'app_metadata') ->> 'tenant_id')::uuid` | Es literalmente el de ADR-0018. Lo que la PoC mide es lo que el ADR decidio |
| Poblacion | 3 tenants: `acme-servicios` (3 usuarios), `nova-mantenimiento` (3), `poc-concurrencia` (51) | Los 2 tenants de CFG-04 alcanzan para la prueba cruzada. El de CFG-09 no estorba |
| `pgcrypto` | instalada, 1.3 | El seed de la Fase 2 puede crear usuarios de Auth con `crypt()` |

## B1 — Bloqueante: el hook no puede leer `usuario`

Es el hallazgo central de esta verificacion, y **son dos problemas encadenados**. GoTrue
invoca el Custom Access Token Hook como `supabase_auth_admin`, un rol distinto de
`authenticated` y de `postgres`.

**Primero, faltan los privilegios:**

```
has_schema_privilege('supabase_auth_admin', 'public', 'USAGE')          = true
has_table_privilege ('supabase_auth_admin', 'public.usuario', 'SELECT') = false
has_table_privilege ('supabase_auth_admin', 'public.tenant',  'SELECT') = false
```

**Segundo, y esto no lo arregla un `GRANT`:** `supabase_auth_admin` tiene
`rolbypassrls = false`, y `usuario` tiene RLS activo con la politica
`tenant_isolation_usuario`, `cmd = ALL`, `roles = {public}`:

```sql
USING (tenant_id = ((auth.jwt() -> 'app_metadata') ->> 'tenant_id')::uuid)
```

Dentro del hook **todavia no existe el JWT**: el hook corre precisamente para construirlo.
`auth.jwt()` devuelve null, la comparacion se evalua a `NULL`, `NULL` no es `true`, y la
funcion lee cero filas.

**Por que importa mas de lo que parece.** El hook no fallaria. Devolveria claims vacios y
GoTrue emitiria un token perfectamente valido y firmado, sin `tenant_id`. Contra las
politicas de ADR-0018 ese token no ve nada —falla cerrado, que es lo correcto— pero el
sintoma seria "la app no muestra datos", no "el hook esta roto". Un fallo silencioso en la
capa de identidad es exactamente el tipo de problema que SCRUM-1039 tardo meses en
descubrir.

**Consecuencia para la Fase 1.** El script del hook debe incluir, ademas de la funcion:

```sql
GRANT USAGE ON SCHEMA public TO supabase_auth_admin;   -- ya concedido
GRANT SELECT ON public.usuario TO supabase_auth_admin;
CREATE POLICY hook_lee_usuario ON public.usuario
  FOR SELECT TO supabase_auth_admin USING (true);
```

Esa politica le da a `supabase_auth_admin` lectura de **todas** las filas de `usuario`,
cruzando tenants. Es inevitable —el hook tiene que resolver el tenant de cualquier usuario
que se autentique, antes de saber cual es— y es el patron que la documentacion de Supabase
prescribe, pero **amplia superficie y debe quedar declarado**, no escondido en el script.
El rol no es alcanzable por la API: `anon` y `authenticated` no pueden asumirlo, y la
funcion se revoca explicitamente para ellos.

## Subtareas que cambian de naturaleza

### SCRUM-973, caso "multiples roles" — no es medible contra este modelo

`usuario` tiene un solo `tenant_id`. No hay tabla de membresia: las unicas tablas con
`usuario_id` y `tenant_id` a la vez son `aliado`, `cliente` y `notificacion`, que son
perfiles y notificaciones, no vinculos de pertenencia. Empiricamente, cero usuarios tienen
mas de un tenant.

Un usuario pertenece a exactamente un tenant, y el hook no puede devolver algo ambiguo
porque no hay ambiguedad que resolver. El caso borde **se declara como limitacion del
modelo de datos**, no como caso de prueba fallido.

No contradice a ADR-0018: el ADR ya admite como consecuencia negativa que "en caso de que
un usuario pertenezca a mas de un tenant (ej. superadministrador o aliado multi-empresa),
el cambio de contexto de tenant requiere refrescar o reexpedir explicitamente el token".
Lo que esta verificacion agrega es que **hoy ese escenario ni siquiera es representable**:
antes de poder reexpedir el token habria que poder modelar la doble pertenencia. Si el
producto lo va a necesitar (RF de superadministrador), requiere cambio de esquema y ticket
propio.

### SCRUM-975, caso 6 de ADR-0015 — no es ejecutable

El sexto caso de acceso cruzado que enumera
`Project/Documento_Herramientas_Politicas_Lineamientos_V2.md` seccion 4.3.3 es el
"aislamiento de documentos KYC en Supabase Storage" (ADR-0013). En QA:

| Verificacion | Resultado |
| --- | --- |
| `storage.buckets` | **0 buckets** |
| Politicas sobre `storage.objects` | **0** |
| Filas en `public.documento_kyc` | **0** |

La tabla `documento_kyc` existe y tiene su politica de aislamiento por tenant, pero no hay
nada en Storage que aislar. **ADR-0013 no esta implementado en QA.** El caso 6 se declara
no ejecutable, con esta justificacion, en vez de omitirse o de sustituirse por una prueba
sobre la tabla —que probaria otra cosa: el aislamiento de la fila, no el del objeto.

Sembrar el bucket desde esta PoC seria implementar ADR-0013 de contrabando. Requiere
ticket propio, con DevOps.

## Hallazgos sobre el estado del aislamiento

Exceden a CFG-12. Se declaran porque condicionan la interpretacion de sus resultados.

### H-01 — `with_check` ausente en 17 de 18 politicas

Todas las politicas `tenant_isolation_*` tienen `with_check = NULL`. La unica excepcion es
`tenant_isolation_poc_log`, escrita por CFG-09.

Con `cmd = ALL` y sin `WITH CHECK`, Postgres reutiliza la expresion de `USING` para validar
las filas de `INSERT` y `UPDATE`. **Funciona**, pero depende de un comportamiento implicito
del motor en vez de una declaracion explicita. SCRUM-1039 dejo este punto abierto —
"evaluar anhadir `WITH CHECK` a las politicas" — y sigue abierto. La Fase 5 de esta PoC lo
comprueba empiricamente con un caso de insercion cruzada, en vez de suponerlo.

### H-02 — Ninguna politica distingue rol ni propietario

Las 18 politicas tienen `roles = {public}`. El aislamiento es **solo por tenant**:
cualquier usuario autenticado de un tenant puede leer y escribir cualquier fila de ese
tenant, sin importar su rol ni si la fila le pertenece.

CFG-09 ya lo habia levantado sobre `solicitud` (hallazgo H-02 de PoC-001, donde un
`cliente` podia autoasignarse una solicitud). Esta verificacion muestra que **no es un
problema de esa tabla: es el diseño de las 15**. Un `cliente` puede modificar el perfil de
un `aliado` de su tenant, o leer los documentos KYC de otro. `DD-MANI.md` restringe
operaciones por rol; la base no lo impone en ninguna parte.

RNF-01 habla de aislamiento **entre** tenants, y eso si se cumple. La autorizacion
**dentro** del tenant es una capa que no existe. Requiere ticket propio y probablemente
una decision de arquitectura sobre donde vive esa autorizacion.

### H-03 — La desviacion de `tenant` y `zona` sigue sin aprobarse

Ambas tienen politica `FOR SELECT USING (true)` mas escritura revocada, en vez de RLS
apagado como manda `Product/DDL_MANI.sql`. Es la desviacion que SCRUM-1039 introdujo
deliberadamente —apagar RLS en el esquema `public` de Supabase deja la tabla escribible
con la anon key, que viaja embebida en el cliente Flutter— y que dejo **pendiente de
aprobacion del Backend Lead** por desviarse de ADR-0012. Sigue pendiente.

### H-04 — Las politicas RLS no estan versionadas, y ahora hay una cadena que las omite

Las 18 politicas existen **solo en la base de QA**. Se aplicaron a mano al cerrar
SCRUM-1039, que dejo como pendiente explicito "versionar `aplicar_rls_qa.sql` y
`revertir_rls_qa.sql` en el repo que corresponda". No ocurrio.

Entre tanto, el commit `948bebb` de `MANI-Flutter` introdujo `database/migrations/` como
cadena de migraciones versionadas que —segun su propio README— "se ejecuta de forma
secuencial en todos los ambientes (DEV, QA y PROD)", con un paso de CI que la aplica
automaticamente. **`001_initial_schema.sql` no contiene ni un `CREATE POLICY` ni un
`ENABLE ROW LEVEL SECURITY`.**

Reconstruir cualquier ambiente desde esa cadena produce el esquema sin aislamiento: el
estado exacto que SCRUM-1039 clasifico como "RNF-01 no implementado". El riesgo que ese
ticket identifico —"no existe verificacion posterior a la aplicacion del DDL"— no solo
sigue abierto, ahora tiene un mecanismo automatizado que lo puede materializar.

**Dato adicional:** `public.schema_migrations` **no existe en QA**. El paso de CI la crea
con `CREATE TABLE IF NOT EXISTS` en su primer push, asi que nunca ha corrido contra ese
ambiente. La cadena de migraciones esta escrita pero no ha tocado QA todavia. Eso da
margen para corregirla antes de que aplique, en vez de despues.

### H-05 — `usuario.rol` es texto libre

No hay `CHECK` sobre `rol` ni sobre `estado`. Es la misma deriva que SCRUM-959 documento
para `solicitud.estado` (deriva D2 de CFG-09): la maquina de estados y el vocabulario de
roles viven en el codigo, no en la base. Para esta PoC importa porque **el hook copiara al
JWT el valor que encuentre**, sea cual sea. Si una fila tiene `rol = 'Aliado'` o
`rol = 'aliadoo'`, el claim sale con esa cadena y las politicas que comparen contra un
literal fallaran en silencio.

## Estado del ambiente, para el encabezado del informe final

| Dato | Valor |
| --- | --- |
| Motor | PostgreSQL 17.6, `read committed`, `max_connections = 60` |
| Extensiones | `pgcrypto` 1.3, `uuid-ossp` 1.1, `pg_stat_statements` 1.11, `supabase_vault` 0.3.1 |
| Usuarios en `auth.users` | 57 (6 de CFG-04, 51 de CFG-09) |
| Tenants | 3 |
| Tablas en `public` | 18 (17 del esquema + `poc_asignacion_log` de CFG-09) |
| Firma de los JWT | ES256, JWKS publico, `kid` `a069a215-25f2-4958-8b90-ef5b289a025a` |
| `schema_migrations` | no existe |

## Siguiente paso

Fase 1 — `supabase/poc-cfg12/10_hook_claims_tenant.sql`, ampliada para resolver B1: la
funcion del hook mas el `GRANT` y la politica de lectura para `supabase_auth_admin`, con
la ampliacion de superficie declarada en comentarios.

## Trazabilidad

- Ticket Jira: SCRUM-929 (CFG-12) · subtarea SCRUM-971
- ADRs afectados: ADR-0018 (propagacion de tenant), ADR-0012 (aislamiento), ADR-0013 (KYC
  en Storage, no implementado), ADR-0015 (suite de acceso cruzado)
- Requerimientos: RNF-01, DR-01
- Antecedentes: SCRUM-1039 (politicas RLS faltantes), SCRUM-959 (verificacion de terreno de
  CFG-09), CFG-04 (SCRUM-921, seed multi-tenant)
- Hallazgos que requieren ticket propio: H-02 (autorizacion por rol), H-03 (aprobacion de
  la desviacion de `tenant`/`zona`), H-04 (versionar las politicas RLS), y el caso 6 de
  ADR-0015 (implementar ADR-0013 en QA)

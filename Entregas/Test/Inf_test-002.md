# Informe de test — Promoción `develop` → `release` (Sprint 2)

**PR de promoción:** `MANI-Flutter#24` (mergeado, merge commit `ad4af04` en `release`) · **Responsable:** Santiago (QA) · **Fecha:** 2026-09-23

## Alcance

Este informe documenta la verificación del **gate DEV → QA** (Documento de Herramientas y
Políticas V2, §5.2, paso 1) antes de promover `develop` a `release`, y las pruebas que se
corrieron contra el estado de `develop` para decidir la promoción.

`release` se usa como **rama persistente**, no como `release/vX.Y.Z` por versión. Es un desvío
consciente frente a ADR-0004, ya decidido por el equipo: las PR de PoC (CFG-09, CFG-10, CFG-12 y
CFG-13) ya la usaban como base.

**Fuera de alcance:** k6 y OWASP ZAP. Corresponden al ambiente de Testing, después de promover.
La suite Newman de ADR-0015 contra QA no se corrió antes de promover, porque QA no tenía todavía el
esquema de `develop` (sección 4). Se corre después de poner QA al día.

**Después de promover** fue necesario poner MANI-QA al día. Primero se aplicaron 001–006, que
nunca habían llegado. Después hubo que normalizar los valores de dominio de sus datos con la
migración 007. Eso se documenta en la sección 4.

**Veredicto:** se promovió **con excepción documentada**. El gate técnico (CI y pruebas) se
cumple; el gate de proceso (revisión por par y DoR) no. Las brechas quedan en SCRUM-1055 a
SCRUM-1058. La promoción se integró con merge commit (`ad4af04`, padres `665f223` de `release` y
`9b86618` de `develop`), y el pipeline de `release` sobre ese commit quedó en verde. Al cierre
de este informe, MANI-QA tiene 001–007 aplicadas y la verificación `database/verify/11` da
**21/21** (sección 4.4).

---

## 1. Qué se promueve

Base común `23a317d` (2026-09-21). El último sync fue `39a9b3e`. `develop` está en `9b86618` y
`release` en `665f223`: son **44 commits, 196 archivos, +27 448 / −355 líneas**. El merge simulado
no tiene conflictos y conserva el workflow de CI propio de `release`.

| Origen | Autor | Merge por | Historia | Jira |
|---|---|---|---|---|
| `MANI-Flutter#9` Clean Architecture y DI | Nicolas11Leon (fork) | el autor | — | sin ticket |
| `MANI-Flutter#14` Register/Login | Alviz09 | el autor | US-02.1.1, US-02.1.2, US-02.2.1 | SCRUM-846, 847, 851 |
| Commit directo `d9c6ef8` | Jose Nicolas Alvarez | — | US-02.1.3 y US-02.1.4 | SCRUM-848, 849 |
| `MANI-Flutter#18` | dsavilam | Santiago | US-03.1.1 Crear categoría | SCRUM-857 |
| `MANI-Flutter#19` | dsavilam | Santiago | US-03.1.3 Categorías del aliado | SCRUM-859 |
| `MANI-Flutter#21` | Warriorr89 | Santiago | US-04.1.4 Aceptar/rechazar sin doble asignación | SCRUM-863 |
| `MANI-Flutter#22` | Warriorr89 | Santiago | US-04.1.1 Crear solicitud | SCRUM-860 |

**Commits directos a `develop`**, sin PR (vistos con `git log --first-parent`):

- Juan Sebastian Alvarez: `4b6428b`, `45f5777`, `c485aef`, `775601b` y `c903da1` (login/register y
  formato).
- Jose Nicolas Alvarez: `d9c6ef8` (SCRUM-848, que trae además completa la feature de cobertura de
  SCRUM-849), `de47f43` (merge local) y `7d97281` (fix de wiring).

**Esquema:** entran las migraciones `002_verificacion_aliados` a `006_crear_solicitud`. Traen
RPCs, triggers, políticas RLS, las tablas `solicitud_rechazo` y `solicitud_foto` y el bucket
`solicitudes`. Todas las historias tocan esquema o RLS.

---

## 2. Gate DEV → QA, punto por punto

### 2.1 Pipeline de `develop` en verde

**Pregunta:** ¿el último run de `develop` pasó formato, linter y tests con cobertura?

**Resultado real:** sí. Run
[35912665285](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35912665285) sobre `9b86618`
(merge de #22). Pasaron `dart format --set-exit-if-changed`, `flutter analyze`,
`flutter test --coverage`, `flutter test test/integration` y `flutter build web --release`. Los
runs de los merges anteriores (#18, #19 y #21) también están en verde.

**Veredicto:** **cumple.**

### 2.2 PR revisado y aprobado por un par (Gobierno §2.3) y regla §4.1

**Pregunta:** ¿cada cambio que se promueve llegó por PR con al menos una aprobación real?

**Resultado real** (API de GitHub, `pulls/{n}/reviews`):

| PR | Aprobación al integrarse | Estado al promover |
|---|---|---|
| #9 | ninguna | sin aprobación |
| #14 | ninguna; cuerpo del PR vacío | sin aprobación |
| #18, #19, #21 | ninguna registrada | Approve de Santiago, registrado después del merge |
| #22 | solo Copilot (`COMMENTED`) | Approve de Santiago, registrado después del merge |

Santiago revisó #18, #19, #21 y #22 antes de mergearlos, pero no dejó el Approve en GitHub; lo
registró el 2026-09-23. **#9 y #14 se auto-mergearon sin revisión de nadie.** Ningún PR enlaza
un issue de GitHub.

Además hay **8 commits directos a `develop`**, lo que viola §4.1. El equipo los aceptó y acordó
que no se repite.

**Veredicto:** **no cumple.** Se promovió con excepción. Queda pendiente en **SCRUM-1056**:
revisión retroactiva de #9, #14 y `d9c6ef8`, y decidir la protección de rama en `develop`.

### 2.3 DoR cumplida y criterios de aceptación validados en local

Se toma como referencia el DoR vigente del spike SCRUM-945, no el de Gobierno §2.7. Pide
evidencia en Jira (punto 5) y, por cada criterio de aceptación, un caso positivo, uno negativo y
un intento de violar la regla crítica, cada uno declarando qué criterio cubre (punto 7).

**Pregunta:** ¿las historias que se promueven tienen criterios y evidencia de validación?

**Resultado real** (Jira, 2026-09-23):

| Historia | Estado en Jira | Criterios | Evidencia (comentarios) |
|---|---|---|---|
| SCRUM-846 US-02.1.1 | En revisión | no | 0 |
| SCRUM-847 US-02.1.2 | En revisión | no | 0 |
| SCRUM-851 US-02.2.1 | En revisión | no | 0 |
| SCRUM-848 US-02.1.3 | Finalizada | no | 0 |
| SCRUM-849 US-02.1.4 | Finalizada | no | 0 |
| SCRUM-857 US-03.1.1 | Finalizada | **sí** (Given/When/Then) | 0 |
| SCRUM-859 US-03.1.3 | En curso | no | 0 |
| SCRUM-860 US-04.1.1 | En revisión | no | 0 |
| SCRUM-863 US-04.1.4 | En revisión | no | 0 |

`Product/Product_Backlog.md` tampoco tiene criterios para estas historias. Los PR #21 y #22
describen el comportamiento y traen una sección "Cómo probar"; es evidencia de validación
local, pero vive en GitHub y no está escrita como criterios.

**Estados desalineados con el código:**

- SCRUM-859 sigue "En curso" y sus subtareas 1016, 1017, 1019, 1020 y 1021 están en "Tareas por
  hacer", aunque hay commits integrados con esas claves.
- 846, 847, 851, 860 y 863 siguen "En revisión" con el código ya en `develop`.

**Veredicto:** **no cumple.** Queda pendiente en **SCRUM-1055**.

### 2.4 SonarQube (§4.3.1, ADR-0005)

**Resultado real:** no verificable. Desde los 403 del Quality Gate del 20/09, SonarQube solo
corre en `main`; ni `develop` ni `release` lo ejecutan.

**Veredicto:** **no verificable**; se revisará en la promoción a `main`.

---

## 3. Pruebas corridas antes de promover

Ejecutadas el 2026-09-23 en local, con Flutter 3.47.5 stable, sobre worktrees limpios. Se usaron
dos árboles: `develop` en `9b86618`, y el resultado de mezclar `develop` sobre `release` (merge
simulado), para detectar roturas que solo aparecen al combinar las dos ramas.

### 3.1 Suite Flutter

| Prueba | `develop` | Merge simulado |
|---|---|---|
| `dart format --set-exit-if-changed .` | exit 0 | exit 0 |
| `flutter analyze` | sin issues | sin issues |
| `flutter test --coverage` | **313 pasan**, 0 fallan, 0 en skip | 313 pasan |
| `flutter test test/integration` (subconjunto de las 313) | **18 pasan** | 18 pasan |
| Cobertura de líneas (`lcov.info`) | **85,4 %** (3 689 / 4 321) | — |

Pruebas de integración por archivo: `asignacion_rf14` (1), `asignacion_us0414` (4),
`categorias_us0311` (5), `crear_solicitud_us0411` (3) y `verificacion_aliados_us0213` (5).
Todas usan datasources falsos en memoria; **ninguna va contra Supabase real**.

### 3.2 Migraciones y verificación de base de datos

Se usaron contenedores Postgres 16 desechables, sin tocar el volumen de desarrollo. Cada
migración se aplicó **dos veces seguidas** para comprobar la idempotencia que exige
`database/migrations/README.md`.

| Escenario | Resultado |
|---|---|
| A. Postgres limpio, igual que `scripts/migrate-local.sh` | 001, 002, 003, 005 y 006 pasan; **004 falla** en las dos pasadas |
| B. Postgres con un shim mínimo de Supabase (`auth.uid()` y roles `anon`, `authenticated`, `service_role`) | 001–006 pasan en las dos pasadas; `schema_migrations` = 001…006 |
| `database/verify/10-test-aliado-categorias.sql` sobre B | **12/12 OK** |
| Seed `database/init/08` y `database/verify/09-test-tenant-isolation.sql` sobre B | **0 fugas** entre tenants (4 y 4 registros) |

**Causa de la falla en A:** `004_aliado_categorias.sql` usa `'auth'::regnamespace` dentro de un
`IF EXISTS`. El cast lanza error si el esquema `auth` no existe, así que la guarda no protege.
En DEV local esto detiene `migrate-local.sh` antes de 005 y 006. En Supabase no ocurre. Queda en
**SCRUM-1058**.

### 3.3 Checklist de regresión funcional (DD-MANI §10)

| Elemento de diseño | Cobertura en `develop` | Estado |
|---|---|---|
| Despacho atómico (§6.1) | `asignacion_repository_test` (5 aceptaciones simultáneas producen 1 asignación) y `asignacion_us0414_test`, ambos contra fakes. La RPC de `005` usa `UPDATE` condicional y `GET DIAGNOSTICS ROW_COUNT`. El patrón se validó contra PostgreSQL en CFG-09 (`Inf_PoC-001`) | **Parcial**: no hay prueba de la RPC `aceptar_solicitud` contra BD real |
| Resolución de tenant (§6.3) | `verify/09` y `verify/10` en SQL. Sin prueba de headers o JWT alterados | **Parcial**: la suite ADR-0015 queda para después (SCRUM-1057) |
| Idempotencia de aceptación (§7.1) | "el reintento del mismo aliado es idempotente" y "rechazar dos veces es idempotente" (fakes) | **Parcial** |
| Idempotencia de calificación (§7.2) | no existe la feature (US-04.4.1, SCRUM-874, en "Tareas por hacer") | **Brecha**, fuera del alcance de esta promoción |
| Aislamiento de Storage (§8.2) | la suite `qa/storage` de CFG-13 ya está en `release`. `006` crea el bucket `solicitudes` con políticas por carpeta del usuario, sin prueba propia | **Parcial** |

---

## 4. Pipeline de migraciones a QA y puesta al día de MANI-QA

### 4.1 El paso de migraciones nunca se ejecutaba

**Pregunta:** al promover, ¿las migraciones 002–006 llegan solas a MANI-QA?

**Resultado real:** no. El paso `Apply DB Migrations to Supabase QA` del workflow de `release`
tenía la condición `if: ... && env.SUPABASE_QA_DB_URL != ''`, con la variable declarada en el
`env` del mismo step. Ese `env` todavía no existe cuando se evalúa el `if`, así que el paso salía
`skipped` en todos los push (run
[35822083795](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35822083795)).

`MANI-Flutter#23` lo corrigió: un step previo resuelve si el secret existe y deja un `::warning::`
si falta. El primer run después del fix
([35916376440](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35916376440), `665f223`)
confirmó que el secret `SUPABASE_QA_DB_URL` tampoco estaba configurado.

Esto **cierra el punto abierto de `Inf_test-001`** (sección 6): el job de migraciones no
contradecía la deuda de CFG-12, porque **nunca había llegado a ejecutarse**.

### 4.2 Primera aplicación de la cadena en QA (001–006)

Con el secret creado, la cadena corrió por primera vez contra QA. Como antes `schema_migrations`
no existía en QA, se hizo como un paso controlado:

1. **Snapshot previo** de solo lectura (21:10 UTC): 18 tablas, 20 políticas, 22 índices y 4
   funciones. Pre-chequeo de datos: 0 duplicados que rompieran los índices únicos de 003 y 004.
2. **Simulación en una réplica local** con la estructura exacta de `public` de QA: 001–006
   aplican sin error y una segunda corrida también. No se pierde ninguna política.
3. **Aplicación:** re-ejecución (intento 2) del run
   [35919352037](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35919352037) sobre
   `ad4af04`, a las 21:20 UTC, con `[ÉXITO]` de 001 a 006. `004` reportó `DELETE 0`.
4. **Snapshot posterior**, que coincide exactamente con la simulación:

| | Antes | Después |
|---|---|---|
| `schema_migrations` | no existía | 001–006 |
| Tablas `public` | 18 | 21 |
| Políticas (`public` y `storage`) | 20 | 25, ninguna perdida |
| Índices `public` | 22 | 34, ninguno perdido |
| Funciones `public` | 4 | 32, las 4 previas se conservan |
| Buckets | `kyc-documentos` | más `solicitudes` |

SCRUM-1051 sigue vigente: las 16 políticas `tenant_isolation_*` de QA siguen sin estar en
`database/migrations/`. Reconstruir un ambiente desde la cadena lo dejaría sin aislamiento.

### 4.3 Los datos de QA usaban otro dominio: migración 007

**Pregunta:** con 001–006 aplicadas, ¿funcionan en QA la bandeja del aliado y el catálogo?

**Resultado real:** no. Los datos que dejaron los seeds de CFG-04, CFG-09 y CFG-12 usan minúscula
y en parte inglés: `aliado`, `activo`, `aprobado`, `assigned`, `cedula`. 002–006 y la app
comparan contra MAYÚSCULA en español: `ALIADO`, `ACTIVO`, `VERIFICADO`, `ASIGNADA`. En la réplica
eso daba:

- Bandeja y catálogo en `MANI-SOL-403` / `MANI-CAT-403`.
- Cualquier `UPDATE` a una categoría existente rechazado por `ck_categoria_estado`.
- El seed de CFG-04 ya no se podía volver a correr: desde 003, insertar `'activa'` viola el
  `CHECK` (`NOT VALID` solo exime las filas existentes).

**Decisión** (Santiago, 2026-09-23): normalizar los datos al formato del código. El token JWT
sigue en minúscula porque es el contrato de ADR-0018. `MANI-Flutter#25` (SCRUM-1057) hace lo
siguiente:

- **Compatibilidad de las PoC, antes de tocar datos:** el hook de CFG-12 emite `lower(rol)` y
  `kyc_isolation` de CFG-13 compara el rol con `lower()`.
- **`007_normalizar_dominios.sql`**, en una transacción:
  - Aplica esa compatibilidad solo si el hook y la política existen.
  - 17 `UPDATE`, uno por valor viejo.
  - Valida los `CHECK` que 003 dejó `NOT VALID`.
  - Aborta si queda algún valor viejo.
- **Seed de CFG-04** con los valores nuevos.

Pruebas en la réplica (20 casos):

| Escenario | Resultado |
|---|---|
| Antes de 007 (réplica igual a QA) | 13/20 |
| Solo los `UPDATE`, sin compatibilidad de PoC | 12/20: el token sale `ADMIN_TENANT` y el admin_tenant **pierde acceso** a los KYC de su tenant |
| 007 completa, con el runner del CI | 20/20 |
| 007 dos veces | 244 filas la primera vez (la suma del inventario) y 0 la segunda |

### 4.4 Aplicación de 007 y verificación en QA

- **Aplicación:** merge de `MANI-Flutter#25` (`3d46075`, 21:40 UTC), run
  [35923851959](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35923851959).
- **Verificación en QA** con `database/verify/11-normalizacion-dominios.sql` (solo lectura):
  **21/21**. Cubre:
  - `schema_migrations` con 007.
  - 0 valores viejos.
  - Bandeja del aliado asignado: 1 fila.
  - Catálogo tenant/admin/cliente: 1 fila cada uno.
  - `CHECK` validado y sin filas que lo violen.
  - Claims del hook `admin_tenant`/`aliado`/`cliente` para CFG-04 y CFG-12, y V4 fail closed.
  - KYC (ADR-0015 caso 6): propio 1, de otro tenant 0, admin de su tenant 1, cliente 0.

`#25` se mergeó antes de que entraran tres commits, que llegaron con `MANI-Flutter#27`
(`e5e33b0`):

- El seed de CFG-12 con los valores nuevos.
- El assert de la suite Newman de ADR-0015 ("su estado NO fue modificado" esperaba
  `'aprobado'`; ahora `'VERIFICADO'`).
- `supabase/seed/README.md` con el orden para volver a sembrar QA.
- Una versión de `verify/11` de un único `SELECT`, que ya no dispara el aviso de operaciones
  destructivas del SQL Editor y usa el aliado real de la solicitud de CFG-09.

### 4.5 PoC CFG-09

`MANI-Flutter#26` (SCRUM-1059, `e6bb402`):

- Versiona la RPC que corría en QA: tiene `p_espera`, que no estaba en el repo.
- Pasa la PoC a `PENDIENTE`/`ASIGNADA`, en la función, el seed, el reset y las verificaciones.

En la réplica, 10 aceptaciones simultáneas dan 1 éxito y 9 `ya_no_disponible`. El control
negativo sigue produciendo 10 asignaciones y el reintento no duplica.

**Aplicación en QA: pendiente**, a cargo de Santiago desde el SQL Editor. Se aplican solo las
funciones (secciones 2 a 4 del archivo) y el reset: la sección 1 de
`20_rpc_aceptar_solicitud.sql` hace `DROP TABLE poc_asignacion_log` y **borraría la bitácora de
CFG-09**, que en QA tiene 13 filas de las corridas r1–r4.

### 4.6 Suites Newman contra QA

**Pendiente:** correr `qa/newman/mani-claims` (CFG-12) y `qa/newman/mani-aislamiento`
(ADR-0015, CFG-13) contra QA. Usan las credenciales de los usuarios sembrados y las corre
Santiago. Es lo último que falta para cerrar SCRUM-1057.

---

## 5. Evidencia

**Runs de CI:**

| Propósito | Run | Rama | Commit | Resultado |
|---|---|---|---|---|
| Último pipeline de `develop` | [35912665285](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35912665285) | `develop` | `9b86618` | success |
| Paso de migraciones `skipped` antes del fix | [35822083795](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35822083795) | `release` | `246a150` | success, paso skipped |
| Fix activo, warning de secret ausente | [35916376440](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35916376440) | `release` | `665f223` | success, warning |
| CI del PR de promoción | [35918366684](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35918366684) | `develop` → `release` | `9b86618` | success |
| Pipeline de `release` tras el merge | [35919352037](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35919352037) | `release` | `ad4af04` | intento 1: success, migraciones skipped por secret ausente |
| Primera aplicación de 001–006 en QA | [35919352037](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35919352037) (intento 2) | `release` | `ad4af04` | success, `[ÉXITO]` 001–006 |
| Aplicación de 007 en QA | [35923851959](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35923851959) | `release` | `3d46075` | success |
| Merge de #26 (CFG-09) | [35925196154](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35925196154) | `release` | `e6bb402` | success |
| Merge de #27 | [35925409985](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35925409985) | `release` | `e5e33b0` | success |

**PR:** `MANI-Flutter#23` (fix del paso de migraciones), `#24` (promoción), `#25` (007 y
compatibilidad de PoC), `#26` (CFG-09 alineada) y `#27` (seed de CFG-12, assert de Newman,
README de seeds y `verify/11`). Todos mergeados en `release`.

**QA:** snapshots de solo lectura antes (21:10 UTC) y después (21:22 UTC) de 001–006, y
`verify/11` después de 007 (21/21). Los resultados están en los comentarios de SCRUM-1057.

**Archivos:** `database/migrations/002…006`, `database/verify/09` y `10`,
`database/init/08-seed-qa-multitenant.sql`, `test/integration/*` y
`.github/workflows/ci.yml` (en `release`).

---

## 6. Tickets derivados

| Ticket | Qué cubre |
|---|---|
| SCRUM-1055 | Criterios de aceptación, evidencia y estados en Jira de las 9 historias promovidas |
| SCRUM-1056 | Revisión retroactiva por un par de #9, #14 y `d9c6ef8`; protección de rama en `develop` |
| SCRUM-1057 | Poner QA al día: 001–007 aplicadas y `verify/11` 21/21. **Falta** correr las suites Newman de CFG-12 y ADR-0015 |
| SCRUM-1058 | `004` falla en Postgres sin esquema `auth` y corta `migrate-local` en DEV. Próximo sprint |
| SCRUM-1059 | Alinear la PoC CFG-09 y versionar su RPC de QA. Mergeado en #26; **falta aplicarla en QA** |

---

## Hallazgos transversales

- **El gate técnico funciona; el de proceso no se está aplicando.** CI, formato, análisis y
  pruebas están en verde de forma consistente. Revisión por par, criterios y evidencia en Jira
  fallan en casi todos los cambios. `develop` no tiene una regla de rama que lo impida (mismo
  hallazgo que `Inf_test-001` sobre `release`).
- **Las pruebas automatizadas verifican contratos, no la base de datos.** Las 313 pruebas corren
  contra fakes. La única verificación contra PostgreSQL de esta promoción son los scripts de
  `database/verify`, corridos a mano. Mientras no exista un job con `services: postgres`, el
  pipeline no detecta un problema de migraciones como el de SCRUM-1058.
- **QA estuvo desconectado de la cadena de migraciones desde que se creó.** El primer contacto
  metió 6 migraciones de una vez. Se hizo como paso controlado: snapshot, simulación en una
  réplica con la estructura real, re-ejecución del run y snapshot posterior. La simulación
  predijo exactamente el resultado.
- **Los seeds y las PoC hablaban otro dominio que el código.** CFG-04, CFG-09 y CFG-12 sembraban
  minúscula e inglés, y nada lo detectaba, porque las pruebas automatizadas usan fakes. Se
  corrigió con 007 y con los seeds alineados. La prevención de fondo sigue siendo un `CHECK` por
  columna de dominio, que hoy solo existe en `categoria_servicio`.
- **Algunos scripts de PoC no son seguros para volver a correrlos completos.**
  `supabase/poc-cfg09/20_rpc_aceptar_solicitud.sql` recrea la bitácora con `DROP TABLE`, y el
  seed de CFG-04 borra todo lo que cuelga de sus tenants, incluidos los usuarios de CFG-12.
  Antes de volver a correr una PoC en QA hay que leer qué borra.

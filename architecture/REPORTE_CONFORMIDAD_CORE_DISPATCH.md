# Agente 5 — Conformidad técnica: matriz de responsabilidades Core–Dispatch

Fecha de examen: 2026-10-20. Sin cambios en ningún repositorio: solo lectura.

## 1. Código examinado (commit exacto)

| Repositorio | main | develop | release |
|---|---|---|---|
| MANI-Node | `f236962` | `8e198ff` | `2745bb0` |
| MANI-.NET | `1c8b981` | `5736636` | `41ba171` |
| MANI-docs | `416d3a8` (origin/main) | — | — |

PR verificados y su commit de fusión, comprobados como ancestros de `develop` **y** de `release`
(`git merge-base --is-ancestor`):

| PR | Título | Base | Merge commit | En develop | En release |
|---|---|---|---|---|---|
| MANI-Node #43 | SCRUM-1073 — endpoints de elegibilidad, contexto y notificaciones en Core | develop | `46c6192` | sí | sí |
| MANI-Node #44 | SCRUM-1072 — creación de la solicitud en Core | develop | `536b33c` | sí | sí |
| MANI-.NET #1 | SCRUM-1074 — exclusión concurrente | develop | `c069307` | sí | sí |
| MANI-.NET #2 | SCRUM-1073 — orquestación de despacho | develop | `341f164` | sí | sí |
| MANI-.NET #3 | SCRUM-861 — aliados por cobertura y categoría | develop | `0cc3ea8` | sí | sí |
| MANI-.NET #8 | SCRUM-862 — filtro por tipo de aliado | develop | `686d528` | sí | sí |

**`main` de MANI-.NET (`1c8b981`) es código antiguo:** `Controllers/DispatchController.cs:36-38`
devuelve candidatos fijos con `DistanceKm`/`EstimatedArrivalMinutes` y `:11` usa
`ConcurrentDictionary` en memoria. Ese código **no existe** en `develop` ni en `release`:
`DistanceKm` tiene cero apariciones y `ConcurrentDictionary` solo aparece en dobles de prueba
(`tests/.../Helpers/`). Cualquier hallazgo citando `main` describe una rama que no se despliega.

## 2. Matriz de responsabilidades Core–Dispatch

Columna «Dueño documental» = SAD §7.4 (tabla «Dueño de los datos», decisión SCRUM-1232),
ADR-0022 §Decisión y ModeloDatos §13.

| Capacidad | Dueño documental | Implementado en | Estado |
|---|---|---|---|
| Crear y persistir la solicitud (RF-12) | Core (SAD §7.4 «Dispatch… no crea la solicitud») | Core: `POST /solicitudes`, PR Node #44 | **Conforme** al SAD §7.4; **contradice** SAD §7.2 y ADR-0022 (ver D-1) |
| Elegibilidad por categoría, zona, disponibilidad | Core (SAD §7.3, §7.4) | Core: `GET /api/v1/allies/eligible` (`src/routes/core.routes.js:49`, `PgElegibilidadRepository`) | **Conforme** |
| Consumo de elegibilidad por Dispatch | HTTP, nunca SQL (ADR-0030 §2) | `Infrastructure/Core/CoreAllyClient.cs` implementa `IAllyRepository`; **no existe `PostgresAllyRepository`** en develop/release | **Conforme** en código; ADR-0030 sigue **Propuesto** (ver P-1) |
| Contexto de la solicitud (zona, categoría, estado) | Core | `GET /api/v1/solicitudes/:id/context` ↔ `CoreAllyClient.GetSolicitudContextAsync` | **Conforme** |
| Perfil del aliado autenticado | Core | `GET /api/v1/allies/me` ↔ `CoreAllyClient.GetAllyProfileAsync` | **Conforme** (no estaba en el cuerpo del PR #43; existe en código) |
| Orden del listado (ranking, RF-13) | Rules (SAD §7.4, ADR-0030 §2) | **Nada**: cero referencias a Rules en el código de Dispatch | **No implementado** (D-5) |
| Broadcast de ofertas | Dispatch | `OrchestrateDispatchUseCase` + `CoreDispatchPublisher` → `POST /notifications` de Core | **Parcial** (D-4: tope de 50, sin reanudación) |
| Notificación al usuario final (FCM/APNs, Realtime) | Core (ADR-0030 §2, SAD §12) | Dispatch publica a través de Core | **Conforme** en la frontera; P4 de SAD §7.4 sigue abierto |
| Aceptación con exclusión concurrente (RNF-05) | Dispatch, por `UPDATE` condicional atómico (ADR-0016, ADR-0022) | `PostgresSolicitudAssignmentRepository.AcceptRequestAsync` | **Parcial**: el `UPDATE` es correcto; falla el contexto de sesión y la semántica de estados (D-2, D-3, D-6) |
| Rechazo de oferta | Dispatch (`solicitud_rechazo`, dominio de Dispatch según migración Core 0007) | `RejectRequestAsync`, `INSERT … ON CONFLICT DO NOTHING` | **Parcial** (D-3) |
| Idempotencia (RNF-03) | Core en creación, Dispatch en despacho | Core: `claveIdempotencia` con savepoint. Dispatch: relectura de ofertas previas | **Parcial** (D-4) |
| Propiedad del esquema y migraciones | Core (ADR-0030 §1) | Toda la DDL vive en `MANI-Node/db/migrations/`; `MANI-.NET` solo tiene SQL bajo `tests/` | **Conforme**: el `schema_and_seed_dotnet.sql` que ADR-0030 prohibía no entró |

### Verificación explícita de los hallazgos heredados

- **Hallazgo 3 y 7 (`PostgresAllyRepository`)**: ya **no existe** en `develop` ni en `release`. La
  propuesta N6 **ya está implementada** (`CoreAllyClient`, timeout de 3 s en `Program.cs:31`,
  reenvío del JWT en `ForwardAuthorizationHandler`, 503 si Core no responde). No hay nada que
  proponer; queda la ratificación del ADR.
- **Hallazgo 9 (`DistanceKm`)**: defecto inexistente en la rama que se despliega. La selección es
  por zona (con ancestro), categoría, `estado_verificacion = 'VERIFICADO'`, ausencia vigente,
  rechazo previo y `tipo` opcional (`PgElegibilidadRepository`, `GetEligibleAlliesUseCase`). **No
  se propone retirar nada.**
- **Exclusión concurrente**: `ConcurrentDictionary` solo en dobles de prueba. La producción usa
  `UPDATE solicitud SET aliado_id=…, estado='ASIGNADA' WHERE id=… AND tenant_id=… AND aliado_id IS
  NULL AND estado='PENDIENTE'`, atómico y correcto como sentencia.
- **Valor canónico de verificación** (ADR-0030, hallazgo 1): en el código ya es uno solo. La
  escritura pasa por `ESTADO_VERIFICACION_TO_DB` (`VERIFIED`→`VERIFICADO`) y la consulta de
  elegibilidad filtra solo `'VERIFICADO'`. No se encontró el `OR 'aprobado'` que citaba el ADR.

## 3. Defectos verificables

**D-1 — Contradicción documental sobre la propiedad de la solicitud. Pendiente de decisión.**
SAD §7.4 decide «Core crea la solicitud» (17 oct 2026, SCRUM-1232) y dice que Dispatch no la crea,
pero **SAD §7.2 sigue diciendo** «RF-12: creación y coordinación operacional de solicitudes» para
Dispatch, y **ADR-0022 §Decisión** asigna a Dispatch «solicitudes, aceptación, idempotencia y
exclusión concurrente». ModeloDatos §6.1 ubica `solicitud` en el esquema `despacho` y §13 declara
**escritura exclusiva** del dueño del esquema; el propio documento marca el punto abierto. El código
sigue SAD §7.4. Además **P1 de SAD §7.4** (quién es dueño del estado de la solicitud después de la
asignación) tenía fecha límite 20 oct 2026 y sigue abierto, y es justo lo que Dispatch ya escribe.
No corregir por mi cuenta: ratificar o reasignar. La corrección de §7.2 ya está asignada a DOC4-03
(SCRUM-1246).

**D-2 — Dispatch nunca fija el contexto de identidad en la base. Desviación, alto impacto.**
La migración de Core `0007_politicas_por_tenant.sql` otorga a `mani_dispatch_svc` `SELECT, UPDATE`
sobre `solicitud` y `SELECT, INSERT` sobre `solicitud_rechazo`, con RLS y políticas que dependen de
`app.tenant_id()`, `app.user_role() = 'aliado'` y `app.user_id()`; y `0006_contexto_identidad.sql`
concede `EXECUTE` de `app.set_context(uuid,uuid,text)` **a `mani_dispatch_svc`** precisamente para
que lo invoque como primera sentencia de cada transacción. En `MANI-.NET` (release y develop) hay
**cero** apariciones de `set_config`, `app.set_context`, `SET LOCAL` o `mani_dispatch_svc`.
Escenario de fallo: desplegado con el rol previsto, `app.tenant_id()` es `NULL`, la política
`solicitud_aceptar_aliado` no deja pasar ninguna fila y toda aceptación devuelve «no encontrada» o
conflicto. Desplegado con `service_role`/`postgres`, funciona pero RLS queda como documentación,
contra ADR-0012 y la alternativa 1 de ADR-0032. Criterio de aceptación: abrir transacción, invocar
`app.set_context(tenant, usuario, 'aliado')` y ejecutar el `UPDATE` dentro de ella, con una prueba
de integración conectada como `mani_dispatch_svc` (`NOBYPASSRLS`) que acepte una solicitud y falle
al intentar la de otro tenant.

**D-3 — La política de `solicitud_rechazo` exige leer `aliado`, tabla sin permiso para Dispatch. Desviación.**
`0007` crea `solicitud_rechazo_aliado` con `aliado_id IN (SELECT a.id FROM aliado a WHERE
a.usuario_id = app.user_id())`, y el mismo archivo revoca todo y **no** concede `SELECT` sobre
`aliado` a `mani_dispatch_svc` (su encabezado lo dice literalmente: «sin permisos sobre `aliado`…»).
La expresión de la política se evalúa con los privilegios del rol activo. Escenario de fallo: con el
contexto ya corregido, el `INSERT` de rechazo falla con «permission denied for table aliado». El
defecto está en la migración de Core, no en Dispatch. Dos salidas posibles: conceder `SELECT` sobre
`aliado` restringido, o reescribir la política sin tocar `aliado` (p. ej. comparando contra un claim
de aliado). Requiere decidir cuál, porque cambia la superficie de lectura cruzada que ADR-0030
limita.

**D-4 — El broadcast se corta en 50 aliados y un fallo a mitad queda congelado. Desviación.**
`OrchestrateDispatchUseCase` fija `PageSize = 50` y **no recorre páginas**, aunque Core pagina hasta
100 y devuelve `totalCount`, que aquí se descarta. Con 51 elegibles, 1 no recibe oferta y la
respuesta anuncia el despacho como exitoso. Peor: la guarda de idempotencia es
`existingOffers.Count > 0`; si el proceso muere tras publicar 10 de 40 ofertas, el reintento ve 10
ofertas y responde «Despacho ya transmitido previamente», dejando 30 aliados sin oferta de forma
permanente. Criterio de aceptación: recorrer hasta cubrir `totalCount` y comparar el conjunto de
ofertas existentes contra el de elegibles, publicando solo las faltantes; prueba que simule un corte
a mitad y verifique que el reintento completa el resto sin duplicar.

**D-5 — Dispatch no consulta a Rules para el orden del listado. No implementado.**
SAD §7.4 y ADR-0030 §2 ponen el orden en Rules; el cuerpo del PR Node #43 también lo dice («el
ranking es de Rules»). En `MANI-.NET` no hay cliente de Rules ni referencia alguna, y `appsettings.json`
declara un `ServiceUrls:RulesService` que nadie lee. El orden efectivo es el de Core, por `id`.
Es una capacidad faltante, no un defecto de implementación: requiere historia propia.

**D-6 — Una solicitud que no está `PENDIENTE` se reporta como «asignada a otro profesional». Desviación menor.**
En `AcceptRequestAsync`, si la fila existe con `aliado_id IS NULL` pero el estado no es `PENDIENTE`
(p. ej. `CANCELADA`), el `UPDATE` no afecta filas, la relectura devuelve `NULL` y el método retorna
`Conflict` con `AssignedAllyId = null` y el mensaje «La solicitud ya fue asignada a otro
profesional». El cliente recibe un 409 que describe un hecho falso. Debe distinguirse conflicto de
asignación de conflicto de estado.

**D-7 — `CORE_SERVICE_URL` no está declarada en ningún manifiesto versionado. Desviación.**
`CoreAllyClient` y `CoreDispatchPublisher` leen `configuration["CORE_SERVICE_URL"]`, mientras
`appsettings.json` declara `ServiceUrls:CoreService` que **ningún código lee**. `docker-compose.yml`
solo carga un `.env` no versionado y el repositorio no tiene `.env.example`. Sin esa variable, todo
el flujo de despacho responde 503. Es compatible con el historial de imágenes desactualizadas en QA.
Corrección mínima: leer la clave que ya existe en `appsettings.json` como respaldo, o declarar la
variable en el compose y en un `.env.example`.

**D-8 — Dispatch acepta tokens que Core rechaza, y no valida tokens asimétricos. Desviación menor.**
`JwtAuthHelper` valida solo HS256 con `SUPABASE_JWT_SECRET` y, si no encuentra los claims en
`app_metadata`, cae a `tenant_id`/`tenantId`/`user_role` planos. El `TokenService` de Core declara
explícitamente que **no hay fallback** a claims de la raíz y contempla encabezados ES256. Resultado:
dos políticas de token distintas en el mismo flujo (contra ADR-0031). Si el proyecto emite claves
asimétricas, Dispatch devuelve 401 mientras Core autentica bien.

**D-9 — Hueco de autorización reconocido en el PR #43 y cerrado fuera de él. Pendiente de verificación.**
El propio PR declara que `/allies/eligible`, `/solicitudes/*/context` y `/notifications` quedan
alcanzables con un JWT de cliente y que se cierran con `MANI-APIGateway#11`, que debía fusionarse
antes o junto con él. No verifiqué el Gateway en este pase: queda como punto a comprobar antes de
promover (el PR de Core ya está en `release`).

**D-10 — Hueco en la numeración de migraciones. Desviación menor.**
`MANI-Node/db/migrations/` salta de `0010` a `0013` en develop y release. Los números 0011 y 0012
fueron consumidos por ramas cuyos PR se cerraron sin fusionar (`0012_evento_servicio_evidencia.sql`
existe en `cd32501`, de SCRUM-869). ADR-0030 §1 exige numeración incremental e inmutable con registro
en `schema_migrations`; conviene dejar constancia de por qué faltan, para que un despliegue no los
busque.

## 4. Decisiones necesarias antes de refactorizar

| ID | Decisión | Por qué bloquea |
|---|---|---|
| P-1 | Ratificar **ADR-0030** (hoy **Propuesto**) | El código de `release` ya lo cumple (frontera por HTTP, DDL solo en Core). Está implementado contra una decisión no aprobada: o se ratifica o hay que revertir código fusionado. |
| P-2 | Ratificar **ADR-0016** (hoy **Propuesto**; absorbe **ADR-0021**, que figura **Superseded**) | Es el fundamento de la aceptación atómica ya implementada y de los permisos de `0007`. |
| P-3 | Ratificar **ADR-0022** (hoy **Propuesto**) y **corregir su reparto** | Su §Decisión asigna «solicitudes» a Dispatch, en contra de SAD §7.4 y del código. Mientras no se corrija, D-1 no se puede cerrar. |
| P-4 | Resolver **P1 de SAD §7.4** (dueño del estado de la solicitud tras la asignación) y, con él, la ubicación de `solicitud` en ModeloDatos §6.1/§13 | Determina si el `UPDATE` de Dispatch es escritura en dominio propio o cruzada, y por tanto si D-2/D-3 se arreglan en Dispatch o moviendo la operación a Core. |
| P-5 | Ratificar **ADR-0032** y fijar con qué rol se conecta Dispatch | Sin esto, D-2 no tiene criterio de aceptación: el arreglo cambia según si el rol es `mani_dispatch_svc` o `service_role`. |
| P-6 | Decidir la salida de D-3 (conceder `SELECT` sobre `aliado` o reescribir la política) | Toca una migración de Core y la frontera de lectura de ADR-0030. |

**No implementé ni propuse N6:** ya está en el código. No toqué ADR ni documentos. No propuse
retirar `DistanceKm` ni el `ConcurrentDictionary`: no existen en las ramas que se despliegan.

## 5. Pruebas existentes

- MANI-.NET develop/release: `tests/Mani.Dispatch.Tests/` incluye
  `PostgresSolicitudAssignmentRepositoryIntegrationTests.cs` (asignación, estado resultante,
  concurrencia con un único ganador, rechazo) contra PostgreSQL con migraciones propias de prueba
  (`001`–`008`). **No cubren**: contexto de identidad con `mani_dispatch_svc` (D-2), inserción de
  rechazo bajo la política real (D-3), broadcast con más de 50 elegibles ni reintento parcial (D-4),
  estado distinto de `PENDIENTE` en la aceptación (D-6).
- MANI-Node release: suite propia con pruebas de ruta e integración `pg` para elegibilidad
  (verificados, ausencia vigente, rechazo, tipo, paginación, zona padre, aislamiento de tenant) y
  para la creación de la solicitud (idempotencia, concurrencia, tenant cruzado).
- SAD §7.5 advierte que **ninguna capacidad está verificada por QA en la arquitectura vigente**: la
  matriz del Sprint 4 (SCRUM-1264) está diseñada y sin ejecutar.

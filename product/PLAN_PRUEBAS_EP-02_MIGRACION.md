# Plan de pruebas de las historias migradas de EP-02 (paridad con la arquitectura anterior)

**Ticket:** SCRUM-1094 (DOC-38), subtareas SCRUM-1167 a SCRUM-1172 · **Responsable:** Santiago (QA) · **Fecha:** 2026-10-06 · **Estado:** borrador para revisión del par técnico

**Historias cubiertas:** US-02.1.1-M2/M3 (SCRUM-1065, SCRUM-1061), US-02.1.2-M2/M3 (SCRUM-1063, SCRUM-1060), US-02.1.3-M2 (SCRUM-1066) y US-02.2.1-M2 (SCRUM-1064).

**Insumo de:** DOC-24 (informe de resultados), US-02.1.1-M4 (SCRUM-1062) y el retiro de funciones PL/pgSQL previsto en ADR-0022.

---

## 1. Propósito, alcance y criterio de paridad

### 1.1 Propósito

El Sprint 3 cambia el camino de las historias de EP-02:

| | Arquitectura anterior (entregas 1 a 3) | Arquitectura vigente (Sprint 3) |
|---|---|---|
| Camino | Flutter -> Supabase directo (`.rpc()`, `.from()`, `.storage.from()`) | Flutter -> NGINX API Gateway -> Core Node -> Supabase/PostgreSQL |
| Identidad | El cliente llama a Supabase con su propio token | Supabase Auth emite el JWT, el tenant viaja como claim y el servicio valida el token |
| Lógica de negocio | En Flutter y en funciones PL/pgSQL | En los servicios (ADR-0022, **Propuesto**, PR Trama-AS/MANI-docs#11) |
| Aislamiento | RLS por `auth.uid()` | Autorización en el servicio; RLS queda como defensa adicional |

Este plan define cómo demostrar que la migración no rompe lo que ya funcionaba. Según ADR-0022, las funciones PL/pgSQL "no se editan: se retiran con una migración nueva una vez la regresión en QA confirme el reemplazo". El reporte que se derive de este plan es lo que autoriza ese retiro.

### 1.2 Criterio de paridad

La verificación se hace **comportamiento por comportamiento**:

1. Cada comportamiento que la arquitectura anterior verificaba (por una prueba vieja, por un criterio de aceptación original o por la regla de una función PL/pgSQL) se lista con su resultado esperado.
2. Ese resultado esperado se escribe **antes** de ejecutar y se verifica por el camino nuevo.
3. Un comportamiento queda **preservado** solo si pasa por el camino nuevo con el mismo resultado.
4. Un comportamiento que no tenía línea base (no existía antes o nadie lo verificó) se declara **construido y verificado**, nunca "preservado".
5. Un comportamiento viejo que viola la arquitectura vigente se declara **no se preserva**, con su motivo.

### 1.3 Fuentes y versiones leídas

Lectura del 6 de octubre de 2026, después de `git fetch --all --prune`.

| Repositorio | Rama | SHA | Uso |
|---|---|---|---|
| `MANI-Flutter` | `develop` | `1f4c843` | Pruebas viejas, datasources, funciones PL/pgSQL, colecciones Newman |
| `MANI-Flutter` | `feature/SCRUM-1061-auth-remote-gateway` (PR Trama-AS/MANI-Flutter#34 hacia `develop`, abierto) | `e2eca3a` | Registro de aliado persona natural por Gateway |
| `MANI-docs` | `main` | `3fd4473` | SRS, backlog, gobierno, ADR-0005, ADR-0013, ADR-0015, comunicación con el Gateway |
| `MANI-docs` | `docs/SCRUM-1076-criterios-aceptacion-us-02-1-1` (PR #13) | `97e72ae` | Criterios y casos de regresión de US-02.1.1 |
| `MANI-docs` | `docs/SCRUM-1095-umbrales-qas-sdd` (PR #14) | `d1c7d5e` | Punto 8 del SDD: método de verificación de QAS-01 a QAS-09 |
| `MANI-docs` | `SCRUM-1075-adr-0022` (PR #11) | `aa6d464` | ADR-0022, Propuesto |
| `MANI-APIGateway` | `main` | `e312793` | `nginx.conf`, `CLAUDE.md` |
| `MANI-Node` | `main` | `07069d3` | Esqueleto de Core, `CLAUDE.md` |
| `MANI-Java`, `MANI-.NET` | `main` | `ae5d6ce`, `e2e8370` | Fuera del alcance de estas historias |

Jira: SCRUM-1094 y subtareas, las siete historias `-M2`/`-M3`, PO-05 (SCRUM-1083, criterios escritos en la descripción de SCRUM-1060, 1063, 1064 y 1066), CFG-16, CFG-22, CFG-23a, CFG-23b y QA-01 a QA-05.

Convención de nombres: variables, marcadores y campos en `snake_case`, como las colecciones de `qa/newman`. Los identificadores de escenario ya publicados (`A1-P`, `B3`, `rgA1P`) se conservan.

---

## 2. Cómo cambia la verificación con la nueva arquitectura

Buena parte de las pruebas viejas queda obsoleta **como mecanismo**, pero sus reglas siguen siendo el resultado esperado. La arquitectura limpia de Flutter separa `data`, `domain` y `presentation`, y la migración solo cambia `data` (criterio CA-2 de PO-05). Eso divide las pruebas así:

| Prueba vieja | Destino | Motivo |
|---|---|---|
| `test/features/profiles/verification/fakes.dart` (`ServidorVerificacionFake`) | **Reescribir** cuando exista el datasource HTTP de US-02.1.3 | Implementa `VerificacionRemoteDataSource` y lanza `PostgrestException` con códigos `MANI-VER-*`. Con el Gateway el error llega como HTTP con `{ error, code?, correlationId }` |
| `test/features/profiles/verification/data/repository_impl_test.dart` | **Reescribir** | El repositorio traduce `PostgrestException` `MANI-VER-*` (`verificacion_aliados_repository_impl.dart`). Esa traducción cambia |
| `test/integration/verificacion_aliados_us0213_test.dart` | **Reescribir el mecanismo; conservar las reglas** | Sus 9 comportamientos son el resultado esperado de US-02.1.3 (sección 6.3) |
| `test/features/profiles/verification/domain/*`, `presentation/*` | **Se mantienen** | Usan `FakeVerificacionRepository`, que implementa la interfaz del dominio. La interfaz no cambia |
| `qa/newman/mani-aislamiento.postman_collection.json` | **Se reorienta** | Ataca `/rest/v1` y `/storage/v1`. Ya no prueba la autorización nueva. Sirve para (a) probar RLS como defensa adicional y (b) como prueba negativa de "solo Gateway" (CC-1) cuando la llave pública salga del bundle y se rote (CFG-36, SCRUM-1113, subtareas 1228 a 1230). Mientras eso no ocurra, cualquiera con la llave puede llamar a PostgREST y RLS es la única barrera (descripción de SCRUM-1113), por lo que esta colección sigue siendo obligatoria en cada corrida |
| `qa/newman/mani-claims.postman_collection.json` | **Se reorienta** | Prueba los claims que emite Supabase Auth. Sigue vigente para la emisión; la propagación por Gateway y Core es nueva |
| `database/verify/09-test-tenant-isolation.sql`, `11-normalizacion-dominios.sql` | **Se mantienen hasta CFG-23a** | Verifican la base. El modelo de identidad nuevo puede cambiarlos |
| `database/verify/10-test-aliado-categorias.sql`, `qa/k6/aceptar_concurrente.js`, las demás pruebas de `test/` | **Fuera de alcance** | Pertenecen a historias de Incremento 2 |

**Regla del plan:** una prueba de Flutter con servidor o cliente HTTP falso verifica el comportamiento **del cliente** (que llama al Gateway, que no envía el tenant en el cuerpo, que muestra los errores). **No cuenta como paridad** de una regla que ahora vive en Core. Esa regla se demuestra en Core, con Testcontainers o con Newman a través del Gateway.

**Riesgo asociado:** si el servidor falso de US-02.1.3 se adapta para lanzar errores HTTP, las pruebas de Flutter pasan sin verificar nada del servidor. El reporte de paridad no las acepta como evidencia de las reglas de la sección 6.3.

---

## 3. Inventario de pruebas viejas (SCRUM-1167)

### 3.1 `MANI-Flutter@develop` (`1f4c843`)

`test/` contiene 39 archivos: 33 `_test.dart` y 6 `fakes.dart`.

| Ubicación | Casos (aprox.) | Qué verificaba | Historia |
|---|---|---|---|
| `test/integration/verificacion_aliados_us0213_test.dart` | 5 | Recorrido completo con capas reales y servidor falso: bandeja del tenant, FIFO, KYC, aprobar, rechazar con motivo, 409 por decisión concurrente, no admin, sesión expirada, documento ausente, logs sin PII | US-02.1.3 |
| `test/features/profiles/verification/**` | 71 | Repositorio (13), entidades (13), casos de uso (10), cubit (19), página (16) | US-02.1.3 |
| `test/core/network/gateway_client_test.dart` | 28 | Cliente HTTP del Gateway: `Bearer`, `X-Correlation-ID`, reintentos con idempotencia, 401/403/5xx, timeout | Transversal (SCRUM-1111). Prueba nueva |
| `test/features/auth/data/registro_empresa_gateway_test.dart` | 10 | Una sola petición al Gateway y ninguna a Supabase, multipart, tenant solo en `X-Tenant-Slug`, mensajes 400/401/409/5xx | US-02.1.2-M3. Prueba nueva |
| `test/features/auth/data/registro_aliado_gateway_test.dart` (solo en PR #34 hacia `develop`) | 9 | Lo mismo para persona natural, más 409 por correo duplicado | US-02.1.1-M3. Prueba nueva |
| `test/integration/asignacion_*`, `categorias_us0311_test.dart`, `crear_solicitud_us0411_test.dart` y sus unitarias | — | RF-14, US-04.1.4, US-03.1.1, US-04.1.1 | Fuera de alcance |

**Historias sin prueba vieja propia** (verificado también en el historial de `test/features/auth`): US-02.1.1, US-02.1.2 y US-02.2.1. Su línea base son los criterios originales de `Entregas/Entrega4/Backlog_V3.md` §3, la suite de aislamiento y la regla de la función PL/pgSQL que reemplazan.

### 3.2 Otras pruebas y verificaciones

| Ubicación | Qué verificaba |
|---|---|
| `qa/newman/mani-aislamiento` | Casos 1 a 5 de Políticas DevOps §13.4 sobre `/rest/v1`; caso 6 de KYC en Storage (P1–P3, N1–N11, C1) |
| `qa/newman/mani-claims` | Propagación de claims (SCRUM-972), casos borde (SCRUM-973), cuatro vectores de suplantación |
| `qa/storage/*` | Carga de KYC y tiempos (PoC CFG-13) |
| `database/verify/09`, `11` | Ausencia de contaminación cruzada en el seed; controles de CFG-12 y CFG-13 |

### 3.3 Funciones PL/pgSQL que reemplazan las historias

Lectura de `MANI-Flutter@develop`; no se ejecutaron.

| Función | Archivo | Historia | Reglas relevantes |
|---|---|---|---|
| `registrar_aliado_persona_natural`, `handle_new_user` | `database/init/03`, `04`, `05` | US-02.1.1 | Ver `PLAN_REGRESION_US-02.1.1-M4.md` §6 |
| `registrar_aliado_empresa` | `database/init/07-registro-aliado-empresa.sql` | US-02.1.2 | Tenant debe existir; categoría debe existir; `usuario` con rol `ALIADO`; `aliado` `PERSONA_JURIDICA` en `PENDIENTE`; documentos en `documento_kyc` en `PENDIENTE`. Duplicado: `ON CONFLICT ... DO UPDATE` (no rechaza). Sin validación de documentos obligatorios |
| `registrar_cliente_persona_natural` | `database/init/06-registro-cliente.sql` | US-02.2.1 | Tenant debe existir; `usuario` `CLIENTE` `ACTIVO`; `cliente` `PERSONA_NATURAL`; si hay dirección, crea un `sitio` en la primera zona `ACTIVO` encontrada; `GRANT EXECUTE` a `anon` |
| `listar_aliados_verificacion`, `obtener_aliado_verificacion`, `resolver_verificacion_aliado` | `database/migrations/002_verificacion_aliados.sql` | US-02.1.3 | Códigos `MANI-VER-401/403/404/409/422D/422M/422K`; bloqueo `FOR UPDATE`; motivo de rechazo de 10 a 500 caracteres; no se aprueba sin KYC; inserta notificación |

### 3.4 Origen de las cifras 135 y 313

Para usar estas cifras como línea base se precisa su composición. Según `Entregas/Entrega4/DD_V2.md` (§10), `SAD_V3.md` y `SDD_V1.md`, el informe Inf_test-002 midió **313 pruebas de Flutter, 18 de ellas de integración, con cobertura de 85,4 %**, y **135 aserciones de Newman (135/135)** en la suite de aislamiento. El informe (`Inf_test-002`, promoción `develop` -> `release` del Sprint 2, 2026-09-23) confirma esas cifras en su §4: `flutter test --coverage` con 313 pruebas que pasan, `flutter test test/integration` con 18, cobertura de líneas de 85,4 % y 135/135 aserciones de Newman. **No está en ninguna rama actual de MANI-docs:** salió del árbol en la reestructuración del commit `cc28e0c` (2026-09-30) y se recupera del historial con `git show cc28e0c^:Project/Test/Inf_test-002.md`. El conteo de `develop` al 6 de octubre da unas 346 pruebas (incluye las ~38 nuevas del Gateway) y las mismas 18 de integración.

---

## 4. Matriz de trazabilidad y paridad (SCRUM-1168)

Estados: **P** preservado si pasa · **C** construido y verificado (sin línea base) · **NP** no se preserva. Herramientas en la sección 8.

| Historia | Requisito | Criterio | Línea base | Comportamiento | Qué cambia | Prueba nueva (nivel, herramienta) | Tipo |
|---|---|---|---|---|---|---|---|
| US-02.1.1 | RF-05, RNF-01 | A1–A4, B1–B6 (PR #13) | `PLAN_REGRESION_US-02.1.1-M4.md` §6 | Ver sección 6.1 | `signUp` + RPC -> Core | Ver sección 6.1 | P/C según §6 de ese documento |
| US-02.1.2 | RF-05 | 1063 CA-1 | `registrar_aliado_empresa` | Aliado `PERSONA_JURIDICA` en `PENDIENTE` en su tenant | RPC -> Core | Integración (Testcontainers), contrato (Newman) | P |
| US-02.1.2 | RF-05, RNF-01 | 1063 CA-2, B6 | Caso 6 de `mani-aislamiento`; ADR-0013 | Documentos en bucket privado, aislados por tenant y aliado | `.storage.from()` -> Core | Newman, `qa/storage` | P |
| US-02.1.2 | RF-05 | 1063 CA-3 | Backlog_V3 §3 "Falta un documento exigido" | Rechazo sin registro parcial | La función vieja no validaba | Testcontainers, Newman | C |
| US-02.1.2 | RF-05 | 1063 CA-4 (pendiente) | `ON CONFLICT DO UPDATE` | Duplicado | Pasa de *upsert* a rechazo | Newman | C (cambio de comportamiento) |
| US-02.1.2 | — | 1060 CA-1, CA-2, CA-6, CC-2 | — | Cliente solo habla con el Gateway; tenant solo en `X-Tenant-Slug` | `.rpc()` -> HTTP | Unitaria Flutter (`registro_empresa_gateway_test.dart`) | C |
| US-02.1.3 | RF-06, RNF-01 | 1066 CA-1, CA-7 | Prueba de integración, `MANI-VER-404` | Bandeja solo del tenant; 404 entre tenants | `.rpc()` -> Core | Testcontainers, Newman | P |
| US-02.1.3 | RF-06 | 1066 CA-3, CA-4 | Prueba de integración, `MANI-VER-422M` | Aprobar; rechazar con motivo de 10 a 500 caracteres | `.rpc()` -> Core | Testcontainers, Newman | P |
| US-02.1.3 | RF-06, RNF-03 | **Sin criterio en PO-05** | Prueba de integración, `MANI-VER-409`, `FOR UPDATE` | Dos decisiones simultáneas: vale la primera, la segunda recibe conflicto, una sola notificación | Atomicidad en Core | Testcontainers con concurrencia | P (pendiente de criterio) |
| US-02.1.3 | RF-06 | 1066 CA-6 | Prueba de integración, `MANI-VER-403`; Backlog_V3 §3 | Solo `ADMIN_TENANT`; un aliado no se aprueba a sí mismo | `.rpc()` -> Core | Newman | P |
| US-02.1.3 | RF-06 | — | `MANI-VER-422K` | No se aprueba un aliado sin KYC | `.rpc()` -> Core | Testcontainers | P |
| US-02.1.3 | RNF-04 | 1066 CA-5 | Logs `US-02.1.3.resolver_verificacion` sin PII | Auditoría con quién, cuándo, decisión y `correlationId` | Auditoría en Core | Testcontainers, Newman | P (amplía) |
| US-02.1.3 | RF-06, RNF-01 | 1066 CA-2 | Caso 6 (URL firmada, TTL 60 s) | Acceso temporal a KYC solo para el admin del tenant | Core entrega el acceso (CFG-23a) | Newman | P |
| US-02.2.1 | RF-08 | 1064 CA-1 | `registrar_cliente_persona_natural` | `usuario` `CLIENTE` `ACTIVO` y `cliente` `PERSONA_NATURAL` en su tenant | RPC -> Core | Testcontainers, Newman | P |
| US-02.2.1 | RF-08 | 1064 CA-4 | Sin verificar: el datasource viejo no maneja el duplicado de forma explícita y depende de lo que responda `signUp` de Supabase Auth | Mensaje claro, sin segunda cuenta | Core | Newman, Playwright | C |
| US-02.2.1 | RF-08, RF-09 | — (punto abierto) | Sitio en "primera zona `ACTIVO`" | Creación del primer sitio | Por decidir | Testcontainers | Ver PA-21 |
| US-02.2.1 | RNF-01 | 1064 CC-1 | *Fallback* que escribe directo en `usuario` y `cliente` si la RPC falla | — | Se elimina | Inspección del datasource, captura de red | **NP** |
| US-02.2.1 | RNF-01 | 1064 CA-5 | `GRANT EXECUTE ... TO anon` | — | Registro solo por Core | Newman contra PostgREST tras retiro | **NP** |
| Todas | RNF-01 | CC-2, CC-3 | `mani-claims` vectores 1 a 4 | Tenant del claim, no del cliente; token alterado o ausente rechazado | Validación en el servicio | Newman | P |

---

## 5. Datos de prueba multi-tenant

**Seed:** `MANI-Flutter@develop`, `supabase/seed/seed_qa_multitenant.sql` y `database/init/08-seed-qa-multitenant.sql` (SCRUM-921, Finalizada). Verificación previa con `database/verify/09-test-tenant-isolation.sql`.

**Tenants:** dos tenants activos (`slug_t1`, `slug_t2`), un slug inexistente (`slug_inexistente`) y un tenant inactivo si existe en QA.

**Usuarios** (existen en `mani-aislamiento`): `aliado.t1`, `aliado.t2`, `admin.t1`, `admin.t2`, `cliente.t1`, `hook.t1` (segundo aliado del tenant 1). **Falta `cliente.t2`** (PA-10, pendiente de Daniel Ávila).

**Datos adicionales por historia:**

| Historia | Datos |
|---|---|
| US-02.1.1 | Los de `PLAN_REGRESION_US-02.1.1-M4.md` §3 |
| US-02.1.2 | Una empresa nueva por corrida en `slug_t1` (correo único por corrida), una empresa ya registrada en `slug_t1`, archivos PDF de Cámara de Comercio, RUT y cédula del representante |
| US-02.1.3 | En cada tenant: un aliado persona natural `PENDIENTE` con KYC, un aliado empresa `PENDIENTE` con KYC, un aliado `PENDIENTE` sin KYC, un aliado ya `VERIFICADO` |
| US-02.2.1 | Un cliente nuevo por corrida en `slug_t1`, un correo ya registrado en `slug_t1`, el mismo correo en `slug_t2` |

**Marcadores** (se completan cuando exista el contrato; no se inventan valores):

| Marcador | Significado | Se completa con |
|---|---|---|
| `{{url_gateway}}` | Base del Gateway en QA | `API_GATEWAY_URL` de Flutter |
| `{{ruta_registro_aliado}}` | Registro de persona natural. Provisional en PR #34: `/api/v1/core/aliados/persona-natural` | CFG-16 |
| `{{ruta_registro_empresa}}` | Registro de empresa. Provisional en `develop`: `/api/v1/core/aliados/empresa` | CFG-16 |
| `{{ruta_registro_cliente}}` | Registro de cliente | CFG-16 |
| `{{ruta_bandeja_verificacion}}`, `{{ruta_detalle_aliado}}`, `{{ruta_resolver_verificacion}}` | Endpoints de US-02.1.3 | CFG-16 (ampliado a US-02.1.3) |
| `{{ruta_acceso_documento}}` | Acceso temporal a un documento KYC | CFG-16 y CFG-23a (PA-09) |
| `{{codigo_rechazo}}` | Rechazo cross-tenant: 403 o 404, nunca 200 con datos | CFG-16 |
| `{{codigo_validacion}}` | Rechazo de validación: 400 según PO-05; la función vieja usaba 422 | CFG-16 |
| `{{codigo_conflicto}}` | Duplicado o decisión concurrente: 409 según PO-05 y la función vieja | CFG-16 |
| `{{formato_error}}` | Partida: `{ error, code?, correlationId }` (`CLAUDE.md` de `MANI-Node`, PA-17) | CFG-16 |
| `{{ttl_url_firmada}}` | Vida del acceso temporal (la colección vieja usa 60 s) | CFG-23a |

**Equivalencia con los marcadores de PR #13**, que están en camelCase: `urlGateway` -> `url_gateway`, `rutaRegistroAliado` -> `ruta_registro_aliado`, `rutaDocumentos` -> `ruta_documentos`, `rutaEstado` -> `ruta_estado`, `rutaAccesoDocumento` -> `ruta_acceso_documento`, `campoCorrelacion` -> `campo_correlacion`, `codigoRechazo` -> `codigo_rechazo`, `formatoError` -> `formato_error`, `ttlUrlFirmada` -> `ttl_url_firmada`, `slugT1` -> `slug_t1`, `slugT2` -> `slug_t2`, `slugInexistente` -> `slug_inexistente`. Se propone alinear PR #13 a `snake_case` en un cambio aparte.

---

## 6. Secciones por historia

Reglas comunes a todas las secciones:

- Cada caso lleva su identificador en el nombre de la prueba.
- Cada negativo (N) y cada caso cross-tenant (X) se ejecuta con su control positivo en la misma corrida. Un negativo cuyo control falló no cuenta como pasado.
- Rechazo cross-tenant: `{{codigo_rechazo}}` o ausencia de datos ajenos; nunca 200 con datos.
- Evidencia redactada con `qa/newman/redactar_evidencia.mjs`, sin JWT ni llaves, con enlace a la corrida de CI.
- Estado al 6 de octubre: **Ejecutable** (se puede correr hoy; no significa que ya se haya corrido), **Bloqueado** (con ticket) o **No ejecutable en el Sprint 3**. Ningún caso de este plan se ha ejecutado todavía.

### 6.1 US-02.1.1-M2/M3: registro de aliado persona natural (SCRUM-1065, SCRUM-1061)

**Fuente única.** Los criterios y los casos de esta historia viven en PR Trama-AS/MANI-docs#13:

- `product/CRITERIOS_ACEPTACION_US-02.1.1.md`: escenarios A1 a A4 (camino funcional) y B1 a B6 (los seis casos cross-tenant), §4.5 (herramienta por caso), §5 y §6.
- `product/PLAN_REGRESION_US-02.1.1-M4.md`: casos `rgA1P` a `rgB6`, juego de línea base y juego Gateway, §6 de paridad.

Este plan no reescribe esos casos. Solo agrega lo que falta para DOC-38:

| Campo | Contenido |
|---|---|
| Alcance | Registro de aliado persona natural con documentos KYC por Flutter -> Gateway -> Core (M2) y el datasource de Flutter (M3) |
| Precondiciones | CFG-16 publicado; endpoint de M2 desplegado en QA; CFG-22 y CFG-23b aplicados; PR #34 fusionado en `develop` |
| Datos | Sección 5 y `PLAN_REGRESION_US-02.1.1-M4.md` §3 |
| Positivos | `rgA1P`, `rgA3P1`, `rgA3P2`, `rgA4P` |
| Negativos | `rgA2N`, `rgA3N1`, `rgA3N2`, `rgA4N` y violaciones `rgA1V1`, `rgA1V2`, `rgA2V`, `rgA3V1`, `rgA3V2`, `rgA4V` |
| Cross-tenant propio | `rgB6` (KYC de otro tenant o aliado), más `rgB1` a `rgB5` |
| Criterio de salida | `PLAN_REGRESION_US-02.1.1-M4.md` §7 |

**Herramienta por nivel**

| Nivel | Herramienta | Qué cubre | Estado |
|---|---|---|---|
| Cliente Flutter | `flutter test` | `registro_aliado_gateway_test.dart` (PR #34): una petición al Gateway, ninguna a Supabase, multipart, tenant solo en `X-Tenant-Slug`, mensajes 400/409/5xx | Ejecutable en la rama del PR |
| Integración de Core | Testcontainers (QA-01) | Lógica de M2 contra Postgres real: aliado `PENDIENTE`, `usuario` con rol y tenant, documentos | Bloqueado: SCRUM-1065, SCRUM-1118 |
| Contrato Gateway–Core | Newman (QA-03) | `rgA1` a `rgA3`, `rgB1` a `rgB6` | Bloqueado: SCRUM-1099, SCRUM-1120 |
| End-to-end web | Playwright (QA-02) | `rgA1P`, `rgA4` con captura de red | Bloqueado: SCRUM-1119, CORS (sección 7) |
| UI móvil | Maestro (QAS-08) | Validaciones y errores del formulario | Sin herramienta: no hay ticket |
| Carga | k6 (QA-04) | Registro por el Gateway con 150 usuarios virtuales, p95 < 3 s (ADR-0022) | Bloqueado: SCRUM-1121 |
| Seguridad | OWASP ZAP (QA-05) | Escaneo del endpoint de registro | Bloqueado: SCRUM-1122 |

**Línea base ejecutable hoy:** `mani-aislamiento` y `mani-claims` en QA por el camino directo (`PLAN_REGRESION_US-02.1.1-M4.md` §8). Requiere credenciales de QA, que solo maneja el equipo.

### 6.2 US-02.1.2-M2/M3: registro de aliado empresa (SCRUM-1063, SCRUM-1060)

| Campo | Contenido |
|---|---|
| Alcance | Registro de aliado empresa con representante legal y documentos de la empresa por el Gateway (M2 en Core; M3 en Flutter, ya Finalizada) |
| Requisitos | RF-05, RNF-01, RNF-03 |
| Línea base | Sin prueba vieja propia. Criterios originales de `Backlog_V3.md` §3 (compartidos con US-02.1.1), caso 6 de `mani-aislamiento` y la función `registrar_aliado_empresa` |
| Precondiciones | CFG-16 con el endpoint de empresa; SCRUM-1063 desplegado en QA; CFG-22 y CFG-23b aplicados; bucket `kyc-documentos` con la política de ADR-0013 |
| Datos | Sección 5 |

**Casos** (resultado esperado escrito antes de ejecutar):

| Caso | Criterio | Pasos | Resultado esperado | Tipo | Estado |
|---|---|---|---|---|---|
| US0212-P1 | 1063 CA-1 | Enviar registro completo de una empresa nueva con `X-Tenant-Slug: slug_t1` a `{{ruta_registro_empresa}}` | Respuesta exitosa según CFG-16; en base: `usuario` con rol `ALIADO` y `aliado` `PERSONA_JURIDICA` en `PENDIENTE` con `tenant_id` del tenant 1; ninguna llamada de Core a `registrar_aliado_empresa` (ADR-0022) | P | Bloqueado: 1099, 1063 |
| US0212-P2 | 1063 CA-2 | Consultar `documento_kyc` y Storage tras US0212-P1 | Filas `PENDIENTE`, ruta dentro de la carpeta del tenant 1 y del aliado (formato según PA-04), bucket privado | P | Bloqueado: 1063, PA-04 |
| US0212-P3 | 1060 CA-1, CC-1 | Ejecutar `registro_empresa_gateway_test.dart` | Una sola petición, al Gateway; ninguna a Supabase | C | **Ejecutable** (`develop`) |
| US0212-P4 | 1060 CA-4 | Ejecutar el grupo "errores visibles" de la misma prueba | 400 muestra el campo faltante; 401 pide iniciar sesión; 409 informa empresa duplicada; 5xx sin detalles internos | C | **Ejecutable** (`develop`) |
| US0212-N1 | 1063 CA-3 | Registro sin Cámara de Comercio | `{{codigo_validacion}}` indicando el campo; ningún registro en `usuario`, `aliado` ni `documento_kyc` | C (la función vieja no validaba) | Bloqueado: 1063 |
| US0212-N2 | 1063 CA-4 | Registrar dos veces la misma empresa en `slug_t1` | `{{codigo_conflicto}}`; un solo `aliado`. **Cambio de comportamiento:** la función vieja hacía *upsert* | C | Bloqueado: 1063 y validación de la regla (PO) |
| US0212-N3 | CC-3 | Endpoint privado de la historia (consulta del registro) sin token y con token alterado | 401 (emisor según PA-16); no se devuelve dato | P | Bloqueado: 1099, 1102 |
| US0212-V1 | CC-2, 1060 CA-6 | Enviar `tenant_id` del tenant 2 en el cuerpo o en `X-Tenant-ID` con slug del tenant 1 | El registro queda solo en el tenant 1; el dato ajeno se ignora o se rechaza (PA-05) | P | Bloqueado: 1063 |
| US0212-X1 | 1063 CA-5, B1, B6 | `aliado.t2` y `admin.t2` consultan el registro y descargan documentos de la empresa del tenant 1 | `{{codigo_rechazo}}`, ningún dato; control: `admin.t1` sí accede | P | Bloqueado: 1063, 1103 |
| US0212-X2 | B6 (N6 de la colección) | `hook.t1` (otro aliado del mismo tenant) descarga documentos de la empresa | `{{codigo_rechazo}}`; control: la empresa accede a los suyos | P | Bloqueado: 1063, 1103 |

**Herramienta por nivel:** cliente Flutter con `flutter test` (P3, P4); Testcontainers (P1, P2, N1, N2); Newman (P1, N1 a N3, V1, X1, X2); Playwright para el recorrido web; Maestro para la UI móvil; k6 y ZAP comparten el escenario de registro de la sección 6.1.

**Criterio de salida:** todos los casos conformes con su resultado esperado y cada X con su control positivo. CA-4 queda fuera del criterio de salida hasta que el PO confirme la regla.

### 6.3 US-02.1.3-M2: aprobar o rechazar el registro de aliado (SCRUM-1066)

**No ejecutable en el Sprint 3.** SCRUM-1066 no tiene sprint asignado y `product/BACKLOG_MANI.md` §3.4 la deja para Incremento 2 "por capacidad, no por dependencia técnica". La sección queda completa para que la regresión esté lista cuando entre.

| Campo | Contenido |
|---|---|
| Alcance | Bandeja de verificación, detalle con documentos KYC, aprobación y rechazo, por Gateway y Core |
| Requisitos | RF-06, RNF-01, RNF-03, RNF-04 |
| Línea base | `test/integration/verificacion_aliados_us0213_test.dart` y las funciones de `database/migrations/002_verificacion_aliados.sql`. Criterios originales de `Backlog_V3.md` §3 |
| Precondiciones | Endpoints de la historia en el contrato; SCRUM-1066 desplegado; CFG-23a define el acceso temporal a KYC; CFG-22 aplicado |
| Datos | Sección 5 |

**Comportamientos de la prueba vieja que se preservan** (son el resultado esperado):

| Caso | Prueba vieja | Criterio | Resultado esperado por el camino nuevo | Estado |
|---|---|---|---|---|
| US0213-P1 | "flujo completo" | CA-1 | `admin.t1` ve solo los aliados `PENDIENTE` del tenant 1; el aliado del tenant 2 no aparece | No ejecutable en el Sprint 3 |
| US0213-P2 | "flujo completo" (FIFO) | — | La bandeja se ordena de mayor a menor tiempo de espera | No ejecutable en el Sprint 3 |
| US0213-P3 | "flujo completo" (KYC) | CA-2 | El detalle lista los documentos del aliado y Core entrega un acceso temporal (`{{ruta_acceso_documento}}`, `{{ttl_url_firmada}}`) | No ejecutable; además PA-09 |
| US0213-P4 | "flujo completo" (aprobar) | CA-3 | El aliado pasa a `VERIFICADO` y recibe una notificación | No ejecutable en el Sprint 3 |
| US0213-P5 | "flujo completo" (rechazar) | CA-4 | Con motivo de 10 a 500 caracteres, el aliado pasa a `RECHAZADO` con el motivo guardado | No ejecutable en el Sprint 3 |
| US0213-P6 | "flujo completo" (logs) | CA-5 | Se registran quién, cuándo, la decisión y el `correlationId`; el log no contiene el correo del aliado | No ejecutable en el Sprint 3 |
| US0213-N1 | `MANI-VER-422M` | CA-4 | Motivo vacío o de menos de 10 caracteres: `{{codigo_validacion}}`; el estado no cambia | No ejecutable en el Sprint 3 |
| US0213-N2 | `MANI-VER-422K` | — | Aprobar un aliado sin KYC: `{{codigo_validacion}}`; el estado no cambia | No ejecutable en el Sprint 3 |
| US0213-N3 | "dos administradores deciden a la vez" | **Sin criterio** (PA-18) | Dos decisiones simultáneas sobre el mismo aliado: exactamente una se confirma, la otra recibe `{{codigo_conflicto}}`, la decisión ganadora no se sobrescribe y el aliado recibe una sola notificación | No ejecutable en el Sprint 3 |
| US0213-N4 | `MANI-VER-409` | — | Decidir sobre un aliado ya resuelto: `{{codigo_conflicto}}` | No ejecutable en el Sprint 3 |
| US0213-N5 | "usuario que no es ADMIN_TENANT" | CA-6 | `aliado.t1` o `cliente.t1` intenta listar, aprobar o rechazar: 403; el estado no cambia | No ejecutable en el Sprint 3 |
| US0213-N6 | Backlog_V3 "aliado intenta aprobarse a sí mismo" | CA-6 | 403; el estado no cambia | No ejecutable en el Sprint 3 |
| US0213-N7 | "sesión expirada" | CC-3 | Token expirado: 401 (emisor según PA-16); la app pide iniciar sesión | No ejecutable en el Sprint 3 |
| US0213-N8 | "documento que no está en Storage" | — | Documento registrado sin archivo en Storage: la app muestra un mensaje claro y no se queda cargando | No ejecutable en el Sprint 3 |
| US0213-X1 | `MANI-VER-404`, Backlog_V3 "admin de otro tenant" | CA-7 (crítico, KI-05) | `admin.t2` intenta listar, ver documentos, aprobar o rechazar un aliado del tenant 1: `{{codigo_rechazo}}`, ningún dato, el estado no cambia. Control: `admin.t1` sí puede | No ejecutable en el Sprint 3 |
| US0213-X2 | Caso 6 N1b, N2b | CA-7 | `admin.t2` usa un acceso temporal emitido para el tenant 1: rechazado | No ejecutable; además PA-09 |

**Herramienta por nivel**

| Nivel | Herramienta | Casos |
|---|---|---|
| Integración de Core | Testcontainers (QA-01) | P1, P4, P5, N1 a N4 (N3 con dos transacciones concurrentes), X1 |
| Contrato | Newman (QA-03) | P1, P3, N1, N2, N4 a N7, X1, X2 |
| End-to-end web | Playwright (QA-02) | Recorrido de la bandeja del Backoffice (descrito en QA-02) |
| UI móvil | Maestro (QAS-08) | Confirmación del rechazo y validación del motivo |
| Cliente Flutter | `flutter test` | Las pruebas de dominio y presentación se mantienen; datasource y repositorio se reescriben (sección 2) |

**Criterio de salida:** los 16 casos conformes; N3 obligatorio aunque PO-05 no lo exija, porque es una regla ya verificada (paridad). Hasta que eso ocurra, `listar_aliados_verificacion`, `obtener_aliado_verificacion` y `resolver_verificacion_aliado` no se retiran.

**Deuda registrada:** reescribir `test/features/profiles/verification/fakes.dart` y `data/repository_impl_test.dart` contra el error HTTP, a cargo de quien implemente el datasource de US-02.1.3.

### 6.4 US-02.2.1-M2: registro de cliente persona natural (SCRUM-1064)

| Campo | Contenido |
|---|---|
| Alcance | Registro de cliente persona natural por Gateway y Core, incluido su datasource en Flutter |
| Requisitos | RF-08, RNF-01 |
| Línea base | Sin prueba vieja propia ni criterio original en `Backlog_V3.md` §3. Línea base: la función `registrar_cliente_persona_natural` y el comportamiento de Supabase Auth ante correo duplicado |
| Precondiciones | Endpoint de registro de cliente en CFG-16 (hoy CFG-16 está acotado a identidad y registro de aliado); SCRUM-1064 desplegado; CFG-22 aplicado |
| Datos | Sección 5 |

| Caso | Criterio | Resultado esperado | Tipo | Estado |
|---|---|---|---|---|
| US0221-P1 | CA-1 | Registro válido con `X-Tenant-Slug: slug_t1`: `usuario` `CLIENTE` `ACTIVO` y `cliente` `PERSONA_NATURAL` en el tenant 1; Core no invoca `registrar_cliente_persona_natural` | P | Bloqueado: 1064, 1099 |
| US0221-P2 | CA-2 | El registro usa el endpoint de identidad y el cliente HTTP de US-02.1.1 (revisión del PR) | C | Bloqueado: 1064 |
| US0221-P3 | CA-3, CC-1 | El datasource de registro de cliente no contiene `.rpc()` ni `.from()`; captura de red: ninguna petición a Supabase salvo la excepción de Auth (PA-07) | C | Bloqueado: 1064 |
| US0221-N1 | CA-4 | Correo ya registrado en `slug_t1`: mensaje claro, sin segunda cuenta | C (línea base sin verificar) | Bloqueado: 1064 |
| US0221-N2 | CC-3 | Endpoint privado del cliente sin token o con token alterado: 401 | P | Bloqueado: 1099, 1102 |
| US0221-N3 | — | `slug_inexistente`: rechazo sin crear usuario (la función vieja lanzaba excepción si el tenant no existía) | P | Bloqueado: 1064 |
| US0221-V1 | CA-5, CC-2 | Enviar `tenant_id` del tenant 2 en el cuerpo con slug del tenant 1: la cuenta queda solo en el tenant 1 | P | Bloqueado: 1064 |
| US0221-X1 | CA-5 | `cliente.t1` consulta datos del tenant 2 (perfil, sitios): `{{codigo_rechazo}}`, ningún dato. Control: `cliente.t2` consulta los suyos | P | Bloqueado: 1064 y `cliente.t2` (PA-10) |

**Comportamientos que no se preservan**

| Comportamiento viejo | Motivo |
|---|---|
| *Fallback* de `auth_remote_data_source.dart`: si la RPC falla, el cliente escribe directo en `usuario` y `cliente` | Viola CC-1 y la decisión de ADR-0022 |
| `GRANT EXECUTE ON FUNCTION registrar_cliente_persona_natural TO anon` | Permite registrar con `p_usuario_id` y `p_tenant_id` arbitrarios sin pasar por Core. Al retirar la función debe retirarse el permiso; se verifica con una petición directa a PostgREST que debe fallar |

**Punto abierto PA-21:** la función vieja crea el primer `sitio` en "la primera zona `ACTIVO`" sin filtrar por tenant (según lectura). El PO decide si Core conserva la creación del sitio; si la conserva, la zona debe ser del tenant del cliente.

**Herramienta por nivel:** Testcontainers (P1, N3, V1); Newman (P1, N1 a N3, V1, X1); Playwright y Maestro para el formulario; `flutter test` para el datasource nuevo.

**Criterio de salida:** todos los casos conformes y los dos comportamientos no preservados verificados como ausentes.

---

## 7. Pruebas de conexión y API del camino nuevo (SCRUM-1171)

Verifican que el camino existe antes de probar historias. Fuente: `MANI-APIGateway@main` (`nginx.conf`, `CLAUDE.md`), `MANI-Node@main`, `architecture/COMUNICACION_SERVICIOS_GATEWAY.md`.

CX-01 a CX-10 y CX-13 se ejecutaron el 6 de octubre en un **ambiente local** (docker-compose de `MANI-APIGateway`), no en QA. Los resultados esperados se escribieron antes de ejecutar. El detalle está en el anexo A. Un resultado local no sustituye la corrida en QA: confirma el comportamiento del código de `main`.

| Caso | Qué se verifica | Resultado esperado | Herramienta | Estado |
|---|---|---|---|---|
| CX-01 | Salud del Gateway: `GET {{url_gateway}}/health` | 200 con `{"status":"UP","gateway":"MANI-APIGateway",...}` | Newman | Local: **conforme**. QA: Gateway desplegado sin confirmar |
| CX-02 | Salud de Core a través del Gateway: `GET {{url_gateway}}/api/v1/core/health` | 200 desde Core con el `correlationId` recibido | Newman | Local: **conforme**. QA: idem |
| CX-03 | Enrutamiento y recorte de prefijo: `/api/v1/core/<ruta>` llega a Core como `/<ruta>` (`proxy_pass .../`) | La ruta responde desde Core; una ruta inexistente responde 404 de Core, no del Gateway | Newman | Local: **conforme** (Core registra `/aliados/empresa`). Las rutas provisionales de registro responden 404 porque Core aún no las implementa. Rutas del contrato: bloqueado por CFG-16 |
| CX-04 | Salud de Rules y Dispatch: `/api/v1/rules/health`, `/api/v1/dispatch/health` | 200 desde cada servicio | Newman | Local: **conforme**. Dispatch responde por un `/health` adicional de `Program.cs`, no por su controlador (ver CX-13) |
| CX-05 | Reenvío del token: `Authorization: Bearer` llega a Core | Con encabezado, Core responde; el Gateway no lo modifica ni lo valida | Newman | Local: **conforme**. Con un token inválido cualquiera, Core responde 200: hoy solo verifica que el encabezado exista (PA-16) |
| CX-06 | Quién rechaza un token inválido | 401 en un endpoint privado; se registra si lo emite Core o el Gateway (PA-16) | Newman | Local, parcial: sin encabezado, el 401 lo emite **Core**. Token inválido: no se rechaza (CX-05). Validación real: bloqueado por CFG-22 |
| CX-07 | Propagación de `X-Correlation-ID` enviado por el cliente | El mismo valor vuelve en la respuesta y aparece en el log de Core | Newman | Local: **conforme**. El encabezado sale duplicado en la respuesta (PA-27) |
| CX-08 | Generación de `X-Correlation-ID` si el cliente no lo envía | La respuesta trae un identificador generado por NGINX (`$request_id`) y Core recibe el mismo | Newman | Local: **conforme**. El log de acceso del Gateway registra ese caso con el campo vacío (PA-27) |
| CX-09 | Formato de error | Los errores de Core siguen `{{formato_error}}` | Newman | Local: **no conforme** con el `CLAUDE.md` de Core: `{"error":"..."}` sin `correlationId` (PA-17). Formato definitivo: CFG-16 |
| CX-10 | CORS del build web | El preflight `OPTIONS` del registro permite `Authorization`, `Content-Type`, `X-Correlation-ID`, `X-Tenant-Slug` e `Idempotency-Key` | Playwright, Newman con `OPTIONS` | Local: **no conforme**. `Access-Control-Allow-Headers` devuelve solo `Authorization, Content-Type, X-Correlation-ID, X-Tenant-ID`; un navegador bloquearía el registro desde Flutter Web (PA-19) |
| CX-13 | Rutas de negocio de Rules y Dispatch a través del Gateway | `POST /api/v1/rules/evaluate-rate` y `POST /api/v1/dispatch/match` llegan a su controlador | Newman | Local: **no conforme**. Ambas responden 404: el Gateway recorta el prefijo y los controladores de Java y .NET esperan la ruta completa (PA-26). No afecta a EP-02; afecta a Incremento 2 y a QAS-06 |
| CX-11 | Contrato Gateway–Core | Cada endpoint de las historias cumple el OpenAPI de CFG-16 en códigos, campos obligatorios y tipos (QAS-06) | Newman | Bloqueado: CFG-16, QA-03 |
| CX-12 | Solo Gateway desde el cliente | Captura de red del build web: ninguna petición a `/rest/v1` ni `/storage/v1`; el bundle no contiene `SUPABASE_ANON_KEY` (excepción de Auth según PA-07); la llave anterior ya no es aceptada por PostgREST. Es la misma verificación que pide CFG-36.1 (SCRUM-1228) antes de rotar | Playwright, inspección del bundle, Newman | Bloqueado: CFG-35 (SCRUM-1112, Daniel), CFG-36 (SCRUM-1113, Juan), PA-07 |

Notas:
- El Gateway no tiene ruta para un servicio de disponibilidad; no afecta a estas historias.
- `COMUNICACION_SERVICIOS_GATEWAY.md` nombra `MANI-Rules-Java` y `MANI-Dispatch-DotNet`; los repositorios reales son `MANI-Java` y `MANI-.NET`.

---

## 8. Herramienta por nivel

Coherente con `product/BACKLOG_MANI.md` §4.1 y con el punto 8 del SDD (PR #14).

| Nivel | Herramienta | Ticket | Responsable | Estado de Jira | Uso en este plan |
|---|---|---|---|---|---|
| Cliente Flutter | `flutter test` con cliente HTTP falso | — | Cada desarrollador | Disponible | Comportamiento del cliente; no es evidencia de paridad de reglas de Core |
| Integración de Core con Postgres real | Testcontainers | QA-01 (SCRUM-1118) | José Nicolás Álvarez | Tareas por hacer | Reglas de negocio, atomicidad, persistencia |
| Contrato Gateway–Core | Postman + Newman | QA-03 (SCRUM-1120) | Juan Sebastián Álvarez | Tareas por hacer | Contrato, seis casos cross-tenant, conexión (QAS-01, QAS-06) |
| End-to-end del **build web** | Playwright | QA-02 (SCRUM-1119) | José Nicolás Álvarez | En revisión; al 6 oct no se encontró código de Playwright en las ramas remotas de los repositorios de Trama-AS | Recorridos web, captura de red, CORS |
| Flujos de pantalla de la **app móvil** | Maestro | Sin ticket | — | — | QAS-08: validaciones, confirmaciones y errores accionables |
| Carga, 150 usuarios | k6 | QA-04 (SCRUM-1121) | Nicolás León | Tareas por hacer | Registro por el Gateway, p95 < 3 s (ADR-0022) |
| Seguridad dinámica | OWASP ZAP | QA-05 (SCRUM-1122) | Nicolás León | Tareas por hacer | Gate de ADR-0005 |
| RLS como defensa adicional | Newman (colección vieja) y `database/verify` | — | QA | Disponible en QA | Sección 2 |

Playwright y Maestro no se contradicen: Playwright cubre el build web (QA-02) y Maestro la app móvil (QAS-08). Un nivel sin herramienta entregada se reporta como "sin herramienta disponible", nunca como cubierto.

---

## 9. Criterios de entrada y salida

**Entrada** (por historia): contrato de CFG-16 con sus endpoints; servicio desplegado en QA; cadena de identidad (CFG-22) y políticas del modelo nuevo (CFG-23b) aplicadas; seed verificado con `database/verify/09`; herramienta del nivel entregada.

**Salida** (por historia):

1. El 100 % de los comportamientos marcados P de la sección 4 pasa por el camino nuevo con su resultado esperado.
2. El 100 % de los negativos y cross-tenant pasa con su control positivo exitoso en la misma corrida.
3. Los comportamientos NP se verifican como ausentes.
4. Los Quality Gates mínimos de ADR-0005 se cumplen o la excepción queda documentada: 0 vulnerabilidades Blocker/Critical; 0 vulnerabilidades High conocidas abiertas; cobertura de código nuevo >= 80 %; cobertura de casos críticos >= 90 %; duplicación de código nuevo < 3 %. Las vulnerabilidades se toman de SonarQube (SAST) y OWASP ZAP (DAST). `MANI-Node` y `MANI-APIGateway` aún no tienen proyecto en SonarQube: mientras no se cumplan CFG-41 (SCRUM-1116, Santiago) y CFG-40 (SCRUM-1115, Nicolás León), los gates que dependen de SonarQube se reportan como "no medibles" para Core y para el Gateway, nunca como cumplidos.
5. Cualquier diferencia se registra como defecto en Jira con el identificador del caso; un defecto bloqueante impide cerrar la historia.

**Autorización de retiro (ADR-0022):** una función PL/pgSQL solo queda autorizada para retirarse cuando todos los comportamientos P que dependen de ella cumplen los puntos 1 a 3. El reporte lo declara función por función.

---

## 10. Estado de ejecución al cierre del Sprint 3

Corte: 6 de octubre de 2026. Se actualiza solo lo que cambie antes del cierre (7 de octubre, 6 p. m., hora de Bogotá).

| Grupo | Ejecutable hoy | Bloqueado por |
|---|---|---|
| Línea base por camino directo (`mani-aislamiento`, `mani-claims`) | Sí, en QA, con credenciales del equipo | — |
| Cliente Flutter (US0212-P3, US0212-P4; prueba de PR #34) | Sí | — |
| US-02.1.1 por Gateway | No | CFG-16 (SCRUM-1099, Juan), M2 (SCRUM-1065, Juan), CFG-22 (SCRUM-1102, Daniel), CFG-23a/b (SCRUM-1103 Juan, SCRUM-1104 Daniel) |
| US-02.1.2 por Gateway | No | CFG-16, M2 (SCRUM-1063, Nicolás León), CFG-22, CFG-23 |
| US-02.1.3 | No | Fuera del Sprint 3 (SCRUM-1066, Nicolás León) |
| US-02.2.1 | No | CFG-16 no incluye el registro de cliente, M2 (SCRUM-1064, Juan) |
| Conexión (CX-01 a CX-13) | Ejecutados en local el 6 oct: CX-01 a CX-05, CX-07 y CX-08 conformes; CX-09, CX-10 y CX-13 no conformes; CX-06 parcial (anexo A). En QA, no | QA: Gateway y Core desplegados en QA, CFG-16, CFG-22. CX-11: CFG-16, QA-03. CX-12: CFG-35, CFG-36 |
| Niveles QA-01 a QA-05 y Maestro | No | Herramientas sin entregar (sección 8) |

**Declaración:** al corte, el criterio de salida de la sección 9 **no se alcanzó** para ninguna historia. Ninguna función PL/pgSQL queda autorizada para retirarse. Este plan cumple su función como insumo previo a la ejecución; los resultados corresponden a DOC-24, US-02.1.1-M4 y las tareas QA-01 a QA-05.

---

## 11. Puntos abiertos y responsables

Los identificadores PA-01 a PA-17 son los de `product/CRITERIOS_ACEPTACION_US-02.1.1.md` (PR #13). Los nuevos empiezan en PA-18.

| ID | Punto | Afecta a | Responsable |
|---|---|---|---|
| PA-01 | Fecha del contrato de CFG-16; incluir endpoints de empresa, cliente y verificación | Todas las rutas y códigos | Juan Sebastián Álvarez |
| PA-03 | Documentos obligatorios y si la lista sale de Core o del servicio de reglas | US0212-N1, rgA2N | Nicolás León, Juan Sebastián Álvarez |
| PA-04 | Formato de ruta de Storage (`aliado_id` frente a `uid`) | US0212-P2, rgB6 | María Camila Beltrán |
| PA-05 | Tenant ajeno en el cuerpo: ignorar o rechazar | US0212-V1, US0221-V1 | Sara Albarracín, María Camila Beltrán |
| PA-07 | Excepción de Supabase Auth en el cliente. CFG-35 conserva Auth en Flutter y CFG-36 retira la llave pública del bundle web; queda por definir con qué credencial llama el cliente a Supabase Auth si la llave ya no está | CX-12, US0221-P3 | Daniel Ávila (CFG-35), Juan Sebastián Álvarez (CFG-36) |
| PA-08 | Control positivo de B3 y B4 | rgB3, rgB4 | Nicolás León |
| PA-09 | Mecanismo y TTL del acceso temporal a KYC | US0213-P3, US0213-X2, rgB6 | Juan Sebastián Álvarez (CFG-23a) |
| PA-10 | Falta `cliente.t2` en QA; crearlo requiere acceso al Supabase de QA | US0221-X1, rgB* | Daniel Ávila |
| PA-13 | Regresión de US-02.1.2 y US-02.2.1, que no tienen tarea propia (backlog §3.6) | Secciones 6.2 y 6.4 | Nicolás León (PO) |
| PA-16 | Quién valida el JWT y devuelve el 401: el `CLAUDE.md` del Gateway dice que no lo valida; PO-05 CC-3 dice que el Gateway responde 401. **Confirmado en local (CX-05, CX-06):** el Gateway no valida y el 401 lo emite Core, que hoy solo verifica que el encabezado exista | CX-06, N de token | Daniel Ávila, Juan Sebastián Álvarez |
| PA-17 | Formato de error y nombre del campo de correlación. **Confirmado en local (CX-09):** el 404 de Core devuelve `{"error":"..."}` sin `correlationId`, distinto de su `CLAUDE.md` | CX-09 | Juan Sebastián Álvarez |
| PA-18 | El 409 por decisión concurrente no está en los criterios PO-05 de SCRUM-1066 | US0213-N3 | Nicolás León, María Camila Beltrán |
| PA-19 | CORS: `X-Tenant-Slug` e `Idempotency-Key` no están en `Access-Control-Allow-Headers`. **Confirmado en local (CX-10)** | CX-10, Playwright | Daniel Ávila |
| PA-20 | Maestro no tiene ticket en Jira | Nivel UI móvil | Sara Albarracín |
| PA-21 | Creación del primer sitio del cliente en "la primera zona activa" sin filtro de tenant | US-02.2.1 | Nicolás León |
| PA-22 | Duplicado de empresa: la función vieja hace *upsert*; CA-4 pide 409 | US0212-N2 | Nicolás León |
| PA-23 | `Inf_test-002` salió del árbol en la reestructuración (`cc28e0c`, 2026-09-30), aunque DD_V2, SAD_V3 y SDD_V1 lo citan. Decidir si se restaura junto a `Inf_test-001` | Sección 3.4 | Santiago, Sara Albarracín |
| PA-24 | `product/BACKLOG_MANI.md` §3.5 y la wiki (SP-05 abierto) contradicen ADR-0022 | Trazabilidad | María Camila Beltrán |
| PA-25 | Destino del documento: la carpeta `quality/` que indica el ticket no existe | Publicación | Sara Albarracín |
| PA-26 | Las rutas de negocio de Rules y Dispatch responden 404 a través del Gateway: `proxy_pass` recorta `/api/v1/rules/` y `/api/v1/dispatch/`, y los controladores de Java y .NET esperan la ruta completa (CX-13). Solo responde el `/health` | CX-13, Incremento 2, QAS-06 | Daniel Ávila (Gateway) y responsables de `MANI-Java` y `MANI-.NET` |
| PA-27 | Trazabilidad del correlation ID: el encabezado `X-Correlation-ID` sale duplicado en las respuestas de Core (lo agregan NGINX y Core), y el log de acceso del Gateway usa `$http_x_correlation_id`, por lo que el identificador que genera NGINX queda vacío en su log (RNF-04) | CX-07, CX-08 | Daniel Ávila |
| PA-28 | El `Dockerfile` de `MANI-Java` no construye en equipos ARM (Apple Silicon): `eclipse-temurin:17-jre-alpine` no publica imagen para esa plataforma. En local se construyó con `--platform linux/amd64` | Anexo A, QA-01 | Responsables de `MANI-Java` |

Si se agregan puntos abiertos en `CRITERIOS_ACEPTACION_US-02.1.1.md` (PR #13), su numeración continúa en PA-29 para no repetir identificadores.

---

## 12. Trazabilidad con Jira

| Ticket | Relación con este plan |
|---|---|
| SCRUM-1094 (DOC-38) | Este documento |
| SCRUM-1167 (DOC-38a) | Secciones 2 y 3 |
| SCRUM-1168 (DOC-38b) | Secciones 4 y 5 |
| SCRUM-1169 (DOC-38c) | Secciones 6.1 y 6.2 |
| SCRUM-1170 (DOC-38d) | Secciones 6.3 y 6.4 |
| SCRUM-1171 (DOC-38e) | Secciones 7, 8 y 9 |
| SCRUM-1172 (DOC-38f) | Revisión y publicación |
| SCRUM-1062, 1184 a 1188 (US-02.1.1-M4) | Ejecutan la sección 6.1 |
| SCRUM-1105 (CFG-23c) | Comparte los seis casos cross-tenant |
| SCRUM-1118 a 1122 (QA-01 a QA-05) | Herramientas por nivel |
| SCRUM-1099, 1102, 1103, 1104 | Precondiciones de entrada |
| SCRUM-1112 (CFG-35), SCRUM-1113 y 1228 a 1230 (CFG-36) | Precondición de CX-12 y de reorientar `mani-aislamiento` (sección 2) |
| DOC-24 | Informe de resultados que se compara contra este plan |

---

## Anexo A. Ejecución local de las pruebas de conexión (6 de octubre de 2026)

**Ambiente:** local, no QA. `docker compose up` desde `MANI-APIGateway@main` (`e312793`), con imágenes construidas desde `MANI-Node@main` (`07069d3`), `MANI-Java@main` (`ae5d6ce`) y `MANI-.NET@main` (`e2e8370`). Docker 29.8.1 sobre macOS ARM; la imagen de Java se construyó con `--platform linux/amd64` (PA-28). Hora de la corrida: 2026-10-06T19:22Z. `base_url = http://localhost:80`.

Los resultados esperados se escribieron antes de ejecutar. La corrida no usó tokens reales ni credenciales: el único token enviado fue el texto `token_de_prueba_invalido`.

| Caso | Petición (`curl -i`) | Esperado | Obtenido |
|---|---|---|---|
| CX-01 | `GET {base_url}/health` | 200, `UP` | 200, `{"status":"UP","gateway":"MANI-APIGateway",...}` |
| CX-02 | `GET /api/v1/core/health` | 200 desde Core | 200, `"service":"MANI-Core-Node"`, `correlationId` igual al encabezado |
| CX-03a | `GET /api/v1/core/tenants` | 200 desde Core | 200, datos de ejemplo |
| CX-03b | `GET /api/v1/core/no-existe` | 404 de Core | 404, `{"error":"Ruta no encontrada en MANI-Core-Node"}` |
| CX-03c | `POST /api/v1/core/aliados/persona-natural` | 404 (ruta no implementada) | 404 de Core; el log de Core registra `/aliados/persona-natural` |
| CX-03d | `POST /api/v1/core/aliados/empresa` | 404 (ruta no implementada) | 404 de Core; el log de Core registra `/aliados/empresa` |
| CX-04a | `GET /api/v1/rules/health` | 200 | 200, `"service":"MANI-Rules-Java"` |
| CX-04b | `GET /api/v1/dispatch/health` | 404 (según lectura del controlador) | **200**, `"service":"MANI-Dispatch-DotNet"`, servido por el `MapGet("/health")` de `Program.cs`. El esperado estaba mal planteado; ver CX-13 |
| CX-05a | `GET /api/v1/core/profiles/me` sin `Authorization` | 401 de Core | 401, `{"error":"Encabezado Authorization requerido"}` |
| CX-05b | Igual, con `Authorization: Bearer token_de_prueba_invalido` | 200 (Core no valida) | 200, perfil de ejemplo |
| CX-07 | `GET /api/v1/core/health` con `X-Correlation-ID: cx-07-prueba` | Se propaga | Respuesta y cuerpo con `cx-07-prueba`; log de Core y del Gateway con el mismo valor. Encabezado duplicado en la respuesta |
| CX-08 | `GET /api/v1/core/health` sin el encabezado | NGINX lo genera y Core lo recibe | Identificador de 32 caracteres hexadecimales en la respuesta y en el cuerpo de Core; el log del Gateway lo registra vacío |
| CX-09 | Cuerpo de CX-03b | Sin `correlationId` | `{"error":"..."}` sin `correlationId` |
| CX-10 | `OPTIONS /api/v1/core/aliados/empresa` con `Access-Control-Request-Headers: authorization,content-type,x-correlation-id,x-tenant-slug,idempotency-key` | 204 sin `X-Tenant-Slug` | 204, `Access-Control-Allow-Headers: Authorization, Content-Type, X-Correlation-ID, X-Tenant-ID` |
| CX-13 | `POST /api/v1/rules/evaluate-rate` y `POST /api/v1/dispatch/match` | Llegan al controlador | 404 en ambos; Java informa `"path":"/evaluate-rate"` |

No se ejecutaron en local: CX-06 con un JWT real (requiere CFG-22), CX-11 (requiere CFG-16) ni CX-12 (requiere CFG-35 y CFG-36). Ningún caso de historia de la sección 6 se ejecutó.

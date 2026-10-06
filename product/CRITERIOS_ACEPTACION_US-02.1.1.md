# Criterios de aceptación de US-02.1.1 sobre el camino Gateway - Core

| Campo | Valor |
|---|---|
| Historia | US-02.1.1 - Registro de aliado persona natural con KYC (SCRUM-846, RF-05) |
| Tarea | SCRUM-1076 (PO-01), subtareas SCRUM-1126 (PO-01a), SCRUM-1127 (PO-01b), SCRUM-1128 (PO-01c) y SCRUM-1129 (PO-01d) |
| Camino de la arquitectura | Flutter -> NGINX Gateway -> Core Node -> funciones PL/pgSQL en Supabase |
| Autor | Santiago (QA) |
| Fecha | 6 de octubre de 2026 (actualizado tras sincronizar los siete repositorios) |
| Estado | Borrador. DoR y DoD de M4 definidos por QA. DoR y DoD de M1 a M3 en propuesta, pendientes de sus responsables. Escenarios BDD condicionales a la confirmación de la Scrum Master. Validación del PO y revisión del par técnico pendientes (SCRUM-1130). Publicación pendiente (SCRUM-1131) |
| Alimenta a | SCRUM-1062 (US-02.1.1-M4), SCRUM-1094 (DOC-38) y SCRUM-1105 (CFG-23c) |

## 1. Alcance y fuentes verificadas

Este documento reescribe los criterios de aceptación de US-02.1.1 para un llamador que es un servicio, fija los seis casos cross-tenant como condición de aceptación y propone el DoR y el DoD de los cuatro pasos de migración (M1 a M4). Los criterios se redactan en formato BDD. Según el Backlog V3 (sección 3), cada criterio lleva un caso positivo, uno negativo y un intento de violar la regla crítica.

Autoridad de decisión (`governance/GOBIERNO_DEL_EQUIPO.md`, sección 2.3): el PO decide los criterios de aceptación y QA decide el DoD. Por eso los criterios requieren validación del PO, y los DoR y DoD de los pasos que pertenecen a otros responsables se presentan como propuesta.

| Fuente | Estado de la lectura | Observación relevante |
|---|---|---|
| `wiki/05-proceso/dor-y-dod.md` | Leída en `origin/main` (`3fd4473`) | DoR y DoD oficiales. Exige que toda historia que toque autenticación, tenant, RLS, endpoints de datos o Storage demuestre los seis casos cross-tenant con rechazo o ausencia de datos |
| `governance/GOBIERNO_DEL_EQUIPO.md`, secciones 2.3, 8 y 9 | Leídas | El DoD lo decide QA. El DoR exige spike bloqueante cerrado |
| `governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`, sección 13.4 | Leída | Define los seis casos |
| `product/BACKLOG_MANI.md` | Leído | Única fuente del backlog. M1 no figura como paso propio: lo sustituye CFG-16 |
| `architecture/COMUNICACION_SERVICIOS_GATEWAY.md` | Leída | Rutas `/api/v1/core\|rules\|dispatch/*`. Cada servicio inspecciona el JWT para extraer `user_id` y `tenant_id`. Availability no aparece en la matriz de rutas |
| `ADR/ADR-0015` (Propuesto), `ADR-0013` (Propuesto), `ADR-0005` (Aceptado), `ADR-0018` (Aceptado) | Leídos | ADR-0015 exige 100 % de rechazo cross-tenant. ADR-0005 fija los gates (ver sección 4) |
| `product/SRS.md`: RF-02, RF-03, RF-05, RNF-01, RNF-04, REST-02 | Leídos | RF-05 exige documentos según la configuración del tenant y aislados por aliado y tenant |
| `Entregas/Entrega4/Backlog_V3.md`, sección 3 | Leída | Tres escenarios originales de US-02.1.1 y US-02.1.2, pendientes de validación del PO |
| `wiki/02-arquitectura/riesgos-y-puntos-abiertos.md` | Leída | SP-05 abierto; riesgos CFG-23 y CFG-36 |
| `ADR-0022` (rama `SCRUM-1075-adr-0022`, `aa6d464`, no fusionada) | Leído, estado Propuesto | Decide que la lógica de negocio vive en los servicios y que las funciones PL/pgSQL se retiran después de que la regresión en QA (SCRUM-1062) confirme el reemplazo. Contradice la lectura "los servicios invocan las funciones existentes". No es una decisión vigente hasta que se acepte |
| `MANI-Flutter/qa/newman/` | Leída en `develop` (sin cambios frente a `main`) | Colecciones `mani-aislamiento` y `mani-claims`. Atacan Supabase directo |
| Contrato OpenAPI de CFG-16 (SCRUM-1099) | No existe | No hay archivos OpenAPI en los repositorios revisados. Rutas y códigos quedan atados a SCRUM-1099 (PA-01) |
| `MANI-Node` y `MANI-APIGateway` (carpeta local `MANI-API`) | Leídos en `main` | Solo esqueleto, gobernanza y plantilla de PR. Sin workflows, sin proyecto Sonar y sin pruebas. El Core no tiene ruta de registro |
| `MANI-Java`, `MANI-.NET` y `MANI-Infrastructure` | Sincronizados; solo se listó su contenido | No se asume nada sobre ellos |
| Jira | Leído en línea el 6 de octubre, sin escrituras | SCRUM-1076, 1126 a 1131, 1062, 1184 a 1188, 1061, 1065, 1099, 1075, 1083, 1102 a 1104 y 1112 |

No se citan ADR-0022 a ADR-0026: la wiki indica que no están en el repositorio.

Base de código al 6 de octubre de 2026, tras `git fetch --all --prune` en los siete repositorios: `MANI-docs` `origin/main` `3fd4473`; **`MANI-Flutter` rama `develop` `1f4c843`** (la rama vigente: `main` `0412421` y `release` `a2a2e15` están atrasadas; `develop` lleva 6 commits sobre `main` y 14 sobre `release`); `MANI-Node` `07069d3`, `MANI-APIGateway` `e312793`, `MANI-Java` `ae5d6ce`, `MANI-.NET` `e2e8370` y `MANI-Infrastructure` `eadd67c`, todos en `main`.

## 2. Línea base: qué hace hoy el código

Los criterios se verificaron contra el comportamiento real del código, que difiere de lo descrito en el Backlog V3. Todos los hallazgos son por lectura de código; no se ejecutó nada contra QA ni contra producción.

| ID | Hallazgo | Evidencia |
|---|---|---|
| F1 | En `develop`, el registro de aliado persona natural sigue directo a Supabase: hace `client.auth.signUp` con metadata y devuelve éxito sin invocar `registrar_aliado_persona_natural` (el código dice "Simplificado por brevedad"). El cliente tampoco sube los archivos a Storage: solo arma una lista de rutas. Ningún camino del registro de persona natural inserta filas en `documento_kyc`. El registro de cliente persona natural también sigue directo | `lib/features/auth/data/datasources/auth_remote_data_source.dart`; `registro_aliado_page.dart`; `handle_new_user` en `database/init/05` |
| F2 | La ruta que arma el cliente es `kyc/<tenant>/cedula_<nombre>`; la política de Storage exige `<tenant_id>/<uid>/...` | `registro_aliado_page.dart`; política `kyc_isolation` en `database/migrations/007_normalizar_dominios.sql` |
| F3 | El tenant lo elige el registrante en una lista desplegable, y el cliente envía `rol: 'ALIADO'` y `tenant_id` dentro de la metadata del `signUp` (verificado en `develop`). `handle_new_user` toma `tenant_id` y `rol` de `raw_user_meta_data` y, si falta el tenant, usa uno fijo. La RPC `registrar_aliado_persona_natural` recibe `p_tenant_id` por parámetro, es `SECURITY DEFINER` y tiene `GRANT` a `anon`. La definición solo está en `database/init`, no en `database/migrations`, por lo que la versión desplegada en QA no se pudo confirmar | `registro_aliado_page.dart`; `database/init/04` y `05` |
| F4 | La interfaz exige solo la cédula; `RUT_CERTIFICADO` es opcional. No existe "antecedentes" en el código ni en el esquema, y no hay configuración de documentos requeridos por tenant, que RF-02 y RF-05 sí exigen | `registro_aliado_page.dart`; búsqueda en `lib/` y `database/` |
| F5 | Bucket privado `kyc-documentos` (10 MB; PDF, JPEG y PNG). La política `kyc_isolation` permite acceso si el tenant de la carpeta 1 coincide con el claim y la carpeta 2 es `auth.uid()` o el rol es `admin_tenant`. Solo se evalúa con el JWT de un usuario: un Core que use `service-role` la omite | `database/migrations/007`; `supabase/poc-cfg13/10_bucket_kyc.sql` |
| F6 | Los casos 1 a 5 de la colección usan PostgREST con tokens de usuario, no el Gateway, y recursos que no son de US-02.1.1 (`sitio`, `usuario`, `notificacion`). El caso 5 no incluye token expirado ni ausencia total de token. El control positivo del caso 3 modifica el propio KYC poniendo `estado: "aprobado"` | `mani-aislamiento.postman_collection.json`, carpetas 01 a 05 |
| F7 | En `database/init/04`, `documento_kyc` tiene `INSERT WITH CHECK (true)` y `SELECT USING (true)`. El aislamiento real depende de las políticas `tenant_isolation_*` de QA, cuyo estado actual no se pudo confirmar. CFG-23b (SCRUM-1104) las versiona | `database/init/04-supabase-rls-and-functions.sql` |
| F8 | `supabase_flutter` o `SupabaseClient` aparecen en 20 archivos de `lib/` en `develop` (19 en `main`), incluidos el datasource de autenticación, el router y la inyección de dependencias. Una versión anterior de este documento decía 10 por un conteo truncado | `git grep` sobre `origin/develop`, `lib/` |
| F9 | `MANI-Node` solo tiene el esqueleto de Express con endpoints de ejemplo (`/tenants`, `/profiles/me`, `/catalog`). No existe ruta de registro, workflow ni pruebas, aunque Flutter ya consume `/api/v1/core/aliados/empresa` (F10) | `MANI-Node/src/routes/core.routes.js` |
| F10 | Existe un precedente por el Gateway: en `develop`, `registrarAliadoEmpresa` (SCRUM-1060, US-02.1.2-M3) hace un `POST` multipart a `/api/v1/core/aliados/empresa` mediante `GatewayClient` (SCRUM-1111). El tenant viaja solo en la cabecera `X-Tenant-Slug`, no en el cuerpo, y el comentario del código dice que el Core construye la ruta de Storage. `GatewayClient` envía `Authorization: Bearer` si hay sesión y un `X-Correlation-ID` por petición. Esa ruta no existe en `MANI-Node` y no hay contrato OpenAPI | `lib/features/auth/data/datasources/auth_remote_data_source.dart` y `lib/core/network/gateway_client.dart` en `develop` |
| F11 | El comentario de F10 fija la ruta de Storage como `tenant_id/aliado_id/documento` (ADR-0013), que es la que la política `kyc_isolation` deniega (PA-04) | `auth_remote_data_source.dart` en `develop`; `database/migrations/007` |

Los hallazgos F2 a F7 se verificaron sobre `develop`: `database/`, `qa/newman/` y `registro_aliado_page.dart` no difieren de `main`.

Consecuencia: varias postcondiciones de los criterios originales (documentos en `<tenant_id>/<uid>/`, rechazo de documento faltante) son hoy comportamiento por construir, no regresión por revalidar. M4 (SCRUM-1062) debe tratarlas como tales.

## 3. Trazabilidad (PO-01a)

### 3.1 Criterios originales frente a requisitos y casos

| Criterio | Origen | Requisito | Escenario nuevo | Caso cross-tenant | Estado en el código |
|---|---|---|---|---|---|
| O1. Registro exitoso con documentos en `<tenant_id>/<uid>/` y estado `PENDIENTE` | Backlog V3, escenario 1 | RF-05, REST-02 | A1 | Caso 6 (controles positivos) | No cumplido: F1 y F2 |
| O2. Falta un documento exigido y el registro se rechaza | Backlog V3, escenario 2 | RF-05, RF-02 | A2 | Ninguno | No existe la regla: F4 |
| O3. Un aliado no puede leer los documentos de otro aliado del mismo tenant | Backlog V3, escenario 3, regla crítica REST-02 | RF-05, RNF-01 | B6 | Caso 6 | La política `kyc_isolation` lo cubre en el camino directo: F5 |
| N1. El tenant, el rol y el estado no los fija el cliente | Nuevo | RF-03, RNF-01, ADR-0018 | A1 (V) y A3 | Casos 3 y 5 | Incumplido por diseño: F3 |
| N2. El cliente solo habla con el Gateway | Nuevo | `COMUNICACION_SERVICIOS_GATEWAY.md` | A4 | Caso 5 y CFG-36 | Incumplido para persona natural y cliente; cumplido en el cliente para empresa (F10) |
| N3. Respuesta con `correlation_id` | Nuevo | RNF-04, CFG-16 | A1 y A2 (respuestas) | No aplica | Sin contrato: PA-01 |

### 3.2 Los seis casos frente a los recursos de US-02.1.1

| Caso | Recurso de la colección actual | Aplica a US-02.1.1 | Recurso propio de US-02.1.1 | Escenario |
|---|---|---|---|---|
| 1. Lectura | `sitio` | No | Registro y estado del aliado; fila de `documento_kyc` | B1 |
| 2. Listado | `sitio` y `usuario`; fila de `documento_kyc` en el complemento del caso 6 | Parcial | Documentos propios del aliado; usuarios y aliados del tenant | B2 |
| 3. Escritura, con variante de inserción | `documento_kyc` (PATCH) y `notificacion` (POST) | Parcial: `documento_kyc` sí | Documento KYC y registro de aliado con `tenant_id` ajeno | B3 |
| 4. Borrado | `documento_kyc` (DELETE negativo) y `notificacion` (control positivo) | Parcial | Documento KYC propio y ajeno | B4 |
| 5. Tokens alterados o expirados | `sitio` (GET) | El recurso no, el mecanismo sí | Endpoints privados de documentos y de estado | B5 |
| 6. KYC en Storage | `kyc-documentos` | Sí, completo | `<tenant_id>/<uid>/` | B6 |

## 4. DoR y DoD de M1 a M4 (PO-01a y PO-01b)

Base: `wiki/05-proceso/dor-y-dod.md` (DoR y DoD oficiales, DoD decidido por QA), los gates de ADR-0005 y la regla de los seis casos de `POLITICAS_DEVOPS_HERRAMIENTAS.md` sección 13.4.

Gates de ADR-0005 que aplican a todo código nuevo: 0 vulnerabilidades Blocker o Critical, 0 High conocidas abiertas en producción, cobertura de código nuevo >= 80 %, cobertura de casos críticos >= 90 %, duplicación de código nuevo < 3 %.

Los pasos M1 a M3 pertenecen a otros responsables. Lo siguiente es una **propuesta de borrador**: se ajusta con ellos (SCRUM-1130) y se actualiza cuando su trabajo esté subido al repositorio. El DoR y el DoD de M4 pertenecen a QA y se definen aquí.

### 4.1 Estado actual y propuesta para M1 a M3

| Paso | Ticket y responsable | Problema del DoR y DoD actuales | DoR propuesto | DoD propuesto |
|---|---|---|---|---|
| M1 | CFG-16, SCRUM-1099 (Juan Sebastián Álvarez). No tiene ticket propio: CFG-16 lo sustituye | El DoD es de plantilla de código ("cobertura mayor al 80 %, desplegado en QA") y no encaja con un documento OpenAPI. Además, Flutter ya consume `/api/v1/core/aliados/empresa` antes de que exista el contrato (F10) | Lista de operaciones acordada (registro público, carga de documentos, estado). Borrador del modelo de identidad (CFG-23a). Revisadas la ruta y la forma de petición que Flutter ya usa en `develop` | Documento OpenAPI válido según linter. Revisado por par técnico. Versionado en el repositorio acordado. Incluye endpoint público de registro, privados de documentos y estado, formato de error y campo de `correlation_id`. Reconciliado con lo ya construido en Flutter (ruta, multipart, `X-Tenant-Slug`) o con una nota de cambio acordada con quien lo implementó. Referenciado desde M2 y M3 |
| M2 | SCRUM-1065 (Juan Sebastián Álvarez) | El DoD no exige los seis casos y su cobertura (>80 %) no coincide con el gate de ADR-0005. El DoR no refleja que SP-05 sigue sin decisión aceptada: la descripción dice "SP-05 cerrado en invocar", pero el ADR-0022 de DOC-26 (SCRUM-1075, en curso) está en estado Propuesto y decide lo contrario: la lógica se migra al servicio y no se invoca la función PL/pgSQL. El título de M2 ("invocando registrar_aliado_persona_natural") queda desactualizado si ese ADR se acepta | Contrato CFG-16 publicado. ADR de DOC-26 aceptado, para saber si M2 invoca o reimplementa. Modelo de identidad CFG-23a aprobado. Criterios de aceptación validados por el PO | Gates de ADR-0005. Los seis casos con rechazo y control positivo, con el aislamiento demostrado en el Core (con `service-role` la política `kyc_isolation` no se evalúa, F5). Pull Request aprobado y CI en verde. Contrato actualizado. Desplegado en QA |
| M3 | SCRUM-1061 (José Nicolás Álvarez) | El DoR pide diseño en Figma, que no aplica porque la UI no se toca. El DoD no pide ausencia de llamadas a `SupabaseClient`. No menciona el precedente de SCRUM-1060 (empresa), ya en `develop` | Contrato OpenAPI publicado o mockeado. `GatewayClient` (SCRUM-1111) disponible. Decisión de CFG-35 sobre qué queda de `supabase_flutter`. Se toma SCRUM-1060 como patrón (multipart al Core, tenant solo en `X-Tenant-Slug`, el cliente no envía rutas de Storage) y se confirma PA-02 | Ninguna llamada a `SupabaseClient`, `.rpc()`, `.from()` ni `.storage.from()` en `registrarAliadoPersonaNatural`, salvo la excepción que decida CFG-35. El cliente deja de enviar `rol`, `estado_verificacion` y rutas de Storage en la metadata, y el tenant viaja solo en `X-Tenant-Slug`. Interfaz de `domain/repositories` sin cambios, o cambio aprobado por el PO. Pruebas unitarias del datasource, como las de SCRUM-1060. CI en verde. Código integrado por Pull Request |

### 4.2 DoR de M4 (SCRUM-1062)

M4 puede iniciar solo cuando se cumplan las condiciones 1 a 7. Las condiciones 8 y 9 son recomendadas: su ausencia no impide iniciar, pero debe declararse en el reporte. SCRUM-1184 (M4a) las verifica con la lista de la sección 4.4.

1. M1 (CFG-16), M2 (SCRUM-1065) y M3 (SCRUM-1061) desplegados en QA y alcanzables a través del Gateway.
2. Esqueleto del Core desplegado en QA (CFG-20, SCRUM-1100).
3. JWT con claims de tenant y rol operativo entre Supabase Auth, Gateway y Core (CFG-22, SCRUM-1102).
4. Modelo de identidad aprobado (CFG-23a, SCRUM-1103) y políticas RLS del nuevo modelo aplicadas en QA (CFG-23b, SCRUM-1104).
5. Criterios de aceptación de este documento validados por el PO (SCRUM-1130).
6. Usuarios de prueba de dos tenants disponibles en QA.
7. Entorno de QA estable.
8. Recomendado: decisión de CFG-35 (SCRUM-1112) sobre la excepción de Supabase Auth, para cerrar el alcance de A4. Sin ella, A4 solo cubre REST, RPC y Storage (PA-07).
9. Recomendado: PA-06 verificado, es decir, saber si un registro con `rol` o `tenant_id` fijados desde el cliente crea un usuario con ese rol o en ese tenant.

### 4.3 DoD de M4 (SCRUM-1062)

Base: DoD oficial de la wiki más los añadidos de los seis casos.

1. Regresión de US-02.1.1 ejecutada al 100 %, con el resultado esperado escrito antes de ejecutar.
2. Los seis casos cross-tenant (B1 a B6) con rechazo o ausencia de datos, cada negativo con su control positivo en la misma corrida.
3. Meta: control negativo ejecutable. Con el aislamiento del Core desactivado en un entorno de prueba, los negativos de B1 a B6 deberían fallar. Depende del Core (Juan) y no bloquea el cierre de M4; si no se logra, se declara en el reporte.
4. Ninguna petición del cliente a Supabase REST, RPC ni Storage, salvo la excepción que decida CFG-35.
5. Evidencia versionada y redactada (sin JWT ni llaves), con el enlace a la corrida de CI en verde.
6. Defectos registrados en Jira. Ningún defecto bloqueante abierto.
7. Reporte QA aprobado, socializado y vinculado a Jira y GitHub.
8. Documentación afectada actualizada (plan de pruebas de DOC-38, SCRUM-1094).

Si el ADR-0022 se acepta, el reporte de M4 es además el criterio que autoriza retirar las funciones PL/pgSQL que M2 reemplace: sin regresión aprobada, esas funciones no se retiran. El reporte debe decir qué funciones cubre.

### 4.4 Lista de verificación go/no-go de M4 (SCRUM-1184)

| Ítem | Ticket | Dueño | Cumplido al 6 de octubre |
|---|---|---|---|
| Contrato OpenAPI publicado | SCRUM-1099 | Juan | No |
| Core desplegado en QA | SCRUM-1100 | Juan | No |
| M2 desplegado en QA | SCRUM-1065 | Juan | No |
| M3 desplegado en el build de QA | SCRUM-1061 | José | No |
| JWT con claims operativo | SCRUM-1102 | Daniel | No |
| Modelo de identidad aprobado | SCRUM-1103 | Juan | No |
| Políticas RLS aplicadas en QA | SCRUM-1104 | Daniel | No |
| ADR de DOC-26 aceptado (SP-05) | SCRUM-1075 | María Camila | No (Propuesto) |
| `GatewayClient` en `develop` | SCRUM-1111 | José | Sí (merge de PR #33) |
| Excepción de Auth decidida (recomendado) | SCRUM-1112 | Daniel | No |
| Criterios validados por el PO | SCRUM-1130 | Nicolás León | No |
| Usuarios de dos tenants en QA | Colección `mani-aislamiento` | Santiago | Por confirmar |
| PA-06 verificado (recomendado) | SCRUM-1062 | Santiago | No |

Los estados salen de Jira el 6 de octubre de 2026. Todos los tickets de dependencia figuran "Tareas por hacer".

### 4.5 Casos de regresión de M4 (SCRUM-1185)

Cada caso lleva el identificador del escenario en su nombre. El resultado esperado se escribe antes de ejecutar.

| Caso | Escenario | Herramienta | Se puede preparar sin QA desplegado |
|---|---|---|---|
| A1-P, A1-V | Registro exitoso e identidad fijada por el servidor | Newman (contrato) y Playwright (recorrido web) | Sí: pasos y resultados esperados. Las rutas se completan con CFG-16 |
| A2-N, A2-V | Documento faltante y ruta fuera de la carpeta | Newman | Sí, con la misma salvedad |
| A3-P, A3-N, A3-V | Tenant tomado del token | Newman | Sí, con la misma salvedad |
| A4-P, A4-N, A4-V | Solo Gateway, sin anon key y sin acceso directo | Playwright con captura de red, e inspección del bundle | Sí: la búsqueda de `SUPABASE_ANON_KEY` en el bundle se puede preparar hoy |
| B1, B2 | Lectura y listado | Newman | Parcial: usuarios y semillas sí, solicitudes al Gateway no |
| B3, B4 | Escritura y borrado | Newman | Parcial; también alimentan SCRUM-1187 y CFG-23c |
| B5 | Tokens inválidos | Newman | Sí, con la salvedad de las rutas |
| B6 | KYC en Storage | Newman y scripts de `qa/storage` | Sí para el camino directo; el camino por el Core espera PA-09 |

## 5. Escenarios de aceptación: camino funcional A1 a A4 (PO-01c)

**Condicional.** La Scrum Master debe confirmar si se requieren escenarios BDD completos o solo DoR y DoD. Si solo DoR y DoD, esta sección y la 6 se reducen a la tabla de la sección 4.5, con un título y un resultado esperado por caso.

Convención: P es el caso positivo, N el negativo y V el intento de violar la regla crítica. Los códigos HTTP concretos se fijan en el contrato de CFG-16 (PA-01). Mientras no exista, el rechazo se expresa como "403 o 404, nunca 200 con datos" y la falta de campos como "error de validación que identifica el campo".

El registro es el único endpoint público de la historia: el registrante todavía no tiene token, por lo que el tenant se resuelve antes de autenticar con la cabecera `X-Tenant-Slug` (ADR-0018 la permite solo para esa resolución, sin autorizar acceso a datos). El claim `tenant_id` aparece **después** del registro, en el primer token. La carga posterior de documentos y la consulta de estado son privadas y toman el tenant solo del claim. El precedente de empresa (F10) manda el registro y los documentos en una sola petición multipart; para persona natural queda por confirmar en PA-02.

```gherkin
Característica: Registro de aliado persona natural con KYC por el camino Gateway - Core

Escenario A1-P: Registro exitoso con documentos privados
  Dado un tenant activo, identificado por la cabecera X-Tenant-Slug, que exige los documentos de su configuración para persona natural
  Cuando el aliado envía el registro con todos los documentos exigidos al Gateway
  Entonces el Gateway enruta la solicitud al Core
  Y el Core registra al aliado, sea invocando la lógica existente o reimplementándola según lo que decida el ADR de DOC-26
  Y el aliado queda con estado_verificacion "PENDIENTE" en ese tenant, con el rol "aliado"
  Y cada documento queda en el bucket privado kyc-documentos bajo la ruta <tenant_id>/<uid>/
  Y existe una fila de documento_kyc por documento, con ruta_storage igual a la ruta real del objeto
  Y la respuesta incluye correlation_id y cumple el contrato de CFG-16
  Y el primer token del aliado trae el claim tenant_id de ese tenant y el rol "aliado"

Escenario A1-V: El cliente intenta fijar rol, estado o tenant ajeno
  Dado un registro cuyo cuerpo o metadata incluye rol "ADMIN_TENANT", estado_verificacion "VERIFICADO" o un tenant_id distinto del que resuelve X-Tenant-Slug
  Cuando el Core procesa la petición
  Entonces esos valores se ignoran o la petición se rechaza (PA-05)
  Y el usuario creado, si existe, es un aliado en estado "PENDIENTE" en el tenant resuelto
  Y no queda ningún registro en el tenant ajeno
```

El escenario A1-V traslada a criterio la regla crítica que hoy no se cumple por lectura de código (F3). La verificación en QA debe confirmarla o descartarla antes de la regresión (PA-06).

```gherkin
Escenario A2-N: Falta un documento exigido
  Dado un tenant que exige un documento que el aliado no adjunta
  Cuando el aliado envía el registro
  Entonces el registro se rechaza con un error que identifica el documento faltante
  Y la respuesta de error incluye correlation_id y no expone detalles internos de PL/pgSQL ni de Supabase
  Y no queda usuario, aliado, fila de documento_kyc ni objeto en Storage
  Y el mismo registro con todos los documentos tiene éxito (control positivo: A1-P)

Escenario A2-V: Ruta de documento fuera de la carpeta del aliado
  Dado un registro con una ruta o un nombre de archivo que apunta a otro tenant u otro uid
  Cuando el Core procesa el registro
  Entonces el servidor construye la ruta <tenant_id>/<uid>/ por sí mismo o rechaza la petición
  Y no se escribe ningún objeto fuera de la carpeta del propio aliado
```

A2-N materializa el criterio original O2. La regla "cédula y antecedentes" del Backlog V3 no existe en el código (F4): el documento exigido depende de la configuración del tenant (RF-02), cuya fuente no está definida (PA-03).

```gherkin
Escenario A3-P: El tenant se resuelve por slug en el registro y por token en lo privado
  Dado un registro público con X-Tenant-Slug de un tenant activo
  Cuando el Core crea al aliado
  Entonces el aliado queda en ese tenant y el primer token trae el claim tenant_id de ese tenant
  Dado un aliado autenticado en el tenant 1
  Cuando sube un documento o consulta su estado por el Gateway
  Entonces el Core usa únicamente el claim tenant_id del token
  Y la operación afecta solo registros del tenant 1 y de su propio uid

Escenario A3-N: Tenant inexistente o inactivo, o petición privada sin token válido
  Dado un registro con un X-Tenant-Slug que no existe o no está activo
  Cuando el aliado envía el registro
  Entonces el registro se rechaza, no se asigna ningún tenant por defecto y no se crea usuario, aliado ni documento
  Dada una petición privada sin token, con token expirado o con firma alterada
  Cuando llega al Gateway
  Entonces el Gateway responde 401 y la petición no llega al Core

Escenario A3-V: El cliente intenta fijar otro tenant
  Dado un registro con X-Tenant-Slug del tenant 1 y un tenant_id del tenant 2 en el cuerpo
  Cuando el Core procesa el registro
  Entonces el cuerpo se ignora o la petición se rechaza (PA-05) y no queda nada en el tenant 2
  Dado un aliado autenticado en el tenant 1
  Cuando envía una operación privada con el tenant 2 en el cuerpo o en la cabecera X-Tenant-Slug
  Entonces el Core usa el claim tenant_id del token y nada se escribe ni se lee en el tenant 2
```

```gherkin
Escenario A4-P: Recorrido completo solo por el Gateway
  Dado el build de Flutter desplegado en QA
  Cuando se ejecuta el recorrido de registro y de carga de documentos
  Entonces todas las peticiones de negocio del cliente van al Gateway
  Y ninguna petición va a Supabase REST (rest/v1), RPC ni Storage desde el cliente

Escenario A4-N: El bundle no entrega credenciales de acceso directo
  Dado el artefacto web publicado en QA
  Cuando se inspecciona su contenido y su tráfico de red
  Entonces no incluye SUPABASE_ANON_KEY ni la llave de servicio (CFG-36)

Escenario A4-V: Acceso directo a Supabase con el token del aliado
  Dado un aliado con sesión válida
  Cuando intenta leer o escribir aliado y documento_kyc directamente en Supabase REST o Storage
  Entonces el acceso se deniega o no existe ruta para hacerlo
```

La excepción de Supabase Auth para el inicio de sesión queda sujeta a CFG-35 (SCRUM-1112): A4 solo prohíbe REST, RPC y Storage, y debe ajustarse si CFG-35 decide otra cosa (PA-07).

## 6. Escenarios de aceptación: los seis casos cross-tenant B1 a B6 (PO-01c)

Se ejecutan en QA a través del Gateway, con tokens de usuarios de dos tenants. La colección `mani-aislamiento` ya aporta los usuarios de prueba y los casos 5 y 6 de Storage, pero llama directo a PostgREST y a Storage (F6): debe agregar solicitudes contra el Gateway y conservar las actuales como defensa en profundidad. Usuarios de la colección: `aliado.t1`, `aliado.t2`, `admin.t1`, `admin.t2`, `cliente.t1` y `hook.t1` (segundo aliado del tenant 1).

Regla de lectura de los negativos: el rechazo es 403 o 404, o ausencia total de datos ajenos; nunca 200 con datos del otro tenant. Cada negativo tiene su control positivo y solo es válido si el control pasa en la misma corrida.

```gherkin
Escenario B1 (caso 1, lectura)
  Cuando aliado.t1 consulta por el Gateway el registro o el estado de un aliado del tenant 2
  Entonces la respuesta es 403 o 404 y no contiene ningún dato del aliado del tenant 2
  Y la misma consulta sobre su propio registro devuelve 200 con su estado (control positivo)

Escenario B2 (caso 2, listado)
  Cuando aliado.t1 lista sus documentos KYC y admin.t1 lista los aliados y documentos de su tenant
  Entonces ninguna fila pertenece al tenant 2
  Y el aliado no ve documentos de otro aliado del tenant 1
  Y cada listado devuelve al menos una fila propia (control positivo)

Escenario B3 (caso 3, escritura)
  Cuando aliado.t1 intenta reemplazar o modificar el documento KYC o el estado de un aliado del tenant 2
  Entonces la petición se rechaza o afecta 0 filas y el registro del tenant 2 queda intacto, comprobado con una lectura posterior de admin.t2
  Y aliado.t1 puede reemplazar su propio documento mientras su estado es "PENDIENTE" (control positivo; PA-08)
  Y una petición con un tenant_id ajeno en el cuerpo se rechaza o ignora, sin crear nada en el tenant 2 (variante de inserción)
  Y aliado.t1 no puede cambiar el estado de su propio documento ni de su propio aliado: recibe 403 y el estado no cambia

Escenario B4 (caso 4, borrado)
  Cuando aliado.t1 intenta borrar un documento KYC del tenant 2
  Entonces la petición se rechaza o afecta 0 filas y el documento sigue existiendo, comprobado con admin.t2
  Y aliado.t1 puede retirar su propio documento mientras está "PENDIENTE" (control positivo; PA-08)

Escenario B5 (caso 5, tokens inválidos)
  Cuando se llama a un endpoint privado de documentos o de estado con un token con tenant_id reescrito, con la firma alterada, expirado o sin cabecera Authorization
  Entonces el Gateway responde 401 en cada variante, la petición no llega al Core y no se devuelve ninguna fila
  Y la misma llamada con un token válido de aliado.t1 devuelve 200 (control positivo)

Escenario B6 (caso 6, KYC en Storage)
  Dado documentos KYC de aliado.t1 en <tenant_id>/<uid>/
  Cuando aliado.t2, admin.t2, hook.t1, cliente.t1 o un anónimo intentan descargar, firmar, listar o subir sobre esa ruta
  Entonces todas las operaciones se deniegan y no se filtra ni el archivo ni una URL firmada
  Y aliado.t1 descarga, firma y lista su propia cédula, y admin.t1 descarga y firma la cédula de un aliado de su tenant (controles positivos)
  Y una URL firmada con firma alterada, reutilizada sobre otra ruta o usada después de su TTL se rechaza
```

Alternativa para los controles positivos de B3 y B4 (PA-08): si el PO decide que el aliado no puede reemplazar ni retirar un documento propio en estado "PENDIENTE", el control positivo de ambos escenarios pasa a ser que aliado.t1 lee y lista su propio documento con 200. Los negativos no cambian.

Detalle de ejecución del caso 6:

1. Camino por el Gateway: la descarga o el acceso temporal que entrega el Core (mecanismo de SCRUM-1066 CA-2 y CFG-23a, PA-09) se prueba con los mismos actores.
2. Camino directo a Storage: las solicitudes N1 a N11 de la colección se mantienen como regresión, porque mientras la anon key esté publicada (CFG-36) un atacante puede llamar a Supabase sin pasar por el Gateway.
3. El control C1 de la colección documenta que una URL firmada filtrada funciona hasta su TTL. El criterio exige que el TTL no supere el valor que fije CFG-23a (la colección usa 60 s; PA-09).
4. Solo los actores del tenant 2 prueban aislamiento entre tenants. `hook.t1` y `cliente.t1` pertenecen al tenant 1 y cubren el criterio O3 y la regla de que un cliente no ve KYC. La colección no incluye hoy un cliente del tenant 2.

## 7. Condición de aceptación (PO-01d)

US-02.1.1 se acepta solo si se cumplen todas estas condiciones:

1. Los escenarios B1 a B6 se ejecutan en QA a través del Gateway, con el 100 % de los negativos rechazados y el 100 % de los controles positivos exitosos (ADR-0015). Un negativo cuyo control positivo falló no cuenta como pasado.
2. El caso 6 se ejecuta por los dos caminos: acceso temporal del Core y acceso directo a Storage.
3. Los escenarios A1 a A4 pasan en QA sobre el build desplegado, incluido A1-V (rol y tenant no fijados por el cliente).
4. Meta: la suite incluye un control negativo ejecutable. Con el aislamiento del Core desactivado en un entorno de prueba, los negativos de B1 a B6 deberían fallar; si no pueden fallar, no validan nada. No bloquea la aceptación, pero su ausencia se declara en el reporte.
5. La evidencia se versiona redactada (sin JWT ni llaves; el redactor `qa/newman/redactar_evidencia.mjs` falla si sobrevive un JWT) junto con el enlace a la corrida de CI en verde, y cada prueba lleva el identificador del escenario en su nombre (A1-P, B3, etc.).
6. Las dependencias están desplegadas en QA antes de ejecutar: CFG-16 (SCRUM-1099), CFG-17 (SCRUM-1101), CFG-20 (SCRUM-1100), CFG-22 (SCRUM-1102), CFG-23a y CFG-23b (SCRUM-1103 y 1104), M2 (SCRUM-1065) y M3 (SCRUM-1061).
7. Cualquier defecto se registra en Jira y no se acepta con una excepción sin aprobación del PO.

Si las dependencias del punto 6 no llegan a QA antes del cierre del sprint, la aceptación no se declara: se registra como incremento no entregado, con causa, impacto, estado y decisión de replanificación (`GOBIERNO_DEL_EQUIPO.md`, sección 10).

## 8. Puntos abiertos

| ID | Punto abierto | Responsable sugerido y ticket |
|---|---|---|
| PA-01 | No existe el contrato OpenAPI. Rutas, códigos de estado, formato de error y nombre del campo de `correlation_id` no se inventan aquí y quedan atados a CFG-16. Debe incluir el endpoint público de registro y los privados de documentos y estado. Flutter ya consume `/api/v1/core/aliados/empresa` (F10): el contrato debe reconciliarse con esa ruta o acordar el cambio con quien la implementó | Juan Sebastián Álvarez, SCRUM-1099 |
| PA-02 | Si el registro y la carga de documentos son una sola petición o dos para persona natural. El precedente de empresa (F10) usa una sola petición multipart, y su método recibe `documentosKYC` como `List<Map<String, String>>` con `contenido_base64`, el mismo tipo que usa persona natural. Eso sugiere que la interfaz del repositorio no necesita cambiar, solo lo que la página pone en cada mapa (contenido en lugar de rutas). Falta que José lo confirme | José Nicolás Álvarez y Juan Sebastián Álvarez, SCRUM-1061 y SCRUM-1065; decisión de fondo en CFG-35 |
| PA-03 | Fuente de los documentos requeridos por tenant. El Backlog V3 habla de "cédula y antecedentes"; el código exige solo la cédula (F4) y no hay configuración por tenant (RF-02). El PO debe confirmar si "antecedentes" es obligatorio | Nicolás León (PO), con SCRUM-1065 |
| PA-04 | Inconsistencia de ruta de Storage: ADR-0013 y el comentario del código de empresa en `develop` (F11) dicen `tenant_id/aliado_id/documento`; el Backlog V3, la política `kyc_isolation` y la colección usan `<tenant_id>/<uid>/` (la solicitud N11 de la colección verifica que la ruta con `aliado.id` se deniega). SCRUM-1063 CA-2 también usa `aliado_id`. Si el Core construye la ruta con `aliado_id`, la política vigente la rechazaría o habría que migrarla. Corrección propuesta, sin editar el ADR: fijar cuál es la ruta, sustituir `aliado_id` por `usuario_id` o migrar la política | Autor de ADR-0013 y Mesa de Arquitectura; María Camila Beltrán en SCRUM-1063; Juan Sebastián Álvarez como implementador del Core |
| PA-05 | Tratamiento de un `tenant_id` ajeno en el cuerpo: PO-05 dice "se ignora" y la colección (caso 3, variante de inserción) espera rechazo. Los criterios admiten ambos y exigen que no se escriba en el tenant ajeno. Debe unificarse en el contrato | Sara Albarracín y María Camila Beltrán, SCRUM-1083 |
| PA-06 | Verificar en QA, antes de la regresión, si un registro con `rol` o `tenant_id` fijados desde el cliente crea un usuario con ese rol o en ese tenant (F3). Es una lectura de código no ejecutada | Santiago, SCRUM-1062; si se confirma, abrir defecto en Jira |
| PA-07 | Alcance de la excepción de Supabase Auth en A4. Hasta que CFG-35 decida, el criterio solo cubre REST, RPC y Storage | Daniel Ávila, SCRUM-1112 |
| PA-08 | Si el aliado puede reemplazar o retirar un documento propio mientras está en `PENDIENTE`. El control positivo actual de la colección (caso 3) cambia el `estado` del propio KYC a "aprobado": es una auto-aprobación y debe eliminarse. Los controles positivos de B3 y B4 dependen de la respuesta | Nicolás León (PO), con SCRUM-1062 |
| PA-09 | Mecanismo y TTL del acceso temporal a documentos KYC cuando el llamador es el Core (SCRUM-1066 CA-2 lo deja "según diseño de CFG-23a"). Con `service-role` la política `kyc_isolation` no se evalúa (F5): el aislamiento debe demostrarse en el Core | Juan Sebastián Álvarez, SCRUM-1103 |
| PA-10 | La colección debe ampliarse: solicitudes contra el Gateway para los casos 1 a 5 sobre recursos de US-02.1.1, token expirado y ausencia total de token en el caso 5, un cliente del tenant 2 en el caso 6 y reemplazo del control positivo del caso 3 | Santiago, SCRUM-1105 (CFG-23c) y SCRUM-1120 (QA-03) |
| PA-11 | SP-05 no tiene decisión aceptada: la descripción de SCRUM-1065 dice "SP-05 cerrado en invocar", pero el ADR-0022 (SCRUM-1075, Propuesto, rama `SCRUM-1075-adr-0022`) decide que la lógica vive en los servicios y las funciones PL/pgSQL se retiran después de la regresión de M4. Si se acepta, el título de M2 y A1 deben leerse sin "invoca"; si no, M2 invoca. Hasta entonces el DoR de M2 no se cumple | María Camila Beltrán (SCRUM-1075), Sara Albarracín (revisora del ADR) y Juan Sebastián Álvarez (SCRUM-1065) |
| PA-12 | Los escenarios originales del Backlog V3 cubren US-02.1.1 y US-02.1.2 en un mismo bloque; este documento solo cubre persona natural. La variante de empresa queda en PO-05 | Nicolás León (PO), SCRUM-1083 |
| PA-13 | El backlog (sección 3.6) deja regresión solo para US-02.1.1. US-02.1.2-M2/M3 y US-02.2.1-M2 entran sin historia de regresión propia. Decisión pendiente del PO | Nicolás León (PO) |
| PA-14 | El destino de publicación: la descripción de SCRUM-1076 dice "Jira / Backlog V4", archivo que ya no existe. Falta confirmar con la Scrum Master si el destino es Jira o `MANI-docs` | Sara Albarracín |
| PA-15 | Los escenarios BDD completos están condicionados a lo que confirme la Scrum Master (sección 5) | Sara Albarracín |

## 9. Solapes con PO-05 (SCRUM-1083)

PO-05 cubre US-02.1.2-M2/M3, US-02.1.3-M2 y US-02.2.1-M2, no US-02.1.1. La descripción de SCRUM-1083 en Jira no contiene criterios comunes. El borrador anterior citaba criterios CC-1 a CC-4 de un comentario del 5 de octubre; no se reverificaron en esta revisión, por lo que la alineación se tratará con María Camila Beltrán en SCRUM-1130.

| Escenario de PO-01 | Tema | Tratamiento propuesto |
|---|---|---|
| A4 (solo Gateway) | CC-1, según el borrador anterior | Mantener un único texto y referenciarlo desde ambas historias. A4-N y A4-V (anon key y acceso directo) son aportes propios |
| A3 (tenant por token, 401 sin token) | CC-2 y CC-3 | Mantener un único texto. El registro de US-02.1.1 es público y no entra en CC-2 ni CC-3; A3-N lo cubre |
| `correlation_id` en A1 y A2 | CC-4 | Alinear el nombre del campo con CFG-16 |
| B1 a B6 por historia | CA-5 de SCRUM-1063 y CA-7 de SCRUM-1066 | US-02.1.1 cubre el KYC y el registro del aliado; SCRUM-1066 cubre la bandeja y la aprobación. Ejecutar el caso 6 una vez y referenciarlo desde ambas historias |

## 10. Revisores propuestos

| Revisor | Motivo |
|---|---|
| Nicolás León (PO) | Decide los criterios de aceptación. Resuelve PA-03, PA-08 y PA-13 |
| Sara Albarracín (Scrum Master, par técnico) | Revisa el documento como DoD de SCRUM-1076. Resuelve PA-14 y PA-15. Unifica con PO-05 (PA-05) |
| Juan Sebastián Álvarez (dueño de CFG-16, CFG-23a y M2) | Ajusta el DoR y el DoD de M1 y M2. Resuelve PA-01, PA-02, PA-09 y PA-11 |
| José Nicolás Álvarez (dueño de M3) | Ajusta el DoR y el DoD de M3. Resuelve PA-02 |
| María Camila Beltrán (PO-05 y DOC-26) | Evita duplicar criterios comunes. Reconcilia la ruta de Storage (PA-04) |
| Daniel Ávila (DevOps) | Confirma la ejecución en CI. Resuelve PA-07 y las fechas de CFG-22 y CFG-23b |

## 11. Cambios propuestos en Jira (no ejecutados)

| Ticket | Propuesta |
|---|---|
| SCRUM-1062 y 1184 a 1188 | Prioridad Low a Highest. El backlog fija M4 en Highest |
| SCRUM-1065 | Prioridad High a Highest. Corregir "SP-05 cerrado en invocar" y revisar el título ("invocando") cuando se acepte el ADR de DOC-26. Sustituir el DoD por el de la sección 4.1 |
| SCRUM-1061 | Quitar "Diseño en Figma" del DoR. Añadir la ausencia de llamadas a `SupabaseClient` al DoD |
| SCRUM-1099 | Corregir el título ("Gateway con Js acotado PARA a identidad"). Sustituir el DoD de código por el de documento OpenAPI |
| SCRUM-1102, 1103, 1104 y 1112 | Prioridad Medium o Low a Highest, como en el backlog |
| SCRUM-1116 (CFG-41) | Prioridad Medium a Highest, como en el backlog |
| SCRUM-1118 (QA-01) | Prioridad High a Highest, como en el backlog |
| SCRUM-1126 a 1129 | Pasar a "En curso" |
| SCRUM-1076 | Corregir el destino "Backlog V4" una vez responda la Scrum Master |
| Enlaces | Verificar enlaces "bloquea" entre 1099, 1065, 1061 y 1062, y entre 1103, 1104, 1102 y 1105. No se pudieron leer los enlaces existentes |

## 12. Cambios respecto al borrador anterior

- Los escenarios de la historia son A1 a A4; se eliminó A5 y su contenido (`correlation_id`) pasó a A1 y A2.
- Se añadió la sección 4 con el DoR y el DoD de M1 a M4, la lista go/no-go y los casos de regresión de M4.
- Se eliminaron las citas a `BACKLOG_MANI_V4_TRANSICION`, al Documento de Herramientas V3 y a ADR-0026, y se sustituyeron por la wiki y `BACKLOG_MANI.md`.
- Se eliminó el punto abierto sobre la numeración de ADR-0025 y ADR-0026, y se añadieron PA-11 y PA-13 a PA-15.
- Se añadieron los hallazgos F8 y F9 y se ajustó F7.
- Tras la revisión del 6 de octubre: las condiciones 8 y 9 del DoR de M4 pasan a recomendadas, el control negativo ejecutable pasa a meta, se añade la alternativa de los controles positivos de B3 y B4 (PA-08) y se mantiene la evidencia con enlace a CI como requisito.
- Actualización del 6 de octubre tras sincronizar los siete repositorios: la revisión de Flutter pasa de `main` a `develop` (`1f4c843`). Se corrige F8 (20 archivos, no 10), se confirma F3 por el lado del cliente y se añaden F10 y F11 (precedente de empresa por el Gateway y ruta de Storage). A1 y A3 nombran `X-Tenant-Slug` en el registro y el claim en lo privado. Se ajustan los DoR y DoD de M1 a M3, PA-01, PA-02 y PA-04. PA-11 se reformula por el ADR-0022 (Propuesto), y el reporte de M4 se vuelve el criterio para retirar las funciones PL/pgSQL si ese ADR se acepta.

# Criterios de aceptación y DoD de las historias priorizadas del Sprint 4

| Campo | Valor |
|---|---|
| Tarea | SCRUM-1257 (PO4-02), subtareas SCRUM-1286 y SCRUM-1287 |
| Historias | Las 17 historias del Sprint 4 de la matriz de SCRUM-1256 |
| Autora | Camila Beltrán (PO) |
| Fecha | 19 de octubre de 2026 (versión 2, ajustada según la revisión de QA del PR #49) |
| Criterios de aceptación | Decididos por el PO. Las reglas de producto nuevas (§3: 852, 855 y 1063) fueron confirmadas con Sara el 19-oct |
| DoD (sección 4) | **Decidido por QA** (Santiago, revisión del PR #49) |
| Alimenta a | SCRUM-1245 (Backlog V5) |

## 1. Alcance, autoridad y fuentes

Este documento fija los criterios de aceptación funcionales de las 17 historias priorizadas del Sprint 4. El DoD técnico transversal vive en `wiki/05-proceso/dor-y-dod.md`; la sección 4 solo registra lo que QA decidió sobre los añadidos propuestos. Según `governance/GOBIERNO_DEL_EQUIPO.md` §2.3, el PO decide los criterios de aceptación y QA decide el DoD.

**Estos criterios se suman a lo que ya está en Jira, no lo reemplazan.** Siguen vigentes, en cada historia, la sección «QA - pruebas obligatorias» y, donde existen, los criterios CC y CA publicados (SCRUM-1060, 1063 y 1066). Los criterios C1, C2 y C3 de cada historia son el caso positivo, el negativo y el intento de violar la regla crítica; los C4 en adelante cubren los escenarios de «QA - pruebas obligatorias» que C1 a C3 no alcanzan.

**Códigos de error.** Los criterios no fijan códigos ni nombres de error: pertenecen al contrato de cada servicio publicado en el Gateway. Cuando un criterio dice «se rechaza con el error de validación del contrato», se verifica contra ese contrato. Los códigos HTTP `401`, `403`, `409` y `503` sí se fijan cuando el SRS, un ADR o la historia ya los establecen.

**Mocks.** En QA, las notificaciones push y los pagos son simulados. Ningún criterio exige envíos reales a FCM/APNs ni cobros reales.

**Línea de verificación por historia.** Cada historia indica quién acepta, qué subtarea de QA verifica y qué casos de la matriz de pruebas del Sprint 4 (`product/MANI_Matriz_Pruebas_Sprint4.xlsx`, SCRUM-1264) la cubren.

Fuentes revisadas: la descripción de cada historia en Jira (alcance, DoD y «QA - pruebas obligatorias»), la matriz de pruebas SCRUM-1264, `product/SRS.md`, `architecture/SAD.md` §7, `architecture/SDD.md` §4.2 y §8, los contratos del Gateway y ADR-0012, 0016, 0018, 0022, 0027, 0030 y 0031 con su estado vigente.

## 2. Criterios transversales

Aplican a todas las historias de este documento. Una historia que incumpla uno de ellos no se acepta.

| ID | Criterio | Origen |
|---|---|---|
| T1 | Ningún servicio consulta ni escribe tablas de un dominio ajeno; las dependencias entre servicios son llamadas HTTP. Los estados de asignación son dominio de Dispatch (SAD §7). | SDD §4.2; ADR-0030 §2 (Propuesto) |
| T2 | Si un servicio del que se depende no responde, el llamador devuelve `503` y no sustituye la respuesta por lógica local ni por un valor por omisión. | SDD §4.2; ADR-0030 §2 (Propuesto) |
| T3 | Toda tabla nueva nace con `tenant_id`, RLS habilitado y su política por tenant en la misma migración. **Aplica cuando se apruebe ADR-0030:** la migración vive en `MANI-Node/db/migrations/`, y Rules y Dispatch no versionan DDL. | ADR-0012 (Aceptado); ADR-0030 §1 (Propuesto) |
| T4 | El tenant, el rol y el usuario se toman del claim verificado y se propagan en `X-Tenant-Id`, `X-User-Role` y `X-Correlation-ID`; nunca se toman del cuerpo de la petición. | ADR-0018 |
| T5 | Los errores responden con el formato `{ error, code, correlationId }` en todos los servicios. | Contrato de Core |
| T6 | La aplicación móvil solo usa `supabase.auth`; todo acceso a datos pasa por el Gateway. | ADR-0027 |
| T7 | Sin token o con token inválido, el Gateway responde `401` y la petición no llega al servicio. | CC-3 en Jira; ADR-0018 |
| T8 | Las peticiones y respuestas cumplen el contrato OpenAPI publicado en el Gateway. | CC-4 en Jira; QAS-06 |
| T9 | El servicio falla cerrado sin `SUPABASE_JWT_SECRET`, salvo con `NODE_ENV=development` o `test`; `dev-token` solo existe en desarrollo. | ADR-0031 (Aprobado) |
| T10 | Las operaciones administrativas (crear, aprobar, rechazar, desactivar) registran quién, cuándo, la decisión y el `correlationId`. | RNF-04; CA-5 de SCRUM-1066 |

## 3. Criterios por historia

### SCRUM-850 · Registrar empleado directo · RF-05 · Nicolás León

- **C1 (positivo).** Dado un administrador del tenant autenticado, cuando registra un empleado directo con los datos obligatorios, entonces el aliado queda creado en ese tenant con tipo empleado directo.
- **C2 (negativo).** Dado un registro al que le falta un dato obligatorio, cuando se envía, entonces se rechaza con el error de validación del contrato y no se crea ningún registro.
- **C3 (regla crítica).** Dado un administrador del tenant A, cuando envía en el cuerpo el identificador del tenant B, entonces el empleado no queda en el tenant B (T4).
- **C4 (duplicado).** Dado un empleado ya registrado, cuando se intenta registrar de nuevo, entonces se responde `409` y sigue existiendo un solo registro.
- **C5 (rol no autorizado).** Dado un usuario que no es administrador del tenant, cuando intenta registrar un empleado directo, entonces la petición se rechaza.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1306 · **Casos:** US0215-P1, N1, N2, S1, S2, E1, X1 a X5, G1.

### SCRUM-852 · Cliente empresa con varios sitios · RF-08 · Nicolás León

- **C1 (positivo).** Dado un cliente empresa autenticado, cuando registra dos o más sitios con su zona, entonces cada sitio queda asociado al cliente.
- **C2 (negativo).** Dado un sitio con campos inválidos o sin zona asignada, cuando se intenta registrar, entonces se rechaza con el error de validación del contrato, porque todo sitio debe tener una zona (RF-09).
- **C3 (regla crítica).** Dado el usuario de otra empresa o de otro tenant, cuando intenta consultar o modificar esos sitios, entonces recibe rechazo o ausencia de datos.
- **C4 (roles, decisión del PO).** Los sitios de un cliente empresa los crean y editan **el propio cliente empresa o el administrador de su tenant**. Un aliado u otro cliente que lo intente recibe rechazo.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1307 · **Casos:** US0222-P1, N1, S1, S2, E1, X1 a X5.

### SCRUM-853 · Reglas del sitio visibles al aliado · RF-09 · Nicolás León

- **C1 (positivo).** Dado un sitio con reglas de acceso registradas, cuando un aliado es asignado a una solicitud en ese sitio, entonces ve las reglas antes de la programación.
- **C2 (negativo).** Dado un aliado que no está asignado a ninguna solicitud del sitio, cuando consulta las reglas, entonces no las recibe.
- **C3 (regla crítica).** Dado un aliado de otro tenant, cuando intenta consultar las reglas del sitio, entonces recibe rechazo o ausencia de datos.
- **C4 (sitio sin reglas).** Dado un sitio sin reglas registradas, cuando el aliado asignado las consulta, entonces recibe una respuesta vacía, no un error.
- **C5 (cambio de sitio).** Dado que la solicitud cambia de sitio, cuando el aliado consulta las reglas, entonces ve las del sitio nuevo y no las del anterior.
- **Pantalla Flutter:** MANI-Flutter#44.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1308 · **Casos:** US0223-P1, P2, P3, S1, E1, X1 a X5.

### SCRUM-854 · Editar perfil propio · RF-30 · Nicolás León

- **C1 (positivo).** Dado un usuario autenticado, cuando edita un dato permitido de su perfil o su foto, entonces el cambio queda guardado y se refleja al consultarlo.
- **C2 (negativo).** Dado un dato con formato inválido, cuando se envía, entonces se rechaza con el error de validación del contrato y el perfil no cambia.
- **C3 (regla crítica).** Dado un usuario, cuando intenta editar el perfil de otro usuario o cambiar su propio rol, tenant o estado de verificación, entonces la petición se rechaza.
- **Pantalla Flutter:** MANI-Flutter#45.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1309 · **Casos:** US0231-P1, P2, N1, S1, S2, X1 a X6.

### SCRUM-855 · Aliado gestiona su disponibilidad · RF-29 · José Nicolás Álvarez

Decisión del PO: el aliado registra **intervalos en los que NO está disponible** (vacaciones, enfermedad), como dice la historia y como ya implementa el contrato del Gateway (`/profiles/me/unavailability`). RF-29 del SRS se ajusta a este modelo.

- **C1 (positivo).** Dado un aliado aprobado, cuando registra o edita un intervalo de no disponibilidad, entonces no se presenta como aliado válido durante ese intervalo.
- **C2 (negativo).** Dado un intervalo cuya fecha de fin es anterior a la de inicio, cuando se envía, entonces se rechaza con el error de validación del contrato.
- **C3 (regla crítica).** Dado un aliado, cuando intenta modificar la no disponibilidad de otro aliado, entonces la petición se rechaza.
- **C4 (solapamiento, decisión del PO).** Dado un intervalo que se cruza con otro ya registrado del mismo aliado, cuando se envía, entonces **se rechaza y la respuesta le explica al aliado que se cruza con un intervalo existente**.
- **C5 (elegibilidad).** Dado un aliado dentro de un intervalo de no disponibilidad, cuando se conforma el listado de aliados válidos (SCRUM-861), entonces no aparece.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1310 · **Casos:** US0216-P1, P2, N1, N2, I1, S1, X1 a X5. Latencia de la consulta dentro del umbral (QAS-03).

### SCRUM-856 · Aceptar términos y condiciones · RF-31 · Nicolás León

- **C1 (positivo).** Dado un usuario que no ha aceptado la versión vigente, cuando la acepta de forma expresa, entonces queda registrado el consentimiento con versión, usuario y fecha, y puede usar la plataforma.
- **C2 (negativo).** Dado un usuario sin la versión vigente aceptada, cuando intenta usar una función de la plataforma, entonces se le exige aceptarla primero.
- **C3 (regla crítica).** Dado que se publica una nueva versión, cuando un usuario que aceptó la anterior inicia sesión, entonces debe aceptar la nueva.
- **C4 (consulta).** Dado un usuario autenticado, cuando consulta su consentimiento, entonces ve la versión aceptada y la fecha.
- **C5 (consentimiento ajeno).** Dado otro usuario del mismo tenant, cuando intenta consultar o modificar ese consentimiento, entonces la petición se rechaza.
- **Pantalla Flutter:** MANI-Flutter#41.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1311 · **Casos:** US0232-P1, P2, P3, N1, S1, E1, X1 a X5. La tabla de consentimientos cumple T3.

### SCRUM-858 · Desactivar categoría sin afectar servicios en curso · RF-10 · Juan Sebastián Álvarez

- **C1 (positivo).** Dado un administrador del tenant, cuando desactiva una categoría, entonces deja de ofrecerse en el catálogo y en las solicitudes nuevas.
- **C2 (negativo).** Dada una categoría desactivada, cuando un cliente intenta crear una solicitud nueva con ella, entonces se rechaza.
- **C3 (regla crítica).** Dado que hay servicios en curso de esa categoría, cuando se desactiva, entonces esos servicios continúan sin cambios hasta cerrarse.
- **C4 (permisos).** Dado un usuario que no es administrador, o un administrador de otro tenant, cuando intenta desactivar la categoría, entonces la petición se rechaza.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1312 · **Casos:** US0312-P1, P2, N1, S1, I1, X1 a X5, G1. Si se consulta el estado de los servicios en Dispatch, se hace por HTTP (T1). Registra la operación según T10.

### SCRUM-861 · Ver aliados válidos por cobertura y categoría · RF-12 · Nicolás León

- **C1 (positivo).** Dada una solicitud con categoría y zona, cuando se conforma el listado, entonces solo incluye aliados aprobados, de esa categoría, con cobertura en la zona y sin intervalo de no disponibilidad vigente.
- **C2 (negativo).** Dado que ningún aliado cumple las condiciones, cuando se conforma el listado, entonces se devuelve vacío con un mensaje, no un error.
- **C3 (regla crítica).** El listado nunca incluye aliados de otro tenant, sin aprobar, fuera de cobertura, de otra categoría o no disponibles. Dispatch obtiene la elegibilidad de Core por HTTP (T1) y responde `503` si Core no responde (T2).
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1313 · **Casos:** US0412-P1, N1, N2, N3, S1, R1, X1 a X5. Latencia dentro del umbral (QAS-03).

### SCRUM-862 · Filtrar por tipo de aliado · RF-12 · José Nicolás Álvarez

Decisión del PO (comentario del 19-oct en SCRUM-862): los tipos de aliado válidos son **persona natural, empresa y empleado directo** (RF-05).

- **C1 (positivo).** Dado un listado de aliados válidos, cuando el cliente filtra por uno de los tres tipos, entonces solo ve aliados de ese tipo.
- **C2 (negativo).** Dado un tipo de aliado que no es ninguno de los tres, cuando se usa como filtro, entonces se rechaza con el error de validación del contrato.
- **C3 (regla crítica).** Dado cualquier filtro o combinación de filtros, el resultado nunca incluye aliados fuera del listado de aliados válidos de SCRUM-861; si no hay coincidencias, se devuelve vacío.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1314 · **Casos:** US0413-P1, P2, P3, P4, N1, S1, X1 a X5.

### SCRUM-1060 · Registro de empresa en la app vía Gateway · RF-05 · José Nicolás Álvarez

**Siguen vigentes los CC-1 a CC-4 y los CA de Jira** (entre ellos CA-2, dominio intacto; CA-5, fiel al diseño de Figma; y CA-6, rechazo cross-tenant). C1 a C3 se suman a ellos.

- **C1 (positivo).** Dado un usuario en la app, cuando completa el registro de aliado empresa, entonces la app lo envía al Gateway y muestra el resultado.
- **C2 (negativo).** Dado que el Gateway responde con error, cuando la app lo recibe, entonces muestra un mensaje comprensible con el `correlationId` y el usuario no pierde lo diligenciado.
- **C3 (regla crítica).** La app no llama a Supabase con `.from()`, `.rpc()` ni `.storage.from()` en este flujo (T6).
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1328 · **Casos:** US0212M3-C1 a C4, P1, N1 a N4, S1 a S3, E1, M1 a M3, X1 a X6. En Flutter, el resultado local de `flutter analyze` y `flutter test` reemplaza al CI (decisión de QA, §4).

### SCRUM-1063 · Registro de aliado empresa en Core · RF-05 · Nicolás León

**Siguen vigentes los CC-1 a CC-4 y los CA-1 a CA-5 de Jira** (entre ellos CA-2, documentos en bucket privado con ruta `tenant_id/aliado_id/documento`). C1 a C3 se suman a ellos.

- **C1 (positivo).** Dado un registro con los documentos exigidos por la configuración del tenant, cuando Core lo recibe, entonces crea el aliado empresa en estado pendiente de verificación.
- **C2 (negativo).** Dado un registro al que le falta un documento exigido, cuando Core lo recibe, entonces lo rechaza con el error de validación del contrato y no crea ningún registro.
- **C3 (regla crítica).** El tenant se toma del claim (T4), y los documentos de un aliado no son accesibles para otro aliado ni para otro tenant.
- **CA-4 cerrado por el PO (empresa duplicada).** Dada una empresa ya registrada en el tenant, cuando se intenta registrar de nuevo, entonces se responde `409` y no se crea un segundo registro.
- **Acepta:** Camila (PO) · **Verifica:** sin subtarea QA (pendiente PE4) · **Casos:** US0212M2-C1 a C4, P1, P2, N1, N2, F1, M1 a M3, X1 a X6.

### SCRUM-1066 · Aprobar o rechazar registro de aliado · RF-06 · Nicolás León

**Siguen vigentes los CC-1 a CC-4 y los CA-1 a CA-7 de Jira** (entre ellos CA-2, acceso temporal a los documentos KYC; CA-5, auditoría; y CA-6, `403` para aliado o cliente). C1 a C3 se suman a ellos.

- **C1 (positivo).** Dado un aliado pendiente, cuando el administrador del tenant lo aprueba, entonces queda aprobado y puede aparecer como aliado válido.
- **C2 (negativo).** Dado un aliado pendiente, cuando el administrador lo rechaza, entonces queda rechazado con el motivo y no aparece como aliado válido.
- **C3 (regla crítica).** Un aliado no puede aprobarse a sí mismo, y un administrador de otro tenant no puede aprobarlo ni rechazarlo.
- **Acepta:** Camila (PO) · **Verifica:** sin subtarea QA (pendiente PE4) · **Casos:** US0213M2-C1 a C4, P1 a P4, N1, S1, E1, M1 a M3, X1 a X6. Registra la decisión según T10. Si se notifica al aliado, la notificación es simulada.

### SCRUM-1068 · Zona de cobertura · RF-07 · Nicolás León

- **C1 (positivo).** Dado un aliado aprobado, cuando declara sus zonas desde el catálogo de zonas del tenant, entonces quedan registradas como su cobertura.
- **C2 (negativo).** Dada una zona que no existe en el catálogo, cuando se declara, entonces se rechaza con el error de validación del contrato.
- **C3 (regla crítica).** Las zonas de otro tenant no pueden seleccionarse.
- **Acepta:** Camila (PO) · **Verifica:** sin subtarea QA (pendiente PE4) · **Casos:** US0214M2-P1, N1, S1, M1 a M3, X1 a X5. La cobertura es dominio de Core (ADR-0028); el título de la historia aún menciona «Availability Service» (PE3).

### SCRUM-1070 · Reglas de categoría en Rules · RF-02 · Juan Sebastián Álvarez

Criterios definidos después del cierre de la historia; se verifican en la regresión del Sprint 4.

- **C1 (positivo).** Dada una regla de categoría configurada por el tenant, cuando Core la consulta, entonces Rules la evalúa y responde según esa configuración, manteniendo el comportamiento funcional previo.
- **C2 (negativo).** Dada una categoría inválida, inactiva o fuera de los límites, cuando Core la consulta, entonces Rules la rechaza con el error del contrato.
- **C3 (regla crítica).** Dado que Rules no responde, cuando Core lo consulta, entonces Core devuelve `503` y no aplica una regla local (T2). La regla del tenant A nunca se aplica al tenant B.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1329 · **Casos:** US0311M6-P1, N1 a N3, F1, S1, C1, R1, M1 a M3, X1 a X5. Un cambio de regla del tenant surte efecto sin despliegue (QAS-04).

### SCRUM-1072 · Creación de solicitud en Core · RF-12 · Nicolás León

- **C1 (positivo).** Dado un cliente autenticado, cuando crea una solicitud con categoría y sitio, entonces Core la persiste y queda lista para que Dispatch la orqueste, sin replicar lógica de despacho.
- **C2 (negativo).** Dada una solicitud con datos erróneos o incompletos, cuando se envía, entonces se rechaza con el error de validación del contrato y no se crea.
- **C3 (regla crítica).** Un cliente no puede crear solicitudes sobre el sitio de otro cliente ni de otro tenant.
- **C4 (sin permiso).** Dado un usuario sin permiso para crear solicitudes, cuando lo intenta, entonces recibe `403`.
- **C5 (falla de dependencia).** Dado que una dependencia de Core no responde, cuando se crea la solicitud, entonces Core responde `503` y no queda una solicitud a medias (T2, QAS-09).
- **C6 (reintento).** Dado un reintento con la misma `claveIdempotencia`, cuando llega a Core, entonces no se crea una segunda solicitud.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1330 · **Casos:** US0411M2-P1, N1, S1, F1, K1, E1, M1 a M3, X1 a X6. Core crea la solicitud y Dispatch la orquesta (decisión D1 de SCRUM-1232).

### SCRUM-1073 · Orquestación del despacho en Dispatch · RF-12, RF-13 · Nicolás León

- **C1 (positivo).** Dada una solicitud creada en Core, cuando Dispatch la orquesta, entonces pide a Core los aliados elegibles y a Rules el orden, ambos por HTTP, y envía el broadcast.
- **C2 (negativo).** Dado que Core o Rules no responden, cuando Dispatch los consulta, entonces devuelve `503`, no arma el listado con lógica local y no deja la solicitud en estado ambiguo (T2, QAS-09).
- **C3 (regla crítica).** Dispatch no hace consultas SQL sobre tablas de Core ni inserta en tablas de notificación: notifica a través de Core (T1).
- **C4 (sin candidatos).** Dado que no hay aliados elegibles, cuando Dispatch orquesta, entonces la solicitud queda sin broadcast y el cliente recibe un resultado claro, no un error.
- **C5 (reintentos).** Dado un reintento de la orquestación, cuando llega a Dispatch, entonces no se duplica el broadcast.
- **Mocks:** las notificaciones push del broadcast son simuladas en QA.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1331 · **Casos:** US0411M6-P1, P2, K1, F1, S1, I1, M1 a M3, X1 a X5. Escenarios críticos aprobados (QAS-07); un fallo de push no revierte una operación confirmada (QAS-02).

### SCRUM-1074 · Aceptar o rechazar sin doble asignación · RF-14 · Nicolás León

La asignación es dominio de Dispatch (SAD §7, «estados de asignación»), así que escribirla no viola T1. El dueño del estado de la solicitud después de la asignación es el pendiente P1 del SAD §7.4 (Juan Sebastián, 20 oct, SCRUM-1233). La exclusión concurrente sigue ADR-0016 (Propuesto).

- **C1 (positivo).** Dado un broadcast activo, cuando el primer aliado acepta, entonces la solicitud queda asignada a ese aliado.
- **C2 (negativo).** Dado que la solicitud ya fue asignada, cuando otro aliado intenta aceptarla, entonces recibe `409`.
- **C3 (regla crítica).** Bajo aceptaciones concurrentes nunca hay dos aliados asignados a la misma solicitud, y un reintento de la misma aceptación no cambia el resultado.
- **C4 (rechazo).** Dado un broadcast activo, cuando un aliado lo rechaza, entonces queda registrado su rechazo y la solicitud sigue disponible para los demás.
- **C5 (aliado no autorizado).** Dado un aliado que no recibió el broadcast o es de otro tenant, cuando intenta aceptar, entonces la petición se rechaza.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1332 · **Casos:** US0414M6-K1, K2, P1, P2, N1, S1, M1 a M3, X1 a X5. Cero dobles asignaciones e idempotencia (QAS-07).

## 4. Añadidos al DoD — Decidido por QA

Decisión de Santiago (QA) en la revisión del PR #49 (https://github.com/Trama-AS/MANI-docs/pull/49). QA la lleva a `wiki/05-proceso/dor-y-dod.md` en su propio PR, junto con la corrección de la numeración de los QAS.

| Propuesta | Decisión de QA |
|---|---|
| Fila «Datos o reglas de otro servicio» | Aprobada tal cual, con respaldo en SDD §4.2. |
| Fila «Esquema o tablas» | Aprobada en dos partes: `tenant_id`, RLS y política en la misma migración, vigente desde ya (ADR-0012); migración en `MANI-Node/db/migrations/`, cuando se apruebe ADR-0030. |
| Evidencia exigida | Aprobada con dos ajustes: la evidencia de QA va en la subtarea QA de la historia, con los IDs de casos de la matriz SCRUM-1264; en Flutter, el resultado local de `flutter analyze` y `flutter test` reemplaza al CI, porque los PRs a `develop` no lo corren. |

## 5. Pendientes

| ID | Pendiente | Responsable |
|---|---|---|
| PE2 | Los PRs de 856, 861, 1073 y 1074 ya cumplen T1 y T3. Faltan dos cosas: que MANI-Node#14 resuelva su conflicto con `develop`, y que MANI-Node#43 cierre el acceso a los endpoints internos para que entren MANI-.NET#3, #2 y #1. | Nicolás León |
| PE3 | Corregir el título de SCRUM-1068, que menciona «Availability Service». | Nicolás León |
| PE4 | Crear las subtareas QA de SCRUM-1063, 1066 y 1068. | Santiago (QA) |
| PE5 | Dispatch responde `{ error, status }`; debe responder según T5. | Nicolás León |
| PE6 | El filtro de Dispatch solo acepta `PERSONA_NATURAL` y `PERSONA_JURIDICA`; debe aceptar también `EMPLEADO_DIRECTO` (decisión de SCRUM-862). | José Nicolás Álvarez |
| PE7 | Definir el límite de tamaño de la foto de perfil de SCRUM-854 (brecha B-21 de la matriz). | Camila (PO) |
| PE8 | Ajustar RF-29 del SRS al modelo de intervalos de no disponibilidad. | Camila (PO) |
| PE9 | En Jira: corregir la descripción de SCRUM-862 (habla de cotizaciones, brecha B-24); quitar «funciones PL/pgSQL» de 1060, 1066, 1070, 1072, 1073 y 1074 (B-16); cambiar ADR-0021 por ADR-0016 en 1074 (B-17); y enlazar cada historia a su sección de este documento. | Camila (PO) |

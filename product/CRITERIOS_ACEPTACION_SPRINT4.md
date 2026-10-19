# Criterios de aceptación y DoD de las historias priorizadas del Sprint 4

| Campo | Valor |
|---|---|
| Tarea | SCRUM-1257 (PO4-02), subtareas SCRUM-1286 y SCRUM-1287 |
| Historias | Las 17 historias del Sprint 4 de la matriz de SCRUM-1256 |
| Autora | Camila Beltrán (PO) |
| Fecha | 18 de octubre de 2026 |
| Estado | Criterios de aceptación: decisión del PO. Añadidos al DoD: propuesta para decisión de QA |
| Alimenta a | SCRUM-1245 (Backlog V5) |

## 1. Alcance y autoridad

Este documento fija los criterios de aceptación de las 17 historias priorizadas del Sprint 4 y propone los añadidos al DoD que exige el ADR-0030.

Según `governance/GOBIERNO_DEL_EQUIPO.md` §2.3, el PO decide los criterios de aceptación y QA decide el Definition of Done. Por eso la sección 4 es una propuesta: entra en `wiki/05-proceso/dor-y-dod.md` solo si QA la aprueba.

Cada historia tiene tres criterios en formato BDD, como pide el backlog: un caso positivo (C1), uno negativo (C2) y un intento de violar la regla crítica (C3). Los criterios describen el comportamiento exigido por el SRS; no fijan nombres de campos ni de rutas, que pertenecen a los contratos de cada servicio.

Fuentes: `product/SRS.md` (RF-02 a RF-36), `architecture/SAD.md` §7, `wiki/05-proceso/dor-y-dod.md`, ADR-0022, ADR-0027, ADR-0029 y ADR-0030, y la matriz de SCRUM-1256.

## 2. Criterios transversales

Aplican a todas las historias de este documento, además de sus criterios propios. Una historia que incumpla uno de ellos no se acepta.

| ID | Criterio | Origen |
|---|---|---|
| T1 | Ningún servicio consulta ni escribe tablas de un dominio ajeno. Las dependencias entre servicios son llamadas HTTP. | ADR-0030 §2 |
| T2 | Si un servicio del que se depende no responde, el llamador devuelve `503` y no sustituye la respuesta por lógica local ni por un valor por omisión. | ADR-0030 §2 |
| T3 | Toda tabla nueva nace con `tenant_id`, `ENABLE ROW LEVEL SECURITY` y su política por tenant en la misma migración, y la migración vive en `MANI-Node/db/migrations/`. Rules y Dispatch no versionan DDL. | ADR-0030 §1 |
| T4 | El tenant, el rol y el usuario se toman del claim verificado y se propagan en `X-Tenant-Id`, `X-User-Role` y `X-Correlation-ID`. Nunca se toman del cuerpo de la petición. | ADR-0030 §2, ADR-0018 |
| T5 | Los errores responden con el formato `{ error, code, correlationId }`. | Contrato de Core |
| T6 | La aplicación móvil solo usa `supabase.auth`; todo acceso a datos pasa por el Gateway. | ADR-0027 |

## 3. Criterios por historia

### SCRUM-850 · Registrar empleado directo · RF-05 · Nicolás León

- **C1 (positivo).** Dado un administrador del tenant autenticado, cuando registra un empleado directo con los datos obligatorios, entonces el aliado queda creado en ese tenant con tipo empleado directo.
- **C2 (negativo).** Dado un registro al que le falta un dato obligatorio, cuando se envía, entonces se rechaza con `VALIDATION_ERROR` y no se crea ningún registro.
- **C3 (regla crítica).** Dado un administrador del tenant A, cuando envía en el cuerpo el identificador del tenant B, entonces el empleado no queda en el tenant B (T4).
- **Añadidos del DoD:** los seis casos cross-tenant.

### SCRUM-852 · Cliente empresa con varios sitios · RF-08 · Nicolás León

- **C1 (positivo).** Dado un cliente empresa autenticado, cuando registra dos o más sitios con su zona, entonces cada sitio queda asociado al cliente y visible solo para él y para el administrador de su tenant.
- **C2 (negativo).** Dado un sitio sin zona asignada, cuando se intenta registrar, entonces se rechaza, porque todo sitio debe tener una zona (RF-09).
- **C3 (regla crítica).** Dado el usuario de otro cliente o de otro tenant, cuando intenta consultar o modificar esos sitios, entonces recibe rechazo o ausencia de datos.
- **Añadidos del DoD:** los seis casos cross-tenant.

### SCRUM-853 · Reglas del sitio visibles al aliado · RF-09 · Nicolás León

- **C1 (positivo).** Dado un sitio con reglas de acceso registradas, cuando un aliado es asignado a una solicitud en ese sitio, entonces ve las reglas antes de la programación.
- **C2 (negativo).** Dado un aliado que no está asignado a ninguna solicitud del sitio, cuando consulta las reglas, entonces no las recibe.
- **C3 (regla crítica).** Dado un aliado de otro tenant, cuando intenta consultar las reglas del sitio, entonces recibe rechazo o ausencia de datos.
- **Añadidos del DoD:** los seis casos cross-tenant.

### SCRUM-854 · Editar perfil propio · RF-30 · Nicolás León

- **C1 (positivo).** Dado un usuario autenticado, cuando edita un dato permitido de su perfil, entonces el cambio queda guardado y se refleja al consultarlo.
- **C2 (negativo).** Dado un dato con formato inválido, cuando se envía, entonces se rechaza con `VALIDATION_ERROR` y el perfil no cambia.
- **C3 (regla crítica).** Dado un usuario, cuando intenta editar el perfil de otro usuario o cambiar su propio rol, tenant o estado de verificación, entonces la petición se rechaza.
- **Añadidos del DoD:** los seis casos cross-tenant.

### SCRUM-855 · Aliado gestiona su disponibilidad · RF-29 · José Nicolás Álvarez

- **C1 (positivo).** Dado un aliado aprobado, cuando declara un horario o un periodo de disponibilidad, entonces solo se presenta como aliado válido dentro de ese horario o periodo.
- **C2 (negativo).** Dado un periodo cuya fecha de fin es anterior a la de inicio, cuando se envía, entonces se rechaza con `VALIDATION_ERROR`.
- **C3 (regla crítica).** Dado un aliado, cuando intenta modificar la disponibilidad de otro aliado, entonces la petición se rechaza.
- **Añadidos del DoD:** los seis casos cross-tenant; latencia de la consulta de disponibilidad dentro del umbral (QAS-03).

### SCRUM-856 · Aceptar términos y condiciones · RF-31 · Nicolás León

- **C1 (positivo).** Dado un usuario que no ha aceptado la versión vigente, cuando la acepta, entonces queda registrada la versión aceptada y la fecha, y puede usar la plataforma.
- **C2 (negativo).** Dado un usuario sin la versión vigente aceptada, cuando intenta usar una función de la plataforma, entonces se le exige aceptarla primero.
- **C3 (regla crítica).** Dado que se publica una nueva versión, cuando un usuario que aceptó la anterior inicia sesión, entonces debe aceptar la nueva.
- **Añadidos del DoD:** los seis casos cross-tenant; la tabla de aceptación cumple T3 (hallazgo del ADR-0030 sobre su PR).

### SCRUM-858 · Desactivar categoría sin afectar servicios en curso · RF-10 · Juan Sebastián Álvarez

- **C1 (positivo).** Dado un administrador del tenant, cuando desactiva una categoría, entonces deja de ofrecerse en las solicitudes nuevas.
- **C2 (negativo).** Dado que hay solicitudes en curso de esa categoría, cuando se desactiva, entonces esas solicitudes continúan sin cambios hasta cerrarse.
- **C3 (regla crítica).** Dado un administrador de otro tenant, cuando intenta desactivar la categoría, entonces la petición se rechaza.
- **Añadidos del DoD:** los seis casos cross-tenant; si se consulta el estado de las solicitudes en Dispatch, se hace por HTTP (T1).

### SCRUM-861 · Ver aliados válidos por cobertura y categoría · RF-12 · Nicolás León

- **C1 (positivo).** Dada una solicitud con categoría y zona, cuando se conforma el listado, entonces solo incluye aliados aprobados, de esa categoría, con cobertura en la zona y disponibles.
- **C2 (negativo).** Dado que ningún aliado cumple las condiciones, cuando se conforma el listado, entonces se devuelve vacío con un mensaje, no un error.
- **C3 (regla crítica).** Dado el listado, nunca incluye aliados de otro tenant, sin aprobar o sin disponibilidad. Dispatch obtiene la elegibilidad de Core por HTTP, no por SQL (T1), y si Core no responde devuelve `503` (T2).
- **Añadidos del DoD:** los seis casos cross-tenant; latencia dentro del umbral (QAS-03).

### SCRUM-862 · Filtrar por tipo de aliado · RF-12 · José Nicolás Álvarez

- **C1 (positivo).** Dado un listado de aliados válidos, cuando el cliente filtra por un tipo de aliado, entonces solo ve aliados de ese tipo.
- **C2 (negativo).** Dado un tipo de aliado que no existe, cuando se usa como filtro, entonces se rechaza con `VALIDATION_ERROR`.
- **C3 (regla crítica).** Dado cualquier filtro, el resultado nunca incluye aliados fuera del listado de aliados válidos de SCRUM-861.
- **Añadidos del DoD:** los seis casos cross-tenant.

### SCRUM-1060 · Registro de empresa en la app vía Gateway · RF-05 · José Nicolás Álvarez

- **C1 (positivo).** Dado un usuario en la app, cuando completa el registro de aliado empresa, entonces la app lo envía al Gateway y muestra el resultado.
- **C2 (negativo).** Dado que el Gateway responde con error, cuando la app lo recibe, entonces muestra un mensaje comprensible con el `correlationId` y el usuario no pierde lo diligenciado.
- **C3 (regla crítica).** La app no llama a Supabase con `.from()`, `.rpc()` ni `.storage.from()` en este flujo (T6).
- **Añadidos del DoD:** los seis casos cross-tenant.

### SCRUM-1063 · Registro de aliado empresa en Core · RF-05 · Nicolás León

- **C1 (positivo).** Dado un registro con los documentos exigidos por la configuración del tenant, cuando Core lo recibe, entonces crea el aliado empresa en estado pendiente de verificación.
- **C2 (negativo).** Dado un registro al que le falta un documento exigido, cuando Core lo recibe, entonces lo rechaza y no crea ningún registro.
- **C3 (regla crítica).** El tenant se toma del claim o del encabezado de tenant, nunca del cuerpo (T4), y los documentos de un aliado no son accesibles para otro aliado ni para otro tenant.
- **Añadidos del DoD:** los seis casos cross-tenant.

### SCRUM-1066 · Aprobar o rechazar registro de aliado · RF-06 · Nicolás León

- **C1 (positivo).** Dado un aliado pendiente, cuando el administrador del tenant lo aprueba, entonces queda aprobado y puede aparecer como aliado válido.
- **C2 (negativo).** Dado un aliado pendiente, cuando el administrador lo rechaza, entonces queda rechazado con el motivo y no aparece como aliado válido.
- **C3 (regla crítica).** Un aliado no puede aprobarse a sí mismo, y un administrador de otro tenant no puede aprobarlo ni rechazarlo.
- **Añadidos del DoD:** los seis casos cross-tenant.

### SCRUM-1068 · Zona de cobertura · RF-07 · Nicolás León

- **C1 (positivo).** Dado un aliado aprobado, cuando declara sus zonas desde el catálogo de zonas del tenant, entonces quedan registradas como su cobertura.
- **C2 (negativo).** Dada una zona que no existe en el catálogo, cuando se declara, entonces se rechaza.
- **C3 (regla crítica).** Las zonas de otro tenant no pueden seleccionarse.
- **Añadidos del DoD:** los seis casos cross-tenant. La disponibilidad y la cobertura son dominio de Core (ADR-0028); el título de la historia aún menciona "Availability Service".

### SCRUM-1070 · Reglas de categoría en Rules · RF-02 · Juan Sebastián Álvarez

- **C1 (positivo).** Dada una regla de categoría configurada por el tenant, cuando Core la consulta, entonces Rules la evalúa y responde según la configuración del tenant.
- **C2 (negativo).** Dado que Rules no responde, cuando Core lo consulta, entonces Core devuelve `503` y no aplica una regla local (T2).
- **C3 (regla crítica).** La regla del tenant A nunca se aplica al tenant B.
- **Añadidos del DoD:** un cambio de regla del tenant surte efecto sin despliegue (QAS-05).

### SCRUM-1072 · Creación de solicitud en Core · RF-12 · Nicolás León

- **C1 (positivo).** Dado un cliente autenticado, cuando crea una solicitud con categoría y sitio, entonces Core la persiste y queda lista para que Dispatch la orqueste.
- **C2 (negativo).** Dada una solicitud a la que le falta un dato obligatorio, cuando se envía, entonces se rechaza con `VALIDATION_ERROR` y no se crea.
- **C3 (regla crítica).** Un cliente no puede crear solicitudes sobre el sitio de otro cliente ni de otro tenant.
- **Añadidos del DoD:** los seis casos cross-tenant. Core crea la solicitud y Dispatch la orquesta (decisión D1 de SCRUM-1232).

### SCRUM-1073 · Orquestación del despacho en Dispatch · RF-12, RF-13 · Nicolás León

- **C1 (positivo).** Dada una solicitud creada en Core, cuando Dispatch la orquesta, entonces pide a Core los aliados elegibles y a Rules el orden, ambos por HTTP, y envía el broadcast.
- **C2 (negativo).** Dado que Core o Rules no responden, cuando Dispatch los consulta, entonces devuelve `503` y no arma el listado con lógica local (T2).
- **C3 (regla crítica).** Dispatch no hace consultas SQL sobre tablas de Core ni inserta en tablas de notificación: notifica a través de Core (T1, ADR-0030).
- **Añadidos del DoD:** idempotencia de la orquestación (QAS-02); un fallo de push no revierte una operación confirmada (QAS-04).

### SCRUM-1074 · Aceptar o rechazar sin doble asignación · RF-14 · Nicolás León

- **C1 (positivo).** Dado un broadcast activo, cuando el primer aliado acepta, entonces la solicitud queda asignada a ese aliado.
- **C2 (negativo).** Dado que la solicitud ya fue asignada, cuando otro aliado intenta aceptarla, entonces recibe `409`.
- **C3 (regla crítica).** Bajo aceptaciones concurrentes nunca hay dos aliados asignados a la misma solicitud, y un reintento de la misma aceptación no cambia el resultado.
- **Añadidos del DoD:** cero dobles asignaciones bajo concurrencia e idempotencia (QAS-02); el acceso a datos cumple T1.

## 4. Propuesta de añadidos al DoD (decisión de QA)

Se propone agregar dos filas a la tabla "Añadidos que aplican a historias concretas" de `wiki/05-proceso/dor-y-dod.md`:

| Si la historia toca… | Debe demostrar |
|---|---|
| Esquema o tablas de la base de datos | Que la migración vive en `MANI-Node/db/migrations/` y que toda tabla nueva tiene `tenant_id`, RLS habilitado y política por tenant (ADR-0030 §1) |
| Datos o reglas de otro servicio | Que la dependencia es una llamada HTTP con encabezados tomados del claim verificado, y que responde `503` si la dependencia falla, sin sustituir la respuesta (ADR-0030 §2) |

Evidencia exigida para aceptar cada historia:

- el PR enlazado en Jira, con la clave de la historia en el título y en los commits;
- CI en verde;
- la evidencia de QA de los tres criterios (C1, C2 y C3) y de los añadidos que apliquen.

## 5. Pendientes

| ID | Pendiente | Responsable |
|---|---|---|
| PE1 | Aprobar o ajustar la propuesta de la sección 4. | Santiago (QA) |
| PE2 | Corregir los PRs de SCRUM-856, SCRUM-861, SCRUM-1073 y SCRUM-1074 para que cumplan T1 y T3 antes de entrar. | Nicolás León |
| PE3 | Corregir el título de SCRUM-1068, que menciona "Availability Service". | Nicolás León |

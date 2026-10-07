# Casos de regresión de US-02.1.1-M4

| Campo | Valor |
|---|---|
| Historia | US-02.1.1 - Registro de aliado persona natural con KYC (SCRUM-846, RF-05) |
| Tarea | SCRUM-1062 (M4). Subtarea SCRUM-1185 (M4b). Alimenta a SCRUM-1186, 1187 y 1188 |
| Camino | Flutter -> NGINX Gateway -> Core Node -> Supabase |
| Autor | Santiago (QA) |
| Fecha | 6 de octubre de 2026 |
| Estado | Borrador. Ningún caso se ha ejecutado. Rutas, campos y códigos tomados del contrato v0.3.0 de CFG-16 (`MANI-APIGateway`, rama `CFG-16`) cuando existen; lo que el contrato no cubre queda como marcador |
| Fuente de los casos | `product/CRITERIOS_ACEPTACION_US-02.1.1.md` (SCRUM-1076, PR 13 de `MANI-docs`), escenarios A1 a A4 y B1 a B6 |

## 1. Propósito y reglas

Este documento convierte los escenarios de aceptación en casos ejecutables. Cada caso lleva su resultado esperado escrito **antes** de ejecutar (DoD de M4). Lo que no se pueda saber hoy se marca con un marcador entre llaves dobles y se completa cuando exista el contrato de CFG-16; no se inventan rutas ni códigos de error.

Reglas:

1. Cada caso lleva el identificador del escenario en su nombre. El prefijo `rg` significa regresión.
2. Cada negativo (N) y cada intento de violación (V) exige su control positivo (P) en la misma corrida. Un negativo cuyo control falló no cuenta como pasado.
3. Rechazo de acceso cross-tenant: 403 o 404, o ausencia de datos ajenos; nunca 200 con datos. Para tokens inválidos: 401, del Gateway o del Core según PA-16.
4. Evidencia redactada, sin JWT ni llaves. Las variables llevan nombre en camelCase.
5. Los resultados esperados marcados como "según lectura" provienen de leer el código y no se han observado.
6. Los marcadores se completan con el contrato v0.3.0 cuando lo cubre. Donde el contrato falta o difiere de Flutter, se anota el punto abierto (PA-29 a PA-33 de `CRITERIOS_ACEPTACION_US-02.1.1.md`).

## 2. Dos juegos de casos

| Juego | Qué mide | Camino | Cuándo se puede ejecutar |
|---|---|---|---|
| Línea base | El comportamiento validado en las entregas 1 a 3, que debe preservarse | Flutter directo a Supabase (el camino actual de persona natural, F1) | Hoy, con la colección `mani-aislamiento` y `mani-claims` ya existentes, solo en QA |
| Gateway | El mismo comportamiento y el aislamiento por el camino nuevo | Flutter -> Gateway -> Core | Cuando M1 a M3, CFG-20, CFG-22 y CFG-23 estén desplegados en QA |

Según el ADR-0022 (decisión del equipo del 5 de octubre, documento aún Propuesto), la línea base es además el criterio que autoriza retirar las funciones PL/pgSQL que reemplace M2 ("una vez la regresión en QA confirme el reemplazo"). Por eso cada caso funcional indica si **tiene línea base** o es comportamiento **por construir** (F1).

## 3. Marcadores y datos de prueba

| Marcador | Significado | Se completa con |
|---|---|---|
| `{{url_gateway}}` | Base del Gateway en QA | `API_GATEWAY_URL` de Flutter |
| `{{ruta_registro_aliado}}` | Endpoint público de registro de persona natural | Contrato v0.3.0: `POST /api/v1/core/auth/register/ally`, `multipart/form-data`. Flutter usa la misma ruta desde `25c2a76` |
| `{{ruta_documentos}}` | Carga de documentos | No hay endpoint aparte: los documentos van en el mismo multipart del registro (`cedula_ciudadania`, `rut_certificado`). La carga posterior no existe en el contrato (PA-29) |
| `{{ruta_estado}}` | Consulta de estado del aliado | No existe en el contrato (PA-29) |
| `{{ruta_acceso_documento}}` | Mecanismo de acceso temporal al documento (descarga o URL firmada) | CFG-23a (PA-09); no está en el contrato |
| `{{campo_correlacion}}` | Campo de correlación en la respuesta | Contrato v0.3.0: `correlationId` en el cuerpo del error y el header `X-Correlation-ID` (PA-17) |
| `{{codigo_rechazo}}` | Código exacto de rechazo cross-tenant, entre 403 y 404 | El contrato no define 403 ni 404 (solo 400, 401, 409 y 500); pendiente de CFG-16 |
| `{{formato_error}}` | Estructura del error | Contrato v0.3.0: `{ error, code, correlationId }`, con `code` entre `VALIDATION_ERROR`, `INVALID_CREDENTIALS`, `UNAUTHORIZED`, `TOKEN_INVALID`, `TOKEN_EXPIRED`, `TENANT_NOT_FOUND`, `CATEGORY_NOT_FOUND`, `EMAIL_ALREADY_REGISTERED`, `DOCUMENT_ALREADY_REGISTERED` e `INTERNAL_ERROR` |
| `{{ttl_url_firmada}}` | Vida de la URL firmada | CFG-23a (la colección usa 60 s) |

Usuarios de prueba (existen en la colección `mani-aislamiento`): `aliado.t1`, `aliado.t2`, `admin.t1`, `admin.t2`, `cliente.t1` y `hook.t1` (segundo aliado del tenant 1). Falta un `cliente.t2` (PA-10). Datos: dos tenants activos con su slug (`slug_t1`, `slug_t2`), un tenant inexistente (`slug_inexistente`) y un tenant inactivo si existe en QA.

## 4. Casos funcionales (escenarios A1 a A4)

### 4.1 A1: registro exitoso e identidad fijada por el servidor

| ID | Escenario | Tipo | Línea base | Precondición | Pasos | Resultado esperado |
|---|---|---|---|---|---|---|
| rgA1P | A1-P | Positivo | Parcial (F1): el `signUp` directo crea el usuario, pero no persiste documentos | Tenant 1 activo, categoría activa del tenant y cédula disponible | 1. Enviar multipart a `{{url_gateway}}{{ruta_registro_aliado}}` con `X-Tenant-Slug: slug_t1` y los campos `fullName`, `email`, `password`, `phone`, `categoriaId` y el archivo `cedula_ciudadania` (`rut_certificado` opcional) | 201 con `profile` y `tokens`. El aliado queda con rol ALLY y estado PENDING en el tenant 1. El claim `tenant_id` del token es el del tenant 1 y `user_role` es `aliado`. El documento queda en `kyc-documentos` bajo la ruta que construye el Core (PA-04) y hay una fila de `documento_kyc` con `ruta_storage` igual a la real. La respuesta lleva `X-Correlation-ID` |
| rgA1V1 | A1-V | Violación | No | Mismo contexto | 1. Registrar con `rol: ADMIN_TENANT` en cuerpo o metadata. 2. Registrar con `estado_verificacion: VERIFICADO`. 3. Registrar con un `tenant_id` del tenant 2 en el cuerpo y `X-Tenant-Slug: slug_t1` | En los tres casos el aliado queda con rol aliado, PENDIENTE y en el tenant 1, o la petición se rechaza (PA-05). Nunca queda nada en el tenant 2. Control positivo: rgA1P en la misma corrida |
| rgA1V2 | A1-V (línea base) | Violación | Sí, **según lectura**: `handle_new_user` toma rol y tenant de la metadata (F3) | Camino directo en QA | 1. Hacer `signUp` directo con metadata `rol: ADMIN_TENANT` y `tenant_id` del tenant 2 | Resultado esperado de **aceptación**: el usuario no se crea con ese rol ni en ese tenant. Resultado esperado según lectura del código actual: sí se crea. Si se crea, es un defecto que se registra en Jira y verifica PA-06 |

### 4.2 A2: documento exigido faltante y ruta fuera de la carpeta

| ID | Escenario | Tipo | Línea base | Precondición | Pasos | Resultado esperado |
|---|---|---|---|---|---|---|
| rgA2N | A2-N | Negativo | No: la regla no existe (F4) | Tenant 1 activo | 1. Registrar sin el archivo `cedula_ciudadania` | 400 `VALIDATION_ERROR` que identifica el documento faltante, con `correlationId` y sin detalles de PL/pgSQL ni de Supabase. No queda usuario, aliado, fila de `documento_kyc` ni objeto en Storage. Supuesto: la cédula es el documento exigido (PA-03). Control positivo: rgA1P |
| rgA2V | A2-V | Violación | No | Registro con nombre de archivo o ruta apuntando a otro tenant u otro uid, p. ej. `../<tenant_id_2>/<uid>/cedula` | 1. Enviar el registro | El servidor construye la ruta `<tenant_id>/<uid>/` por sí mismo o rechaza la petición. Ningún objeto queda fuera de la carpeta del propio aliado. Control positivo: rgA1P |
| rgA2D | Contrato v0.3.0 | Negativo | No | Aliado ya registrado en el tenant 1 con un email y un número de documento | 1. Registrar otro aliado con el mismo email. 2. Registrar otro con el mismo número de documento y otro email | 409 con `EMAIL_ALREADY_REGISTERED` en el primer caso y `DOCUMENT_ALREADY_REGISTERED` en el segundo, y `correlationId` en el error. No queda un segundo usuario. Control positivo: rgA1P |

### 4.3 A3: el tenant se resuelve por slug en el registro y por token en lo privado

| ID | Escenario | Tipo | Línea base | Precondición | Pasos | Resultado esperado |
|---|---|---|---|---|---|---|
| rgA3P1 | A3-P | Positivo | No | Tenant 1 activo | 1. Registrar con `X-Tenant-Slug: slug_t1`. 2. Iniciar sesión y decodificar el claim, sin versionar el token | El aliado queda en el tenant 1 y el claim `app_metadata.tenant_id` es el del tenant 1 |
| rgA3P2 | A3-P | Positivo | No | Aliado autenticado en el tenant 1 | 1. Subir un documento a `{{ruta_documentos}}`. 2. Consultar `{{ruta_estado}}` | 2xx. Solo se afectan registros del tenant 1 y del propio uid |
| rgA3N1 | A3-N | Negativo | No: hoy se usa un tenant por defecto (F3) | `slug_inexistente` y, si existe, un tenant inactivo | 1. Registrar con cada uno | Rechazo con 400 y `code` `TENANT_NOT_FOUND` según el contrato v0.3.0. Ningún tenant por defecto. No se crea usuario, aliado ni documento. Control positivo: rgA3P1 |
| rgA3N2 | A3-N | Negativo | No | Sin sesión | 1. Llamar a `{{ruta_documentos}}` y `{{ruta_estado}}` sin cabecera `Authorization`, con token expirado y con firma alterada | 401 del Core en cada variante, con `code` `UNAUTHORIZED` sin cabecera, `TOKEN_EXPIRED` si expiró y `TOKEN_INVALID` si la firma está alterada (contrato v0.3.0; el Gateway no valida, PA-16), sin acceder a ningún dato. Control positivo: rgA3P2 |
| rgA3V1 | A3-V | Violación | No | `X-Tenant-Slug: slug_t1` | 1. Registrar con `tenant_id` del tenant 2 en el cuerpo | El cuerpo se ignora o se rechaza (PA-05). Nada queda en el tenant 2 |
| rgA3V2 | A3-V | Violación | No | Aliado autenticado en el tenant 1 | 1. Operación privada con `tenant_id` del tenant 2 en el cuerpo. 2. La misma con `X-Tenant-Slug: slug_t2` | El Core usa el claim del token. Nada se lee ni se escribe en el tenant 2. Control positivo: rgA3P2 |

### 4.4 A4: solo Gateway

| ID | Escenario | Tipo | Línea base | Precondición | Pasos | Resultado esperado |
|---|---|---|---|---|---|---|
| rgA4P | A4-P | Positivo | No | Build web de QA con M3 desplegado | 1. Ejecutar con Playwright el recorrido de registro y carga de documentos, capturando la red | Todas las peticiones de negocio van a `{{url_gateway}}`. Ninguna va a `rest/v1`, RPC ni Storage de Supabase. La excepción del inicio de sesión de Supabase Auth depende de CFG-35 (PA-07) |
| rgA4N | A4-N | Negativo | Sí, **según lectura**: la anon key está en el bundle (CFG-36) | Artefacto web publicado en QA | 1. Descargar el bundle. 2. Buscar `SUPABASE_ANON_KEY` y la llave de servicio, sin versionar el valor | No aparece ninguna de las dos. Hoy se espera que aparezca la anon key, y eso se reporta por nombre, sin copiar el valor |
| rgA4V | A4-V | Violación | Sí | Token válido de `aliado.t1` | 1. Leer y escribir `aliado` y `documento_kyc` por Supabase REST. 2. Acceder a Storage directo | Acceso denegado o sin ruta. Control positivo: la misma operación por el Gateway funciona (rgA3P2) |

## 5. Casos de aislamiento (escenarios B1 a B6)

Los casos reutilizan los usuarios y las solicitudes de `mani-aislamiento`. La columna "Colección actual" indica qué solicitud existente cubre el camino directo y cuál falta para el Gateway (PA-10).

| ID | Escenario | Negativo | Control positivo | Colección actual | Falta para el Gateway |
|---|---|---|---|---|---|
| rgB1 | B1 lectura | `aliado.t1` consulta el registro o estado de un aliado del tenant 2: 403 o 404 sin datos | Su propio registro: 200 | Carpeta 01 (lee `sitio`, que no es de US-02.1.1) | Solicitudes a `{{ruta_estado}}` |
| rgB2 | B2 listado | `aliado.t1` y `admin.t1` listan: ninguna fila del tenant 2. Un aliado no ve documentos de otro aliado del tenant | Cada listado devuelve al menos una fila propia | Carpeta 02 (`sitio` y `usuario`) y el complemento de la fila de `documento_kyc` | Listados de documentos y aliados por el Gateway |
| rgB3 | B3 escritura | `aliado.t1` intenta modificar el KYC o el estado del tenant 2. Verificar con `admin.t2` que sigue intacto. Variante de inserción con `tenant_id` ajeno. No puede cambiar su propio estado (403) | Reemplazar su propio documento si está PENDIENTE (PA-08) | Carpetas 03 y 03b. El control positivo actual pone `estado: aprobado` (auto-aprobación) y debe reemplazarse | Solicitudes por el Gateway y control positivo nuevo |
| rgB4 | B4 borrado | `aliado.t1` intenta borrar un documento del tenant 2. Verificar con `admin.t2` | Retirar su propio documento si está PENDIENTE (PA-08) | Carpeta 04 | Solicitudes por el Gateway |
| rgB5 | B5 tokens | Token con `tenant_id` reescrito, firma alterada, expirado y sin `Authorization`: 401, del Gateway o del Core según PA-16, y ninguna fila | Token válido de `aliado.t1`: 200 | Carpeta 05 (no cubre expirado ni ausencia total de token) | Variantes expirado y sin cabecera |
| rgB6 | B6 KYC en Storage | `aliado.t2`, `admin.t2`, `hook.t1`, `cliente.t1` y anónimo no descargan, firman, listan ni suben. URLs firmadas alteradas, reutilizadas o vencidas se rechazan | El dueño y su admin descargan, firman y listan | Carpeta 06 completa (N1 a N11, P1 a P3, C1 y complemento) | Acceso por `{{ruta_acceso_documento}}`; `cliente.t2` |

Controles adicionales del caso 6, para decidir el resultado esperado:
- C1 documenta que una URL firmada filtrada funciona hasta su TTL. El criterio exige que `{{ttl_url_firmada}}` no supere lo que fije CFG-23a.
- N11 verifica que la ruta con `aliado.id` se deniega. Si el Core construye la ruta con `aliado_id` (PA-04), esa ruta pasa de "negativo esperado" a "ruta oficial" y el caso se invierte. Hasta cerrar PA-04 no se ejecuta en el Gateway.

## 6. Paridad: lo que debe preservarse antes de retirar la lógica vieja

Aplica por la decisión del 5 de octubre registrada en el ADR-0022 (Propuesto). Lista de comportamientos que el reporte de M4 debe declarar cubiertos o no cubiertos.

| Comportamiento | Función o pieza actual | Línea base existente | Caso |
|---|---|---|---|
| Crear usuario en Supabase Auth con metadata | `signUp` y `handle_new_user` | Sí, según lectura | rgA1P, rgA1V2 |
| Crear aliado en estado PENDIENTE | `registrar_aliado_persona_natural` | No: no se invoca (F1) | rgA1P |
| Persistir documentos y filas de `documento_kyc` | RPC y Storage | No (F1) | rgA1P, rgA2N |
| Upsert a `usuario` con rol y tenant | `handle_new_user` | Sí, según lectura | rgA1P, rgA3P1 |
| Rechazo por documento faltante | Regla de RF-02 | No (F4) | rgA2N |
| Aislamiento de documentos KYC | Política `kyc_isolation` | Sí (carpeta 06) | rgB6 |

Un comportamiento sin línea base no puede declararse "preservado": se declara "construido y verificado".

## 7. Ejecución, criterio de aprobación y reporte

1. Orden: línea base primero, en QA, y luego el juego Gateway. Cada corrida corre los controles positivos antes que los negativos.
2. Aprobado: 100 % de los negativos rechazados con su control positivo exitoso, y 100 % de los casos funcionales conformes con su resultado esperado.
3. Cualquier diferencia se registra como defecto en Jira con el identificador del caso. El defecto bloqueante impide cerrar M4.
4. Control negativo ejecutable (meta): con el aislamiento del Core desactivado en un entorno de prueba, los negativos deberían fallar. Su ausencia se declara en el reporte.
5. Evidencia: informe de Newman y traza de Playwright, redactados con `qa/newman/redactar_evidencia.mjs`, versionados con el enlace a la corrida de CI.
6. El reporte QA (SCRUM-1188) lista cada caso con su resultado, los defectos, qué funciones PL/pgSQL cubre la regresión y la aprobación.

## 8. Qué se puede ejecutar hoy y qué no

| Caso | Hoy | Depende de |
|---|---|---|
| rgA1V2, rgA4N, rgA4V | Sí, en QA y camino directo | Acceso a QA y usuarios semilla |
| rgB1 a rgB6 (camino directo) | Sí, con la colección actual | Acceso a QA. Quitar la auto-aprobación del caso 3 (PA-10) |
| rgA1P a rgA3V2, rgA4P | No | CFG-16, CFG-20, M2, M3, CFG-22 y CFG-23 en QA |
| rgB1 a rgB6 (Gateway) | No | Los mismos, más `cliente.t2` |

## 9. Puntos abiertos que afectan a estos casos

| ID | Afecta a | Dueño |
|---|---|---|
| PA-01 | Todas las rutas y códigos | Juan Sebastián Álvarez |
| PA-02 | rgA1P: registro y documentos en una o dos peticiones | José Nicolás Álvarez y Juan Sebastián Álvarez |
| PA-03 | rgA2N: qué documento es obligatorio, y si la lista sale del Core o del servicio de reglas | Nicolás León y Juan Sebastián Álvarez |
| PA-04 | rgB6 y rgA1P: ruta de Storage | Autor de ADR-0013 y Mesa de Arquitectura |
| PA-05 | rgA1V1 y rgA3V1: ignorar o rechazar | Sara Albarracín y María Camila Beltrán |
| PA-06 | rgA1V2 | Santiago |
| PA-07 | rgA4P: excepción de Supabase Auth | Daniel Ávila |
| PA-08 | rgB3 y rgB4: control positivo | Nicolás León |
| PA-09 | rgB6: mecanismo y TTL | Juan Sebastián Álvarez |
| PA-16 | rgA3N2 y rgB5: el contrato dice que el 401 lo devuelve el Core; falta corregir el ADR-0018 | Daniel Ávila y Juan Sebastián Álvarez |
| PA-29 | rgB1, rgB2 y rgB6: el contrato no tiene consulta de estado ni carga posterior de documentos | Juan Sebastián Álvarez |
| PA-30 | rgA3P1 y rgA3V1: Flutter envía `X-Tenant-Id` y el contrato exige `X-Tenant-Slug` | José Nicolás Álvarez y Juan Sebastián Álvarez |
| PA-31 | rgA1P: comprobar que los nombres de los campos multipart de Flutter coinciden con el contrato | José Nicolás Álvarez y Juan Sebastián Álvarez |
| PA-11 | Sección 6: falta publicar el ADR-0022 que registra la decisión | María Camila Beltrán |

## 10. Trazabilidad con Jira

| Ticket | Uso de este documento |
|---|---|
| SCRUM-1185 (M4b) | Este documento es su entregable |
| SCRUM-1186 (M4c) | Ejecuta rgA1 a rgA4 con Newman y Playwright |
| SCRUM-1187 (M4d) | Ejecuta rgB1 a rgB6 y rgA4 |
| SCRUM-1188 (M4e) | Toma los resultados y los defectos |
| SCRUM-1105 (CFG-23c) | Comparte rgB1 a rgB6 |

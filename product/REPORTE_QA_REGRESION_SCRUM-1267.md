# Reporte QA de SCRUM-1267: regresión funcional, API, E2E y multi-tenant del Sprint 4 en QA

| Campo | Valor |
|---|---|
| Tarea | SCRUM-1267 (QA4-04), subtareas SCRUM-1277 (Newman), SCRUM-1278 (Playwright) y SCRUM-1279 (multi-tenant) |
| Responsable | Santiago Hernández (QA) |
| Fecha de ejecución | 20 de octubre de 2026 |
| Ambiente | QA `10.43.100.141`, rama `release`, base Supabase `MANI-QA` |
| Corridas finales (UTC) | Newman `20261020T212453Z`; Playwright `20261020T212519Z` |
| Matriz | [`MANI_Matriz_Ejecucion_Sprint4.xlsx`](MANI_Matriz_Ejecucion_Sprint4.xlsx) |
| Evidencia | [`qa/regresion_sprint4/evidencia/`](../qa/regresion_sprint4/evidencia/) |
| Suites | MANI-APIGateway, rama `qa/SCRUM-1267-regresion-sprint4` (`qa/`) |

## 1. Resumen

Se ejecutó en QA la regresión de las 27 historias priorizadas del Sprint 4: las 24 historias con subtarea "QA - Validar US" y las historias SCRUM-1063, SCRUM-1066 y SCRUM-1068 de la matriz de diseño SCRUM-1264. Ninguna historia se considera aprobada por su estado en Jira: el estado de cada una sale de la ejecución en QA.

| Estado QA | Historias | Cuáles |
|---|---|---|
| Aprobado | 3 | 1070, 1073, 1335 |
| Parcial | 10 | 850, 852, 854, 855, 858, 861, 862, 1063, 1072, 1074 |
| Fallido | 3 | 853, 856, 1066 |
| Bloqueado | 5 | 866, 874, 875, 1060, 1068 |
| No disponible | 6 | 865, 867, 868, 869, 870, 879 |

- **Newman:** 77 solicitudes y 91 aserciones, con 5 fallidas en 4 casos (853-04, 856-05, 1066-01 y 1066-02). Los cuatro corresponden a defectos de Desarrollo (sección 9).
- **Playwright:** 11 pruebas, 9 aprobadas y 2 fallidas (FW-02 y FW-03), que son la evidencia de D-04.
- **Recorrido E2E en QA:** crear solicitud (1072) → aliados elegibles (861/862) → despacho (1073) → aceptación (1074), con control cross-tenant. Aprobado en sus 5 pasos.
- **Multi-tenant:** los casos B1, B2, B3, B4 (855-04) y B5 se aprueban a través del Gateway; B6 queda parcial (sección 7).
- **Cobertura:** sobre las 17 historias con casos diseñados en SCRUM-1264 se ejecutaron 65 casos frente a 228 diseñados (29 %). "Aprobado" significa que lo ejecutado pasa; no equivale a la aceptación de la historia ni a la cobertura completa de sus casos diseñados.
- **Interfaz:** la web de QA arranca y llega a `/login` en 3,1 s, pero usa el Supabase del proyecto MANI y no el de MANI-QA (D-04). No se ejecutaron flujos de interfaz.
- **Defectos propuestos:** 8 abiertos (1 crítica, 5 altas, 2 medias) y 1 hallazgo retirado (sección 8).

## 2. Ambiente verificado y preparación

La promoción de `develop` a `release` se hizo el 20 de octubre a las 11:27 (Bogotá) en los seis repositorios: MANI-APIGateway#17, MANI-Node#48, MANI-Java#6, MANI-.NET#10, MANI-Flutter#50 y MANI-Landing#5. El árbol de `release` quedó idéntico al de `develop` en los seis.

QA no se actualizó con la promoción (D-08). Para dejarlo en el código de `release` se hizo lo siguiente, con respaldo previo de los archivos modificados en `/opt/mani`:

1. Se bajaron las imágenes `:staging` y se recrearon los seis contenedores.
2. En el compose se cambió `NODE_ENV: staging` por `qa`, porque Core en `release` solo acepta `development`, `qa`, `production` o `test`. A Dispatch se le agregaron `SUPABASE_JWT_SECRET`, la cadena de conexión y `CORE_SERVICE_URL`, que el código nuevo exige. `SUPABASE_URL` perdió su valor por defecto hacia `mock.supabase.co`.
3. `.env.qa` tenía credenciales de relleno y `SUPABASE_URL` apuntaba a `mock.supabase.co`. Se cargaron las credenciales de MANI-QA y se verificaron sin imprimirlas: la referencia de las llaves, la firma de la llave anon con el JWT secret y la autenticación real contra la base. La conexión usa el Session pooler, porque la conexión directa solo tiene IPv6 y la VM no tiene salida IPv6.
4. Se aplicaron en MANI-QA las migraciones de Core 0001 a 0010 y 0013 de MANI-Node `release` 2745bb0, desde el SQL Editor (antes solo estaban las 001 a 008 del Gateway). Las numeradas 0011 y 0012 no existen en `release`: pertenecen a ramas sin fusionar de SCRUM-865 y SCRUM-869.

**Verificación posterior (21:06 UTC):** seis contenedores con las revisiones de la tabla, sin reinicios; salud en 200 en los cuatro endpoints, también por la IP externa de la VM; el compose difiere del respaldo original en tres cambios (los del punto 2); `.env.qa` con permisos 600, sin variables duplicadas y sin referencias a mock.

| Contenedor | Revisión |
|---|---|
| mani-api-gateway | 82473d6 |
| mani-core-service | 2745bb0 |
| mani-rules-service | e90f32b |
| mani-dispatch-service | 41ba171 |
| mani-flutter-web | 74bab53 |
| mani-landing-web | a82b94e |

Core y Dispatch se conectan a la base como `postgres`, que ignora RLS (D-09).

## 3. Cómo se ejecutó

- **Datos:** tenants de prueba de MANI-QA `acme-servicios` (t1) y `nova-mantenimiento` (t2) para la regresión y el aislamiento, y `poc-concurrencia` para la doble aceptación. Cada corrida crea datos marcados con `QA <corrida>`.
- **Autenticación de prueba:** tokens HS256 firmados dentro de la VM con el JWT secret legado de MANI-QA, con los claims `sub`, `app_metadata.tenant_id` y `app_metadata.user_role`. Los tokens no salen de la VM. No se usó `/auth/dev-token`, que en QA responde 404 (caso PER-05). Esto limita lo que los resultados prueban (L-01).
- **Newman:** colección generada por `qa/newman/generar_coleccion.js` (77 casos en 18 carpetas), ejecutada en contenedor dentro de la VM contra el Gateway (`localhost:80`).
- **Playwright:** imagen oficial `mcr.microsoft.com/playwright:v1.48.2-jammy` en la VM, con trace, capturas y reporte HTML. Los traces se conservan en la VM porque contienen tokens de prueba ya vencidos.
- **Evidencia versionada:** Newman exporta las respuestas como arreglos de bytes. El ejecutor los decodifica, enmascara contraseñas temporales y tokens, y verifica que no quede ninguna credencial antes de guardar. La evidencia versionada se revisó además con una herramienta independiente que decodifica esos arreglos.
- **Verificación del motor:** `db/verify/0005` y `db/verify/0007` de Core con `psql`, en transacciones revertidas (sección 7).
- **Diagnóstico de Flutter Web:** carga de la aplicación en un navegador sin pantalla dentro de la VM, con eventos y cronología (`flutter_web_diagnostico_fw01.txt` y `flutter_login_qa.png`).

## 4. Criterios de estado y cobertura

| Estado | Criterio |
|---|---|
| Aprobado | Todos los casos ejecutados pasan, no hay bloqueos y menos de la mitad de los casos diseñados de la historia involucra la interfaz de Flutter. No equivale a la aceptación de la PO ni a la cobertura completa de los casos diseñados (ver cobertura). |
| Parcial | Los casos ejecutados pasan, pero la mitad o más de los casos diseñados involucra la interfaz de Flutter (no ejecutada) o solo se ejecutó una parte del alcance. |
| Fallido | Al menos un caso ejecutado falla por un defecto del sistema. |
| Bloqueado | Una dependencia impide ejecutar la historia (estado blocked sin PR, o historia solo de interfaz sin acceso por la interfaz). |
| No disponible | La historia no tiene código fusionado. |
| Origen probable | Desarrollo, DevOps, Prueba de QA o Por determinar. Indica dónde se espera que se corrija; no es un juicio sobre las personas. |
| Confianza | Alta: confirmado en el código y en el ambiente. Media: confirmado solo en un lado o con otra explicación posible. Baja: inferencia. |

La cobertura de cada historia compara los casos ejecutados de la colección con los casos diseñados en SCRUM-1264. Los IDs de ambos no coinciden: la trazabilidad uno a uno queda pendiente (L-03). Las historias 1070 y 1073 figuran como Aprobado con una cobertura baja (3 de 16 y 4 de 14 casos diseñados).

## 5. Resultado por historia

| Historia | Nombre | Subtarea QA | Ejecutados (OK/total) | Diseñados | Estado QA | Origen probable (confianza) | Observación |
|---|---|---|---|---|---|---|---|
| SCRUM-850 | US-02.1.5 - Registrar empleado directo | SCRUM-1306 | 4/4 | 12 | Parcial | DevOps, con Desarrollo de Flutter (Alta) | API aprobada. Pantalla no ejecutada: el login de la web de QA usa el Supabase del proyecto MANI (D-04). |
| SCRUM-852 | US-02.2.2 - Cliente empresa con múltiples sitios | SCRUM-1307 | 6/6 | 10 | Parcial | DevOps, con Desarrollo de Flutter (Alta) | API aprobada con un cliente empresa creado en la corrida. Pantalla no ejecutada (D-04). |
| SCRUM-853 | US-02.2.3 - Reglas contextuales del sitio visibles al aliado | SCRUM-1308 | 3/4 | 10 | Fallido | Desarrollo (Alta) | El aliado con el servicio asignado no puede leer las reglas del sitio (D-02); los demás casos pasan, incluido el negativo con un aliado sin asignación. |
| SCRUM-854 | US-02.3.1 - Editar perfil propio | SCRUM-1309 | 3/3 | 11 | Parcial | DevOps, con Desarrollo de Flutter (Alta) | API aprobada. Pantalla no ejecutada (D-04). |
| SCRUM-855 | US-02.1.6 - Aliado gestiona su disponibilidad | SCRUM-1310 | 6/6 | 11 | Parcial | DevOps, con Desarrollo de Flutter (Alta) | API aprobada, incluido el aislamiento entre aliados (caso B4 real). Pantalla no ejecutada (D-04). |
| SCRUM-856 | US-02.3.2 - Aceptación de Términos y Condiciones | SCRUM-1311 | 4/5 | 11 | Fallido | Desarrollo (Alta) | Documentos legales inaccesibles antes del registro (D-01); el consentimiento con sesión se aprueba. |
| SCRUM-858 | US-03.1.2 - Desactivar categoría sin afectar en curso | SCRUM-1312 | 8/8 | 11 | Parcial | DevOps, con Desarrollo de Flutter (Alta) | API aprobada, incluida la vitrina pública (SCRUM-1069): crear, desactivar sin aparecer en la vitrina, reactivar y aislamiento. Pantalla no ejecutada (D-04). |
| SCRUM-861 | US-04.1.2 - Ver aliados válidos por cobertura y categoría | SCRUM-1313 | 3/3 | 11 | Parcial | DevOps, con Desarrollo de Flutter (Alta) | API aprobada (Newman y E2E-02). La mayoría de los casos diseñados involucra la interfaz de Flutter, no ejecutada (D-04). |
| SCRUM-862 | US-04.1.3 - Filtrar por tipo de aliado | SCRUM-1314 | 2/2 | 11 | Parcial | DevOps, con Desarrollo de Flutter (Alta) | API aprobada (Newman y E2E-02). La mayoría de los casos diseñados involucra la interfaz de Flutter, no ejecutada (D-04). |
| SCRUM-865 | US-04.2.1 - Cotización con mano de obra y materiales separados | SCRUM-1315 | - | - | No disponible | Desarrollo (Alta) | Sin código fusionado (MANI-Node#32 cerrado sin fusionar). Sin casos diseñados en SCRUM-1264. |
| SCRUM-866 | US-04.2.2 - Alerta de tarifa bidireccional | SCRUM-1316 | - | - | Bloqueado | Desarrollo (Alta) | Historia en estado blocked en Jira, sin PR. |
| SCRUM-867 | US-04.2.3 - Cliente acepta/rechaza/ajusta cotización | SCRUM-1317 | - | - | No disponible | Desarrollo (Alta) | Sin código fusionado (MANI-Node#33 cerrado sin fusionar). Sin casos diseñados en SCRUM-1264. |
| SCRUM-868 | US-04.3.1 - Marcar inicio/fin de ejecución | SCRUM-1318 | - | - | No disponible | Desarrollo (Alta) | Sin código fusionado (MANI-Node#34 cerrado sin fusionar). Sin casos diseñados en SCRUM-1264. |
| SCRUM-869 | US-04.3.2 - Registrar eventos durante la ejecución | SCRUM-1319 | - | - | No disponible | Desarrollo (Alta) | Sin código fusionado (MANI-Node#35 cerrado sin fusionar). Sin casos diseñados en SCRUM-1264. |
| SCRUM-870 | US-04.3.3 - Cliente consulta el log del servicio | SCRUM-1320 | - | - | No disponible | Desarrollo (Alta) | Sin código fusionado (MANI-Node#36 cerrado sin fusionar). Sin casos diseñados en SCRUM-1264. |
| SCRUM-874 | US-04.4.1 - Cliente califica al aliado | SCRUM-1321 | - | - | Bloqueado | Desarrollo (Alta) | Historia en estado blocked en Jira, sin PR. |
| SCRUM-875 | US-04.4.2 - Aliado califica al cliente | SCRUM-1326 | - | - | Bloqueado | Desarrollo (Alta) | Historia en estado blocked en Jira, sin PR. |
| SCRUM-879 | US-04.6.1 - Consultar historial de servicios | SCRUM-1327 | - | - | No disponible | Desarrollo (Alta) | Sin código fusionado (MANI-Node#37 cerrado sin fusionar). Sin casos diseñados en SCRUM-1264. |
| SCRUM-1060 | US-02.1.2-M3 - Migracion: reescribir el datasource de registr… | SCRUM-1328 | - | 22 | Bloqueado | DevOps, con Desarrollo de Flutter (Alta) | Historia solo de interfaz. La web de QA arranca y llega a /login, pero usa el Supabase del proyecto MANI y no el de MANI-QA (D-04): se infiere que los usuarios de prueba de MANI-QA no pueden iniciar sesión; no se intentó. |
| SCRUM-1070 | US-03.1.1-M6 - Migracion: llevar las reglas evaluables de la … | SCRUM-1329 | 3/3 | 16 | Aprobado | - | Rules rechaza nombre y flujo inválidos a través de Core; el aliado no evalúa CREATE. |
| SCRUM-1072 | US-04.1.1-M2 - Migracion: creacion de solicitud en Core Node,… | SCRUM-1330 | 6/6 | 15 | Parcial | DevOps, con Desarrollo de Flutter (Alta) | API aprobada y E2E-01. Pantalla no ejecutada (D-04). |
| SCRUM-1073 | US-04.1.1-M6 - Migracion: orquestacion de despacho de la soli… | SCRUM-1331 | 4/4 | 14 | Aprobado | - | Orquestación y rutas internas cerradas (Newman y E2E-03). Publicación de eventos no ejecutable: QA no tiene Kafka. |
| SCRUM-1074 | US-04.1.4-M6 - Migracion: aceptar o rechazar solicitud sin do… | SCRUM-1332 | 7/7 | 14 | Parcial | DevOps, con Desarrollo de Flutter (Alta) | Aceptación y reaceptación idempotente (E2E-04), 409 al segundo aliado sobre una solicitud ya asignada (1074-06) y 404 al aliado de otro tenant. No se ejecutó la concurrencia. La mayoría de los casos diseñados involucra la interfaz (D-04). |
| SCRUM-1335 | US-09.1.1 - Landing page comercial como entrada publica a la … | SCRUM-1356 | 3/3 | - | Aprobado | - | Tarifas, estimador con aviso y botón de ingreso a Flutter Web (Playwright). La historia no tiene casos diseñados en SCRUM-1264. |
| SCRUM-1063 | US-02.1.2-M2 - Migracion: implementar el registro de aliado e… | sin subtarea QA | 1/1 | 18 | Parcial | Prueba de QA (Alta) | Solo se ejecutó el caso negativo (sin documentos responde 400); el registro con documentos no se ejecutó. |
| SCRUM-1066 | US-02.1.3-M2 - Migracion: aprobacion y rechazo de registro de… | sin subtarea QA | 1/3 | 20 | Fallido | Desarrollo (Alta) | Listado y detalle de verificación responden 500: falta documento_kyc.created_at (D-03). |
| SCRUM-1068 | US-02.1.4-M2 - Migracion: declaracion de zona de cobertura so… | sin subtarea QA | - | 11 | Bloqueado | Desarrollo (Alta) | Historia en estado blocked en Jira, sin PR identificado. |

Cada fila corresponde a la subtarea "QA - Validar US" indicada y es su evidencia. El detalle caso por caso está en la hoja `ejecucion_casos` de la matriz, y el origen probable de cada fallo en `defectos_propuestos`.

## 6. Recorrido E2E en QA

Prueba `qa/playwright/tests/e2e_solicitud.spec.js`, corrida `20261020T212519Z`.

| Paso | Historia | API (a través del Gateway) | Resultado |
|---|---|---|---|
| E2E-01 | SCRUM-1072 | `POST /api/v1/core/solicitudes` (cliente t1, sitio t1) | 201, solicitud en estado PENDIENTE |
| E2E-02 | SCRUM-861/862 | `GET /api/v1/dispatch/requests/{id}/eligible-allies?tipo=PERSONA_NATURAL` | 200, incluye al aliado t1 y no al de t2 |
| E2E-03 | SCRUM-1073 | `POST /api/v1/dispatch/requests/orchestrate` | 200, oferta transmitida a 1 aliado elegible |
| E2E-04 | SCRUM-1074 | `POST /api/v1/dispatch/requests/{id}/accept` dos veces (aliado t1) | 200 y 200 (reintento idempotente, mismo aliado) |
| E2E-05 | Cross-tenant | Aceptación por el aliado t2 | 404 |

El inicio del recorrido desde la interfaz Flutter no se ejecutó (D-04); los cinco pasos se ejecutaron por API dentro de la misma prueba de Playwright.

Newman complementa el paso de aceptación: 1074-06 devuelve 409 al segundo aliado sobre una solicitud ya asignada. En esta corrida esa solicitud (la de PoC) ya estaba asignada por corridas anteriores, por lo que 1074-05 fue un reintento idempotente y no una primera aceptación. La concurrencia de dos aceptaciones simultáneas sobre el Dispatch real no se ejecutó (L-07).

## 7. Regresión multi-tenant (SCRUM-1279)

| Caso | Qué se prueba | Casos de la colección | Resultado |
|---|---|---|---|
| B1 | Lectura de un recurso de otro tenant (sedes de un cliente de t2) | B1-01 | 404, aprobado |
| B2 | Listado sin recursos ajenos (categorías) | B2-01 | 200 sin ids de t2, aprobado |
| B3 | Escritura en otro tenant (reglas de un sitio de t2) | B3-01 | 404, aprobado |
| B4 | Borrado de un recurso ajeno (ausencia de otro aliado) | 855-04 (B4-01 es un control con un id inexistente) | 404, aprobado |
| B5 | Token expirado, firma alterada, sin `tenant_id` y `X-Tenant-Id` falso | B5-01 a B5-04 | 401, 401, 401 y sin efecto; aprobado |
| B6 | KYC de un aliado de otro tenant | B6-01 | 404 sobre el detalle de verificación; parcial (L-05) |

Además, cada historia incluye su caso de tenant cruzado, todos aprobados: 850-04 (categoría de otro tenant, 400), 852-05 (404), 853-03 (404), 856-03 (404), 858-07 (404), 862-01 (200 sin aliados de t2), 1072-05 (422), 1074-03 (404) y E2E-05 (404).

**Verificación en el motor (`db/verify` de Core):**
- `0005_verificar_exposiciones` falla porque supone que existe la función `registrar_aliado_persona_natural`. En MANI-QA no existe, así que no hay exposición; es una observación sobre el script.
- `0007_verificar_modelo_identidad_rls` se detiene en el invariante "tablas con `tenant_id` sin FORCE RLS: poc_asignacion_log" (D-07), por lo que los seis casos del motor no llegaron a ejecutarse.
- En MANI-QA quedan 18 políticas heredadas `tenant_isolation_*` con `TO public` (D-06), y Core y Dispatch usan `postgres`, que ignora RLS (D-09).

El aislamiento comprobado es el de la aplicación a través del Gateway. La defensa en la base de datos (RLS) no se ejerce en QA y queda pendiente de D-06, D-07 y D-09.

## 8. Defectos propuestos

Los defectos se proponen aquí; su registro en el backlog lo decide la Scrum Master. La numeración D-xx es propia de este reporte y no coincide con la de SCRUM-1266.

| Id | Severidad | Historia | Descripción | Origen probable (confianza) | Fundamento |
|---|---|---|---|---|---|
| D-04 | Crítica | Todas las historias con interfaz | La imagen mani-flutter:staging se construye con .env.example: SUPABASE_URL apunta al proyecto MANI (el que el equipo designó como producción el 19 de octubre) y API_GATEWAY_URL=localhost. La pantalla de login de QA lista empresas de ese proyecto (por ejemplo "Plomería Express CDMX SA"), que no son tenants de MANI-QA. Se infiere que los usuarios de prueba de MANI-QA no pueden iniciar sesión por la interfaz; no se intentó. | DevOps, con Desarrollo de Flutter (Alta) | El Dockerfile de Flutter indica que el .env se inyecta en CI, pero docker-publish.yml copia .env.example; el panel de Supabase identifica tjxueukivwxsgipltqwb como el proyecto MANI. |
| D-01 | Alta | SCRUM-856 | El Gateway exige token en GET /api/v1/core/legal/documents/active. Core declara la ruta como consulta pública previa al inicio de sesión y Flutter la consulta con X-Tenant-Slug antes del registro. Resultado: 401; el formulario de registro no puede mostrar los términos. | Desarrollo (Alta) | legal.routes.js (comentario "Consulta pública / pre-login"); nginx.conf no define la ruta; core.yaml no define /legal/*. |
| D-02 | Alta | SCRUM-853 | GET /sites/:id/rules (GetSiteRulesForAllyUseCase) solo permite al cliente dueño o al admin del tenant; no tiene rama para el aliado asignado. El criterio de la historia exige mostrar al aliado las reglas del sitio asociado a su servicio. Con el aliado asignado (caso 853-04) la respuesta es 403. | Desarrollo (Alta) | La prueba de desarrollo (sites.routes.test.js) documenta que ningún aliado lee las reglas hasta integrar la asignación; MANI-.NET#1 y MANI-Node#43 ya están fusionados y el caso de uso no tiene rama para el aliado. |
| D-03 | Alta | SCRUM-1066 | El listado y el detalle de verificación de aliados responden 500: SupabaseDocumentoKycRepository selecciona documento_kyc.created_at; la tabla (esquema versionado y MANI-QA) tiene fecha_carga. | Desarrollo (Alta) | SupabaseDocumentoKycRepository.js línea 44; database/init/01-schema.sql; consulta a las columnas de MANI-QA el 20 de octubre. |
| D-08 | Alta | Todas | La promoción a release no dejaba QA operativo: compose con NODE_ENV=staging (Core no arranca), Dispatch sin JWT, base ni CORE_SERVICE_URL, .env.qa con credenciales de relleno y migraciones de Core sin aplicar. Se corrigió a mano el 20 de octubre; el compose y deploy-qa.sh solo existen en la VM. | DevOps, con Desarrollo (migraciones sin mecanismo de aplicación) (Alta) | db/README.md de Core asigna a Operaciones aplicar las migraciones; no hay compose de QA en ningún repositorio. |
| D-09 | Alta | SCRUM-1279 | Core y Dispatch se conectan a la base como postgres (con BYPASSRLS). Los roles de servicio mani_core_svc y mani_dispatch_svc existen sin LOGIN, por lo que las políticas RLS de la migración 0007 no se ejercen en QA: el aislamiento comprobado es el de la aplicación, no el de la base. | DevOps (Alta) | db/README.md de Core: Operaciones asigna LOGIN y contraseña a los roles de servicio fuera de git (ADR-0032). |
| D-06 | Media | SCRUM-1279 | 18 políticas heredadas tenant_isolation_* con TO public conviven con las políticas de la migración 0007. | Desarrollo (Media) | La migración 0007 reemplaza políticas por nombre y no retira estas; también pueden venir de migraciones anteriores del Gateway o de una aplicación manual. |
| D-07 | Media | SCRUM-1279 | La tabla de PoC poc_asignacion_log (con tenant_id y RLS sin FORCE) sigue en MANI-QA; db/verify/0007 se detiene en ese invariante y no ejecuta los seis casos dentro del motor. | DevOps (Media) | supabase/poc-cfg09 del Gateway es el origen de la tabla de PoC; no pertenece al esquema de Core. |

**Correcciones sugeridas**

- **D-04:** Inyectar el .env de QA (Supabase de MANI-QA y URL del Gateway de QA) al construir la imagen :staging.
- **D-01:** Agregar la ruta pública en nginx.conf (solo GET, sin Authorization, con X-Tenant-Slug), como /api/v1/core/catalog, y documentarla en core.yaml.
- **D-02:** Habilitar la lectura al aliado asignado a una solicitud del sitio, sin exponer otros clientes.
- **D-03:** Seleccionar fecha_carga o agregar la columna con una migración de Core.
- **D-08:** Versionar el compose y el despliegue de QA y aplicar las migraciones en el pipeline.
- **D-09:** Asignar LOGIN y credenciales a los roles de servicio, usarlos en Core y Dispatch y repetir la regresión multi-tenant.
- **D-06:** Retirar las políticas heredadas con una migración de Core y repetir db/verify/0007.
- **D-07:** Retirar la tabla de PoC de QA o forzar RLS.

**Hallazgo retirado (D-05).** Se había propuesto que Flutter Web no arranca en QA. Era un error de la prueba: la configuración de Playwright agregaba el encabezado X-Correlation-ID a todas las peticiones del navegador y el CDN de Google rechazaba el preflight CORS (CanvasKit y fuentes). Sin el encabezado la aplicación arranca en 3,1 s y llega a /login. Evidencia: errores CORS en la consola del trace anterior; diagnóstico en vivo en la VM sin el encabezado; FW-01 aprobado en la corrida final.

## 9. Origen de los resultados

| Origen probable | Defectos | Comentario |
|---|---|---|
| Desarrollo | D-01, D-02, D-03 (confianza alta); D-06 (media) | Los cuatro casos fallidos de Newman (853-04, 856-05, 1066-01 y 1066-02) corresponden a D-01, D-02 y D-03. Se confirmaron en el código y en el ambiente; ninguno se explica por la escritura de la prueba |
| DevOps | D-04, D-08, D-09 (alta); D-07 (media) | Pipeline de Flutter, despliegue de QA, roles de servicio de la base y restos de PoC. D-04 y D-08 con apoyo de Desarrollo |
| Prueba de QA | D-05 (retirado) y los límites L-01, L-02, L-03, L-05, L-06, L-07, L-08 | El único falso positivo (FW-01) se corrigió. Los fallos de la primera corrida del día se debían al ambiente (D-08) y a tres errores de la propia colección, ya corregidos. Los límites no producen fallos, pero acotan lo que los resultados prueban |

## 10. Discrepancias con Jira

- Las subtareas "QA - Validar US" de 850, 852, 853, 854, 855, 856, 858, 861, 862, 1060, 1070, 1072, 1073, 1074 y 1335 están en Finalizada. Su cierre se basó en el merge a `develop` y el CI en verde, no en una ejecución en QA. Este reporte deja su resultado real en QA: de esas 15 historias, 3 quedan en Aprobado, 9 en Parcial, 2 en Fallido (853 y 856) y 1 en Bloqueado (1060).
- SCRUM-1063, 1066 y 1068 están en la matriz de diseño SCRUM-1264 pero no tienen subtarea QA.
- SCRUM-865, 867, 868, 869, 870, 879 y 1335 tienen subtarea QA pero no tienen casos diseñados en SCRUM-1264.
- Este reporte no modifica Jira.

## 11. Relación con SCRUM-1266

La regresión usó los mismos datos de prueba y la misma fuente de tokens que SCRUM-1266, y deja:
- **QAS-01:** casos B1 a B6 a través del Gateway (sección 7).
- **QAS-07:** la doble aceptación sobre el Dispatch real queda parcialmente cubierta (sección 6). La solicitud de PoC que el arnés de QAS-07 necesita en estado PENDIENTE quedó asignada (L-07); restablecerla con `supabase/poc-cfg09/11_reset_solicitud.sql` del Gateway es una decisión pendiente.
- El defecto de `/auth/dev-token` público propuesto en SCRUM-1266 ya no se reproduce en QA: PER-05 responde 404.

## 12. Reproducibilidad

```bash
node qa/newman/generar_coleccion.js
COLECCION=qa/newman/mani_regresion_sprint4.postman_collection.json bash qa/ejecutar_newman_qa.sh
SUITE_DIR=qa/playwright bash qa/ejecutar_playwright_qa.sh
```

Se ejecutan en la VM de QA desde una copia de MANI-APIGateway. La corrida final usó la colección y la suite empaquetadas, idénticas a las versionadas (comparación byte a byte). No se ejercieron las variantes `COLECCION` y `SUITE_DIR` ni el workflow `.github/workflows/qa-regresion.yml`, que corre Newman desde el runner `nbig02-calidad` y necesita el secreto `QA_JWT_SECRET` (L-08).

## 13. Límites y supuestos

| Id | Tema | Descripción | Origen |
|---|---|---|---|
| L-01 | Autenticación | Toda la regresión usó tokens HS256 firmados dentro de la VM con el JWT secret legado de MANI-QA. No se probó el flujo con un token emitido por Supabase Auth. Según el panel de JWT Keys de MANI-QA (verificado el 20 de octubre), la llave de firma vigente es ECC P-256 (ES256) y HS256 figura como llave anterior; validate-token de Core, que usa el Gateway, acepta solo HS256, por lo que un inicio de sesión real podría recibir 401. Sin verificar. | Prueba de QA |
| L-02 | Punto de ejecución | Newman y Playwright se ejecutaron dentro de la VM de QA (localhost). El puerto 80 de QA desde el equipo del QA por la VPN responde reset, mientras la VM responde 200 por su propia IP; la causa está fuera del host y no se probó desde la VM de Calidad. | Prueba de QA |
| L-03 | Cobertura | Los casos ejecutados son los de la colección de regresión y no los IDs de SCRUM-1264. Sobre las 17 historias con casos diseñados: 65 casos ejecutados frente a 228 diseñados. La trazabilidad uno a uno con los IDs diseñados queda pendiente. | Prueba de QA |
| L-04 | Interfaz | No se ejecutaron flujos de interfaz. La web de QA arranca y llega a /login, pero usa el Supabase del proyecto MANI (D-04), por lo que se infiere que los usuarios de MANI-QA no pueden iniciar sesión; no se intentó. | DevOps |
| L-05 | Casos B4 y B6 | B4-01 borra una ausencia inexistente y solo es un control; el aislamiento de borrado se prueba en 855-04. B6 se ejecutó sobre el detalle de verificación de otro tenant (404); el camino de los documentos KYC falla antes por D-03 y no se probó el aislamiento de las URL firmadas. | Prueba de QA |
| L-06 | Expectativas ajustadas | Tras la primera corrida se ajustaron expectativas: la reaceptación del mismo aliado pasó de 409 a 200 (1074-02 y E2E-04) porque Dispatch documenta el reintento idempotente en su respuesta; 856-01 y 856-02 usan una sesión; 1070-03 corrige la forma del cuerpo; 852 crea primero un cliente empresa; 853-02 se redefinió como negativo con un aliado sin asignación y se agregó 853-04 con el aliado asignado. | Prueba de QA |
| L-07 | Datos de prueba y concurrencia | Cada corrida crea datos en MANI-QA (empleado, cliente empresa, sedes, categoría, consentimiento y solicitud). La solicitud de PoC que SCRUM-1266 necesita en estado PENDIENTE quedó ASIGNADA; en la corrida final 1074-05 fue un reintento idempotente. La concurrencia de dos aceptaciones simultáneas sobre el Dispatch real no se ejecutó. Para restablecer la solicitud existe supabase/poc-cfg09/11_reset_solicitud.sql del Gateway. | Prueba de QA |
| L-08 | Gate de CI | El workflow qa-regresion.yml no se ejecutó: necesita el secreto QA_JWT_SECRET en MANI-APIGateway y no se probó en el runner de Calidad. Tampoco se ejecutaron las variantes COLECCION y SUITE_DIR de los ejecutores (la corrida usó la colección y la suite empaquetadas). | Prueba de QA |
| L-09 | Aislamiento en el motor | db/verify/0007 se detiene en el invariante de poc_asignacion_log (D-07) y no ejecutó los seis casos dentro del motor. db/verify/0005 supone que existe registrar_aliado_persona_natural; en MANI-QA no existe, así que no hay exposición, pero el script falla. Además Core y Dispatch usan postgres (D-09). | Desarrollo y DevOps |

## 14. Pendientes

1. Probar el flujo con un token emitido por Supabase Auth (ES256), con un usuario de prueba de contraseña conocida.
2. Ejecutar flujos de interfaz cuando D-04 esté corregido.
3. Mapear los casos ejecutados a los IDs de SCRUM-1264 y ampliar la cobertura.
4. Restablecer la solicitud de PoC y ejecutar la concurrencia de QAS-07 sobre el Dispatch real (requiere autorización).
5. Retirar de la VM de QA los respaldos de `.env.qa` y los datos y traces de las corridas, y los datos de prueba de MANI-QA (requiere autorización).
6. Ejecutar el workflow `qa-regresion.yml` en el runner de Calidad con el secreto `QA_JWT_SECRET`.
7. Probar el puerto 80 de QA desde la VM de Calidad.
8. Corregir D-01 a D-09 por sus responsables y repetir la regresión.

## 15. Cumplimiento del DoD de SCRUM-1267

| Criterio | Estado |
|---|---|
| Matriz de ejecución con el 100 % de las historias priorizadas, con estado y evidencia o bloqueo | Cumplido: 27 de 27 (sección 5 y matriz), con criterios de estado y cobertura declarados |
| Al menos un recorrido E2E en QA con sus APIs y datos | Cumplido por API (sección 6); el inicio desde la interfaz queda sin ejecutar por D-04 |
| Informe de defectos priorizados | Cumplido como propuesta (sección 8): 8 abiertos |
| Resultados presentados a Camila (PO) | Pendiente |
| SCRUM-1277: colección versionada, workflow de CI, casos ejecutados, resultado y evidencia por historia, gate comprobable | Colección, ejecutor y workflow en la rama del Gateway; casos ejecutados con evidencia por historia. El gate no se ha comprobado: el workflow requiere el secreto `QA_JWT_SECRET` (L-08) |
| SCRUM-1278: suite reproducible, ejecución de CI contra QA, evidencias por historia, registro de errores | Suite reproducible y ejecutada dentro de la VM con trace, capturas y reporte. La ejecución desde CI queda pendiente (L-08) |
| SCRUM-1279: matriz aprobado, fallido, bloqueado o no ejecutable y validación de la PO | Matriz lista; validación de la PO pendiente |

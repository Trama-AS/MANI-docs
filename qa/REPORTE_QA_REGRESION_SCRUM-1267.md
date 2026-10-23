# Reporte QA de SCRUM-1267: regresión funcional, API, E2E y multi-tenant del Sprint 4 en QA

| Campo | Valor |
|---|---|
| Tarea | SCRUM-1267 (QA4-04), subtareas SCRUM-1277 (Newman), SCRUM-1278 (Playwright) y SCRUM-1279 (multi-tenant) |
| Responsable | Santiago Hernández (QA) |
| Fecha de ejecución | 20 de octubre de 2026 (regresión) y 21 de octubre de 2026 (validación de las correcciones) |
| Ambiente | QA `10.43.100.141`, rama `release`, base Supabase `MANI-QA` |
| Corridas (UTC) | Vigentes, tras las correcciones del 21 de octubre: Newman `20261021T161015Z` y Playwright `20261021T170129Z`. Del 20 de octubre, con la colección corregida: Newman `20261020T224842Z` y Playwright `20261020T224932Z`. Anteriores: Newman `20261020T212453Z` y Playwright `20261020T212519Z`. Consultas de solo lectura sobre MANI-QA: `20261020T225146Z`. Gate de CI desde el runner de Calidad ([run 39513870492](https://github.com/Trama-AS/MANI-APIGateway/actions/runs/39513870492)): Newman `20261020T234635Z` y Playwright `20261020T235520Z` |
| Revisión | 20 de octubre de 2026: estados, cobertura y defectos revisados contra el DoD de QA (`backlog/CRITERIOS_ACEPTACION_SPRINT4.md` §4), los criterios de SCRUM-1257, la matriz SCRUM-1264, ADR-0005 y el reporte de SCRUM-1266. Actualizado con la corrida de la colección corregida y la evidencia de R-06, R-07 y R-09, y el 21 de octubre con la validación de las correcciones de R-01 a R-04 y R-10 (sección 16) |
| Matriz | [`MANI_Matriz_Ejecucion_Sprint4.xlsx`](MANI_Matriz_Ejecucion_Sprint4.xlsx) |
| Evidencia | [`qa/regresion_sprint4/evidencia/`](../qa/regresion_sprint4/evidencia/); la del 21 de octubre en [`20261021_validacion/`](../qa/regresion_sprint4/evidencia/20261021_validacion/) |
| Suites | MANI-APIGateway `qa/`, fusionadas en `develop` (#18, `9f67ab1`) y promovidas a `release` (#19, `3c070db`) el 20 de octubre |

## 1. Resumen

Se ejecutó en QA la regresión de las 27 historias priorizadas del Sprint 4: las 24 historias con subtarea "QA - Validar US" y las historias SCRUM-1063, SCRUM-1066 y SCRUM-1068 de la matriz de diseño SCRUM-1264. Ninguna historia se considera aprobada por su estado en Jira: el estado de cada una sale de la ejecución en QA.

| Estado QA | Historias | Cuáles |
|---|---|---|
| Aprobado | 0 | - |
| Ejecutado | 16 | 850, 852, 853, 854, 855, 856, 858, 861, 862, 1063, 1066, 1070, 1072, 1073, 1074, 1335 |
| Fallido | 0 | - |
| Bloqueado | 4 | 866, 874, 875, 1068 |
| Sin ejecutar | 1 | 1060 |
| No disponible | 6 | 865, 867, 868, 869, 870, 879 |

Estado al 21 de octubre. El 20 de octubre 853, 856 y 1066 estaban en Fallido (R-02, R-01 y R-03) y 1060 en Bloqueado (R-04 y R-10); los cuatro defectos se corrigieron o mitigaron y la regresión del 21 de octubre en QA no tiene fallas (sección 16). Ninguna historia queda en Aprobado: "Ejecutado" significa que los casos ejecutados no fallan por un defecto del sistema, pero la evidencia no alcanza para aprobar, porque la cobertura de los casos diseñados en SCRUM-1264 o de los criterios de aceptación es incompleta y la regresión usa tokens de prueba sintéticos. "Sin ejecutar" (1060) indica que ya no hay bloqueo externo y QA no ha ejecutado sus casos; no es un estado del vocabulario de SCRUM-1267 y se declara para no ocultar la brecha.

- **Cobertura de SCRUM-1264 (DoD de QA):** de 228 casos diseñados, 20 quedan cubiertos de forma completa y 22 de forma parcial por casos válidos de la regresión. De los 200 casos de prioridad Alta, 13 completos y 19 parciales. ADR-0005 exige una cobertura de casos críticos de al menos 90 %: el umbral no se cumple. La trazabilidad caso a caso está en la hoja `cobertura_1264` de la matriz.
- **Multi-tenant (SCRUM-1279):** de los 90 casos cross-tenant aplicables de SCRUM-1264 (X1 a X6 de 17 historias), 10 se ejecutaron y se aprobaron (2 de ellos de forma parcial), 5 están bloqueados (SCRUM-1068) y 75 no se ejecutaron. Todos los accesos cruzados ejecutados se rechazaron.
- **Identidad:** la regresión usa tokens HS256 sintéticos. Hasta el 20 de octubre un usuario real no podía usar las rutas protegidas porque recibe un token ES256 que el Gateway rechazaba (R-10). Desde el 21 de octubre sí puede: login real de `admin.t1` con ES256 y 200 en Core y Rules; Dispatch acepta el token (L-01).
- **Newman:** el 20 de octubre (corrida `20261020T224842Z`, colección corregida) dio 77 solicitudes y 125 aserciones, con 5 fallidas en 4 casos (853-04, 856-05, 1066-01 y 1066-02) por defectos de Desarrollo. El 21 de octubre, con las correcciones desplegadas (corrida `20261021T161015Z`), da 77 solicitudes, 125 aserciones y **0 fallidas**; los demás casos responden igual. 1063-01 rechaza por la falta de la Cámara de Comercio y cuenta como evidencia. Un caso ejecutado no cuenta como evidencia: 856-02 (no concluyente). 1074-05 y 1074-06 están excluidos de la colección.
- **Playwright:** el 20 de octubre, 11 pruebas y 9 aprobadas (FW-02 y FW-03 fallaban por R-04). El 21 de octubre, con R-04 mitigado en QA (corrida `20261021T170129Z`), **11 de 11**.
- **Recorrido E2E en QA:** crear solicitud (1072) → aliados elegibles (861/862) → despacho (1073) → aceptación (1074), con control cross-tenant, aprobado en sus 5 pasos por API. R-04 y R-10 ya no bloquean el recorrido desde Flutter Web que exige SCRUM-1278, pero la suite aún no lo tiene (L-04).
- **Defectos:** 11 propuestos (R-01 a R-11), de los cuales 1 se retiró (R-05). Al 21 de octubre: 4 corregidos y verificados en QA (R-01, R-02, R-03 y R-10), 1 mitigado en QA con la corrección del repositorio pendiente (R-04) y 5 abiertos (R-06, R-07, R-08, R-09 y R-11). Detalle en la sección 8. Los cinco que bloqueaban la aprobación se registraron en Jira el 20 de octubre: R-02 [SCRUM-1358](https://maniservices.atlassian.net/browse/SCRUM-1358), R-01 [SCRUM-1359](https://maniservices.atlassian.net/browse/SCRUM-1359), R-03 [SCRUM-1360](https://maniservices.atlassian.net/browse/SCRUM-1360), R-04 [SCRUM-1361](https://maniservices.atlassian.net/browse/SCRUM-1361) y R-10 [SCRUM-1362](https://maniservices.atlassian.net/browse/SCRUM-1362).

## 2. Ambiente verificado y preparación

La promoción de `develop` a `release` se hizo el 20 de octubre a las 11:27 (Bogotá) en los seis repositorios: MANI-APIGateway#17, MANI-Node#48, MANI-Java#6, MANI-.NET#10, MANI-Flutter#50 y MANI-Landing#5. El árbol de `release` quedó idéntico al de `develop` en los seis.

QA no quedó operativo con la promoción (R-08). Para dejarlo en el código de `release`, QA (Santiago Hernández) hizo los siguientes cambios el 20 de octubre, con respaldo previo de los archivos modificados en `/opt/mani`. Según `governance/GOBIERNO_DEL_EQUIPO.md` §2.3, las decisiones sobre CI/CD, despliegue y secretos corresponden a DevOps; la comunicación formal de estos cambios a DevOps está pendiente.

1. Se bajaron las imágenes `:staging` y se recrearon los seis contenedores.
2. En el compose se cambió `NODE_ENV: staging` por `qa`, porque Core en `release` solo acepta `development`, `qa`, `production` o `test`. A Dispatch se le agregaron `SUPABASE_JWT_SECRET`, la cadena de conexión y `CORE_SERVICE_URL`, que el código nuevo exige. `SUPABASE_URL` perdió su valor por defecto hacia `mock.supabase.co`.
3. `.env.qa` tenía credenciales de relleno y `SUPABASE_URL` apuntaba a `mock.supabase.co`. Se cargaron las credenciales de MANI-QA y se verificaron sin imprimirlas. La conexión usa el Session pooler, porque la conexión directa solo tiene IPv6 y la VM no tiene salida IPv6.
4. Se aplicaron en MANI-QA las migraciones de Core 0001 a 0010 y 0013 de MANI-Node `release` 2745bb0, desde el SQL Editor. Las numeradas 0011 y 0012 no existen en `release`: pertenecen a ramas sin fusionar de SCRUM-865 y SCRUM-869.

Estos cambios no están versionados: el ambiente sobre el que se ejecutó la regresión no se puede reproducir desde los repositorios (R-08).

| Contenedor | Revisión del 20 de octubre | Revisión desde el 21 de octubre |
|---|---|---|
| mani-api-gateway | 82473d6 | f042817 |
| mani-core-service | 2745bb0 | 8ad4a35 |
| mani-rules-service | e90f32b | e90f32b |
| mani-dispatch-service | 41ba171 | 0998a3d |
| mani-flutter-web | 74bab53 | 8e606e4 |
| mani-landing-web | a82b94e | a82b94e |

El 21 de octubre se promovieron a `release` las correcciones (MANI-Node#51 y #53, MANI-.NET#12 y #14, MANI-APIGateway#21) y QA se redesplegó a las 14:57 UTC. Las seis imágenes corresponden a la cabeza de `release`, y `develop` no tiene cambios que falten en `release` en ninguno de los seis repositorios (`ambiente_qa_20261021.txt`). Ese mismo día, con autorización de Santiago Hernández y respaldo previo, QA agregó al compose de `/opt/mani` el montaje de `flutter.env.qa` en `assets/.env` del contenedor `flutter-web` para mitigar R-04 (sección 8). Es otro cambio manual sin versionar (R-08) y queda para que DevOps lo valide en el despliegue.

## 3. Cómo se ejecutó

- **Datos:** tenants de prueba `acme-servicios` (t1) y `nova-mantenimiento` (t2) de `supabase/seed/seed_qa_multitenant.sql`, la semilla que SCRUM-1264 toma como base (supuesto S-03). El aliado `aliado_t1b` (sin servicio asignado) no está en la semilla. Cada corrida crea datos marcados con `QA <corrida>`.
- **Identidad de prueba:** tokens HS256 firmados dentro de la VM con el JWT secret legado de MANI-QA, con los claims `sub`, `app_metadata.tenant_id` y `app_metadata.user_role`. No salen de la VM. `/auth/dev-token` responde 404 en QA (PER-05). Supabase Auth de MANI-QA firma hoy con ECC P-256 (ES256, `kid a069a215`); la clave HS256 legada figura como anterior y sin revocar, por eso los tokens sintéticos siguen siendo válidos (`supabase_auth_20261021.txt`).
- **Newman:** colección generada por `qa/newman/generar_coleccion.js`, ejecutada en contenedor dentro de la VM contra el Gateway (`localhost:80`) y, con el gate de CI habilitado, desde el runner `nbig02-calidad` de la VM de Calidad que prevé la guía CFG4-03 ([run 39513870492](https://github.com/Trama-AS/MANI-APIGateway/actions/runs/39513870492)), con el mismo resultado.
- **Playwright:** imagen oficial `mcr.microsoft.com/playwright:v1.48.2-jammy` en la VM, con trace, capturas y reporte HTML. Los traces se conservan en la VM porque contienen tokens de prueba ya vencidos.
- **Evidencia versionada:** el ejecutor decodifica las respuestas de Newman, enmascara contraseñas temporales y tokens y verifica que no quede ninguna credencial antes de guardar.
- **Trazabilidad:** cada caso de la regresión se relaciona con los casos de SCRUM-1264 que cubre, de forma completa o parcial (hoja `ejecucion_casos`, columna `caso_1264`, y hoja `cobertura_1264`), como pide el DoD de QA.
- **Correcciones posteriores a la primera corrida:** la colección se corrigió después de la auditoría (1063-01, 856-00, 856-02, 856-06, aserciones de negocio y precondiciones). Primero se verificaron reproduciendo las respuestas guardadas (`verificacion_coleccion_por_reproduccion.txt`) y después se ejecutaron en QA en la corrida `20261020T224842Z` (L-10 cerrada). Las aserciones pasan de 91 a 125 y las 5 fallidas son las mismas de la primera corrida.
- **Validación del 21 de octubre:** Newman y Playwright desde una copia de MANI-APIGateway en `release` (`f042817`); login real con `qa/monitoreo_qas/confirmar_d02.sh`, ejecutado por Santiago Hernández con un usuario de la semilla; tokens ES256 falsificados con una clave propia para comprobar el rechazo; y consultas de solo lectura a la configuración de Supabase Auth.
- **Consultas sobre la base:** para R-06, R-07 y R-09 se ejecutaron consultas de catálogo de solo lectura (`BEGIN READ ONLY ... ROLLBACK`) con `psql` en contenedor dentro de la VM y las cadenas de conexión de Core y Dispatch de `.env.qa`, sin imprimir credenciales (`consultas_rls_20261020T225146Z.txt` y `dispatch_rol_20261020T232719Z.txt`; repetidas el 21 de octubre en `consultas_rls_20261021T170441Z.txt`).

## 4. Criterios de estado y de origen

Los estados de historia usan el vocabulario de SCRUM-1267 y el estado multi-tenant por caso usa el de SCRUM-1279.

| Estado de la historia | Criterio |
|---|---|
| Aprobado | Todos los casos diseñados aplicables están cubiertos, pasan con una identidad que un usuario real puede usar (o la historia no usa rutas protegidas) y se verificaron todos sus criterios de aceptación. |
| Ejecutado | Se ejecutaron casos y ninguno falla por un defecto del sistema, pero la evidencia no alcanza para aprobar. Incluye historias cuyos casos ejecutados no son válidos. |
| Fallido | Al menos un caso válido falla por un defecto del sistema. |
| Bloqueado | Una dependencia externa a QA impide ejecutar la historia. |
| No disponible | La historia no tiene código fusionado. |
| Sin ejecutar | La historia ya no tiene bloqueo externo y QA no ha ejecutado sus casos. No es un estado del vocabulario de SCRUM-1267; se declara para no ocultar la brecha (SCRUM-1060 desde el 21 de octubre). |

| Estado multi-tenant por caso (X1 a X6) | Criterio |
|---|---|
| aprobado / fallido | El caso se ejecutó; "(parcial)" indica que cubre una parte del caso diseñado. |
| bloqueado | Una dependencia externa impide ejecutarlo. |
| no aplica | SCRUM-1264 lo declara no aplicable. |
| sin ejecutar | El caso es ejecutable y QA no lo corrió. No es un estado del DoD de SCRUM-1279: se declara para no ocultar la brecha. |

Cada caso de la regresión se marca además como No válido, No concluyente o Excluido cuando no cuenta como evidencia.

| Origen | Condición |
|---|---|
| Desarrollo | La prueba sigue el criterio de aceptación o el contrato y el sistema responde distinto, con la causa en el código. |
| DevOps | El mismo código funciona con otra configuración, o falta un componente del despliegue. |
| QA | La prueba, los datos o la cobertura no corresponden al criterio. |

## 5. Resultado por historia

| Historia | Subtarea QA | Casos SCRUM-1264: completos / parciales / diseñados | Estado QA | Origen de la brecha o del fallo | Observación |
|---|---|---|---|---|---|
| SCRUM-850 | SCRUM-1306 | 0 / 3 / 12 | Ejecutado | QA (cobertura) | Alta, duplicado de correo y rol cliente, cada uno de forma parcial. Sin campos vacíos ni casos cross-tenant X1 a X5. |
| SCRUM-852 | SCRUM-1307 | 1 / 2 / 10 | Ejecutado | QA (cobertura) | Cliente empresa con dos sedes creado por el admin del tenant; X1 aprobado. |
| SCRUM-853 | SCRUM-1308 | 3 / 1 / 10 | Ejecutado | QA (cobertura) | El aliado asignado lee las reglas del sitio (C1, 853-04) desde el 21 de octubre; el 20 recibía 403 (R-02, corregido). El aliado sin asignación recibe 403 y el de otro tenant 404. |
| SCRUM-854 | SCRUM-1309 | 1 / 2 / 11 | Ejecutado | QA (cobertura) | Teléfono actualizado; el rol no se puede cambiar. |
| SCRUM-855 | SCRUM-1310 | 2 / 1 / 11 | Ejecutado | QA (cobertura) | Incluye el borrado ajeno (855-04, X4). Sin solapamiento (C4), fin anterior al inicio (C2) ni elegibilidad durante la ausencia (C5). |
| SCRUM-856 | SCRUM-1311 | 1 / 1 / 11 | Ejecutado | QA (cobertura) | Los documentos legales se consultan antes del registro (856-05) desde el 21 de octubre; el 20 el Gateway exigía token (R-01, corregido). El consentimiento sobre un documento de t2 se rechaza con `LEGAL_DOCUMENT_NOT_FOUND` (856-03) y repetir el consentimiento no lo duplica (856-06). 856-02 sigue no concluyente: el cliente t1 ya había consentido en la corrida `20261020T200914Z`. Core no expone una consulta del consentimiento propio (C4): por confirmar con Desarrollo. |
| SCRUM-858 | SCRUM-1312 | 3 / 1 / 11 | Ejecutado | QA (cobertura) | Desactivar sin aparecer en la vitrina (C1) y aislamiento. Sin C2 (solicitud nueva con categoría inactiva) ni C3 (servicios en curso). |
| SCRUM-861 | SCRUM-1313 | 2 / 0 / 11 | Ejecutado | QA (cobertura); R-11 | Elegible y sin aliados de t2 (Newman y E2E-02). |
| SCRUM-862 | SCRUM-1314 | 2 / 0 / 11 | Ejecutado | QA (cobertura); R-11 | Filtro por persona natural y rechazo de tipo inválido. El filtro ya acepta EMPLEADO_DIRECTO (PE6 de SCRUM-1257 resuelto). |
| SCRUM-865 | SCRUM-1315 | - | No disponible | Desarrollo | MANI-Node#32 cerrado sin fusionar. |
| SCRUM-866 | SCRUM-1316 | - | Bloqueado | Desarrollo | Historia en estado blocked en Jira, sin PR. |
| SCRUM-867 | SCRUM-1317 | - | No disponible | Desarrollo | MANI-Node#33 cerrado sin fusionar. |
| SCRUM-868 | SCRUM-1318 | - | No disponible | Desarrollo | MANI-Node#34 cerrado sin fusionar. |
| SCRUM-869 | SCRUM-1319 | - | No disponible | Desarrollo | MANI-Node#35 cerrado sin fusionar. |
| SCRUM-870 | SCRUM-1320 | - | No disponible | Desarrollo | MANI-Node#36 cerrado sin fusionar. |
| SCRUM-874 | SCRUM-1321 | - | Bloqueado | Desarrollo | Historia en estado blocked en Jira, sin PR. |
| SCRUM-875 | SCRUM-1326 | - | Bloqueado | Desarrollo | Historia en estado blocked en Jira, sin PR. |
| SCRUM-879 | SCRUM-1327 | - | No disponible | Desarrollo | MANI-Node#37 cerrado sin fusionar. |
| SCRUM-1060 | SCRUM-1328 | 0 / 0 / 22 | Sin ejecutar | QA | Historia de interfaz. Estaba bloqueada por R-04 y R-10; desde el 21 de octubre ya no lo está, pero QA no ha ejecutado sus casos de interfaz ni los de API por el Gateway (CC-2 a CC-4 y X1 a X6). |
| SCRUM-1070 | SCRUM-1329 | 0 / 4 / 16 | Ejecutado | QA (cobertura) | Rules rechaza nombre y flujo inválidos a través de Core y el aliado no evalúa CREATE; ninguno cubre por completo un caso diseñado. |
| SCRUM-1072 | SCRUM-1330 | 1 / 2 / 15 | Ejecutado | QA (cobertura) | Creación, reintento con la misma clave, validación y rol. Sin C3 (sitio de otro cliente). |
| SCRUM-1073 | SCRUM-1331 | 0 / 1 / 14 | Ejecutado | QA (cobertura); R-11 | Orquestación y rutas internas cerradas. La publicación de eventos no es ejecutable: QA no tiene Kafka. |
| SCRUM-1074 | SCRUM-1332 | 2 / 2 / 14 | Ejecutado | QA (cobertura); R-11 | Aceptación, reaceptación idempotente y rechazo cross-tenant. La doble aceptación se excluyó (L-07); la concurrencia (K1) no se ejecutó. |
| SCRUM-1335 | SCRUM-1356 | - | Ejecutado | QA (criterios sin verificar) | CA-1 y CA-2 verificados con Playwright. CA-3 solo en parte (el botón abre Flutter Web; no se verifica que conserve el contexto). CA-4 a CA-7 requieren revisión de código y de pipeline y no se ejecutaron. Sin casos en SCRUM-1264. |
| SCRUM-1063 | sin subtarea QA | 0 / 1 / 18 | Ejecutado | QA (cobertura) | 1063-01 rechaza el registro sin la Cámara de Comercio (US0212M2-N1, parcial). Sin el registro con documentos (C1), la empresa duplicada (CA-4), el bucket privado (CA-2) ni los casos X1 a X6. |
| SCRUM-1066 | sin subtarea QA | 2 / 1 / 20 | Ejecutado | QA (cobertura) | Listado y detalle de verificación responden 200 desde el 21 de octubre; el 20 respondían 500 (R-03, corregido). Aprobar, rechazar, la auditoría (T10) y el X6 siguen sin ejecutar. |
| SCRUM-1068 | sin subtarea QA | 0 / 0 / 11 | Bloqueado | Desarrollo | Historia en estado blocked en Jira, sin PR identificado. |

Hasta el 20 de octubre todas las historias con rutas protegidas llevaban además R-10 y las que tienen casos de interfaz previstos llevaban R-04; la matriz los marca como corregido y mitigado en QA. Los casos de interfaz siguen sin ejecutar (L-04). El detalle está en las hojas `resumen_historias`, `cobertura_1264` y `ejecucion_casos` de la matriz.

## 6. Recorrido E2E en QA

Prueba `qa/playwright/tests/e2e_solicitud.spec.js`, corrida `20261021T170129Z` (igual resultado que en `20261020T224932Z` y `20261020T212519Z`).

| Paso | Historia | API (a través del Gateway) | Resultado | Caso de SCRUM-1264 |
|---|---|---|---|---|
| E2E-01 | SCRUM-1072 | `POST /api/v1/core/solicitudes` (cliente t1, sitio t1) | 201, solicitud en estado PENDIENTE | US0411M2-P1 (parcial) |
| E2E-02 | SCRUM-861/862 | `GET /api/v1/dispatch/requests/{id}/eligible-allies?tipo=PERSONA_NATURAL` | 200, incluye al aliado t1 y no al de t2 | US0412-P1, US0412-S1, US0413-P2 |
| E2E-03 | SCRUM-1073 | `POST /api/v1/dispatch/requests/orchestrate` | 200, oferta transmitida a 1 aliado elegible | US0411M6-P1 (parcial) |
| E2E-04 | SCRUM-1074 | `POST /api/v1/dispatch/requests/{id}/accept` dos veces (aliado t1) | 200 y 200 (reintento idempotente, mismo aliado) | US0414M6-P1, US0414M6-K2 |
| E2E-05 | Cross-tenant | Aceptación por el aliado t2 | 404 | US0414M6-X3 (parcial) |

El recorrido usa APIs y datos reales de QA, con tokens de prueba. El inicio desde la interfaz Flutter no se ejecutó. Hasta el 20 de octubre lo impedían R-04 (la web de QA apuntaba al Supabase de producción) y R-10 (un usuario real no podía usar rutas protegidas); desde el 21 de octubre ninguno lo impide, y falta que la suite incluya el flujo de interfaz (L-04).

## 7. Regresión multi-tenant (SCRUM-1279)

Los seis casos cross-tenant (B1 a B6) se definieron en SCRUM-1105 y ADR-0015, y SCRUM-1264 los detalla por historia (hoja `cross_tenant`). El reporte de SCRUM-1105 (`product/REPORTE_QA_CFG-23c.md`) se retiró de `main` en el commit e4950fc (SCRUM-1249); esta regresión reutiliza la definición de los casos, no ese documento.

| Caso | Qué se prueba | Casos de la colección | Resultado |
|---|---|---|---|
| B1 | Lectura de un recurso de otro tenant (sedes de un cliente de t2) | B1-01 | 404, aprobado |
| B2 | Listado sin recursos ajenos (categorías) | B2-01 | 200 sin ids de t2, aprobado |
| B3 | Escritura en otro tenant (reglas de un sitio de t2) | B3-01 | 404, aprobado |
| B4 | Borrado de un recurso ajeno (ausencia de otro aliado) | 855-04 (B4-01 es un control con un id inexistente) | 404, aprobado |
| B5 | Token expirado, firma alterada, sin `tenant_id` y `X-Tenant-Id` falso | B5-01 a B5-04 | 401, 401, 401 y sin efecto; aprobado |
| B6 | KYC de un aliado de otro tenant | B6-01 | 404 sobre el detalle de verificación; las URL firmadas de Storage no se probaron (L-05) |

**Por historia (DoD: seis casos cross-tenant en cada historia que toca tenant o datos).** De 90 casos aplicables, 10 se ejecutaron y se aprobaron (US0222-X1, US0223-X1, US0223-X3, US0231-X5 parcial, US0216-X4, US0232-X3, US0312-X1, US0312-X2, US0213M2-X1 y US0414M6-X3 parcial), 5 están bloqueados (SCRUM-1068) y 75 no se ejecutaron. El X6 de SCRUM-1066 estaba bloqueado por R-03; desde su corrección, el 21 de octubre, pasa a sin ejecutar. Ninguna historia cumple todavía ese añadido del DoD. El detalle por historia está en la columna `multitenant_x1_x6_scrum_1279` de la matriz.

El aislamiento comprobado es el de la aplicación a través del Gateway. La defensa en la base (RLS) no se ejerce en QA, según las consultas de solo lectura de `consultas_rls_20261020T225146Z.txt`, repetidas el 21 de octubre con el mismo resultado (`consultas_rls_20261021T170441Z.txt`):

- **R-09:** Core y Dispatch se conectan como `postgres` (`current_user = postgres`, `rolbypassrls = t`), cada uno con su propia cadena de `.env.qa` (`consultas_rls_20261020T225146Z.txt` y `dispatch_rol_20261020T232719Z.txt`). `mani_core_svc` y `mani_dispatch_svc` existen sin LOGIN y sin BYPASSRLS.
- **R-07:** `poc_asignacion_log` tiene RLS habilitado sin FORCE (`relforcerowsecurity = f`), y `db/verify/0007` se detiene en ese invariante (`verify_0007_rls_20261020T202905Z.log`).
- **R-06:** 15 políticas `tenant_isolation_*` con `TO public`, una por tabla. Con las 3 de lectura global (`documento_legal`, `tenant` y `zona`) son 18 las políticas con `TO public`; la versión anterior del reporte las contaba todas como `tenant_isolation_*`.

## 8. Defectos propuestos

R-01 a R-04 y R-10 se registraron en Jira el 20 de octubre (SCRUM-1358 a SCRUM-1362), asignados y enlazados a su historia y a SCRUM-1267, con prioridad Highest y vencimiento el 20 de octubre. El 21 de octubre se corrigieron o mitigaron y se verificaron en QA (tabla de estado al final de esta sección). R-06 a R-09 y R-11 siguen como propuestas. El formato sigue el de las propuestas de SCRUM-1266 y el de los defectos existentes del proyecto (tipo Error, resumen `BUG-<área>-NN`, como SCRUM-1333 y SCRUM-1334). La numeración R-xx es propia de este reporte; la hoja `equivalencias` de la matriz la relaciona con la versión anterior y con SCRUM-1266.

| Id | Propuesta | Severidad | Prioridad sugerida | Historia | Hallazgo | Origen |
|---|---|---|---|---|---|---|
| R-10 | BUG-SEC-04, [SCRUM-1362](https://maniservices.atlassian.net/browse/SCRUM-1362) (propuesto antes en SCRUM-1266) | Crítica | Highest | Todas con rutas protegidas | `validate-token` acepta solo HS256; Supabase Auth de MANI-QA emite ES256. Ningún usuario real usa las rutas protegidas. SCRUM-1266 lo propuso como High; con Core real desplegado bloquea a todos los usuarios | Desarrollo |
| R-04 | BUG-QA-07, [SCRUM-1361](https://maniservices.atlassian.net/browse/SCRUM-1361) | Crítica | Highest | Historias con interfaz | La imagen `mani-flutter:staging` se construye con `.env.example`: Supabase de producción y Gateway en `localhost` | DevOps, con Flutter |
| R-08 | BUG-QA-08 | Alta | High | Todas | La promoción a release no dejó QA operativo; compose y despliegue sin versionar | DevOps |
| R-01 | BUG-GW-01, [SCRUM-1359](https://maniservices.atlassian.net/browse/SCRUM-1359) | Alta | High | SCRUM-856 | El Gateway exige token en `GET /legal/documents/active`, que Core declara pública | Desarrollo (Gateway) |
| R-02 | BUG-CORE-01, [SCRUM-1358](https://maniservices.atlassian.net/browse/SCRUM-1358) | Alta | High | SCRUM-853 | `GET /sites/:id/rules` no permite al aliado asignado leer las reglas | Desarrollo (Core) |
| R-03 | BUG-CORE-02, [SCRUM-1360](https://maniservices.atlassian.net/browse/SCRUM-1360) | Alta | High | SCRUM-1066 | El repositorio selecciona `documento_kyc.created_at`; la tabla tiene `fecha_carga` | Desarrollo (Core) |
| R-09 | BUG-SEC-05 | Alta | High | SCRUM-1279 | Core y Dispatch conectan como `postgres`; los roles de servicio no tienen LOGIN | DevOps |
| R-11 | BUG-DISP-01 | Media | Medium | 861, 862, 1073, 1074 | Las respuestas de error de Dispatch no tienen `code` (criterio transversal T5); confirma el pendiente PE5 de SCRUM-1257 | Desarrollo (Dispatch) |
| R-06 | BUG-SEC-06 | Media | Medium | SCRUM-1279 | 15 políticas heredadas `tenant_isolation_*` con `TO public` | Desarrollo |
| R-07 | BUG-QA-09 | Media | Medium | SCRUM-1279 | `poc_asignacion_log` sin FORCE RLS detiene `db/verify/0007` | DevOps |

Detalle para el registro:

| Id | Ambiente | Cómo se reproduce | Esperado | Observado | Evidencia |
|---|---|---|---|---|---|
| R-10 | QA, Core 2745bb0, Supabase MANI-QA | Password grant de un usuario de prueba y llamada a `GET /api/v1/core/profiles/me` por el Gateway (`qa/monitoreo_qas/confirmar_d02.sh`) | 200 con el tenant del claim | 401 en Core, Rules y Dispatch | `confirmacion_d02_login_real.txt` (SCRUM-1266); MANI-Node `src/routes/auth.routes.js:9` |
| R-04 | QA, Flutter 74bab53 | Abrir `http://10.43.100.141:8080` y leer `/assets/.env` | Supabase de MANI-QA y Gateway de QA | Proyecto MANI y `localhost`; el login lista empresas de producción | FW-02, FW-03; `flutter_login_qa.png`; MANI-Flutter `docker-publish.yml:30` |
| R-08 | VM de QA | Desplegar `:staging` de release con el compose de `/opt/mani` | Servicios sanos con la configuración del repositorio | Core no arranca con `NODE_ENV=staging`; Dispatch sin configuración | Sección 2 (sin evidencia versionada) |
| R-01 | QA, Gateway 82473d6 | `GET /api/v1/core/legal/documents/active` con `X-Tenant-Slug` y sin token | 200 | 401 | 856-05 en `newman_resumen_20261020T224842Z.json` (igual en `20261020T212453Z`); MANI-Node `src/routes/legal.routes.js:8` |
| R-02 | QA, Core 2745bb0 | El aliado t1 acepta una solicitud del sitio de t1 y consulta sus reglas | 200 | 403 | 853-04 en `newman_resumen_20261020T224842Z.json` (igual en `20261020T212453Z`); `GetSiteRulesForAllyUseCase.js:45-51` |
| R-03 | QA, Core 2745bb0 | Admin t1 consulta `GET /api/v1/core/aliados/verificacion` | 200 | 500 `column documento_kyc.created_at does not exist` | 1066-01 y 1066-02 en `newman_resumen_20261020T224842Z.json` (igual en `20261020T212453Z`); `SupabaseDocumentoKycRepository.js:44` |
| R-09 | VM de QA y MANI-QA | `current_user` con la cadena de cada servicio y `pg_roles` de `postgres`, `mani_core_svc` y `mani_dispatch_svc` | Servicios conectados con roles sin BYPASSRLS | Core y Dispatch como `postgres` (`rolbypassrls = t`); roles de servicio sin LOGIN | `consultas_rls_20261020T225146Z.txt` (sección 3 y usuario de Core); `dispatch_rol_20261020T232719Z.txt` (usuario de Dispatch) |
| R-11 | QA, Dispatch 41ba171 | Filtro con `tipo=MARCIANO` (862-02) o aceptación como cliente (1074-04) | `{ error, code, correlationId }` | `{ error, status, correlationId, timestamp }` | Cuerpos de 862-02, 1074-03 y 1074-04 en `newman_reporte_redactado_20261020T224842Z.json` (igual en `newman_reporte_redactado.json`) |
| R-06 | MANI-QA | `pg_policies` con `policyname like 'tenant_isolation_%'` | Solo las políticas de la migración 0007 | 15 políticas `tenant_isolation_*` con `TO public` (18 con `TO public` en total) | `consultas_rls_20261020T225146Z.txt` (secciones 1, 1b y 1c) |
| R-07 | MANI-QA | `pg_class` de `poc_asignacion_log` y `db/verify/0007` en una transacción revertida | Invariantes en verde | `relforcerowsecurity = f`; `db/verify/0007` se detiene en `poc_asignacion_log` | `consultas_rls_20261020T225146Z.txt` (sección 2); `verify_0007_rls_20261020T202905Z.log` |

Fundamento, corrección sugerida y responsable de cada defecto: hoja `defectos_propuestos` de la matriz. Las filas anteriores describen los defectos tal como se observaron el 20 de octubre.

**Estado al 21 de octubre:**

| Id | Jira | Estado | Corrección | Verificación en QA (evidencia en `20261021_validacion/`) |
|---|---|---|---|---|
| R-01 | [SCRUM-1359](https://maniservices.atlassian.net/browse/SCRUM-1359) | Corregido y verificado | MANI-APIGateway#20 (excepción pública en `nginx.conf` y contrato, con prueba `tests/gateway/ruta-publica-legal.sh`), promovido con #21 | 856-05 en 200 (`newman_resumen_20261021T161015Z.json`) |
| R-02 | [SCRUM-1358](https://maniservices.atlassian.net/browse/SCRUM-1358) | Corregido y verificado | MANI-Node#50 (Core consulta las asignaciones a Dispatch) y MANI-.NET#11 (Dispatch las expone), con pruebas unitarias y de integración; promovidos con MANI-Node#51 y MANI-.NET#12 | 853-04 en 200; 853-02 sigue en 403 y 853-03 en 404 |
| R-03 | [SCRUM-1360](https://maniservices.atlassian.net/browse/SCRUM-1360) | Corregido y verificado | MANI-Node#49 (`fecha_carga`), con prueba del repositorio; promovido con #51 | 1066-01 y 1066-02 en 200 |
| R-10 | [SCRUM-1362](https://maniservices.atlassian.net/browse/SCRUM-1362) | Corregido y verificado | MANI-Node#52 y MANI-.NET#13 (ES256 verificado con el JWKS de Supabase), con pruebas de seguridad; promovidos con MANI-Node#53 y MANI-.NET#14. El ADR-0031 que lo respalda está en MANI-docs#59, abierto | Login real de `admin.t1` con ES256: 200 en Core y Rules y token aceptado en Dispatch (`login_real_es256_20261021T164543Z.txt`). Tokens ES256 firmados con otra clave, sin `kid` o con `alg: none`: 401 en Core y Dispatch (`es256_negativos_20261021.txt`) |
| R-04 | [SCRUM-1361](https://maniservices.atlassian.net/browse/SCRUM-1361) | Mitigado en QA; corrección del repositorio pendiente | Montaje manual de `/opt/mani/flutter.env.qa` en `assets/.env` del contenedor `flutter-web` (sin versionar, R-08). MANI-Flutter sigue copiando `.env.example` al construir la imagen | FW-02 y FW-03 aprueban (`playwright_resultados_20261021T170129Z.json`); antes del montaje fallaban (`playwright_resultados_20261021T161050Z_antes_r04.json`) |
| R-06, R-07, R-09 | - | Abiertos | - | Sin cambios en `consultas_rls_20261021T170441Z.txt` |
| R-08 | - | Abierto | - | Al compose sin versionar se sumó el montaje de R-04 |
| R-11 | - | Abierto | - | 862-02 y 1074-04 siguen sin `code` (`newman_reporte_redactado_20261021T161015Z.json`) |

El estado de SCRUM-1358 a SCRUM-1362 en Jira no se actualizó desde este reporte: el conector de Jira no estuvo disponible el 21 de octubre.

**Hallazgo retirado (R-05).** Se había propuesto que Flutter Web no arranca en QA. Era un error de la prueba: el encabezado global X-Correlation-ID de Playwright provocaba el rechazo del preflight CORS en el CDN de Google. Sin el encabezado la aplicación llega a `/login` en 3,1 s y FW-01 pasa.

## 9. Atribución de los resultados

| Origen | Qué le corresponde |
|---|---|
| Desarrollo | Abiertos: R-11 (formato de error de Dispatch) y R-06. Corregidos el 21 de octubre: R-01, R-02 y R-03 (fallos de 856, 853 y 1066) y R-10 (identidad real). |
| DevOps | R-04 (mitigado en QA el 21 de octubre; falta la corrección en MANI-Flutter), R-08 (despliegue sin versionar), R-09 (RLS no ejercido) y R-07. |
| QA | La cobertura de SCRUM-1264 (20 completos y 22 parciales de 228; 75 casos cross-tenant sin ejecutar), los casos de SCRUM-1060 y los flujos de interfaz sin ejecutar, los criterios de SCRUM-1335 sin verificar, el caso no concluyente 856-02 (falta un usuario sin consentimiento en la semilla) y los casos PENDIENTE de la colección de contrato (SCRUM-1277). Ya se corrigieron el falso positivo FW-01 (R-05), el falso positivo de 1063-01 y la falta de evidencia versionada de R-06, R-07 y R-09. |

## 10. Discrepancias con Jira

- Las subtareas "QA - Validar US" de 850, 852, 853, 854, 855, 856, 858, 861, 862, 1060, 1070, 1072, 1073, 1074 y 1335 están en Finalizada. Su cierre se basó en el merge a `develop` y el CI en verde, no en una ejecución en QA. Resultado real en QA de esas 15 historias al 21 de octubre: 14 Ejecutado y 1 Sin ejecutar (1060); el 20 de octubre 853 y 856 estaban en Fallido.
- Las historias 853, 856 y 1066 estaban en Finalizada con un fallo en QA el 20 de octubre. Sus defectos (SCRUM-1358, 1359 y 1360) se corrigieron y verificaron el 21 de octubre, así que esa discrepancia ya no existe; las tres siguen sin cumplir la cobertura de SCRUM-1264.
- El DoD de QA (`CRITERIOS_ACEPTACION_SPRINT4.md` §4) pide que la evidencia vaya en la subtarea QA de cada historia con los IDs de casos de SCRUM-1264. La evidencia está en este reporte y en la matriz, y el 20 de octubre se registró con un comentario en cada una de las 14 subtareas de historias con ejecución (estado QA, casos de SCRUM-1264, casos de la regresión, corrida y defectos). SCRUM-1328 (SCRUM-1060, Bloqueado) y las subtareas de historias No disponible o Bloqueado no tienen ejecución que registrar.
- SCRUM-1277 y SCRUM-1278 están en Finalizada. Sus PR (MANI-APIGateway#18 y #19) se fusionaron el 20 de octubre y el gate de CI se ejecutó ese día en rojo por R-01 a R-04; falta la corrida en verde en CI (L-08).
- SCRUM-1063, 1066 y 1068 no tienen subtarea QA (pendiente PE4 de SCRUM-1257).
- SCRUM-865, 867, 868, 869, 870, 879 y 1335 tienen subtarea QA pero no tienen casos diseñados en SCRUM-1264.
- Desde este reporte se hicieron en Jira, el 20 de octubre, los comentarios de evidencia en las subtareas QA y en SCRUM-1267 y el registro de SCRUM-1358 a SCRUM-1362. No se cambiaron estados de historias ni de subtareas.

## 11. Relación con SCRUM-1266

- **R-10** es el hallazgo H-02 de SCRUM-1266 (propuesta D-02, BUG-SEC-04), comprobado allí con un inicio de sesión real. El mismo script de SCRUM-1266 confirmó su corrección el 21 de octubre (`login_real_es256_20261021T164543Z.txt`).
- **Propuestas de SCRUM-1266 que ya no se reproducen** tras el redespliegue del 20 de octubre: D-01 (`/auth/dev-token` público: PER-05 responde 404) y D-03 (el Gateway de QA no corría la revisión de `release`: corría 82473d6 el 20 de octubre y f042817 desde el 21). D-08 (`SUPABASE_URL` hacia un mock) se corrigió a mano y queda dentro de R-08.
- **QAS-01:** SCRUM-1266 dejó bloqueados los casos 1 a 4 y 6 porque Core era un stub. Con Core real, esta regresión ejecuta B1 a B6 por el Gateway (sección 7), con la cobertura por historia indicada allí.
- **QAS-07:** la regresión ya no usa la solicitud de PoC que el arnés de QAS-07 necesita en PENDIENTE (1074-05 y 1074-06 excluidos). Esa solicitud quedó ASIGNADA por corridas anteriores; restablecerla con `supabase/poc-cfg09/11_reset_solicitud.sql` del Gateway es una decisión pendiente.

## 12. Reproducibilidad

```bash
node qa/newman/generar_coleccion.js
COLECCION=qa/newman/mani_regresion_sprint4.postman_collection.json bash qa/ejecutar_newman_qa.sh
SUITE_DIR=qa/playwright bash qa/ejecutar_playwright_qa.sh
```

Se ejecutan en la VM de QA desde una copia de MANI-APIGateway, o desde la VM de Calidad indicando las URLs de QA (`qa/README.md`). La corrida de las 21:24 UTC usó la colección y la suite empaquetadas, idénticas a las versionadas en ese momento. Las corridas del 20 de octubre con la colección corregida (`20261020T224842Z` y `20261020T224932Z`) se hicieron desde una copia de la rama `qa/SCRUM-1267-regresion-sprint4` en 7a5d6ea, y las del 21 de octubre (`20261021T161015Z` y `20261021T170129Z`) desde `release` en `f042817`, con la colección regenerada por `generar_coleccion.js` sin diferencias frente a la versionada. El workflow `.github/workflows/qa-regresion.yml` (jobs `newman_qa` y `playwright_qa`) está habilitado desde el 20 de octubre: environment `qa-regresion` con revisor obligatorio y el secreto `QA_JWT_SECRET`, y variables de repositorio `QA_GATEWAY_URL`, `QA_FLUTTER_URL`, `QA_LANDING_URL` y `QA_REGRESION_HABILITADA=true` (`qa/README.md`). Cada job espera la aprobación del revisor.

## 13. Límites y supuestos

| Id | Tema | Descripción | Origen |
|---|---|---|---|
| L-01 | Identidad de prueba | La regresión sigue usando tokens HS256 sintéticos, válidos mientras la clave HS256 legada de MANI-QA no se revoque. Desde el 21 de octubre un usuario real sí usa las rutas protegidas (R-10 corregido), pero eso se verificó solo con `admin.t1` y tres rutas. Pasar la regresión a usuarios reales (los que prevé SCRUM-1269) queda pendiente. | QA |
| L-02 | Punto de ejecución (cerrada) | Cerrada el 20 de octubre: además de la VM de QA, la regresión corrió desde el runner `nbig02-calidad` de la VM de Calidad ([run 39513870492](https://github.com/Trama-AS/MANI-APIGateway/actions/runs/39513870492)) con el mismo resultado. Desde el equipo del QA por la VPN, el puerto 80 de QA sigue respondiendo reset. | DevOps |
| L-03 | Cobertura de SCRUM-1264 | 20 casos completos y 22 parciales de 228; de los 200 de prioridad Alta, 13 completos y 19 parciales. ADR-0005 exige al menos 90 % de casos críticos: no se cumple. | QA |
| L-04 | Interfaz | No se ejecutaron flujos de interfaz. Hasta el 20 de octubre los bloqueaban R-04 y R-10; desde el 21 ya no, y falta que la suite Playwright incluya flujos Flutter Web → Gateway → servicios. | QA |
| L-05 | Casos B4 y B6 | B4-01 es un control con un id inexistente; el borrado ajeno se prueba en 855-04. B6 no cubre las URL firmadas de Storage: lo impedía R-03, corregido el 21 de octubre, y el caso aún no se ejecuta. | QA |
| L-06 | Expectativas y casos invalidados | Tras la primera corrida se ajustaron expectativas (1074-02 y E2E-04 de 409 a 200 por reintento idempotente documentado; 853-02 redefinido y 853-04 agregado). En la auditoría se invalidó 1063-01 y 856-02 quedó como no concluyente. En la corrida `20261020T224842Z`, 1063-01 ya rechaza por la Cámara de Comercio y cuenta como evidencia; 856-02 sigue no concluyente porque el cliente t1 ya había consentido. | QA |
| L-07 | Datos de prueba | Cada corrida crea datos `QA <corrida>` en MANI-QA. 1074-05 y 1074-06 se excluyeron para no alterar la solicitud de QAS-07. `aliado_t1b` no está en la semilla versionada. | QA |
| L-08 | Gate de CI | Habilitado por QA el 20 de octubre y ejecutado una vez ([run 39513870492](https://github.com/Trama-AS/MANI-APIGateway/actions/runs/39513870492)): Newman 77 solicitudes, 125 aserciones y 5 fallidas; Playwright 11 pruebas y 9 aprobadas. Los dos jobs quedan en rojo por R-01 a R-04, que es la corrida en rojo que pide el DoD. Con las correcciones del 21 de octubre la regresión en la VM de QA da 0 fallas, pero la corrida en verde en CI no se ha hecho. El gate no es un check obligatorio de la rama. GOBIERNO_DEL_EQUIPO §2.3 asigna CI/CD y secretos a DevOps. | QA y DevOps |
| L-09 | Aislamiento en el motor | RLS no se ejerce en QA (R-06, R-07 y R-09, con evidencia en `consultas_rls_20261020T225146Z.txt` y `consultas_rls_20261021T170441Z.txt`). | Desarrollo y DevOps |
| L-10 | Correcciones sin corrida (cerrada) | Cerrada el 20 de octubre: la colección corregida se ejecutó en QA (Newman `20261020T224842Z` y Playwright `20261020T224932Z`). La verificación por reproducción queda como antecedente. | QA |
| L-11 | Pruebas de desarrollo y contrato | Los casos de SCRUM-1264 previstos como prueba de integración nativa, SQL, revisión estática, prueba unitaria de Flutter, k6 o manual no forman parte de esta regresión, y no se recopiló la evidencia de desarrollo. Los tres casos PENDIENTE de la colección de contrato `postman/MANI-Core` (login, refresh y logout) siguen pendientes. | QA |

## 14. Pendientes

Atendidos el 20 de octubre: la corrida de la colección corregida (L-10), la evidencia versionada de R-06, R-07 y R-09 y el registro de la evidencia en las subtareas "QA - Validar US" con los IDs de casos de SCRUM-1264 (comentarios en Jira). Siguen pendientes:

Atendidos el 21 de octubre: la corrección y la verificación en QA de R-01, R-02, R-03 y R-10, la mitigación de R-04 en QA y la prueba con un token real de Supabase Auth.

1. Ampliar la colección hacia los casos de SCRUM-1264 con su ID, empezando por los 75 casos cross-tenant sin ejecutar, y completar los casos PENDIENTE de la colección de contrato.
2. Ejecutar los casos de SCRUM-1060 y agregar a Playwright los flujos Flutter Web → Gateway → servicios (L-04).
3. Pasar la regresión de tokens sintéticos a usuarios reales de Supabase Auth y, después, decidir con DevOps la revocación de la clave HS256 legada (L-01).
4. Comprobar el gate de CI con una corrida en verde (L-08).
5. Corregir R-04 en MANI-Flutter (dejar de copiar `.env.example` al construir y reemplazar sus valores reales de producción por valores de ejemplo) y versionar el compose de QA, incluido el montaje de `flutter.env.qa` (R-08).
6. Corregir R-06, R-07, R-09 y R-11 por sus responsables.
7. Revisar y fusionar el ADR-0031 de MANI-docs#59, que respalda la corrección de R-10 ya promovida a `release`.
8. Actualizar en Jira el estado de SCRUM-1358 a SCRUM-1362 con su verificación.
9. Verificar CA-3 a CA-7 de SCRUM-1335 (contexto en la redirección, revisión de código y pipeline, ejecución local).
10. Agregar a la semilla `aliado_t1b`, documentos legales por tenant, un usuario sin consentimiento (para que 856-02 sea concluyente) y un segundo aliado elegible de t1, y reemplazar la doble aceptación excluida.
11. Restablecer la solicitud de PoC y retirar de la VM los respaldos de `.env.qa` y del compose y los traces de las corridas (requiere autorización).
12. Presentar los resultados a la PO y obtener su validación de SCRUM-1279.

## 15. Cumplimiento del DoD de SCRUM-1267

| Criterio | Estado | Razón |
|---|---|---|
| Matriz de ejecución con el 100 % de las historias priorizadas, con estado y evidencia o bloqueo | Cumplido | 27 de 27 con estado, evidencia o bloqueo, y trazabilidad a los casos de SCRUM-1264 |
| Al menos un recorrido E2E en QA con sus APIs y datos | Cumplido por API | Recorrido completo por API con datos de QA, aprobado el 20 y el 21 de octubre. El recorrido desde Flutter Web ya no está bloqueado y no se ha implementado (L-04) |
| Informe de defectos priorizados | Cumplido | 10 defectos con severidad, prioridad, reproducción, resultado esperado y observado; los 5 que bloqueaban la aprobación se registraron en Jira y 4 se corrigieron y 1 se mitigó en QA el 21 de octubre |
| Resultados presentados a Camila (PO) | Pendiente | |
| SCRUM-1277: colección versionada, workflow de CI, casos ejecutados, evidencia por historia, gate comprobable | Parcial | Colección versionada, colección corregida ejecutada en QA (`20261020T224842Z`) y gate de CI ejecutado desde el runner de Calidad, en rojo por R-01 a R-03 ([run 39513870492](https://github.com/Trama-AS/MANI-APIGateway/actions/runs/39513870492)). El 21 de octubre la regresión en la VM de QA da 0 fallas; falta la corrida en verde en CI y siguen abiertos los casos PENDIENTE del contrato |
| SCRUM-1278: suite reproducible, ejecución de CI contra QA, evidencias asociadas a historias, registro de errores | Parcial | Suite con lockfile ejecutada en CI contra QA ([run 39513870492](https://github.com/Trama-AS/MANI-APIGateway/actions/runs/39513870492): 11 pruebas, 9 aprobadas; FW-02 y FW-03 por R-04). El 21 de octubre, 11 de 11 en la VM de QA. Faltan los flujos Flutter Web → Gateway → servicios, ya no bloqueados |
| SCRUM-1279: matriz aprobado, fallido, bloqueado o no ejecutable y validación de la PO | Parcial | 10 de 90 casos cross-tenant aplicables ejecutados y aprobados, 5 bloqueados y 75 sin ejecutar; RLS no ejercido (con evidencia versionada); validación de la PO pendiente |

## 16. Cambios frente a la versión anterior de este reporte

- El estado "Parcial" se reemplazó por el vocabulario de SCRUM-1267 y SCRUM-1279.
- Ninguna historia queda en Aprobado: SCRUM-1070 y SCRUM-1073 pasaron a Ejecutado (cobertura parcial y token de prueba) y SCRUM-1335 también, porque CA-3 a CA-7 no se verificaron.
- La cobertura se mide contra los casos de SCRUM-1264 caso a caso, como exige el DoD de QA, en lugar de contar casos ejecutados. La causa de la cobertura incompleta se atribuyó a QA en lugar de a la interfaz.
- Se agregaron R-10 (H-02 de SCRUM-1266) y R-11 (formato de error de Dispatch), y los defectos siguen el formato de propuestas de SCRUM-1266.

Actualización del 20 de octubre, con la colección corregida ejecutada en QA:

- Corridas nuevas: Newman `20261020T224842Z` (77 solicitudes, 125 aserciones, 5 fallidas en los mismos 4 casos) y Playwright `20261020T224932Z` (11 pruebas, 9 aprobadas). La evidencia anterior se conserva.
- 1063-01 pasa de No válido a Aprobado (US0212M2-N1, parcial): SCRUM-1063 sigue en Ejecutado y ya no tiene casos que no cuentan.
- 856-00 y 856-06 se ejecutaron y aprueban; 856-03 se confirma con `LEGAL_DOCUMENT_NOT_FOUND`; 856-02 sigue no concluyente, y su causa queda documentada en `consentimiento_previo_856_20261020T200914Z.json`.
- Cobertura de SCRUM-1264: de 20 completos y 21 parciales a 20 completos y 22 parciales. Ningún estado de historia cambia.
- R-06, R-07 y R-09 tienen evidencia versionada. R-06 se corrige a 15 políticas `tenant_isolation_*` (18 con `TO public` en total). R-09 queda comprobado para Core y Dispatch: ambos se conectan como `postgres` con BYPASSRLS. Un primer intento con la cadena de Dispatch falló porque QA interpretó mal las comillas de la cadena Npgsql, no por la credencial; Dispatch sí accede a la base (1074-01 asigna la solicitud) y la consulta repetida con la cadena bien interpretada está en `dispatch_rol_20261020T232719Z.txt`.
- L-10 se cierra.

Actualización del 20 de octubre, gate de CI:

- QA habilitó el gate en MANI-APIGateway (environment `qa-regresion`, secreto `QA_JWT_SECRET` y variables `QA_*`) y lo ejecutó desde el runner `nbig02-calidad` ([run 39513870492](https://github.com/Trama-AS/MANI-APIGateway/actions/runs/39513870492)). Newman `20261020T234635Z` y Playwright `20261020T235520Z` dan el mismo resultado que en la VM de QA; los dos jobs quedan en rojo por R-01 a R-04. El log público y los artefactos se revisaron sin hallar credenciales.
- L-02 se cierra y L-08 se actualiza. Evidencia: `newman_resumen_ci_20261020T234635Z.json` y `playwright_resultados_ci_20261020T235520Z.json`.
- R-01 a R-04 y R-10 se registraron en Jira como SCRUM-1358 a SCRUM-1362, con su historia, el PR que introdujo cada cambio y la corrección propuesta.

Actualización del 21 de octubre, validación de las correcciones:

- Los defectos registrados en Jira se corrigieron y se promovieron a `release`: R-01 (MANI-APIGateway#20), R-02 (MANI-Node#50 y MANI-.NET#11), R-03 (MANI-Node#49) y R-10 (MANI-Node#52 y MANI-.NET#13), todos con pruebas y CI en verde. QA se redesplegó con la cabeza de `release` en los seis servicios, y `develop` no tiene cambios que falten en `release`.
- R-04 se mitigó en QA montando `flutter.env.qa` en el contenedor `flutter-web`; la corrección en MANI-Flutter sigue pendiente.
- Corridas nuevas desde `release`: Newman `20261021T161015Z` (77 solicitudes, 125 aserciones, 0 fallidas) y Playwright `20261021T170129Z` (11 de 11). Login real con ES256 verificado y tokens ES256 falsificados rechazados.
- Estados: 853, 856 y 1066 pasan de Fallido a Ejecutado y 1060 de Bloqueado a Sin ejecutar. Multi-tenant: el X6 de 1066 pasa de bloqueado a sin ejecutar. La cobertura de SCRUM-1264 no cambia.
- R-06, R-07, R-09 y R-11 se reverificaron sin cambios. L-01, L-04, L-05, L-08 y L-09 se actualizan, y los pendientes se reordenan.
- Correcciones de inconsistencias: la línea de `legal.routes.js` en R-01 es la 8 (no la 7) y la restricción de R-02 está en las líneas 45 a 51 de `GetSiteRulesForAllyUseCase.js` (no en la 8). El DoD de defectos pasa de "Cumplido como propuesta" a "Cumplido", y la discrepancia de SCRUM-1277 y SCRUM-1278 ya no dice "sin PR fusionado".

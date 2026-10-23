# TD — Documento de pruebas de MANI

| Campo | Valor |
|---|---|
| Versión | V2 (Sprint 4) |
| Tarea | SCRUM-1250 (DOC4-07): plan de pruebas, resultados QA, criterios DoD y evidencia |
| Responsable | Santiago Hernández (QA) |
| Fecha de corte | 21 de octubre de 2026 |
| Estado | Borrador para revisión de la Scrum Master y aceptación de la PO |
| Documento vivo | La versión vigente es la de `main`. Los umbrales de calidad no se definen aquí: viven en el [SDD](../architecture/SDD.md) §7 y §8 y en [ADR-0005](../adr/ADR-0005-devsecops.md) |

## Historial de versiones

| Versión | Momento | Contenido |
|---|---|---|
| V1 | Sprint 2 y Sprint 3 | Informe de pruebas del Sprint 2 ([`Entregas/Entrega4/Inf_test-001.md`](../Entregas/Entrega4/Inf_test-001.md), SCRUM-953) y plan de pruebas de paridad de las historias migradas de EP-02 ([`qa/PLAN_PRUEBAS_EP-02_MIGRACION.md`](../qa/PLAN_PRUEBAS_EP-02_MIGRACION.md), DOC-38, SCRUM-1094). |
| V2 | Sprint 4, 21 de octubre de 2026 | Reúne en un solo documento la estrategia de pruebas con la cadena de calidad operativa (SonarQube, Newman, Playwright y gate de CI), el plan de pruebas del Sprint 4 (SCRUM-1264), los resultados de QA del sprint (SCRUM-1265, SCRUM-1266, SCRUM-1267 y SCRUM-1279), los criterios DoD con su grado de cumplimiento y el índice de evidencia. Corrige la numeración de los QAS en la tabla de añadidos del DoD. |

Los documentos de V1 se conservan: el plan de EP-02 sigue siendo el detalle de la paridad de esas historias y este documento lo referencia.

## 1. Propósito y alcance

Este documento describe cómo se prueba MANI, qué se planeó probar en el Sprint 4, qué resultados obtuvo QA y qué criterios de terminado se cumplen con evidencia. Cubre los seis repositorios del producto (MANI-APIGateway, MANI-Node, MANI-Java, MANI-.NET, MANI-Flutter y MANI-Landing) y el ambiente de QA (`10.43.100.141`, rama `release`, base Supabase MANI-QA).

Regla que aplica en todo el documento: una historia no se considera aprobada por su estado en Jira, sino por la ejecución en QA con evidencia versionada. Un escenario cuya herramienta o dependencia no está disponible se reporta como bloqueado o no medible, nunca como cumplido.

## 2. Estrategia de pruebas

### 2.1 Niveles y herramientas

| Nivel | Qué verifica | Herramienta | Dónde corre |
|---|---|---|---|
| Unitarias y de integración del servicio | Lógica de cada servicio con sus dobles de prueba | `node --test` con supertest (Core), `spring-boot-starter-test` con JUnit (Rules), xUnit (Dispatch), `flutter test` (Flutter) | CI de cada repositorio (`Pruebas y cobertura`) |
| Análisis estático y cobertura | Calidad del código nuevo con el gate de ADR-0005 | SonarQube Community Build 26.10 (`10.43.98.196:9000`); SonarCloud para Flutter | Job `Sonar Quality Gate` en el runner `nbig02-calidad`; CI de Flutter |
| Contrato de API | Que el Gateway y los servicios cumplen el OpenAPI publicado | Newman con las colecciones de `postman/` de MANI-APIGateway | CI del Gateway, contra servicios levantados en el job |
| Regresión funcional, API y multi-tenant en QA | Comportamiento integrado Gateway, Core, Rules y Dispatch con datos de MANI-QA y varios tenants | Newman con `qa/newman/` de MANI-APIGateway | VM de QA y gate `qa-regresion.yml` en el runner de Calidad |
| E2E e interfaz | Recorrido de la solicitud por API, landing y configuración de Flutter Web | Playwright con `qa/playwright/` de MANI-APIGateway | VM de QA y gate `qa-regresion.yml` |
| Escenarios de calidad | QAS-01 a QAS-09 del SDD §8 | k6, Newman e inspección | Runner de Calidad ([SCRUM-1266](https://maniservices.atlassian.net/browse/SCRUM-1266)) |
| Defensa en la base | RLS y roles de servicio | Consultas de catálogo de solo lectura y `db/verify/` de Core | VM de QA contra MANI-QA |

La configuración de la cadena de calidad está en la [guía operativa CFG4-03](../qa/GUIA_OPERATIVA_CALIDAD_QA_CFG4-03.md) y la del gate de regresión en `qa/README.md` de MANI-APIGateway.

### 2.2 Datos, identidad y aislamiento

- **Datos:** tenants de prueba `acme-servicios` (t1) y `nova-mantenimiento` (t2) de `supabase/seed/seed_qa_multitenant.sql` (MANI-APIGateway). Cada corrida de la regresión crea datos marcados `QA <corrida>`.
- **Identidad:** la regresión usa tokens HS256 sintéticos firmados en el ambiente con el secreto legado de MANI-QA. Desde el 21 de octubre los usuarios reales también usan las rutas protegidas con tokens ES256 de Supabase Auth (sección 4.5).
- **Aislamiento multi-tenant:** los seis casos B1 a B6 de [ADR-0015](../adr/ADR-0015-pruebas-aislamiento-multitenant.md) se aplican por historia como X1 a X6 (DoD, sección 5).

### 2.3 Gates

| Gate | Condición | Bloquea el merge |
|---|---|---|
| Sonar Quality Gate (`MANI ADR-0005`) | Violaciones nuevas = 0, cobertura del código nuevo ≥ 80 %, duplicación del código nuevo ≤ 3 %, hotspots nuevos revisados al 100 % | Sí: es el check obligatorio de `develop`, `release` y `main` en MANI-APIGateway |
| Contrato Newman y OpenAPI | Colecciones de contrato y validación del OpenAPI | Según el repositorio |
| Regresión en QA (`qa-regresion.yml`) | Ninguna aserción fallida en Newman y Playwright; cada job espera la aprobación del revisor del environment `qa-regresion` | No |

## 3. Plan de pruebas del Sprint 4

El plan del sprint es la matriz [`../qa/MANI_Matriz_Pruebas_Sprint4.xlsx`](../qa/MANI_Matriz_Pruebas_Sprint4.xlsx) (SCRUM-1264), derivada de los criterios de aceptación de SCRUM-1257 ([`../backlog/CRITERIOS_ACEPTACION_SPRINT4.md`](../backlog/CRITERIOS_ACEPTACION_SPRINT4.md)).

| Dimensión | Valor |
|---|---|
| Historias con casos diseñados | 17 |
| Casos diseñados | 228 (200 de prioridad Alta y 28 de prioridad Media) |
| Herramienta prevista | Newman 174, Playwright 21, otras 33 (integración nativa, SQL, revisión estática, pruebas de Flutter, k6 o manual) |
| Tipo | Multi-tenant 81, positivos 32, regresión 29, seguridad 23, negativos 21, roles 12, errores 8, E2E 7, integración 6, contrato 4, concurrencia 4, rendimiento 1 |
| Casos cross-tenant aplicables (X1 a X6) | 90 |

Las historias priorizadas del sprint son 27: las 24 con subtarea "QA - Validar US" y SCRUM-1063, SCRUM-1066 y SCRUM-1068. Siete de ellas (SCRUM-865, 867, 868, 869, 870, 879 y 1335) tienen subtarea QA pero no tienen casos en SCRUM-1264.

## 4. Resultados QA del Sprint 4

### 4.1 Calidad estática

Consulta del 21 de octubre a SonarQube y SonarCloud ([`qa/td_v2/evidencia/sonar_20261021.json`](../qa/td_v2/evidencia/sonar_20261021.json)):

| Repositorio | Gate | Cobertura total | Duplicación total | Vulnerabilidades abiertas | Último análisis |
|---|---|---|---|---|---|
| MANI-APIGateway | OK | sin dato (no hay pruebas que reporten cobertura) | 0,0 % | 1 MINOR | 21 oct, `fc08a33` |
| MANI-Node (Core) | OK | 90,1 % | 1,4 % | 4 MAJOR | 21 oct, `8e198ff` |
| MANI-.NET (Dispatch) | OK | 84,5 % | 8,7 % | 1 MAJOR y 1 MINOR | 21 oct, `a0a18e1` |
| MANI-Java (Rules) | OK | 92,3 % | 0,0 % | 0 | 20 oct, `9f7ab3c` |
| MANI-Landing | OK | 100 % | 1,0 % | 0 | 20 oct, `f79e55b` |
| MANI-Flutter (SonarCloud) | OK | 83,2 % | 13,4 % | 0 | 21 oct, `6b805e2` |

Observaciones:

- El gate mide el código nuevo. Por eso pasa con vulnerabilidades y duplicación que ya existían: en Core, los límites de tamaño de `auth.routes.js` (líneas 28 y 34) y dos generadores aleatorios en repositorios en memoria; en Dispatch, la política CORS abierta de `Program.cs:24`; en Gateway y Dispatch, las imágenes que corren como root.
- En MANI-APIGateway no hay dato de cobertura, así que Sonar omite la condición de cobertura del gate.
- El gate de SonarCloud para Flutter evalúa las calificaciones de fiabilidad, seguridad y mantenibilidad del código nuevo y la revisión de hotspots, no las condiciones de `MANI ADR-0005`. La duplicación total de Flutter (13,4 %) supera el 3 % de ADR-0005, aunque ese umbral aplica al código nuevo.
- El Quality Gate del Gateway detectó el 20 de octubre dos contraseñas de prueba escritas en el generador de la regresión (S2068); se corrigió en MANI-APIGateway#18 antes del merge.

### 4.2 Regresión funcional, API y E2E en QA (SCRUM-1267)

Reporte completo: [`../qa/REPORTE_QA_REGRESION_SCRUM-1267.md`](../qa/REPORTE_QA_REGRESION_SCRUM-1267.md) y matriz de ejecución [`../qa/MANI_Matriz_Ejecucion_Sprint4.xlsx`](../qa/MANI_Matriz_Ejecucion_Sprint4.xlsx). El estado al 21 de octubre está en MANI-docs#60.

| Corrida | Newman | Playwright |
|---|---|---|
| 20 de octubre, colección corregida (`20261020T224842Z` y `20261020T224932Z`) | 77 solicitudes, 125 aserciones, 5 fallidas en 4 casos (853-04, 856-05, 1066-01 y 1066-02) | 11 pruebas, 9 aprobadas (FW-02 y FW-03 fallan) |
| 20 de octubre, gate de CI desde el runner de Calidad ([run 39513870492](https://github.com/Trama-AS/MANI-APIGateway/actions/runs/39513870492)) | Mismo resultado | Mismo resultado |
| 21 de octubre, tras las correcciones (`20261021T161015Z` y `20261021T170129Z`) | 77 solicitudes, 125 aserciones, **0 fallidas** | **11 de 11** |

Estado de las 27 historias al 21 de octubre:

| Estado QA | Historias |
|---|---|
| Aprobado | 0 |
| Ejecutado | 16: SCRUM-850, 852, 853, 854, 855, 856, 858, 861, 862, 1063, 1066, 1070, 1072, 1073, 1074 y 1335 |
| Fallido | 0 (853, 856 y 1066 lo estaban el 20 de octubre) |
| Bloqueado | 4: SCRUM-866, 874, 875 y 1068 |
| Sin ejecutar | 1: SCRUM-1060 (ya no la bloquea nada y QA no ha ejecutado sus casos) |
| No disponible | 6: SCRUM-865, 867, 868, 869, 870 y 879 |

Ninguna historia llega a Aprobado porque la cobertura de los casos diseñados es incompleta:

| Cobertura de SCRUM-1264 | Completos | Parciales | Sin ejecutar |
|---|---|---|---|
| Todos los casos (228) | 20 | 22 | 186 |
| Casos de prioridad Alta (200) | 13 | 19 | 168 |
| Casos previstos con Newman (174) | 20 | 22 | 132 |
| Casos previstos con Playwright (21) | 0 | 0 | 21 |
| Casos previstos con otras herramientas (33) | 0 | 0 | 33 |

El recorrido E2E por API —crear solicitud (SCRUM-1072), aliados elegibles (861/862), despacho (1073) y aceptación (1074), con control cross-tenant— aprueba sus cinco pasos con datos de QA. El recorrido desde la interfaz de Flutter Web no está implementado en la suite.

### 4.3 Regresión multi-tenant (SCRUM-1279)

Los seis casos B1 a B6 se ejecutan por el Gateway con los tenants t1 y t2 y todos los accesos cruzados se rechazan. Por historia, de los 90 casos cross-tenant aplicables: **10 aprobados** (2 de forma parcial), **5 bloqueados** (SCRUM-1068) y **75 sin ejecutar**. Ninguna historia cumple todavía el añadido del DoD de los seis casos cross-tenant.

La defensa en la base no se ejerce en QA: Core y Dispatch se conectan como `postgres` con BYPASSRLS (R-09), quedan 15 políticas `tenant_isolation_*` con `TO public` (R-06) y `poc_asignacion_log` tiene RLS sin FORCE (R-07). El aislamiento comprobado es el de la aplicación.

### 4.4 Escenarios de calidad QAS-01 a QAS-09 (SCRUM-1266)

Estado medido por [SCRUM-1266](../qa/REPORTE_QA_MONITOREO_QAS_SCRUM-1266.md) el 19 y 20 de octubre, cuando Core, Rules y Dispatch de QA eran todavía stubs, y cambios verificados después:

| QAS | Atributo (SDD §8) | Estado en SCRUM-1266 | Cambio verificado después |
|---|---|---|---|
| 01 | Seguridad, confidencialidad | No cumple: `dev-token` público (H-01) y tokens reales rechazados (H-02); casos 1 a 4 y 6 bloqueados | H-01 ya no se reproduce (`dev-token` responde 404, caso PER-05). H-02 corregido el 21 de octubre (R-10). B1 a B6 aprueban por el Gateway. Pendiente: 75 casos X sin ejecutar y RLS no ejercido |
| 02 | Fiabilidad, tolerancia a fallos | Bloqueado: no hay componente de notificaciones en QA | Sin cambio |
| 03 | Eficiencia, comportamiento temporal | Bloqueado: p95 de 12,4 ms con 300 sesiones y 50 req/s, medido sobre el stub de Dispatch | Dispatch real desplegado; la medición no se repitió |
| 04 | Mantenibilidad, modificabilidad | No medible | Sin cambio |
| 05 | Flexibilidad, escalabilidad | No medible: QA corre en Docker Compose, sin Kubernetes | Sin cambio |
| 06 | Compatibilidad, interoperabilidad | No cumple: 1 de 12 operaciones publicadas con contrato OpenAPI | MANI-APIGateway#20 agregó la ruta pública de documentos legales al contrato; la medición no se repitió |
| 07 | Adecuación funcional, corrección | Bloqueado: el stub guardaba la asignación en memoria | La aceptación idempotente y el rechazo cross-tenant aprueban contra Dispatch real (1074-01 a 1074-04). La aceptación concurrente no se ejecutó: la solicitud de PoC está reservada para el arnés de QAS-07 |
| 08 | Capacidad de interacción | Bloqueado o no medible | Sin cambio |
| 09 | Safety, protección ante fallos | Bloqueado | Sin cambio |

### 4.5 Defectos del Sprint 4

| Id | Jira | Hallazgo | Estado al 21 de octubre | Corrección y verificación |
|---|---|---|---|---|
| R-01 | [SCRUM-1359](https://maniservices.atlassian.net/browse/SCRUM-1359) | El Gateway exigía token en `GET /legal/documents/active` | Corregido y verificado | MANI-APIGateway#20 y #21; 856-05 en 200 |
| R-02 | [SCRUM-1358](https://maniservices.atlassian.net/browse/SCRUM-1358) | El aliado asignado recibía 403 al leer las reglas del sitio | Corregido y verificado | MANI-Node#50 y MANI-.NET#11; 853-04 en 200 |
| R-03 | [SCRUM-1360](https://maniservices.atlassian.net/browse/SCRUM-1360) | La verificación KYC respondía 500 por `documento_kyc.created_at` | Corregido y verificado | MANI-Node#49; 1066-01 y 1066-02 en 200 |
| R-10 | [SCRUM-1362](https://maniservices.atlassian.net/browse/SCRUM-1362) | `validate-token` solo aceptaba HS256 y Supabase emite ES256 | Corregido y verificado | MANI-Node#52 y MANI-.NET#13; login real con 200 y tokens falsificados con 401. ADR-0031 en MANI-docs#59, abierto |
| R-04 | [SCRUM-1361](https://maniservices.atlassian.net/browse/SCRUM-1361) | Flutter de QA construido con `.env.example` | Mitigado en QA; corrección del repositorio pendiente | Montaje manual de `flutter.env.qa`; FW-02 y FW-03 aprueban |
| R-06, R-07, R-09 | Propuestos | RLS no ejercido en QA | Abiertos | Reverificados sin cambios el 21 de octubre |
| R-08 | Propuesto | Compose y despliegue de QA sin versionar | Abierto | Se le sumó el montaje de R-04 |
| R-11 | Propuesto | Las respuestas de error de Dispatch no tienen `code` (criterio T5) | Abierto | 862-02 y 1074-04 sin cambio |

## 5. Criterios DoD y su cumplimiento

### 5.1 Criterios vigentes

El DoD lo decide QA ([GOBIERNO_DEL_EQUIPO](../governance/GOBIERNO_DEL_EQUIPO.md) §2.3) y vive en [`wiki/05-proceso/dor-y-dod.md`](../wiki/05-proceso/dor-y-dod.md). Con esta versión del TD, esa página:

- corrige la numeración de los QAS en la tabla de añadidos según el SDD §8: la doble asignación es QAS-07 (decía QAS-02), las reglas sin despliegue QAS-04 (decía QAS-05) y los fallos de notificación QAS-02 (decía QAS-04);
- incorpora las decisiones de QA de [`../backlog/CRITERIOS_ACEPTACION_SPRINT4.md`](../backlog/CRITERIOS_ACEPTACION_SPRINT4.md) §4, pendientes de llevar a la wiki: las filas "Datos o reglas de otro servicio" y "Esquema o tablas" y la evidencia exigida (IDs de casos de la matriz del sprint en la subtarea QA y resultado local de `flutter analyze` y `flutter test` en Flutter).

### 5.2 Gates de ADR-0005

| Gate mínimo para release | Resultado al 21 de octubre | Estado |
|---|---|---|
| 0 vulnerabilidades Blocker/Critical | Ninguna Blocker ni Critical abierta en los seis repositorios (5 MAJOR y 2 MINOR) | Cumple |
| 0 vulnerabilidades High conocidas abiertas en producción | Producción no se evaluó en este sprint | No medido |
| Cobertura del código nuevo ≥ 80 % | Gates de Sonar en verde. En MANI-APIGateway la condición no se evalúa por falta de dato; el gate de Flutter en SonarCloud no la incluye | Cumple con salvedades |
| Cobertura de casos críticos ≥ 90 % | 13 de 200 casos de prioridad Alta cubiertos de forma completa (6,5 %) y 19 de forma parcial | No cumple |
| Duplicación del código nuevo < 3 % | Gates de Sonar en verde | Cumple |
| DAST con OWASP ZAP en QA | No ejecutado (QA-05, SCRUM-1122) | No medido |

### 5.3 DoD de las historias del Sprint 4

| Criterio del DoD | Resultado |
|---|---|
| Cambios integrados mediante PR, con revisión y CI en verde | No verificado historia por historia en este documento. La relación historia–repositorio–PR está en [`../backlog/MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md`](../backlog/MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md) (SCRUM-1256). Las correcciones del 21 de octubre (sección 4.5) entraron por PR con pruebas y CI en verde |
| QA ejecutó o validó las pruebas requeridas | Parcial: 16 historias ejecutadas, ninguna con la cobertura completa de sus casos de SCRUM-1264 |
| No existen defectos que impidan la entrega | Se cumple al 21 de octubre para los defectos de la regresión (4 corregidos y 1 mitigado); quedan abiertos R-06 a R-09 y R-11, que no hacen fallar ningún caso |
| Seis casos cross-tenant por historia que toca tenant | No se cumple en ninguna historia (10 de 90 aprobados) |
| Evidencia en la subtarea QA con IDs de casos de SCRUM-1264 | Comentario registrado el 20 de octubre en las 14 subtareas de historias con ejecución; SCRUM-1063, 1066 y 1068 no tienen subtarea QA (PE4 de SCRUM-1257) |
| Aceptación funcional del PO | Pendiente: los resultados no se han presentado a la PO |

## 6. Evidencia

| Evidencia | Ubicación |
|---|---|
| Plan de pruebas del Sprint 4 | [`qa/MANI_Matriz_Pruebas_Sprint4.xlsx`](../qa/MANI_Matriz_Pruebas_Sprint4.xlsx) (SCRUM-1264) |
| Criterios de aceptación y DoD del Sprint 4 | [`backlog/CRITERIOS_ACEPTACION_SPRINT4.md`](../backlog/CRITERIOS_ACEPTACION_SPRINT4.md) (SCRUM-1257) |
| Matriz y reporte de la regresión | [`qa/MANI_Matriz_Ejecucion_Sprint4.xlsx`](../qa/MANI_Matriz_Ejecucion_Sprint4.xlsx) y [`qa/REPORTE_QA_REGRESION_SCRUM-1267.md`](../qa/REPORTE_QA_REGRESION_SCRUM-1267.md) |
| Corridas redactadas de Newman y Playwright, consultas de RLS y login real | [`qa/regresion_sprint4/evidencia/`](../qa/regresion_sprint4/evidencia/), con la validación del 21 de octubre en `20261021_validacion/` |
| Escenarios de calidad, k6 y monitoreo | [`qa/REPORTE_QA_MONITOREO_QAS_SCRUM-1266.md`](../qa/REPORTE_QA_MONITOREO_QAS_SCRUM-1266.md) y [`qa/monitoreo_qas/`](../qa/monitoreo_qas/) |
| Calidad estática | [`qa/td_v2/evidencia/sonar_20261021.json`](../qa/td_v2/evidencia/sonar_20261021.json) |
| Cadena de calidad (SonarQube, runners) | [`qa/GUIA_OPERATIVA_CALIDAD_QA_CFG4-03.md`](../qa/GUIA_OPERATIVA_CALIDAD_QA_CFG4-03.md) |
| Suites de regresión y gate de CI | MANI-APIGateway `qa/` y `.github/workflows/qa-regresion.yml` (MANI-APIGateway#18 y #19) |
| Defectos | SCRUM-1358 a SCRUM-1362 en Jira |

## 7. Trazabilidad con el backlog y la arquitectura

| Fuente | Relación con este documento | Observación |
|---|---|---|
| [Backlog V5](../backlog/BACKLOG_MANI.md) §0.1 y §0.6 (SCRUM-1245) | Estado real de los servicios al cierre del Sprint 4 y compromiso de terminar la regresión antes del Sprint 5 | El §0.1 marca SCRUM-1060 como "Verificado por QA" porque su subtarea está en Finalizada, pero la regresión no ejecutó ningún caso de esa historia. Las otras historias de esa columna están en Ejecutado, no en Aprobado. Corresponde a la PO decidir el ajuste |
| [SDD](../architecture/SDD.md) §7 y §8 | Umbrales y escenarios QAS-01 a QAS-09 (sección 4.4) | La nota de estado del §8 tiene corte del 6 de octubre: dice que ninguna herramienta de QA está entregada y remite al plan de EP-02. SonarQube, Newman y Playwright ya operan; conviene actualizarla para que remita a este documento |
| [ADR-0005](../adr/ADR-0005-devsecops.md) | Gates mínimos (sección 5.2) | Cobertura de casos críticos sin cumplir |
| [ADR-0012](../adr/ADR-0012-persistencia-multitenant.md), [ADR-0015](../adr/ADR-0015-pruebas-aislamiento-multitenant.md) y [ADR-0018](../adr/ADR-0018-identificacion-tenant.md) | Aislamiento multi-tenant e identificación del tenant (secciones 4.3 y 5.1) | RLS no ejercido en QA (R-06, R-07 y R-09) |
| [ADR-0031](../adr/ADR-0031-politica-configuracion-jwt-ambientes.md) | Política JWT por ambiente | La corrección de R-10 (ES256) está en `release` y el cambio del ADR está en revisión (MANI-docs#59) |

## 8. Brechas y pendientes

1. Ampliar la regresión a los casos de SCRUM-1264 sin ejecutar, empezando por los 75 casos cross-tenant y los 21 previstos con Playwright, y ejecutar SCRUM-1060.
2. Implementar en Playwright los flujos Flutter Web → Gateway → servicios.
3. Pasar la regresión a usuarios reales de Supabase Auth y decidir con DevOps la revocación de la clave HS256 legada.
4. Ejecutar el gate de CI en verde tras las correcciones del 21 de octubre.
5. Repetir QAS-03 y QAS-06 con los servicios reales y ejecutar la aceptación concurrente de QAS-07 con una solicitud propia de la regresión.
6. Corregir R-04 en MANI-Flutter, versionar el compose de QA (R-08) y atender R-06, R-07, R-09 y R-11.
7. Recopilar la evidencia de pruebas nativas aportada por Desarrollo para los casos de SCRUM-1264 previstos con otras herramientas.
8. Actualizar la nota de estado del SDD §8 y el §0.1 del Backlog V5 (decisión de sus responsables).
9. Presentar los resultados a la PO y obtener su aceptación.

## 9. Revisión y aceptación

| Rol | Persona | Estado |
|---|---|---|
| Elabora | Santiago Hernández (QA) | Completo |
| Revisa | Sara Albarracín (Scrum Master) | Pendiente |
| Acepta | Camila Beltrán (PO) | Pendiente |

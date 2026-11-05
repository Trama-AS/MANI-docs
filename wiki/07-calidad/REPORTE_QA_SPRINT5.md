# Reporte de QA del Sprint 5, corte 2

| Campo | Valor |
|---|---|
| Sprint | Sprint 5, cierre del MVP |
| Responsable | Santiago Hernández (QA) |
| Fecha de corte | 5 de noviembre de 2026 |
| Ambiente | QA `10.43.100.141`, Supabase `MANI-QA` |
| Estado | Para revisión de la Scrum Master |
| Evidencia | Las salidas de los lotes (`qa_s5_corte2/`, `reg_*`) quedan en el equipo de QA; no se publican en este documento |


Estado al 5 nov de 2026. **Pruebas por API repetidas con los roles nuevos, sin fallas nuevas. Flujo en la app probado a mano por el equipo: lo previsto para el sprint funciona, salvo las 4 fallas de abajo.** QA se queda en la versión actual por decisión de Santiago, sin desplegar `release`.

## Estado actual

**Versión en QA** (leída en los lotes): Core `cfa503a`, Dispatch `930a15b`, Gateway `ecd9ec2`, Flutter `46bee9a`; Core conecta como `mani_core_svc` y Dispatch como `mani_dispatch_svc`. Las cabezas de `release` (Node `98506f7`, .NET `746c451`, Gateway `edc3c97`, Flutter `f62f241`) traen 901 (contexto de plataforma), 1418 (puntaje privado) y 1453, que no se pueden comprobar en QA. **Estas pruebas confirman QA, no lo promovido a `main`.**

**Corrida con roles nuevos (5 nov, 22:49Z a 23:21Z).** Salidas `*_05nov_2249z`, `*_05nov_2304z`, `reg_*_05nov_2308z` y `diag_1392_1396_1462_05nov_2321z`.

| Lote | Pasan | Fallan | Lectura |
|---|---|---|---|
| humo | 26 | 2 | Geometrías: el chequeo manda lista vacía porque no lee bien las zonas. Error de prueba. |
| lote_a_b | 33 | 3 | 1392 C1 sin explicar. 1396 por tomar los primeros 20 barrios: error de prueba. |
| lote_c | 38 | 1 | 1462 C2: los aliados sin calificaciones no tienen puntaje; razones 51 de 51. Chequeo mal planteado. |
| lote_d_g | 122 | 8 | Mismos casos que a las 05:41Z. |
| lote_f3 | 81 | 4 | 892 C1 real. 1386 y 1369 son errores de prueba; `lote_limpieza` pasa. |
| lote_limpieza | 8 | 0 | |
| lote_comision (repetido) | 29 | 0 | La primera vez (25/4) falló por la ausencia que deja `lote_f3` en aliado.t1. |
| lote_decimales | 6 | 0 | |
| Regresión, 13 lotes | 461 | 23 | Ningún caso nuevo frente a las 05:23Z. Mejoran lote1 (de 68/6 a 70/4), lote2 (de 41/11 a 48/4) y lote7c (de 0/1 a 2/0). Las fallas repetidas no se revisaron una por una hoy. |
| Diagnóstico 1450 | 2 | 0 | Directo como `mani_dispatch_svc`, con ROLLBACK. |

**Resultados que cambian algo**

- **892 sigue fallando:** pago hecho tras finalizar queda RETENIDA y no se libera por ese camino. Está en Finalizada.
- **1468 pasa:** roles propios y 0 políticas `TO public`.
- **1450 pasa:** C1 y C3. Finalizada el 5 nov con la subtarea 1558.
- **893 y 1366 pasan** con `mani_core_svc`: liquidación con 12 % y 10 %, y la anterior conserva su 12 %.
- **1378 pasa:** 3 respuestas 202 idénticas, sin el 500.
- **1396:** por API, 20 de 20 localidades y 1.229 de 1.233 barrios con límite, sin geometrías inválidas. Alguien las cargó; no fue este corte. MANI-Flutter#131 sigue abierto: sin él, falta ver si el mapa de QA carga con más de 20 zonas.
- **1462:** el ranking por COBERTURA dio a,b,c donde se esperaba a,c,b y el lote lo marca PASA: sigue por revisar. `/rank-allies` da 400 y `/evaluate-rate` 404 en `lote1`, igual que antes.
- **1383 sigue:** 68 de 68 documentos y 27 de 27 teléfonos en claro.

## Prueba manual del flujo

Santiago informó el 5 nov que el equipo recorrió el flujo en la app y que lo previsto para el sprint funciona, salvo lo siguiente. Este informe no guarda salidas de esa prueba: el resultado es el que reporta el equipo.

| Bug | Falla | Qué pasa | Evidencia por API | Lectura sin confirmar |
|---|---|---|---|---|
| SCRUM-1634 | Foto de perfil | Cambiar la imagen no funciona en la app. | 1628 y 1629 pasan: PNG válido 200 y foto en el perfil, límites 413. | Si la API responde, apunta a la pantalla. |
| SCRUM-1635 | Aliados por solicitud | Ver los aliados de una solicitud no funciona en la app. | 1401 pasa: `eligible-allies` 200 con 51 aliados y ranking. | Si la API responde, apunta a la pantalla. |
| SCRUM-1636 | Estado en vivo | Las actualizaciones de estado no llegan en vivo; hay que recargar la página. | Sin chequeo: los lotes no prueban actualización en vivo. | En Flutter hay suscripción en la lista del aliado, chat y eventos; falta revisar el resto. |
| SCRUM-1637 | Clientes y tenant | Los clientes quedan asociados a un tenant, y eso está mal. | Sin chequeo: los lotes parten de ese modelo y comprueban aislamiento por tenant. | Es cambio de modelo, con efecto en RLS, cuentas y aislamiento. Requiere decisión del equipo y ADR. |

Por decisión de Santiago, lo que falla se abre como bug en vez de reabrir la historia. Además de estos 4, SCRUM-1633 recoge la falla medida de 892 (pago tras finalizar queda RETENIDA). Los 5 están en Por hacer, sin asignar y sin sprint. 892 sigue en Finalizada.

"Funciona" es el resultado reportado para el flujo y no cancela lo medido por API: 892 sigue fallando (SCRUM-1633) y 1383 sigue con datos en claro (Reabierta).


## Qué falta ejecutar

| # | Prueba | Quién |
|---|---|---|
| 1 | Repetir las 4 fallas de la prueba manual cuando se corrijan | Equipo |
| 2 | 1392: qué categoría da 422 al guardar la misma selección (`diag_1392_1396_1462_qa.sh`, ya corregido) | Santiago escribe las claves |
| 3 | Remedir carga QAS-03, 15 y 19 | Requiere ajustar el pool de Core y aprobar k6 |

No se puede resolver con pruebas: 1383 (cambio de código), 901 C1 (sin PLATFORM_ADMIN en QA), 1418 y 1453 (corrección fuera de QA), 1396 (MANI-Flutter#131), 1236 (Kafka, Daniel) y 1470 (PO).

No se repite `lote3` (inserta aliados por SQL, aprobado solo el 31 oct) ni `lote_ajustes` (detiene Rules y Dispatch), salvo aprobación nueva.

## Resumen de Jira

Lectura del 5 nov, 23:30Z, de las 75 historias de este informe: 70 Finalizada, 4 En revisión (901, 1396, 1418, 1453) y 1 Reabierta (1383).

El 5 nov, 22:25Z, por orden de Santiago, se pasaron a Finalizada las historias con video validado en persona y las que ya estaban en QA, con sus subtareas de QA (comentarios 11014 a 11069). Ese cierre es una decisión de equipo y no una nueva medición: 892, 1378, 1618, 873, 1375 y 1462 se cerraron sin repetir su última falla o salvedad; la repetición posterior confirma que 892 sigue fallando (ver Estado actual).

Subtareas abiertas: 1300 y 1301 En revisión (Kafka); 1526 En curso (1418); 1491, 1504, 1561, 1577, 1578 y 1613 Por hacer. Fuera de la matriz: 1236 En revisión, 1470 En curso; 1469 y 1471 Finalizada.

## Matriz

Estado Jira leído el 5 nov, 22:45Z. Pasan, Fallan, Resultado y Nota son la última medición, anterior al cambio de rol salvo donde se indica: "Reabrir" o "Bloqueada" con estado Finalizada significa que Jira se cerró sin repetir esa prueba. Las filas de 892, 1378, 1450, 1468 y 1618 traen el resultado de la repetición.

| Historia | Responsable | Estado Jira | Pasan | Fallan | Resultado | Nota |
|---|---|---|---|---|---|---|
| SCRUM-892 | nicolas | Finalizada | 4 | 1 | Falla; bug SCRUM-1633 | C1 repetido el 5 nov, 22:57Z: pago después de finalizar sigue en RETENIDA. La app muestra Pagar con cotización aceptada, sin mirar la solicitud. |
| SCRUM-1378 | nicolas | Finalizada | 4 | 4 | Pasa | Repetida el 5 nov, 23:10Z: 3 respuestas 202 idénticas, sin el 500. C1 sigue sin probar: exige correo real. |
| SCRUM-1383 | Daniel | Reabierta | 4 | 0 | Reabrir | C1: documento de aliado 68/68 y teléfono de usuario 26/26 en claro, columnas text. Registros sin tokens ni claves. |
| SCRUM-1450 | Nicolás | Finalizada | 8 | 4 | Pasa | Antes con BYPASSRLS. C1 y C3 pasan como mani_dispatch_svc el 5 nov, 23:21Z. |
| SCRUM-1453 | Juan | En revisión | 0 | 0 | Reabrir | Medición anterior. Corrección en release (GW#83, .NET#31), sin comprobar en QA. |
| SCRUM-1468 | Juan | Finalizada | 0 | 3 | Pasa | Antes con postgres. Desde el 5 nov 19:05Z conectan con rol propio; 0039 aplicada a las 20:14Z; 3 de 3 en lote_f3 a las 22:57Z. |
| SCRUM-1618 | nicolas | Finalizada | 0 | 0 | Sin chequeo propio | El 500 de 1378 ya no ocurre. Sigue sin prueba de respuesta igual ante fallo del proveedor. |
| SCRUM-901 | Juan | En revisión | 6 | 0 | Bloqueada | C2 y C3 pasan. C1 sin cuenta PLATFORM_ADMIN en QA. Corrección de contexto en release, sin desplegar en QA. |
| SCRUM-1449 | Juan | Finalizada | 0 | 0 | Bloqueada | Exige prueba como mani_dispatch_svc; el rol ya existe en QA, prueba sin repetir. |
| SCRUM-866 | Jose | Finalizada | 14 | 0 | Pasa API; flujo revisado en equipo | Alerta en ambos sentidos, Rules caído da 503. Sin probar: SIN_TARIFA en cotización (ningún aliado en categoría sin tarifa). |
| SCRUM-873 | Jose | Finalizada | 7 | 2 | Pasa API; flujo revisado en equipo | lote4b pasa; offline en app revisado en equipo. |
| SCRUM-874 | Juan | Finalizada | 19 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-875 | Juan | Finalizada | 7 | 2 | Pasa API; flujo revisado en equipo | lote5b pasa. |
| SCRUM-878 | Juan | Finalizada | 19 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-879 | Juan | Finalizada | 8 | 1 | Pasa API; flujo revisado en equipo | lote5b pasa. |
| SCRUM-880 | Juan | Finalizada | 10 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-882 | nicolas | Finalizada | 7 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-883 | nicolas | Finalizada | 15 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-884 | nicolas | Finalizada | 8 | 1 | Pasa API; flujo revisado en equipo | lote6b pasa. |
| SCRUM-885 | Juan | Finalizada | 23 | 1 | Pasa API; flujo revisado en equipo | Versionado, validaciones, aislamiento y auditoría. |
| SCRUM-886 | Juan | Finalizada | 8 | 0 | Pasa API; flujo revisado en equipo | Sin tarifa: disponible false. |
| SCRUM-887 | Juan | Finalizada | 9 | 0 | Pasa API; flujo revisado en equipo | Rules caído da 503. |
| SCRUM-889 | nicolas | Finalizada | 16 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-890 | nicolas | Finalizada | 6 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-891 | nicolas | Finalizada | 5 | 1 | Pasa API; flujo revisado en equipo | Retención simulada; pago fallido no retiene. |
| SCRUM-893 | nicolas | Finalizada | 35 | 5 | Pasa API; flujo revisado en equipo | La regla gobierna la liquidación: con 12 % liquida 12000 y con 10 % liquida 10000, y la anterior conserva su 12 %. Los 3 decimales se reabrieron a las 14:41Z y se corrigieron con Node#120: 10.555 se rechaza y 10.55 se acepta. Las 5 fallas del conteo son de corridas anteriores a las correcciones. Sin comprobar en QA: regla inválida ya guardada y tenant sin regla; la liquidación completa es de `ee9feb7`. |
| SCRUM-894 | nicolas | Finalizada | 5 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-895 | Juan | Finalizada | 19 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-896 | Juan | Finalizada | 13 | 0 | Pasa API; flujo revisado en equipo | Tres transiciones con actor en base. |
| SCRUM-900 | Juan | Finalizada | 8 | 0 | Pasa API; flujo revisado en equipo | Coincide con la base en t1 y t2. |
| SCRUM-1365 | Daniel | Finalizada | 6 | 0 | Pasa API; flujo revisado en equipo | Lectura cruzada 403/404. Ver 1468: aislamiento por código, no por RLS. |
| SCRUM-1366 | Juan | Finalizada | 25 | 0 | Pasa API; flujo revisado en equipo | La comisión de la regla ya se aplica (ver 893). Regla de t1 en 10 %, versión 11. Con Core `ee9feb7` y `af24c6c` solo se repitió lo de comisión; los otros 18 chequeos son de `3e41538`. |
| SCRUM-1369 | Daniel | Finalizada | 2 | 1 | Pasa API; flujo revisado en equipo |  |
| SCRUM-1372 | Daniel | Finalizada | 1 | 0 | Pasa API; flujo revisado en equipo | Solo inválidos; registro completo revisado en equipo. |
| SCRUM-1373 | Daniel | Finalizada | 1 | 0 | Pasa API; flujo revisado en equipo | Solo inválidos; registro completo revisado en equipo. |
| SCRUM-1374 | Daniel | Finalizada | 1 | 0 | Pasa API; flujo revisado en equipo | Solo inválidos; registro completo revisado en equipo. |
| SCRUM-1375 | nicolas | Finalizada | 6 | 4 | Pasa API; flujo revisado en equipo | Registro completo revisado en equipo. |
| SCRUM-1376 | nicolas | Finalizada | 10 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-1385 | maria | Finalizada | 6 | 0 | Pasa API; flujo revisado en equipo | Sin probar: rechazo de aliado no aprobado. |
| SCRUM-1386 | maria | Finalizada | 16 | 2 | Pasa API; flujo revisado en equipo | La ausencia saca de elegibles y al borrar vuelve. |
| SCRUM-1388 | maria | Finalizada | 22 | 6 | Pasa API; flujo revisado en equipo | Oferta oculta contacto; Dispatch caído da 503. Sin ruta para cambiar de sitio. |
| SCRUM-1389 | maria | Finalizada | 2 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-1390 | Sara | Finalizada | 10 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-1391 | Sara | Finalizada | 8 | 0 | Pasa API; flujo revisado en equipo | Sin probar: servicio en curso con categoría real. |
| SCRUM-1392 | Sara | Finalizada | 5 | 0 | Pasa API; flujo revisado en equipo | Sin probar: rechazo de aliado no aprobado. |
| SCRUM-1395 | Sara | Finalizada | 4 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-1396 | Sara | En revisión | 6 | 0 | Pasa API; flujo revisado en equipo | API pasa: 20 de 20 localidades y 1.229 de 1.233 barrios con límite. Abierta por MANI-Flutter#131 sin fusionar. |
| SCRUM-1401 | Santiago | Finalizada | 9 | 0 | Pasa API; flujo revisado en equipo | Rules caído da 503. |
| SCRUM-1402 | Santiago | Finalizada | 15 | 1 | Pasa API; flujo revisado en equipo | C2 por prueba automatizada; CI de 5d7c2ab en verde. |
| SCRUM-1418 | Juan | En revisión | 9 | 0 | Pasa API; flujo revisado en equipo | Calificaciones privadas en release (Node#130), sin comprobar en QA. |
| SCRUM-1451 | Juan | Finalizada | 1 | 0 | Pasa API; flujo revisado en equipo | 51 ofertas sin duplicar tras 2 despachos. |
| SCRUM-1462 | Juan | Finalizada | 6 | 3 | Pasa API; flujo revisado en equipo | Ranking real; evaluación por Core. Por revisar: 1 de 51 aliados con puntaje y razones, y el orden por COBERTURA dio a,b,c donde se esperaba a,c,b, marcado PASA. |
| SCRUM-1465 | Jose | Finalizada | 2 | 0 | Pasa API; flujo revisado en equipo |  |
| SCRUM-1622 | Juan | Finalizada | 2 | 0 | Pasa API; flujo revisado en equipo | Sin UPDATE; sí INSERT en rechazo. C5 depende de 1468. |
| SCRUM-1632 | Sara | Finalizada | 1 | 0 | Pasa API; flujo revisado en equipo | Reversión en pantalla revisada en equipo. |
| SCRUM-888 | nicolas | Finalizada | 0 | 0 | Sin chequeo propio; flujo revisado en equipo | Mismo camino de 1432; ver 892 por pago tras finalizar. |
| SCRUM-1068 | nicolas | Finalizada | 0 | 0 | Sin chequeo propio; flujo revisado en equipo | Elegibilidad por Core en lote C. Sin probar: Core caído. |
| SCRUM-1379 | Daniel | Finalizada | 0 | 0 | Sin chequeo propio; flujo revisado en equipo | TERMS_NOT_ACCEPTED al registrar; 9 consentimientos. C1 y C3 revisados en equipo. |
| SCRUM-1423 | nicolas | Finalizada | 0 | 0 | Sin chequeo propio; flujo revisado en equipo | Por 882, 884 y 1428. |
| SCRUM-1466 | nicolas | Finalizada | 0 | 0 | Sin chequeo propio; flujo revisado en equipo | Migración 0009 y foto por 1629. |
| SCRUM-1619 | Jose | Finalizada | 0 | 0 | Sin chequeo propio; flujo revisado en equipo | C3: cero accesos directos en lib/. C1, C2, C4 sin revisar. |
| SCRUM-1620 | Jose | Finalizada | 0 | 0 | Sin chequeo propio; flujo revisado en equipo | Por 1403 y 1621. |
| SCRUM-1621 | Juan | Finalizada | 0 | 0 | Sin chequeo propio; flujo revisado en equipo | Sin UPDATE ni INSERT sobre solicitud. |
| SCRUM-1630 | Sara | Finalizada | 0 | 0 | Sin chequeo propio; flujo revisado en equipo | Semilla con UUID. |
| SCRUM-1452 | Juan | Finalizada | 1 | 0 | Finalizada | Cerrada el 5 nov: MANI-SOL-409E sin decir que fue asignada a otro. Subtarea 1560 cerrada. Comentario 11001. |
| SCRUM-1628 | nicolas | Finalizada | 4 | 0 | Finalizada | Cerrada el 5 nov: C1 a C3 cumplidos en QA; la tarea no pide video. Comentario 11000. |
| SCRUM-1629 | Daniel | Finalizada | 2 | 0 | Finalizada | Cerrada el 5 nov: C1, C2 y C3 cumplidos; la tarea no pide video. Comentario 10999. |


## Finalizadas con observación

| Historia | Pasan | Fallan | Observación |
|---|---|---|---|
| SCRUM-877 | 7 | 4 | Rechazos correctos; la lectura de base no devolvió el estado final en la repetición, sin confirmar. |
| SCRUM-1370 | 16 | 0 | Lote A/B pasa; aterrizaje revisado en equipo. |
| SCRUM-1377 | 14 | 2 | 400 con código MANI-PRF-422. Igual que el 31 oct. |
| SCRUM-1380 | 5 | 2 | C3 de lote2 compara JSON completo; mi prueba por ids (1367) pasa. |
| SCRUM-1403 | 6 | 4 | Una sola asignación. En carrera de 11, 2 de 5 de aliado.t1 dan 503. Igual que el 31 oct. |
| SCRUM-1432 | 27 | 0 | Pasa por API; pantalla revisada en equipo. |
| SCRUM-1446 | 8 | 8 | lote2 usa IDs fijos; igual que el 31 oct. |
| SCRUM-1461 | 0 | 0 | /metrics responde 200 sin token desde fuera; la historia pide exponerlo. Sin alerta verificada. |

## Escenarios QAS medidos en este corte

Medición del 5 nov, anterior al cambio de rol. QAS-01 y QAS-20 mencionan la conexión como `postgres`, que ya no es la de QA; deben repetirse antes de citarlos como vigentes.

Fuente: SDD §8, `origin/main` de MANI-docs (`fcd35ec`). Los 45 escenarios, medidos sobre esta versión el 5 nov. Lo anterior no se reutiliza. Sara aprobó QAS-41 a 45 el 5 nov. Los fallos son propuestas; no se abrieron incidencias.

Conteo: Cumple 0, Parcial 13, No cumple 10, Bloqueado 3, No medido 19. Ningún Cumple: en cada escenario medido falta alguna parte del método del SDD.

Carga: k6 v2.3.0 desde la VM de Calidad al Gateway de QA (puerto 80), solo lecturas, con un token de cliente.t1 y uno de aliado.t1. Salida: `qa_s5_corte2/qas_carga_05nov_0636z.txt`.

| QAS | Umbral | Medido | Resultado |
|---|---|---|---|
| QAS-03 | p95 ≤ 500 ms, 300 sesiones y 50 req/s | `eligible-allies` (Gateway, Dispatch, Core): p95 3.015 ms; 14.999 de 14.999 con 5xx a 50,0 req/s, 5 min. Sin carga (2 req/s): p95 2.638 ms, 0 errores. | No cumple |
| QAS-15 | 5xx < 1 % en 15 min | 66,7 % de 35.192 peticiones | No cumple |
| QAS-19 | 300 sesiones y 50 req/s sin incumplir p95 | 39,1 req/s. p95: elegibles 3.015 ms, ofertas 3.137 ms, sitios 10.512 ms, tarifa 10.514 ms, perfil 244 ms. | No cumple |
| QAS-18 | CPU sostenida < 70 % | Máximo por contenedor: Core 49,7 %, Dispatch 50,3 %, Gateway 7,7 %, Rules 0,3 %. Sin límites ni pods; la carga no se atendió bien. | Parcial |
| QAS-01 | 100 % cross-tenant rechazado | 6 de 6 casos rechazados por API. Aislamiento por código, no por RLS (1468). | Parcial |
| QAS-13 | Tokens validados en 100 % de rutas protegidas | 388 de 388 intentos sin token válido dan 401, 97 operaciones. Sin token real vencido en esta corrida. | Parcial |
| QAS-14 | Rate limiting y 0 Critical/High | 400 peticiones en ráfaga, 0 con 429. ZAP sin ejecutar. | No cumple |
| QAS-22 | 100 % con correlation ID, logs estructurados | Dispatch no registra el ID (0). JSON en logs: Gateway 24/24, Core 4/192, Dispatch 0/200. | No cumple |
| QAS-27 | Respeta límites de CPU y memoria | Sin límites en los 5 contenedores. | No cumple |
| QAS-37 | Estados inválidos rechazados | Cancelar dos veces da 200, no 409; el estado no cambia. Lo demás se rechaza. Falta ver en código si es idempotencia a propósito. | Parcial |
| QAS-42 | Misma clave con otro cuerpo da 409 | Reintento sin duplicado; un solo pago. Otro cuerpo da 200, no 409. | No cumple |
| QAS-43 | TLS 1.2+ | 443 rechaza conexión desde el Mac; 8080 sirve HTTP sin redirección. | No cumple |
| QAS-06 | 100 % de APIs con OpenAPI y contract tests aprobados | Código frente a contratos de `release`, por texto de ruta: 105 de 127 (82,7 %), sin 7 internas de `core-internal.yaml` ni `dev-token`, que está cerrada. Sin contrato, entre otras: `profiles/me`, `sites/{id}/reglas`, `aliados/{id}/verificacion`. Contract tests sin correr en este corte. | No cumple |
| QAS-07 | 100 % de ranking, tarifa, asignación y conflicto | Por API: ranking 1401 y 1462, tarifa 885-887 y 866, una sola asignación en 1403. Comisión: la liquidación aplica la regla vigente, comprobado con 12 % y 10 % (893). Faltan pantallas. | Parcial |
| QAS-10 | 100 % de operaciones críticas protegidas | Negativos en los lotes por historia y QAS-37. Sin inventario de operación por operación. | Parcial |
| QAS-11 | Evidencia auditable e inmutable | `regla_tenant`: UPDATE, DELETE y TRUNCATE rechazados. `transaccion_evento` y `consulta_conversacion` tienen trigger de inmutabilidad (UPDATE y DELETE), sin intentar. La consulta no halló ese trigger en `evento_servicio`. | Parcial |
| QAS-12 | Actor, hora y correlation ID en 100 % de cambios | `regla_tenant` guarda actor, hora e ID; quejas guardan actor (896). Dispatch no registra el ID en logs. Por esquema, actor, rol e ID están en `transaccion_evento`, `consulta_conversacion`, `queja_transicion` y `tenant_estado_cambio`; `evento_servicio` solo tiene actor y `pago` solo ID. Sin revisar datos cambio por cambio. | Parcial |
| QAS-20 | Ningún servicio accede a tablas de otro dominio | Permisos del rol: Dispatch lee 4 tablas y escribe solo `solicitud_rechazo`. Pero los servicios conectan como `postgres` (1468), así que esos permisos no se ejercen. Falta la revisión de SQL. | Parcial |
| QAS-23 | Cobertura nueva ≥ 80 %, críticos ≥ 90 % | Solo Flutter, `develop` en SonarCloud: nueva 88,6 %, total 84,3 %. Los otros 5 repos sin consultar: su Sonar no responde desde el Mac. | Parcial |
| QAS-28 | 100 % de historias críticas con caso | Esta matriz traza las historias del corte a lotes; 9 sin chequeo propio. Falta el cruce con el backlog completo. | Parcial |
| QAS-34 | Criterios de accesibilidad definidos | Sin criterio WCAG publicado en `wiki` ni `governance`. `Semantics` en 16 archivos de Flutter. Lighthouse sin correr. | No cumple |
| QAS-41 | Una aceptación 200, las demás 409, 0 dobles | Carrera de 11: una sola asignación, pero 2 de 5 de aliado.t1 dan 503 (1403). Arnés k6 sin correr sobre esta versión. | Parcial |
| QAS-45 | 0 Blocker/Critical nuevos, duplicación < 3 %, gate bloquea | Solo Flutter: gate OK, duplicación nueva 0,4 %. Total de esa rama: 0 Blocker y 41 Critical, sin separar nuevos. Otros 5 repos sin consultar. PR de prueba sin abrir. | Parcial |

**Bloqueados**

| QAS | Motivo |
|---|---|
| QAS-02 | No hay forma de provocar el fallo: el mock de avisos siempre entrega (884 C2, 1428 C2). |
| QAS-09 | QA no tiene inyección de fallas con adaptador de prueba. |
| QAS-40 | Igual que QAS-09: falta demora, respuesta malformada y caídas repetidas en el adaptador. |

**No medidos**

| QAS | Motivo |
|---|---|
| QAS-04, 21, 26, 29, 38 | Método de revisión sin ejecutar en este corte. |
| QAS-05 | QA corre en Compose, sin Kubernetes ni réplicas. |
| QAS-08, 30, 31, 32, 33, 35, 36, 39 | Requieren pantalla o usuarios. Sin medición formal; el equipo revisó el flujo en la app. |
| QAS-16 | Sin serie de sondas del mes; sin Prometheus en QA. |
| QAS-17 | Sin simulacro de restauración. Afectaría la base compartida; decisión de Daniel. |
| QAS-24 | Solo tengo digests de QA; faltan DEV y PROD para comparar. |
| QAS-25 | Sin despliegue automatizado cronometrado; el del 5 nov fue por script. |
| QAS-44 | Sin simulacro de reversión. Afectaría QA; decisión de Daniel. |

**Causa de los fallos de carga: se agota el pool de conexiones de Core.** Confirmado en los logs de la ventana 06:37Z a 07:01:30Z (`qa_s5_corte2/logs_carga_05nov_1312z.txt`).

- **Core:** registra 31.451 veces `timeout exceeded when trying to connect` en `pg-pool`, desde `withTenantContext`. El pool tiene 5 conexiones y espera 10 s (`PgPoolFactory.js:10,30`; `container.js:160` no pasa otro máximo). Los errores suman exacto: `context` 17.028, `sitios` 4.962, `offers` 4.803 y `tarifa` 4.658.
- **`sitios` y `tarifa`:** Gateway devuelve 500 con mediana cercana a 10 s (9.620). Las que sí responden 200 también tardan cerca de 10,5 s (4.969).
- **`eligible-allies` y `offers/me`:** Dispatch corta a los 3 s su llamada a Core (`Program.cs:32`). Sus 31.026 `TaskCanceledException` coinciden con los 31.026 503 de Gateway (23.870 + 7.156).
- **Descartado:** reinicios y OOM (0 en los 4 servicios), CPU (máximo 50,3 %) y Rules (solo 62 rankings, sin errores). `perfil` no registra errores de pool: 7.380 respuestas 200, mediana 0,226 s.
- **Sin comprobar:** si subir el pool alcanza los umbrales de QAS-03, 15 y 19; hay que cambiarlo y volver a medir. `max_connections` es 60, leído a las 13:13Z, no durante la carga.
- **Propuesta:** subir `max` del pool y hacerlo configurable, y alinear los 3 s de Dispatch con los 10 s de espera de Core. Hoy Dispatch abandona antes de que Core termine de esperar.


## Rastro en QA

- Lote QAS corrido dos veces (06:21Z y 06:31Z): 4 solicitudes de prueba, 2 canceladas y 2 con pago simulado.
- Reglas de t1 en versión 2, con el contenido original.
- Tarifa de Plomería: 3 versiones; la vigente con los valores originales.
- `SITIO_T1` restaurado por UPDATE a la semilla. El valor justo antes de la prueba no quedó registrado.
- Categoría "Corte2 QA" desactivada. Ausencia de aliado.t1 borrada.
- Compose de la VM: `RULES_SERVICE_URL` agregado a Dispatch (respaldo `docker-compose.qa.yml.bak_rules_dispatch_20261105T050811Z`).
- Foto de `cliente_natural.t2` cambiada. Solicitudes, pagos simulados y queja de prueba de los lotes.
- TEC-21, 5 nov 19:05Z: `.env.qa` cambiado (`DATABASE_URL` de `mani_core_svc`, `DISPATCH_DB_CONNECTION` de `mani_dispatch_svc`, `DATABASE_URL_ADMIN` de `postgres`). Respaldo `.env.qa.bak_tec21_20261105T190422Z`. Migraciones 0037 y 0038 aplicadas.
- 0039 aplicada a las 20:14Z, antes del merge de Node#128, porque QA estaba rota. `documento_legal` devuelve 2 filas de otro tenant como `mani_core_svc`; la política admite `tenant_id IS NULL`, filas sin inspeccionar.
- Solicitud de Cerrajería de cliente.t1 en Niza, en BUSCANDO ALIADO.

## Observaciones abiertas

- Comisión en `lote_f3_qa.sh`: el chequeo C2 de 893 usa el PUT retirado; ese fallo no es defecto. Vale `lote_comision_qa.sh`.
- `postgres` en Supabase no es superusuario ni puede dar permiso sobre `auth`: la 0006 no se cumple allí y CI no lo detecta, porque su `auth` es un stub.
- Puerto 80 con `Connection reset` desde el Mac por VPN, sin revisar.

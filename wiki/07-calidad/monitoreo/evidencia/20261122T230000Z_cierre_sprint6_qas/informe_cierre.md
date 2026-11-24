# Cierre de los escenarios de calidad del Sprint 6 (22 de noviembre de 2026)

> Evidencia de QA. Resultado en el [SDD §8](../../../../02-arquitectura/SDD.md). Umbrales: [acta A/B](../../../../06-gobernanza/ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md). Mantiene: QA (Santiago Hernández).

Remedición del 22 de noviembre, de las 19:20Z a las 00:30Z del 23, después de la promoción a `release` y del despliegue en MANI-QA (`10.43.100.141`).

## Versiones en QA al cierre

| Servicio | Commit | Qué trae del día |
|---|---|---|
| Core | `cdebf74` | Migración 0043 (CHECK de `solicitud.estado` y `cotizacion.estado`), SCRUM-1657 |
| Dispatch | `ba460e4` | SCRUM-1651 (timeout hacia el Core) |
| Flutter | `95a3e42` | #152 rediseño, #154 componentes Mani, #155 rescate SCRUM-1646/1647, #157 confirmación al cerrar sesión, #159 y #161 registro de aliado |
| Gateway | `e454bcf` | #100 límite de 25 MB en `/api/v1/core/auth/` |
| Rules | `348f6d9` | Sin cambios |

Pools: Core 30 y Dispatch 5 (pooler de Supabase en modo transacción). Despliegues en [`despliegues/`](despliegues).

## Resultados

| QAS | Antes | Ahora | Medición |
|---|---|---|---|
| 03 Comportamiento temporal | No cumple | **No cumple** | `eligible-allies` con 300 VUs y 50 req/s por 5 min: p95 **8 212 ms** (umbral 500 ms), 5xx 0,008 %. Con SCRUM-1651 ya no hay 5xx, pero las peticiones esperan al Core. Sin carga, p95 de 540 ms. [`carga/`](carga) |
| 10 Integridad | Parcial | **Cumple** | T-27 (`t27_22nov_1927z.txt`): las 7 operaciones críticas rechazan los negativos y no cambian el estado; con la migración 0043 la base rechaza un estado inexistente en `solicitud` y `cotizacion` (`23514`). 48 PASA, 1 FALLA: la prueba de `pago` no se pudo ejecutar con el rol del servicio (`42501`), pero el catálogo muestra `pago_estado_check` |
| 12 Accountability | Parcial | **Parcial** | SCRUM-1657 (en `cdebf74`) no cubre la aprobación de aliado: sigue sin actor ni correlation ID en la base |
| 15 Ausencia de fallos | No cumple | **Cumple** | Mezcla de 15 min con 300 VUs: **0,92 %** de fallos HTTP (umbral < 1 %), frente a 39,8 % el 22 nov a las 04:12Z |
| 19 Capacidad | No cumple | **No cumple** | Misma mezcla: **36,4 req/s** sostenidas (objetivo 50), p95 de 7 a 12 s. CPU del Core alrededor del 66 %: el cuello ya no es la CPU sino la base y el pool |
| 30 Reconocibilidad | No medido | **No cumple** | Revisión heurística (opción B): acción principal visible sin documentación en **11 de 14 flujos**. No: reglas del tenant y los dos registros (el botón queda bajo el pliegue a 800x865) |
| 31 Aprendizabilidad | No medido | **Cumple** | Flujos base: F1 0, F2 0, F3 0 y F7 1 asistencia (rótulos «Backoffice», «KYC»). Umbral ≤ 1. Límite: el evaluador conoce el sistema |
| 32 Operabilidad | No medido | **Cumple, tras corregir tres defectos** | Tareas críticas ejecutadas: 8 de 8 al cierre (100 %). En el primer intento, el registro de aliado (F7) falló: 7 de 8 (87,5 %). F4 (pagar) no se ejecutó |
| 33 Involucración | Cumple | **No cumple** | #152 se fusionó con 28 líneas de botones o campos nativos en pantallas que modifica. En `release` quedan 83 nativos en 31 pantallas tocadas desde la regla (antes 162). [`t45/qas33_release_1991221_22nov.txt`](t45/qas33_release_1991221_22nov.txt) |
| 34 Inclusividad | No cumple | **No cumple** (23 nov) | El criterio ya existe (WCAG 2.2 AA en `PRODUCT.md` de Flutter). Flutter falla idioma (`en-US`), nombre de los campos, zoom en celular y foco visible; contraste de tokens 38 de 38. Landing con 33 textos de contraste bajo. [`qas34_qas35/`](qas34_qas35/revision_qas34_qas35.md) |
| 35 Asistencia al usuario | No cumple | **No cumple** (23 nov) | 594 de 594 pruebas de mensajes. Orientan 3 de 6 casos; no orientan la redirección por rol, los 5xx de verificación y asignación ni el error de tamaño de archivo. [`qas34_qas35/`](qas34_qas35/revision_qas34_qas35.md) |
| 38 Identificación de riesgos | Parcial | **Cumple** (23 nov) | 12 de 12 operaciones sensibles en SAD §23.1 (MANI-docs#91) con riesgo y mitigación; el control de cada una existe en Core `cdebf74`. [`qas38/`](qas38/qas38_operacion_riesgo_23nov.md) |
| 39 Advertencia de peligro | Parcial | **Cumple** | Ocultar categoría, cerrar sesión (barra superior, Tu cuenta en celular y tarjeta del inicio), cancelar solicitud y aprobar aliado piden confirmación; «Cancelar» no cambia nada. [`t45/qas39_qa_1991221_22nov.txt`](t45/qas39_qa_1991221_22nov.txt) |

## Defectos encontrados y corregidos durante la medición

| Id | Qué | Arreglo | Estado |
|---|---|---|---|
| D-QAS39-1 | En celular, «Cerrar sesión» de Tu cuenta y la tarjeta del inicio cerraban la sesión sin confirmar (llegaron con #155) | MANI-Flutter#157 | En QA (`77cd696`) |
| D-T45-1 | El Gateway cortaba con 413 cualquier registro con documentos de más de 1 MB | MANI-APIGateway#100 | En QA (`e454bcf`) |
| D-T45-2 | Flutter enviaba los documentos KYC como `application/octet-stream` y Core los rechazaba con 400 | MANI-Flutter#159 | En QA (`003f57e`) |
| D-T45-3 | Flutter no enviaba `acceptsTerms` en el registro de aliado persona natural y Core respondía `TERMS_NOT_ACCEPTED` (exigido desde SCRUM-856, 7 oct) | MANI-Flutter#161 | En QA (`95a3e42`) |

Con D-T45-1 a D-T45-3, el registro de aliado persona natural no funcionaba en QA desde el 7 de octubre.

## Hallazgos de la revisión heurística sin corregir

| Hallazgo | Heurística y severidad | Responsable |
|---|---|---|
| La verificación de aliados tarda 12 a 18 s con solo un indicador de carga | H1, 2 | Core y Flutter |
| Reglas del tenant: «Guardar nueva versión» bajo el pliegue y rótulos con códigos «(RF-13)», «(RNF-10)»; sin el encabezado de las demás páginas | H2 y H4, 2 | Flutter |
| Registros de cliente y aliado con el estilo viejo (mayúsculas) y jerga («Backoffice», «KYC», «Garantía Multi-tenant») | H2 y H4, 2 | Flutter |
| El error de tamaño de archivo no dice el límite | H9, 2 | Flutter |
| Cobros del aliado sin el servicio al que corresponde cada monto | H6, 2 | Flutter |
| Aceptar una cotización no pide confirmación | H5, 2 | PO, luego Flutter |
| «Orden no disponible…» y «(sandbox)» exponen estado técnico al cliente | H2, 1 | Flutter |

Registro completo por flujo: [`t45/lista_chequeo_heuristica.md`](t45/lista_chequeo_heuristica.md).

## Límites

- Revisión heurística de experto, no prueba con usuarios (opción B aceptada por la SM). El evaluador conoce el sistema y subestima las asistencias.
- Datos de prueba que quedan en QA: categoría «Categoria QA T45 heuristica» (oculta), solicitud de Plomería en Bosa (cancelada), cotización aceptada de «Corte 2 lote C», aliado «Aliado QA T45 Heuristica» (aprobado) y cliente `qa.t45.cliente.0030@qa.mani.test`.

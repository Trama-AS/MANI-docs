# Reporte de QA del Sprint 6

> **Finalidad:** qué midió QA en el Sprint 6, con qué resultado y qué queda pendiente. **Mantiene:** QA (Santiago Hernández). **Consume:** PO, SM, desarrollo y DevOps. **Se actualiza:** al cierre del sprint. **Versión:** 1.2, 2026-11-24 (remedición tras el despliegue del 23 nov). **HU:** [SCRUM-1692](https://maniservices.atlassian.net/browse/SCRUM-1692). Estados de los QAS: [SDD §8](../02-arquitectura/SDD.md) y [tabla operativa](QAS_45_ESTADO_METODO_EVIDENCIA.md).

## 1. Resultado

**Conteo final de los 45 QAS:** Cumple 26 · Parcial 9 · No cumple 7 · No medido 3. Al cierre del Sprint 5 eran 9 Cumple. En el primer corte del 22 nov eran 18 Cumple y 6 No medido.

Los 3 No medido (05, 18 y 27) dependen de DevOps. Los 7 No cumple tienen causa y responsable en el §5.

La remedición del 22 de noviembre (19:20Z a 00:30Z) se hizo sobre lo promovido ese día a `release` y desplegado en QA: Core `cdebf74`, Dispatch `ba460e4`, Flutter `95a3e42`, Gateway `e454bcf` y Rules `348f6d9`. Detalle en el [informe del cierre](monitoreo/evidencia/20261122T230000Z_cierre_sprint6_qas/informe_cierre.md).

La remedición del 23 y 24 de noviembre (23:41Z a 01:24Z) se hizo sobre Core `f0c2e87`, Dispatch `4b065e9`, Flutter `d9597a5`, Gateway `45a6c95`, Rules `348f6d9` y Landing `7649832`, con la migración 0044 aplicada. QAS-30 y 44 pasaron a Cumple. Detalle en el [informe de la remedición](monitoreo/evidencia/20261124T012400Z_remedicion_qas/informe_remedicion.md).

## 2. Qué se midió

| Tarea | Escenarios | Resultado | Informe |
|---|---|---|---|
| T-41 (SCRUM-1678) | 01, 20 y roles de servicio | Cumple | [t41_roles_servicio](monitoreo/evidencia/20261113T003051Z_t41_roles_servicio) |
| T-27 (SCRUM-1664) | 10 (negativos de operaciones críticas) | **Cumple** desde el 22 nov, con el CHECK de estado de SCRUM-1713 (migración 0043) | [corrida del 22 nov](monitoreo/evidencia/20261122T230000Z_cierre_sprint6_qas/t27_22nov_1927z.txt) |
| T-44 (SCRUM-1681) | 45 (Quality Gate) | Cumple | [t44_quality_gate](monitoreo/evidencia/20261115T182000Z_t44_quality_gate) |
| T-42 (SCRUM-1679) | 03, 15, 19 | 15 **Cumple** (0,92 % de fallos). 03 y 19 No cumple: p95 de 8,2 s y 36,4 req/s | [carga del cierre](monitoreo/evidencia/20261122T230000Z_cierre_sprint6_qas/carga) |
| T-43 (SCRUM-1680) | 04, 08, 13, 21, 28, 29, 33 a 36, 38, 39, 44 | 39 pasó a Cumple el 22 nov y 33 a No cumple (§4) | [t43_solo_medicion](monitoreo/evidencia/20261121T154000Z_t43_solo_medicion) |
| T-46 (SCRUM-1683) | 07, 41 | Cumple | [t46_concurrencia](monitoreo/evidencia/20261122T013000Z_t46_concurrencia) |
| SCRUM-1685 | 17 (recuperabilidad) | Cumple con el umbral del acta A/B | SDD §8 |
| Barrido del 22 nov | Las 22 filas sin medir del sprint, más 11, 37, 42 | 11, 16, 25, 37 y 42 Cumple | [informe del barrido](monitoreo/evidencia/20261122T025500Z_barrido_qas/informe_barrido.md) |
| QAS-14 | SAST, OWASP ZAP y rate limiting | Cumple | [informe de QAS-14](monitoreo/evidencia/20261122T032900Z_qas14_dast_sast/informe_qas14.md) |
| QAS-23 | Cobertura de casos de uso críticos | Parcial | [informe de QAS-23](monitoreo/evidencia/20261122T040500Z_qas23_cobertura/informe_qas23.md) |
| QAS-24 y 33 con el umbral B | Imagen por ambiente y regla de componentes | 24 No cumple (backend y Gateway); 33 No cumple tras fusionar #152 | [informe del umbral B](monitoreo/evidencia/20261122T180000Z_qas24_qas33_umbral_b/informe_qas24_qas33.md) |
| T-45 (SCRUM-1682) | 30, 31, 32 | Revisión heurística, opción B aceptada por la SM: 30 **No cumple** (11 de 14 flujos), 31 **Cumple**, 32 **Cumple** tras corregir tres defectos. 30 pasó a **Cumple** el 23 nov (14 de 14, MANI-Flutter#163) | [lista de chequeo](monitoreo/evidencia/20261122T230000Z_cierre_sprint6_qas/t45/lista_chequeo_heuristica.md) |
| QAS-34 y 35 (23 nov) | Accesibilidad y asistencia al usuario | Siguen **No cumple**. 34: el criterio WCAG 2.2 AA ya existe en Flutter, pero fallan idioma, nombre de campos, zoom en celular y foco visible, y la Landing tiene contraste bajo. 35: 3 de 6 casos no orientan | [revisión del 23 nov](monitoreo/evidencia/20261122T230000Z_cierre_sprint6_qas/qas34_qas35/revision_qas34_qas35.md) |
| QAS-38 (23 nov) | Riesgos de las operaciones sensibles | **Cumple**: 12 de 12 en SAD §23.1 (MANI-docs#91), con el control verificado en el código de QA | [operación ↔ riesgo](monitoreo/evidencia/20261122T230000Z_cierre_sprint6_qas/qas38/qas38_operacion_riesgo_23nov.md) |
| Remedición del 23 y 24 nov | 01, 20, 22, 30, 34 (Landing), 40, 44 | 30 y 44 pasan a **Cumple**. 01 y 20 siguen en Cumple tras la 0044. 22 y 40 siguen Parcial (falta Core). 34 sigue No cumple (Landing: 18 textos bajo el umbral, antes 33) | [informe de la remedición](monitoreo/evidencia/20261124T012400Z_remedicion_qas/informe_remedicion.md) |
| SCRUM-1719 | 44 (rollback con despliegue fallido a propósito) | **Cumple**: rollback en 6 s y aceptación sin duplicado | [corrida](monitoreo/evidencia/20261124T012400Z_remedicion_qas/qas40_qas44/qas40_44_24nov_0123z.txt) |

## 3. Bugs abiertos (Jira, 23 nov)

| Clave | Resumen | Estado | Asignado |
|---|---|---|---|
| [SCRUM-1633](https://maniservices.atlassian.net/browse/SCRUM-1633) | Pago hecho después de finalizar queda RETENIDA y no se libera | En revisión | Nicolás León |
| [SCRUM-1634](https://maniservices.atlassian.net/browse/SCRUM-1634) | Cambiar la foto de perfil no funciona en la app | En revisión | Juan Sebastián Álvarez |
| [SCRUM-1635](https://maniservices.atlassian.net/browse/SCRUM-1635) | Ver los aliados de una solicitud no funciona en la app | En revisión | Juan Sebastián Álvarez |
| [SCRUM-1636](https://maniservices.atlassian.net/browse/SCRUM-1636) | Los cambios de estado no se actualizan en vivo | Por hacer | José Nicolás Álvarez |
| [SCRUM-1713](https://maniservices.atlassian.net/browse/SCRUM-1713) | Falta CHECK de estado en `solicitud` y `cotizacion` (QAS-10) | En revisión. **Verificado en QA el 22 nov** (migración 0043, T-27 rechaza estados inexistentes con `23514`) | Nicolás León |

D-T43-1 (pooler agotado) no se abrió como bug: DevOps lo corrigió el 21 nov con el modo transacción (SCRUM-1680, comentarios 11235, 11236 y 11279).

### Defectos encontrados y corregidos durante la medición del 22 nov

No se abrieron como bugs: se corrigieron el mismo día, con PR, promoción a `release` y despliegue en QA.

| Id | Qué pasaba | Arreglo |
|---|---|---|
| D-QAS39-1 | En celular, cerrar sesión desde Tu cuenta y desde la tarjeta del inicio no pedía confirmación (llegó con MANI-Flutter#155) | MANI-Flutter#157 |
| D-T45-1 | El Gateway respondía 413 a todo registro con documentos de más de 1 MB | MANI-APIGateway#100 |
| D-T45-2 | Flutter enviaba los documentos KYC como `application/octet-stream` y Core los rechazaba | MANI-Flutter#159 |
| D-T45-3 | Flutter no enviaba `acceptsTerms` en el registro de aliado persona natural y Core respondía `TERMS_NOT_ACCEPTED` | MANI-Flutter#161 |

Con D-T45-1 a D-T45-3, **el registro de aliado persona natural no funcionaba en QA desde el 7 de octubre** (SCRUM-856 empezó a exigir `acceptsTerms`). Ninguna prueba automatizada lo detectó. #159 y #161 agregan pruebas en Flutter; el límite del Gateway (#100) no tiene prueba automática y se verificó a mano en QA.

## 4. Quality Gate por repositorio

Gate `MANI ADR-0005` sobre código nuevo: 0 issues nuevos, 100 % de hotspots revisados, cobertura ≥ 80 % y duplicación ≤ 3 %. Bloqueo probado con un PR rojo en cada repositorio (T-44):

| Repositorio | Dónde | PR de prueba bloqueado | Observación |
|---|---|---|---|
| MANI-Node (Core) | SonarQube de la VM de Calidad | #42 | — |
| MANI-Java (Rules) | SonarQube de la VM | #12 | — |
| MANI-.NET (Dispatch) | SonarQube de la VM | #35 | — |
| MANI-APIGateway | SonarQube de la VM | #96 | No exige cobertura de código nuevo (QAS-23) |
| MANI-Landing | SonarQube de la VM | #7 | — |
| MANI-Flutter | SonarCloud | #141 | 42 Critical de mantenibilidad abiertos en código existente. El paso «Sin issues Blocker o Critical nuevos» bloqueó el 22 nov el rescate de SCRUM-1646 (#155) hasta corregir 14 Critical nuevos |

**QAS-33 (regla de componentes, SCRUM-1648):** el Quality Gate no la verifica. MANI-Flutter#152 se fusionó con 28 líneas de botones o campos nativos y QAS-33 pasó a No cumple. Para que no se repita hace falta un paso de CI que cuente nativos en las pantallas modificadas.

## 5. Pendientes por responsable

- **DevOps:**
  - ventana para escalar en QA (05);
  - cAdvisor por contenedor (18, 27);
  - `mock_falla` y `STORAGE_FALLA` activos en QA (02, 09);
  - cerrar el 8080 sin TLS y medir PROD (43);
  - promover el mismo digest a `staging` y `latest` (24);
  - cabeceras CSP y anti-clickjacking (14).
- **Core:**
  - menos consultas por petición en elegibles y revisión del pool (03, 19);
  - actor y correlation ID en la aprobación de aliado (12);
  - logs JSON (22);
  - circuit breaker (40);
  - quitar a `mani_dispatch_svc` el `SELECT` sobre `solicitud`, que Dispatch ya no usa (20, no cambia el estado);
  - segundo adaptador de pagos (26);
  - validación de reglas solo en Rules (21);
  - pruebas de los 3 casos críticos bajo 90 % (23).
- **Flutter:**
  - migrar a `ManiButton` y `ManiTextField` las 31 pantallas con nativos (33);
  - mensaje al redirigir por rol y errores útiles (35);
  - idioma `es-CO`, rótulos de campos, foco visible y prueba de escalado de texto (34);
  - hallazgos de la revisión heurística en el [informe del cierre](monitoreo/evidencia/20261122T230000Z_cierre_sprint6_qas/informe_cierre.md).
- **Landing:** contraste de los textos en naranja y amarillo (el botón principal ya cumple) y movimiento reducido (34).
- **PO y arquitectura:**
  - llevar el criterio WCAG 2.2 AA de `PRODUCT.md` al SDD §7.9 y a la Landing (34);
  - confirmación al aceptar una cotización (hallazgo H5 de T-45);
  - fusionar MANI-docs#81 (06).
- **QA:**
  - remedir 02, 09 y 43 cuando DevOps habilite cada caso;
  - repetir 05, 18 y 27 con el cAdvisor por contenedor.

El detalle de cada pendiente, con su posible solución, está en la [tabla de los 45 QAS](QAS_45_ESTADO_METODO_EVIDENCIA.md).

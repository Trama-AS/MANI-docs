# SCRUM-1680 (T-43): escenarios de solo medición

**Fecha:** 2026-11-21, 15:00Z a 17:00Z (hora Colombia 10:00 a 12:00)
**Ambiente:** MANI-QA (VM `10.43.100.141`, Gateway por el puerto 8080), SonarQube de la VM de Calidad (`10.43.98.196`), SonarCloud para Flutter; repos en `develop` y `release` del 20 nov
**Responsable:** Santiago (QA)
**Método:** SDD §8, columna «¿Cómo lo mide QA?» de cada escenario

**Alcance.** Los escenarios del criterio de T-43: 04, 13, 21, 28, 29, 34, 38, 44 y 45, más los de interacción 08, 33, 35, 36 y 39. QAS-30, 31 y 32 se miden en T-45 (SCRUM-1682).

**Regla de estados.** Se usa **Parcial** cuando el umbral se cumple en parte (hay cobertura, pero no total) o el método se ejecutó solo en parte. Se usa **No cumple** cuando falta lo que el umbral exige: el criterio no existe o se repite justo lo que el umbral prohíbe. Los umbrales del SDD no se tocaron.

## 1. Resultado

| QAS | Atributo | Umbral (SDD §8) | Medición del 21 nov | Estado |
|---|---|---|---|---|
| 04 | Capacidad para ser modificado | 0 cambios obligatorios en consumidores de Rules | MANI-Java#13 (merge `054f464`, 19 nov) toca solo Rules: ningún controlador ni contrato. No hay commits en Core, Dispatch, Gateway ni Flutter derivados del cambio. Desplegado en QA (`348f6d9`), Rules atendió 678 peticiones de `rank-allies` durante T-42 sin errores propios. | **Cumple** |
| 08 | Protección contra errores de usuario | 100 % de acciones irreversibles con confirmación | `flutter test`: 102 de 102 pruebas pasan (confirmación previa, «Volver» no ejecuta, doble toque no repite el pago, entradas inválidas no se envían). Las acciones irreversibles definidas (cancelar solicitud, rechazar oferta, aprobar o rechazar aliado, eliminar ausencia, pagar) tienen confirmación o protección probada. | **Cumple** |
| 13 | Autenticidad | Tokens firmados y validados en 100 % de llamadas protegidas | Login real con Supabase: ES256 con `kid`, 60 min, trae `tenant_id` y rol; con el token vigente las rutas protegidas responden 200. Por el Gateway, sobre las **120 operaciones protegidas** de los contratos de `release` (Core 109, Dispatch 7, Rules 4): sin token, firma alterada y token ES256 de otro emisor dan **360 de 360 en 401**. Token **vencido real** (16:40Z, vencido hace 43 s): **75 de 75 operaciones evaluadas en 401** (63 lecturas y 12 escrituras); las otras 45 escrituras recibieron 429 del límite del Gateway antes de llegar a la validación (§3). 0 aceptados y ningún rechazo con datos de negocio. | **Cumple** |
| 21 | Reusabilidad | Sin duplicar reglas de dominio | Sonar: Node 0,6 %, Java 0,0 %, .NET 1,6 %, Gateway 0,0 %, Landing 1,0 %, Flutter 6,3 %. **Hallazgo H-21-1:** la validación de reglas operativas del tenant está copiada con los mismos límites en Core (`src/domain/rules/tenantRulesDefaults.js`, `validarReglasOperativas`, llamada en `TenantRulesUseCase.js:58` antes de ir a Rules) y en Rules (`TenantRulesValidator.java`). Ranking y comisión no tienen copias. | **No cumple** |
| 28 | Completitud funcional | 100 % de historias críticas con caso | 45 de 51 historias críticas (Highest o High) tienen al menos un caso: **88,2 %**. Sin caso: SCRUM-871, 872, 876, 881, 1061 y 1071. | **Parcial** |
| 29 | Pertinencia funcional | Cada endpoint productivo con caso de uso | 141 operaciones en los contratos (137 productivas). 109 citan su historia en el contrato y QA mapeó las otras 28. **0 rutas sin caso de uso.** | **Cumple** |
| 33 | Involucración | Consistencia visual definida por sistema de diseño | El sistema existe (tema y componentes `Mani*`), pero la adopción es baja: ManiButton 83 frente a 141 botones nativos (37 %), ManiTextField 1 frente a 105 campos (1 %), ManiCard 37 frente a 44 tarjetas (46 %) y 115 colores literales en `features/`. Los PR #142 a #147 de MANI-Flutter, que migran pantallas, siguen abiertos. | **Parcial** |
| 34 | Inclusividad | Criterios de accesibilidad definidos | Ningún documento fija un nivel WCAG ni contrastes. Flutter: 15 usos de `Semantics` en 13 archivos, 0 `semanticsLabel`, 28 `tooltip`, 0 pruebas de escalado de texto ni de guías de accesibilidad. Lighthouse no se corrió (ver §3). | **No cumple** |
| 35 | Asistencia al usuario | Errores y estados vacíos con orientación | `flutter test`: 289 de 290 pasan. La única falla es de arquitectura y se debe a duplicados locales de iCloud; el CI está en verde. Faltan las capturas del recorrido en QA. | **Parcial** |
| 36 | Auto-descriptividad | Formularios y estados críticos explican el siguiente paso | `flutter test`: 100 de 100 pasan. Faltan las capturas y la tabla pantalla ↔ texto del recorrido en QA. | **Parcial** |
| 38 | Identificación de riesgos | Operaciones sensibles en el análisis de riesgo | 4 de 12 operaciones sensibles figuran en SAD §23 o SDD §16 con mitigación (**33 %**): pago, escrow, asignación y aislamiento multi-tenant. Faltan KYC (aprobación y documentos), cancelación y penalización, liquidación, cambio de tarifa, reglas del tenant, adición de monto y registro inmutable. | **Parcial** |
| 39 | Advertencia de peligro | Mensaje explícito antes de cancelaciones o reversiones críticas | `flutter test`: 116 de 116 pasan (cancelar, rechazar, aprobar o rechazar aliado, eliminar ausencia). Revisión del código: **desactivar categoría** (`gestion_categorias_page.dart:133`) y **cerrar sesión** (`app_shell.dart:111`) no piden confirmación. Faltan las capturas. | **Parcial** |
| 44 | Reversión de despliegue | Rollback ≤ 5 min | Simulacro de SCRUM-1675 del 14 nov: rollback de `gateway` por digest SHA256 con `rollback_qa.sh`, `check-qa.sh` 6 de 6 en 200, en **8 s**; se restableció en 13 s. No se forzó un fallo ni se repitió una petición crítica, como pide el método. | **Parcial** |
| 45 | Quality Gate | Bloquea Blocker y Critical | Medido en T-44 (SCRUM-1681). | **Cumple** |

**Conteo (14 escenarios):** Cumple 5 (04, 08, 13, 29, 45) · Parcial 7 (28, 33, 35, 36, 38, 39, 44) · No cumple 2 (21, 34).

## 2. Hallazgos para desarrollo y PO

| # | Hallazgo | Escenario | Responsable sugerido |
|---|---|---|---|
| H-21-1 | Validación de reglas del tenant duplicada entre Core y Rules. Si cambia un límite en un lado, el otro rechaza o acepta distinto. | QAS-21 | Equipo de Core y de Rules |
| H-28-1 | Seis historias críticas sin caso de prueba (871, 872, 876, 881, 1061, 1071). | QAS-28 | QA |
| H-33-1 | Adopción baja del sistema de diseño, sobre todo en campos de texto (1 %). | QAS-33 | Nicolás León (PR #142 a #147) |
| H-34-1 | No existe un criterio de accesibilidad publicado. | QAS-34 | Arquitectura y PO |
| H-38-1 | El análisis de riesgos es arquitectónico y no recorre las operaciones de negocio sensibles. | QAS-38 | Arquitectura |
| H-39-1 | Desactivar categoría y cerrar sesión sin confirmación. Falta decidir si son reversiones críticas; QA propone que desactivar categoría sí lo es, porque la oculta a todos los clientes del tenant. | QAS-39 | PO y Flutter |
| H-44-1 | El simulacro de rollback no forzó un fallo. | QAS-44 | Daniel (DevOps) |

## 3. Qué no se pudo medir y por qué

- **QAS-13, primera corrida (16:40Z):** 181 de 480 intentos recibieron 429 del límite de escrituras del Gateway (60 por minuto por IP, burst 40, aplicado antes de `auth_request`), así que no llegaron a la validación del token. Ninguno fue aceptado. Se repitió con las escrituras en serie, por debajo del límite. La corrida queda como evidencia en `qas13_tokens_21nov_1640z_con_429.txt`.
- **QAS-13, token vencido en las 45 escrituras limitadas:** no se repitió, porque el token vencido se borró al terminar la primera corrida y uno nuevo tarda 60 min en vencer. Se da por cubierto porque el Gateway valida todas las rutas protegidas con el mismo `auth_request /_auth_validate`, y la corrida sin 429 (360 de 360) muestra que las 120 operaciones pasan por esa validación. Si la corrida programada de las 17:55Z termina, se agrega como confirmación.
- **Lighthouse (QAS-34):** no se corrió. Necesita descargar el paquete y la Landing no respondía desde la máquina de QA. No cambia el estado: sin criterio publicado no hay contra qué medir.
- **Capturas de 35, 36 y 39:** el recorrido en la app de QA requiere iniciar sesión con las cuentas de prueba desde la sesión del responsable de QA.
- **Sonar, fecha de último análisis:** el token de análisis no puede listar análisis. Las medidas sí responden.

## 4. Evidencia (esta carpeta)

- `qas04_rules_pr13.txt`: diff de MANI-Java#13, checks y commits de consumidores.
- `qas13_login_real_21nov_1539z.txt` y `qas13_login_real_21nov_1654z.txt`: login real y respuesta con token vigente.
- `qas13_tokens_vigente_21nov_1654z.txt`: sin token, firma alterada y otro emisor (360 de 360 en 401).
- `qas13_tokens_21nov_1640z_con_429.txt`: primera corrida, con el caso de token vencido real y los 429 del límite del Gateway.
- `qas21_duplicacion.txt` y `qas21_sonar_21nov_1544z.txt`: duplicación por repo y hallazgo H-21-1.
- `qas28_historia_caso.md`, `qas29_ruta_historia.md` y `qas38_operacion_riesgo.md`: tablas de trazabilidad.
- `qas33_conteo_componentes.txt` y `qas34_accesibilidad.txt`: conteos en el código de Flutter.
- `flutter_test_interaccion.md`: `flutter test` de MANI-Flutter `develop` `daba130` y selección por escenario (08, 35, 36, 39). La salida JSON completa (800 KB) no se versiona.
- QAS-44: [`08-infraestructura/03-despliegue-y-rollback.md`](../../../../08-infraestructura/03-despliegue-y-rollback.md), Runbook C.

Scripts en `scripts/`: `qas13_tokens.py`, `correr_qas13.sh` y `consultar_sonar_duplicacion.sh`. No guardan ni imprimen tokens ni contraseñas.

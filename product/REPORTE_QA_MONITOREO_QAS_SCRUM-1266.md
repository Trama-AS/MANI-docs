# Reporte QA de SCRUM-1266: monitoreo verificable en QA y escenarios QAS-01 a QAS-09

| Campo | Valor |
|---|---|
| Tarea | SCRUM-1266 (QA4-03). Subtareas SCRUM-1274 (QA-MON-01), SCRUM-1275 (QA-MON-02), SCRUM-1276 (QA-MON-03) |
| Autor | Santiago Hernández (QA) |
| Corte | 19 oct 2026 |
| Ambiente | QA: VM 10.43.100.141 (Docker Compose, imágenes `:staging`), Supabase `MANI-QA` (`hpsxdotaizzclkeufzct`) |
| Origen de las pruebas | VM de Calidad 10.43.98.196 y, donde se indica, el equipo del autor dentro de la red del campus |
| Umbrales | SDD §8 (sin cambios) |
| Scripts y evidencia | [`qa/monitoreo_qas/`](../qa/monitoreo_qas/README.md) |

> Los campos marcados `PENDIENTE_CORRIDA_CALIDAD` se llenan con la salida de
> `qa/monitoreo_qas/ejecutar_calidad.sh`. Ningún valor de este reporte está estimado: lo que no se
> midió se declara como no medido.

## 1. Resumen

QA ejecuta las imágenes de `release` de los cuatro servicios, y las de Core, Rules y Dispatch son
stubs con datos fijos. Con eso, de los nueve escenarios del SDD §8:

- **QAS-01** se ejecutó en la parte que QA permite (caso 5 del token) y **no cumple**: el Gateway
  acepta tokens emitidos por un endpoint público de desarrollo para cualquier tenant y rol (H-01).
- **QAS-06** se ejecutó por inspección y **no cumple**: 1 de 12 operaciones publicadas en QA tiene
  contrato OpenAPI.
- **QAS-03** tiene una medición p95 reproducible, pero sobre el stub de Dispatch: es línea base del
  perímetro, no verificación del escenario, que queda **bloqueado**.
- **QAS-02, QAS-04, QAS-05, QAS-07, QAS-08 y QAS-09** quedan **bloqueados** o **no medibles**, con la
  dependencia que los libera.

El monitoreo de QA (QA-MON-01) se limita a healthchecks por el Gateway, el log JSON de nginx con
`request_time` y `x_correlation_id`, los logs de contenedor y `docker stats`. No hay Prometheus,
Grafana, Datadog ni Kafka en QA.

## 2. Ambiente verificado (QA-MON-01, SCRUM-1274)

Evidencia: `qa/monitoreo_qas/evidencia/20261019_diagnostico/` (`qa_mon_01_*`).

### 2.1 Revisiones desplegadas

| Contenedor | Imagen | Revisión desplegada | Cabeza de la rama | Coincide |
|---|---|---|---|---|
| `mani-api-gateway` | `mani-apigateway:staging` | `6b475f9` | `release` `9874e93` | **No** (H-03) |
| `mani-core-service` | `mani-node:staging` | `6ca27ab` | `release` `6ca27ab` | Sí |
| `mani-rules-service` | `mani-java:staging` | `f8582aa` | `release` `f8582aa` | Sí |
| `mani-dispatch-service` | `mani-dotnet:staging` | `e40f84e` | `release` `e40f84e` | Sí |
| `mani-flutter-web` | `mani-flutter:staging` | `5e71358` | `release` `5e71358` | Sí |
| `mani-landing-web` | `mani-landing:staging` | `c015164` | — | No revisado |

Los seis contenedores estaban arriba desde el 17 oct 2026, sin reinicios.

### 2.2 Inventario de observabilidad

| Elemento | Documentado | Verificado en QA | Consulta reproducible |
|---|---|---|---|
| Healthchecks por el Gateway (`/health`, `/api/v1/{core,rules,dispatch}/health`) | Guía CFG4-03 §4.1 | Sí: 200 en los cuatro, 3 a 36 ms desde Calidad, con `X-Correlation-ID` devuelto | `verificar_monitoreo.sh calidad`; colección Newman, carpeta `qa_mon_01_healthchecks` |
| `healthcheck:` de Docker por contenedor | INFRAESTRUCTURA_MANI §9 | **No**: ninguno de los seis contenedores lo declara (H-04) | `verificar_monitoreo.sh vm_qa` |
| Log del Gateway | JSON con `request_time` y `x_correlation_id` | Sí. Se lee con `docker logs mani-api-gateway` (`access.log` es un enlace a stdout) | `verificar_monitoreo.sh vm_qa` |
| Logs de servicios | Logs estructurados en JSON (ADR-0006) | Core: una línea de texto por petición con `Correlation:`. Rules: texto con `[Correlation: ]`; en la muestra solo había líneas de arranque. Dispatch: formato por defecto de .NET; en la muestra solo había líneas de arranque, sin peticiones (H-05) | `docker logs` |
| Métricas (Prometheus, Grafana, Datadog) | ADR-0006, INFRAESTRUCTURA_MANI §20 | **No hay** contenedores ni puertos (9090, 3000, 9100, 8081, 3100, 8126 cerrados) ni endpoints `/metrics` en el código (H-05) | `verificar_monitoreo.sh calidad` y `vm_qa` |
| Recursos por contenedor | — | `docker stats` disponible | `verificar_monitoreo.sh vm_qa` (muestreo) |
| Kafka y topics | CONTRATOS_EVENTOS (`mani.*.v1`) | No hay broker (9092, 9093 y 2181 cerrados). ARQ-05 (SCRUM-1236) está en `blocked` y diferida al Sprint 5 según TRAZABILIDAD_INTEGRACION §1 | `verificar_monitoreo.sh` |
| k6 en Calidad | No figura en la Guía CFG4-03 | No instalado al 19 oct. `ejecutar_calidad.sh` lo instala (binario oficial v2.3.0 con sha256) | `k6 version` |

**Monitoreo durante la prueba:** `PENDIENTE_CORRIDA_CALIDAD`: muestreo de `docker stats` en QA y
cruce de las peticiones `qa1266-qas03-*` en el log del Gateway (`verificar_monitoreo.sh vm_qa`).

**Kafka durante la demo:** no aplica en el Sprint 4. No hay broker que monitorear.

## 3. Matriz QAS-01 a QAS-09 (SCRUM-1275)

| QAS | Atributo | Umbral (SDD §8) | Qué se hizo | Medido | Estado | Justificación |
|---|---|---|---|---|---|---|
| 01 | Seguridad, confidencialidad | 100 % de accesos cross-tenant rechazados | Caso 5 por el Gateway (sin token, esquema distinto de Bearer, firma alterada, vencido) y emisión de tokens con `dev-token` | Caso 5: 4 de 4 rechazos (401). `dev-token`: 200 y token aceptado para cualquier tenant y rol | **No cumple** | Un tercero obtiene acceso con el tenant que elija (H-01). Los casos 1 a 4 y 6 siguen **bloqueados**: el Core de `release` es un stub sin endpoints de lectura, listado, escritura, borrado ni KYC sobre datos reales |
| 02 | Fiabilidad, tolerancia a fallos | 0 operaciones confirmadas revertidas solo por fallo de notificación | Nada ejecutable | — | **Bloqueado** | No hay Notification Component ni adaptador FCM/APNs en Core (`develop` ni `release`); MANI-Node#43 los introduce y tiene cambios pedidos |
| 03 | Eficiencia, comportamiento temporal | p95 ≤ 500 ms para la consulta bajo 300 sesiones y 50 req/s | k6 sobre `POST /api/v1/dispatch/match` (stub). Humo desde el equipo del autor y corrida nominal desde Calidad | Humo: p95 89,0 ms con 10 VUs y 2 req/s. Nominal: `PENDIENTE_CORRIDA_CALIDAD` | **Bloqueado** (con línea base) | La ruta real (MANI-.NET #3 + MANI-Node#43) no está en QA. La medición sobre el stub no incluye base de datos ni elegibilidad: no acredita el escenario |
| 04 | Mantenibilidad, modificabilidad | 0 cambios obligatorios en consumidores ante un cambio interno compatible de Rules | Revisión de PR de Rules | — | **No medible** | El único cambio de Rules fusionado (MANI-Java #2, SCRUM-1070) agrega un endpoint y obligó a cambiar Core (MANI-Node#23): no es un cambio interno compatible. No hay contract tests de Rules en ejecución |
| 05 | Flexibilidad, escalabilidad | Escalamiento de 2 a 6 réplicas sin cambio de código | Nada ejecutable | — | **No medible** | QA corre en Docker Compose; no hay Kubernetes, HPA ni Prometheus (INFRA-01/02 sin decidir) |
| 06 | Compatibilidad, interoperabilidad | 100 % de APIs con OpenAPI y contract tests críticos aprobados antes de promoción | Inventario de rutas publicadas en QA contra `core.yaml` y `rules.yaml` | 1 de 12 operaciones con contrato (8,3 %); contract tests solo para Core `develop` en memoria | **No cumple** | [`qas06_api_vs_contrato.md`](../qa/monitoreo_qas/qas06_api_vs_contrato.md) |
| 07 | Adecuación funcional, corrección | 100 % de escenarios críticos aprobados; en asignación: un 200, el resto 409, 0 dobles asignaciones | Arnés k6 de aceptación concurrente contra el stub (validación del arnés) | Arnés: 1×200 y 19×409 en dos corridas de 20; reintento del ganador: 409. Corrida de 50 en Calidad: `PENDIENTE_CORRIDA_CALIDAD` | **Bloqueado** | El stub guarda la asignación en memoria: un resultado correcto no prueba la exclusión en base. Falta MANI-.NET #1 (SCRUM-1074) en QA y una solicitud PENDIENTE en `MANI-QA`. Ranking y tarifa responden con datos fijos de stub |
| 08 | Interacción, protección contra errores de usuario | 100 % de acciones irreversibles con validación o confirmación | Nada ejecutable | — | **Bloqueado / no medible** | Maestro no tiene ticket ni instalación; el Core de QA no tiene endpoints de escritura que validar |
| 09 | Safety, protección ante fallos | 0 transacciones críticas en estado ambiguo por fallas de terceros | Nada ejecutable | — | **Bloqueado** | La carga de KYC existe en Core `develop`, no en QA, y no hay adaptador de fault injection |

## 4. Resultados por escenario ejecutado

### 4.1 QAS-01: caso 5 y emisión de tokens

**Fecha:** 19 oct 2026, 21:48 UTC. **Origen:** equipo del autor, en la red del campus. **Fuente del
token:** `dev_token`. Evidencia: `evidencia/20261019_diagnostico/qas01_dev_token_mac_2148z.txt`
(sin tokens).

| # | Prueba | Esperado | Observado |
|---|---|---|---|
| 1 | `POST /api/v1/core/auth/dev-token` por el Gateway | 404 (ruta inexistente fuera de desarrollo) | **200**; emite un JWT HS256 |
| 2 | Token emitido para el tenant t2, rol `cliente` | — | `app_metadata.tenant_id` = t2, vigencia 600 s |
| 3 | `GET /api/v1/core/profiles/me` con ese token | 401 | **200** con `tenantId` = t2 |
| 4 | `POST` a `rules/evaluate-rate`, `rules/rank-allies` y `dispatch/match` con ese token | 401 | **200** en los tres |
| 5 | Token para un tenant inexistente con rol `admin` | 401 | **200** con `tenantId` inexistente y `role` = `admin` |
| 6 | Firma alterada | 401 | 401 |
| 7 | Token vencido | 401 | 401 |
| 8 | Sin `Authorization` | 401 | 401 |
| 9 | `Authorization: Token ...` | 401 | 401 |

La corrida reproducible desde Calidad (`newman/qas01_perimetro.postman_collection.json`) queda en
`PENDIENTE_CORRIDA_CALIDAD`.

### 4.2 QAS-03: línea base del perímetro

| Campo | Humo (equipo del autor) | Nominal (Calidad) |
|---|---|---|
| Fecha (UTC) | 2026-10-19T21:51:29Z | `PENDIENTE_CORRIDA_CALIDAD` |
| Ruta | `POST /api/v1/dispatch/match` (stub) | Igual |
| Fuente del token | `dev_token` | `dev_token` |
| Carga | 10 VUs, 2 req/s, rampa 5 s, 20 s sostenidos | 300 VUs, 50 req/s, rampa 60 s, 5 min sostenidos |
| Peticiones sostenidas | 40 | `PENDIENTE_CORRIDA_CALIDAD` |
| Tasa de status 200 | 1,0 | `PENDIENTE_CORRIDA_CALIDAD` |
| p95 | 89,0 ms | `PENDIENTE_CORRIDA_CALIDAD` |
| p95 en el Gateway (`request_time`) | No medido | `PENDIENTE_CORRIDA_CALIDAD` |
| Umbral | ≤ 500 ms | ≤ 500 ms |
| Validez para QAS-03 | No: carga y origen distintos, stub | No: stub sin base de datos |

**Declaración de ruta:** el SDD §8 pide medir la consulta de aliados por categoría y zona en el
dominio de disponibilidad del Core. La implementación en curso la ubica en Dispatch
(`POST /api/v1/dispatch/match`, MANI-.NET #3), que consulta al Core (`GET /allies/eligible`,
MANI-Node#43). Ninguna de las dos está desplegada en QA. La medición sobre el stub no se extrapola
a QAS-03.

### 4.3 QAS-07: validación del arnés

`k6/qas07_aceptacion_concurrente.js` contra el stub, 20 aceptaciones simultáneas sobre una misma
solicitud, dos corridas: 1×200 y 19×409 en ambas. Una primera versión del arnés generaba un id de
solicitud distinto por VU y produjo 2×200; se corrigió fijando el id en `setup()`. El reintento del
ganador recibe 409: el stub no es idempotente, a diferencia de lo que declara MANI-.NET #1. Esta
corrida valida el arnés, no QAS-07.

## 5. Hallazgos

| ID | Severidad | Hallazgo | Evidencia | Responsable sugerido |
|---|---|---|---|---|
| H-01 | Crítica | `POST /api/v1/core/auth/dev-token` está publicado sin autenticación por el Gateway de QA y firma, con el secreto real del ambiente, tokens para cualquier `tenantId`, `userId` y rol que pida el cliente. El Gateway los acepta en las rutas protegidas de Core, Rules y Dispatch. En MANI-Node `release` (`6ca27ab`) la ruta no tiene guarda de entorno; `develop` ya la restringe a `development` y `test` (`isDevTokenEnabled`). `release` también conserva en el código un secreto JWT de respaldo, que en QA no se usa porque `SUPABASE_JWT_SECRET` está definida | §4.1; `qa_mon_01_calidad_2103z.txt` | Core (MANI-Node), Daniel para el despliegue |
| H-02 | Alta (inferida) | `MANI-QA` y `MANI` firman con ECC P-256 (ES256); HS256 solo queda como llave previa. La validación que usa el Gateway (`/api/v1/auth/validate-token`) acepta solo HS256/384/512 en `release` y solo HS256 en `develop`; los PR de Dispatch validan con llave simétrica. Un token real emitido hoy por Supabase sería rechazado con 401. No se confirmó con un inicio de sesión real | Dashboard de Supabase, JWT Keys (19 oct); código de `release` y `develop` | Core y Dispatch |
| H-03 | Media | El Gateway de QA corre `6b475f9`, no la cabeza de `release` (`9874e93`): la imagen nueva se descargó pero el contenedor no se recreó. Lo desplegado no coincide con la rama que se promovió | `qa_mon_01_vm_qa_1746z.txt` | Daniel |
| H-04 | Media | Ningún contenedor de QA declara `healthcheck:` en `docker-compose.qa.yml`, aunque INFRAESTRUCTURA_MANI §9 lo exige | `qa_mon_01_vm_qa_1720z.txt` | Daniel |
| H-05 | Media | No hay plataforma de métricas ni de logs centralizados en QA, y los logs de Core, Rules y Dispatch no son JSON estructurado (ADR-0006). En la muestra, Rules y Dispatch no registraron las peticiones atendidas | §2.2 | Daniel y dueños de servicio |
| H-06 | Baja | El Gateway reemplaza los 401 del Core por un mensaje único (`UNAUTHORIZED`), sin distinguir token vencido, firma inválida o falta de tenant | §4.1, pruebas 6 a 9 | Gateway |

Observaciones documentales (no son defectos del producto):

- SDD §8, QAS-03: el método todavía cita «la excepción de la sección 2.1», que §2.2 retiró. El
  artefacto que nombra (Core, dominio de disponibilidad) no coincide con la implementación en curso
  (Dispatch).
- INFRAESTRUCTURA_MANI §5.2 describe un «Supabase DEV compartido». Según la decisión verbal del 19 oct
  2026 (Daniel, Nicolás León y Sara), solo existen `MANI` (PROD) y `MANI-QA` (QA), con el mismo
  esquema, y el desarrollo usa base local. Los proyectos de otra organización vinculados a
  MANI-.NET quedan fuera. Falta reflejarlo en la documentación.
- SDD §8 cita SCRUM-1121 (k6) y SCRUM-1122 (ZAP); ninguno es visible en Jira al 19 oct.

## 6. Reproducibilidad

- Todos los scripts leen la configuración de variables de entorno y no contienen secretos
  ([README](../qa/monitoreo_qas/README.md)).
- Umbral de QAS-03 declarado en `thresholds` de k6; criterio de QAS-07 declarado en `thresholds`.
- Cada petición de carga lleva `X-Correlation-ID` `qa1266-<escenario>-<vu>-<iteración>`, que permite
  recalcular la latencia del lado del Gateway con el log de nginx.
- La evidencia se redacta con `redactar_evidencia.mjs` antes de versionarse.

## 7. Límites y lo no verificado

- No se ejecutó ninguna prueba sobre datos reales de `MANI-QA`: los servicios desplegados no la
  consultan.
- H-02 es inferencia de configuración y código; falta un inicio de sesión real en `MANI-QA`.
- La causa de que las rutas protegidas de Rules y Dispatch respondan 200 con el Gateway `6b475f9`
  (cuyo `proxy_pass` termina en `/`) no se explicó; se observó el 200, no se supuso.
- El monitoreo de QA no tiene retención: `docker logs` conserva lo que el contenedor no rotó.
- `PENDIENTE_CORRIDA_CALIDAD`: corrida desde Calidad. Al cierre de la tarde del 19 oct la red
  10.43.x.x no estaba alcanzable desde fuera del campus.

## 8. Dependencias que liberan escenarios

| Escenario | Se libera con | Responsable |
|---|---|---|
| QAS-01 casos 1 a 4 y 6 | Core real en QA (`develop` → `release`), endpoints de lectura, listado, escritura, borrado y KYC; H-01 y H-02 corregidos | Core, Daniel |
| QAS-02 | Notification Component con adaptador de prueba (MANI-Node#43) | Core |
| QAS-03 | MANI-.NET #3 y MANI-Node#43 fusionados y desplegados en QA | Dispatch, Core, Daniel |
| QAS-04 | Un cambio interno compatible de Rules y contract tests de Rules en CI | Rules |
| QAS-05 | Kubernetes con HPA y Prometheus (INFRA-01/02) | Daniel |
| QAS-07 | MANI-.NET #1 (SCRUM-1074) en QA y solicitud PENDIENTE sembrada en `MANI-QA` | Dispatch, Daniel |
| QAS-08 | Herramienta para flujos de pantalla (Maestro sin ticket) y endpoints de escritura | Equipo |
| QAS-09 | Core con carga de KYC en QA y adaptador de fault injection | Core |

## 9. Cumplimiento del DoD de SCRUM-1266

| Criterio | Estado |
|---|---|
| Matriz QAS-01..09 con ejecutado, no aplicable o bloqueado y justificación | Cumplido (§3) |
| Scripts y configuración versionados | Cumplido (`qa/monitoreo_qas/`) |
| Capturas o enlaces a logs, informes o series de métricas reales por escenario | Parcial: QAS-01, QAS-03 (humo) y QAS-06 con evidencia; corrida de Calidad `PENDIENTE_CORRIDA_CALIDAD` |
| Al menos una medición p95 reproducible | Cumplido con la limitación de §4.2 (línea base del perímetro) |
| Incidentes y regresiones registrados | Pendiente: los hallazgos H-01 a H-06 se registran en Jira según decida QA |
| Informe entregado a la Scrum Master y a la PO | Pendiente de entrega |

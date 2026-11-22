# Barrido de escenarios QAS sin medición del Sprint 6

> Evidencia de QA del Sprint 6. Resultado en el [SDD §8](../../../../02-arquitectura/SDD.md). Mantiene: QA (Santiago Hernández).

22 de noviembre de 2026, de 02:55Z a 03:05Z. Revisión de los escenarios del SDD §8 cuyo último corte era de octubre o del 4 de noviembre y que ninguna tarea del Sprint 6 volvió a medir. Los escenarios medidos en el sprint (T-41 a T-46) no se tocan.

**Fuentes:** QA (`10.43.100.141`) con `release` del 20 nov (Core `73c28f4`, Dispatch `eedb112`, Rules `348f6d9`, Gateway `ee5000c`); Prometheus de la VM de Calidad (`10.43.98.196`); el mapa de versiones de DevOps del 14 nov (`08-infraestructura/01-mapa-ambientes-y-versiones.md`); y el código de `release`. Las consultas a QA fueron de solo lectura, salvo el intento de modificar los registros inmutables de QAS-11, que corrió dentro de una transacción que se revirtió.

**Regla de estados.** Igual que en T-43: **Parcial** cuando el umbral se cumple en parte o el método se ejecutó en parte; **No cumple** cuando falta lo que el umbral exige; **No medido** cuando el método no se pudo ejecutar, con el motivo actualizado al 22 nov.

## 1. Resultado

| QAS | Antes | Ahora | Dato del 22 nov |
|---|---|---|---|
| 02 Tolerancia a fallos | Bloqueado (20 oct) | **Parcial** | El bloqueo ya no existe: Core tiene el adaptador `mock_falla` (SCRUM-1662) para simular la caída de push, con reintento por clave de idempotencia. Sus pruebas pasan (55 de 55 en proveedores). En QA el Core corre con el proveedor por omisión (`mock`), así que la falla no se inyectó en QA. |
| 09 Protección ante fallos | Bloqueado (20 oct) | **Parcial** | KYC ya está en QA. El Storage de KYC tiene falla inyectable (`STORAGE_FALLA`, SCRUM-1662) y sus pruebas pasan. No se inyectó la falla en QA. |
| 05 Escalabilidad | No medido (21 oct) | **No medido** | Motivo actualizado: escalar con `docker compose --scale` cambia el QA compartido y es una decisión de DevOps. El umbral es el de la opción B (acta SCRUM-1684). |
| 06 Interoperabilidad | No cumple (19 oct) | **Parcial** | Ya no es 1 de 12: los contratos de `release` describen 141 operaciones (T-43) y el CI del Gateway valida los contratos (`validate:openapi`, Spectral) y corre un gate de contrato con Newman. No se verificó en este corte que el 100 % de las rutas publicadas tenga contrato; MANI-docs#81 reporta 127 de 127, sin fusionar. |
| 11 No repudio | No medido (4 nov) | **Parcial** | En QA, `UPDATE` y `DELETE` sobre `evento_servicio` los rechaza el trigger («es inmutable»); `TRUNCATE` y la modificación de `transaccion_evento` los rechaza el permiso. Siete tablas tienen trigger de inmutabilidad. La aceptación (T-46) dejó actor, rol y correlation ID en las 10 filas. Falta ejecutar un pago en este corte. |
| 12 Accountability | Parcial (21 oct) | **Parcial** | Asignación y creación: 10 de 10 eventos con actor, rol y correlation ID (el de la petición k6). Tarifa, reglas, pagos y consultas guardan actor y correlation ID. **La aprobación de aliado no guarda actor ni correlation ID** en la base (tabla `aliado`). Cancelación no ejecutada en este corte. |
| 14 Resistencia | No cumple (4 nov) | **Parcial** | El rate limiting ya existe y se observó: 429 por `write_limit` (60/min por IP, burst 40) en QAS-13. Sonar: gate de código nuevo en los 6 repos (T-44); Flutter tiene 42 Critical abiertos de mantenibilidad. No se consultaron vulnerabilidades Critical/High ni se corrió OWASP ZAP. |
| 16 Disponibilidad | No medido (19 nov) | **Cumple** | Sondas del blackbox de Prometheus, 7 días continuos (15 a 22 nov, unas 20 100 muestras por sonda). QA: Core 99,965 %, Dispatch 99,990 %, Rules 99,995 %, Gateway 99,995 %. PROD: Core 99,965 %, Dispatch, Rules y Gateway 100 %. Todas ≥ 99,9 %. No se descontaron ventanas de mantenimiento. |
| 18 Utilización de recursos | No medido (4 nov) | **No medido** | Motivo actualizado: los contenedores de QA ya tienen límites (SCRUM-1672: Core, Dispatch y Rules 1 CPU; Gateway 0,5 CPU), pero Prometheus no tiene CPU por contenedor (§2). |
| 22 Analizabilidad | Parcial (21 oct) | **Parcial** | Correlation ID: Core, Dispatch y Rules devuelven el mismo ID enviado, una sola vez, y lo generan si falta (H-07 ya no se reproduce). Logs: Gateway y Rules en JSON con el ID; **Core y Dispatch en texto plano**. |
| 23 Capacidad para ser probado | Parcial (21 oct) | **Parcial** | El gate exige cobertura de código nuevo ≥ 80 % en Java, .NET, Landing y Flutter; el Gateway la excluye. Contract tests obligatorios solo en el CI del Gateway. La cobertura de casos de uso críticos (≥ 90 %) no se recalculó. |
| 24 Adaptabilidad | No medido (4 nov) | **No cumple** | Cada ambiente usa una imagen distinta: `develop`, `staging` y `latest`, con digests diferentes (mapa del 14 nov y QA hoy: Core `438921ef…`). Las imágenes se construyen por rama, no se promueve la misma. La prueba de arranque de Flutter con otro `.env` no se hizo. |
| 25 Instalabilidad | No medido (4 nov) | **Cumple** | Script versionado de un comando: `MANI-APIGateway/infra/qa/desplegar_release_qa.sh` (PR #91). DevOps lo cronometró en 13 s (SCRUM-1674) y el despliegue de `release` del 20 nov terminó con salud en 2 min 24 s (T-42). |
| 26 Reemplazabilidad | No medido (4 nov) | **Parcial** | Push: dos adaptadores (`mock` y `mock_falla`) elegidos por configuración, con pruebas de contrato comunes; el cambio no toca dominio. Pagos: solo existe `mock`. Pruebas de proveedores 55 de 55. |
| 27 Coexistencia | No medido (4 nov) | **No medido** | Motivo actualizado: límites de CPU y memoria configurados en los 13 contenedores de QA, pero sin serie por contenedor (§2) no se puede ver si un servicio degrada a los demás. |
| 30, 31 y 32 Usabilidad | No medido (4 nov) | **No medido** | Motivo actualizado: la PO no ha elegido el método de T-45 (SCRUM-1682): prueba con 3 a 5 personas por rol o revisión heurística. |
| 37 Restricción operativa | No medido (4 nov) | **Parcial** | Core define 15 códigos de conflicto por estado (`MANI-SOL-409`, `-409E`, `MANI-COT-409E`, `MANI-PAG-409K`…). En QA se observaron 409 al aceptar una solicitud ya asignada y 403 al aceptar sin oferta o sin elegibilidad (T-46), sin cambio de estado. La matriz Newman completa no se ejecutó. |
| 40 Integración segura | No medido (4 nov) | **Parcial** | Timeouts: Dispatch 3 s hacia Core, Core 3 s hacia Dispatch y Rules con un reintento, proveedores 5 y 10 s. Validación de respuesta con contratos de proveedores (pruebas pasan). **Circuit breaker solo en Rules**; Core y Dispatch no lo tienen. No hubo inyección en QA. |
| 42 Idempotencia | Parcial (21 oct) | **Parcial** | En QA, la aceptación repetida devuelve 200 con `isRetry: true` sin segunda asignación (T-46), y crear solicitud acepta `claveIdempotencia`. Pagos y mensajes también usan clave; pagos rechaza la misma clave con otro cuerpo (`MANI-PAG-409K`). No se corrió en QA el caso «misma clave, otro cuerpo». |
| 43 TLS | No medido (20 oct) | **Parcial** | En la VM de QA, el puerto 443 acepta TLS 1.2 y 1.3, rechaza TLS 1.1, y el 80 redirige con 301 a HTTPS. Pero el **8080 sirve la app y la API por HTTP sin TLS**, y es el puerto que se usa en QA. Desde fuera de la VM, 80 y 443 no responden (cortafuegos). PROD no se midió. |

## 2. Utilización de recursos y coexistencia (QAS-18 y 27)

Los límites existen en los 13 contenedores (`vm_qa_22nov_0257z.txt`). Para medir el uso se consultó cAdvisor en Prometheus durante las cargas de T-42 (20 nov 19:25Z a 19:45Z y 21 nov 22:43Z a 22:51Z): `container_cpu_usage_seconds_total` del job `mani_qa_cadvisor` tiene **una sola serie**, la del host, con las etiquetas `cpu`, `id`, `instance` y `ambiente`, y **sin nombre de contenedor** (`qas18_cpu_contenedores_22nov_0302z.txt`). El cAdvisor de QA no está viendo los contenedores de Docker (falta montar su socket o sus cgroups) o el scrape descarta esas series. Mientras no se corrija, QAS-18 y 27 no se pueden medir.

## 3. Hallazgos

| # | Hallazgo | QAS | Responsable sugerido |
|---|---|---|---|
| H-B-1 | El puerto 8080 de QA expone la app y la API sin TLS, en paralelo al 443. | 43 | DevOps |
| H-B-2 | Las imágenes se construyen por rama y ambiente; no se promueve la misma imagen de QA a PROD. | 24 | DevOps |
| H-B-3 | La aprobación de aliado no deja actor ni correlation ID en la base. | 12 | Equipo de Core |
| H-B-4 | Core y Dispatch registran logs en texto plano. | 22 | Equipo de Core y Dispatch |
| H-B-5 | Core y Dispatch no tienen circuit breaker; Dispatch corta a los 3 s (mismo timeout de SCRUM-1651). | 40 | Equipo de Core y Dispatch |
| H-B-6 | Pagos solo tiene el adaptador `mock`. | 26 | Equipo de Core |
| H-B-7 | El cAdvisor de QA no exporta métricas por contenedor: Prometheus solo tiene la serie del host. | 18 y 27 | DevOps |

## 4. Evidencia (esta carpeta)

- `vm_qa_22nov_0257z.txt`: puertos y TLS desde la VM, límites por contenedor, digests de QA, formato de logs, tablas con actor y correlation ID, triggers de inmutabilidad, eventos de T-46 e intentos rechazados de UPDATE, DELETE y TRUNCATE.
- `vm_calidad_prometheus_22nov_0258z.txt`: disponibilidad por sonda en 7 y 14 días.
- `qas18_cpu_contenedores_22nov_0302z.txt`: series de CPU de cAdvisor (solo la del host).
- `qas43_tls_22nov.txt`: TLS y puertos desde fuera de la VM.
- `qas22_correlacion_22nov.txt`: correlation ID por el Gateway, con y sin cabecera.
- `revision_codigo_22nov.txt`: circuit breaker, timeouts, idempotencia, códigos de conflicto, adaptadores y contract tests en `release`.
- `core_pruebas_proveedores_22nov.txt`: pruebas de proveedores y falla inyectable del Core (55 de 55).

Scripts en `scripts/`: `revisar_vm_qa.sh`, `revisar_vm_calidad.sh` y `revisar_cpu_contenedores.sh`. No guardan ni imprimen claves ni tokens.

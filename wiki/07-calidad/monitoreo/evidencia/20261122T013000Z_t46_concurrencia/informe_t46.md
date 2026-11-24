# T-46 (SCRUM-1683): aceptación concurrente sobre Dispatch real, QAS-07 y QAS-41

> Evidencia de QA del Sprint 6. Resultado en el [SDD §8](../../../../02-arquitectura/SDD.md) (filas QAS-07 y QAS-41).

22 de noviembre de 2026, de 01:30Z a 01:56Z. Ambiente MANI-QA (`10.43.100.141`, Gateway por el puerto 8080) con `release` del 20 nov: Dispatch `eedb112`, Core `73c28f4`, Rules `348f6d9`. El Core ya usa el pooler en modo transacción (cambio de DevOps del 21 nov). k6 v2.3.0 desde la máquina de QA.

**Criterio de la tarea.** Con aceptaciones simultáneas, una responde 200 y las demás 409. Ranking, tarifa, asignación y conflicto correctos en el 100 % de los casos.

## 1. Resultado

| QAS | Umbral (SDD §8) | Medición | Estado propuesto |
|---|---|---|---|
| **41** Concurrencia de asignación | Una aceptación confirmada con 200, las demás con 409, 0 dobles asignaciones y reintentos idempotentes | 5 rondas de 37 aceptaciones simultáneas entre 2 aliados elegibles. En las 5: **1 asignación**, todos los 200 con el mismo aliado, todos los 409 (`MANI-SOL-409`) para el otro aliado, **0 respuestas inesperadas**. El reintento del ganador da 200 con `isRetry: true`. La base confirma **un solo aliado por solicitud**, el mismo que ganó en k6, y **un solo aviso `SOLICITUD_ASIGNADA`**. | **Cumple**, con la diferencia de la §3 |
| **07** Corrección funcional | 100 % de escenarios críticos de ranking, tarifa, asignación y conflicto aprobados | **Asignación y conflicto:** las 5 rondas de QAS-41. **Ranking:** `AllyRankerTest` 12 de 12, y en QA el orden de `eligible-allies` respeta la regla (el aliado calificado, 4,86 de 5 con puntaje 0,972, va primero; el que no tiene calificaciones va después). Sin aliados en la zona responde 0 candidatos, coherente con `NO_ELIGIBLE_ALLIES`. **Tarifa:** `RateEvaluatorTest` y `RatesControllerTest` 19 de 19, y en QA la tarifa de referencia de Plomería (80.000 a 350.000 COP, típica 150.000, versión 5) llega al cliente y al aliado asignado; el aliado que perdió recibe 404, sin datos. Rules completo: **142 de 142 pruebas** en `release`. | **Cumple** |

### Rondas

| Ronda | Solicitud | Ganador | Asignada | Reintentos del ganador (200) | 409 del perdedor | Otros | Tiempo (mín. / mediana / máx.) |
|---|---|---|---|---|---|---|---|
| 1 | `03490d4a` | `empleado_directo.t1` | 1 | 17 | 19 | 0 | 2,2 / 3,9 / 5,7 s |
| 2 | `6ef93e76` | `aliado.t1` | 1 | 18 | 18 | 0 | 2,2 / 3,8 / 5,6 s |
| 3 | `0b226a4a` | `aliado.t1` | 1 | 18 | 18 | 0 | 2,2 / 3,9 / 5,6 s |
| 4 | `04b65083` | `aliado.t1` | 1 | 18 | 18 | 0 | 2,1 / 3,8 / 5,5 s |
| 5 | `5aedc113` | `aliado.t1` | 1 | 18 | 18 | 0 | 2,2 / 3,8 / 5,6 s |

Cada ronda sigue el flujo de la app: `cliente.t1` crea la solicitud (Plomería, sitio en Niza, dentro de Suba), la orquesta (`DISPATCHED`, 2 candidatos, 2 ofertas `OFERTA_DESPACHO`) y k6 lanza las aceptaciones de `aliado.t1` y `empleado_directo.t1` repartidas en partes iguales.

## 2. Hallazgos

| # | Hallazgo | Escenario | Responsable sugerido |
|---|---|---|---|
| H-46-1 | En la primera ronda, sin ofertas, 19 de 37 aceptaciones simultáneas recibieron **503 `CORE_SERVICE_UNAVAILABLE`** a los 5 o 6 s, aunque Core solo tenía que rechazarlas (403 «no recibiste una oferta»). Con concurrencia, Dispatch se queda sin respuesta de Core antes de su timeout. Es la misma causa de fondo que T-42 (`HttpClient.Timeout` de 3 s, SCRUM-1651). Con ofertas no pasó, pero el margen es corto. | QAS-41 y 15 | Equipo de Dispatch y Core |
| H-46-2 | Las aceptaciones se atienden en serie (bloqueo de fila en Core): la última de 37 tarda unos 5,6 s. Es correcto para la exclusión, pero con más aliados el tiempo crece lineal y se acerca al timeout de 3 s de Dispatch por petición. | QAS-41 y 03 | Equipo de Core |
| H-46-3 | Los 50 aliados de broadcast del tenant 1 (`aliado_broadcast_XX.t1`) existen solo en la base, sin cuenta de login: no sirven para pruebas por el Gateway. | QAS-41 | QA y DevOps (semilla) |

## 3. Diferencias con el método del SDD

- **37 aceptaciones simultáneas, no 50.** El Gateway admite 41 escrituras de golpe por IP (`write_limit`, 60 por minuto con `burst=40 nodelay`). Cada ronda gasta 1 en crear la solicitud, 1 en orquestarla y 1 en el reintento del ganador. Para 50 haría falta otra IP o relajar el límite en QA durante la prueba.
- **2 aliados, no 50.** Son los únicos del tenant 1 que tienen login, atienden Plomería y comparten zona (`cobertura_aliados_22nov_0132z.txt`). Las demás aceptaciones son reintentos del mismo aliado, que deben dar 200 idempotente.
- **La verificación en base** se hizo con una consulta equivalente a `qas07_verificar_asignacion.sql`, por el contenedor del Core y dentro de una transacción de solo lectura que se revierte.
- **Rules local con JDK 25:** Byte Buddy y JaCoCo del proyecto soportan hasta Java 23, así que se corrió con `-Djacoco.skip=true -DargLine=-Dnet.bytebuddy.experimental=true`. En CI, con su JDK, el mismo commit pasa.

## 4. Datos que quedaron en QA

- 5 solicitudes «Prueba QA T-46 … no atender» en estado ASIGNADA (una a `empleado_directo.t1` y cuatro a `aliado.t1`).
- 2 solicitudes de las pruebas previas, PENDIENTE y sin aliado: `16188038` y `b94cdb40` (sitio en Bosa, sin aliados que la cubran).
- No se cancelaron. Se pueden cancelar como `cliente.t1` si se decide limpiar.

## 5. Evidencia (esta carpeta)

- `qas41_rondas_22nov_0146z.txt` y `qas41_rondas_22nov_0147z.txt`: las 5 rondas, con cada respuesta (estado, código, aliado y tiempo). `qas41_ronda*_*.json`: resumen de k6 por ronda.
- `qas41_verificacion_base_22nov_0152z.txt`: estado, aliado persistido y avisos por solicitud.
- `cobertura_aliados_22nov_0132z.txt`: categorías y zonas de los aliados del tenant 1 y sitios de `cliente.t1`.
- `qas07_rules_mvn_test_22nov.txt`: pruebas de Rules en `release` (142 de 142).
- `qas07_ranking_vivo_22nov_0155z.txt`: ranking y tarifa de referencia en QA.
- `descartadas/`: la ronda sin ofertas (H-46-1).

Scripts en `scripts/`: `correr_t46.sh` (tokens y rondas), `k6_qas41_aceptacion.js`, `cobertura_aliados.sh` y `verificar_asignacion.sh`. No guardan ni imprimen tokens ni contraseñas; los tokens viven en un archivo temporal con permisos 600.

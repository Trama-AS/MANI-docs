# SCRUM-1679 (T-42): re-medición de QAS-03, QAS-15 y QAS-19

**Fecha de la corrida:** 2026-11-20, 19:25Z a 19:49Z (hora Colombia 14:25 a 14:49)
**Ambiente:** MANI-QA (VM `10.43.100.141`), generador k6 en la VM de Calidad (`10.43.98.196`), Gateway por el puerto 8080
**Responsable:** Santiago (QA)
**Método:** SDD §8 (QAS-03, QAS-15 y QAS-19), el mismo de la medición del Sprint 5 ([`REPORTE_QA_SPRINT5.md`](../../../REPORTE_QA_SPRINT5.md))

**Resultado: los tres escenarios siguen en No cumple** frente a los umbrales del SDD §8 (p95 ≤ 500 ms, 5xx < 1 %, 50 req/s con 300 sesiones). El aumento del pool (SCRUM-1652) no alcanza, y la parte de timeouts de SCRUM-1651 no está en el código desplegado.

## 1. Qué se midió

| Componente | Versión en QA (`org.opencontainers.image.revision`) |
|---|---|
| Core (MANI-Node) | `73c28f4` |
| Dispatch (MANI-.NET) | `eedb112` |
| Gateway | `ee5000c` |
| Rules (MANI-Java) | `348f6d9` |
| Flutter web | `b74d923` |

Preparación del ambiente, el mismo día:

- Promoción de `develop` a `release` en los cinco repos y despliegue en QA.
- Migraciones 0040, 0041 y 0042 aplicadas a las 19:16:56Z.
- Pools según MANI-APIGateway#97: Core `DATABASE_POOL_MAX=30`, Dispatch `Maximum Pool Size=10`. La base admite 60 conexiones.

Las cuatro sondas de salud respondían 200 antes, entre y después de las pruebas. No hubo reinicios ni OOM.

## 2. Resultados

| Prueba | Carga | req/s sostenidas | 5xx | p95 |
|---|---|---|---|---|
| Humo, 30 s | 10 VU, 2 req/s | 2 | 0 % | elegibles 2.870 ms; ofertas 2.978 ms; perfil 1.779 ms |
| **QAS-03** consulta, 5 min | 300 VU, 50 req/s | 49,98 | **100 %** (14.995 peticiones) | elegibles **3.025 ms** |
| **QAS-15 y QAS-19** mezcla, 15 min | 300 VU, 50 req/s | **31,91** | **81,4 %** (28.719 peticiones) | elegibles 3.022; ofertas 3.021; perfil 21.011; sitios 11.217; tarifa 11.222 ms |

| QAS | Umbral | 5 nov (Sprint 5) | 20 nov | Estado |
|---|---|---|---|---|
| 03 Comportamiento temporal | p95 ≤ 500 ms | 3.015 ms | 3.025 ms (2.870 ms sin carga) | No cumple |
| 15 Ausencia de fallos | 5xx < 1 % en 15 min | 66,7 % | 81,4 % | No cumple |
| 19 Capacidad | 50 req/s, 300 sesiones | 39,1 req/s | 31,9 req/s | No cumple |

Recursos: CPU máxima de Core 55 % y de Dispatch 55,5 %. El límite no es la CPU.

## 3. Causa medida

Datos del análisis de logs de la ventana 19:25:40Z a 19:49:10Z:

1. **Latencia hacia la base:** 10 consultas `SELECT 1` dieron entre 96,3 y 97,6 ms cada una. Un `eligible-allies` hace cerca de 9 sentencias, o sea ~1 s de conexión ocupada por petición. Con 30 conexiones, el techo teórico es ~30 req/s, lo que coincide con las 31,9 req/s medidas.
2. **Pool de Core agotado:** 20.956 `timeout exceeded when trying to connect` (pg-pool, `withTenantContext`) y 8.766 respuestas 500. Además, 2.232 `EMAXCONN` / `max clients`; no se confirmó si ese límite viene del pooler de la base.
3. **Timeout de Dispatch:** 27.217 `TaskCanceledException` por el `HttpClient.Timeout` de 3 s hacia Core (`MANI-.NET/Program.cs:37`). Los 503 del Gateway tienen una mediana de 3,009 s. SCRUM-1651 pedía ≥ 10 s y eso no está desplegado.
4. **Doble carga en Core:** el Gateway llama a `/api/v1/auth/validate-token` en cada petición (46.693 llamadas en la ventana).
5. **Sin carga tampoco se cumple:** las elegibles exitosas tienen una mediana de 1,07 s, y en la prueba de humo el p95 es de 2.870 ms. QAS-03 no se arregla solo con más pool.

## 4. Qué haría falta para cumplir (no es trabajo de QA)

- Bajar la latencia a la base: misma región o red que la VM.
- Usar un pooler en modo transacción con más capacidad, o subir `max_connections`.
- Reducir las sentencias por petición en `eligible-allies` y cachear la validación del token en el Gateway.
- Subir el timeout de Dispatch hacia Core a ≥ 10 s (pendiente de SCRUM-1651).

## 5. Evidencia

Salidas de la corrida, en esta carpeta:

| Archivo | Qué contiene |
|---|---|
| [`verificar_20nov_1859z.txt`](verificar_20nov_1859z.txt) | Versiones y pools antes del despliegue |
| [`ensayo_0040_0042_20nov_1914z.txt`](ensayo_0040_0042_20nov_1914z.txt), [`aplicar_0040_0042_20nov_1916z.txt`](aplicar_0040_0042_20nov_1916z.txt) | Migraciones 0040 a 0042: ensayo con `ROLLBACK` y aplicación |
| [`pools_ensayo_20nov_1914z.txt`](pools_ensayo_20nov_1914z.txt), [`pools_aplicar_20nov_1917z.txt`](pools_aplicar_20nov_1917z.txt), [`pools_aplicar_20nov_1919z.txt`](pools_aplicar_20nov_1919z.txt) | Configuración de pools (la segunda aplicación no encontró cambios) |
| [`despliegue_release_20nov_1917z.txt`](despliegue_release_20nov_1917z.txt), [`despliegue_release_20nov_1919z.txt`](despliegue_release_20nov_1919z.txt) | Despliegue. Las dos corridas se solaparon; el estado final quedó correcto y sin contenedores huérfanos |
| [`qas_carga_20nov_1924z.txt`](qas_carga_20nov_1924z.txt) | Salida de k6: humo, QAS-03 y la mezcla de QAS-15 y 19 |
| [`qas_stats_qas03_20nov_1924z.txt`](qas_stats_qas03_20nov_1924z.txt), [`qas_stats_qas19_20nov_1924z.txt`](qas_stats_qas19_20nov_1924z.txt) | `docker stats` durante la carga |
| [`logs_carga_20nov_1958z.txt`](logs_carga_20nov_1958z.txt) | Análisis de logs de la ventana y latencia a la base |

Scripts, en [`scripts/`](scripts): `verificar_qa_t42.sh`, `migrar_0040_0042_qa.sh`, `configurar_pools_qa.sh`, `desplegar_release_qa_t42.sh`, `k6_qas_carga.js`, `correr_qas_carga_t42.sh`, `logs_carga_qa_t42.py` y `correr_logs_carga_t42.sh`. Se corrieron desde la carpeta local de QA (`qa_t42/`), por eso escriben en `qa_t42/evidencia/`. Ninguno contiene credenciales: las contraseñas se teclean al ejecutar y las salidas ocultan URLs y claves.

## 6. Carga corta del 21 nov, tras el cambio del pooler

El 21 nov DevOps pasó el Core de QA al pooler en modo transacción (puerto 6543) y bajó el pool de Dispatch a 5 (SCRUM-1680, comentarios 11235 y 11236). Se repitió la misma carga nominal en versión corta: QAS-03 por 2 min y la mezcla por 5 min, en vez de 5 y 15. Es una medición complementaria: no reemplaza la corrida de 15 min que pide QAS-15.

| Prueba | 20 nov | 21 nov (corta) |
|---|---|---|
| Humo, p95 de elegibles | 2.870 ms | 879 ms |
| QAS-03, p95 de elegibles | 3.025 ms | 3.031 ms |
| QAS-03, 5xx | 100 % | 88,4 % |
| Mezcla, req/s sostenidas | 31,9 | 47,0 |
| Mezcla, 5xx | 81,4 % | 39,6 % |
| Mezcla, 5xx de las rutas de Core (perfil, sitios, tarifa) | altos | 0 % (p95 de 5,2 a 9,1 s) |
| Mezcla, 5xx de las rutas de Dispatch (elegibles, ofertas) | altos | 98,2 % y 99,5 % (p95 ~3,1 s) |
| `EMAXCONN` en Core | 2.232 | **0** |
| `timeout exceeded when trying to connect` en Core | 20.956 | 383 |
| `TaskCanceledException` en Dispatch | 27.217 | 21.768 |

**Lectura:**

- El cambio del pooler eliminó el rechazo de conexiones y casi todos los timeouts del pool de Core. Las rutas que atiende solo el Core ya no fallan, aunque siguen lentas (p95 de 5 a 9 s).
- **El cuello de botella ahora es Dispatch:** casi todos los 5xx que quedan son de `eligible-allies` y `offers/me`, que cortan a los ~3 s por el `HttpClient.Timeout` de 3 s hacia Core. Es lo que pide SCRUM-1651 (≥ 10 s) y sigue sin desplegarse.
- Los tres escenarios siguen en **No cumple** (p95 muy por encima de 500 ms, 5xx muy por encima de 1 %, 47 req/s con 40 % de errores). Mejoraron QAS-15 (de 81 % a 40 % de 5xx) y QAS-19 (de 31,9 a 47 req/s).

Evidencia: `qas_carga_corta_21nov_2242z.txt`, `qas_stats_corta_qas03_21nov_2242z.txt`, `qas_stats_corta_qas19_21nov_2242z.txt` y `scripts/correr_qas_carga_t42_corta.sh`.

## 7. Corrida completa del 22 nov, con el pooler en modo transacción

22 nov, de 04:14Z a 04:38Z, con el mismo script y la misma carga nominal que el 20 nov (300 VUs, 50 req/s, QAS-03 por 5 min y la mezcla por **15 min**). El Core usa el pooler en modo transacción (puerto 6543) con pool de 30, y Dispatch tiene pool de 5 (cambio de DevOps del 21 nov, SCRUM-1680, comentario 11236). SCRUM-1651 sigue sin desplegarse: Dispatch corta a los 3 s hacia Core. Esta es la medición oficial de QAS-15, que pide 15 min.

| Prueba | 20 nov | 22 nov |
|---|---|---|
| Humo, p95 de elegibles | 2.870 ms | 548 ms |
| QAS-03, p95 de elegibles | 3.025 ms | 3.044 ms |
| QAS-03, 5xx | 100 % | 96,3 % (14.999 peticiones) |
| Mezcla 15 min, req/s sostenidas | 31,9 | 43,9 (39.487 peticiones) |
| Mezcla 15 min, 5xx | 81,4 % | **39,8 %** |
| Mezcla, rutas de Core (perfil, sitios, tarifa) | 5xx altos | **0 % de 5xx**, p95 de 7,0 a 11,6 s |
| Mezcla, rutas de Dispatch (elegibles, ofertas) | 5xx altos | 99,5 % y 100 % de 5xx, p95 3,2 y 5,7 s |
| CPU máxima de Core (límite 1 CPU) | 55 % | **101 %** en la mezcla |

**Lectura:**

- Se confirma la carga corta del 21 nov en una ventana de 15 min. Con el pooler en modo transacción las rutas que atiende el Core ya no fallan, pero son lentas y **el Core llega al 100 % de su CPU** (límite de 1 CPU, SCRUM-1672): el siguiente techo del Core es de cómputo, no de conexiones.
- Los 5xx que quedan son casi todos de Dispatch (`eligible-allies` y `offers/me`), que corta a los 3 s esperando al Core. Mientras SCRUM-1651 no se despliegue, esas rutas fallan bajo carga.
- Los tres escenarios siguen en **No cumple**: QAS-03 con p95 de 3 s frente a 500 ms, QAS-15 con 39,8 % de 5xx frente a 1 %, y QAS-19 con 43,9 req/s y p95 de 3 a 11,6 s frente a 50 req/s dentro del umbral.

**Qué haría falta:** desplegar SCRUM-1651 (timeout de Dispatch ≥ 10 s); reducir las consultas por petición de `eligible-allies` y de las rutas de perfil, sitios y tarifa, que el Core resuelve con varias transacciones cada una; y revisar el límite de 1 CPU del Core o escalarlo (QAS-05).

Evidencia: `qas_carga_22nov_0412z.txt`, `qas_stats_qas03_22nov_0412z.txt` y `qas_stats_qas19_22nov_0412z.txt`. No se tomaron logs de esta corrida; las causas en Core y Dispatch son las mismas que se registraron en la carga corta del 21 nov.

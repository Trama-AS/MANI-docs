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

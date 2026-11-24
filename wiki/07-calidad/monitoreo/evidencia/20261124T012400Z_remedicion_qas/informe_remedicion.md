# Remedición de QAS tras el despliegue del 23 de noviembre de 2026

> Evidencia de QA. Resultado en el [SDD §8](../../../../02-arquitectura/SDD.md). Mantiene: QA (Santiago Hernández).

QA: Core `f0c2e87`, Dispatch `4b065e9`, Flutter `d9597a5`, Gateway `45a6c95`, Rules `348f6d9`, Landing `7649832`. Medición del 23 de noviembre 23:41Z al 24 de noviembre 01:24Z.

Antes se aplicó la migración 0044 (SCRUM-1720) y se desplegó `release`: [0044](despliegue/aplicar_0044_23nov_2147z.txt), [servicios](despliegue/despliegue_release_23nov_2147z.txt) y [Landing](despliegue/despliegue_landing_23nov_2145z.txt). El último paso del script `db/verify/0044` da `permission denied to set role "mani_core_svc"`: el rol de administración de la base no puede asumirlo. Core sí lee `tenant` y `zona` con su rol (T-41 y catálogo de QA).

## QAS-34 (Landing): sigue No cumple, mejora

Landing de QA (`http://10.43.100.141:3001`, 1280x800). Medición propia de contraste sobre estilos calculados (sin axe ni Lighthouse). Evidencia: [medición](qas34/landing_contraste_23nov.txt).

| Criterio | 22 nov (`a82b94e`) | 23 nov (`7649832`) |
|---|---|---|
| Textos bajo el umbral | 33 de 316 | **18 de 316** |
| Botón principal | 3,68:1 | Sin falla (`#CC441C`) |
| `prefers-reduced-motion` | No | No |
| `lang="es"`, imágenes con `alt`, controles con nombre, un `h1` | Sí | Sí (4 imágenes, 68 controles, 1 `h1`) |
| Enlace para saltar al contenido | No | No |

Los 18 que fallan: 15 textos en `#E4572E` (14 en subtítulos o cargos sobre blanco, 3,68:1; «Inicio Rápido» sobre `#FDE5DE`, 3,06:1), texto amarillo sobre blanco (1,82:1), blanco sobre `#E4572E` («Disponible Ahora en Tu Ciudad», 3,68:1) y «©» en el pie (3,68:1). 21 textos están sobre fondos con imagen o degradado: se midieron contra el color sólido de detrás.

La parte Flutter no cambió (SCRUM-1647), así que QAS-34 no puede pasar.

## QAS-30: Cumple (14 de 14)

Método: la revisión heurística de T-45 (opción B aceptada por la SM). Es una revisión de experto, no una prueba con usuarios. Flutter `d9597a5`: el build de QA servido por un proxy local de solo lectura, sin sesión en los registros y con sesión de administrador en las reglas.

Capturas: [registro de cliente](qas30/registro_cliente_800x600.jpg), [registro de aliado](qas30/registro_aliado_800x600.jpg) ([celular](qas30/registro_aliado_390x844.jpg)) y [reglas del tenant](qas30/reglas_tenant_800x600.jpg) ([celular](qas30/reglas_tenant_390x844.jpg)).

| Pantalla | 800x600 | 390x844 |
|---|---|---|
| Registro de cliente | Sí, «Crear mi cuenta de cliente» fijo al pie | — |
| Registro de aliado | Sí, «Enviar registro a revisión» fijo al pie | Sí |
| Reglas del tenant (administrador, versión vigente 20) | Sí, «Guardar nueva versión» fijo al pie | Sí |

Se repitieron las 3 pantallas que fallaban el 23 nov 00:30Z; las otras 11 pasaron en T-45 con `95a3e42` y #163 no las cambia. No se guardó ninguna versión de reglas. Siguen los hallazgos menores de T-45 en reglas: rótulos con «(RF-13)», «(RF-16)», «(RNF-10)» y encabezados en mayúsculas.

## QAS-01: Cumple (regresión tras la 0044)

Corrida T-41 en QA, 23:48Z, con los roles reales: 37 comprobaciones PASA, 0 FALLA, 0 REVISAR (QAS-01 y 20 juntas). Los seis casos cross-tenant y P4 por el Gateway, y los seis casos, P1 y P5 en el motor como `mani_core_svc`: 32 tablas leídas sin filas de otro tenant. Las 2 solicitudes de prueba quedaron CANCELADA. Evidencia: [corrida](t41/t41_23nov_2346z.txt).

Aparte, el TEC-21 avisa que en ese momento no había conexiones de `mani_dispatch_svc` abiertas. Lo más probable es que Dispatch no tuviera conexiones en uso; la corrida sí se conectó con ese rol.

## QAS-20: Cumple, con un permiso sobrante

- Código de Dispatch `4b065e9`: sin SQL sobre `solicitud` ni otra tabla de Core; solo `solicitud_rechazo`. Evidencia: [revisión de código](t41/qas20_codigo_dispatch_23nov_2342z.txt).
- Motor: 7 de 7 operaciones prohibidas reciben `42501`; la escritura propia en `solicitud_rechazo` funciona (revertida).
- Rules `348f6d9`: no usa base de datos, así que se cierra el pendiente del corte del 13 nov.
- **Permiso sobrante:** `mani_dispatch_svc` conserva `SELECT` sobre `solicitud` (además de `tenant` y `zona`). El código ya no lo usa; conviene un `REVOKE` en una migración de Core. SCRUM-1660 pide que Dispatch solo acceda a `solicitud_rechazo`.

## QAS-22: Parcial (falta Core)

Medido en QA, 23:50Z. Evidencia: [logs por servicio](qas22/qas22_logs_23nov_2349z.txt).

| Servicio | Líneas de log en JSON (30 min) | 22 nov |
|---|---|---|
| Gateway | 349 de 349 (100 %) | JSON |
| Dispatch | 73 de 73 (100 %) | Texto |
| Rules | 62 de 62 (100 %) | JSON |
| Core | **1 de 221 (0,5 %)** | Texto |

- Cabecera `X-Correlation-ID`: 5 rutas, con ID (devuelve el mismo, una sola vez) y sin ID (lo genera), 10 de 10.
- Propagación: 17 IDs de la corrida T-41 y de esta prueba; 2 aparecen en Gateway, Core y Dispatch (aceptaciones rechazadas), los demás en el servicio que atendió la petición.
- Falta: logs de Core en JSON (`correlationId.middleware.js` y `errorHandler.middleware.js` usan `console` con texto).

## QAS-40: Parcial (Dispatch ya corta; Core no)

Inyección en QA, 24 nov 01:22Z (`docker pause` de Rules, `GET /dispatch/requests/:id/eligible-allies`). Evidencia: [corrida](qas40_qas44/qas40_44_24nov_0121z.txt).

| Momento | Respuesta | Tiempo |
|---|---|---|
| Antes | 200 | 0,50 s |
| Intentos 1 a 5 | 503 `RULES_SERVICE_UNAVAILABLE` | 3,43 a 3,56 s (timeout de 3 s) |
| Intentos 6 a 9 | 503, circuito abierto | 0,43 s |
| 12 s después de reanudar Rules | 200 | 0,44 s |

Los logs de Dispatch registran 4 veces «Circuito abierto para mani-rules». Falta: circuit breaker en Core (sin cambios en `f0c2e87`) e inyección de respuestas malformadas. La caída de Core vista desde Dispatch no se probó.

## QAS-44: Cumple (SCRUM-1719, criterios 1 a 3)

Simulacro en QA, 24 nov 01:23Z. Evidencia: [corrida](qas40_qas44/qas40_44_24nov_0123z.txt).

1. Despliegue a propósito de una imagen de Dispatch que no arranca: el contenedor entra en reinicios (6) y `/dispatch/health` responde 502. Aceptar durante la falla: 502 y la solicitud sigue PENDIENTE.
2. `rollback_qa.sh` al digest `sha256:03067794…`: **6 s** (límite 300 s); 19 s desde el despliegue fallido.
3. Aceptación con la misma `Idempotency-Key`: 200 `isRetry=false`; repetida, 200 `isRetry=true` con el mismo aliado. En la base: ASIGNADA y 1 aviso `SOLICITUD_ASIGNADA` (sin duplicado).

El primer intento abortó antes de desplegar la imagen fallida (el `FROM` buscaba la imagen en el registro); se corrigió con `docker commit`. QA quedó en `:staging` con la misma imagen (`4b065e9`), Rules activo y las 2 solicitudes de prueba CANCELADA. Pendiente de la tarea: el video.

## Conteo

Cumple 26 (entran 30 y 44) · Parcial 9 · No cumple 7 · No medido 3.

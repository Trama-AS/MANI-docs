# Remedición de QAS tras el despliegue del 24 de noviembre de 2026

> Evidencia de QA. Resultado en el [SDD §8](../../../../02-arquitectura/SDD.md). Mantiene: QA (Santiago Hernández).

QA: Core `3bb3dd3`, Dispatch `1fce80e`, Rules `ce513cb`, Gateway `71558b8`, Flutter `a98fa12`, Landing `73b1625`, con las migraciones [0045](despliegue/aplicar_0045_24nov_0323z.txt) y [0046](despliegue/aplicar_0046_24nov_0325z.txt) ([despliegue](despliegue/despliegue_release_24nov_0324z.txt)). Medición del 24 de noviembre, 03:24Z a 04:00Z; QAS-33 y 35, 04:05Z a 04:26Z; QAS-18 y 27, 04:46Z a 05:09Z; QAS-02 y 09, 15:03Z a 15:09Z; QAS-06 y 26, el mismo día sobre el código desplegado.

Flutter vigente en QA desde las 05:47Z: `4539d53` ([despliegue](despliegue/despliegue_flutter_24nov_0545z.txt)). Entre `a98fa12` y `4539d53` solo entra MANI-Flutter#168 (SCRUM-1646): cambia colores del tema y no toca rutas, sesión, red ni mensajes. QAS-30, 34 y 35 se midieron con `a98fa12` y no se repitieron. El conteo de QAS-33 se repitió en `4539d53` y da lo mismo: 83 nativos en 31 archivos, 0 agregados.

| QAS | Antes | Ahora |
|---|---|---|
| 02 | Parcial | Parcial |
| 06 | Parcial | Parcial |
| 09 | Parcial | **Cumple** |
| 18 | No medido | **Cumple** |
| 20 | Cumple (con un permiso sobrante) | Cumple |
| 21 | No cumple | **Parcial** |
| 22 | Parcial | **Cumple** |
| 23 | Parcial | **Cumple** |
| 26 | Parcial | **Cumple** |
| 27 | No medido | **Cumple** |
| 30 | Cumple | Cumple |
| 33 | No cumple | No cumple |
| 34 | No cumple | No cumple |
| 35 | No cumple | No cumple |
| 40 | Parcial | **Cumple** |
| 43 | Parcial | Parcial |

**Conteo:** Cumple 33 · Parcial 5 (02, 06, 12, 21, 43) · No cumple 6 · No medido 1 (05).

## QAS-02: Parcial

[Corrida](qas02_qas09/qas02_09_real_24nov_1503z.txt) ([script](qas02_qas09/qas02_qas09_qa.py), [corredor](qas02_qas09/correr_qas02_09.sh), [observador](qas02_qas09/observador_push.js), [ensayo](qas02_qas09/qas02_09_ensayo_24nov_1501z.txt)). Copias desechables de Core y Dispatch con las imágenes desplegadas y sus mismas variables, sin Kafka y con 2 conexiones. Los servicios de QA no cambiaron. Caída y error usan `mock_falla`; en el timeout, el observador deja sin respuesta al proveedor, porque `mock_falla` no simula esa falla. 31 PASA, 1 FALLA y 3 REVISAR.

| Caso | Orquestar | Aceptar | Cancelar | Intentos por aviso | Ofertas guardadas |
|---|---|---|---|---|---|
| Control (`mock`) | 200 en 3,03 s | 200 | 200 | 1 | 2 de 2 |
| Caída | 200 en 3,24 s | 200 | 200 | 2, ambos fallan | 2 de 2 |
| Error y reintento | 200 en 3,30 s | 200 | 200 | 2, el segundo entrega | 2 de 2 |
| Timeout | **503 en 11,96 s** | 200 en 4,36 s | 200 en 3,37 s | 2, sin respuesta | **1 de 2** |

- **Umbral:** 0 operaciones confirmadas revertidas. En los tres casos con falla, aceptar dejó la solicitud ASIGNADA y cancelar la dejó CANCELADA (6 de 6). Los avisos de esas operaciones quedaron en la bandeja del cliente y del aliado.
- **Reintento:** misma clave de idempotencia y mismo correlation ID en cada intento.
- **Brecha 1:** la oferta de Dispatch espera al push. `PublishNotificationUseCase` hace hasta 3 intentos de 5 s y Dispatch corta cada llamada a Core a los 10 s (`ClientesDeCore.Espera`). Dispatch publica las ofertas una por una, así que el segundo aliado no la recibió. La recuperación se midió en QAS-09.
- **Brecha 2:** Core no registra la falla de entrega. Con el correlation ID de cada corrida hay 9 o 10 líneas y ninguna la menciona.
- **Alcance:** QA corre con `mock`; la brecha 1 se vería con un proveedor real que no responda.

## QAS-06: Parcial

[Tabla API ↔ contrato](qas06/tabla_api_contrato.csv), [resumen](qas06/resumen.txt) y [contract tests](qas06/contract_tests_ci.txt) ([cruce](qas06/qas06_rutas_contrato.py), [rutas de Core](qas06/qas06_rutas_core.js)). Core: rutas que Express registra al cargar `3bb3dd3`. Dispatch y Rules: rutas declaradas en `1fce80e` y `ce513cb`. Solo lectura.

| Servicio | Rutas en código | Operaciones en contrato | Sin contrato |
|---|---|---|---|
| Core | 129 | 128 (120 + 8 internas) | `/auth/validate-token` |
| Dispatch | 9 | 8 | `GET /metrics` |
| Rules | 5 | 5 | `/actuator/prometheus` (la expone Spring; no entra en el conteo) |

- Ninguna operación de los contratos carece de ruta.
- `/auth/validate-token` es interna: el Gateway responde 404 desde fuera (comprobado en su CI). `/metrics` de Dispatch y `/actuator/prometheus` de Rules sí se publican, en `/api/v1/dispatch/metrics` y `/api/v1/rules/metrics` (SCRUM-1714), y no tienen contrato. Core sí documenta el suyo.
- Contract tests en `develop` antes de promover, sobre código idéntico al de `release`: 120/120, 8/8, 8/8 y 5/5. CI del Gateway en verde, con Newman en 19 peticiones y 78 verificaciones sin fallas.
- MANI-docs#81 suma 140 operaciones y aquí hay 141: falta `/allies/eligible/by-request/{id}` del contrato interno, agregada con SCRUM-1652.

## QAS-09: Cumple

[Corrida](qas02_qas09/qas02_09_real_24nov_1503z.txt): 15 de 15. [Recuperación](qas02_qas09/qas02_09_real_recuperacion_24nov_1508z.txt): 4 de 4.

| Caso | Respuesta | Estado persistido | Recuperación |
|---|---|---|---|
| Aliado natural, falla el primer documento | 503 | 0 residuos | Repetir no choca con 409 |
| Aliado natural, falla el segundo documento | 503 | 0 residuos | Repetir no choca con 409 |
| Aliado empresa, falla el tercer documento | 503 | 0 residuos | Repetir no choca con 409 |
| Orquestación con el push colgado | 503 | PENDIENTE, 1 de 2 ofertas | Repetir con el push sano: 2 de 2, sin duplicados |

- Residuos revisados por SELECT en `auth.users`, `usuario`, `aliado`, `aliado_categoria`, `documento_kyc`, `consentimiento_usuario` y el bucket `kyc-documentos`. El segundo intento se hizo con la misma falla para no crear una cuenta.
- **Límites:** no se probó un Storage que no responde (el cliente de Supabase de Core no fija un timeout propio), ni que falle también la limpieza: `STORAGE_FALLA_DESPUES_DE` cuenta por operación y no permite provocarla; por código, el archivo ya subido quedaría huérfano. Pagos no se ejecutó.

## QAS-26: Cumple

[Pruebas](qas26/pruebas.txt) (58 de 58) y [diff de MANI-Node#148](qas26/diff_stat_node148.txt). Core `3bb3dd3` elige entre `mock` y `sandbox_http` con `PAYMENT_PROVIDER`. Las mismas 4 pruebas de contrato pasan con ambos, y los casos de uso de cobro también. El diff toca `infrastructure/payments`, `config`, `container`, documentación y pruebas; 0 archivos en `domain` o `application`. Corrido en local con Node 25 (CI usa 22) contra un servidor falso: no hubo cobros.

## QAS-18: Cumple

[Carga y series](qas18_qas27/qas18_27_real_24nov_0444z.txt) ([corredor](qas18_qas27/correr_qas18_27.sh), [k6](qas18_qas27/k6_qas18.js), [consultas](qas18_qas27/prom_qas18_27.py)). cAdvisor v0.55.1 exporta los 13 contenedores de QA y Prometheus los lee. 300 VUs, 1 min de rampa y 5 min sostenidos con las mismas rutas de QAS-19; k6 entró por un túnel SSH al Gateway porque el certificado de QA no incluye un nombre verificable. Porcentaje del límite de cada contenedor:

| Contenedor | Media | Máximo |
|---|---|---|
| promtail | 37,7 % | 43,0 % |
| Core | 35,1 % | 37,7 % |
| Dispatch | 17,9 % | 20,2 % |
| Gateway | 8,4 % | 9,0 % |
| Rules | 4,2 % | 5,2 % |

Límite: el sistema sostuvo 37,3 req/s de los 50 pedidos, con 0 % de fallos y p95 de 6 a 12 s. La CPU no es el cuello. No cambia QAS-03, 15 ni 19.

## QAS-27: Cumple

Misma [corrida](qas18_qas27/qas18_27_real_24nov_0444z.txt), con el [script de saturación](qas18_qas27/qas27_coexistencia.py) en la VM de QA.

| Saturado | CPU (Prometheus) | p95 de los vecinos, antes y durante | Fallos |
|---|---|---|---|
| Rules | 99,5 % | Gateway 4 y 5 ms; Core 20 y 23 ms; Dispatch 6 y 8 ms | 0 |
| Core | 99,6 % | Gateway 4 y 5 ms; Rules 6 y 7 ms; Dispatch 5 y 8 ms | 0 |

Los contenedores no se reiniciaron ni hubo OOM. El aviso «NO, 80 %» de Rules en la salida sale de una muestra anterior a la saturación; la serie de Prometheus, con la ventana completa adentro, da 99,5 %. Límites: la memoria no llegó a su tope (22 y 13 %); no se saturaron Gateway ni Dispatch; los vecinos se midieron con sondas de salud y métricas; la saturación la hizo un script Python y no k6. Las rutas con sesión dependen de Core, así que su latencia con Core saturado no es coexistencia y no se midió.

## QAS-20: Cumple (y QAS-01, regresión)

[Corrida](qas01_qas20/qas01_qas20_24nov_0350z.txt): 50 PASA, 0 FALLA, 0 REVISAR.

- Tras la 0046, `mani_dispatch_svc` solo tiene `SELECT` e `INSERT` sobre `solicitud_rechazo`.
- 10 de 10 operaciones prohibidas reciben `42501`, incluidas las lecturas de `solicitud`, `tenant` y `zona`.
- Con sesión: ofertar, ver la bandeja, rechazar (repetirlo no duplica) y aceptar lo rechazado (409 `MANI-DSP-409R`). Logs de Dispatch con 0 `permission denied`.
- [Código de Dispatch](qas01_qas20/qas20_codigo_dispatch_24nov_0330z.txt) `1fce80e`: SQL solo sobre `solicitud_rechazo`.
- Las 3 solicitudes de prueba quedaron CANCELADA. Queda 1 rechazo de `aliado.t1`.

## QAS-21: Parcial

[Medición](qas21/qas21_24nov_0331z.txt). La validación de las reglas del tenant quedó solo en Rules (SCRUM-1722). Duplicación: Node 0,6 %, Java 0,0 %, .NET 1,5 %, Gateway 0,0 %, Landing 1,0 % y Flutter 0,9 % (antes 6,3 %). Falta: `comisionValida()` en Core repite el límite de la comisión (0 a 30 %, 2 decimales) que también está en Rules; la usa la liquidación.

## QAS-22: Cumple

[Logs por servicio](qas22/qas22_logs_24nov_0359z.txt), desde el arranque de cada contenedor. El corte del 23 de noviembre usó una ventana posterior al arranque, así que los porcentajes no se comparan directo.

| Servicio | Líneas en JSON | Lo que no es JSON |
|---|---|---|
| Core | 517 de 519 | 2 mensajes de arranque |
| Dispatch | 258 de 260 | 2 mensajes de arranque |
| Rules | 139 de 146 | 7 líneas del letrero de arranque |
| Gateway | 1237 de 1375 | 9 de arranque y 129 del `error_log` de nginx, que solo escribe texto |

El registro de acceso del Gateway es JSON. `X-Correlation-ID`: 10 de 10 peticiones con una sola cabecera, 9 IDs en Gateway, Core y Dispatch, y 14 en Core y Rules (de la corrida de QAS-40, que llegaron a los servicios reales). Observación: 76 avisos del `error_log` dicen que `correlation_id` no estaba definido; por la configuración parecen ser redirecciones a HTTPS, que no llegan a ningún servicio.

## QAS-23: Cumple

[Medición](qas23/qas23_24nov_0400z.txt). El gate de código nuevo está en los 6 repositorios y los contract tests son obligatorios en el CI de Gateway, Core, Dispatch y Rules (141 de 141 operaciones). Todos los casos críticos están en 90 % o más; los otros 10 casos de Core conservan la cifra del 22 de noviembre (95,2 a 100 %). Corrección: en el corte del 22 de noviembre los casos bajo 90 % eran 4, no 3; faltó contar rechazar oferta (87,7 %).

## QAS-30: Cumple (14 de 14)

Mismo método de T-45. [Pantallas con sesión](qas30/qas30_sesion_24nov.txt) y [sin sesión](qas30/qas30_sin_sesion_24nov_0334z.txt). Ventana de referencia 800x865; se repitieron 13 flujos a 800x600 y los dos registros también a 390x844. F11 no se repitió porque no había aliados pendientes y conserva la medición del 22 y 23 de noviembre. Límite: revisión de experto, no prueba con usuarios; en ventanas bajas (800x600), «Pagar» (F4) y «Aceptar» de la bandeja del aliado (F8) aparecen al desplazarse un poco; en celular solo se revisaron los dos registros.

## QAS-33: No cumple

[Conteo](qas33/qas33_a98fa12_24nov.txt) ([script](qas33/qas33_conteo.py)) con el método del 22 de noviembre. Los 6 PR de Flutter fusionados desde `1991221` agregan 0 nativos. `lib/features` conserva 83 nativos en 31 archivos, todos tocados desde la regla; los mayores son mis solicitudes (11), adiciones (10) y tarifario (7).

## QAS-34: No cumple

[Landing](qas34/qas34_landing_24nov_0332z.txt): 18 de 319 textos con contraste bajo (los mismos), sin `prefers-reduced-motion`. [Flutter](qas34/qas34_flutter_24nov_0334z.txt): el foco de «Ingresar» ya se ve (2.4.7); siguen `lang` en `en-US` (3.1.1), campos nombrados por su ejemplo (1.3.1) y zoom bloqueado en celular (1.4.4).

## QAS-35: No cumple

[Revisión](qas35/qas35_a98fa12_24nov.md). `flutter test` de 39 suites: 579 de 579 (el 23 de noviembre se usó un filtro más amplio, 594; no se comparan). Orientan la validación, la falta de conexión y los 5xx de asignación; los estados vacíos también, salvo la [solicitud cancelada sin cotización](qas35/qas35_cancelada_sin_cotizacion_a98fa12.jpg). No orientan la [redirección por rol](qas35/qas35_redireccion_rol_2s_a98fa12.jpg), los 5xx de verificación ni el archivo grande del registro. Límite: los 5xx y el archivo grande se verificaron en código, y las listas vacías no se vieron en pantalla porque la cuenta de prueba tiene datos. Corrección: el corte del 23 de noviembre incluyó por error los 5xx de asignación.

## QAS-40: Cumple

[Corrida](qas40/qas40_24nov_0352z.txt), con copias desechables de las imágenes desplegadas en la red de QA y un [proxy que inyecta fallas](qas40/proxy_fallas.js). Los contenedores de QA no se tocaron (imagen, arranque y reinicios iguales). 34 PASA, 0 FALLA, 4 observaciones.

| Camino | Timeout | Circuito | Recuperación |
|---|---|---|---|
| Dispatch → Rules | 3,5 s | Abre tras 5 caídas | A los 10 s |
| Dispatch → Core | 10,0 s | Abre tras 5 caídas | A los 10 s |
| Core → Rules | 6,0 s | Abre tras 5 caídas | A los 10 s |
| Core → Dispatch | 6,4 s | Abre tras 5 caídas | A los 10 s |

Con el circuito abierto el destino recibió 0 llamadas. Ninguna respuesta malformada terminó en 2xx. Observaciones: con HTML, JSON roto o `{}` de Rules, Core responde 400 `MANI-RGL-400` (lo atribuye al administrador; no guarda nada); con `{}` de Core, la bandeja de Dispatch responde 403. No se probó `{}` en la segunda llamada de la bandeja. Los proveedores externos se apoyan en las pruebas de Core del 22 de noviembre.

## QAS-43: Parcial

[Medición](qas43/qas43_tls_24nov_0329z.txt) desde fuera de las VM. QA: el 8080 redirige HTTP a HTTPS y acepta TLS 1.2 y 1.3; rechaza 1.0 y 1.1 (SCRUM-1718). El certificado es autofirmado y no incluye la IP de QA. PROD: el 8080 sirve la app por HTTP y el 443 no responde.

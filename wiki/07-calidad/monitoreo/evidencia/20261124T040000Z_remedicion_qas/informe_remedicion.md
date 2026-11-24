# Remedición de QAS tras el despliegue del 24 de noviembre de 2026

> Evidencia de QA. Resultado en el [SDD §8](../../../../02-arquitectura/SDD.md). Mantiene: QA (Santiago Hernández).

QA: Core `3bb3dd3`, Dispatch `1fce80e`, Rules `ce513cb`, Gateway `71558b8`, Flutter `a98fa12`, Landing `73b1625`, con las migraciones [0045](despliegue/aplicar_0045_24nov_0323z.txt) y [0046](despliegue/aplicar_0046_24nov_0325z.txt) ([despliegue](despliegue/despliegue_release_24nov_0324z.txt)). Medición del 24 de noviembre, 03:24Z a 04:00Z; QAS-33 y 35, 04:05Z a 04:26Z; QAS-18 y 27, 04:46Z a 05:09Z.

| QAS | Antes | Ahora |
|---|---|---|
| 18 | No medido | **Cumple** |
| 20 | Cumple (con un permiso sobrante) | Cumple |
| 21 | No cumple | **Parcial** |
| 22 | Parcial | **Cumple** |
| 23 | Parcial | **Cumple** |
| 27 | No medido | **Cumple** |
| 30 | Cumple | Cumple |
| 33 | No cumple | No cumple |
| 34 | No cumple | No cumple |
| 35 | No cumple | No cumple |
| 40 | Parcial | **Cumple** |
| 43 | Parcial | Parcial |

**Conteo:** Cumple 31 · Parcial 7 · No cumple 6 · No medido 1 (05).

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

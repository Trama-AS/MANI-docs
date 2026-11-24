# Acta de decisión A/B por escenario de calidad (SCRUM-1684, T-47)

**Versión firmada**, 21 de noviembre de 2026. Las decisiones escenario por escenario están en el comentario 11269 de [SCRUM-1684](https://maniservices.atlassian.net/browse/SCRUM-1684).

| | |
|---|---|
| **Decide y firma** | Camila Beltrán (PO) |
| **Facilita** | Sara Albarracín (SM) |
| **Prepara** | Santiago Hernández (QA) |
| **Tarea que depende de esta acta** | SCRUM-1685 (T-48): escribir en el SDD §7 y §8 los umbrales de los escenarios con opción B |
| **Fuente** | Análisis de QA del 9 nov sobre los 45 escenarios (§4, «Los dos caminos»), con los datos actualizados al 21 nov |
| **Dónde se aplica** | [SDD §7 y §8](../02-arquitectura/SDD.md) |
| **Reemplaza** | Las decisiones parciales del 19 nov (SCRUM-1684, comentarios 11204 y 11207) y, en cuanto al RPO, la fila D4 de SCRUM-1696 |

## Qué se decide

Para cada escenario que hoy no se cumple o no se puede medir, la PO elige un camino:

- **A. Cambiar el sistema** para que cumpla el umbral actual del SDD. El umbral no se toca.
- **B. Ajustar el escenario** a lo que el proyecto sí va a tener. El umbral cambia al texto aprobado, y QA lo vuelve a medir con ese umbral.

B solo se usa donde hay un motivo escrito para el umbral nuevo.

## Reglas

1. **No se ajustan con B los escenarios donde el sistema falla de verdad:** 03, 15, 19, 14, 22, 42 y 06. Siguen en A.
2. Elegir B no da el escenario por cumplido: solo cambia contra qué se mide.
3. **Kubernetes sigue siendo el objetivo** (PROY-08, ADR-0004). Donde B se apoya en Docker Compose (05 y 18), es porque el proyecto trabaja hoy con Compose, no porque se renuncie a Kubernetes.

## Decisión por escenario

### En B (umbral nuevo)

| QAS | Umbral actual (SDD §8) | Estado al 21 nov | Umbral nuevo (opción B) | Cómo se mide | Motivo |
|---|---|---|---|---|---|
| **05** Escalabilidad | Escalamiento de 2 a 6 réplicas sin cambio de código (con Kubernetes y HPA) | No medido. QA corre en Docker Compose | Escalamiento manual de 2 a 6 réplicas por servicio con `docker compose --scale`, sin cambio de código | Carga k6 mientras se escala: el Gateway reparte entre las réplicas y no aparecen errores por el cambio | El proyecto trabaja con Compose; Kubernetes queda como objetivo (ADR-0004), no como cumplido |
| **16** Disponibilidad | ≥ 99,9 % mensual en las APIs críticas | No medido. Prometheus sondea QA desde la VM de Calidad, sin un mes de serie. El 99,9 % está marcado `supuesto` | ≥ 99,9 % en la ventana disponible, con un mínimo de 7 días continuos; pasa a mensual cuando exista la serie | Proporción de sondas `/health` exitosas en Prometheus, por servicio y por el Gateway, descontando ventanas de mantenimiento declaradas | Un mes de serie no se puede acumular antes del cierre |
| **17** Recuperabilidad | RTO ≤ 30 min; RPO ≤ 5 min | **Parcial** con el umbral actual. El RTO se cumple: **2 s** en QA y en PROD (simulacro del 15 nov, [`04-respaldos-y-restauracion.md`](../08-infraestructura/04-respaldos-y-restauracion.md)); el RPO real es de hasta 24 h porque el respaldo es diario | **RPO ≤ 24 h con respaldo diario cifrado; RTO ≤ 30 min, sin cambio** | El mismo simulacro: hora del último respaldo frente a la pérdida (RPO) y tiempo hasta que los endpoints críticos responden (RTO) | Decisión de diseño de DevOps: el respaldo cada 5 min saturaba (SCRUM-1666). Reemplaza la D4 de SCRUM-1696 en cuanto al RPO |
| **18** Utilización de recursos | < 70 % de CPU sostenida **por pod** antes de escalar | No medido como escenario. Hay cAdvisor en QA; la carga corta del 21 nov dio 56 % máximo, pero con 40 % de errores | < 70 % de CPU sostenida **por contenedor** con la carga nominal | k6 con la carga nominal y CPU por contenedor desde cAdvisor | Igual que el 05: se trabaja con Compose y Kubernetes queda como objetivo (ADR-0004) |
| **24** Adaptabilidad | Misma imagen desplegable en DEV, QA y PROD con configuración externa | No medido. El backend usa configuración externa. Flutter construye una imagen por ambiente; la configuración al arrancar quedó en MANI-Flutter#150 (fusionado en `develop` el 21 nov, `f4424f2`) | Backend y Gateway: la misma imagen en los tres ambientes. Flutter web: una imagen por ambiente, construida desde el mismo commit, con la configuración ajustable al arrancar | 1. En GHCR, las tres imágenes de Flutter tienen el mismo commit de origen. 2. Al arrancar el contenedor con otras variables, `/assets/.env` cambia sin recompilar. 3. Backend: el mismo digest en los tres ambientes | Imagen por rama validada por DevOps (SCRUM-1649). Resuelve la reserva de la SM (comentario 11207): el método anterior, comparar digests, no se podía cumplir para Flutter |
| **25** Instalabilidad | Despliegue **automatizado** por ambiente ≤ 10 min | No medido como escenario. Solo Core tiene CD (`cd.yml`). El despliegue con script ya se cronometró en SCRUM-1674: **13 s** en QA ([`01-mapa-ambientes-y-versiones.md`](../08-infraestructura/01-mapa-ambientes-y-versiones.md)) | Despliegue por ambiente con un script versionado de un solo comando, ≤ 10 min hasta `/health` 200 en todos los servicios | Cronometrar el script (`desplegar_release_qa.sh`) desde el inicio hasta `/health` 200 | Llevar CD a 5 repos con runner hacia las VM no cabe en el proyecto |
| **26** Reemplazabilidad | Cambio de proveedor sin alterar el dominio | No medido. Core elige el proveedor por configuración; solo existe el adaptador `mock` | Cambio entre dos adaptadores (el `mock` y un segundo adaptador de prueba con contrato distinto) sin tocar casos de uso ni dominio | Pruebas de contrato con los dos adaptadores y diff que solo toca el adaptador y la configuración | No hay contrato con proveedores reales de notificaciones ni pagos |
| **33** Involucración | Consistencia visual definida por el sistema de diseño | Parcial (T-43): adopción de 37 % en botones, 1 % en campos y 46 % en tarjetas | ManiButton y ManiTextField obligatorios en las pantallas nuevas o modificadas | En cada PR de Flutter que cree o modifique una pantalla, no aparecen botones ni campos nativos nuevos | Decidido el 17 nov en SCRUM-1648; la regla quedó en el README de MANI-Flutter (PR #149, `5441e82`) |

### En A (el umbral no cambia)

| QAS | Umbral (SDD §8) | Estado al 21 nov | Qué falta | Motivo |
|---|---|---|---|---|
| **40** Integración segura | Timeout, validación de respuesta y circuit breaker cuando aplique | No medido. Hay timeout y validación; ningún servicio tiene circuit breaker | Circuit breaker en Core, Dispatch y Rules, con pruebas de falla | B quitaría justo lo que falta. Sin circuit breaker queda en No cumple |
| **43** TLS en tránsito | TLS 1.2 o superior, y HTTP redirige a HTTPS | En el video de SCRUM-1665 (21 nov) QA responde por HTTPS con TLS 1.2 y redirige con 301, medido desde la VM de Calidad. Desde la red de QA (Mac del responsable de QA), el 443 no responde | Ejecutar el método (`openssl s_client`, `testssl.sh`) desde la VM de Calidad en QA y PROD | El sistema debe cumplir el umbral; la diferencia en el puerto 443 se explica por la red desde la que se mide |

## Qué pasa después de firmar

1. QA escribió en el SDD §7 y §8 el umbral nuevo de cada escenario en B, con el enlace a esta acta (SCRUM-1685, 21 nov).
2. Los escenarios en A conservan su umbral y su estado. Lo que falta queda como hallazgo para el equipo responsable.
3. Volver a medir con los umbrales nuevos queda para el siguiente incremento. Excepciones posibles antes del cierre, si hay tiempo: QAS-17 y QAS-25, que ya tienen mediciones.

## Firma

| | Nombre | Fecha | Firma |
|---|---|---|---|
| PO | Camila Beltrán | 2026-11-21 | Firmada |
| SM (testigo) | Sara Albarracín | 2026-11-24 | Firmada (por instrucción expresa de la SM en el hilo del proyecto, 24/11) |

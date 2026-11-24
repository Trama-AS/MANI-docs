# Informe de proyecto — MANI

[← 06 · Gobernanza](README.md) · [Entrega final](ENTREGA_FINAL.md) · [Índice de la wiki](../Home.md)

| Campo | Valor |
|---|---|
| **Finalidad** | Dejar por escrito los resultados del proyecto, las lecciones aprendidas y las conclusiones, con cifras que se puedan reproducir. |
| **Redacta** | Sara Albarracín (Scrum Master) |
| **Consume** | La PO, el equipo y el jurado en la sustentación |
| **Corte** | 24 de noviembre de 2026, 3:50 p. m. El Sprint 6 cierra el 25 de noviembre |
| **Fuentes** | Jira (`project = SCRUM`), [`QAS_45_ESTADO_METODO_EVIDENCIA.md`](../07-calidad/QAS_45_ESTADO_METODO_EVIDENCIA.md), [`INFORME_CIERRE_SPRINT_6.md`](INFORME_CIERRE_SPRINT_6.md), [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) y la wiki. Las consultas están en la §9 |

> **Regla de este informe.** Las cifras son las de Jira y las de las mediciones de QA, no las de la impresión de nadie. Donde el dato es incómodo se escribe igual.

## 1. Resumen

MANI formaliza el ciclo solicitud, cotización, ejecución, calificación y cierre de servicios entre clientes y aliados, para varias empresas a la vez y con los datos de cada una aislados. En seis sprints, del 26 de agosto al 25 de noviembre de 2026, el equipo construyó el MVP sobre una arquitectura de tres servicios detrás de un API Gateway y lo desplegó en tres ambientes.

- **735 de 764** ítems de Jira cerrados; **134 de 135** historias.
- **33 de 45** escenarios de calidad se cumplen; 5 en parte, 6 no y 1 sin medir.
- **15 de 15** contradicciones entre documentos resueltas con evidencia.
- Lo que no se entrega: rendimiento del Core bajo carga, accesibilidad WCAG 2.2 AA, promoción del mismo digest de QA a PROD, Kafka en PROD y varias funcionalidades puntuales. Está en la §6.

## 2. Contexto y alcance

**El problema.** La operación se gestionaba de forma informal (llamadas, mensajería, contactos directos), sin trazabilidad de los servicios, verificación de aliados, tarifas estandarizadas ni auditoría, y sin forma de escalar a varias empresas. Está en [`vision-y-alcance.md`](../01-producto/vision-y-alcance.md).

**Alcance del MVP.** Plataforma multi-tenant, autenticación y control de acceso, directorio de aliados y clientes, documentos KYC, catálogo de categorías, cobertura por zonas, creación y despacho de solicitudes, cotizaciones, ejecución, calificación bidireccional, mensajería y notificaciones, tarifario de referencia y reportes asociados.

**Segundo incremento, fuera del MVP.** Pagos y liquidaciones, quejas, comercialización y métricas por tenant (RF-24 a RF-28). Sin pasarela de pago, sin facturación electrónica y sin cálculo de proximidad.

## 3. Qué se construyó

**Arquitectura.** SOA distribuida con un API Gateway y tres servicios, cada uno en su tecnología y con su repositorio ([`SAD.md`](../02-arquitectura/SAD.md)):

| Servicio | Tecnología | Responde de |
|---|---|---|
| Rules Service | Java | reglas por tenant, ranking de aliados y validación de tarifa |
| Dispatch Service | .NET | ofertas, aceptación y exclusión concurrente |
| Core Service | Node.js | identidad, aliados y KYC, clientes, catálogo, disponibilidad, solicitud, cotización, ejecución, calificación, mensajería y reportes |

La aplicación cliente es Flutter (web y móvil); la persistencia, Supabase sobre PostgreSQL con RLS por tenant; los eventos de negocio van por Kafka con *transactional outbox*. El diseño detallado, las vistas C4, los escenarios de calidad y los contratos de eventos están en [`SDD.md`](../02-arquitectura/SDD.md), y el modelo de datos, de 37 tablas, en [`ModeloDatos.md`](../02-arquitectura/ModeloDatos.md).

**Decisiones.** 30 ADR, de los cuales 29 aceptados y 1 rechazado. Las más determinantes: SOA políglota (ADR-0019), la lógica de negocio fuera de la base de datos (ADR-0022), la exclusión concurrente en la asignación (ADR-0016) y la decisión 6A, por la que Core es el único que escribe el estado de la solicitud (ADR-0035).

**Operación.** Tres ambientes (DEV, QA y PROD) sobre Docker Compose, con imágenes versionadas en GHCR; respaldo diario cifrado con un simulacro de recuperación de 2 segundos; métricas con Prometheus y Grafana y logs con Loki ([`08-infraestructura/`](../08-infraestructura/README.md)).

## 4. Cómo se trabajó

Seis sprints con Scrum, un tablero en Jira y la convención `[SCRUM-id]` en cada commit y PR. Cada historia termina con QA ejecutado, un video en QA con token real y el visto bueno de la PO. Las cifras por sprint cuentan los ítems que el sprint llegó a contener, así que un ítem arrastrado aparece en más de uno y las filas no se suman:

| Sprint | Fechas | Ítems | En Done | Meta |
|---|---|---|---|---|
| 1 | 26 ago al 4 sep | 17 | 17 | Un tenant puede existir y operar de forma aislada: creación, configuración y autenticación de sus usuarios |
| 2 | 9 al 23 sep (cerrado el 4 oct) | 39 | 39 | Un esqueleto vertical en DEV y QA: cliente y aliado se registran, declaran cobertura y categoría, y una solicitud se asigna a un único aliado sin doble asignación; decisiones validadas con PoC |
| 3 | 4 al 7 oct | 35 | 35 | Sin meta escrita |
| 4 | 13 al 22 oct | 57 | 57 | Sin meta escrita |
| 5 | 26 oct al 4 nov (cerrado el 5 nov) | 124 | 124 | Terminar el desarrollo y demostrar por video, en QA y por el Gateway con token real, que cada funcionalidad cumple. Último sprint de desarrollo |
| 6 | 6 al 25 nov | 103 | 88 al 24 nov | Validación, calidad y documentación final. Sin meta escrita |

## 5. Resultados

### 5.1 Producto

La versión entregada es la `v1.0.5` de los siete repositorios ([`INCREMENTO_DE_VALOR.md`](INCREMENTO_DE_VALOR.md)). 134 de las 135 historias del proyecto están cerradas; la que queda es SCRUM-1643 (mensajes de error con código), en revisión. PROD sirve la versión `v1.0.4` de Flutter Web con un digest que coincide con el tag, y las dieciocho rutas verificadas responden ([`01-mapa-ambientes-y-versiones.md`](../08-infraestructura/01-mapa-ambientes-y-versiones.md)).

### 5.2 Calidad

Los 45 escenarios de calidad (ISO/IEC 25010:2023) se definieron en el SDD §8 con su umbral y se midieron con k6, Newman, SonarQube y revisión de código. Al 24 de noviembre:

| Estado | Escenarios |
|---|---|
| **Cumple (33)** | todos los demás, entre ellos confidencialidad entre tenants (01), integridad (10), no repudio (11), recuperabilidad (17: RTO de 2 s, RPO de hasta 24 h con el umbral del acta A/B) y concurrencia de asignación (41) |
| Parcial (5) | 02 tolerancia a fallos, 06 interoperabilidad, 12 accountability, 21 reusabilidad, 43 TLS |
| No cumple (6) | 03 comportamiento temporal, 19 capacidad, 24 adaptabilidad, 33 involucración, 34 inclusividad, 35 asistencia al usuario |
| No medido (1) | 05 escalabilidad |

Los umbrales de once escenarios P1 que no tenían requisito se revisaron y cuatro quedaron marcados `supuesto`. La PO fijó el criterio de medición de varios escenarios en el acta A/B del 21 de noviembre ([`ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md`](ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md)).

### 5.3 Validación de la documentación

Se detectaron quince contradicciones entre documentos de la línea base (versiones de servicios, número de ambientes, estado de Kafka y de la observabilidad, RPO y RTO, cifrado y otras). **Las quince están cerradas**, cada una con evidencia o con una decisión ([`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md)).

La carpeta de arquitectura se redujo a cuatro documentos (SAD, SDD, ModeloDatos y TECH_RADAR), más las decisiones y los diagramas. El modelo C4 se actualizó al sistema real y el modelo de datos se reescribió desde la base resultante de las migraciones.

## 6. Lo que no se entrega

El detalle, la causa y lo que pasó en el proceso están en [`INFORME_CIERRE_SPRINT_6.md`](INFORME_CIERRE_SPRINT_6.md) §4. En resumen:

- **Rendimiento (QAS-03 y 19).** `eligible-allies` tiene un p95 de 8,2 s con 300 usuarios y la capacidad se queda en 36 req/s frente a los 50 pedidos. El cuello está en la base de datos y el pool del Core.
- **Accesibilidad (QAS-34).** El criterio es WCAG 2.2 AA y ni Flutter ni la Landing lo cumplen.
- **Una sola imagen de QA a PROD (QAS-24).** El backend y el Gateway construyen una imagen por rama.
- **Sistema de diseño y mensajes de error (QAS-33 y 35).** Migración parcial de componentes y errores sin orientar al usuario.
- **Kafka en PROD.** Funciona en DEV y QA; PROD queda sin broker (épica SCRUM-1677).
- **Funcionalidades puntuales.** Siguen abiertas en Jira, en revisión, los aliados de una solicitud (SCRUM-1635), los mensajes de error con código (1643), el sistema de diseño (1648), el rendimiento de `eligible-allies` (1652), el actor y correlation ID (1657) y los contratos OpenAPI (1661). La foto de perfil y el inicio por rol accesible se cerraron después del informe de cierre del Sprint 6.

**Riesgos aceptados al cerrar:** el token de SonarQube expuesto se retiró pero no se rotó; ADR-0034 a ADR-0038 se ratificaron sin sesión de la Mesa de Arquitectura; y RNF-13 y QAS-46 (cifrado en reposo) no están aprobados por la PO. Están en el [acta de cierre](ACTA_DE_CIERRE.md) §6.

## 7. Lecciones aprendidas

1. **Decidimos sin saber si había requisito.** Apareció dos veces y las dos por casualidad: no existía ningún requisito de recuperabilidad ni de cifrado en reposo, y cuatro escenarios P1 no tenían respaldo. *Qué hacer distinto:* antes de pedir una decisión técnica, comprobar que existe el requisito que la decisión debe cumplir; si no existe, el primer trabajo es crearlo, y es del PO.
2. **Validar y medir al final deja hallazgos sin tiempo de corregirse.** En cuatro días del último sprint se pasó de 2 a 60 ítems cerrados porque el trabajo ya estaba hecho y faltaba validarlo; las cargas de rendimiento se corrieron al cierre. La medición del 22 de noviembre descubrió que el registro de aliado persona natural no funcionaba en QA desde el 7 de octubre. *Qué hacer distinto:* validar y medir a mitad de cada sprint, no al final.
3. **Un barrido por carpeta no demuestra que el repositorio esté limpio.** Un barrido de secretos sobre la carpeta de gobernanza dio cero y aun así se escapó un token en otra carpeta de un repositorio público. *Qué hacer distinto:* el barrido se corre sobre todo el repositorio o no se afirma nada sobre el repositorio.
4. **Los estados y las etiquetas no se mantienen solos.** La etiqueta `bloqueado` no existía y nueve bloqueos llevaban días parados como `To Do`. *Qué hacer distinto:* crear el registro de bloqueos vacío en la planning.
5. **Repartir los archivos antes de empezar.** Dos personas sobre los mismos archivos produjeron trabajo duplicado; al repartir las carpetas por dueño, no hubo más conflictos.
6. **Un pedido al grupo sin responsable nombrado no se responde.** Funcionó el pedido directo a una persona, con fecha. *Qué hacer distinto:* todo pedido lleva el nombre de quien responde y una fecha.
7. **Las reglas transversales deben exigirse al revisar el PR.** Reusabilidad, cobertura y uso del sistema de diseño se incumplieron porque ninguna revisión las exigía. *Qué hacer distinto:* convertirlas en comprobaciones de CI o en una lista fija del revisor.
8. **La documentación se desalinea del código si se escribe aparte de él.** El modelo C4 mostraba un servicio de disponibilidad que ya no existía y el modelo de datos describía seis esquemas que la base no tiene. *Qué hacer distinto:* generar diagramas y diccionario desde la fuente, el DSL y la base resultante de las migraciones, y regenerarlos con cada cambio.

## 8. Conclusiones

1. **El MVP se construyó y se validó sobre la arquitectura prevista.** Tres servicios, un Gateway, aislamiento por tenant con RLS y exclusión concurrente en la asignación, desplegados en tres ambientes. Los escenarios de calidad que más pesan para el aislamiento y la integridad se cumplen.
2. **El cuello de botella fue validar, no construir.** En el Sprint 6, 58 ítems pasaron a Done en cuatro días porque el trabajo ya estaba hecho y faltaba validarlo. La planificación debe reservar tiempo de validación y de medición dentro del sprint.
3. **La calidad no funcional quedó más atrás que la funcional.** Rendimiento, accesibilidad y promoción de una misma imagen son los pendientes más serios, y los tres nacen de medir tarde y de definir el criterio después de construir.
4. **Declarar lo que falta fue más útil que ocultarlo.** El estado honesto de los 45 escenarios, de las quince discrepancias y de los riesgos aceptados permite priorizar el trabajo siguiente sin discutir cifras.

## 9. Trabajo futuro

1. Corregir el rendimiento del Core (QAS-03 y 19): consultas por petición y tamaño del pool.
2. Cumplir WCAG 2.2 AA en Flutter y en la Landing, y escribir el criterio en el SDD.
3. Promover el mismo digest de QA a PROD en backend y Gateway.
4. Épica post-MVP SCRUM-1677: Kafka en PROD, clúster de tres nodos, gestor de secretos y despliegue blue/green.
5. Rotar el token de SonarQube y convocar la Mesa para confirmar o revertir los ADR ratificados sin sesión.
6. Segundo incremento: pagos y liquidaciones, quejas, comercialización y métricas por tenant.

## 10. Cómo se reproducen las cifras

| Cifra | Consulta |
|---|---|
| Ítems del proyecto: 764; en Done: 735 | `project = SCRUM` y `project = SCRUM AND statusCategory = Done` |
| Historias: 135; en Done: 134 | `project = SCRUM AND issuetype = Historia` (y con `statusCategory = Done`) |
| Ítems por sprint | `project = SCRUM AND sprint = <id>`, con ids 3, 36, 37, 70, 71 (sprints 1 a 5) y `sprint in openSprints()` (sprint 6) |
| Escenarios de calidad | Columna Resultado del [SDD §8](../02-arquitectura/SDD.md) y su vista operativa [`QAS_45_ESTADO_METODO_EVIDENCIA.md`](../07-calidad/QAS_45_ESTADO_METODO_EVIDENCIA.md) |
| Discrepancias | [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) |

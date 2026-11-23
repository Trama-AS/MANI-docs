# Informe de cierre del Sprint 6

[← Índice de la wiki](../Home.md) · [← 06 Gobernanza](README.md)

| Campo | Valor |
|---|---|
| **Finalidad** | Dejar por escrito qué se cerró, qué no se entrega en el producto final y por qué, y qué aprendimos, con cifras que se puedan reproducir. |
| **Origen** | [SCRUM-1708](https://maniservices.atlassian.net/browse/SCRUM-1708) (T-63) |
| **Redacta** | Sara Albarracín (Scrum Master) |
| **Consume** | El equipo, el PO y el jurado en la sustentación |
| **Versión** | 2.1 · corte **2026-11-23**. La cifra definitiva se toma el día del cierre del sprint |
| **Fuente de las cifras** | Jira: `project = SCRUM AND sprint in openSprints()`, consultada el 2026-11-23. Escenarios de calidad: columna Resultado del [SDD §8](../02-arquitectura/SDD.md), en su vista operativa [`QAS_45_ESTADO_METODO_EVIDENCIA.md`](../07-calidad/QAS_45_ESTADO_METODO_EVIDENCIA.md) v1.1. Reproducible. |

> **Regla de este informe.** Las cifras son las de Jira y las del SDD, no las de la impresión de nadie. Donde el dato es incómodo se escribe igual: un informe de cierre que maquilla no sirve para planificar ni para sustentar.

## 1. Resultados, en cifras

**82 ítems** en el sprint al 2026-11-23. Estado, comparado con los cortes anteriores:

| Estado | 2026-11-23 | 2026-11-22 | 2026-11-19 |
|---|---|---|---|
| **Done** | **57** | 52 | 2 |
| **In Review** | 12 | 17 | 36 |
| In Progress | 4 | 4 | 32 |
| Reopened | 3 | 3 | 2 |
| To Do | 6 | 6 | 9 |

Por tipo: 56 tareas (40 en Done), 19 historias (**14 en Done**), 6 defectos (3 en Done) y 1 épica (sin empezar, fuera del alcance del MVP). Las cinco historias abiertas son SCRUM-1643, 1644, 1647 (en revisión), 1696 (en curso, falta la fila D10) y 1693 (sin empezar).

### El dato que manda

**En cuatro días el sprint pasó de 2 a 57 ítems cerrados.** El trabajo ya estaba hecho el 19-nov; lo que faltaba era validarlo. Eso confirma el diagnóstico del primer corte: **el cuello de botella de este sprint no fue construir, fue validar.** Casi toda historia exige un video en QA con token real y el visto bueno del PO, y el *definition of done* lo decide QA. Son reglas buenas, pero concentran el cierre en dos personas al final del sprint.

**Escenarios de calidad, al cierre:** de los 45, **23 cumplen**, 11 cumplen en parte, 8 no cumplen y 3 no se pudieron medir. El detalle de lo que no se entrega está en [§4](#4-lo-no-entregado-en-el-producto-final).

## 2. Lo que sí se cerró, y vale

**Cinco decisiones de arquitectura con ficha y ratificación.** Pertenencia del cliente a un tenant ([ADR-0036](../02-arquitectura/adr/ADR-0036-pertenencia-del-cliente-a-tenant.md)), cifrado de datos personales en reposo ([ADR-0037](../02-arquitectura/adr/ADR-0037-cifrado-de-datos-personales-en-reposo.md)), logs centralizados con Loki ([ADR-0038](../02-arquitectura/adr/ADR-0038-logs-centralizados-y-trazas-loki.md)) y la enmienda que retiró Datadog de [ADR-0006](../02-arquitectura/adr/ADR-0006-observabilidad.md). **Las cuatro las ratificó la SM el 2026-11-19 sin sesión de Mesa**, porque no se convocó ninguna, y cada ficha dice que la Mesa puede confirmarlas o revertirlas.

**El acta A/B de los escenarios de calidad, firmada por la PO el 2026-11-21** ([acta](ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md)), y sus umbrales escritos en el SDD el mismo día.

**La validación de discrepancias pasó de 0 a 14 de 15 filas cerradas** ([`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md)). Quince contradicciones entre documentos; queda una, D10.

**Cuatro restricciones de proyecto que nadie había escrito** (PROY-09 a PROY-12 del [SRS](../01-producto/SRS.md)): observabilidad, eventos de negocio, lógica fuera de la base de datos y no usar la plataforma de datos como *backend as a service*.

**Una carpeta de infraestructura con evidencia real** ([`08-infraestructura/`](../08-infraestructura/README.md)): digests por servicio y ambiente, puertos verificados, respaldo diario cifrado con simulacro de recuperación de 2 segundos y tiempos reales de despliegue y rollback.

**El análisis de riesgo de las doce operaciones sensibles**, en [`SAD.md`](../02-arquitectura/SAD.md) §23.1, publicado el 2026-11-22 para QAS-38.

**Siete de los nueve bloqueos del sprint resueltos**, con un tiempo medio de 4,5 días hábiles ([`REGISTRO_BLOQUEOS.md`](REGISTRO_BLOQUEOS.md)).

## 3. Lecciones aprendidas

### 3.1 La más cara: decidíamos sin saber si había requisito

Apareció dos veces, y **las dos por casualidad**, al decidir otra cosa. Al cerrar el RPO/RTO se vio que **no existe ningún requisito de recuperabilidad**. Al decidir el responsable del cifrado se vio que **no existe ningún requisito de cifrado en reposo**, y que la historia estaba anclada a RNF-01, que exige aislamiento entre tenants y no cifrado.

Eso llevó a revisar los 45 escenarios de calidad contra los requisitos, y el resultado es el hallazgo más serio del sprint: **cuatro escenarios de prioridad P1 no tienen ningún respaldo** y uno de ellos compromete a QA a medir una disponibilidad del 99,9 % mensual que nadie pidió. Están marcados `supuesto` en el SDD.

**Qué hacer distinto:** antes de pedir una decisión técnica, comprobar que existe el requisito que la decisión debe cumplir. Si no existe, el primer trabajo es crearlo, y es del PO.

### 3.2 Un barrido por carpeta no sirve para decir que el repositorio está limpio

Se hizo un barrido de secretos sobre `wiki/06-gobernanza/` y dio cero credenciales. **Y era cierto, y aun así se nos escapó un token de SonarQube** en `Entregas/`, en un repositorio público. El barrido estaba bien hecho; el alcance estaba mal elegido.

**Qué hacer distinto:** el barrido se corre sobre todo el repositorio, o no se afirma nada sobre el repositorio.

### 3.3 Las etiquetas y los estados no se mantienen solos

La etiqueta `bloqueado` **no existía** en Jira cuando se fue a usar. Nueve bloqueos llevaban días parados sin que el tablero lo dijera: figuraban como `To Do`, indistinguibles de lo que nadie había empezado.

**Qué hacer distinto:** el registro de bloqueos se crea vacío en la planning, no a mitad del sprint.

### 3.4 Dos personas trabajando sobre los mismos archivos sin repartirlos

Hubo trabajo duplicado y una corrección mutua de errores reales en la misma carpeta. Se resolvió repartiendo las carpetas por dueño, y funcionó: cero conflictos después.

**Qué hacer distinto:** repartir antes de empezar, no al chocar.

### 3.5 Medir al final deja hallazgos sin tiempo para corregirlos

La carga completa de rendimiento se corrió el 22 de noviembre, al cierre. Ahí apareció que `eligible-allies` tarda 8,2 s con 300 usuarios (QAS-03) y que la capacidad se queda en 36 req/s (QAS-19). Son problemas del Core que se corrigen en código, pero a esas alturas ya no había sprint para hacerlo. Lo mismo pasó con el acta A/B: se firmó el 21-nov y dejó un solo día para volver a medir contra los umbrales nuevos.

**Qué hacer distinto:** correr la carga y las mediciones de los escenarios a mitad del sprint, no al cierre, para que lo que falle todavía tenga tiempo de corregirse.

### 3.6 Un pedido al grupo sin un responsable nombrado no se responde

La SM pidió varias veces por el grupo información y acciones de cierre, y la respuesta fue escasa: o no contestaba nadie, o la respuesta era que el ítem «ya está en review», sin decir quién lo validaba ni cuándo. Lo que sí funcionó fue el pedido directo a una persona, con fecha. Así se resolvieron los escalamientos del 10 y del 16 de noviembre, el mismo día.

**Qué hacer distinto:** todo pedido lleva el nombre de quien responde y una fecha, y «en review» no cuenta como respuesta si no dice quién valida.

## 4. Lo no entregado en el producto final

El producto se entrega el martes 25 de noviembre. Esto es lo que **no queda entregado** a esa fecha, por qué no, y qué pasó en el proceso para que ocurriera. Los escenarios salen de la columna Resultado del SDD §8 al 2026-11-22; las soluciones y los responsables son los que QA dejó en [`QAS_45_ESTADO_METODO_EVIDENCIA.md`](../07-calidad/QAS_45_ESTADO_METODO_EVIDENCIA.md).

### 4.1 Escenarios de calidad que no se cumplen (8)

| QAS | Qué no se entrega | Responsable | Qué pasó en el proceso |
|---|---|---|---|
| **03** Comportamiento temporal | `eligible-allies` con 300 usuarios: p95 de 8.212 ms frente a un umbral de 500 ms. Las peticiones esperan al Core | Core | La carga se midió al cierre (§3.5). La optimización ([SCRUM-1652](https://maniservices.atlassian.net/browse/SCRUM-1652)) sigue en revisión |
| **19** Capacidad | 36,4 req/s sostenidas frente a un objetivo de 50, con p95 de 7 a 12 s. El cuello es la base de datos y el pool | Core y DevOps | La misma causa que QAS-03. Además, escalar el Core depende de QAS-05, que tampoco se pudo medir |
| **21** Reusabilidad | La validación de reglas del tenant está copiada en Core y en Rules | Core y Rules | La duplicación pasó la revisión de código: ningún PR exigía comprobar que la regla no existiera ya en otro servicio |
| **24** Adaptabilidad | Backend y Gateway construyen una imagen nueva por rama y no promueven el mismo digest de QA a PROD | DevOps | El umbral nuevo se fijó en el acta del 21-nov. La configuración de Flutter al arrancar ([SCRUM-1649](https://maniservices.atlassian.net/browse/SCRUM-1649)) sigue en revisión |
| **30** Reconocibilidad | La acción principal se ve sin ayuda en 11 de 14 flujos. En reglas del tenant y en los dos registros, el botón de guardar queda fuera de la vista | Flutter | La prueba de usabilidad (T-45) se hizo en el último corte. Lo que encontró ya no tuvo tiempo de corregirse |
| **33** Involucración | Quedan 83 componentes nativos en 31 pantallas en vez de los del sistema de diseño Mani | Flutter | La migración ([SCRUM-1648](https://maniservices.atlassian.net/browse/SCRUM-1648)) se fusionó parcial y sigue en revisión. La regla de usar el sistema de diseño no se exigía al revisar los PR |
| **34** Inclusividad | No hay un nivel WCAG definido; pocas etiquetas semánticas y ninguna prueba de escalado de texto | PO y Arquitectura, luego Flutter | **Nunca se fijó el nivel de accesibilidad que había que cumplir.** Sin esa decisión, Flutter no tenía contra qué construir. Es el patrón de §3.1: falta el requisito |
| **35** Asistencia al usuario | 3 de 5 casos orientan al usuario. Una ruta de otro rol redirige al inicio sin mensaje y un error 500 solo dice «Algo salió mal» | Flutter | Los mensajes de error por código ([SCRUM-1643](https://maniservices.atlassian.net/browse/SCRUM-1643)) siguen en revisión |

### 4.2 Escenarios que no se pudieron medir (3)

| QAS | Por qué no se midió | Responsable | Qué pasó en el proceso |
|---|---|---|---|
| **05** Escalabilidad | Escalar con `docker compose --scale` altera el ambiente de QA, que es compartido | DevOps | Nadie autorizó una ventana de mantenimiento en QA para medir. QA depende de un solo ambiente compartido y no tiene uno propio para pruebas destructivas |
| **18** Utilización de recursos | cAdvisor solo exporta la serie del host, sin la CPU de cada contenedor | DevOps | Los exporters se dieron por instalados ([SCRUM-1671](https://maniservices.atlassian.net/browse/SCRUM-1671)), pero no se comprobó que entregaran el dato que el escenario necesita. La falla apareció al intentar medir |
| **27** Coexistencia | La misma causa que QAS-18 | DevOps | La misma que QAS-18 |

### 4.3 Escenarios que se cumplen en parte (11)

| QAS | Qué falta | Responsable | Qué pasó en el proceso |
|---|---|---|---|
| **02** Tolerancia a fallos | El adaptador `mock_falla` existe y tiene pruebas, pero en QA no está activo y la falla no se inyectó | DevOps y QA | El código se entregó ([SCRUM-1662](https://maniservices.atlassian.net/browse/SCRUM-1662), en revisión), pero activarlo en QA era otra tarea que no tenía responsable |
| **06** Interoperabilidad | No se verificó que el 100 % de las rutas tenga contrato OpenAPI | Sara Albarracín | El PR que reporta 127 de 127 contratos ([MANI-docs#81](https://github.com/Trama-AS/MANI-docs/pull/81), [SCRUM-1661](https://maniservices.atlassian.net/browse/SCRUM-1661)) está **retenido sin fusionar** |
| **09** Protección ante fallos | `STORAGE_FALLA` existe para KYC, pero no se inyectó en QA | DevOps y QA | La misma causa que QAS-02 |
| **12** Accountability | La aprobación de un aliado no guarda quién la hizo ni el correlation ID | Core | La tarea de trazabilidad ([SCRUM-1657](https://maniservices.atlassian.net/browse/SCRUM-1657)) no incluía la aprobación de aliados en su alcance |
| **22** Analizabilidad | Core y Dispatch escriben logs en texto plano; Gateway y Rules, en JSON | Core y Dispatch | La tarea ([SCRUM-1658](https://maniservices.atlassian.net/browse/SCRUM-1658)) se **reabrió** al validarla en QA, al final del sprint |
| **23** Capacidad para ser probado | 3 casos de uso críticos con cobertura bajo el 90 %. El Gateway no exige cobertura de código nuevo, y solo su CI corre contract tests | Core, Dispatch y DevOps | La cobertura se midió como resultado, no como condición: los *gates* de CI no la exigían en todos los servicios |
| **26** Reemplazabilidad | Push tiene dos adaptadores intercambiables; pagos solo tiene `mock` | Core | Un segundo adaptador de pagos no estuvo entre las tareas del Sprint 6 |
| **38** Identificación de riesgos | En el corte del 22-nov, 4 de 12 operaciones sensibles tenían análisis de riesgo | Arquitectura | **Resuelto después del corte:** las doce están en [`SAD.md`](../02-arquitectura/SAD.md) §23.1 desde el 2026-11-22. Falta que QA vuelva a medir el escenario |
| **40** Integración segura | El circuit breaker solo está en Rules | Core y Dispatch | La tarea ([SCRUM-1663](https://maniservices.atlassian.net/browse/SCRUM-1663)) se **reabrió** al validarla en QA |
| **43** TLS | El puerto 443 tiene TLS 1.2 y 1.3, pero QA usa el 8080, que sirve la app y la API por HTTP. PROD no se midió | DevOps | El 8080 quedó abierto por comodidad de pruebas y nadie lo cerró ni lo redirigió |
| **44** Reversión de despliegue | El rollback tardó 8 s, pero no se forzó un fallo real ni se repitió una petición crítica | DevOps y QA | El simulacro ([SCRUM-1675](https://maniservices.atlassian.net/browse/SCRUM-1675)) midió el tiempo, pero no el escenario completo que pide el SDD |

### 4.4 Fuera del producto, pero no entregado

| Qué | Responsable | Por qué no se entrega |
|---|---|---|
| **Kafka en PROD** ([SCRUM-1677](https://maniservices.atlassian.net/browse/SCRUM-1677)) | DevOps y Arquitectura | Kafka corre en DEV y QA, pero no en PROD. Está en la épica post-MVP, que según su propio criterio no entra al sprint hasta que la PO la priorice. Los flujos que dependen de eventos asíncronos no funcionan en PROD, y la restricción PROY-10 lo exige |
| **Fila D10 de la validación** | Daniel y Santiago | Falta la consulta a Supabase de PROD y de QA. Se pidió el 22-nov con la consulta corregida en el PR #90 |
| **Ratificación de ADR-0035 en Mesa** | Mesa de Arquitectura | La Mesa no se convocó en todo el sprint, y la SM no puede ratificar un ADR que ella misma propuso |
| **Token de SonarQube sin rotar** | Daniel | Es un **riesgo aceptado**, no resuelto: se retiró de los archivos, pero no se invalidó. Ver [`08-infraestructura/02-accesos-y-gestion-secretos.md`](../08-infraestructura/02-accesos-y-gestion-secretos.md) |
| **RNF-13 y QAS-46 sin aprobar** | PO | Son la base de ADR-0037. Están propuestos, pero la PO no los ha aprobado |
| **Cierres en Jira sin la evidencia que pide el *definition of done*** | QA y PO | [SCRUM-1697](https://maniservices.atlassian.net/browse/SCRUM-1697) se cerró el 2026-11-22 con la prueba de QA de Santiago, pero **sin el video con el visto bueno de la PO**. [SCRUM-1704](https://maniservices.atlassian.net/browse/SCRUM-1704) se cerró aunque ADR-0035 sigue `Propuesto`. Los dos cuentan en los 57 de §1, y el informe lo dice para que la cifra no se lea como validada por completo |
| **Ítems que no llegan a Done al corte** | Cada responsable en Jira | En revisión, esperando prueba de QA: SCRUM-1634, 1644, 1649 y 1710. En revisión sin condiciones para cerrar: 1635, 1643, 1647, 1648, 1652, 1657, 1661 y 1662. **Reabiertos** por fallar la validación: 1658, 1660 y 1663. Sin empezar: 1636, 1670, 1677, 1693 y 1698 |

### 4.5 Las causas de proceso, agrupadas

Casi todo lo anterior cae en cuatro patrones, y ninguno es técnico:

1. **Validar y medir al final** (QAS-03, 19, 22, 24, 30, 40). Lo que falló se encontró cuando ya no había tiempo de corregirlo (§3.5).
2. **Decisiones sin dueño ni fecha** (QAS-34, el acta A/B y ADR-0035). El trabajo técnico esperó una decisión que nadie tenía comprometida (§3.1).
3. **Un solo ambiente compartido y el acceso concentrado en DevOps** (QAS-02, 05, 09, 18, 27, 43, 44). QA no podía medir sin pedir permiso o una ventana, y la ventana no llegó.
4. **Reglas transversales que no se exigían al revisar los PR** (QAS-21, 23, 33). El código cumplía su tarea, pero no la regla común, y nadie lo frenó en la revisión.

## 5. Qué llevar a la sustentación, y qué no

**Se puede afirmar:**
- PROD sirve `v1.0.4`, con un digest que coincide y las dieciocho rutas abiertas.
- Hay respaldo diario cifrado, con un simulacro de recuperación de 2 segundos.
- La observabilidad existe y corre en la VM de Calidad.
- 14 de 15 contradicciones entre documentos están resueltas con evidencia.
- 23 de los 45 escenarios de calidad se cumplen, con su evidencia enlazada.
- 57 de los 82 ítems del sprint están cerrados, y 14 de las 19 historias.

**No se puede afirmar:**
- Que el sistema aguanta la carga objetivo: QAS-03 y QAS-19 no cumplen.
- Que la misma imagen se promueve de QA a PROD.
- Que la app cumple un nivel de accesibilidad, porque ese nivel no está definido.
- Que hay trazas por *spans*.
- Que los escenarios marcados `supuesto` son exigencias del producto.
- Que el token expuesto está resuelto: está aceptado como riesgo, que es distinto.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 2.1 | 2026-11-23 | Corte al 23 de noviembre: 57 de 82 ítems en Done y 14 de 19 historias. §4.4 suma los cierres sin toda la evidencia del *definition of done* (SCRUM-1697 sin el video de la PO; SCRUM-1704 con ADR-0035 aún `Propuesto`) y la lista de ítems que no llegan a Done. La consulta D10 quedó corregida en el PR #90. | Sara Albarracín |
| 2.0 | 2026-11-22 | Corte al 22 de noviembre: 52 de 82 ítems en Done (eran 2) y 13 de 19 historias. §2 recoge las cuatro ratificaciones, el acta A/B firmada y el análisis de riesgo de SAD §23.1. **§4 se reescribe como lo no entregado en el producto final**: los 8 escenarios que no cumplen, los 3 sin medir y los 11 parciales, cada uno con su responsable y lo que pasó en el proceso, más lo no entregado fuera del producto y las cuatro causas de proceso agrupadas. Dos lecciones nuevas: medir al final (3.5) y los pedidos sin un responsable nombrado (3.6). | Sara Albarracín |
| 1.0 | 2026-11-19 | Informe inicial. Cifras de Jira del mismo día: 81 ítems, 2 en Done, ninguna de las 19 historias cerrada y 36 en revisión. Cuatro lecciones aprendidas y nueve puntos abiertos con su responsable. | Sara Albarracín |

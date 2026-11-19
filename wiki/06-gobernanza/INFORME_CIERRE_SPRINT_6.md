# Informe de cierre del Sprint 6

[← Índice de la wiki](../Home.md) · [← 06 Gobernanza](README.md)

| Campo | Valor |
|---|---|
| **Finalidad** | Dejar por escrito qué se cerró, qué no, qué aprendimos y qué deuda queda abierta, con cifras que se puedan reproducir. |
| **Origen** | [SCRUM-1708](https://maniservices.atlassian.net/browse/SCRUM-1708) (T-63) |
| **Redacta** | Sara Albarracín (Scrum Master) |
| **Consume** | El equipo, el PO y el jurado en la sustentación |
| **Versión** | 1.0 · corte **2026-11-19** |
| **Fuente de las cifras** | Consulta JQL a Jira el 2026-11-19: `project = SCRUM AND sprint in openSprints()`. Reproducible. |

> **Regla de este informe.** Las cifras son las de Jira, no las de la impresión de nadie. Donde el dato es incómodo se escribe igual: un informe de cierre que maquilla no sirve para planificar el siguiente sprint.

## 1. Resultados, en cifras

**81 ítems** en el sprint. Estado al cierre:

| Estado | Ítems | Qué significa aquí |
|---|---|---|
| **In Review** | **36** | Trabajo hecho que espera validación: el video en QA con token real, el visto bueno del PO o el *definition of done* de QA |
| **In Progress** | 32 | En curso |
| To Do | 9 | Sin empezar |
| Reopened | 2 | Reabiertos tras validación |
| **Done** | **2** | Cerrados formalmente |

Por tipo: 55 tareas, 19 historias, 6 defectos y 1 épica.

### El dato que manda, y no se suaviza

**De las 19 historias del sprint, ninguna está en Done.** De los 81 ítems, **2**.

Eso no significa que no se haya trabajado: 36 ítems están en revisión, es decir, **terminados y esperando a que alguien los valide**. Pero el marcador formal es el que es, y conviene decirlo en estos términos: **el cuello de botella de este sprint no fue construir, fue validar**.

La causa es estructural y está en nuestras propias reglas. Casi toda historia exige un video grabado en QA, a través del Gateway, con token real ES256, y el visto bueno del PO; y quien decide el *definition of done* es QA, no quien implementa. Son reglas buenas —evitan dar por hecho lo que no está probado— pero concentran el cierre en dos personas al final del sprint. Con 36 ítems llegando juntos a esa puerta, la puerta es el límite.

## 2. Lo que sí se cerró, y vale

No todo el valor del sprint está en el marcador. Lo que queda escrito y verificable:

**Cinco decisiones de arquitectura**, dos de ellas nuevas en este sprint: la pertenencia del cliente a un tenant ([ADR-0036](../02-arquitectura/adr/ADR-0036-pertenencia-del-cliente-a-tenant.md)), el cifrado de datos personales en reposo ([ADR-0037](../02-arquitectura/adr/ADR-0037-cifrado-de-datos-personales-en-reposo.md)) y los logs centralizados con Loki ([ADR-0038](../02-arquitectura/adr/ADR-0038-logs-centralizados-y-trazas-loki.md)), más la enmienda que retiró Datadog de [ADR-0006](../02-arquitectura/adr/ADR-0006-observabilidad.md). **Las cuatro están decididas y pendientes de ratificación en Mesa**, y así figuran: no se presentan como aceptadas.

**La validación de discrepancias pasó de 0 a 14 de 15 filas cerradas** ([`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md)). Quince puntos en que los documentos del proyecto se contradecían; hoy queda uno. Eso es lo que evita presentar cifras falsas en la sustentación, que era el objetivo de la historia.

**Cuatro restricciones de proyecto que nadie había escrito** (PROY-09 a PROY-12 del [SRS](../01-producto/SRS.md)): la observabilidad, los eventos de negocio, la lógica fuera de la base de datos y el no usar la plataforma de datos como *backend as a service*. Se cumplían por costumbre, sin requisito detrás.

**Una carpeta de infraestructura con evidencia real** ([`08-infraestructura/`](../08-infraestructura/README.md)): digests por servicio y ambiente, puertos verificados con `ss -tulpn`, respaldo diario cifrado con simulacro de recuperación cronometrado y tiempos reales de despliegue y rollback. Es lo que cerró seis filas de la validación de golpe.

**La wiki quedó a cero enlaces internos rotos**, desde 37 que había.

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

## 4. Deuda abierta

| Qué | De quién | Por qué importa |
|---|---|---|
| **36 ítems en revisión** | PO y QA | Es el cuello de botella real. Entra al Sprint 7 tal cual |
| **Ratificar cuatro decisiones en Mesa** | Mesa de Arquitectura | ADR-0036, ADR-0037, ADR-0038 y la enmienda de ADR-0006 están decididas y sin ratificar |
| **Cuatro escenarios P1 sin respaldo** | PO | Crear los requisitos, bajar su prioridad o retirarlos. No se arregla escribiendo |
| **Fila D10 de la validación** | Daniel y Santiago | La única que queda: migraciones y `BYPASSRLS` en PROD |
| **Token de SonarQube sin rotar** | Daniel | **Riesgo aceptado por el equipo**, no resuelto. Ver [`08-infraestructura/02-accesos-y-gestion-secretos.md`](../08-infraestructura/02-accesos-y-gestion-secretos.md) |
| **Acta A/B de ocho escenarios** | PO | No existe. Sin ella, la tarea de reescribir umbrales no tiene trabajo |
| **Kafka no está en PROD** | Arquitectura y DevOps | Descubierto al cerrar la fila D7. Cualquier flujo que dependa de eventos asíncronos no funciona allí, y **PROY-10** lo exige |
| **QAS-17 figura `No medido`** | Arquitectura | El simulacro de recuperación del 15 de noviembre **es** una medición. Hay que actualizarlo |
| **La imagen del Tech Radar** | Arquitectura | No coincide con las listas: no muestra Loki y todavía muestra Datadog |

## 5. Qué llevar a la sustentación, y qué no

**Se puede afirmar:** que PROD sirve `v1.0.4` con digest que coincide y las dieciocho rutas abiertas; que hay respaldo diario cifrado con simulacro de recuperación de 2 segundos; que la observabilidad existe y corre en la VM de Calidad; que 14 de 15 contradicciones documentales están resueltas con evidencia de sistema o de código.

**No se puede afirmar:** que las historias del sprint están terminadas, porque formalmente no lo están; que hay APM o trazas por *spans*, porque quedaron fuera de fase; que los escenarios marcados `supuesto` son exigencias del producto, porque no lo son; ni que el token expuesto está resuelto, porque está aceptado como riesgo, que es distinto.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.0 | 2026-11-19 | Informe inicial. Cifras tomadas de Jira el mismo día: 81 ítems, 2 en Done, ninguna de las 19 historias cerrada y 36 en revisión. Cuatro lecciones aprendidas y nueve puntos de deuda abierta con su responsable. | Sara Albarracín |

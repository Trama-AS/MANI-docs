# Registro de bloqueos del Sprint 6

[← Índice de la wiki](../Home.md) · [← 06 Gobernanza](README.md)

| Campo | Valor |
|---|---|
| **Finalidad** | Que todo bloqueo del Sprint 6 quede trazable desde su aparición hasta su resolución, con causa, responsable y tiempo, y que el informe de cierre se alimente de aquí y no de la memoria de la *daily*. |
| **Origen** | [SCRUM-1709](https://maniservices.atlassian.net/browse/SCRUM-1709) (T-64) |
| **Mantiene** | Sara Albarracín (Scrum Master), gestión de impedimentos |
| **Consume** | El equipo en cada *daily*; el informe de cierre del Sprint 6 ([SCRUM-1708](https://maniservices.atlassian.net/browse/SCRUM-1708)); el PO para los bloqueos que escalan a decisión |
| **Se actualiza** | En cada *daily*: se abre lo nuevo, se cierra lo resuelto y se recalcula el tiempo abierto |
| **Versión** | 1.2 |
| **Fecha de corte** | 2026-11-11 |
| **Umbral de escalamiento** | **2 días hábiles abierto.** Al cumplirse, el bloqueo se escala con evidencia al rol con autoridad sobre el artefacto ([`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §2.3). |

> **Regla de este registro.** Un bloqueo se registra el día en que se detecta, no el día en que alguien decide que es importante. Si no tiene responsable nombrado, el responsable es la SM hasta que se reasigne: un bloqueo sin dueño no existe para nadie.

## 1. Qué cuenta como bloqueo

Un ítem está bloqueado cuando **no puede avanzar por una causa externa a quien lo tiene asignado**. Tres causas, y conviene no confundirlas porque se resuelven distinto:

| Tipo | Qué lo causa | Quién lo resuelve |
|---|---|---|
| **Decisión** | Falta una decisión de un rol con autoridad (PO, Mesa de Arquitectura) | El rol que decide, por escrito |
| **Dependencia** | Falta un entregable de otra tarea o de otra persona | El responsable de esa tarea |
| **Acceso** | Falta una credencial, un permiso, una red o un ambiente | DevOps o quien administre el recurso |

No es un bloqueo: una tarea que avanza despacio, una tarea mal estimada, ni una tarea que nadie ha empezado.

## 2. Bloqueos abiertos

Ocho bloqueos al 2026-11-11. Las fechas de aparición son las del hecho que los origina, no la de este registro.

| ID | Ítem afectado | Tipo | Causa | Responsable de resolverlo | Aparición | Días hábiles | Estado |
|---|---|---|---|---|---|---|---|
| **B-01** | [SCRUM-1685](https://maniservices.atlassian.net/browse/SCRUM-1685) (reescribir SDD §7 y §8) | Dependencia | El acta de decisión A/B ([SCRUM-1684](https://maniservices.atlassian.net/browse/SCRUM-1684)) está en `To Do` y no existe como documento. El 2026-11-11 se decidió una de sus partes —el RPO/RTO único, fila D4—, pero el acta sigue faltando: nadie ha marcado cada escenario como A o B con su motivo, y la firma es del PO. Reescribir el SDD sin eso sería inventar las cifras | Camila Beltrán (PO) firma; Sara Albarracín facilita | 2026-11-09 | **2** | **Escalado** — en umbral |
| **B-02** | [SCRUM-1686](https://maniservices.atlassian.net/browse/SCRUM-1686) (SDD §8, Infra V4 §7, Excel) | Dependencia | Doble: espera a B-01 (la tarea declara que va después de la T-48) y espera la fila D8 de HU-VAL-01, que fija si hay observabilidad en QA. **La cifra del enunciado ya está corregida** el 2026-11-11: el título y el criterio decían 82/84 y ahora dicen **84/85**, el conteo de Jira. Queda por corregir el Excel, que es parte de la tarea | Camila Beltrán (PO) y Daniel Ávila; la cifra la corrige Sara | 2026-11-09 | **2** | **Escalado** — en umbral, y con la cifra del enunciado en disputa |
| **B-03** | [SCRUM-1696](https://maniservices.atlassian.net/browse/SCRUM-1696), 7 filas (D1, D5, D6, D7, D8, D9, D10) | Acceso | Las siete exigen sesión SSH en las VMs de DEV, QA y PROD, consulta a Supabase de PROD, o prueba de puertos **desde la red de la universidad**. No son verificables desde los repositorios. El usuario SSH se solicita al DevOps Lead y no está repartido | Daniel Ávila (DevOps), con Santiago para D6 y D10 | 2026-11-10 | **1** | Abierto |
| **B-04** | [SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637) (clientes asociados a un tenant) | Decisión | La ficha [ADR-0036](../02-arquitectura/adr/ADR-0036-pertenencia-del-cliente-a-tenant.md) ya está publicada y establece que no es un defecto sino el diseño vigente, pero está en estado `Propuesto`: faltan las respuestas M1 a M4. No se toca código hasta que el ADR esté aprobado | Camila Beltrán (PO); M4 a la Mesa de Arquitectura | 2026-11-05 | **4** | **Escalado** — supera el umbral |
| **B-05** | [SCRUM-1638](https://maniservices.atlassian.net/browse/SCRUM-1638) (desplegar front v1.0.4 y repetir las 18 rutas) | Dependencia | Está en `To Do`, y es la evidencia que la fila D1 necesita para cerrar. Mientras no se ejecute, la afirmación «PROD en v1.0.4 al 100 %» no tiene respaldo y no puede presentarse como hecho | Daniel Ávila (despliegue) y Camila Beltrán (revisión de rutas) | 2026-11-09 | **2** | **Escalado** — en umbral |
| **B-06** | [SCRUM-1704](https://maniservices.atlassian.net/browse/SCRUM-1704) (ADR 6A y SAD §7.4) | Decisión | [ADR-0035](../02-arquitectura/adr/ADR-0035-frontera-de-asignacion-6a.md) sigue `Propuesto` y [ADR-0032](../02-arquitectura/adr/ADR-0032-identidad-de-servicio-en-base-de-datos.md) está aprobado en revisión de arquitectura pero **pendiente de acta de Mesa**. La asignación idempotente no está escrita en el SAD | Mesa de Arquitectura (ADR-0003) | 2026-11-09 | **2** | **Escalado** — en umbral |
| **B-07** | Las ocho HU de wiki, entre ellas [SCRUM-1690](https://maniservices.atlassian.net/browse/SCRUM-1690) y [SCRUM-1711](https://maniservices.atlassian.net/browse/SCRUM-1711) | Decisión | Los criterios comunes exigen **suplente por carpeta**, y ninguna carpeta lo tiene asignado. Es una decisión de equipo, no de la responsable de cada carpeta | El equipo, según [`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §2.3 | 2026-11-09 | **2** | **Escalado** — en umbral, y afecta a ocho historias a la vez |
| **B-08** | Las ocho HU de wiki | Dependencia | Los criterios comunes exigen que **otro responsable de carpeta revise y apruebe el README**. Ningún README está revisado por un par, así que ninguna de las ocho puede cerrarse aunque su contenido esté completo | Responsables de carpeta, en revisión cruzada | 2026-11-10 | **1** | Abierto |
| **B-09** | [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699) (ADR de cifrado) y con él [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383) | Decisión | **No hay requisito que cumplir.** Los RNF vigentes van de RNF-01 a RNF-11 y ninguno exige cifrado en reposo; el SDD tiene QAS-01 y QAS-43 (confidencialidad entre tenants y **en tránsito**) pero **ningún escenario de confidencialidad en reposo**. Sin umbral ni método, cualquier elección de mecanismo sería una cifra inventada. La necesidad sí está documentada: la Ley 1581 de 2012, citada en el SRS | Camila Beltrán (PO): un RNF de protección de datos personales en reposo y un QAS derivado con umbral y método | 2026-11-11 | **0** | Abierto — recién identificado al decidir P-D15a |

## 3. Bloqueos resueltos

| ID | Ítem afectado | Causa | Aparición | Resolución | Días hábiles | Cómo se resolvió |
|---|---|---|---|---|---|---|
| **B-00** | [SCRUM-1700](https://maniservices.atlassian.net/browse/SCRUM-1700) (ADR del tenant de clientes) | Dependencia: el ADR no existía y [SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637) no podía avanzar sin él | 2026-11-09 | 2026-11-11 | 2 | Se publicó [ADR-0036](../02-arquitectura/adr/ADR-0036-pertenencia-del-cliente-a-tenant.md) en estado `Propuesto`. **El bloqueo de redacción se cierra; el de decisión queda abierto como B-04.** Un bloqueo que cambia de tipo no se cierra sin abrir el que lo sucede |

## 4. Resumen al corte

| Métrica | Valor al 2026-11-11 |
|---|---|
| Bloqueos abiertos | **9** |
| Bloqueos resueltos | **1** |
| En o sobre el umbral de 2 días hábiles | **6** de 9 (B-01, B-02, B-04, B-05, B-06, B-07) |
| Tiempo medio de resolución | **2 días hábiles**, sobre una sola muestra: no es un promedio significativo todavía |
| Por tipo | Decisión **5** · Dependencia **3** · Acceso **1** |

**Causas recurrentes y su acción de mejora.** Tres patrones, los tres con acción asociada, como exige el criterio de aceptación:

| Patrón | Cuántos | Acción de mejora o riesgo |
|---|---|---|
| **Falta una decisión del PO o de la Mesa** (B-01, B-04, B-06, B-07) | 4 de 9 | El 2026-11-11 se cerraron cinco puntos de golpe ([`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) §4: D4, D12, P-D2, P-D14, P-D15a), lo que confirma que el cuello de botella era la falta de una sesión de decisión, no la dificultad de las preguntas. Acción: repetir esa sesión con lo que queda —M1 a M4 de [ADR-0036](../02-arquitectura/adr/ADR-0036-pertenencia-del-cliente-a-tenant.md), el acta A/B y la ratificación en Mesa de ADR-0032, ADR-0035 y ADR-0036— con fecha comprometida. **Riesgo si no ocurre:** la sustentación presenta como pendientes cuatro bloques de trabajo que ya estaban hechos salvo por una firma |
| **Nadie tiene acceso al ambiente que debe verificar** (B-03, y B-05 en parte) | 2 de 9 | El acceso SSH a las VMs y a Supabase de PROD está concentrado en DevOps y no está repartido ni documentado. Acción: repartir el acceso de lectura, o agendar una sesión conjunta en la que se ejecuten de una vez los comandos ya escritos en [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) §3. **Riesgo si no ocurre:** siete filas llegan a la sustentación como «pendiente de validar» |
| **El requisito que la decisión debería cumplir no existe** (B-09, y el trasfondo de B-01) | 2 de 9 | Es el patrón más costoso porque no se ve: al decidir D4 y P-D15a quedó a la vista que **no hay RNF de recuperabilidad ni RNF de cifrado en reposo**, y sin requisito no hay umbral que QA pueda verificar ni ADR que se pueda escribir. Acción: el PO crea los dos RNF que faltan y sus QAS derivados antes de pedir la decisión técnica. **Riesgo si no ocurre:** se decide un mecanismo sin umbral, QA no puede verificarlo y la decisión vuelve a abrirse |

## 5. Lo que falta para cerrar SCRUM-1709

| # | Qué falta | De quién depende |
|---|---|---|
| 1 | ~~Crear la etiqueta `bloqueado` y aplicarla~~ **Hecho el 2026-11-11.** La etiqueta no existía —`labels in (bloqueado, bloqueo, blocked)` y `status = Blocked` daban cero en todo el proyecto— y Jira la creó al usarla. Aplicada a los **diez tickets** que cubren los nueve bloqueos: SCRUM-1685, 1686, 1696, 1637, 1638, 1704, 1690, 1711, 1699 y 1383, más SCRUM-1712. Las etiquetas previas de cada ticket se conservaron | — |
| 2 | **Revisar los bloqueos abiertos en cada *daily*** y actualizar aquí lo que cambie | El equipo en la *daily* |
| 3 | **Evidencia del escalamiento** de los seis que están en o sobre el umbral: a quién se escaló, cuándo y con qué respuesta | Sara Albarracín (SM) |
| 4 | **Resumen de cierre** con el número final, el tiempo medio y las causas recurrentes, para alimentar [SCRUM-1708](https://maniservices.atlassian.net/browse/SCRUM-1708) | Sara Albarracín (SM), al cerrar el sprint |

El criterio «la tabla existe antes del inicio del sprint» **no se cumplió**: el registro se crea el 2026-11-11, con el sprint en curso. Queda dicho así, y no como cumplido, porque los ocho bloqueos de §2 ya estaban activos antes de que existiera dónde anotarlos. Para el Sprint 7 la tabla debe crearse vacía en la *planning*.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.2 | 2026-11-11 | Se aplica la etiqueta `bloqueado` en Jira a los diez tickets de los nueve bloqueos, con lo que el primer criterio de SCRUM-1709 queda cumplido. B-02 recoge que el título y el criterio de SCRUM-1686 ya dicen 84/85. | Sara Albarracín |
| 1.1 | 2026-11-11 | Alineación con la v2.0 de [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md). Se añade **B-09**: el ADR de cifrado está bloqueado porque no existe el requisito que debería cumplir, ni RNF ni QAS de confidencialidad en reposo. Se matiza B-01: la decisión de D4 cerró el RPO/RTO único, pero el acta A/B sigue faltando. Se añade una tercera causa recurrente —el requisito inexistente— y se recalcula el resumen a nueve bloqueos abiertos. | Sara Albarracín |
| 1.0 | 2026-11-11 | Registro inicial. Ocho bloqueos abiertos y uno resuelto, con tipo, causa, responsable, fecha de aparición y días hábiles. Resumen por tipo, dos causas recurrentes con su acción de mejora, y constancia de que la etiqueta `bloqueado` no existe todavía en Jira. | Sara Albarracín |

# Registro de bloqueos del Sprint 6

[← Índice de la wiki](../Home.md) · [← 06 Gobernanza](README.md)

| Campo | Valor |
|---|---|
| **Finalidad** | Que todo bloqueo del Sprint 6 quede trazable desde su aparición hasta su resolución, con causa, responsable y tiempo, y que el informe de cierre se alimente de aquí y no de la memoria de la *daily*. |
| **Origen** | [SCRUM-1709](https://maniservices.atlassian.net/browse/SCRUM-1709) (T-64) |
| **Mantiene** | Sara Albarracín (Scrum Master), gestión de impedimentos |
| **Consume** | El equipo en cada *daily*; el informe de cierre del Sprint 6 ([SCRUM-1708](https://maniservices.atlassian.net/browse/SCRUM-1708)); el PO para los bloqueos que escalan a decisión |
| **Se actualiza** | En cada *daily*: se abre lo nuevo, se cierra lo resuelto y se recalcula el tiempo abierto |
| **Versión** | 1.4 |
| **Fecha de corte** | 2026-11-22. Días hábiles de lunes a viernes, sin el festivo del 16 de noviembre |
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

**Dos bloqueos abiertos al 2026-11-22**, de los nueve registrados el 11 de noviembre. Los otros siete se resolvieron entre el 12 y el 21 de noviembre y están en [§3](#3-bloqueos-resueltos).

| ID | Ítem afectado | Tipo | Causa | Responsable de resolverlo | Aparición | Días hábiles | Estado |
|---|---|---|---|---|---|---|---|
| **B-03** | [SCRUM-1696](https://maniservices.atlassian.net/browse/SCRUM-1696), fila **D10** | Acceso | De las siete filas que exigían acceso a los ambientes, seis se cerraron el 2026-11-19 con la evidencia que DevOps publicó en [`08-infraestructura/`](../08-infraestructura/README.md). Queda **D10**: las migraciones aplicadas y `BYPASSRLS` en los roles de servicio, que solo se comprueban con una consulta a Supabase de PROD y de QA. La consulta se corrigió el 2026-11-22 ([`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) §3.1): la versión anterior leía una tabla equivocada y exigía `f` en roles que en Supabase tienen `BYPASSRLS` por diseño. **El 2026-11-23 Santiago corrió la consulta en QA y cumple**; falta solo PROD, que depende de Daniel | Daniel Ávila o Santiago Hernández, que tienen acceso a los dos proyectos | 2026-11-10 | **7** | **Supera el umbral.** Pendiente de la consulta |
| **B-06** | [SCRUM-1704](https://maniservices.atlassian.net/browse/SCRUM-1704) (ADR 6A) | Decisión | [ADR-0035](../02-arquitectura/adr/ADR-0035-frontera-de-asignacion-6a.md) sigue `Propuesto` y [ADR-0032](../02-arquitectura/adr/ADR-0032-identidad-de-servicio-en-base-de-datos.md) sigue pendiente de acta. **La Mesa no se convocó en todo el Sprint 6.** La SM ratificó el 2026-11-19 otras cuatro decisiones sin Mesa (ADR-0036, 0037, 0038 y la enmienda de 0006), pero no puede ratificar ADR-0035 porque es su proponente. La asignación idempotente sí está escrita en `SAD.md` §7.2 y §7.4: lo que falta es la firma, no el contenido. SCRUM-1704 se cerró en Jira, pero el bloqueo sigue: el ADR no está ratificado | Mesa de Arquitectura (ADR-0003) | 2026-11-09 | **8** | **Supera el umbral.** Sin respuesta: depende de convocar una sesión, no de una persona |

## 3. Bloqueos resueltos

| ID | Ítem afectado | Causa | Aparición | Resolución | Días hábiles | Cómo se resolvió |
|---|---|---|---|---|---|---|
| **B-00** | [SCRUM-1700](https://maniservices.atlassian.net/browse/SCRUM-1700) (ADR del tenant de clientes) | Dependencia: el ADR no existía y [SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637) no podía avanzar sin él | 2026-11-09 | 2026-11-11 | 2 | Se publicó [ADR-0036](../02-arquitectura/adr/ADR-0036-pertenencia-del-cliente-a-tenant.md) en estado `Propuesto`. **El bloqueo de redacción se cerró; el de decisión siguió abierto como B-04.** Un bloqueo que cambia de tipo no se cierra sin abrir el que lo sucede |
| **B-08** | Las ocho HU de wiki | Dependencia: revisión del README por otro responsable de carpeta | 2026-11-10 | 2026-11-12 | 2 | **Criterio retirado por la SM**, no cumplido: ninguna carpeta declaraba responsable, así que la figura que el criterio invocaba no existía. Se retiró en vez de darlo por cumplido sin revisión real |
| **B-07** | Las ocho HU de wiki | Decisión: suplente por carpeta | 2026-11-09 | 2026-11-12 | 3 | En las dos carpetas de la SM: suplencia de la **Mesa de Arquitectura** como órgano en 02-arquitectura (2026-11-11) y de la **PO** en 06-gobernanza (2026-11-12). Las demás carpetas lo resolvieron sus responsables al cerrar su HU |
| **B-05** | [SCRUM-1638](https://maniservices.atlassian.net/browse/SCRUM-1638) (front v1.0.4 en PROD y las 18 rutas) | Dependencia: la tarea no se había ejecutado y la fila D1 no tenía respaldo | 2026-11-09 | 2026-11-15 | 4 | DevOps capturó la evidencia el 14 y 15-nov: digest de PROD igual al tag `v1.0.4` y `200 OK` en las 18 rutas. Con ella se cerró D1 el 2026-11-19, y la tarea pasó a `Done` el 2026-11-21 |
| **B-04** | [SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637) (clientes asociados a un tenant) | Decisión: ADR-0036 sin respuestas M1 a M4 | 2026-11-05 | 2026-11-12 | 5 | ADR-0036 v2.0 respondió M1 a M4 y SCRUM-1637 se cerró como «funciona según diseño». La SM ratificó el ADR el 2026-11-19 sin Mesa, y la Mesa puede confirmarlo o revertirlo |
| **B-09** | [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699) y [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383) (cifrado) | Decisión: no existía el requisito que el ADR debía cumplir | 2026-11-11 | 2026-11-19 | 5 | Se propusieron RNF-13 y QAS-46 ([`PROPUESTA_RNF_PROTECCION_Y_RECUPERACION.md`](PROPUESTA_RNF_PROTECCION_Y_RECUPERACION.md)); [ADR-0037](../02-arquitectura/adr/ADR-0037-cifrado-de-datos-personales-en-reposo.md) decidió la opción A, con acreditación técnica el 14-nov, y la SM lo ratificó el 19-nov. SCRUM-1383 pasó a `Done` el 21-nov. **Queda abierto, sin bloquear:** la aprobación de RNF-13 y QAS-46 por la PO (M2 del ADR) |
| **B-02** | [SCRUM-1686](https://maniservices.atlassian.net/browse/SCRUM-1686) (SDD §8, Infra V4 §7, Excel) | Dependencia: esperaba la fila D8 | 2026-11-09 | 2026-11-19 | 7 | Al cerrarse D8 el 2026-11-19, DevOps actualizó `SDD.md` §8 e Infraestructura V4 §7 (`a0bb876`). El Excel salió del alcance el 2026-11-12, porque ninguna de sus 34 hojas tiene el conteo de historias, y el 84/85 ya está en D11. La tarea está en revisión |
| **B-01** | [SCRUM-1685](https://maniservices.atlassian.net/browse/SCRUM-1685) (reescribir SDD §7 y §8) | Dependencia: el acta A/B no existía | 2026-11-09 | 2026-11-21 | 8 | La PO firmó el [acta A/B](ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md) el 2026-11-21 y QA escribió los umbrales en el SDD (`7815d75`). SCRUM-1685 `Done` ese mismo día. **Es el bloqueo que más duró**, y por la causa más evitable: no había una fecha comprometida para firmar el acta |

## 3.1 Evidencia del escalamiento

El umbral de escalamiento son **2 días hábiles**. Seis bloqueos lo alcanzaron o lo superaron, y esta es la evidencia de haberlos escalado, con la respuesta recibida. Dos conversaciones, las dos conducidas por la SM.

### Escalamiento del 2026-11-10 al Product Owner

**A quién:** Camila Beltrán (PO). **Canal:** mensaje directo. **Qué se escaló:** las decisiones de producto que tenían bloqueado trabajo de otros, entre ellas los bloqueos **B-04** (la pertenencia del cliente a un tenant) y las filas de la validación que esperaban decisión suya.

**Respuesta recibida, el mismo día.** Cerró cinco decisiones: Jardinería activa en PROD y desactivada en QA; la baja de sedes se mantiene como baja lógica y pasa al siguiente incremento; las cuatro preguntas de pagos de Nicolás (10 % de comisión, liberar al finalizar, liquidar lo retenido menos la comisión, pago aparte); HU-M04-05 se da por cubierta con [SCRUM-1390](https://maniservices.atlassian.net/browse/SCRUM-1390), [SCRUM-1391](https://maniservices.atlassian.net/browse/SCRUM-1391) y [SCRUM-1393](https://maniservices.atlassian.net/browse/SCRUM-1393); y el acta de la 1470 queda aceptada con condiciones.

**Resultado.** Desbloqueó dos filas de la validación, **D13** y **D14-PROD**, y ratificó la decisión **P-D2**. Registrado en [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) §2 y §4.

### Escalamiento del 2026-11-16 a DevOps

**A quién:** Daniel Ávila (DevOps Lead). **Canal:** mensaje directo. **Qué se escaló:** el token de SonarQube y las credenciales de las máquinas virtuales expuestos en un repositorio **público**, registrado en [SCRUM-1712](https://maniservices.atlassian.net/browse/SCRUM-1712) con prioridad máxima.

**Respuesta recibida, el mismo día.** Confirmó que **no rotó** el token ni las credenciales de las VMs, y dio su justificación: el token tiene como objetivo el propio proyecto, de modo que a su juicio un tercero no podría hacer daño con él; las VMs están todas tras la VPN de la universidad; y cambiar las contraseñas de las VMs obligaría a los siete integrantes a hacerlo con la entrega encima. Lo que sí hizo: retirar las credenciales de los archivos activos y sacar el valor de `HEAD`.

**Resultado.** La SM aceptó el criterio el 2026-11-19 y queda registrado como **riesgo aceptado con justificación**, no como resuelto, en [`08-infraestructura/02-accesos-y-gestion-secretos.md`](../08-infraestructura/02-accesos-y-gestion-secretos.md). SCRUM-1712 pasó a `Done` el 2026-11-21 con ese alcance: credenciales retiradas de `HEAD`, **sin rotar**.

### Lo que estos dos escalamientos dejan dicho

Los seis bloqueos que superaron el umbral **se escalaron y obtuvieron respuesta**, de modo que el criterio de aceptación queda cumplido. Pero la respuesta no siempre fue desbloquear: en el caso del token fue **aceptar el riesgo de forma deliberada**, y eso también es una respuesta válida de quien tiene la autoridad. Lo que no sería válido es presentarlo como cerrado.

**Lo que sigue sin escalarse con respuesta** es **B-06**, que espera a la Mesa de Arquitectura y depende de convocar una sesión, no de una persona. B-07 se resolvió el 2026-11-12 sin necesidad de sesión. **B-03** pasó el umbral con la fila D10: la evidencia de su escalamiento se registra aquí cuando Daniel o Santiago respondan.

## 4. Resumen al corte

| Métrica | Valor al 2026-11-22 | Valor al 2026-11-11 |
|---|---|---|
| Bloqueos registrados | **10** (B-00 a B-09) | 10 |
| Abiertos | **2** (B-03, B-06) | 9 |
| Resueltos | **8** | 1 |
| Tiempo medio de resolución | **4,5 días hábiles** sobre 8 muestras (mínimo 2, máximo 8; mediana 4,5) | 2, sobre una sola muestra |
| Superaron el umbral de 2 días hábiles | **7** de 10: B-01, B-02, B-03, B-04, B-05, B-06 y B-09 | 6 de 9 |
| Por tipo, los 10 | Decisión **5** · Dependencia **4** · Acceso **1** | — |
| Por tipo, los 2 abiertos | Decisión **1** (Mesa) · Acceso **1** (Supabase) | — |

**Lo que dicen las cifras.** Los bloqueos de **decisión** se resolvieron en cuanto hubo una sesión o alguien con autoridad que decidiera; el que sigue abierto (B-06) es justamente el único que exige una sesión que nunca se convocó. Los de **dependencia** tardaron más (de 2 a 8 días) porque esperaban un entregable de otra persona sin fecha comprometida: B-01, el más largo, esperó doce días naturales un acta que podía firmarse en una reunión.

**Causas recurrentes y su acción de mejora.** Tres patrones, los tres con acción asociada, como exige el criterio de aceptación:

| Patrón | Cuántos | Acción de mejora o riesgo |
|---|---|---|
| **Falta una decisión del PO o de la Mesa** (B-01, B-04, B-06, B-07) | 4 de 9 | El 2026-11-11 se cerraron cinco puntos de golpe ([`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) §4: D4, D12, P-D2, P-D14, P-D15a), lo que confirma que el cuello de botella era la falta de una sesión de decisión, no la dificultad de las preguntas. Acción: repetir esa sesión con lo que queda —M1 a M4 de [ADR-0036](../02-arquitectura/adr/ADR-0036-pertenencia-del-cliente-a-tenant.md), el acta A/B y la ratificación en Mesa de ADR-0032, ADR-0035 y ADR-0036— con fecha comprometida. **Riesgo si no ocurre:** la sustentación presenta como pendientes cuatro bloques de trabajo que ya estaban hechos salvo por una firma |
| **Nadie tiene acceso al ambiente que debe verificar** (B-03, y B-05 en parte) | 2 de 9 | El acceso SSH a las VMs y a Supabase de PROD está concentrado en DevOps y no está repartido ni documentado. Acción: repartir el acceso de lectura, o agendar una sesión conjunta en la que se ejecuten de una vez los comandos ya escritos en [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) §3. **Riesgo si no ocurre:** siete filas llegan a la sustentación como «pendiente de validar» |
| **El requisito que la decisión debería cumplir no existe** (B-09, y el trasfondo de B-01) | 2 de 9 | Es el patrón más costoso porque no se ve: al decidir D4 y P-D15a quedó a la vista que **no hay RNF de recuperabilidad ni RNF de cifrado en reposo**, y sin requisito no hay umbral que QA pueda verificar ni ADR que se pueda escribir. Acción: el PO crea los dos RNF que faltan y sus QAS derivados antes de pedir la decisión técnica. **Riesgo si no ocurre:** se decide un mecanismo sin umbral, QA no puede verificarlo y la decisión vuelve a abrirse |

## 5. Lo que falta para cerrar SCRUM-1709

| # | Criterio | Estado al 2026-11-22 |
|---|---|---|
| 1 | La etiqueta `bloqueado` y la tabla existen | Cumplido, con la salvedad de abajo |
| 2 | El 100 % de los bloqueos tiene ítem, causa, responsable y fechas | Cumplido: los diez |
| 3 | Los bloqueos sobre el umbral quedan escalados con evidencia | Cumplido en los resueltos (§3.1). B-06 y B-03 siguen sin respuesta y así se declaran |
| 4 | Resumen al cierre: número, tiempo medio y causas recurrentes | Cumplido al corte del 2026-11-22 (§4). Se toma la cifra definitiva el día del cierre |
| 5 | Cada bloqueo recurrente genera acción de mejora o riesgo | Cumplido: tres patrones con su acción |

**Lo único que queda** es repetir el corte el día del cierre del sprint: B-03 se resuelve con la consulta de D10, y B-06 se declara como abierto al cierre si la Mesa no se convoca.

El criterio «la tabla existe antes del inicio del sprint» **no se cumplió**: el registro se crea el 2026-11-11, con el sprint en curso. Queda dicho así, y no como cumplido, porque los ocho bloqueos de §2 ya estaban activos antes de que existiera dónde anotarlos. Para el Sprint 7 la tabla debe crearse vacía en la *planning*.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.4 | 2026-11-22 | Corte al 22 de noviembre con los estados de Jira del día: **siete bloqueos resueltos** (B-01, B-02, B-04, B-05, B-07, B-08 y B-09) con fecha y forma de resolución, y **dos abiertos** (B-03, reducido a la fila D10, y B-06, que espera a la Mesa). Tiempo medio de resolución de 4,5 días hábiles sobre ocho muestras. §5 pasa a tabla de criterios. Anotado el 23-nov: SCRUM-1704 se cerró en Jira, pero B-06 sigue abierto porque ADR-0035 no está ratificado. | Sara Albarracín |
| 1.3 | 2026-11-19 | Se añade la **evidencia del escalamiento** de los seis bloqueos que superaron el umbral, con las dos conversaciones que la acreditan: la del 10 de noviembre con el PO, que cerró cinco decisiones y desbloqueó dos filas de la validación, y la del 16 con DevOps sobre el token expuesto, cuya respuesta fue aceptar el riesgo con justificación. Con esto queda cumplido el tercer criterio de aceptación de SCRUM-1709. | Sara Albarracín |
| 1.2 | 2026-11-11 | Se aplica la etiqueta `bloqueado` en Jira a los diez tickets de los nueve bloqueos, con lo que el primer criterio de SCRUM-1709 queda cumplido. B-02 recoge que el título y el criterio de SCRUM-1686 ya dicen 84/85. | Sara Albarracín |
| 1.1 | 2026-11-11 | Alineación con la v2.0 de [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md). Se añade **B-09**: el ADR de cifrado está bloqueado porque no existe el requisito que debería cumplir, ni RNF ni QAS de confidencialidad en reposo. Se matiza B-01: la decisión de D4 cerró el RPO/RTO único, pero el acta A/B sigue faltando. Se añade una tercera causa recurrente —el requisito inexistente— y se recalcula el resumen a nueve bloqueos abiertos. | Sara Albarracín |
| 1.0 | 2026-11-11 | Registro inicial. Ocho bloqueos abiertos y uno resuelto, con tipo, causa, responsable, fecha de aparición y días hábiles. Resumen por tipo, dos causas recurrentes con su acción de mejora, y constancia de que la etiqueta `bloqueado` no existe todavía en Jira. | Sara Albarracín |

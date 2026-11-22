# Seguimiento de los acuerdos del Sprint 6

[← Índice de la wiki](../Home.md) · [← 06 Gobernanza](README.md)

| Campo | Valor |
|---|---|
| **Finalidad** | Seguir los acuerdos del sprint hasta su cierre: quién responde de cada uno, en qué quedó y con qué evidencia. |
| **Origen** | [SCRUM-1707](https://maniservices.atlassian.net/browse/SCRUM-1707) (T-62) |
| **Mantiene** | Sara Albarracín (Scrum Master) |
| **Consume** | El equipo en cada *daily*; el informe de cierre |
| **Versión** | 1.0 · corte **2026-11-19** |

> **Lo primero, porque condiciona todo lo demás.** **No existen notas escritas de la reunión de planning del Sprint 6.** Este documento **no las reconstruye de memoria**: eso sería inventar acuerdos y presentarlos como registrados.
>
> Lo que sí se puede acreditar, y es lo que hay aquí, son los acuerdos que **dejaron rastro verificable** en Jira o en la wiki. Un acuerdo que solo se habló en la reunión y nadie escribió no está en esta tabla, y esa ausencia es en sí misma el dato más útil del documento.

## 1. Acuerdos acreditables

Cada fila tiene evidencia que se puede abrir y comprobar. Ninguna se sostiene solo en que alguien lo recuerde.

| # | Acuerdo | Responde | Estado al 2026-11-19 | Evidencia |
|---|---|---|---|---|
| **A-01** | Validar los puntos en que los documentos se contradicen antes de la sustentación, para no presentar cifras falsas | Sara (coordina), cada validador su fila | **14 de 15 filas cerradas.** Queda la de migraciones y `BYPASSRLS` en PROD | [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) v2.3 |
| **A-02** | Ordenar las ocho carpetas de la wiki con ficha, orden de lectura y metadatos por documento | Un responsable por carpeta | **Dos cerradas** (02-arquitectura y 06-gobernanza) de las ocho | [SCRUM-1690](https://maniservices.atlassian.net/browse/SCRUM-1690), [SCRUM-1711](https://maniservices.atlassian.net/browse/SCRUM-1711) |
| **A-03** | El PO cierra sus decisiones de producto pendientes | Camila Beltrán | **Cumplido el 10-nov.** Cinco decisiones cerradas | [SCRUM-1687](https://maniservices.atlassian.net/browse/SCRUM-1687); registro en [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) §2 y §4 |
| **A-04** | Registrar y escalar los bloqueos con causa, responsable y tiempos | Sara | **Cumplido.** Nueve bloqueos con evidencia de escalamiento | [`REGISTRO_BLOQUEOS.md`](REGISTRO_BLOQUEOS.md) v1.3 |
| **A-05** | Dejar ADR de las decisiones que atan al equipo, en vez de decidir en conversaciones | Arquitectura | **Cumplido.** Dos ADR nuevos y una enmienda | ADR-0036, ADR-0037, ADR-0038 y la enmienda de ADR-0006 |
| **A-06** | Ninguna historia se declara terminada sin video en QA, con token real y visto bueno del PO | Todo el equipo | **Vigente, y es el cuello de botella del sprint:** 36 ítems esperando validación | Criterios de aceptación de las historias; [informe de cierre](INFORME_CIERRE_SPRINT_6.md) §1 |
| **A-07** | Retirar las credenciales expuestas del repositorio | Daniel Ávila | **Cumplido en parte:** retiradas de `HEAD`, **sin rotar**. Riesgo aceptado por el equipo | [SCRUM-1712](https://maniservices.atlassian.net/browse/SCRUM-1712); [`08-infraestructura/02-accesos-y-gestion-secretos.md`](../08-infraestructura/02-accesos-y-gestion-secretos.md) |
| **A-08** | Documentar la infraestructura real con evidencia, no con descripciones | Daniel Ávila | **Cumplido.** Carpeta nueva con digests, puertos y simulacro de recuperación | [`08-infraestructura/`](../08-infraestructura/README.md) |

## 2. Acuerdos que se nombran en las tareas pero nadie cerró

No son incumplimientos: son acuerdos **sin dueño efectivo o sin artefacto**, y por eso siguen abiertos.

| # | Acuerdo | Por qué no se cerró |
|---|---|---|
| **B-01** | Acta de decisión A/B por escenario de calidad | **El acta no existe.** Nueve escenarios esperaban un umbral nuevo; solo uno tenía decisión, y fue no cambiar nada. Reasignada a Santiago el 19-nov |
| **B-02** | Ratificar en Mesa de Arquitectura las decisiones tomadas | **No hubo sesión de Mesa en el sprint.** Cuatro decisiones quedan vinculantes para la implementación pero sin ratificar |
| **B-03** | Asignar un suplente por carpeta de la wiki | Resuelto solo en las dos carpetas trabajadas. En las otras seis sigue sin asignar |
| **B-04** | Revisión cruzada del README por otro responsable de carpeta | **Criterio retirado el 12-nov:** ninguna carpeta declara responsable, así que la figura no existía en el proyecto |

## 3. Lo que este documento deja dicho sobre el proceso

**El acuerdo que más daño hizo por no estar escrito fue el de los umbrales de calidad.** Nueve escenarios esperando un acta que nadie redactó, y una tarea bloqueada diez días por eso. Si la planning hubiera dejado una línea por acuerdo con su responsable y su fecha, ese bloqueo se habría visto el primer día.

**Para el Sprint 7**, tres cosas que cuestan minutos y habrían ahorrado días:

1. Que la planning cierre con **una línea por acuerdo**: qué, quién y para cuándo. Sin eso, el seguimiento se convierte en arqueología.
2. Que el **registro de bloqueos se cree vacío en la planning**, no a mitad del sprint.
3. Que los acuerdos que exigen una **sesión** (una Mesa, una revisión cruzada) tengan **fecha de convocatoria** en el momento de acordarlos. Los dos acuerdos que quedaron sin cerrar son justamente de ese tipo.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.0 | 2026-11-19 | Documento inicial. Ocho acuerdos acreditables con su evidencia y cuatro sin cerrar con su motivo. Se deja constancia de que **no existen notas escritas de la planning** y de que los acuerdos no acreditables no se reconstruyen de memoria. | Sara Albarracín |

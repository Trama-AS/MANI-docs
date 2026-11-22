# 06 · Gobernanza

[← Índice de la wiki](../Home.md)

Esta carpeta responde a **quién decide**, **bajo qué políticas**, **sobre qué infraestructura** y **con qué evidencia**. No describe el producto ni la arquitectura: eso es [01-producto](../01-producto/README.md) y [02-arquitectura](../02-arquitectura/README.md).

## Ficha de la carpeta

| Campo | Valor |
|---|---|
| **Propósito** | Dejar por escrito la autoridad por rol y por artefacto, las políticas que rigen el trabajo, la vista física vigente y el estado verificado de lo que el equipo afirma, de modo que ninguna decisión ni ninguna cifra dependa de una conversación informal. |
| **Responsable** | Sara Albarracín (Scrum Master) |
| **Suplente** | **María Camila Beltrán (PO).** Decidido por la Scrum Master el 2026-11-12; pendiente de ratificación. Es la suplencia natural de esta carpeta: el PO ya firma sus actas de aceptación, de modo que la suplencia no le añade un encargo nuevo. |
| **Quién firma las actas** | María Camila Beltrán (Product Owner). La SM facilita y redacta; no firma en nombre del PO. |
| **Quién la consume** | Todo el equipo para las reglas de decisión; DevOps y QA para infraestructura y políticas; el PO para las actas y los informes de cierre; el jurado en la sustentación. |
| **Cada cuánto se actualiza** | Al cerrar cada sprint (informe de cierre), y de inmediato cuando se firma un acta, se registra un bloqueo o se cierra una fila de HU-VAL-01. |
| **Última revisión de la carpeta** | 2026-11-22 ([SCRUM-1711](https://maniservices.atlassian.net/browse/SCRUM-1711), HU-WIKI-08) |
| **Barrido de secretos** | 2026-11-22: **sin credenciales en la carpeta**, repetido sobre los doce documentos y este README. Ver [§5](#5-barrido-de-secretos). |
| **Estado del cierre de HU-WIKI-08** | **Criterios cumplidos al 2026-11-22, con una reserva sobre el acta A/B; pendiente de la decisión de cierre de la SM.** Ver [§6](#6-qué-falta-para-cerrar-hu-wiki-08). |

## 1. Orden de lectura

Seis pasos, de la autoridad a la evidencia. Quien llega nuevo los recorre en orden; quien busca un dato concreto va directo a [§3](#3-documentos).

| # | Qué leer | Dónde | Por qué va aquí |
|---|---|---|---|
| 1 | **Roles y responsabilidades**: qué decide el PO, qué facilita la SM, qué decide QA, cómo se desempata | [`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §1 y §2 | Sin saber quién decide, el resto de la carpeta no es exigible |
| 2 | **Políticas de trabajo**: ramas, PR, promoción, CI/CD, secretos, uso de IA | [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](POLITICAS_DEVOPS_HERRAMIENTAS.md) | Es la norma que el incumplimiento de un entregable se mide contra ella |
| 3 | **Infraestructura vigente**: ambientes, VMs, Supabase, red, backups | [`DOCUMENTO_INFRAESTRUCTURA_V4.md`](DOCUMENTO_INFRAESTRUCTURA_V4.md) y [`INFRAESTRUCTURA_MANI.md`](INFRAESTRUCTURA_MANI.md) | Fija sobre qué se despliega lo que se decide |
| 4 | **Validación de discrepancias**: qué se verificó de verdad y qué sigue pendiente | [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) | Separa lo verificado de lo afirmado, antes de llevar una cifra a la sustentación |
| 5 | **Seguimiento del sprint**: acuerdos y bloqueos | [`SEGUIMIENTO_ACUERDOS_SPRINT_6.md`](SEGUIMIENTO_ACUERDOS_SPRINT_6.md) y [`REGISTRO_BLOQUEOS.md`](REGISTRO_BLOQUEOS.md) | Qué se acordó, quién responde y qué está bloqueado, con su causa y su tiempo |
| 6 | **Actas e informes de cierre** | [`ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md`](ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md) y [`INFORME_CIERRE_SPRINT_6.md`](INFORME_CIERRE_SPRINT_6.md) | Lo que la PO firmó y el balance del sprint con cifras de Jira |

## 2. La regla que resuelve discusiones

De [`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §1:

- **Lo que no está documentado no se exige.**
- Lo acordado se cumple durante su vigencia.
- Ninguna conversación informal sustituye un artefacto oficial.

La autoridad es del **rol** y del **artefacto**, no de la persona (§2.3): el PO decide los criterios de aceptación, QA decide el DoD, y una contradicción estructural va a Mesa de Arquitectura y produce un ADR.

## 3. Documentos

| Documento | Finalidad | Mantiene | Consume | Frecuencia | Versión y fecha |
|---|---|---|---|---|---|
| [`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) | Roles, autoridad por artefacto, desempates, ceremonias, plazos exigibles y qué pasa con un incremento no entregado | Sara Albarracín (SM) | Todo el equipo | Cuando cambia un rol o una ceremonia | Vivo · 2026-11-04 |
| [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](POLITICAS_DEVOPS_HERRAMIENTAS.md) | Políticas de ramas, PR, promoción, CI/CD, contenedores, testing, DevSecOps, secretos, observabilidad, uso de IA, versionamiento de despliegue y, en §22, la política de JWT entre ambientes | Daniel Ávila (DevOps) con la SM | Desarrollo, QA, DevOps | Cuando cambia una política | Vivo · 2026-10-22 |
| [`DOCUMENTO_INFRAESTRUCTURA_V4.md`](DOCUMENTO_INFRAESTRUCTURA_V4.md) | **Vista física vigente desde el 2026-11-19** del modelo 4+1: ambientes, VMs, registro de imágenes, Supabase, red y TLS, backups y el estado de lo verificado contra el código | Daniel Ávila (DevOps) | DevOps, QA, Arquitectura | Por sprint y ante cada cambio de ambiente | V4 · 2026-11-19 · **Vigente** |
| [`INFRAESTRUCTURA_MANI.md`](INFRAESTRUCTURA_MANI.md) | Vista física detallada: ambientes DEV, QA y PROD, VMs, Supabase, red y TLS, backups, escalabilidad y, en §27, el plan de alineación y rollback de Supabase PROD y QA | Daniel Ávila (DevOps) | DevOps, QA | Cuando cambia la infraestructura | Vivo · 2026-10-22 |
| [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) | Validación de las discrepancias entre documentos: estado por fila, lo verificado en el sistema o en el código con su evidencia, el comando y el responsable de cada fila pendiente, las decisiones tomadas y lo que sigue abierto | Sara Albarracín (SM) | PO, Arquitectura, DevOps, QA | Cada vez que se cierra una fila; obligatorio antes de cada sustentación | 2.3 · 2026-11-19 · **14 de 15 filas cerradas; queda D10** |
| [`REGISTRO_BLOQUEOS.md`](REGISTRO_BLOQUEOS.md) | Bloqueos del Sprint 6: ítem afectado, tipo, causa, responsable, fecha de aparición y días hábiles abierto, con el resumen por tipo y las causas recurrentes con su acción de mejora | Sara Albarracín (SM) | El equipo en cada *daily*; el informe de cierre | En cada *daily* | 1.3 |
| [`SEGUIMIENTO_ACUERDOS_SPRINT_6.md`](SEGUIMIENTO_ACUERDOS_SPRINT_6.md) | Acuerdos del Sprint 6 con responsable, estado y evidencia. Deja constancia de que **no existen notas escritas de la planning** y no las reconstruye de memoria ([SCRUM-1707](https://maniservices.atlassian.net/browse/SCRUM-1707)) | Sara Albarracín (SM) | El equipo en cada *daily*; el informe de cierre | En cada *daily* | 1.0 · 2026-11-19 |
| [`ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md`](ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md) | Acta de decisión A/B por escenario de calidad: qué escenarios se ajustan con umbral nuevo y cuáles exigen cambiar el sistema ([SCRUM-1684](https://maniservices.atlassian.net/browse/SCRUM-1684)) | Santiago Hernández (QA) prepara; la SM facilita | QA, Arquitectura ([SCRUM-1685](https://maniservices.atlassian.net/browse/SCRUM-1685)) | Una vez; se reemplaza con un acta nueva | **Firmada por la PO** · 2026-11-21 |
| [`INFORME_CIERRE_SPRINT_6.md`](INFORME_CIERRE_SPRINT_6.md) | Cierre del Sprint 6: resultados con cifras de Jira, lecciones aprendidas y deuda abierta con su responsable ([SCRUM-1708](https://maniservices.atlassian.net/browse/SCRUM-1708)) | Sara Albarracín (SM) | El equipo, el PO y el jurado | Al cierre de cada sprint | 1.0 · corte 2026-11-19; se actualiza al cierre definitivo |
| [`PROPUESTA_RNF_PROTECCION_Y_RECUPERACION.md`](PROPUESTA_RNF_PROTECCION_Y_RECUPERACION.md) | **Propuesta, pendiente del PO.** Dos requisitos que hoy faltan —recuperabilidad y protección de datos personales en reposo— y el escenario derivado del segundo, con el desacuerdo entre cifrado de volumen y por columna | Sara Albarracín (SM) | PO, Arquitectura, QA | Hasta que el PO los apruebe o los descarte | 1.0 · 2026-11-11 · **Propuesta** |
| [`REVISION_QAS_SIN_REQUISITO.md`](REVISION_QAS_SIN_REQUISITO.md) | **Propuesta, pendiente de PO.** Recorrido de los 45 escenarios de calidad contra los once RNF y las restricciones del SRS §3: los once P1 clasificados en requisito sin enlazar, restricción y sin respaldo, con la columna de origen propuesta para el SDD | Sara Albarracín (SM) | PO, Arquitectura, QA | Cuando se crea o retira un RNF o un QAS | 2.0 · 2026-11-11 · **Propuesta** |
| [`DOCUMENTO_INFRAESTRUCTURA_V3.md`](DOCUMENTO_INFRAESTRUCTURA_V3.md) | Vista física al cierre del Sprint 4, con evidencia empírica y runbook | Daniel Ávila (DevOps) | Consulta histórica | No se actualiza | V3 · 2026-10-17 · **Superado por V4** |

> **`DOCUMENTO_INFRAESTRUCTURA_V3.md` está superado, no borrado.** La vista vigente es la V4. La V3 se conserva porque es la única que recoge el estado verificado operativamente al cierre del Sprint 4, y se cita solo como corte histórico, nunca como estado de hoy. El criterio de las HU de wiki es explícito: un documento obsoleto se marca, no se borra.

**Trazabilidad de esta carpeta.** El encadenamiento `necesidad → requisito → atributo de calidad → ADR → componente → prueba` no nace aquí: esta carpeta aporta el eslabón de **autoridad y evidencia**. `GOBIERNO_DEL_EQUIPO.md` §2.3 dice quién puede cerrar cada eslabón; `VALIDACION_HU-VAL-01.md` dice qué eslabones están verificados y cuáles solo afirmados. Los requisitos y atributos de calidad viven en [01-producto](../01-producto/README.md) y [02-arquitectura](../02-arquitectura/README.md); las pruebas, en [07-calidad](../07-calidad/README.md).

### Dos documentos que dejaron de existir aparte

El 22 de octubre de 2026 se absorbieron dos documentos que vivían sueltos, porque su contenido pertenece a una política y a la infraestructura, no a un documento propio:

| Antes | Ahora |
|---|---|
| `POLITICA_CONFIGURACION_JWT_CFG4-04.md` | [`POLITICAS_DEVOPS_HERRAMIENTAS.md` §22](POLITICAS_DEVOPS_HERRAMIENTAS.md#22-política-de-configuración-validación-perimetral-y-propagación-de-jwt-entre-ambientes-cfg4-04) |
| `PLAN_ALINEACION_SUPABASE_PROD_QA_CFG-26.md` | [`INFRAESTRUCTURA_MANI.md` §27](INFRAESTRUCTURA_MANI.md#27-plan-de-auditoría-alineación-y-migraciónrollback-de-supabase-prod-y-qa-cfg-26) |

Se citan por su sección. Sus versiones originales quedan en el historial de git y, congeladas, en [`Entregas/Entrega4/`](../../Entregas/Entrega4).

## 4. Actas, informes y seguimiento: estado

Los criterios específicos de HU-WIKI-08 piden actas, informes de cierre y registro de bloqueos. **Al 2026-11-22 los cuatro existen como documento.** Hasta el 2026-11-19 esta sección los declaraba ausentes.

| Documento | Jira | Estado |
|---|---|---|
| [`REGISTRO_BLOQUEOS.md`](REGISTRO_BLOQUEOS.md) | [SCRUM-1709](https://maniservices.atlassian.net/browse/SCRUM-1709) | Publicado; se mantiene hasta el cierre del sprint |
| [`SEGUIMIENTO_ACUERDOS_SPRINT_6.md`](SEGUIMIENTO_ACUERDOS_SPRINT_6.md) | [SCRUM-1707](https://maniservices.atlassian.net/browse/SCRUM-1707) | Publicado el 2026-11-19 |
| [`ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md`](ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md) | [SCRUM-1684](https://maniservices.atlassian.net/browse/SCRUM-1684) | **Firmada por la PO el 2026-11-21.** Desbloqueó [SCRUM-1685](https://maniservices.atlassian.net/browse/SCRUM-1685), hoy `Done` |
| [`INFORME_CIERRE_SPRINT_6.md`](INFORME_CIERRE_SPRINT_6.md) | [SCRUM-1708](https://maniservices.atlassian.net/browse/SCRUM-1708) | Versión 1.0 con corte al 2026-11-19; se actualiza al cierre definitivo del sprint |

**Reserva sobre el acta A/B.** Lleva fecha, decisiones escenario por escenario, firma de la PO y enlace a la tarea que la ejecuta, pero **no tiene un campo «Asistentes»**: nombra a quien decide, facilita y prepara. Como es un acta firmada, no se modifica aquí; si se quiere el campo, lo añade la PO o se registra en una adenda.

**Toda acta de esta carpeta lleva**, sin excepción: fecha, asistentes, decisiones tomadas una por una, y el enlace a la tarea de Jira que la ejecuta. Las actas de aceptación las firma el PO. Un acta sin firma del PO no es un acta: es un borrador de la SM.

## 5. Barrido de secretos

**Repetida el 2026-11-22** sobre los doce documentos y este README con los mismos patrones, más el prefijo `sqa_` de SonarQube: **0 credenciales.** Las únicas cadenas hexadecimales largas son el digest de imagen de la fila D1 y SHA de commits.

Revisión del 2026-11-11 sobre los seis documentos de la carpeta. Se buscaron **valores, no palabras**: JWT (`eyJ…`), llaves de Supabase (`sb_…`), llaves de AWS (`AKIA…`), bloques `BEGIN … PRIVATE KEY`, cadenas hexadecimales de 40 o más caracteres y asignaciones del tipo `password=…`, `secret=…`, `token=…`, `api_key=…`.

**Sin credenciales.** Dos coincidencias de patrón, ambas revisadas una a una y benignas:

| Coincidencia | Dónde | Qué es en realidad |
|---|---|---|
| `eyJyZWZlcnJhbEluZm8…` | [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](POLITICAS_DEVOPS_HERRAMIENTAS.md) líneas 8 y 118 | **No es un JWT.** Es el parámetro `referralInfo` de dos enlaces de SharePoint institucional a los videos de socialización: base64 de `{"referralInfo":{"referralApp":"OneDriveForBusiness",…}}`, metadatos de telemetría del enlace. No contiene firma, ni secreto, ni identidad. |
| `098bf38c3f8f…` | [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) | SHA-1 de un commit de git (evidencia de la fila D2), no una llave. |

**Lo que sí hay en la carpeta y no es un secreto pero sí es información interna:** direcciones IP de las VMs del laboratorio y los identificadores de proyecto de Supabase de PROD y QA. No son credenciales y son necesarios para que los comandos de verificación sean ejecutables, pero la carpeta **no debe contener nunca** la contraseña, el token ni la cadena de conexión que los acompaña. Quien pegue evidencia aquí reemplaza esos valores por `<redactado>`, como ya exige [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) §3.

## 5.1 Comprobador de la wiki

[`scripts/verificar-wiki.sh`](../../scripts/verificar-wiki.sh) recorre los `.md` de `wiki/`, resuelve cada enlace relativo **desde el directorio del archivo que lo contiene** y avisa de los que no resuelven y de los marcadores de conflicto de git commiteados. Se corre antes de commitear documentación, sobre toda la wiki o sobre una carpeta: `./scripts/verificar-wiki.sh` o `./scripts/verificar-wiki.sh wiki/06-gobernanza`. Devuelve 0 si está limpio y 1 si encuentra algo, de modo que sirve como paso de CI. Al 2026-11-11 la wiki completa está en **0 enlaces rotos y 0 marcadores**.

## 6. Qué falta para cerrar HU-WIKI-08

**Estado al 2026-11-22: criterios cumplidos.**

| Criterio | Estado |
|---|---|
| README con propósito, responsable, suplente, orden de lectura y para qué sirve cada documento | Cumplido. Suplente: la PO, decidido el 2026-11-12 |
| Finalidad, mantenedor, consumidor, frecuencia, versión y fecha por documento | Cumplido para los trece documentos, incluidos los cuatro publicados entre el 19 y el 21 de noviembre |
| Obsoletos marcados, no borrados | Cumplido: la V3 de infraestructura queda como superada |
| Sin credenciales | Cumplido: barrido del 2026-11-22 sin coincidencias ([§5](#5-barrido-de-secretos)) |
| Discrepancias de HU-VAL-01 resueltas o enlazadas | Cumplido: 14 de 15 cerradas y D10 enlazada ([§7](#7-discrepancias-de-hu-val-01-que-son-de-esta-carpeta)) |
| Actas, informe de cierre, registro de bloqueos y tabla de HU-VAL-01 en la carpeta | Cumplido ([§4](#4-actas-informes-y-seguimiento-estado)) |
| Cada acta con fecha, asistentes, decisiones y enlace a Jira; el PO firma las de aceptación | Cumplido salvo el campo «Asistentes» del acta A/B (reserva en §4) |
| ~~Otro responsable de carpeta revisa y aprueba el README~~ | **Criterio retirado por la Scrum Master el 2026-11-12**: ninguna carpeta de la wiki declara responsable, así que la figura no existe |

**Lo que sigue abierto y es de otras tareas:** la fila D10 de HU-VAL-01 ([SCRUM-1696](https://maniservices.atlassian.net/browse/SCRUM-1696)), que necesita la consulta a la base de PROD; y la versión final del informe de cierre ([SCRUM-1708](https://maniservices.atlassian.net/browse/SCRUM-1708)) y del registro de bloqueos ([SCRUM-1709](https://maniservices.atlassian.net/browse/SCRUM-1709)), que se cierran al final del sprint.

## 7. Discrepancias de HU-VAL-01 que son de esta carpeta

Nueve de las quince filas tocan documentos de 06-gobernanza, casi todas sobre infraestructura. **Al 2026-11-22 ocho están cerradas y una pendiente.** El estado por fila, la evidencia y el comando están en [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md).

| Fila | Qué afecta en esta carpeta | Estado |
|---|---|---|
| D1 | Versión real de PROD frente al informe de DevOps | **Cerrada el 2026-11-19:** el digest de PROD coincide con `v1.0.4` y las dieciocho rutas responden `200 OK` |
| D5 | Servicios por ambiente: la lista de PROD del informe de DevOps | **Cerrada el 2026-11-19** con el conteo de contenedores por ambiente |
| D6 | Puertos de QA: 80 y 443 según el informe, 443 rechaza según QA | **Cerrada el 2026-11-19:** el 443 escucha con TLS 1.2+ |
| D7 | Kafka en DEV y QA frente a la descripción de la VM de QA | **Cerrada el 2026-11-19:** Kafka corre en DEV y QA, no en PROD |
| D8 | Observabilidad: Infraestructura V4 §7 la declaraba futura | **Cerrada el 2026-11-19:** Prometheus y Grafana corren en la VM de Calidad; V4 §7 corregida (`a0bb876`) |
| D9 | Respaldos: scripts de `pg_dump` documentados frente a volcados puntuales | **Cerrada el 2026-11-19:** respaldo diario cifrado y simulacro `PASS` |
| D10 | Migraciones y roles sin `BYPASSRLS` en PROD | **Pendiente de validar.** Falta la consulta a la base de PROD y a la de QA ([`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) §3.1) |
| D4 | RPO/RTO: tres pares incompatibles | **Decidido.** El [acta A/B](ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md), firmada el 2026-11-21, fija **RPO ≤ 24 h y RTO ≤ 30 min** y reemplaza en cuanto al RPO la decisión del 2026-11-11 |
| D12 | Quién firma el acta de ajustes: «Sara como PO» frente a Camila como PO | **Decidido el 2026-11-11:** firma **Camila Beltrán como PO** y Sara como SM, y así se firmó el acta A/B. La tabla de roles de [`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §2.1 lleva la enmienda anotada, no reescrita |

## 8. Dónde va un documento nuevo

1. ¿Fija quién decide algo, o cómo se desempata? → a [`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md), a su sección, no a un archivo nuevo.
2. ¿Es una norma de trabajo (ramas, PR, CI, secretos, IA)? → a [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](POLITICAS_DEVOPS_HERRAMIENTAS.md).
3. ¿Describe la infraestructura? → a la vista vigente, [`DOCUMENTO_INFRAESTRUCTURA_V4.md`](DOCUMENTO_INFRAESTRUCTURA_V4.md), con su fecha de corte.
4. ¿Es un acta, un informe de cierre o un registro de bloqueos? → aquí, como documento propio, con fecha, asistentes, decisiones y enlace a Jira.
5. ¿Es evidencia de una prueba o un reporte de QA? → [`wiki/07-calidad/`](../07-calidad/README.md), no aquí.
6. ¿Decide algo que ataría técnicamente al equipo? → un ADR en [`../02-arquitectura/adr/`](../02-arquitectura/adr/), por Mesa de Arquitectura.

## Historial de cambios

| Fecha | Cambio |
|---|---|
| 2026-11-22 | Puesta al día con el estado de `main`: se listan el acta A/B (firmada el 2026-11-21), el seguimiento de acuerdos y el informe de cierre, que §4 seguía declarando ausentes; se repara el orden de lectura, cuyas filas 5 y 6 estaban mezcladas con la tabla de documentos; §6 pasa a tabla de criterios y §7 refleja las seis filas cerradas el 2026-11-19 y la D4 reemplazada por el acta. Barrido de secretos repetido. |
| 2026-11-11 | Alineación con la v2.0 de [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md): el conteo verificado baja de 8 a **6 de 15** (D4 y D12 tenían el conflicto verificado, no el dato), y §7 registra que esas dos quedaron **decididas**, no pendientes. |
| 2026-11-11 | Se publica [`REGISTRO_BLOQUEOS.md`](REGISTRO_BLOQUEOS.md) ([SCRUM-1709](https://maniservices.atlassian.net/browse/SCRUM-1709)) y se enlaza desde el orden de lectura, la tabla de documentos y §4. |
| 2026-11-11 | HU-WIKI-08 ([SCRUM-1711](https://maniservices.atlassian.net/browse/SCRUM-1711)): ficha de carpeta, orden de lectura, metadatos completos por documento (finalidad, mantenedor, consumidor, frecuencia, versión y fecha), incorporación de `DOCUMENTO_INFRAESTRUCTURA_V4.md` que estaba sin listar, marcado de la V3 como superada, barrido de secretos con las dos coincidencias explicadas, tabla de los cuatro documentos que aún no existen, enlace de las nueve filas de HU-VAL-01 que son de esta carpeta y reglas de ubicación de un documento nuevo. Cierre parcial: ver §6. |
| 2026-10-22 | Absorción de la política de JWT y del plan de alineación de Supabase en sus documentos destino. |

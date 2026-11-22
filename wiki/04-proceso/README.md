# 04 · Proceso de trabajo

[← Índice de la wiki](../Home.md)

**Fuente:** [`GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) · [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md) §5 a §18 · [`ADR-0002`](../02-arquitectura/adr/ADR-0002-jira-github.md) y [`ADR-0003`](../02-arquitectura/adr/ADR-0003-mesa-arquitectura.md) · el tablero `SCRUM` de Jira.

Esta carpeta responde a **cómo trabaja el equipo**: cómo entra una historia a un sprint, cómo se lleva en Jira, cómo llega al repositorio, cómo se prueba y cuándo está terminada. No describe el producto ni la arquitectura, y **no decide nada**: ordena lo que ya está en los documentos de gobierno, en las políticas y en Jira. Si una página contradice su fuente, manda la fuente y se corrige la página.

## Ficha de la carpeta

| Campo | Valor |
|---|---|
| **Propósito** | Que cualquier integrante, o un asistente de IA, sepa cómo se trabaja sin preguntarle a nadie: mismas reglas, mismo orden y sin ambigüedades |
| **Responsable** | Nicolás Álvarez (desarrollo) |
| **Suplente** | **Nicolás León, propuesto.** La historia prevé repartir la carpeta con él si se comparte. Falta su aceptación y la ratificación de la Scrum Master ([§6](#6-lo-que-falta)) |
| **Quién la consume** | Todo el equipo en el día a día; quien entra nuevo; los asistentes de IA que trabajan en los repositorios; el jurado en la sustentación |
| **Cada cuánto se actualiza** | Cuando cambia una regla en su fuente, y al cerrar cada sprint para revisar que los ejemplos y los pendientes sigan vigentes |
| **Última revisión de la carpeta** | 2026-11-16 ([SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694), HU-WIKI-06) |
| **Barrido de secretos** | 2026-11-16: **sin credenciales en la carpeta.** Ver [§7](#7-barrido-de-secretos) |
| **Estado del cierre de HU-WIKI-06** | **Parcial.** Ver [§6](#6-lo-que-falta) |

## 1. Orden de lectura

Siete procesos, en el orden en que una historia los recorre. Quien llega nuevo empieza por [Onboarding](onboarding.md), que remite a esta misma tabla.

| # | Proceso | Página | Por qué va aquí |
|---|---|---|---|
| 1 | **Scrum del equipo y ceremonias** | [Ceremonias y tiempos de respuesta](ceremonias-y-tiempos.md) y [Roles y decisiones](roles-y-decisiones.md) | Sin saber quién decide y cuándo se reúne el equipo, lo demás no es exigible |
| 2 | **Definición de Listo y de Terminado** | [DoR y DoD](dor-y-dod.md) | Fija cuándo una historia puede empezar y cuándo se puede decir que acabó |
| 3 | **Flujo de Jira**: estados, transiciones y enlaces de bloqueo | [Jira y trazabilidad](jira-y-trazabilidad.md) | Es donde vive el trabajo y donde se ve si avanza |
| 4 | **Flujo de PR y revisión** | [Git: ramas y commits](git-ramas-y-commits.md), [Pull requests](pull-requests.md) y [CI/CD y calidad](cicd-y-calidad.md) | Es el único camino del código hacia una rama compartida |
| 5 | **Videos de validación** | [Videos de validación](videos-de-validacion.md) | Es la evidencia que la PO revisa antes de aceptar |
| 6 | **Reporte de fallas** | [Reporte de fallas](reporte-de-fallas.md) | Dice qué hacer cuando algo no funciona en QA |
| 7 | **Onboarding** | [Onboarding de un desarrollador nuevo](onboarding.md) | Reúne todo lo anterior en una lista para el primer día |

Páginas de apoyo, que se consultan cuando la tarea lo pide: [Ambientes y promoción](ambientes-y-promocion.md), [Secretos](secretos.md), [Observabilidad](observabilidad.md), [Estándares de documentación](documentacion.md) y [Trabajo con asistentes de IA](trabajo-con-ia.md).

## 2. Los siete procesos: responsable, entradas, salidas y ejemplo

Los ejemplos son del Sprint 5 (26 de octubre a 5 de noviembre de 2026) y se pueden comprobar en Jira y en GitHub.

| Proceso | Responsable | Entradas | Salidas | Ejemplo real del Sprint 5 |
|---|---|---|---|---|
| **Scrum y ceremonias** | Scrum Master convoca; el PO decide el alcance | Backlog priorizado; capacidad del equipo | Sprint con sus ítems en Jira; reporte diario; incremento revisado; acuerdos de la retrospectiva | El calendario del sprint fijó el cierre de desarrollo el 30 de octubre, la validación del PO del 2 al 4 de noviembre y el despliegue el 5 ([Backlog, calendario](../05-backlog/README.md#calendario)) |
| **DoR y DoD** | El PO decide los criterios; QA decide el DoD | Historia con descripción, criterios, prioridad y dependencias | Historia lista para planear; al final, historia que cumple lo funcional, técnico, calidad, documentación y gestión | SCRUM-872 y SCRUM-873 no tenían criterios aprobados. Se propusieron en Jira, la PO los aprobó el 27 de octubre y solo entonces se implementaron |
| **Flujo de Jira** | La persona asignada mueve su ítem; la Scrum Master declara los bloqueos | Ítem asignado en el sprint | Estado al día, con comentario y evidencia en cada cambio; bloqueos enlazados y registrados | SCRUM-866 salió de `blocked` el 4 de noviembre, cuando se integraron las dos historias que la bloqueaban ([detalle](jira-y-trazabilidad.md#enlaces-de-bloqueo)) |
| **PR y revisión** | El autor abre; revisa alguien distinto; quien integra comprueba el CI | Rama con la clave de Jira; pruebas en verde | PR integrado, con CI y *quality gate* en verde y el enlace en Jira | En [MANI-Flutter#67](https://github.com/Trama-AS/MANI-Flutter/pull/67) (SCRUM-871) QA pidió un cambio el 27 de octubre, se corrigió con su prueba y se aprobó 40 minutos después ([detalle](onboarding.md#6-ejemplo-real-del-sprint-5)) |
| **Videos de validación** | Quien implementa graba; la PO valida | Cambio desplegado en QA; criterios de la tarea | Video adjunto a la tarea; visto bueno de la PO; paso a «Finalizada» | SCRUM-866 se finalizó el 5 de noviembre con el video validado en persona ([detalle](videos-de-validacion.md#5-ejemplo-real-del-sprint-5)) |
| **Reporte de fallas** | QA recibe, confirma y registra | Falla con clave, paso, cuenta y hora | Defecto en Jira creado por QA; re-prueba y cierre | Tras la prueba manual del 5 de noviembre, QA abrió SCRUM-1633 a SCRUM-1637 en lugar de reabrir las historias ([detalle](reporte-de-fallas.md#5-ejemplo-real-del-sprint-5)) |
| **Onboarding** | La Scrum Master asigna a quien acompaña; DevOps da los accesos | Cuentas de GitHub y Jira; un ítem asignado | Repositorio corriendo en local y primer PR integrado | El recorrido de SCRUM-871, de la rama a la revisión ([detalle](onboarding.md#6-ejemplo-real-del-sprint-5)) |

## 3. Las reglas en seis líneas

1. Todo trabajo tiene su ítem en **Jira**; el backlog no vive en GitHub.
2. Toda rama de trabajo nace de la rama de integración y vuelve por **Pull Request**.
3. `main` representa la versión productiva: protegida contra push directo, solo cambios aprobados, releases etiquetados.
4. El PR lleva referencia Jira, propósito, cambios, pruebas ejecutadas, impacto técnico, evidencia y actualización documental si aplica.
5. Lo revisa al menos una persona distinta del autor; una solicitud de revisión se atiende en **≤ 24 h hábiles**.
6. Nada está terminado con pruebas pendientes, documentación requerida incompleta, defectos bloqueantes abiertos o criterios incumplidos.

Tres reglas de gobierno resuelven las discusiones ([`GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §1):

- **Lo que no está documentado no se exige.** Si alguien pide algo que ningún documento sostiene, se documenta primero.
- **Lo acordado se cumple durante su vigencia.** Un cambio de reglas de proceso se aprueba en retrospectiva y aplica al sprint siguiente.
- **Toda excepción se registra** con responsable, motivo y fecha.

## 4. Documentos

Cada página lleva su propia ficha con finalidad, quién la mantiene, quién la consume, frecuencia, versión y fecha, y su cadena de origen y destino. Esta tabla las resume.

| Documento | Para qué sirve | Fuente que resume | Mantiene la fuente | Versión y fecha |
|---|---|---|---|---|
| [Ceremonias y tiempos de respuesta](ceremonias-y-tiempos.md) | Ceremonias, canales, *daily*, retrospectiva y plazos exigibles | Gobierno §4, §6 y §10 | Scrum Master | Viva · 2026-10-22 |
| [Roles y decisiones](roles-y-decisiones.md) | Quién decide qué, desempates y Mesa de Arquitectura | Gobierno §2 y §5; ADR-0003 | Scrum Master | Viva · 2026-11-16 |
| [DoR y DoD](dor-y-dod.md) | Cuándo una historia entra y cuándo está terminada | Gobierno §8 y §9 | QA (DoD) y Scrum Master (DoR) | Viva · 2026-11-04 |
| [Jira y trazabilidad](jira-y-trazabilidad.md) | Qué vive en Jira y qué en GitHub, estados, transiciones y enlaces de bloqueo | ADR-0002; Gobierno §3 y §6; tablero `SCRUM` | Scrum Master | Viva · 2026-11-16 |
| [Git: ramas y commits](git-ramas-y-commits.md) | Modelo de ramas y lo que está y no está normado | Políticas §5 y §6 | DevOps | Viva · 2026-10-22 |
| [Pull requests](pull-requests.md) | Contenido obligatorio, revisión y cierre | Políticas §6; Gobierno §6.1 y §9 | DevOps | Viva · 2026-11-04 |
| [CI/CD y calidad](cicd-y-calidad.md) | Pipeline, pruebas exigidas y *gates* | Políticas §8, §13 y §14; ADR-0005 y ADR-0015 | DevOps y QA | Viva · 2026-11-04 |
| [Videos de validación](videos-de-validacion.md) | Cómo se graba, se entrega y se valida el video de un cambio en QA | Criterios del Sprint 6 en Jira | PO y Scrum Master | 1.0 · 2026-11-16 |
| [Reporte de fallas](reporte-de-fallas.md) | Cómo se prueba a mano en QA, a quién se reporta y con qué datos | Reporte de QA del Sprint 5; criterios de SCRUM-1694 | QA | 1.0 · 2026-11-16 |
| [Onboarding de un desarrollador nuevo](onboarding.md) | Lista ordenada para entregar el primer cambio | Las páginas de esta carpeta | Scrum Master y DevOps | 1.0 · 2026-11-16 |
| [Ambientes y promoción](ambientes-y-promocion.md) | DEV, QA y PROD, y cómo se promueve una versión | Políticas §7 a §12; ADR-0004 y ADR-0028 | DevOps | Viva · 2026-10-23 |
| [Secretos](secretos.md) | Qué no se sube y cómo se manejan los secretos por ambiente | Políticas §15 y §16 | DevOps | Viva · 2026-11-04 |
| [Observabilidad](observabilidad.md) | Herramientas y obligaciones de los servicios | Políticas §17; ADR-0006 | DevOps | Viva · 2026-11-13 |
| [Estándares de documentación](documentacion.md) | Qué documento se actualiza con cada tipo de cambio | ADR-0001 y ADR-0008; Gobierno §3 y §9.4 | Scrum Master | Viva · 2026-11-04 |
| [Trabajo con asistentes de IA](trabajo-con-ia.md) | Política de uso de IA y cómo se aplica | Políticas §18 | DevOps con la Scrum Master | Viva · 2026-11-04 |

**No hay documentos obsoletos en la carpeta.** Si una página deja de aplicar, se marca como superada en esta tabla y se conserva: no se borra.

**Trazabilidad de esta carpeta.** El encadenamiento `necesidad → requisito → atributo de calidad → ADR → componente → prueba` no nace aquí. Esta carpeta aporta el eslabón del **cómo**: por qué pasos una historia llega a ser un cambio probado y aceptado. Los requisitos están en [01-producto](../01-producto/README.md), los atributos de calidad, los ADR y los componentes en [02-arquitectura](../02-arquitectura/README.md), las pruebas en [07-calidad](../07-calidad/README.md) y la autoridad sobre cada eslabón en [06-gobernanza](../06-gobernanza/README.md). La fila «Origen y destino» de cada ficha dice a qué eslabones toca esa página.

## 5. Discrepancias

### De HU-VAL-01 que tocan esta carpeta

| Fila | Qué dice | Estado en esta carpeta |
|---|---|---|
| **D12** — quién firma como PO | Decidido el 2026-11-11: firma Camila Beltrán como PO | **Enlazada.** [Roles y decisiones](roles-y-decisiones.md) avisa que la tabla de roles de la fuente está desactualizada en esa fila. La tabla no se reescribe hasta que el equipo acuerde el cambio |
| **D8** — observabilidad | Pendiente de validar por DevOps y la Scrum Master | **Enlazada.** [Observabilidad](observabilidad.md) describe la política; el estado real lo cierra [`VALIDACION_HU-VAL-01.md`](../06-gobernanza/VALIDACION_HU-VAL-01.md) |

Las demás filas de [`VALIDACION_HU-VAL-01.md`](../06-gobernanza/VALIDACION_HU-VAL-01.md) no corresponden a esta carpeta.

### Encontradas al ordenar la carpeta

Se reportan a quien responde por la fuente. **No se corrigen aquí**, porque una regla no se cambia en la wiki.

| # | Discrepancia | Quién la resuelve |
|---|---|---|
| 1 | [Git: ramas y commits](git-ramas-y-commits.md) dice que no hay formato de commit normado y que la rama es `feature/US-XX-…`. Las plantillas de PR de los repositorios exigen commits `[SCRUM-<id>]` y las ramas reales son `feature/SCRUM-<id>-…` | DevOps, en `POLITICAS_DEVOPS_HERRAMIENTAS.md` §5 |
| 2 | Las páginas dicen que toda rama nace de `develop`. `MANI-docs` no tiene `develop`: sus PR van a `main`. Los criterios de las HU de wiki piden «PR a `develop`» | DevOps y Scrum Master |
| 3 | [DoR y DoD](dor-y-dod.md) dice que en Flutter el resultado local reemplaza al CI «mientras los PR a `develop` no lo corran». Hoy el CI de Flutter sí corre en los PR a `develop` (por ejemplo, MANI-Flutter#136) | QA, que decide el DoD |
| 4 | Las reglas de videos de validación y de prueba manual (navegador distinto, ventana privada, fallas a QA, no crear incidencias) solo están en criterios de Jira, no en `GOBIERNO_DEL_EQUIPO.md` ni en el DoD | Scrum Master, por control de cambios (Gobierno §13) |

## 6. Lo que falta

| # | Qué falta para cerrar HU-WIKI-06 | De quién depende |
|---|---|---|
| 1 | Que Nicolás León acepte la suplencia y la Scrum Master la ratifique | Nicolás León y Sara Albarracín |
| 2 | Que otro responsable de carpeta revise y apruebe este README | Un responsable de otra carpeta, en el PR |
| 3 | Que las cuatro discrepancias de [§5](#encontradas-al-ordenar-la-carpeta) tengan dueño y decisión | DevOps, QA y Scrum Master |
| 4 | Que la PO apruebe la documentación ([Roles y decisiones](roles-y-decisiones.md): aprobar documentación es decisión del PO) | Camila Beltrán (PO) |

## 7. Barrido de secretos

Revisión del 2026-11-16 sobre las 16 páginas de la carpeta. Se buscaron **valores, no palabras**: JWT (`eyJ…`), llaves de Supabase (`sb_…`), llaves de AWS (`AKIA…`), bloques `BEGIN … PRIVATE KEY`, cadenas hexadecimales de 40 o más caracteres y asignaciones del tipo `password=…`, `secret=…`, `token=…`, `api_key=…`.

**Sin credenciales.** La única coincidencia de patrón es la lista de patrones de este mismo párrafo. [Secretos](secretos.md) nombra la variable `SUPABASE_ANON_KEY`, pero no trae su valor.

## 8. Historial

| Fecha | Cambio |
|---|---|
| 2026-11-16 | Ficha de la carpeta, orden de lectura, tabla de procesos con ejemplos del Sprint 5, ficha en cada página, páginas nuevas de videos de validación, reporte de fallas y onboarding, y estados y enlaces de bloqueo en Jira ([SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694)) |
| 2026-10-22 | Versión anterior: índice de ocho páginas y reglas en seis líneas |

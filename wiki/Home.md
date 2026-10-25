# MANI — Wiki del repositorio MANI-Docs

> **Esta wiki no decide nada.** Describe, ordena y hace navegable lo que ya está decidido en los documentos de este repositorio. Toda afirmación de estas páginas sale de un documento fuente, citado al inicio de cada página en la línea `Fuente`.
> Si una página contradice su fuente, **manda la fuente** y se corrige la página.

**MANI en una frase:** plataforma SaaS multi-tenant que formaliza operaciones de servicio conectando clientes con aliados en el ciclo `Solicitud → Cotización → Ejecución → Calificación → Cierre`, con aislamiento estricto por empresa y configuración por tenant sin despliegue propio.

Proyecto de **TRAMA · Ingeniería de Software**. Este repositorio (`MANI-Docs`) es documentación: no contiene código desplegable.

---

## 1. Cómo está organizada

**La documentación viva está toda dentro de `wiki/`.** Cada carpeta numerada es una responsabilidad, y los documentos extensos viven en la carpeta de su tema, no en una paralela. En la raíz del repositorio quedan solo el `README.md`, el `CONTRIBUTING.md` y [`Entregas/`](../Entregas/README.md), que no es documentación viva sino el archivo de las entregas ya presentadas: congeladas, no se editan y no se citan como fuente.

| Carpeta | De qué responde | Empieza por |
|---|---|---|
| [`01-producto/`](01-producto/README.md) | Qué se construye y qué no: visión, actores, requisitos, criterios de éxito. Contiene el SRS y el TD | [Visión y alcance](01-producto/vision-y-alcance.md) |
| [`02-arquitectura/`](02-arquitectura/README.md) | Cómo está construido: estilo, contenedores, reglas, multi-tenancy, datos, contratos. Contiene el SAD, el SDD, los ADR y los diagramas | [Reglas arquitectónicas](02-arquitectura/reglas-arquitectonicas.md) |
| [`03-repositorios/`](03-repositorios/README.md) | Modelo multi-repo, estructura de este repo y versionado | [Multi-repo](03-repositorios/multirepo.md) |
| [`04-proceso/`](04-proceso/README.md) | Cómo trabaja el equipo: ramas, PR, Jira, roles, DoR/DoD, ambientes, CI/CD, secretos y observabilidad | [Proceso de trabajo](04-proceso/README.md) |
| [`05-backlog/`](05-backlog/README.md) | Qué se hace y en qué orden. Contiene el backlog único y el libro de módulos y servicios | [Backlog MANI](05-backlog/BACKLOG_MANI.md) |
| [`06-gobernanza/`](06-gobernanza/README.md) | Quién decide y bajo qué políticas: gobierno del equipo, políticas DevOps e infraestructura | [Gobierno del equipo](06-gobernanza/GOBIERNO_DEL_EQUIPO.md) |
| [`07-calidad/`](07-calidad/README.md) | Qué se probó y con qué resultado: reporte de QA, matrices, evidencia y PoC | [Reporte general de QA del Sprint 4](07-calidad/REPORTE_QA_SPRINT4.md) |

---

## 2. Jerarquía de fuentes

Ninguna persona es dueña de un documento: la autoridad es del **rol** y del **artefacto**, según [`GOBIERNO_DEL_EQUIPO.md`](06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §2.3. Si dos fuentes se contradicen, prevalece la de menor número:

1. **Requerimientos:** [`product/SRS.md`](01-producto/SRS.md).
2. **Arquitectura y diseño:** [`architecture/SAD.md`](02-arquitectura/SAD.md), [`architecture/SDD.md`](02-arquitectura/SDD.md) y [`architecture/SECUENCIAS.md`](02-arquitectura/SECUENCIAS.md).
3. **Decisiones:** [`adr/`](02-arquitectura/adr/) — una decisión vigente está `Aceptado`; una sustituida está `Superseded`.
4. **Datos:** [`architecture/ModeloDatos.md`](02-arquitectura/ModeloDatos.md).
5. **Proceso y entrega:** [`governance/GOBIERNO_DEL_EQUIPO.md`](06-gobernanza/GOBIERNO_DEL_EQUIPO.md), [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md), [`governance/INFRAESTRUCTURA_MANI.md`](06-gobernanza/INFRAESTRUCTURA_MANI.md).
6. **Tecnologías vigentes:** [`architecture/TECH_RADAR.md`](02-arquitectura/TECH_RADAR.md).
7. **Trabajo:** Jira es la fuente del backlog y los sprints; [`05-backlog/BACKLOG_MANI.md`](05-backlog/BACKLOG_MANI.md) es el backlog único: criterios de aceptación, backlog técnico y cobertura incluidos.
8. **Resultados de prueba:** [`07-calidad/REPORTE_QA_SPRINT4.md`](07-calidad/REPORTE_QA_SPRINT4.md) manda sobre el estado real de cada capacidad y de cada defecto. Un estado en Jira no acredita nada por sí solo.
9. **Esta wiki.**

Tres reglas de gobierno aplican a todo lo anterior ([`GOBIERNO_DEL_EQUIPO.md`](06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §1):

- **Lo que no está documentado no se exige.**
- Lo acordado se cumple durante su vigencia.
- Ninguna conversación informal sustituye un artefacto oficial.

Una contradicción no se resuelve en silencio: se reporta en el PR o en el issue de Jira correspondiente. Si es estructural, va a **Mesa de Arquitectura** y produce un ADR.

---

## 3. Qué leer según la tarea

| Tarea | Lee |
|---|---|
| Entender el producto en 5 minutos | [Visión y alcance](01-producto/vision-y-alcance.md) |
| Implementar una historia | Su RF en [Requisitos](01-producto/requisitos.md), las [reglas arquitectónicas](02-arquitectura/reglas-arquitectonicas.md) y el [DoD](04-proceso/dor-y-dod.md) |
| Saber qué servicio es dueño de algo | [Estilo y contenedores](02-arquitectura/estilo-y-contenedores.md) |
| Tocar autenticación, tenant, RLS o Storage | [Multi-tenancy y seguridad](02-arquitectura/multitenancy-y-seguridad.md) y [CI/CD y calidad](04-proceso/cicd-y-calidad.md) |
| Tocar base de datos o migraciones | [Datos y analítica](02-arquitectura/datos-y-analitica.md) |
| Crear rama, commit o PR | [Git: ramas y commits](04-proceso/git-ramas-y-commits.md) y [Pull requests](04-proceso/pull-requests.md) |
| Vincular trabajo con Jira | [Jira y trazabilidad](04-proceso/jira-y-trazabilidad.md) |
| Desplegar o promover una versión | [Ambientes y promoción](04-proceso/ambientes-y-promocion.md) y [Versionado](03-repositorios/versionado.md) |
| Proponer una decisión técnica | [Decisiones ADR](02-arquitectura/decisiones-adr.md) y [Roles y decisiones](04-proceso/roles-y-decisiones.md) |
| Saber qué está sin decidir | [Riesgos y puntos abiertos](02-arquitectura/riesgos-y-puntos-abiertos.md) |
| Trabajar con un asistente de IA | [Trabajo con asistentes de IA](04-proceso/trabajo-con-ia.md) |
| Entender cómo quedó la transición V4 | [Backlog §10](05-backlog/BACKLOG_MANI.md#10-registro-de-la-transición-v4) |
| Ver un diagrama | [Diagramas](02-arquitectura/diagramas.md) |
| Saber si una capacidad está verificada de verdad | [Cobertura y verificación](05-backlog/BACKLOG_MANI.md#9-cobertura-de-lo-que-falta-y-verificación-de-lo-que-ya-está) y el [reporte de QA](07-calidad/REPORTE_QA_SPRINT4.md) |
| Saber el estado de un defecto | [Defectos consolidados](07-calidad/REPORTE_QA_SPRINT4.md#9-defectos-consolidados-del-sprint) |
| Conocer los criterios de aceptación de una historia | [Backlog §6](05-backlog/BACKLOG_MANI.md#6-criterios-de-aceptación-y-dod-de-las-historias-priorizadas-del-sprint-4) |
| Consultar una entrega ya presentada | [Entregas](../Entregas/README.md) |

---

## 4. Convenciones de esta wiki

- **Una página, un tema.** Se enlaza en lugar de duplicar.
- **Cada página declara su fuente** en la primera línea tras el título. Un dato sin fuente no pertenece a esta wiki.
- **No se inventan umbrales, rutas, credenciales ni nombres.** Si el dato no está en un documento, la página dice que está abierto y lo registra en [Riesgos y puntos abiertos](02-arquitectura/riesgos-y-puntos-abiertos.md).
- Lo marcado como **Aceptado** en un ADR es vinculante; lo **Propuesto** es la recomendación vigente hasta que la Mesa de Arquitectura lo apruebe.
- El contenido técnico de detalle (DDL, diccionario de datos, C4 nivel 4, umbrales completos) vive en los documentos; la wiki sólo apunta a ellos.

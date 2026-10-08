# MANI — Wiki del repositorio MANI-Docs

> **Esta wiki no decide nada.** Describe, ordena y hace navegable lo que ya está decidido en los documentos de este repositorio. Toda afirmación de estas páginas sale de un documento fuente, citado al inicio de cada página en la línea `Fuente`.
> Si una página contradice su fuente, **manda la fuente** y se corrige la página.

**MANI en una frase:** plataforma SaaS multi-tenant que formaliza operaciones de servicio conectando clientes con aliados en el ciclo `Solicitud → Cotización → Ejecución → Calificación → Cierre`, con aislamiento estricto por empresa y configuración por tenant sin despliegue propio.

Proyecto de **TRAMA · Ingeniería de Software**. Este repositorio (`MANI-Docs`) es documentación: no contiene código desplegable.

---

## 1. Cómo está organizada

| Carpeta | Qué contiene | Empieza por |
|---|---|---|
| [`01-producto/`](01-producto/README.md) | Qué se construye, qué no, actores, requisitos y criterios de llegada | [Visión y alcance](01-producto/vision-y-alcance.md) |
| [`02-arquitectura/`](02-arquitectura/README.md) | Estilo, contenedores, reglas, multi-tenancy, datos, calidad, ADR, riesgos | [Reglas arquitectónicas](02-arquitectura/reglas-arquitectonicas.md) |
| [`03-entrega/`](03-entrega/README.md) | Ambientes, promoción, CI/CD, pruebas, secretos y observabilidad | [Ambientes y promoción](03-entrega/ambientes-y-promocion.md) |
| [`04-repositorios/`](04-repositorios/README.md) | Modelo multi-repo, estructura de este repo y versionado | [Multi-repo](04-repositorios/multirepo.md) |
| [`05-proceso/`](05-proceso/README.md) | Ramas, commits, PR, Jira, roles, DoR/DoD, documentación y uso de IA | [Proceso de trabajo](05-proceso/README.md) |
| [`06-backlog/`](06-backlog/README.md) | Cómo leer el backlog V4 de transición y en qué orden se ejecuta | [Backlog](06-backlog/README.md) |

---

## 2. Jerarquía de fuentes

Ninguna persona es dueña de un documento: la autoridad es del **rol** y del **artefacto**, según [`GOBIERNO_DEL_EQUIPO.md`](../governance/GOBIERNO_DEL_EQUIPO.md) §2.3. Si dos fuentes se contradicen, prevalece la de menor número:

1. **Requerimientos:** [`product/SRS.md`](../product/SRS.md).
2. **Arquitectura y diseño:** [`architecture/SAD.md`](../architecture/SAD.md), [`architecture/SDD.md`](../architecture/SDD.md) y [`architecture/SECUENCIAS.md`](../architecture/SECUENCIAS.md).
3. **Decisiones:** [`adr/`](../adr/) — una decisión vigente está `Aceptado`; una sustituida está `Superseded`.
4. **Datos:** [`architecture/ModeloDatos.md`](../architecture/ModeloDatos.md).
5. **Proceso y entrega:** [`governance/GOBIERNO_DEL_EQUIPO.md`](../governance/GOBIERNO_DEL_EQUIPO.md), [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md), [`governance/INFRAESTRUCTURA_MANI.md`](../governance/INFRAESTRUCTURA_MANI.md).
6. **Tecnologías vigentes:** [`architecture/TECH_RADAR.md`](../architecture/TECH_RADAR.md).
7. **Trabajo:** Jira es la fuente del backlog y los sprints; [`product/BACKLOG_MANI.md`](../product/BACKLOG_MANI.md) es el criterio de transición.
8. **Esta wiki.**

Tres reglas de gobierno aplican a todo lo anterior ([`GOBIERNO_DEL_EQUIPO.md`](../governance/GOBIERNO_DEL_EQUIPO.md) §1):

- **Lo que no está documentado no se exige.**
- Lo acordado se cumple durante su vigencia.
- Ninguna conversación informal sustituye un artefacto oficial.

Una contradicción no se resuelve en silencio: se reporta en el PR o en el issue de Jira correspondiente. Si es estructural, va a **Mesa de Arquitectura** y produce un ADR.

---

## 3. Qué leer según la tarea

| Tarea | Lee |
|---|---|
| Entender el producto en 5 minutos | [Visión y alcance](01-producto/vision-y-alcance.md) |
| Implementar una historia | Su RF en [Requisitos](01-producto/requisitos.md), las [reglas arquitectónicas](02-arquitectura/reglas-arquitectonicas.md) y el [DoD](05-proceso/dor-y-dod.md) |
| Saber qué servicio es dueño de algo | [Estilo y contenedores](02-arquitectura/estilo-y-contenedores.md) |
| Tocar autenticación, tenant, RLS o Storage | [Multi-tenancy y seguridad](02-arquitectura/multitenancy-y-seguridad.md) y [CI/CD y calidad](03-entrega/cicd-y-calidad.md) |
| Tocar base de datos o migraciones | [Datos y analítica](02-arquitectura/datos-y-analitica.md) |
| Crear rama, commit o PR | [Git: ramas y commits](05-proceso/git-ramas-y-commits.md) y [Pull requests](05-proceso/pull-requests.md) |
| Vincular trabajo con Jira | [Jira y trazabilidad](05-proceso/jira-y-trazabilidad.md) |
| Desplegar o promover una versión | [Ambientes y promoción](03-entrega/ambientes-y-promocion.md) y [Versionado](04-repositorios/versionado.md) |
| Proponer una decisión técnica | [Decisiones ADR](02-arquitectura/decisiones-adr.md) y [Roles y decisiones](05-proceso/roles-y-decisiones.md) |
| Saber qué está sin decidir | [Riesgos y puntos abiertos](02-arquitectura/riesgos-y-puntos-abiertos.md) |
| Trabajar con un asistente de IA | [Trabajo con asistentes de IA](05-proceso/trabajo-con-ia.md) |
| Entender en qué orden va la transición | [Orden de ejecución](06-backlog/orden-de-ejecucion.md) |
| Ver un diagrama | [Diagramas](02-arquitectura/diagramas.md) |

---

## 4. Convenciones de esta wiki

- **Una página, un tema.** Se enlaza en lugar de duplicar.
- **Cada página declara su fuente** en la primera línea tras el título. Un dato sin fuente no pertenece a esta wiki.
- **No se inventan umbrales, rutas, credenciales ni nombres.** Si el dato no está en un documento, la página dice que está abierto y lo registra en [Riesgos y puntos abiertos](02-arquitectura/riesgos-y-puntos-abiertos.md).
- Lo marcado como **Aceptado** en un ADR es vinculante; lo **Propuesto** es la recomendación vigente hasta que la Mesa de Arquitectura lo apruebe.
- El contenido técnico de detalle (DDL, diccionario de datos, C4 nivel 4, umbrales completos) vive en los documentos; la wiki sólo apunta a ellos.

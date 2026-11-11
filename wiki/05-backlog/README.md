# 05 · Backlog

[← Índice de la wiki](../Home.md)

| | |
|---|---|
| **Versión** | 2.0 |
| **Fecha** | 2026-11-10 |
| **Responsable de la carpeta** | Nicolás León |
| **Suplente** | Nicolás Álvarez (propuesto; falta confirmarlo con la Scrum Master) |
| **Revisa este README** | Otro responsable de carpeta, distinto de quien lo escribe (ver [puntos abiertos](#puntos-abiertos)) |
| **Historia en Jira** | [SCRUM-1695](https://maniservices.atlassian.net/browse/SCRUM-1695) (HU-WIKI-07) |

**Fuente:** [`BACKLOG_MANI.md`](BACKLOG_MANI.md) · [`adr/ADR-0002`](../02-arquitectura/adr/ADR-0002-jira-github.md).

> **Jira es la fuente del trabajo.** Esta carpeta no lo duplica: fija los criterios con los que se acepta, explica en qué orden se ejecuta y deja la cadena que une cada ítem con su origen y con su prueba.

## Para qué sirve esta carpeta

Responde cuatro preguntas: **qué hay que hacer** (backlog vigente), **con qué forma se escribe un ítem** (plantillas), **en qué orden se hace** (criterios de priorización) y **de dónde viene y cómo se prueba** (matriz de trazabilidad).

## Quién agrega, prioriza y cierra un ítem

| Acción | Quién | Cómo se ve en la práctica |
|---|---|---|
| **Agregar** | Cualquier integrante propone; QA registra los defectos que encuentra y la Scrum Master registra las tareas y decisiones pendientes | Los defectos `SCRUM-1633` a `1637` los abrió QA; las tareas del 9-nov, la SM |
| **Priorizar** | **Product Owner**, con la Scrum Master consultada | [Criterios de priorización](criterios-de-priorizacion.md) |
| **Facilitar** | **Scrum Master**: ceremonias, bloqueos, reglas de proceso | [Ceremonias y tiempos](../04-proceso/ceremonias-y-tiempos.md) |
| **Estimar** | Desarrollo | Puntos de historia con Fibonacci |
| **Cerrar** | **QA**: decide el DoD y cierra con la subtarea `QA-…`; ningún ítem pasa a Done por sí mismo | [DoR y DoD](../04-proceso/dor-y-dod.md) y [plantillas](plantillas.md) |

Fuente de la autoridad: [Roles y decisiones](../04-proceso/roles-y-decisiones.md) y [`GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §2.3.

## Orden de lectura

| # | Documento | Para qué sirve | Lo mantiene | Lo consume | Cada cuánto | Versión y fecha |
|---|---|---|---|---|---|---|
| 1 | `README.md` | Este índice | Responsable de la carpeta | Todo el equipo | Al cambiar la carpeta | 2.0 · 2026-11-10 |
| 2 | [`BACKLOG_MANI.md`](BACKLOG_MANI.md) | **Backlog vigente**: cierre del Sprint 4, plan del Sprint 5, épicas e historias, criterios de aceptación y registro de la transición | Responsable de la carpeta, con la PO | PO, SM, QA y Desarrollo | Al cerrar cada sprint | V5 · 2026-10-20 (cabecera del archivo) |
| 3 | [`epicas-y-modulos.md`](epicas-y-modulos.md) | Épicas de Jira y módulos M-01 a M-13 con su dueño | Responsable de la carpeta | PO, SM, quien busca el módulo de un ítem | Al cambiar el reparto | 1.0 · 2026-11-10 |
| 4 | [`plantillas.md`](plantillas.md) | Plantillas de historia, tarea, defecto y criterio de aceptación | Responsable de la carpeta, con la PO | Quien redacta ítems; QA | Al cambiar DoR o DoD | 1.0 · 2026-11-10 |
| 5 | [`criterios-de-priorizacion.md`](criterios-de-priorizacion.md) | Cómo se ordena el backlog | Responsable de la carpeta; decide la PO | PO, SM y quien planifica | En cada refinamiento | 1.0 · 2026-11-10 |
| 6 | [`backlog-9-nov.md`](backlog-9-nov.md) | Fotografía del backlog del 9-nov: los 78 ítems con su clave de Jira y los defectos 1633 a 1637 | Responsable de la carpeta, desde Jira | PO, SM, QA y Desarrollo | En cada refinamiento y al cerrar el Sprint 6 | 1.0 · 2026-11-10 |
| 7 | [`historico-por-version.md`](historico-por-version.md) | Qué versión del backlog rige y cómo llegó a serlo | Responsable de la carpeta | Quien consulta una versión pasada | Al publicar una versión | 1.0 · 2026-11-10 |
| 8 | [`matriz-de-trazabilidad.md`](matriz-de-trazabilidad.md) | Ítem → módulo → requisito → QAS → ADR → prueba (parcial) | Responsable de la carpeta, con QA | QA, PO y quien audita | Al cerrar cada ítem | 1.0 · 2026-11-10 |
| 9 | [`MANI_MODULOS_SERVICIOS_Y_BACKLOG_S5.xlsx`](MANI_MODULOS_SERVICIOS_Y_BACKLOG_S5.xlsx) | Libro de módulos, servicios, backlog del Sprint 5 y criterios en tabla filtrable | Responsable de la carpeta | PO, SM, QA y Desarrollo | Al cambiar los módulos | Sin versión propia: la de la fecha del archivo en Git |

**Origen y destino de cada documento.** Cada página nueva (3 a 8) declara en su cabecera de dónde sale y a dónde alimenta, y enlaza su historia en Jira. La cadena general es:

```text
Necesidad → requisito (SRS) → atributo de calidad (QAS, SDD §8) → ADR → componente → prueba
        ↘ historia o tarea en Jira ↗                                     ↘ evidencia en 07-calidad
```

**Obsoletos.** Lo que dejó de regir se marca, no se borra. En esta carpeta: la sección «Importar el Sprint 5 a Jira» de este README, que quedó como registro histórico, y [`BACKLOG_MANI.md`](BACKLOG_MANI.md) §10.5, que es el orden del Sprint 3 ya ejecutado.

## Puntos abiertos

Cosas que esta versión del README **no resuelve** y que hay que cerrar antes de darlo por completo. Las discrepancias entre documentos se registran además en la [HU-VAL-01](https://maniservices.atlassian.net/browse/SCRUM-1696).

| # | Punto | Estado |
|---|---|---|
| 1 | **Roles contradictorios.** [Roles y decisiones](../04-proceso/roles-y-decisiones.md) lista a Nicolás León como Product Owner y a Camila Beltrán como Frontend y Scrum Master; el reparto del Sprint 5 de este README y Jira dejan a Camila Beltrán como PO | Abierto: pertenece a `04-proceso`; se eleva a HU-VAL-01 |
| 2 | **Épica `EP-11`.** El tablero la usa (`SCRUM-1363`) y la tabla de §1 de `BACKLOG_MANI.md` no la incluye | Abierto: se completa al publicar la siguiente versión del backlog |
| 3 | **Versiones V1 a V4.** El repositorio no guarda su número ni su fecha como documento | Abierto: ver [histórico](historico-por-version.md) |
| 4 | **Matriz de trazabilidad.** Los 78 ítems del 9-nov tienen origen y, donde la descripción los nombra, QAS (28) y ADR (9); 9 tienen prueba o evidencia. Faltan el módulo y el requisito (las descripciones no los traen) y la prueba de lo que aún no se fusiona | Abierto: ver [matriz](matriz-de-trazabilidad.md) |
| 5 | **Suplente de la carpeta.** Nicolás Álvarez figura como propuesto | Pendiente de confirmar con la Scrum Master |
| 6 | **Revisión.** Otro responsable de carpeta debe revisar y aprobar este README | Pendiente |
| 7 | **Rama de destino.** La historia pide el cambio por PR a `develop`; el repositorio MANI-docs no tiene rama `develop` y sus PR van a `main` | Este PR va a `main`; confirmar la regla |
| 8 | **Búsqueda de secretos.** Se hizo sobre esta carpeta (no encontró credenciales); falta la que corre el equipo en el PR | Hecha para esta carpeta |
| 9 | **Enlaces rotos heredados.** `BACKLOG_MANI.md` y la tabla «Qué se absorbió» de este README enlazan `../07-calidad/MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md` y `../07-calidad/REPORTE_QA_SPRINT4.md`, que no existen en esa ruta (el reporte vive en `07-calidad/monitoreo/`; la matriz no está en el repositorio) | Abierto: se corrigen con quien mantiene `07-calidad` |

---

## Los archivos originales de la carpeta

| Archivo | De qué responde |
|---|---|
| [`BACKLOG_MANI.md`](BACKLOG_MANI.md) | **Backlog único.** Cierre del Sprint 4 y plan del Sprint 5 (§0), épicas e historias (§1–§2), registro del Sprint 3 (§3–§4), documentos relacionados (§5), criterios de aceptación y DoD del Sprint 4 (§6), criterios de US-02.1.1 (§7), backlog técnico en GitHub e issues propuestos (§8), cobertura de lo que falta frente a verificación de lo que ya está (§9) y registro de la transición V4 (§10) |
| [`MANI_MODULOS_SERVICIOS_Y_BACKLOG_S5.xlsx`](MANI_MODULOS_SERVICIOS_Y_BACKLOG_S5.xlsx) | Libro de módulos M-01 a M-13, servicios de negocio, matriz módulo × servicio, backlog del Sprint 5 por bloques VAL, CONS y TEC, guion de videos, cobertura del producto y, en las hojas 18 a 20, los criterios de aceptación en forma de tabla filtrable |
| `README.md` | Este índice |

## Qué se absorbió y dónde quedó

| Antes | Ahora |
|---|---|
| `backlog/CRITERIOS_ACEPTACION_SPRINT4.md` | [§6](BACKLOG_MANI.md#6-criterios-de-aceptación-y-dod-de-las-historias-priorizadas-del-sprint-4) |
| `backlog/CRITERIOS_ACEPTACION_US-02.1.1.md` | [§7](BACKLOG_MANI.md#7-criterios-de-aceptación-de-us-0211-sobre-el-camino-gateway---core) |
| `backlog/BACKLOG_GITHUB_SPRINT4_PROPUESTA.md` | [§8](BACKLOG_MANI.md#8-backlog-técnico-en-github-estado-verificado-e-issues-propuestos-del-cierre-del-sprint-4) |
| `transicion-v4.md` y `orden-de-ejecucion.md` | [§10](BACKLOG_MANI.md#10-registro-de-la-transición-v4), como registro histórico del Sprint 3 |
| `backlog/MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md` | [`07-calidad/`](../07-calidad/MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md), porque es material de QA |

**El orden de ejecución vigente no está en §10.** §10.5 es el orden del Sprint 3, ya ejecutado. El del Sprint 5 está en la hoja `12 Backlog S5 resumen` del libro de módulos.

## Los criterios de aceptación, en el libro

Las §6 y §7 son el texto normativo; las hojas 18 a 20 del libro son la misma cosa en forma de tabla, para filtrar por historia, por responsable o por caso de prueba. Si difieren, **manda el documento**.

| Hoja | Contenido | Filas |
|---|---|---|
| `18 Criterios transversales S4` | T1 a T10, con su origen. Aplican a todas las historias | 10 |
| `19 Criterios por historia S4` | Una fila por criterio: historia, RF, responsable, enunciado, quién acepta, qué subtarea de QA verifica y qué casos de la matriz lo cubren | 69, sobre 17 historias |
| `20 Criterios US-02.1.1` | Escenarios A1 a A4 y B1 a B6 con sus pasos, más las 7 condiciones de aceptación | 16 escenarios |

## Cobertura cerrada: toda funcionalidad con su historia

Revisión del 24 de octubre de 2026. Las 88 funcionalidades de las hojas M-01 a M-13 tienen ahora una historia asignada; 18 no la tenían.

| Hoja | Contenido | Filas |
|---|---|---|
| `21 Cierre de cobertura` | Las 18 funcionalidades que estaban sin historia, con la que las cubre y qué exige esa historia | 18 |
| `22 Gestion del sprint` | `SM-01` facilitación del sprint y `PO-01` validación del producto y aceptación del incremento | 2 |
| `24 Sprint 5 por modulo` | **El backlog del sprint.** Una historia por funcionalidad, con quién la ejecuta, quién la valida y su subtarea de QA | 88 |

### Reparto del Sprint 5

Por módulo completo, no por tarea: cada quien es dueño de sus módulos de punta a punta, y las dependencias que quedan son de ambiente, concentradas en el bloque TEC. Así entre desarrolladores no hay tareas que se bloqueen.

| Persona | Rol | Módulos | Ejecuta | Valida y acepta |
|---|---|---|---:|---:|
| Nicolás León | Desarrollo | M-09, M-11 | 19 HU · 95 SP | 14 HU |
| Juan Sebastián Álvarez | Desarrollo | M-08, M-10, M-12 | 17 HU · 85 SP | 14 HU |
| José Nicolás Álvarez | Desarrollo | M-06, M-07, M-13 | 16 HU · 80 SP | 11 HU |
| Daniel Ávila | No programa | M-01, M-02 | 14 HU · 58 SP | 20 HU |
| Santiago Hernández | QA, no programa | M-05 | 8 HU · 32 SP | 10 HU |
| Camila Beltrán | PO, no programa | M-03 | 4 HU · 16 SP | 6 HU |
| Sara Albarracín | SM, no programa | M-04 | 4 HU · 16 SP | 7 HU |

Quienes no programamos llevamos un módulo cada uno, de validación y verificación. Daniel se ofreció a llevar dos, M-01 y M-02.

**Trece historias de esos cinco módulos exigen código.** Las ejecuta un desarrollador y el dueño del módulo las valida y acepta: son las únicas filas donde las dos columnas de persona no coinciden, y van resaltadas en la hoja.

| Tipo de trabajo | HU | Qué significa |
|---|---:|---|
| Construcción desde 0 | 37 | No existe |
| Validación de lo implementado | 14 | Figura hecho y nunca se probó contra lo pedido |
| Corrección + validación | 14 | A medias o con defecto abierto |
| Front contra mock | 14 | Notificaciones (M-09) y pagos (M-11): el front tiene que existir completo, sin integración real con el proveedor |
| Terminar + validación | 3 | En curso |
| Fuera de alcance | 4 | 2.º incremento de M-12 y la división del front |

Entran sí o sí la visualización en mapa (`HU-M04-07`) y el rastreo del aliado en vivo (`HU-M07-04`).

### Dos decisiones del 24 de octubre que hay que conocer

**El rastreo en vivo entró al MVP y por eso existe `RF-37`.** Estaba excluido en `SRS.md` §1.2 y §7.1 registraba que SCRUM-871 no se relacionaba con ningún requisito. Sin un RF no tendría criterio de aceptación, así que ni el PO podría aceptarlo ni QA cerrarlo. Lo decidió la Scrum Master al priorizar el sprint, **sin sesión de refinamiento registrada**, y queda pendiente de confirmación del PO, que es quien decide el alcance (`GOBIERNO_DEL_EQUIPO.md` §2.3). El cálculo de proximidad sigue fuera: RF-37 no cambia la declaración de cobertura, que sigue siendo por zonas (RNF-09, REST-01). La ubicación continua es dato personal bajo la Ley 1581 de 2012, así que el requisito exige permiso expreso del aliado, ventana limitada a la ejecución y retención configurable por tenant.

**`HU-M13-05`, dividir el Core por dominios, es prerrequisito del sprint.** Va los primeros días, junto a las tareas TEC de ambiente, y nadie construye sobre Core hasta que esté fusionada. El motivo está en la hoja `01 Indice modulos`: los 13 módulos listan Core entre sus servicios, así que sin dividirlo siete personas editan el mismo servicio Node y el reparto por módulo reparte la responsabilidad pero no los archivos. `SAD.md` §7.3 ya permite esta división interna y prohíbe lo contrario, un servicio por cada CRUD.

Dividir el front (`HU-M13-04`) se queda fuera: el choque ahí es menor porque cada módulo tiende a su propia pantalla. Se asume el conflicto en `lib/features`.

**Total del sprint: 107 ítems y 501 story points** — 84 historias por funcionalidad, 21 tareas técnicas y las 2 de gestión.

De las 18, doce ya estaban cubiertas por un ítem del Sprint 5 pero sin trazar en la columna `Historia`. Seis necesitaron historia nueva:

| Nueva | Tipo | Por qué |
|---|---|---|
| `CONS-46` | Construcción desde cero | RF-01 es crítico y hoy solo existe `GET /core/tenants`: no hay forma de crear un tenant por la aplicación |
| `VAL-19` | Validación | El perfil del aliado que consumen Dispatch y Rules existe en código y nunca se validó como contrato |
| `VAL-20` | Validación | El catálogo es pre-auth en nginx; hay que comprobar el aislamiento con token y que sin token no filtre nada |
| `VAL-21` | Validación | El contexto de solicitud que Dispatch pide a Core está implementado y sin validar contra T1 y T2 |
| `VAL-22` | Validación | RNF-03 exige resistir reintentos sin duplicar, y la guarda de idempotencia del broadcast se congela tras un corte parcial |
| `TEC-21` | Seguridad | Core y Dispatch conectan con `BYPASSRLS`: ninguna política RLS se evalúa, así que el aislamiento de RNF-01 descansa solo en el código |

**Trazabilidad de requisitos completa.** Se corrigieron 16 etiquetas: RF-29 a RF-36, RNF-06, RNF-07, RNF-11, REST-03 y REST-05 no aparecían en ninguna fila aunque su funcionalidad sí existía. Los 36 RF, los 11 RNF y las 5 REST del SRS están trazados a una funcionalidad y a una historia.

**Ninguna historia pasa a Done por sí misma.** Cada una lleva su subtarea `QA-<id>`: Santiago revisa la evidencia contra los criterios y es quien cierra, porque QA decide el DoD (`GOBIERNO_DEL_EQUIPO.md` §2.3). Esto cierra el hueco del Sprint 4, donde tres historias no tenían subtarea de QA (pendiente PE4 de §6.5).

> El estado real de cada capacidad y de cada defecto lo manda [07-calidad](../07-calidad/README.md), no el tablero de Jira. La §9 del backlog aplica esa regla: «cerrado» no es «verificado».

## Regla principal

**Una historia o tarea histórica marcada `Done` no se reabre sólo porque cambió la arquitectura.** Se conserva su evidencia. Si necesita adaptación se crea:

- una **subtarea `-Mn`** colgada de la propia historia, o
- una tarea **`CFG`** en EP-09, o
- un **bug de regresión**.

Así no se borra trabajo real ni se finge que la migración ya ocurrió.

## Punto de partida real

Backlog V4 §3: la arquitectura anterior **no es un backend que haya que mover de lenguaje**. Es un cliente Flutter hablando directo con Supabase y la lógica de negocio en ~32 funciones PL/pgSQL. Por tanto:

1. la migración consiste en **crear el backend que no existe y sacar al cliente de la base de datos**;
2. los riesgos *Lógica de negocio en Flutter* y *Acceso directo indiscriminado a Supabase* del SAD §23 están mal calibrados y su corrección es la tarea `DOC-28`.

## Qué se conserva

Supabase, Auth, RLS y aislamiento multi-tenant · registro y aprobación de aliados · registro de cliente · categorías · creación de solicitud · exclusión concurrente · las PoC de despacho, identidad y Storage/KYC · pipelines, GHCR, secretos y promoción de ambientes · seeds multi-tenant · documentación y diagramas consolidados.

Ese trabajo **cambia de ubicación**, no se desecha: la lógica se reimplementa en Rules (Java), Dispatch (.NET) y Core Service (Node.js), y el cliente deja de invocarla ([ADR-0022](../02-arquitectura/adr/ADR-0022-logica-de-negocio-en-servicios.md)).

## Importar el Sprint 5 a Jira (histórico: ya ejecutado)

**Ya hecho: el CSV se retiró.** `IMPORTAR_JIRA_SPRINT5.csv` traía 215 filas para el importador
externo de Jira (86 historias, 22 tareas y 107 subtareas de QA, 506 story points). El Sprint 5 ya
está cargado en el tablero, así que el archivo cumplió su función y se borró para no dejar una
fuente paralela al tablero, que es la que manda.

**Por qué existió.** El conector de Atlassian no estaba instalado en `maniservices.atlassian.net`:
la autenticación funcionaba, pero toda llamada a Jira y a Confluence respondía
`403 The app is not installed on this instance`. Era una instalación del lado del sitio, no un
problema de sesión, así que la carga se hizo con el CSV. El síntoma sigue apareciendo en algunos
conectores, de modo que conviene no perder el dato.

### Calendario

| Hito | Fecha | Qué pasa |
|---|---|---|
| Inicio | lunes 26-oct-2026 | Arranca el sprint |
| Prerrequisitos | martes 27-oct | `TEC-09`, `TEC-10`, `TEC-11`, `TEC-16` y `HU-M13-05`. Sin token real ES256, sin QA sembrada y sin el Core dividido, nada de lo demás vale |
| Cierre de desarrollo | viernes 30-oct | Último día hábil para fusionar código |
| Corte formal | domingo 1-nov | Los cuatro días antes del fin que pediste. Cae en domingo, así que el corte operativo es el viernes 30 |
| Validación del PO y preparación de DevOps | 2-nov a 4-nov | `PO-01` recorre el producto y acepta o rechaza el incremento |
| Fin de sprint y despliegue | jueves 5-nov | `DEPLOY-S5` a producción, solo si `PO-01` declaró aceptado |

**Las fechas de inicio y fin del sprint se fijan en el tablero al crear el sprint**, no vienen en el CSV: el CSV solo trae la fecha de vencimiento de cada ítem y el nombre `Sprint 5`.

### Al importar

- El importador mapea la persona por **nombre mostrado**. Los nombres del CSV son Nicolás León, José Nicolás Álvarez, Juan Sebastián Álvarez, Daniel Ávila, Santiago Hernández, Camila Beltrán y Sara Albarracín, sin el rol entre paréntesis. Si en Jira figuran distinto, se mapean en el paso de usuarios.
- Las subtareas se enlazan por la columna `Parent`, que repite el resumen exacto del padre. Importa el archivo completo de una vez: si separas padres y subtareas en dos cargas, el enlace se pierde.
- La columna `Identificador interno` (`HU-M01-01`, `TEC-09`, `QA-HU-M01-01`) es la del libro de módulos y no un campo de Jira. Sirve para reconciliar después; si tu importador no la acepta, descártala.
- **Ya existen issues en Jira para parte de estas funcionalidades** (SCRUM-846, 847, 850, 851, 852, 854, 856 y otras, según la columna `Clave Jira` de las hojas M-01 a M-13). Revísalas antes de importar para no duplicar: lo que ya existe se actualiza a mano, no se vuelve a crear.

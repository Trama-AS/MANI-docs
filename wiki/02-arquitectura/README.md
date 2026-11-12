# 02 · Arquitectura

[← Índice de la wiki](../Home.md)

**Arquitectura objetivo:** SOA distribuida + API Gateway + enfoque políglota + multi-tenancy.

## Ficha de la carpeta

| Campo | Valor |
|---|---|
| **Propósito** | Responder cómo es el sistema y por qué es así, de modo que cada decisión se pueda rastrear hasta el requisito que la originó y hasta la prueba que la verifica. |
| **Responsable** | Sara Albarracín |
| **Suplente** | **Mesa de Arquitectura**, como órgano. Decidido por la Scrum Master el 2026-11-11; ver [§1.1](#11-por-qué-la-suplencia-es-de-la-mesa-y-no-de-una-persona). |
| **Quién la consume** | Desarrollo (los seis repositorios), QA (para derivar pruebas de los escenarios), DevOps (vista de despliegue) y el PO (restricciones que afectan el alcance). |
| **Cada cuánto se actualiza** | Al cerrar cada sprint, y de inmediato cuando una Mesa de Arquitectura produce o modifica un ADR. |
| **Última revisión de la carpeta** | 2026-11-11 ([SCRUM-1690](https://maniservices.atlassian.net/browse/SCRUM-1690), HU-WIKI-02) |
| **Barrido de secretos** | 2026-11-10: sin credenciales en la carpeta. Se buscaron valores, no palabras: JWT (`eyJ…`), llaves de Supabase (`sb_…`), llaves de AWS (`AKIA…`), bloques `BEGIN … PRIVATE KEY`, cadenas hexadecimales de 40+ caracteres y asignaciones del tipo `password=…`, `secret=…`, `token=…`. **0 coincidencias.** Las apariciones de «token», «secret» y `LOGIN PASSWORD` son vocabulario y referencias de política (ADR-0031 §5), no valores. |
| **Estado del cierre de HU-WIKI-02** | **Parcial.** Ver [§7](#7-qué-falta-para-cerrar-hu-wiki-02). |

La carpeta tiene tres capas, y cada documento vive en una sola:

| Capa | Qué es | Dónde |
|---|---|---|
| Guía | Páginas de lectura: ordenan y explican, no deciden | [`guia/`](guia/) |
| Documentos | La fuente de verdad de la arquitectura vigente | raíz de esta carpeta |
| Decisiones | Un ADR por decisión, con su estado | [`adr/`](adr/) |

Si guía y documento se contradicen, manda el documento. Si documento y ADR se contradicen, manda el ADR.

**No hay carpeta de expedientes.** Una auditoría, un inventario o el material de una Mesa no son un documento aparte: su contenido va al documento o al ADR que responde por ese tema, con su fecha de corte escrita. Lo que no sobrevive a esa pregunta —«¿de qué documento es esto una parte?»— no se guarda aquí.

### 1.1 Por qué la suplencia es de la Mesa y no de una persona

**Decisión tomada: Sara Albarracín (Scrum Master), 2026-11-11.** La suplencia de una carpeta no está regulada en [`GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md), que solo define suplencia **de rol** en §2.1 («Segundo rol»).

El criterio obvio —«suple quien ya mantiene contenido de la carpeta»— **no aplica aquí**, porque la responsable escribe y mantiene todos los documentos de la carpeta. Las cabeceras que nombran a otras personas en [`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md) y [`ARQ-05`](ARQ-05-despliegue-kafka-dev-qa.md) acreditan la autoría del entregable que originó cada documento, no su mantenimiento continuo.

Por eso la suplencia se asigna al **órgano, no a un individuo**: la Mesa de Arquitectura. Dos razones:

- §2.1 de gobernanza dice que **todos los integrantes técnicos participan transversalmente como Arquitectos** dentro de la Mesa, así que el órgano existe y tiene a todos dentro.
- La Mesa ya es la autoridad sobre el contenido vinculante de esta carpeta: los ADR se ratifican allí (ADR-0003 §2). Hacerla suplente no le añade una atribución nueva, solo cubre el hueco de mantenimiento cuando falta la responsable.

**Qué significa en la práctica.** Si la responsable no está, un cambio en esta carpeta se lleva a Mesa en lugar de esperar; la Mesa designa quién lo aplica para ese cambio concreto. No se designa a nadie de forma permanente, de modo que no se compromete a una persona que no lo aceptó.

**Lo que esta decisión NO cubre.** Los criterios comunes de las ocho HU de wiki piden que el README lo revise y apruebe **otro responsable de carpeta**. Eso sigue pendiente y lo tiene que hacer quien responde por otra carpeta, no la Mesa ni la autora.

**Trazabilidad:** necesidad = que la carpeta siga al día si falta la responsable → requisito = criterios comunes de las ocho HU de wiki ([SCRUM-1690](https://maniservices.atlassian.net/browse/SCRUM-1690)) → atributo de calidad = Mantenibilidad P1 ([`SDD.md`](SDD.md) §8.5) → decisión = suplencia del órgano que ya decide sobre la carpeta.

## 1. Orden de lectura

Seis pasos. Quien llega nuevo los recorre en este orden; quien viene a resolver una duda concreta usa la tabla de atajos de [§3](#3-documentos--la-fuente).

| # | Qué leer | Dónde | Por qué va aquí |
|---|---|---|---|
| 1 | **Drivers y restricciones**: qué obliga a que la arquitectura sea así | [`SAD.md`](SAD.md) §2 y §3, y [Reglas arquitectónicas](guia/reglas-arquitectonicas.md) | Sin los drivers, las decisiones de más abajo parecen arbitrarias |
| 2 | **SAD** — arquitectura del sistema: estilo, contenedores, límites entre servicios, multi-tenancy | [`SAD.md`](SAD.md) | Fija el qué y el dónde antes del cómo |
| 3 | **SDD** — diseño detallado, vistas C4 y el modelo 4+1 | [`SDD.md`](SDD.md) §4 | Desarrolla el SAD hasta el nivel de componente |
| 4 | **Índice de ADR con estado** | [Decisiones ADR](guia/decisiones-adr.md) y [§4](#4-decisiones) | Una decisión vinculante manda sobre cualquier descripción |
| 5 | **Escenarios de calidad QAS-01 a QAS-45 con su umbral vigente** | [`SDD.md`](SDD.md) §7 y §8 — **único lugar donde viven los umbrales** | Es lo que convierte un atributo de calidad en algo medible por QA |
| 6 | **Trade-offs y puntos abiertos** | [Riesgos y puntos abiertos](guia/riesgos-y-puntos-abiertos.md) y [§5](#5-lo-que-falta-decidir) | Lo que todavía no está decidido, dicho como pendiente y no como hecho |

## 2. Guía — páginas de lectura

Explican y ordenan; no deciden. Las mantiene la responsable de la carpeta y se revisan al cierre de cada sprint.

| Página | Tema | Qué fuente resume |
|---|---|---|
| [Estilo y contenedores](guia/estilo-y-contenedores.md) | SOA + Gateway + políglota; qué contenedor hace qué | `SAD.md`, ADR-0019 |
| [Reglas arquitectónicas](guia/reglas-arquitectonicas.md) | Principios y dependencias permitidas/prohibidas | `SAD.md`, ADR-0022, ADR-0030 |
| [Multi-tenancy y seguridad](guia/multitenancy-y-seguridad.md) | Identificación de tenant, capas de control, KYC | `ModeloDatos.md` §6, ADR-0012, ADR-0018 |
| [Datos y analítica](guia/datos-y-analitica.md) | Propiedad de datos, esquemas, RLS, Data Warehouse | `ModeloDatos.md`, ADR-0030 |
| [Atributos de calidad](guia/atributos-de-calidad.md) | Prioridades y umbrales verificables | `SDD.md` §7 y §8 |
| [Decisiones ADR](guia/decisiones-adr.md) | Índice de ADR con estado, reglas de Mesa, huecos y lo que falta ratificar | `adr/`, ADR-0003 |
| [Riesgos y puntos abiertos](guia/riesgos-y-puntos-abiertos.md) | *Architectural killers* y lo que falta decidir | `SAD.md` §7.4 y §7.6 |
| [Diagramas](guia/diagramas.md) | Qué diagramas existen y dónde | `diagrams/`, ADR-0008 |

## 3. Documentos — la fuente

Los tres primeros son **documentos vivos**: no llevan número de versión, la vigente es la de `main` y su historial está en el log de git. La columna de fecha es la del último cambio en `main` al 2026-11-10.

| Documento | Finalidad | Mantiene | Consume | Frecuencia | Versión y fecha |
|---|---|---|---|---|---|
| [`SAD.md`](SAD.md) | Arquitectura del sistema: estilo, contenedores, límites entre servicios, multi-tenancy, observabilidad, riesgos | Arquitectura | Desarrollo, DevOps, PO | Por sprint y ante cada ADR | Vivo · 2026-11-04 |
| [`SDD.md`](SDD.md) | Diseño detallado, vistas C4, **los 45 escenarios de calidad con su umbral** y la vista de despliegue | Arquitectura | Desarrollo, QA | Por sprint y ante cada cambio de umbral | Vivo · 2026-11-05 |
| [`ModeloDatos.md`](ModeloDatos.md) | Modelo de datos, propiedad de esquema, permisos y políticas RLS | Arquitectura con Core | Desarrollo, QA, DevOps | Por migración | Vivo · 2026-11-04 |
| [`SECUENCIAS.md`](SECUENCIAS.md) | Secuencias de los flujos principales en PlantUML, pegables en cualquier visor | Arquitectura | Desarrollo, sustentación | Cuando cambia un flujo | Vivo · 2026-11-04 |
| [`COMUNICACION_SERVICIOS_GATEWAY.md`](COMUNICACION_SERVICIOS_GATEWAY.md) | Enrutamiento perimetral y reglas de comunicación entre servicios | Arquitectura con DevOps | Desarrollo, DevOps | Cuando cambia una ruta o un servicio | 1.0 · 2026-10-05 |
| [`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md) | Esquemas y versionado de los cuatro eventos de negocio (ARQ-06) | Juan Sebastián Álvarez | Desarrollo, QA | Cuando cambia un contrato de evento | ARQ-06 · 2026-10-18 |
| [`TECH_RADAR.md`](TECH_RADAR.md) | Tecnologías adoptadas, en prueba y descartadas | Arquitectura | Todo el equipo | Por sprint | Vivo · 2026-11-04 |
| [`ARQ-05-despliegue-kafka-dev-qa.md`](ARQ-05-despliegue-kafka-dev-qa.md) | Configuración y despliegue de Kafka en DEV y QA: tópicos canónicos, *smoke test* y monitoreo (SCRUM-1236) | Daniel Ávila | DevOps, Desarrollo | Cuando cambia el broker o sus tópicos | ARQ-05 · 2026-11-03 |

> **Dato en disputa.** Este documento declara Kafka implementado y verificado en DEV y QA. La fila D7 de [HU-VAL-01](../06-gobernanza/VALIDACION_HU-VAL-01.md) está **pendiente de validar** porque la descripción de la VM de QA no lista el contenedor. No se cita como hecho hasta que haya evidencia.

Atajos a secciones que suelen buscarse como si fueran un documento aparte:

| Si buscas | Está en |
|---|---|
| Estado real de RLS hoy, y las exposiciones abiertas | [`ModeloDatos.md`](ModeloDatos.md) §6.4 |
| Modelo de identidad en el motor y políticas objetivo por tabla | [`ModeloDatos.md`](ModeloDatos.md) §6.5 |
| Conformidad del código con los límites entre servicios, y sus desviaciones abiertas | [`SAD.md`](SAD.md) §7.6 |
| Qué falta para cumplir ADR-0027 en Flutter | [`SAD.md`](SAD.md) §8.3.1 |
| Métricas y alertas de autenticación | [`SAD.md`](SAD.md) §19.1 y §19.2 |
| Los seis casos cross-tenant que QA debe ejecutar | [`SDD.md`](SDD.md) §8.12 |
| Lo que falta ratificar en Mesa | [Decisiones ADR](guia/decisiones-adr.md) y «Pendiente de Mesa» de [ADR-0032](adr/ADR-0032-identidad-de-servicio-en-base-de-datos.md) |

## 4. Decisiones

[`adr/`](adr/) — **29 fichas** al 2026-11-12: **24 `Aceptado`** (vinculantes), **1 `Rechazado`** (ADR-0014, *feature toggle*), **2 `Propuesto`** (ADR-0034 contrato común de proveedores externos, ADR-0035 frontera de asignación 6A) y **2 decididos por la SM y pendientes de ratificación en Mesa**: [ADR-0036](adr/ADR-0036-pertenencia-del-cliente-a-tenant.md) (pertenencia del cliente a un tenant, M1 a M4 respondidas el 2026-11-12) y [ADR-0037](adr/ADR-0037-cifrado-de-datos-personales-en-reposo.md) (cifrado de datos personales en reposo).

Los números no son contiguos y no se reutilizan. **Huecos:** 0007, 0009, 0010, 0020, 0021, 0023, 0026 y 0033. El siguiente número libre es **ADR-0038**. El índice completo con estado y los retiros está en [Decisiones ADR](guia/decisiones-adr.md).

Un ADR de esta carpeta debe enlazar tres cosas: el **requisito** que lo origina, el **atributo de calidad** que compromete y la **prueba** que lo verifica. El índice de [Decisiones ADR](guia/decisiones-adr.md) ya trae la columna de requisito por ADR; completar los que falten es trabajo de esta carpeta y **no** de [SCRUM-1661](https://maniservices.atlassian.net/browse/SCRUM-1661), que es otra cosa: los 22 contratos OpenAPI que faltan y sus *contract tests* en CI (127 de 127), trabajo de Juan S. Álvarez en los repositorios de código.

## 5. Lo que falta decidir

Ninguno de estos puntos se presenta como resuelto.

| Pendiente | Estado hoy | Qué lo cierra |
|---|---|---|
| **Asignación idempotente (6A)** | **Documentado y cerrado.** [ADR-0035](adr/ADR-0035-frontera-de-asignacion-6a.md) está escrito con contexto, alternativas A/B/C y consecuencias, y [`SAD.md`](SAD.md) §7.4 lo referencia y registra la decisión 6A cerrando el pendiente P1; la asignación idempotente sí está escrita, en §7.2 y §7.4. Lo único que falta es **ratificar el ADR en Mesa**: hasta entonces queda `Propuesto` y la decisión de la SM rige el sprint | Sesión de Mesa (ADR-0003 §2). [SCRUM-1704](https://maniservices.atlassian.net/browse/SCRUM-1704) ya cumple sus dos criterios |
| **Acta A/B** | Los escenarios con opción B no están reflejados en `SDD.md` §7 y §8. [SCRUM-1685](https://maniservices.atlassian.net/browse/SCRUM-1685) **está bloqueada**: depende del acta [SCRUM-1684](https://maniservices.atlassian.net/browse/SCRUM-1684), que es la que fija los umbrales nuevos de los escenarios 05, 16, 17, 18, 24, 25, 26, 40 y 43. Sin el acta no hay cifra que escribir | Firmar el acta 1684, y después 1685 |
| **Tenant de los clientes** | [ADR-0036](adr/ADR-0036-pertenencia-del-cliente-a-tenant.md) existe en estado `Propuesto` desde el 2026-11-11: establece que lo reportado en [SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637) **no es un defecto sino el diseño vigente** de ADR-0012 y ADR-0018, y propone mantener un tenant por cliente en el MVP | Decisión del PO sobre las preguntas M1 a M4 del propio ADR y ratificación en Mesa; solo entonces se reclasifica SCRUM-1637 |
| **Cifrado de credenciales y datos sensibles** | [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383) `Reopened`, único ítem abierto del Sprint 5. La **responsabilidad** quedó decidida el 2026-11-11 (un solo responsable, P-D15a). El **mecanismo** sigue sin decidir y **no por falta de criterio técnico**: no existe un RNF de cifrado en reposo ni un QAS de confidencialidad en reposo, y sin ellos no hay umbral que QA pueda verificar | Dos artefactos del PO —un RNF y un QAS— y luego el ADR de [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699). Ver [P-D15b](../06-gobernanza/VALIDACION_HU-VAL-01.md#5-lo-único-que-sigue-abierto) |
| **Kafka: declarado verificado sin evidencia** | [`ARQ-05`](ARQ-05-despliegue-kafka-dev-qa.md) decía «Implementado y Verificado en DEV y QA». Corregido el 2026-11-11 a «Implementado; NO verificado de forma independiente», porque la descripción de la VM de QA no lista el contenedor | Fila D7 de [HU-VAL-01](../06-gobernanza/VALIDACION_HU-VAL-01.md) |
| **Observabilidad: ¿Datadog o Loki?** | [ADR-0006](adr/ADR-0006-observabilidad.md) está `Aceptado` con Datadog. Si se sustituye por Loki, el ADR hay que revisarlo, no contradecirlo desde otro documento | Revisión de ADR-0006 en Mesa |
| **SDD §8 e Infraestructura V4 §7 sobre monitoreo** | Ambos declaran la observabilidad como futura; hay indicios de Prometheus y Grafana en QA desde el 6-nov, sin verificar | Fila D8 de [HU-VAL-01](../06-gobernanza/VALIDACION_HU-VAL-01.md) y luego [SCRUM-1686](https://maniservices.atlassian.net/browse/SCRUM-1686) |

## 6. Discrepancias de HU-VAL-01 que son de esta carpeta

Cinco de las quince filas de [`VALIDACION_HU-VAL-01.md`](../06-gobernanza/VALIDACION_HU-VAL-01.md) tocan documentos de 02-arquitectura. Ninguna se da por cerrada aquí: esta tabla es el enlace exigido por HU-WIKI-02.

| Fila | Qué afecta en esta carpeta | Estado |
|---|---|---|
| D4 | RPO/RTO: `SDD.md` QAS-17 contra el informe de DevOps y la opción B | Conflicto verificado; **falta la decisión** (P-D4) |
| D5 | Servicios por ambiente: la tabla de contenedores de `SAD.md` incluye Availability | **Pendiente de validar** (`docker ps` por host) |
| D7 | Kafka en DEV y QA: [`ARQ-05`](ARQ-05-despliegue-kafka-dev-qa.md) y el estado de ADR-0029 | **Pendiente de validar** |
| D8 | Observabilidad: `SDD.md` §8 declara que no hay | **Pendiente de validar** |
| D15 | Responsable y alcance del cifrado, que condiciona el ADR de [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699) | Dato de Jira verificado; **falta la decisión** (P-D15) |

## 7. Qué falta para cerrar HU-WIKI-02

Hecho: orden de lectura, ficha de carpeta, finalidad y mantenedor por documento, versión y fecha, índice de ADR con estado al día (28 fichas al 2026-11-11), barrido de secretos, enlace de las discrepancias de HU-VAL-01 y retiro de los tres documentos ya absorbidos.

Añadido el 2026-11-11: se resolvieron los cinco marcadores de conflicto de git que estaban commiteados en [`SDD.md`](SDD.md) §4.6, se corrigió el estado de [`ARQ-05`](ARQ-05-despliegue-kafka-dev-qa.md) y se registraron las decisiones de HU-VAL-01 que afectan a esta carpeta ([§6](#6-discrepancias-de-hu-val-01-que-son-de-esta-carpeta)). [SCRUM-1704](https://maniservices.atlassian.net/browse/SCRUM-1704) quedó verificada como **ya cumplida**: el ADR existe y `SAD.md` §7.4 lo referencia.

Falta, y **cada punto depende de algo que no está en esta carpeta**:

1. **Ratificación de la suplencia en Mesa.** Asignada a la Mesa de Arquitectura el 2026-11-11 ([§1.1](#11-por-qué-la-suplencia-es-de-la-mesa-y-no-de-una-persona)); conviene que la propia Mesa lo deje en acta.
2. **Acta A/B y los ADR pendientes.** El ADR del tenant de clientes ([SCRUM-1700](https://maniservices.atlassian.net/browse/SCRUM-1700)) ya está publicado como [ADR-0036](adr/ADR-0036-pertenencia-del-cliente-a-tenant.md); le falta la decisión del PO, no la redacción. Siguen sin ficha o sin ratificar: el acta A/B ([SCRUM-1685](https://maniservices.atlassian.net/browse/SCRUM-1685), bloqueada por [SCRUM-1684](https://maniservices.atlassian.net/browse/SCRUM-1684)), el cifrado ([SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699)) y la asignación idempotente ([SCRUM-1704](https://maniservices.atlassian.net/browse/SCRUM-1704)).
3. **SDD §8 e Infraestructura V4 §7** corregidos respecto al monitoreo — [SCRUM-1686](https://maniservices.atlassian.net/browse/SCRUM-1686), que a su vez espera la fila D8.
4. **Ratificación de ADR-0035 en Mesa** (ADR-0003 §2). No la puede hacer la Scrum Master, que es la proponente del ADR.
5. ~~Revisión y aprobación del README por otro responsable de carpeta.~~ **Criterio retirado por la Scrum Master el 2026-11-12**, por el mismo motivo que en [06-gobernanza](../06-gobernanza/README.md): ninguna carpeta de la wiki declara responsable, así que la figura no existe.

**Fuera del alcance de esta carpeta:** [SCRUM-1661](https://maniservices.atlassian.net/browse/SCRUM-1661) no es trazabilidad de ADR. Son los 22 contratos OpenAPI que faltan (127 de 127) con sus *contract tests* en CI y un vídeo de validación en QA aprobado por la PO: trabajo de Juan S. Álvarez en los repositorios de código, no documentación de esta carpeta.

## 8. Diagramas

[`diagrams/`](diagrams/) — fuentes y PNG de los diagramas C4, de despliegue, de datos y de flujos. Los C4 se editan en [`diagrams/c4/workspace.dsl`](diagrams/c4/workspace.dsl), nunca sobre la imagen (ADR-0008).

## 9. Documentos absorbidos

Nueve documentos que vivían aquí como pieza aparte. Su contenido está íntegro en el documento que lo absorbió, que es ahora la única fuente; el texto original sigue en el historial de git.

Los tres primeros se retiraron de la raíz el 2026-11-10, tras comprobar sección por sección que su contenido está en el destino: el README ya los declaraba absorbidos mientras los archivos seguían presentes.

| Absorbido | Dónde quedó su contenido |
|---|---|
| `01-inventario-rls.md` (CFG-23a.1) | [`ModeloDatos.md`](ModeloDatos.md) §6.4, con la consulta de confirmación contra el motor y la conciliación con SCRUM-1334 |
| `02-diseno-modelo-identidad.md` (CFG-23a.3) | [`ModeloDatos.md`](ModeloDatos.md) §6.5 (componentes, contexto por flujo, políticas objetivo por tabla, integración por servicio, despliegue con reversa y riesgos) y [`SDD.md`](SDD.md) §8.12 (los seis casos cross-tenant) |
| `03-mesa-arquitectura.md` (CFG-23a.4) | [ADR-0032](adr/ADR-0032-identidad-de-servicio-en-base-de-datos.md), «Pendiente de Mesa»: preguntas M1 a M8, alternativas, evidencia de la PoC y acta pendiente |
| `EXPEDIENTE_MESA_TEC-12.md` | [Decisiones ADR](guia/decisiones-adr.md), «Qué tiene que decidir la Mesa»; el pendiente es P7 de [`SAD.md`](SAD.md) §7.4 |
| `REPORTE_CONFORMIDAD_CORE_DISPATCH.md` | [`SAD.md`](SAD.md) §7.6, con las desviaciones D-2 a D-10 y sus criterios de cierre |
| `CUMPLIMIENTO_ADR0027_FLUTTER.md` | [`SAD.md`](SAD.md) §8.3.1, con los accesos pendientes y la búsqueda que acredita el cierre |
| `TEC-14-observabilidad-minima-autenticacion.md` | [`SAD.md`](SAD.md) §19.1 y §19.2 |
| `MATRIZ_DECISION_6A.md` | [`SAD.md`](SAD.md) §7.4, que ya contenía la decisión y su contrato; sus puntos abiertos son P5 a P9 |
| `TRAZABILIDAD_INTEGRACION.md` | [`SAD.md`](SAD.md) §12.2 y §7.4, [`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md) y [`COMUNICACION_SERVICIOS_GATEWAY.md`](COMUNICACION_SERVICIOS_GATEWAY.md) §4.4 |

**Un documento obsoleto se marca, no se borra.** Lo que se retira de la raíz es un documento cuyo contenido completo vive ya en otro; queda en el historial de git y en esta tabla. Un documento que sigue siendo la única fuente de algo no se retira nunca: se marca con su fecha de corte y el motivo.

## 10. Dónde va un documento nuevo

1. ¿Decide algo que ataría al equipo? → un ADR en [`adr/`](adr/), por Mesa de Arquitectura (ADR-0003), con su requisito, su atributo de calidad y su prueba.
2. ¿Describe cómo es el sistema, o cómo debería ser? → a la sección del documento que ya cubre el tema, con su fecha de corte si es un estado. No a un archivo nuevo.
3. ¿Es el material de una Mesa que aún no se ha celebrado? → al ADR que se va a decidir.
4. ¿Es la ejecución de una prueba, un reporte de QA o una evidencia de sprint? → [`wiki/07-calidad/`](../07-calidad/README.md), no aquí.
5. ¿Solo explica para leer más fácil? → [`guia/`](guia/), citando la fuente que resume.

## Historial de cambios

| Fecha | Cambio |
|---|---|
| 2026-11-11 | Suplencia de la carpeta asignada a la **Mesa de Arquitectura** como órgano, no a una persona: la responsable mantiene todos los documentos, y las cabeceras que nombran a otros acreditan autoría del entregable, no mantenimiento continuo (§1.1). |
| 2026-11-11 | Correcciones: se resuelven los **cinco marcadores de conflicto de git** que estaban commiteados en [`SDD.md`](SDD.md) §4.6; [`ARQ-05`](ARQ-05-despliegue-kafka-dev-qa.md) deja de declarar Kafka verificado; se corrige que [SCRUM-1661](https://maniservices.atlassian.net/browse/SCRUM-1661) son los contratos OpenAPI y no la trazabilidad de los ADR; se corrige que `SAD.md` §7.4 **sí** documenta la asignación idempotente y referencia a ADR-0035, de modo que [SCRUM-1704](https://maniservices.atlassian.net/browse/SCRUM-1704) ya cumplía; se registran las decisiones de HU-VAL-01 que afectan a esta carpeta. |
| 2026-11-11 | Se publica [ADR-0036](adr/ADR-0036-pertenencia-del-cliente-a-tenant.md) (pertenencia del cliente a un tenant, `Propuesto`) y se propaga al índice de decisiones (§4, 28 fichas), al pendiente de §5 y al cierre de §7: el tenant de clientes pasa de «bug sin ADR» a «ADR publicado, decisión del PO pendiente». |
| 2026-11-10 | HU-WIKI-02 ([SCRUM-1690](https://maniservices.atlassian.net/browse/SCRUM-1690)): ficha de carpeta con responsable y consumidores, orden de lectura en seis pasos, finalidad y mantenedor por documento, versión y fecha, índice de ADR corregido a 27 fichas, barrido de secretos, enlace de las discrepancias de HU-VAL-01 y retiro de los tres documentos absorbidos que seguían en la raíz. Cierre parcial: ver §7. |
| 2026-11-04 | Reorganización en tres capas y absorción de los expedientes cerrados. |

# 02 · Arquitectura

[← Índice de la wiki](../Home.md)

**Arquitectura objetivo:** SOA distribuida + API Gateway + enfoque políglota + multi-tenancy.

La carpeta tiene tres capas, y cada documento vive en una sola:

| Capa | Qué es | Dónde |
|---|---|---|
| Guía | Páginas de lectura: ordenan y explican, no deciden | [`guia/`](guia/) |
| Documentos | La fuente de verdad de la arquitectura vigente | raíz de esta carpeta |
| Decisiones | Un ADR por decisión, con su estado | [`adr/`](adr/) |

Si guía y documento se contradicen, manda el documento. Si documento y ADR se contradicen, manda el ADR.

**No hay carpeta de expedientes.** Una auditoría, un inventario o el material de una Mesa no son un documento aparte: su contenido va al documento o al ADR que responde por ese tema, con su fecha de corte escrita. Lo que no sobrevive a esa pregunta —«¿de qué documento es esto una parte?»— no se guarda aquí.

## Guía — empieza por aquí

| Página | Tema |
|---|---|
| [Estilo y contenedores](guia/estilo-y-contenedores.md) | SOA + Gateway + políglota; qué contenedor hace qué |
| [Reglas arquitectónicas](guia/reglas-arquitectonicas.md) | Principios y dependencias permitidas/prohibidas |
| [Multi-tenancy y seguridad](guia/multitenancy-y-seguridad.md) | Identificación de tenant, capas de control, KYC |
| [Datos y analítica](guia/datos-y-analitica.md) | Propiedad de datos, esquemas, RLS, Data Warehouse |
| [Atributos de calidad](guia/atributos-de-calidad.md) | Prioridades y umbrales verificables |
| [Decisiones ADR](guia/decisiones-adr.md) | Índice de ADR con estado, reglas de Mesa, huecos y lo que falta ratificar |
| [Riesgos y puntos abiertos](guia/riesgos-y-puntos-abiertos.md) | Architectural killers y lo que falta decidir |
| [Diagramas](guia/diagramas.md) | Qué diagramas existen y dónde |

## Documentos — la fuente

| Documento | De qué responde |
|---|---|
| [`SAD.md`](SAD.md) | Arquitectura del sistema: estilo, contenedores, límites entre servicios, multi-tenancy, observabilidad, riesgos |
| [`SDD.md`](SDD.md) | Diseño detallado, vistas C4, escenarios de calidad y vista de despliegue |
| [`ModeloDatos.md`](ModeloDatos.md) | Modelo de datos, propiedad de esquema, permisos y políticas RLS |
| [`SECUENCIAS.md`](SECUENCIAS.md) | Secuencias de los flujos principales |
| [`COMUNICACION_SERVICIOS_GATEWAY.md`](COMUNICACION_SERVICIOS_GATEWAY.md) | Enrutamiento perimetral y reglas de comunicación entre servicios |
| [`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md) | Esquemas y versionado de los eventos de negocio |
| [`TECH_RADAR.md`](TECH_RADAR.md) | Tecnologías adoptadas, en prueba y descartadas |

Secciones que conviene conocer porque son las que suelen buscarse como «documento aparte»:

| Si buscas | Está en |
|---|---|
| Estado real de RLS hoy, y las exposiciones abiertas | [`ModeloDatos.md`](ModeloDatos.md) §6.4 |
| Modelo de identidad en el motor y políticas objetivo por tabla | [`ModeloDatos.md`](ModeloDatos.md) §6.5 |
| Conformidad del código con los límites entre servicios, y sus desviaciones abiertas | [`SAD.md`](SAD.md) §7.6 |
| Qué falta para cumplir ADR-0027 en Flutter | [`SAD.md`](SAD.md) §8.3.1 |
| Métricas y alertas de autenticación | [`SAD.md`](SAD.md) §19.1 y §19.2 |
| Los seis casos cross-tenant que QA debe ejecutar | [`SDD.md`](SDD.md) §8.1 |
| Lo que falta ratificar en Mesa | [Decisiones ADR](guia/decisiones-adr.md) y el apartado «Pendiente de Mesa» de [ADR-0032](adr/ADR-0032-identidad-de-servicio-en-base-de-datos.md) |

## Decisiones

[`adr/`](adr/) — 26 fichas: 24 `Aceptado` (vinculantes), 1 `Rechazado` y 1 `Propuesto`. Los números no son contiguos y no se reutilizan. El índice con estado, los retiros y los huecos están en [Decisiones ADR](guia/decisiones-adr.md).

## Diagramas

[`diagrams/`](diagrams/) — fuentes y PNG de los diagramas C4, de despliegue, de datos y de flujos. Los C4 se editan en [`diagrams/c4/workspace.dsl`](diagrams/c4/workspace.dsl), nunca sobre la imagen (ADR-0008).

## Documentos absorbidos

Seis documentos que vivían aquí como pieza aparte. Su contenido está íntegro en el documento que lo absorbió, que es ahora la única fuente; el texto original sigue en el historial de git.

| Absorbido | Dónde quedó su contenido |
|---|---|
| `CFG-23a/01-inventario-rls.md` | [`ModeloDatos.md`](ModeloDatos.md) §6.4, con la consulta de confirmación contra el motor |
| `CFG-23a/02-diseno-modelo-identidad.md` | [`ModeloDatos.md`](ModeloDatos.md) §6.5 (modelo, políticas por tabla, despliegue y riesgos) y [`SDD.md`](SDD.md) §8.1 (los seis casos cross-tenant) |
| `CFG-23a/03-mesa-arquitectura.md` | [ADR-0032](adr/ADR-0032-identidad-de-servicio-en-base-de-datos.md), apartado «Pendiente de Mesa»: preguntas M1 a M8, evidencia de la PoC y acta pendiente |
| `EXPEDIENTE_MESA_TEC-12.md` | [Decisiones ADR](guia/decisiones-adr.md), «Qué tiene que decidir la Mesa»; el pendiente es P7 de [`SAD.md`](SAD.md) §7.4 |
| `REPORTE_CONFORMIDAD_CORE_DISPATCH.md` | [`SAD.md`](SAD.md) §7.6, con las desviaciones D-2 a D-10 y sus criterios de cierre |
| `CUMPLIMIENTO_ADR0027_FLUTTER.md` | [`SAD.md`](SAD.md) §8.3.1, con los accesos pendientes y la búsqueda que acredita el cierre |
| `TEC-14-observabilidad-minima-autenticacion.md` | [`SAD.md`](SAD.md) §19.1 y §19.2 |
| `MATRIZ_DECISION_6A.md` | [`SAD.md`](SAD.md) §7.4, que ya contenía la decisión y su contrato; sus puntos abiertos son P5 a P9 |
| `TRAZABILIDAD_INTEGRACION.md` | [`SAD.md`](SAD.md) §12.2 y §7.4, [`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md) y [`COMUNICACION_SERVICIOS_GATEWAY.md`](COMUNICACION_SERVICIOS_GATEWAY.md) §4.4 |

## Dónde va un documento nuevo

1. ¿Decide algo que ataría al equipo? → un ADR en [`adr/`](adr/), por Mesa de Arquitectura (ADR-0003).
2. ¿Describe cómo es el sistema, o cómo debería ser? → a la sección del documento que ya cubre el tema, con su fecha de corte si es un estado. No a un archivo nuevo.
3. ¿Es el material de una Mesa que aún no se ha celebrado? → al ADR que se va a decidir.
4. ¿Es la ejecución de una prueba, un reporte de QA o una evidencia de sprint? → [`wiki/07-calidad/`](../07-calidad/README.md), no aquí.
5. ¿Solo explica para leer más fácil? → [`guia/`](guia/), citando la fuente que resume.

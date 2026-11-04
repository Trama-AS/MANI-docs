# 02 · Arquitectura

[← Índice de la wiki](../Home.md)

**Arquitectura objetivo:** SOA distribuida + API Gateway + enfoque políglota + multi-tenancy.

La carpeta tiene cuatro capas, y cada documento vive en una sola:

| Capa | Qué es | Dónde |
|---|---|---|
| Guía | Páginas de lectura: ordenan y explican, no deciden | [`guia/`](guia/) |
| Documentos | La fuente de verdad de la arquitectura vigente | raíz de esta carpeta |
| Decisiones | Un ADR por decisión, con su estado | [`adr/`](adr/) |
| Expedientes | Evidencia puntual de una tarea o una Mesa, con fecha | [`expedientes/`](expedientes/) |

Si guía y documento se contradicen, manda el documento. Si documento y ADR se contradicen, manda el ADR.

## Guía — empieza por aquí

| Página | Tema |
|---|---|
| [Estilo y contenedores](guia/estilo-y-contenedores.md) | SOA + Gateway + políglota; qué contenedor hace qué |
| [Reglas arquitectónicas](guia/reglas-arquitectonicas.md) | Principios y dependencias permitidas/prohibidas |
| [Multi-tenancy y seguridad](guia/multitenancy-y-seguridad.md) | Identificación de tenant, capas de control, KYC |
| [Datos y analítica](guia/datos-y-analitica.md) | Propiedad de datos, esquemas, RLS, Data Warehouse |
| [Atributos de calidad](guia/atributos-de-calidad.md) | Prioridades y umbrales verificables |
| [Decisiones ADR](guia/decisiones-adr.md) | Índice de ADR con estado, reglas de Mesa y huecos de numeración |
| [Riesgos y puntos abiertos](guia/riesgos-y-puntos-abiertos.md) | Architectural killers y lo que falta decidir |
| [Diagramas](guia/diagramas.md) | Qué diagramas existen y dónde |

## Documentos — la fuente

| Documento | De qué responde |
|---|---|
| [`SAD.md`](SAD.md) | Arquitectura del sistema: estilo, contenedores, vistas, atributos de calidad, riesgos |
| [`SDD.md`](SDD.md) | Diseño detallado, vistas C4, escenarios QAS y vista de despliegue |
| [`ModeloDatos.md`](ModeloDatos.md) | Modelo de datos, propiedad de esquema y políticas RLS |
| [`SECUENCIAS.md`](SECUENCIAS.md) | Secuencias de los flujos principales |
| [`COMUNICACION_SERVICIOS_GATEWAY.md`](COMUNICACION_SERVICIOS_GATEWAY.md) | Reglas de comunicación entre servicios y por el Gateway |
| [`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md) | Esquemas y versionado de los eventos de negocio |
| [`TECH_RADAR.md`](TECH_RADAR.md) | Tecnologías adoptadas, en prueba y descartadas |

## Decisiones

[`adr/`](adr/) — 26 fichas: 24 `Aceptado` (vinculantes), 1 `Rechazado` y 1 `Propuesto`. Los números no son contiguos y no se reutilizan. El índice con estado, los retiros y los huecos están en [Decisiones ADR](guia/decisiones-adr.md).

## Expedientes

Evidencia de una tarea concreta, no doctrina. Se leen por su fecha; si contradicen a un documento o a un ADR, el expediente está desactualizado.

| Expediente | De qué responde | Por qué sigue abierto |
|---|---|---|
| [`CFG-23a/`](expedientes/CFG-23a/) | Inventario de políticas RLS, diseño del modelo de identidad de servicio y su paso por Mesa | El diseño aún no se aplica: lo versiona CFG-23b y lo acredita CFG-23c, con las preguntas M2 y M4 pendientes de Mesa |
| [`EXPEDIENTE_MESA_TEC-12.md`](expedientes/EXPEDIENTE_MESA_TEC-12.md) | Material para que la Mesa ratifique o revierta ADR-0030 y ADR-0016, con la evidencia de que el código ya los cumple | La sesión de Mesa no ha ocurrido (pendiente P7 de SAD §7.4) |
| [`REPORTE_CONFORMIDAD_CORE_DISPATCH.md`](expedientes/REPORTE_CONFORMIDAD_CORE_DISPATCH.md) | Conformidad técnica de Core y Dispatch, auditada contra commits exactos del 2026-10-20 | Es una auditoría fechada: vale como evidencia de ese corte, no como descripción del sistema de hoy |
| [`CUMPLIMIENTO_ADR0027_FLUTTER.md`](expedientes/CUMPLIMIENTO_ADR0027_FLUTTER.md) | Accesos directos a Supabase que quedan en Flutter y la búsqueda que acredita ADR-0027, al corte del 2026-10-28 | Quedan dos accesos por retirar (§5 del propio expediente) |

### Expedientes retirados

Su contenido vive íntegro en el documento que lo absorbió, que es ahora la única fuente. El texto original sigue en el historial de git.

| Retirado | Dónde quedó su contenido |
|---|---|
| `TEC-14-observabilidad-minima-autenticacion.md` | [`SAD.md`](SAD.md) §19.1 (métricas) y §19.2 (alertas de R-4); la evidencia de pruebas se cita allí |
| `MATRIZ_DECISION_6A.md` | [`SAD.md`](SAD.md) §7.4: la decisión 6A, su contrato de asignación y los pendientes P5 a P9. La matriz solo verificaba que esas filas estuvieran sincronizadas, y lo están |
| `TRAZABILIDAD_INTEGRACION.md` | [`SAD.md`](SAD.md) §12.2 (eventos, sobre y outbox) y §7.4 (dueños y pendientes), [`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md) (esquemas y versionado) y [`COMUNICACION_SERVICIOS_GATEWAY.md`](COMUNICACION_SERVICIOS_GATEWAY.md) §4.4 (llamadas permitidas y prohibidas) |

## Diagramas

[`diagrams/`](diagrams/) — fuentes y PNG de los diagramas C4, de despliegue, de datos y de flujos. Los C4 se editan en [`diagrams/c4/workspace.dsl`](diagrams/c4/workspace.dsl), nunca sobre la imagen (ADR-0008).

## Dónde va un documento nuevo

1. ¿Decide algo que ataría al equipo? → un ADR en [`adr/`](adr/), por Mesa de Arquitectura (ADR-0003).
2. ¿Describe cómo es el sistema hoy? → al documento que ya cubre el tema, no a uno nuevo.
3. ¿Es la evidencia de una tarea, una Mesa o una verificación? → [`expedientes/`](expedientes/), con su identificador Jira en el nombre.
4. ¿Solo explica para leer más fácil? → [`guia/`](guia/), citando la fuente que resume.

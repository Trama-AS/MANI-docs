# 02 · Arquitectura

[← Índice de la wiki](../Home.md)

**Fuente:** [`architecture/SAD.md`](SAD.md) · [`architecture/SDD.md`](SDD.md) · [`adr/`](adr/) · [`architecture/TECH_RADAR.md`](TECH_RADAR.md).

| Página | Tema |
|---|---|
| [Estilo y contenedores](estilo-y-contenedores.md) | SOA + Gateway + políglota; qué contenedor hace qué |
| [Reglas arquitectónicas](reglas-arquitectonicas.md) | Principios y dependencias permitidas/prohibidas |
| [Multi-tenancy y seguridad](multitenancy-y-seguridad.md) | Identificación de tenant, capas de control, KYC |
| [Datos y analítica](datos-y-analitica.md) | Propiedad de datos, esquemas, RLS, Data Warehouse |
| [Atributos de calidad](atributos-de-calidad.md) | Prioridades y umbrales verificables |
| [Decisiones ADR](decisiones-adr.md) | Índice de ADR con estado |
| [Riesgos y puntos abiertos](riesgos-y-puntos-abiertos.md) | Architectural killers y lo que falta decidir |
| [Diagramas](diagramas.md) | Qué diagramas existen y dónde |

## Documentos y carpetas de esta carpeta

Las páginas de arriba ordenan y navegan; esto es la fuente.

| Documento | De qué responde |
|---|---|
| [`SAD.md`](SAD.md) | Arquitectura del sistema: estilo, contenedores, vistas, atributos de calidad, riesgos |
| [`SDD.md`](SDD.md) | Diseño detallado, vistas C4, escenarios QAS y vista de despliegue |
| [`ModeloDatos.md`](ModeloDatos.md) | Modelo de datos, propiedad de esquema y políticas RLS |
| [`SECUENCIAS.md`](SECUENCIAS.md) | Secuencias de los flujos principales |
| [`COMUNICACION_SERVICIOS_GATEWAY.md`](COMUNICACION_SERVICIOS_GATEWAY.md) | Reglas de comunicación entre servicios y por el Gateway |
| [`CONTRATOS_EVENTOS.md`](CONTRATOS_EVENTOS.md) | Esquemas y versionado de los eventos |
| [`TRAZABILIDAD_INTEGRACION.md`](TRAZABILIDAD_INTEGRACION.md) | Trazabilidad de la integración entre servicios |
| [`REPORTE_CONFORMIDAD_CORE_DISPATCH.md`](REPORTE_CONFORMIDAD_CORE_DISPATCH.md) | Conformidad técnica de Core y Dispatch con la arquitectura vigente |
| [`MATRIZ_DECISION_6A.md`](MATRIZ_DECISION_6A.md) | Decisión 6A (propiedad del estado del servicio): dónde quedó escrita, su contrato y la historia responsable de cada parte |
| [`EXPEDIENTE_MESA_TEC-12.md`](EXPEDIENTE_MESA_TEC-12.md) | Material para que la Mesa ratifique o revierta ADR-0030 y ADR-0016, con la evidencia de que el código ya los cumple |
| [`TECH_RADAR.md`](TECH_RADAR.md) | Tecnologías adoptadas, en prueba y descartadas |
| [`adr/`](adr/) | Decisiones arquitectónicas. Una vigente está `Aceptado`; una sustituida, `Superseded` |
| [`diagrams/`](diagrams/) | Fuentes y PNG de los diagramas C4, de despliegue, de datos y de flujos |
| [`CFG-23a/`](CFG-23a/) | Inventario de RLS y diseño del modelo de identidad de servicio |

**Arquitectura objetivo:** SOA distribuida + API Gateway + enfoque políglota + multi-tenancy.

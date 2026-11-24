# 02 · Arquitectura

[← Índice de la wiki](../Home.md)

**Arquitectura objetivo:** SOA distribuida + API Gateway + enfoque políglota + multi-tenancy.

La carpeta contiene cuatro documentos, las decisiones y los diagramas. Todo lo demás vive dentro de ellos.

| Documento | Qué contiene |
|---|---|
| [`SAD.md`](SAD.md) | Arquitectura de alto nivel: drivers, principios, contexto y contenedores (C4 N1 y N2), responsabilidad y límites de cada servicio, multi-tenancy y seguridad, despliegue, CI/CD, observabilidad, patrones, riesgos y registro de decisiones |
| [`SDD.md`](SDD.md) | Diseño de bajo nivel: vistas C4 de componentes y código, vistas dinámicas, atributos de calidad y escenarios con sus umbrales, ambientes y versionamiento, comunicación entre servicios y Gateway, contratos de eventos, secuencias, Kafka y diseño de los módulos de cotización, cola sin conexión, alerta de tarifa y menú por rol |
| [`ModeloDatos.md`](ModeloDatos.md) | Modelo conceptual, lógico y físico, DDL, diccionario de datos, permisos y RLS, Data Warehouse |
| [`TECH_RADAR.md`](TECH_RADAR.md) | Tecnologías adoptadas, en evaluación y descartadas |

| Carpeta | Qué contiene |
|---|---|
| [`adr/`](adr/) | Una ficha por decisión arquitectónica. Un ADR `Aceptado` prevalece sobre cualquier descripción de los documentos. El índice está en SAD §24 |
| [`diagrams/`](diagrams/) | Modelo C4 en Structurizr DSL (`c4/workspace.dsl`) y las imágenes exportadas |

Orden de lectura: SAD §2 a §6 (qué se construye), SAD §7 a §8 (límites y seguridad), SDD §4 (vistas C4), SDD §7 y §8 (calidad), y ModeloDatos §6 (persistencia y aislamiento).

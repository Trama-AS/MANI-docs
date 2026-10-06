# Decisiones ADR

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** los archivos de [`adr/`](../../adr/) · [`governance/GOBIERNO_DEL_EQUIPO.md`](../../governance/GOBIERNO_DEL_EQUIPO.md) §5 · [`adr/ADR-0003`](../../adr/ADR-0003-mesa-arquitectura.md).

## Cómo funciona un ADR en MANI

Reglas de Mesa de Arquitectura (`GOBIERNO_DEL_EQUIPO.md` §5):

1. ficha de preparación antes de la sesión;
2. mínimo dos alternativas reales;
3. quórum mínimo de 5 de 7 integrantes;
4. al menos una persona argumenta en contra de la opción preferida;
5. el redactor del ADR debe ser distinto del proponente cuando sea viable;
6. el disenso se documenta;
7. toda decisión arquitectónica produce un ADR;
8. **los ADR históricos no se eliminan**;
9. si una decisión cambia, el ADR anterior pasa a `Superseded`.

Una respuesta de un asistente de IA, un mensaje de chat o una propuesta en un PR **no** constituyen una decisión arquitectónica (Políticas DevOps §18.5).

## Estados

| Estado | Significado |
|---|---|
| `Aceptado` | Vinculante |
| `Propuesto` | Recomendación vigente hasta que la Mesa lo apruebe |
| `Rejected` | Evaluado y descartado; no se reintroduce sin nueva decisión |
| `Superseded` | Reemplazado; se conserva por trazabilidad |

## Índice

### Vigentes — `Aceptado`

| ADR | Tema |
|---|---|
| [ADR-0001](../../adr/ADR-0001-gestion-documental.md) | Gestión documental del proyecto |
| [ADR-0002](../../adr/ADR-0002-jira-github.md) | Jira para gestión, GitHub para desarrollo técnico |
| [ADR-0003](../../adr/ADR-0003-mesa-arquitectura.md) | Gobierno mediante Mesa de Arquitectura |
| [ADR-0004](../../adr/ADR-0004-cicd-multirepo-ambientes.md) | CI/CD multi-repositorio y promoción de ambientes |
| [ADR-0005](../../adr/ADR-0005-devsecops.md) | DevSecOps con SAST, DAST y pruebas de API |
| [ADR-0006](../../adr/ADR-0006-observabilidad.md) | Observabilidad distribuida y gestión de incidentes |
| [ADR-0008](../../adr/ADR-0008-diagramacion-tecnica.md) | Organización y versionado de diagramas técnicos |
| [ADR-0011](../../adr/ADR-0011-cobertura-geografica.md) | Cobertura geográfica por zonas |
| [ADR-0012](../../adr/ADR-0012-persistencia-multitenant.md) | Persistencia operacional y aislamiento multi-tenant |
| [ADR-0018](../../adr/ADR-0018-identificacion-tenant.md) | Identificación y propagación segura del tenant |
| [ADR-0019](../../adr/ADR-0019-arquitectura-soa-poliglota.md) | Arquitectura SOA distribuida, multi-tenant y políglota |
| [ADR-0027](../../adr/ADR-0027-alcance-supabase-cliente-flutter.md) | Alcance de supabase_flutter en el cliente (retiro de PostgREST y Storage) |

### Pendientes de aprobación — `Propuesto`

| ADR | Tema | Afecta |
|---|---|---|
| [ADR-0013](../../adr/ADR-0013-storage-kyc.md) | Almacenamiento de documentos KYC | RF-05, RF-06, REST-02 |
| [ADR-0015](../../adr/ADR-0015-pruebas-aislamiento-multitenant.md) | Pruebas automatizadas de aislamiento multi-tenant | RNF-01 |
| [ADR-0016](../../adr/ADR-0016-despacho-concurrencia.md) | Despacho broadcast y exclusión concurrente (absorbe ADR-0021) | RF-14, RNF-03, RNF-05 |
| [ADR-0017](../../adr/ADR-0017-realtime-notificaciones.md) | Mensajería en tiempo real y notificaciones push | RF-20, RF-21 |

### Descartado — `Rejected`

| ADR | Tema |
|---|---|
| [ADR-0014](../../adr/ADR-0014-feature-toggle.md) | Feature Toggle como mecanismo de diferencias por tenant |

### Históricos — `Superseded`

| ADR | Tema | Sustituido por |
|---|---|---|
| [ADR-0007](../../adr/ADR-0007-documentacion-repositorio.md) | Documentación técnica en repositorio | ADR-0001 |
| [ADR-0009](../../adr/ADR-0009-politica-ia.md) | Política de uso de IA | Documento de gobierno (ver nota) |
| [ADR-0010](../../adr/ADR-0010-tech-radar.md) | Tech Radar como ADR | [`TECH_RADAR.md`](../../architecture/TECH_RADAR.md) |
| [ADR-0020](../../adr/ADR-0020-herramientas-visuales.md) | Herramientas de documentación visual | ADR-0008 + Tech Radar |
| [ADR-0021](../../adr/ADR-0021-exclusion-concurrente.md) | Exclusión concurrente en despacho | ADR-0016 |

> **Nota sobre ADR-0009.** Remite a `docs/governance/POLITICA_USO_IA.md`, archivo que no existe en este repositorio. La política de IA vigente y localizable es la sección 18 de [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md), recogida en [Trabajo con asistentes de IA](../05-proceso/trabajo-con-ia.md). Queda listado en [Riesgos y puntos abiertos](riesgos-y-puntos-abiertos.md).

## Numeración

El backlog de transición registra la tarea `DOC-27`: reconstruir la matriz de trazabilidad de ADR y recuperar **ADR-0022 a ADR-0026**, que no están en este repositorio. Hasta que se ejecute, el rango vigente localizable es ADR-0001..ADR-0021.

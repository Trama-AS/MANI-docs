# Decisiones ADR

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** los archivos de [`adr/`](adr/) · [`GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §5 · [`adr/ADR-0003`](adr/ADR-0003-mesa-arquitectura.md).

**25 ADR vigentes**, numerados `ADR-0001` a `ADR-0032` con huecos. 24 son vinculantes y 1 está descartado. Ningún ADR queda en `Propuesto` ni en `Superseded`.

## Cómo funciona un ADR en MANI

Reglas de Mesa de Arquitectura (`GOBIERNO_DEL_EQUIPO.md` §5):

1. ficha de preparación antes de la sesión;
2. mínimo dos alternativas reales;
3. quórum mínimo de 5 de 7 integrantes;
4. al menos una persona argumenta en contra de la opción preferida;
5. el redactor del ADR debe ser distinto del proponente cuando sea viable;
6. el disenso se documenta;
7. toda decisión arquitectónica produce un ADR;
8. un ADR absorbido por otro se retira del registro, si su decisión vive íntegra en el que lo absorbe, ese ADR lo declara en su cabecera, el retiro se lista en esta página y su número no se reutiliza;
9. si una decisión cambia, el ADR anterior pasa a `Superseded` y se mantiene hasta que su contenido se absorba.

Las reglas 8 y 9 se enmendaron el 2026-10-23: antes los ADR históricos no se eliminaban. El motivo está en [`GOBIERNO_DEL_EQUIPO.md` §5](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md#5-mesa-de-arquitectura).

Una respuesta de un asistente de IA, un mensaje de chat o una propuesta en un PR **no** constituyen una decisión arquitectónica (Políticas DevOps §18.5).

## Estados

| Estado | Significado |
|---|---|
| `Aceptado` | Vinculante |
| `Rechazado` | Evaluado y descartado; no se reintroduce sin nueva decisión |

`Propuesto` y `Superseded` ya no se usan en el registro: los diez ADR que estaban en `Propuesto` se ratificaron el 2026-10-23 y los seis `Superseded` se retiraron. El estado `Propuesto` sigue siendo válido para un ADR nuevo mientras la Mesa no lo apruebe.

## Índice — vigentes

| ADR | Tema | Afecta |
|---|---|---|
| [ADR-0001](adr/ADR-0001-gestion-documental.md) | Gestión documental del proyecto | documentación |
| [ADR-0002](adr/ADR-0002-jira-github.md) | Jira para gestión, GitHub para desarrollo técnico | trazabilidad |
| [ADR-0003](adr/ADR-0003-mesa-arquitectura.md) | Gobierno mediante Mesa de Arquitectura | gobierno |
| [ADR-0004](adr/ADR-0004-cicd-multirepo-ambientes.md) | CI/CD multi-repositorio y promoción de ambientes — *enmendado el 2026-10-07; su lista de repositorios la reemplaza ADR-0028* | entrega |
| [ADR-0005](adr/ADR-0005-devsecops.md) | DevSecOps con SAST, DAST y pruebas de API | calidad |
| [ADR-0006](adr/ADR-0006-observabilidad.md) | Observabilidad distribuida y gestión de incidentes | RNF-04 |
| [ADR-0008](adr/ADR-0008-diagramacion-tecnica.md) | Organización y versionado de diagramas técnicos — *absorbe el antiguo ADR-0020* | documentación |
| [ADR-0011](adr/ADR-0011-cobertura-geografica.md) | Cobertura geográfica por zonas | RF-07 |
| [ADR-0012](adr/ADR-0012-persistencia-multitenant.md) | Persistencia operacional y aislamiento multi-tenant | RNF-01 |
| [ADR-0013](adr/ADR-0013-storage-kyc.md) | Almacenamiento de documentos KYC | RF-05, RF-06, REST-02 |
| [ADR-0015](adr/ADR-0015-pruebas-aislamiento-multitenant.md) | Pruebas automatizadas de aislamiento multi-tenant | RNF-01 |
| [ADR-0016](adr/ADR-0016-despacho-concurrencia.md) | Despacho broadcast y exclusión concurrente — *absorbe el antiguo ADR-0021; evidencia en PoC-001* | RF-14, RNF-03, RNF-05 |
| [ADR-0017](adr/ADR-0017-realtime-notificaciones.md) | Mensajería en tiempo real y notificaciones push | RF-20, RF-21 |
| [ADR-0018](adr/ADR-0018-identificacion-tenant.md) | Identificación y propagación segura del tenant | RNF-01 |
| [ADR-0019](adr/ADR-0019-arquitectura-soa-poliglota.md) | Arquitectura SOA distribuida, multi-tenant y políglota | PROY-07 |
| [ADR-0022](adr/ADR-0022-logica-de-negocio-en-servicios.md) | La lógica de negocio vive en los servicios; se retira de Flutter y de las funciones PL/pgSQL | RF-05, RF-06, RF-08, RF-10, RF-11, RF-12, RNF-01 |
| [ADR-0024](adr/ADR-0024-modelo-custodia-pagos.md) | Modelo de custodia de pagos: el dinero lo custodia un operador regulado y MANI gestiona el estado — *absorbe el antiguo ADR-0023, con su análisis regulatorio* | RF-24, RF-25, RNF-06, RNF-11 |
| [ADR-0025](adr/ADR-0025-integracion-jira-github.md) | Integración Jira–GitHub con GitHub for Atlassian y convención `[SCRUM-<id>]` | trazabilidad |
| [ADR-0027](adr/ADR-0027-alcance-supabase-cliente-flutter.md) | Alcance de `supabase_flutter`: solo Auth y Realtime; retiro de PostgREST, RPC y Storage | RNF-01 |
| [ADR-0028](adr/ADR-0028-nombres-repositorios-y-ambientes.md) | Nombres de los repositorios y de los ambientes | PROY-07, PROY-08 |
| [ADR-0029](adr/ADR-0029-comunicacion-asincrona-kafka.md) | Comunicación asíncrona con Kafka | RNF-03 |
| [ADR-0030](adr/ADR-0030-propiedad-esquema-y-frontera-de-datos.md) | Propiedad del esquema y frontera de datos entre servicios | RNF-01 |
| [ADR-0031](adr/ADR-0031-politica-configuracion-jwt-ambientes.md) | Configuración, validación perimetral y propagación de JWT por ambiente — *enmendado el 2026-10-21 para aceptar ES256 verificado con el JWKS de Supabase* | RNF-01 |
| [ADR-0032](adr/ADR-0032-identidad-de-servicio-en-base-de-datos.md) | Identidad de servicio en base de datos | RNF-01 |
| [ADR-0033](adr/ADR-0033-productor-del-evento-solicitud-creada.md) | Productor del evento `SolicitudCreada`: Dispatch, no Core — `Propuesto`; reemplazaría [ADR-0029](adr/ADR-0029-comunicacion-asincrona-kafka.md) §1 en esa fila si la Mesa lo aprueba | RF-12 |
| [ADR-0034](adr/ADR-0034-contrato-comun-proveedores-externos.md) | Contrato y política comunes para proveedores externos de pagos y notificaciones — `Propuesto` | RF-20, RF-24 |
| [ADR-0035](adr/ADR-0035-frontera-de-asignacion-6a.md) | Frontera de la asignación: Dispatch decide y Core escribe (decisión 6A) — `Propuesto`; reemplazaría la fila de `AliadoAsignado` en [ADR-0029](adr/ADR-0029-comunicacion-asincrona-kafka.md) §1 si la Mesa lo aprueba | RF-14, RNF-03, RNF-05 |

## Índice — descartado

| ADR | Tema |
|---|---|
| [ADR-0014](adr/ADR-0014-feature-toggle.md) | Feature Toggle como mecanismo de diferencias por tenant |

## Dos cambios del 2026-10-23 que hay que conocer

### Los diez ADR que estaban en `Propuesto` pasaron a `Aceptado`

Fueron ADR-0013, 0015, 0016, 0017, 0022, 0025, 0028, 0029, 0030 y 0032. La ratificación la decidió la Scrum Master (Sara Albarracín) en la consolidación documental, **sin sesión de Mesa de Arquitectura registrada**, que es lo que ADR-0003 §2 exige para una decisión estructural. Cada ADR lo declara en su cabecera, en el campo `Ratificación`, para que la Mesa pueda confirmarlo o revertirlo.

Esto importa porque varios ya se usaban como si fueran vinculantes: ADR-0030 es la fuente de los criterios transversales T1, T2 y T3 del [backlog §6.2](../05-backlog/BACKLOG_MANI.md#62-criterios-transversales), y ADR-0022 gobierna la migración completa de la lógica de negocio.

### Los seis ADR `Superseded` se retiraron del repositorio

| Retirado | Tema | Dónde quedó su contenido |
|---|---|---|
| `ADR-0007` | Documentación técnica en repositorio | Consolidado en [ADR-0001](adr/ADR-0001-gestion-documental.md), que lo declara en su cabecera |
| `ADR-0009` | Política de uso de IA | No era decisión de arquitectura: la política viva es [`POLITICAS_DEVOPS_HERRAMIENTAS.md` §18](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md#18-política-de-uso-de-ia), recogida en [Trabajo con asistentes de IA](../04-proceso/trabajo-con-ia.md). Su «sustituto» declarado, `docs/governance/POLITICA_USO_IA.md`, nunca existió |
| `ADR-0010` | Tech Radar como ADR | Es un artefacto vivo, no una decisión: [`TECH_RADAR.md`](TECH_RADAR.md) |
| `ADR-0020` | Herramientas de documentación visual | Absorbido por [ADR-0008](adr/ADR-0008-diagramacion-tecnica.md); las herramientas concretas son parte del Tech Radar |
| `ADR-0021` | Exclusión concurrente en despacho | Absorbido por [ADR-0016](adr/ADR-0016-despacho-concurrencia.md), que ahora cita la evidencia de PoC-001 |
| `ADR-0023` | Riesgo regulatorio en la custodia de pagos de EP-07 | Su análisis regulatorio completo (art. 316 del Código Penal, Decreto 1981 de 1988, Ley 1581 de 2012) se trasladó íntegro al contexto de [ADR-0024](adr/ADR-0024-modelo-custodia-pagos.md) |

Los cinco primeros eran lápidas de 10 a 14 líneas, sin decisión propia: solo declaraban su sustituto. ADR-0023 sí tenía contenido, y por eso se absorbió antes de retirarlo.

Los retiros cumplen la regla 8: cada decisión vive íntegra en el ADR que la absorbe, que lo declara en su cabecera. El texto original de los seis sigue recuperable en el historial de git y en las copias congeladas de [`Entregas/`](../../Entregas/README.md).

## Numeración

Los números **no son contiguos y no se reutilizan**. Tres huecos:

| Hueco | Por qué |
|---|---|
| `0007`, `0009`, `0010`, `0020`, `0021`, `0023` | Retirados el 2026-10-23, ver arriba |
| `0026` | Nunca se emitió |
| — | El siguiente ADR que se emita es `ADR-0036` |

Dos avisos para no equivocarse al leer:

- Los documentos de [`Entregas/`](../../Entregas/README.md) usaron una numeración **distinta y hoy abandonada**, en la que `ADR-0022` era «proveedor de identidad» y `ADR-0023` el cierre de KI-02 (consolidación del stack sin Azure). En el esquema vigente `ADR-0022` es la lógica de negocio en los servicios, y el antiguo `ADR-0023` era el riesgo regulatorio de la custodia de pagos. `Entregas/` es un histórico congelado y **no es fuente de verdad**.
- `ADR-0027` se emitió antes que `0024` y `0025`, así que la numeración no sigue el orden cronológico. Conserva su número porque lo referencian `CFG-35` y el commit que lo introdujo.

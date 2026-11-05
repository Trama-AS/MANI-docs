# Decisiones ADR

[← 02 · Arquitectura](../README.md) · [Índice](../../Home.md)

**Fuente:** los archivos de [`adr/`](../adr/) · [`GOBIERNO_DEL_EQUIPO.md`](../../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §5 · [`adr/ADR-0003`](../adr/ADR-0003-mesa-arquitectura.md).

**27 ADR en el registro**, numerados `ADR-0001` a `ADR-0035` con huecos: 24 `Aceptado` (vinculantes), 1 `Rechazado` (ADR-0014) y 2 `Propuesto` (ADR-0034 y ADR-0035, pendientes de Mesa). Ningún ADR queda en `Superseded`.

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

Las reglas 8 y 9 se enmendaron el 2026-10-23: antes los ADR históricos no se eliminaban. El motivo está en [`GOBIERNO_DEL_EQUIPO.md` §5](../../06-gobernanza/GOBIERNO_DEL_EQUIPO.md#5-mesa-de-arquitectura).

Una respuesta de un asistente de IA, un mensaje de chat o una propuesta en un PR **no** constituyen una decisión arquitectónica (Políticas DevOps §18.5).

## Estados

| Estado | Significado |
|---|---|
| `Aceptado` | Vinculante |
| `Rechazado` | Evaluado y descartado; no se reintroduce sin nueva decisión |
| `Propuesto` | Redactado y a la espera de Mesa; no vincula todavía. Hoy ADR-0034 y ADR-0035 |

`Superseded` ya no se usa en el registro: los seis ADR que lo tenían se retiraron el 2026-10-23. Los diez que estaban en `Propuesto` se ratificaron esa misma fecha, y `Propuesto` sigue siendo el estado de salida de todo ADR nuevo mientras la Mesa no lo apruebe.

## Índice — vinculantes y propuestos

| ADR | Tema | Afecta |
|---|---|---|
| [ADR-0001](../adr/ADR-0001-gestion-documental.md) | Gestión documental del proyecto | documentación |
| [ADR-0002](../adr/ADR-0002-jira-github.md) | Jira para gestión, GitHub para desarrollo técnico | trazabilidad |
| [ADR-0003](../adr/ADR-0003-mesa-arquitectura.md) | Gobierno mediante Mesa de Arquitectura | gobierno |
| [ADR-0004](../adr/ADR-0004-cicd-multirepo-ambientes.md) | CI/CD multi-repositorio y promoción de ambientes — *enmendado el 2026-10-07; su lista de repositorios la reemplaza ADR-0028* | entrega |
| [ADR-0005](../adr/ADR-0005-devsecops.md) | DevSecOps con SAST, DAST y pruebas de API | calidad |
| [ADR-0006](../adr/ADR-0006-observabilidad.md) | Observabilidad distribuida y gestión de incidentes | RNF-04 |
| [ADR-0008](../adr/ADR-0008-diagramacion-tecnica.md) | Organización y versionado de diagramas técnicos — *absorbe el antiguo ADR-0020* | documentación |
| [ADR-0011](../adr/ADR-0011-cobertura-geografica.md) | Cobertura geográfica por zonas | RF-07 |
| [ADR-0012](../adr/ADR-0012-persistencia-multitenant.md) | Persistencia operacional y aislamiento multi-tenant | RNF-01 |
| [ADR-0013](../adr/ADR-0013-storage-kyc.md) | Almacenamiento de documentos KYC | RF-05, RF-06, REST-02 |
| [ADR-0015](../adr/ADR-0015-pruebas-aislamiento-multitenant.md) | Pruebas automatizadas de aislamiento multi-tenant | RNF-01 |
| [ADR-0016](../adr/ADR-0016-despacho-concurrencia.md) | Despacho broadcast y exclusión concurrente — *absorbe el antiguo ADR-0021; evidencia en PoC-001* | RF-14, RNF-03, RNF-05 |
| [ADR-0017](../adr/ADR-0017-realtime-notificaciones.md) | Mensajería en tiempo real y notificaciones push | RF-20, RF-21 |
| [ADR-0018](../adr/ADR-0018-identificacion-tenant.md) | Identificación y propagación segura del tenant | RNF-01 |
| [ADR-0019](../adr/ADR-0019-arquitectura-soa-poliglota.md) | Arquitectura SOA distribuida, multi-tenant y políglota | PROY-07 |
| [ADR-0022](../adr/ADR-0022-logica-de-negocio-en-servicios.md) | La lógica de negocio vive en los servicios; se retira de Flutter y de las funciones PL/pgSQL | RF-05, RF-06, RF-08, RF-10, RF-11, RF-12, RNF-01 |
| [ADR-0024](../adr/ADR-0024-modelo-custodia-pagos.md) | Modelo de custodia de pagos: el dinero lo custodia un operador regulado y MANI gestiona el estado — *absorbe el antiguo ADR-0023, con su análisis regulatorio* | RF-24, RF-25, RNF-06, RNF-11 |
| [ADR-0025](../adr/ADR-0025-integracion-jira-github.md) | Integración Jira–GitHub con GitHub for Atlassian y convención `[SCRUM-<id>]` | trazabilidad |
| [ADR-0027](../adr/ADR-0027-alcance-supabase-cliente-flutter.md) | Alcance de `supabase_flutter`: solo Auth y Realtime; retiro de PostgREST, RPC y Storage | RNF-01 |
| [ADR-0028](../adr/ADR-0028-nombres-repositorios-y-ambientes.md) | Nombres de los repositorios y de los ambientes | PROY-07, PROY-08 |
| [ADR-0029](../adr/ADR-0029-comunicacion-asincrona-kafka.md) | Comunicación asíncrona con Kafka | RNF-03 |
| [ADR-0030](../adr/ADR-0030-propiedad-esquema-y-frontera-de-datos.md) | Propiedad del esquema y frontera de datos entre servicios | RNF-01 |
| [ADR-0031](../adr/ADR-0031-politica-configuracion-jwt-ambientes.md) | Configuración, validación perimetral y propagación de JWT por ambiente — *enmendado el 2026-10-21 para aceptar ES256 verificado con el JWKS de Supabase* | RNF-01 |
| [ADR-0032](../adr/ADR-0032-identidad-de-servicio-en-base-de-datos.md) | Identidad de servicio en base de datos | RNF-01 |
| [ADR-0034](../adr/ADR-0034-contrato-comun-proveedores-externos.md) | Contrato y política comunes para proveedores externos de pagos y notificaciones — `Propuesto` | RF-20, RF-24 |
| [ADR-0035](../adr/ADR-0035-frontera-de-asignacion-6a.md) | Frontera de la asignación: Dispatch decide y Core escribe (decisión 6A) — `Propuesto`; reemplazaría la fila de `AliadoAsignado` en [ADR-0029](../adr/ADR-0029-comunicacion-asincrona-kafka.md) §1 si la Mesa lo aprueba | RF-14, RNF-03, RNF-05 |

## Índice — descartado

| ADR | Tema |
|---|---|
| [ADR-0014](../adr/ADR-0014-feature-toggle.md) | Feature Toggle como mecanismo de diferencias por tenant |

## Dos cambios del 2026-10-23 que hay que conocer

### Los diez ADR que estaban en `Propuesto` pasaron a `Aceptado`

Fueron ADR-0013, 0015, 0016, 0017, 0022, 0025, 0028, 0029, 0030 y 0032. La ratificación la decidió la Scrum Master (Sara Albarracín) en la consolidación documental, **sin sesión de Mesa de Arquitectura registrada**, que es lo que el apartado «Decisión» de ADR-0003 exige para una decisión estructural. Cada ADR lo declara en su cabecera, en el campo `Ratificación`, para que la Mesa pueda confirmarlo o revertirlo.

Esto importa porque varios ya se usaban como si fueran vinculantes: ADR-0030 es la fuente de los criterios transversales T1, T2 y T3 del [backlog §6.2](../../05-backlog/BACKLOG_MANI.md#62-criterios-transversales), y ADR-0022 gobierna la migración completa de la lógica de negocio.

#### Qué tiene que decidir la Mesa — material de TEC-12

TEC-12 (SCRUM-1459) reunió lo que la Mesa necesita para **confirmar o revertir** ADR-0030 y ADR-0016, las dos más comprometidas porque el código fusionado ya las cumple. La ratificación es un acto de la Mesa: esto es el material, no la ratificación. Registrado como pendiente P7 en [`SAD.md`](../SAD.md) §7.4.

La alternativa a ratificar **no** es «no aceptar en abstracto», es revertir código que está en `develop` y en `release`:

| Si la Mesa | Entonces |
|---|---|
| Ratifica | Se retira de los dos ADR la nota de «sin sesión de Mesa» y se cierra TEC-12. Nada cambia en código |
| Revierte ADR-0030 | Hay que rehacer la frontera de datos de Dispatch, que hoy consume la elegibilidad por HTTP y no tiene acceso SQL al dominio de Core |
| Revierte ADR-0016 | Hay que rehacer la aceptación atómica y revisar los permisos que dependen de ella, incluida la frontera de la decisión 6A |

Evidencia de que el código ya los cumple, verificada contra `origin/develop` el 2026-10-27 leyendo el código, no las historias:

- **ADR-0030.** Dispatch consume la elegibilidad por HTTP: `Infrastructure/Core/CoreAllyClient.cs` implementa `Application/Interfaces/IAllyRepository.cs` y **no existe `PostgresAllyRepository`**. Los únicos `UPDATE solicitud` de `MANI-.NET` están en fixtures de prueba. La frontera está aplicada en el motor: `MANI-Node/db/migrations/0019_frontera_asignacion_6a.sql` revoca el `UPDATE` sobre `solicitud` al rol de Dispatch y retira la política de escritura directa, dejándole solo `SELECT` para `assignments/me`. Y toda la serie `db/migrations/` vive en `MANI-Node`, que es el dueño que nombra ADR-0030 §1.
- **ADR-0016.** `PgSolicitudAsignacionRepository` de `MANI-Node` bloquea la fila con `FOR UPDATE` y repite el predicado `estado = 'PENDIENTE' AND aliado_id IS NULL` en el `UPDATE`, que hace de versión de la fila; las aceptaciones posteriores reciben `MANI-SOL-409` o `MANI-SOL-409E`. Hay medición, no solo diseño: PoC-001 (`07-calidad/PoC/PoC-001-exclusion-concurrente-aceptacion.md`) obtuvo 1 asignación y 0 dobles sobre 50 aceptaciones simultáneas —un 200 y 49 respuestas 409— mientras el control negativo produjo 10 asignaciones en 136 ms.

Dos cosas que conviene corregir en la misma sesión: **ADR-0016 no declara autor ni revisor**, y **ADR-0030 declara autor (Sara Albarracín) pero no revisor**, cuando ADR-0003 pide autor y revisor distintos donde aplique; para una decisión estructural, el revisor debería ser alguien distinto de quien la ratificó. Y una que ratificar no borra: **ADR-0016 declara como deuda técnica la cola de reintento ante caída de la base de datos**, que conviene registrar como tal en el acta para que no se lea como cerrada.

Para cerrar TEC-12 faltan: la sesión de Mesa que confirme o revierta las dos decisiones; retirar de ambos ADR la nota de «sin sesión de Mesa registrada» si se confirman; declarar autor y revisor en ADR-0016 y revisor en ADR-0030; y el cierre con la subtarea QA-TEC-12 (Santiago). Mientras la sesión no ocurra, **TEC-12 no está cumplido**, porque su criterio de aceptación es que las dos decisiones se ratifiquen o que se revierta el código que ya las cumple.

ADR-0032 está en la misma situación y lleva su propio material de Mesa, con las preguntas M1 a M8, en el apartado «Pendiente de Mesa» de [ADR-0032](../adr/ADR-0032-identidad-de-servicio-en-base-de-datos.md).

### Los seis ADR `Superseded` se retiraron del repositorio

| Retirado | Tema | Dónde quedó su contenido |
|---|---|---|
| `ADR-0007` | Documentación técnica en repositorio | Consolidado en [ADR-0001](../adr/ADR-0001-gestion-documental.md), que lo declara en su cabecera |
| `ADR-0009` | Política de uso de IA | No era decisión de arquitectura: la política viva es [`POLITICAS_DEVOPS_HERRAMIENTAS.md` §18](../../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md#18-política-de-uso-de-ia), recogida en [Trabajo con asistentes de IA](../../04-proceso/trabajo-con-ia.md). Su «sustituto» declarado, `docs/governance/POLITICA_USO_IA.md`, nunca existió |
| `ADR-0010` | Tech Radar como ADR | Es un artefacto vivo, no una decisión: [`TECH_RADAR.md`](../TECH_RADAR.md) |
| `ADR-0020` | Herramientas de documentación visual | Absorbido por [ADR-0008](../adr/ADR-0008-diagramacion-tecnica.md); las herramientas concretas son parte del Tech Radar |
| `ADR-0021` | Exclusión concurrente en despacho | Absorbido por [ADR-0016](../adr/ADR-0016-despacho-concurrencia.md), que ahora cita la evidencia de PoC-001 |
| `ADR-0023` | Riesgo regulatorio en la custodia de pagos de EP-07 | Su análisis regulatorio completo (art. 316 del Código Penal, Decreto 1981 de 1988, Ley 1581 de 2012) se trasladó íntegro al contexto de [ADR-0024](../adr/ADR-0024-modelo-custodia-pagos.md) |

Los cinco primeros eran lápidas de 10 a 14 líneas, sin decisión propia: solo declaraban su sustituto. ADR-0023 sí tenía contenido, y por eso se absorbió antes de retirarlo.

Los retiros cumplen la regla 8: cada decisión vive íntegra en el ADR que la absorbe, que lo declara en su cabecera. El texto original de los seis sigue recuperable en el historial de git y en las copias congeladas de [`Entregas/`](../../../Entregas/README.md).

## Numeración

Los números **no son contiguos y no se reutilizan**. Ocho números libres, por tres motivos distintos:

| Hueco | Por qué |
|---|---|
| `0007`, `0009`, `0010`, `0020`, `0021`, `0023` | Retirados el 2026-10-23, ver arriba |
| `0026` | Nunca se emitió |
| `0033` | Retirado el 2026-11-02 sin llegar a Mesa. Proponía a Dispatch como productor de `SolicitudCreada`, sobre la premisa de que Dispatch persiste la solicitud. La decisión del 17-oct-2026 (Core crea la solicitud, SAD §7.2) y la decisión 6A del 26-oct (Core es el único escritor de su estado) dejaron esa premisa sin base, y el propio documento lo declaraba en su cierre. La fila de `SolicitudCreada` de ADR-0029 §1 —Core como productor— sigue vigente y nunca fue reemplazada. El texto queda en el histórico de git. |
| — | `ADR-0034` y `ADR-0035` ya están emitidos, en estado `Propuesto`. El siguiente que se emita es `ADR-0036` |

Dos avisos para no equivocarse al leer:

- Los documentos de [`Entregas/`](../../../Entregas/README.md) usaron una numeración **distinta y hoy abandonada**, en la que `ADR-0022` era «proveedor de identidad» y `ADR-0023` el cierre de KI-02 (consolidación del stack sin Azure). En el esquema vigente `ADR-0022` es la lógica de negocio en los servicios, y el antiguo `ADR-0023` era el riesgo regulatorio de la custodia de pagos. `Entregas/` es un histórico congelado y **no es fuente de verdad**.
- `ADR-0027` se emitió antes que `0024` y `0025`, así que la numeración no sigue el orden cronológico. Conserva su número porque lo referencian `CFG-35` y el commit que lo introdujo.

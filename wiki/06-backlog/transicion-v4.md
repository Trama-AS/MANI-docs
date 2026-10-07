# Transición V4

[← 06 · Backlog](README.md) · [Índice](../Home.md)

**Fuente:** [`product/BACKLOG_MANI.md`](../../product/BACKLOG_MANI.md) §1–§8.

## Fotografía de partida

Jira exportado: **250 issues** — 155 `Done`, 88 `To Do`, 2 `In Progress`, 5 `In Review`. Tipos: 61 tareas, 120 subtareas, 56 historias, 13 épicas. El CSV conserva cada issue legacy con su `Source Jira Key`, estado histórico y clasificación de transición (328 filas, 18 columnas, importable).

## Cómo se lee una clasificación

| Clasificación | Qué hacer |
|---|---|
| `PRESERVAR_HISTORICO` | No reabrir; la evidencia es válida |
| `PRESERVAR_Y_VALIDAR` | Reutilizar y validar con subtareas `-Mn` y regresión |
| `REESPECIFICAR_Y_REUTILIZAR` | Conservar código y evidencia, adaptar al requisito nuevo |
| `CONTINUAR` | Pendiente y alineada al SRS; seguir, ajustada al componente objetivo |
| `REESPECIFICAR` | Actualizar alcance antes de implementar |
| `BACKLOG_SECUNDARIO` | Útil, no requisito principal del MVP; detrás de los RF críticos |
| `POSTERGAR_INCREMENTO_2` | Pertenece a RF-24..RF-28 |
| `RETIRAR_MVP` | Fuera de alcance; se saca del MVP sin borrar historial |
| `NUEVO_DELTA_ARQUITECTURA` | Trabajo necesario por el cambio arquitectónico; crear y ejecutar |
| `NUEVO_REQUERIDO` | Hueco entre SRS y backlog legacy; crear en Jira |

## Dónde va cada tipo de trabajo

| Destino | Qué recibe | Convención |
|---|---|---|
| **EP-09** — gestión y configuración | Plataforma, repositorios, Gateway, esqueletos de servicio, identidad, CI/CD, GHCR, Compose, Kubernetes, configuración del cliente y regresión | tareas `CFG-` (23 en el backlog §4, serie no continua), más el spike `SP-05`, ya decidido |
| **EP-10** — documentación y entregables | ADR de la decisión PL/pgSQL, matriz de trazabilidad, actualización de SAD/SDD y del contexto de IA | `DOC-25 … DOC-28` |
| **Las 9 historias ya desarrolladas** | El trabajo funcional de migrar y revalidar cada caso de uso | Subtareas `US-xx-M1 … -Mn` |
| **Épicas funcionales** (EP-01, EP-02, EP-04D) | Historias que el SRS exige y el backlog legacy no cubre | `HU-N-01 … HU-N-05` |

No se crea una épica de migración aparte.

## Patrón de subtareas por historia

| Subtarea | Qué hace |
|---|---|
| `-M1` | Definir el contrato REST del caso de uso en OpenAPI |
| `-M2` | Implementar el caso de uso en el servicio destino, portando la lógica PL/pgSQL indicada |
| `-M3` | Reescribir el `*_remote_datasource.dart` contra el Gateway |
| `-M4…` | Ajustes específicos de la historia |
| última | Regresión de la historia y pruebas de aislamiento multi-tenant |

En `-M3` **sólo cambia `data/datasources`**: las interfaces de `domain/repositories` se mantienen, así que usecases, BLoC y UI quedan intactos. La arquitectura limpia ya aplicada es lo que acota el delta del cliente.

## Las nueve historias con trabajo ejecutado

| Historia | Jira | Estado | RF | Servicio destino |
|---|---|---|---|---|
| `US-02.1.1` Registro aliado persona natural | SCRUM-846 | Done | RF-05 | Core Node |
| `US-02.1.2` Registro aliado empresa | SCRUM-847 | Done | RF-05 | Core Node |
| `US-02.1.3` Aprobar/rechazar aliado | SCRUM-848 | Done | RF-06 | Core Node |
| `US-02.1.4` Declarar zona de cobertura | SCRUM-849 | Done | RF-07 | Availability Node |
| `US-02.2.1` Registro cliente persona natural | SCRUM-851 | Done | RF-08 | Core Node |
| `US-03.1.1` Crear categoría con flujo operativo | SCRUM-857 | Done | RF-10 | Core Node + Rules Java |
| `US-03.1.3` Aliado declara categorías | SCRUM-859 | In Progress | RF-11 | Core Node |
| `US-04.1.1` Crear solicitud | SCRUM-860 | Done | RF-12 | Core Node + Availability |
| `US-04.1.4` Aceptar/rechazar sin doble asignación | SCRUM-863 | Done | RF-14 | Dispatch .NET |

Subtareas adicionales fuera del patrón, por historia: revalidar aislamiento de KYC entre aliados (`US-02.1.3`) · reemplazar selección libre de zona por catálogo jerárquico con coincidencia exacta (`US-02.1.4`) · separar gestión de categoría en Core de las reglas evaluables en Rules (`US-03.1.1`) · separar creación en Core de la orquestación del despacho (`US-04.1.1`) · **decidir dónde vive la atomicidad y revalidar PoC-001**, más idempotencia y ausencia de doble asignación bajo concurrencia (`US-04.1.4`).

## Huecos del SRS que generan historias nuevas

| ID | Épica | RF | Historia | Componente |
|---|---|---|---|---|
| `HU-N-01` | EP-01 | RF-01 | Administrar tenants y su estado base | Core Node |
| `HU-N-02` | EP-01 | RF-02 / RNF-02 / REST-05 | Configurar reglas por tenant sin despliegue | Rules Java + Core Node |
| `HU-N-03` | EP-01 | RF-03 / RNF-01 | Autenticar y autorizar por tenant y rol | Supabase Auth + Gateway + servicios |
| `HU-N-04` | EP-02 | RF-04 | Recuperar contraseña de forma segura | Supabase Auth + Core Node |
| `HU-N-05` | EP-04D | RF-19 | Cerrar servicio sólo tras calificación bidireccional | Core Node |

## Cambios de alcance que ya están decididos

- **Cobertura:** catálogo jerárquico de zonas y coincidencia exacta. Sin radio ni proximidad. El trabajo existente se reutiliza adaptándolo.
- **Ranking:** no es «priorizar por comisión»; es ranking **configurable por tenant**, donde la comisión puede ser uno de varios criterios (`US-04.1.5`).
- **Geolocalización en vivo:** sale del MVP (`US-04.3.4`). Se conserva en histórico y no consume capacidad.
- **Calificaciones:** las dos historias convergen en RF-19; sin ambas calificaciones no hay cierre.
- **Pagos, escrow y disputas:** pagos y liquidación quedan en el segundo incremento. Escrow, liberación automática y reglas de disputa **no se asumen como alcance aprobado** sin decisión funcional o regulatoria.

La disposición issue por issue de las 56 historias legacy está en el documento fuente §6.

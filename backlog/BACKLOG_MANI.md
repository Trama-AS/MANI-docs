# Backlog MANI — V5

- **Versión:** V5, cierre del Sprint 4 y objetivo del Sprint 5 (último sprint)
- **Fecha:** 2026-10-20 (versión anterior: 2026-10-03, actualizada el 2026-10-06 por PO-02 y ADR-0022)
- **Proyecto Jira:** MANI (`SCRUM`)
- **Arquitectura vigente:** `Flutter → NGINX API Gateway → Core Node, Rules Java y Dispatch .NET (lógica de negocio en el servicio, límites en SAD §7.4) → Supabase/PostgreSQL`, con Supabase Auth emitiendo el token y el tenant viajando como claim. La lógica que estaba en Flutter y en las funciones PL/pgSQL se migra a los servicios (ADR-0022)

Este documento es la única fuente del backlog. Reemplaza las versiones anteriores y el inventario de transición. La sección 0 es el cierre del Sprint 4 y el plan del Sprint 5; los estados de §2 son los de Jira al 2026-10-20; las secciones 3 y 4 conservan el registro del Sprint 3.

---

## 0. Backlog V5 — cierre del Sprint 4 y objetivo del Sprint 5

- **Tarea:** [SCRUM-1245](https://maniservices.atlassian.net/browse/SCRUM-1245) (DOC4-02), subtareas [SCRUM-1290](https://maniservices.atlassian.net/browse/SCRUM-1290) y [SCRUM-1291](https://maniservices.atlassian.net/browse/SCRUM-1291).
- **Autora:** Camila Beltrán (PO). **Fecha:** 2026-10-20, al cierre del Sprint 4. **Revisión:** Scrum Master (Sara Albarracín) y QA (Santiago).
- **Contexto:** el Sprint 5 es el **último**. Las historias que entren deben terminar el producto prometido: el MVP de `SRS.md` §1.2.
- **Insumos:** matriz historia ↔ repositorios ([SCRUM-1256](https://maniservices.atlassian.net/browse/SCRUM-1256), `backlog/MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md`), criterios de aceptación y DoD ([SCRUM-1257](https://maniservices.atlassian.net/browse/SCRUM-1257), `backlog/CRITERIOS_ACEPTACION_SPRINT4.md`) e inventario funcional ([SCRUM-1260](https://maniservices.atlassian.net/browse/SCRUM-1260), `SRS.md` §7.2 y `architecture/SAD.md` §7.5).
- **Enlaces:** cada clave `SCRUM-n` de esta sección enlaza a Jira; el estado es el del tablero al 2026-10-20.

### 0.1 Estado real de los servicios al cierre del Sprint 4

Una historia cuenta como verificada solo si su subtarea QA está finalizada con evidencia. La regresión funcional, de API, E2E y de seguridad multi-tenant ([SCRUM-1267](https://maniservices.atlassian.net/browse/SCRUM-1267)) sigue en curso.

| Servicio | Verificado por QA en el Sprint 4 | Finalizado sin subtarea QA visible | Abierto |
|---|---|---|---|
| Core — Node.js | Empleado directo ([SCRUM-850](https://maniservices.atlassian.net/browse/SCRUM-850), QA [SCRUM-1306](https://maniservices.atlassian.net/browse/SCRUM-1306)), cliente empresa con sitios ([SCRUM-852](https://maniservices.atlassian.net/browse/SCRUM-852), [SCRUM-1307](https://maniservices.atlassian.net/browse/SCRUM-1307)), reglas del sitio ([SCRUM-853](https://maniservices.atlassian.net/browse/SCRUM-853), [SCRUM-1308](https://maniservices.atlassian.net/browse/SCRUM-1308)), perfil ([SCRUM-854](https://maniservices.atlassian.net/browse/SCRUM-854), [SCRUM-1309](https://maniservices.atlassian.net/browse/SCRUM-1309)), disponibilidad ([SCRUM-855](https://maniservices.atlassian.net/browse/SCRUM-855), [SCRUM-1310](https://maniservices.atlassian.net/browse/SCRUM-1310)), términos y condiciones ([SCRUM-856](https://maniservices.atlassian.net/browse/SCRUM-856), [SCRUM-1311](https://maniservices.atlassian.net/browse/SCRUM-1311)), desactivar categoría ([SCRUM-858](https://maniservices.atlassian.net/browse/SCRUM-858), [SCRUM-1312](https://maniservices.atlassian.net/browse/SCRUM-1312)), creación de solicitud ([SCRUM-1072](https://maniservices.atlassian.net/browse/SCRUM-1072), [SCRUM-1330](https://maniservices.atlassian.net/browse/SCRUM-1330)) | Aliado empresa ([SCRUM-1063](https://maniservices.atlassian.net/browse/SCRUM-1063)), aprobar o rechazar aliado ([SCRUM-1066](https://maniservices.atlassian.net/browse/SCRUM-1066)), gestión de categoría ([SCRUM-1069](https://maniservices.atlassian.net/browse/SCRUM-1069)) | Zonas de cobertura ([SCRUM-1067](https://maniservices.atlassian.net/browse/SCRUM-1067), [SCRUM-1068](https://maniservices.atlassian.net/browse/SCRUM-1068)) |
| Rules — Java | Reglas de categoría ([SCRUM-1070](https://maniservices.atlassian.net/browse/SCRUM-1070), [SCRUM-1329](https://maniservices.atlassian.net/browse/SCRUM-1329)) | — | — |
| Dispatch — .NET | Aliados válidos ([SCRUM-861](https://maniservices.atlassian.net/browse/SCRUM-861), [SCRUM-1313](https://maniservices.atlassian.net/browse/SCRUM-1313)), filtro por tipo ([SCRUM-862](https://maniservices.atlassian.net/browse/SCRUM-862), [SCRUM-1314](https://maniservices.atlassian.net/browse/SCRUM-1314)), orquestación ([SCRUM-1073](https://maniservices.atlassian.net/browse/SCRUM-1073), [SCRUM-1331](https://maniservices.atlassian.net/browse/SCRUM-1331)), aceptar sin doble asignación ([SCRUM-1074](https://maniservices.atlassian.net/browse/SCRUM-1074), [SCRUM-1332](https://maniservices.atlassian.net/browse/SCRUM-1332)) | — | — |
| App Flutter | Registro de empresa vía Gateway ([SCRUM-1060](https://maniservices.atlassian.net/browse/SCRUM-1060), [SCRUM-1328](https://maniservices.atlassian.net/browse/SCRUM-1328)) | — | — |

Para [SCRUM-1063](https://maniservices.atlassian.net/browse/SCRUM-1063), [SCRUM-1066](https://maniservices.atlassian.net/browse/SCRUM-1066) y [SCRUM-1069](https://maniservices.atlassian.net/browse/SCRUM-1069) se debe enlazar la evidencia de QA o crear su subtarea (pendiente PE4 de `CRITERIOS_ACEPTACION_SPRINT4.md`); hasta entonces este backlog no las declara aceptadas.

Del MVP **falta el ciclo del servicio después de la asignación** (cotización, ejecución, calificación y cierre), la **comunicación** y el **tarifario con su reporte**.

### 0.2 Objetivo del Sprint 5

> Cerrar de punta a punta el ciclo del servicio del MVP —de la solicitud aceptada a la cotización, la ejecución, la calificación y el cierre—, con tarifario de referencia y notificaciones, cada historia verificada por QA con evidencia y sin deuda técnica abierta.

### 0.3 Prioridades del Sprint 5

**P0 — Cierre del flujo principal.** Sin ellas no existe el producto prometido. Se comprometen completas.

| Clave | Historia | Estado | RF | Repo principal | Otros repos | Responsable |
|---|---|---|---|---|---|---|
| [SCRUM-1067](https://maniservices.atlassian.net/browse/SCRUM-1067) + [SCRUM-1068](https://maniservices.atlassian.net/browse/SCRUM-1068) | Catálogo jerárquico de zonas y zona de cobertura | Por hacer / Bloqueada | RF-07 | Core | Front, GW | Nicolás León |
| [SCRUM-885](https://maniservices.atlassian.net/browse/SCRUM-885) | Cargar tabla de tarifas por categoría | Por hacer | RF-22 | Rules | Core, Front, GW | Por asignar |
| [SCRUM-865](https://maniservices.atlassian.net/browse/SCRUM-865) | Cotización con mano de obra y materiales | Por hacer | RF-15 | Core | Rules, Front, GW | Por asignar |
| [SCRUM-867](https://maniservices.atlassian.net/browse/SCRUM-867) | Cliente acepta, rechaza o ajusta la cotización | Por hacer | RF-17 | Core | Front, GW | Por asignar |
| [SCRUM-868](https://maniservices.atlassian.net/browse/SCRUM-868) | Marcar inicio y fin de la ejecución | Por hacer | RF-18 | Core | Front, GW | Por asignar |
| [SCRUM-869](https://maniservices.atlassian.net/browse/SCRUM-869) | Registrar eventos durante la ejecución | Por hacer | RF-18 | Core | Front, GW | Por asignar |
| [SCRUM-874](https://maniservices.atlassian.net/browse/SCRUM-874) | Cliente califica al aliado | Bloqueada | RF-19 | Core | Front, GW | Juan Sebastián Álvarez |
| [SCRUM-875](https://maniservices.atlassian.net/browse/SCRUM-875) | Aliado califica al cliente | Bloqueada | RF-19 | Core | Front, GW | José Nicolás Álvarez |
| [SCRUM-884](https://maniservices.atlassian.net/browse/SCRUM-884) | Notificaciones push del ciclo del servicio | Por hacer | RF-21 | Core | Front, GW | Por asignar |

**P1 — Completan el MVP prometido.** Entran después de las P0. Si alguna no termina, se declara en la Review con su razón; no se cierra a medias.

| Clave | Historia | Estado | RF | Repo principal | Otros repos |
|---|---|---|---|---|---|
| [SCRUM-866](https://maniservices.atlassian.net/browse/SCRUM-866) | Alerta de tarifa bidireccional | Bloqueada | RF-16 | Rules | Core, Front, GW |
| [SCRUM-886](https://maniservices.atlassian.net/browse/SCRUM-886) | Ver tarifa de referencia al cotizar | Por hacer | RF-16, RF-22 | Core | Rules, Front, GW |
| [SCRUM-887](https://maniservices.atlassian.net/browse/SCRUM-887) | Reporte de cotizaciones fuera de rango | Por hacer | RF-23 | Core | Front, GW |
| [SCRUM-870](https://maniservices.atlassian.net/browse/SCRUM-870) | Cliente consulta el log del servicio | Por hacer | RF-18 | Core | Front, GW |
| [SCRUM-881](https://maniservices.atlassian.net/browse/SCRUM-881) | Mensajería cliente-aliado por servicio | Por hacer | RF-20 | Core | Front, GW |
| [SCRUM-882](https://maniservices.atlassian.net/browse/SCRUM-882) | Notificaciones de mensajes nuevos | Por hacer | RF-21 | Core | Front, GW |
| [SCRUM-864](https://maniservices.atlassian.net/browse/SCRUM-864) | Priorizar por comisión ofrecida | Por hacer | RF-13 | Rules | Disp, GW |
| Nueva | Recuperar contraseña | Sin historia | RF-04 | GW (Supabase Auth) | Front |

**No entran en el Sprint 5.**

| Grupo | Historias | Razón |
|---|---|---|
| Backlog secundario (PO-02, §2.1) | [SCRUM-872](https://maniservices.atlassian.net/browse/SCRUM-872), [SCRUM-873](https://maniservices.atlassian.net/browse/SCRUM-873), [SCRUM-876](https://maniservices.atlassian.net/browse/SCRUM-876), [SCRUM-877](https://maniservices.atlassian.net/browse/SCRUM-877), [SCRUM-878](https://maniservices.atlassian.net/browse/SCRUM-878), [SCRUM-879](https://maniservices.atlassian.net/browse/SCRUM-879), [SCRUM-880](https://maniservices.atlassian.net/browse/SCRUM-880) | Siguen fuera del compromiso del MVP. El SRS V5 les dio requisito (RF-32 a RF-36, prioridad Media) para que queden trazables; su implementación va después del MVP. [SCRUM-878](https://maniservices.atlassian.net/browse/SCRUM-878) sigue a [SCRUM-877](https://maniservices.atlassian.net/browse/SCRUM-877). |
| Incremento 2 | [SCRUM-871](https://maniservices.atlassian.net/browse/SCRUM-871) y [SCRUM-888](https://maniservices.atlassian.net/browse/SCRUM-888) a [SCRUM-901](https://maniservices.atlassian.net/browse/SCRUM-901) | [SCRUM-871](https://maniservices.atlassian.net/browse/SCRUM-871) (rastreo en vivo) se asignó al Incremento 2 el 17-oct (decisión SM/PO); pagos, quejas, comercialización y métricas ya estaban ahí (§2.1). |
| Depende de quejas | [SCRUM-883](https://maniservices.atlassian.net/browse/SCRUM-883) | Consultar la conversación para atender una queja requiere quejas (RF-26), que son del Incremento 2. |
| Sin historia | RF-01 Gestión de tenants | El alta de tenants existe desde la configuración inicial; la administración de tenants ([SCRUM-901](https://maniservices.atlassian.net/browse/SCRUM-901)) es del Incremento 2. |

**Carga.** Las P0 nuevas suman 47 SP más la migración de zonas, y las P1, 42 SP. La asignación se decide en el Planning; en el Sprint 4, Nicolás León tuvo 12 de las 17 historias, así que conviene repartir las nuevas.

### 0.4 Dependencias

| Historia | Depende de | Motivo |
|---|---|---|
| [SCRUM-865](https://maniservices.atlassian.net/browse/SCRUM-865) | Pendiente P1 del SAD §7.4 | Quién es dueño del estado de la solicitud después de la asignación (Core o Dispatch). Responsable: Juan Sebastián Álvarez. Se cierra el primer día del sprint. |
| [SCRUM-885](https://maniservices.atlassian.net/browse/SCRUM-885) | Pendiente P2 del SAD §7.4 | Qué servicio escribe el tarifario (RF-22). Responsables: equipos de Rules y Core. |
| [SCRUM-867](https://maniservices.atlassian.net/browse/SCRUM-867) | [SCRUM-865](https://maniservices.atlassian.net/browse/SCRUM-865) | No hay qué aceptar sin cotización. |
| [SCRUM-868](https://maniservices.atlassian.net/browse/SCRUM-868), [SCRUM-869](https://maniservices.atlassian.net/browse/SCRUM-869) | [SCRUM-867](https://maniservices.atlassian.net/browse/SCRUM-867) | La ejecución empieza con la cotización aceptada. |
| [SCRUM-874](https://maniservices.atlassian.net/browse/SCRUM-874), [SCRUM-875](https://maniservices.atlassian.net/browse/SCRUM-875) | [SCRUM-868](https://maniservices.atlassian.net/browse/SCRUM-868) | Se califica al terminar la ejecución; el servicio no cierra hasta que ambas partes califiquen (RF-19). |
| [SCRUM-866](https://maniservices.atlassian.net/browse/SCRUM-866), [SCRUM-886](https://maniservices.atlassian.net/browse/SCRUM-886) | [SCRUM-885](https://maniservices.atlassian.net/browse/SCRUM-885), [SCRUM-865](https://maniservices.atlassian.net/browse/SCRUM-865) | Se compara la cotización contra el tarifario. |
| [SCRUM-887](https://maniservices.atlassian.net/browse/SCRUM-887) | [SCRUM-866](https://maniservices.atlassian.net/browse/SCRUM-866) | El reporte agrupa las cotizaciones fuera de rango. |
| [SCRUM-882](https://maniservices.atlassian.net/browse/SCRUM-882) | [SCRUM-881](https://maniservices.atlassian.net/browse/SCRUM-881) | Notifica mensajes nuevos. |
| [SCRUM-884](https://maniservices.atlassian.net/browse/SCRUM-884), [SCRUM-882](https://maniservices.atlassian.net/browse/SCRUM-882) | ADR-0030 | Las notificaciones push las emite Core; en QA son simuladas. |
| [SCRUM-1068](https://maniservices.atlassian.net/browse/SCRUM-1068) | [SCRUM-1067](https://maniservices.atlassian.net/browse/SCRUM-1067) | La zona se declara sobre el catálogo jerárquico. |

### 0.5 Criterios de aceptación y DoD

- **[SCRUM-1067](https://maniservices.atlassian.net/browse/SCRUM-1067) y [SCRUM-1068](https://maniservices.atlassian.net/browse/SCRUM-1068):** aplican sus criterios de `backlog/CRITERIOS_ACEPTACION_SPRINT4.md` y los CC/CA de Jira.
- **Historias nuevas del Sprint 5:** no entran al sprint sin criterios C1 (positivo), C2 (negativo) y C3 (regla crítica), redactados por el PO a partir del RF y revisados por QA (DoR). Mínimo exigido:

| Historia | C1 mínimo | C3 regla crítica |
|---|---|---|
| [SCRUM-865](https://maniservices.atlassian.net/browse/SCRUM-865) | El aliado asignado cotiza con mano de obra y materiales separados. | Solo el aliado asignado cotiza esa solicitud. |
| [SCRUM-867](https://maniservices.atlassian.net/browse/SCRUM-867) | El cliente acepta, rechaza o pide ajuste, y la solicitud cambia de estado. | Un cliente no decide sobre cotizaciones de otro cliente o tenant. |
| [SCRUM-868](https://maniservices.atlassian.net/browse/SCRUM-868), [SCRUM-869](https://maniservices.atlassian.net/browse/SCRUM-869) | El aliado marca inicio y fin, y registra eventos con fecha y hora. | Solo el aliado asignado registra la ejecución; los eventos no se editan. |
| [SCRUM-874](https://maniservices.atlassian.net/browse/SCRUM-874), [SCRUM-875](https://maniservices.atlassian.net/browse/SCRUM-875) | Cada parte califica una vez al terminar la ejecución. | El servicio no cierra hasta que ambas partes califiquen (RF-19). |
| [SCRUM-884](https://maniservices.atlassian.net/browse/SCRUM-884) | Cada cambio de estado del servicio genera su notificación. | Un fallo de push no revierte la operación (QAS-02). |
| [SCRUM-885](https://maniservices.atlassian.net/browse/SCRUM-885) | El administrador del tenant carga rangos de tarifa por categoría. | El tarifario del tenant A no se aplica al tenant B. |

- **DoD:** `wiki/05-proceso/dor-y-dod.md` con los añadidos decididos por QA; subtarea QA de la historia finalizada con los IDs de casos de la matriz de pruebas; PR enlazado en Jira; aceptación funcional del PO. Ninguna historia se declara aceptada sin esa evidencia.

### 0.6 Pruebas y deuda técnica

El Sprint 5 entrega las pruebas. Antes de cualquier historia nueva se termina la regresión del Sprint 4 ([SCRUM-1267](https://maniservices.atlassian.net/browse/SCRUM-1267)) y se completa la evidencia de [SCRUM-1063](https://maniservices.atlassian.net/browse/SCRUM-1063), [SCRUM-1066](https://maniservices.atlassian.net/browse/SCRUM-1066) y [SCRUM-1069](https://maniservices.atlassian.net/browse/SCRUM-1069). No se deja deuda técnica abierta: lo que no cumpla el DoD vuelve a desarrollo.

### 0.7 Riesgos

| Riesgo | Impacto | Mitigación |
|---|---|---|
| Las P0 nuevas (47 SP) son casi todo el ciclo del servicio en un solo sprint. | No cerrar el MVP. | Comprometer solo las P0; las P1 entran si hay capacidad. Repartir la carga desde el Planning. |
| Los pendientes P1 y P2 del SAD §7.4 siguen abiertos. | Bloquean cotización y tarifario. | Cerrarlos el primer día del sprint. |
| La regresión del Sprint 4 ([SCRUM-1267](https://maniservices.atlassian.net/browse/SCRUM-1267)) no ha terminado. | Defectos que se arrastran al último sprint. | Terminarla antes de las historias nuevas. |
| [SCRUM-1063](https://maniservices.atlassian.net/browse/SCRUM-1063), [SCRUM-1066](https://maniservices.atlassian.net/browse/SCRUM-1066) y [SCRUM-1069](https://maniservices.atlassian.net/browse/SCRUM-1069) no tienen evidencia de QA visible. | Historias finalizadas sin evidencia comprobable. | Enlazar la evidencia o crear su subtarea QA. |
| [SCRUM-874](https://maniservices.atlassian.net/browse/SCRUM-874), [SCRUM-875](https://maniservices.atlassian.net/browse/SCRUM-875) y [SCRUM-866](https://maniservices.atlassian.net/browse/SCRUM-866) llevan bloqueadas desde sprints anteriores. | Calificación y alertas sin avanzar. | Sus dependencias quedan explícitas en §0.4. |

### 0.8 Decisiones para el Planning

1. Confirmar el objetivo del Sprint 5 (§0.2).
2. Crear la historia de **recuperar contraseña** (RF-04) como P1.
3. Confirmar que el backlog secundario (RF-32 a RF-36) queda fuera del Sprint 5.
4. Asignar responsables de las P0 nuevas, repartiendo la carga.
5. Cerrar los pendientes P1 y P2 del SAD §7.4 el primer día del sprint.

---


## 1. Épicas

| Épica | Clave | Nombre | Historias |
|---|---|---|---|
| `EP-01` | `SCRUM-441` | Plataforma multi-tenant | — (transversal / sin historias) |
| `EP-02` | `SCRUM-442` | Directorio de actores | 11 |
| `EP-03` | `SCRUM-443` | Catalogo y cobertura | 3 |
| `EP-04A` | `SCRUM-444` | Ciclo del servicio: solicitud y asignacion | 5 |
| `EP-04B` | `SCRUM-445` | Ciclo del servicio: cotizacion | 3 |
| `EP-04C` | `SCRUM-446` | Ciclo del servicio: ejecucion y trazabilidad | 6 |
| `EP-04D` | `SCRUM-447` | Ciclo del servicio: calificacion y cierre | 7 |
| `EP-05` | `SCRUM-448` | Comunicacion | 4 |
| `EP-06` | `SCRUM-449` | Tarifario | 3 |
| `EP-07` | `SCRUM-450` | Pagos y facturacion | 7 |
| `EP-08` | `SCRUM-451` | Operacion y comercializacion | 7 |
| `EP-09` | `SCRUM-452` | Gestion y configuracion del proyecto | — (transversal / sin historias) |
| `EP-10` | `SCRUM-453` | Documentacion de arquitectura y entregables academicos | — (transversal / sin historias) |

`EP-09` y `EP-10` no tienen historias de usuario: agrupan las tareas de configuración, plataforma y documentación del sprint (§4).

---

## 2. Historias por épica

La columna **Migración** indica qué historia nueva rehace a una cerrada bajo la arquitectura vigente (§3).

### EP-02 — Directorio de actores

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-02.1.1` | `SCRUM-846` | Registro aliado persona natural | Done | Highest | 3.0 | `US-02.1.1-M3`, `US-02.1.1-M4`, `US-02.1.1-M2` |
| `US-02.1.2` | `SCRUM-847` | Registro aliado empresa | Done | Medium | 3.0 | `US-02.1.2-M3`, `US-02.1.2-M2` |
| `US-02.1.3` | `SCRUM-848` | Aprobar/rechazar registro de aliado | Done | Medium | 5.0 | `US-02.1.3-M2` |
| `US-02.1.4` | `SCRUM-849` | Declarar zona de cobertura | Done | High | 5.0 | `US-02.1.4-R1`, `US-02.1.4-M2` |
| `US-02.1.5` | `SCRUM-850` | Registrar empleado directo | Done | Medium | 3.0 | — |
| `US-02.1.6` | `SCRUM-855` | Aliado gestiona su disponibilidad | Done | Medium | 3.0 | — |
| `US-02.2.1` | `SCRUM-851` | Registro cliente persona natural | Done | Highest | 3.0 | `US-02.2.1-M2` |
| `US-02.2.2` | `SCRUM-852` | Cliente empresa con múltiples sitios | Done | Medium | 8.0 | — |
| `US-02.2.3` | `SCRUM-853` | Reglas contextuales del sitio visibles al aliado | Done | Medium | 5.0 | — |
| `US-02.3.1` | `SCRUM-854` | Editar perfil propio | Done | Medium | 2.0 | — |
| `US-02.3.2` | `SCRUM-856` | Aceptación de Términos y Condiciones | Done | Low | 8.0 | — |

### EP-03 — Catalogo y cobertura

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-03.1.1` | `SCRUM-857` | Crear categoría con flujo operativo | Done | Highest | 5.0 | `US-03.1.1-M2`, `US-03.1.1-M6` |
| `US-03.1.2` | `SCRUM-858` | Desactivar categoría sin afectar en curso | Done | High | 8.0 | — |
| `US-03.1.3` | `SCRUM-859` | Aliado declara categorías que atiende | Done | Medium | 3.0 | `US-03.1.3-M2` |

### EP-04A — Ciclo del servicio: solicitud y asignacion

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-04.1.1` | `SCRUM-860` | Crear solicitud | Done | Highest | 3.0 | `US-04.1.1-M2`, `US-04.1.1-M6` |
| `US-04.1.2` | `SCRUM-861` | Ver aliados válidos por cobertura y categoría | Done | High | 5.0 | — |
| `US-04.1.3` | `SCRUM-862` | Filtrar por tipo de aliado | Done | High | 5.0 | — |
| `US-04.1.4` | `SCRUM-863` | Aceptar/rechazar solicitud sin doble asignación | Done | Highest | 5.0 | `US-04.1.4-M6` |
| `US-04.1.5` | `SCRUM-864` | Priorizar por comisión ofrecida | To Do | Medium | 2.0 | — |

### EP-04B — Ciclo del servicio: cotizacion

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-04.2.1` | `SCRUM-865` | Cotización con mano de obra y materiales separados | To Do | High | 8.0 | — |
| `US-04.2.2` | `SCRUM-866` | Alerta de tarifa bidireccional | Blocked | High | 5.0 | — |
| `US-04.2.3` | `SCRUM-867` | Cliente acepta/rechaza/ajusta cotización | To Do | Medium | 8.0 | — |

### EP-04C — Ciclo del servicio: ejecucion y trazabilidad

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-04.3.1` | `SCRUM-868` | Marcar inicio/fin de ejecución | To Do | High | 2.0 | — |
| `US-04.3.2` | `SCRUM-869` | Registrar eventos durante la ejecución | To Do | High | 8.0 | — |
| `US-04.3.3` | `SCRUM-870` | Cliente consulta el log del servicio | To Do | Medium | 8.0 | — |
| `US-04.3.4` | `SCRUM-871` | Cliente rastrea ubicación del aliado en vivo | To Do | High | 5.0 | — |
| `US-04.3.5` | `SCRUM-872` | Aliado solicita adición por imprevisto | To Do | High | 8.0 | — |
| `US-04.3.6` | `SCRUM-873` | Registrar evidencias sin conexión (Offline) | To Do | High | 5.0 | — |

### EP-04D — Ciclo del servicio: calificacion y cierre

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-04.4.1` | `SCRUM-874` | Cliente califica al aliado | Blocked | High | 8.0 | — |
| `US-04.4.2` | `SCRUM-875` | Aliado califica al cliente | Blocked | Medium | 3.0 | — |
| `US-04.4.3` | `SCRUM-876` | Calificación agregada visible en el listado | To Do | High | 3.0 | — |
| `US-04.5.1` | `SCRUM-877` | Cancelar solicitud antes de la ejecución | To Do | High | 8.0 | — |
| `US-04.5.2` | `SCRUM-878` | Penalización por cancelación tardía | To Do | High | 3.0 | — |
| `US-04.6.1` | `SCRUM-879` | Consultar historial de servicios | To Do | Medium | 3.0 | — |
| `US-04.6.2` | `SCRUM-880` | Aliado consulta historial de trabajos | To Do | High | 8.0 | — |

### EP-05 — Comunicacion

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-05.1.1` | `SCRUM-881` | Mensajería cliente-aliado por servicio | To Do | High | 8.0 | — |
| `US-05.1.2` | `SCRUM-882` | Notificaciones de mensajes nuevos | To Do | Medium | 8.0 | — |
| `US-05.1.3` | `SCRUM-883` | Consultar conversación para atender queja | To Do | High | 5.0 | — |
| `US-05.1.4` | `SCRUM-884` | Notificaciones push del ciclo del servicio | To Do | Medium | 8.0 | — |

### EP-06 — Tarifario

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-06.1.1` | `SCRUM-885` | Cargar tabla de tarifas por categoría | To Do | High | 2.0 | — |
| `US-06.1.2` | `SCRUM-886` | Ver tarifa de referencia al cotizar | To Do | Medium | 8.0 | — |
| `US-06.1.3` | `SCRUM-887` | Reporte de cotizaciones fuera de rango | To Do | Medium | 3.0 | — |

### EP-07 — Pagos y facturacion

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-07.1.1` | `SCRUM-888` | Pago en línea al aceptar cotización | To Do | Highest | 8.0 | — |
| `US-07.1.2` | `SCRUM-889` | Registro de transacciones (Audit Log inmutable) | To Do | Highest | 3.0 | — |
| `US-07.1.3` | `SCRUM-890` | Descargar soporte de pago | To Do | Highest | 5.0 | — |
| `US-07.1.4` | `SCRUM-891` | Retención de fondos en garantía (Escrow) | To Do | Medium | 3.0 | — |
| `US-07.1.5` | `SCRUM-892` | Liberación automática de fondos | To Do | Medium | 2.0 | — |
| `US-07.2.1` | `SCRUM-893` | Liquidación al aliado (Comisión configurable) | To Do | Medium | 8.0 | — |
| `US-07.2.2` | `SCRUM-894` | Aliado consulta detalle de pagos | To Do | Highest | 2.0 | — |

### EP-08 — Operacion y comercializacion

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-08.1.1` | `SCRUM-895` | Cliente registra queja | To Do | High | 3.0 | — |
| `US-08.1.2` | `SCRUM-896` | Tenant gestiona estado de quejas | To Do | High | 8.0 | — |
| `US-08.1.3` | `SCRUM-897` | Resolución de disputa financiera | To Do | High | 2.0 | — |
| `US-08.2.1` | `SCRUM-898` | Publicar contenido en redes conectadas | To Do | Medium | 8.0 | — |
| `US-08.2.2` | `SCRUM-899` | Registrar campañas y ver desempeño | To Do | High | 5.0 | — |
| `US-08.3.1` | `SCRUM-900` | Métricas operativas por tenant | To Do | High | 2.0 | — |
| `US-08.3.2` | `SCRUM-901` | Administrar estado de tenants | To Do | High | 8.0 | — |

### Landing comercial pública

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-09.1.1` | `SCRUM-1335` | Landing page comercial como entrada pública a la plataforma | Done | Medium | — | — |
| `US-09.1.2` | `SCRUM-1343` | Documentar la landing page y actualizar la arquitectura afectada | Done | Medium | — | — |

- **Épica.** El código `US-09` las ubica en `EP-09` (`SCRUM-452`), pero en Jira no tienen épica
  asignada; la tabla de §1 no se cambia hasta que se vinculen. Tampoco tienen puntos estimados.
- **`SCRUM-1335` es una formalización retroactiva.** El desarrollo de `MANI-Landing` existía antes
  de la historia y esta lo verifica y acredita contra sus criterios, sin volver a desarrollarlo
  (etiqueta `formalizacion-retroactiva` en Jira). Al verificarlo aparecieron tres criterios sin
  cumplir (tarifas base, rango del estimador y redirección a rutas que existen en el cliente), y
  se corrigen en `MANI-Landing#2`.
- **`SCRUM-1343`** depende de `SCRUM-1335`: documenta solo lo que esa historia acredita, en un
  único PR de `MANI-Docs`.

### 2.1 Repriorización del incremento (PO-02)

Clasificación ratificada en `PO-02` (`SCRUM-1077`) el 2026-10-06. En Jira, cada historia tiene la etiqueta
correspondiente y un comentario con la razón y la referencia al SRS.

**Incremento 2** — etiqueta `postergar-incremento-2`

| Clave | Historia | Referencia SRS |
|---|---|---|
| `SCRUM-450` | EP-07 Pagos y facturación (épica) | RF-24 a RF-28, §1.2 y §4.7 |
| `SCRUM-451` | EP-08 Operación y comercialización (épica) | RF-24 a RF-28, §1.2 y §4.7 |
| `SCRUM-888` | Pago en línea al aceptar cotización | RF-24 |
| `SCRUM-889` | Registro de transacciones (Audit Log inmutable) | RF-24, RNF-04 |
| `SCRUM-893` | Liquidación al aliado (Comisión configurable) | RF-25 |
| `SCRUM-895` | Cliente registra queja | RF-26 |
| `SCRUM-896` | Tenant gestiona estado de quejas | RF-26 |
| `SCRUM-900` | Métricas operativas por tenant | RF-28 |
| `SCRUM-901` | Administrar estado de tenants | RF-27, RF-28 |

Al postergarse las épicas `EP-07` y `EP-08`, sus demás historias tampoco entran en el incremento actual.

**Fuera del MVP** — etiqueta `retirar-mvp`

| Clave | Historia | Referencia SRS |
|---|---|---|
| `SCRUM-871` | Cliente rastrea ubicación del aliado en vivo | §1.2 "Fuera de alcance del MVP" y REST-01. Asignada al Incremento 2 el 2026-10-17 (§0.3) |

**Backlog secundario** — etiqueta `backlog-secundario`

| Clave | Historia | Razón |
|---|---|---|
| `SCRUM-862` | Filtrar por tipo de aliado | Mejora opcional; no es un RF del SRS actual |
| `SCRUM-872` | Aliado solicita adición por imprevisto | Posible evolución, no compromiso del MVP |
| `SCRUM-873` | Registrar evidencias sin conexión (Offline) | El SRS actual no exige modo offline |
| `SCRUM-876` | Calificación agregada visible en el listado | Puede alimentar el ranking (RF-13), no es RF independiente |
| `SCRUM-877` | Cancelar solicitud antes de la ejecución | Posible regla futura del ciclo del servicio |
| `SCRUM-879` | Consultar historial de servicios | Trazabilidad (RNF-04), no es RF independiente |
| `SCRUM-880` | Aliado consulta historial de trabajos | Trazabilidad (RNF-04), no es RF independiente |

**Se mantienen en el Sprint 3** por decisión del equipo (2026-10-06), aunque su clasificación es backlog
secundario: `SCRUM-854` Editar perfil propio, como tarea de desarrollo de la PO, y `SCRUM-856` Aceptación de
Términos y Condiciones. Ninguna desplaza a las historias de migración críticas.

**Ratificación de dependencias:** ninguna historia del Sprint 3 depende de las historias que salen del
incremento, y ninguna de ellas estaba en el sprint.

---

## 3. Historias cerradas rehechas sobre la arquitectura vigente

### 3.1 Por qué se rehacen

Nueve historias se cerraron con la arquitectura de las entregas 1, 2 y 3, en la que el cliente Flutter
invocaba Supabase directamente con `.rpc()`, `.from()` y `.storage.from()`:

```text
Flutter  --.rpc() / .from() / .storage.from()-->  Supabase (PostgREST)
```

Ese cierre **no acredita la arquitectura vigente**. Dos consecuencias concretas:

1. **La evidencia no sirve.** Las pruebas que cerraron esas historias ejercitaban un llamador que ya no existe.
2. **El control de aislamiento cambia de sujeto.** Con Core llamando por `service-role`, `auth.uid()` deja de
   filtrar, por lo que el aislamiento multi-tenant (riesgo *Perdida de aislamiento multi-tenant*, SAD §23) debe demostrarse de nuevo, historia por historia.

Las historias originales **no se reabren**: conservan su estado como registro histórico y quedan vinculadas
con *Relates* a la historia de migración que las reemplaza.

### 3.2 Convención de identificadores

| Sufijo | Significado |
|---|---|
| `-M2` | Implementación en el servicio destino (Core Service) |
| `-M3` | Delta del cliente Flutter: solo `data/datasources` |
| `-M4` | Regresión en QA por el Gateway más aislamiento multi-tenant |
| `-M6` | Parte que depende de un servicio políglota inexistente hoy (Rules Service, Dispatch Service, Availability) |
| `-R1` | Reespecificación funcional: el alcance anterior no se preserva |

### 3.3 Mapeo

| Historia cerrada | Estado | Clasificación | Componente destino | Historias nuevas | Fase |
|---|---|---|---|---|---|
| `SCRUM-846` · US-02.1.1 Registro aliado persona natural | Done | PRESERVAR_Y_VALIDAR | Core Service + Auth/Storage | `US-02.1.1-M3`, `US-02.1.1-M4`, `US-02.1.1-M2` | Sprint 3 |
| `SCRUM-847` · US-02.1.2 Registro aliado empresa | Done | PRESERVAR_Y_VALIDAR | Core Service + Auth/Storage | `US-02.1.2-M3`, `US-02.1.2-M2`, `US-02.1.2-M4` | Sprint 3; su `-M4` en Incremento 2 |
| `SCRUM-848` · US-02.1.3 Aprobar/rechazar registro de aliado | Done | PRESERVAR_Y_VALIDAR | Core Service | `US-02.1.3-M2` | Incremento 2 |
| `SCRUM-849` · US-02.1.4 Declarar zona de cobertura | Done | REESPECIFICAR_Y_REUTILIZAR | Core Service | `US-02.1.4-R1`, `US-02.1.4-M2` | Incremento 2 |
| `SCRUM-851` · US-02.2.1 Registro cliente persona natural | Done | PRESERVAR_Y_VALIDAR | Core Service + Auth | `US-02.2.1-M2`, `US-02.2.1-M4` | Sprint 3; su `-M4` en Incremento 2 |
| `SCRUM-857` · US-03.1.1 Crear categoría con flujo operativo | Done | PRESERVAR_Y_VALIDAR | Core Service + Rules Service | `US-03.1.1-M2`, `US-03.1.1-M6` | Incremento 2 |
| `SCRUM-859` · US-03.1.3 Aliado declara categorías que atiende | In Progress | Completar sobre el camino nuevo | Core Service / Availability | `US-03.1.3-M2` | Incremento 2 |
| `SCRUM-860` · US-04.1.1 Crear solicitud | Done | PRESERVAR_Y_VALIDAR | Core Service + Dispatch Service | `US-04.1.1-M2`, `US-04.1.1-M6` | Incremento 2 |
| `SCRUM-863` · US-04.1.4 Aceptar/rechazar solicitud sin doble asignación | Done | PRESERVAR_Y_VALIDAR | Dispatch Service + PostgreSQL | `US-04.1.4-M6` | Incremento 2 |

### 3.4 Criterio de corte Sprint 3 / Incremento 2

En el Sprint 3 solo existen dos servicios nuevos: **MANI-API-Gateway** (NGINX) y **MANI-Core-Service** (Node). Por tanto:

- **Entra al Sprint 3** la historia cuyo componente destino se resuelve con Gateway + Core (con la lógica en el servicio, ADR-0022), y que
  además reutiliza el modelo de identidad y el cliente HTTP que construye `US-02.1.1`.
- **Queda en Incremento 2** la que necesita Rules Service, Dispatch Service o Core Service. Donde hay una parte
  que Core sí sostiene hoy, la historia se **parte** (`-M2` ahora, `-M6` después) en vez de arrastrarse completa.
- `SCRUM-863` es el único caso que migra completo al Incremento 2: su valor es la exclusión concurrente en el
  servicio de despacho (riesgo *Doble asignacion* del SAD §23, ADR-0021), y no tiene porción que Core Service pueda sostener.
- `SCRUM-848` sale del Sprint 3 **por capacidad, no por dependencia técnica**: Gateway y Core ya la soportan,
  así que es la primera candidata a volver si se libera holgura.

### 3.5 Historias de migración

**Sprint 3** — 6 historias

| Código | Historia | Prioridad | SP | Reemplaza |
|---|---|---|---|---|
| `US-02.1.2-M3` | Migracion: reescribir el datasource de registro de empresa en Flutter contra el Gateway, retirando .rpc() y .storage.from() y conservando la interfaz del repositorio | High | 3 | `SCRUM-847` |
| `US-02.1.1-M3` | Migracion: reescribir auth_remote_datasource.dart contra el Gateway en lugar de SupabaseClient, conservando la interfaz de domain/repositories. | Highest | 4 | `SCRUM-846` |
| `US-02.1.1-M4` | Migracion: regresion funcional de US-02.1.1 desplegada en QA a traves del Gateway, mas las pruebas de aislamiento multi-tenant de los documentos KYC. | Highest | 4 | `SCRUM-846` |
| `US-02.1.2-M2` | Migracion: implementar el registro de aliado empresa en Core Service con la logica del registro en el servicio (ADR-0022), con el representante legal y los documentos de la empresa entrando por el Gateway | High | 4 | `SCRUM-847` |
| `US-02.2.1-M2` | Migracion: llevar el registro de cliente persona natural al camino Gateway - Core Service, incluyendo su datasource en Flutter | High | 4 | `SCRUM-851` |
| `US-02.1.1-M2` | Migracion: implementar el registro de aliado persona natural en Core Service, migrando al servicio la logica de registrar_aliado_persona_natural, handle_new_user y el upsert a usuario (ADR-0022), expuesto por el contrato OpenAPI de CFG-16. | Highest | 5 | `SCRUM-846` |

**Incremento 2** — 11 historias

| Código | Historia | Prioridad | SP | Reemplaza |
|---|---|---|---|---|
| `US-02.1.2-M4` | Migracion: regresion funcional de US-02.1.2 desplegada en QA a traves del Gateway, mas el aislamiento multi-tenant de los documentos de la empresa y del representante legal | High | 4 | `SCRUM-847` |
| `US-02.2.1-M4` | Migracion: regresion funcional de US-02.2.1 desplegada en QA a traves del Gateway, mas el aislamiento multi-tenant de los datos del cliente | High | 4 | `SCRUM-851` |
| `US-02.1.3-M2` | Migracion: aprobacion y rechazo de registro de aliado en Core Service, con la visibilidad de documentos KYC resuelta en el nuevo modelo de identidad | High | 5 | `SCRUM-848` |
| `US-02.1.4-R1` | Reespecificacion: sustituir la seleccion libre en mapa por el catalogo jerarquico de zonas | High | 5 | `SCRUM-849` |
| `US-02.1.4-M2` | Migracion: declaracion de zona de cobertura en el Core Service, persistida en `core.aliado_cobertura` | High | 5 | `SCRUM-849` |
| `US-03.1.1-M2` | Migracion: gestion de categoria en Core Service, dejando la evaluacion de reglas como frontera declarada hacia Rules | Highest | 5 | `SCRUM-857` |
| `US-03.1.1-M6` | Migracion: llevar las reglas evaluables de la categoria al Rules Service en Java | High | 5 | `SCRUM-857` |
| `US-03.1.3-M2` | Migracion: completar la asociacion aliado-categoria por el camino Gateway - Core Service | Medium | 3 | `SCRUM-859` |
| `US-04.1.1-M2` | Migracion: creacion de solicitud en Core Service, separada de la orquestacion de despacho | Highest | 3 | `SCRUM-860` |
| `US-04.1.1-M6` | Migracion: orquestacion de despacho de la solicitud en el Dispatch Service .NET | Highest | 3 | `SCRUM-860` |
| `US-04.1.4-M6` | Migracion: aceptar o rechazar solicitud sin doble asignacion, con la exclusion concurrente en Dispatch Service | Highest | 5 | `SCRUM-863` |

### 3.6 Cobertura de regresión

**Cerrado el 2026-10-07 por decisión del PO.**

La planificación original dejó regresión solo para `US-02.1.1` (`US-02.1.1-M4`): `US-02.1.2-M2/M3` y
`US-02.2.1-M2` entraban al Sprint 3 sin historia de regresión propia en QA, por lo que su pasada de
aislamiento multi-tenant no quedaba planificada.

**Decisión:** cada historia migrada tiene su propia historia de regresión. Se crean `US-02.1.2-M4` y
`US-02.2.1-M4` siguiendo la convención del §3.2, y **se programan en el Incremento 2**, no en el Sprint 3.
El motivo es que la regresión por el Gateway no es ejecutable hasta que exista la cadena de verificación:
`QA-01` a `QA-05` no están entregadas al corte de este sprint, el contrato OpenAPI de `CFG-16` no está
publicado y `CFG-20` todavía no deja el Core desplegado en DEV y QA. Adelantarlas al Sprint 3 las dejaría
bloqueadas desde el primer día.

`US-02.1.1-M4` se mantiene en el Sprint 3: es la que abre camino y define los casos que las otras dos
reutilizan.

**Consecuencia que queda explícita:** al cierre del Sprint 3, `US-02.1.2` y `US-02.2.1` quedan migradas sin
regresión propia ejecutada. Su comportamiento no puede declararse *preservado* en ese corte, solo
*construido y verificado* en los términos del plan de pruebas de `DOC-38`. La declaración de paridad de las
dos historias se emite en el Incremento 2, cuando corran sus `-M4`.

Los números de sufijo no son continuos a propósito: `US-02.2.1` no tiene `-M3` porque su `-M2` ya incluye el
delta del cliente Flutter. `-M4` significa regresión en cualquier historia, según el §3.2.
---

## 4. Tareas del Sprint 3

51 tareas. `EP-09` agrupa plataforma y calidad; `EP-10`, documentación y gestión.

### Producto y gestión del sprint

Refinamiento del backlog, aceptación del incremento y ceremonias.

| Tarea | Prioridad | PH | Épica |
|---|---|---|---|
| `PO-01` — Refinar los criterios de aceptacion de US-02.1.1 sobre el nuevo camino de arquitectura | Highest | 3 | `SCRUM-453` |
| `PO-02` — Repriorizar el backlog V4 y ratificar que sale del incremento actual | Highest | 4 | `SCRUM-453` |
| `PO-03` — Aceptar el incremento desplegado en QA | Highest | 3 | `SCRUM-453` |
| `SM-01` — Facilitar Planning, Dailies, Review y Retrospectiva y publicar el reporte de indicadores del sprint | High | 4 | `SCRUM-453` |
| `SM-02` — Registrar y escalar los bloqueos y mantener la trazabilidad Jira <-> GitHub <-> pruebas | Medium | 3 | `SCRUM-453` |
| `PO-04` — Reespecificar las historias cerradas contra la arquitectura vigente y separar lo que sale del incremento | Highest | 4 | `SCRUM-453` |
| `PO-05` — Escribir los criterios de aceptacion de las historias de migracion de EP-02 | Highest | 3 | `SCRUM-453` |
| `PO-06` — Terminar los mockups de las historias del incremento y referenciarlos en el SAD con dos imagenes | Highest | 4 | `SCRUM-453` |

### Documentación y vistas de arquitectura

Actualización documental y diagramas de las vistas.

| Tarea | Prioridad | PH | Épica |
|---|---|---|---|
| ~~`DOC-26` — Registrar en ADR la decision de SP-05~~ **CERRADA el 2026-10-07.** La decision de la daily del 2026-10-05 (la logica de negocio vive en los servicios y se retira de Flutter y de las funciones PL/pgSQL) quedo registrada en [`adr/ADR-0022`](../adr/ADR-0022-logica-de-negocio-en-servicios.md), publicado en `main`. El ADR queda en estado **Propuesto**: pasarlo a Aceptado requiere sesion formal de la Mesa (Gobierno §2.6) | Highest | 3 | `SCRUM-453` |
| `DOC-28` — Actualizar el SAD y el SDD con el resultado real de la transicion y cerrar los dos riesgos mal calibrados del SAD §23: *Logica de negocio en Flutter* y *Acceso directo indiscriminado a Supabase* | Highest | 4 | `SCRUM-453` |
| `DOC-29` — Reorganizar el repositorio de diagramas a la estructura de ADR-0008 y versionar la fuente editable | High | 2 | `SCRUM-453` |
| `DOC-30` — Rehacer las vistas C4 de contexto y de contenedores con el camino real del incremento | Highest | 3 | `SCRUM-453` |
| `DOC-31` — Diagramar la vista C4 de componentes de MANI-API-Gateway y de MANI-Core-Service | Highest | 3 | `SCRUM-453` |
| `DOC-32` — Diagramar la vista de despliegue de DEV y QA tal como queda despues de la transicion | High | 3 | `SCRUM-453` |
| `DOC-33` — Diagramar la vista de datos con el nuevo modelo de identidad y actualizar ModeloDatos | Highest | 3 | `SCRUM-453` |
| `DOC-34` — Diagramar la vista de flujos con las secuencias del camino nuevo | High | 2 | `SCRUM-453` |
| `DOC-35` — Actualizar los documentos de infraestructura y de politicas DevOps con la topologia real | High | 3 | `SCRUM-453` |
| `DOC-36` — Registrar en ADR la integracion Jira - GitHub que ADR-0002 dejo declarada como pendiente | High | 2 | `SCRUM-453` |
| `DOC-37` — Actualizar el Tech Radar y la wiki con el stack realmente desplegado en el sprint | Medium | 2 | `SCRUM-453` |
| `DOC-38` — Escribir el plan de pruebas por historia de las historias migradas del incremento | Highest | 4 | `SCRUM-453` |
| `DOC-39` — Dejar publicadas las metricas de los atributos de calidad con su valor medido en el sprint | High | 3 | `SCRUM-453` |

### Transición arquitectónica y plataforma

Repositorios, Gateway, Core, identidad, RLS, imágenes y pipeline.

| Tarea | Prioridad | PH | Épica |
|---|---|---|---|
| `CFG-37` — Resolver la estrategia de ramas de MANI-Frontend antes de migrar | Highest | 2 | `SCRUM-452` |
| `CFG-38` — Reconciliar las 13 ramas feature/fix con trabajo sin fusionar | Highest | 5 | `SCRUM-452` |
| `CFG-15` — Crear los repositorios faltantes del modelo multi-repo | Highest | 2 | `SCRUM-452` |
| `CFG-16` — Definir el contrato OpenAPI entre Gateway y Core, acotado a identidad y registro de aliado | Highest | 3 | `SCRUM-452` |
| `CFG-20` — Crear el esqueleto del Core Service en Node.js desplegable en DEV y QA | Highest | 3 | `SCRUM-452` |
| `CFG-17` — Implementar el NGINX API Gateway como entrada unica | Highest | 6 | `SCRUM-452` |
| `CFG-22` — Alinear la emision y propagacion de JWT con claims de tenant y rol entre Supabase Auth, Gateway y Core | Highest | 4 | `SCRUM-452` |
| `CFG-23a` — Disenar el modelo de identidad en base de datos porque RLS deja de filtrar por auth.uid() cuando el llamador es un servicio | Highest | 5 | `SCRUM-452` |
| `CFG-23b` — Versionar y aplicar las politicas RLS del nuevo modelo de identidad en DEV y QA | Highest | 5 | `SCRUM-452` |
| `CFG-23c` — Validar los seis casos cross-tenant contra el nuevo modelo de identidad en QA | Highest | 4 | `SCRUM-452` |
| `CFG-26` — Alinear los proyectos Supabase de DEV, QA y PROD | High | 3 | `SCRUM-452` |
| `CFG-28` — Actualizar el Docker Compose por ambiente para consumir GHCR | High | 3 | `SCRUM-452` |
| `CFG-27` — Estandarizar las imagenes OCI de Gateway y Core y publicarlas en GHCR | High | 3 | `SCRUM-452` |
| `CFG-29` — Replicar el pipeline CI/CD en MANI-API-Gateway y MANI-Core-Service con los gates de calidad | Highest | 5 | `SCRUM-452` |
| `CFG-33` — Sacar database/, docker-compose.yml, scripts/ y nginx.conf del repositorio Flutter | Highest | 4 | `SCRUM-452` |
| `CFG-34` — Construir la capa HTTP del cliente Flutter que sustituye a SupabaseClient | Highest | 6 | `SCRUM-452` |
| `CFG-35` — Decidir y aplicar que queda de supabase_flutter en el cliente | Highest | 3 | `SCRUM-452` |
| `CFG-36` — Retirar la SUPABASE_ANON_KEY del bundle web y rotarla | Highest | 3 | `SCRUM-452` |
| `CFG-39` — Conectar GitHub con Jira y dejar la trazabilidad automatica en los cuatro repositorios | Highest | 4 | `SCRUM-452` |
| `CFG-40` — Crear el proyecto SonarQube de MANI-API-Gateway y volver vinculante su Quality Gate | Highest | 3 | `SCRUM-452` |
| `CFG-41` — Crear el proyecto SonarQube de MANI-Core-Service y volver vinculante su Quality Gate | Highest | 3 | `SCRUM-452` |
| `CFG-42` — Rebaselinar el proyecto SonarQube de MANI-Frontend despues de sacar los artefactos que no le pertenecen | High | 2 | `SCRUM-452` |
| `CFG-43` — Definir los contratos entre los repositorios del modelo multi-repo | Highest | 3 | `SCRUM-452` |

### Automatización de pruebas

Herramientas de verificación, todas gratuitas y locales.

| Tarea | Prioridad | PH | Épica |
|---|---|---|---|
| `QA-01` — Montar las pruebas de integracion de Core Service sobre Postgres real levantado con Testcontainers | Highest | 4 | `SCRUM-452` |
| `QA-02` — Automatizar con Playwright el recorrido end-to-end del build web sobre el Gateway | High | 3 | `SCRUM-452` |
| `QA-03` — Dejar la coleccion Postman del contrato Gateway - Core corriendo con Newman en el pipeline | Highest | 3 | `SCRUM-452` |
| `QA-04` — Medir con k6 el camino de registro por el Gateway con 150 usuarios virtuales concurrentes | High | 3 | `SCRUM-452` |
| `QA-05` — Ejecutar el escaneo DAST con OWASP ZAP sobre el Gateway desplegado en QA | High | 3 | `SCRUM-452` |
| `QA-06` — Dejar el esqueleto de pruebas unitarias de los servicios poliglotas listo antes de que existan | Medium | 2 | `SCRUM-452` |
| `QA-07` — Construir el escaner propio de PCI-DSS que busca PAN y CVV en base de datos y en logs | Medium | 2 | `SCRUM-452` |

### 4.1 Verificación por historia

Cada historia migrada tiene su sección en el plan de pruebas (`DOC-38`) y se verifica con la herramienta que
corresponde al nivel. Todas son gratuitas, open source y corren localmente o en GitHub Actions:

| Nivel | Herramienta | Tarea | Por qué esta y no la tradicional |
|---|---|---|---|
| Integración de Core contra base real | Testcontainers + Postgres | `QA-01` | Docker levanta y destruye la base dentro de la prueba; nadie instala Postgres a mano |
| End-to-end en navegador | Playwright | `QA-02` | Espera sola a que el control esté listo y graba video del fallo; Selenium exige drivers manuales que se rompen |
| Contrato Gateway ↔ Core | Postman + Newman | `QA-03` | Es la herramienta que el equipo ya usa; Newman la corre en terminal y en CI |
| Carga y concurrencia | k6 | `QA-04` | Menos de 100 MB de memoria frente a los gigabytes de JMeter. La carga objetivo y el umbral de p95 los fija el SDD §7.4 y §8; este backlog no define umbrales propios |
| Seguridad dinámica | OWASP ZAP | `QA-05` | Estándar gratuito de DAST exigido por ADR-0005 |
| Unitarias de los servicios políglotas | JUnit 5 / xUnit | `QA-06` | Esqueleto listo antes de que Rules Service y Dispatch Service existan |
| Cumplimiento PCI-DSS | Escáner propio | `QA-07` | Busca PAN y CVV en base y logs antes de que `EP-07` entre al backlog |

Los valores medidos con estas herramientas son los que `DOC-39` publica como métricas de los atributos de
calidad P1 de ISO/IEC 25010.

---

## 5. Documentos relacionados

| Tema | Documento |
|---|---|
| Requerimientos | [`product/SRS.md`](../product/SRS.md) |
| Arquitectura | [`architecture/SAD.md`](../architecture/SAD.md) |
| Diseño detallado y vistas C4 | [`architecture/SDD.md`](../architecture/SDD.md) |
| Modelo de datos | [`architecture/ModeloDatos.md`](../architecture/ModeloDatos.md) |
| Decisiones arquitectónicas | [`adr/`](../adr/) |
| Matriz historia ↔ repositorios del Sprint 4 | [`backlog/MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md`](MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md) |
| Criterios de aceptación del Sprint 4 | [`backlog/CRITERIOS_ACEPTACION_SPRINT4.md`](CRITERIOS_ACEPTACION_SPRINT4.md) |
| Políticas DevOps y versionamiento de despliegue | [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) |

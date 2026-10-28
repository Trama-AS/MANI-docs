# Backlog MANI — V5

- **Versión:** V5, cierre del Sprint 4 y objetivo del Sprint 5 (último sprint)
- **Fecha:** 2026-10-20 (versión anterior: 2026-10-03, actualizada el 2026-10-06 por PO-02 y ADR-0022)
- **Proyecto Jira:** MANI (`SCRUM`)
- **Arquitectura vigente:** `Flutter → NGINX API Gateway → Core Node, Rules Java y Dispatch .NET (lógica de negocio en el servicio, límites en SAD §7.4) → Supabase/PostgreSQL`, con Supabase Auth emitiendo el token y el tenant viajando como claim. La lógica que estaba en Flutter y en las funciones PL/pgSQL se migra a los servicios (ADR-0022)

Este documento es la única fuente del backlog. Reemplaza las versiones anteriores y el inventario de transición. La sección 0 es el cierre del Sprint 4 y el plan del Sprint 5; los estados de §2 son los de Jira al 2026-10-20; las secciones 3 y 4 conservan el registro del Sprint 3.

**Unificación del 22 de octubre de 2026.** Se absorbieron aquí tres documentos que antes vivían sueltos en `backlog/`: los criterios de aceptación y DoD del Sprint 4 (§6), los criterios de aceptación de US-02.1.1 (§7) y el backlog técnico en GitHub con los issues propuestos (§8). La §9, nueva, cruza la cobertura de lo que falta con la verificación de lo que ya está. Los documentos originales se borraron; esta es la referencia a citar.

---

## 0. Backlog V5 — cierre del Sprint 4 y objetivo del Sprint 5

- **Tarea:** [SCRUM-1245](https://maniservices.atlassian.net/browse/SCRUM-1245) (DOC4-02), subtareas [SCRUM-1290](https://maniservices.atlassian.net/browse/SCRUM-1290) y [SCRUM-1291](https://maniservices.atlassian.net/browse/SCRUM-1291).
- **Autora:** Camila Beltrán (PO). **Fecha:** 2026-10-20, al cierre del Sprint 4. **Revisión:** Scrum Master (Sara Albarracín) y QA (Santiago).
- **Contexto:** el Sprint 5 es el **último**. Las historias que entren deben terminar el producto prometido: el MVP de `SRS.md` §1.2.
- **Insumos:** matriz historia ↔ repositorios ([SCRUM-1256](https://maniservices.atlassian.net/browse/SCRUM-1256), `qa/MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md`), criterios de aceptación y DoD ([SCRUM-1257](https://maniservices.atlassian.net/browse/SCRUM-1257), §6 de este documento) e inventario funcional ([SCRUM-1260](https://maniservices.atlassian.net/browse/SCRUM-1260), `SRS.md` §7.2 y `architecture/SAD.md` §7.5).
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

> Terminar el desarrollo del producto comprometido y demostrar, por video desde el front, en QA y a través del Gateway con token real ES256, que cada funcionalidad cumple lo pedido. Es el último sprint de desarrollo: lo que no entra no se construye.

**Redacción unificada el 25 de octubre de 2026.** Este objetivo decía antes «cerrar de punta a punta el ciclo del servicio del MVP… cada historia verificada por QA con evidencia y sin deuda técnica abierta», y no mencionaba el video. El libro de módulos decía «validación por video y cierre funcional» y el sprint de Jira una tercera cosa. Las tres fuentes decían objetivos distintos del mismo sprint, lo que reportó José Nicolás Álvarez. Ahora dicen esto mismo, literal: la hoja `12 Backlog S5 resumen` del libro, el objetivo del sprint 71 en Jira y esta sección.

Lo que no cambió: el alcance sigue siendo cerrar el ciclo del servicio del MVP —solicitud, cotización, ejecución, calificación y cierre— con tarifario y notificaciones. Lo que se precisó es **cómo se acredita**: por video desde el front, no por estado en el tablero.

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

- **[SCRUM-1067](https://maniservices.atlassian.net/browse/SCRUM-1067) y [SCRUM-1068](https://maniservices.atlassian.net/browse/SCRUM-1068):** aplican sus criterios de §6 de este documento y los CC/CA de Jira.
- **Historias nuevas del Sprint 5:** no entran al sprint sin criterios C1 (positivo), C2 (negativo) y C3 (regla crítica), redactados por el PO a partir del RF y revisados por QA (DoR). Mínimo exigido:

| Historia | C1 mínimo | C3 regla crítica |
|---|---|---|
| [SCRUM-865](https://maniservices.atlassian.net/browse/SCRUM-865) | El aliado asignado cotiza con mano de obra y materiales separados. | Solo el aliado asignado cotiza esa solicitud. |
| [SCRUM-867](https://maniservices.atlassian.net/browse/SCRUM-867) | El cliente acepta, rechaza o pide ajuste, y la solicitud cambia de estado. | Un cliente no decide sobre cotizaciones de otro cliente o tenant. |
| [SCRUM-868](https://maniservices.atlassian.net/browse/SCRUM-868), [SCRUM-869](https://maniservices.atlassian.net/browse/SCRUM-869) | El aliado marca inicio y fin, y registra eventos con fecha y hora. | Solo el aliado asignado registra la ejecución; los eventos no se editan. |
| [SCRUM-874](https://maniservices.atlassian.net/browse/SCRUM-874), [SCRUM-875](https://maniservices.atlassian.net/browse/SCRUM-875) | Cada parte califica una vez al terminar la ejecución. | El servicio no cierra hasta que ambas partes califiquen (RF-19). |
| [SCRUM-884](https://maniservices.atlassian.net/browse/SCRUM-884) | Cada cambio de estado del servicio genera su notificación. | Un fallo de push no revierte la operación (QAS-02). |
| [SCRUM-885](https://maniservices.atlassian.net/browse/SCRUM-885) | El administrador del tenant carga rangos de tarifa por categoría. | El tarifario del tenant A no se aplica al tenant B. |

- **DoD:** `wiki/04-proceso/dor-y-dod.md` con los añadidos decididos por QA; subtarea QA de la historia finalizada con los IDs de casos de la matriz de pruebas; PR enlazado en Jira; aceptación funcional del PO. Ninguna historia se declara aceptada sin esa evidencia.

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
  servicio de despacho (riesgo *Doble asignacion* del SAD §23, ADR-0016), y no tiene porción que Core Service pueda sostener.
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
| ~~`DOC-26` — Registrar en ADR la decision de SP-05~~ **CERRADA el 2026-10-07.** La decision de la daily del 2026-10-05 (la logica de negocio vive en los servicios y se retira de Flutter y de las funciones PL/pgSQL) quedo registrada en [`adr/ADR-0022`](../02-arquitectura/adr/ADR-0022-logica-de-negocio-en-servicios.md), publicado en `main`. El ADR queda en estado **Propuesto**: pasarlo a Aceptado requiere sesion formal de la Mesa (Gobierno §2.6) | Highest | 3 | `SCRUM-453` |
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
| Requerimientos | [`product/SRS.md`](../01-producto/SRS.md) |
| Arquitectura | [`architecture/SAD.md`](../02-arquitectura/SAD.md) |
| Diseño detallado y vistas C4 | [`architecture/SDD.md`](../02-arquitectura/SDD.md) |
| Modelo de datos | [`architecture/ModeloDatos.md`](../02-arquitectura/ModeloDatos.md) |
| Decisiones arquitectónicas | [`adr/`](../02-arquitectura/adr) |
| Matriz historia ↔ repositorios del Sprint 4 | [`qa/MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md`](../07-calidad/MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md) |
| Criterios de aceptación del Sprint 4 | [§6 de este documento](BACKLOG_MANI.md#6-criterios-de-aceptación-y-dod-de-las-historias-priorizadas-del-sprint-4) |
| Políticas DevOps y versionamiento de despliegue | [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md) |

---

## 6. Criterios de aceptación y DoD de las historias priorizadas del Sprint 4

> Fusionado desde §6 de este documento (SCRUM-1257) el 22 de octubre de 2026. Este backlog es ahora la fuente única. Las referencias internas de este bloque que dicen «la sección N» o «§N» corresponden a §6.N de este documento.

| Campo | Valor |
|---|---|
| Tarea | SCRUM-1257 (PO4-02), subtareas SCRUM-1286 y SCRUM-1287 |
| Historias | Las 17 historias del Sprint 4 de la matriz de SCRUM-1256 |
| Autora | Camila Beltrán (PO) |
| Fecha | 19 de octubre de 2026 (versión 2, ajustada según la revisión de QA del PR #49) |
| Criterios de aceptación | Decididos por el PO. Las reglas de producto nuevas (§3: 852, 855 y 1063) fueron confirmadas con Sara el 19-oct |
| DoD (sección 4) | **Decidido por QA** (Santiago, revisión del PR #49) |
| Alimenta a | SCRUM-1245 (Backlog V5) |

### 6.1 Alcance, autoridad y fuentes

Este documento fija los criterios de aceptación funcionales de las 17 historias priorizadas del Sprint 4. El DoD técnico transversal vive en `wiki/04-proceso/dor-y-dod.md`; la sección 4 solo registra lo que QA decidió sobre los añadidos propuestos. Según `governance/GOBIERNO_DEL_EQUIPO.md` §2.3, el PO decide los criterios de aceptación y QA decide el DoD.

**Estos criterios se suman a lo que ya está en Jira, no lo reemplazan.** Siguen vigentes, en cada historia, la sección «QA - pruebas obligatorias» y, donde existen, los criterios CC y CA publicados (SCRUM-1060, 1063 y 1066). Los criterios C1, C2 y C3 de cada historia son el caso positivo, el negativo y el intento de violar la regla crítica; los C4 en adelante cubren los escenarios de «QA - pruebas obligatorias» que C1 a C3 no alcanzan.

**Códigos de error.** Los criterios no fijan códigos ni nombres de error: pertenecen al contrato de cada servicio publicado en el Gateway. Cuando un criterio dice «se rechaza con el error de validación del contrato», se verifica contra ese contrato. Los códigos HTTP `401`, `403`, `409` y `503` sí se fijan cuando el SRS, un ADR o la historia ya los establecen.

**Mocks.** En QA, las notificaciones push y los pagos son simulados. Ningún criterio exige envíos reales a FCM/APNs ni cobros reales.

**Línea de verificación por historia.** Cada historia indica quién acepta, qué subtarea de QA verifica y qué casos de la matriz de pruebas del Sprint 4 (`qa/regresion_sprint4/MANI_Matriz_Pruebas_Sprint4.xlsx`, SCRUM-1264) la cubren.

Fuentes revisadas: la descripción de cada historia en Jira (alcance, DoD y «QA - pruebas obligatorias»), la matriz de pruebas SCRUM-1264, `product/SRS.md`, `architecture/SAD.md` §7, `architecture/SDD.md` §4.2 y §8, los contratos del Gateway y ADR-0012, 0016, 0018, 0022, 0027, 0030 y 0031 con su estado vigente.

### 6.2 Criterios transversales

Aplican a todas las historias de este documento. Una historia que incumpla uno de ellos no se acepta.

| ID | Criterio | Origen |
|---|---|---|
| T1 | Ningún servicio consulta ni escribe tablas de un dominio ajeno; las dependencias entre servicios son llamadas HTTP. Los estados de asignación son dominio de Dispatch (SAD §7). | SDD §4.2; ADR-0030 §2 (Propuesto) |
| T2 | Si un servicio del que se depende no responde, el llamador devuelve `503` y no sustituye la respuesta por lógica local ni por un valor por omisión. | SDD §4.2; ADR-0030 §2 (Propuesto) |
| T3 | Toda tabla nueva nace con `tenant_id`, RLS habilitado y su política por tenant en la misma migración. **Aplica cuando se apruebe ADR-0030:** la migración vive en `MANI-Node/db/migrations/`, y Rules y Dispatch no versionan DDL. | ADR-0012 (Aceptado); ADR-0030 §1 (Propuesto) |
| T4 | El tenant, el rol y el usuario se toman del claim verificado y se propagan en `X-Tenant-Id`, `X-User-Role` y `X-Correlation-ID`; nunca se toman del cuerpo de la petición. | ADR-0018 |
| T5 | Los errores responden con el formato `{ error, code, correlationId }` en todos los servicios. | Contrato de Core |
| T6 | La aplicación móvil solo usa `supabase.auth`; todo acceso a datos pasa por el Gateway. | ADR-0027 |
| T7 | Sin token o con token inválido, el Gateway responde `401` y la petición no llega al servicio. | CC-3 en Jira; ADR-0018 |
| T8 | Las peticiones y respuestas cumplen el contrato OpenAPI publicado en el Gateway. | CC-4 en Jira; QAS-06 |
| T9 | El servicio falla cerrado sin `SUPABASE_JWT_SECRET`, salvo con `NODE_ENV=development` o `test`; `dev-token` solo existe en desarrollo. | ADR-0031 (Aprobado) |
| T10 | Las operaciones administrativas (crear, aprobar, rechazar, desactivar) registran quién, cuándo, la decisión y el `correlationId`. | RNF-04; CA-5 de SCRUM-1066 |

### 6.3 Criterios por historia

#### SCRUM-850 · Registrar empleado directo · RF-05 · Nicolás León

- **C1 (positivo).** Dado un administrador del tenant autenticado, cuando registra un empleado directo con los datos obligatorios, entonces el aliado queda creado en ese tenant con tipo empleado directo.
- **C2 (negativo).** Dado un registro al que le falta un dato obligatorio, cuando se envía, entonces se rechaza con el error de validación del contrato y no se crea ningún registro.
- **C3 (regla crítica).** Dado un administrador del tenant A, cuando envía en el cuerpo el identificador del tenant B, entonces el empleado no queda en el tenant B (T4).
- **C4 (duplicado).** Dado un empleado ya registrado, cuando se intenta registrar de nuevo, entonces se responde `409` y sigue existiendo un solo registro.
- **C5 (rol no autorizado).** Dado un usuario que no es administrador del tenant, cuando intenta registrar un empleado directo, entonces la petición se rechaza.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1306 · **Casos:** US0215-P1, N1, N2, S1, S2, E1, X1 a X5, G1.

#### SCRUM-852 · Cliente empresa con varios sitios · RF-08 · Nicolás León

- **C1 (positivo).** Dado un cliente empresa autenticado, cuando registra dos o más sitios con su zona, entonces cada sitio queda asociado al cliente.
- **C2 (negativo).** Dado un sitio con campos inválidos o sin zona asignada, cuando se intenta registrar, entonces se rechaza con el error de validación del contrato, porque todo sitio debe tener una zona (RF-09).
- **C3 (regla crítica).** Dado el usuario de otra empresa o de otro tenant, cuando intenta consultar o modificar esos sitios, entonces recibe rechazo o ausencia de datos.
- **C4 (roles, decisión del PO).** Los sitios de un cliente empresa los crean y editan **el propio cliente empresa o el administrador de su tenant**. Un aliado u otro cliente que lo intente recibe rechazo.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1307 · **Casos:** US0222-P1, N1, S1, S2, E1, X1 a X5.

#### SCRUM-853 · Reglas del sitio visibles al aliado · RF-09 · Nicolás León

- **C1 (positivo).** Dado un sitio con reglas de acceso registradas, cuando un aliado es asignado a una solicitud en ese sitio, entonces ve las reglas antes de la programación.
- **C2 (negativo).** Dado un aliado que no está asignado a ninguna solicitud del sitio, cuando consulta las reglas, entonces no las recibe.
- **C3 (regla crítica).** Dado un aliado de otro tenant, cuando intenta consultar las reglas del sitio, entonces recibe rechazo o ausencia de datos.
- **C4 (sitio sin reglas).** Dado un sitio sin reglas registradas, cuando el aliado asignado las consulta, entonces recibe una respuesta vacía, no un error.
- **C5 (cambio de sitio).** Dado que la solicitud cambia de sitio, cuando el aliado consulta las reglas, entonces ve las del sitio nuevo y no las del anterior.
- **Pantalla Flutter:** MANI-Flutter#44.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1308 · **Casos:** US0223-P1, P2, P3, S1, E1, X1 a X5.

#### SCRUM-854 · Editar perfil propio · RF-30 · Nicolás León

- **C1 (positivo).** Dado un usuario autenticado, cuando edita un dato permitido de su perfil o su foto, entonces el cambio queda guardado y se refleja al consultarlo.
- **C2 (negativo).** Dado un dato con formato inválido, cuando se envía, entonces se rechaza con el error de validación del contrato y el perfil no cambia.
- **C3 (regla crítica).** Dado un usuario, cuando intenta editar el perfil de otro usuario o cambiar su propio rol, tenant o estado de verificación, entonces la petición se rechaza.
- **Pantalla Flutter:** MANI-Flutter#45.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1309 · **Casos:** US0231-P1, P2, N1, S1, S2, X1 a X6.

#### SCRUM-855 · Aliado gestiona su disponibilidad · RF-29 · José Nicolás Álvarez

Decisión del PO: el aliado registra **intervalos en los que NO está disponible** (vacaciones, enfermedad), como dice la historia y como ya implementa el contrato del Gateway (`/profiles/me/unavailability`). RF-29 del SRS se ajusta a este modelo.

- **C1 (positivo).** Dado un aliado aprobado, cuando registra o edita un intervalo de no disponibilidad, entonces no se presenta como aliado válido durante ese intervalo.
- **C2 (negativo).** Dado un intervalo cuya fecha de fin es anterior a la de inicio, cuando se envía, entonces se rechaza con el error de validación del contrato.
- **C3 (regla crítica).** Dado un aliado, cuando intenta modificar la no disponibilidad de otro aliado, entonces la petición se rechaza.
- **C4 (solapamiento, decisión del PO).** Dado un intervalo que se cruza con otro ya registrado del mismo aliado, cuando se envía, entonces **se rechaza y la respuesta le explica al aliado que se cruza con un intervalo existente**.
- **C5 (elegibilidad).** Dado un aliado dentro de un intervalo de no disponibilidad, cuando se conforma el listado de aliados válidos (SCRUM-861), entonces no aparece.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1310 · **Casos:** US0216-P1, P2, N1, N2, I1, S1, X1 a X5. Latencia de la consulta dentro del umbral (QAS-03).

#### SCRUM-856 · Aceptar términos y condiciones · RF-31 · Nicolás León

- **C1 (positivo).** Dado un usuario que no ha aceptado la versión vigente, cuando la acepta de forma expresa, entonces queda registrado el consentimiento con versión, usuario y fecha, y puede usar la plataforma.
- **C2 (negativo).** Dado un usuario sin la versión vigente aceptada, cuando intenta usar una función de la plataforma, entonces se le exige aceptarla primero.
- **C3 (regla crítica).** Dado que se publica una nueva versión, cuando un usuario que aceptó la anterior inicia sesión, entonces debe aceptar la nueva.
- **C4 (consulta).** Dado un usuario autenticado, cuando consulta su consentimiento, entonces ve la versión aceptada y la fecha.
- **C5 (consentimiento ajeno).** Dado otro usuario del mismo tenant, cuando intenta consultar o modificar ese consentimiento, entonces la petición se rechaza.
- **Pantalla Flutter:** MANI-Flutter#41.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1311 · **Casos:** US0232-P1, P2, P3, N1, S1, E1, X1 a X5. La tabla de consentimientos cumple T3.

#### SCRUM-858 · Desactivar categoría sin afectar servicios en curso · RF-10 · Juan Sebastián Álvarez

- **C1 (positivo).** Dado un administrador del tenant, cuando desactiva una categoría, entonces deja de ofrecerse en el catálogo y en las solicitudes nuevas.
- **C2 (negativo).** Dada una categoría desactivada, cuando un cliente intenta crear una solicitud nueva con ella, entonces se rechaza.
- **C3 (regla crítica).** Dado que hay servicios en curso de esa categoría, cuando se desactiva, entonces esos servicios continúan sin cambios hasta cerrarse.
- **C4 (permisos).** Dado un usuario que no es administrador, o un administrador de otro tenant, cuando intenta desactivar la categoría, entonces la petición se rechaza.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1312 · **Casos:** US0312-P1, P2, N1, S1, I1, X1 a X5, G1. Si se consulta el estado de los servicios en Dispatch, se hace por HTTP (T1). Registra la operación según T10.

#### SCRUM-861 · Ver aliados válidos por cobertura y categoría · RF-12 · Nicolás León

- **C1 (positivo).** Dada una solicitud con categoría y zona, cuando se conforma el listado, entonces solo incluye aliados aprobados, de esa categoría, con cobertura en la zona y sin intervalo de no disponibilidad vigente.
- **C2 (negativo).** Dado que ningún aliado cumple las condiciones, cuando se conforma el listado, entonces se devuelve vacío con un mensaje, no un error.
- **C3 (regla crítica).** El listado nunca incluye aliados de otro tenant, sin aprobar, fuera de cobertura, de otra categoría o no disponibles. Dispatch obtiene la elegibilidad de Core por HTTP (T1) y responde `503` si Core no responde (T2).
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1313 · **Casos:** US0412-P1, N1, N2, N3, S1, R1, X1 a X5. Latencia dentro del umbral (QAS-03).

#### SCRUM-862 · Filtrar por tipo de aliado · RF-12 · José Nicolás Álvarez

Decisión del PO (comentario del 19-oct en SCRUM-862): los tipos de aliado válidos son **persona natural, empresa y empleado directo** (RF-05).

- **C1 (positivo).** Dado un listado de aliados válidos, cuando el cliente filtra por uno de los tres tipos, entonces solo ve aliados de ese tipo.
- **C2 (negativo).** Dado un tipo de aliado que no es ninguno de los tres, cuando se usa como filtro, entonces se rechaza con el error de validación del contrato.
- **C3 (regla crítica).** Dado cualquier filtro o combinación de filtros, el resultado nunca incluye aliados fuera del listado de aliados válidos de SCRUM-861; si no hay coincidencias, se devuelve vacío.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1314 · **Casos:** US0413-P1, P2, P3, P4, N1, S1, X1 a X5.

#### SCRUM-1060 · Registro de empresa en la app vía Gateway · RF-05 · José Nicolás Álvarez

**Siguen vigentes los CC-1 a CC-4 y los CA de Jira** (entre ellos CA-2, dominio intacto; CA-5, fiel al diseño de Figma; y CA-6, rechazo cross-tenant). C1 a C3 se suman a ellos.

- **C1 (positivo).** Dado un usuario en la app, cuando completa el registro de aliado empresa, entonces la app lo envía al Gateway y muestra el resultado.
- **C2 (negativo).** Dado que el Gateway responde con error, cuando la app lo recibe, entonces muestra un mensaje comprensible con el `correlationId` y el usuario no pierde lo diligenciado.
- **C3 (regla crítica).** La app no llama a Supabase con `.from()`, `.rpc()` ni `.storage.from()` en este flujo (T6).
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1328 · **Casos:** US0212M3-C1 a C4, P1, N1 a N4, S1 a S3, E1, M1 a M3, X1 a X6. En Flutter, el resultado local de `flutter analyze` y `flutter test` reemplaza al CI (decisión de QA, §4).

#### SCRUM-1063 · Registro de aliado empresa en Core · RF-05 · Nicolás León

**Siguen vigentes los CC-1 a CC-4 y los CA-1 a CA-5 de Jira** (entre ellos CA-2, documentos en bucket privado con ruta `tenant_id/aliado_id/documento`). C1 a C3 se suman a ellos.

- **C1 (positivo).** Dado un registro con los documentos exigidos por la configuración del tenant, cuando Core lo recibe, entonces crea el aliado empresa en estado pendiente de verificación.
- **C2 (negativo).** Dado un registro al que le falta un documento exigido, cuando Core lo recibe, entonces lo rechaza con el error de validación del contrato y no crea ningún registro.
- **C3 (regla crítica).** El tenant se toma del claim (T4), y los documentos de un aliado no son accesibles para otro aliado ni para otro tenant.
- **CA-4 cerrado por el PO (empresa duplicada).** Dada una empresa ya registrada en el tenant, cuando se intenta registrar de nuevo, entonces se responde `409` y no se crea un segundo registro.
- **Acepta:** Camila (PO) · **Verifica:** sin subtarea QA (pendiente PE4) · **Casos:** US0212M2-C1 a C4, P1, P2, N1, N2, F1, M1 a M3, X1 a X6.

#### SCRUM-1066 · Aprobar o rechazar registro de aliado · RF-06 · Nicolás León

**Siguen vigentes los CC-1 a CC-4 y los CA-1 a CA-7 de Jira** (entre ellos CA-2, acceso temporal a los documentos KYC; CA-5, auditoría; y CA-6, `403` para aliado o cliente). C1 a C3 se suman a ellos.

- **C1 (positivo).** Dado un aliado pendiente, cuando el administrador del tenant lo aprueba, entonces queda aprobado y puede aparecer como aliado válido.
- **C2 (negativo).** Dado un aliado pendiente, cuando el administrador lo rechaza, entonces queda rechazado con el motivo y no aparece como aliado válido.
- **C3 (regla crítica).** Un aliado no puede aprobarse a sí mismo, y un administrador de otro tenant no puede aprobarlo ni rechazarlo.
- **Acepta:** Camila (PO) · **Verifica:** sin subtarea QA (pendiente PE4) · **Casos:** US0213M2-C1 a C4, P1 a P4, N1, S1, E1, M1 a M3, X1 a X6. Registra la decisión según T10. Si se notifica al aliado, la notificación es simulada.

#### SCRUM-1068 · Zona de cobertura · RF-07 · Nicolás León

- **C1 (positivo).** Dado un aliado aprobado, cuando declara sus zonas desde el catálogo de zonas del tenant, entonces quedan registradas como su cobertura.
- **C2 (negativo).** Dada una zona que no existe en el catálogo, cuando se declara, entonces se rechaza con el error de validación del contrato.
- **C3 (regla crítica).** Las zonas de otro tenant no pueden seleccionarse.
- **Acepta:** Camila (PO) · **Verifica:** sin subtarea QA (pendiente PE4) · **Casos:** US0214M2-P1, N1, S1, M1 a M3, X1 a X5. La cobertura es dominio de Core (ADR-0028); el título de la historia aún menciona «Availability Service» (PE3).

#### SCRUM-1070 · Reglas de categoría en Rules · RF-02 · Juan Sebastián Álvarez

Criterios definidos después del cierre de la historia; se verifican en la regresión del Sprint 4.

- **C1 (positivo).** Dada una regla de categoría configurada por el tenant, cuando Core la consulta, entonces Rules la evalúa y responde según esa configuración, manteniendo el comportamiento funcional previo.
- **C2 (negativo).** Dada una categoría inválida, inactiva o fuera de los límites, cuando Core la consulta, entonces Rules la rechaza con el error del contrato.
- **C3 (regla crítica).** Dado que Rules no responde, cuando Core lo consulta, entonces Core devuelve `503` y no aplica una regla local (T2). La regla del tenant A nunca se aplica al tenant B.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1329 · **Casos:** US0311M6-P1, N1 a N3, F1, S1, C1, R1, M1 a M3, X1 a X5. Un cambio de regla del tenant surte efecto sin despliegue (QAS-04).

#### SCRUM-1072 · Creación de solicitud en Core · RF-12 · Nicolás León

- **C1 (positivo).** Dado un cliente autenticado, cuando crea una solicitud con categoría y sitio, entonces Core la persiste y queda lista para que Dispatch la orqueste, sin replicar lógica de despacho.
- **C2 (negativo).** Dada una solicitud con datos erróneos o incompletos, cuando se envía, entonces se rechaza con el error de validación del contrato y no se crea.
- **C3 (regla crítica).** Un cliente no puede crear solicitudes sobre el sitio de otro cliente ni de otro tenant.
- **C4 (sin permiso).** Dado un usuario sin permiso para crear solicitudes, cuando lo intenta, entonces recibe `403`.
- **C5 (falla de dependencia).** Dado que una dependencia de Core no responde, cuando se crea la solicitud, entonces Core responde `503` y no queda una solicitud a medias (T2, QAS-09).
- **C6 (reintento).** Dado un reintento con la misma `claveIdempotencia`, cuando llega a Core, entonces no se crea una segunda solicitud.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1330 · **Casos:** US0411M2-P1, N1, S1, F1, K1, E1, M1 a M3, X1 a X6. Core crea la solicitud y Dispatch la orquesta (decisión D1 de SCRUM-1232).

#### SCRUM-1073 · Orquestación del despacho en Dispatch · RF-12, RF-13 · Nicolás León

- **C1 (positivo).** Dada una solicitud creada en Core, cuando Dispatch la orquesta, entonces pide a Core los aliados elegibles y a Rules el orden, ambos por HTTP, y envía el broadcast.
- **C2 (negativo).** Dado que Core o Rules no responden, cuando Dispatch los consulta, entonces devuelve `503`, no arma el listado con lógica local y no deja la solicitud en estado ambiguo (T2, QAS-09).
- **C3 (regla crítica).** Dispatch no hace consultas SQL sobre tablas de Core ni inserta en tablas de notificación: notifica a través de Core (T1).
- **C4 (sin candidatos).** Dado que no hay aliados elegibles, cuando Dispatch orquesta, entonces la solicitud queda sin broadcast y el cliente recibe un resultado claro, no un error.
- **C5 (reintentos).** Dado un reintento de la orquestación, cuando llega a Dispatch, entonces no se duplica el broadcast.
- **Mocks:** las notificaciones push del broadcast son simuladas en QA.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1331 · **Casos:** US0411M6-P1, P2, K1, F1, S1, I1, M1 a M3, X1 a X5. Escenarios críticos aprobados (QAS-07); un fallo de push no revierte una operación confirmada (QAS-02).

#### SCRUM-1074 · Aceptar o rechazar sin doble asignación · RF-14 · Nicolás León

La asignación es dominio de Dispatch (SAD §7, «estados de asignación»), así que escribirla no viola T1. El dueño del estado de la solicitud después de la asignación es el pendiente P1 del SAD §7.4 (Juan Sebastián, 20 oct, SCRUM-1233). La exclusión concurrente sigue ADR-0016 (Propuesto).

- **C1 (positivo).** Dado un broadcast activo, cuando el primer aliado acepta, entonces la solicitud queda asignada a ese aliado.
- **C2 (negativo).** Dado que la solicitud ya fue asignada, cuando otro aliado intenta aceptarla, entonces recibe `409`.
- **C3 (regla crítica).** Bajo aceptaciones concurrentes nunca hay dos aliados asignados a la misma solicitud, y un reintento de la misma aceptación no cambia el resultado.
- **C4 (rechazo).** Dado un broadcast activo, cuando un aliado lo rechaza, entonces queda registrado su rechazo y la solicitud sigue disponible para los demás.
- **C5 (aliado no autorizado).** Dado un aliado que no recibió el broadcast o es de otro tenant, cuando intenta aceptar, entonces la petición se rechaza.
- **Acepta:** Camila (PO) · **Verifica:** SCRUM-1332 · **Casos:** US0414M6-K1, K2, P1, P2, N1, S1, M1 a M3, X1 a X5. Cero dobles asignaciones e idempotencia (QAS-07).

### 6.4 Añadidos al DoD — Decidido por QA

Decisión de Santiago (QA) en la revisión del PR #49 (https://github.com/Trama-AS/MANI-docs/pull/49). QA la lleva a `wiki/04-proceso/dor-y-dod.md` en su propio PR, junto con la corrección de la numeración de los QAS.

| Propuesta | Decisión de QA |
|---|---|
| Fila «Datos o reglas de otro servicio» | Aprobada tal cual, con respaldo en SDD §4.2. |
| Fila «Esquema o tablas» | Aprobada en dos partes: `tenant_id`, RLS y política en la misma migración, vigente desde ya (ADR-0012); migración en `MANI-Node/db/migrations/`, cuando se apruebe ADR-0030. |
| Evidencia exigida | Aprobada con dos ajustes: la evidencia de QA va en la subtarea QA de la historia, con los IDs de casos de la matriz SCRUM-1264; en Flutter, el resultado local de `flutter analyze` y `flutter test` reemplaza al CI, porque los PRs a `develop` no lo corren. |

### 6.5 Pendientes

| ID | Pendiente | Responsable |
|---|---|---|
| PE2 | Los PRs de 856, 861, 1073 y 1074 ya cumplen T1 y T3. Faltan dos cosas: que MANI-Node#14 resuelva su conflicto con `develop`, y que MANI-Node#43 cierre el acceso a los endpoints internos para que entren MANI-.NET#3, #2 y #1. | Nicolás León |
| PE3 | Corregir el título de SCRUM-1068, que menciona «Availability Service». | Nicolás León |
| PE4 | Crear las subtareas QA de SCRUM-1063, 1066 y 1068. | Santiago (QA) |
| PE5 | Dispatch responde `{ error, status }`; debe responder según T5. | Nicolás León |
| PE6 | El filtro de Dispatch solo acepta `PERSONA_NATURAL` y `PERSONA_JURIDICA`; debe aceptar también `EMPLEADO_DIRECTO` (decisión de SCRUM-862). | José Nicolás Álvarez |
| PE7 | Definir el límite de tamaño de la foto de perfil de SCRUM-854 (brecha B-21 de la matriz). | Camila (PO) |
| PE8 | Ajustar RF-29 del SRS al modelo de intervalos de no disponibilidad. | Camila (PO) |
| PE9 | En Jira: corregir la descripción de SCRUM-862 (habla de cotizaciones, brecha B-24); quitar «funciones PL/pgSQL» de 1060, 1066, 1070, 1072, 1073 y 1074 (B-16); cambiar ADR-0021 por ADR-0016 en 1074 (B-17); y enlazar cada historia a su sección de este documento. | Camila (PO) |

---

## 7. Criterios de aceptación de US-02.1.1 sobre el camino Gateway - Core

> Fusionado desde `backlog/CRITERIOS_ACEPTACION_US-02.1.1.md` (SCRUM-1076) el 22 de octubre de 2026. Las referencias internas de este bloque que dicen «la sección N» o «§N» corresponden a §7.N de este documento.

| Campo | Valor |
|---|---|
| Historia | US-02.1.1 - Registro de aliado persona natural con KYC (SCRUM-846, RF-05) |
| Tarea | SCRUM-1076 (PO-01), subtareas SCRUM-1126 (PO-01a), SCRUM-1127 (PO-01b), SCRUM-1128 (PO-01c) y SCRUM-1129 (PO-01d) |
| Camino de la arquitectura | Flutter -> NGINX Gateway -> Core Node -> funciones PL/pgSQL en Supabase |
| Autor | Santiago (QA) |
| Fecha | 7 de octubre de 2026 (actualizado contra GitHub y Jira) |
| Estado | Borrador. DoR y DoD de M4 definidos por QA. DoR y DoD de M1 a M3 en propuesta, pendientes de sus responsables. Escenarios BDD condicionales a la confirmación de la Scrum Master. Validación del PO y revisión del par técnico pendientes (SCRUM-1130). Publicación pendiente (SCRUM-1131) |
| Alimenta a | SCRUM-1062 (US-02.1.1-M4), SCRUM-1094 (DOC-38) y SCRUM-1105 (CFG-23c) |

### 7.1 Alcance y fuentes verificadas

Este documento reescribe los criterios de aceptación de US-02.1.1 para un llamador que es un servicio, fija los seis casos cross-tenant como condición de aceptación y propone el DoR y el DoD de los cuatro pasos de migración (M1 a M4). Los criterios se redactan en formato BDD. Según el Backlog V3 (sección 3), cada criterio lleva un caso positivo, uno negativo y un intento de violar la regla crítica.

Autoridad de decisión (`governance/GOBIERNO_DEL_EQUIPO.md`, sección 2.3): el PO decide los criterios de aceptación y QA decide el DoD. Por eso los criterios requieren validación del PO, y los DoR y DoD de los pasos que pertenecen a otros responsables se presentan como propuesta.

| Fuente | Estado de la lectura | Observación relevante |
|---|---|---|
| `wiki/04-proceso/dor-y-dod.md` | Leída en `origin/main` (`3fd4473`) | DoR y DoD oficiales. Exige que toda historia que toque autenticación, tenant, RLS, endpoints de datos o Storage demuestre los seis casos cross-tenant con rechazo o ausencia de datos |
| `governance/GOBIERNO_DEL_EQUIPO.md`, secciones 2.3, 8 y 9 | Leídas | El DoD lo decide QA. El DoR exige spike bloqueante cerrado |
| `governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`, sección 13.4 | Leída | Define los seis casos |
| `backlog/BACKLOG_MANI.md` | Leído | Única fuente del backlog. M1 no figura como paso propio: lo sustituye CFG-16 |
| `architecture/COMUNICACION_SERVICIOS_GATEWAY.md` | Leída | Rutas `/api/v1/core\|rules\|dispatch/*`. Cada servicio inspecciona el JWT para extraer `user_id` y `tenant_id`. Availability no aparece en la matriz de rutas |
| `ADR/ADR-0015` (Propuesto), `ADR-0013` (Propuesto), `ADR-0005` (Aceptado), `ADR-0018` (Aceptado) | Leídos | ADR-0015 exige 100 % de rechazo cross-tenant. ADR-0005 fija los gates (ver sección 4) |
| `product/SRS.md`: RF-02, RF-03, RF-05, RNF-01, RNF-04, REST-02 | Leídos | RF-05 exige documentos según la configuración del tenant y aislados por aliado y tenant |
| `Entregas/Entrega4/Backlog_V3.md`, sección 3 | Leída | Tres escenarios originales de US-02.1.1 y US-02.1.2, pendientes de validación del PO |
| `wiki/02-arquitectura/riesgos-y-puntos-abiertos.md` | Leída | SP-05 abierto; riesgos CFG-23 y CFG-36 |
| `ADR-0022` (rama `SCRUM-1075-adr-0022`, `aa6d464`, no fusionada) | Leído, estado Propuesto | Registra la decisión de SP-05 que el equipo revisó en la daily del 5 de octubre: la lógica de negocio vive en los servicios y las funciones PL/pgSQL se retiran después de que la regresión en QA (SCRUM-1062) confirme el reemplazo. Los títulos de SCRUM-1063, 1064 y 1065 ya reflejan esa decisión. El documento formal sigue en Propuesto y no está en `main` |
| `ADR-0027` | Leído, estado Aceptado | CFG-35. Flutter conserva solo `supabase.auth` (inicio de sesión, registro de usuarios y refresco de token) y se prohíben `.from()`, `.rpc()` y `.storage.from()`. Resuelve PA-07 en cuanto a REST, RPC y Storage |
| `MANI-Flutter/qa/newman/` | Leída en `develop` (sin cambios frente a `main`) | Colecciones `mani-aislamiento` y `mani-claims`. Atacan Supabase directo |
| Contrato OpenAPI de CFG-16 (SCRUM-1099) | Leído, versión 0.3.0 | Vive en `MANI-APIGateway`, rama `CFG-16` (`b1b5048`), `docs/openapi/core.yaml`, con Spectral y una colección Postman en CI (QA-03). CFG-16 está En revisión. Define `login`, `refresh`, `logout` y `register/ally`; el registro es `multipart/form-data` con documentos KYC (cédula obligatoria, RUT opcional) y `X-Tenant-Slug`. No define endpoint de consulta de estado ni de carga posterior de documentos (PA-29). El borrador anterior de `MANI-Node` quedó obsoleto |
| `MANI-Node` y `MANI-APIGateway` (carpeta local `MANI-API`) | Leídos en `main` | Solo esqueleto, gobernanza y plantilla de PR. Sin workflows, sin proyecto Sonar y sin pruebas. El Core no tiene ruta de registro |
| `MANI-Java` y `MANI-.NET` | Sincronizados; solo se listó su contenido | No se asume nada sobre ellos |
| `MANI-Infrastructure` (`MANI-Infra` en la documentación) | **No existe** | DevOps (Daniel Ávila) lo borró el 6 de octubre porque ya no se necesitaba. Ninguno de los `AGENTS.md` ni `CLAUDE.md` lo menciona. ADR-0004, el SAD, el SDD, el README y la wiki aún lo nombran como `MANI-Infra` |
| `AGENTS.md` y `CLAUDE.md` de `MANI-Flutter` (`develop`), `MANI-Node`, `MANI-APIGateway`, `MANI-Java` y `MANI-.NET` | Leídos en su rama vigente | `MANI-docs` no tiene esos archivos. Fijan lo siguiente: el Gateway reenvía el JWT sin validarlo (PA-16); el error del Core es `{ error, code?, correlationId }`; el servicio de reglas se encarga de las reglas por tenant (RF-02, PA-03); Flutter hace PR a `develop` o `release`; ninguno menciona Availability ni un repo de infraestructura |
| Jira | Leído en línea el 6 de octubre, sin escrituras | SCRUM-1076, 1126 a 1131, 1062, 1184 a 1188, 1061, 1065, 1099, 1075, 1083, 1102 a 1104 y 1112 |

Nota de la época: no se citaban ADR-0023 a ADR-0026 porque no estaban en el repositorio, y ADR-0022 se citaba desde su rama sin fusionar. Hoy ADR-0022, ADR-0024 y ADR-0025 están vigentes y Aceptados; ADR-0023 quedó absorbido por ADR-0024 y ADR-0026 nunca se emitió.

Base de código al 7 de octubre de 2026, tras `git fetch --all --prune`: `MANI-docs` `origin/main` `12dd5ff`; **`MANI-Flutter` rama `develop` `25c2a76`** (la rama vigente; `main` y `release` están atrasadas); `MANI-Node` `develop` `f84dab7` (10 commits sobre `main`, que sigue revertida a `07069d3`); `MANI-APIGateway` rama `CFG-16` `b1b5048` (`main` `e312793`); `MANI-Java` `ae5d6ce` y `MANI-.NET` `e2e8370`, en `main`. `MANI-Infrastructure` ya no existe (borrado por DevOps).

### 7.2 Línea base: qué hace hoy el código

Los criterios se verificaron contra el comportamiento real del código, que difiere de lo descrito en el Backlog V3. Todos los hallazgos son por lectura de código; no se ejecutó nada contra QA ni contra producción.

| ID | Hallazgo | Evidencia |
|---|---|---|
| F1 | El registro de aliado persona natural **dejó de ir directo a Supabase** en `develop`: `registrarAliadoPersonaNatural` hace un `POST` multipart al Gateway en `/api/v1/core/auth/register/ally` (SCRUM-1061, ruta alineada al contrato en `25c2a76`). El Core ya implementa esa ruta en `MANI-Node` `develop` (M2), pero no está en `main` ni se confirmó su despliegue en QA. Antes de SCRUM-1061 solo se hacía `signUp` y se devolvía éxito sin invocar `registrar_aliado_persona_natural` ni subir archivos. El registro de cliente persona natural sigue directo con `signUp`, `.rpc()` y `.from()` | `lib/features/auth/data/datasources/auth_remote_data_source.dart` en `develop` |
| F2 | La ruta que arma el cliente es `kyc/<tenant>/cedula_<nombre>`; la política de Storage exige `<tenant_id>/<uid>/...` | `registro_aliado_page.dart`; política `kyc_isolation` en `database/migrations/007_normalizar_dominios.sql` |
| F3 | Antes del PR 34, el cliente enviaba `rol: 'ALIADO'` y `tenant_id` en la metadata del `signUp` y `handle_new_user` los tomaba de `raw_user_meta_data` (si faltaba el tenant, usaba uno fijo). Con M3, el registro de persona natural manda solo `email`, `password`, `nombre_completo` y `categoria_id`, y el tenant en el header `X-Tenant-Id` (el contrato v0.3.0 exige `X-Tenant-Slug`); el camino de cliente conserva el `signUp` directo. La RPC `registrar_aliado_persona_natural` recibe `p_tenant_id` por parámetro, es `SECURITY DEFINER` y tiene `GRANT` a `anon`. La definición solo está en `database/init`, no en `database/migrations`, por lo que la versión desplegada en QA no se pudo confirmar. PA-06 sigue abierto: hay que verificar si un `signUp` directo con rol o tenant ajeno aún crea ese usuario | `auth_remote_data_source.dart`; `database/init/04` y `05` |
| F4 | La interfaz exige solo la cédula; `RUT_CERTIFICADO` es opcional. No existe "antecedentes" en el código ni en el esquema, y no hay configuración de documentos requeridos por tenant, que RF-02 y RF-05 sí exigen | `registro_aliado_page.dart`; búsqueda en `lib/` y `database/` |
| F5 | Bucket privado `kyc-documentos` (10 MB; PDF, JPEG y PNG). La política `kyc_isolation` permite acceso si el tenant de la carpeta 1 coincide con el claim y la carpeta 2 es `auth.uid()` o el rol es `admin_tenant`. Solo se evalúa con el JWT de un usuario: un Core que use `service-role` la omite | `database/migrations/007`; `supabase/poc-cfg13/10_bucket_kyc.sql` |
| F6 | Los casos 1 a 5 de la colección usan PostgREST con tokens de usuario, no el Gateway, y recursos que no son de US-02.1.1 (`sitio`, `usuario`, `notificacion`). El caso 5 no incluye token expirado ni ausencia total de token. El control positivo del caso 3 modifica el propio KYC poniendo `estado: "aprobado"` | `mani-aislamiento.postman_collection.json`, carpetas 01 a 05 |
| F7 | En `database/init/04`, `documento_kyc` tiene `INSERT WITH CHECK (true)` y `SELECT USING (true)`. El aislamiento real depende de las políticas `tenant_isolation_*` de QA, cuyo estado actual no se pudo confirmar. CFG-23b (SCRUM-1104) las versiona | `database/init/04-supabase-rls-and-functions.sql` |
| F8 | `supabase_flutter` o `SupabaseClient` aparecen en 20 archivos de `lib/` en `develop` (`b8b917b`). Quedan llamadas `.rpc()`, `.from()` o `.storage.from()` en asignación, categorías, cobertura, verificación de aliados y el registro de cliente. El ADR-0027 conserva solo `supabase.auth`, de modo que esas llamadas deben retirarse | `git grep` sobre `origin/develop`, `lib/` |
| F9 | `MANI-Node` `develop` (`f84dab7`) ya implementa el registro de aliado persona natural (M2): `RegisterAllyNaturalPersonUseCase`, `auth.controller`, repositorios de Supabase para usuario, aliado, categoría y `documento_kyc`, servicio de almacenamiento de archivos, pruebas unitarias e integración, y acepta `X-Tenant-Slug` (ADR-0018). `main` sigue revertida a `07069d3` y el PR 13 de Node (M2) está abierto hacia `main`. El workflow `cd.yml` despliega solo con push a `main`; no existe rama `release` en Node | `MANI-Node` en `develop` y `.github/workflows/cd.yml` |
| F10 | Existe un precedente por el Gateway: `registrarAliadoEmpresa` (SCRUM-1060) hace un `POST` multipart a `/api/v1/core/aliados/empresa` mediante `GatewayClient` (SCRUM-1111). Hoy ambos registros de aliado envían el tenant en `X-Tenant-Id`, y el comentario del código dice que el Core construye la ruta de Storage. `GatewayClient` envía `Authorization: Bearer` si hay sesión y un `X-Correlation-ID` por petición | `auth_remote_data_source.dart` y `gateway_client.dart` en `develop` |
| F11 | El comentario de F10 fija la ruta de Storage como `tenant_id/aliado_id/documento` (ADR-0013), que es la que la política `kyc_isolation` deniega (PA-04) | `auth_remote_data_source.dart` en `develop`; `database/migrations/007` |
| F12 | El contrato v0.3.0 define el registro como `POST /auth/register/ally` en `multipart/form-data`: `fullName`, `email`, `password`, `categoriaId` y `cedula_ciudadania` obligatorios; `phone`, `documentType`, `documentNumber` y `rut_certificado` opcionales. Respuesta 201 con `profile` y `tokens`. Header de tenant `X-Tenant-Slug` obligatorio; `X-Tenant-Id` figura como alternativa interna. Errores `{ error, code, correlationId }` con `code` entre `VALIDATION_ERROR`, `TENANT_NOT_FOUND`, `CATEGORY_NOT_FOUND`, `EMAIL_ALREADY_REGISTERED`, `DOCUMENT_ALREADY_REGISTERED` y los de token. Los roles del perfil son `CLIENT`, `ALLY`, `ADMIN`, los estados `VERIFIED`, `PENDING`, `REJECTED`, y en el JWT `user_role` es `aliado`, `cliente` o `admin_tenant`. No define 403 ni 404, ni consulta de estado | `docs/openapi/core.yaml` en `MANI-APIGateway`, rama `CFG-16` |

Los hallazgos F2 a F7 se verificaron sobre `develop`: `database/`, `qa/newman/` y `registro_aliado_page.dart` no difieren de `main`.

Consecuencia: varias postcondiciones de los criterios originales (documentos en `<tenant_id>/<uid>/`, rechazo de documento faltante) son hoy comportamiento por construir, no regresión por revalidar. M4 (SCRUM-1062) debe tratarlas como tales.

### 7.3 Trazabilidad (PO-01a)

#### 7.3.1 Criterios originales frente a requisitos y casos

| Criterio | Origen | Requisito | Escenario nuevo | Caso cross-tenant | Estado en el código |
|---|---|---|---|---|---|
| O1. Registro exitoso con documentos en `<tenant_id>/<uid>/` y estado `PENDIENTE` | Backlog V3, escenario 1 | RF-05, REST-02 | A1 | Caso 6 (controles positivos) | No cumplido: F1 y F2 |
| O2. Falta un documento exigido y el registro se rechaza | Backlog V3, escenario 2 | RF-05, RF-02 | A2 | Ninguno | No existe la regla: F4 |
| O3. Un aliado no puede leer los documentos de otro aliado del mismo tenant | Backlog V3, escenario 3, regla crítica REST-02 | RF-05, RNF-01 | B6 | Caso 6 | La política `kyc_isolation` lo cubre en el camino directo: F5 |
| N1. El tenant, el rol y el estado no los fija el cliente | Nuevo | RF-03, RNF-01, ADR-0018 | A1 (V) y A3 | Casos 3 y 5 | Incumplido por diseño: F3 |
| N2. El cliente solo habla con el Gateway | Nuevo | `COMUNICACION_SERVICIOS_GATEWAY.md` | A4 | Caso 5 y CFG-36 | Incumplido para persona natural y cliente; cumplido en el cliente para empresa (F10) |
| N3. Respuesta con `correlation_id` | Nuevo | RNF-04, CFG-16 | A1 y A2 (respuestas) | No aplica | Sin contrato: PA-01 |

#### 7.3.2 Los seis casos frente a los recursos de US-02.1.1

| Caso | Recurso de la colección actual | Aplica a US-02.1.1 | Recurso propio de US-02.1.1 | Escenario |
|---|---|---|---|---|
| 1. Lectura | `sitio` | No | Registro y estado del aliado; fila de `documento_kyc` | B1 |
| 2. Listado | `sitio` y `usuario`; fila de `documento_kyc` en el complemento del caso 6 | Parcial | Documentos propios del aliado; usuarios y aliados del tenant | B2 |
| 3. Escritura, con variante de inserción | `documento_kyc` (PATCH) y `notificacion` (POST) | Parcial: `documento_kyc` sí | Documento KYC y registro de aliado con `tenant_id` ajeno | B3 |
| 4. Borrado | `documento_kyc` (DELETE negativo) y `notificacion` (control positivo) | Parcial | Documento KYC propio y ajeno | B4 |
| 5. Tokens alterados o expirados | `sitio` (GET) | El recurso no, el mecanismo sí | Endpoints privados de documentos y de estado | B5 |
| 6. KYC en Storage | `kyc-documentos` | Sí, completo | `<tenant_id>/<uid>/` | B6 |

### 7.4 DoR y DoD de M1 a M4 (PO-01a y PO-01b)

Base: `wiki/04-proceso/dor-y-dod.md` (DoR y DoD oficiales, DoD decidido por QA), los gates de ADR-0005 y la regla de los seis casos de `POLITICAS_DEVOPS_HERRAMIENTAS.md` sección 13.4.

Gates de ADR-0005 que aplican a todo código nuevo: 0 vulnerabilidades Blocker o Critical, 0 High conocidas abiertas en producción, cobertura de código nuevo >= 80 %, cobertura de casos críticos >= 90 %, duplicación de código nuevo < 3 %.

Los pasos M1 a M3 pertenecen a otros responsables. Lo siguiente es una **propuesta de borrador**: se ajusta con ellos (SCRUM-1130) y se actualiza cuando su trabajo esté subido al repositorio. El DoR y el DoD de M4 pertenecen a QA y se definen aquí.

#### 7.4.1 Estado actual y propuesta para M1 a M3

| Paso | Ticket y responsable | Problema del DoR y DoD actuales | DoR propuesto | DoD propuesto |
|---|---|---|---|---|
| M1 | CFG-16, SCRUM-1099 (Juan Sebastián Álvarez). No tiene ticket propio: CFG-16 lo sustituye | El DoD es de plantilla de código ("cobertura mayor al 80 %, desplegado en QA") y no encaja con un documento OpenAPI. El contrato v0.3.0 ya existe, pasa linter y vive en `MANI-APIGateway` (rama `CFG-16`), pero no define consulta de estado ni códigos de rechazo cross-tenant | Lista de operaciones acordada (registro, carga de documentos, estado). Borrador del modelo de identidad (CFG-23a) | Documento OpenAPI válido según linter. Revisado por par técnico y fusionado en `MANI-APIGateway`. Cubre el registro con documentos y declara qué contrato cubre la consulta de estado. Alineado con M2 y M3 en cabecera de tenant (`X-Tenant-Slug`), formato (multipart) y campos. Referenciado desde M2 y M3 |
| M2 | SCRUM-1065 (Juan Sebastián Álvarez) | El DoD no exige los seis casos y su cobertura (>80 %) no coincide con el gate de ADR-0005. El título y la justificación ya se actualizaron el 6 de octubre: el Core migra al servicio la lógica de `registrar_aliado_persona_natural`, `handle_new_user` y el upsert a `usuario` (ADR-0022) y deja de invocar las funciones PL/pgSQL. Por eso M2 reimplementa comportamiento y no solo cambia el llamador | Contrato CFG-16 publicado. Decisión de SP-05 registrada (daily del 5 de octubre) y ADR-0022 en `main` de `MANI-docs`, aún en estado Propuesto. Modelo de identidad CFG-23a aprobado. Criterios de aceptación validados por el PO | Gates de ADR-0005. Los seis casos con rechazo y control positivo, con el aislamiento demostrado en el Core (con `service-role` la política `kyc_isolation` no se evalúa, F5). Paridad con el comportamiento de la línea base, declarada en el reporte de M4. Pull Request aprobado y CI en verde. Contrato actualizado. Desplegado en QA |
| M3 | SCRUM-1061 (José Nicolás Álvarez) | El DoR pide diseño en Figma, que no aplica porque la UI no se toca. El DoD no pide ausencia de llamadas a `SupabaseClient`. El código ya está en `develop` (PR 34 y `25c2a76`) con la ruta del contrato, pero envía el tenant en `X-Tenant-Id` y no `X-Tenant-Slug`; el ticket está En revisión | Contrato OpenAPI publicado. `GatewayClient` (SCRUM-1111) disponible. Decisión de CFG-35 (ADR-0027 Aceptado). Se toma SCRUM-1060 como patrón | Ninguna llamada a `SupabaseClient`, `.rpc()`, `.from()` ni `.storage.from()` en `registrarAliadoPersonaNatural`, salvo `supabase.auth` (ADR-0027). El cliente no envía `rol`, `estado_verificacion` ni rutas de Storage, y envía el tenant en `X-Tenant-Slug`. Ruta y campos conformes al contrato publicado. Interfaz de `domain/repositories` sin cambios, o cambio aprobado por el PO. Pruebas unitarias del datasource, como las de SCRUM-1060. CI en verde. Código integrado por Pull Request |

#### 7.4.2 DoR de M4 (SCRUM-1062)

M4 puede iniciar solo cuando se cumplan las condiciones 1 a 7. Las condiciones 8 y 9 son recomendadas: su ausencia no impide iniciar, pero debe declararse en el reporte. SCRUM-1184 (M4a) las verifica con la lista de la sección 4.4.

1. M1 (CFG-16), M2 (SCRUM-1065) y M3 (SCRUM-1061) desplegados en QA y alcanzables a través del Gateway.
2. Esqueleto del Core desplegado en QA (CFG-20, SCRUM-1100).
3. JWT con claims de tenant y rol operativo entre Supabase Auth, Gateway y Core (CFG-22, SCRUM-1102).
4. Modelo de identidad aprobado (CFG-23a, SCRUM-1103) y políticas RLS del nuevo modelo aplicadas en QA (CFG-23b, SCRUM-1104).
5. Criterios de aceptación de este documento validados por el PO (SCRUM-1130).
6. Usuarios de prueba de dos tenants disponibles en QA.
7. Entorno de QA estable.
8. Recomendado: decisión de CFG-35 (SCRUM-1112) sobre la excepción de Supabase Auth, para cerrar el alcance de A4. Sin ella, A4 solo cubre REST, RPC y Storage (PA-07).
9. Recomendado: PA-06 verificado, es decir, saber si un registro con `rol` o `tenant_id` fijados desde el cliente crea un usuario con ese rol o en ese tenant.

#### 7.4.3 DoD de M4 (SCRUM-1062)

Base: DoD oficial de la wiki más los añadidos de los seis casos.

1. Regresión de US-02.1.1 ejecutada al 100 %, con el resultado esperado escrito antes de ejecutar.
2. Los seis casos cross-tenant (B1 a B6) con rechazo o ausencia de datos, cada negativo con su control positivo en la misma corrida.
3. Meta: control negativo ejecutable. Con el aislamiento del Core desactivado en un entorno de prueba, los negativos de B1 a B6 deberían fallar. Depende del Core (Juan) y no bloquea el cierre de M4; si no se logra, se declara en el reporte.
4. Ninguna petición del cliente a Supabase REST, RPC ni Storage, salvo la excepción que decida CFG-35.
5. Evidencia versionada y redactada (sin JWT ni llaves), con el enlace a la corrida de CI en verde.
6. Defectos registrados en Jira. Ningún defecto bloqueante abierto.
7. Reporte QA aprobado, socializado y vinculado a Jira y GitHub.
8. Documentación afectada actualizada (plan de pruebas de DOC-38, SCRUM-1094).

Según el ADR-0022 (decisión del equipo del 5 de octubre), el reporte de M4 es además el criterio que autoriza retirar las funciones PL/pgSQL que M2 reemplace: sin regresión aprobada, esas funciones no se retiran. El reporte debe decir qué funciones cubre.

#### 7.4.4 Lista de verificación go/no-go de M4 (SCRUM-1184)

| Ítem | Ticket | Dueño | Cumplido al 6 de octubre |
|---|---|---|---|
| Contrato OpenAPI publicado | SCRUM-1099 | Juan | Parcial: v0.3.0 en `MANI-APIGateway` rama `CFG-16`; CFG-16 En revisión; sin consulta de estado |
| Core desplegado en QA | SCRUM-1100 | Juan | Parcial: código en `develop` de `MANI-Node`; CFG-20 En revisión; `cd.yml` despliega solo desde `main`, que sigue revertida; no existe rama `release`; despliegue en QA no verificado |
| M2 desplegado en QA | SCRUM-1065 | Juan | Parcial: implementado en `develop` de `MANI-Node` (PR 13 de Node abierto hacia `main`); Jira En revisión con M2.1 a M2.4 por hacer; despliegue en QA no verificado |
| M3 desplegado en el build de QA | SCRUM-1061 | José | Parcial: código en `develop` (`25c2a76`); Jira En revisión; `release` de Flutter está atrasada; despliegue en QA no verificado; header `X-Tenant-Id` en vez de `X-Tenant-Slug` |
| JWT con claims operativo | SCRUM-1102 | Daniel | No |
| Modelo de identidad aprobado | SCRUM-1103 | Juan | No |
| Políticas RLS aplicadas en QA | SCRUM-1104 | Daniel | No |
| Decisión de SP-05 registrada y ADR-0022 publicado | SCRUM-1075 | María Camila | Sí: ADR-0022 fusionado en `main` (PR 11) con estado Propuesto; SCRUM-1075 Finalizada |
| `GatewayClient` en `develop` | SCRUM-1111 | José | Sí (PR 33 fusionado) |
| Excepción de Auth decidida (recomendado) | SCRUM-1112 | Daniel | Sí: ADR-0027 Aceptado conserva solo `supabase.auth`; CFG-35 sigue En curso en Jira |
| Criterios validados por el PO | SCRUM-1130 | Nicolás León | No |
| Usuarios de dos tenants en QA | Colección `mani-aislamiento` | Santiago | Por confirmar |
| PA-06 verificado (recomendado) | SCRUM-1062 | Santiago | No |

Los estados salen de Jira y de GitHub al 7 de octubre de 2026. JWT con claims (CFG-22), modelo de identidad (CFG-23a) y RLS (CFG-23b) siguen "Tareas por hacer". El DoR de M4 sigue sin cumplirse.

#### 7.4.5 Casos de regresión de M4 (SCRUM-1185)

Cada caso lleva el identificador del escenario en su nombre. El resultado esperado se escribe antes de ejecutar.

| Caso | Escenario | Herramienta | Se puede preparar sin QA desplegado |
|---|---|---|---|
| A1-P, A1-V | Registro exitoso e identidad fijada por el servidor | Newman (contrato) y Playwright (recorrido web) | Sí: pasos y resultados esperados. Las rutas se completan con CFG-16 |
| A2-N, A2-V | Documento faltante y ruta fuera de la carpeta | Newman | Sí, con la misma salvedad |
| A3-P, A3-N, A3-V | Tenant tomado del token | Newman | Sí, con la misma salvedad |
| A4-P, A4-N, A4-V | Solo Gateway, sin anon key y sin acceso directo | Playwright con captura de red, e inspección del bundle | Sí: la búsqueda de `SUPABASE_ANON_KEY` en el bundle se puede preparar hoy |
| B1, B2 | Lectura y listado | Newman | Parcial: usuarios y semillas sí, solicitudes al Gateway no |
| B3, B4 | Escritura y borrado | Newman | Parcial; también alimentan SCRUM-1187 y CFG-23c |
| B5 | Tokens inválidos | Newman | Sí, con la salvedad de las rutas |
| B6 | KYC en Storage | Newman y scripts de `qa/storage` | Sí para el camino directo; el camino por el Core espera PA-09 |

### 7.5 Escenarios de aceptación: camino funcional A1 a A4 (PO-01c)

**Condicional.** La Scrum Master debe confirmar si se requieren escenarios BDD completos o solo DoR y DoD. Si solo DoR y DoD, esta sección y la 6 se reducen a la tabla de la sección 4.5, con un título y un resultado esperado por caso.

Convención: P es el caso positivo, N el negativo y V el intento de violar la regla crítica. Los códigos HTTP concretos se fijan en el contrato de CFG-16 (PA-01). Mientras no exista, el rechazo se expresa como "403 o 404, nunca 200 con datos" y la falta de campos como "error de validación que identifica el campo".

El registro es el único endpoint público de la historia: el registrante todavía no tiene token, por lo que el tenant se resuelve antes de autenticar con la cabecera `X-Tenant-Slug` (ADR-0018 la permite solo para esa resolución, sin autorizar acceso a datos). El contrato v0.3.0 también usa `X-Tenant-Slug`, mientras Flutter envía `X-Tenant-Id` (PA-30). El claim `tenant_id` aparece **después** del registro, en el primer token. La carga posterior de documentos y la consulta de estado son privadas y toman el tenant solo del claim. El precedente de empresa (F10) manda el registro y los documentos en una sola petición multipart; para persona natural queda por confirmar en PA-02.

```gherkin
Característica: Registro de aliado persona natural con KYC por el camino Gateway - Core

Escenario A1-P: Registro exitoso con documentos privados
  Dado un tenant activo, identificado por la cabecera X-Tenant-Slug, que exige los documentos de su configuración para persona natural
  Cuando el aliado envía el registro con todos los documentos exigidos al Gateway
  Entonces el Gateway enruta la solicitud al Core
  Y el Core ejecuta la lógica del registro en el propio servicio, sin invocar funciones PL/pgSQL (ADR-0022)
  Y el aliado queda con estado_verificacion "PENDIENTE" en ese tenant, con el rol "aliado"
  Y cada documento queda en el bucket privado kyc-documentos bajo la ruta <tenant_id>/<uid>/
  Y existe una fila de documento_kyc por documento, con ruta_storage igual a la ruta real del objeto
  Y la respuesta incluye correlation_id y cumple el contrato de CFG-16
  Y el primer token del aliado trae el claim tenant_id de ese tenant y el rol "aliado"

Escenario A1-V: El cliente intenta fijar rol, estado o tenant ajeno
  Dado un registro cuyo cuerpo o metadata incluye rol "ADMIN_TENANT", estado_verificacion "VERIFICADO" o un tenant_id distinto del que resuelve X-Tenant-Slug
  Cuando el Core procesa la petición
  Entonces esos valores se ignoran o la petición se rechaza (PA-05)
  Y el usuario creado, si existe, es un aliado en estado "PENDIENTE" en el tenant resuelto
  Y no queda ningún registro en el tenant ajeno
```

El escenario A1-V traslada a criterio la regla crítica que hoy no se cumple por lectura de código (F3). La verificación en QA debe confirmarla o descartarla antes de la regresión (PA-06).

```gherkin
Escenario A2-N: Falta un documento exigido
  Dado un tenant que exige un documento que el aliado no adjunta
  Cuando el aliado envía el registro
  Entonces el registro se rechaza con un error que identifica el documento faltante
  Y la respuesta de error incluye correlation_id y no expone detalles internos de PL/pgSQL ni de Supabase
  Y no queda usuario, aliado, fila de documento_kyc ni objeto en Storage
  Y el mismo registro con todos los documentos tiene éxito (control positivo: A1-P)

Escenario A2-V: Ruta de documento fuera de la carpeta del aliado
  Dado un registro con una ruta o un nombre de archivo que apunta a otro tenant u otro uid
  Cuando el Core procesa el registro
  Entonces el servidor construye la ruta <tenant_id>/<uid>/ por sí mismo o rechaza la petición
  Y no se escribe ningún objeto fuera de la carpeta del propio aliado
```

A2-N materializa el criterio original O2. La regla "cédula y antecedentes" del Backlog V3 no existe en el código (F4): el documento exigido depende de la configuración del tenant (RF-02), cuya fuente no está definida (PA-03).

```gherkin
Escenario A3-P: El tenant se resuelve por slug en el registro y por token en lo privado
  Dado un registro público con X-Tenant-Slug de un tenant activo
  Cuando el Core crea al aliado
  Entonces el aliado queda en ese tenant y el primer token trae el claim tenant_id de ese tenant
  Dado un aliado autenticado en el tenant 1
  Cuando sube un documento o consulta su estado por el Gateway
  Entonces el Core usa únicamente el claim tenant_id del token
  Y la operación afecta solo registros del tenant 1 y de su propio uid

Escenario A3-N: Tenant inexistente o inactivo, o petición privada sin token válido
  Dado un registro con un X-Tenant-Slug que no existe o no está activo
  Cuando el aliado envía el registro
  Entonces el registro se rechaza, no se asigna ningún tenant por defecto y no se crea usuario, aliado ni documento
  Dada una petición privada sin token, con token expirado o con firma alterada
  Cuando llega al Gateway
  Entonces la petición se rechaza con 401, sea en el Gateway o en el Core según lo que decida PA-16, y no se accede a ningún dato

Escenario A3-V: El cliente intenta fijar otro tenant
  Dado un registro con X-Tenant-Slug del tenant 1 y un tenant_id del tenant 2 en el cuerpo
  Cuando el Core procesa el registro
  Entonces el cuerpo se ignora o la petición se rechaza (PA-05) y no queda nada en el tenant 2
  Dado un aliado autenticado en el tenant 1
  Cuando envía una operación privada con el tenant 2 en el cuerpo o en la cabecera X-Tenant-Slug
  Entonces el Core usa el claim tenant_id del token y nada se escribe ni se lee en el tenant 2
```

```gherkin
Escenario A4-P: Recorrido completo solo por el Gateway
  Dado el build de Flutter desplegado en QA
  Cuando se ejecuta el recorrido de registro y de carga de documentos
  Entonces todas las peticiones de negocio del cliente van al Gateway
  Y ninguna petición va a Supabase REST (rest/v1), RPC ni Storage desde el cliente

Escenario A4-N: El bundle no entrega credenciales de acceso directo
  Dado el artefacto web publicado en QA
  Cuando se inspecciona su contenido y su tráfico de red
  Entonces no incluye SUPABASE_ANON_KEY ni la llave de servicio (CFG-36)

Escenario A4-V: Acceso directo a Supabase con el token del aliado
  Dado un aliado con sesión válida
  Cuando intenta leer o escribir aliado y documento_kyc directamente en Supabase REST o Storage
  Entonces el acceso se deniega o no existe ruta para hacerlo
```

La excepción de Supabase Auth para el inicio de sesión queda sujeta a CFG-35 (SCRUM-1112): A4 solo prohíbe REST, RPC y Storage, y debe ajustarse si CFG-35 decide otra cosa (PA-07).

### 7.6 Escenarios de aceptación: los seis casos cross-tenant B1 a B6 (PO-01c)

Se ejecutan en QA a través del Gateway, con tokens de usuarios de dos tenants. La colección `mani-aislamiento` ya aporta los usuarios de prueba y los casos 5 y 6 de Storage, pero llama directo a PostgREST y a Storage (F6): debe agregar solicitudes contra el Gateway y conservar las actuales como defensa en profundidad. Usuarios de la colección: `aliado.t1`, `aliado.t2`, `admin.t1`, `admin.t2`, `cliente.t1` y `hook.t1` (segundo aliado del tenant 1).

Regla de lectura de los negativos: el rechazo es 403 o 404, o ausencia total de datos ajenos; nunca 200 con datos del otro tenant. Cada negativo tiene su control positivo y solo es válido si el control pasa en la misma corrida.

```gherkin
Escenario B1 (caso 1, lectura)
  Cuando aliado.t1 consulta por el Gateway el registro o el estado de un aliado del tenant 2
  Entonces la respuesta es 403 o 404 y no contiene ningún dato del aliado del tenant 2
  Y la misma consulta sobre su propio registro devuelve 200 con su estado (control positivo)

Escenario B2 (caso 2, listado)
  Cuando aliado.t1 lista sus documentos KYC y admin.t1 lista los aliados y documentos de su tenant
  Entonces ninguna fila pertenece al tenant 2
  Y el aliado no ve documentos de otro aliado del tenant 1
  Y cada listado devuelve al menos una fila propia (control positivo)

Escenario B3 (caso 3, escritura)
  Cuando aliado.t1 intenta reemplazar o modificar el documento KYC o el estado de un aliado del tenant 2
  Entonces la petición se rechaza o afecta 0 filas y el registro del tenant 2 queda intacto, comprobado con una lectura posterior de admin.t2
  Y aliado.t1 puede reemplazar su propio documento mientras su estado es "PENDIENTE" (control positivo; PA-08)
  Y una petición con un tenant_id ajeno en el cuerpo se rechaza o ignora, sin crear nada en el tenant 2 (variante de inserción)
  Y aliado.t1 no puede cambiar el estado de su propio documento ni de su propio aliado: recibe 403 y el estado no cambia

Escenario B4 (caso 4, borrado)
  Cuando aliado.t1 intenta borrar un documento KYC del tenant 2
  Entonces la petición se rechaza o afecta 0 filas y el documento sigue existiendo, comprobado con admin.t2
  Y aliado.t1 puede retirar su propio documento mientras está "PENDIENTE" (control positivo; PA-08)

Escenario B5 (caso 5, tokens inválidos)
  Cuando se llama a un endpoint privado de documentos o de estado con un token con tenant_id reescrito, con la firma alterada, expirado o sin cabecera Authorization
  Entonces cada variante se rechaza con 401, sea en el Gateway o en el Core según lo que decida PA-16, y no se devuelve ninguna fila
  Y la misma llamada con un token válido de aliado.t1 devuelve 200 (control positivo)

Escenario B6 (caso 6, KYC en Storage)
  Dado documentos KYC de aliado.t1 en <tenant_id>/<uid>/
  Cuando aliado.t2, admin.t2, hook.t1, cliente.t1 o un anónimo intentan descargar, firmar, listar o subir sobre esa ruta
  Entonces todas las operaciones se deniegan y no se filtra ni el archivo ni una URL firmada
  Y aliado.t1 descarga, firma y lista su propia cédula, y admin.t1 descarga y firma la cédula de un aliado de su tenant (controles positivos)
  Y una URL firmada con firma alterada, reutilizada sobre otra ruta o usada después de su TTL se rechaza
```

Alternativa para los controles positivos de B3 y B4 (PA-08): si el PO decide que el aliado no puede reemplazar ni retirar un documento propio en estado "PENDIENTE", el control positivo de ambos escenarios pasa a ser que aliado.t1 lee y lista su propio documento con 200. Los negativos no cambian.

Detalle de ejecución del caso 6:

1. Camino por el Gateway: la descarga o el acceso temporal que entrega el Core (mecanismo de SCRUM-1066 CA-2 y CFG-23a, PA-09) se prueba con los mismos actores.
2. Camino directo a Storage: las solicitudes N1 a N11 de la colección se mantienen como regresión, porque mientras la anon key esté publicada (CFG-36) un atacante puede llamar a Supabase sin pasar por el Gateway.
3. El control C1 de la colección documenta que una URL firmada filtrada funciona hasta su TTL. El criterio exige que el TTL no supere el valor que fije CFG-23a (la colección usa 60 s; PA-09).
4. Solo los actores del tenant 2 prueban aislamiento entre tenants. `hook.t1` y `cliente.t1` pertenecen al tenant 1 y cubren el criterio O3 y la regla de que un cliente no ve KYC. La colección no incluye hoy un cliente del tenant 2.

### 7.7 Condición de aceptación (PO-01d)

US-02.1.1 se acepta solo si se cumplen todas estas condiciones:

1. Los escenarios B1 a B6 se ejecutan en QA a través del Gateway, con el 100 % de los negativos rechazados y el 100 % de los controles positivos exitosos (ADR-0015). Un negativo cuyo control positivo falló no cuenta como pasado.
2. El caso 6 se ejecuta por los dos caminos: acceso temporal del Core y acceso directo a Storage.
3. Los escenarios A1 a A4 pasan en QA sobre el build desplegado, incluido A1-V (rol y tenant no fijados por el cliente).
4. Meta: la suite incluye un control negativo ejecutable. Con el aislamiento del Core desactivado en un entorno de prueba, los negativos de B1 a B6 deberían fallar; si no pueden fallar, no validan nada. No bloquea la aceptación, pero su ausencia se declara en el reporte.
5. La evidencia se versiona redactada (sin JWT ni llaves; el redactor `qa/newman/redactar_evidencia.mjs` falla si sobrevive un JWT) junto con el enlace a la corrida de CI en verde, y cada prueba lleva el identificador del escenario en su nombre (A1-P, B3, etc.).
6. Las dependencias están desplegadas en QA antes de ejecutar: CFG-16 (SCRUM-1099), CFG-17 (SCRUM-1101), CFG-20 (SCRUM-1100), CFG-22 (SCRUM-1102), CFG-23a y CFG-23b (SCRUM-1103 y 1104), M2 (SCRUM-1065) y M3 (SCRUM-1061).
7. Cualquier defecto se registra en Jira y no se acepta con una excepción sin aprobación del PO.

Si las dependencias del punto 6 no llegan a QA antes del cierre del sprint, la aceptación no se declara: se registra como incremento no entregado, con causa, impacto, estado y decisión de replanificación (`GOBIERNO_DEL_EQUIPO.md`, sección 10).

### 7.8 Puntos abiertos

| ID | Punto abierto | Responsable sugerido y ticket |
|---|---|---|
| PA-01 | Resuelto en lo esencial: el contrato v0.3.0 existe en `MANI-APIGateway` (rama `CFG-16`, `b1b5048`) con rutas, errores y registro multipart con documentos. Siguen faltando la consulta de estado y los códigos de rechazo cross-tenant (403 o 404), y que se fusione (CFG-16 En revisión) | Juan Sebastián Álvarez, SCRUM-1099 y SCRUM-1202 |
| PA-02 | Si el registro y la carga de documentos son una sola petición o dos para persona natural. El precedente de empresa (F10) usa una sola petición multipart, y su método recibe `documentosKYC` como `List<Map<String, String>>` con `contenido_base64`, el mismo tipo que usa persona natural. Eso sugiere que la interfaz del repositorio no necesita cambiar, solo lo que la página pone en cada mapa (contenido en lugar de rutas). Falta que José lo confirme | José Nicolás Álvarez y Juan Sebastián Álvarez, SCRUM-1061 y SCRUM-1065; decisión de fondo en CFG-35 |
| PA-03 | Documentos requeridos por tenant. **Supuesto adoptado:** cédula obligatoria y RUT opcional, según el contrato v0.3.0; "antecedentes" no existe en el código ni en el contrato. Falta la configuración por tenant (RF-02), que el `AGENTS.md` de `MANI-Java` atribuiría al servicio de reglas | Nicolás León (PO), con Juan Sebastián Álvarez |
| PA-04 | Ruta de Storage. **Supuesto adoptado:** `tenant_id/aliado_id/documento`, construida por el Core (ADR-0013 y comentario del código de Flutter). La política `kyc_isolation` y la colección usan `<tenant_id>/<uid>/` y la solicitud N11 deniega la ruta con `aliado.id`: hay que alinear la política (CFG-23b) o los casos B6 | Juan Sebastián Álvarez, Daniel Ávila y María Camila Beltrán |
| PA-05 | `tenant_id` ajeno en el cuerpo. **Supuesto adoptado:** el cuerpo se ignora y el tenant sale de `X-Tenant-Slug` (contrato v0.3.0 y ADR-0018); los casos exigen que no quede nada en el tenant ajeno, se ignore o se rechace. Sara Albarracín lo registra con María Camila Beltrán | Sara Albarracín y María Camila Beltrán |
| PA-06 | Verificar en QA, antes de la regresión, si un registro con `rol` o `tenant_id` fijados desde el cliente crea un usuario con ese rol o en ese tenant (F3). Es una lectura de código no ejecutada | Santiago, SCRUM-1062; si se confirma, abrir defecto en Jira |
| PA-07 | Resuelto por el ADR-0027 (Aceptado): Flutter conserva solo `supabase.auth`. Queda la tensión con el contrato, donde el Core registra al aliado y emite los tokens (PA-33) | Daniel Ávila, SCRUM-1112 |
| PA-08 | Documento propio en estado PENDIENTE. **Supuesto adoptado:** se usa la alternativa de la sección 6: el control positivo de B3 y B4 es que `aliado.t1` lee y lista su propio documento. El contrato no define reemplazo ni retiro. El control positivo actual de la colección pone el KYC en `aprobado` (auto-aprobación) y debe eliminarse | Nicolás León (PO), con SCRUM-1062 |
| PA-09 | Mecanismo y TTL del acceso temporal a documentos KYC cuando el llamador es el Core (SCRUM-1066 CA-2 lo deja "según diseño de CFG-23a"). Con `service-role` la política `kyc_isolation` no se evalúa (F5): el aislamiento debe demostrarse en el Core | Juan Sebastián Álvarez, SCRUM-1103 |
| PA-10 | La colección debe ampliarse: solicitudes contra el Gateway para los casos 1 a 5 sobre recursos de US-02.1.1, token expirado y ausencia total de token en el caso 5, un cliente del tenant 2 en el caso 6 y reemplazo del control positivo del caso 3 | Santiago, SCRUM-1105 (CFG-23c) y SCRUM-1120 (QA-03) |
| PA-11 | Resuelto: la lógica vive en los servicios (decisión del 5 de octubre). El ADR-0022 está en `main` desde el PR 11, aunque con estado Propuesto, y SCRUM-1075 está Finalizada. Los títulos de SCRUM-1063, 1064 y 1065 ya lo reflejan | María Camila Beltrán (SCRUM-1075) |
| PA-12 | Los escenarios originales del Backlog V3 cubren US-02.1.1 y US-02.1.2 en un mismo bloque; este documento solo cubre persona natural. La variante de empresa queda en PO-05 | Nicolás León (PO), SCRUM-1083 |
| PA-13 | Resuelto: `BACKLOG_MANI.md` §3.6 crea las historias de regresión `US-02.1.2-M4` y `US-02.2.1-M4` en el Incremento 2 | Nicolás León (PO) |
| PA-14 | Destino de publicación. **Supuesto adoptado:** `product/` en `MANI-docs`, donde Sara Albarracín aprobó el documento. El Backlog V4 ya no existe | Sara Albarracín |
| PA-15 | Escenarios BDD. **Supuesto adoptado:** se conservan A1 a A4 y B1 a B6 completos, tal como Sara Albarracín los aprobó | Sara Albarracín |
| PA-16 | Quién valida el JWT. **Supuesto adoptado:** lo valida el Core (contrato v0.3.0: el Core verifica la firma y extrae `tenant_id` y `user_role` de `app_metadata`) y el Gateway lo reenvía sin consumirlo (`CLAUDE.md` de `MANI-APIGateway`). El ADR-0018 aún dice que el Gateway lo valida inicialmente y debe corregirse | Daniel Ávila y Juan Sebastián Álvarez, con CFG-22 (SCRUM-1102) |
| PA-17 | Resuelto por el contrato: error `{ error, code, correlationId }` con catálogo de `code`. Falta que todas las respuestas del Core lo cumplan (el 404 de la versión anterior no llevaba `correlationId`) | Juan Sebastián Álvarez, SCRUM-1099 |
| PA-29 | Resuelto en parte: el contrato v0.3.0 sí incluye documentos KYC dentro del registro multipart. Siguen sin existir la consulta de estado y la carga posterior de documentos, así que B1 y B2 sobre estado y listado de documentos no tienen endpoint. Los puntos PA-18 a PA-28 los usa el plan de pruebas de EP-02 (PR 15) y no se repiten aquí | Juan Sebastián Álvarez, SCRUM-1099 |
| PA-30 | Cabecera de tenant en el registro: el contrato v0.3.0 y el ADR-0018 exigen `X-Tenant-Slug` (Node ya lo acepta, `f84dab7`), pero Flutter `develop` envía `X-Tenant-Id` y el contrato aún lo lista como alternativa interna. El `nginx.conf` del Gateway no resuelve tenant | José Nicolás Álvarez y Juan Sebastián Álvarez |
| PA-31 | Resuelto en la ruta: Flutter usa `/api/v1/core/auth/register/ally`, la del contrato. Queda comprobar que los nombres de los campos multipart coinciden (`fullName`, `categoriaId`, `cedula_ciudadania` en el contrato; Flutter armaba `nombre_completo` y `categoria_id`) | José Nicolás Álvarez y Juan Sebastián Álvarez |
| PA-32 | Valores del contrato frente al proyecto: perfil con `CLIENT`, `ALLY`, `ADMIN` y estados `PENDING`, `VERIFIED`, `REJECTED`, mientras el claim `user_role` usa `aliado`, `cliente`, `admin_tenant`, y el JSON está en camelCase frente a la regla de snake_case del proyecto | Juan Sebastián Álvarez, con Nicolás León |
| PA-33 | El ADR-0027 deja `signUp` de Supabase en el cliente, pero el contrato hace que el Core registre al aliado y emita los tokens, y M3 ya envía el registro al Gateway. Hay que fijar quién crea el usuario en Supabase Auth | Daniel Ávila y Juan Sebastián Álvarez |

#### 7.8.1 Supuestos adoptados el 7 de octubre de 2026

No hubo tiempo de consultar a los responsables antes del cierre del sprint. Por decisión de QA se adoptó lo que dice la documentación vigente. Cada supuesto indica su fuente y puede revertirse si el responsable decide otra cosa.

| Punto | Supuesto | Fuente |
|---|---|---|
| PA-03 | Cédula obligatoria y RUT opcional | Contrato v0.3.0 |
| PA-04 | Ruta `tenant_id/aliado_id/documento`, construida por el Core | ADR-0013 y código de Flutter |
| PA-05 | El `tenant_id` del cuerpo se ignora; el tenant sale de `X-Tenant-Slug` | Contrato v0.3.0 y ADR-0018 |
| PA-07 | Flutter conserva solo `supabase.auth` | ADR-0027 |
| PA-08 | Control positivo de B3 y B4: leer y listar el propio documento | Alternativa de la sección 6; sin fuente que lo contradiga |
| PA-11 | La lógica vive en los servicios | ADR-0022 (en `main`, Propuesto) |
| PA-13 | La regresión de las otras historias está cubierta por `US-02.1.2-M4` y `US-02.2.1-M4` | `BACKLOG_MANI.md` §3.6 |
| PA-14 | Destino: `product/` en `MANI-docs` | Aprobación de Sara Albarracín |
| PA-15 | Escenarios completos | Aprobación de Sara Albarracín |
| PA-16 | El Core valida el JWT y devuelve los 401 | Contrato v0.3.0 y `CLAUDE.md` del Gateway |
| PA-17 | Error `{ error, code, correlationId }` | Contrato v0.3.0 |

Siguen abiertos porque la documentación no los resuelve: PA-02, PA-06, PA-09, PA-30, PA-31, PA-32 y PA-33, y la falta de un endpoint de consulta de estado (PA-29).

### 7.9 Solapes con PO-05 (SCRUM-1083)

PO-05 cubre US-02.1.2-M2/M3, US-02.1.3-M2 y US-02.2.1-M2, no US-02.1.1. La descripción de SCRUM-1083 en Jira no contiene criterios comunes. El borrador anterior citaba criterios CC-1 a CC-4 de un comentario del 5 de octubre.

**Alineación cerrada el 7 de octubre de 2026** con María Camila Beltrán en SCRUM-1130, que quedó en `Done`. El tratamiento de la tabla es el acordado, no una propuesta pendiente.

| Escenario de PO-01 | Tema | Tratamiento acordado |
|---|---|---|
| A4 (solo Gateway) | CC-1, según el borrador anterior | Mantener un único texto y referenciarlo desde ambas historias. A4-N y A4-V (anon key y acceso directo) son aportes propios |
| A3 (tenant por token, 401 sin token) | CC-2 y CC-3 | Mantener un único texto. El registro de US-02.1.1 es público y no entra en CC-2 ni CC-3; A3-N lo cubre |
| `correlation_id` en A1 y A2 | CC-4 | Alinear el nombre del campo con CFG-16 |
| B1 a B6 por historia | CA-5 de SCRUM-1063 y CA-7 de SCRUM-1066 | US-02.1.1 cubre el KYC y el registro del aliado; SCRUM-1066 cubre la bandeja y la aprobación. Ejecutar el caso 6 una vez y referenciarlo desde ambas historias |

### 7.10 Revisores

Revisión cerrada el 7 de octubre de 2026 (SCRUM-1130, en `Done`). La revisión del par técnico quedó registrada en el PR #13 de `MANI-docs`, fusionado a `main`.

| Revisor | Motivo |
|---|---|
| Nicolás León (PO) | Decide los criterios de aceptación. Resuelve PA-03, PA-08 y PA-13 |
| Sara Albarracín (Scrum Master, par técnico) | Revisa el documento como DoD de SCRUM-1076. Resuelve PA-14 y PA-15. Unifica con PO-05 (PA-05) |
| Juan Sebastián Álvarez (dueño de CFG-16, CFG-23a y M2) | Ajusta el DoR y el DoD de M1 y M2. Resuelve PA-01, PA-02, PA-09 y PA-11 |
| José Nicolás Álvarez (dueño de M3) | Ajusta el DoR y el DoD de M3. Resuelve PA-02 |
| María Camila Beltrán (PO-05 y DOC-26) | Evita duplicar criterios comunes. Reconcilia la ruta de Storage (PA-04) |
| Nota | `MANI-Infra` sigue nombrado en ADR-0004, SAD, SDD, README y wiki, aunque el repositorio ya no existe. Pasa por María Camila Beltrán (documentación) |
| Daniel Ávila (DevOps) | Confirma la ejecución en CI. Resuelve PA-07 y PA-16, y las fechas de CFG-22 y CFG-23b |

### 7.11 Cambios propuestos en Jira (no ejecutados)

Estado verificado el 7 de octubre de 2026: ninguno de los ajustes de abajo se ha aplicado. Siguen en su valor anterior SCRUM-1062 (`Low`), SCRUM-1065 (`High`), SCRUM-1102, SCRUM-1103, SCRUM-1112 y SCRUM-1116 (`Medium`), SCRUM-1104 (`Low`) y SCRUM-1118 (`High`), y los títulos de SCRUM-1075 y SCRUM-1099 conservan el error señalado.

| Ticket | Propuesta |
|---|---|
| SCRUM-1062 y 1184 a 1188 | Prioridad Low a Highest. El backlog fija M4 en Highest |
| SCRUM-1065 | Prioridad High a Highest. Sustituir el DoD por el de la sección 4.1. Sus subtareas SCRUM-1207 a 1210 siguen "Tareas por hacer" aunque la historia está En revisión: moverlas según el avance real |
| SCRUM-1075 | Corregir el título, que aún dice que los servicios invocan las funciones PL/pgSQL. Pasa por María Camila Beltrán |
| SCRUM-1061 | Cerrar cuando José confirme su DoD: el código ya está en `develop` (PR 34) y el ticket sigue "Tareas por hacer". Reconciliar ruta y campos con el contrato (PA-31) |
| SCRUM-1099 | Revisión por pares y fusión del contrato; añadir los documentos KYC o indicar qué contrato los cubre (PA-29) |
| SCRUM-1061 | Quitar "Diseño en Figma" del DoR. Añadir la ausencia de llamadas a `SupabaseClient` al DoD |
| SCRUM-1099 | Corregir el título ("Gateway con Js acotado PARA a identidad"). Sustituir el DoD de código por el de documento OpenAPI |
| SCRUM-1102, 1103, 1104 y 1112 | Prioridad Medium o Low a Highest, como en el backlog |
| SCRUM-1116 (CFG-41) | Prioridad Medium a Highest, como en el backlog |
| SCRUM-1118 (QA-01) | Prioridad High a Highest, como en el backlog |
| SCRUM-1126 a 1129 | ~~Pasar a "En curso"~~ Ya no aplica: PO-01a a PO-01d quedaron en `Done` el 7 de octubre de 2026 con el merge del PR #13 |
| SCRUM-1076 | Corregir el destino "Backlog V4" una vez responda la Scrum Master |
| Enlaces | Verificar enlaces "bloquea" entre 1099, 1065, 1061 y 1062, y entre 1103, 1104, 1102 y 1105. No se pudieron leer los enlaces existentes |

### 7.12 Cambios respecto al borrador anterior

- Los escenarios de la historia son A1 a A4; se eliminó A5 y su contenido (`correlation_id`) pasó a A1 y A2.
- Se añadió la sección 4 con el DoR y el DoD de M1 a M4, la lista go/no-go y los casos de regresión de M4.
- Se eliminaron las citas a `BACKLOG_MANI_V4_TRANSICION`, al Documento de Herramientas V3 y a ADR-0026, y se sustituyeron por la wiki y `BACKLOG_MANI.md`.
- Se eliminó el punto abierto sobre la numeración de ADR-0025 y ADR-0026, y se añadieron PA-11 y PA-13 a PA-15.
- Se añadieron los hallazgos F8 y F9 y se ajustó F7.
- Tras la revisión del 6 de octubre: las condiciones 8 y 9 del DoR de M4 pasan a recomendadas, el control negativo ejecutable pasa a meta, se añade la alternativa de los controles positivos de B3 y B4 (PA-08) y se mantiene la evidencia con enlace a CI como requisito.
- Actualización del 6 de octubre tras sincronizar los siete repositorios: la revisión de Flutter pasa de `main` a `develop` (`1f4c843`). Se corrige F8 (20 archivos, no 10), se confirma F3 por el lado del cliente y se añaden F10 y F11 (precedente de empresa por el Gateway y ruta de Storage). A1 y A3 nombran `X-Tenant-Slug` en el registro y el claim en lo privado. Se ajustan los DoR y DoD de M1 a M3, PA-01, PA-02 y PA-04. PA-11 se reformula por el ADR-0022 (Propuesto), y el reporte de M4 se vuelve el criterio para retirar las funciones PL/pgSQL si ese ADR se acepta.
- Actualización del 6 de octubre, por lo publicado por María Camila Beltrán: SCRUM-1063, 1064 y 1065 ya dicen que el Core migra la lógica al servicio (ADR-0022). A1 deja de ser ambiguo, la paridad de M4 pasa a regla vigente, PA-11 queda como "decidido, falta publicar el ADR" y se añade que SCRUM-1075 conserva el título anterior. `MANI-Infrastructure` ya no existe (borrado por DevOps).
- Actualización del 6 de octubre tras leer los `AGENTS.md` y `CLAUDE.md` de los repos: los 401 de A3-N y B5 ya no se atribuyen solo al Gateway (PA-16). Se añaden PA-16 y PA-17, la hipótesis de las reglas por tenant en PA-03 y la confirmación de que `MANI-Infrastructure` fue borrado por DevOps.
- Actualización del 7 de octubre tras el aviso de SCRUM-1202: el contrato OpenAPI borrador v0.2.0 ya existe y llena rutas, errores y formato de error; deja fuera los documentos KYC y difiere de Flutter (F12, PA-29 a PA-33). M3 está en `develop` (F1, F3, F8), el Core tiene esqueleto sin ruta de registro (F9) y el ADR-0027 está Aceptado (PA-07). PA-16 y PA-17 quedan confirmados por el contrato. Los puntos nuevos empiezan en PA-29 para no chocar con el plan de EP-02.
- Actualización del 7 de octubre contra GitHub y Jira: el contrato pasó a la v0.3.0 y vive en `MANI-APIGateway` (multipart con documentos KYC, `X-Tenant-Slug`); M2 está implementado en `develop` de `MANI-Node`; Flutter alineó la ruta del registro pero envía `X-Tenant-Id`; el ADR-0022 está en `main` como Propuesto y el backlog crea las historias de regresión de EP-02. Se añadió la sección 8.1 con los supuestos adoptados en lugar de consultar a los responsables, y se cerraron PA-11, PA-13 y PA-17, y en parte PA-01, PA-29 y PA-31.

---

## 8. Backlog técnico en GitHub: estado verificado e issues propuestos del cierre del Sprint 4

> Fusionado desde `backlog/BACKLOG_GITHUB_SPRINT4_PROPUESTA.md` el 22 de octubre de 2026. Sigue siendo una propuesta: ningún issue se ha creado en GitHub. Las referencias internas de este bloque que dicen «§N» corresponden a §8.N de este documento.

| Campo | Valor |
|---|---|
| Propósito | Verificar el estado real de los issues de GitHub en los siete repositorios, distinguir el trabajo ya implementado del pendiente y dejar listos para registro los issues de los hallazgos bloqueantes de QA |
| Presenta | Sara Albarracín |
| Corte de la verificación | 20 de octubre de 2026 |
| Alcance | Organización `Trama-AS`: MANI-docs, MANI-Node, MANI-.NET, MANI-Java, MANI-Flutter, MANI-APIGateway, MANI-Landing |
| Fuentes | `gh issue list` y `gh pr list` sobre los siete repositorios; código de `release` y `develop` de MANI-Node, MANI-APIGateway y MANI-.NET; [reporte de monitoreo QA](../07-calidad/REPORTE_QA_SPRINT4.md#7-monitoreo-de-qa-y-escenarios-qas-01-a-qas-09-scrum-1266) (SCRUM-1266) y [reporte de regresión](../07-calidad/REPORTE_QA_SPRINT4.md#8-regresión-funcional-api-e2e-y-multi-tenant-scrum-1267) (SCRUM-1267) |
| Estado | Propuesta. Ningún issue se ha creado en GitHub; los borradores de §4 esperan aprobación |

> Este documento no registra hallazgos nuevos ni cambia estados históricos. Los hallazgos son los de
> SCRUM-1266 y SCRUM-1267; aquí se verifica cuáles siguen vigentes en el código y qué unidad de
> trabajo corresponde a cada uno.

### 8.1 Estado verificado de GitHub

**Los siete repositorios tienen cero issues**, incluidos los cerrados (`gh issue list --state all`,
20 de octubre de 2026). El seguimiento vive en Jira y en los pull requests.

La organización **no tiene ningún GitHub Project**, y los siete repositorios conservan solo las
etiquetas por defecto de GitHub (`bug`, `documentation`, `enhancement`, `duplicate`, `invalid`,
`question`, `wontfix`, `help wanted`, `good first issue`, `accessibility`). El modelo de trabajo que
se pretende administrar en GitHub —estados *bloqueado*, *listo*, *en curso*, *en revisión* y
*terminado*, prioridades, dependencias y responsables— **no existe todavía como estructura**. Antes
de crear issues hace falta decidir:

1. Un proyecto único cross-repo (recomendado, porque los hallazgos cruzan repositorios) o uno por
   repositorio.
2. Los campos del proyecto: estado, prioridad, componente, referencia Jira, dependencia.
3. Un conjunto mínimo de etiquetas: `seguridad`, `qa`, `devops`, `deuda-tecnica`, `multi-tenant`,
   `adr`, `prioridad:highest|high|medium|low`.

Esa decisión no está tomada y no se asume en este documento.

### 8.2 Las referencias de trabajo existente son pull requests, no issues

Las referencias que circulan como «MANI-Node #43» o «MANI-.NET #1» son **números de pull request**.
Todas están fusionadas, así que ninguna genera un issue nuevo.

| Referencia | Qué es | Jira | Estado |
|---|---|---|---|
| MANI-Node #43 | Endpoints de elegibilidad, contexto de solicitud y notificaciones para Dispatch | SCRUM-1073 | Fusionado el 19 de octubre |
| MANI-Node #44 | Creación de la solicitud de servicio en Core, separada del despacho | SCRUM-1072 | Fusionado el 19 de octubre |
| MANI-Node #46 | El filtro por tipo de la elegibilidad acepta `EMPLEADO_DIRECTO` | SCRUM-862 | Fusionado el 19 de octubre |
| MANI-.NET #1 | Exclusión concurrente en la aceptación de solicitudes | SCRUM-1074 | Fusionado el 19 de octubre |
| MANI-.NET #2 | Orquestación de despacho a aliados elegibles | SCRUM-1073 | Fusionado el 19 de octubre |
| MANI-.NET #3 | Consulta de aliados válidos por cobertura y categoría | SCRUM-861 | Fusionado el 19 de octubre |
| MANI-.NET #8 | Filtro de aliados elegibles por tipo | SCRUM-862 | Fusionado el 19 de octubre |
| MANI-Java #2 | Reglas de categoría en el Rules Service | SCRUM-1070 | Fusionado el 17 de octubre |

La promoción de `develop` a `release` se hizo el 20 de octubre en los seis repositorios de código
(MANI-APIGateway#17, MANI-Node#48, MANI-Java#6, MANI-.NET#10, MANI-Flutter#50, MANI-Landing#5).

Pull requests abiertos al corte: MANI-docs#58 (línea base documental de los 23 hallazgos) y las
promociones a `release` de las correcciones de la regresión en MANI-Node#51, MANI-.NET#12 y
MANI-APIGateway#21, que llevan R-01, R-02 y R-03. Ninguno toca la validación de algoritmos de JWT.

### 8.3 H-01: corregido y validado, no genera tarea de desarrollo

El hallazgo H-01 de SCRUM-1266 (el endpoint `POST /api/v1/core/auth/dev-token` emitía, sin
autenticación y con el secreto real del ambiente, tokens para cualquier `tenantId` y rol) **ya está
corregido en el código y verificado en el ambiente**:

- `MANI-Node` `release` (2745bb0), `src/config/jwtSecret.js:37`: `isDevTokenEnabled` solo devuelve
  `true` con `NODE_ENV` igual a `development` o `test`.
- `src/routes/auth.routes.js:130`: la ruta se registra dentro de esa condición, así que en cualquier
  otro entorno no existe.
- `tests/auth.security.test.js:70`: prueba de regresión que exige 404 con `NODE_ENV` igual a
  `production`, `qa` y `staging`, incluso con el secreto real presente.
- Verificación en ambiente: SCRUM-1267 §3 registra que `/auth/dev-token` responde **404 en QA**
  (PER-05).
- Origen de la corrección: MANI-Node#27 y MANI-Node#29 (SCRUM-1333), promovidos en MANI-Node#48.

Por lo tanto H-01 se cierra documentalmente y **no se abre un issue de corrección**. Quedan tres
residuos, que son del mismo vector pero no del mismo hallazgo:

1. La llave **HS256 previa de `MANI-QA` sigue habilitada**: toda la regresión del Sprint 4 firmó
   tokens válidos con ella dentro de la VM (SCRUM-1267 §3). Quien tenga ese secreto emite tokens
   para cualquier tenant y rol, y Core los acepta.
2. `src/config/jwtSecret.js:4` versiona el valor literal `INSECURE_DEV_SECRET`. Fuera de
   `development` y `test` el servicio ya no arranca sin `SUPABASE_JWT_SECRET`, pero el valor está en
   el historial de Git y firma tokens válidos en cualquier entorno local.
3. ADR-0031 §1 todavía autoriza `/auth/dev-token` «exclusivamente para pruebas automatizadas y
   CI/CD» sin restricción de ambiente: el texto no refleja la guarda que el código ya aplica. Es una
   corrección documental en MANI-docs, no trabajo de desarrollo.

Los residuos 1 y 2 son el issue propuesto **S-01** (§4.2). El 3 es una enmienda de ADR-0031 que
corresponde a Arquitectura.

### 8.4 Issues propuestos

#### 8.4.1 Issue 1 — MANI-Node. Validación de tokens ES256 (H-02 / R-10 / SCRUM-1362)

**Título:** `[SCRUM-1362] validate-token rechaza los tokens ES256 de Supabase: ningún usuario real accede a las rutas protegidas`

**Problema verificable.** `POST /api/v1/auth/validate-token` de Core acepta únicamente HS256
(`src/routes/auth.routes.js:9`, `ALLOWED_ALGORITHMS = ['HS256']`; igual en `develop` 8e198ff y en
`release` 2745bb0). Supabase Auth de `MANI-QA` y de `MANI` firma con ECC P-256 (ES256) y su JWKS
publica una sola llave ES256 (`kid` `a069a215-25f2-4958-8b90-ef5b289a025a`); HS256 solo sobrevive
como llave previa. Como el Gateway resuelve toda ruta protegida con `auth_request` hacia ese
endpoint (`nginx.conf:85`), el token real de un usuario autenticado recibe 401 en Core, Rules y
Dispatch.

**Contexto.** Comprobado el 20 de octubre a las 02:05 UTC: un password grant real de
`admin.t1@qa.mani.test` en `MANI-QA` devolvió 200 y un token ES256 con el `tenant_id` de t1, y el
Gateway lo rechazó con 401 `UNAUTHORIZED` en `core/profiles/me`, `rules/evaluate-rate` y
`dispatch/match`. La consecuencia es que la regresión completa del Sprint 4 se ejecutó con tokens
HS256 sintéticos firmados dentro de la VM: ninguna de las 27 historias quedó en *Aprobado* y QAS-01
no cumple.

**Componente responsable.** MANI-Node (Core), en `src/routes/auth.routes.js` y
`src/config/jwtSecret.js`. MANI-.NET (Dispatch) valida además con llave simétrica
(`Infrastructure/Auth/JwtAuthHelper.cs:46`, `SymmetricSecurityKey`): es un issue relacionado y
distinto, no parte de este alcance.

**Referencia a requisito o ADR.** ADR-0031 §1 (Aprobado) fija «HS256 en ambientes de desarrollo y
staging; preparado para RS256 vía JWKS de Supabase en producción». El emisor real usa **ES256**, que
el ADR no contempla. Este issue **depende de una enmienda a ADR-0031** que declare el algoritmo y la
fuente de llaves por ambiente, y no se implementa antes de esa enmienda.

**Evidencia existente.**

- [SCRUM-1266](../07-calidad/REPORTE_QA_SPRINT4.md#7-monitoreo-de-qa-y-escenarios-qas-01-a-qas-09-scrum-1266) §5 (H-02) y §5.1 (D-02).
- [SCRUM-1267](../07-calidad/REPORTE_QA_SPRINT4.md#8-regresión-funcional-api-e2e-y-multi-tenant-scrum-1267) §8 (R-10).
- `qa/monitoreo_qas/evidencia/20261020T020546Z_d02/confirmacion_d02_login_real.txt`.
- Reproducible con `qa/monitoreo_qas/confirmar_d02.sh` desde la VM de Calidad.
- `MANI-APIGateway` `qa/README.md:73-74`.

**Alcance.**

- Validar ES256 contra el JWKS del proyecto Supabase del ambiente, con caché de llaves y rotación
  por `kid`.
- Mantener el rechazo estricto por el `alg` declarado (sin confusión de algoritmo) y la
  obligatoriedad del claim `app_metadata.tenant_id`.
- Conservar la emisión de `X-Tenant-Id`, `X-User-Role` y `X-User-Id` para `auth_request_set`.
- Configuración por variable de entorno: URL del JWKS y algoritmos permitidos por ambiente.

**Exclusiones.** La validación propia de Dispatch; el retiro de la llave HS256 previa de `MANI-QA`
(issue S-01); cualquier cambio en el flujo de refresh del cliente Flutter.

**Criterios de aceptación.**

1. Un password grant real en `MANI-QA` devuelve un token ES256 y `GET /api/v1/core/profiles/me` por
   el Gateway responde 200 con el `tenantId` del claim; se adjunta al PR la corrida de
   `confirmar_d02.sh`.
2. Las tres rutas de la comprobación de H-02 (`core/profiles/me`, `rules/evaluate-rate`,
   `dispatch/match`) responden 200 con ese token.
3. Un token ES256 con firma alterada, vencido, con `kid` desconocido o sin
   `app_metadata.tenant_id` sigue recibiendo 401, con el código específico de ADR-0031 §3.
4. Un token que declara `alg: none` o un algoritmo no permitido recibe 401.
5. Pruebas automatizadas nuevas cubren los puntos 1 a 4 contra un JWKS de prueba, y
   `tests/auth.security.test.js` sigue en verde.
6. El Quality Gate de SonarQube del Core pasa.
7. La suite Newman de `MANI-APIGateway/qa/` se ejecuta con identidad real, no con tokens HS256
   sintéticos, y los casos que hoy dependen de ellos conservan su resultado.

**Dependencias y bloqueos.** Bloquea QAS-01 (casos 1 a 4 y 6), la aprobación de las 27 historias del
Sprint 4, SCRUM-1278 (E2E desde Flutter Web) y SCRUM-1263 (pase a producción). Está bloqueado por la
enmienda de ADR-0031. Relacionado: R-04 / SCRUM-1361 (la imagen de Flutter en QA apunta a
producción) impide el recorrido E2E real aunque esto se corrija.

**Prioridad.** Máxima: riesgo de seguridad —hoy el único camino que funciona es el inseguro— y
bloqueo de integración y despliegue.

**Responsable.** Core (MANI-Node). Sin persona asignada: el reporte de QA sugiere «Core y Dispatch»
sin nombre.

**Trazabilidad.** Jira SCRUM-1362 (BUG-SEC-04), enlazado a SCRUM-1267. QA: H-02 de SCRUM-1266 y
R-10 de SCRUM-1267. Sin pull request todavía.

#### 8.4.2 Issue S-01 — MANI-Node y DevOps. Retiro del secreto HS256 legado

**Título:** `Retirar el secreto HS256 legado: llave previa activa en MANI-QA y secreto de desarrollo versionado`

**Problema verificable.**

1. `MANI-QA` conserva habilitada su llave HS256 previa. Toda la regresión del Sprint 4 firmó tokens
   válidos con ella desde la VM de QA (SCRUM-1267 §3). Quien tenga ese secreto emite tokens para
   cualquier `tenant_id` y rol, que Core acepta hoy.
2. `src/config/jwtSecret.js:4` versiona el valor literal de `INSECURE_DEV_SECRET`. Fuera de
   `NODE_ENV` igual a `development` o `test` el servicio ya no arranca sin `SUPABASE_JWT_SECRET`
   —corrección de SCRUM-1333—, pero el valor queda en el historial de Git y sigue firmando tokens
   válidos en cualquier entorno local.

Este issue **no es H-01**: la exposición de `/auth/dev-token` ya está corregida y validada (§3). Es
el residuo del mismo vector por otra vía.

**Componente responsable.** MANI-Node (Core) para el código; DevOps para las llaves de Supabase y
los secretos de ambiente.

**Referencia a requisito o ADR.** ADR-0031 §3 (segregación estricta de secretos por ambiente, llaves
fuera del control de versiones), ADR-0018 (identificación de tenant).

**Evidencia existente.** `src/config/jwtSecret.js:4` en `release` 2745bb0; SCRUM-1266 §5, última
frase de H-01; SCRUM-1267 §3, «Identidad de prueba»; `MANI-APIGateway` `qa/ejecutar_newman_qa.sh:32`
y `qa/README.md:73`.

**Alcance.** Dejar la llave ES256 como única llave válida de `MANI-QA` y de `MANI` una vez el issue 1
esté desplegado en QA; sustituir el secreto de desarrollo versionado por uno generado localmente y
rotar el que esté en uso; migrar las suites de QA a identidad real cuando el issue 1 lo permita.

**Exclusiones.** Purgar el historial de Git —decisión aparte; el valor debe considerarse comprometido
igual— y la validación ES256, que es el issue 1.

**Criterios de aceptación.**

1. Una búsqueda en el repositorio no devuelve ningún secreto JWT literal, y el arranque en
   `development` o `test` sin `SUPABASE_JWT_SECRET` no usa un valor conocido del repositorio.
2. En `MANI-QA`, la llave HS256 previa queda revocada: un token firmado con ella recibe 401 en
   `validate-token`, con la corrida adjunta como evidencia.
3. Las suites de `MANI-APIGateway/qa/` pasan sin firmar tokens HS256 propios.
4. ADR-0031 y [POLITICA_CONFIGURACION_JWT_CFG4-04](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md#22-política-de-configuración-validación-perimetral-y-propagación-de-jwt-entre-ambientes-cfg4-04) reflejan
   el estado final de las llaves por ambiente.

**Dependencias y bloqueos.** Bloqueado por el issue 1 desplegado en QA: revocar HS256 antes dejaría
QA sin ninguna identidad usable.

**Prioridad.** Alta por riesgo de seguridad. No bloquea el Sprint mientras se respete el orden con
el issue 1.

**Responsable.** Core y DevOps. Sin persona asignada.

**Trazabilidad.** Deriva del residuo de H-01 tras SCRUM-1333. Sin ticket de Jira propio: la Scrum
Master decide si se registra como defecto nuevo o como subtarea de SCRUM-1362.

### 8.5 Decisiones pendientes antes de crear los issues

1. Confirmar que H-01 se cierra documentalmente (§3) y que solo se abre S-01. Si se prefiere dejar
   rastro explícito en GitHub, el issue de H-01 se crearía ya cerrado, con la evidencia de §3.
2. El issue 1 está bloqueado por la enmienda de ADR-0031. Decidir si se registra ahora en estado
   *bloqueado* —registrar no es implementar— o si se espera la enmienda.
3. Confirmar MANI-Node como repositorio destino del issue 1, con la validación de Dispatch como
   issue separado en MANI-.NET.
4. Decidir quién crea el GitHub Project y el conjunto de etiquetas descritos en §1.

### 8.6 Lo que falta de este trabajo

Pendiente de la siguiente iteración, no cubierto aquí: el mapeo de H-03 a H-08 y de R-01 a R-11 al
repositorio responsable, con la decisión de issue único o tareas relacionadas; el dictamen sobre los
issues propuestos por arquitectura N3 (TLS en el borde), N4 (documentos KYC por tenant) y N6
(frontera de datos de Dispatch); y la comprobación de N1 (distancia en Dispatch) y N2 (acceso
directo de Flutter a Supabase), que no deben crearse automáticamente. N5 (seis esquemas de base de
datos) sigue dependiendo de la decisión asociada a ADR-0030.

---

## 9. Cobertura de lo que falta y verificación de lo que ya está

Añadida el 22 de octubre de 2026 al unificar el backlog. Esta sección responde dos preguntas en un
solo lugar: **qué está verificado de verdad** (con evidencia, no con el estado del tablero) y **qué
queda sin cubrir**. Las fuentes son la hoja `17 Cobertura del producto` y la hoja `01 Indice modulos`
de [`MANI_MODULOS_SERVICIOS_Y_BACKLOG_S5.xlsx`](MANI_MODULOS_SERVICIOS_Y_BACKLOG_S5.xlsx), §8 de este
documento (estado verificado de GitHub) y los reportes de QA SCRUM-1266 y SCRUM-1267.

### 9.1 Regla de lectura: «cerrado» no es «verificado»

`architecture/SAD.md` §7.5 advierte que **ninguna capacidad está verificada por QA en la arquitectura
vigente**. Por eso el Sprint 5 parte en dos mitades: validar por video lo que el backlog declara
cerrado y construir lo que falta. Un estado *Done* en Jira sin video, sin token real ES256 y sin
tráfico por el Gateway **no cuenta como verificado** en esta sección.

| Nivel | Qué significa | Qué lo acredita |
|---|---|---|
| Verificado | Comprobado contra el código o el ambiente, con evidencia enlazada | Commit y línea citados, corrida de QA, o video del Sprint 5 según el DoD del sprint |
| Implementado sin validar | Existe el código fusionado, no hay demostración por el front en QA | PR fusionado, sin historia VAL cerrada |
| Pendiente | No existe, o existe con defecto abierto que lo bloquea | Historia CONS o tarea TEC abierta |

### 9.2 Lo que ya está verificado

| Qué | Evidencia | Dónde |
|---|---|---|
| H-01: `/auth/dev-token` ya no se expone fuera de `development` y `test` | `MANI-Node` `release` 2745bb0, `src/config/jwtSecret.js:37` y `src/routes/auth.routes.js:130`; prueba `tests/auth.security.test.js:70`; 404 en QA (PER-05) | §8.3 |
| Los siete repositorios no tienen issues abiertos ni cerrados; el seguimiento vive en Jira y en los PR | `gh issue list --state all`, corte del 20 de octubre de 2026 | §8.1 |
| Las referencias «MANI-Node #43», «MANI-.NET #1» y similares son pull requests fusionados, no trabajo pendiente | Tabla de ocho PR fusionados entre el 17 y el 19 de octubre | §8.2 |
| Promoción de `develop` a `release` en los seis repositorios de código | MANI-APIGateway#17, MANI-Node#48, MANI-Java#6, MANI-.NET#10, MANI-Flutter#50, MANI-Landing#5, 20 de octubre | §8.2 |
| Aislamiento KYC en el camino directo a Storage | Política `kyc_isolation` (hallazgo F5 de la línea base de US-02.1.1) | §7.2 y §7.3.1 |

### 9.3 Lo que falta por cubrir, módulo por módulo

Las columnas VAL, CONS y TEC son los bloques del Sprint 5 de la hoja `17 Cobertura del producto`.

| Módulo | Func. | Validación (VAL) | Construcción (CONS) | Técnicas (TEC) | Sin cubrir en el Sprint 5 |
|---|---|---|---|---|---|
| M-01 Plataforma multi-tenant y aislamiento | 5 | VAL-16 | CONS-44 | TEC-02, TEC-08, TEC-09, TEC-12 | Ninguna |
| M-02 Usuario (identidad, registro, sesión, perfil) | 15 | VAL-01 a VAL-05, VAL-17, VAL-18 | CONS-01 a CONS-06, CONS-45 | TEC-07, TEC-09, TEC-10, TEC-11 | Ninguna |
| M-03 Directorio, KYC y cobertura | 6 | VAL-06, VAL-07 | CONS-15 a CONS-17 | — | Ninguna |
| M-04 Catálogo, zonas y barrios | 7 | VAL-08, VAL-09 | CONS-12 a CONS-14 | — | Ninguna |
| M-05 Solicitud y asignación | 10 | VAL-10 a VAL-14 | CONS-18 a CONS-20 | TEC-01 a TEC-06, TEC-12, TEC-13 | Ninguna |
| M-06 Cotización | 3 | — | CONS-21 a CONS-23 | — | Ninguna |
| M-07 Ejecución y trazabilidad | 6 | — | CONS-24 a CONS-26 | — | M-07.4 rastreo en vivo: fuera del MVP por SRS §1.2 |
| M-08 Calificación, cancelación y cierre | 7 | — | CONS-30 a CONS-33 | — | Ninguna |
| M-09 Comunicación y notificaciones | 6 | VAL-15 | CONS-34 a CONS-37 | — | Ninguna |
| M-10 Tarifario de referencia y reportes | 3 | — | CONS-27 a CONS-29 | — | Ninguna |
| M-11 Pagos y facturación | 8 | — | CONS-38 a CONS-40 | — | M-11.2 a M-11.8 pasan al 2.º incremento; en el Sprint 5 solo entra el mock |
| M-12 Operación, quejas y comercialización | 7 | — | CONS-41 a CONS-43 | TEC-14 | M-12.3 a M-12.5 pasan al 2.º incremento |
| M-13 Shell de aplicación y modularización | 5 | — | CONS-07 a CONS-11 | — | Ninguna |

**Volumen del Sprint 5:** 18 ítems VAL (87 puntos), 45 CONS (269) y 20 TEC (85). Total 83 ítems y
441 puntos.

### 9.4 Bloqueos que impiden verificar

El DoD del Sprint 5 exige token real ES256 por el Gateway. Ese camino **ya funciona desde el 21 de
octubre**, así que el bloqueo de raíz está levantado; lo que queda abajo es lo que sigue abierto.

> **El §8 de este documento tiene corte del 20 de octubre y la §9.2 del 22.** El reporte general de
> QA del Sprint 4 ([`qa/REPORTE_QA_SPRINT4.md` §9](../07-calidad/REPORTE_QA_SPRINT4.md#9-defectos-consolidados-del-sprint))
> es posterior y manda sobre el estado de cada defecto. En particular, el issue de ES256 que §8.4.1
> propone ya se implementó.

| Estado | Bloqueo | Efecto | Evidencia |
|---|---|---|---|
| **Levantado** | `validate-token` solo aceptaba HS256 y Supabase firma ES256 (H-02 / R-10 / SCRUM-1362) | Era la causa de que ninguna de las 27 historias quedara en *Aprobado* | Corregido y verificado: MANI-Node#52 y MANI-.NET#13; login real de `admin.t1` con 200 en Core y Rules; tokens falsificados, sin `kid` o con `alg: none` con 401 |
| **Levantado** | ADR-0031 §1 no contemplaba ES256 | Impedía implementar la validación | Enmendado en MANI-docs#59, fusionado el 21 de octubre |
| Abierto | La llave HS256 previa de `MANI-QA` sigue habilitada y `INSECURE_DEV_SECRET` está versionado (S-01) | Quien tenga el secreto emite tokens para cualquier tenant y rol | §8.4.2; ya se puede ejecutar porque ES256 está desplegado |
| Abierto | R-09 / BUG-SEC-05: Core y Dispatch conectan como `postgres` con BYPASSRLS | El aislamiento por RLS no defiende contra el propio servicio | Reporte de QA §9 |
| Abierto | R-06 / BUG-SEC-06: 15 políticas `tenant_isolation_*` con `TO public` | Igual que el anterior, en la capa de políticas | Reporte de QA §9 |
| Mitigado | R-04 / SCRUM-1361: la imagen de Flutter en QA se construye con `.env.example` | Impide el E2E real; en QA se sortea montando `flutter.env.qa` a mano, pero falta corregir MANI-Flutter | Reporte de QA §9 |
| Abierto | R-08 / BUG-QA-08: la promoción a `release` no dejó QA operativo; compose y despliegue sin versionar | Hace que cada corrida dependa de ajustes manuales | Reporte de QA §9 |
| Abierto | R-11 / BUG-DISP-01: los errores de Dispatch no traen `code` (criterio T5, PE5) | Rompe el formato de error único de §6.2 | Reporte de QA §9 |

### 9.5 Incremento no entregado: lo que no se construye y por qué

Registro exigido por [`GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §10 para un incremento que no se entrega: causa, impacto, estado y decisión de replanificación. Se escribe aquí porque **el Sprint 5 es el último de desarrollo**: lo que no entra en él no se construye, y los issues correspondientes se borraron de Jira el 24 de octubre de 2026 por decisión de la Scrum Master, para no dejar trabajo muerto en el tablero.

| Issue borrado | Historia | Requisito | Causa | Impacto | Decisión |
|---|---|---|---|---|---|
| `SCRUM-864` | US-04.1.5 Priorizar por comisión ofrecida | RF-13 | **Superada, no descartada.** §10.4 decidió que el ranking no es «priorizar por comisión» sino configurable por tenant, donde la comisión puede ser uno de varios criterios | Ninguno: la capacidad se construye en `HU-M05-05`, dentro del sprint | Se retira el issue; el requisito queda cubierto |
| `SCRUM-897` | US-08.1.3 Resolución de disputa financiera | RF-26 | Segundo incremento. Depende del modelo de pagos, que en el Sprint 5 solo entra como mock | **RF-26 queda cubierto a medias:** se construyen el registro y la gestión de quejas (`HU-M12-01` y `HU-M12-02`), no la resolución de disputa financiera | No se entrega. Si el producto continúa, se recrea con el alcance de pagos resuelto |
| `SCRUM-898` | US-08.2.1 Publicar contenido en redes conectadas | RF-27 | Segundo incremento. Comercialización, fuera del MVP de `SRS.md` §1.2 | **RF-27 queda sin entregar.** La consola de comercialización no se construye | No se entrega |
| `SCRUM-899` | US-08.2.2 Registrar campañas y ver su desempeño | RF-27 | Igual que el anterior | Igual que el anterior | No se entrega |

**Lo que esto significa para la trazabilidad.** RF-27 pierde sus dos únicas historias y queda sin cobertura; RF-26 queda cubierto solo en la parte de quejas. Ambos siguen en el SRS como requisitos del segundo incremento: no se retiran del documento, porque el requisito existe aunque no se construya. La diferencia entre «requisito sin construir» y «requisito que ya no existe» es la que permite sustentar la decisión.

**Por qué se borraron en vez de cerrarse.** El workflow del proyecto SCRUM solo tiene `To Do`, `In Progress`, `In Review`, `Done` y `blocked`: **no existe un estado `Won't Do`**. Un issue que no se va a construir solo podía quedarse en `To Do` indefinidamente, apareciendo como trabajo pendiente en todos los filtros del tablero. El borrado en Jira es permanente, y por eso el registro vive en esta tabla.

---

### 9.6 Pendientes consolidados

Los PE vienen de §6.5, los PA de §7.8 y las decisiones D de §8.5. Se listan juntos porque varios se
bloquean entre sí.

| ID | Pendiente | Responsable |
|---|---|---|
| PE2 | MANI-Node#14 debe resolver su conflicto con `develop`, y MANI-Node#43 cerrar el acceso a los endpoints internos | Nicolás León |
| PE3 | Corregir el título de SCRUM-1068, que menciona «Availability Service» | Nicolás León |
| PE4 | Crear las subtareas QA de SCRUM-1063, 1066 y 1068 | Santiago (QA) |
| PE5 | Dispatch responde `{ error, status }`; debe responder según T5 | Nicolás León |
| PE6 | El filtro de Dispatch debe aceptar también `EMPLEADO_DIRECTO` | José Nicolás Álvarez |
| PE7 | Definir el límite de tamaño de la foto de perfil de SCRUM-854 | Camila (PO) |
| PE8 | Ajustar RF-29 del SRS al modelo de intervalos de no disponibilidad | Camila (PO) |
| PE9 | Correcciones en Jira: descripción de SCRUM-862, «funciones PL/pgSQL», ADR-0021 por ADR-0016 y enlace de cada historia a §6.3 | Camila (PO) |
| PA-01 a PA-17 | Puntos abiertos de US-02.1.1; el contrato v0.3.0 cubre lo esencial pero falta fusionarlo (CFG-16) | §7.8 |
| D1 | Confirmar que H-01 se cierra documentalmente y que solo se abre S-01 | Scrum Master |
| D2 | Decidir si el issue de ES256 se registra ahora como *bloqueado* o se espera la enmienda de ADR-0031 | Scrum Master |
| D3 | Confirmar MANI-Node como repositorio destino, con la validación de Dispatch como issue separado en MANI-.NET | Arquitectura |
| D4 | Decidir quién crea el GitHub Project y el conjunto de etiquetas de §8.1 | Scrum Master |
| D5 | Mapear H-03 a H-08 y R-01 a R-11 al repositorio responsable; dictaminar N3, N4 y N6; comprobar N1 y N2; N5 depende de ADR-0030 | §8.6 |

---

## 10. Registro de la transición V4

Absorbido el 23 de octubre de 2026 desde `transicion-v4.md` y `orden-de-ejecucion.md`, que eran vistas derivadas de este documento y dejaron de
existir aparte. **Es registro histórico del Sprint 3**: el orden de §10.5 ya se ejecutó y no gobierna
el Sprint 5, cuyo orden está en la hoja `12 Backlog S5 resumen` del libro de módulos y servicios. Se
conserva porque explica por qué cada historia legacy quedó como quedó.

### 10.1 Cómo se lee una clasificación

| Clasificación | Qué hacer |
|---|---|
| `PRESERVAR_HISTORICO` | No reabrir; la evidencia es válida |
| `PRESERVAR_Y_VALIDAR` | Reutilizar y validar con subtareas `-Mn` y regresión |
| `REESPECIFICAR_Y_REUTILIZAR` | Conservar código y evidencia, adaptar al requisito nuevo |
| `CONTINUAR` | Pendiente y alineada al SRS; seguir, ajustada al componente objetivo |
| `REESPECIFICAR` | Actualizar alcance antes de implementar |
| `BACKLOG_SECUNDARIO` | Útil, no requisito principal del MVP; detrás de los RF críticos |
| `POSTERGAR_INCREMENTO_2` | Pertenece a RF-24 a RF-28 |
| `RETIRAR_MVP` | Fuera de alcance; se saca del MVP sin borrar historial |
| `NUEVO_DELTA_ARQUITECTURA` | Trabajo necesario por el cambio arquitectónico; crear y ejecutar |
| `NUEVO_REQUERIDO` | Hueco entre el SRS y el backlog legacy; crear en Jira |

La convención de sufijos `-M2`, `-M3`, `-M4`, `-M6` y `-R1` está en §3.2.

### 10.2 Dónde fue cada tipo de trabajo

| Destino | Qué recibió | Convención |
|---|---|---|
| **EP-09** — gestión y configuración | Plataforma, repositorios, Gateway, esqueletos de servicio, identidad, CI/CD, GHCR, Compose, Kubernetes, configuración del cliente y regresión | tareas `CFG-` (serie no continua), más el spike `SP-05` |
| **EP-10** — documentación y entregables | ADR de la decisión PL/pgSQL, matriz de trazabilidad, actualización de SAD y SDD y del contexto de IA | `DOC-25` a `DOC-28` |
| **Las nueve historias ya desarrolladas** | El trabajo funcional de migrar y revalidar cada caso de uso | Subtareas `US-xx-M1` a `-Mn` (§3.3) |
| **Épicas funcionales** EP-01, EP-02 y EP-04D | Historias que el SRS exige y el backlog legacy no cubría | `HU-N-01` a `HU-N-05` (§10.3) |

No se creó una épica de migración aparte.

### 10.3 Huecos del SRS que generaron historias nuevas

| ID | Épica | RF | Historia | Componente |
|---|---|---|---|---|
| `HU-N-01` | EP-01 | RF-01 | Administrar tenants y su estado base | Core |
| `HU-N-02` | EP-01 | RF-02 / RNF-02 / REST-05 | Configurar reglas por tenant sin despliegue | Rules y Core |
| `HU-N-03` | EP-01 | RF-03 / RNF-01 | Autenticar y autorizar por tenant y rol | Supabase Auth, Gateway y servicios |
| `HU-N-04` | EP-02 | RF-04 | Recuperar contraseña de forma segura | Supabase Auth y Core |
| `HU-N-05` | EP-04D | RF-19 | Cerrar servicio solo tras calificación bidireccional | Core |

### 10.4 Cambios de alcance decididos en la transición

- **Cobertura:** catálogo jerárquico de zonas y coincidencia exacta. Sin radio ni proximidad. El trabajo existente se reutiliza adaptándolo.
- **Ranking:** no es «priorizar por comisión»; es ranking **configurable por tenant**, donde la comisión puede ser uno de varios criterios.
- **Geolocalización en vivo:** salía del MVP en la transición V4. **Revertido el 24 de octubre de 2026:** entró al Sprint 5 como RF-37 y como `HU-M07-04`, por decisión de la Scrum Master y pendiente de confirmación del PO. El cálculo de proximidad sigue fuera.
- **Calificaciones:** las dos historias convergen en RF-19; sin ambas calificaciones no hay cierre.
- **Pagos, escrow y disputas:** pagos y liquidación quedan en el segundo incremento. Escrow, liberación automática y reglas de disputa **no se asumen como alcance aprobado** sin decisión funcional o regulatoria.

### 10.5 Orden en que se ejecutó la transición

Las fases 1 y 2 bloqueaban el resto. Se conserva como registro, no como plan vigente.

| Fase | Trabajo | Por qué iba ahí |
|---:|---|---|
| 1 | `CFG-37`, `CFG-38` — reconciliar las ramas de `MANI-Frontend` y fijar la base de código | Sin esto, lo demás se construye sobre una base incompleta |
| 2 | `SP-05`, **decidido el 2026-10-05**: los servicios reescriben la lógica. Registrado en [`ADR-0022`](../02-arquitectura/adr/ADR-0022-logica-de-negocio-en-servicios.md) | Dejó de bloquear la estimación de las subtareas `-M2` |
| 3 | `CFG-15`, `CFG-16`, `CFG-17`, `CFG-20` — repositorios, contratos OpenAPI, Gateway y esqueletos de servicio | Plataforma mínima para implementar casos de uso |
| 4 | `CFG-22`, `CFG-23a`, `CFG-23b`, `CFG-23c` — identidad y propagación de JWT y rediseño del modelo de identidad en base de datos | Es el punto que podía tumbar el aislamiento multi-tenant |
| 5 | `CFG-26` a `CFG-30`, `CFG-33` — Supabase por ambiente, GHCR, Compose, CI/CD, observabilidad y sacar `database/`, Compose, `scripts/` y `nginx.conf` del repositorio Flutter | Entrega y operación por repositorio |
| 6 | `CFG-34` a `CFG-36`, `CFG-39` — capa HTTP del cliente, recorte de `supabase_flutter`, retirar y rotar la `SUPABASE_ANON_KEY` y mock del Gateway | Saca al cliente de la base de datos |
| 7 | Subtareas `-M1` a `-Mn` por historia, en el orden de las épicas funcionales | El trabajo funcional propiamente dicho |
| 8 | `CFG-40` — regresión completa sobre todo lo legacy preservado | Demuestra que nada se rompió |
| 9 | Cerrar Kubernetes por ADR y ejecutar la transición de despliegue sin romper el Compose actual | Depende de `INFRA-01` e `INFRA-02`, ambos sin decidir. Mientras no haya decisión, Docker Compose sobre VM sigue siendo el mecanismo operativo |
| 10 | `DOC-25` a `DOC-28` — documentación, en paralelo y cerrando al final | Deja SAD, SDD, ADR y contexto alineados con lo que de verdad se hizo |

Dependencias entre tareas `CFG`: `CFG-16` tras `CFG-15`; `CFG-17` tras `CFG-15` y `CFG-16`;
`CFG-22` tras `CFG-17` a `CFG-21`; `CFG-23a/b/c` tras `CFG-22`; `CFG-28` tras `CFG-27` y `CFG-33`;
`CFG-34` tras `CFG-16` y `CFG-17`; `CFG-36` tras `CFG-34` y `CFG-35`; `CFG-40` tras `CFG-23`,
`CFG-34` y `CFG-38`.

Los once puntos de la definición de llegada de la transición están en
[Criterios de éxito](../01-producto/criterios-de-exito.md).

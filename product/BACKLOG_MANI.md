# Backlog MANI

- **Proyecto Jira:** MANI (`SCRUM`)
- **Documento vivo:** sin número de versión; la vigente es la de `main`. Jira es la fuente del estado
  de cada historia y del sprint en curso; este documento es el criterio de transición.
- **Arquitectura vigente:**
  `Flutter → NGINX API Gateway → servicio (Rules Java · Dispatch .NET · Core Service) → Supabase/PostgreSQL`,
  con Supabase Auth emitiendo el token y el tenant viajando como claim.

> **La lógica de negocio vive en los servicios, no en funciones PL/pgSQL.** Lo decidió
> [ADR-0022](../adr/ADR-0022-logica-de-negocio-en-servicios.md): cuando un servicio atiende un caso
> de uso, **reimplementa** la lógica en el servicio dueño de la capacidad; no invoca la función
> almacenada. Las funciones existentes se retiran con una migración nueva una vez QA confirme el
> reemplazo, y no se escribe lógica nueva en PL/pgSQL.
>
> El cliente Flutter alcanza Supabase solo por Auth y Realtime
> ([ADR-0027](../adr/ADR-0027-alcance-supabase-cliente-flutter.md)). `.from()`, `.rpc()` y
> `.storage.from()` están retirados, sin excepción.
>
> Las versiones anteriores de este documento daban por vigente el camino
> `Gateway → Core → funciones PL/pgSQL`, que es la alternativa que ADR-0022 descartó. Las historias
> `-M2` de abajo quedaron reestimadas en consecuencia.

Este documento es la única fuente del backlog. Reemplaza las versiones anteriores y el inventario de transición.

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
| `US-02.1.5` | `SCRUM-850` | Registrar empleado directo | To Do | Medium | 3.0 | — |
| `US-02.1.6` | `SCRUM-855` | Aliado gestiona su disponibilidad | To Do | Medium | 3.0 | — |
| `US-02.2.1` | `SCRUM-851` | Registro cliente persona natural | Done | Highest | 3.0 | `US-02.2.1-M2` |
| `US-02.2.2` | `SCRUM-852` | Cliente empresa con múltiples sitios | To Do | Medium | 8.0 | — |
| `US-02.2.3` | `SCRUM-853` | Reglas contextuales del sitio visibles al aliado | To Do | Medium | 5.0 | — |
| `US-02.3.1` | `SCRUM-854` | Editar perfil propio | To Do | Medium | 2.0 | — |
| `US-02.3.2` | `SCRUM-856` | Aceptación de Términos y Condiciones | To Do | Low | 8.0 | — |

### EP-03 — Catalogo y cobertura

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-03.1.1` | `SCRUM-857` | Crear categoría con flujo operativo | Done | Highest | 5.0 | `US-03.1.1-M2`, `US-03.1.1-M6` |
| `US-03.1.2` | `SCRUM-858` | Desactivar categoría sin afectar en curso | To Do | High | 8.0 | — |
| `US-03.1.3` | `SCRUM-859` | Aliado declara categorías que atiende | In Progress | Medium | 3.0 | `US-03.1.3-M2` |

### EP-04A — Ciclo del servicio: solicitud y asignacion

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-04.1.1` | `SCRUM-860` | Crear solicitud | Done | Highest | 3.0 | `US-04.1.1-M2`, `US-04.1.1-M6` |
| `US-04.1.2` | `SCRUM-861` | Ver aliados válidos por cobertura y categoría | To Do | High | 5.0 | — |
| `US-04.1.3` | `SCRUM-862` | Filtrar por tipo de aliado | To Do | High | 5.0 | — |
| `US-04.1.4` | `SCRUM-863` | Aceptar/rechazar solicitud sin doble asignación | Done | Highest | 5.0 | `US-04.1.4-M6` |
| `US-04.1.5` | `SCRUM-864` | Priorizar por comisión ofrecida | To Do | Medium | 2.0 | — |

### EP-04B — Ciclo del servicio: cotizacion

| Código | Clave | Historia | Estado | Prioridad | SP | Migración |
|---|---|---|---|---|---|---|
| `US-04.2.1` | `SCRUM-865` | Cotización con mano de obra y materiales separados | To Do | High | 8.0 | — |
| `US-04.2.2` | `SCRUM-866` | Alerta de tarifa bidireccional | To Do | High | 5.0 | — |
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
| `US-04.4.1` | `SCRUM-874` | Cliente califica al aliado | To Do | High | 8.0 | — |
| `US-04.4.2` | `SCRUM-875` | Aliado califica al cliente | To Do | Medium | 3.0 | — |
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
   filtrar, por lo que el aislamiento multi-tenant (KI-05) debe demostrarse de nuevo, historia por historia.

Las historias originales **no se reabren**: conservan su estado como registro histórico y quedan vinculadas
con *Relates* a la historia de migración que las reemplaza.

### 3.2 Convención de identificadores

| Sufijo | Significado |
|---|---|
| `-M2` | Implementación de la lógica en el servicio destino. **Reimplementa**, no invoca la función PL/pgSQL (ADR-0022) |
| `-M3` | Delta del cliente Flutter: solo `data/datasources` |
| `-M4` | Regresión en QA por el Gateway más aislamiento multi-tenant |
| `-M6` | Parte que depende de un servicio políglota inexistente hoy (Rules Java o Dispatch .NET) |
| `-R1` | Reespecificación funcional: el alcance anterior no se preserva |

Toda historia `-M2` conserva como criterio de aceptación el comportamiento validado en las entregas
1 a 3, y pasa la regresión en QA antes de que se retire la función PL/pgSQL correspondiente.

### 3.3 Mapeo

| Historia cerrada | Estado | Clasificación | Componente destino | Historias nuevas | Fase |
|---|---|---|---|---|---|
| `SCRUM-846` · US-02.1.1 Registro aliado persona natural | Done | PRESERVAR_Y_VALIDAR | Core Service + Auth/Storage | `US-02.1.1-M3`, `US-02.1.1-M4`, `US-02.1.1-M2` | Sprint 3 |
| `SCRUM-847` · US-02.1.2 Registro aliado empresa | Done | PRESERVAR_Y_VALIDAR | Core Service + Auth/Storage | `US-02.1.2-M3`, `US-02.1.2-M2` | Sprint 3 |
| `SCRUM-848` · US-02.1.3 Aprobar/rechazar registro de aliado | Done | PRESERVAR_Y_VALIDAR | Core Service | `US-02.1.3-M2` | Incremento 2 |
| `SCRUM-849` · US-02.1.4 Declarar zona de cobertura | Done | REESPECIFICAR_Y_REUTILIZAR | modulo de disponibilidades del Core Service | `US-02.1.4-R1`, `US-02.1.4-M2` | Incremento 2 |
| `SCRUM-851` · US-02.2.1 Registro cliente persona natural | Done | PRESERVAR_Y_VALIDAR | Core Service + Auth | `US-02.2.1-M2` | Sprint 3 |
| `SCRUM-857` · US-03.1.1 Crear categoría con flujo operativo | Done | PRESERVAR_Y_VALIDAR | Core Service + Rules Java | `US-03.1.1-M2`, `US-03.1.1-M6` | Incremento 2 |
| `SCRUM-859` · US-03.1.3 Aliado declara categorías que atiende | In Progress | Completar sobre el camino nuevo | Core Service, modulo de disponibilidades | `US-03.1.3-M2` | Incremento 2 |
| `SCRUM-860` · US-04.1.1 Crear solicitud | Done | PRESERVAR_Y_VALIDAR | Core Service + Dispatch .NET | `US-04.1.1-M2`, `US-04.1.1-M6` | Incremento 2 |
| `SCRUM-863` · US-04.1.4 Aceptar/rechazar solicitud sin doble asignación | Done | PRESERVAR_Y_VALIDAR | Dispatch .NET + PostgreSQL | `US-04.1.4-M6` | Incremento 2 |

### 3.4 Criterio de corte Sprint 3 / Incremento 2

En el Sprint 3 solo existen dos servicios nuevos: **MANI-API-Gateway** (NGINX) y
**MANI-Core-Service** (Node). Por tanto:

- **Entra al Sprint 3** la historia cuyo componente destino se resuelve con Gateway + Core Service, y que
  además reutiliza el modelo de identidad y el cliente HTTP que construye `US-02.1.1`.
- **Queda en Incremento 2** la que necesita Rules Java o Dispatch .NET. Donde hay una parte
  que Core sí sostiene hoy, la historia se **parte** (`-M2` ahora, `-M6` después) en vez de arrastrarse completa.
- Las disponibilidades **no** son un criterio de corte: son un módulo del Core Service, así que lo que
  dependa de ellas entra cuando entre el Core, no cuando exista un cuarto servicio.
- `SCRUM-863` es el único caso que migra completo al Incremento 2: su valor es la exclusión concurrente en el
  servicio de despacho (KI-06, [ADR-0016](../adr/ADR-0016-despacho-concurrencia.md)), y no tiene porción que
  el Core Service pueda sostener.
- `SCRUM-848` sale del Sprint 3 **por capacidad, no por dependencia técnica**: Gateway y Core ya la soportan,
  así que es la primera candidata a volver si se libera holgura.

### 3.5 Historias de migración

**Sprint 3** — 6 historias

| Código | Historia | Prioridad | SP | Reemplaza |
|---|---|---|---|---|
| `US-02.1.2-M3` | Migracion: reescribir el datasource de registro de empresa en Flutter contra el Gateway, retirando .rpc() y .storage.from() y conservando la interfaz del repositorio | High | 3 | `SCRUM-847` |
| `US-02.1.1-M3` | Migracion: reescribir auth_remote_datasource.dart contra el Gateway en lugar de SupabaseClient, conservando la interfaz de domain/repositories. | Highest | 4 | `SCRUM-846` |
| `US-02.1.1-M4` | Migracion: regresion funcional de US-02.1.1 desplegada en QA a traves del Gateway, mas las pruebas de aislamiento multi-tenant de los documentos KYC. | Highest | 4 | `SCRUM-846` |
| `US-02.1.2-M2` | Migracion: reimplementar la logica de registro de aliado empresa en el Core Service, con el representante legal y los documentos de la empresa entrando por el Gateway. No invoca la funcion PL/pgSQL (ADR-0022) | High | 5 | `SCRUM-847` |
| `US-02.2.1-M2` | Migracion: reimplementar el registro de cliente persona natural en el camino Gateway - Core Service, incluyendo su datasource en Flutter | High | 5 | `SCRUM-851` |
| `US-02.1.1-M2` | Migracion: reimplementar en el Core Service la logica que hoy vive en `registrar_aliado_persona_natural`, `handle_new_user` y el upsert a `usuario`, expuesta por el contrato OpenAPI de CFG-16. La funcion PL/pgSQL se retira cuando la regresion de QA confirme el reemplazo (ADR-0022) | Highest | 8 | `SCRUM-846` |

**Incremento 2** — 9 historias

| Código | Historia | Prioridad | SP | Reemplaza |
|---|---|---|---|---|
| `US-02.1.3-M2` | Migracion: aprobacion y rechazo de registro de aliado en Core Service, con la visibilidad de documentos KYC resuelta en el nuevo modelo de identidad | High | 5 | `SCRUM-848` |
| `US-02.1.4-R1` | Reespecificacion: sustituir la seleccion libre en mapa por el catalogo jerarquico de zonas | High | 5 | `SCRUM-849` |
| `US-02.1.4-M2` | Migracion: declaracion de zona de cobertura sobre el modulo de disponibilidades del Core Service, persistida en `core.aliado_cobertura` | High | 5 | `SCRUM-849` |
| `US-03.1.1-M2` | Migracion: gestion de categoria en Core Service, dejando la evaluacion de reglas como frontera declarada hacia Rules | Highest | 5 | `SCRUM-857` |
| `US-03.1.1-M6` | Migracion: llevar las reglas evaluables de la categoria al Rules Service en Java | High | 5 | `SCRUM-857` |
| `US-03.1.3-M2` | Migracion: completar la asociacion aliado-categoria por el camino Gateway - Core Service | Medium | 3 | `SCRUM-859` |
| `US-04.1.1-M2` | Migracion: creacion de solicitud en Core Service, separada de la orquestacion de despacho | Highest | 3 | `SCRUM-860` |
| `US-04.1.1-M6` | Migracion: orquestacion de despacho de la solicitud en el Dispatch Service .NET | Highest | 3 | `SCRUM-860` |
| `US-04.1.4-M6` | Migracion: aceptar o rechazar solicitud sin doble asignacion, con la exclusion concurrente en Dispatch .NET | Highest | 5 | `SCRUM-863` |

### 3.6 Riesgo abierto de cobertura de regresión

La planificación dejó regresión solo para `US-02.1.1` (`US-02.1.1-M4`). **`US-02.1.2-M2/M3` y `US-02.2.1-M2`
entran al sprint sin historia de regresión propia en QA**, por lo que su pasada de aislamiento multi-tenant
no está planificada. Decisión pendiente del PO.
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
| `DOC-26` — Registrar en ADR la decision de SP-05. **Cerrada:** la decidio ADR-0022, y el resultado fue el contrario al que se anticipo aqui: la logica se reimplementa en los servicios y Supabase queda como persistencia | Highest | 3 | `SCRUM-453` |
| `DOC-28` — Actualizar el SAD y el SDD con el resultado real de la transicion y cerrar KI-01 y KI-02 | Highest | 4 | `SCRUM-453` |
| `DOC-29` — Reorganizar el repositorio de diagramas a la estructura de ADR-0008 y versionar la fuente editable | High | 2 | `SCRUM-453` |
| `DOC-30` — Rehacer las vistas C4 de contexto y de contenedores con el camino real del incremento | Highest | 3 | `SCRUM-453` |
| `DOC-31` — Diagramar la vista C4 de componentes de MANI-API-Gateway y de MANI-Core | Highest | 3 | `SCRUM-453` |
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
| `CFG-29` — Replicar el pipeline CI/CD en MANI-API-Gateway y MANI-Core con los gates de calidad | Highest | 5 | `SCRUM-452` |
| `CFG-33` — Sacar database/, docker-compose.yml, scripts/ y nginx.conf del repositorio Flutter | Highest | 4 | `SCRUM-452` |
| `CFG-34` — Construir la capa HTTP del cliente Flutter que sustituye a SupabaseClient | Highest | 6 | `SCRUM-452` |
| `CFG-35` — Decidir y aplicar que queda de supabase_flutter en el cliente | Highest | 3 | `SCRUM-452` |
| `CFG-36` — Retirar la SUPABASE_ANON_KEY del bundle web y rotarla | Highest | 3 | `SCRUM-452` |
| `CFG-39` — Conectar GitHub con Jira y dejar la trazabilidad automatica en los cuatro repositorios | Highest | 4 | `SCRUM-452` |
| `CFG-40` — Crear el proyecto SonarQube de MANI-API-Gateway y volver vinculante su Quality Gate | Highest | 3 | `SCRUM-452` |
| `CFG-41` — Crear el proyecto SonarQube de MANI-Core y volver vinculante su Quality Gate | Highest | 3 | `SCRUM-452` |
| `CFG-42` — Rebaselinar el proyecto SonarQube de MANI-Frontend despues de sacar los artefactos que no le pertenecen | High | 2 | `SCRUM-452` |
| `CFG-43` — Definir los contratos entre los repositorios del modelo multi-repo | Highest | 3 | `SCRUM-452` |

### Automatización de pruebas

Herramientas de verificación, todas gratuitas y locales.

| Tarea | Prioridad | PH | Épica |
|---|---|---|---|
| `QA-01` — Montar las pruebas de integracion de Core Service sobre Postgres real levantado con Testcontainers | Highest | 4 | `SCRUM-452` |
| `QA-02` — Automatizar con Playwright el recorrido end-to-end del build web sobre el Gateway | High | 3 | `SCRUM-452` |
| `QA-03` — Dejar la coleccion Postman del contrato Gateway - Core corriendo con Newman en el pipeline | Highest | 3 | `SCRUM-452` |
| `QA-04` — Medir con k6 el camino de registro por el Gateway, con la carga y el umbral que define el escenario QAS-03 del SDD §8 | High | 3 | `SCRUM-452` |
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
| Unitarias de los servicios políglotas | JUnit 5 / xUnit | `QA-06` | Esqueleto listo antes de que Rules Java y Dispatch .NET existan |
| Cumplimiento PCI-DSS | Escáner propio | `QA-07` | Busca PAN y CVV en base y logs antes de que `EP-07` entre al backlog |

Los valores medidos con estas herramientas son los que `DOC-39` publica como métricas de los atributos de
calidad P1 de ISO/IEC 25010.

---

## 5. Documentos relacionados

| Tema | Documento |
|---|---|
| Requerimientos | [`product/SRS.md`](SRS.md) |
| Arquitectura | [`architecture/SAD.md`](../architecture/SAD.md) |
| Diseño detallado y vistas C4 | [`architecture/SDD.md`](../architecture/SDD.md) |
| Modelo de datos | [`architecture/ModeloDatos.md`](../architecture/ModeloDatos.md) |
| Decisiones arquitectónicas | [`adr/`](../adr/) |
| Políticas DevOps y versionamiento de despliegue | [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) |

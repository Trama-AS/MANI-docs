# Product Backlog MANI — V4 de transición

**Objetivo:** conservar todo el trabajo ya ejecutado en Jira, alinear el producto con el SRS vigente y crear explícitamente las tareas necesarias para migrar de la implementación anterior a la arquitectura objetivo actual.

> Regla principal: **una historia o tarea histórica marcada Done no se reabre solo porque cambió la arquitectura**. Se conserva su evidencia. Si necesita adaptación, se crea una subtarea de migración `-Mn` colgada de la propia historia, una tarea `CFG` en EP-09 o un bug de regresión. Así no se borra trabajo real ni se finge que la migración ya ocurrió.

## 1. Fotografía del Jira recibido

- Issues totales exportados: **250**.
- Done: **155**.
- To Do: **88**.
- In Progress: **2**.
- In Review: **5**.
- Tipos: **Tarea: 61**, **Subtarea: 120**, **Historia: 56**, **Epic: 13**.

El backlog nuevo no elimina esas filas. El CSV conserva cada issue legacy con su `Source Jira Key`, estado histórico y una clasificación de transición.

## 2. Cómo leer la transición

| Clasificación | Significado | Qué hacer |
|---|---|---|
| `PRESERVAR_HISTORICO` | Trabajo terminado/evidencia válida | No reabrir |
| `PRESERVAR_Y_VALIDAR` | Funcionalidad terminada y todavía requerida | Reutilizar y validar mediante subtareas `-Mn` y regresión |
| `REESPECIFICAR_Y_REUTILIZAR` | Hay trabajo útil pero cambió el requisito | Conservar código/evidencia y adaptar |
| `CONTINUAR` | Historia pendiente alineada al SRS | Continuar, ajustada al componente objetivo |
| `REESPECIFICAR` | La HU actual es demasiado específica o contradice el SRS | Actualizar alcance antes de implementar |
| `BACKLOG_SECUNDARIO` | Útil pero no requisito principal del MVP | Mantener detrás de RF críticos |
| `POSTERGAR_INCREMENTO_2` | Pertenece a RF-24..RF-28 | No meter en MVP |
| `RETIRAR_MVP` | Contradice/fuera del alcance actual | Sacar del MVP sin borrar historial |
| `NUEVO_DELTA_ARQUITECTURA` | Trabajo necesario por el cambio arquitectónico | Crear y ejecutar |
| `NUEVO_REQUERIDO` | Hueco entre SRS y backlog legacy | Crear en Jira |

## 3. Punto de partida real de la arquitectura anterior

Antes de listar tareas hay que corregir el supuesto de partida. La arquitectura anterior **no es un backend que haya que mover de lenguaje**: es un cliente Flutter hablando directo con Supabase, con la lógica de negocio en la base de datos.

Lo verificado en `MANI-Flutter`:

- `main` contiene únicamente el scaffold por defecto de Flutter (un archivo en `lib/`). El producto real vive en **`develop` y `release`**, con 128 archivos en `lib/` y arquitectura limpia por feature (`data` / `domain` / `presentation`), BLoC, `get_it` y `go_router`.
- Los **siete `*_remote_datasource.dart` instancian `SupabaseClient`** y llaman `.rpc()`, `.from()` y `.storage.from()` directamente. No hay backend propio ni API Gateway; el `nginx.conf` del repositorio sirve la SPA.
- La lógica de negocio está en **unas 32 funciones PL/pgSQL** bajo `database/` (`crear_solicitud`, `aceptar_solicitud`, `rechazar_solicitud`, `registrar_aliado_empresa`, `resolver_verificacion_aliado`, `_sol_aliado_elegible`, `_sol_zona_cubierta`, `_zona_activa` y auxiliares), más las políticas RLS.
- `database/`, `docker-compose.yml`, `scripts/` y las migraciones viven **dentro del repositorio Flutter**, y su CI es el que las ejecuta.
- El registro escribe en las tablas `usuario` y `cliente` con `.from().upsert()` desde el cliente, sin pasar por función alguna.

Dos consecuencias para el backlog:

1. La migración consiste en **crear el backend que no existe y sacar al cliente de la base de datos**, no en traducir servicios entre lenguajes.
2. Los riesgos **KI-01** y **KI-02** del SAD están mal calibrados: KI-01 supone lógica de negocio en Flutter, pero la lógica está en PL/pgSQL. Lo que hay en Flutter son casos de uso que orquestan llamadas RPC.

### Qué trabajo ya hecho se conserva

Se conserva la inversión en Supabase, Auth, RLS y aislamiento multi-tenant; registro y aprobación de aliados; registro de cliente; categorías; creación de solicitud; exclusión concurrente; las PoC de despacho, identidad y Storage/KYC; los pipelines, GHCR, secretos y promoción de ambientes; los seeds multi-tenant; y la documentación y diagramas consolidados.

Ese trabajo **no se desecha**. Cambia de ubicación: parte de la lógica se mueve a Gateway, Rules Java, Dispatch .NET, Core Node y Availability Node, y el cliente deja de ser quien la invoca.

## 4. Dónde van las tareas de migración

No se crea una épica de migración aparte. El trabajo de transición se reparte en los contenedores que ya existen en Jira:

| Destino | Qué recibe | Convención |
|---|---|---|
| **EP-09 — Gestión y configuración del proyecto** | Plataforma, repositorios, Gateway, esqueletos de servicio, identidad, CI/CD, GHCR, Compose, Kubernetes, configuración del cliente Flutter y regresión | `CFG-15` … `CFG-40`, más el spike `SP-05` |
| **EP-10 — Documentación de arquitectura y entregables académicos** | ADR de la decisión sobre PL/pgSQL, matriz de trazabilidad, actualización de SAD/SDD y del contexto de IA | `DOC-25` … `DOC-28` |
| **Las 9 historias ya desarrolladas** | El trabajo funcional de migrar y revalidar cada caso de uso, como **subtareas** de la propia historia | `US-xx-M1` … `US-xx-Mn` |

La regla de la sección anterior se mantiene: **ninguna historia en Done se reabre**. Las subtareas `-Mn` cuelgan de la historia para que el trabajo quede trazado contra el requisito original, mientras el estado histórico de la historia permanece intacto.

### 4.1 Spike bloqueante

| ID | Épica | Pts | Spike |
|---|---|---:|---|
| `SP-05` | EP-09 | 5 | Decidir si los servicios reescriben la lógica PL/pgSQL o la invocan |

Es la decisión que falta y la que **impide estimar el trabajo funcional**: ¿los servicios nuevos llaman a las funciones existentes, dejando la lógica en la base de datos, o acceden a tablas y la lógica se reescribe en Java, .NET y Node? KI-02 apunta a reescribir, pero nunca se decidió ni se tasó. Mientras no se cierre, las subtareas `-M2` de todas las historias no son estimables.

### 4.2 Plataforma y configuración — EP-09

| ID | Pts | Tarea | Depende de |
|---|---:|---|---|
| `CFG-15` | 5 | Crear los repositorios faltantes del modelo multi-repo | — |
| `CFG-16` | 5 | Definir los contratos OpenAPI entre Gateway y servicios | CFG-15 |
| `CFG-17` | 8 | Implementar el NGINX API Gateway como entrada única | CFG-15, CFG-16 |
| `CFG-18` | 5 | Crear el esqueleto del Rules Service en Java | CFG-15 |
| `CFG-19` | 5 | Crear el esqueleto del Dispatch Service en .NET | CFG-15 |
| `CFG-20` | 8 | Crear el esqueleto de los Core Services en Node.js | CFG-15 |
| `CFG-21` | 5 | Crear el esqueleto del Availability Service en Node.js | CFG-15 |
| `CFG-22` | 8 | Alinear emisión y propagación de JWT entre Auth, Gateway y servicios | CFG-17..21 |
| `CFG-23` | 8 | **Rediseñar el modelo de identidad en base de datos porque RLS deja de filtrar por `auth.uid()`** | CFG-22, SP-05 |
| `CFG-24` | 5 | Inventariar y mapear cada función PL/pgSQL a su servicio dueño | SP-05 |
| `CFG-25` | 5 | Aplicar la propiedad lógica de datos por dominio | CFG-24 |
| `CFG-26` | 5 | Alinear los proyectos Supabase de DEV, TEST/QA y PROD | — |
| `CFG-27` | 5 | Estandarizar imágenes OCI y publicación multi-repo en GHCR | CFG-15 |
| `CFG-28` | 5 | Actualizar el Docker Compose por ambiente para consumir GHCR | CFG-27, CFG-33 |
| `CFG-29` | 8 | Replicar el pipeline CI/CD en cada repositorio | CFG-15, CFG-27 |
| `CFG-30` | 5 | Extender la observabilidad al Gateway y a todos los servicios | CFG-17..21 |
| `CFG-31` | 5 | Definir hosting y topología concreta de Kubernetes | — |
| `CFG-32` | 8 | Preparar el despliegue en Kubernetes sin romper el Compose actual | CFG-31, CFG-27 |
| `CFG-33` | 8 | Sacar `database/`, `docker-compose.yml`, `scripts/` y `nginx.conf` del repositorio Flutter | CFG-15 |
| `CFG-34` | 8 | Construir la capa HTTP del cliente que sustituye a `SupabaseClient` | CFG-16, CFG-17 |
| `CFG-35` | 5 | Decidir y aplicar qué queda de `supabase_flutter` en el cliente | CFG-34 |
| `CFG-36` | 5 | **Retirar la `SUPABASE_ANON_KEY` del bundle web y rotarla** | CFG-34, CFG-35 |
| `CFG-37` | 3 | Resolver la estrategia de ramas de `MANI-Flutter` antes de migrar | — |
| `CFG-38` | 5 | Reconciliar las 13 ramas `feature`/`fix` con trabajo sin fusionar | CFG-37 |
| `CFG-39` | 5 | Montar la base de pruebas del cliente contra un mock del Gateway | CFG-16, CFG-34 |
| `CFG-40` | 8 | Ejecutar la regresión funcional sobre todo lo legacy preservado | CFG-23, CFG-34, CFG-38 |

Tres de estas tareas no estaban contempladas y son las de mayor riesgo:

- **`CFG-23`** — las políticas RLS derivan tenant y usuario de `auth.uid()` porque hoy el llamador es el cliente. Cuando el llamador pase a ser un servicio con `service-role`, **dejan de aislar**. Es el punto que puede tumbar el aislamiento multi-tenant y no estaba nombrado.
- **`CFG-36`** — el artefacto web publicado hoy incluye la `SUPABASE_ANON_KEY`, de modo que cualquiera puede llamar a PostgREST directamente y solo RLS lo contiene. Hay que sacarla del bundle y rotarla.
- **`CFG-38`** — hay 13 ramas vivas con trabajo sin fusionar. Si no se reconcilian primero, el trabajo funcional se ejecuta sobre una base incompleta.

### 4.3 Documentación — EP-10

| ID | Pts | Tarea |
|---|---:|---|
| `DOC-25` | 2 | Actualizar `architecture_context.txt`, que aún describe la arquitectura anterior a las herramientas de IA |
| `DOC-26` | 3 | Registrar en ADR la decisión sobre la capa de funciones PL/pgSQL (resultado de `SP-05`) |
| `DOC-27` | 3 | Reconstruir la matriz de trazabilidad ADR y recuperar los ADR-0022 a ADR-0026 |
| `DOC-28` | 3 | Actualizar SAD y SDD con el resultado real, corrigiendo KI-01 y KI-02 |

### 4.4 Trabajo funcional — subtareas dentro de cada historia desarrollada

Las nueve historias con trabajo ejecutado mapean **una a una** con las siete carpetas de `lib/features/`, lo que permite acotar el delta por historia:

| Historia | Jira | Estado | RF | Código existente | Lógica PL/pgSQL a portar | Servicio destino |
|---|---|---|---|---|---|---|
| `US-02.1.1` Registro aliado persona natural | SCRUM-846 | Done | RF-05 | `features/auth` | `registrar_aliado_persona_natural`, `handle_new_user`, upsert a `usuario` | Core Node |
| `US-02.1.2` Registro aliado empresa | SCRUM-847 | Done | RF-05 | `features/auth` | `registrar_aliado_empresa` | Core Node |
| `US-02.1.3` Aprobar/rechazar aliado | SCRUM-848 | Done | RF-06 | `features/profiles/verification` | `listar_aliados_verificacion`, `obtener_aliado_verificacion`, `resolver_verificacion_aliado` | Core Node |
| `US-02.1.4` Declarar zona de cobertura | SCRUM-849 | Done | RF-07 | `features/profiles/coverage` | `declarar_cobertura`, `obtener_mi_cobertura`, `listar_zonas`, `_zona_activa` | Availability Node |
| `US-02.2.1` Registro cliente persona natural | SCRUM-851 | Done | RF-08 | `features/auth` | `registrar_cliente_persona_natural`, upsert a `cliente` | Core Node |
| `US-03.1.1` Crear categoría con flujo operativo | SCRUM-857 | Done | RF-10 | `features/services/categories` | `crear_categoria_servicio`, `listar_categorias_admin`, `listar_categorias_cliente` | Core Node + Rules Java |
| `US-03.1.3` Aliado declara categorías | SCRUM-859 | In Progress | RF-11 | `features/profile_categories` | `guardar_mis_categorias`, `obtener_mis_categorias`, `listar_categorias_tenant` | Core Node |
| `US-04.1.1` Crear solicitud | SCRUM-860 | Done | RF-12 | `features/services/requests` | `crear_solicitud`, `_sol_zona_cubierta`, `_sol_aliado_elegible`, Storage | Core Node + Availability |
| `US-04.1.4` Aceptar/rechazar sin doble asignación | SCRUM-863 | Done | RF-14 | `features/asignacion` | `aceptar_solicitud`, `rechazar_solicitud`, `listar_solicitudes_aliado` | Dispatch .NET |

Cada historia recibe este patrón de subtareas:

| Subtarea | Qué hace |
|---|---|
| `-M1` | Definir el contrato REST del caso de uso en OpenAPI |
| `-M2` | Implementar el caso de uso en el servicio destino, portando la lógica PL/pgSQL indicada |
| `-M3` | Reescribir el `*_remote_datasource.dart` contra el Gateway |
| `-M4…` | Ajustes específicos de la historia, cuando los hay |
| último | Regresión de la historia y pruebas de aislamiento multi-tenant |

**El punto que conviene defender ante el equipo:** en `-M3` sólo cambia `data/datasources`. Las interfaces de `domain/repositories` se mantienen, así que usecases, BLoC y UI quedan intactos. La arquitectura limpia que ya se aplicó es lo que hace que el delta del cliente sea acotado.

Subtareas específicas más allá del patrón:

| Historia | Subtarea adicional | Por qué |
|---|---|---|
| `US-02.1.3` | Revalidar que los documentos KYC de un aliado nunca sean visibles para otro | El control de acceso a Storage cambia de dueño al pasar al servicio |
| `US-02.1.4` | Reemplazar la selección libre de zona por catálogo jerárquico con coincidencia exacta | Se implementó con mapa y radio; el requisito vigente exige catálogo y coincidencia exacta |
| `US-03.1.1` | Separar la gestión de categoría en Core de las reglas evaluables en Rules | Hoy ambas viven en la misma función PL/pgSQL |
| `US-04.1.1` | Separar la creación en Core de la orquestación del despacho | `crear_solicitud` resuelve creación y elegibilidad en una sola función |
| `US-04.1.4` | **Decidir dónde vive la atomicidad y revalidar PoC-001** | La exclusión concurrente la garantiza hoy la transacción de PostgreSQL; es el mayor riesgo de regresión |
| `US-04.1.4` | Revalidar idempotencia y ausencia de doble asignación bajo concurrencia | Repetir el escenario del PoC contra el servicio .NET a través del Gateway |

### 4.5 Orden de ejecución

1. `CFG-37`, `CFG-38` — reconciliar ramas y fijar la base de código. **Antes de todo lo demás.**
2. `SP-05` — cerrar la decisión sobre PL/pgSQL. Bloquea toda estimación funcional.
3. `CFG-15` … `CFG-21` — repositorios, contratos, Gateway y esqueletos de servicio.
4. `CFG-22`, `CFG-23`, `CFG-24`, `CFG-25` — identidad, RLS y propiedad de datos.
5. `CFG-26` … `CFG-30`, `CFG-33` — Supabase por ambiente, GHCR, Compose, CI/CD, observabilidad y reubicación de artefactos.
6. `CFG-34` … `CFG-36`, `CFG-39` — capa HTTP del cliente, recorte de `supabase_flutter`, seguridad del bundle y mock de pruebas.
7. Subtareas `-M1` … `-Mn` por historia, en el orden de las épicas funcionales.
8. `CFG-40` — regresión completa.
9. `CFG-31`, `CFG-32` — cerrar Kubernetes por ADR y ejecutar la transición de despliegue.
10. `DOC-25` … `DOC-28` — documentación, en paralelo y cerrando al final.

Corrección frente a la versión anterior de este backlog: `SP-05` y `CFG-23` estaban ausentes y son **bloqueantes del trabajo funcional**; van en las fases 1 y 2, no al final.

## 5. Huecos del backlog frente al SRS

Historias nuevas que el SRS exige y el backlog legacy no cubre. Van bajo su épica funcional, no bajo EP-09.

| ID | Épica | RF | Historia nueva | Componente |
|---|---|---|---|---|
| `HU-N-01` | EP-01 | RF-01 | Administrar tenants y su estado base | Core Node |
| `HU-N-02` | EP-01 | RF-02 / RNF-02 / REST-05 | Configurar reglas operativas por tenant sin despliegue | Rules Java + Core Node |
| `HU-N-03` | EP-01 | RF-03 / RNF-01 | Autenticar y autorizar por tenant y rol | Supabase Auth + Gateway + servicios |
| `HU-N-04` | EP-02 | RF-04 | Recuperar contraseña de forma segura | Supabase Auth + Core Node |
| `HU-N-05` | EP-04D | RF-19 | Cerrar servicio sólo tras calificación bidireccional | Core Node |

## 6. Revisión de Historias de Usuario legacy

| ID | Jira | Estado histórico | Disposición V4 | Requisito | Acción |
|---|---|---|---|---|---|
| `US-08.3.2` | SCRUM-901 | To Do | `POSTERGAR_INCREMENTO_2` | RF-28 | Segundo incremento. |
| `US-08.3.1` | SCRUM-900 | To Do | `POSTERGAR_INCREMENTO_2` | RF-28 | Segundo incremento. |
| `US-08.2.2` | SCRUM-899 | To Do | `REESPECIFICAR_INCREMENTO_2` | RF-27 | Campañas pueden vivir dentro de la consola si PO las ratifica. |
| `US-08.2.1` | SCRUM-898 | To Do | `REESPECIFICAR_INCREMENTO_2` | RF-27 | RF-27 exige consola de comercialización/publicación; redes conectadas son una posible función, no obligación actual. |
| `US-08.1.3` | SCRUM-897 | To Do | `REESPECIFICAR_INCREMENTO_2` | RF-26 + pagos | Depende de política de disputa y pago. |
| `US-08.1.2` | SCRUM-896 | To Do | `POSTERGAR_INCREMENTO_2` | RF-26 | Segundo incremento. |
| `US-08.1.1` | SCRUM-895 | To Do | `POSTERGAR_INCREMENTO_2` | RF-26 | Segundo incremento. |
| `US-07.2.2` | SCRUM-894 | To Do | `BACKLOG_INCREMENTO_2` | Complementario RF-25 | Conservar como vista financiera posterior. |
| `US-07.2.1` | SCRUM-893 | To Do | `POSTERGAR_INCREMENTO_2` | RF-25 | Liquidación descontando comisión configurable. |
| `US-07.1.5` | SCRUM-892 | To Do | `REESPECIFICAR_INCREMENTO_2` | No explícito en SRS | Liberación automática de escrow depende de decisión no tomada. |
| `US-07.1.4` | SCRUM-891 | To Do | `REESPECIFICAR_INCREMENTO_2` | No explícito en SRS | Escrow no está comprometido por el SRS; requiere decisión/regulación antes de implementar. |
| `US-07.1.3` | SCRUM-890 | To Do | `BACKLOG_INCREMENTO_2` | Complementario RF-24 | Conservar como detalle de producto posterior. |
| `US-07.1.2` | SCRUM-889 | To Do | `POSTERGAR_INCREMENTO_2` | RNF-04 / RF-24 | Segundo incremento; auditoría financiera inmutable. |
| `US-07.1.1` | SCRUM-888 | To Do | `POSTERGAR_INCREMENTO_2` | RF-24 | Segundo incremento; operador certificado. |
| `US-06.1.3` | SCRUM-887 | To Do | `REESPECIFICAR` | RF-23 | Reporte por período de cotizaciones fuera de rango; no limitarlo solo a mensual. |
| `US-06.1.2` | SCRUM-886 | To Do | `CONTINUAR` | RF-22 | Mostrar tarifario de referencia al cotizar. |
| `US-06.1.1` | SCRUM-885 | To Do | `REESPECIFICAR` | RF-22 | Gestionar mínimo/típico/máximo por categoría y tenant; carga por archivo puede ser una interfaz, no el requisito. |
| `US-05.1.4` | SCRUM-884 | To Do | `CONTINUAR` | RF-20 | Notificaciones de eventos del ciclo. |
| `US-05.1.3` | SCRUM-883 | To Do | `CONTINUAR` | RF-21 | Consulta de conversación para soporte/quejas. |
| `US-05.1.2` | SCRUM-882 | To Do | `CONTINUAR` | RF-20 | Fallback push cuando destinatario no está conectado. |
| `US-05.1.1` | SCRUM-881 | To Do | `CONTINUAR` | RF-20 | Mensajería por servicio. |
| `US-04.6.2` | SCRUM-880 | To Do | `BACKLOG_SECUNDARIO` | RNF-04 relacionado | Útil para trazabilidad, pero no RF independiente. |
| `US-04.6.1` | SCRUM-879 | To Do | `BACKLOG_SECUNDARIO` | RNF-04 relacionado | Útil para trazabilidad, pero no RF independiente. |
| `US-04.5.2` | SCRUM-878 | To Do | `POSTERGAR` | No explícito en MVP / depende pagos | No comprometer en MVP; depende del modelo financiero. |
| `US-04.5.1` | SCRUM-877 | To Do | `BACKLOG_SECUNDARIO` | No explícito en SRS | Mantener como posible regla futura de ciclo. |
| `US-04.4.3` | SCRUM-876 | To Do | `BACKLOG_SECUNDARIO` | RF-13 relacionado | Puede alimentar ranking, pero no es RF independiente. |
| `US-04.4.2` | SCRUM-875 | To Do | `REESPECIFICAR` | RF-19 | Debe integrarse a calificación bidireccional; cierre bloqueado hasta ambas calificaciones. |
| `US-04.4.1` | SCRUM-874 | To Do | `REESPECIFICAR` | RF-19 | Debe integrarse a calificación bidireccional; cierre bloqueado hasta ambas calificaciones. |
| `US-04.3.6` | SCRUM-873 | To Do | `BACKLOG_SECUNDARIO` | No explícito en SRS | Offline no está exigido por el SRS actual. Mantener como mejora futura. |
| `US-04.3.5` | SCRUM-872 | To Do | `BACKLOG_SECUNDARIO` | No explícito en SRS | Conservar como posible evolución, no como compromiso del MVP actual. |
| `US-04.3.4` | SCRUM-871 | To Do | `RETIRAR_MVP` | Fuera de alcance | Geolocalización en tiempo real está explícitamente fuera del MVP. |
| `US-04.3.3` | SCRUM-870 | To Do | `CONTINUAR` | RF-18 | Consulta del historial del servicio basada en eventos registrados. |
| `US-04.3.2` | SCRUM-869 | To Do | `CONTINUAR` | RF-18 | Evidencias/observaciones dentro de la trazabilidad. |
| `US-04.3.1` | SCRUM-868 | To Do | `CONTINUAR` | RF-18 | Registrar eventos cronológicos de ejecución. |
| `US-04.2.3` | SCRUM-867 | To Do | `CONTINUAR` | RF-17 | Aceptar, rechazar o solicitar ajuste. |
| `US-04.2.2` | SCRUM-866 | To Do | `REESPECIFICAR` | RF-16 | Comparar con mínimo/típico/máximo de tarifario, no con 'promedio del mercado'. |
| `US-04.2.1` | SCRUM-865 | To Do | `CONTINUAR` | RF-15 | Cotización pertenece a Core; separar mano de obra y materiales. |
| `US-04.1.5` | SCRUM-864 | To Do | `REESPECIFICAR` | RF-13 | No fijar solo comisión. Debe ser ranking configurable por tenant: cobertura/calificación/comisión u otra regla. |
| `US-04.1.4` | SCRUM-863 | Done | `PRESERVAR_Y_VALIDAR` | RF-14 / RNF-03 / RNF-05 | Reutilizar PoC/implementación; validar operación atómica e idempotencia en el nuevo servicio .NET. |
| `US-04.1.3` | SCRUM-862 | To Do | `BACKLOG_SECUNDARIO` | No explícito en SRS | Mantener como mejora opcional; no es RF actual. |
| `US-04.1.2` | SCRUM-861 | To Do | `CONTINUAR` | RF-12 | Elegibilidad por categoría y coincidencia exacta de zona; sin proximidad. |
| `US-04.1.1` | SCRUM-860 | Done | `PRESERVAR_Y_VALIDAR` | RF-12 | La creación existe; separar creación/core de orquestación de despacho. |
| `US-03.1.3` | SCRUM-859 | In Progress | `CONTINUAR` | RF-11 | Completar asociación aliado-categoría. |
| `US-03.1.2` | SCRUM-858 | To Do | `CONTINUAR` | RF-10 | No eliminar categorías con operación histórica; activar/desactivar. |
| `US-03.1.1` | SCRUM-857 | Done | `PRESERVAR_Y_VALIDAR` | RF-10 | La funcionalidad existe; separar gestión de categoría en Core y reglas evaluables en Rules. |
| `US-02.3.2` | SCRUM-856 | To Do | `BACKLOG_SECUNDARIO` | Cumplimiento/legal | Mantener como requisito complementario; no sustituye un RF del SRS. |
| `US-02.1.6` | SCRUM-855 | To Do | `CONTINUAR` | RF-12 / RNF-07 | Mantener como soporte de elegibilidad/disponibilidad, sin convertirlo en requisito geoespacial. |
| `US-02.3.1` | SCRUM-854 | To Do | `BACKLOG_SECUNDARIO` | Soporte de perfil | Útil, pero no es driver principal del SRS actual. Mantener sin desplazar RF críticos. |
| `US-02.2.3` | SCRUM-853 | To Do | `CONTINUAR` | RF-09 | Las reglas del sitio deben ser visibles antes de programación y el sitio debe tener zona. |
| `US-02.2.2` | SCRUM-852 | To Do | `CONTINUAR` | RF-08 | Alinear cliente empresa con múltiples sitios. |
| `US-02.2.1` | SCRUM-851 | Done | `PRESERVAR_Y_VALIDAR` | RF-08 | La funcionalidad existe; validar aislamiento tenant y flujo de identidad. |
| `US-02.1.5` | SCRUM-850 | To Do | `CONTINUAR` | RF-05 | Alinear empleado directo con tipo de aliado permitido por el SRS. |
| `US-02.1.4` | SCRUM-849 | Done | `REESPECIFICAR_Y_REUTILIZAR` | RF-07 / RNF-09 / REST-01 | Conservar trabajo útil, pero reemplazar cualquier selección libre en mapa/radio por catálogo jerárquico de zonas, MVP localidad/comuna. |
| `US-02.1.3` | SCRUM-848 | Done | `PRESERVAR_Y_VALIDAR` | RF-06 | Conservar; validar que documentos de otros aliados nunca sean visibles. |
| `US-02.1.2` | SCRUM-847 | Done | `PRESERVAR_Y_VALIDAR` | RF-05 | La funcionalidad existe; validar modelo empresa/representante bajo Core actual. |
| `US-02.1.1` | SCRUM-846 | Done | `PRESERVAR_Y_VALIDAR` | RF-05 | La funcionalidad existe; validar/portar al límite Core actual y repetir aislamiento KYC. |

## 7. Cambios de alcance importantes

### Cobertura
La HU legacy de cobertura hablaba de delimitar zonas/barrios en un mapa. La línea actual exige **catálogo jerárquico de zonas y coincidencia exacta**, sin radio ni proximidad. El trabajo existente se reutiliza, pero debe adaptarse.

### Ranking
`US-04.1.5` no debe quedar como «priorizar por comisión» únicamente. El requisito actual es **ranking configurable por tenant**, donde comisión puede ser uno de varios criterios.

### Geolocalización en vivo
`US-04.3.4` sale del MVP. Se conserva en histórico, pero no debe consumir capacidad del incremento actual.

### Calificaciones
Las dos historias de calificación deben converger en RF-19: **cliente y aliado califican, y el servicio no puede cerrarse hasta tener ambas calificaciones**.

### Pagos, escrow y disputas
Pagos y liquidación permanecen en el segundo incremento. Escrow, liberación automática y reglas detalladas de disputa no se asumen como alcance aprobado hasta que exista decisión funcional/regulatoria.

## 8. Estrategia recomendada en Jira

1. **No borrar issues antiguos.**
2. **No cambiar Done a To Do** para representar la migración.
3. Mantener `EP-09 - Gestión y configuración del proyecto` como contenedor de la transición de plataforma, ampliando su descripción a «transición arquitectónica y plataforma». Crear allí `CFG-15` … `CFG-40` y `SP-05`.
4. Crear `DOC-25` … `DOC-28` bajo `EP-10`.
5. Crear las subtareas `-Mn` **colgando de cada historia ya desarrollada**, sin tocar su estado histórico. Así el trabajo de migración queda trazado contra el requisito original en lugar de vivir en una épica paralela.
6. Crear `HU-N-01` … `HU-N-05` bajo sus épicas funcionales (EP-01, EP-02, EP-04D).
7. En las historias legacy aún abiertas, actualizar descripción y criterios cuando la disposición sea `REESPECIFICAR`.
8. Mover RF-24..RF-28 a un backlog de **Segundo Incremento**, no al sprint del MVP.
9. Marcar lo que sale de alcance como `Won't Do` o `Cancelled` si el workflow lo permite, conservando la razón y la referencia al SRS.

### Defecto corregido en el inventario

El `Backlog ID` de cuatro filas legacy se había derivado del texto del resumen, de modo que subtareas que *mencionaban* `CFG-04`, `CFG-06`, `CFG-09` o `SP-02.1.1` quedaron con ese identificador y colisionaban con la tarea real. Esas cuatro filas usan ahora su propia clave Jira (`SCRUM-959`, `SCRUM-985`, `SCRUM-1059`, `SCRUM-970`). El CSV queda sin identificadores duplicados ni dependencias colgantes.

## 9. Definición de llegada

La transición puede considerarse completada cuando:

- Flutter consume la solución a través del NGINX Gateway para toda operación de negocio, y **no queda ningún acceso PostgREST desde el cliente**.
- La `SUPABASE_ANON_KEY` ya no viaja en el artefacto web.
- Rules corre en Java, Dispatch en .NET, y Core y Availability en Node.js.
- Dispatch conserva exactamente una asignación válida bajo concurrencia, con el PoC-001 revalidado.
- Supabase/PostgreSQL mantiene RLS **con el modelo de identidad rediseñado** para un llamador que es un servicio, no el usuario final.
- Auth, Storage y Realtime están integrados según el SAD, y el destino de cada función PL/pgSQL está decidido y registrado en ADR.
- `database/`, Compose y scripts viven en su repositorio dueño, y está definido quién ejecuta las migraciones en cada ambiente.
- Cada repositorio publica su imagen en GHCR y las VMs pueden levantarlas con Compose.
- CI/CD y las pruebas de aislamiento funcionan por repositorio.
- Las nueve historias preservadas pasan la regresión.
- El proveedor y la topología de Kubernetes quedan cerrados por ADR y pueden desplegar las mismas imágenes OCI.

## 10. Archivos

- `BACKLOG_MANI_V4_TRANSICION.md`: criterio de transición y backlog legible.
- `BACKLOG_MANI_V4_TRANSICION.csv`: inventario completo de Jira más los ítems nuevos, con clasificación y delta. 328 filas, 18 columnas, listo para importar.

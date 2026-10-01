# Product Backlog MANI — V4 de transición

**Objetivo:** conservar todo el trabajo ya ejecutado en Jira, alinear el producto con el SRS vigente y crear explícitamente las tareas necesarias para migrar de la implementación anterior a la arquitectura objetivo actual.

> Regla principal: **una historia o tarea histórica marcada Done no se reabre solo porque cambió la arquitectura**. Se conserva su evidencia. Si necesita adaptación, se crea una tarea `MIG-xx` o un bug de regresión. Así no se borra trabajo real ni se finge que la migración ya ocurrió.

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
| `PRESERVAR_Y_VALIDAR` | Funcionalidad terminada y todavía requerida | Reutilizar y validar mediante MIG/regresión |
| `REESPECIFICAR_Y_REUTILIZAR` | Hay trabajo útil pero cambió el requisito | Conservar código/evidencia y adaptar |
| `CONTINUAR` | Historia pendiente alineada al SRS | Continuar, ajustada al componente objetivo |
| `REESPECIFICAR` | La HU actual es demasiado específica o contradice el SRS | Actualizar alcance antes de implementar |
| `BACKLOG_SECUNDARIO` | Útil pero no requisito principal del MVP | Mantener detrás de RF críticos |
| `POSTERGAR_INCREMENTO_2` | Pertenece a RF-24..RF-28 | No meter en MVP |
| `RETIRAR_MVP` | Contradice/fuera del alcance actual | Sacar del MVP sin borrar historial |
| `NUEVO_DELTA_ARQUITECTURA` | Trabajo necesario por el cambio arquitectónico | Crear y ejecutar |
| `NUEVO_REQUERIDO` | Hueco entre SRS y backlog legacy | Crear en Jira |

## 3. Qué trabajo ya hecho se conserva

Se conservan especialmente los avances ya ejecutados en:

- Supabase, Auth, RLS y aislamiento multi-tenant.
- Registro y aprobación de aliados.
- Registro de cliente persona natural.
- Categorías.
- Creación de solicitud.
- Exclusión concurrente / aceptación sin doble asignación.
- PoC de despacho concurrente.
- PoC de identidad/claims de tenant.
- PoC de Storage/KYC.
- pipelines, GHCR, secretos y promoción de ambientes.
- seeds multi-tenant.
- documentación y diagramas ya consolidados.

Ese trabajo **no se desecha**. La diferencia es que parte de la implementación debe moverse o validarse dentro de los límites nuevos: Gateway, Rules Java, Dispatch .NET, Core Node y Availability Node.

## 4. Delta arquitectónico que sí hay que ejecutar

| ID | Prioridad | Pts | Tarea | Dependencias |
|---|---|---:|---|---|
| `MIG-01` | Highest | 5 | Crear repositorios faltantes del modelo multi-repo | — |
| `MIG-02` | Highest | 5 | Definir contratos OpenAPI entre Gateway y servicios | — |
| `MIG-03` | Highest | 8 | Implementar NGINX API Gateway como entrada única | — |
| `MIG-04` | Highest | 5 | Crear esqueleto Rules Service en Java | — |
| `MIG-05` | Highest | 5 | Crear esqueleto Dispatch Service en .NET | — |
| `MIG-06` | Highest | 8 | Crear esqueleto Core Services en Node.js | — |
| `MIG-07` | High | 5 | Crear Availability Service en Node.js | — |
| `MIG-08` | Highest | 8 | Portar y validar registro/KYC ya implementado al Core actual | MIG-06,MIG-14 |
| `MIG-09` | High | 5 | Portar categorías y asociación aliado-categoría | MIG-04,MIG-06 |
| `MIG-10` | Highest | 8 | Portar creación de solicitud al Core y despacho al servicio .NET | MIG-05,MIG-06,MIG-07 |
| `MIG-11` | Highest | 8 | Portar aceptación concurrente a Dispatch .NET | MIG-05,MIG-14 |
| `MIG-12` | Highest | 5 | Ajustar cobertura implementada a catálogo jerárquico de zonas | MIG-07 |
| `MIG-13` | High | 5 | Aplicar propiedad lógica de datos por dominio | MIG-04,MIG-05,MIG-06,MIG-07 |
| `MIG-14` | Highest | 8 | Alinear JWT, Gateway, servicios y RLS | MIG-03,MIG-04,MIG-05,MIG-06,MIG-07 |
| `MIG-15` | High | 5 | Alinear Supabase DEV, TEST/QA y PROD | — |
| `MIG-16` | Highest | 5 | Estandarizar imágenes OCI y publicación multi-repo en GHCR | MIG-01 |
| `MIG-17` | High | 5 | Actualizar Docker Compose por ambiente para consumir GHCR | MIG-16 |
| `MIG-18` | Highest | 8 | Replicar pipeline CI/CD por repositorio | MIG-01,MIG-16 |
| `MIG-19` | High | 5 | Extender observabilidad a Gateway y todos los servicios nuevos | MIG-03,MIG-04,MIG-05,MIG-06,MIG-07 |
| `MIG-20` | High | 5 | Definir hosting y topología concreta de Kubernetes | — |
| `MIG-21` | High | 8 | Preparar despliegue Kubernetes sin romper Compose actual | MIG-20,MIG-16 |
| `MIG-22` | Highest | 8 | Ejecutar regresión funcional sobre funcionalidades legacy preservadas | MIG-08,MIG-09,MIG-10,MIG-11,MIG-12,MIG-14 |

### Orden recomendado

1. `MIG-01..07`: crear la estructura de repositorios y servicios.
2. `MIG-13..18`: datos, identidad, GHCR, Compose y pipelines.
3. `MIG-08..12`: portar/reutilizar las funcionalidades que ya existen.
4. `MIG-19`: observabilidad transversal.
5. `MIG-22`: regresión completa del trabajo preservado.
6. `MIG-20..21`: cerrar hosting/topología Kubernetes y ejecutar la transición cuando el ADR correspondiente exista.

## 5. Huecos del backlog frente al SRS

| ID | RF | Historia nueva | Componente |
|---|---|---|---|
| `HU-N-01` | RF-01 | Administrar tenants y su estado base | Core Node |
| `HU-N-02` | RF-02 / RNF-02 / REST-05 | Configurar reglas operativas por tenant sin despliegue | Rules Java + Core Node |
| `HU-N-03` | RF-03 / RNF-01 | Autenticar y autorizar por tenant y rol | Supabase Auth + Gateway + Services |
| `HU-N-04` | RF-04 | Recuperar contraseña de forma segura | Supabase Auth + Core Node |
| `HU-N-05` | RF-19 | Cerrar servicio solo tras calificación bidireccional | Core Node |

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
3. Mantener `EP-09 - Gestión y configuración del proyecto`, pero ampliarla como épica de **transición arquitectónica y plataforma**.
4. Crear `MIG-01..MIG-22` bajo EP-09.
5. Crear `HU-N-01..HU-N-05` bajo las épicas funcionales correspondientes.
6. En las HUs legacy aún abiertas, actualizar descripción/criterios cuando la disposición sea `REESPECIFICAR`.
7. Mover RF-24..RF-28 a un backlog de **Segundo Incremento**, no al Sprint MVP.
8. Marcar historias fuera de alcance como `Won't Do`/`Cancelled` si el workflow de Jira lo permite, conservando la razón y la referencia al SRS.

## 9. Definición de llegada

La transición puede considerarse completada cuando:

- Flutter consume la solución a través de NGINX Gateway para operaciones de negocio.
- Rules corre en Java.
- Dispatch corre en .NET y conserva exactamente una asignación válida.
- Core y Availability corren en Node.js.
- Supabase/PostgreSQL mantiene RLS y separación por dominio.
- Auth, Storage y Realtime están integrados según el SAD.
- cada repositorio publica su imagen en GHCR.
- las VMs pueden levantar los servicios con Compose usando esas imágenes.
- CI/CD y pruebas de aislamiento funcionan por repositorio.
- las funcionalidades históricas preservadas pasan la regresión.
- el proveedor/topología Kubernetes queda cerrado por ADR y puede desplegar las mismas imágenes OCI.

## 10. Archivos

- `BACKLOG_MANI_V4_TRANSICION.md`: criterio de transición y backlog legible.
- `BACKLOG_MANI_V4_TRANSICION.csv`: inventario completo de Jira + ítems nuevos + clasificación y delta.

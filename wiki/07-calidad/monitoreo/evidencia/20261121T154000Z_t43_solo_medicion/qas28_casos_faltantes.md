# QAS-28: casos de prueba de las 6 historias críticas sin caso

Corte 2026-11-21. Los casos salen de los criterios C1, C2 y C3 de cada historia en Jira (decisión DoR opción C, 26 oct) o, si la historia no los tiene, de su enunciado. El ambiente es MANI-QA por el Gateway, con un token real ES256 de las cuentas CFG-04 (`cliente.t1`, `aliado.t1`, `admin.t1` y `cliente.t2` para cruzar tenant).

Ejecutar y registrar estos casos le corresponde a la matriz del sprint. Este documento solo los define, para cerrar la trazabilidad historia ↔ caso.

| Caso | Historia | Tipo | Precondición | Pasos | Resultado esperado |
|---|---|---|---|---|---|
| CP-871-01 | SCRUM-871 (HU-M07-04) Estado y zona declarada | Positivo | `cliente.t1` con una solicitud asignada que tiene zona declarada | Abrir el detalle de la solicitud en Flutter | Se ven el estado vigente y la zona, rotulada como zona declarada con su fecha u origen, no como ubicación actual. Al recargar se ve el estado nuevo si cambió. |
| CP-871-02 | SCRUM-871 | Negativo | Solicitud sin zona declarada, o un id inexistente | Abrir el detalle o pedir `GET` por el Gateway | Estado vacío controlado o 404 según contrato. No aparecen posiciones, recorridos ni tiempos estimados inventados. |
| CP-871-03 | SCRUM-871 | Seguridad | Solicitud de `cliente.t1` | Pedir el estado de esa solicitud con `cliente.t2` (otro tenant) y con otro cliente del mismo tenant | 403 o 404, sin datos de la solicitud ajena. |
| CP-872-01 | SCRUM-872 (US-04.3.5) Adición por imprevisto | Positivo | `aliado.t1` asignado a un servicio activo | Solicitar una adición con motivo y ajuste de costo o tiempo | La adición queda pendiente de la decisión del cliente, y el cliente la ve con su motivo y su monto. |
| CP-872-02 | SCRUM-872 | Negativo | Adición pendiente | Consultar el total del servicio antes de que el cliente acepte | El total no incluye la adición. Solo cambia después de `POST /adiciones/{id}/aceptar`. |
| CP-872-03 | SCRUM-872 | Seguridad | Servicio de `cliente.t1` asignado a `aliado.t1` | Solicitar la adición con otro aliado y aceptarla con otro cliente | 403 en ambos casos; la adición no cambia. |
| CP-876-01 | SCRUM-876 (US-04.4.3) Calificación agregada | Positivo | Aliado con servicios calificados | Ver el listado de aliados como cliente | Se ve la calificación agregada y coincide con el promedio de las calificaciones registradas. |
| CP-876-02 | SCRUM-876 | Negativo | Aliado sin calificaciones | Ver el listado | Se muestra «sin valorar», no 0 ni estrellas vacías como si fuera una nota. |
| CP-876-03 | SCRUM-876 | Seguridad | Calificaciones en los dos tenants | Ver el listado como `cliente.t1` | El agregado solo cuenta calificaciones del tenant 1. |
| CP-881-01 | SCRUM-881 (US-05.1.1) Mensajería | Positivo | Servicio asignado entre `cliente.t1` y `aliado.t1` | Enviar mensajes desde los dos lados y recargar | Los mensajes aparecen en orden, en el hilo del servicio, y persisten al recargar. |
| CP-881-02 | SCRUM-881 | Negativo | Error del proveedor o de la red al enviar | Enviar un mensaje con la red cortada | La app no lo muestra como entregado, avisa y conserva el texto para reintentar. |
| CP-881-03 | SCRUM-881 | Seguridad | Hilo de un servicio ajeno | Leer o escribir en ese hilo con un usuario que no participa y con `cliente.t2` | 403 o 404, sin mensajes. |
| CP-1061-01 | SCRUM-1061 (US-02.1.1-M3) Registro de aliado por el Gateway | Positivo | Correo nuevo | Registrarse como aliado técnico desde Flutter | El registro pasa por el Gateway (`/api/v1/auth/...`) y no llama a Supabase desde el cliente, salvo `supabase.auth`. La cuenta queda creada en el tenant. |
| CP-1061-02 | SCRUM-1061 | Negativo | Correo ya registrado, o datos inválidos | Intentar el registro | La app muestra el error del Gateway en español, sin crear una cuenta duplicada. |
| CP-1061-03 | SCRUM-1061 | Arquitectura | Código de `develop` | Revisar `auth_remote_datasource.dart` y su prueba de arquitectura | No usa `SupabaseClient` para datos (`.from`, `.rpc`, `.storage`); la interfaz de `domain/repositories` no cambia. |
| CP-1071-01 | SCRUM-1071 (US-03.1.3-M2) Aliado ↔ categoría | Positivo | `aliado.t1` | Declarar dos categorías y guardar | Se guardan por el Gateway y persisten al recargar. El aliado aparece en las búsquedas de esas categorías. |
| CP-1071-02 | SCRUM-1071 | Negativo | Categoría desactivada, o id inexistente | Intentar declararla | Rechazo controlado (4xx con mensaje); la selección vuelve a lo último confirmado. |
| CP-1071-03 | SCRUM-1071 | Seguridad | Categoría del tenant 2 | Declararla con `aliado.t1` | Rechazo; no se asocia una categoría de otro tenant. |

**Resultado para QAS-28:** con estos 18 casos, las 51 historias críticas tienen al menos un caso: **51 de 51 (100 %)**.

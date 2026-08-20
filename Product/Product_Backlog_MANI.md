# TRAMA · MANI — Product Backlog

> 🔴 = pendiente de decisión del equipo. Prioridad y estimación son **propuesta inicial**,
> revisable posteriormente por el equipo y por el PO (se valida por Planning Poker sin
> consenso). Este backlog está dirigido **exclusivamente a los requerimientos de nuestro
> producto**; no compara ni referencia backlogs externos.

## 1. Convenciones

- **Jerarquía:** Épica → Feature → Historia de usuario → (Task, Spike, Sub-task, Bug).
- **Estados:** Backlog · Ready · In Progress · In Review · Done. Los spikes usan además
  Timeboxed.
- **Estimación:** puntos de historia (Fibonacci), propuesta inicial.
- **Sprint candidato:** Sprint 0 (spikes/investigación) · Sprint 1 (candidatas, preparadas
  pero no iniciadas) · Posterior.
- Criterios de aceptación en **BDD** (Given/When/Then). Se conservan en la herramienta de
  backlog (Jira); aquí se listan íntegros para las historias candidatas a Sprint 1.

## 2. Clases utilizadas

Toda historia, spike o elemento del backlog lleva una **Clase**. Se usan como mínimo estas
cinco:

| Clase | Significado |
| --- | --- |
| **Funcional** | Historias relacionadas directamente con una capacidad, comportamiento o funcionalidad que el producto debe proporcionar al usuario o al negocio (autenticación, gestión de usuarios, consultas, registro de información, operaciones propias del negocio). |
| **Configuración** | Elementos necesarios para configurar el entorno, herramientas, repositorios, servicios, parámetros o infraestructura que el equipo o el producto requieren para operar. No representan directamente una funcionalidad de negocio para el usuario final. |
| **Técnica / Arquitectura** | Trabajo necesario para resolver aspectos técnicos o arquitectónicos del producto: spikes, evaluaciones técnicas, pruebas de concepto, decisiones arquitectónicas, preparación técnica antes de implementar ciertas funcionalidades. |
| **Calidad / Pruebas** | Trabajo orientado a QA, automatización de pruebas, validaciones, performance, Security Testing y calidad del producto en general. |
| **Gestión / Proceso** | Trabajo necesario para establecer o mantener el sistema de trabajo del proyecto, cuando deba gestionarse dentro de Jira. No se usa para convertir documentación en historias de producto; solo cuando representa trabajo real del sprint. |

**Subtipos dentro de Clase Funcional.** Para organizar el dominio del producto, las
historias de Clase Funcional llevan además un **Subtipo**, definido explícitamente aquí antes
de usarse:

| Subtipo | Significado |
| --- | --- |
| Fundacional | Capacidad base de la que dependen otras funcionalidades (registro de tenant, login). |
| Core | Funcionalidad central del ciclo del servicio (solicitud, cotización, ejecución, calificación). |
| Comunicación | Mensajería y notificaciones entre las partes. |
| Reporte | Consultas agregadas o reportes sobre datos ya registrados. |
| Financiero | Cobro, liquidación y soporte de pago (2º incremento). |

Los spikes se clasifican como **Técnica / Arquitectura**. Ningún elemento del backlog usa una
clase distinta de las cinco listadas arriba sin definirla explícitamente primero.

## 3. Escala de prioridad

| Prioridad | Significado |
| --- | --- |
| **Crítica** | Elemento indispensable para continuar el proyecto, resolver una dependencia fundamental o habilitar una capacidad esencial del producto. |
| **Alta** | Elemento de alto valor o necesidad para el MVP que debe atenderse tempranamente. |
| **Media** | Elemento necesario, pero que puede ejecutarse después de las dependencias o capacidades prioritarias. |
| **Baja** | Elemento cuyo aplazamiento no compromete los objetivos inmediatos del producto o del sprint. |

La prioridad aquí asignada es una **propuesta inicial**; puede ser revisada posteriormente
por el equipo y por el PO según avance el proyecto.

## 4. Multi-tenancy: por qué es la primera épica (justificación propia)

Multi-tenancy es la capacidad de servir a múltiples empresas (tenants) desde una misma
instancia, con datos, configuración y usuarios aislados. En MANI el tenant es una empresa
suscrita; la del cliente actual es el primer tenant. Va primero porque:

- El cliente lo formuló como condición estructural (doble naturaleza: montar la plataforma y
  a la vez operar su empresa).
- El aislamiento por tenant afecta el modelo de datos completo; introducirlo tarde obliga a
  rehacer entidades, consultas, autenticación y control de acceso.
- Cada tenant configura sus reglas (RF-02); sin soporte desde el inicio, cada configuración
  se vuelve código específico y no escala.

## 5. Mapa de épicas

| ID | Épica | Objetivo | Módulos | Incremento |
| --- | --- | --- | --- | --- |
| EP-01 | Plataforma multi-tenant | Múltiples empresas sobre la misma plataforma, aisladas y configurables | M-01 | MVP |
| EP-02 | Directorio de actores | Registro diferenciado de aliados, empleados y clientes | M-02, M-03 | MVP |
| EP-03 | Catálogo y cobertura | Categorías por tenant y zonas de cobertura del aliado | M-04 | MVP |
| EP-04 | Ciclo del servicio | Solicitar, cotizar, ejecutar, calificar y cerrar | M-05..M-08 | MVP |
| EP-05 | Comunicación | Mensajería y notificaciones por servicio | M-09 | MVP |
| EP-06 | Tarifario | Tarifas de referencia y alerta fuera de rango | M-11 | MVP |
| EP-07 | Pagos y facturación | Cobro centralizado y liquidación al aliado | M-10 | 2º incremento |
| EP-08 | Operación y comercialización | Quejas, comercialización y administración | M-12..M-14 | 2º incremento |

---

## 6. SPRINT 0 — Spikes técnicos (trabajo de este corte)

Todo el trabajo de investigación técnica de este corte queda en Sprint 0. Ningún spike
compromete código de producto; su salida es una **decisión**, que se registra como ADR
**únicamente si y cuando** la Mesa de Arquitectura la toma. Este backlog no anticipa números
ni contenidos de ADR.

| ID | Spike | Épica relacionada | Objetivo | Clase | Prior. | Bloquea Sprint 1 |
| --- | --- | --- | --- | --- | --- | --- |
| SP-01.1.1 | Aislamiento multi-tenant | EP-01 | Definir estrategia de aislamiento de datos entre tenants | Técnica / Arquitectura | **Crítica** | Sí — US-01.1.1 |
| SP-01.1.2 | Resolución de tenant por petición | EP-01 | Definir cómo cada petición identifica su tenant | Técnica / Arquitectura | Alta | No |
| SP-01.2.1 | Proveedor de identidad | EP-01 | Definir mecanismo de autenticación y control de acceso | Técnica / Arquitectura | **Crítica** | Sí — US-01.2.1 |
| SP-02.1.1 | Modelo de cobertura | EP-02 | Definir cómo se representa la cobertura por zonas | Técnica / Arquitectura | Alta | No |
| SP-02.1.2 | Almacenamiento de documentos | EP-02 | Definir dónde y cómo se guardan documentos cargados (KYC) | Técnica / Arquitectura | Media | No |
| SP-03.1.1 | Configurabilidad del flujo por categoría | EP-03 | Definir nivel de configuración del flujo operativo por categoría | Técnica / Arquitectura | Media | No |
| SP-04.1.1 | Estrategia de despacho | EP-04 | Definir si el despacho es uno a la vez o simultáneo | Técnica / Arquitectura | **Crítica** | No |
| SP-04.1.2 | Exclusión concurrente *(condicional)* | EP-04 | Definir control de concurrencia, solo si el despacho es simultáneo | Técnica / Arquitectura | Alta | No |
| SP-04.4.1 | Ponderación de calificaciones | EP-04 | Definir cómo se agregan las calificaciones bidireccionales | Técnica / Arquitectura | Media | No |
| SP-05.1.1 | Mecanismo de mensajería en tiempo real | EP-05 | Definir cómo se entregan mensajes y notificaciones | Técnica / Arquitectura | Media | No |
| SP-07.1.1 | Operador de pagos *(2º incremento)* | EP-07 | Evaluar operadores de pago certificados | Técnica / Arquitectura | Baja | No |
| SP-07.1.2 | Facturación *(2º incremento)* | EP-07 | Evaluar requisitos de facturación electrónica | Técnica / Arquitectura | Baja | No |
| SP-08.2.1 | Integraciones de redes sociales *(2º incremento)* | EP-08 | Evaluar integraciones para comercialización | Técnica / Arquitectura | Baja | No |

**Bugs previsibles identificados (no son Sprint 0, quedan registrados para prevención):**

| ID | Descripción | Épica | Prior. |
| --- | --- | --- | --- |
| B-01.2.1 | Un token de un tenant no debe acceder a datos de otro (RNF-01) | EP-01 | **Crítica** |
| B-02.1.1 | Documentos de un aliado no deben ser visibles para otros aliados del tenant | EP-02 | Alta |
| B-04.1.1 | Solicitud rechazada no debe reasignarse al mismo aliado en el mismo ciclo | EP-04 | Media |
| B-04.1.2 | Aceptaciones concurrentes deben dejar exactamente una asignación (RNF-05) | EP-04 | Alta |

---

## 7. SPRINT 1 — Historias candidatas y priorizadas (preparado, NO iniciado)

Estas historias están **priorizadas y listas como candidatas** para el primer sprint de
desarrollo. Ninguna se considera iniciada ni comprometida: la selección definitiva ocurre en
el Planning de Sprint 1, con estimación acordada por el equipo. Todas están contingentes a
que SP-01.1.1 y SP-01.2.1 queden resueltos en Sprint 0.

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF |
| --- | --- | --- | --- | --- | --- | --- |
| US-01.1.1 Registrar tenant | Funcional | Fundacional | **Crítica** | 5 | SP-01.1.1 | RF-01 |
| US-01.1.2 Configurar documentos por tipo de aliado | Configuración | — | Alta | 5 | US-01.1.1 | RF-02 |
| US-01.2.1 Login restringido al tenant | Funcional | Fundacional | **Crítica** | 5 | SP-01.2.1 | RF-03 |
| US-01.2.2 Recuperar contraseña | Funcional | Fundacional | Alta | 3 | US-01.2.1 | RF-04 |
| US-01.2.3 Asignar roles a usuarios | Configuración | — | Alta | 3 | US-01.2.1 | RF-03 |

**Criterios de aceptación (BDD):**

- **US-01.1.1 — Registrar tenant.**
  *Scenario 1:* Given credenciales válidas de administrador de plataforma, When envío nombre,
  NIT y dominio, Then el tenant queda Activo And el evento se registra en auditoría.
- **US-01.1.2 — Configurar documentos por tipo de aliado.**
  *Scenario 1:* Given un tenant activo, When el administrador define los documentos
  requeridos para un tipo de aliado, Then esa configuración aplica a todo registro nuevo de
  ese tipo en ese tenant.
- **US-01.2.1 — Login restringido al tenant.**
  *Scenario 1:* Given credenciales válidas, When envío el login, Then recibo sesión
  restringida a mi tenant And no consulto datos de otro tenant.
  *Scenario 2:* Given cinco intentos fallidos, When intento un sexto, Then la cuenta queda
  bloqueada 15 minutos.
- **US-01.2.2 — Recuperar contraseña.**
  *Scenario 1:* Given un correo registrado, When solicito recuperación, Then recibo enlace con
  expiración de 30 minutos And puedo definir nueva contraseña.
- **US-01.2.3 — Asignar roles.**
  *Scenario 1:* Given acceso de administrador, When asigno un rol a un usuario, Then obtiene
  los permisos del rol And el cambio queda auditado.

---

## 8. Backlog completo por épica (referencia — incluye Sprint 1 y posteriores)

### EP-01 · Plataforma multi-tenant — Prioridad **Crítica**

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-01.1.1 Registrar tenant | Funcional | Fundacional | **Crítica** | 5 | SP-01.1.1 | RF-01 | **Sprint 1** |
| US-01.1.2 Configurar documentos por tipo de aliado | Configuración | — | Alta | 5 | US-01.1.1 | RF-02 | Sprint 1 |
| US-01.1.3 Configurar regla de posicionamiento del listado | Configuración | — | Media | 3 | US-01.1.1 | RF-02, RF-13 | Posterior |
| US-01.2.1 Login restringido al tenant | Funcional | Fundacional | **Crítica** | 5 | SP-01.2.1 | RF-03 | **Sprint 1** |
| US-01.2.2 Recuperar contraseña | Funcional | Fundacional | Alta | 3 | US-01.2.1 | RF-04 | Sprint 1 |
| US-01.2.3 Asignar roles a usuarios | Configuración | — | Alta | 3 | US-01.2.1 | RF-03 | Sprint 1 |

### EP-02 · Directorio de actores — Prioridad **Alta**

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-02.1.1 Registro aliado persona natural (docs. del tenant) | Funcional | Core | Alta | 5 | US-01.1.2 | RF-05 | Posterior |
| US-02.1.2 Registro aliado empresa (carta rep. legal) | Funcional | Core | Alta | 5 | US-01.1.2 | RF-05 | Posterior |
| US-02.1.3 Aprobar/rechazar registro de aliado | Funcional | Core | Alta | 5 | US-02.1.1 | RF-06 | Posterior |
| US-02.1.4 Declarar zona de cobertura | Funcional | Core | Alta | 5 | SP-02.1.1 | RF-07 | Posterior |
| US-02.1.5 Registrar empleado directo | Configuración | — | Media | 3 | US-01.1.2 | RF-05 | Posterior |
| US-02.2.1 Registro cliente persona natural | Funcional | Core | Alta | 3 | US-01.1.1 | RF-08 | Posterior |
| US-02.2.2 Cliente empresa con múltiples sitios | Funcional | Core | Media | 5 | US-02.2.1 | RF-08 | Posterior |
| US-02.2.3 Reglas contextuales del sitio visibles al aliado | Funcional | Core | Media | 5 | US-02.2.2 | RF-09 | Posterior |

### EP-03 · Catálogo y cobertura — Prioridad **Alta**

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-03.1.1 Crear categoría con flujo operativo | Configuración | — | Alta | 5 | US-01.1.2 | RF-10 | Posterior |
| US-03.1.2 Desactivar categoría sin afectar en curso | Configuración | — | Media | 3 | US-03.1.1 | RF-10 | Posterior |
| US-03.1.3 Aliado declara categorías que atiende | Funcional | Core | Media | 3 | US-03.1.1 | RF-11 | Posterior |

### EP-04 · Ciclo del servicio — Prioridad **Crítica** (corazón del producto)

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-04.1.1 Crear solicitud | Funcional | Core | **Crítica** | 5 | US-02.2.1, US-03.1.1 | RF-12 | Posterior |
| US-04.1.2 Ver aliados válidos por cobertura y categoría | Funcional | Core | **Crítica** | 8 | US-04.1.1, SP-02.1.1 | RF-12 | Posterior |
| US-04.1.3 Filtrar por tipo de aliado | Funcional | Core | Baja | 2 | US-04.1.2 | RF-12 | Posterior |
| US-04.1.4 Aceptar/rechazar solicitud (sin doble asignación) | Funcional | Core | **Crítica** | 8 | SP-04.1.1 | RF-14 | Posterior |
| US-04.1.5 Priorizar por comisión ofrecida (regla activa) | Funcional | Core | Media | 5 | US-04.1.2 | RF-13 | Posterior |
| US-04.2.1 Cotización con mano de obra y materiales separados | Funcional | Core | Alta | 5 | US-04.1.4 | RF-15 | Posterior |
| US-04.2.2 Alerta de tarifa bidireccional (caro/barato) | Funcional | Core | Media | 3 | US-04.2.1, US-06.1.1 | RF-16 | Posterior |
| US-04.2.3 Cliente acepta/rechaza/ajusta cotización | Funcional | Core | Alta | 5 | US-04.2.1 | RF-17 | Posterior |
| US-04.3.1 Marcar inicio/fin de ejecución | Funcional | Core | Media | 3 | US-04.2.3 | RF-18 | Posterior |
| US-04.3.2 Registrar eventos durante la ejecución | Funcional | Core | Media | 3 | US-04.3.1 | RF-18 | Posterior |
| US-04.3.3 Cliente consulta el log del servicio | Funcional | Reporte | Baja | 2 | US-04.3.2 | RF-18 | Posterior |
| US-04.4.1 Cliente califica al aliado | Funcional | Core | Media | 3 | US-04.3.1 | RF-19 | Posterior |
| US-04.4.2 Aliado califica al cliente | Funcional | Core | Media | 3 | US-04.4.1 | RF-19 | Posterior |
| US-04.4.3 Calificación agregada visible en el listado | Funcional | Reporte | Media | 3 | US-04.4.1 | RF-19 | Posterior |

**Tasks de resiliencia (Calidad/Técnica):** endpoints idempotentes en aceptar solicitud,
aceptar cotización y calificar (RNF-03).

### EP-05 · Comunicación — Prioridad **Media**

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-05.1.1 Mensajería cliente-aliado por servicio | Funcional | Comunicación | Media | 5 | US-04.1.4 | RF-20 | Posterior |
| US-05.1.2 Notificaciones de mensajes nuevos | Funcional | Comunicación | Media | 3 | US-05.1.1 | RF-20 | Posterior |
| US-05.1.3 Consultar conversación para atender queja | Funcional | Comunicación | Baja | 3 | US-05.1.1 | RF-21 | Posterior |

### EP-06 · Tarifario — Prioridad **Alta**

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-06.1.1 Cargar tabla de tarifas por categoría | Configuración | — | Alta | 5 | US-03.1.1 | RF-22 | Posterior |
| US-06.1.2 Ver tarifa de referencia al cotizar | Funcional | Core | Media | 2 | US-06.1.1 | RF-22 | Posterior |
| US-06.1.3 Reporte de cotizaciones fuera de rango | Funcional | Reporte | Baja | 3 | US-04.2.2 | RF-23 | Posterior |

### EP-07 · Pagos y facturación — **2º incremento** (fuera de MVP)

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-07.1.1 Pago en línea al aceptar cotización | Funcional | Financiero | Media | 8 | SP-07.1.1 | RF-24 | Posterior |
| US-07.1.2 Registro de transacciones (audit log inmutable) | Funcional | Financiero | Media | 5 | US-07.1.1 | RF-24, RNF-04 | Posterior |
| US-07.1.3 Descargar soporte de pago | Funcional | Financiero | Baja | 3 | US-07.1.1 | RF-24 | Posterior |
| US-07.2.1 Liquidación al aliado (comisión configurable) | Funcional | Financiero | Media | 5 | US-07.1.2 | RF-25 | Posterior |
| US-07.2.2 Aliado consulta detalle de pagos | Funcional | Financiero | Baja | 3 | US-07.2.1 | RF-25 | Posterior |

### EP-08 · Operación y comercialización — **2º incremento** (fuera de MVP)

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-08.1.1 Cliente registra queja | Funcional | Core | Baja | 3 | US-04.4.1 | RF-26 | Posterior |
| US-08.1.2 Tenant gestiona estado de quejas | Funcional | Core | Baja | 3 | US-08.1.1 | RF-26 | Posterior |
| US-08.2.1 Publicar contenido en redes conectadas | Funcional | Comunicación | Baja | 8 | US-01.1.1 | RF-27 | Posterior |
| US-08.2.2 Registrar campañas y ver desempeño | Funcional | Reporte | Baja | 5 | US-08.2.1 | RF-27 | Posterior |
| US-08.3.1 Métricas operativas por tenant | Funcional | Reporte | Baja | 5 | US-01.1.1 | RF-28 | Posterior |
| US-08.3.2 Administrar estado de tenants | Configuración | — | Media | 3 | US-01.1.1 | RF-28 | Posterior |

---

## 9. Resumen

| Elemento | Cantidad |
| --- | --- |
| Épicas | 8 (6 MVP, 2 en 2º incremento) |
| Historias de usuario | 40 |
| Spikes (Sprint 0) | 13 (uno condicional) |
| Bugs previsibles | 4 |

## 10. Corte por sprint

- **Sprint 0 (actual):** Spikes técnicos de la sección 6, más la preparación general del
  proyecto (SRS, Backlog, Matriz de Herramientas, Gobierno del Equipo — ver Plan de Tareas).
  No se compromete código de producto.
- **Sprint 1 (candidatas, preparado — no iniciado):** fundación multi-tenant + identidad —
  sección 7. Contingente a SP-01.1.1 y SP-01.2.1 resueltos en Sprint 0.
- **Posteriores:** EP-02 a EP-06, luego EP-07/EP-08.

🔴 **PROPUESTA PARA EL EQUIPO:** este corte es una propuesta fundamentada, no una decisión.
La selección definitiva de Sprint 1 se hace en el Planning con estimación acordada. Ninguna
historia se mueve a Sprint 1 solo por existir en el backlog.

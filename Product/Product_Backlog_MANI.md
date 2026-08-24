# TRAMA · MANI — Product Backlog

> 🔴 = pendiente de decisión del equipo. Prioridad y estimación son **propuesta inicial**,
> revisable posteriormente por el equipo y por el PO (se valida por Planning Poker sin
> consenso). Este backlog está dirigido **exclusivamente a los requerimientos de nuestro
> producto**; no compara ni referencia backlogs externos.
>
> **Actualización 2026-08-23:** se agrega la Épica EP-10 (entregables académicos por sprint)
> y una propuesta de asignación de Sprint 1 a Sprint 5 + Cierre para todo el backlog (§11).
> Existe una exportación completa en `Product_Backlog_MANI_Jira.csv` (mismo directorio) lista
> para importar a Jira, con columnas ID, Issue Type, Summary, Description, Parent ID,
> Assignee, Priority, Status, Sprint, Estimate, Dependencies, Class.

## 1. Convenciones

- **Jerarquía:** Épica → Feature → Historia de usuario → (Task, Spike, Sub-task, Bug).
- **Estados:** Backlog · Ready · In Progress · In Review · Done. Los spikes usan además
  Timeboxed.
- **Estimación:** puntos de historia (Fibonacci), propuesta inicial.
- **Sprint candidato:** Sprint 0 (spikes/investigación) · Sprint 1..Sprint 5 (propuesta de
  distribución, §11) · Cierre · Posterior (fuera de alcance del corte, 2º incremento).
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
| EP-09 | Gestión y configuración del proyecto | Configurar herramientas, repositorios, ambientes e infraestructura que el equipo y el producto necesitan para operar; no son funcionalidad de negocio | — | Transversal (proceso) |
| EP-10 | Documentación de arquitectura y entregables académicos | SAD, DD, SDD, Infraestructura, Pruebas (TD), presentaciones y demás entregables exigidos por el cronograma académico en cada Sprint Review | — | Transversal (proceso) |

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

**Orden de prioridad dentro de Sprint 0:** SP-01.1.1, SP-01.2.1, SP-04.1.1 (Crítica, bloquean
Sprint 1 o son driver de diseño) → SP-01.1.2, SP-02.1.1, SP-04.1.2 (Alta) → SP-02.1.2,
SP-03.1.1, SP-04.4.1, SP-05.1.1 (Media). **SP-07.1.1, SP-07.1.2, SP-08.2.1 se sacan de Sprint 0**
y pasan a "Posterior (fuera de alcance del corte)": son spikes del 2º incremento (PROY-02) y no
aportan a decidir nada del MVP — no vale la pena gastar tiempo de Sprint 0 en ellos.

**Bugs previsibles identificados (no son Sprint 0, quedan registrados para prevención):**

| ID | Descripción | Épica | Prior. | Sprint candidato |
| --- | --- | --- | --- | --- |
| B-01.2.1 | Un token de un tenant no debe acceder a datos de otro (RNF-01) | EP-01 | **Crítica** | Sprint 1 |
| B-02.1.1 | Documentos de un aliado no deben ser visibles para otros aliados del tenant | EP-02 | Alta | Sprint 2 |
| B-04.1.1 | Solicitud rechazada no debe reasignarse al mismo aliado en el mismo ciclo | EP-04 | Media | Sprint 3 |
| B-04.1.2 | Aceptaciones concurrentes deben dejar exactamente una asignación (RNF-05) | EP-04 | Alta | Sprint 3 |

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

### 7.1 Candidatas de EP-09 (gestión y configuración) para Sprint 1

Trabajo transversal que las historias de EP-01 necesitan para poder construirse (repositorio,
pipeline, base de datos, tablero de indicadores) — no es funcionalidad de negocio, pero bloquea
Sprint 1 igual que un spike. Ver sección 8, EP-09, para el resto del backlog de esta épica.

| Historia | Clase | Prior. | Est. | Dep. |
| --- | --- | --- | --- | --- |
| US-09.1.2 Configurar CI/CD por repositorio (Flutter/Java/.NET) | Configuración | **Crítica** | 8 | US-09.1.1, ADR-0004 |
| US-09.2.1 Configurar ambientes en Azure con nomenclatura ratificada | Configuración | **Crítica** | 8 | Temas Mesa #3 (terminología) |
| US-09.2.2 Configurar motor de base de datos y esquema inicial multi-tenant | Configuración | **Crítica** | 8 | SP-01.1.1, PROY-07 |
| US-09.4.1 Configurar extracción automatizada de indicadores E1-E6/I1-I5 desde Jira/GitHub | Gestión / Proceso | **Crítica** | 8 | Gobierno §1.4.2 |

**Criterios de aceptación (BDD):**

- **US-09.1.2 — Configurar CI/CD por repositorio.**
  *Scenario 1:* Given un repositorio (Flutter, Java o .NET) con rama `feature/*` abierta, When se
  abre un Pull Request hacia `develop`, Then el workflow de GitHub Actions ejecuta build y pruebas
  unitarias And el resultado (verde/rojo) se refleja como check obligatorio del PR.
- **US-09.2.1 — Configurar ambientes en Azure.**
  *Scenario 1:* Given la nomenclatura de ambientes ratificada en Mesa, When DevOps aprovisiona
  Development/Testing/Production en Azure, Then cada ambiente queda aislado con sus propias
  variables y secretos And el nombre coincide con el usado en Gobierno del Equipo y en los
  workflows.
- **US-09.2.2 — Configurar base de datos.**
  *Scenario 1:* Given el motor de persistencia y la estrategia de aislamiento definidos por
  SP-01.1.1, When se aprovisiona el ambiente de Development, Then el esquema inicial soporta
  múltiples tenants aislados desde el primer registro (RNF-01).
- **US-09.4.1 — Configurar extracción de indicadores.**
  *Scenario 1:* Given el tablero Jira y el repositorio GitHub configurados, When cierra un sprint,
  Then los indicadores E1-E6 e I1-I5 (Gobierno §1.4.3/1.4.4) se calculan desde Jira/GitHub sin
  captura manual de datos.

---

## 8. Backlog completo por épica (referencia — incluye Sprint 1 y posteriores)

### EP-01 · Plataforma multi-tenant — Prioridad **Crítica**

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-01.1.1 Registrar tenant | Funcional | Fundacional | **Crítica** | 5 | SP-01.1.1 | RF-01 | **Sprint 1** |
| US-01.1.2 Configurar documentos por tipo de aliado | Configuración | — | Alta | 5 | US-01.1.1 | RF-02 | Sprint 1 |
| US-01.1.3 Configurar regla de posicionamiento del listado | Configuración | — | Media | 3 | US-01.1.1 | RF-02, RF-13 | Sprint 3 |
| US-01.2.1 Login restringido al tenant | Funcional | Fundacional | **Crítica** | 5 | SP-01.2.1 | RF-03 | **Sprint 1** |
| US-01.2.2 Recuperar contraseña | Funcional | Fundacional | Alta | 3 | US-01.2.1 | RF-04 | Sprint 1 |
| US-01.2.3 Asignar roles a usuarios | Configuración | — | Alta | 3 | US-01.2.1 | RF-03 | Sprint 1 |

### EP-02 · Directorio de actores — Prioridad **Alta**

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-02.1.1 Registro aliado persona natural (docs. del tenant) | Funcional | Core | Alta | 5 | US-01.1.2 | RF-05 | Sprint 2 |
| US-02.1.2 Registro aliado empresa (carta rep. legal) | Funcional | Core | Alta | 5 | US-01.1.2 | RF-05 | Sprint 2 |
| US-02.1.3 Aprobar/rechazar registro de aliado | Funcional | Core | Alta | 5 | US-02.1.1 | RF-06 | Sprint 2 |
| US-02.1.4 Declarar zona de cobertura | Funcional | Core | Alta | 5 | SP-02.1.1 | RF-07 | Sprint 2 |
| US-02.1.5 Registrar empleado directo | Configuración | — | Media | 3 | US-01.1.2 | RF-05 | Sprint 2 |
| US-02.2.1 Registro cliente persona natural | Funcional | Core | Alta | 3 | US-01.1.1 | RF-08 | Sprint 2 |
| US-02.2.2 Cliente empresa con múltiples sitios | Funcional | Core | Media | 5 | US-02.2.1 | RF-08 | Sprint 2 |
| US-02.2.3 Reglas contextuales del sitio visibles al aliado | Funcional | Core | Media | 5 | US-02.2.2 | RF-09 | Sprint 2 |

### EP-03 · Catálogo y cobertura — Prioridad **Alta**

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-03.1.1 Crear categoría con flujo operativo | Configuración | — | Alta | 5 | US-01.1.2 | RF-10 | Sprint 2 |
| US-03.1.2 Desactivar categoría sin afectar en curso | Configuración | — | Media | 3 | US-03.1.1 | RF-10 | Sprint 2 |
| US-03.1.3 Aliado declara categorías que atiende | Funcional | Core | Media | 3 | US-03.1.1 | RF-11 | Sprint 2 |

### EP-04 · Ciclo del servicio — Prioridad **Crítica** (corazón del producto)

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-04.1.1 Crear solicitud | Funcional | Core | **Crítica** | 5 | US-02.2.1, US-03.1.1 | RF-12 | Sprint 3 |
| US-04.1.2 Ver aliados válidos por cobertura y categoría | Funcional | Core | **Crítica** | 8 | US-04.1.1, SP-02.1.1 | RF-12 | Sprint 3 |
| US-04.1.3 Filtrar por tipo de aliado | Funcional | Core | Baja | 2 | US-04.1.2 | RF-12 | Sprint 3 |
| US-04.1.4 Aceptar/rechazar solicitud (sin doble asignación) | Funcional | Core | **Crítica** | 8 | SP-04.1.1 | RF-14 | Sprint 3 |
| US-04.1.5 Priorizar por comisión ofrecida (regla activa) | Funcional | Core | Media | 5 | US-04.1.2 | RF-13 | Sprint 3 |
| US-04.2.1 Cotización con mano de obra y materiales separados | Funcional | Core | Alta | 5 | US-04.1.4 | RF-15 | Sprint 3 |
| US-04.2.2 Alerta de tarifa bidireccional (caro/barato) | Funcional | Core | Media | 3 | US-04.2.1, US-06.1.1 | RF-16 | Sprint 3 |
| US-04.2.3 Cliente acepta/rechaza/ajusta cotización | Funcional | Core | Alta | 5 | US-04.2.1 | RF-17 | Sprint 3 |
| US-04.3.1 Marcar inicio/fin de ejecución | Funcional | Core | Media | 3 | US-04.2.3 | RF-18 | Sprint 4 |
| US-04.3.2 Registrar eventos durante la ejecución | Funcional | Core | Media | 3 | US-04.3.1 | RF-18 | Sprint 4 |
| US-04.3.3 Cliente consulta el log del servicio | Funcional | Reporte | Baja | 2 | US-04.3.2 | RF-18 | Sprint 4 |
| US-04.4.1 Cliente califica al aliado | Funcional | Core | Media | 3 | US-04.3.1 | RF-19 | Sprint 4 |
| US-04.4.2 Aliado califica al cliente | Funcional | Core | Media | 3 | US-04.4.1 | RF-19 | Sprint 4 |
| US-04.4.3 Calificación agregada visible en el listado | Funcional | Reporte | Media | 3 | US-04.4.1 | RF-19 | Sprint 4 |

**Task de resiliencia (Calidad/Pruebas):** endpoints idempotentes en aceptar solicitud,
aceptar cotización y calificar (RNF-03) — Sprint 3, Prior. Alta, Est. 5, Dep. US-04.1.4;
US-04.2.3; US-04.4.1.

### EP-05 · Comunicación — Prioridad **Media**

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-05.1.1 Mensajería cliente-aliado por servicio | Funcional | Comunicación | Media | 5 | US-04.1.4 | RF-20 | Sprint 4 |
| US-05.1.2 Notificaciones de mensajes nuevos | Funcional | Comunicación | Media | 3 | US-05.1.1 | RF-20 | Sprint 4 |
| US-05.1.3 Consultar conversación para atender queja | Funcional | Comunicación | Baja | 3 | US-05.1.1 | RF-21 | Sprint 4 |

### EP-06 · Tarifario — Prioridad **Alta**

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-06.1.1 Cargar tabla de tarifas por categoría | Configuración | — | Alta | 5 | US-03.1.1 | RF-22 | Sprint 3 |
| US-06.1.2 Ver tarifa de referencia al cotizar | Funcional | Core | Media | 2 | US-06.1.1 | RF-22 | Sprint 3 |
| US-06.1.3 Reporte de cotizaciones fuera de rango | Funcional | Reporte | Baja | 3 | US-04.2.2 | RF-23 | Sprint 4 |

### EP-07 · Pagos y facturación — **2º incremento** (fuera de MVP)

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-07.1.1 Pago en línea al aceptar cotización | Funcional | Financiero | Media | 8 | SP-07.1.1 | RF-24 | Posterior (fuera de alcance del corte) |
| US-07.1.2 Registro de transacciones (audit log inmutable) | Funcional | Financiero | Media | 5 | US-07.1.1 | RF-24, RNF-04 | Posterior (fuera de alcance del corte) |
| US-07.1.3 Descargar soporte de pago | Funcional | Financiero | Baja | 3 | US-07.1.1 | RF-24 | Posterior (fuera de alcance del corte) |
| US-07.2.1 Liquidación al aliado (comisión configurable) | Funcional | Financiero | Media | 5 | US-07.1.2 | RF-25 | Posterior (fuera de alcance del corte) |
| US-07.2.2 Aliado consulta detalle de pagos | Funcional | Financiero | Baja | 3 | US-07.2.1 | RF-25 | Posterior (fuera de alcance del corte) |

### EP-08 · Operación y comercialización — **2º incremento** (fuera de MVP)

| Historia | Clase | Subtipo | Prior. | Est. | Dep. | RF | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- | --- |
| US-08.1.1 Cliente registra queja | Funcional | Core | Baja | 3 | US-04.4.1 | RF-26 | Posterior (fuera de alcance del corte) |
| US-08.1.2 Tenant gestiona estado de quejas | Funcional | Core | Baja | 3 | US-08.1.1 | RF-26 | Posterior (fuera de alcance del corte) |
| US-08.2.1 Publicar contenido en redes conectadas | Funcional | Comunicación | Baja | 8 | US-01.1.1 | RF-27 | Posterior (fuera de alcance del corte) |
| US-08.2.2 Registrar campañas y ver desempeño | Funcional | Reporte | Baja | 5 | US-08.2.1 | RF-27 | Posterior (fuera de alcance del corte) |
| US-08.3.1 Métricas operativas por tenant | Funcional | Reporte | Baja | 5 | US-01.1.1 | RF-28 | Posterior (fuera de alcance del corte) |
| US-08.3.2 Administrar estado de tenants | Configuración | — | Media | 3 | US-01.1.1 | RF-28 | Posterior (fuera de alcance del corte) |

### EP-09 · Gestión y configuración del proyecto — Prioridad **Crítica** (transversal)

Trabajo necesario para que el equipo y el producto tengan dónde y cómo operar: repositorios,
pipelines, ambientes, base de datos, herramientas de calidad/seguridad e indicadores de
gestión. No es funcionalidad de negocio (no tiene RF) — la columna "Ref." reemplaza a "RF" y
apunta al ADR, PROY o sección de Gobierno del Equipo que origina la necesidad. Cubre HU de
Scrum Master y de cualquier actor del proyecto (PO, DevOps, QA, Backend, Frontend) cuyo
trabajo no cabe en una historia funcional de producto.

| Historia | Clase | Prior. | Est. | Dep. | Ref. | Sprint candidato |
| --- | --- | --- | --- | --- | --- | --- |
| US-09.1.1 Configurar repositorios GitHub (ramas, protecciones, plantilla de PR) | Configuración | **Crítica** | 3 | — | ADR-0001, Gobierno §2.3 | Sprint 0 |
| US-09.1.2 Configurar CI/CD por repositorio (Flutter/Java/.NET) | Configuración | **Crítica** | 8 | US-09.1.1 | ADR-0004 | Sprint 1 |
| US-09.1.3 Configurar proyecto y tablero Jira (workflows, campos Clase/Subtipo/Prioridad/RF) | Configuración | **Crítica** | 5 | — | ADR-0002 | Sprint 0 |
| US-09.1.4 Configurar canales Discord por ceremonia | Configuración | Alta | 2 | — | Gobierno §1.3.1 | Sprint 0 |
| US-09.1.5 Configurar estructura documental en OneDrive (carpetas, permisos) | Configuración | Alta | 2 | — | ADR-0001, Gobierno §1.2 | Sprint 0 |
| US-09.1.6 Configurar plantilla y carpeta `/docs/adr` en GitHub | Configuración | Alta | 2 | — | ADR-0001, ADR-0003 | Sprint 0 |
| US-09.2.1 Configurar ambientes (Development/Testing/Production) en Azure con nomenclatura ratificada | Configuración | **Crítica** | 8 | Terminología ratificada en Mesa | ADR-0004 | Sprint 1 |
| US-09.2.2 Configurar motor de base de datos y esquema inicial multi-tenant | Configuración | **Crítica** | 8 | SP-01.1.1 resuelto | PROY-07 | Sprint 1 |
| US-09.2.3 Configurar gestión de secretos y variables por ambiente | Configuración | Alta | 5 | US-09.2.1 | 🔴 Gobierno §2.4 (herramienta sin definir) | Sprint 1 |
| US-09.2.4 Configurar Kubernetes/AKS (distribución, nodos, escalado) | Configuración | **Crítica** | 8 | 🔴 ADR de configuración concreta (pendiente Mesa) | PROY-08, ADR-0004 | Sprint 2 |
| US-09.3.1 Configurar SonarQube (Quality Gate, reglas, exclusión de falsos positivos) | Configuración | Alta | 5 | US-09.1.2 | ADR-0005 | Sprint 1 |
| US-09.3.2 Configurar OWASP ZAP sobre el ambiente de Testing | Configuración | Alta | 5 | US-09.2.1 | ADR-0005 | Sprint 1 |
| US-09.3.3 Configurar colecciones Postman/Newman por servicio | Configuración | Alta | 3 | US-09.1.2 | Matriz de Herramientas §A | Sprint 1 |
| US-09.3.4 Configurar escenarios k6 de carga (despacho, mensajería) | Configuración | Media | 5 | SP-04.1.1 | Matriz de Herramientas §A | Sprint 3 |
| US-09.3.5 Configurar stack de observabilidad | Configuración | **Crítica** | 8 | 🔴 observabilidad ratificada en Mesa | ADR-0006 (sin ratificar) | Sprint 2 |
| US-09.4.1 Configurar extracción automatizada de indicadores E1-E6/I1-I5 desde Jira/GitHub | Gestión / Proceso | **Crítica** | 8 | US-09.1.3 | Gobierno §1.4.2 | Sprint 1 |
| US-09.4.2 Configurar plantilla de Informe de Sprint (Excel, OneDrive) | Gestión / Proceso | Media | 2 | US-09.1.5 | Gobierno §1.2.2 | Sprint 1 |
| US-09.4.3 Configurar Plan de Tareas del sprint | Gestión / Proceso | Media | 2 | — | Gobierno §1.2.2 | Sprint 1 |

### EP-10 · Documentación de arquitectura y entregables académicos — Prioridad **Crítica** (transversal)

Entregables exigidos por el cronograma académico en cada Sprint Review (Perfil de Proyecto
§6). No tiene RF; la columna "Ref." indica de qué entregable de la rúbrica proviene. El
detalle completo (Summary/Description por tarea, para importar a Jira) está en
`Product_Backlog_MANI_Jira.csv`; aquí se resume por sprint.

**Sprint 1 (Review Sprint 1 y Planning Sprint 2) — 14 tareas, 54 pts:** SAD V1 en 8 partes
(Drivers y Killers, Atributos de calidad, Escenarios de calidad, Trade-offs y ADR, HLD,
Arquitectura de Negocio, de Datos, de Infraestructura) · DD V1 (modelos de datos + contratos)
· Prototipos Front (Mockup) · Presentación de la entrega · Herramientas V2 · SRS V2 ·
Backlog V2.

**Sprint 2 (Review Sprint 2 y Planning Sprint 3) — 11 tareas, 52 pts:** SDD — framework de
modelado 4+1/C4 · PoC + ADR (Spike de benchmarking) · Vista Física (seguridad + config.
ambientes Dev/QA/Prod) · Presentación · Herramientas V3 · SRS V3 · Backlog V3 · SAD V2 ·
DD V2 · Infraestructura V1 · Diseño SDD V1.

**Sprint 3 (Review Sprint 3 y Planning Sprint 4) — 12 tareas, 48 pts:** Despliegue a QA ·
Informe de pruebas · Actualización doc+arquitectura · Demo del incremento · Presentación ·
SRS V4 · Backlog V4 · SAD V3 · DD V3 · Infraestructura V2 · Diseño SDD V2 · Pruebas TD V1.

**Sprint 4 (Review Sprint 4 y Planning Sprint 5, peso 15%) — 12 tareas, 48 pts:** mismo patrón
que Sprint 3 — Despliegue a QA · Informe de pruebas · Actualización doc+arquitectura · Demo ·
Presentación · SRS V5 · Backlog V5 · SAD V4 · DD V4 · Infraestructura V3 · Diseño SDD V3 ·
Pruebas TD V2.

**Sprint 5 (Review Sprint 5 y Lanzamiento) — 11 tareas, 45 pts:** Despliegue a QA · Informe de
pruebas · Actualización doc+arquitectura · Demo · Acta de Cierre (borrador) · Presentación ·
SAD V5 · DD V5 · Infraestructura V4 · Diseño SDD V4 · Pruebas TD V3.

**Cierre del proyecto (peso 25%) — 8 tareas, 26 pts:** Despliegue final a QA · Informe de
pruebas final · Actualización final de doc+arquitectura · Demo final · Acta de Cierre
(versión final) · Informe de proyecto (resultados, lecciones aprendidas, conclusiones) ·
Presentación final · Versión final de todos los documentos y productos.

Total EP-10: **68 tareas, 273 pts**, todas Issue Type = Task en el CSV excepto el PoC+ADR de
Sprint 2 (Spike). Dependencias entre versiones (p. ej. SAD V2 depende de SAD V1) y con EP-09
(Infraestructura V1 depende de la Vista Física, que depende de los ambientes configurados en
US-09.2.1) están en el CSV, columna Dependencies.

---

## 9. Resumen

| Elemento | Cantidad |
| --- | --- |
| Épicas | 10 (6 MVP, 2 en 2º incremento — fuera de alcance del corte, 2 transversales de proceso) |
| Historias de usuario (producto, EP-01..EP-08) | 48 |
| Historias de gestión/configuración (EP-09) | 18 |
| Tareas de entregables académicos (EP-10) | 68 |
| Spikes (Sprint 0, 3 fuera de alcance del corte) | 13 (uno condicional) |
| Bugs previsibles | 4 |
| **Total ítems en el backlog (`Product_Backlog_MANI_Jira.csv`)** | **162** (10 épicas + 152 ítems) |

## 10. Corte por sprint

- **Sprint 0 (actual):** Spikes técnicos de la sección 6 (10 activos, 3 fuera de alcance del
  corte), más la preparación general del proyecto y las historias de configuración base de
  EP-09 marcadas "Sprint 0" (repositorio, Jira, Discord, OneDrive, plantilla de ADR). No se
  compromete código de producto.
- **Sprint 1:** EP-01 completo (fundación multi-tenant + identidad, sección 7) + EP-09
  habilitante (CI/CD, ambientes, base de datos, SonarQube, ZAP, Postman, secretos,
  indicadores, informe de sprint, plan de tareas) + EP-10 Sprint 1 (SAD V1, DD V1, mockups,
  Herramientas V2, SRS V2, Backlog V2) + bug B-01.2.1. Contingente a SP-01.1.1/SP-01.2.1
  resueltos y a que Mesa ratifique terminología de ambientes y alcance de Java+.NET (ver
  Temas_Mesa_Arquitectura_Sprint1.md).
- **Sprint 2:** EP-02 (directorio de actores, 8 historias) + EP-03 (catálogo y cobertura, 3
  historias) + EP-09 (Kubernetes/AKS, observabilidad) + EP-10 Sprint 2 (SDD, PoC+ADR, Vista
  Física, Herramientas V3, SRS V3, Backlog V3, SAD V2, DD V2, Infraestructura V1, SDD V1) +
  bug B-02.1.1.
- **Sprint 3:** EP-04 primera mitad (solicitud→cotización, 7 historias) + EP-06 completo
  (tarifario, adelantado porque US-04.2.2 depende de US-06.1.1) + EP-09 (k6) + task de
  resiliencia (RNF-03) + EP-10 Sprint 3 (primer despliegue a QA, informe de pruebas, SRS V4,
  Backlog V4, SAD V3, DD V3, Infraestructura V2, SDD V2, Pruebas TD V1) + bugs B-04.1.1,
  B-04.1.2.
- **Sprint 4:** EP-04 segunda mitad (ejecución→calificación, 6 historias) + EP-05 completo
  (comunicación) + resto de EP-06 (reporte fuera de rango) + EP-10 Sprint 4 (peso 15%: SRS V5,
  Backlog V5, SAD V4, DD V4, Infraestructura V3, SDD V3, Pruebas TD V2).
- **Sprint 5:** estabilización y pendientes de baja prioridad (US-01.1.3 posicionamiento del
  listado) + EP-10 Sprint 5 (Review y Lanzamiento: SAD V5, DD V5, Infraestructura V4, SDD V4,
  Pruebas TD V3, Acta de Cierre borrador). Sin funcionalidad nueva de producto — sprint de
  cierre técnico, no de features (PROY-02: 2º incremento sigue fuera de alcance).
- **Cierre del proyecto (peso 25%):** EP-10 Cierre (despliegue final, informe de pruebas
  final, Acta de Cierre versión final, Informe de proyecto, versión final de documentos y
  producto).
- **Fuera de alcance de este corte:** EP-07, EP-08 y los 3 spikes de 2º incremento
  (SP-07.1.1, SP-07.1.2, SP-08.2.1) — PROY-02.

## 11. Propuesta de asignación de sprints (1–5) y prioridad

**Criterio de secuenciación:** dependencias de datos primero, luego flujo de negocio en el
orden en que el cliente lo vive (RF-01→RF-28), documentación de arquitectura un sprint por
detrás de lo que documenta (no se puede escribir el DD de algo que aún no se construyó).

1. **EP-01 va en Sprint 1** porque el aislamiento multi-tenant afecta el modelo de datos
   completo (§4) — introducirlo después obliga a rehacer todo lo demás.
2. **EP-02 y EP-03 van en Sprint 2** porque EP-04 (el corazón del producto) depende de tener
   clientes, aliados y categorías registrados (US-04.1.1 depende de US-02.2.1 y US-03.1.1).
3. **EP-04 se parte en dos sprints (3 y 4)** por ser la épica más grande (14 historias + 1
   task de resiliencia, 74 pts): Sprint 3 cubre solicitud→cotización, Sprint 4 cubre
   ejecución→calificación. **EP-06
   (tarifario) se adelanta a Sprint 3** — pese a ser una épica separada — porque
   US-04.2.2 (alerta de tarifa) la necesita en el mismo sprint, no después.
4. **EP-05 (comunicación) va en Sprint 4** junto con el cierre de EP-04, porque la mensajería
   solo tiene sentido sobre una solicitud ya aceptada (US-04.1.4).
5. **Sprint 5 es de estabilización**, no de nuevas features: solo queda backlog de baja
   prioridad (US-01.1.3) y el cierre de documentación/pruebas. Esto es intencional — un
   capstone académico necesita un sprint de margen antes del Cierre, no siempre lo llena
   trabajo nuevo.
6. **EP-07/EP-08 (2º incremento) no se sprintan en este corte** — PROY-02 los excluye
   explícitamente; aparecen en el backlog solo para trazabilidad futura.

🔴 **Esto es una propuesta, no una decisión de Planning.** La selección definitiva de cada
sprint se hace en su ceremonia de Planning con estimación acordada por el equipo (Gobierno
§1.3.5); la Mesa de Arquitectura puede mover fechas si SP-01.1.1/SP-01.2.1 (Sprint 0) o los
ADR pendientes de Java+.NET/Kubernetes/observabilidad (Temas_Mesa_Arquitectura_Sprint1.md) no
se resuelven a tiempo. El detalle fila por fila, listo para importar a Jira, está en
`Product_Backlog_MANI_Jira.csv`.

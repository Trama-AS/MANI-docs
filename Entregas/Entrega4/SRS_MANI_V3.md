# Software Requirements Specification (SRS) — MANI

**Empresa:** TRAMA · Ingeniería de Software
**Producto:** MANI — plataforma multi-tenant de formalización de operaciones de servicio
**Documento:** SRS V3 (Entrega 4)
**Estado:** Borrador para revisión
**Fecha de esta versión:** 2026-09-23

## Historial de versiones

| Versión | Momento | Cambios principales |
| --- | --- | --- |
| **V1** | Sprint 0, Sem. 4 (Planning Sprint 1) | Propósito, alcance, contexto, funciones principales, RF-01..28, RNF-01..11, restricciones e integraciones. |
| **V2** | Sprint 2, 2026-09-03 (Entrega 3) | Formato IEEE 830; PROY-07/08; REST-01..05; modelo de zonas (ADR-0011) en RF-07/12/13 y RNF-09; aislamiento KYC (ADR-0013) en RF-05/06; broadcast (ADR-0016) en RF-14; mensajería (ADR-0017) en RF-20; tenant no falsificable (ADR-0018) en RNF-01; objetivo provisional de RNF-07; resolución de la contradicción de Kubernetes (PROY-08). |
| **V3** | Sprint 2 Review, 2026-09-23 (Entrega 4) | Se incorpora la **evidencia de las PoC** a los RNF que la tienen (RNF-01, RNF-03, RNF-05, RNF-07). **RNF-01** explicita la autorización **por rol dentro del tenant** (hallazgo H-02 de PoC-001). **RF-12** exige listado paginado (PoC-004 H-03). **§1.4** actualizada: KI-02 cerrado (ADR-0023), numeración ADR-0021/0023 en ratificación, propuesta de ubicación de Kubernetes (ADR-0029 borrador). **§3.2** actualizada: proveedor de identidad resuelto (ADR-0022). **PROY-07** con alcance propuesto por módulo (ADR-0028 borrador). Nueva suposición **SUP-06** (un usuario pertenece a un solo tenant en el MVP). |

## 1. Introducción

### 1.1 Propósito

Especificar los requisitos de MANI, plataforma que permite a **empresas de servicios**
formalizar digitalmente su operación: conectar clientes con aliados a través de un ciclo
completo de solicitud, cotización, ejecución, calificación y cierre, con trazabilidad y
configuración propia por empresa. Este documento es la fuente de verdad del **qué**; el
**cómo** vive en el SAD V3, el SDD V1, el DD V2, el Documento de Infraestructura V1 y los ADR.

### 1.2 Alcance

- **MVP (primer incremento):** plataforma multi-tenant, directorio de actores, catálogo y
  cobertura, ciclo del servicio, comunicación y tarifario (EP-01 a EP-06).
- **Segundo incremento:** pagos y facturación, quejas, comercialización y administración
  avanzada (EP-07, EP-08).
- **Fuera de alcance del MVP:** pasarela de pago, facturación electrónica, consola de
  comercialización, geolocalización en tiempo real del aliado, cálculo de proximidad (REST-01).
- **Fuera de alcance de este documento:** tareas técnicas de habilitación (ÉPICA 1 /
  "Enablers"); se gestionan vía Gobierno del Equipo, ADR y Backlog.

### 1.3 Definiciones, acrónimos y abreviaturas

Glosario completo: **DD V2 §14** (integra el antiguo `Product/Glosario_Terminos_MANI.md`). Mínimos:

- **Tenant:** empresa suscrita; opera aislada con su propia configuración.
- **Aliado:** prestador (persona natural, empresa o empleado directo).
- **Cliente:** solicitante (persona natural o empresa).
- **RF / RNF / PROY / REST:** requerimiento funcional / no funcional / de proyecto /
  restricción de producto.
- **DR / KI / AC / QS / TO:** códigos del SAD (Driver, Killer, Atributo, Escenario, Trade-off).
- **PoC:** prueba de concepto que verifica una decisión ya redactada, con métrica, umbral y
  control negativo (`Project/PoC/`).
- **Ciclo del servicio:** Solicitud → Cotización → Ejecución → Calificación → Cierre.

### 1.4 Notas de consistencia documental

Inconsistencias detectadas entre documentos. Ningún requisito depende de resolverlas, pero
condicionan el diseño.

| # | Tema | Estado al 2026-09-23 |
| --- | --- | --- |
| N-01 | **Kubernetes / PROY-08** | ✅ El "sí" está resuelto desde 2026-09-03: PROY-08 es la fuente autoritativa (curricular; Kubernetes no tiene costo de licencia; el costo atribuido era de Azure AKS, retirado por ADR-0023). 🟡 El "dónde y con cuántos nodos" se propone en **ADR-0029 (borrador)**: Railway para QA/PROD del MVP + clúster k3d/kind de referencia con las mismas imágenes (Documento de Infraestructura V1 §9). Depende del spike SP-TO-11. |
| N-02 | **KI-02 — stack backend Java/.NET/Azure vs Dart/Serverpod** | ✅ Cerrado por **ADR-0023**: los tres stacks coexisten gobernando módulos distintos; se retira Azure. (La V2 de este SRS lo citaba como "ADR-0021"; ver N-03.) |
| N-03 | **Numeración ADR-0021 / ADR-0023** | 🟡 Dos documentos se llamaron "ADR-0021". La Mesa del 2026-09-22 (DOC-14 D-01) propone adoptar la numeración por nombre de archivo: **0021 = exclusión concurrente en el despacho**, **0023 = stack sin Azure**. Este SRS la adopta, pendiente de ratificación. |
| N-04 | **ADR-0025 / ADR-0026** | El SDD 0.1 propuso "ADR-0025" (API Gateway) y "ADR-0026" (Java/.NET), pero esos números ya los usan DoD y DoR. Los borradores pasan a **ADR-0027** y **ADR-0028** (SDD V1 Anexo A). |
| N-05 | **Estado de ADR en el README** | El README marca ADR-0014/0015 como Aceptados; los archivos dicen Propuesto. Prevalece el archivo (Gobierno §2.6). |

---

## 2. Descripción general

### 2.1 Perspectiva del producto

MANI es **SaaS multi-tenant**: una instancia sirve a múltiples empresas manteniendo datos,
configuración y usuarios aislados. La empresa del cliente del proyecto es el primer tenant.
Cada tenant configura sus reglas (documentos exigidos, categorías, tarifas, orden del listado,
comisión) sin desarrollo específico.

### 2.2 Funciones principales

- Registro y configuración de tenants.
- Identidad y control de acceso por rol y por tenant.
- Directorio diferenciado de aliados y clientes.
- Catálogo de categorías y cobertura por zonas.
- Ciclo del servicio de extremo a extremo.
- Mensajería y notificaciones por servicio.
- Tarifario de referencia con alerta de desviación.
- *(2º incremento)* Cobro y liquidación, quejas, comercialización y métricas.

#### 2.2.1 Matriz de actores por función

| Función | Admin. plataforma | Admin. tenant | Aliado | Cliente |
| --- | :---: | :---: | :---: | :---: |
| Alta y estado de tenants | ✔ | — | — | — |
| Configuración de reglas del tenant | — | ✔ | — | — |
| Autenticación y acceso | login | login | login | login |
| Directorio de aliados | — | ✔ (aprueba) | ✔ (se registra) | consulta |
| Directorio de clientes | — | ✔ | consulta reglas de sitio | ✔ (se registra) |
| Catálogo y cobertura | — | ✔ (categorías) | ✔ (cobertura/categorías) | — |
| Solicitud y despacho | — | define regla de orden | ✔ (acepta/rechaza) | ✔ (crea) |
| Cotización | — | — | ✔ (cotiza) | ✔ (acepta/ajusta) |
| Ejecución | — | — | ✔ (registra) | consulta log |
| Calificación | — | — | ✔ | ✔ |
| Mensajería | — | consulta (quejas) | ✔ | ✔ |
| Tarifario | — | ✔ (carga) | consulta al cotizar | — |
| Pagos *(2º)* | ✔ (concilia) | ✔ (liquida) | consulta | ✔ (paga) |
| Quejas / operación *(2º)* | ✔ (estado tenants) | ✔ | — | ✔ (quejas) |

### 2.3 Clases y características de usuarios

- **Administrador de plataforma:** opera MANI como SaaS; alta y estado de tenants.
- **Administrador de tenant:** configura reglas; aprueba/rechaza aliados.
- **Aliado:** declara cobertura y categorías, cotiza y ejecuta.
- **Cliente:** solicita el servicio; el cliente empresa administra múltiples sitios.

### 2.4 Entorno operativo

Utilizable desde dispositivos móviles por clientes y aliados (RNF-08); hoy operativo como
aplicación web (Flutter Web). Servicio multi-tenant accesible remotamente. Tres ambientes
(DEV, QA, PROD) según DOC-08; detalle en el Documento de Infraestructura V1.

### 2.5 Restricciones

#### 2.5.1 Restricciones del proyecto (PROY)

| ID | Restricción | Estado |
| --- | --- | --- |
| **PROY-01** | Metodología **Scrum** con sprints ajustados al cronograma académico. | Vigente |
| **PROY-02** | Alcance del corte limitado al **MVP** (EP-01..EP-06). | Vigente |
| **PROY-03** | Documentación según el esquema de Gobierno del Equipo. | Vigente |
| **PROY-04** | 7 integrantes con responsabilidad transversal de Arquitecto. | Vigente |
| **PROY-05** | Toda decisión técnica costosa de revertir pasa por la Mesa y un ADR antes de implementarse. | Vigente |
| **PROY-06** | Herramientas según el Documento de Herramientas vigente (V3). | Vigente |
| **PROY-07** | Uso de **Java** y **.NET** en algún módulo del backend (constraint externo). | Confirmado. 🟡 Alcance propuesto (ADR-0028 borrador): **Java = Motor de Reglas por Tenant** (RF-02, RF-05, RF-13, RF-16); **.NET = Motor de Despacho y Asignación** (RF-12, RF-14). |
| **PROY-08** | Uso de **Kubernetes** como orquestador (curricular). | Vigente. Ubicación propuesta en ADR-0029 (borrador) — ver §1.4 N-01. |

#### 2.5.2 Restricciones del producto (REST)

| ID | Restricción |
| --- | --- |
| **REST-01** | Cobertura por **zonas** de un catálogo jerárquico (ciudad → localidad/comuna → barrio), nunca por radio ni geolocalización. Granularidad del MVP: localidad/comuna; catálogo global de solo lectura para tenants; las zonas se desactivan, no se eliminan (ADR-0011, confirmado por PoC-004). |
| **REST-02** | KYC y reglas de tiempos/comisión **configurables por tenant**. Un documento KYC no es visible para otro aliado del mismo tenant ni para otro tenant: el aislamiento aplica también a archivos (ADR-0013, validado por PoC-003). |
| **REST-03** | Pagos **centralizados** con operador certificado; PCI DSS a cargo del operador *(2º incremento)*. |
| **REST-04** | Aislamiento estricto entre tenants en toda funcionalidad (RNF-01). |
| **REST-05** | Cada tenant configura sus reglas sin despliegue de código específico (RNF-02). |

### 2.6 Suposiciones y dependencias

| ID | Suposición / dependencia | Impacto si no se cumple |
| --- | --- | --- |
| SUP-01 | Existe información oficial de división político-administrativa por ciudad (KI-08). | La cobertura degrada a nivel ciudad. |
| SUP-02 | Supabase (Auth, PostgreSQL, Storage, Realtime) sigue disponible en capa gratuita para QA. | Revisar costo y ADR-0022/0012. |
| SUP-03 | El volumen concurrente real del primer tenant no supera el volumen sintético de PoC-004 (100k aliados/tenant, 20 usuarios concurrentes). | RNF-07 pasa de riesgo a bloqueante (KI-09). |
| SUP-04 | El operador de pagos se selecciona antes del 2º incremento. | RF-24/25 bloqueados. |
| SUP-05 | Los servicios de push (FCM/APNs) están disponibles para la app móvil. | RF-20 solo casi en tiempo real con la app abierta. |
| **SUP-06** | **Un usuario (correo) pertenece a un solo tenant en el MVP** (limitación del modelo: `usuario` tiene un único `tenant_id`; PoC-002). | Un usuario multi-tenant exigiría tabla de membresía y cambio en el hook de claims. Pendiente de confirmar en Mesa (SDD V1 P-06). |

---

## 3. Requerimientos específicos

### 3.1 Requerimientos funcionales

Identificador **RF-01..RF-28**, módulo **M-01..M-14**, prioridad y estimación (puntos de
historia) según el Análisis de Requerimientos; se validan en el refinamiento del Backlog.

#### 3.1.1 Plataforma multi-tenant y control de acceso (M-01)

| ID | Requerimiento funcional | Prioridad | Est. | Dep. |
| --- | --- | :---: | :---: | --- |
| **RF-01** | Registrar y administrar empresas (**tenants**), garantizando el aislamiento de sus datos. | **Crítica** | 8 | — |
| **RF-02** | Permitir que cada tenant configure sus reglas: documentos por tipo de aliado, orden del listado, categorías y tarifas. | **Crítica** | 8 | RF-01 |
| **RF-03** | Autenticar usuarios y restringir su acceso según su tenant y los permisos de su rol, con una identificación de tenant no falsificable por el cliente (RNF-01). | **Crítica** | 8 | RF-01 |
| **RF-04** | Permitir la recuperación segura de la contraseña. | Alta | 3 | RF-03 |

#### 3.1.2 Directorio de aliados y clientes (M-02 / M-03)

| ID | Requerimiento funcional | Prioridad | Est. | Dep. |
| --- | --- | :---: | :---: | --- |
| **RF-05** | Registrar aliados (persona natural, empresa, empleado directo) con los documentos que exija el tenant; documentos aislados por aliado y por tenant (REST-02). | **Crítica** | 8 | RF-02 |
| **RF-06** | Permitir al admin. del tenant aprobar o rechazar aliados en una bandeja de verificación, sin exponer a un aliado los documentos de otro (REST-02). | Alta | 5 | RF-05 |
| **RF-07** | Permitir que los aliados declaren sus zonas sobre el catálogo jerárquico (localidad/comuna en el MVP; REST-01). | Alta | 5 | RF-05 |
| **RF-08** | Registrar clientes persona natural o empresa; el cliente empresa administra múltiples sitios. | Alta | 5 | RF-02 |
| **RF-09** | Registrar reglas y condiciones de cada sitio, visibles al aliado antes de programar el servicio. Todo sitio tiene una zona del catálogo; sin zona no origina solicitudes. | Media | 5 | RF-08 |

#### 3.1.3 Catálogo y cobertura (M-04)

| ID | Requerimiento funcional | Prioridad | Est. | Dep. |
| --- | --- | :---: | :---: | --- |
| **RF-10** | Permitir al tenant definir, activar y desactivar categorías, con su flujo operativo. | Alta | 5 | RF-02 |
| **RF-11** | Asociar aliados con las categorías que atienden. | Media | 3 | RF-05, RF-10 |

#### 3.1.4 Ciclo del servicio (M-05..M-08)

| ID | Requerimiento funcional | Prioridad | Est. | Dep. |
| --- | --- | :---: | :---: | --- |
| **RF-12** | Crear solicitudes y presentar los aliados válidos por categoría y cobertura (match exacto de zona entre sitio y cobertura; sin cálculo geoespacial). **El listado debe ser paginado** (PoC-004 H-03: a 100k aliados sin paginación no escala en la interfaz). | **Crítica** | 8 | RF-07, RF-10 |
| **RF-13** | Ordenar el listado según la regla del tenant (cobertura, calificación o comisión). | Alta | 5 | RF-12 |
| **RF-14** | Permitir al aliado aceptar o rechazar una solicitud sin dobles asignaciones. La solicitud se presenta simultáneamente a todos los aliados válidos; la primera aceptación válida gana y el resto recibe "ya no disponible" (RNF-05). **Solo un usuario con rol aliado puede aceptar** (RNF-01). | **Crítica** | 8 | RF-12 |
| **RF-15** | Elaborar cotizaciones diferenciando mano de obra y materiales. | Alta | 5 | RF-14 |
| **RF-16** | Alertar al aliado si la cotización sale del rango del tarifario. | Media | 3 | RF-15, RF-22 |
| **RF-17** | Permitir al cliente aceptar, rechazar o pedir ajustes a una cotización. | Alta | 5 | RF-15 |
| **RF-18** | Registrar cronológicamente eventos y observaciones de la ejecución. | Media | 5 | RF-17 |
| **RF-19** | Calificación bidireccional al cierre; el servicio no cierra sin ambas calificaciones. | Media | 5 | RF-18 |

#### 3.1.5 Comunicación (M-09)

| ID | Requerimiento funcional | Prioridad | Est. | Dep. |
| --- | --- | :---: | :---: | --- |
| **RF-20** | Mensajería cliente–aliado por servicio con notificaciones; casi en tiempo real si ambos están conectados, con respaldo push si no. | Media | 8 | RF-14 |
| **RF-21** | Consultar las conversaciones de un servicio para atender quejas. | Baja | 3 | RF-20 |

#### 3.1.6 Tarifario (M-11)

| ID | Requerimiento funcional | Prioridad | Est. | Dep. |
| --- | --- | :---: | :---: | --- |
| **RF-22** | Tabla de tarifas por categoría y tenant con mínimo, típico y máximo. | Alta | 5 | RF-10 |
| **RF-23** | Reporte de cotizaciones fuera de rango por período. | Baja | 3 | RF-16 |

#### 3.1.7 Segundo incremento (M-10, M-12..M-14)

| ID | Requerimiento funcional | Prioridad | Est. | Dep. |
| --- | --- | :---: | :---: | --- |
| **RF-24** | Cobro en línea mediante operador certificado y registro de cada transacción. | Media | 13 | RF-17 |
| **RF-25** | Liquidación al aliado descontando la comisión del tenant. | Media | 8 | RF-24 |
| **RF-26** | Registro y gestión de quejas por servicio. | Baja | 5 | RF-19 |
| **RF-27** | Consola de comercialización y publicación del tenant. | Baja | 8 | RF-01 |
| **RF-28** | Métricas operativas por tenant y administración del estado de tenants. | Baja | 8 | RF-01 |

#### 3.1.8 Resumen por módulo

| Módulo | RF | Épica | Alcance |
| --- | --- | --- | --- |
| M-01 Plataforma y acceso | RF-01 – RF-04 | EP-01 | MVP |
| M-02/M-03 Directorio | RF-05 – RF-09 | EP-02 | MVP |
| M-04 Catálogo y cobertura | RF-10 – RF-11 | EP-03 | MVP |
| M-05..M-08 Ciclo del servicio | RF-12 – RF-19 | EP-04 | MVP |
| M-09 Comunicación | RF-20 – RF-21 | EP-05 | MVP |
| M-11 Tarifario | RF-22 – RF-23 | EP-06 | MVP |
| M-10 Pagos | RF-24 – RF-25 | EP-07 | 2º |
| M-12..M-14 Quejas, comercialización, administración | RF-26 – RF-28 | EP-08 | 2º |

### 3.2 Requerimientos de interfaces externas

| Sistema externo | Propósito | Información | Dirección | Restricciones | Estado |
| --- | --- | --- | --- | --- | --- |
| Operador de pagos *(2º)* | Cobros y liquidaciones | Monto, medio, estado, comprobante | Bidireccional | PCI DSS a cargo del operador (REST-03) | 🔴 Selección pendiente (spike + ADR) |
| **Proveedor de identidad** | Autenticar y gestionar credenciales | Credenciales, JWT con `tenant_id` y rol | Bidireccional | Respeta RNF-01/REST-04; tenant solo en claims firmados | ✅ **Resuelto: Supabase Auth (ADR-0022, Aceptado)**; claims por hook validados en PoC-002 |
| Servicio de push | Notificar sin conexión activa (RF-20) | Destinatario, canal, contenido | Saliente | ADR-0017 Propuesto | 🟡 Pendiente de ratificar |
| Almacenamiento de archivos | Documentos KYC y fotos de solicitud | Archivos, URLs firmadas | Bidireccional | Aislamiento por tenant y usuario (REST-02) | 🔵 Supabase Storage (ADR-0013 Propuesto, validado por PoC-003) |

### 3.3 Requerimientos no funcionales

Tecnológicamente neutrales. Los escenarios de calidad que los operacionalizan viven en el
SAD V3 §5 (QS-01..QS-22). La columna **Evidencia** es nueva en V3.

#### 3.3.1 Seguridad y aislamiento multi-tenant

| ID | Requerimiento no funcional | Atributo | Prioridad | Evidencia |
| --- | --- | --- | :---: | --- |
| **RNF-01** | Los datos de un tenant deben estar estrictamente aislados. Ningún usuario o mecanismo de un tenant accede a información de otro. Cubre registros **y archivos** (REST-02). La identificación del tenant debe ser verificable por el servidor, no un valor que el cliente pueda enviar. **Dentro de un tenant, las operaciones de escritura críticas deben estar restringidas al rol que las ejecuta** (p. ej., solo un aliado acepta una solicitud; solo el admin. del tenant aprueba aliados). | Seguridad / Multi-tenancy | **Crítica** | ✅ Entre tenants: PoC-002 (0 fugas; 4/4 suplantaciones rechazadas), PoC-003 (95/95), Inf_test-002 (135/135). ❌ Por rol: PoC-001 H-02 muestra que la política vigente no restringe rol — corrección en DD V2 §8.1 |
| **RNF-06** | PCI DSS a cargo del operador de pagos, no de MANI. | Seguridad / Cumplimiento | Alta | 2º incremento |
| **RNF-11** | Pagos centralizados con operador certificado, priorizando integración sobre construcción propia. | Seguridad / Cumplimiento | Media | 2º incremento |

#### 3.3.2 Configurabilidad y modificabilidad

| ID | Requerimiento no funcional | Atributo | Prioridad | Evidencia |
| --- | --- | --- | :---: | --- |
| **RNF-02** | Cada tenant configura sus reglas sin código específico ni despliegue. | Modificabilidad | **Crítica** | ⬜ Sin medir (SP-TO-02) |
| **RNF-10** | KYC, tiempos y comisiones configurables por tenant, no codificados. | Modificabilidad | Alta | ⬜ |

#### 3.3.3 Fiabilidad, resiliencia y concurrencia

| ID | Requerimiento no funcional | Atributo | Prioridad | Evidencia |
| --- | --- | --- | :---: | --- |
| **RNF-03** | Operaciones críticas (aceptar solicitud, aceptar cotización, calificar) resistentes a reintentos, sin duplicados. | Fiabilidad | Alta | ✅ Aceptación de solicitud: PoC-001 r5 (reintento → 200, 0 filas nuevas). ⬜ Cotización y calificación |
| **RNF-05** | Despacho determinista: exactamente una asignación válida por solicitud ante aceptaciones concurrentes. | Fiabilidad / Concurrencia | Alta | ✅ PoC-001: 50 aceptaciones simultáneas → 1 asignación, 0 dobles; control negativo → 10 asignaciones en 136 ms |
| **RNF-07** | Concurrencia en (a) búsqueda de aliados válidos, (b) aceptación de la misma solicitud, (c) mensajería. Prioridad de backlog Media; **riesgo crítico de diseño** (KI-09). Objetivo provisional (QS-08): listado < 1 s con 20 usuarios concurrentes. | Rendimiento | Media | ✅ (a) PoC-004: p95 E2E 296 ms con 20 VUs; en BD 9,48 ms a 100k aliados **con 2 índices** (123,91 ms sin ellos). ✅ (b) PoC-001. ⬜ (c) sin medir. Volumen real de negocio aún desconocido |

#### 3.3.4 Auditabilidad

| ID | Requerimiento no funcional | Atributo | Prioridad | Evidencia |
| --- | --- | --- | :---: | --- |
| **RNF-04** | Trazabilidad suficiente para reconstruir los eventos del ciclo; registro financiero inmutable en el 2º incremento. | Auditabilidad | Alta | ⬜ |

#### 3.3.5 Usabilidad y modelo de cobertura

| ID | Requerimiento no funcional | Atributo | Prioridad | Evidencia |
| --- | --- | --- | :---: | --- |
| **RNF-08** | Interfaz utilizable desde dispositivos móviles por clientes y aliados. | Usabilidad | Media | ◐ Flutter (una base de código); web operativa, móvil sin publicar |
| **RNF-09** | Cobertura por zonas, no por radio (REST-01): catálogo jerárquico, granularidad localidad/comuna, catálogo global de solo lectura, zonas que se desactivan. Sin cobertura parcial de una localidad en el MVP. | Usabilidad / Modelo de datos | Alta | ✅ PoC-004 confirma ADR-0011 |

#### 3.3.6 Resumen

| Categoría | RNF | Destacado |
| --- | --- | --- |
| Seguridad / Multi-tenancy | RNF-01, RNF-06, RNF-11 | RNF-01 **Crítica** |
| Configurabilidad | RNF-02, RNF-10 | RNF-02 **Crítica** |
| Fiabilidad / Concurrencia | RNF-03, RNF-05, RNF-07 | Alta |
| Auditabilidad | RNF-04 | Alta |
| Usabilidad / Modelo de datos | RNF-08, RNF-09 | RNF-09 Alta |

#### 3.3.7 Drivers arquitectónicos y riesgos

Drivers confirmados (SAD V3 §1): **RNF-01** (aislamiento, incluidos archivos y rol),
**RNF-02** (configurabilidad), **RNF-03** (idempotencia), **RNF-05** (despacho determinista).

**RNF-07** es el killer candidato (KI-09): la prioridad Media mide orden de atención, no
severidad. PoC-004 dio la primera cifra sintética; si el volumen real supera lo asumido
(SUP-03), obliga a rediseñar la capa de consulta.

Riesgos derivados de las PoC que condicionan la implementación de los drivers (sin cambiar
estos requisitos): políticas de aislamiento sin versionar en migraciones (KI-12) y ausencia de
restricción por rol (KI-13). Ver SAD V3 §2.

---

## 4. Apéndices

### 4.1 Glosario

Ver **DD V2 §14 — Glosario de términos**, única fuente de definiciones del proyecto.

### 4.2 Esquema de códigos

- **RF-01..28**, **RNF-01..11**, **PROY-01..08**, **REST-01..05**, **SUP-01..06**,
  **M-01..M-14**.
- Los códigos **DR, KI, AC, QS, TO** pertenecen al SAD; aquí solo se citan.
- Ningún código se reutiliza ni se renumera entre versiones; una eliminación se marca como
  retirada.

### 4.3 Trazabilidad RF → HU → ADR → PoC

La matriz completa (sin celdas vacías) vive en `Project/MatrizTrazabilidad.md`. Resumen de
cobertura de evidencia del MVP: 4 PoC concentradas en los drivers críticos (RF-03, RF-05/06,
RF-07/09/12, RF-14); el resto de RF-01..RF-23 no tiene PoC.

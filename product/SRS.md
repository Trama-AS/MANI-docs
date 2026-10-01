# Software Requirements Specification (SRS) — MANI

**Empresa:** TRAMA · Ingeniería de Software  
**Producto:** MANI — plataforma multi-tenant de formalización de operaciones de servicio  
**Versión:** V4 — depurada  
**Estado:** Borrador para revisión  

---

# 1. Introducción

## 1.1 Propósito

Este documento especifica los requerimientos funcionales, no funcionales, restricciones del producto e interfaces externas de MANI.

El SRS define **qué debe hacer el sistema** y **qué condiciones debe cumplir**. Las decisiones de arquitectura, tecnologías, despliegue, modelo físico de datos, CI/CD y herramientas se documentan fuera de este SRS.

## 1.2 Alcance

MANI es una plataforma SaaS multi-tenant que permite a empresas de servicios formalizar digitalmente su operación, conectando clientes con aliados mediante un ciclo de solicitud, cotización, ejecución, calificación y cierre, con trazabilidad operativa y configuración propia por empresa.

### MVP

El MVP comprende:

- plataforma multi-tenant;
- autenticación y control de acceso;
- directorio de aliados y clientes;
- catálogo de categorías;
- cobertura por zonas;
- ciclo del servicio;
- comunicación y notificaciones;
- tarifario de referencia;
- reportes asociados al tarifario.

### Segundo incremento

Se contempla posteriormente:

- pagos y liquidación;
- gestión de quejas;
- comercialización;
- administración avanzada;
- métricas operativas por tenant.

### Fuera de alcance del MVP

- pasarela de pago;
- facturación electrónica;
- consola de comercialización;
- geolocalización en tiempo real del aliado;
- cálculo de proximidad o distancia entre aliado y sitio.

## 1.3 Definiciones

- **Tenant:** empresa suscrita a la plataforma.
- **Aliado:** prestador del servicio.
- **Cliente:** quien solicita el servicio.
- **Administrador de plataforma:** administra la plataforma SaaS y los tenants.
- **Administrador de tenant:** administra la configuración y operación de su empresa.
- **RF:** requerimiento funcional.
- **RNF:** requerimiento no funcional.
- **REST:** restricción del producto.
- **PROY:** restricción de ejecución del proyecto.
- **Solicitud → Cotización → Ejecución → Calificación → Cierre:** ciclo de vida principal del servicio.

---

# 2. Descripción general

## 2.1 Perspectiva del producto

MANI es una plataforma SaaS multi-tenant en la que una única solución sirve a múltiples empresas, manteniendo aislados sus datos, usuarios y configuraciones.

Cada tenant puede configurar sus propias reglas operativas sin requerir una versión distinta del producto.

## 2.2 Funciones principales

El sistema debe proporcionar:

- registro y administración de tenants;
- autenticación y autorización por rol y tenant;
- directorio de aliados;
- directorio de clientes;
- gestión de documentos KYC;
- catálogo de categorías;
- cobertura por zonas;
- solicitud y despacho de servicios;
- cotización;
- ejecución;
- calificación;
- mensajería;
- notificaciones;
- tarifario;
- reportes operativos;
- funcionalidades de pagos, quejas y métricas en el segundo incremento.

## 2.3 Actores

### Administrador de plataforma

Responsabilidades:

- registrar tenants;
- administrar el estado de tenants;
- supervisar aspectos administrativos de la plataforma.

### Administrador de tenant

Responsabilidades:

- configurar reglas del tenant;
- administrar categorías;
- administrar tarifarios;
- definir documentos requeridos;
- aprobar o rechazar aliados;
- gestionar parámetros operativos del tenant.

### Aliado

Responsabilidades:

- registrarse;
- cargar documentos KYC;
- declarar categorías atendidas;
- declarar cobertura;
- aceptar o rechazar solicitudes;
- cotizar;
- ejecutar servicios;
- participar en mensajería;
- calificar al cliente.

### Cliente

Responsabilidades:

- registrarse;
- administrar sitios de servicio cuando corresponda;
- crear solicitudes;
- consultar aliados;
- gestionar cotizaciones;
- participar en mensajería;
- calificar al aliado.

## 2.4 Entorno operativo

La interfaz debe ser utilizable desde dispositivos móviles por clientes y aliados.

El sistema debe ser accesible remotamente y soportar múltiples tenants de forma simultánea.

---

# 3. Restricciones

## 3.1 Restricciones del proyecto

| ID | Restricción |
|---|---|
| **PROY-01** | El proyecto se ejecuta bajo metodología Scrum. |
| **PROY-02** | El alcance de este corte académico se limita al MVP. |
| **PROY-03** | La documentación y gestión siguen el esquema de gobierno definido por el equipo. |
| **PROY-04** | El equipo cuenta con siete integrantes y responsabilidad técnica distribuida. |
| **PROY-05** | Las decisiones técnicas costosas de revertir deben discutirse y documentarse formalmente. |
| **PROY-06** | Las herramientas utilizadas deben corresponder a las aprobadas por el equipo. |
| **PROY-07** | El proyecto exige el uso de Java y .NET en algún módulo del backend. |
| **PROY-08** | El proyecto exige el uso de Kubernetes como orquestador. |

## 3.2 Restricciones del producto

| ID | Restricción |
|---|---|
| **REST-01** | La cobertura de aliados se declara por zonas de un catálogo administrativo jerárquico y no mediante radio geográfico ni geolocalización en tiempo real. |
| **REST-02** | Los documentos KYC y las reglas operativas configurables deben depender del tenant. Los documentos KYC deben mantenerse aislados entre aliados y tenants. |
| **REST-03** | El modelo de pagos será centralizado y utilizará un operador certificado. |
| **REST-04** | El aislamiento de datos entre tenants debe ser estricto en toda funcionalidad del sistema. |
| **REST-05** | Cada tenant debe poder configurar sus propias reglas sin requerir un despliegue de código específico para esa empresa. |

---

# 4. Requerimientos funcionales

## 4.1 Plataforma multi-tenant y acceso

| ID | Requerimiento | Prioridad | Dependencias |
|---|---|---:|---|
| **RF-01** | Registrar y administrar empresas (tenants), garantizando el aislamiento de sus datos. | Crítica | — |
| **RF-02** | Permitir que cada tenant configure sus propias reglas, incluyendo documentos requeridos por tipo de aliado, orden del listado, categorías y tarifas. | Crítica | RF-01 |
| **RF-03** | Autenticar usuarios y restringir su acceso de acuerdo con el tenant al que pertenecen y los permisos de su rol, mediante un mecanismo de identificación de tenant no falsificable por el cliente. | Crítica | RF-01 |
| **RF-04** | Permitir la recuperación segura de la contraseña de los usuarios. | Alta | RF-03 |

## 4.2 Directorio de aliados y clientes

| ID | Requerimiento | Prioridad | Dependencias |
|---|---|---:|---|
| **RF-05** | Registrar aliados diferenciando entre persona natural, empresa y empleado directo, incluyendo los documentos requeridos según la configuración del tenant. Los documentos cargados deben quedar aislados por aliado y tenant. | Crítica | RF-02 |
| **RF-06** | Permitir al administrador del tenant aprobar o rechazar registros de aliados mediante una bandeja de verificación, sin exponer documentos de otro aliado. | Alta | RF-05 |
| **RF-07** | Permitir que los aliados declaren las zonas geográficas en las que prestan sus servicios. | Alta | RF-05 |
| **RF-08** | Registrar clientes como persona natural o empresa, permitiendo que los clientes empresa administren múltiples sitios de servicio. | Alta | RF-02 |
| **RF-09** | Registrar reglas y condiciones particulares de cada sitio de servicio y hacerlas visibles al aliado antes de la programación. Todo sitio debe tener una zona asignada. | Media | RF-08 |

## 4.3 Catálogo y cobertura

| ID | Requerimiento | Prioridad | Dependencias |
|---|---|---:|---|
| **RF-10** | Permitir al tenant definir, activar y desactivar categorías de servicio. | Alta | RF-02 |
| **RF-11** | Permitir asociar aliados con las categorías de servicio que pueden atender. | Media | RF-05, RF-10 |

## 4.4 Ciclo del servicio

| ID | Requerimiento | Prioridad | Dependencias |
|---|---|---:|---|
| **RF-12** | Permitir crear solicitudes de servicio y presentar aliados válidos de acuerdo con categoría y cobertura por zona. | Crítica | RF-07, RF-10 |
| **RF-13** | Ordenar el listado de aliados de acuerdo con la regla configurada por el tenant, considerando criterios como cobertura, calificación o comisión. | Alta | RF-12 |
| **RF-14** | Permitir que un aliado acepte o rechace una solicitud, garantizando que no existan dobles asignaciones para un mismo servicio. | Crítica | RF-12 |
| **RF-15** | Permitir al aliado elaborar una cotización diferenciando costos de mano de obra y materiales. | Alta | RF-14 |
| **RF-16** | Alertar al aliado cuando una cotización esté por encima o por debajo del rango establecido en el tarifario de referencia. | Media | RF-15, RF-22 |
| **RF-17** | Permitir al cliente aceptar, rechazar o solicitar ajustes sobre una cotización. | Alta | RF-15 |
| **RF-18** | Registrar cronológicamente los eventos y observaciones ocurridos durante la ejecución del servicio. | Media | RF-17 |
| **RF-19** | Permitir una calificación bidireccional entre cliente y aliado al finalizar el servicio. El servicio no podrá cerrarse hasta que ambas partes hayan realizado su calificación. | Media | RF-18 |

## 4.5 Comunicación y notificaciones

| ID | Requerimiento | Prioridad | Dependencias |
|---|---|---:|---|
| **RF-20** | Permitir la mensajería entre cliente y aliado asociada a cada servicio, con entrega casi en tiempo real cuando estén conectados y notificación cuando el destinatario no lo esté. | Media | RF-14 |
| **RF-21** | Permitir consultar las conversaciones asociadas a un servicio para apoyar la atención y gestión de quejas. | Baja | RF-20 |

## 4.6 Tarifario de referencia

| ID | Requerimiento | Prioridad | Dependencias |
|---|---|---:|---|
| **RF-22** | Mantener una tabla de tarifas de referencia por categoría y tenant, con valores mínimo, típico y máximo. | Alta | RF-10 |
| **RF-23** | Generar reportes de cotizaciones fuera del rango de referencia, permitiendo consulta por período. | Baja | RF-16 |

## 4.7 Segundo incremento

| ID | Requerimiento | Prioridad | Dependencias |
|---|---|---:|---|
| **RF-24** | Permitir cobrar al cliente en línea mediante un operador certificado y registrar cada transacción. | Media | RF-17 |
| **RF-25** | Permitir liquidar pagos al aliado descontando la comisión configurable del tenant. | Media | RF-24 |
| **RF-26** | Registrar y gestionar quejas asociadas a un servicio. | Baja | RF-19 |
| **RF-27** | Proporcionar una consola para la comercialización y publicación del tenant. | Baja | RF-01 |
| **RF-28** | Proporcionar métricas operativas por tenant y permitir la administración del estado de los tenants. | Baja | RF-01 |

---

# 5. Interfaces externas

| Sistema externo | Propósito | Información intercambiada | Dirección | Restricción |
|---|---|---|---|---|
| Operador de pagos certificado | Procesar cobros y liquidaciones | monto, estado, comprobante | Bidireccional | PCI DSS recae en el operador |
| Proveedor de identidad | Autenticar usuarios y gestionar credenciales | credenciales, tokens | Bidireccional | debe respetar el aislamiento multi-tenant |
| Servicio de notificaciones push | Entregar notificaciones cuando el usuario no está conectado | destinatario, contenido, evento | Saliente | debe complementar la mensajería del sistema |

---

# 6. Requerimientos no funcionales

## 6.1 Seguridad y aislamiento multi-tenant

| ID | Requerimiento | Prioridad |
|---|---|---:|
| **RNF-01** | Los datos de un tenant deben estar estrictamente aislados de los demás. Ningún usuario o mecanismo de acceso asociado a un tenant podrá acceder a información perteneciente a otro tenant. El aislamiento cubre registros y archivos/documentos, y la identificación del tenant debe ser verificable por el servidor. | Crítica |
| **RNF-06** | La responsabilidad de cumplimiento PCI DSS deberá recaer en el operador de pagos certificado y no en MANI. | Alta |
| **RNF-11** | El modelo de pagos deberá ser centralizado y utilizar un operador certificado. | Media |

## 6.2 Configurabilidad y modificabilidad

| ID | Requerimiento | Prioridad |
|---|---|---:|
| **RNF-02** | Cada tenant debe poder configurar sus propias reglas sin requerir código específico ni un nuevo despliegue de la plataforma. | Crítica |
| **RNF-10** | Los documentos KYC, tiempos y comisiones deben ser configurables por tenant y no estar definidos de forma fija en el sistema. | Alta |

## 6.3 Fiabilidad, resiliencia y concurrencia

| ID | Requerimiento | Prioridad |
|---|---|---:|
| **RNF-03** | Las operaciones críticas deben ser resistentes a reintentos y no generar operaciones duplicadas. | Alta |
| **RNF-05** | El proceso de despacho debe resolver de forma determinista las aceptaciones concurrentes, garantizando exactamente una asignación válida por solicitud. | Alta |
| **RNF-07** | La plataforma debe soportar concurrencia en consultas de aliados, aceptación de solicitudes y mecanismos de comunicación. | Media |

## 6.4 Auditabilidad y trazabilidad

| ID | Requerimiento | Prioridad |
|---|---|---:|
| **RNF-04** | La operación debe contar con trazabilidad y auditabilidad suficientes para reconstruir eventos relevantes del ciclo del servicio. | Alta |

## 6.5 Usabilidad y cobertura

| ID | Requerimiento | Prioridad |
|---|---|---:|
| **RNF-08** | La interfaz debe ser utilizable desde dispositivos móviles por clientes y aliados. | Media |
| **RNF-09** | La cobertura de aliados debe declararse y gestionarse mediante zonas geográficas y no mediante radio de distancia. | Alta |

---

# 7. Trazabilidad mínima

| Grupo | Requerimientos |
|---|---|
| Plataforma multi-tenant | RF-01..RF-04 |
| Directorio de actores | RF-05..RF-09 |
| Catálogo y cobertura | RF-10..RF-11 |
| Ciclo del servicio | RF-12..RF-19 |
| Comunicación | RF-20..RF-21 |
| Tarifario | RF-22..RF-23 |
| Segundo incremento | RF-24..RF-28 |
| Seguridad | RNF-01, RNF-06, RNF-11 |
| Configurabilidad | RNF-02, RNF-10 |
| Fiabilidad/concurrencia | RNF-03, RNF-05, RNF-07 |
| Auditabilidad | RNF-04 |
| Usabilidad/cobertura | RNF-08, RNF-09 |

---

# 8. Criterio documental

Este SRS no contiene:

- decisiones de arquitectura;
- diagramas C4;
- tecnologías de implementación;
- configuración de despliegue;
- ambientes;
- pipelines CI/CD;
- herramientas DevSecOps;
- herramientas de observabilidad;
- modelo físico de datos;
- DDL;
- ADR;
- decisiones de infraestructura.

Esos elementos pertenecen al SAD, SDD, documento de datos y ADR del proyecto.

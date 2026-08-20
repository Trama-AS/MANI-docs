# Software Requirements Specification (SRS) — MANI

**Empresa:** TRAMA · Ingeniería de Software
**Producto:** MANI — plataforma multi-tenant de formalización de operaciones de servicio
**Documento:** SRS V1
**Estado:** Borrador para revisión

> 🔴 = pendiente de decisión del equipo. Este SRS es **tecnológicamente neutral**: describe
> qué debe cumplir el sistema, no con qué tecnología se implementará. Las decisiones de
> stack se registran vía ADR cuando la Mesa de Arquitectura las tome, a partir de la Matriz
> de Herramientas y de los Spikes técnicos. Este documento no incluye matriz de
> trazabilidad hacia transcripciones, reuniones ni otras fuentes documentales; la
> identificación de los requisitos se sostiene con sus propios códigos y organización interna.

## Flujo de aprobación de este documento

1. **Elaboración:** responsable de requerimientos (Product Owner, Nicolás León) a partir del
   Análisis de Requerimientos.
2. **Revisión y comentarios:** revisor de requerimientos definido por el equipo.
   🔴 **PREGUNTA PARA EL EQUIPO:** confirmar el nombre del revisor del SRS. En la
   documentación existente el rol que verifica criterios de aceptación/calidad de
   requerimientos es **QA (Santiago)**; se propone que QA sea el revisor que comenta antes de
   la aprobación. Confirmar o corregir.
3. **Aprobación:** Product Owner (Nicolás León) aprueba tras incorporar los comentarios.

---

## 1. Propósito y alcance

### 1.1 Propósito
Especificar los requisitos del sistema MANI, una plataforma que permite a **empresas de
servicios** formalizar digitalmente su operación: conectar clientes con aliados a través de
un ciclo completo de solicitud, cotización, ejecución, calificación y cierre, con
trazabilidad operativa y configuración propia por empresa.

### 1.2 Alcance
- **MVP (primer incremento):** plataforma multi-tenant, directorio de actores, catálogo y
  cobertura, ciclo del servicio, comunicación y tarifario. *(EP-01 a EP-06 del Product
  Backlog.)*
- **Segundo incremento:** pagos y facturación, quejas, comercialización y administración
  avanzada. *(EP-07, EP-08.)*
- **Fuera de alcance del MVP:** pasarela de pago, facturación electrónica, consola de
  comercialización, geolocalización en tiempo real del aliado (descartado).

## 2. Contexto del producto

MANI es una plataforma **SaaS multi-tenant**. Una única instancia sirve a múltiples empresas
(tenants) manteniendo datos, configuración y usuarios aislados entre ellas. La empresa del
cliente actual del proyecto opera como primer tenant. Cada tenant configura sus propias
reglas (documentos exigidos, categorías, tarifas, orden del listado, comisión) sin requerir
desarrollo específico para cada empresa.

El sistema soporta el proceso operativo completo del sector de servicios que hoy el cliente
gestiona de forma informal: un cliente solicita un servicio, un aliado lo cotiza y ejecuta, y
la operación queda registrada de extremo a extremo hasta su cierre y calificación.

**Definiciones de dominio:**
- **Tenant:** empresa suscrita a la plataforma; opera aislada de las demás con su propia
  configuración.
- **Aliado:** prestador del servicio (persona natural, empresa o empleado directo).
- **Cliente:** quien solicita el servicio (persona natural o empresa).
- **Solicitud → Cotización → Ejecución → Calificación → Cierre:** ciclo de vida del servicio.

**Clases de usuario:** administrador de plataforma; administrador de tenant; aliado (persona
natural / empresa / empleado directo); cliente (persona natural / empresa).

## 3. Funciones principales

Principales capacidades que debe proporcionar el sistema, sin describirlas en términos de
tecnología:

- Registro y configuración de tenants (empresas suscritas).
- Identidad y control de acceso por rol y por tenant.
- Directorio diferenciado de aliados (persona natural, empresa, empleado directo) y clientes
  (persona natural, empresa).
- Catálogo de categorías de servicio y declaración de cobertura por zonas.
- Ciclo del servicio de extremo a extremo: solicitud, cotización, ejecución, calificación y
  cierre.
- Mensajería y notificaciones asociadas a cada servicio.
- Tarifario de referencia por categoría, con alerta cuando una cotización se sale de rango.
- *(2º incremento)* Cobro y liquidación, gestión de quejas, comercialización y métricas
  operativas por tenant.

### 3.1 Matriz de actores por función

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
| Tarifario | — | ✔ (carga tarifas) | consulta al cotizar | — |
| Pagos *(2º incremento)* | ✔ (concilia) | ✔ (liquida) | consulta pagos | ✔ (paga) |
| Quejas / operación *(2º incremento)* | ✔ (estado tenants) | ✔ | — | ✔ (quejas) |

## 4. Requerimientos funcionales identificados

4. Requerimientos funcionales

Los siguientes requerimientos funcionales consolidan las capacidades identificadas para MANI. Cada requerimiento está asociado a un identificador único (RF-01 a RF-28) y se organiza de acuerdo con los principales módulos funcionales del producto.

Las prioridades y estimaciones corresponden a la propuesta inicial del Análisis de Requerimientos y deberán validarse durante el refinamiento del Product Backlog. Las estimaciones están expresadas en puntos de historia.

4.1 Plataforma multi-tenant y control de acceso

ID	Requerimiento funcional	Prioridad	Est.	Dependencias
RF-01	Registrar y administrar empresas (tenants), garantizando el aislamiento de sus datos.	Crítica	8	—
RF-02	Permitir que cada tenant configure sus propias reglas, incluyendo documentos requeridos por tipo de aliado, orden del listado, categorías y tarifas.	Crítica	8	RF-01
RF-03	Autenticar usuarios y restringir su acceso de acuerdo con el tenant al que pertenecen y los permisos de su rol.	Crítica	8	RF-01
RF-04	Permitir la recuperación segura de la contraseña de los usuarios.	Alta	3	RF-03

4.2 Directorio de aliados y clientes

ID	Requerimiento funcional	Prioridad	Est.	Dependencias
RF-05	Registrar aliados diferenciando entre persona natural, empresa y empleado directo, incluyendo los documentos requeridos según la configuración del tenant.	Crítica	8	RF-02
RF-06	Permitir al administrador del tenant aprobar o rechazar registros de aliados mediante una bandeja de verificación.	Alta	5	RF-05
RF-07	Permitir que los aliados declaren las zonas geográficas en las que prestan sus servicios.	Alta	5	RF-05
RF-08	Registrar clientes como persona natural o empresa, permitiendo que los clientes empresa administren múltiples sitios de servicio.	Alta	5	RF-02
RF-09	Registrar reglas y condiciones particulares de cada sitio de servicio y hacerlas visibles al aliado antes de la programación del servicio.	Media	5	RF-08

4.3 Catálogo de servicios y cobertura

ID	Requerimiento funcional	Prioridad	Est.	Dependencias
RF-10	Permitir al tenant definir, activar y desactivar categorías de servicio, incluyendo el flujo operativo asociado a cada categoría.	Alta	5	RF-02
RF-11	Permitir asociar aliados con las categorías de servicio que pueden atender.	Media	3	RF-05, RF-10

4.4 Ciclo del servicio

El ciclo principal de MANI comprende las etapas de solicitud, cotización, ejecución, calificación y cierre.

ID	Requerimiento funcional	Prioridad	Est.	Dependencias
RF-12	Permitir crear solicitudes de servicio y presentar los aliados válidos de acuerdo con la categoría y su cobertura.	Crítica	8	RF-07, RF-10
RF-13	Ordenar el listado de aliados de acuerdo con la regla configurada por el tenant, considerando criterios como cobertura, calificación o comisión.	Alta	5	RF-12
RF-14	Permitir que un aliado acepte o rechace una solicitud asignada, garantizando que no existan dobles asignaciones para un mismo servicio.	Crítica	8	RF-12
RF-15	Permitir al aliado elaborar una cotización diferenciando los costos de mano de obra y materiales.	Alta	5	RF-14
RF-16	Alertar al aliado cuando una cotización se encuentre por encima o por debajo del rango establecido en el tarifario de referencia.	Media	3	RF-15, RF-22
RF-17	Permitir al cliente aceptar, rechazar o solicitar ajustes sobre una cotización.	Alta	5	RF-15
RF-18	Registrar cronológicamente los eventos y observaciones ocurridos durante la ejecución del servicio.	Media	5	RF-17
RF-19	Permitir una calificación bidireccional entre cliente y aliado al finalizar el servicio. El servicio no podrá cerrarse hasta que ambas partes hayan realizado su calificación.	Media	5	RF-18

4.5 Comunicación y notificaciones

ID	Requerimiento funcional	Prioridad	Est.	Dependencias
RF-20	Permitir la mensajería entre cliente y aliado asociada a cada servicio, incluyendo las notificaciones correspondientes a los eventos relevantes.	Media	8	RF-14
RF-21	Permitir consultar las conversaciones asociadas a un servicio para apoyar la atención y gestión de quejas.	Baja	3	RF-20

4.6 Tarifario de referencia

ID	Requerimiento funcional	Prioridad	Est.	Dependencias
RF-22	Mantener una tabla de tarifas de referencia por categoría y tenant, con valores mínimo, típico y máximo.	Alta	5	RF-10
RF-23	Generar reportes de cotizaciones que se encuentren fuera del rango de referencia, permitiendo su consulta por período.	Baja	3	RF-16

4.7 Segundo incremento

Los siguientes requerimientos corresponden a funcionalidades previstas para un segundo incremento y se encuentran fuera del alcance del MVP definido para este corte académico.

ID	Requerimiento funcional	Prioridad	Est.	Dependencias
RF-24	Permitir cobrar al cliente en línea mediante un operador certificado y registrar cada transacción.	Media	13	RF-17
RF-25	Permitir liquidar los pagos al aliado descontando la comisión configurable del tenant.	Media	8	RF-24
RF-26	Registrar y gestionar quejas asociadas a un servicio.	Baja	5	RF-19
RF-27	Proporcionar una consola para la comercialización y publicación del tenant.	Baja	8	RF-01
RF-28	Proporcionar métricas operativas por tenant y permitir la administración del estado de los tenants.	Baja	8	RF-01

## 5. Requerimientos no funcionales

Consolidados desde el Análisis de Requerimientos (RNF-01..RNF-11):

- **Seguridad / Multi-tenancy (RNF-01, RNF-06):** aislamiento estricto entre tenants; PCI DSS
  delegado al operador de pagos.
- **Modificabilidad / Configurabilidad (RNF-02, RNF-10):** reglas, documentos, tiempos y
  comisiones configurables por tenant, sin código específico.
- **Fiabilidad / Resiliencia (RNF-03, RNF-05):** idempotencia en operaciones críticas;
  resolución determinista de aceptaciones concurrentes.
- **Auditabilidad (RNF-04):** trazabilidad operativa; registro inmutable financiero *(2º
  incremento)*.
- **Rendimiento / Escalabilidad (RNF-07):** soporte de concurrencia en búsqueda y mensajería.
- **Usabilidad (RNF-08, RNF-09):** operable en dispositivos móviles; cobertura declarada por
  zonas.
- **Cumplimiento (RNF-11):** modelo de pagos centralizado con operador certificado.

Estas características de calidad no se convierten aquí en soluciones tecnológicas; su
resolución técnica corresponde a la arquitectura, los Spikes y los ADR correspondientes.

## 6. Restricciones del proyecto

Condiciones que limitan o condicionan la ejecución del proyecto, no del producto en sí:

- El alcance de este corte académico se limita al **MVP** (EP-01..EP-06 del Product
  Backlog); el 2º incremento (pagos, quejas, comercialización, administración avanzada)
  queda fuera de este corte.
- El proyecto se ejecuta bajo metodología **Scrum**, con sprints y ceremonias ajustados al
  cronograma académico vigente.
- El equipo cuenta con 7 integrantes, con roles y disponibilidad definidos (ver documento de
  Gobierno del Equipo).
- Las decisiones tecnológicas de producto dependen de Spikes y de la discusión en la Mesa de
  Arquitectura; no se cierran unilateralmente ni antes de tiempo.
- La documentación y gestión del proyecto siguen el esquema documental vigente (ver
  documento de Gobierno del Equipo).

## 7. Restricciones del producto

Condiciones o límites que debe respetar el producto, independientemente de la tecnología que
finalmente se seleccione:

- La cobertura de los aliados se declara por **zonas**, no por radio geográfico.
- Los documentos de verificación (KYC) y las reglas de tiempos/comisión son **configurables
  por tenant**, no fijos ni codificados.
- El modelo de pagos es **centralizado**, con un operador certificado; la responsabilidad
  PCI DSS recae en ese operador, no en la plataforma *(2º incremento)*.
- El aislamiento de datos entre tenants es estricto en toda funcionalidad del sistema.
- Cada tenant debe poder configurar sus propias reglas sin requerir un despliegue de código
  específico para esa empresa.

## 8. Integraciones

Sistemas, servicios o componentes externos que no forman parte de nuestro alcance de
desarrollo, pero que deberán comunicarse con el sistema. No se detallan aquí decisiones
técnicas que todavía no existen.

| Sistema / servicio externo | Propósito | Información que intercambia | Dirección | Restricciones conocidas | Dependencias externas |
| --- | --- | --- | --- | --- | --- |
| Operador de pagos certificado *(2º incremento)* | Procesar cobros al cliente y liquidaciones al aliado | Monto, medio de pago, estado de la transacción, comprobante | Bidireccional (solicitud de cobro ↔ confirmación/estado) | La responsabilidad PCI DSS recae en el operador, no en la plataforma (restricción del producto) | 🔴 Selección del operador pendiente de spike y ADR |
| Proveedor de identidad *(si se decide externalizar autenticación)* | Autenticar usuarios y gestionar credenciales | Credenciales, tokens de sesión | Bidireccional | Debe respetar el aislamiento de datos entre tenants | 🔴 Pendiente del spike de identidad; puede resolverse con un componente interno en vez de un proveedor externo |
| Servicio de notificaciones *(correo / push / SMS, si se decide externalizar)* | Enviar notificaciones de eventos del ciclo del servicio y de mensajería | Destinatario, canal, contenido del evento | Saliente (plataforma → servicio externo) | 🔴 Sin definir | 🔴 Selección pendiente de la Mesa de Arquitectura |

🔴 **PREGUNTA PARA EL EQUIPO:** confirmar si alguna de estas integraciones se resuelve con un
componente propio en lugar de un servicio externo; mientras no haya spike/ADR, ninguna se
considera decidida.

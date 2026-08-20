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

Consolidados desde el Análisis de Requerimientos (RF-01..RF-28), agrupados por función:

- **Plataforma multi-tenant:** RF-01, RF-02, RF-03, RF-04.
- **Directorio de actores:** RF-05, RF-06, RF-07, RF-08, RF-09.
- **Catálogo y cobertura:** RF-10, RF-11.
- **Ciclo del servicio:** RF-12, RF-13, RF-14, RF-15, RF-16, RF-17, RF-18, RF-19.
- **Comunicación:** RF-20, RF-21.
- **Tarifario:** RF-22, RF-23.
- **Pagos** *(2º incremento)*: RF-24, RF-25.
- **Operación y comercialización** *(2º incremento)*: RF-26, RF-27, RF-28.

La descripción completa de cada RF, su prioridad y estimación propuestas viven en el
Análisis de Requerimientos.

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

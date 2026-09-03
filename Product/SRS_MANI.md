# Software Requirements Specification (SRS) — MANI

**Empresa:** TRAMA · Ingeniería de Software
**Producto:** MANI — plataforma multi-tenant de formalización de operaciones de servicio
**Documento:** SRS V3
**Estado:** Borrador para revisión
**Fecha de esta versión:** 2026-09-03

## Historial de versiones

| Versión     | Momento                                                    | Cambios principales                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| ------------ | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **V1** | Sprint 0, Sem. 4 (Planning Sprint 1)                       | Primera versión: propósito, alcance, contexto, funciones principales, RF-01..28, RNF-01..11, restricciones y integraciones.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| **V2** | Sprint 2 (Review Sprint 1 / Planning Sprint 2), 2026-09-03 | Reestructuración a formato IEEE 830; se agregan PROY-07/PROY-08 a las restricciones; se agregan códigos REST-01..05; se enriquecen RF-07/RF-12/RF-13/RNF-09 con el modelo de zonas de ADR-0011; se agrega columna de módulo a la tabla RF; se agrega §2.6 Suposiciones y dependencias.<br />Se enriquecen RF-05/RF-06 (aislamiento de documentos KYC por aliado, ADR-0013), RF-14 (comportamiento de despacho simultáneo/broadcast, ADR-0016) y RF-20 (mensajería casi en tiempo real con respaldo de notificación push, ADR-0017). Se enriquece RNF-01 con la identificación de tenant no falsificable (ADR-0018) y con el aislamiento de archivos/documentos, no solo de filas. Se enriquece RNF-07 con el objetivo provisional (no validado) que ya propone SAD-MANI.md §5 (QS-08). Se actualiza el estado de PROY-07 (reparto de módulos backend ya confirmado) y se agrega una **nueva nota de inconsistencia crítica sobre Kubernetes (PROY-08)**, detectada al consolidar ADR-0010, SAD-MANI.md, ADR-0019 y el Documento de Herramientas V2, que hoy se contradicen entre sí. Se agrega nota sobre KI-02 (contradicción de stack backend Java/.NET/Azure vs. Dart/Serverpod/Supabase), reconocida por el propio SAD.  |

## 1. Introducción

### 1.1 Propósito

Especificar los requisitos del sistema MANI, una plataforma que permite a **empresas de
servicios** formalizar digitalmente su operación: conectar clientes con aliados a través de
un ciclo completo de solicitud, cotización, ejecución, calificación y cierre, con
trazabilidad operativa y configuración propia por empresa. Este documento es la fuente de
verdad de **qué** debe hacer el sistema; el **cómo** (arquitectura, modelo de datos físico,
stack) se especifica en el SAD, el DD y los ADR derivados.

### 1.2 Alcance

- **MVP (primer incremento):** plataforma multi-tenant, directorio de actores, catálogo y
  cobertura, ciclo del servicio, comunicación y tarifario. *(EP-01 a EP-06 del Product
  Backlog.)*
- **Segundo incremento:** pagos y facturación, quejas, comercialización y administración
  avanzada. *(EP-07, EP-08.)*
- **Fuera de alcance del MVP:** pasarela de pago, facturación electrónica, consola de
  comercialización, geolocalización en tiempo real del aliado (descartada), cálculo de
  proximidad o distancia entre aliado y sitio (descartado, ver REST-01).
- **Fuera de alcance de este documento:** las tareas puramente técnicas de habilitación
  (repositorios, base de datos, CI/CD, ambientes — ÉPICA 1 / "Enablers" del Product Backlog)
  no generan requerimientos funcionales en este SRS; se gestionan vía Gobierno del Equipo,
  ADR y Plan de Tareas.

### 1.3 Definiciones, acrónimos y abreviaturas

El glosario completo del proyecto vive en `Product/Glosario_Terminos_MANI.md` (términos de
negocio, técnicos y de metodología) y es la referencia autoritativa. Se listan aquí solo los
términos imprescindibles para leer este documento sin saltar a otro archivo:

- **Tenant:** empresa suscrita a la plataforma; opera aislada de las demás con su propia
  configuración.
- **Aliado:** prestador del servicio (persona natural, empresa o empleado directo).
- **Cliente:** quien solicita el servicio (persona natural o empresa).
- **RF / RNF:** requerimiento funcional / no funcional, identificados en este documento.
- **PROY:** requerimiento de proyecto (condición de ejecución, no de producto); ver
  Análisis de Requerimientos §6.
- **REST:** restricción del producto identificada en este documento (§2.5.2).
- **DR / KI / AC / QS / TO:** códigos propios de `Product/SAD-MANI.md` (Driver, Killer,
  Atributo de Calidad, Escenario de Calidad, Trade-off); no se redefinen aquí, se referencian
  cuando aportan contexto a un RF/RNF.
- **Solicitud → Cotización → Ejecución → Calificación → Cierre:** ciclo de vida del servicio.

### 1.4 Notas de consistencia documental

Se registran aquí, no como requisito, las inconsistencias detectadas entre documentos del
repositorio al elaborar esta versión. Ninguna decisión de este SRS depende de resolverlas,
pero condicionan directamente el diseño de solución que consume este documento.

✅ **Kubernetes / PROY-08 — contradicción resuelta (2026-09-03). PROY-08 es la fuente
autoritativa: Kubernetes es obligatorio.** Hasta el 2026-09-02, cinco fuentes vigentes decían
cosas distintas sobre si Kubernetes era obligatorio y sobre su costo:

| Fuente                                                        | Fecha      | Posición histórica (antes de la resolución)                                                                                             |
| ------------------------------------------------------------- | ---------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Análisis de Requerimientos / Perfil de Proyecto (PROY-08)    | 2026-08-23 | "Confirmado obligatorio" — requisito curricular del profesor                                                                            |
| ADR-0010 · Tech Radar                                        | 2026-08-25 | Kubernetes en anillo "Tal vez", condicionado a costo (~$450–650 USD/mes) sin driver de calidad que lo justifique                        |
| SAD-MANI.md · Killers (KI-03)                                | 2026-08-25 | "Veto explícito por costo-beneficio... pospuesto deliberadamente"                                                                       |
| ADR-0019 · Estilo macroarquitectónico                       | 2026-09-03 | Descartaba "Microservicios contenerizados sobre clúster gestionado de Kubernetes" por exceder el presupuesto del proyecto              |
| Documento de Herramientas V2 (Entrega3, línea base Sprint 2) | 2026-09-02 | Kubernetes (AKS) en anillo "SÍ O SÍ", estado "Adoptada"                                                                                 |

**Resolución (2026-09-03):** PROY-08 es un requisito curricular del profesor, no una decisión
evaluable por atributo de calidad ni por costo — es la fuente autoritativa y las demás se
alinean a ella, no al revés. El conflicto de costo nacía de confundir dos cosas distintas:
Kubernetes es software open source sin costo de licencia; la cifra de ~$450–650 USD/mes que
lo hacía ver "condicionado" o "pospuesto" correspondía al cómputo gestionado de Azure AKS, no
al orquestador — y Azure ya se retiró como proveedor de infraestructura (ADR-0021). Con esa
aclaración:
- **ADR-0010** (Tech Radar) mueve Kubernetes de "Tal vez" a "Sí o sí" — actualizado 2026-09-03.
- **SAD-MANI.md (KI-03)** deja de describirlo como "veto por costo, pospuesto": el "si" queda
  resuelto (se adopta); solo sigue abierto el "cómo" (dimensionamiento/hosting del clúster).
- **ADR-0019** aclara que la alternativa descartada por costo fue un clúster **gestionado en
  la nube** (tipo AKS), no Kubernetes como orquestador — la arquitectura distribuida elegida
  se despliega igual sobre Kubernetes, solo que sin clúster gestionado por un proveedor cloud.
- El Documento de Herramientas V2 ya no queda aislado: coincide con las demás fuentes.

Sigue abierto, y sí requiere un ADR propio, el **dónde y con cuántos nodos** corre el clúster
(proveedor de cómputo) — eso no lo resuelve esta nota ni ninguno de los ADR citados arriba.

---

## 2. Descripción general

### 2.1 Perspectiva del producto

MANI es una plataforma **SaaS multi-tenant**. Una única instancia sirve a múltiples empresas
(tenants) manteniendo datos, configuración y usuarios aislados entre ellas. La empresa del
cliente actual del proyecto opera como primer tenant. Cada tenant configura sus propias
reglas (documentos exigidos, categorías, tarifas, orden del listado, comisión) sin requerir
desarrollo específico para cada empresa.

El sistema soporta el proceso operativo completo del sector de servicios que hoy el cliente
gestiona de forma informal: un cliente solicita un servicio, un aliado lo cotiza y ejecuta, y
la operación queda registrada de extremo a extremo hasta su cierre y calificación.

### 2.2 Funciones principales

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

#### 2.2.1 Matriz de actores por función

| Función                              |  Admin. plataforma  |     Admin. tenant     |           Aliado           |      Cliente      |
| ------------------------------------- | :-----------------: | :-------------------: | :------------------------: | :----------------: |
| Alta y estado de tenants              |         ✔         |          —          |             —             |         —         |
| Configuración de reglas del tenant   |         —         |          ✔          |             —             |         —         |
| Autenticación y acceso               |        login        |         login         |           login           |       login       |
| Directorio de aliados                 |         —         |     ✔ (aprueba)     |      ✔ (se registra)      |      consulta      |
| Directorio de clientes                |         —         |          ✔          |  consulta reglas de sitio  |  ✔ (se registra)  |
| Catálogo y cobertura                 |         —         |   ✔ (categorías)   | ✔ (cobertura/categorías) |         —         |
| Solicitud y despacho                  |         —         | define regla de orden |    ✔ (acepta/rechaza)    |     ✔ (crea)     |
| Cotización                           |         —         |          —          |        ✔ (cotiza)        | ✔ (acepta/ajusta) |
| Ejecución                            |         —         |          —          |       ✔ (registra)       |    consulta log    |
| Calificación                         |         —         |          —          |             ✔             |         ✔         |
| Mensajería                           |         —         |   consulta (quejas)   |             ✔             |         ✔         |
| Tarifario                             |         —         |  ✔ (carga tarifas)  |    consulta al cotizar    |         —         |
| Pagos*(2º incremento)*               |    ✔ (concilia)    |     ✔ (liquida)     |       consulta pagos       |     ✔ (paga)     |
| Quejas / operación*(2º incremento)* | ✔ (estado tenants) |          ✔          |             —             |    ✔ (quejas)    |

### 2.3 Clases y características de usuarios

- **Administrador de plataforma:** opera MANI como SaaS; da de alta tenants y gestiona su
  estado. No participa en la operación diaria de un tenant.
- **Administrador de tenant:** configura las reglas de su empresa (categorías, tarifas,
  documentos exigidos, orden del listado, comisión); aprueba/rechaza aliados.
- **Aliado** (persona natural / empresa / empleado directo): presta el servicio; declara
  cobertura y categorías atendidas, cotiza y ejecuta.
- **Cliente** (persona natural / empresa): solicita el servicio; el cliente empresa administra
  múltiples sitios de servicio.

### 2.4 Entorno operativo

La interfaz debe ser utilizable desde dispositivos móviles por clientes y aliados (RNF-08).
El sistema opera como servicio multi-tenant accesible remotamente; no se asume un entorno de
despliegue específico en este documento — ver SAD y ADR para decisiones de infraestructura, y
§1.4 para la resolución de la contradicción sobre Kubernetes (PROY-08).

### 2.5 Restricciones

#### 2.5.1 Restricciones del proyecto (PROY)

Condiciones que limitan o condicionan la ejecución del proyecto, no del producto en sí.
Detalle completo en Análisis de Requerimientos §6; se resumen aquí las que enmarcan el alcance
de este SRS:

| ID                | Restricción                                                                                                                                                                            | Estado                                                                                                                                                                                       |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **PROY-01** | El proyecto se ejecuta bajo metodología**Scrum**, con sprints y ceremonias ajustados al cronograma académico vigente.                                                           | Vigente                                                                                                                                                                                      |
| **PROY-02** | El alcance de este corte académico se limita al**MVP** (EP-01..EP-06); el 2º incremento (pagos, quejas, comercialización, administración avanzada) queda fuera de este corte. | Vigente                                                                                                                                                                                      |
| **PROY-03** | La documentación y gestión del proyecto siguen el esquema documental vigente (Gobierno del Equipo).                                                                                   | Vigente                                                                                                                                                                                      |
| **PROY-04** | El equipo cuenta con 7 integrantes, con roles y disponibilidad definidos, incluida la responsabilidad transversal de Arquitecto.                                                        | Vigente                                                                                                                                                                                      |
| **PROY-05** | Toda decisión técnica costosa de revertir se discute en la Mesa de Arquitectura y se registra como ADR antes de implementarse.                                                        | Vigente                                                                                                                                                                                      |
| **PROY-06** | Las herramientas de gestión, documentación y calidad usadas son las definidas en la Matriz de Herramientas / Documento de Herramientas vigente.                                       | Vigente                                                                                                                                                                                      |
| **PROY-07** | El proyecto exige el uso de**Java** y **.NET** en algún módulo del backend (constraint externo, no elección tecnológica evaluable).                                     | **Confirmado y con alcance ya repartido**: Java (Repo B, reglas de negocio) y .NET (Repo C, alta concurrencia/transaccional), según ADR-0004, ADR-0019 y Documento de Herramientas V2 |
| **PROY-08** | El proyecto exige el uso de**Kubernetes** como orquestador (requisito curricular, no evaluable por atributo de calidad).                                                          | Vigente                                                                                                                                                                                      |

#### 2.5.2 Restricciones del producto (REST)

Condiciones o límites que debe respetar el producto, independientemente de la tecnología que
finalmente se seleccione. Se numeran porque ya son referenciadas por código desde otros
documentos (p. ej. ADR-0011 cita `REST-01`).

| ID                | Restricción                                                                                                                                                                                                                                                                                                                                                                                                                        |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **REST-01** | La cobertura de los aliados se declara por**zonas** de un catálogo administrativo jerárquico (ciudad → localidad/comuna → barrio), nunca por radio geográfico ni geolocalización en tiempo real. Ratificada en ADR-0011: la granularidad operativa del MVP es **localidad/comuna**; el catálogo de zonas es global de la plataforma y de solo lectura para los tenants; las zonas no se eliminan, se desactivan. |
| **REST-02** | Los documentos de verificación (KYC) y las reglas de tiempos/comisión son**configurables por tenant**, no fijos ni codificados. Adicionalmente (ADR-0013): un documento KYC cargado por un aliado no debe ser visible ni accesible para otro aliado del mismo tenant ni para ningún usuario de otro tenant — el aislamiento aplica también a archivos, no solo a registros de base de datos.                             |
| **REST-03** | El modelo de pagos es**centralizado**, con un operador certificado; la responsabilidad PCI DSS recae en ese operador, no en la plataforma *(2º incremento)*.                                                                                                                                                                                                                                                               |
| **REST-04** | El aislamiento de datos entre tenants es estricto en toda funcionalidad del sistema (ver RNF-01).                                                                                                                                                                                                                                                                                                                                   |
| **REST-05** | Cada tenant debe poder configurar sus propias reglas sin requerir un despliegue de código específico para esa empresa (ver RNF-02).                                                                                                                                                                                                                                                                                               |

---

## 3. Requerimientos específicos

### 3.1 Requerimientos funcionales

Los siguientes requerimientos funcionales consolidan las capacidades identificadas para MANI.
Cada requerimiento está asociado a un identificador único (**RF-01 a RF-28**), a su módulo
funcional (**M-01..M-14**, ver Análisis de Requerimientos §3) y se organiza de acuerdo con
los principales módulos funcionales del producto.

Las prioridades y estimaciones corresponden a la propuesta inicial del Análisis de
Requerimientos y deberán validarse durante el refinamiento del Product Backlog. Las
estimaciones están expresadas en puntos de historia.

#### 3.1.1 Plataforma multi-tenant y control de acceso (M-01)

| ID              | Requerimiento funcional                                                                                                                                                                                         |     Prioridad     | Est. | Dependencias |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------------: | :--: | ------------ |
| **RF-01** | Registrar y administrar empresas (**tenants**), garantizando el aislamiento de sus datos.                                                                                                                 | **Crítica** |  8  | —           |
| **RF-02** | Permitir que cada tenant configure sus propias reglas, incluyendo documentos requeridos por tipo de aliado, orden del listado, categorías y tarifas.                                                           | **Crítica** |  8  | RF-01        |
| **RF-03** | Autenticar usuarios y restringir su acceso de acuerdo con el tenant al que pertenecen y los permisos de su rol, mediante un mecanismo de identificación de tenant no falsificable por el cliente (ver RNF-01). | **Crítica** |  8  | RF-01        |
| **RF-04** | Permitir la recuperación segura de la contraseña de los usuarios.                                                                                                                                             |        Alta        |  3  | RF-03        |

#### 3.1.2 Directorio de aliados y clientes (M-02 / M-03)

| ID              | Requerimiento funcional                                                                                                                                                                                                                                |     Prioridad     | Est. | Dependencias |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :----------------: | :--: | ------------ |
| **RF-05** | Registrar aliados diferenciando entre persona natural, empresa y empleado directo, incluyendo los documentos requeridos según la configuración del tenant. Los documentos cargados deben quedar aislados por aliado y por tenant (ver REST-02).      | **Crítica** |  8  | RF-02        |
| **RF-06** | Permitir al administrador del tenant aprobar o rechazar registros de aliados mediante una bandeja de verificación, sin exponer a un aliado los documentos de verificación de otro aliado del mismo tenant (REST-02).                                 |        Alta        |  5  | RF-05        |
| **RF-07** | Permitir que los aliados declaren las zonas geográficas en las que prestan sus servicios, sobre el catálogo jerárquico de zonas (granularidad de localidad/comuna en el MVP; ver REST-01).                                                          |        Alta        |  5  | RF-05        |
| **RF-08** | Registrar clientes como persona natural o empresa, permitiendo que los clientes empresa administren múltiples sitios de servicio.                                                                                                                     |        Alta        |  5  | RF-02        |
| **RF-09** | Registrar reglas y condiciones particulares de cada sitio de servicio y hacerlas visibles al aliado antes de la programación del servicio. Todo sitio debe tener asignada una zona del catálogo (REST-01); sin zona no puede originar una solicitud. |       Media       |  5  | RF-08        |

#### 3.1.3 Catálogo de servicios y cobertura (M-04)

| ID              | Requerimiento funcional                                                                                                             | Prioridad | Est. | Dependencias |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------- | :-------: | :--: | ------------ |
| **RF-10** | Permitir al tenant definir, activar y desactivar categorías de servicio, incluyendo el flujo operativo asociado a cada categoría. |   Alta   |  5  | RF-02        |
| **RF-11** | Permitir asociar aliados con las categorías de servicio que pueden atender.                                                        |   Media   |  3  | RF-05, RF-10 |

#### 3.1.4 Ciclo del servicio (M-05..M-08)

El ciclo principal de MANI comprende las etapas de **solicitud, cotización, ejecución,
calificación y cierre**.

| ID              | Requerimiento funcional                                                                                                                                                                                                                                                                                                                        |     Prioridad     | Est. | Dependencias |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :----------------: | :--: | ------------ |
| **RF-12** | Permitir crear solicitudes de servicio y presentar los aliados válidos de acuerdo con la categoría y su cobertura (match exacto de zona entre el sitio y la cobertura declarada por el aliado; sin cálculo geoespacial en el MVP, ver REST-01).                                                                                             | **Crítica** |  8  | RF-07, RF-10 |
| **RF-13** | Ordenar el listado de aliados de acuerdo con la regla configurada por el tenant, considerando criterios como cobertura, calificación o comisión.                                                                                                                                                                                             |        Alta        |  5  | RF-12        |
| **RF-14** | Permitir que un aliado acepte o rechace una solicitud asignada, garantizando que no existan dobles asignaciones para un mismo servicio. La solicitud puede presentarse simultáneamente a todos los aliados válidos; el sistema resuelve la primera aceptación válida como asignación y notifica "ya no disponible" al resto (ver RNF-05). | **Crítica** |  8  | RF-12        |
| **RF-15** | Permitir al aliado elaborar una cotización diferenciando los costos de mano de obra y materiales.                                                                                                                                                                                                                                             |        Alta        |  5  | RF-14        |
| **RF-16** | Alertar al aliado cuando una cotización se encuentre por encima o por debajo del rango establecido en el tarifario de referencia.                                                                                                                                                                                                             |       Media       |  3  | RF-15, RF-22 |
| **RF-17** | Permitir al cliente aceptar, rechazar o solicitar ajustes sobre una cotización.                                                                                                                                                                                                                                                               |        Alta        |  5  | RF-15        |
| **RF-18** | Registrar cronológicamente los eventos y observaciones ocurridos durante la ejecución del servicio.                                                                                                                                                                                                                                          |       Media       |  5  | RF-17        |
| **RF-19** | Permitir una calificación bidireccional entre cliente y aliado al finalizar el servicio. El servicio no podrá cerrarse hasta que ambas partes hayan realizado su calificación.                                                                                                                                                              |       Media       |  5  | RF-18        |

#### 3.1.5 Comunicación y notificaciones (M-09)

| ID              | Requerimiento funcional                                                                                                                                                                                                                                                                                 | Prioridad | Est. | Dependencias |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------: | :--: | ------------ |
| **RF-20** | Permitir la mensajería entre cliente y aliado asociada a cada servicio, incluyendo las notificaciones correspondientes a los eventos relevantes. La entrega debe ser casi en tiempo real cuando ambas partes están conectadas, con respaldo de notificación push cuando el destinatario no lo está. |   Media   |  8  | RF-14        |
| **RF-21** | Permitir consultar las conversaciones asociadas a un servicio para apoyar la atención y gestión de quejas.                                                                                                                                                                                            |   Baja   |  3  | RF-20        |

#### 3.1.6 Tarifario de referencia (M-11)

| ID              | Requerimiento funcional                                                                                                 | Prioridad | Est. | Dependencias |
| --------------- | ----------------------------------------------------------------------------------------------------------------------- | :-------: | :--: | ------------ |
| **RF-22** | Mantener una tabla de tarifas de referencia por categoría y tenant, con valores mínimo, típico y máximo.            |   Alta   |  5  | RF-10        |
| **RF-23** | Generar reportes de cotizaciones que se encuentren fuera del rango de referencia, permitiendo su consulta por período. |   Baja   |  3  | RF-16        |

#### 3.1.7 Segundo incremento (M-10, M-12..M-14)

Los siguientes requerimientos corresponden a funcionalidades previstas para un **segundo
incremento** y se encuentran fuera del alcance del MVP definido para este corte académico.

| ID              | Requerimiento funcional                                                                               | Prioridad | Est. | Dependencias |
| --------------- | ----------------------------------------------------------------------------------------------------- | :-------: | :--: | ------------ |
| **RF-24** | Permitir cobrar al cliente en línea mediante un operador certificado y registrar cada transacción.  |   Media   |  13  | RF-17        |
| **RF-25** | Permitir liquidar los pagos al aliado descontando la comisión configurable del tenant.               |   Media   |  8  | RF-24        |
| **RF-26** | Registrar y gestionar quejas asociadas a un servicio.                                                 |   Baja   |  5  | RF-19        |
| **RF-27** | Proporcionar una consola para la comercialización y publicación del tenant.                         |   Baja   |  8  | RF-01        |
| **RF-28** | Proporcionar métricas operativas por tenant y permitir la administración del estado de los tenants. |   Baja   |  8  | RF-01        |

#### 3.1.8 Resumen por módulo

| Módulo                                                             | Requerimientos | Épica | Alcance         |
| ------------------------------------------------------------------- | -------------- | ------ | --------------- |
| **M-01 · Plataforma multi-tenant y acceso**                  | RF-01 – RF-04 | EP-01  | MVP             |
| **M-02/M-03 · Directorio de actores**                        | RF-05 – RF-09 | EP-02  | MVP             |
| **M-04 · Catálogo y cobertura**                             | RF-10 – RF-11 | EP-03  | MVP             |
| **M-05..M-08 · Ciclo del servicio**                          | RF-12 – RF-19 | EP-04  | MVP             |
| **M-09 · Comunicación**                                     | RF-20 – RF-21 | EP-05  | MVP             |
| **M-11 · Tarifario**                                         | RF-22 – RF-23 | EP-06  | MVP             |
| **M-10 · Pagos y liquidación**                              | RF-24 – RF-25 | EP-07  | 2.º incremento |
| **M-12..M-14 · Quejas, comercialización y administración** | RF-26 – RF-28 | EP-08  | 2.º incremento |

### 3.2 Requerimientos de interfaces externas (integraciones)

Sistemas, servicios o componentes externos que no forman parte del alcance de desarrollo,
pero que deberán comunicarse con el sistema. No se detallan aquí decisiones técnicas que
todavía no existen o no están ratificadas en firme.

| Sistema / servicio externo                      | Propósito                                                                                             | Información que intercambia                                 | Dirección                                                 | Restricciones conocidas                                                                                 | Dependencias externas                               |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------ | ---------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | --------------------------------------------------- |
| Operador de pagos certificado*(2º incremento)* | Procesar cobros al cliente y liquidaciones al aliado                                                   | Monto, medio de pago, estado de la transacción, comprobante | Bidireccional (solicitud de cobro ↔ confirmación/estado) | La responsabilidad PCI DSS recae en el operador, no en la plataforma (REST-03)                          | 🔴 Selección del operador pendiente de spike y ADR |
| Proveedor de identidad                          | Autenticar usuarios y gestionar credenciales                                                           | Credenciales, tokens de sesión                              | Bidireccional                                              | Debe respetar el aislamiento de datos entre tenants (RNF-01, REST-04)                                   | Spike y ADR Asignados                               |
| Servicio de notificaciones push                 | Entregar notificaciones cuando el destinatario no tiene una conexión activa con la plataforma (RF-20) | Destinatario, canal, contenido del evento                    | Saliente (plataforma → servicio externo)                  | Definición propuesta en ADR-0017, estado**Propuesto** — aún no ratificado en firme por la Mesa | ADR-0017 pendiente de ratificación final           |

### 3.3 Requerimientos no funcionales

Los requerimientos no funcionales establecen las características de calidad, restricciones y
condiciones que debe cumplir MANI, independientemente de las tecnologías utilizadas para su
implementación. Se mantienen tecnológicamente neutrales. Las decisiones relacionadas con su
implementación deberán ser evaluadas mediante Spikes técnicos y, cuando corresponda,
formalizadas mediante ADR en la Mesa de Arquitectura. Los escenarios de calidad (estímulo /
respuesta / medida) que operacionalizan cada RNF se elaboran en `Product/SAD-MANI.md` §5 (24
escenarios QS-01..QS-24) y no se duplican aquí para evitar que ambos documentos diverjan.

#### 3.3.1 Seguridad y aislamiento multi-tenant

| ID               | Requerimiento no funcional                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | Atributo de calidad       |     Prioridad     |
| ---------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- | :----------------: |
| **RNF-01** | Los datos de un tenant deben estar estrictamente aislados de los demás. Un usuario o mecanismo de acceso asociado a un tenant no podrá acceder a información perteneciente a otro tenant. El aislamiento cubre tanto registros de datos como archivos/documentos cargados por los usuarios (ver REST-02), y debe apoyarse en una identificación de tenant que el cliente no pueda falsificar enviando un valor arbitrario (p. ej. una cabecera editable) — la fuente de verdad del tenant debe ser verificable por el propio servidor. | Seguridad / Multi-tenancy | **Crítica** |
| **RNF-06** | La responsabilidad relacionada con el cumplimiento de PCI DSS deberá recaer en el operador de pagos certificado y no en la plataforma MANI.                                                                                                                                                                                                                                                                                                                                                                                                | Seguridad / Cumplimiento  |        Alta        |
| **RNF-11** | El modelo de pagos deberá ser centralizado y utilizar un operador certificado, priorizando la integración con un servicio existente sobre la construcción de un sistema propio.                                                                                                                                                                                                                                                                                                                                                          | Seguridad / Cumplimiento  |       Media       |

#### 3.3.2 Configurabilidad y modificabilidad

| ID               | Requerimiento no funcional                                                                                                                                     | Atributo de calidad                |     Prioridad     |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------- | :----------------: |
| **RNF-02** | Cada tenant debe poder configurar sus propias reglas sin requerir código específico ni un nuevo despliegue de la plataforma.                                 | Modificabilidad / Configurabilidad | **Crítica** |
| **RNF-10** | Los documentos de verificación (KYC), tiempos y comisiones deben ser configurables por tenant y no estar definidos de forma fija o codificados en el sistema. | Modificabilidad / Configurabilidad |        Alta        |

#### 3.3.3 Fiabilidad, resiliencia y concurrencia

| ID               | Requerimiento no funcional                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | Atributo de calidad         | Prioridad |
| ---------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | :-------: |
| **RNF-03** | Las operaciones críticas, como aceptar una solicitud, aceptar una cotización o realizar una calificación, deben ser resistentes a reintentos y no generar operaciones duplicadas.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | Fiabilidad / Resiliencia    |   Alta   |
| **RNF-05** | El proceso de despacho debe resolver de forma determinista las aceptaciones concurrentes, garantizando que exactamente una asignación válida quede asociada a una solicitud.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | Fiabilidad / Concurrencia   |   Alta   |
| **RNF-07** | La plataforma debe soportar concurrencia de usuarios realizando búsquedas de aliados y utilizando los mecanismos de comunicación asociados a los servicios. Cubre tres frentes: (a) múltiples clientes creando solicitudes y consultando aliados válidos por cobertura/categoría a la vez (RF-12, RF-13); (b) múltiples aliados intentando aceptar la misma solicitud en la misma ventana (RF-14, acoplado a RNF-05); (c) mensajería/notificaciones concurrentes por servicio en curso (RF-20). Prioridad de backlog Media;**riesgo crítico de diseño** — ver §2.6 y SAD §1/§2 (killer KI-09). SAD §5 (QS-08) propone un objetivo provisional (listado de aliados en <1 s con 20 usuarios concurrentes), explícitamente marcado como no validado con volumen real. | Rendimiento / Escalabilidad |   Media   |

#### 3.3.4 Auditabilidad y trazabilidad

| ID               | Requerimiento no funcional                                                                                                                                                                                                    | Atributo de calidad | Prioridad |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- | :-------: |
| **RNF-04** | La operación debe contar con trazabilidad y auditabilidad suficientes para reconstruir los eventos relevantes del ciclo del servicio. El registro de operaciones financieras deberá ser inmutable en el segundo incremento. | Auditabilidad       |   Alta   |

#### 3.3.5 Usabilidad y modelo de cobertura

| ID               | Requerimiento no funcional                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | Atributo de calidad          | Prioridad |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | :-------: |
| **RNF-08** | La interfaz debe ser utilizable desde dispositivos móviles por parte de clientes y aliados.                                                                                                                                                                                                                                                                                                                                                                                                                            | Usabilidad                   |   Media   |
| **RNF-09** | La cobertura de los aliados debe declararse y gestionarse mediante zonas geográficas y no mediante un radio de distancia (ver REST-01). Ratificado en ADR-0011: catálogo jerárquico ciudad → localidad/comuna → barrio; granularidad operativa del MVP en localidad/comuna; catálogo global de plataforma, solo lectura por tenant; las zonas se desactivan, nunca se eliminan, preservando la integridad histórica de los servicios ya registrados. No se soporta cobertura parcial de una localidad en el MVP. | Usabilidad / Modelo de datos |   Alta   |

#### 3.3.6 Resumen de requerimientos no funcionales

| Categoría                                        | Requerimientos         | Prioridad destacada       |
| ------------------------------------------------- | ---------------------- | ------------------------- |
| **Seguridad / Multi-tenancy**               | RNF-01, RNF-06, RNF-11 | RNF-01:**Crítica** |
| **Configurabilidad / Modificabilidad**      | RNF-02, RNF-10         | RNF-02:**Crítica** |
| **Fiabilidad / Resiliencia / Concurrencia** | RNF-03, RNF-05, RNF-07 | Alta                      |
| **Auditabilidad**                           | RNF-04                 | Alta                      |
| **Usabilidad / Modelo de datos**            | RNF-08, RNF-09         | RNF-09: Alta              |

#### 3.3.7 Drivers arquitectónicos y riesgos

De acuerdo con el Análisis de Requerimientos y ratificado en SAD-MANI.md §1 (Drivers) y §2
(Killers), los siguientes requerimientos son **drivers arquitectónicos** confirmados de MANI:

- **RNF-01 — Aislamiento multi-tenant:** el aislamiento estricto de datos es una condición
  crítica del producto y debe mantenerse en todas sus funcionalidades, incluidos los archivos.
- **RNF-02 — Configurabilidad:** cada tenant debe poder modificar sus reglas sin requerir
  desarrollos o despliegues específicos.
- **RNF-03 — Idempotencia:** las operaciones críticas deben tolerar reintentos sin generar
  duplicidad.
- **RNF-05 — Concurrencia en el despacho:** el sistema debe resolver de manera determinista
  las aceptaciones simultáneas de una solicitud.

**RNF-07** constituye el **killer arquitectónico candidato** (KI-09 en SAD): su prioridad de
backlog ("Media") mide orden de atención, no severidad de riesgo de diseño. Si el volumen real
de solicitudes/tenants concurrentes supera lo asumido, obliga a rediseñar la capa de consulta
después de construida.

Un riesgo adicional, no derivado de un RNF puntual sino de la propia consistencia de la
documentación de arquitectura, condiciona cómo se implementan estos drivers: la contradicción
de stack backend (KI-02), descrita en §1.4. No invalida los RF/RNF de este documento (que son
tecnológicamente neutrales), pero sí puede invalidar supuestos de costo y de despliegue del
SAD si no se resuelve antes de que Infraestructura comprometa una configuración en firme. La
contradicción sobre Kubernetes/PROY-08 que antes se citaba aquí junto a KI-02 ya quedó resuelta
(§1.4): PROY-08 es la fuente autoritativa, y ADR-0010/SAD-MANI.md (KI-03)/ADR-0019 quedaron
alineados a ella el 2026-09-03.

---

## 4. Apéndices

### 4.1 Glosario

Ver `Product/Glosario_Terminos_MANI.md` — fuente única de definiciones de negocio, técnicas y
de metodología del proyecto.

### 4.2 Esquema de códigos y trazabilidad

Este SRS no mantiene una matriz de trazabilidad completa hacia actas, transcripciones o
reuniones (decisión de alcance documental del equipo). Sí sostiene identificación estable por
código para que otros documentos puedan referenciarlo sin ambigüedad:

- **RF-01..28** — requerimientos funcionales (§3.1). Referenciados por Product Backlog, SAD
  (como origen de cada Driver y Escenario de Calidad) y ADR.
- **RNF-01..11** — requerimientos no funcionales (§3.3). Referenciados por SAD (Drivers,
  Killers, Escenarios de Calidad) y ADR.
- **PROY-01..08** — requerimientos de proyecto (§2.5.1), definidos in extenso en Análisis de
  Requerimientos §6.
- **REST-01..05** — restricciones del producto (§2.5.2). `REST-01` es citado por ADR-0011.
- **M-01..M-14** — módulos funcionales (Análisis de Requerimientos §3), usados para agrupar
  RF en §3.1 y para mapear épicas del Product Backlog.

Este SRS no posee autoridad sobre los códigos **DR** (Driver), **KI** (Killer), **AC**
(Atributo de Calidad ISO 25010) y **QS** (Escenario de Calidad) — esos viven y se numeran en
`Product/SAD-MANI.md`, que los deriva de los RF/RNF de este documento; se citan aquí solo como
referencia cruzada, nunca se redefinen.

Ningún código se reutiliza para conceptos distintos ni se renumera entre versiones de este
documento; una eliminación se marca como retirado, no se reasigna el número.

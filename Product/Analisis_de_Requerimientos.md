# TRAMA · MANI — Análisis de Requerimientos

> 🔴 = pendiente de decisión del equipo. Prioridades y estimaciones son **propuesta
> inicial**; se validan en refinamiento y, sin consenso, por **Planning Poker**.
> Los requerimientos son **tecnológicamente neutrales**: no nombran herramientas ni stack.
> Este documento concentra únicamente los requerimientos identificados del producto y del
> proyecto. No incluye matriz de trazabilidad ni referencias a transcripciones, actas o
> reuniones como evidencia del requerimiento.

## 1. Contexto del problema

El cliente opera (y quiere ofrecer a otras empresas del sector) un servicio que hoy vive de
forma **informal**: coordinación por WhatsApp, llamadas y contactos, sin trazabilidad ni
auditabilidad operativa. Necesita **formalizar digitalmente** esa operación en una plataforma
donde clientes soliciten servicios, aliados los coticen y ejecuten, y la operación quede
registrada de extremo a extremo.

**Doble naturaleza del negocio:** el cliente quiere montar una empresa de plataforma y, a la
vez, operar su propia empresa sobre ella → la plataforma debe servir a **múltiples empresas
(tenants)** y, simultáneamente, ser operada por la empresa del propio cliente como primer
tenant.

## 2. Stakeholders y actores

| Actor | Descripción |
| --- | --- |
| Administrador de plataforma | Opera la plataforma SaaS: alta y estado de tenants |
| Administrador de tenant | Configura reglas, categorías, tarifas, documentos y comisión de su empresa |
| Aliado persona natural | Prestador individual del servicio |
| Aliado empresa | Prestador que opera con representante legal |
| Empleado directo | Prestador vinculado laboralmente al tenant, sin flujo de aliado |
| Cliente persona natural | Solicita servicios |
| Cliente empresa | Solicita servicios y administra varios sitios |

## 3. Módulos funcionales (neutrales)

| Módulo | Nombre |
| --- | --- |
| M-01 | Plataforma multi-tenant (aislamiento + configuración) |
| M-02 / M-03 | Directorio de aliados / directorio de clientes |
| M-04 | Catálogo de categorías y cobertura |
| M-05..M-08 | Ciclo del servicio (solicitud, cotización, ejecución, calificación) |
| M-09 | Comunicación / notificaciones |
| M-11 | Tarifario de referencia |
| M-10 | Pagos y facturación (2º incremento) |
| M-12..M-14 | Quejas, comercialización y administración (2º incremento) |

## 4. Requerimientos funcionales

Funciones y comportamientos que debe proporcionar el sistema.

Campos: **ID · Descripción · Prioridad propuesta · Estimación propuesta (pts) ·
Dependencias**. Prioridad: Crítica / Alta / Media / Baja (ver escala en el Product Backlog).

| ID | Descripción (qué debe hacer el sistema) | Prior. | Est. | Dep. |
| --- | --- | --- | --- | --- |
| RF-01 | Registrar y administrar empresas (tenants) con aislamiento de datos entre ellas | **Crítica** | 8 | — |
| RF-02 | Permitir a cada tenant configurar sus reglas (documentos por tipo de aliado, orden del listado, categorías, tarifas) | **Crítica** | 8 | RF-01 |
| RF-03 | Autenticar usuarios y restringir su acceso a los datos de su tenant y a los permisos de su rol | **Crítica** | 8 | RF-01 |
| RF-04 | Recuperar contraseña de forma segura | Alta | 3 | RF-03 |
| RF-05 | Registrar aliados diferenciando persona natural, empresa y empleado directo, con documentos configurables por tenant | **Crítica** | 8 | RF-02 |
| RF-06 | Aprobar/rechazar registros de aliados (bandeja de verificación) | Alta | 5 | RF-05 |
| RF-07 | Permitir a los aliados declarar su zona de cobertura (por zonas, no por radio) | Alta | 5 | RF-05 |
| RF-08 | Registrar clientes persona natural y empresa, con múltiples sitios de servicio | Alta | 5 | RF-02 |
| RF-09 | Registrar reglas contextuales de un sitio y hacerlas visibles al aliado antes de agendar | Media | 5 | RF-08 |
| RF-10 | Definir categorías de servicio por tenant, con su flujo operativo, y activarlas/desactivarlas | Alta | 5 | RF-02 |
| RF-11 | Asociar aliados a las categorías que atienden | Media | 3 | RF-05, RF-10 |
| RF-12 | Crear solicitudes de servicio y presentar aliados válidos por cobertura y categoría | **Crítica** | 8 | RF-07, RF-10 |
| RF-13 | Ordenar el listado de aliados según la regla configurada por el tenant (cobertura, calificación o comisión) | Alta | 5 | RF-12 |
| RF-14 | Permitir al aliado aceptar o rechazar una solicitud asignada, sin dobles asignaciones | **Crítica** | 8 | RF-12 |
| RF-15 | Elaborar cotización con mano de obra y materiales separados | Alta | 5 | RF-14 |
| RF-16 | Alertar al aliado cuando su cotización se salga del rango de tarifas (por encima **o** por debajo) | Media | 3 | RF-15, RF-22 |
| RF-17 | Permitir al cliente aceptar, rechazar o solicitar ajuste a una cotización | Alta | 5 | RF-15 |
| RF-18 | Registrar cronológicamente eventos y observaciones durante la ejecución (log del servicio) | Media | 5 | RF-17 |
| RF-19 | Calificación bidireccional al cierre; el servicio no cierra hasta que ambas partes califiquen | Media | 5 | RF-18 |
| RF-20 | Mensajería entre las partes asociada a cada servicio, con notificaciones | Media | 8 | RF-14 |
| RF-21 | Consultar conversaciones de un servicio para atender quejas | Baja | 3 | RF-20 |
| RF-22 | Mantener tabla de tarifas de referencia por categoría (mín/típico/máx) por tenant | Alta | 5 | RF-10 |
| RF-23 | Reportar cotizaciones fuera de rango por período | Baja | 3 | RF-16 |
| RF-24 | Cobrar al cliente en línea vía operador certificado y registrar cada transacción (2º incremento) | Media | 13 | RF-17 |
| RF-25 | Liquidar al aliado descontando la comisión configurable del tenant (2º incremento) | Media | 8 | RF-24 |
| RF-26 | Registrar y gestionar quejas ligadas al servicio (2º incremento) | Baja | 5 | RF-19 |
| RF-27 | Consola de comercialización y publicación del tenant (2º incremento) | Baja | 8 | RF-01 |
| RF-28 | Métricas operativas por tenant y administración de estado de tenants (2º incremento) | Baja | 8 | RF-01 |

## 5. Requerimientos no funcionales

Condiciones de calidad, rendimiento, seguridad, disponibilidad, usabilidad y mantenibilidad
identificadas para el producto.

| ID | Descripción | Atributo de calidad | Prior. |
| --- | --- | --- | --- |
| RNF-01 | Los datos de un tenant deben estar aislados de los demás; un token de un tenant no accede a datos de otro | Seguridad / Multi-tenancy | **Crítica** |
| RNF-02 | Cada tenant configura sus reglas sin requerir código específico ni nuevo despliegue | Modificabilidad / Configurabilidad | **Crítica** |
| RNF-03 | Operaciones críticas (aceptar solicitud, aceptar cotización, calificar) resistentes a reintentos sin duplicar (idempotencia) | Fiabilidad / Resiliencia | Alta |
| RNF-04 | Trazabilidad y auditabilidad de la operación; registro inmutable de operaciones financieras (2º incremento) | Auditabilidad | Alta |
| RNF-05 | El despacho debe resolver aceptaciones concurrentes dejando exactamente una asignación válida | Fiabilidad / Concurrencia | Alta |
| RNF-06 | La responsabilidad PCI DSS recae en el operador de pagos certificado, no en la plataforma | Seguridad / Cumplimiento | Alta |
| RNF-07 | La plataforma debe soportar concurrencia de usuarios buscando aliado y comunicándose | Rendimiento / Escalabilidad | Media |
| RNF-08 | Interfaz utilizable en dispositivos móviles del cliente y del aliado | Usabilidad | Media |
| RNF-09 | Cobertura declarada por **zonas**, no por radio geográfico | Usabilidad / Modelo de datos | Alta |
| RNF-10 | KYC/documentos y tiempos/comisiones **configurables por tenant**, no fijos ni codificados | Modificabilidad / Configurabilidad | Alta |
| RNF-11 | El modelo de pagos es **centralizado**, con operador certificado (integrar antes que construir) | Seguridad / Cumplimiento | Media |

🔴 **PROPUESTA PARA LA MESA DE ARQUITECTURA:** RNF-01, RNF-02, RNF-03 y RNF-05 son
candidatos fuertes a **drivers arquitectónicos** del diseño de solución. RNF-07 es candidato a
**riesgo crítico de diseño** si se subestima la concurrencia del despacho. Confirmar en la
Mesa al iniciar el diseño de arquitectura.

## 6. Requerimientos del proyecto

Condiciones necesarias para desarrollar, gestionar, entregar o implementar el proyecto que no
constituyen funcionalidades directas del producto.

| ID | Descripción | Prior. |
| --- | --- | --- |
| PROY-01 | El proyecto se ejecuta bajo metodología **Scrum**, con sprints y ceremonias definidos por el cronograma académico vigente | **Crítica** |
| PROY-02 | El alcance de este corte se limita al **MVP** (EP-01..EP-06 del Product Backlog); pagos, facturación, quejas, comercialización y administración avanzada quedan para un **2º incremento** fuera de este corte | **Crítica** |
| PROY-03 | La documentación del proyecto se gestiona según el esquema documental vigente (ver documento de Gobierno del Equipo) | Alta |
| PROY-04 | El equipo cuenta con roles y responsabilidades definidos, incluida la responsabilidad transversal de Arquitecto (ver documento de Gobierno del Equipo) | Alta |
| PROY-05 | Toda decisión técnica costosa de revertir se discute en la Mesa de Arquitectura y se registra como ADR antes de implementarse | Alta |
| PROY-06 | Las herramientas de gestión, documentación y calidad usadas por el equipo son las definidas en la Matriz de Herramientas vigente; no se incorporan herramientas adicionales sin justificación | Media |

No se agrega trazabilidad de estos requerimientos.

## 7. Vacíos identificados (información que aún no conocemos)

- 🔴 Volumen esperado de tenants en el lanzamiento (define si multi-tenancy plena o
  aislamiento lógico basta).
- 🔴 Volumen esperado de solicitudes concurrentes (alimenta RNF-07).
- 🔴 Requisitos legales de facturación electrónica en Colombia (alimenta RF-24).

## 8. Decisiones pendientes

Existen decisiones de producto que dependen de investigación técnica (spikes) y de la
discusión en la Mesa de Arquitectura. Ninguna se cierra en este documento: las que resulten se
registran como ADR únicamente cuando la Mesa las apruebe formalmente. No se anticipa aquí
ningún número ni contenido de ADR.

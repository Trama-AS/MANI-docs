# Requisitos — índice navegable

[← 01 · Producto](README.md) · [Índice](../Home.md)

**Fuente:** [`product/SRS.md`](../../product/SRS.md) §3, §4, §6 y §7. Esta página **resume e indexa**; el enunciado completo y la prioridad oficial están en el SRS.

## Requerimientos funcionales — MVP

| ID | Requerimiento | Prioridad | Servicio dueño |
|---|---|---|---|
| RF-01 | Registrar y administrar tenants con aislamiento de datos | Crítica | Core Node |
| RF-02 | Configurar reglas por tenant (documentos, orden del listado, categorías, tarifas) | Crítica | Rules Java + Core Node |
| RF-03 | Autenticar y restringir acceso por tenant y rol, con identificación de tenant no falsificable | Crítica | Supabase Auth + Gateway + servicios |
| RF-04 | Recuperación segura de contraseña | Alta | Supabase Auth + Core Node |
| RF-05 | Registrar aliados (persona natural, empresa, empleado directo) con documentos aislados por aliado y tenant | Crítica | Core Node |
| RF-06 | Bandeja de verificación para aprobar o rechazar aliados sin exponer documentos ajenos | Alta | Core Node |
| RF-07 | Declarar zonas de cobertura del aliado | Alta | Core Node |
| RF-08 | Registrar clientes; cliente empresa con múltiples sitios | Alta | Core Node |
| RF-09 | Reglas y condiciones por sitio, visibles al aliado antes de programar; todo sitio con zona | Media | Core Node |
| RF-10 | Definir, activar y desactivar categorías de servicio | Alta | Core Node |
| RF-11 | Asociar aliados con categorías que atienden | Media | Core Node |
| RF-12 | Crear solicitudes y presentar aliados válidos por categoría y cobertura | Crítica | Core Node + Availability + Dispatch |
| RF-13 | Ordenar aliados según la regla configurada por el tenant | Alta | Rules Java |
| RF-14 | Aceptar o rechazar solicitud sin dobles asignaciones | Crítica | Dispatch .NET |
| RF-15 | Cotización separando mano de obra y materiales | Alta | Core Node |
| RF-16 | Alertar cotización fuera del rango del tarifario | Media | Rules Java |
| RF-17 | Cliente acepta, rechaza o pide ajustes de la cotización | Alta | Core Node |
| RF-18 | Registrar cronológicamente eventos y observaciones de ejecución | Media | Core Node |
| RF-19 | Calificación bidireccional; sin ambas no hay cierre | Media | Core Node |
| RF-20 | Mensajería por servicio, casi en tiempo real, con notificación si el destinatario no está conectado | Media | Core Node + Realtime + FCM/APNs |
| RF-21 | Consultar conversaciones de un servicio | Baja | Core Node |
| RF-22 | Tarifas de referencia por categoría y tenant (mínimo, típico, máximo) | Alta | Rules Java |
| RF-23 | Reportes de cotizaciones fuera de rango por período | Baja | Core Node |

## Requerimientos funcionales — segundo incremento

RF-24 cobro en línea con operador certificado · RF-25 liquidación con comisión configurable · RF-26 quejas · RF-27 consola de comercialización · RF-28 métricas operativas y estado de tenants.

No entran al MVP. Ver [Visión y alcance](vision-y-alcance.md) y la disposición de las historias legacy en el [backlog de transición](../06-backlog/transicion-v4.md).

## Requerimientos no funcionales

| ID | Tema | Prioridad |
|---|---|---|
| RNF-01 | Aislamiento estricto entre tenants, en registros y archivos, verificable por el servidor | Crítica |
| RNF-02 | Configuración por tenant sin código ni despliegue específico | Crítica |
| RNF-03 | Operaciones críticas resistentes a reintentos, sin duplicar efectos | Alta |
| RNF-04 | Trazabilidad y auditabilidad suficientes para reconstruir el ciclo | Alta |
| RNF-05 | Despacho determinista: exactamente una asignación válida por solicitud | Alta |
| RNF-06 | PCI DSS recae en el operador de pagos, no en MANI | Alta |
| RNF-07 | Concurrencia en consultas de aliados, aceptación y comunicación | Media |
| RNF-08 | Interfaz utilizable desde dispositivos móviles | Media |
| RNF-09 | Cobertura por zonas, no por radio | Alta |
| RNF-10 | Documentos KYC, tiempos y comisiones configurables por tenant | Alta |
| RNF-11 | Modelo de pagos centralizado con operador certificado | Media |

Los umbrales que verifican estos RNF están en [Atributos de calidad](../02-arquitectura/atributos-de-calidad.md).

## Restricciones

**Del producto (REST):** cobertura por catálogo jerárquico de zonas sin radio ni geolocalización en vivo (REST-01) · KYC y reglas dependientes del tenant, con documentos aislados entre aliados y tenants (REST-02) · pagos centralizados con operador certificado (REST-03) · aislamiento estricto en toda funcionalidad (REST-04) · configuración por tenant sin despliegue específico (REST-05).

**Del proyecto (PROY):** Scrum (PROY-01) · alcance académico limitado al MVP (PROY-02) · gobierno documental del equipo (PROY-03) · siete integrantes con responsabilidad técnica distribuida (PROY-04) · decisiones costosas de revertir documentadas formalmente (PROY-05) · sólo herramientas aprobadas (PROY-06) · **Java y .NET obligatorios en algún módulo de backend** (PROY-07) · **Kubernetes como orquestador** (PROY-08).

PROY-07 y PROY-08 explican por qué la arquitectura es políglota y por qué Kubernetes no es opcional: ver [ADR-0019](../../adr/ADR-0019-arquitectura-soa-poliglota.md) y [Ambientes y promoción](../03-entrega/ambientes-y-promocion.md).

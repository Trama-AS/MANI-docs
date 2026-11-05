# Atributos de calidad

[← 02 · Arquitectura](../README.md) · [Índice](../../Home.md)

**Fuente:** [`architecture/SDD.md`](../SDD.md) §7 y §8 (ISO/IEC 25010:2023) · [`architecture/SAD.md`](../SAD.md) §20.

> **Esta página es un índice, no la fuente de los umbrales.** Los umbrales de calidad del proyecto
> viven en **un solo lugar**: [`SDD.md`](../SDD.md) §7, y los escenarios con los que QA los verifica y
> sus resultados en §8. La tabla de abajo los muestra para consulta rápida. Antes esta página los
> repetía a mano y la copia se desincronizó: llegó a decir `p95 ≤ 1 s` mientras el SDD decía
> `p95 ≤ 500 ms`.
>
> Si un número de esta página difiere del SDD, está desactualizado: vale el SDD.

## Qué decide cada documento

| Pregunta | Dónde se responde |
|---|---|
| ¿Qué atributo es prioritario y por qué? | [`SAD.md`](../SAD.md) §20 |
| ¿Qué decisión de arquitectura obliga esa prioridad? | [`SAD.md`](../SAD.md) §20.1 |
| ¿Con qué umbral se verifica? | [`SDD.md`](../SDD.md) §7 |
| ¿Con qué escenario lo comprueba QA, con qué herramienta y qué resultado dio? | [`SDD.md`](../SDD.md) §8 |

## Prioridades

| Prioridad | Atributos |
|---|---|
| **P1 — crítico** | seguridad · fiabilidad · eficiencia de desempeño · mantenibilidad · flexibilidad |
| **P2 — alto** | compatibilidad · adecuación funcional · capacidad de interacción |
| **P3 — controlado** | protección / safety |

P1 condiciona decisiones estructurales y la aceptación del sistema. P2 debe cumplirse antes de
producción. P3 se verifica, pero su impacto arquitectónico es menor para el alcance actual.

## Escenarios de calidad

[`SDD.md`](../SDD.md) §8 define **45 escenarios**: uno por cada una de las 40 subcaracterísticas de
ISO/IEC 25010:2023 que prioriza §7 (`QAS-01` a `QAS-40`) y cinco transversales (`QAS-41` a `QAS-45`).
Cada uno tiene fuente, estímulo, entorno, artefacto, respuesta esperada, umbral esperado, cómo lo mide
QA y resultado. Los identificadores `QAS-01` a `QAS-09` son los de los nueve escenarios originales y no
cambian.

**Resultado** es el estado de la verificación de QA y su fecha de corte. Los estados son **Cumple**,
**Parcial**, **No cumple**, **Bloqueado** y **No medido**; su significado está en
[`SDD.md`](../SDD.md) §8.1. **No medido** y **Bloqueado** no son "cumple".

| ID | Característica | Subcaracterística | Prioridad | Umbral esperado | Resultado |
|---|---|---|:---:|---|---|
| `QAS-01` | Seguridad | Confidencialidad | P1 | 100% de accesos cross-tenant rechazados | Parcial · 2026-10-21 |
| `QAS-02` | Fiabilidad | Tolerancia a fallos | P1 | 0 operaciones confirmadas revertidas únicamente por fallo de notificación | Bloqueado · 2026-10-20 |
| `QAS-03` | Eficiencia de desempeño | Comportamiento temporal | P1 | p95 ≤ 500 ms para la consulta bajo carga nominal | Bloqueado · 2026-10-20 |
| `QAS-04` | Mantenibilidad | Capacidad para ser modificado | P1 | 0 cambios obligatorios en Flutter, Gateway, Dispatch ni en otros servicios consumidores de Rules para un cambio interno compatible | No medido · 2026-10-21 |
| `QAS-05` | Flexibilidad | Escalabilidad | P1 | Escalamiento de 2 a 6 réplicas sin cambio de código | No medido · 2026-10-21 |
| `QAS-06` | Compatibilidad | Interoperabilidad | P2 | 100% de APIs documentadas con OpenAPI y contract tests críticos aprobados antes de promoción | No cumple · 2026-10-19 |
| `QAS-07` | Adecuación funcional | Corrección funcional | P2 | 100% de escenarios críticos de ranking, tarifa, asignación y conflicto aprobados | Parcial · 2026-10-21 |
| `QAS-08` | Capacidad de interacción | Protección contra errores de usuario | P2 | 100% de acciones irreversibles definidas requieren validación o confirmación previa | No medido · 2026-10-21 |
| `QAS-09` | Protección / Safety | Protección ante fallos | P3 | 0 transacciones críticas en estado ambiguo por fallas de terceros | Bloqueado · 2026-10-20 |
| `QAS-10` | Seguridad | Integridad | P1 | 100% de operaciones críticas protegidas por validación de autorización y constraints transaccionales | Parcial · 2026-10-21 |
| `QAS-11` | Seguridad | No repudio | P2 | Pagos, aceptación y cambios críticos conservan evidencia auditable | No medido · 2026-11-04 |
| `QAS-12` | Seguridad | Responsabilidad / accountability | P1 | 100% de cambios críticos generan actor, timestamp y correlation ID | Parcial · 2026-10-21 |
| `QAS-13` | Seguridad | Autenticidad | P1 | Tokens firmados y validados en 100% de llamadas protegidas | Parcial · 2026-10-21 |
| `QAS-14` | Seguridad | Resistencia | P1 | 0 vulnerabilidades Critical/High conocidas abiertas en release de producción; rate limiting en Gateway | No cumple · 2026-11-04 |
| `QAS-15` | Fiabilidad | Ausencia de fallos | P1 | Tasa de error 5xx < 1% en ventana de 15 min bajo carga nominal | Bloqueado · 2026-10-20 |
| `QAS-16` | Fiabilidad | Disponibilidad | P1 | ≥ 99.9% mensual para APIs críticas | No medido · 2026-11-04 |
| `QAS-17` | Fiabilidad | Recuperabilidad | P1 | RTO ≤ 30 min; RPO ≤ 5 min para datos operacionales críticos | No medido · 2026-11-04 |
| `QAS-18` | Eficiencia de desempeño | Utilización de recursos | P2 | Utilización sostenida objetivo < 70% CPU por pod antes de escalar | No medido · 2026-11-04 |
| `QAS-19` | Eficiencia de desempeño | Capacidad | P1 | Soportar inicialmente 300 sesiones concurrentes y 50 req/s sostenidos sin incumplir p95 | Bloqueado · 2026-10-20 |
| `QAS-20` | Mantenibilidad | Modularidad | P1 | Ningún servicio accede directamente a tablas de otro dominio | Parcial · 2026-10-20 |
| `QAS-21` | Mantenibilidad | Reusabilidad | P2 | Contratos y adaptadores comunes reutilizables sin duplicar reglas de dominio | No medido · 2026-11-04 |
| `QAS-22` | Mantenibilidad | Analizabilidad | P1 | 100% de requests distribuidos con correlation ID; logs estructurados | Parcial · 2026-10-21 |
| `QAS-23` | Mantenibilidad | Capacidad para ser probado | P1 | Cobertura de código nuevo ≥ 80%; casos de uso críticos ≥ 90%; contract tests obligatorios | Parcial · 2026-10-21 |
| `QAS-24` | Flexibilidad | Adaptabilidad | P1 | Misma imagen desplegable en DEV/QA/PROD mediante configuración externa | No medido · 2026-11-04 |
| `QAS-25` | Flexibilidad | Instalabilidad | P1 | Despliegue automatizado por ambiente ≤ 10 min en condiciones normales | No medido · 2026-11-04 |
| `QAS-26` | Flexibilidad | Reemplazabilidad | P2 | Proveedores externos encapsulados por Adapter; cambio de proveedor sin alterar dominio | No medido · 2026-11-04 |
| `QAS-27` | Compatibilidad | Coexistencia | P2 | Servicios respetan límites configurados de CPU/memoria y no degradan otros workloads | No medido · 2026-11-04 |
| `QAS-28` | Adecuación funcional | Completitud funcional | P2 | 100% de historias críticas trazadas a casos de prueba | Parcial · 2026-10-21 |
| `QAS-29` | Adecuación funcional | Pertinencia funcional | P2 | Cada endpoint productivo corresponde a un caso de uso identificado | No medido · 2026-11-04 |
| `QAS-30` | Capacidad de interacción | Reconocibilidad | P2 | Usuario identifica acción principal de cada flujo sin documentación externa | No medido · 2026-11-04 |
| `QAS-31` | Capacidad de interacción | Aprendizabilidad | P3 | Usuarios de prueba completan flujos base con ≤ 1 asistencia | No medido · 2026-11-04 |
| `QAS-32` | Capacidad de interacción | Operabilidad | P2 | ≥ 90% de éxito en pruebas de tareas críticas | No medido · 2026-11-04 |
| `QAS-33` | Capacidad de interacción | Involucración | P3 | Consistencia visual definida por sistema de diseño | No medido · 2026-11-04 |
| `QAS-34` | Capacidad de interacción | Inclusividad | P2 | Criterios de accesibilidad definidos para web/móvil | No cumple · 2026-11-04 |
| `QAS-35` | Capacidad de interacción | Asistencia al usuario | P3 | Errores y estados vacíos incluyen orientación | No medido · 2026-11-04 |
| `QAS-36` | Capacidad de interacción | Auto-descriptividad | P2 | Formularios y estados críticos explican el siguiente paso | No medido · 2026-11-04 |
| `QAS-37` | Protección / Safety | Restricción operativa | P2 | Estados inválidos de solicitud/asignación deben rechazarse | No medido · 2026-11-04 |
| `QAS-38` | Protección / Safety | Identificación de riesgos | P3 | Operaciones sensibles identificadas en análisis de riesgo | No medido · 2026-11-04 |
| `QAS-39` | Protección / Safety | Advertencia de peligro | P3 | Mensajes explícitos antes de cancelaciones/reversiones críticas | No medido · 2026-11-04 |
| `QAS-40` | Protección / Safety | Integración segura | P2 | Integración externa requiere timeout, validación de respuesta y circuit breaker cuando aplique | No medido · 2026-11-04 |
| `QAS-41` | Transversal: Adecuación funcional y Fiabilidad | Concurrencia de asignación | P1 | Una aceptación confirmada con 200, las demás con 409, 0 dobles asignaciones y reintentos idempotentes | No medido · 2026-10-20 |
| `QAS-42` | Transversal: Fiabilidad | Idempotencia de reintentos | P1 | 0 duplicados por reintento con la misma `Idempotency-Key`; la misma clave con otro cuerpo se rechaza con 409 | Parcial · 2026-10-21 |
| `QAS-43` | Transversal: Seguridad | Confidencialidad en tránsito (TLS) | P1 | TLS 1.2+ | No medido · 2026-10-20 |
| `QAS-44` | Transversal: Flexibilidad y Fiabilidad | Reversión de despliegue | P1 | Objetivo de rollback operacional ≤ 5 min | No medido · 2026-11-04 |
| `QAS-45` | Transversal: Mantenibilidad | Quality Gate de código nuevo | P1 | 0 issues Blocker/Critical en código nuevo; duplicación de código nuevo < 3%; el pipeline falla si el Quality Gate no se cumple | Parcial · 2026-10-21 |

Una historia que toque uno de esos temas debe demostrar su escenario, no solo sus criterios
funcionales ([DoR y DoD](../../04-proceso/dor-y-dod.md)).

Cuando un escenario y un criterio de la sección §7 del SDD difieran, **prevalece el más
restrictivo** (SDD §8).

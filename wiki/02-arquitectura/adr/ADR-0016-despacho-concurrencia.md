# ADR-0016 — Despacho broadcast y exclusión concurrente

- **Estado:** Aceptado
- **Decisión de:** despacho y concurrencia
- **Relacionado con:** RF-14, RNF-03, RNF-05
- **Absorbe:** ADR-0021, «Exclusión concurrente en despacho». El archivo se retiró el 2026-10-23 al consolidar el registro de decisiones; su contenido era una lápida sin decisión propia.
- **Evidencia:** PoC-001, exclusión concurrente en la aceptación (`07-calidad/PoC/PoC-001-exclusion-concurrente-aceptacion.md`): con 50 aceptaciones simultáneas, 1 asignación, 0 dobles, un 200 y 49 respuestas 409, y el control negativo produjo 10 asignaciones en 136 ms. La cola de reintento ante caída de base de datos sigue siendo deuda técnica declarada.
- **Ratificación:** pasó de `Propuesto` a `Aceptado` el 2026-10-23, por decisión de la Scrum Master (Sara Albarracín) en la consolidación documental. **No hay sesión de Mesa de Arquitectura registrada para esta ratificación**, que ADR-0003 §2 exige para una decisión estructural: queda anotado aquí para que la Mesa lo confirme o lo revierta.

## Contexto

Una solicitud puede ser visible simultáneamente para varios aliados y el sistema debe garantizar exactamente una asignación válida.

## Alternativas

1. **Despacho secuencial.** Descartada por aumentar el tiempo hasta aceptación.
2. **Bloqueo pesimista prolongado.** Descartada por contención.
3. **Broadcast + actualización condicional atómica.** Elegida.

## Decisión

La solicitud se publica a los aliados elegibles mediante broadcast.

La primera aceptación válida se confirma mediante una actualización condicional atómica en PostgreSQL. Solo una operación puede modificar la solicitud desde estado pendiente a asignado.

Las aceptaciones posteriores reciben `409 Conflict / ya no disponible`.

Los reintentos no deben generar una segunda asignación.

## Justificación

Cumple RNF-05 y aporta idempotencia a la operación crítica.

La PoC existente demostró una única asignación bajo aceptaciones concurrentes; la evidencia se conserva fuera del ADR.

## Consecuencias

### Positivas
- Baja latencia de aceptación.
- Exclusión resuelta en la transacción.

### Negativas
- Si la base no está disponible, la aceptación no puede confirmarse.

## Condición de revisión

Revisar si se requiere cola de reintento o mayor resiliencia ante indisponibilidad de base.

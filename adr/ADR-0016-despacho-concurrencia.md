# ADR-0016 — Despacho broadcast y exclusión concurrente

- **Estado:** Propuesto
- **Decisión de:** despacho y concurrencia
- **Relacionado con:** RF-14, RNF-03, RNF-05
- **Absorbe:** ADR-0021

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

# ADR-0017 — Mensajería en tiempo real y notificaciones push

- **Estado:** Propuesto
- **Decisión de:** comunicación
- **Relacionado con:** RF-20, RF-21, ADR-0012

## Contexto

MANI necesita mensajería asociada al servicio con entrega casi en tiempo real y notificación cuando el usuario no está conectado.

## Alternativas

1. **WebSockets propios.** Descartada por infraestructura adicional.
2. **Polling.** Descartada por latencia y carga innecesaria.
3. **Supabase Realtime + FCM/APNs.** Elegida.

## Decisión

Se utiliza **Supabase Realtime** para eventos cuando el cliente está conectado y **FCM/APNs** para notificaciones push en background o desconexión.

Los mensajes y el estado relevante se persisten; Realtime transporta eventos pero no contiene reglas de negocio.

## Justificación

Aprovecha capacidades ya disponibles en Supabase y cubre RF-20 sin construir infraestructura de sockets propia.

## Consecuencias

### Positivas
- Menor infraestructura propia.
- Experiencia casi en tiempo real.

### Negativas
- Dependencia de servicios externos para entrega push/realtime.

## Condición de revisión

Revisar si volumen, latencia o requisitos de entrega garantizada superan las capacidades previstas.

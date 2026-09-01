# ADR-0017: Mecanismo de mensajería y notificaciones en tiempo real

> ⚠️ Confirmar el número real de ADR antes de commitear (revisar el último ADR en
> `/docs/adr` del repositorio para no duplicar numeración).

**Estado:** Propuesto — condicionado a la decisión de SP-01.1.1 (persistencia)
**Fecha:** 2026-09-01
**Proponente:** Jose Nicolas Alvarez Mesa (Frontend)
**Redactor:** [completar — confirmar con Sara si es rotativo o el proponente]
**Spike relacionado:** SP-05.1.1 (SCRUM-511)
**Relacionado con:** RF-20, RF-21, RNF-07, SP-01.1.1 (dependencia)

## Contexto

RF-20 exige mensajería entre cliente y aliado asociada a cada servicio, con
notificaciones de eventos relevantes. Es necesario definir el mecanismo técnico de
entrega de esos mensajes y notificaciones.

**Nota de dependencia entre spikes:** esta decisión no debería tomarse en aislamiento de
SP-01.1.1 (aislamiento/persistencia multi-tenant). Si el equipo adopta Supabase como
motor de persistencia, la mensajería en tiempo real queda resuelta en gran parte de forma
nativa; si se adopta MongoDB/NestJS, este spike debe revisitarse con una solución
independiente.

## Alternativas evaluadas

### Opción 1: WebSockets propios (ej. Socket.io sobre el backend)
Conexión persistente bidireccional construida y mantenida por el propio equipo.

- **Ventajas:** control total sobre el protocolo y la infraestructura; no depende de la
  decisión de persistencia.
- **Desventajas:** infraestructura adicional que el equipo debe construir, escalar y
  mantener desde cero; mayor esfuerzo de desarrollo.

### Opción 2: Polling
La aplicación consulta periódicamente al servidor si hay mensajes nuevos.

- **Ventajas:** simple de implementar, sin infraestructura especial.
- **Desventajas:** latencia perceptible por el usuario; carga innecesaria en el servidor
  con solicitudes frecuentes.

### Opción 3: Supabase Realtime (modo Broadcast) + Push notifications — PROPUESTA
Uso del servicio de tiempo real incluido nativamente en Supabase (servidor Elixir/Phoenix
sobre WebSockets) en su modo Broadcast, complementado con notificaciones push (FCM/APNs)
para cuando la aplicación está en segundo plano o cerrada.

- **Ventajas:** no se construye infraestructura de mensajería desde cero; el broadcast se
  publica vía HTTP desde el backend y se distribuye a los clientes suscritos por
  WebSocket ya abierto; la autorización de canal puede reutilizar RLS, el mismo mecanismo
  que resolvería el aislamiento multi-tenant (RNF-01) si se adopta Supabase en SP-01.1.1.
- **Desventajas:** acopla esta decisión a la de SP-01.1.1; si no se adopta Supabase, esta
  alternativa cae y hay que reevaluar con la Opción 1.

## Decisión propuesta

**Supabase Realtime en modo Broadcast** como mecanismo principal (mientras la app está en
primer plano), complementado con **push notifications (FCM/APNs)** para eventos cuando la
app está en background o cerrada. Esta decisión queda **condicionada** a que SP-01.1.1
resuelva adoptar Supabase como motor de persistencia.

## Trade-offs y consecuencias

- Si SP-01.1.1 no adopta Supabase, este ADR queda invalidado y debe reemplazarse por uno
  nuevo que declare `supersedes ADR-0017`, evaluando WebSockets propios como decisión
  primaria.
- El broadcast se dispara vía HTTP API desde el backend (`POST /api/broadcast`), no
  mediante webhooks — es importante no confundir ambos mecanismos en la documentación
  técnica.
- La entrega en tiempo real depende de que el cliente mantenga una conexión WebSocket
  activa; para reconexiones se recomienda usar Postgres Changes o consulta directa como
  respaldo, para no perder eventos ocurridos mientras el aliado estuvo desconectado.

## Disenso

[Completar con lo registrado en la Mesa: quién argumentó en contra y cuál fue el
argumento.]

## Quórum y asistentes

[Completar: confirmar que se alcanzó el quórum de 5 de 7 integrantes exigido.]

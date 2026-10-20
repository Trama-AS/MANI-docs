# ADR-0033 — Productor del evento `SolicitudCreada`

- **Estado:** Propuesto
- **Decisión de:** comunicación entre servicios y propiedad de datos
- **Autor:** Sara Albarracín Niño
- **Fecha:** 2026-10-20
- **Jira:** pendiente de abrir
- **Relacionado con:** ADR-0029 (comunicación asíncrona y Kafka), ADR-0030 (propiedad de esquema y frontera de datos), ADR-0012, ADR-0022, RF-12
- **Reemplaza, si se aprueba:** [ADR-0029](./ADR-0029-comunicacion-asincrona-kafka.md) §1, únicamente en la fila del evento `SolicitudCreada`

---

## Contexto

[ADR-0029](./ADR-0029-comunicacion-asincrona-kafka.md) §1 fija un único productor por evento de
negocio y asigna `SolicitudCreada` al **Core Service**, con la condición «una solicitud queda
persistida y lista para repartirse».

Esa asignación choca con la propiedad de datos que fija el resto de la línea base:

- `SAD.md` §4.2.1: «Las solicitudes pertenecen a Dispatch, no al Core. El Core aporta la
  elegibilidad por API».
- `SAD.md` §7.2: RF-12, creación y coordinación operacional de solicitudes, es de Dispatch.
- `ModeloDatos.md` §6.1 y §13: la tabla es `despacho.solicitud` y su servicio propietario es
  Dispatch Service, con **escritura exclusiva**.
- `SDD.md` §4.3.2: «crear solicitudes» es responsabilidad del Dispatch Service.

ADR-0029 §3 exige además que el evento se escriba en el *outbox* **dentro de la misma transacción**
que cambia el estado del negocio. Con la solicitud en `despacho.solicitud`, esa transacción solo
puede abrirla Dispatch: Core no escribe ese esquema. Tal como está, la regla de ADR-0029 §1 y la de
ADR-0029 §3 no pueden cumplirse a la vez.

Estado verificado el 2026-10-20, antes de proponer:

- Ningún servicio expone hoy la creación de la solicitud. La crea la función PL/pgSQL
  `crear_solicitud(...)` (`MANI-Flutter/database/migrations/006_crear_solicitud.sql:197`), que
  Flutter invoca por RPC, e inserta en `solicitud`, `solicitud_foto` y `evento_servicio`.
- El DDL real no crea los seis esquemas de `ModeloDatos.md` §6.1: todas las tablas viven en
  `public`. No existe ninguna tabla outbox.
- No hay productor, consumidor, tópico ni broker en ningún repositorio.

Es decir: la decisión se toma sobre el diseño objetivo, no sobre código existente.

## Alternativas

1. **Dejar a Core como productor y mover `solicitud` al esquema de Core.** Descartada: contradice
   `SAD.md` §4.2.1 y §7.2 y el modelo de datos vigente, y convertiría a Core en dueño del despacho,
   que es la capacidad que justifica un servicio aparte.
2. **Dejar a Core como productor leyendo `despacho.solicitud`.** Descartada: exige lectura o
   escritura cruzada de esquema ajeno, prohibida por `SDD.md` §14, `ModeloDatos.md` §13 y ADR-0030
   §2, y rompe la garantía transaccional de ADR-0029 §3.
3. **Dispatch como único productor de `SolicitudCreada`.** Elegida.

## Decisión

**El único productor de `SolicitudCreada` es el Dispatch Service, que lo escribe en
`despacho.outbox` dentro de la misma transacción que persiste la solicitud en `despacho.solicitud`.**

El resto de ADR-0029 no se altera: `AliadoAsignado` sigue siendo de Dispatch, `CotizacionAceptada`
de Core, el sobre común y el versionado no cambian, y la adopción de Kafka sigue diferida al
Sprint 5.

Core mantiene su papel en el flujo: Dispatch le consulta la elegibilidad de aliados por categoría y
zona antes de conformar el listado de candidatos (RF-12, `SAD.md` §7.3).

## Consecuencias

- La tabla `servicio.outbox` deja de necesitar la fila de `SolicitudCreada`; conserva
  `CotizacionAceptada`.
- Un solo servicio escribe y publica la solicitud, de modo que la frontera de datos de ADR-0030 y la
  garantía de publicación de ADR-0029 §3 dejan de contradecirse.
- Queda pendiente, y no lo resuelve este ADR, quién expone el endpoint de creación: hoy no existe en
  ningún servicio.

## Estado de aprobación

Propuesto. No reemplaza nada mientras la Mesa de Arquitectura no lo apruebe con el quórum de
`GOBIERNO_DEL_EQUIPO.md` §5. Hasta entonces, la fila de `SolicitudCreada` de ADR-0029 §1 sigue
siendo la referencia vigente, y ADR-0029 **no se edita** (Gobierno §5.8 y §5.9).

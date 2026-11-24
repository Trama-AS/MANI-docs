# ADR-0035 — Frontera de la asignación: Dispatch decide y Core escribe (decisión 6A)

- **Estado:** `Aceptado` · **ratificado por la Scrum Master (Sara Albarracín) el 2026-11-20**, sin sesión de Mesa de Arquitectura. ADR-0003 reserva la ratificación a la Mesa; al no haberse convocado ninguna en el Sprint 6 y con la entrega en curso, la SM ratifica para que la decisión no quede sin respaldo formal mientras el código ya la cumple. **La Mesa puede confirmarla o revertirla** cuando se reúna.
- **Decisión de:** límites entre servicios y propiedad del estado del servicio
- **Proponente:** Sara Albarracín Niño (Scrum Master), decisión 6A del 2026-10-26
- **Autor:** Santiago Hernández Barbosa
- **Fecha:** 2026-10-28
- **Jira:** [SCRUM-1403](https://maniservices.atlassian.net/browse/SCRUM-1403) (HU-M05-07), con [SCRUM-1402](https://maniservices.atlassian.net/browse/SCRUM-1402), [SCRUM-1404](https://maniservices.atlassian.net/browse/SCRUM-1404) y [SCRUM-1405](https://maniservices.atlassian.net/browse/SCRUM-1405)
- **Relacionado con:** ADR-0016 (exclusión concurrente), ADR-0022 (lógica en los servicios), ADR-0029 §1 (productor de `AliadoAsignado`), ADR-0030 (frontera de datos), ADR-0032 (identidad de servicio en base de datos), SAD §7.2 y §7.4
- **Implementación de referencia:** MANI-Node#80, MANI-.NET#16, MANI-APIGateway#41 y MANI-Flutter#76, fusionados en `develop`

---

## Contexto

El SAD dejaba abierto quién escribe el estado de la solicitud después de la asignación (pendiente P1 de §7.4). Mientras
tanto, el código tomó un camino: Dispatch .NET aceptaba con un `UPDATE solicitud` directo sobre la tabla de Core, y la
política `solicitud_aceptar_aliado` permitía también a `authenticated` escribir la fila. Eso dejaba dos escritores del
mismo estado:

- **Las reglas de Core no se aplicaban al aceptar.** Verificación del aliado, oferta propia, categoría y zona quedaban
  repartidas entre la RPC 005, Dispatch y la app.
- **La garantía de RNF-05 dependía de quién llegara.** La actualización condicional de ADR-0016 existía en dos lugares
  con predicados distintos.
- **Dispatch escribía en el dominio de otro servicio**, lo que ADR-0030 y el principio 7 del SAD §4.1 prohíben.

El 26 de octubre de 2026 la Scrum Master decidió (decisión 6A): Core es el único dueño y escritor del estado canónico
del servicio, también después de la asignación; Dispatch conserva la elegibilidad, la oferta y la decisión de quién
acepta, y entrega el resultado a Core por un contrato idempotente. Este ADR registra esa decisión con sus alternativas
para que la Mesa la ratifique.

## Alternativas

**A. Dispatch escribe la asignación directamente** (lo que había). Una sola llamada y sin dependencia en línea de
Core al aceptar. Pero mantiene dos escritores del estado, obliga a duplicar en Dispatch las reglas de Core y exige
que el rol de Dispatch tenga `UPDATE` sobre una tabla ajena.

**B. Comando síncrono e idempotente de Dispatch a Core** (preferida, decisión 6A). Dispatch comprueba al aliado y lo
que es de su dominio (los rechazos) y llama a `POST /solicitudes/{id}/asignacion`, interna, con el JWT del aliado.
Core bloquea la fila, repite el predicado y responde `200` o `409`. El aliado sabe en la misma petición si ganó.

**C. Evento asíncrono de Dispatch que Core consume.** Desacopla los servicios, pero el aliado no sabe si ganó hasta
que Core procese el evento, la exclusión concurrente queda diferida y hoy no hay Kafka en operación (ADR-0029 sigue
sin implementarse). Agrega un estado intermedio «aceptación en proceso» que la app tendría que mostrar.

Argumento en contra de B: si Core no responde, nadie puede aceptar, y la latencia de aceptar suma un salto entre
servicios. Se acepta porque aceptar sin Core no es seguro (no hay quién confirme la exclusión), porque Dispatch falla
cerrado con `503 CORE_SERVICE_UNAVAILABLE` sin dar nada por asignado, y porque el salto es por la red interna.

## Decisión

Se adopta la alternativa **B**.

1. **Core es el único que escribe `solicitud`**, desde la creación y también al asignar. La migración
   `0019_frontera_asignacion_6a.sql` de MANI-Node revoca `UPDATE` sobre `solicitud` al rol `mani_dispatch_svc` y retira
   la política `solicitud_aceptar_aliado`.
2. **El comando de asignación** es `POST /api/v1/core/solicitudes/{id}/asignacion`, interno (el Gateway lo bloquea), con
   el contrato de SAD §7.4: actor y tenant desde el JWT reenviado, cuerpo vacío, `Idempotency-Key` y `X-Correlation-ID`.
   Core bloquea la fila (`FOR UPDATE`) y repite `estado = 'PENDIENTE' AND aliado_id IS NULL` en el `UPDATE`. El `409`
   no revela al aliado ganador. Un reintento del mismo aliado responde `200` con `asignada: false` y no repite efectos.
3. **Los rechazos son de Dispatch** (`solicitud_rechazo`). Dispatch los envía a Core como `excludeAllyIds` al pedir
   elegibles, y Core no lee esa tabla. Un aliado que rechazó y luego intenta aceptar recibe `409 MANI-DSP-409R` sin que
   Dispatch llame a Core.
4. **La oferta la guarda Core**, una por aliado y solicitud (índice único `ux_notificacion_oferta_despacho`), cuando
   Dispatch se la pide con `POST /notifications`.
5. **`AliadoAsignado` lo produce Core** desde `servicio.outbox`, en la misma transacción del `UPDATE`
   (SDD §20.2 y §20.4.2). Esto reemplaza, para ese evento, la fila de ADR-0029 §1 que lo atribuía a
   Dispatch.

## Consecuencias

- La exclusión concurrente de ADR-0016 vive en un solo lugar: Core. ADR-0016 no cambia de mecanismo, cambia de dueño.
- Dispatch ya no necesita permisos de escritura sobre tablas de Core. Lo que sí necesita (leer rechazos con el contexto
  del tenant) lo da la política `solicitud_rechazo_lectura_despacho`.
- La app acepta, rechaza y lista sus ofertas por el Gateway hacia Dispatch (`/api/v1/dispatch/offers/me`, `accept`,
  `reject`); las RPC de la migración 005 quedan sin uso desde la app y se pueden retirar cuando esa versión esté en
  todos los ambientes (coordinado con TEC-18, SCRUM-1465).
- La migración `0019` borra las ofertas duplicadas antes de crear el índice único. En los ambientes con duplicados
  elimina filas de `notificacion`, así que su aplicación en QA requiere la aprobación de la Scrum Master.
- **Documentación que queda por alinear** si se aprueba:
  - ADR-0029 §1: la fila de `AliadoAsignado` (productor y tópico).
  - `ModeloDatos.md`: `despacho.asignacion` y el `CHECK` de `despacho.outbox` todavía reflejan el modelo anterior.

## Verificación

- MANI-Node#80: `npm test` con PostgreSQL 15, 1140 de 1140. Como `mani_core_svc`: 50 aliados aceptan a la vez y queda
  1 asignación, 49 respuestas `409` y 1 evento; 10 reintentos simultáneos del mismo aliado dan una sola asignación.
  Como `mani_dispatch_svc`: `UPDATE solicitud` falla con `42501`.
- MANI-.NET#16: `dotnet test`, 199 de 199. 50 aceptaciones simultáneas por HTTP contra un Core falso: 1 asignada y 49
  con `409` sin el ganador; `409R` sin llamar a Core; falla cerrada ante una respuesta inesperada de Core.
- `develop` de MANI-Node el 28-oct-2026 (`e9d5e58`): 1252 de 1252, 0 omitidas.
- La certificación en el ambiente QA depende de TEC-16 (SCRUM-1463).

## Ratificación

**Ratificado el 2026-11-20 por la Scrum Master (Sara Albarracín), sin sesión de Mesa de Arquitectura.**

ADR-0003 §2 y `GOBIERNO_DEL_EQUIPO.md` §5 reservan la ratificación de una decisión estructural a la Mesa de
Arquitectura. **No se convocó ninguna sesión en el Sprint 6** y la entrega está en curso, de modo que la alternativa
real no era ratificar en Mesa sino llegar a la sustentación con una decisión que el código ya cumple y que
formalmente nadie había aprobado.

Lo que sostiene la ratificación:

- La decisión 6A es de la propia Scrum Master, tomada el 2026-10-26, y ha regido el trabajo del sprint desde entonces.
- La implementación de referencia está **fusionada en `develop`** en MANI-Node#80, MANI-.NET#16, MANI-APIGateway#41 y
  MANI-Flutter#76, con la verificación de §Verificación en verde.
- Existe precedente propio: el 2026-10-23 la misma Scrum Master ratificó así
  [ADR-0032](ADR-0032-identidad-de-servicio-en-base-de-datos.md), y lo dejó anotado en su cabecera.

**La objeción que esta ratificación tiene en contra, dicha completa.** El README de la carpeta sostuvo hasta hoy que
la ratificación de este ADR «no la puede hacer la Scrum Master, que es la proponente del ADR». Es cierto que lo es: la
decisión 6A es suya, del 2026-10-26. Ratificar lo que uno mismo propuso concentra en una persona la propuesta y su
aprobación, y eso es exactamente lo que ADR-0003 quiere evitar al reservar la ratificación a un órgano colegiado.

Se ratifica igual, y por eso queda escrito aquí y no omitido. El motivo es que la alternativa no era una ratificación
imparcial sino **ninguna**: no hay Mesa convocada y la entrega está en curso. Entre dejar la decisión sin respaldo
formal mientras cuatro repositorios ya la implementan, y respaldarla declarando el conflicto, se elige lo segundo.
**Quién puede subsanarlo sin esperar a la Mesa:** un segundo revisor técnico que no sea la proponente —Santiago
Hernández, autor de la ficha, o Juan Sebastián Álvarez, autor de ADR-0032— dejando su visto bueno en este apartado.

**Esta ratificación es reversible.** Cuando la Mesa se reúna puede confirmarla o revertirla; si la revierte, el ADR
vuelve a `Propuesto` y queda constancia aquí de ambas decisiones, sin borrar ninguna.

Lo que la ratificación **no** resuelve: la certificación en el ambiente QA sigue dependiendo de TEC-16
([SCRUM-1463](https://maniservices.atlassian.net/browse/SCRUM-1463)), y el pendiente P1 de SAD §7.4 solo se cierra
cuando la asignación idempotente quede escrita en el SAD
([SCRUM-1704](https://maniservices.atlassian.net/browse/SCRUM-1704)).

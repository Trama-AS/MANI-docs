# Expediente para la Mesa de Arquitectura — ratificación de ADR-0030 y ADR-0016

TEC-12 (SCRUM-1459). Reúne, en un solo lugar, lo que la Mesa necesita para **confirmar o revertir**
dos decisiones que ya están implementadas en código fusionado. Cierra los hallazgos P-1 y P-2 del
[reporte de conformidad](REPORTE_CONFORMIDAD_CORE_DISPATCH.md) §12.

Este documento **no ratifica nada**: la ratificación es un acto de la Mesa. Acá está el material
para que esa sesión dure lo que debe durar.

## Qué se pide decidir

| ADR | Decide | Estado hoy |
|---|---|---|
| [ADR-0030](adr/ADR-0030-propiedad-esquema-y-frontera-de-datos.md) | Propiedad del esquema de base de datos y frontera de datos entre servicios: la frontera se cruza por HTTP y el DDL vive en Core | `Aceptado` desde el 2026-10-23, **sin sesión de Mesa** |
| [ADR-0016](adr/ADR-0016-despacho-concurrencia.md) | Despacho broadcast y exclusión concurrente: una sola asignación válida mediante actualización condicional atómica | `Aceptado` desde el 2026-10-23, **sin sesión de Mesa** |

Las dos pasaron de `Propuesto` a `Aceptado` por decisión de la Scrum Master en la consolidación
documental del 23 de octubre de 2026. **Las dos lo dicen en su propia nota de ratificación** y piden
expresamente que la Mesa lo confirme o lo revierta. Eso es lo que falta.

## La decisión real que tiene la Mesa

No es «aceptar o no aceptar en abstracto». El código fusionado ya cumple ambas decisiones, así que
la alternativa a ratificar es **revertir código que está en `develop` y en `release`**:

| Si la Mesa | Entonces |
|---|---|
| Ratifica | Se retira la nota de «sin sesión de Mesa» de los dos ADR y se cierra TEC-12. Nada cambia en código |
| Revierte ADR-0030 | Hay que rehacer la frontera de datos de Dispatch: hoy consume elegibilidad por HTTP y no tiene acceso SQL al dominio de Core |
| Revierte ADR-0016 | Hay que rehacer la aceptación atómica y revisar los permisos que dependen de ella, incluida la frontera de la decisión 6A |

## Evidencia de que el código ya los cumple

Verificado contra `origin/develop` el 27 de octubre de 2026, leyendo el código, no las historias.

### ADR-0030 — frontera por HTTP, DDL solo en Core

| Afirmación | Dónde se comprueba |
|---|---|
| Dispatch consume la elegibilidad por HTTP, nunca por SQL | `MANI-.NET`: `Infrastructure/Core/CoreAllyClient.cs` implementa `Application/Interfaces/IAllyRepository.cs`. **No existe `PostgresAllyRepository`** |
| Dispatch no escribe el estado del dominio de Core | `MANI-.NET`: los únicos `UPDATE solicitud` del repositorio están en fixtures de prueba (`tests/Mani.Dispatch.Tests/Fixtures/DispatchSeed.cs`, `GetAllyAssignmentsTests.cs`), no en código de producción |
| La frontera está aplicada en la base, no solo acordada | `MANI-Node`: `db/migrations/0019_frontera_asignacion_6a.sql` revoca `UPDATE` sobre `solicitud` al rol `mani_dispatch_svc` y retira la política `solicitud_aceptar_aliado`. Dispatch conserva `SELECT` para `assignments/me` |
| El DDL vive en Core | La serie `db/migrations/` completa está en `MANI-Node`; ADR-0030 §1 nombra a Core dueño de la serie |

### ADR-0016 — exclusión concurrente

| Afirmación | Dónde se comprueba |
|---|---|
| La asignación se decide con actualización condicional atómica | `MANI-Node`: `PgSolicitudAsignacionRepository` bloquea la fila con `FOR UPDATE` y repite el predicado `estado = 'PENDIENTE' AND aliado_id IS NULL` en el `UPDATE`, que hace de versión de la fila |
| Las aceptaciones posteriores reciben 409 | Mismo archivo: `MANI-SOL-409` si ya hay aliado, `MANI-SOL-409E` si el estado no admite asignación |
| Hay medición, no solo diseño | PoC-001 (`07-calidad/PoC/PoC-001-exclusion-concurrente-aceptacion.md`), citada en el propio ADR: 50 aceptaciones simultáneas → 1 asignación, 0 dobles, un 200 y 49 respuestas 409. El control negativo produjo 10 asignaciones en 136 ms |

## Lo que la Mesa debería corregir al ratificar

Tres cosas que aparecieron al preparar este expediente y que conviene resolver en la misma sesión.

1. **ADR-0016 no tiene autor ni revisor.** ADR-0003 pide que cada ADR «tenga autor y revisor
   distintos cuando aplique», y ese ADR no declara ninguno de los dos. ADR-0030 declara autor
   (Sara Albarracín) pero no revisor. Para una decisión estructural, conviene que el revisor sea
   alguien distinto de quien la ratificó.
2. **La cita «ADR-0003 §2» no existe.** Las notas de ratificación de ADR-0016, ADR-0022 y ADR-0030
   dicen que la sesión de Mesa la exige «ADR-0003 §2», pero ADR-0003 no tiene secciones numeradas.
   El requisito sí está en su decisión («las decisiones técnicas costosas de revertir se discuten en
   la Mesa de Arquitectura»); lo que falta es citarlo bien.
3. **El reporte de conformidad quedó desactualizado.** Sus hallazgos P-1 y P-2 describen ADR-0030 y
   ADR-0016 como `Propuesto`, estado anterior al 23 de octubre. Se corrige en este mismo cambio.

## Deuda que la ratificación no borra

ADR-0016 declara como deuda técnica la cola de reintento ante caída de la base de datos. Ratificar
la decisión no la resuelve: conviene que quede registrada como tal en la sesión, para que no se lea
como cerrada.

## Lo que falta para cerrar TEC-12

| Qué | Quién |
|---|---|
| Sesión de Mesa que confirme o revierta las dos decisiones | Mesa de Arquitectura |
| Retirar de los dos ADR la nota de «sin sesión de Mesa registrada», si se confirman | Quien registre el acta |
| Declarar autor y revisor en ADR-0016, y revisor en ADR-0030 | Mesa |
| Cierre con la subtarea QA-TEC-12 | Santiago |

Mientras la sesión no ocurra, TEC-12 **no está cumplido**: su criterio de aceptación es que las dos
decisiones se ratifiquen o que se revierta el código que ya las cumple, y ninguna de las dos cosas
la puede hacer este documento.

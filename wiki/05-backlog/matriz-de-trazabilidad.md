# Matriz de trazabilidad

[← 05 · Backlog](README.md) · [Índice](../Home.md)

| | |
|---|---|
| **Versión** | 1.0 |
| **Fecha** | 2026-11-10 |
| **Finalidad** | Seguir un ítem del backlog hasta su origen (necesidad, requisito, atributo de calidad) y hasta su destino (decisión, componente, prueba) |
| **Lo mantiene** | Nicolás León (suplente: Nicolás Álvarez), con QA para la columna de prueba |
| **Lo consumen** | QA (verifica y cierra), Product Owner (acepta) y quien audita el origen de un cambio |
| **Se actualiza** | Al cerrar cada ítem; revisar la matriz completa al cerrar cada sprint |
| **Origen** | Los ítems de [Jira](backlog-9-nov.md), el [SRS](../01-producto/SRS.md), el [SDD §8](../02-arquitectura/SDD.md) (atributos de calidad `QAS`) y los [ADR](../02-arquitectura/adr/) |
| **Destino** | La subtarea `QA-…` de cada ítem y la evidencia de [07 · Calidad](../07-calidad/README.md) |
| **Historia en Jira** | [SCRUM-1695](https://maniservices.atlassian.net/browse/SCRUM-1695) (HU-WIKI-07) |

> **Estado: parcial.** La cadena completa de un ítem es `necesidad → requisito → atributo de calidad (QAS) → ADR → componente → prueba`. Esta primera versión recoge **solo lo que está respaldado** por la descripción del ítem en Jira o por el código fusionado o en revisión; lo demás figura como *por completar* y no se infiere. Completar la matriz de las 78 filas del [backlog del 9-nov](backlog-9-nov.md) es un punto abierto del [README](README.md#puntos-abiertos).

## Cómo se lee

| Columna | Qué es | De dónde sale |
|---|---|---|
| Ítem | Clave de Jira | [Backlog del 9-nov](backlog-9-nov.md) |
| Módulo | Módulo `M-xx` del libro y su [épica](epicas-y-modulos.md) | Libro de módulos |
| Requisito | `RF-nn`, `RNF-nn` o `REST-nn` del SRS | Descripción del ítem |
| QAS | Atributo de calidad que motiva el ítem | Campo «Fuente» de la descripción |
| ADR | Decisión de arquitectura que lo gobierna | [Registro de ADR](../02-arquitectura/guia/decisiones-adr.md) |
| Prueba | Prueba automatizada o evidencia que lo verifica | PR y archivo de prueba |

## Ítems con trazabilidad respaldada

| Ítem | Módulo | Requisito | QAS | ADR | Prueba |
|---|---|---|---|---|---|
| [SCRUM-1633](https://maniservices.atlassian.net/browse/SCRUM-1633) pago tras finalizar queda retenido | M-11 | por completar | 892 C1 (QA, corte 2) | por completar | `tests/integration/pg/fondosGarantia.pg.test.js` (MANI-Node#121, fusionado) |
| [SCRUM-1651](https://maniservices.atlassian.net/browse/SCRUM-1651) pool de Core y timeouts de Dispatch | por completar | por completar | QAS-15, 41, 07, 03 y 19 | por completar | `tests/unit/db/pgPoolFactory.test.js` y `tests/unit/config/config.test.js` (MANI-Node#133) |
| [SCRUM-1653](https://maniservices.atlassian.net/browse/SCRUM-1653) idempotencia en pagos | M-11 | por completar | QAS-42 | por completar | `tests/integration/pg/pagos.pg.test.js` (MANI-Node#135) |
| [SCRUM-1656](https://maniservices.atlassian.net/browse/SCRUM-1656) `evento_servicio` inmutable | por completar | por completar | QAS-11 | por completar | `tests/integration/pg/trazabilidadEventos.pg.test.js` (MANI-Node#136) |
| [SCRUM-1657](https://maniservices.atlassian.net/browse/SCRUM-1657) actor y correlation ID | por completar | por completar | QAS-12 | por completar | `tests/integration/pg/trazabilidadEventos.pg.test.js` (MANI-Node#136) |
| [SCRUM-1659](https://maniservices.atlassian.net/browse/SCRUM-1659) política RLS de `documento_legal` | por completar | por completar | QAS-01 | por completar | `tests/integration/pg/documentoLegalAislamiento.pg.test.js` (MANI-Node#134) |
| [SCRUM-1662](https://maniservices.atlassian.net/browse/SCRUM-1662) adaptadores con falla inyectable | por completar | por completar | QAS-02 y 09 | por completar | `tests/unit/push/falibleMockPushProvider.test.js` y `tests/unit/security/falibleFileStorageService.test.js` (MANI-Node#137) |

Las pruebas de los PR en revisión pasan a ser evidencia vigente cuando el PR se fusiona.

## Regla de mantenimiento

1. Al **abrir** un ítem se registra su origen (campo «Fuente»: un QAS, un hallazgo, una propuesta o una decisión).
2. Al **fusionar** su PR se añade la prueba que lo verifica.
3. Al **cerrarlo** QA comprueba que ninguna celda quede como *por completar* sin motivo.
4. Una celda *por completar* no se rellena por deducción: se consulta al dueño del ítem o del ADR.

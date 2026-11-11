# Matriz de trazabilidad

[← 05 · Backlog](README.md) · [Índice](../Home.md)

| | |
|---|---|
| **Versión** | 1.1 |
| **Fecha** | 2026-11-10 |
| **Finalidad** | Seguir un ítem del backlog hasta su origen (necesidad, requisito, atributo de calidad) y hasta su destino (decisión, componente, prueba) |
| **Lo mantiene** | Nicolás León (suplente: Nicolás Álvarez), con QA para la columna de prueba |
| **Lo consumen** | QA (verifica y cierra), Product Owner (acepta) y quien audita el origen de un cambio |
| **Se actualiza** | Al cerrar cada ítem; revisar la matriz completa al cerrar cada sprint |
| **Origen** | Los ítems de [Jira](backlog-9-nov.md), el [SRS](../01-producto/SRS.md), el [SDD §8](../02-arquitectura/SDD.md) (atributos de calidad `QAS`) y los [ADR](../02-arquitectura/adr/) |
| **Destino** | La subtarea `QA-…` de cada ítem y la evidencia de [07 · Calidad](../07-calidad/README.md) |
| **Historia en Jira** | [SCRUM-1695](https://maniservices.atlassian.net/browse/SCRUM-1695) (HU-WIKI-07) |

> **Estado: parcial.** La cadena completa de un ítem es `necesidad → requisito → atributo de calidad (QAS) → ADR → componente → prueba`. Esta versión recoge **solo lo que está escrito** en la descripción del ítem en Jira o en el PR que lo resuelve; lo demás figura como *por completar* y no se infiere.

| Cobertura de los 78 ítems del [backlog del 9-nov](backlog-9-nov.md) | |
|---|---:|
| Con **origen** declarado (campo «Fuente» u «Origen», o definido en la propia historia) | 78 de 78 |
| Con al menos un **QAS** nombrado en la descripción | 28 |
| Con al menos un **ADR** nombrado en la descripción | 9 |
| Con **prueba o evidencia** registrada | 9 |

**Por qué faltan columnas.** Las descripciones del 9-nov son de tareas, defectos e historias de wiki, no de las historias por módulo del libro: **no traen `Mxx` ni `RF-nn`**. El módulo y el requisito se completan enlazando cada ítem con su historia de origen en el [libro de módulos](MANI_MODULOS_SERVICIOS_Y_BACKLOG_S5.xlsx); mientras eso no se haga, la matriz no los muestra en vez de inventarlos.

## Cómo se lee

| Columna | Qué es | De dónde sale |
|---|---|---|
| Ítem | Clave de Jira | [Backlog del 9-nov](backlog-9-nov.md) |
| Tipo | Historia, Tarea, Error o Epic | Jira |
| Origen | Lo que motivó el ítem: un hallazgo de QA, un informe, una decisión o una propuesta | Campo «Fuente» u «Origen» de la descripción, recortado a 110 caracteres |
| QAS | Atributo de calidad que motiva el ítem | Menciones `QAS-nn` de la descripción ([SDD §8](../02-arquitectura/SDD.md)) |
| ADR | Decisión de arquitectura que lo gobierna | Menciones `ADR-nnnn` de la descripción ([registro](../02-arquitectura/guia/decisiones-adr.md)) |
| Prueba o evidencia | Prueba automatizada o evidencia que lo verifica | PR y archivos de prueba; *por completar* hasta que el PR se fusiona |

## Matriz

| Ítem | Tipo | Origen | QAS | ADR | Prueba o evidencia |
|---|---|---|---|---|---|
| [SCRUM-1633](https://maniservices.atlassian.net/browse/SCRUM-1633) | Error | QA Sprint 5, corte 2. Relacionada con SCRUM-892 (Finalizada); se abre bug en lugar de reabrirla | — | — | `tests/integration/pg/fondosGarantia.pg.test.js` (MANI-Node#121, fusionado); re-prueba de QA en `SCRUM-1642` |
| [SCRUM-1634](https://maniservices.atlassian.net/browse/SCRUM-1634) | Error | prueba manual del flujo en MANI-QA, reportada por Santiago el 5 nov. Relacionada con SCRUM-1628 y SCRUM-1629 | — | — | por completar |
| [SCRUM-1635](https://maniservices.atlassian.net/browse/SCRUM-1635) | Error | prueba manual del flujo en MANI-QA, reportada por Santiago el 5 nov. Relacionada con SCRUM-1401 | — | — | por completar |
| [SCRUM-1636](https://maniservices.atlassian.net/browse/SCRUM-1636) | Error | prueba manual del flujo en MANI-QA, reportada por Santiago el 5 nov | — | — | por completar |
| [SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637) | Error | prueba manual del flujo en MANI-QA, reportada por Santiago el 5 nov | — | ADR-0018 | por completar |
| [SCRUM-1638](https://maniservices.atlassian.net/browse/SCRUM-1638) | Tarea | traspaso Camila §3b / informe DevOps §3.1 | — | — | por completar |
| [SCRUM-1639](https://maniservices.atlassian.net/browse/SCRUM-1639) | Tarea | traspaso Camila §3b | — | — | por completar |
| [SCRUM-1640](https://maniservices.atlassian.net/browse/SCRUM-1640) | Tarea | informe DevOps §3.3 | — | — | por completar |
| [SCRUM-1641](https://maniservices.atlassian.net/browse/SCRUM-1641) | Tarea | traspaso Camila §3b | — | — | por completar |
| [SCRUM-1642](https://maniservices.atlassian.net/browse/SCRUM-1642) | Tarea | mejoras de producto | — | — | por completar |
| [SCRUM-1643](https://maniservices.atlassian.net/browse/SCRUM-1643) | Historia | mejoras de producto §2… | — | — | `test/core/network/gateway_exception_codigo_test.dart` y `test/features/services/requests/data/errores_por_codigo_test.dart` (MANI-Flutter#132) |
| [SCRUM-1644](https://maniservices.atlassian.net/browse/SCRUM-1644) | Historia | mejoras de producto §1; ideas Sprint 6 de Nicolás Álvarez… | — | ADR-0027 | por completar |
| [SCRUM-1645](https://maniservices.atlassian.net/browse/SCRUM-1645) | Historia | propuesta UI/UX §4 | — | — | por completar |
| [SCRUM-1646](https://maniservices.atlassian.net/browse/SCRUM-1646) | Historia | propuesta UI/UX §3.1 y 3.4 | — | — | por completar |
| [SCRUM-1647](https://maniservices.atlassian.net/browse/SCRUM-1647) | Historia | propuesta UI/UX §3.5 y 3.6 | — | — | por completar |
| [SCRUM-1648](https://maniservices.atlassian.net/browse/SCRUM-1648) | Tarea | QAS-33… | QAS-33 | — | por completar |
| [SCRUM-1649](https://maniservices.atlassian.net/browse/SCRUM-1649) | Tarea | QAS-24… | QAS-24 | — | por completar |
| [SCRUM-1650](https://maniservices.atlassian.net/browse/SCRUM-1650) | Tarea | QAS-39… | QAS-39 | — | por completar |
| [SCRUM-1651](https://maniservices.atlassian.net/browse/SCRUM-1651) | Tarea | análisis de calidad §4 punto 1 (QAS-15, 41, 07, 03, 19)… | QAS-15 | — | `tests/unit/db/pgPoolFactory.test.js` y `tests/unit/config/config.test.js` (MANI-Node#133) |
| [SCRUM-1652](https://maniservices.atlassian.net/browse/SCRUM-1652) | Tarea | QAS-03 | QAS-03 | — | por completar |
| [SCRUM-1653](https://maniservices.atlassian.net/browse/SCRUM-1653) | Tarea | QAS-42 | QAS-42 | — | `tests/integration/pg/pagos.pg.test.js` y `tests/unit/useCases/payments/paymentUseCases.test.js` (MANI-Node#135) |
| [SCRUM-1654](https://maniservices.atlassian.net/browse/SCRUM-1654) | Tarea | QAS-37 | QAS-37 | — | por completar |
| [SCRUM-1655](https://maniservices.atlassian.net/browse/SCRUM-1655) | Tarea | QAS-14 | QAS-14 | — | por completar |
| [SCRUM-1656](https://maniservices.atlassian.net/browse/SCRUM-1656) | Tarea | QAS-11 | QAS-11 | — | `tests/integration/pg/trazabilidadEventos.pg.test.js` (MANI-Node#136) |
| [SCRUM-1657](https://maniservices.atlassian.net/browse/SCRUM-1657) | Tarea | QAS-12 | QAS-12 | — | `tests/integration/pg/trazabilidadEventos.pg.test.js` y `tests/unit/infrastructure/withTenantContext.test.js` (MANI-Node#136) |
| [SCRUM-1658](https://maniservices.atlassian.net/browse/SCRUM-1658) | Tarea | QAS-22 | QAS-22 | — | por completar |
| [SCRUM-1659](https://maniservices.atlassian.net/browse/SCRUM-1659) | Tarea | QAS-01 | QAS-01 | — | `tests/integration/pg/documentoLegalAislamiento.pg.test.js` (MANI-Node#134) |
| [SCRUM-1660](https://maniservices.atlassian.net/browse/SCRUM-1660) | Tarea | QAS-20 | QAS-20 | — | por completar |
| [SCRUM-1661](https://maniservices.atlassian.net/browse/SCRUM-1661) | Tarea | QAS-06 y 23 | QAS-06 | — | por completar |
| [SCRUM-1662](https://maniservices.atlassian.net/browse/SCRUM-1662) | Tarea | QAS-02 y 09 | QAS-02 | — | `tests/unit/push/falibleMockPushProvider.test.js` y `tests/unit/security/falibleFileStorageService.test.js` (MANI-Node#137) |
| [SCRUM-1663](https://maniservices.atlassian.net/browse/SCRUM-1663) | Tarea | QAS-40 | QAS-40 | — | por completar |
| [SCRUM-1664](https://maniservices.atlassian.net/browse/SCRUM-1664) | Tarea | QAS-10 | QAS-10 | — | por completar |
| [SCRUM-1665](https://maniservices.atlassian.net/browse/SCRUM-1665) | Historia | informe DevOps §4.1, QAS-43 | QAS-43 | — | por completar |
| [SCRUM-1666](https://maniservices.atlassian.net/browse/SCRUM-1666) | Historia | informe DevOps §4.5, QAS-17 | QAS-17 | — | por completar |
| [SCRUM-1667](https://maniservices.atlassian.net/browse/SCRUM-1667) | Tarea | análisis de monitoreo #1 | — | — | por completar |
| [SCRUM-1668](https://maniservices.atlassian.net/browse/SCRUM-1668) | Tarea | análisis de monitoreo #2, QAS-16 | QAS-16 | — | por completar |
| [SCRUM-1669](https://maniservices.atlassian.net/browse/SCRUM-1669) | Historia | análisis de monitoreo #3 y #4 | — | ADR-0006 | por completar |
| [SCRUM-1670](https://maniservices.atlassian.net/browse/SCRUM-1670) | Tarea | análisis de monitoreo #5… | — | — | por completar |
| [SCRUM-1671](https://maniservices.atlassian.net/browse/SCRUM-1671) | Tarea | análisis de monitoreo #6, 7 y 8 | — | — | por completar |
| [SCRUM-1672](https://maniservices.atlassian.net/browse/SCRUM-1672) | Tarea | QAS-27 y 18 | QAS-27 | — | por completar |
| [SCRUM-1673](https://maniservices.atlassian.net/browse/SCRUM-1673) | Tarea | análisis de monitoreo #11… | — | — | por completar |
| [SCRUM-1674](https://maniservices.atlassian.net/browse/SCRUM-1674) | Tarea | informe DevOps §4.2, QAS-25 | QAS-25 | — | por completar |
| [SCRUM-1675](https://maniservices.atlassian.net/browse/SCRUM-1675) | Tarea | QAS-44 | QAS-44 | — | por completar |
| [SCRUM-1676](https://maniservices.atlassian.net/browse/SCRUM-1676) | Historia | análisis de monitoreo #9 y #10 | — | ADR-0006 | por completar |
| [SCRUM-1677](https://maniservices.atlassian.net/browse/SCRUM-1677) | Epic | informe DevOps §4.4 a 4.6 | — | — | por completar |
| [SCRUM-1678](https://maniservices.atlassian.net/browse/SCRUM-1678) | Tarea | análisis de calidad §1 | — | — | por completar |
| [SCRUM-1679](https://maniservices.atlassian.net/browse/SCRUM-1679) | Tarea | análisis de calidad §4 | — | — | por completar |
| [SCRUM-1680](https://maniservices.atlassian.net/browse/SCRUM-1680) | Tarea | análisis de calidad §2 (grupo G1) | QAS-13, QAS-34 | — | por completar |
| [SCRUM-1681](https://maniservices.atlassian.net/browse/SCRUM-1681) | Tarea | QAS-45 | QAS-45 | — | por completar |
| [SCRUM-1682](https://maniservices.atlassian.net/browse/SCRUM-1682) | Tarea | análisis de calidad §3.8 | — | — | por completar |
| [SCRUM-1683](https://maniservices.atlassian.net/browse/SCRUM-1683) | Tarea | QAS-07 y 41 | QAS-07 | — | por completar |
| [SCRUM-1684](https://maniservices.atlassian.net/browse/SCRUM-1684) | Tarea | análisis de calidad §4 a 6 | — | — | por completar |
| [SCRUM-1685](https://maniservices.atlassian.net/browse/SCRUM-1685) | Tarea | análisis de calidad §4 | — | — | por completar |
| [SCRUM-1686](https://maniservices.atlassian.net/browse/SCRUM-1686) | Tarea | análisis de monitoreo #12; traspaso §8 | — | — | por completar |
| [SCRUM-1687](https://maniservices.atlassian.net/browse/SCRUM-1687) | Tarea | traspaso §8 | — | — | por completar |
| [SCRUM-1688](https://maniservices.atlassian.net/browse/SCRUM-1688) | Tarea | contradicción entre el informe de DevOps y la revisión de Camila | — | — | por completar |
| [SCRUM-1689](https://maniservices.atlassian.net/browse/SCRUM-1689) | Historia | Historia de orden de la wiki (HU-WIKI), definida en la propia historia | — | — | por completar |
| [SCRUM-1690](https://maniservices.atlassian.net/browse/SCRUM-1690) | Historia | Historia de orden de la wiki (HU-WIKI), definida en la propia historia | QAS-01, QAS-45 | ADR-0006 | por completar |
| [SCRUM-1691](https://maniservices.atlassian.net/browse/SCRUM-1691) | Historia | Historia de orden de la wiki (HU-WIKI), definida en la propia historia | — | — | por completar |
| [SCRUM-1692](https://maniservices.atlassian.net/browse/SCRUM-1692) | Historia | Historia de orden de la wiki (HU-WIKI), definida en la propia historia | — | — | por completar |
| [SCRUM-1693](https://maniservices.atlassian.net/browse/SCRUM-1693) | Historia | Historia de orden de la wiki (HU-WIKI), definida en la propia historia | — | ADR-0030 | por completar |
| [SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694) | Historia | Historia de orden de la wiki (HU-WIKI), definida en la propia historia | — | — | por completar |
| [SCRUM-1695](https://maniservices.atlassian.net/browse/SCRUM-1695) | Historia | Historia de orden de la wiki (HU-WIKI), definida en la propia historia | — | — | Revisión de MANI-docs#75 y búsqueda de secretos de la carpeta |
| [SCRUM-1696](https://maniservices.atlassian.net/browse/SCRUM-1696) | Historia | Historia de validación (HU-VAL-01), definida en la propia historia | QAS-17 | ADR-0029 | por completar |
| [SCRUM-1697](https://maniservices.atlassian.net/browse/SCRUM-1697) | Tarea | idea 1 de Nicolás Álvarez… | — | — | por completar |
| [SCRUM-1698](https://maniservices.atlassian.net/browse/SCRUM-1698) | Tarea | apartado 6 del documento de Nicolás; SCRUM-1636 | — | — | por completar |
| [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699) | Tarea | idea 3 de Nicolás, SCRUM-1383… | — | — | por completar |
| [SCRUM-1700](https://maniservices.atlassian.net/browse/SCRUM-1700) | Tarea | SCRUM-1637 | — | ADR-0018 | por completar |
| [SCRUM-1701](https://maniservices.atlassian.net/browse/SCRUM-1701) | Tarea | documentación Sprint 6 | — | — | por completar |
| [SCRUM-1702](https://maniservices.atlassian.net/browse/SCRUM-1702) | Tarea | documentación Sprint 6 | — | — | por completar |
| [SCRUM-1703](https://maniservices.atlassian.net/browse/SCRUM-1703) | Tarea | documentación Sprint 6 | — | — | por completar |
| [SCRUM-1704](https://maniservices.atlassian.net/browse/SCRUM-1704) | Tarea | SAD §7.4 | — | — | por completar |
| [SCRUM-1705](https://maniservices.atlassian.net/browse/SCRUM-1705) | Tarea | documentación Sprint 6 | — | — | por completar |
| [SCRUM-1706](https://maniservices.atlassian.net/browse/SCRUM-1706) | Tarea | apartado 5 del documento de Nicolás | — | — | por completar |
| [SCRUM-1707](https://maniservices.atlassian.net/browse/SCRUM-1707) | Tarea | Tarea de gestión de la Scrum Master (objetivo propio) | — | — | por completar |
| [SCRUM-1708](https://maniservices.atlassian.net/browse/SCRUM-1708) | Tarea | Tarea de gestión de la Scrum Master (objetivo propio) | — | — | por completar |
| [SCRUM-1709](https://maniservices.atlassian.net/browse/SCRUM-1709) | Tarea | Tarea de gestión de la Scrum Master (objetivo propio) | — | — | por completar |
| [SCRUM-1710](https://maniservices.atlassian.net/browse/SCRUM-1710) | Tarea | mejoras de producto §1; parte que quedaba «por definir» en SCRUM-1644… | — | ADR-0027 | por completar |

Las pruebas de los PR en revisión pasan a ser evidencia vigente cuando el PR se fusiona.

## Regla de mantenimiento

1. Al **abrir** un ítem se registra su origen (campo «Fuente»: un QAS, un hallazgo, una propuesta o una decisión).
2. Al **fusionar** su PR se añade la prueba que lo verifica.
3. Al **cerrarlo** QA comprueba que ninguna celda quede como *por completar* sin motivo.
4. Una celda *por completar* no se rellena por deducción: se consulta al dueño del ítem o del ADR.

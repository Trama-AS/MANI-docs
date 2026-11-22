# Histórico del backlog por versión

[← 05 · Backlog](README.md) · [Índice](../Home.md)

| | |
|---|---|
| **Versión** | 1.0 |
| **Fecha** | 2026-11-10 |
| **Finalidad** | Dejar a la vista qué versión del backlog rige y cómo llegó a serlo, sin tener que leer el historial de Git |
| **Lo mantiene** | Nicolás León (suplente: Nicolás Álvarez) |
| **Lo consumen** | Quien necesita saber qué versión de un ítem o de una decisión estaba vigente en una fecha |
| **Se actualiza** | Al publicar una versión nueva de `BACKLOG_MANI.md` |
| **Origen** | La cabecera de [`BACKLOG_MANI.md`](BACKLOG_MANI.md) y el historial de Git de ese archivo |
| **Destino** | La cabecera de la versión siguiente |
| **Historia en Jira** | [SCRUM-1695](https://maniservices.atlassian.net/browse/SCRUM-1695) (HU-WIKI-07) |

## Qué rige hoy

**V5** ([`BACKLOG_MANI.md`](BACKLOG_MANI.md)), cierre del Sprint 4 y objetivo del Sprint 5. Fecha de la versión: 2026-10-20; versión anterior: 2026-10-03, actualizada el 2026-10-06 por PO-02 y ADR-0022. La V5 **reemplaza** a las versiones anteriores y al inventario de transición: no hay otra fuente del backlog.

Sobre la V5 hay dos capas posteriores que no cambiaron su número:

| Capa | Qué es | Dónde |
|---|---|---|
| Alineación con el tablero del Sprint 5 | Lo que el Planning del 25-oct comprometió en Jira y no figuraba en la V5 | [`BACKLOG_MANI.md`](BACKLOG_MANI.md) §0.3 |
| Backlog del 9-nov | 78 ítems del Sprint 6 (SCRUM-1633 a 1710) | [`backlog-9-nov.md`](backlog-9-nov.md) |

## Cambios del documento (Git)

Los últimos cambios de `BACKLOG_MANI.md`, del más reciente al más antiguo:

| Fecha | Commit | Cambio |
|---|---|---|
| 2026-10-28 | `0c9c55e` | [SCRUM-1469] Alinea el backlog V5 y el libro con el Sprint 5 de Jira (#64) |
| 2026-10-27 | `37db9dc` | docs: unifica el objetivo del Sprint 5, registra el incremento no entregado y retira el CSV de importacion |
| 2026-10-24 | `938607e` | docs: RF-37 para el rastreo en vivo y la division del Core como prerrequisito |
| 2026-10-23 | `a3411a3` | docs: consolida el registro de ADR en 25 decisiones vigentes y enmienda la regla de retiro |
| 2026-10-22 | `cf06abc` | docs: mueve calidad a la wiki, saca las entregas, renumera y cierra el backlog en tres archivos |

## Versiones anteriores

Las versiones anteriores a la V5 **no están en este repositorio como documentos**: la V5 las absorbió y las referencias a ellas viven en las secciones históricas de `BACKLOG_MANI.md` (§3 y §4, registro del Sprint 3; §10, transición V4). Para consultar el contenido exacto de una versión anterior hay que usar el historial de Git de ese archivo o los archivos de trabajo de quien las redactó.

> **Pendiente de la HU-WIKI-07:** registrar la V1 a la V4 con su fecha y su alcance. El repositorio no guarda su número ni su fecha: hay que reconstruirlos con quien las redactó. Queda como punto abierto del [README](README.md#puntos-abiertos).

## Cómo se versiona de aquí en adelante

1. Un cambio de contenido del backlog sube la versión en la cabecera de `BACKLOG_MANI.md` y añade una fila a este histórico.
2. Un cambio solo de forma (enlaces, erratas) no sube la versión.
3. Lo obsoleto se **marca, no se borra** (regla de [Jira y trazabilidad](../04-proceso/jira-y-trazabilidad.md): no borrar ítems antiguos).

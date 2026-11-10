# Épicas y módulos

[← 05 · Backlog](README.md) · [Índice](../Home.md)

| | |
|---|---|
| **Versión** | 1.0 |
| **Fecha** | 2026-11-10 |
| **Finalidad** | Mostrar cómo se agrupa el trabajo: épicas de Jira (EP-xx) y módulos del libro (M-01 a M-13), y quién es dueño de cada módulo |
| **Lo mantiene** | Nicolás León (suplente: Nicolás Álvarez) |
| **Lo consumen** | Product Owner, Scrum Master y quien busca de qué módulo o épica es un ítem |
| **Se actualiza** | Al cambiar la estructura de módulos o el reparto del sprint |
| **Origen** | [`BACKLOG_MANI.md`](BACKLOG_MANI.md) §1, el libro [`MANI_MODULOS_SERVICIOS_Y_BACKLOG_S5.xlsx`](MANI_MODULOS_SERVICIOS_Y_BACKLOG_S5.xlsx) y los padres de los ítems de Jira |
| **Destino** | La columna de módulo de la [matriz de trazabilidad](matriz-de-trazabilidad.md) |
| **Historia en Jira** | [SCRUM-1695](https://maniservices.atlassian.net/browse/SCRUM-1695) (HU-WIKI-07) |

Hay **dos clasificaciones** del mismo trabajo y no coinciden una a una. Las épicas son la agrupación de Jira; los módulos son la agrupación del libro, y el reparto de responsables del sprint se hizo por módulo.

## Épicas de Jira

Fuente: `BACKLOG_MANI.md` §1 (versión V5).

| Épica | Clave | Nombre | Historias |
|---|---|---|---|
| `EP-01` | `SCRUM-441` | Plataforma multi-tenant | transversal |
| `EP-02` | `SCRUM-442` | Directorio de actores | 11 |
| `EP-03` | `SCRUM-443` | Catálogo y cobertura | 3 |
| `EP-04A` | `SCRUM-444` | Ciclo del servicio: solicitud y asignación | 5 |
| `EP-04B` | `SCRUM-445` | Ciclo del servicio: cotización | 3 |
| `EP-04C` | `SCRUM-446` | Ciclo del servicio: ejecución y trazabilidad | 6 |
| `EP-04D` | `SCRUM-447` | Ciclo del servicio: calificación y cierre | 7 |
| `EP-05` | `SCRUM-448` | Comunicación | 4 |
| `EP-06` | `SCRUM-449` | Tarifario | 3 |
| `EP-07` | `SCRUM-450` | Pagos y facturación | 7 |
| `EP-08` | `SCRUM-451` | Operación y comercialización | 7 |
| `EP-09` | `SCRUM-452` | Gestión y configuración del proyecto | transversal |
| `EP-10` | `SCRUM-453` | Documentación de arquitectura y entregables académicos | transversal |

Además, en el tablero aparece `EP-11` (`SCRUM-1363`, «Usuario, sesión y shell de aplicación»), que no figura en la V5 y es el padre de historias como `SCRUM-1378` (recuperación de contraseña). **Discrepancia a registrar** en la [HU-VAL-01](https://maniservices.atlassian.net/browse/SCRUM-1696): la tabla de §1 no la incluye.

## Módulos del libro

Hojas `M01` a `M13` del libro de módulos (los nombres de las hojas están truncados a 31 caracteres por el formato; el nombre completo está en la hoja `01 Indice modulos`). Reparto de responsables del Sprint 5, tomado del [README](README.md) de esta carpeta:

| Módulo | Nombre (como aparece en la hoja) | Dueño en el Sprint 5 |
|---|---|---|
| M-01 | Plataforma multi-tenant y a… | Daniel Ávila |
| M-02 | Usuario (identidad, registr… | Daniel Ávila |
| M-03 | Directorio, KYC y cobertura | Camila Beltrán |
| M-04 | Catálogo, zonas y barrios | Sara Albarracín |
| M-05 | Solicitud y asignación | Santiago Hernández |
| M-06 | Cotización | José Nicolás Álvarez |
| M-07 | Ejecución y trazabilidad | José Nicolás Álvarez |
| M-08 | Calificación, cancelación y… | Juan Sebastián Álvarez |
| M-09 | Comunicación y notificacion… | Nicolás León |
| M-10 | Tarifario de referencia y r… | Juan Sebastián Álvarez |
| M-11 | Pagos y facturación (2.º inc… | Nicolás León |
| M-12 | Operación, quejas y comerci… | Juan Sebastián Álvarez |
| M-13 | Shell de aplicación, navega… | José Nicolás Álvarez |

El reparto es el del Sprint 5. Para el Sprint 6 la asignación sale de [Jira](backlog-9-nov.md), que manda.

## Servicios

El libro también describe los tres servicios de negocio (hojas `S01 Core`, `S02 Rules`, `S03 Dispatch`) y la matriz módulo × servicio (hoja `03`). Los 13 módulos listan a Core entre sus servicios.

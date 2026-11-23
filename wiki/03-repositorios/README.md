# 03 · Repositorios

[← Índice de la wiki](../Home.md)

Esta carpeta responde a **dónde vive cada cosa y cómo entra un cambio**: qué repositorio tiene qué responsabilidad, cómo se llama de verdad en GitHub, por qué ramas pasa un cambio hasta producción, qué protege cada rama y cómo se etiqueta una versión.

> **Regla que manda.** Ningún cambio entra a una rama compartida sin PR. En los repositorios de código, el PR va a `develop` y llega a `main` solo por la promoción `develop` → `release` → `main`. **Nunca se abre un PR de una rama de trabajo directo a `main`.**

## Ficha de la carpeta

| Campo | Valor |
|---|---|
| **Propósito** | Que cualquiera sepa en qué repositorio va un cambio, por dónde entra y cómo se rastrea hasta Jira y hasta la versión que llega a producción. |
| **Responsable** | Juan Sebastián Álvarez |
| **Suplente** | Por confirmar con la SM |
| **Quién la consume** | Desarrollo (los seis repositorios), DevOps, QA y quien entra nuevo al equipo |
| **Cada cuánto se actualiza** | Cuando se crea, renombra o archiva un repositorio; cuando cambian las ramas, los *rulesets* o CODEOWNERS; en cada versión etiquetada |
| **Versión y fecha** | 2.0 · 2026-11-23 ([SCRUM-1693](https://maniservices.atlassian.net/browse/SCRUM-1693), HU-WIKI-05) |
| **Barrido de secretos** | 2026-11-23, sobre los cinco documentos de la carpeta: sin JWT (`eyJ…`), llaves de Supabase (`sb_…`), llaves de AWS, bloques de llave privada ni asignaciones `password=`. Las IP privadas de los ambientes no son secretos y ya están en [`08-infraestructura`](../08-infraestructura/README.md). |

## Orden de lectura

| # | Documento | Para qué sirve | Mantiene | Consume | Se actualiza |
|---|---|---|---|---|---|
| 1 | [Multi-repo](multirepo.md) | Mapa de los 6 repositorios de GitHub: responsabilidad, nombre en ADR-0028 y estado de su README | Responsable de la carpeta | Todo el equipo | Cuando cambia el inventario de repositorios |
| 2 | [Ramas, flujo y protección](ramas-flujo-y-proteccion.md) | Flujo rama → PR a `develop` → revisión → QA → `release` → `main`; convenciones de commits y etiquetas; *rulesets* y CODEOWNERS; serie única de migraciones (ADR-0030); ramas y etiquetas de respaldo intocables | Responsable de la carpeta, con DevOps | Desarrollo, DevOps, QA | Cuando cambian *rulesets*, CODEOWNERS o el modelo de ramas |
| 3 | [Versionado](versionado.md) | SemVer de servicios, API, base de datos y releases; cuándo se etiqueta y quién lo hace | Responsable de la carpeta; la fuente es el SDD §12 | Desarrollo, DevOps | En cada versión etiquetada |
| 4 | [Estructura de MANI-Docs](estructura-de-mani-docs.md) | Árbol real de este repositorio y dónde poner cada documento | Responsable de la carpeta | Quien escribe documentación | Cuando cambia el árbol de `wiki/` |

## Trazabilidad

Un cambio se sigue así: **historia en Jira → rama con su clave → commits con `[SCRUM-<id>]` → PR a `develop` con la clave en el título → checks requeridos en verde → fusión → etiqueta `vX.Y.Z` → imagen promovida**. Las páginas que hacen cumplir cada tramo:

| Tramo | Dónde está la regla |
|---|---|
| Necesidad → requisito → atributo de calidad | [`01-producto`](../01-producto/README.md) y el [SDD §8](../02-arquitectura/SDD.md) |
| Atributo → ADR → componente | [`02-arquitectura`](../02-arquitectura/README.md); para repositorios: [ADR-0004](../02-arquitectura/adr/ADR-0004-cicd-multirepo-ambientes.md), [ADR-0028](../02-arquitectura/adr/ADR-0028-nombres-repositorios-y-ambientes.md) y [ADR-0030](../02-arquitectura/adr/ADR-0030-propiedad-esquema-y-frontera-de-datos.md) |
| Componente → repositorio → rama → PR | Esta carpeta y [`04-proceso`](../04-proceso/README.md) ([Git: ramas y commits](../04-proceso/git-ramas-y-commits.md), [Pull requests](../04-proceso/pull-requests.md)) |
| PR → prueba | [`07-calidad`](../07-calidad/README.md) |
| Versión → ambiente | [`08-infraestructura`](../08-infraestructura/README.md) y [Ambientes y promoción](../04-proceso/ambientes-y-promocion.md) |

## Discrepancias encontradas y su estado

| # | Discrepancia | Estado |
|---|---|---|
| 1 | Los nombres de GitHub (`MANI-Node`, `MANI-Flutter`, `MANI-.NET`, `MANI-Java`, `MANI-APIGateway`, `MANI-docs`) no son los de [ADR-0028](../02-arquitectura/adr/ADR-0028-nombres-repositorios-y-ambientes.md) (`MANI-Core-Service`, `MANI-Frontend`…), que declara que no existe otro nombre válido. | **Enlazada.** La tabla de equivalencias está en [Multi-repo](multirepo.md#mapa-de-los-6-repositorios). Renombrar en GitHub o enmendar ADR-0028 es decisión de la Mesa de Arquitectura. |
| 2 | Los repositorios de código no tienen protección clásica de rama; la protección es un *ruleset* que exige dos checks. No exige revisión aprobada ni bloquea el push directo. | **Documentada** en [Ramas, flujo y protección](ramas-flujo-y-proteccion.md#protección-de-ramas). Políticas §6.2 ya dice que la regla obliga aunque GitHub no la haga cumplir. |
| 3 | La rama `respaldo-develop-local` que pide la HU no aparece en ningún remoto ni clon revisado el 2026-11-23. Los respaldos que sí existen son etiquetas `respaldo/*`. | **Pendiente:** la SM confirma dónde vive. La regla de no tocarla ya está escrita ([Ramas de respaldo](ramas-flujo-y-proteccion.md#ramas-y-etiquetas-de-respaldo)). |
| 4 | `MANI-docs` solo tiene `main`; la HU pide que los cambios de wiki entren por PR a `develop`. | **Documentada.** Los PR de documentación van a `main` (así entraron #88 a #93). Crear `develop` en MANI-docs es decisión del equipo. |
| 5 | Ningún README de los repositorios de código explica cómo se despliega a QA o PROD; Java y Gateway no dicen cómo correr sus pruebas. | **Pendiente**, detalle por repositorio en [Multi-repo](multirepo.md#estado-de-los-readme). |
| 6 | Las páginas de esta carpeta enlazaban su índice como «04 · Repositorios». | **Corregida** en esta versión: la carpeta es la 03. |

## Qué falta para cerrar HU-WIKI-05

- Que otro responsable de carpeta revise y apruebe este README (criterio común de las 8 HU de wiki).
- Confirmar con la SM la suplencia de la carpeta y la ubicación de `respaldo-develop-local` (discrepancia 3).
- Completar los README de los repositorios con pruebas y despliegue (discrepancia 5).

## Historial

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.0 | 2026-10-22 | Índice de tres páginas | — |
| 2.0 | 2026-11-23 | Ficha, orden de lectura, trazabilidad, discrepancias y página nueva de ramas, flujo y protección (SCRUM-1693) | Juan Sebastián Álvarez |

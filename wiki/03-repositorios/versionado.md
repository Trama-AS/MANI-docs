# Versionado

[← 03 · Repositorios](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SDD.md`](../02-arquitectura/SDD.md) §12 · [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md) §5.1 y §10.

| Campo | Valor |
|---|---|
| **Finalidad** | Resumen operativo de cómo se versionan servicios, API, base de datos y releases, y cuándo y quién etiqueta |
| **Mantiene** | Responsable de la carpeta 03; la fuente es el SDD §12 |
| **Consume** | Desarrollo, DevOps |
| **Cada cuánto se actualiza** | En cada versión etiquetada y cuando cambia el SDD §12 |
| **Versión y fecha** | 1.1 · 2026-11-23 ([SCRUM-1693](https://maniservices.atlassian.net/browse/SCRUM-1693)) |
| **Origen y destino** | SDD §12 y Políticas §5.1 → esta página → etiquetas `vX.Y.Z` y releases de GitHub |

El detalle completo está en SDD §12. Resumen operativo:

| Qué | Cómo se versiona |
|---|---|
| **Servicios** | SemVer por repositorio (SDD §12.1); la imagen lleva además `dev-<sha>`, `qa-<sha>` o la versión semántica |
| **API** | Contratos versionados; es umbral de mantenibilidad (SDD §7.5). Reglas en SDD §12.2 |
| **Base de datos** | Migraciones con estrategia de compatibilidad y rollback (SDD §12.3, §19.5) |
| **Releases** | Etiquetado semántico sobre `main`, que representa la versión productiva (SDD §12.4, Políticas §5.1) |
| **Rollback** | SDD §12.5 |

Principios que atan el versionado con la entrega:

- `main` representa la versión productiva y recibe sólo cambios aprobados; los releases se etiquetan semánticamente.
- El tag inmutable y el digest son el mecanismo de trazabilidad entre ambientes; `latest` no lo sustituye.
- La misma imagen validada se promueve: un cambio de versión no implica reconstruir para PROD ([Ambientes y promoción](../04-proceso/ambientes-y-promocion.md)).

## Cuándo se etiqueta una versión y quién lo hace

- **Cuándo:** cuando `release` pasó la validación en QA y se fusiona en `main` para ir a PROD. La etiqueta se pone sobre ese commit de `main`. No se etiqueta `develop` ni una rama de trabajo.
- **Quién:** DevOps (Daniel Ávila). Las versiones `v1.0.3` y `v1.0.4` de `MANI-Node`, `MANI-.NET`, `MANI-Java` y `MANI-APIGateway` las publicó DevOps; la de `MANI-Flutter` la publica su workflow `Release`, que se dispara al empujar una etiqueta `v*.*.*`.
- **Cómo:** la misma versión en los cinco repositorios desplegables cuando salen juntos (`v1.0.4` del 2026-11-05 en los cinco). Cambio incompatible de API o de esquema: sube MAYOR; funcionalidad compatible: MENOR; corrección: PARCHE (SDD §12.1).
- **Qué no se hace:** mover o borrar una etiqueta publicada. Si una versión sale mal, se publica la siguiente o se hace rollback (SDD §12.5).

## Historial

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.0 | 2026-10-22 | Resumen operativo del SDD §12 | — |
| 1.1 | 2026-11-23 | Ficha y sección «Cuándo se etiqueta una versión y quién lo hace» (SCRUM-1693) | Juan Sebastián Álvarez |

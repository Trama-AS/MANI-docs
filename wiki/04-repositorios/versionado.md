# Versionado

[← 04 · Repositorios](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SDD.md`](../../architecture/SDD.md) §12 · [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §5.1 y §10.

El detalle completo está en SDD §12. Resumen operativo:

| Qué | Cómo se versiona |
|---|---|
| **Servicios** | SemVer por repositorio (SDD §12.1); la imagen lleva además `dev-<sha>`, `qa-<sha>` o la versión semántica |
| **API** | Contratos versionados; es umbral de mantenibilidad (SAD §20.4). Reglas en SDD §12.2 |
| **Base de datos** | Migraciones con estrategia de compatibilidad y rollback (SDD §12.3, §19.5) |
| **Releases** | Etiquetado semántico sobre `main`, que representa la versión productiva (SDD §12.4, Políticas §5.1) |
| **Rollback** | SDD §12.5 |

Principios que atan el versionado con la entrega:

- `main` representa la versión productiva y recibe sólo cambios aprobados; los releases se etiquetan semánticamente.
- El tag inmutable y el digest son el mecanismo de trazabilidad entre ambientes; `latest` no lo sustituye.
- La misma imagen validada se promueve: un cambio de versión no implica reconstruir para PROD ([Ambientes y promoción](../03-entrega/ambientes-y-promocion.md)).

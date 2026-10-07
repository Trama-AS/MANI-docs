# Git: ramas y commits

[← 05 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §5 y §6 · [`architecture/SDD.md`](../../architecture/SDD.md) §12.

## Ramas principales

| Rama | Qué es |
|---|---|
| `main` | La **versión productiva**. Protegida contra push directo; recibe sólo cambios aprobados; sus releases se etiquetan semánticamente |
| `develop` | Rama de **integración** del siguiente incremento |

## Ramas temporales

| Tipo | Patrón | Nace de | Vuelve por |
|---|---|---|---|
| Feature | `feature/US-XX-descripcion` | `develop` | Pull Request |
| Fix | `fix/BUG-XX-descripcion` | `develop` | Pull Request |
| Release | `release/*` | `develop` | Estabilización y promoción hacia TEST/QA |
| Hotfix | `hotfix/*` | `main` | Tras la corrección debe **sincronizarse de nuevo con la línea de desarrollo** |
| Spike | `spike/*` | `develop` | Experimentación técnica |

Dos reglas que se olvidan a menudo:

- Un **hotfix** no termina al desplegarse: termina cuando su corrección volvió a la línea de desarrollo.
- Un **spike no se convierte automáticamente en decisión arquitectónica** (Políticas §5.2). Su resultado se lleva a Mesa de Arquitectura y produce un ADR si corresponde. Ejemplo: `SP-05`, cuyo resultado se registró en [`ADR-0022`](../../adr/ADR-0022-logica-de-negocio-en-servicios.md).

## Reglas de integración

- **Todo cambio hacia ramas compartidas entra por PR** (Políticas §6). No hay commits directos a `main` ni a `develop`.
- `XX` en el nombre de la rama es el identificador del trabajo en Jira (`US-…`, `BUG-…`): es lo que permite rastrear la rama hasta su historia.
- La protección por *rulesets* debe cubrir al menos integración, release y producción. **La política es obligatoria aunque el enforcement automático esté pendiente** (Políticas §6.2): que GitHub todavía no bloquee algo no lo autoriza.

## Formato de mensaje de commit

**No hay un formato de mensaje de commit normado en los documentos del proyecto.** Lo exigible es:

- que el trabajo sea rastreable hasta Jira — la referencia Jira es obligatoria **en el PR** ([Pull requests](pull-requests.md));
- que el nombre de la rama lleve el identificador (`US-XX`, `BUG-XX`).

Práctica recomendable mientras no exista regla: mensaje imperativo, en español, que diga **qué cambia y por qué**, con el identificador de Jira al inicio o al final para que el historial se pueda cruzar sin abrir el PR.

Si el equipo quiere convertir esto en norma (por ejemplo Conventional Commits), es un **cambio de reglas de proceso**: se aprueba en retrospectiva y aplica al sprint siguiente (`GOBIERNO_DEL_EQUIPO.md` §1.4), y se documenta en `POLITICAS_DEVOPS_HERRAMIENTAS.md`, no en esta wiki.

## Caso especial: MANI-Flutter

`CFG-37` y `CFG-38` ya se cerraron: `main` y `release` están contenidos en `develop`, que es la base única, y no quedan ramas con trabajo sin fusionar. Las ramas nuevas salen de `develop` y vuelven por PR, como en el resto de repositorios. El detalle de la reconciliación está en [Multi-repo](../04-repositorios/multirepo.md); el orden de trabajo, en [Orden de ejecución](../06-backlog/orden-de-ejecucion.md).

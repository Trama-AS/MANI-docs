# Ramas, flujo y protección

[← 03 · Repositorios](README.md) · [Índice](../Home.md)

**Fuente:** [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md) §5 y §6 · [SDD §12](../02-arquitectura/SDD.md) · [ADR-0030](../02-arquitectura/adr/ADR-0030-propiedad-esquema-y-frontera-de-datos.md) · configuración real de GitHub (`gh api`), leída el 2026-11-23.

| Campo | Valor |
|---|---|
| **Finalidad** | Decir por qué ramas pasa un cambio hasta producción, qué exige GitHub en cada una, quién es dueño del código y qué no se toca nunca |
| **Mantiene** | Responsable de la carpeta 03, con DevOps (Daniel Ávila) para *rulesets* y etiquetas |
| **Consume** | Desarrollo, DevOps, QA |
| **Cada cuánto se actualiza** | Cuando cambian los *rulesets*, CODEOWNERS o el modelo de ramas de Políticas §5 |
| **Versión y fecha** | 1.0 · 2026-11-23 ([SCRUM-1693](https://maniservices.atlassian.net/browse/SCRUM-1693)) |
| **Origen y destino** | Políticas §5–§6 y ADR-0030 → esta página → [Git: ramas y commits](../04-proceso/git-ramas-y-commits.md) y [Pull requests](../04-proceso/pull-requests.md) (el cómo, paso a paso) |

## Flujo de un cambio

```text
historia en Jira (SCRUM-<id>)
  └─ rama feature/… o fix/… desde develop, con la clave en el nombre (se prueba en DEV, la máquina de cada quien)
       └─ PR a develop  ── checks requeridos en verde + revisión de QA
            └─ fusión en develop  ── integración del siguiente incremento
                 └─ develop → release  ── imagen desplegada y validada en QA
                      └─ release → main  ── etiqueta vX.Y.Z y la misma imagen promovida a PROD
```

DEV no es un ambiente desplegado: el pipeline promueve de QA a PROD ([Ambientes y promoción](../04-proceso/ambientes-y-promocion.md)).

- **Nunca se abre un PR de una rama de trabajo directo a `main`**, ni a `release`. A `main` solo llega `release`, y a `release` solo llega `develop`.
- Un cambio que toca varios repositorios se parte en **un PR por repositorio**, cada uno con la misma clave de Jira y enlazado a los demás. Si uno depende de otro, el PR lo dice y dice el **orden de despliegue**.
- QA aprueba los PR con destino a `develop`. Los PR entre ramas de trabajo (una `feature` sobre otra) los integra quien los abre.
- Un **hotfix** nace de `main` y no termina al desplegarse: termina cuando su corrección volvió a `develop` ([Git: ramas y commits](../04-proceso/git-ramas-y-commits.md#ramas-temporales)).

**Excepción: `MANI-docs`.** Solo tiene `main`; los cambios de documentación entran por PR a `main`, con revisión de otro responsable de carpeta. No se despliega, así que no pasa por `release`.

## Convenciones de commits, PR y etiquetas

| Elemento | Regla | Dónde se exige |
|---|---|---|
| Nombre de rama | `feature/SCRUM-<id>-descripcion`, `fix/SCRUM-<id>-descripcion`, `docs/SCRUM-<id>-descripcion` | Políticas §5; [Git: ramas y commits](../04-proceso/git-ramas-y-commits.md) |
| Título del PR | Empieza con `[SCRUM-<id>]` | Plantilla de PR de cada repositorio (`.github/pull_request_template.md`) |
| Mensaje de commit | Lleva `[SCRUM-<id>]`, en español, imperativo, y dice qué cambia y por qué | Lista de verificación de la plantilla de PR. No es un formato tipo Conventional Commits |
| Autoría | Sin líneas de coautoría ni firmas que atribuyan el trabajo a una herramienta de IA | Políticas §18.7; `CLAUDE.md` de cada repositorio |
| Etiqueta de versión | `vMAYOR.MENOR.PARCHE` sobre `main` (SemVer); la misma en los cinco repositorios desplegables cuando salen juntos | [Versionado](versionado.md) |
| Etiqueta de respaldo | `respaldo/<motivo>`. Ver [más abajo](#ramas-y-etiquetas-de-respaldo) | Esta página |

## Protección de ramas

Estado real leído en GitHub el 2026-11-23:

| Repositorio | Ramas cubiertas | Qué exige el *ruleset* «Quality Gate SonarQube» |
|---|---|---|
| `MANI-Node` | `develop`, `release`, `main` | Checks `Pruebas y cobertura` y `Sonar Quality Gate` en verde para fusionar |
| `MANI-Flutter` | `develop`, `release`, `main` | Ídem |
| `MANI-.NET` | `develop`, `release`, `main` | Ídem |
| `MANI-Java` | `develop`, `release`, `main` | Ídem |
| `MANI-APIGateway` | `develop`, `release`, `main` | Ídem |
| `MANI-docs` | — | Sin *ruleset*; la revisión la hace otro responsable de carpeta |

Lo que el *ruleset* **no** hace hoy: no exige un número de aprobaciones, no bloquea el push directo por sí mismo y no aplica en `MANI-docs`. La regla de Políticas §6.2 sigue valiendo: **la política obliga aunque GitHub no la haga cumplir**. No hay commits directos a `develop`, `release` ni `main`.

Cada repositorio corre además sus propios checks en el PR (lint, pruebas, build), que deben estar en verde aunque el *ruleset* no los nombre. En `MANI-Flutter`, el paso «Sin issues Blocker o Critical nuevos» (QAS-45, SCRUM-1681) rechaza el PR que introduce issues de esa severidad en Sonar, aunque el Quality Gate pase.

## CODEOWNERS

Los seis repositorios tienen `.github/CODEOWNERS` con una sola regla que cubre todo el árbol (`*`): Nicolás León, Sara Albarracín, Daniel Ávila y Santiago Hernández. GitHub les pide revisión en cada PR. Como el *ruleset* no exige su aprobación, la revisión obligatoria es la de QA sobre los PR a `develop`.

## Serie única de migraciones (ADR-0030)

- **`MANI-Node` es el único dueño del esquema.** Toda migración vive en `MANI-Node/db/migrations/`, con numeración incremental e inmutable (`0001`, `0002`…) y su `INSERT INTO schema_migrations`.
- **Rules (`MANI-Java`) y Dispatch (`MANI-.NET`) no versionan DDL.** Si necesitan una tabla o una columna, abren un PR de migración contra `MANI-Node`.
- `MANI-APIGateway/database/` y `MANI-Flutter/database/` son **histórico congelado**: no se les agrega nada.
- La prueba `tests/unit/db/migrationsNumbering.test.js` no deja repetir números ni dejar huecos sin documentar. Si dos PR abiertos toman el mismo número, **el segundo que se fusione se renumera**: archivo, `INSERT INTO schema_migrations`, su prueba y su fila en `db/README.md`. Ejemplo real: `0043` de SCRUM-1713 (#143) y la de SCRUM-1660, que pasó a `0044` en #141.
- Toda tabla nueva nace con `tenant_id`, `ENABLE ROW LEVEL SECURITY` y su política por tenant en la misma migración.

## Ramas y etiquetas de respaldo

**Una rama o etiqueta de respaldo no se borra, no se mueve, no se rebasa y no recibe commits.** Guarda el único estado conocido de algo antes de una operación que no tiene vuelta atrás (una reorganización de carpetas, la consolidación de un PR grande); si se toca, se pierde la posibilidad de comparar o de recuperar.

| Referencia | Repositorio | Qué guarda |
|---|---|---|
| `respaldo-develop-local` (rama) | **Por confirmar.** No aparece en ningún remoto ni en los clones revisados el 2026-11-23 | La HU-WIKI-05 la declara intocable. La SM confirma dónde vive y qué estado guarda |
| `respaldo/reorganizacion-02-arquitectura` y `-remota` (etiquetas) | `MANI-docs` | Estado de la carpeta de arquitectura antes de reorganizarla |
| `respaldo/scrum-1646-nicolas` (etiqueta) | `MANI-Flutter` | Trabajo de SCRUM-1646 antes de consolidarlo en un solo PR |

Para crear un respaldo nuevo se usa una **etiqueta** `respaldo/<motivo>` (no una rama, porque una rama invita a seguir trabajando encima) y se agrega a esta tabla.

## Historial

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.0 | 2026-11-23 | Página nueva (SCRUM-1693) | Juan Sebastián Álvarez |

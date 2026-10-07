# Cómo contribuir

Las reglas completas están en la wiki: [`wiki/05-proceso/`](wiki/05-proceso/README.md). Son las de [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) y [`governance/GOBIERNO_DEL_EQUIPO.md`](governance/GOBIERNO_DEL_EQUIPO.md); la wiki no añade ninguna.

Resumen:

1. Trabaja siempre sobre un ítem registrado en **Jira** (`US-XX`, `BUG-XX`, `CFG-XX`, `DOC-XX`, `SP-XX`). El backlog no vive en GitHub.
2. Crea la rama desde `develop`: `feature/US-XX-descripcion` o `fix/BUG-XX-descripcion`. Nunca commits directos a `main` ni a `develop`.
3. Abre un **Pull Request** con referencia Jira, propósito, cambios principales, pruebas ejecutadas, impacto técnico, evidencia y actualización documental si aplica.
4. Lo revisa al menos una persona distinta del autor; una revisión solicitada se atiende en ≤ 24 h hábiles.
5. Un cambio de arquitectura necesita trazabilidad hacia un **ADR**. Un cambio en datos obliga a revisar migraciones, RLS y compatibilidad.
6. Nada está `Done` con pruebas pendientes, documentación requerida incompleta, defectos bloqueantes abiertos o criterios incumplidos.

En este repositorio (`MANI-Docs`) el cambio es documental: antes de editar, revisa [qué documento corresponde](wiki/05-proceso/documentacion.md) y [la estructura del repo](wiki/04-repositorios/estructura-de-mani-docs.md).

## Tres reglas propias de este repositorio

- **Un dato, un dueño.** Antes de escribir una cifra, una lista de repositorios o un nombre de ambiente, comprueba en la tabla de fuente de verdad del [`README.md`](README.md) §12 a quién le corresponde. Si ya vive en otro documento, **enlaza en vez de copiar**.
- **Los umbrales de calidad viven solo en [`architecture/SDD.md`](architecture/SDD.md) §7 y §8.** No se repiten en el SAD, el backlog, las políticas ni la wiki. Un umbral en otro sitio está desactualizado por definición.
- **Los diagramas se regeneran, no se dibujan.** La fuente es [`diagrams/LLD/workspace.dsl`](diagrams/LLD/workspace.dsl); las imágenes de `diagrams/LLD/Software/` son su resultado. El inventario oficial de vistas es [`SDD.md`](architecture/SDD.md) §4.0. Valida el modelo antes de abrir el PR: ver [Diagramas](wiki/02-arquitectura/diagramas.md).

## Qué no se edita

- **`Entregas/`** es un histórico de entregables académicos. Sus copias de SRS, SAD, SDD, modelo de datos, backlog, infraestructura y políticas ya divergieron de los documentos vivos, y su numeración de ADR no es la vigente. No se actualiza ni se consulta como fuente.
- **Los ADR históricos.** Una decisión que cambia produce un ADR nuevo; el anterior pasa a `Superseded` y se conserva.

Los documentos de este repositorio **no llevan número de versión**: la versión es el commit.

Personas y asistentes de IA siguen las mismas reglas; la política de uso de IA está en [`wiki/05-proceso/trabajo-con-ia.md`](wiki/05-proceso/trabajo-con-ia.md).

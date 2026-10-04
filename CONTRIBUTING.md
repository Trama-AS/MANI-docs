# Cómo contribuir

Las reglas completas están en la wiki: [`wiki/05-proceso/`](wiki/05-proceso/README.md). Son las de [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) y [`governance/GOBIERNO_DEL_EQUIPO.md`](governance/GOBIERNO_DEL_EQUIPO.md); la wiki no añade ninguna.

Resumen:

1. Trabaja siempre sobre un ítem registrado en **Jira** (`US-XX`, `BUG-XX`, `CFG-XX`, `DOC-XX`, `SP-XX`). El backlog no vive en GitHub.
2. Crea la rama desde `develop`: `feature/US-XX-descripcion` o `fix/BUG-XX-descripcion`. Nunca commits directos a `main` ni a `develop`.
3. Abre un **Pull Request** con referencia Jira, propósito, cambios principales, pruebas ejecutadas, impacto técnico, evidencia y actualización documental si aplica.
4. Lo revisa al menos una persona distinta del autor; una revisión solicitada se atiende en ≤ 24 h hábiles.
5. Un cambio de arquitectura necesita trazabilidad hacia un **ADR**. Un cambio en datos obliga a revisar migraciones, RLS y compatibilidad.
6. Nada está `Done` con pruebas pendientes, documentación requerida incompleta, defectos bloqueantes abiertos o criterios incumplidos.

En este repositorio (`MANI-Docs`) el cambio es documental: antes de editar, revisa [qué documento corresponde](wiki/05-proceso/documentacion.md) y [la estructura del repo](wiki/04-repositorios/estructura-de-mani-docs.md). Los diagramas C4 se editan en [`architecture/workspace.dsl`](diagrams/C4Model/workspace.dsl), no en imágenes.

Personas y asistentes de IA siguen las mismas reglas; la política de uso de IA está en [`wiki/05-proceso/trabajo-con-ia.md`](wiki/05-proceso/trabajo-con-ia.md).

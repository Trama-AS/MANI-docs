# Cómo contribuir

Las reglas completas están en la wiki: [`wiki/05-proceso/`](wiki/05-proceso/README.md). Son las de [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) y [`governance/GOBIERNO_DEL_EQUIPO.md`](governance/GOBIERNO_DEL_EQUIPO.md); la wiki no añade ninguna.

Resumen:

1. Trabaja siempre sobre un ítem registrado en **Jira** (`US-XX`, `BUG-XX`, `CFG-XX`, `DOC-XX`, `SP-XX`). El backlog no vive en GitHub.
2. Crea la rama desde `develop`: `feature/US-XX-descripcion` o `fix/BUG-XX-descripcion`. Nunca commits directos a `main` ni a `develop`.
3. Abre un **Pull Request** con referencia Jira, propósito, cambios principales, pruebas ejecutadas, impacto técnico, evidencia y actualización documental si aplica.
4. Lo revisa al menos una persona distinta del autor; una revisión solicitada se atiende en ≤ 24 h hábiles.
5. Un cambio de arquitectura necesita trazabilidad hacia un **ADR**. Un cambio en datos obliga a revisar migraciones, RLS y compatibilidad.
6. Nada está `Done` con pruebas pendientes, documentación requerida incompleta, defectos bloqueantes abiertos o criterios incumplidos.

En este repositorio (`MANI-Docs`) el cambio es documental: antes de editar, revisa [qué documento corresponde](wiki/05-proceso/documentacion.md) y [la estructura del repo](wiki/04-repositorios/estructura-de-mani-docs.md). Los diagramas C4 se editan en [`diagrams/c4/workspace.dsl`](diagrams/c4/workspace.dsl), no en imágenes.

Personas y asistentes de IA siguen las mismas reglas; la política de uso de IA está en [`wiki/05-proceso/trabajo-con-ia.md`](wiki/05-proceso/trabajo-con-ia.md).

**Autoría:** el entregable lo firma la persona que lo presenta. No se añaden líneas de coautoría, firmas, pies ni emojis que atribuyan el trabajo a una herramienta de IA, ni en commits, Pull Requests, documentos, código o comentarios; el campo **Autor** de un ADR lleva el nombre de la persona responsable de la decisión. La revisión humana que exige la política §18.1 es la garantía, y la trazabilidad la dan Jira y el historial de Git ([Políticas §18.7](governance/POLITICAS_DEVOPS_HERRAMIENTAS.md), [Trabajo con asistentes de IA](wiki/05-proceso/trabajo-con-ia.md)).

# 05 · Proceso de trabajo

[← Índice de la wiki](../Home.md)

**Fuente:** [`governance/GOBIERNO_DEL_EQUIPO.md`](../../governance/GOBIERNO_DEL_EQUIPO.md) · [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §5, §6 y §18 · [`adr/ADR-0002`](../../adr/ADR-0002-jira-github.md), [`ADR-0003`](../../adr/ADR-0003-mesa-arquitectura.md).

Estas páginas son **normativas** para personas y asistentes de IA, y no añaden nada a los documentos: los ordenan.

| Página | Tema |
|---|---|
| [Git: ramas y commits](git-ramas-y-commits.md) | Modelo de ramas vigente y qué está y qué no está normado |
| [Pull requests](pull-requests.md) | Contenido obligatorio, revisión y protección |
| [Jira y trazabilidad](jira-y-trazabilidad.md) | Qué vive en Jira, qué en GitHub y cómo se vinculan |
| [Roles y decisiones](roles-y-decisiones.md) | Quién decide qué, desempates y Mesa de Arquitectura |
| [Ceremonias y tiempos de respuesta](ceremonias-y-tiempos.md) | Ceremonias, canales, daily, retro y plazos exigibles |
| [DoR y DoD](dor-y-dod.md) | Cuándo una historia entra y cuándo está terminada |
| [Estándares de documentación](documentacion.md) | Qué documento se actualiza con cada tipo de cambio |
| [Trabajo con asistentes de IA](trabajo-con-ia.md) | Política de uso de IA y cómo se aplica en este repositorio |

## Las reglas en seis líneas

1. Todo trabajo tiene su issue en **Jira**; el backlog no vive en GitHub.
2. Toda rama de trabajo nace de `develop` y vuelve por **Pull Request**: `feature/US-XX-descripcion`, `fix/BUG-XX-descripcion`.
3. `main` representa la versión productiva: protegida contra push directo, sólo cambios aprobados, releases etiquetados.
4. El PR lleva referencia Jira, propósito, cambios, pruebas ejecutadas, impacto técnico, evidencia y actualización documental si aplica.
5. Lo revisa al menos una persona distinta del autor; una solicitud de revisión se atiende en **≤ 24 h hábiles**.
6. Nada está `Done` con pruebas pendientes, documentación requerida incompleta, defectos bloqueantes abiertos o criterios incumplidos.

## Tres reglas de gobierno que resuelven discusiones

De `GOBIERNO_DEL_EQUIPO.md` §1:

- **Lo que no está documentado no se exige.** Si alguien pide algo que ningún documento sostiene, se documenta primero.
- **Lo acordado se cumple durante su vigencia.** Un cambio de reglas de proceso se aprueba en retrospectiva y aplica al sprint siguiente.
- **Toda excepción se registra** con responsable, motivo y fecha.

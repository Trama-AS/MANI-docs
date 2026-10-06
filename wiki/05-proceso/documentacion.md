# Estándares de documentación

[← 05 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** [`adr/ADR-0001`](../../adr/ADR-0001-gestion-documental.md) · [`adr/ADR-0008`](../../adr/ADR-0008-diagramacion-tecnica.md) · [`governance/GOBIERNO_DEL_EQUIPO.md`](../../governance/GOBIERNO_DEL_EQUIPO.md) §3 y §9.4 · [`README.md`](../../README.md) §16.

## Qué se actualiza con cada tipo de cambio

| Cambio | Documento |
|---|---|
| Requisito nuevo o modificado | `product/SRS.md` |
| Arquitectura de alto nivel | `architecture/SAD.md` (+ el DHL si cambia el dibujo) |
| Diseño, componentes o vistas C4 | `diagrams/C4Model/workspace.dsl` y la sección correspondiente del `SDD.md` |
| Tablas, DDL, diccionario, modelo dimensional | `architecture/ModeloDatos.md` |
| Decisión técnica costosa de revertir | ADR nuevo en `adr/` |
| Tecnología que entra o sale | `architecture/TECH_RADAR.md` |
| Regla de proceso del equipo | `governance/GOBIERNO_DEL_EQUIPO.md` |
| Ramas, PR, CI/CD, pruebas, secretos | `governance/POLITICAS_DEVOPS_HERRAMIENTAS.md` |
| Ambientes, Supabase, red, backups | `governance/INFRAESTRUCTURA_MANI.md` |
| Navegación o guía de consulta | esta `wiki/` |

El mapa completo de ubicaciones está en [Estructura de MANI-Docs](../04-repositorios/estructura-de-mani-docs.md).

## Reglas documentales

De `README.md` §16 y ADR-0001:

- Ninguna decisión arquitectónica es oficial sólo por aparecer en una conversación o propuesta.
- Los cambios arquitectónicos relevantes se formalizan mediante **ADR**.
- Los ADR históricos **no se eliminan**; una decisión que cambia deja el anterior en `Superseded`.
- Los requerimientos se mantienen **separados** de las decisiones de implementación.
- **No se duplican decisiones completas** entre SRS, SAD, SDD, ADR, políticas e infraestructura: se enlaza.
- Aprobar documentación es decisión del **PO** ([Roles y decisiones](roles-y-decisiones.md)).

## Formato de un ADR

Los ADR de este repositorio siguen una estructura homogénea; al crear uno nuevo, se copia la de un ADR existente:

```markdown
# ADR-00NN — <título de la decisión>

- **Estado:** Propuesto | Aceptado | Rejected | Superseded
- **Decisión de:** <ámbito>
- **Relacionado con:** <ADR, RF, RNF o REST>

## Contexto
## Alternativas
## Decisión
## Consecuencias
```

Un ADR `Superseded` conserva el motivo y la referencia a quien lo sustituye.

## Diagramas

Los diagramas deben ser localizables, versionables y coherentes con la documentación vigente (ADR-0008). El modelo C4 se mantiene como **DSL versionable** y los diagramas de alto nivel como imágenes referenciadas por el SAD: ver [Diagramas](../02-arquitectura/diagramas.md).

## Esta wiki

- Cada página declara su fuente y no introduce reglas propias.
- Un cambio de regla **no se hace en la wiki**: se hace en el documento fuente y luego la wiki se alinea.
- Si una página contradice su fuente, se corrige la página.

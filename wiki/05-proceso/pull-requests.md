# Pull requests

[← 05 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §6 · [`governance/GOBIERNO_DEL_EQUIPO.md`](../../governance/GOBIERNO_DEL_EQUIPO.md) §6.1 y §9.

## Contenido obligatorio

Un PR debe incluir (Políticas §6):

- **referencia Jira**;
- propósito;
- cambios principales;
- pruebas ejecutadas;
- impacto técnico;
- evidencia relevante;
- actualización documental si aplica.

Plantilla que cubre exactamente eso, sin añadir requisitos:

```markdown
## Jira
<US-XX / BUG-XX / CFG-XX / DOC-XX>

## Propósito
<qué problema resuelve>

## Cambios principales
-

## Pruebas ejecutadas
- `comando` → resultado

## Impacto técnico
<servicios, contratos, datos, ambientes afectados>

## Evidencia
<capturas, logs, salida de pruebas>

## Documentación
<documento actualizado, o "no aplica" con el motivo>
```

## Revisión

- **Mínimo un revisor técnico distinto del autor** cuando la configuración de GitHub lo permita.
- Una solicitud de revisión se responde en **≤ 24 horas hábiles** (`GOBIERNO_DEL_EQUIPO.md` §6.1).
- Los **cambios de arquitectura requieren trazabilidad hacia un ADR**: si no hay ADR que los respalde, el PR se detiene y la decisión va a [Mesa de Arquitectura](roles-y-decisiones.md).
- Los **cambios en datos** obligan a revisar migraciones, RLS y compatibilidad.
- Un cambio que toque autenticación, tenant, RLS, endpoints de datos o Storage debe traer sus pruebas cross-tenant ([CI/CD y calidad](../03-entrega/cicd-y-calidad.md)).

Lista corta para el revisor, derivada de [Reglas arquitectónicas](../02-arquitectura/reglas-arquitectonicas.md):

- [ ] La operación entra por el Gateway.
- [ ] El servicio que cambia es dueño de esos datos.
- [ ] El aislamiento multi-tenant sigue en sus tres capas.
- [ ] No hay credenciales ni secretos en el diff.
- [ ] Hay ADR si el cambio es estructural.
- [ ] La documentación afectada está actualizada.

## Cierre

Un PR integrado no cierra la historia por sí mismo: la historia cierra cuando cumple el [DoD](dor-y-dod.md), incluidas la validación de QA y la aceptación del PO cuando aplique. La vinculación issue ↔ PR ↔ pruebas ↔ aceptación se registra en Jira/GitHub (`GOBIERNO_DEL_EQUIPO.md` §9.5).

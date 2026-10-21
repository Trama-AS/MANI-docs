# DoR y DoD

[← 05 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/GOBIERNO_DEL_EQUIPO.md`](../../governance/GOBIERNO_DEL_EQUIPO.md) §8 y §9. El **DoD lo decide QA** (§2.3).

## Definition of Ready

Una historia puede entrar a Planning cuando tiene, como mínimo:

- descripción comprensible;
- criterios de aceptación;
- prioridad;
- clasificación;
- estimación propuesta;
- dependencias conocidas;
- **sin spike bloqueante abierto** que impida desarrollarla.

> `SP-05`, que bloqueaba la estimación de las subtareas `-M2` de todas las historias de migración, **quedó decidido el 2026-10-05** y registrado en [`ADR-0022`](../../adr/ADR-0022-logica-de-negocio-en-servicios.md). Los spikes que siguen abiertos están en [Riesgos y puntos abiertos](../02-arquitectura/riesgos-y-puntos-abiertos.md).

## Definition of Done

**Ningún elemento es `Done` con pruebas pendientes, documentación requerida incompleta, defectos bloqueantes abiertos o criterios incumplidos.**

### Funcional
- criterios de aceptación verificados;
- comportamiento esperado demostrado;
- aceptación del PO cuando aplique.

### Técnico
- cambios integrados mediante Pull Request;
- revisión técnica realizada;
- **CI en verde**;
- contratos/API actualizados cuando aplica.

### Calidad
- QA ejecutó o validó las pruebas requeridas;
- no existen defectos que impidan la entrega;
- gates técnicos exigibles superados ([CI/CD y calidad](../03-entrega/cicd-y-calidad.md)).

### Documentación
Se actualizan los artefactos afectados: API · arquitectura · modelo de datos · instructivos · ADR cuando corresponda ([Estándares de documentación](documentacion.md)).

### Gestión
Issue, PR, pruebas y aceptación quedan vinculados en Jira/GitHub cuando corresponda.

## Añadidos que aplican a historias concretas

No son un DoD paralelo: son requisitos del propio cambio.

| Si la historia toca… | Debe demostrar |
|---|---|
| Autenticación, tenant, RLS, endpoints de datos o Storage | Los seis casos cross-tenant, con resultado de rechazo o ausencia de datos |
| Despacho o asignación | Cero dobles asignaciones bajo concurrencia e idempotencia (`QAS-07`) |
| Reglas o tarifario | Que un cambio de regla del tenant surte efecto **sin despliegue** (`QAS-04`) |
| Notificaciones | Que un fallo de push no revierte una operación confirmada (`QAS-02`) |
| Consulta de disponibilidad o ranking | la latencia dentro del umbral del [SDD §7.4](../../architecture/SDD.md), verificada con el escenario `QAS-03` del §8 |
| Datos o reglas de otro servicio | Que se obtienen por llamada HTTP al servicio dueño, sin consultar ni escribir tablas de un dominio ajeno, y que el llamador responde `503` si ese servicio no responde ([SDD §4.2](../../architecture/SDD.md); criterios T1 y T2) |
| Esquema o tablas | Que toda tabla nueva nace con `tenant_id`, RLS habilitado y su política por tenant en la misma migración ([ADR-0012](../../adr/ADR-0012-persistencia-multitenant.md)). Cuando se apruebe ADR-0030, la migración vive en `MANI-Node/db/migrations/` |

**Evidencia exigida.** La evidencia de QA va en la subtarea QA de la historia, con los IDs de casos de la matriz de pruebas del sprint (`product/MANI_Matriz_Pruebas_Sprint4.xlsx`, SCRUM-1264). En Flutter, el resultado local de `flutter analyze` y `flutter test` reemplaza al CI mientras los PR a `develop` no lo corran.

> La numeración de los QAS sigue el [SDD §8](../../architecture/SDD.md): QAS-02 es tolerancia a fallos (notificaciones), QAS-04 modificabilidad (reglas sin despliegue) y QAS-07 corrección funcional (asignación sin doble aceptación). Las dos últimas filas y la evidencia exigida son las decisiones de QA de [`product/CRITERIOS_ACEPTACION_SPRINT4.md`](../../product/CRITERIOS_ACEPTACION_SPRINT4.md) §4 (revisión de MANI-docs#49).

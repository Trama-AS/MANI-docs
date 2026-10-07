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
| Despacho o asignación | Cero dobles asignaciones bajo concurrencia e idempotencia (QAS-02) |
| Reglas o tarifario | Que un cambio de regla del tenant surte efecto **sin despliegue** (QAS-05) |
| Notificaciones | Que un fallo de push no revierte una operación confirmada (QAS-04) |
| Consulta de disponibilidad o ranking | p95 ≤ 1 s en el escenario del SRS |

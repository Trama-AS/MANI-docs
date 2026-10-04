# Datos y analítica

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/ModeloDatos.md`](../../architecture/ModeloDatos.md) · [`architecture/SAD.md`](../../architecture/SAD.md) §14 y §15 · [`architecture/SDD.md`](../../architecture/SDD.md) §12.3 y §18 · [`governance/INFRAESTRUCTURA_MANI.md`](../../governance/INFRAESTRUCTURA_MANI.md) §15.

## Dónde está cada cosa

El detalle vive en [`architecture/ModeloDatos.md`](../../architecture/ModeloDatos.md). Secciones útiles para ubicarse:

| Necesitas | Sección del documento |
|---|---|
| Glosario de datos | §2 |
| Modelo conceptual | §3 |
| Modelo lógico por dominio (identidad, catálogo, disponibilidad, operación, reglas, comunicaciones, pagos) | §4 |
| DER lógico | §5 |
| Separación por esquemas | §6.1 |
| DDL operacional | §7 |
| Diccionario de datos tabla por tabla | §8 |
| Data Warehouse, modelo dimensional y flujo analítico | §9–§10 |

## Esquemas y propiedad de datos

La persistencia es PostgreSQL sobre Supabase, separada por esquemas que corresponden a los dominios: `core`, `disponibilidad`, `despacho`, `reglas`, `comunicaciones`, `pagos` (Modelo de Datos §6.1 y §8).

Regla operativa: **un servicio no escribe tablas privadas de otro dominio** (SAD §4.1, SDD §14, umbral de mantenibilidad del SAD §20.4). Si un caso de uso necesita datos de otro dominio, se pide por la API de su dueño.

## Capacidades de Supabase utilizadas

PostgreSQL · RLS · Auth · Storage · Realtime (SAD §14). Realtime transporta eventos, **no** ejecuta reglas de negocio (SAD §12).

## Migraciones

- La definición de esquema y las políticas de seguridad deben ser **equivalentes entre ambientes** (Políticas DevOps §2.7).
- Toda migración requiere estrategia de compatibilidad y rollback antes de promover a producción (SDD §19.5, §12.3).
- Un cambio de datos en un PR obliga a revisar migraciones, RLS y compatibilidad (Políticas DevOps §6.1).
- Quién ejecuta las migraciones en cada ambiente está definido en [`INFRAESTRUCTURA_MANI.md`](../../governance/INFRAESTRUCTURA_MANI.md) §15; cerrarlo para todos los ambientes es parte de la [definición de llegada](../01-producto/criterios-de-exito.md).

## Analítica separada del OLTP

La analítica no se ejecuta sobre la base transaccional (SAD §4.1 y §15; riesgo KI-07). El flujo es:

```text
OLTP → CDC/ELT → Data Warehouse → modelo dimensional → BI
```

El Data Warehouse **no escribe** en OLTP (SDD §14).

## Auditabilidad

Para RNF-04 y RF-18 se mantienen: historial de estados de la solicitud · actor · fecha/hora · operación · `correlation_id` · eventos de despacho · cambios de cotización · eventos de ejecución · auditoría de operaciones sensibles (SAD §13). En el segundo incremento, las operaciones financieras requieren registro inmutable.

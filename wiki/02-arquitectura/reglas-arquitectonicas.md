# Reglas arquitectónicas

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SAD.md`](../../architecture/SAD.md) §4.1 · [`architecture/SDD.md`](../../architecture/SDD.md) §4.2 y §14 · [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §2.

Página de consulta rápida antes de escribir código o revisar un PR. Todo lo de aquí sale de los documentos citados.

## Principios (SAD §4.1)

1. Flutter contiene presentación y lógica de interacción, **no** reglas de negocio centrales.
2. Toda API operacional entra por NGINX / API Gateway.
3. La lógica de dominio vive en servicios.
4. Cada servicio es responsable de su capacidad funcional.
5. Supabase es la plataforma de persistencia administrada; PostgreSQL es su motor.
6. El aislamiento multi-tenant se aplica en varios niveles: JWT, autorización de servicios y RLS.
7. Los servicios **no** escriben directamente en datos privados de otros dominios.
8. Los cambios de configuración por tenant **no** requieren nuevo despliegue.
9. La analítica se desacopla del OLTP.
10. Los artefactos desplegados son contenerizados, versionados e inmutables.

## Dependencias permitidas (SDD §14)

```text
Flutter            → API Gateway
API Gateway        → Servicios
Servicio           → Repositorio propio
Servicio           → Adapter → Proveedor externo
OLTP               → CDC/ELT → Data Warehouse
```

## Dependencias prohibidas (SDD §14)

```text
Flutter            → tabla operacional
Servicio A         → tablas privadas de Servicio B
Data Warehouse     → escritura en OLTP
Gateway            → implementación de reglas de dominio
Servicio           → credenciales hard-coded
DEV/QA             → base de datos PROD
```

La única desviación admitida hoy es la [excepción transitoria de disponibilidades](estilo-y-contenedores.md#excepción-transitoria-vigente), con sus condiciones.

## Reglas complementarias

- Las integraciones externas se encapsulan mediante adaptadores (SDD §4.2).
- El Data Warehouse no participa en transacciones operacionales (SDD §4.2).
- **No se implementan diferencias por tenant mediante forks del producto** (Políticas DevOps §2.10); tampoco mediante feature toggles como requisito arquitectónico ([ADR-0014](../../adr/ADR-0014-feature-toggle.md), `Rejected`).
- Los umbrales funcionales provienen del SRS/SAD/SDD y no se inventan en otros documentos (Políticas DevOps §13.5).

## Verificación en revisión de PR

Un PR que toque arquitectura debe poder responder:

- ¿Entra la operación por el Gateway?
- ¿El servicio que cambia es el dueño de esos datos ([Datos y analítica](datos-y-analitica.md))?
- ¿Se mantiene el aislamiento multi-tenant en las tres capas ([Multi-tenancy y seguridad](multitenancy-y-seguridad.md))?
- ¿Hay ADR que respalde el cambio si es estructural (Políticas DevOps §6.1)?
- ¿Se tocaron migraciones, RLS o compatibilidad de datos, y se revisaron?

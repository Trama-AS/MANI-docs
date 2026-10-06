# Multi-tenancy y seguridad

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SAD.md`](../../architecture/SAD.md) §8 y §9 · [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §13.4 y §16 · [`adr/ADR-0018`](../../adr/ADR-0018-identificacion-tenant.md), [`ADR-0012`](../../adr/ADR-0012-persistencia-multitenant.md), [`ADR-0013`](../../adr/ADR-0013-storage-kyc.md), [`ADR-0015`](../../adr/ADR-0015-pruebas-aislamiento-multitenant.md).

RNF-01 es el requisito crítico del producto. Esta página concentra cómo se cumple.

## Identificación del tenant

Para operaciones autenticadas:

```text
Authorization: Bearer <JWT>
```

- El `tenant_id` se obtiene de un **JWT firmado**: es la fuente canónica.
- El cliente **no** puede decidir el tenant de autorización mediante un header libre.
- `X-Tenant-Slug` puede usarse **antes** de autenticación, sólo como contexto de resolución. No autoriza acceso a datos.

## Capas de control (defensa en profundidad)

```text
Cliente
  ↓
API Gateway          valida token y políticas de acceso
  ↓
Servicio             valida rol y permiso
  ↓
PostgreSQL (RLS)     aisla por tenant
  ↓
Datos
```

Ninguna capa se considera suficiente por sí sola. Quitar una es un cambio arquitectónico y requiere ADR.

## Documentos KYC

Storage de Supabase, con la convención:

```text
tenant_id/aliado_id/documento
```

Controles exigidos: bucket privado · políticas de acceso · separación por tenant · separación por aliado · administrador de tenant limitado a su propio tenant. Responde a RF-05, RF-06 y REST-02.

## Configuración por tenant como dato

RF-02, RNF-02, RNF-10 y REST-05 prohíben código específico por empresa. Se mantienen como datos: documentos KYC requeridos · reglas de ranking · categorías · tarifarios · comisión · tiempos · parámetros operativos.

```text
Tenant → Configuración/Reglas → Rules Service → Comportamiento dinámico
```

Modificar una regla de un tenant **no** exige despliegue.

## Pruebas de aislamiento obligatorias

Todo cambio en autenticación, tenant, RLS, endpoints de datos o Storage debe cubrir, como mínimo, estos casos cross-tenant (Políticas DevOps §13.4):

1. lectura de otro tenant;
2. listado de recursos ajenos;
3. escritura en otro tenant;
4. borrado ajeno;
5. token expirado o alterado;
6. documentos KYC de otro tenant o aliado.

Resultado esperado: rechazo o ausencia de datos no autorizados. El umbral de calidad es **100 % de pruebas cross-tenant deniegan acceso** ([Atributos de calidad](atributos-de-calidad.md)).

## Riesgo abierto que afecta a esta página

El modelo actual de RLS deriva tenant y usuario de `auth.uid()` porque hoy el llamador es el cliente Flutter. Cuando el llamador pase a ser un servicio con `service-role`, **esas políticas dejan de aislar**. Está registrado como tarea `CFG-23` del backlog de transición y es el punto que puede tumbar RNF-01: ver [Riesgos y puntos abiertos](riesgos-y-puntos-abiertos.md).

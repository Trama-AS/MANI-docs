# Multi-tenancy y seguridad

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SAD.md`](SAD.md) §8 y §9 · [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md) §13.4 y §16 · [`adr/ADR-0018`](adr/ADR-0018-identificacion-tenant.md), [`ADR-0012`](adr/ADR-0012-persistencia-multitenant.md), [`ADR-0013`](adr/ADR-0013-storage-kyc.md), [`ADR-0015`](adr/ADR-0015-pruebas-aislamiento-multitenant.md).

RNF-01 es el requisito crítico del producto. Esta página concentra cómo se cumple.

## Identificación del tenant

Para operaciones autenticadas:

```text
Authorization: Bearer <JWT>
```

### Relación entre Supabase Auth (IdP) y JWT
**Supabase Auth y JWT no son conceptos opuestos ni excluyentes:**
* **Supabase Auth (GoTrue):** Cumple el rol de **Proveedor de Identidad (IdP)**. Valida credenciales, hashes de contraseñas y gestiona el ciclo de vida de usuarios y sesiones.
* **JWT (JSON Web Token):** Es el **formato estándar del token portador (*bearer token*)** emitido por Supabase Auth.
* **Propósito en la arquitectura:**
  1. **Autenticación sin estado (Stateless):** Permite que microservicios políglotas independientes (**Node.js, Java Spring Boot, .NET 8**) y el API Gateway NGINX verifiquen la identidad de forma criptográfica sin tener que consultar una base de datos centralizada de sesiones en cada petición.
  2. **Fuente canónica no falsificable (Anti-Spoofing):** El `tenant_id` viaja dentro de la firma criptográfica (`app_metadata.tenant_id`) inyectado por el hook de Supabase. El cliente no puede imponer ni alterar su tenant mediante un header arbitrario.
  3. **Inspección en el Gateway ([ADR-0027](adr/ADR-0027-alcance-supabase-cliente-flutter.md)):** Al retirar el acceso directo de Flutter a la base de datos, el Gateway intercepta el JWT y filtra perimetralmente solicitudes anónimas, expiradas o sin claim de tenant.

- El `tenant_id` se obtiene de un **JWT firmado**: es la única fuente canónica de verdad.
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

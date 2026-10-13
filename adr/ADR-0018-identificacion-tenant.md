# ADR-0018 — Identificación y propagación segura del tenant

- **Estado:** Aceptado
- **Decisión de:** seguridad e identidad
- **Relacionado con:** RF-03, RNF-01, ADR-0012, ADR-0019

## Contexto

Los servicios distribuidos necesitan identificar el tenant y al usuario de forma no falsificable y propagar ese contexto de manera segura y sin estado (stateless) entre todos los componentes políglotas (Node.js, Java, .NET, NGINX).

Surge la necesidad de clarificar el rol de **Supabase Auth** en relación con **JWT**:
Supabase Auth (mediante su componente GoTrue) actúa como el **Proveedor de Identidad (IdP)** oficial del sistema, responsable de validar credenciales (email/contraseña, federación). Sin embargo, en una arquitectura orientada a servicios (SOA) desacoplada de la base de datos (ADR-0019, ADR-0027), los microservicios y el API Gateway no consultan sesiones centralizadas en una base de datos por cada petición; en su lugar, requieren un mecanismo desacoplado, estandarizado y criptográficamente verificable: **JSON Web Tokens (JWT)** emitidos por el IdP.

## Alternativas

1. **Subdominio como única fuente.** Descartada por complejidad operativa y limitaciones en clientes móviles.
2. **Header `X-Tenant-ID` confiado por backend sin firma.** Descartada por riesgo crítico de suplantación (*tenant spoofing*).
3. **Sesiones con estado (Stateful Sessions / Cookies centralizadas en Redis/DB).** Descartada por introducir cuello de botella y alto acoplamiento entre servicios políglotas (Node.js, Java, .NET).
4. **JWT firmado por Supabase Auth (IdP) con inyección de claims de tenant + contexto de preautenticación (Elegida).**

## Decisión

1. **Supabase Auth como Emisor (IdP):** Supabase GoTrue actúa como el proveedor de identidad exclusivo. Tras autenticación exitosa en el cliente (`signInWithPassword`), emite un JWT firmado (`HS256`/asimétrico) conteniendo los claims estándar (`sub`, `exp`) y claims extendidos de tenant inyectados mediante hook de base de datos (`app_metadata.tenant_id`, `app_metadata.user_role`).
2. **Fuente canónica de Tenant:** Para todas las operaciones autenticadas, la **única fuente de verdad** del tenant es el claim `tenant_id` firmado dentro del JWT. Ningún cliente puede imponer o alterar su tenant mediante encabezados arbitrarios.
3. **Inspección perimetral en el API Gateway:** El API Gateway (NGINX) intercepta las peticiones protegidas y valida criptográficamente el JWT (`auth_request /_auth_validate` contra Core). Tokens sin firma válida, expirados o carentes del claim `tenant_id` son rechazados perimetralmente con HTTP `401 Unauthorized`.
4. **Token Relay e Inyección de Headers Limpios:** Una vez validado el JWT, el Gateway propaga el token original (`Authorization: Bearer <JWT>`) e inyecta encabezados normalizados y confiables hacia los servicios internos (`X-Tenant-Id`, `X-User-Role`, `X-User-Id`).
5. **Preautenticación:** `X-Tenant-Slug` se acepta únicamente en rutas preautenticadas (ej. `/api/v1/core/auth/*`) para resolución preliminar de tenant/branding antes de contar con credenciales; jamás autoriza acceso a datos protegidos.

## Justificación

* **Desacoplamiento Políglota:** Permite que servicios escritos en Java, .NET y Node.js verifiquen identidad y tenant sin compartir memoria ni consultar una base de datos de sesiones en cada llamada (*Stateless Authentication*).
* **Anti-Spoofing:** Al viajar el `tenant_id` dentro del payload firmado del JWT, el cliente no puede alterar su pertenencia organizacional.
* **Defensa en Profundidad:** El mismo JWT que valida el Gateway y los microservicios puede ser consumido por PostgreSQL mediante `auth.uid()` para hacer valer políticas de Row-Level Security (RLS).

## Consecuencias

### Positivas
* Contexto de tenant y usuario verificable extremo a extremo de forma criptográfica y sin estado.
* El API Gateway filtra peticiones anónimas o maliciosas antes de que consuman recursos en los microservicios de negocio.
* Total compatibilidad con los clientes Web y Móvil mediante el encabezado estándar `Authorization: Bearer <JWT>`.

### Negativas
* Los microservicios o el endpoint de validación del Gateway deben compartir el secreto de firma (`SUPABASE_JWT_SECRET`) o la clave pública del IdP.
* Requiere sincronizar la expiración y refresco periódico de tokens en el cliente móvil/web.

## Condición de revisión

Revisar si se adopta un IdP externo empresarial (ej. Keycloak, Auth0) o si se migra la validación perimetral a módulos nativos de NGINX con certificados mTLS entre servicios.

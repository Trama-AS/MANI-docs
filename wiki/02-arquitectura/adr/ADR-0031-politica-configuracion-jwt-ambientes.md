# ADR-0031 — Política de configuración, validación perimetral y propagación de JWT por ambiente

- **Estado:** Aceptado
- **Decisión de:** Seguridad, Infraestructura, Autenticación y Autorización Multi-Tenant
- **Autor:** Daniel Ávila (DevOps) / Santiago (Validación Conjunta)
- **Fecha:** 2026-10-17
- **Jira:** CFG4-04 (Auditoría y definición JWT), SCRUM-1102 (Emisión/Propagación JWT)
- **Relacionado con:** ADR-0012 (Persistencia multi-tenant), ADR-0018 (Identificación de tenant), ADR-0022 (Lógica de negocio en servicios), ADR-0027 (Alcance Supabase), ADR-0028 (Nombres repos y ambientes), SCRUM-1103 (Core Node), SCRUM-1104 (Rules Java), SCRUM-1105 (Dispatch .NET), bloqueante previo para SCRUM-1263
- **Enmienda:** SDD §3.1, §4.3 y SAD §6.2
- **Modificado por:** SCRUM-1362 (BUG-SEC-04, 2026-10-21): §1 *Algoritmo* acepta ES256 verificado con el JWKS del proyecto, porque Supabase Auth firma con ES256 y la restricción a HS256 dejaba fuera a todo usuario real.

---

## Contexto y Alcance

Durante la auditoría de seguridad y despliegues del Sprint 4 (CFG4-01 y CFG4-04), se realizó una revisión exhaustiva de la cadena de autenticación y autorización entre Supabase Auth, el API Gateway (NGINX) y los microservicios aguas abajo (`MANI-Core-Node`, `MANI-Rules-Java`, `MANI-Dispatch-DotNet`).

La auditoría técnica identificó dos requerimientos esenciales para cumplir los criterios de aceptación y garantizar el aislamiento multi-tenant antes de habilitar el pase a producción (SCRUM-1263):

1. **Claridad en Emisión vs. Validación:** Definir con rigor matemático y operativo qué entidad emite el JWT, cuál valida la firma criptográfica y cómo se propagan los claims de identidad y tenencia hacia el backend políglota sin sobrecargar a cada microservicio ni duplicar librerías criptográficas heterogéneas.
2. **Retiro de Mecanismos Inseguros (Anti-Spoofing):** En la revisión de código de `MANI-Node/src/routes/auth.routes.js`, se detectó un fallback que permitía decodificar el payload mediante `jwt.decode` si `jwt.verify` fallaba, tolerando tokens adulterados o con firmas inválidas en ambientes locales. Este mecanismo constituía una vulnerabilidad crítica de suplantación de identidad (spoofing) y bypass de RLS.
3. **Segregación Estricta de Secretos por Ambiente:** Asegurar que las llaves criptográficas utilizadas para validar los tokens no sean compartidas entre DEV, QA y PROD, manteniéndose fuera del control de versiones.

---

## Opciones Evaluadas

### Opción 1: Validación Distribuida en cada Microservicio
- Cada servicio (.NET, Java Spring Boot, Node.js Express) implementa su propio middleware JWT, descargando llaves públicas o consumiendo variables de entorno locales.
- *Desventajas:* Duplicación de lógica en tres stacks tecnológicos distintos, discrepancias en el manejo de algoritmos/formatos de claims, mayor superficie de ataque si un servicio olvida validar `tenant_id` y riesgo de desincronización de secretos.

### Opción 2: Validación Perimetral en API Gateway con Subrequest Interno a Core Service (Elegida)
- El API Gateway (NGINX) actúa como frontera de confianza perimetral. Toda petición hacia endpoints protegidos (`/api/v1/core/*`, `/api/v1/rules/*`, `/api/v1/dispatch/*`) ejecuta una directiva `auth_request /_auth_validate` hacia `MANI-Core-Node` (`/api/v1/auth/validate-token`).
- `MANI-Core-Node` valida estrictamente la firma criptográfica (HS256 con el secreto del ambiente o JWKS de Supabase) y la presencia del claim obligatorio `app_metadata.tenant_id`.
- Si el token es válido, responde `HTTP 200` y emite los encabezados HTTP seguros (`X-Tenant-Id`, `X-User-Role`, `X-User-Id`). NGINX los intercepta (`auth_request_set`) y los inyecta en la petición hacia el microservicio upstream. Si el token es inválido o no incluye tenant, NGINX corta la conexión inmediatamente con `HTTP 401 Unauthorized` o `HTTP 403 Forbidden`.
- *Ventajas:* Principio de defensa en profundidad, desacoplamiento de Rules (Java) y Dispatch (.NET) de la criptografía de autenticación, control perimetral estricto de acceso y garantía de que ninguna petición sin tenant_id alcanza a los microservicios de negocio.

---

## Decisión de Arquitectura y Configuración

### 1. Cadena de Emisión y Ciclo de Vida
- **Emisor (Issuer):** Supabase Auth (GoTrue) en ambientes integrados; endpoint interno controlado `/api/v1/auth/dev-token` en `MANI-Core-Node` exclusivamente para pruebas automatizadas y CI/CD.
- **Algoritmos (lista blanca, SCRUM-1362):** la verificación acepta exactamente dos algoritmos, y cada uno se verifica solo con su propia clave, así un token no puede elegir con qué se verifica (*alg confusion*):
  - `ES256`: tokens de usuario de Supabase Auth en todos los ambientes integrados. Clave pública del JWKS del proyecto del ambiente (`<SUPABASE_URL>/auth/v1/.well-known/jwks.json`) elegida por `kid`. Exige `aud = authenticated` e `iss = <SUPABASE_URL>/auth/v1`. El JWKS se cachea; un `kid` desconocido o un JWKS inalcanzable se rechazan (falla cerrado).
  - `HS256`: secreto del ambiente (`SUPABASE_JWT_SECRET`), para el secreto legado de Supabase, `/api/v1/auth/dev-token` (solo desarrollo y pruebas) y los tokens sintéticos de las suites Newman.
  - Cualquier otro algoritmo (`none`, `HS512`, `RS256`, etc.) se rechaza con `HTTP 401`.
- **Dónde se aplica:** `validate-token` de `MANI-Core-Node` (el `auth_request` del Gateway) y `TokenService` de Core usan el mismo verificador. `MANI-Dispatch-DotNet` vuelve a verificar el token en sus controladores, así que aplica la misma política y necesita `SUPABASE_URL` y `SUPABASE_JWT_SECRET` en cada ambiente. `MANI-Rules-Java` confía en los encabezados que inyecta el Gateway.
- **Audience (`aud`):** `authenticated`.
- **Tiempo de Expiración (`exp`):** Tokens con TTL estándar de 3600 segundos (1 hora). La renovación se ejecuta mediante refresh tokens gestionados exclusivamente entre el cliente Flutter y Supabase Auth / Core.

### 2. Estructura Obligatoria de Claims
Todo token procesado por la plataforma debe contener de forma obligatoria la siguiente estructura en el payload:
```json
{
  "sub": "uuid-del-usuario-en-auth",
  "role": "authenticated",
  "iss": "https://<supabase-instance>.supabase.co/auth/v1",
  "app_metadata": {
    "tenant_id": "uuid-del-tenant",
    "user_role": "cliente | aliado | admin_tenant | superadmin"
  },
  "exp": 1729209600,
  "iat": 1729206000
}
```
> **Regla de Validación:** Si `app_metadata.tenant_id` está ausente o vacío, el token es rechazado automáticamente (`HTTP 401 MISSING_TENANT_CLAIM`). Los servicios de negocio jamás procesan peticiones anónimas o sin tenant asignado.

### 3. Retiro del Mecanismo Inseguro de Decodificación Fallback
Se eliminó de raíz el bloque permisivo `jwt.decode` en `MANI-Node/src/routes/auth.routes.js`. La validación ahora aplica control estricto:
- Errores de firma (`JsonWebTokenError`): Rechazo inmediato con `HTTP 401 INVALID_SIGNATURE`.
- Errores de tiempo (`TokenExpiredError`): Rechazo inmediato con `HTTP 401 TOKEN_EXPIRED`.
- Tokens malformados o no Bearer: Rechazo inmediato con `HTTP 401 INVALID_TOKEN`.

### 4. Corrección de Enrutamiento en NGINX Gateway
En `MANI-APIGateway/nginx.conf`, se eliminó la barra inclinada final (`/`) en las directivas `proxy_pass http://rules_service;` y `proxy_pass http://dispatch_service;`. Esto previene que NGINX elimine el prefijo canónico `/api/v1/rules/` o `/api/v1/dispatch/`, permitiendo que los controladores de Spring Boot (`@PostMapping("/api/v1/rules/evaluate-rate")`) y ASP.NET Core (`[Route("api/v1/dispatch")]`) reciban sus rutas completas intactas.

### 5. Segregación Criptográfica de Secretos por Ambiente y Retiro de HS256
Los secretos JWT están desacoplados por máquina virtual y ambiente sin valores literales expuestos en la documentación ni en el repositorio:
- **DEV (`10.43.98.232`):** Inyectado vía variable de entorno `SUPABASE_JWT_SECRET` en `/opt/mani/.env.dev` con permisos `chmod 600`.
- **QA (`10.43.100.141`):** Inyectado vía variable de entorno `SUPABASE_JWT_SECRET` en `/opt/mani/.env.qa` con permisos `chmod 600`, apuntando al JWKS del proyecto Supabase de QA (`hpsxdotaizzclkeufzct`).
- **PROD (`10.43.98.203`):** Secreto de producción rotativo configurado en `/opt/mani/.env.prod`, administrado de forma aislada.

> **Política de Retiro de HS256 (TEC-10 / SCRUM-1457):**  
> La compatibilidad transitoria con tokens firmados simétricamente con `HS256` tiene como fecha límite oficial de retiro el **2026-11-15 (Cierre del Sprint 5)**. A partir de esa fecha, todos los clientes y servicios deberán autenticarse exclusivamente mediante tokens asimétricos `ES256` validados contra el JWKS del respectivo entorno.

---

## Diagrama de Secuencia del Flujo Perimetral

```mermaid
sequenceDiagram
    autonumber
    actor Cliente as Cliente (Flutter / Web)
    participant Gateway as MANI-APIGateway (NGINX)
    participant Core as MANI-Core-Node (/auth/validate-token)
    participant Rules as MANI-Rules-Java (:8080)
    participant Dispatch as MANI-Dispatch-DotNet (:5000)

    Cliente->>Gateway: POST /api/v1/rules/evaluate-rate<br/>Header: Authorization: Bearer <JWT>
    Note over Gateway: Intercepta directiva auth_request
    Gateway->>Core: Internal Subrequest /_auth_validate<br/>Header: Authorization: Bearer <JWT>
    
    alt Token Inválido / Expirado / Firma Adulterada
        Core-->>Gateway: HTTP 401 Unauthorized (INVALID_SIGNATURE / EXPIRED)
        Gateway-->>Cliente: HTTP 401 Unauthorized (Rechazo perimetral)
    else Token Sin Claim tenant_id
        Core-->>Gateway: HTTP 401 Unauthorized (MISSING_TENANT_CLAIM)
        Gateway-->>Cliente: HTTP 401 Unauthorized (Aislamiento RLS protegido)
    else Token Válido con Tenant
        Core-->>Gateway: HTTP 200 OK<br/>Headers: X-Tenant-Id, X-User-Role, X-User-Id
        Note over Gateway: Inyecta headers validados en upstream
        Gateway->>Rules: POST /api/v1/rules/evaluate-rate<br/>Headers: X-Tenant-Id, X-User-Role, X-User-Id, X-Correlation-ID
        Rules-->>Gateway: HTTP 200 OK (Cálculo de tarifa aplicado)
        Gateway-->>Cliente: HTTP 200 OK (Tarifa calculada con tenant aislado)
    end
```

---

## Consecuencias y Verificación

### Positivas
- **Inmunidad contra Spoofing:** Las firmas son verificadas criptográficamente al 100%; tokens alterados son bloqueados en el perímetro.
- **Cero Duplicación de Lógica en Microservicios:** Java y .NET reciben headers sanitizados y verificados por el Gateway (`X-Tenant-Id`, `X-User-Role`, `X-User-Id`).
- **Trazabilidad Total:** Cada validación y rechazo incluye el `X-Correlation-ID` en logs estructurados NGINX y Express.
- **Cumplimiento del DoD:** Cobertura de pruebas automatizadas del 100% en DEV y QA (8/8 casos exitosos).

### Negativas / Mitigaciones
- **Latencia de Subrequest Interno:** Cada petición protegida añade un subrequest HTTP local a Core Node.
  *Mitigación:* Se implementaron conexiones HTTP Keep-Alive en NGINX (`keepalive 32`), reduciendo la latencia de validación a menos de 4 ms en la red interna de Docker (`mani-network`).

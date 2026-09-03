# ADR-0018: Mecanismo de Identificación y Propagación de Tenant en Peticiones (Token JWT vs. Header vs. Subdominio)

- Fecha: 2026-09-02
- Sprint: 1
- Autor: Daniel Avila Medina (DevOps titular)
- Origen: Mesa de Arquitectura (Spike SP-01.1.2)
- Revisor: Santiago (QA / Product Owner)

## Contexto

El proyecto MANI es una plataforma SaaS multi-tenant que interactúa con múltiples clientes y servicios distribuidos: clientes móviles y portales web en Flutter (Repo A), microservicios en Java con Maven (Repo B), microservicios en .NET (Repo C) y servicios de persistencia sobre PostgreSQL gestionado por Supabase (ADR-0012).

El requerimiento no funcional **RNF-01** (Seguridad y aislamiento multi-tenant estricto) y el Objetivo de Diseño **DR-01** imponen como condición crítica que la información de un tenant no debe ser accesible, visible ni modificable por otro tenant bajo ninguna circunstancia. Conforme a **ADR-0012**, el equipo aprobó que dicho aislamiento se ejecute a nivel de motor mediante **Row-Level Security (RLS)** nativo en PostgreSQL.

Para que este modelo opere de manera segura, desacoplada y predecible en todo el ciclo DevSecOps y en la infraestructura en Microsoft Azure (ADR-0004), el equipo requiere:

1. Establecer un mecanismo unívoco, determinista e infalsificable (*anti-spoofing*) para identificar a qué tenant pertenece cada petición HTTP o WebSocket dirigida a los microservicios.
2. Resolver la identificación de tenant en la fase de **pre-autenticación** (resolución de empresa, registro y pantalla de login), cuando el usuario aún no posee un token de sesión activo.
3. Definir la estrategia de propagación del contexto de tenant en la comunicación interna entre microservicios (Java Repo B ↔ .NET Repo C ↔ Supabase).
4. Garantizar una integración ergonómica con la aplicación móvil en Flutter (Repo A), evitando sobrecostos y complejidades de administración de infraestructura DNS y certificados en Azure / Kubernetes.

## Alternativas evaluadas

1. **Identificación de tenant exclusivamente por subdominio (`tenant.mani.app` o `tenant.api.mani.com`).** Descartada principalmente por su impacto negativo en la experiencia de usuario y arquitectura de la aplicación móvil (Flutter en iOS y Android): los clientes y aliados descargan una única aplicación universal de las tiendas de aplicaciones, por lo que exigirles ingresar o seleccionar manualmente un subdominio antes del inicio de sesión degrada la usabilidad. Adicionalmente, introduce sobrecostos y complejidad operativa en la infraestructura cloud de Azure al requerir registros wildcard DNS (`*.mani.app`), certificados SSL/TLS comodín y reglas complejas de enrutamiento dinámico en el Ingress Controller de Kubernetes (AKS).
2. **Identificación exclusiva mediante cabecera HTTP personalizada (`X-Tenant-ID` o `X-Tenant-Key`).** Descartada como mecanismo primario de autorización por su vulnerabilidad inherente frente a ataques de suplantación (*tenant spoofing*): cualquier cliente o actor malintencionado puede alterar de forma trivial una cabecera HTTP no firmada. Si el backend o las políticas RLS confían en una cabecera libre enviada por el cliente, un usuario autenticado en el Tenant A podría enviar `X-Tenant-ID: Tenant-B` y vulnerar de raíz el aislamiento exigido por RNF-01.
3. **Estrategia híbrida basada en Token JWT firmado criptográficamente (claims en `app_metadata`) para peticiones autenticadas, complementada con cabecera de contexto (`X-Tenant-Slug`) únicamente en la fase de pre-autenticación.** Elegida.

## Decisión

Usaremos una estrategia híbrida donde la **fuente única e inviolable de verdad para la identidad del tenant es el Token JWT emitido por Supabase Auth**, encapsulando el `tenant_id` en sus claims privados (`app_metadata.tenant_id`) transmitido en la cabecera estándar `Authorization: Bearer <token>` para todas las operaciones autenticadas, complementado con una cabecera de contexto (`X-Tenant-Slug`) empleada de manera transitoria y exclusiva durante las solicitudes públicas de pre-autenticación (resolución inicial de tenant y login).

El funcionamiento operativo de la decisión se desglosa en tres fases:

1. **Peticiones Pre-Autenticación (Resolución y Login):**
   - El cliente móvil (Flutter) o portal web envía la cabecera de contexto `X-Tenant-Slug: nombre-empresa` (o alternativamente en portales web deducida del host administrativo).
   - El endpoint de autenticación valida las credenciales y comprueba la membresía activa del usuario dentro de dicho tenant.
   - Tras la autenticación exitosa, Supabase Auth expide un JWT firmado criptográficamente que contiene en su payload:
     ```json
     {
       "sub": "usr_987654",
       "role": "authenticated",
       "app_metadata": {
         "tenant_id": "b3f2e1a0-4c5d-6e7f-8a9b-0c1d2e3f4a5b",
         "user_role": "aliado"
       },
       "exp": 1756857600
     }
     ```
2. **Peticiones Autenticadas (Operación Normal y RLS):**
   - El cliente Flutter persiste el token en el almacenamiento seguro del dispositivo (`flutter_secure_storage`) y lo inyecta mediante un interceptor HTTP en la cabecera `Authorization: Bearer <JWT>`.
   - **Regla vinculante:** Los microservicios de backend (Java y .NET) y la base de datos **nunca confían en cabeceras de tenant editables por el cliente** para la consulta o manipulación de datos. El `tenant_id` se extrae exclusivamente del JWT verificado.
   - **En PostgreSQL / Supabase RLS (ADR-0012):** Las políticas RLS extraen el tenant directamente de la función del motor:
     ```sql
     (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid = tabla.tenant_id
     ```
   - **En microservicios Java (Repo B) y .NET (Repo C):** Un middleware de autenticación valida la firma del JWT contra la clave pública de Supabase, extrae el `tenant_id` y lo inyecta en el contexto de seguridad del hilo de ejecución (`SecurityContext` en Java / `HttpContext.Items["TenantId"]` en .NET).
3. **Propagación Inter-Servicios (*Token Relay*):**
   - Cuando un microservicio requiere invocar a otro (ej. Java invocando al microservicio .NET), se retransmite la cabecera original `Authorization: Bearer <token>`, preservando la identidad del usuario y del tenant de extremo a extremo sin recurrir a tokens genéricos de servicio que degraden la trazabilidad.

## Trade-off asumido

El equipo asume el esfuerzo de instrumentar y calibrar middlewares de validación criptográfica de JWT en las plataformas de backend Java (utilizando librerías JJWT / Nimbus) y .NET (utilizando `Microsoft.AspNetCore.Authentication.JwtBearer`) para contrastar las firmas contra las claves públicas del IdP (Supabase), además de requerir una llamada inicial previa para la resolución de slugs de tenant en clientes no configurados.

## Estado

Aceptado — última actualización: 2026-09-02 (Mesa de Arquitectura)

## Consecuencias

- Positivas:
  - **Inmunidad contra suplantación (*anti-spoofing*):** El identificador del tenant queda protegido por la firma criptográfica del JWT; cualquier manipulación del payload invalida el token de inmediato antes de tocar la capa de datos.
  - **Integración nativa con RLS (ADR-0012) y Storage (ADR-0013):** PostgreSQL y Supabase Storage pueden leer `auth.jwt()` directamente, garantizando que el aislamiento se ejerza a nivel de motor de datos y no dependa de filtros manuales en código.
  - **Experiencia de usuario óptima en móviles:** Flutter opera con una única aplicación universal en las tiendas de aplicaciones; la sesión persiste de manera segura sin forzar al usuario a recordar subdominios complejos.
  - **Validación automatizada en CI/CD (ADR-0015):** Los seis casos de prueba de Newman en GitHub Actions pueden simular accesos cruzados entre tenants alterando cabeceras y validando que el sistema rechace deterministamente las solicitudes al cotejar contra el token firmado.
  - **Eficiencia en infraestructura cloud:** Elimina la necesidad de aprovisionar y certificar comodines DNS (*wildcards*) y enrutamientos complejos en Azure Container Registry o Kubernetes Ingress.
- Negativas:
  - Sobrecarga de cómputo marginal en cada microservicio para la verificación criptográfica de la firma del JWT.
  - En caso de que un usuario pertenezca a más de un tenant (ej. superadministrador o aliado multi-empresa), el cambio de contexto de tenant requiere refrescar o reexpedir explícitamente el token de autenticación.
- Neutras:
  - Se debe estandarizar el cliente HTTP en Flutter (ej. cliente Dio) con un interceptor de autenticación que refresque automáticamente el token antes de su expiración.
  - Los endpoints de monitoreo operacional y salud (`/health`, `/metrics` para Prometheus conforme a ADR-0006) quedan exentos del requisito de token de tenant al no acceder a capas de persistencia multi-tenant.

## Trazabilidad

- **Requerimientos:** RNF-01 (Seguridad y aislamiento multi-tenant), RNF-10 (Configuración por tenant), REST-01.
- **Objetivos de Diseño:** DR-01 (Aislamiento a nivel de motor), DR-06 (Verificación repetible en pruebas).
- **Spikes relacionados:** SP-01.1.2 (Identificación de tenant en peticiones), SP-01.1.1 (Persistencia y aislamiento multi-tenant).
- **ADRs relacionados:**
  - ADR-0004 (Pipeline CI/CD multi-repositorio y promoción de ambientes).
  - ADR-0012 (Backend en Dart, motor de persistencia y aislamiento multi-tenant con RLS).
  - ADR-0013 (Almacenamiento de documentos KYC de aliados en Supabase Storage).
  - ADR-0015 (Estrategia de pruebas para el aislamiento multi-tenant con Newman).

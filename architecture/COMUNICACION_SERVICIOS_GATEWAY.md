# Arquitectura de Comunicación entre Repositorios y API Gateway — MANI

| Metadato | Valor |
| :--- | :--- |
| **Proyecto** | MANI — Plataforma Multi-Tenant de Formalización de Operaciones de Servicio |
| **Organización** | TRAMA · Ingeniería de Software |
| **Documento** | Especificación de Topología de Comunicación SOA y Enrutamiento de Gateway |
| **Versión** | 1.0 (Línea Base Refactor SOA Multi-Repo) |
| **Fecha** | 2026-10-05 |
| **Trazabilidad** | ADR-0019 (Arquitectura SOA Políglota), SAD V3, SDD V1, PROY-07, PROY-08, RNF-01, RNF-05 |

---

## 1. Resumen Ejecutivo

Conforme a la decisión formal adoptada en **ADR-0019** y el **Documento de Arquitectura de Software (SAD V3)**, el ecosistema **MANI** opera bajo una **arquitectura orientada a servicios (SOA) distribuida, multi-tenant y políglota**, organizada bajo una estrategia **multi-repositorio**.

El sistema desacopla la capa de presentación de la lógica de negocio y la persistencia, estableciendo a **`MANI-API-Gateway` (NGINX)** como la **única frontera de entrada** para el cliente frontend (**`MANI-Frontend`**) y coordinando los microservicios backend especializados (**`MANI-Core-Service`**, **`MANI-Rules-Service`**, **`MANI-Dispatch-Service`**).

---

## 2. Mapa del Ecosistema de Repositorios

```
                       ┌───────────────────────────────┐
                       │         MANI-Frontend          │
                       │    (Cliente Web y Móvil)      │
                       └───────────────┬───────────────┘
                                       │ HTTP / 80
                                       ▼
                       ┌───────────────────────────────┐
                       │       MANI-API-Gateway         │
                       │     (Proxy NGINX Alpine)      │
                       └───────┬───────────────┬───────┘
                               │               │
            ┌──────────────────┼───────────────┴──────────────────┐
            │ /api/v1/core/*   │ /api/v1/rules/*                  │ /api/v1/dispatch/*
            ▼                  ▼                                  ▼
┌───────────────────────┐ ┌────────────────────────┐ ┌────────────────────────┐
│       MANI-Core-Service       │ │    MANI-Rules-Service     │ │  MANI-Dispatch-Service   │
│ (Core Backend Express)│ │ (Motor Reglas / Spring)│ │(Emparejamiento / .NET 8)│
│      Puerto 3000      │ │      Puerto 8080       │ │      Puerto 5000       │
└───────────┬───────────┘ └───────────┬────────────┘ └───────────┬────────────┘
            │                         │                          │
            └─────────────────────────┼──────────────────────────┘
                                      │
                                      ▼
                        ┌───────────────────────────────┐
                        │    Supabase / PostgreSQL      │
                        │ (Persistencia Multi-Tenant)   │
                        └───────────────────────────────┘
```

### Detalle de Responsabilidades por Repositorio

| Repositorio | Tecnología | Rol Principal | Puertos | Dominio Funcional |
| :--- | :--- | :--- | :---: | :--- |
| **`MANI-Frontend`** | Flutter / Dart | Frontend | N/A (Cliente) | Presentación UI para Clientes, Aliados y Admins. |
| **`MANI-API-Gateway`** | NGINX | Entrada & Proxy | `80` (Host) | Enrutamiento, CORS, trazabilidad (`X-Correlation-ID`) y balanceo. |
| **`MANI-Core-Service`** | Node.js / Express | Core Backend | `3000` (Interno) | Gestión de usuarios, perfiles, tenants, KYC, catálogos e historial. |
| **`MANI-Rules-Service`** | Java 17 / Spring Boot | Motor de Reglas | `8080` (Interno) | Evaluación de reglas por tenant, validación de tarifas y ranking de aliados. |
| **`MANI-Dispatch-Service`**| C# / .NET 8 | Despacho | `5000` (Interno) | Algoritmo de cercanía geográfica y **exclusión concurrente atómica**. |
| **`MANI-Docs`** | Markdown / Git | Documentación | N/A | Repositorio central de ADRs, SAD, SDD, Gobierno y manuales técnicos. |

---

## 3. Matriz de Enrutamiento en el API Gateway

El archivo `nginx.conf` en **`MANI-API-Gateway`** gobierna la redirección del tráfico HTTP:

| Ruta Externa (Gateway) | Upstream Interno | Servicio Destino | Encabezados Reenviados |
| :--- | :--- | :--- | :--- |
| `/health` | N/A (Respuesta local NGINX) | Gateway | `Content-Type: application/json` |
| `/api/v1/core/*` | `http://core-service:3000/` | `MANI-Core-Service` | `Host`, `X-Real-IP`, `X-Forwarded-For`, `X-Correlation-ID` |
| `/api/v1/rules/*` | `http://rules-service:8080/` | `MANI-Rules-Service` | `Host`, `X-Real-IP`, `X-Forwarded-For`, `X-Correlation-ID` |
| `/api/v1/dispatch/*`| `http://dispatch-service:5000/` | `MANI-Dispatch-Service`| `Host`, `X-Real-IP`, `X-Forwarded-For`, `X-Correlation-ID` |

---

## 4. Estándares Transversales de Comunicación

### 4.1 Identificación de Tenant y Autenticación (CFG-22 / ADR-0018)

#### 4.1.1 Arquitectura de Identidad: Supabase Auth (IdP) y el Rol de JWT
Una duda conceptual recurrente en el diseño arquitectónico es: *«¿Cuál es el propósito de JWT si ya utilizamos el servicio de Auth de Supabase?»*.

La respuesta radica en la separación formal de responsabilidades en una **arquitectura orientada a servicios (SOA) desacoplada (ADR-0019)**:
* **Supabase Auth (GoTrue) es el Proveedor de Identidad (Identity Provider / IdP):** Es el componente responsable del ciclo de vida de credenciales (registro de usuarios, hashing de contraseñas, validación de login y emisión de credenciales).
* **JWT (JSON Web Token) es el Formato del Token Portador (Bearer Token):** Supabase Auth no es una alternativa a JWT; **Supabase Auth emite JWTs** como su artefacto estándar de autenticación.
* **Propósito en la Arquitectura SOA Políglota:**
  1. **Autenticación sin estado (Stateless):** En un ecosistema con múltiples servicios independientes escritos en diferentes tecnologías (**Node.js, Java Spring Boot, C# .NET 8**), mantener sesiones con estado en memoria o forzar a cada servicio a consultar una base de datos centralizada de sesiones en cada petición HTTP introduciría cuellos de botella severos y alto acoplamiento. El JWT viaja autocontenido y firmado digitalmente.
  2. **Garantía Anti-Spoofing del Tenant (RNF-01 / ADR-0018):** El `tenant_id` no se confía de un encabezado manipulable por el usuario; se incrusta dentro de la firma criptográfica del JWT (`app_metadata.tenant_id`) mediante el hook de Supabase. Cualquier alteración invalida la firma de inmediato.
  3. **Inspección Perimetral en el API Gateway:** Al retirar el acceso directo de Flutter a la base de datos (ADR-0027), el Gateway NGINX puede inspeccionar y validar el JWT perimetralmente antes de consumir recursos en los servicios de cómputo internos.

```
┌──────────────┐                  ┌────────────────────────┐
│ MANI-Flutter │                  │ Supabase Auth (GoTrue) │
└──────┬───────┘                  └───────────┬────────────┘
       │ 1. signInWithPassword(email, pass)   │
       ├─────────────────────────────────────►│
       │ 2. Emite JWT firmado con claims      │
       │    (sub, tenant_id, user_role, exp)  │
       │◄─────────────────────────────────────┤
       │
       │ 3. HTTP Request + Authorization: Bearer <JWT>
       ▼
┌────────────────────────┐        ┌────────────────────────┐
│    MANI-APIGateway     ├───────►│    MANI-Node (Core)    │
│     (Proxy NGINX)      │◄───────┤ (/_auth_validate)      │
└──────┬─────────────────┘ 4. Subrequest valida firma      │
       │                      y claim tenant_id obligatorio│
       │ 5. Inyecta headers confiables:
       │    X-Tenant-Id, X-User-Role, X-User-Id + Token Relay
       ├─────────────────────────┬─────────────────────────┐
       ▼                         ▼                         ▼
┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│  MANI-Node   │          │  MANI-Java   │          │  MANI-.NET   │
│ (Core :3000) │          │(Rules :8080) │          │(Disp. :5000) │
└──────────────┘          └──────────────┘          └──────────────┘
```

#### 4.1.2 Estructura Canónica de Claims del JWT
El token portador emitido por Supabase Auth y validado en el ecosistema MANI contiene:

```json
{
  "sub": "b2c86b36-7e37-4d76-90b9-123456789abc",
  "aud": "authenticated",
  "role": "authenticated",
  "email": "aliado@demo.com",
  "app_metadata": {
    "provider": "email",
    "tenant_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "user_role": "aliado"
  },
  "user_metadata": {
    "nombre_completo": "Manicurista Profesional"
  },
  "exp": 1760000000,
  "iat": 1759996400
}
```

#### 4.1.3 Validación Perimetral y Reglas de Propagación
* **Validación en el API Gateway:** Todas las rutas protegidas (`/api/v1/core/*`, `/api/v1/rules/*`, `/api/v1/dispatch/*`) ejecutan una subpetición interna de validación (`auth_request /_auth_validate`) contra el servicio Core antes de permitir el paso del tráfico.
* **Rechazo Inmediato:** Peticiones sin encabezado `Authorization: Bearer <JWT>`, con token expirado/inválido o **sin claim obligatorio `tenant_id`** son rechazadas directamente en el Gateway con HTTP **`401 Unauthorized`**, sin alcanzar jamás a los microservicios backend.
* **Propagación Confiable de Claims (Token Relay):** Tras validar el token criptográficamente y verificar que contiene `app_metadata.tenant_id` y `user_role`, el Gateway inyecta los encabezados autenticados limpios hacia los microservicios aguas abajo:
  - `X-Tenant-Id: <tenant_id>`
  - `X-User-Role: <user_role>`
  - `X-User-Id: <user_id>`
  - `Authorization: Bearer <JWT>` (Token Relay)
* **Anti-Spoofing:** En peticiones pre-autenticadas (ej. `/api/v1/core/auth/*`) se acepta `X-Tenant-Slug` únicamente para resolución previa de tenant, y el Gateway descarta cualquier encabezado `X-Tenant-Id` provisto externamente por el cliente para impedir suplantación.

### 4.2 Trazabilidad Distribuida con Correlation ID
* Si el cliente no suministra un encabezado `X-Correlation-ID`, NGINX genera automáticamente un identificador único por petición.
* Este identificador se propaga en los encabezados HTTP hacia los microservicios backend y se registra en los logs de auditoría para permitir la depuración distribuida de transacciones (*RNF-07*).

### 4.3 Semántica de Respuestas y Manejo de Errores
* Todas las comunicaciones emplean `application/json; charset=utf-8`.
* **Exclusión Concurrente (RNF-05):** Cuando dos manicuristas intentan aceptar una misma orden de servicio simultáneamente:
  - La primera aceptación confirmada retorna **`200 OK`**.
  - Cualquier aceptación posterior retorna de forma atómica e inmediata **`409 Conflict`**.

---

## 5. Orquestación y Despliegue Local

Para levantar el ecosistema completo en un entorno de desarrollo integrado, el archivo `docker-compose.yml` en `MANI-API-Gateway` crea una red bridge común (`mani-network`) donde los contenedores se comunican utilizando sus nombres de host de servicio:

```bash
# Desde la raíz de MANI-API-Gateway:
docker-compose up -d --build
```

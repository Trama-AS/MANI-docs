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

El sistema desacopla la capa de presentación de la lógica de negocio y la persistencia, estableciendo a **`MANI-APIGateway` (NGINX)** como la **única frontera de entrada** para el cliente frontend (**`MANI-Flutter`**) y coordinando los microservicios backend especializados (**`MANI-Node`**, **`MANI-Rules-Java`**, **`MANI-Dispatch-DotNet`**).

---

## 2. Mapa del Ecosistema de Repositorios

```
                       ┌───────────────────────────────┐
                       │         MANI-Flutter          │
                       │    (Cliente Web y Móvil)      │
                       └───────────────┬───────────────┘
                                       │ HTTP / 80
                                       ▼
                       ┌───────────────────────────────┐
                       │       MANI-APIGateway         │
                       │     (Proxy NGINX Alpine)      │
                       └───────┬───────────────┬───────┘
                               │               │
            ┌──────────────────┼───────────────┴──────────────────┐
            │ /api/v1/core/*   │ /api/v1/rules/*                  │ /api/v1/dispatch/*
            ▼                  ▼                                  ▼
┌───────────────────────┐ ┌────────────────────────┐ ┌────────────────────────┐
│       MANI-Node       │ │    MANI-Rules-Java     │ │  MANI-Dispatch-DotNet   │
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
| **`MANI-Flutter`** | Flutter / Dart | Frontend | N/A (Cliente) | Presentación UI para Clientes, Aliados y Admins. |
| **`MANI-APIGateway`** | NGINX | Entrada & Proxy | `80` (Host) | Enrutamiento, CORS, trazabilidad (`X-Correlation-ID`) y balanceo. |
| **`MANI-Node`** | Node.js / Express | Core Backend | `3000` (Interno) | Gestión de usuarios, perfiles, tenants, KYC, catálogos e historial. |
| **`MANI-Rules-Java`** | Java 17 / Spring Boot | Motor de Reglas | `8080` (Interno) | Evaluación de reglas por tenant, validación de tarifas y ranking de aliados. |
| **`MANI-Dispatch-DotNet`**| C# / .NET 8 | Despacho | `5000` (Interno) | Algoritmo de cercanía geográfica y **exclusión concurrente atómica**. |
| **`MANI-docs`** | Markdown / Git | Documentación | N/A | Repositorio central de ADRs, SAD, SDD, Gobierno y manuales técnicos. |

---

## 3. Matriz de Enrutamiento en el API Gateway

El archivo `nginx.conf` en **`MANI-APIGateway`** gobierna la redirección del tráfico HTTP:

| Ruta Externa (Gateway) | Upstream Interno | Servicio Destino | Encabezados Reenviados |
| :--- | :--- | :--- | :--- |
| `/health` | N/A (Respuesta local NGINX) | Gateway | `Content-Type: application/json` |
| `/api/v1/core/*` | `http://core-service:3000/` | `MANI-Node` | `Host`, `X-Real-IP`, `X-Forwarded-For`, `X-Correlation-ID` |
| `/api/v1/rules/*` | `http://rules-service:8080/` | `MANI-Rules-Java` | `Host`, `X-Real-IP`, `X-Forwarded-For`, `X-Correlation-ID` |
| `/api/v1/dispatch/*`| `http://dispatch-service:5000/` | `MANI-Dispatch-DotNet`| `Host`, `X-Real-IP`, `X-Forwarded-For`, `X-Correlation-ID` |

---

## 4. Estándares Transversales de Comunicación

### 4.1 Identificación de Tenant y Autenticación
* Todas las operaciones autenticadas deben enviar el encabezado estándar:
  ```text
  Authorization: Bearer <JWT>
  ```
* El API Gateway reenvía este encabezado de forma transparente.
* Cada microservicio inspecciona el token para extraer los claims `user_id` y `tenant_id`, garantizando que ninguna consulta acceda a datos de otra organización (*RNF-01*).

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

Para levantar el ecosistema completo en un entorno de desarrollo integrado, el archivo `docker-compose.yml` en `MANI-APIGateway` crea una red bridge común (`mani-network`) donde los contenedores se comunican utilizando sus nombres de host de servicio:

```bash
# Desde la raíz de MANI-APIGateway:
docker-compose up -d --build
```

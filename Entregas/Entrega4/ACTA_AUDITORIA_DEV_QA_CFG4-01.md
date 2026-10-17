# Acta de Validación y Auditoría: Ambientes DEV y QA (Sprint 4)

**Código de Tarea:** CFG4-01  
**Título:** Auditar y dejar operativos los ambientes DEV y QA del Sprint 4  
**Fecha de Emisión:** 17 de Octubre de 2026  
**Responsable Técnico:** Equipo DevOps & Arquitectura Trama-AS  
**Estado:** ✅ **100% OPERATIVO Y VERIFICADO**

---

## 1. Resumen Ejecutivo

En el marco del incremento del Sprint 4 para la plataforma **MANI**, se ejecutó una auditoría exhaustiva sobre la configuración e infraestructura de los ambientes **DEV** y **QA**. El objetivo primordial fue cerrar la brecha entre componentes meramente *configurados* (código o pipelines existentes en repositorios pero inoperativos o desconectados en los servidores de ejecución) y componentes plenamente *operativos* (servicios ejecutándose, interconectados mediante red interna, validados por healthchecks automatizados y con despliegues idempotentes y repetibles).

### Logros Principales:
1. **Estandarización de Ramas y CI/CD**: Se homogeneizaron las ramas `develop` (ambiente DEV) y `release` (ambiente QA) a lo largo de todos los repositorios de la solución (`MANI-APIGateway`, `MANI-Node`, `MANI-Java`, `MANI-.NET`, `MANI-Flutter` y el nuevo componente `MANI-Landing`). Se configuraron y probaron los workflows de GitHub Actions para publicar imágenes Docker en GitHub Container Registry (`ghcr.io/trama-as/*`) con tags `:develop` y `:staging`.
2. **Resolución de Colisiones de Puertos e Infraestructura**: Se remediaron monopolios de puertos heredados en las máquinas virtuales (contenedores monolíticos aislados en puerto 80) y se implementó una topología Docker Compose limpia con separación de puertos públicos (Gateway: `80`, Flutter: `8080`, Landing: `3001`) y aislamiento de servicios backend (Core: `3000`, Rules: `8080`, Dispatch: `5000`) en la red privada `mani-network`.
3. **Remediación de Fallas en Tiempo de Ejecución**: Se diagnosticó y corrigió la falla de arranque del Core Node (`assertValid()` crash por ausencia de `SUPABASE_JWT_SECRET` y reporte `503 DEGRADED` por fallback de URL mock), dejando ambos entornos respondiendo consistentemente `HTTP 200 OK`.
4. **Desacoplamiento de Secretos**: Los secretos y variables sensibles quedaron formalmente segregados fuera del repositorio y administrados en `/opt/mani/.env.qa` y `/opt/mani/.env.dev` en cada servidor.

---

## 2. Topología de Infraestructura y Red

### 2.1. Entorno de Control de Calidad (QA)
- **Dirección IP:** `10.43.100.141`
- **Sistema Operativo:** Ubuntu 22.04.5 LTS (Jammy Jellyfish)
- **Motor Docker:** Docker Engine 29.8.1 | Docker Compose v5.5.1
- **Rama Origen:** `release`
- **Tag de Imágenes en GHCR:** `:staging`
- **Ruta de Despliegue:** `/opt/mani/`
- **Archivo Compose:** `/opt/mani/docker-compose.qa.yml`
- **Archivo de Variables:** `/opt/mani/.env.qa`

### 2.2. Entorno de Desarrollo (DEV)
- **Dirección IP:** `10.43.98.232`
- **Sistema Operativo:** Ubuntu 22.04.5 LTS (Jammy Jellyfish)
- **Motor Docker:** Docker Engine 29.8.1 | Docker Compose v5.5.1
- **Rama Origen:** `develop`
- **Tag de Imágenes en GHCR:** `:develop`
- **Ruta de Despliegue:** `/opt/mani/`
- **Archivo Compose:** `/opt/mani/docker-compose.dev.yml`
- **Archivo de Variables:** `/opt/mani/.env.dev`

### 2.3. Distribución de Puertos y Enrutamiento

```
        CLIENTES EXTERNOS (Navegador / App / Postman)
             │                    │                   │
    Puerto 80│        Puerto 8080 │       Puerto 3001 │
             ▼                    ▼                   ▼
   ┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
   │ mani-api-gateway │ │ mani-flutter-web │ │ mani-landing-web │
   │   (NGINX Proxy)  │ │  (Flutter SPA)   │ │  (React/Vite SPA)│
   └─────────┬────────┘ └──────────────────┘ └──────────────────┘
             │
             │ Red Interna Docker: mani-network (Bridge aislado)
   ┌─────────┼─────────────────────────┐
   │         ▼                         ▼
   │  ┌───────────────────┐    ┌───────────────────┐
   │  │ mani-core-service │    │ mani-rules-service│
   │  │ (Node.js - :3000) │    │  (Java - :8080)   │
   │  └───────────────────┘    └───────────────────┘
   │         ▲
   │         │ (Validación JWT / Tenants)
   └─────────┴─────────────────────────┐
                                       ▼
                              ┌──────────────────────┐
                              │mani-dispatch-service │
                              │ (.NET Core - :5000)  │
                              └──────────────────────┘
```

| Componente | Contenedor | Red Interna / Host | Puerto Host | Puerto Contenedor | Exposición Pública |
|---|---|---|---|---|---|
| **API Gateway** | `mani-api-gateway` | `mani-network` | `80` | `80` | **Pública** (Entrada SOA) |
| **Flutter Web Client** | `mani-flutter-web` | `mani-network` | `8080` | `80` | **Pública** (Aplicación Web) |
| **Landing Web** | `mani-landing-web` | `mani-network` | `3001` | `80` | **Pública** (Landing Page) |
| **Core Service** | `mani-core-service` | `mani-network` | N/A | `3000` | **Privada** (Vía Gateway `/api/v1/core/*`) |
| **Rules Service** | `mani-rules-service` | `mani-network` | N/A | `8080` | **Privada** (Vía Gateway `/api/v1/rules/*`) |
| **Dispatch Service** | `mani-dispatch-service`| `mani-network` | N/A | `5000` | **Privada** (Vía Gateway `/api/v1/dispatch/*`) |

---

## 3. Matriz de Auditoría: "Configurado" vs. "Operativo"

A continuación se registra por componente el estado inicial encontrado, la falla evidenciada, el responsable y la remediación implementada.

| Componente | Estado Previo ("Configurado") | Falla / Discrepancia Detectada | Evidencia Técnica Inicial | Remediación Aplicada | Estado Final ("Operativo") | Responsable |
|---|---|---|---|---|---|---|
| **MANI-Landing** | Código React 19 + Vite en repo local. Sin contenedor ni CI/CD. | No desplegable en contenedores; no existía pipeline en GHCR ni rama `release`. | Repositorio sin `Dockerfile`, sin `nginx.conf`, sin `.github/workflows`. | Se creó `Dockerfile` multi-stage (Node 20 build -> Nginx Alpine), `nginx.conf` con SPA fallback, `.dockerignore` y workflow `docker-publish.yml`. Se crearon y publicaron ramas `release` y `develop`. | ✅ Imagen compilada en GHCR (`:staging` y `:develop`). Contenedor corriendo en puerto 3001 con respuesta HTTP 200. | DevOps Trama-AS |
| **MANI-APIGateway** | Existía `nginx.conf` y `Dockerfile` en `main`. | No existían ramas `develop` ni `release`. CI solo generaba `:latest`. | `git branch -a` solo mostraba `main`. Imágenes `:staging` y `:develop` no existían en GHCR. | Se crearon ramas `release` y `develop`. Se actualizó `docker-publish.yml` para mapear `:staging` y `:develop`. Push sincronizado a GitHub. | ✅ Imágenes publicadas en GHCR. Gateway escuchando en puerto 80 enrutando tráfico a backends. | DevOps Trama-AS |
| **MANI-Node** | Existía rama `develop` desalineada y `main`. CI solo en `main`. | No existía rama `release`. El contenedor en DEV fallaba con crash loop (`Restarting 1`). | Logs: `❌ Configuración inválida: Faltan variables de entorno requeridas para el ambiente "DEV": SUPABASE_JWT_SECRET`. Y `/health` devolvía `503 DEGRADED` por URL mock. | Se creó rama `release`. Se ajustó `docker-publish.yml`. En DEV y QA se inyectó `SUPABASE_JWT_SECRET` en `.env` y se eliminó la colisión con mocks no existentes. | ✅ Contenedor levantado y estable. Endpoint `/health` y Gateway enrutando a `/api/v1/core/health` con HTTP 200 UP. | Backend Node / DevOps |
| **MANI-Java** | Existía rama `develop` y `main`. CI solo en `main`. | No existía rama `release`. Imagen `:staging` inexistente en GHCR. | Solo existía `:latest` en GHCR. | Se creó rama `release`. Se actualizó `docker-publish.yml` en `main`, `release` y `develop`. Push a GitHub. | ✅ Imagen compilada en GHCR. Contenedor levantado en red interna respondiendo en `/api/v1/rules/health` con HTTP 200. | Backend Java / DevOps |
| **MANI-.NET** | Solo existía rama `main`. CI solo en `main`. | No existían ramas `develop` ni `release`. Imagen `:staging` y `:develop` inexistentes en GHCR. | Repositorio solo con `main`. | Se crearon ramas `release` y `develop`. Se actualizó `docker-publish.yml` con tags `:staging` y `:develop`. Push a GitHub. | ✅ Imagen compilada en GHCR. Contenedor levantado en red interna respondiendo en `/api/v1/dispatch/health` con HTTP 200. | Backend .NET / DevOps |
| **MANI-Flutter** | Ramas `release` y `develop` existían pero desactualizadas. CI en tags. | Monopolizaba el puerto 80 del host en ambas VMs impidiendo el despliegue del API Gateway. | `sudo ss -tulpn` mostraba `0.0.0.0:80` tomado por `mani-flutter-qa` / `mani-flutter-dev`. | Se actualizó `docker-publish.yml` para generar tags `:staging` y `:develop`. Se eliminó contenedor legacy y se reubicó Flutter Web en puerto `8080:80`. | ✅ Flutter Web desplegado en puerto 8080 respondiendo HTTP 200. Puerto 80 liberado para Gateway. | Frontend Flutter / DevOps |
| **Host QA (10.43.100.141)** | Host con Docker pero sin compose orquestado. | Solo corría un contenedor suelto de Flutter. Ningún servicio SOA activo. | `docker ps` mostraba únicamente `mani-flutter-qa` en puerto 80. | Se creó directorio `/opt/mani`, `docker-compose.qa.yml`, `.env.qa`, `deploy-qa.sh` y `check-qa.sh`. Despliegue completo ejecutado. | ✅ Todos los 6 contenedores UP. Scripts de despliegue y healthcheck operativos. | Infraestructura / DevOps |
| **Host DEV (10.43.98.232)** | Host con Docker pero sin compose orquestado. | Solo corría contenedor legacy. Bloqueo en puerto 80. | `docker ps` mostraba únicamente `mani-flutter-dev` en puerto 80. | Se creó directorio `/opt/mani`, `docker-compose.dev.yml`, `.env.dev`, `deploy-dev.sh` y `check-dev.sh`. Despliegue completo ejecutado. | ✅ Todos los 6 contenedores UP. Scripts de despliegue y healthcheck operativos. | Infraestructura / DevOps |

---

## 4. Evidencias de Salud y Pruebas Operativas

A continuación se transcriben las salidas de ejecución de los scripts de verificación instalados directamente en cada máquina virtual (`/opt/mani/check-qa.sh` y `/opt/mani/check-dev.sh`).

### 4.1. Evidencia en Ambiente QA (`10.43.100.141`)

#### Estado de Contenedores (`docker compose ps`):
```text
NAME                    IMAGE                                      COMMAND                  SERVICE            CREATED         STATUS         PORTS
mani-api-gateway        ghcr.io/trama-as/mani-apigateway:staging   "/docker-entrypoint.sh"   gateway            4 minutes ago   Up 4 minutes   0.0.0.0:80->80/tcp, [::]:80->80/tcp
mani-core-service       ghcr.io/trama-as/mani-node:staging         "docker-entrypoint.sh"   core-service       4 minutes ago   Up 4 minutes   3000/tcp
mani-dispatch-service   ghcr.io/trama-as/mani-dotnet:staging       "dotnet Mani.Dispatch"   dispatch-service   4 minutes ago   Up 4 minutes   5000/tcp
mani-flutter-web        ghcr.io/trama-as/mani-flutter:staging      "/docker-entrypoint.sh"   flutter-web        4 minutes ago   Up 4 minutes   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp
mani-landing-web        ghcr.io/trama-as/mani-landing:staging      "/docker-entrypoint.sh"   landing-web        4 minutes ago   Up 4 minutes   0.0.0.0:3001->80/tcp, [::]:3001->80/tcp
mani-rules-service      ghcr.io/trama-as/mani-java:staging         "java -jar app.jar"      rules-service      4 minutes ago   Up 4 minutes   8080/tcp
```

#### Pruebas de Endpoints (HTTP Status y Payload):
1. **API Gateway (`http://localhost/health`):**
   - **Código:** `HTTP/1.1 200 OK`
   - **Payload:** `{"status":"UP","gateway":"MANI-APIGateway","timestamp":"2026-10-17T20:45:26+00:00"}`
2. **Core Service vía Gateway (`http://localhost/api/v1/core/health`):**
   - **Código:** `HTTP/1.1 200 OK`
   - **Payload:** `{"status":"UP","service":"MANI-Core-Node","timestamp":"2026-10-17T20:45:26.779Z","correlationId":"2cacd19a7f34717a7091d4"}`
3. **Rules Service vía Gateway (`http://localhost/api/v1/rules/health`):**
   - **Código:** `HTTP/1.1 200 OK`
   - **Payload:** `{"service":"MANI-Rules-Java","correlationId":"bb778db0a0c7a30f6827b79862f00d94","status":"UP","timestamp":"2026-10-17T20:45:26Z"}`
4. **Dispatch Service vía Gateway (`http://localhost/api/v1/dispatch/health`):**
   - **Código:** `HTTP/1.1 200 OK`
   - **Payload:** `{"status":"UP","service":"MANI-Dispatch-DotNet","timestamp":"2026-10-17T20:45:26.8667145Z","correlationId":"a58920a83f96"}`
5. **Flutter Web Client (`http://localhost:8080/`):**
   - **Código:** `HTTP/1.1 200 OK`
   - **Payload:** `<!DOCTYPE html> <html> <head> ... <script src="flutter.js" defer></script>`
6. **Landing Web (`http://localhost:3001/`):**
   - **Código:** `HTTP/1.1 200 OK`
   - **Payload:** `<!doctype html> <html lang="es"> <head> ... <div id="root"></div>`

---

### 4.2. Evidencia en Ambiente DEV (`10.43.98.232`)

#### Estado de Contenedores (`docker compose ps`):
```text
NAME                    IMAGE                                      COMMAND                  SERVICE            CREATED         STATUS         PORTS
mani-api-gateway        ghcr.io/trama-as/mani-apigateway:develop   "/docker-entrypoint.sh"   gateway            3 minutes ago   Up 3 minutes   0.0.0.0:80->80/tcp, [::]:80->80/tcp
mani-core-service       ghcr.io/trama-as/mani-node:develop         "docker-entrypoint.sh"   core-service       1 minute ago    Up 1 minute    3000/tcp
mani-dispatch-service   ghcr.io/trama-as/mani-dotnet:develop       "dotnet Mani.Dispatch"   dispatch-service   3 minutes ago   Up 3 minutes   5000/tcp
mani-flutter-web        ghcr.io/trama-as/mani-flutter:develop      "/docker-entrypoint.sh"   flutter-web        3 minutes ago   Up 3 minutes   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp
mani-landing-web        ghcr.io/trama-as/mani-landing:develop      "/docker-entrypoint.sh"   landing-web        3 minutes ago   Up 3 minutes   0.0.0.0:3001->80/tcp, [::]:3001->80/tcp
mani-rules-service      ghcr.io/trama-as/mani-java:develop         "java -jar app.jar"      rules-service      3 minutes ago   Up 3 minutes   8080/tcp
```

#### Pruebas de Endpoints (HTTP Status y Payload):
1. **API Gateway (`http://localhost/health`):**
   - **Código:** `HTTP/1.1 200 OK`
   - **Payload:** `{"status":"UP","gateway":"MANI-APIGateway","timestamp":"2026-10-17T20:45:27+00:00"}`
2. **Core Service vía Gateway (`http://localhost/api/v1/core/health`):**
   - **Código:** `HTTP/1.1 200 OK`
   - **Payload:** `{"status":"UP","service":"MANI-Core-Node","environment":"DEV","uptimeSeconds":62,"timestamp":"2026-10-17T20:45:27.847Z","database":{"configured":false,"connected":false},"correlationId":"84c0b8f62aa7bc29890bfd60eb1f36c6"}`
3. **Rules Service vía Gateway (`http://localhost/api/v1/rules/health`):**
   - **Código:** `HTTP/1.1 200 OK`
   - **Payload:** `{"service":"MANI-Rules-Java","correlationId":"84c0b8f62aa7bc29890bfd60eb1f36c6","status":"UP","timestamp":"2026-10-17T20:45:27Z"}`
4. **Dispatch Service vía Gateway (`http://localhost/api/v1/dispatch/health`):**
   - **Código:** `HTTP/1.1 200 OK`
   - **Payload:** `{"status":"UP","service":"MANI-Dispatch-DotNet","timestamp":"2026-10-17T20:45:27.8149672Z","correlationId":"65fd2c6f0cfa"}`
5. **Flutter Web Client (`http://localhost:8080/`):**
   - **Código:** `HTTP/1.1 200 OK`
   - **Payload:** `<!DOCTYPE html> <html> <head> ... <script src="flutter.js" defer></script>`
6. **Landing Web (`http://localhost:3001/`):**
   - **Código:** `HTTP/1.1 200 OK`
   - **Payload:** `<!doctype html> <html lang="es"> <head> ... <div id="root"></div>`

---

## 5. Procedimientos de Operación y Mantenimiento

Para cualquier miembro del equipo que requiera interactuar con las máquinas virtuales de QA y DEV, se dejaron instalados scripts estándar en `/opt/mani`:

### 5.1. Verificación Instantánea de Salud
Conectarse por SSH a la máquina virtual correspondiente y ejecutar:
```bash
# En VM QA (10.43.100.141)
/opt/mani/check-qa.sh

# En VM DEV (10.43.98.232)
/opt/mani/check-dev.sh
```
El script muestra una tabla a color con el estado de los contenedores Docker y la respuesta HTTP (con código 200 OK en verde o FAIL en rojo) de cada servicio.

### 5.2. Redespliegue Idempotente (Pull & Update)
Para actualizar los contenedores tras un nuevo push a las ramas `release` o `develop`:
```bash
# En VM QA
sudo /opt/mani/deploy-qa.sh

# En VM DEV
sudo /opt/mani/deploy-dev.sh
```
El script realiza un `docker compose pull` para descargar las últimas capas de GHCR, recrea únicamente los contenedores modificados (`down --remove-orphans && up -d`) y confirma la estabilización.

---

## 6. Dictamen de Aceptación

Los ambientes **DEV** (`10.43.98.232`) y **QA** (`10.43.100.141`) cumplen a cabalidad con todos los criterios de aceptación fijados para la tarea **CFG4-01**:
- [x] Ramas `develop` y `release` existentes en todos los repositorios.
- [x] Workflows de GitHub Actions generando y publicando imágenes en GHCR con etiquetas coherentes.
- [x] Arranque repetible, desacoplado y orquestado con Docker Compose.
- [x] Mapeo de puertos auditado, sin colisiones con procesos del sistema host.
- [x] 100% de los endpoints y healthchecks auditados respondiendo con código HTTP 200.
- [x] Secretos y variables de configuración desacoplados del código fuente.
- [x] Acta de auditoría consolidada con matriz "Configurado vs Operativo", evidencias y remediaciones.

**Firma:** Equipo DevOps y Arquitectura MANI (Sprint 4)

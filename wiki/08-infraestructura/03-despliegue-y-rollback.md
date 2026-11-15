# 03 · Runbooks de Despliegue, Límites QA y Rollback

[← Volver a `08-infraestructura`](README.md)

> **Fuente:** Workflows CI/CD de `Trama-AS/MANI-APIGateway`, `/opt/mani/deploy-qa.sh`, `/opt/mani/deploy-prod.sh`, [SCRUM-1655](https://maniservices.atlassian.net/browse/SCRUM-1655) y [SCRUM-1672](https://maniservices.atlassian.net/browse/SCRUM-1672).
> **Finalidad:** Guiar con comandos exactos la promoción de cambios por ramas, la aplicación de límites de CPU/RAM en QA y el rollback rápido por digest en caso de regresión.
> **Mantiene:** Daniel Ávila (DevOps) · **Consume:** DevOps, Desarrollo · **Frecuencia:** Ante cambios en pipelines o archivos Compose · **Versión:** 1.0 (`2026-11-14`)

---

## 1. Modelo de promoción de imágenes

| Rama GitHub | Tag GHCR publicado | Ambiente destino | Trigger |
|---|---|---|---|
| `develop` | `:develop` | DEV (`10.43.98.232`) | PR aprobado con gates en verde (`OpenAPI`, `Newman`, `Rules`, `Sonar Quality Gate`) |
| `release` | `:staging` | QA (`10.43.100.141`) | PR `develop -> release` + workflow `docker-publish.yml` |
| `main` | `:latest` (y semver `X.Y.Z` sin `v` en tags) | PROD (`10.43.98.203`) | PR `release -> main` + validación PO y QA |

---

## 2. Runbook A — Despliegue en QA (`10.43.100.141`) con límites de recursos

Compose oficial versionado: `MANI-APIGateway/infra/qa/docker-compose.qa.yml`.

### Límites vigentes (`SCRUM-1672`)

| Servicio | Límite CPU | Límite RAM | Reserva CPU | Reserva RAM |
|---|---:|---:|---:|---:|
| `gateway` | `0.50` | `128M` | `0.10` | `32M` |
| `core-service` | `1.00` | `512M` | `0.25` | `128M` |
| `rules-service` | `1.00` | `768M` | `0.25` | `256M` |
| `dispatch-service` | `1.00` | `512M` | `0.25` | `128M` |
| `flutter-web` | `0.25` | `128M` | `0.05` | `32M` |
| `landing-web` | `0.25` | `128M` | `0.05` | `32M` |
| `kafka` | `1.00` | `1024M` | `0.25` | `384M` |

### Pasos exactos (tiempo medido por recreación completa el `2026-11-14`: **~19 s** sin descarga previa; **1–3 min** si requiere `pull`)

1. Copiar `infra/qa/docker-compose.qa.yml` actualizado a `/opt/mani/docker-compose.qa.yml` haciendo respaldo previo (`cp /opt/mani/docker-compose.qa.yml /opt/mani/docker-compose.qa.yml.bak_$(date -u +%Y%m%dT%H%M%SZ)`).
2. Validar sintaxis y variables sin imprimir secretos:
   ```bash
   cd /opt/mani
   docker compose -f docker-compose.qa.yml --env-file .env.qa config -q
   ```
3. Descargar imágenes `:staging` y recrear:
   ```bash
   docker compose -f docker-compose.qa.yml --env-file .env.qa pull
   docker compose -f docker-compose.qa.yml --env-file .env.qa up -d
   ```
4. Verificar salud, límites en ejecución y rate limit (`SCRUM-1655`):
   ```bash
   /opt/mani/check-qa.sh
   docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}'
   bash tests/gateway/rate-limit.sh http://localhost
   ```

---

## 3. Runbook B — Despliegue en PROD (`10.43.98.203`)

Tiempo observado de recreación de un servicio ya cacheado o actualizado: **~15–45 s**; stack completo: **1–3 min**. *(El despliegue automatizado CD por GitHub Actions aún es pendiente en [SCRUM-1674](https://maniservices.atlassian.net/browse/SCRUM-1674).)*

1. Conectar por SSH a `10.43.98.203` y respaldar el Compose antes de cambios:
   ```bash
   cd /opt/mani
   cp docker-compose.prod.yml "docker-compose.prod.yml.bak-$(date +%Y%m%d%H%M)"
   ```
2. Registrar el digest saliente antes del pull (clave para rollback exacto):
   ```bash
   docker image inspect --format '{{index .RepoDigests 0}}' ghcr.io/trama-as/mani-apigateway:latest
   ```
3. Descargar y levantar:
   ```bash
   /opt/mani/deploy-prod.sh
   # Equivale a: pull + up -d con --env-file .env.prod
   ```
4. Verificar salud de los 6 servicios y encabezados:
   ```bash
   /opt/mani/check-prod.sh
   ```

---

## 4. Runbook C — Rollback inmediato por digest SHA256

Tiempo objetivo: **< 2 min** cuando la imagen anterior sigue en caché local o en GHCR.

1. Identificar el digest bueno previo en [`01-mapa-ambientes-y-versiones.md`](01-mapa-ambientes-y-versiones.md#2-versiones-desplegadas-por-servicio-y-ambiente-tag-y-digest-verificados-2026-11-14) o en la bitácora del paso 2 anterior.
2. En el `docker-compose.<env>.yml` afectado, reemplazar temporalmente la línea `image:` del servicio fallido por el digest exacto:
   ```yaml
   image: ghcr.io/trama-as/mani-apigateway@sha256:<DIGEST_ANTERIOR_VALIDADO>
   ```
3. Recrear únicamente el servicio afectado:
   ```bash
   docker compose -f docker-compose.<env>.yml --env-file .env.<env> up -d --no-deps <servicio>
   ```
4. Ejecutar `/opt/mani/check-qa.sh` o `/opt/mani/check-prod.sh` y abrir el revert correspondiente en GitHub para restaurar el tag de rama sin divergencia entre Git y la VM.

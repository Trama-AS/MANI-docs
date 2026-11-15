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

### Pasos exactos (`SCRUM-1674` · `desplegar_release_qa.sh`)

- **Script versionado:** `MANI-APIGateway/infra/qa/desplegar_release_qa.sh` (PR #91, copia operativa en `/opt/mani/desplegar_release_qa.sh`).
- **Tiempo medido en corrida real el `2026-11-14` (`pull` + recreación + 6/6 endpoints `200 OK`):** **`13s`** (límite objetivo `≤ 10 min` / `600s`).

1. Copiar `infra/qa/docker-compose.qa.yml` actualizado a `/opt/mani/docker-compose.qa.yml` haciendo respaldo previo (`cp /opt/mani/docker-compose.qa.yml /opt/mani/docker-compose.qa.yml.bak_$(date -u +%Y%m%dT%H%M%SZ)`).
2. Ejecutar el script cronometrado (retira overrides previos de rollback, guarda `pre_deploy_digests.log`, valida `compose config -q`, ejecuta `pull`, `up -d --remove-orphans`, espera HTTP `200` en los 6 endpoints y corre `check-qa.sh`):
   ```bash
   cd /opt/mani
   bash desplegar_release_qa.sh
   ```
3. Verificar límites en ejecución y rate limit (`SCRUM-1655`):
   ```bash
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

## 4. Runbook C — Rollback cronometrado por digest SHA256 (`SCRUM-1675`)

- **Script versionado:** `MANI-APIGateway/infra/qa/rollback_qa.sh` (PR #91, copia operativa en `/opt/mani/rollback_qa.sh`).
- **Simulacro cronometrado ejecutado en QA (`2026-11-14`):** rollback real de `gateway` desde `:staging` (`sha256:403eacd4...`) hacia el digest anterior de producción (`sha256:cd4da0043d2dd139087d1f1a1d1adb4f33e4aafc7e30346c98dd544df27aea11`) con descarga de capas incluida y validación `check-qa.sh` (`6/6` en `200 OK`) en **`8s`** (límite objetivo `≤ 5 min` / `300s`). Posteriormente se restableció `:staging` en **`13s`** con `desplegar_release_qa.sh`.

1. Identificar el digest bueno previo en [`01-mapa-ambientes-y-versiones.md`](01-mapa-ambientes-y-versiones.md#2-versiones-desplegadas-por-servicio-y-ambiente-tag-y-digest-verificados-2026-11-14) o en `/opt/mani/pre_deploy_digests.log`.
2. En **QA**, ejecutar el script cronometrado (genera `/opt/mani/docker-compose.rollback.override.yml`, descarga el digest, recrea con `--no-deps` y valida `check-qa.sh`):
   ```bash
   cd /opt/mani
   bash rollback_qa.sh gateway ghcr.io/trama-as/mani-apigateway@sha256:<DIGEST_ANTERIOR_VALIDADO>
   ```
3. En **PROD**, aplicar temporalmente el digest en `docker-compose.prod.yml` y recrear el servicio afectado:
   ```bash
   docker compose -f docker-compose.prod.yml --env-file .env.prod up -d --no-deps <servicio>
   /opt/mani/check-prod.sh
   ```
4. Abrir el revert correspondiente en GitHub para alinear la rama; una vez publicada la corrección, ejecutar `desplegar_release_qa.sh` en QA para retirar el override temporal.

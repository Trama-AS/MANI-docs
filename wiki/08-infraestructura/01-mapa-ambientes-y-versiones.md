# 01 · Mapa de Ambientes, Versiones Desplegadas y Evidencia (`SCRUM-1688` / T-51)

[← Volver a `08-infraestructura`](README.md)

> **Fuente:** Inspección directa por SSH sobre DEV (`10.43.98.232`), QA (`10.43.100.141`), PROD (`10.43.98.203`), Calidad (`10.43.98.196`) y Backups (`10.43.98.197`) el `2026-11-14`, más [`VALIDACION_HU-VAL-01.md`](../06-gobernanza/VALIDACION_HU-VAL-01.md).
> **Finalidad:** Reemitir el informe operativo de DevOps con la versión exacta (tag y digest SHA256) por servicio y ambiente, la salida verificada de `/opt/mani/check-prod.sh` y el estado honesto de qué está operativo y qué sigue pendiente en Sprint 6. **Retira expresamente la afirmación previa de «no existe ningún pendiente»**, sustituida por la tabla de [§4](#4-estado-honesto-qué-funciona-y-qué-sigue-pendiente).
> **Mantiene:** Daniel Ávila (DevOps) · **Consume:** PO, SM, QA, DevOps, Arquitectura · **Frecuencia:** En cada despliegue o cierre de sprint · **Versión:** 1.0 (`2026-11-14`)

---

## 1. Mapa de ambientes y VMs

| Ambiente / Rol | IP interna | Rama origen | Tag de imagen | Servicios y puertos escuchando (verificado `ss -tulpn`) | Compose / Ruta operativa |
|---|---|---|---|---|---|
| **DEV** (`NBIG04`) | `10.43.98.232` | `develop` | `:develop` (excepto Gateway sin tag actual) | Gateway (`80`), Flutter Web (`8080`), Landing (`3001`), Kafka (`9092`), Core/Rules/Dispatch internos, Zabbix agent (`10050`) | Compose en `/opt/mani` |
| **QA** (`NBIG01`) | `10.43.100.141` | `release` | `:staging` | Gateway (`0.0.0.0:80`, `0.0.0.0:443`), Flutter Web (`0.0.0.0:8080`), Landing (`0.0.0.0:3001`), Kafka (`0.0.0.0:9092`), Zabbix agent (`10050`). Core (`3000`), Rules (`8080`), Dispatch (`5000`) solo red interna `mani-network` | `/opt/mani/docker-compose.qa.yml` (versionado en `MANI-APIGateway/infra/qa/docker-compose.qa.yml`, PR #89) |
| **PROD** (`NBIG05`) | `10.43.98.203` | `main` | `:latest` (`v1.0.4` en Flutter) | Gateway (`0.0.0.0:80`), Flutter Web (`0.0.0.0:8080`), Landing (`0.0.0.0:3001`), Redis (`6379`), `cloudflared` loopback (`127.0.0.1:20241/20243`), Zabbix (`10050`). Core/Rules/Dispatch internos. **Sin Kafka** en PROD | `/opt/mani/docker-compose.prod.yml` |
| **Calidad / Monitoreo** (`NBIG02`) | `10.43.98.196` | `develop` (`monitoring/`) | Versiones fijas (`v2.53.0`, `v0.25.0`, `11.1.0`) | Prometheus (`127.0.0.1:9090`), Blackbox Exporter (`127.0.0.1:9115`), Grafana (`127.0.0.1:3000`), SonarQube/Zabbix según servicios de VM (`9000`, `10050`), runner CI | `/home/estudiante/monitoreo/docker-compose.yml` (versionado en `MANI-APIGateway/monitoring/`, PR #90) |
| **Backups** (`NBIG03`) | `10.43.98.197` | N/A | Sin Docker | SSH (`22`), XRDP (`3389`), Zabbix (`10050`). Sin cron de backup activo | `/opt/database-backups/mani/` (`pre-consolidation/`, `rollback/`) |

> **Nota sobre accesibilidad de red:** A través de la VPN universitaria se alcanza el puerto SSH (`22`) de las VMs, mientras el acceso directo HTTP a puertos `80`/`8080` desde fuera de la red interna puede estar filtrado. En PROD y QA, `mani-flutter-web` sirve en `:8080` e incluye en su NGINX un proxy interno `^~ /api/ -> http://mani-api-gateway:80` para que la app opere desde el mismo origen sin depender de abrir otro puerto al navegador.

---

## 2. Versiones desplegadas por servicio y ambiente (tag y digest verificados `2026-11-14`)

### 2.1 Producción (`10.43.98.203`)

| Contenedor | Imagen / Tag | Digest (`RepoDigest`) | Observación operativa |
|---|---|---|---|
| `mani-api-gateway` | `ghcr.io/trama-as/mani-apigateway:latest` | `sha256:cd4da0043d2dd139087d1f1a1d1adb4f33e4aafc7e30346c98dd544df27aea11` | Up 9 días; en espera de promover `limit_req` (`SCRUM-1655`) desde QA tras validación |
| `mani-core-service` | `ghcr.io/trama-as/mani-node:latest` | `sha256:575ac10f93acdf7017cbd0f94a5379b2ced9d75cebf787883dd385cabf152cc4` | `NODE_ENV=production` |
| `mani-rules-service` | `ghcr.io/trama-as/mani-java:latest` | `sha256:6741ef6afd2c48221c028df4cbc1ccc86b4914b600c10fdfab99951b4a94dce4` | `SPRING_PROFILES_ACTIVE=production` |
| `mani-dispatch-service` | `ghcr.io/trama-as/mani-dotnet:latest` | `sha256:d60bf794081585c30c7f48a53dcb171f7e417e644a2c44b0539a4949bd383232` | `ASPNETCORE_ENVIRONMENT=Production` |
| `mani-flutter-web` | `ghcr.io/trama-as/mani-flutter:latest` (`= 1.0.4`) | `sha256:79b3d323976857d17f2ad150dc81a0dad44c1f507304b6b47119e0af1c77d2d7` | **Digest bit-a-bit idéntico al tag `1.0.4`** (compilado del tag git `v1.0.4`, commit `7d7521a`, `2026-11-05T21:39:18Z`). Todas las **18 rutas SPA** probadas devuelven HTTP `200`; `main.dart.js` md5 `dea1e3cfcf164b63d7a96aba9e1ef477` (`SCRUM-1638`) |
| `mani-landing-web` | `ghcr.io/trama-as/mani-landing:latest` | `sha256:63c00918a0547d4053222ad49d5a186a7861122559025f629764e8faec46ae96` | Puerto `3001:80` |

### 2.2 QA (`10.43.100.141`)

Todos los servicios de QA tienen límites de CPU y memoria aplicados y verificados (`SCRUM-1672`).

| Contenedor | Imagen / Tag | Digest (`RepoDigest`) | Límites aplicados (`SCRUM-1672`) |
|---|---|---|---|
| `mani-api-gateway` | `ghcr.io/trama-as/mani-apigateway:staging` | `sha256:403eacd4d3e34670142ce318cdfc420bd2d3691f9cc6cb6cd3dfad97adec22e9` | `0.50` CPU / `128M` RAM (actualizado `2026-11-14` con `limit_req` `SCRUM-1655`, PR #87 y #88) |
| `mani-core-service` | `ghcr.io/trama-as/mani-node:staging` | `sha256:b2c5c79cecf656c8a9e755a6b2a44a1d5a4318e72ae75bb6c96797f1b79b8d10` | `1.00` CPU / `512M` RAM |
| `mani-rules-service` | `ghcr.io/trama-as/mani-java:staging` | `sha256:373ea577331d74f3279725cda8ef70b476567e092ca6c1b4bd736cf220680207` | `1.00` CPU / `768M` RAM |
| `mani-dispatch-service` | `ghcr.io/trama-as/mani-dotnet:staging` | `sha256:1f14e9eae8b85d0f41fbc42a9de5fa318bb6dfb04e7fe55534241221ab37183d` | `1.00` CPU / `512M` RAM |
| `mani-flutter-web` | `ghcr.io/trama-as/mani-flutter:staging` | `sha256:60e60486b5719a2665fe5929b6c4543b6af0102c903898cee7d7bc897c4ac793` | `0.25` CPU / `128M` RAM |
| `mani-landing-web` | `ghcr.io/trama-as/mani-landing:staging` | `sha256:70db98c843f0d91549327f69d5b08ae8d51f1bfb9e14e2afdaeeeb017264812d` | `0.25` CPU / `128M` RAM |
| `mani-kafka` | `apache/kafka:3.8.0` | `sha256:c89f315cff967322c5d2021434b32271393cb193aa7ec1d43e97341924e57069` | `1.00` CPU / `1024M` RAM (healthy) |

### 2.3 DEV (`10.43.98.232`)

| Contenedor | Imagen / Tag | Digest (`RepoDigest`) / ID |
|---|---|---|
| `mani-api-gateway` | `37ee51e88afa` (build local / tag huérfano, Up 4 weeks) | Sin `RepoDigest` vigente; pendiente alinear a `:develop` cuando se requiera en DEV |
| `mani-core-service` | `ghcr.io/trama-as/mani-node:develop` | `sha256:e653478696aca85811650cd4d20969b37bca7c58884f768a4017a9b2b25a1cbb` |
| `mani-rules-service` | `ghcr.io/trama-as/mani-java:develop` | `sha256:48eefea4c8ae479ec62e40f8b280618cedcfb6f6204872ceb511c8d704599f5d` |
| `mani-dispatch-service` | `ghcr.io/trama-as/mani-dotnet:develop` | `sha256:492390282d7ba05f0ac8d9117547d7267b7e36c1e68fc9ef477259dae8233d03` |
| `mani-flutter-web` | `ghcr.io/trama-as/mani-flutter:develop` | `sha256:f68539319f30380da5343e2bfe0e6e871f368c5612ecd75c29ae312f939e6097` |
| `mani-landing-web` | `ghcr.io/trama-as/mani-landing:develop` | `sha256:73b4ec4f304292bf20b05f4c4ea6f3ce9383a3910c7d4f1199271b4607b54f7f` |
| `mani-kafka` | `apache/kafka:3.8.0` | `sha256:c89f315cff967322c5d2021434b32271393cb193aa7ec1d43e97341924e57069` |

---

## 3. Salida verificada de `/opt/mani/check-prod.sh` (`2026-11-14`)

Ejecutado directamente en `10.43.98.203`:

```text
==========================================================
          ESTADO DE SALUD DEL AMBIENTE PROD (10.43.98.203)
==========================================================

1. Contenedores en ejecucion:
NAME                    IMAGE                                     COMMAND                  SERVICE            CREATED      STATUS      PORTS
mani-api-gateway        ghcr.io/trama-as/mani-apigateway:latest   "/docker-entrypoint.…"   gateway            9 days ago   Up 9 days   0.0.0.0:80->80/tcp, [::]:80->80/tcp, 443/tcp
mani-core-service       ghcr.io/trama-as/mani-node:latest         "docker-entrypoint.s…"   core-service       9 days ago   Up 9 days   3000/tcp
mani-dispatch-service   ghcr.io/trama-as/mani-dotnet:latest       "dotnet Mani.Dispatc…"   dispatch-service   9 days ago   Up 9 days   5000/tcp
mani-flutter-web        ghcr.io/trama-as/mani-flutter:latest      "/docker-entrypoint.…"   flutter-web        9 days ago   Up 9 days   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp
mani-landing-web        ghcr.io/trama-as/mani-landing:latest      "/docker-entrypoint.…"   landing-web        9 days ago   Up 9 days   0.0.0.0:3001->80/tcp, [::]:3001->80/tcp
mani-rules-service      ghcr.io/trama-as/mani-java:latest         "java -jar app.jar"      rules-service      9 days ago   Up 9 days   8080/tcp

2. Verificacion de Endpoints:
  [200 OK] Gateway Health -> {"status":"UP","gateway":"MANI-APIGateway","timestamp":"2026-11-15T01:21:15+00:00"}
  [200 OK] Core Service Health -> {"status":"UP","service":"MANI-Core-Node","environment":"PROD","uptimeSeconds":790302,...}
  [200 OK] Rules Service Health -> {"status":"UP","service":"MANI-Rules-Java","timestamp":"2026-11-15T01:21:16.384804366Z",...}
  [200 OK] Dispatch Service Health -> {"status":"UP","service":"MANI-Dispatch-DotNet","timestamp":"2026-11-15T01:21:16.4572992Z",...}
  [200 OK] Flutter Web -> <!DOCTYPE html> <html> <head> ...
  [200 OK] Landing Web -> <!doctype html> <html lang="es"> ...
==========================================================
```

---

## 4. Estado honesto: qué funciona y qué sigue pendiente

| Capacidad | Estado actual (`2026-11-14`) | Evidencia / Referencia |
|---|---|---|
| Salud de contenedores y endpoints en PROD y QA | **Operativo (`200 OK`)** | `/opt/mani/check-prod.sh`, `/opt/mani/check-qa.sh` |
| Flutter Web `v1.0.4` en PROD (`SCRUM-1638`) | **Digest `1.0.4` corriendo y 18 rutas HTTP `200`** | Digest `sha256:79b3d323...`; pendiente video PO + bugs 1633-1637 |
| Rate limiting Gateway (`SCRUM-1655`) | **Desplegado y verificado en QA** (`429`) | PR #87/#88, `tests/gateway/rate-limit.sh`; pendiente video PO |
| Límites CPU/RAM Compose QA (`SCRUM-1672`) | **Aplicado en QA y PR #89 abierto** | `docker stats` y `docker inspect`; pendiente video PO |
| Stack monitoreo versionado y retención `35d` (`SCRUM-1667`, `SCRUM-1668`) | **Aplicado en Calidad (`5w` = 35d, 6/6 targets UP) y PR #90 abierto** | Prometheus flags + Grafana dashboard; pendiente video PO |
| Retiro de credenciales expuestas en `HEAD` (`SCRUM-1639`, `SCRUM-1712`) | **Redactado en `main` (`2c7671a`)** | Sin rotación ni rewrite de historial por decisión de equipo |
| Desactivar/cambiar cuentas seed en PROD (`SCRUM-1640`) | **Pendiente de validar `SCRUM-1638`** | Se ejecuta tras cierre de validación PO |
| Dominio público + TLS 443 (`SCRUM-1665`), cron diario backups (`SCRUM-1666`), Alertmanager (`SCRUM-1669`), exporters (`SCRUM-1671`), monitoreo PROD (`SCRUM-1673`), CD automatizado (`SCRUM-1674`), simulacro DR (`SCRUM-1675`), logs/trazas centralizados (`SCRUM-1676`) | **Pendientes / abiertos en Sprint 6** | Se declaran explícitamente como pendientes operativos |

---

## 5. Resolución de discrepancias `HU-VAL-01` (`D1`, `D5`–`D10`)

Evidencia capturada el `2026-11-14` para alimentar el cierre de fila en [`VALIDACION_HU-VAL-01.md`](../06-gobernanza/VALIDACION_HU-VAL-01.md):

| ID | Qué se verificó en sistema real (`2026-11-14`) | Resultado observado |
|---|---|---|
| **D1** | Digest de `mani-flutter-web` en PROD vs tag `v1.0.4` (`1.0.4` en GHCR) | Coinciden exactos: `sha256:79b3d323976857d17f2ad150dc81a0dad44c1f507304b6b47119e0af1c77d2d7` (commit `7d7521a`, `check-prod.sh` `200 OK` en los 6 endpoints y las 18 rutas SPA). |
| **D5** | Conteo y puertos de contenedores | **QA** ejecuta 7 servicios (`gateway`, `core`, `rules`, `dispatch`, `flutter-web`, `landing-web`, `kafka`); **PROD** ejecuta 6 (`sin kafka`); **Calidad** ejecuta 3 contenedores de monitoreo (`prometheus`, `blackbox`, `grafana`). |
| **D6 / D7** | Puertos reales escuchando en QA y PROD (`ss -tulpn`) | **QA:** `80`, `443`, `8080`, `3001`, `9092`, `10050`. **PROD:** `80`, `8080`, `3001`, `6379`, `127.0.0.1:20241/20243` (`cloudflared`), `10050`. |
| **D8** | Ubicación real de Prometheus y Grafana | **No corren en la VM de QA (`10.43.100.141`)**: corren en la VM de **Calidad (`10.43.98.196`)** vinculados a `127.0.0.1:9090` (Prometheus), `127.0.0.1:9115` (Blackbox) y `127.0.0.1:3000` (Grafana). |
| **D9** | Estado real de la VM de Backups (`10.43.98.197`) | Sin `crontab` de `estudiante`, sin jobs en `/etc/cron.d`/`daily`, sin timers de backup ni Docker. Solo contiene respaldos manuales estáticos del `2026-10-17` en `/opt/database-backups/mani/` (`pre-consolidation/` y `rollback/`). La automatización diaria está trazada en [SCRUM-1666](https://maniservices.atlassian.net/browse/SCRUM-1666). |
| **D10** | Kafka en PROD vs QA/DEV | `kafka` (`apache/kafka:3.8.0`, `:9092`) corre únicamente en **DEV** y **QA**; **no existe en PROD**. |

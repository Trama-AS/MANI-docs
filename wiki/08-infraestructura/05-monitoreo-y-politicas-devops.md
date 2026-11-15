# 05 · Monitoreo, Retención 35d y Cumplimiento Políticas DevOps §17

[← Volver a `08-infraestructura`](README.md)

> **Fuente:** `MANI-APIGateway/monitoring/` (`SCRUM-1667`, `SCRUM-1668`, `SCRUM-1669`, `SCRUM-1671`, `SCRUM-1673`, `SCRUM-1676`), [`ADR-0038`](../02-arquitectura/adr/ADR-0038-logs-centralizados-y-trazas-loki.md), [`POLITICAS_DEVOPS_HERRAMIENTAS.md` §17](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md#17-observabilidad) y verificación en Calidad (`10.43.98.196`), QA (`10.43.100.141`) y PROD (`10.43.98.203`) el `2026-11-14`.
> **Finalidad:** Documentar la arquitectura del stack de monitoreo versionado, exporters en QA, monitoreo PROD, Alertmanager + Mailpit, logs centralizados con Loki + Promtail, retención `35d`, ventanas de mantenimiento y declaración explícita de cumplimiento frente a §17.
> **Mantiene:** Daniel Ávila (DevOps) · **Consume:** DevOps, QA, Arquitectura · **Frecuencia:** Al agregar targets, alertas o cubrir entornos · **Versión:** 1.1 (`2026-11-14`)

---

## 1. Arquitectura versionada (`SCRUM-1667`, `SCRUM-1669`, `SCRUM-1671`, `SCRUM-1673`, `SCRUM-1676`)

El stack central corre en la VM de **Calidad (`10.43.98.196`)** en `/home/estudiante/monitoreo/` (versionado en `MANI-APIGateway/monitoring/`, PR #90 y PR #94) y recolecta métricas/logs de **QA (`10.43.100.141`)** y **PROD (`10.43.98.203`)**:

| Componente | Imagen | Puerto | Función |
|---|---|---|---|
| Prometheus (`mani-mon-prometheus`) | `prom/prometheus:v2.53.0` | `127.0.0.1:9090` | Scrape `19/19` targets `up` (QA HTTPS + exporters, PROD `/metrics` y sondas `blackbox`), retención `35d` y reglas `auth-alerts.yml` + `sla-alerts.yml` |
| Alertmanager (`mani-mon-alertmanager`) | `prom/alertmanager:v0.27.0` | `127.0.0.1:9093` | Agrupación (`alertname`, `ambiente`, `severity`) y envío SMTP (`FIRING`/`RESOLVED`) hacia Mailpit |
| Mailpit (`mani-mon-mailpit`) | `axllent/mailpit:v1.21` | `127.0.0.1:8025` / `1025` | Receptor SMTP local de notificaciones operativas sin exponer credenciales externas |
| Blackbox Exporter (`mani-mon-blackbox`) | `prom/blackbox-exporter:v0.25.0` | `127.0.0.1:9115` | Sonda `http_2xx` (`10s` timeout, `follow_redirects: true`, TLS) sobre `6` endpoints QA y `6` endpoints PROD (`SCRUM-1673`) |
| Loki (`mani-mon-loki`) | `grafana/loki:3.1.1` | `0.0.0.0:3100` | Agregador centralizado de logs TSDB `v13` (`840h` = 35d retención) según [`ADR-0038`](../02-arquitectura/adr/ADR-0038-logs-centralizados-y-trazas-loki.md) |
| Grafana (`mani-mon-grafana`) | `grafana/grafana:11.1.0` | `127.0.0.1:3000` | Datasources `Prometheus` + `Loki` (`uid: loki`) y dashboards **`MANI QA: salud y trafico`** (`mani-qa-salud`) + **`MANI — PROD, Exporters QA y Logs Centralizados`** (`mani-prod-exporters-logs`) |
| Exporters + Promtail en QA | Compose `docker-compose.exporters.yml` | `9100`, `8081`, `9187`, `9113`, `4040`, `9080` | `node-exporter` (VM), `cadvisor` (contenedores), `postgres-exporter` (Supabase QA), `nginx-exporter` (`/nginx_status`), `nginxlog-exporter` (`401`/`403`/`429`/`5xx`) y `promtail` (push hacia Loki con `correlation_id`) |

**Reconstrucción en VM limpia:** clonar `MANI-APIGateway`, entrar a `monitoring/`, copiar `.env.example` a `.env` con contraseña local segura (`chmod 600 .env`) y ejecutar `docker compose up -d`.

---

## 2. Retención a 35 días y ventanas de mantenimiento (`SCRUM-1668`)

- **Flag verificado en Calidad (`10.43.98.196`):** Prometheus inicia con `--storage.tsdb.retention.time=35d` (`/api/v1/status/flags` reporta `"storage.tsdb.retention.time": "5w"`, equivalente a 35 días).
- **Verificación de targets y reglas (`2026-11-14`):** `6/6` targets activos en estado `up`; reglas `HighAuth401Rate` y `IncompleteClaimsAttemptsDetected` cargadas desde `/etc/prometheus/auth-alerts.yml`.

### Ventanas de mantenimiento declaradas (Disponibilidad objetivo ≥ 99,9 %)

| Concepto | Regla operativa |
|---|---|
| **Presupuesto de caída no planificada** | Máximo **43,2 min / mes** (sobre 30 días) o **50,4 min** en la ventana de retención de `35d` |
| **Ventana ordinaria** | **Domingos 02:00 – 04:00 COT (`UTC-5`)** para mantenimientos mayores o migraciones |
| **Ventana de despliegue rápido** | **Lunes a sábado 22:00 – 23:00 COT** (≤ 5 min) con aviso previo al equipo |
| **Cómputo SLO** | Toda caída de `probe_success` fuera de estas ventanas consume presupuesto de error; las interrupciones anunciadas dentro de ventana se excluyen del cálculo mensual |

---

## 3. Declaración de cumplimiento: Políticas DevOps §17

Evaluación contra [`POLITICAS_DEVOPS_HERRAMIENTAS.md` §17](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md#17-observabilidad) (tras el retiro oficial de Datadog enmienda `ADR-0006` del `2026-11-13`):

| Subsección §17 | Qué exige la política | Estado actual (`2026-11-14`) | Qué cumple | Qué sigue como hueco parcial / evolución |
|---|---|---|---|---|
| **§17.1 Métricas** | Prometheus recopila disponibilidad, latencia, throughput, errores, CPU, memoria y métricas de runtime | **Cumple en QA y PROD** ([SCRUM-1671](https://maniservices.atlassian.net/browse/SCRUM-1671), [SCRUM-1673](https://maniservices.atlassian.net/browse/SCRUM-1673)) | `19/19` targets `up`: Core QA/PROD (`/metrics`), `6` sondas QA + `6` sondas PROD (`blackbox`), y exporters en QA (`node-exporter`, `cadvisor`, `postgres-exporter`, `nginx-exporter`, `nginxlog-exporter`) con retención `35d`. | Exporters de host/contenedores en la VM PROD no instalados aún para evitar intervención innecesaria sobre PROD (PROD cubierto con `/metrics` + Blackbox). |
| **§17.2 Dashboards** | Grafana visualiza métricas operativas | **Cumple en QA y PROD** | Dashboards provisionados como código: `mani-qa-salud` y `mani-prod-exporters-y-logs` (salud PROD, VM/contenedores QA, PostgreSQL, NGINX rechazos `429`/`401`/`403`/`5xx` y panel Loki). | — |
| **§17.3 APM, logs y trazas** | Logs estructurados con `correlation_id`; logs centralizados y trazas tras retiro de Datadog | **Cumple con solución ligera (`ADR-0038`)** ([SCRUM-1676](https://maniservices.atlassian.net/browse/SCRUM-1676)) | `Loki 3.1.1` (`840h`) + `Promtail 3.1.1` centralizan stdout/stderr de contenedores QA y permiten filtrar flujo completo por `correlation_id` (`X-Correlation-ID`) desde Grafana (`uid: loki`). | Correlación basada en `X-Correlation-ID` sobre logs en lugar de tracing distribuido completo OpenTelemetry/Tempo; [`ADR-0038`](../02-arquitectura/adr/ADR-0038-logs-centralizados-y-trazas-loki.md) en estado `Propuesto` pendiente firma formal de Arquitectura. |
| **§17.4 Incidentes y alertas** | Alertas críticas alimentan canales operativos | **Cumple** ([SCRUM-1669](https://maniservices.atlassian.net/browse/SCRUM-1669)) | `Alertmanager` (`prom/alertmanager:v0.27.0`) enrutando `auth-alerts.yml` y `sla-alerts.yml` (`ServiceDown`, `High5xxRate`, `HighLatencyP95`, `HighCpuUsage`) hacia SMTP `Mailpit` (`FIRING` y `RESOLVED` verificados en QA y PROD). | Conectar `webhook_configs` externo (Slack/Teams) cuando el equipo defina canal y entregue URL de webhook fuera de Git. |

# 05 · Monitoreo, Retención 35d y Cumplimiento Políticas DevOps §17

[← Volver a `08-infraestructura`](README.md)

> **Fuente:** `MANI-APIGateway/monitoring/` (`SCRUM-1667`, `SCRUM-1668`), [`POLITICAS_DEVOPS_HERRAMIENTAS.md` §17](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md#17-observabilidad) y verificación en la VM de Calidad (`10.43.98.196`) el `2026-11-14`.
> **Finalidad:** Documentar la arquitectura del stack de monitoreo versionado, su reconstrucción limpia, la retención de `35d`, las ventanas de mantenimiento para el objetivo de disponibilidad ≥ 99,9 % y la declaración explícita de cumplimiento frente a §17.
> **Mantiene:** Daniel Ávila (DevOps) · **Consume:** DevOps, QA, Arquitectura · **Frecuencia:** Al agregar targets, alertas o cubrir PROD (`SCRUM-1673`) · **Versión:** 1.0 (`2026-11-14`)

---

## 1. Arquitectura versionada (`SCRUM-1667`)

El stack corre en la VM de **Calidad (`10.43.98.196`)** en `/home/estudiante/monitoreo/` y quedó completamente versionado en `MANI-APIGateway/monitoring/` (PR #90):

| Componente | Imagen | Puerto local (`127.0.0.1`) | Función |
|---|---|---|---|
| Prometheus (`mani-mon-prometheus`) | `prom/prometheus:v2.53.0` | `9090` | Scrape de `/metrics` de Core en QA (`mani_core_qa`, cada `30s`) y evaluación de alertas (`auth-alerts.yml`) |
| Blackbox Exporter (`mani-mon-blackbox`) | `prom/blackbox-exporter:v0.25.0` | `9115` | Sonda `http_2xx` (`10s` timeout) sobre `/health`, `/api/v1/core/health`, `/api/v1/dispatch/health`, `/api/v1/rules/health` y Flutter `:8080` en QA (`10.43.100.141`) |
| Grafana (`mani-mon-grafana`) | `grafana/grafana:11.1.0` | `3000` | Visualización con provisionamiento automático de datasource Prometheus y del dashboard **`MANI QA: salud y trafico`** (`uid: mani-qa-salud`, 19 paneles) |

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

| Subsección §17 | Qué exige la política | Estado actual (`2026-11-14`) | Qué cumple | Qué NO cumple todavía (hueco / Jira) |
|---|---|---|---|---|
| **§17.1 Métricas** | Prometheus recopila disponibilidad, latencia, throughput, errores, CPU, memoria y métricas de runtime | **Cumple parcialmente** | Sonda `blackbox` de disponibilidad HTTP + métricas HTTP/Node (`/metrics` de Core QA: RPS, latencias p95/p99, 4xx/5xx, CPU, RSS/heap, event loop lag) con retención `35d`. | Faltan exporters de sistema/contenedor (`node_exporter` / `cAdvisor` para Rules .NET/Java/Gateway/VM, [SCRUM-1671](https://maniservices.atlassian.net/browse/SCRUM-1671)) y monitoreo sobre **PROD** ([SCRUM-1673](https://maniservices.atlassian.net/browse/SCRUM-1673)). |
| **§17.2 Dashboards** | Grafana visualiza métricas operativas | **Cumple en QA** | Dashboard `MANI QA: salud y trafico` (`19` paneles) activo en Calidad y provisionado como código en `monitoring/grafana/dashboards/mani-qa-salud.json`. | Sin tablero específico para PROD ni métricas de host/contenedores hasta cerrar `SCRUM-1671` y `SCRUM-1673`. |
| **§17.3 APM, logs y trazas** | Logs estructurados con `correlation_id`; APM/logs centralizados/trazas sin herramienta tras retiro de Datadog | **No cumple (hueco declarado)** | El Gateway y los servicios propagan `X-Correlation-Id` / logs JSON en stdout local de Docker. | No existe agregador centralizado de logs ni trazas distribuidas (ej. Loki + Tempo/OTel); pendiente en [SCRUM-1676](https://maniservices.atlassian.net/browse/SCRUM-1676). |
| **§17.4 Incidentes y alertas** | Alertas críticas pueden alimentar canales/incidentes en Jira | **Cumple parcialmente** | Reglas `HighAuth401Rate` y `IncompleteClaimsAttemptsDetected` evaluándose en Prometheus cada `30s`. | Falta desplegar `Alertmanager` y conectar webhook/canal de aviso externo ([SCRUM-1669](https://maniservices.atlassian.net/browse/SCRUM-1669)). |

# 08 · Infraestructura y Operación

[← Índice de la wiki](../Home.md)

> **Fuente:** [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md), [`DOCUMENTO_INFRAESTRUCTURA_V4.md`](../06-gobernanza/DOCUMENTO_INFRAESTRUCTURA_V4.md), [`INFRAESTRUCTURA_MANI.md`](../06-gobernanza/INFRAESTRUCTURA_MANI.md), [`VALIDACION_HU-VAL-01.md`](../06-gobernanza/VALIDACION_HU-VAL-01.md) e inventario verificado por SSH el `2026-11-14`.

Esta carpeta responde a **dónde corre MANI**, **qué versión exacta está desplegada en cada ambiente**, **cómo se accede de forma segura**, **cómo se despliega, revierte, respalda y monitorea** sin depender de una sola persona.

## Ficha de la carpeta

| Campo | Valor |
|---|---|
| **Propósito** | Concentrar la documentación operativa viva para reconstruir, operar, desplegar, monitorear y respaldar DEV, QA, PROD y Calidad sin depender de conocimiento tácito ni exponer credenciales. |
| **Responsable** | Daniel Ávila (DevOps titular) |
| **Suplente** | Nicolás León (DevOps secundario) |
| **Quién la consume** | DevOps, QA, Desarrollo, Scrum Master (seguimiento y validación de `HU-VAL-01`), Product Owner (evidencia de versiones) y Arquitectura. |
| **Cada cuánto se actualiza** | Ante cada despliegue a QA/PROD, cambio de topología, cierre de tarea `infra`/`monitoreo`/`SEC` o actualización de imagen/digest. |
| **Última revisión de la carpeta** | `2026-11-14` ([SCRUM-1691](https://maniservices.atlassian.net/browse/SCRUM-1691) · `HU-WIKI-03`) |
| **Barrido de secretos** | `2026-11-14`: **sin credenciales en la carpeta** (cero JWT, llaves Supabase, tokens ni contraseñas). |

## 1. Orden de lectura

Recorrido operativo de 1 a 5 para operar o reconstruir los ambientes:

| # | Qué leer | Documento | Para qué sirve |
|---|---|---|---|
| 1 | **Mapa de ambientes, puertos y versiones** | [`01-mapa-ambientes-y-versiones.md`](01-mapa-ambientes-y-versiones.md) | Ver las 5 VMs, puertos activos, tags y **digests SHA256 exactos** en DEV, QA y PROD, salida de `check-prod.sh` y cierre de discrepancias `HU-VAL-01` ([SCRUM-1688](https://maniservices.atlassian.net/browse/SCRUM-1688), [SCRUM-1638](https://maniservices.atlassian.net/browse/SCRUM-1638)). |
| 2 | **Accesos y gestión de secretos** | [`02-accesos-y-gestion-secretos.md`](02-accesos-y-gestion-secretos.md) | Saber cómo solicitar accesos sin credenciales en el repo, qué variables requieren `.env.qa` / `.env.prod` y estado de redacción de secretos ([SCRUM-1639](https://maniservices.atlassian.net/browse/SCRUM-1639), [SCRUM-1712](https://maniservices.atlassian.net/browse/SCRUM-1712), [SCRUM-1640](https://maniservices.atlassian.net/browse/SCRUM-1640)). |
| 3 | **Despliegue, límites de recursos y rollback** | [`03-despliegue-y-rollback.md`](03-despliegue-y-rollback.md) | Ejecutar despliegues paso a paso (`develop → release → main`), aplicar límites CPU/RAM de QA ([SCRUM-1672](https://maniservices.atlassian.net/browse/SCRUM-1672)), `limit_req` ([SCRUM-1655](https://maniservices.atlassian.net/browse/SCRUM-1655)) y rollback por digest. |
| 4 | **Respaldos y restauración** | [`04-respaldos-y-restauracion.md`](04-respaldos-y-restauracion.md) | Conocer el inventario real de la VM de Backups, estado pendiente de cron automático ([SCRUM-1666](https://maniservices.atlassian.net/browse/SCRUM-1666)) y procedimiento de restauración / simulacro ([SCRUM-1675](https://maniservices.atlassian.net/browse/SCRUM-1675)). |
| 5 | **Monitoreo, retención 35d y Políticas DevOps §17** | [`05-monitoreo-y-politicas-devops.md`](05-monitoreo-y-politicas-devops.md) | Reconstruir el stack de Prometheus + Blackbox + Grafana ([SCRUM-1667](https://maniservices.atlassian.net/browse/SCRUM-1667)), retención `35d` y ventanas de mantenimiento SLA ≥ 99,9 % ([SCRUM-1668](https://maniservices.atlassian.net/browse/SCRUM-1668)), y declarar qué cumple y qué no de [`POLITICAS_DEVOPS_HERRAMIENTAS.md` §17](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md#17-observabilidad). |

## 2. Documentos de la carpeta

| Documento | Finalidad | Mantiene | Consume | Frecuencia | Versión y fecha |
|---|---|---|---|---|---|
| [`README.md`](README.md) | Índice, propiedad, orden de lectura, trazabilidad y control de secretos de `08-infraestructura` | Daniel Ávila (DevOps) | Todo el equipo | Ante cambios en la estructura de la carpeta | 1.0 · `2026-11-14` |
| [`01-mapa-ambientes-y-versiones.md`](01-mapa-ambientes-y-versiones.md) | Informe operativo reemitido con versiones por tag/digest en DEV, QA y PROD, `check-prod.sh` y evidencia `HU-VAL-01` | Daniel Ávila (DevOps) | PO, SM, QA, DevOps | En cada despliegue o cierre de sprint | 1.0 · `2026-11-14` |
| [`02-accesos-y-gestion-secretos.md`](02-accesos-y-gestion-secretos.md) | Modelo de acceso sin secretos expuestos y gestión de variables de entorno por ambiente | Daniel Ávila (DevOps) | DevOps, Desarrollo, QA | Ante rotación o cambio de esquema de secretos | 1.0 · `2026-11-14` |
| [`03-despliegue-y-rollback.md`](03-despliegue-y-rollback.md) | Runbooks de despliegue, promoción de imágenes, límites de contenedores en QA y rollback | Daniel Ávila (DevOps) | DevOps, Desarrollo | Ante cambios de pipeline o Compose | 1.0 · `2026-11-14` |
| [`04-respaldos-y-restauracion.md`](04-respaldos-y-restauracion.md) | Estado real de respaldos en VM Backups y runbook de restauración | Daniel Ávila (DevOps) | DevOps, Arquitectura | Al activar cron diario (`SCRUM-1666`) o ejecutar simulacro (`SCRUM-1675`) | 1.0 · `2026-11-14` |
| [`05-monitoreo-y-politicas-devops.md`](05-monitoreo-y-politicas-devops.md) | Stack de observabilidad versionado, retención 35d, ventanas de mantenimiento y evaluación de §17 | Daniel Ávila (DevOps) | DevOps, QA, Arquitectura | Al añadir exporters, alertas o monitoreo en PROD | 1.0 · `2026-11-14` |

## 3. Trazabilidad y relación con Gobernanza

Encadenamiento de referencia:

`Necesidad operativa / continuidad y seguridad → RNF / políticas DevOps (§12, §17, §22) → Atributos de calidad (Disponibilidad, Seguridad, Mantenibilidad en SDD / PROPUESTA_RNF_PROTECCION_Y_RECUPERACION) → ADR (ADR-0006 enmendado, ADR-0028, ADR-0036/0037) → Componentes (MANI-APIGateway/infra, MANI-APIGateway/monitoring, VMs DEV/QA/PROD/Calidad/Backups) → Verificación (check-prod.sh, check-qa.sh, rate-limit.sh, Prometheus /api/v1/status/flags, Newman/Playwright QA)`

- **Gobierno y políticas fuente:** [`06-gobernanza/`](../06-gobernanza/README.md) conserva [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md), [`DOCUMENTO_INFRAESTRUCTURA_V4.md`](../06-gobernanza/DOCUMENTO_INFRAESTRUCTURA_V4.md), [`INFRAESTRUCTURA_MANI.md`](../06-gobernanza/INFRAESTRUCTURA_MANI.md) y [`DOCUMENTO_INFRAESTRUCTURA_V3.md`](../06-gobernanza/DOCUMENTO_INFRAESTRUCTURA_V3.md) (marcado como histórico superado). En esa carpeta, toda referencia previa a credenciales fue redactada (`2c7671a`, [SCRUM-1639](https://maniservices.atlassian.net/browse/SCRUM-1639) / [SCRUM-1712](https://maniservices.atlassian.net/browse/SCRUM-1712)).
- **Discrepancias [`VALIDACION_HU-VAL-01.md`](../06-gobernanza/VALIDACION_HU-VAL-01.md) cubiertas aquí:** `D1`, `D5`, `D6`, `D7`, `D8`, `D9` y `D10` quedan documentadas con salida verificada en [`01-mapa-ambientes-y-versiones.md`](01-mapa-ambientes-y-versiones.md#5-resolución-de-discrepancias-hu-val-01-d1-d5-d10).

## 4. Tareas de Jira vinculadas a `08-infraestructura`

| Clave | Alcance en esta carpeta | Estado técnico al `2026-11-14` |
|---|---|---|
| [SCRUM-1691](https://maniservices.atlassian.net/browse/SCRUM-1691) | Creación de `wiki/08-infraestructura/` (`HU-WIKI-03`) | Implementado en `main` |
| [SCRUM-1688](https://maniservices.atlassian.net/browse/SCRUM-1688) | Reemisión del informe DevOps con digests por servicio/ambiente y `check-prod.sh` (`T-51`) | Documentado en `01-mapa-ambientes-y-versiones.md` |
| [SCRUM-1638](https://maniservices.atlassian.net/browse/SCRUM-1638) | Evidencia Flutter `v1.0.4` (`sha256:79b3d323...`) y 18 rutas en PROD (`T-01`) | Verificado en PROD; pendiente video de validación para PO |
| [SCRUM-1639](https://maniservices.atlassian.net/browse/SCRUM-1639) / [SCRUM-1712](https://maniservices.atlassian.net/browse/SCRUM-1712) | Redacción de contraseñas y tokens expuestos en `MANI-docs` (sin rotación/rewrite por decisión de alcance) | En `In Review` (`2c7671a`) |
| [SCRUM-1655](https://maniservices.atlassian.net/browse/SCRUM-1655) | Rate limit (`limit_req`) en NGINX Gateway (`T-09`) | Desplegado en QA; pendiente video de validación para PO |
| [SCRUM-1672](https://maniservices.atlassian.net/browse/SCRUM-1672) | Límites CPU/RAM en Compose de QA versionado (`T-35`) | Aplicado en QA; PR #89 mergeado (`48a43ce`); pendiente video PO |
| [SCRUM-1674](https://maniservices.atlassian.net/browse/SCRUM-1674) / [SCRUM-1675](https://maniservices.atlassian.net/browse/SCRUM-1675) | Despliegue QA cronometrado (`13s`) y simulacro de rollback (`8s`) (`T-37`, `T-38`) | Ejecutados en QA (`desplegar_release_qa.sh` / `rollback_qa.sh`); PR #91; pendiente video PO |
| [SCRUM-1667](https://maniservices.atlassian.net/browse/SCRUM-1667) / [SCRUM-1668](https://maniservices.atlassian.net/browse/SCRUM-1668) | Stack de monitoreo versionado y retención Prometheus `35d` (`T-30`, `T-31`) | Aplicado en Calidad; PR #90 mergeado (`04afa61`); pendiente video PO |
| [SCRUM-1640](https://maniservices.atlassian.net/browse/SCRUM-1640), [SCRUM-1665](https://maniservices.atlassian.net/browse/SCRUM-1665), [SCRUM-1666](https://maniservices.atlassian.net/browse/SCRUM-1666), [SCRUM-1669](https://maniservices.atlassian.net/browse/SCRUM-1669), [SCRUM-1671](https://maniservices.atlassian.net/browse/SCRUM-1671), [SCRUM-1673](https://maniservices.atlassian.net/browse/SCRUM-1673), [SCRUM-1676](https://maniservices.atlassian.net/browse/SCRUM-1676) | Pendientes declarados en Sprint 6 (cuentas seed PROD tras `1638`, TLS 443 público, cron backups, Alertmanager, exporters, monitoreo PROD, logs/trazas) | Abiertos / pendientes |

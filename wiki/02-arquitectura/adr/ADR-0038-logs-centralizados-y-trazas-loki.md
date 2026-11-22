# ADR-0038 — Logs centralizados y trazabilidad por `correlation_id` con Grafana Loki

- **Estado:** `Aceptado` · **ratificado por la Scrum Master (Sara Albarracín) el 2026-11-19**, sin sesión de Mesa de Arquitectura. ADR-0003 reserva la ratificación a la Mesa; al no haberse convocado ninguna en el Sprint 6 y con la entrega en curso, la SM ratifica para que la decisión no quede sin respaldo formal mientras el código ya la cumple. **La Mesa puede confirmarla o revertirla** cuando se reúna. Redactado por Daniel Ávila (DevOps) para implementar [SCRUM-1676](https://maniservices.atlassian.net/browse/SCRUM-1676); la SM ratifica la decisión, no la autoría.
- **Decisión de:** observabilidad, agregación de logs y correlación distribuida
- **Proponente:** Daniel Ávila (DevOps)
- **Fecha:** `2026-11-14`
- **Jira:** [SCRUM-1676](https://maniservices.atlassian.net/browse/SCRUM-1676) (`T-39`)
- **Relacionado con:** [ADR-0006](ADR-0006-observabilidad.md), [ADR-0037](ADR-0037-cifrado-de-datos-personales-en-reposo.md) (verificación de ausencia de PII en logs), RNF-04 / QAS-16
- **Responde a:** tras retirar Datadog de `ADR-0006`, ¿con qué herramienta ligera se centralizan los logs de Gateway, Core, Rules y Dispatch en un único punto y se correlacionan peticiones por `X-Correlation-ID`?

---

## Contexto

La enmienda del `2026-11-13` a [`ADR-0006`](ADR-0006-observabilidad.md) retiró **Datadog** porque nunca estuvo aprovisionado y declaró explícitamente abierto el hueco de logs centralizados y trazas, señalando que adoptar un sustituto como Loki requería una decisión registrada sin reutilizar ni renumerar `ADR-0006`.

Actualmente, aunque los servicios emiten logs JSON estructurados y propagan `X-Correlation-ID` (incluyendo NGINX Gateway, Core Node, Rules Java y Dispatch .NET), consultar una petición extremo a extremo obligaba a entrar por SSH a QA y revisar contenedor por contenedor con `docker logs`. Además, [`ADR-0037`](ADR-0037-cifrado-de-datos-personales-en-reposo.md) exige poder auditar en los logs que ningún dato personal aparezca en claro.

## Alternativas

1. **Grafana Loki + Promtail autoalojados junto al stack existente (`Calidad` + agente en `QA`) — ← elegida.**
   - *Pros:* se integra nativamente en Grafana (`grafana/datasources/loki.yml`) junto a Prometheus, sin nuevo servidor ni interfaz aparte; indexa únicamente etiquetas (`container`, `service`, `ambiente`) y no el texto completo, consumiendo poca RAM (~100–200 MiB en Calidad) y encajando en el versionamiento actual de `MANI-APIGateway/monitoring/`.
   - *Contras:* no reemplaza APM ni tracing OpenTelemetry completo por spans (queda preparado para añadir Grafana Tempo/OTel en una fase posterior si un QAS lo exige).
2. **Elasticsearch + Filebeat + Kibana (ELK).**
   - *Descartada:* alto consumo de memoria sobre la VM compartida de Calidad (`11 GiB` RAM, ya comparte SonarQube + Prometheus + Grafana), ya evaluada y descartada en `ADR-0006`.
3. **Mantener únicamente `docker logs` por SSH (sin centralización).**
   - *Descartada:* incumple [SCRUM-1676](https://maniservices.atlassian.net/browse/SCRUM-1676) y dificulta el diagnóstico transversal y la auditoría de PII de `ADR-0037`.

## Decisión

Se adopta **Grafana Loki (`grafana/loki:3.1.1`)** en la VM de **Calidad (`10.43.98.196`)** y **Promtail (`grafana/promtail:3.1.1`)** como agente recolector de contenedores en **QA (`10.43.100.141`)**, integrados como datasource en Grafana y versionados en `MANI-APIGateway/monitoring/`:

- **Correlación distribuida:** todas las consultas transversales entre Gateway, Core, Rules y Dispatch se filtran en Grafana Explore mediante LogQL usando el campo/encabezado **`X-Correlation-ID`** (`correlationId` / `x_correlation_id`) ya propagado por `nginx.conf` y los servicios.
- **Privacidad y retención:** retención alineada con monitoreo operativo (`35 días` / `840h`), sin almacenar secretos ni datos personales en claro (verificable con `ADR-0037`).
- **Trazas por spans (OpenTelemetry / Tempo):** quedan fuera de esta fase y registradas como evolución futura si un escenario de calidad o la Mesa de Arquitectura las aprueba explícitamente.

## Consecuencias

### Positivas
- Consulta unificada de logs de Gateway, Core, Rules, Dispatch, Flutter y Kafka desde Grafana (`Explore`) sin abrir sesiones SSH individuales.
- Seguimiento inmediato de una petición a través de los servicios filtrando por `correlation_id`.
- Aprovecha el mismo stack versionado de `monitoring/` sin servicios cloud ni licencias externas.

### Negativas
- No ofrece diagramas de cascada (waterfall) de spans sub-milisegundo tipo OTel/Tempo; solo correlación cronológica de logs por `X-Correlation-ID`.
- Introduce un puerto de ingesta Loki (`3100`) en Calidad restringido a la red interna universitaria (`QA -> Calidad`).

## Condición de revisión

Revisar en Mesa de Arquitectura si el proyecto requiere recolección activa de spans con OpenTelemetry Collector + Grafana Tempo o replicar Promtail sobre `PROD` una vez validada la operación en `QA`.

## Ratificación del 2026-11-19

**Ratificado por Sara Albarracín (Scrum Master), sin sesión de Mesa de Arquitectura.**

**Por qué sin Mesa.** [ADR-0003](ADR-0003-mesa-arquitectura.md) reserva la ratificación de una decisión estructural a la Mesa. En el Sprint 6 **no se convocó ninguna sesión**, y la decisión ya estaba siendo cumplida por el código y la infraestructura. Dejarla indefinidamente como «pendiente de ratificar» habría significado llevar a la sustentación una decisión que el proyecto aplica y que formalmente nadie aprobó.

**Qué significa esta ratificación y qué no.** Da respaldo formal a la decisión para que sea exigible y citable. **No sustituye a la Mesa:** cuando se reúna puede **confirmarla o revertirla**, y si la revierte, esta ratificación y su fecha quedan en el historial como lo que fueron. Se registra así, y no como una ratificación ordinaria, para que cualquiera pueda auditar cómo se tomó.

**Sobre la autoría.** Este ADR lo redactó Daniel Ávila (DevOps). La SM ratifica **la decisión**, no la autoría, y las trazas por *spans* siguen fuera de fase tal como el propio ADR las dejó.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.0 | `2026-11-14` | Propuesta inicial: adopción de Grafana Loki + Promtail para centralización de logs y trazabilidad por `correlation_id` (`SCRUM-1676`). | Daniel Ávila |

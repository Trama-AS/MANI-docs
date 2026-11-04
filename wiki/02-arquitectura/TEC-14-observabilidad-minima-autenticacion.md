# TEC-14 — Observabilidad Mínima de Autenticación (R-4)

- **Tipo:** Plataforma
- **Repositorios involucrados:** `MANI-Node`, `MANI-APIGateway`, `MANI-docs`
- **Hallazgo que cierra:** `R-4`
- **Estado:** Implementado y verificado

---

## 1. Contexto y Justificación

El subsistema de autenticación y autorización perimetral de MANI carecía de telemetría métrica en tiempo real para evaluar la salud de los tokens de acceso y la seguridad perimetral. Ante fallos de autenticación (401) o tokens fraudulentos/incompletos que intentaran evadir el Custom Access Token Hook de Supabase (`missing_tenant_claim`, `missing_user_role`), la plataforma no emitía métricas estructuradas que permitieran alertar tempranamente a los equipos de DevOps y Operaciones.

En cumplimiento de **ADR-0006 (Observabilidad distribuida y gestión de incidentes)**, **TEC-14** implementa la instrumentación mínima necesaria en el Gateway y el Core.

---

## 2. Métricas Expuestas (`/metrics`)

El endpoint canónico `/metrics` (formato estándar de Prometheus `text/plain; version=0.0.4; charset=utf-8`) queda expuesto en:
- `http://core-service:3000/metrics` y `http://core-service:3000/api/v1/metrics`
- `http://<gateway>/metrics` y `http://<gateway>/api/v1/core/metrics` (como ruta pública sin token para scrapers internos).

### 2.1 Contadores e Histogramas
| Métrica | Tipo | Etiquetas (Labels) | Descripción |
| :--- | :--- | :--- | :--- |
| `http_requests_total` | Counter | `method`, `route`, `status_code` | Total de peticiones HTTP procesadas por método, ruta normalizada y código de estado HTTP. Permite calcular tasas de 401, 403, 500, etc. |
| `http_request_duration_seconds` | Histogram | `method`, `route`, `status_code` | Latencia de las peticiones HTTP en segundos. |
| `auth_validations_total` | Counter | `result`, `reason` | Total de validaciones de tokens JWT ejecutadas por `TokenService`. Permite discriminar fallos específicos de claims. |

### 2.2 Desglose de `auth_validations_total`
- `result="success"`, `reason="ok"`: Token válido con claims de aislamiento obligatorios.
- `result="failure"`, `reason="missing_tenant_claim"`: Token sin `app_metadata.tenant_id`.
- `result="failure"`, `reason="missing_user_role"`: Token sin `sub` o `app_metadata.user_role`.
- `result="failure"`, `reason="missing_authorization_header"`: Petición sin encabezado `Authorization`.
- `result="failure"`, `reason="malformed_authorization_header"`: Encabezado sin prefijo `Bearer`.
- `result="failure"`, `reason="invalid_signature"`: Firma criptográfica rechazada.
- `result="failure"`, `reason="token_expired"`: Token expirado.
- `result="failure"`, `reason="invalid_token"`: Token inválido general.

---

## 3. Reglas de Alerta Prometheus (`auth-alerts.yml`)

Ubicación en los repositorios:
- `MANI-Node/monitoring/alerts/auth-alerts.yml`
- `MANI-APIGateway/monitoring/alerts/auth-alerts.yml`

```yaml
groups:
  - name: mani_auth_monitoring_alerts
    rules:
      - alert: HighAuth401Rate
        expr: (sum(rate(http_requests_total{status_code="401"}[5m])) / sum(rate(http_requests_total[5m]))) > 0.05
        for: 2m
        labels:
          severity: warning
          service: core-service
          component: auth
          hallazgo: R-4
        annotations:
          summary: "Tasa elevada de respuestas 401 en autenticacion (> 5%)"
          description: "La tasa de errores 401 supera el 5% en los ultimos 5 minutos (posible fuerza bruta o expiracion masiva)."

      - alert: IncompleteClaimsAttemptsDetected
        expr: sum(rate(auth_validations_total{result="failure",reason=~"missing_.*"}[5m])) > 0
        for: 1m
        labels:
          severity: critical
          service: core-service
          component: auth
          hallazgo: R-4
        annotations:
          summary: "Deteccion de intentos de autenticacion con claims incompletos"
          description: "Se detectaron tokens con claims obligatorios ausentes (missing_tenant_claim o missing_user_role) en el Gateway/Core."
```

---

## 4. Evidencia de Verificación

1. **Pruebas de Integración en Core:**
   `tests/integration/routes/metrics.routes.test.js` cubre:
   - Exposición canónica en `/metrics` y `/api/v1/metrics`.
   - Incremento de 401 ante peticiones desprovistas de autenticación.
   - Incremento con `reason="missing_tenant_claim"` ante tokens sin tenant.
   - Incremento con `reason="missing_user_role"` ante tokens sin rol.
   - Incremento con `result="success", reason="ok"` ante tokens conformes.
2. **Validación en Gateway:**
   - `tests/gateway/ruta-publica-metrics.sh` valida que `/metrics` y `/api/v1/core/metrics` son accesibles sin credenciales estáticas y exponen métricas válidas.
   - Verificado en el pipeline CI (`.github/workflows/ci.yml`).

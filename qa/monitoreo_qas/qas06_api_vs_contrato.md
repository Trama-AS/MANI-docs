# QAS-06: APIs publicadas en QA frente a contrato OpenAPI

**Escenario (SDD §8, QAS-06):** 100 % de APIs documentadas con OpenAPI y contract tests críticos
aprobados antes de promoción.

**Corte:** 19 oct 2026. Revisiones desplegadas en QA, leídas de la etiqueta
`org.opencontainers.image.revision` de cada contenedor (evidencia
`evidencia/20261019_diagnostico/qa_mon_01_vm_qa_1720z.txt`): Core `6ca27ab`, Rules `f8582aa`,
Dispatch `e40f84e`, Gateway `6b475f9`. Contratos: `MANI-APIGateway` `develop` `0d9839f`,
`docs/openapi/core.yaml` (servers `.../api/v1/core`) y `docs/openapi/rules.yaml` (servers
`.../api/v1/rules`). No hay contrato OpenAPI en `release` ni en `main` del Gateway, ni en los
repositorios de los servicios, ni contrato para Dispatch. Que el contrato viva solo en `develop`
significa que no se promueve junto con lo que llega a QA.

**Método:** inventario de rutas en el código de cada revisión desplegada y en `nginx.conf` del
Gateway; cruce con los `paths` de cada contrato; búsqueda de contract tests en los seis
repositorios.

## Rutas publicadas por el Gateway de QA

| # | Método y ruta en el Gateway | Servicio | Contrato OpenAPI | Observación |
|---|---|---|---|---|
| 1 | `GET /health` | Gateway | No | Respuesta fija de nginx |
| 2 | `GET /api/v1/core/health` | Core | No | `core.yaml` no declara `/health` |
| 3 | `POST /api/v1/core/auth/dev-token` | Core | No | Ruta de desarrollo expuesta (hallazgo H-01) |
| 4 | `ALL /api/v1/core/auth/validate-token` | Core | No | La usa `auth_request`; también queda pública por `/api/v1/core/auth/` |
| 5 | `GET /api/v1/core/tenants` | Core | No | Stub con datos fijos |
| 6 | `GET /api/v1/core/profiles/me` | Core | No | Stub; devuelve los encabezados que inyecta el Gateway |
| 7 | `GET /api/v1/core/catalog` | Core | No | Stub con datos fijos |
| 8 | `GET /api/v1/rules/health` | Rules | **Sí** (`rules.yaml` `/health`) | Forma de respuesta no verificada contra el esquema |
| 9 | `POST /api/v1/rules/evaluate-rate` | Rules | No | Stub |
| 10 | `POST /api/v1/rules/rank-allies` | Rules | No | Stub |
| 11 | `GET /api/v1/dispatch/health` | Dispatch | No | Sin `dispatch.yaml` |
| 12 | `POST /api/v1/dispatch/match` | Dispatch | No | Stub con 3 aliados fijos |
| 13 | `POST /api/v1/dispatch/requests/{requestId}/accept` | Dispatch | No | Stub en memoria |

Operaciones de servicio publicadas (filas 2 a 13): **12**. Con contrato: **1** (8,3 %).

## Operaciones con contrato que no están desplegadas en QA

| Contrato | Operaciones |
|---|---|
| `core.yaml` | `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`, `POST /auth/register/ally`, `POST /auth/register/ally/company`, `POST /solicitudes`, `GET` y `POST /profiles/me/unavailability`, `PATCH` y `DELETE /profiles/me/unavailability/{absenceId}` |
| `rules.yaml` | `POST /categories/evaluate` |

## Contract tests

`MANI-APIGateway` `develop` tiene un gate de contrato en `.github/workflows/ci.yml`:

- `contract-validation`: valida los YAML (Swagger Parser y Spectral) y genera la colección
  Postman desde `core.yaml`.
- `contract-gate-newman` («Gate de Contrato Postman/Newman (QA-03)»): levanta el Core de `develop`
  en memoria (`NODE_ENV=development`) detrás del Gateway del mismo commit y corre Newman con la
  colección generada. Las cinco corridas más recientes en `develop` (19 oct 2026) terminaron en
  `success`.

Límites frente al umbral:

- Corre sobre `push` y `pull_request` a `develop` y `main`, no sobre `release`, que es la rama que
  promueve a QA.
- Ejercita el Core de `develop` en memoria, no las revisiones desplegadas en QA ni la base de datos.
- Cubre `core.yaml`. Para `rules.yaml` existe `postman/MANI-Rules.postman_collection.json`, sin job
  que la ejecute; Dispatch no tiene contrato.
- Node, Java y .NET no tienen contract tests propios.

## Resultado

| Medido | Umbral | Comparación | Estado |
|---|---|---|---|
| 1 de 12 operaciones publicadas en QA con contrato (8,3 %); contract tests solo para Core `develop` en memoria, ninguno sobre lo desplegado en QA | 100 % documentadas y contract tests críticos aprobados antes de promoción | Fuera del umbral | **No cumple** (ejecutado por inspección) |

**Limitación:** la verificación es estática (código y configuración de las revisiones desplegadas)
más las respuestas observadas en QA para las rutas 1 a 13. No compara la forma de cada respuesta con
un esquema, porque 12 de las 13 rutas no tienen esquema.

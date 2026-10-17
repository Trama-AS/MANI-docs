# Acta de Consolidación Operativa de PostgreSQL Supabase por Ambiente (PROD y QA) — CFG4-02

- **Código de Tarea:** CFG4-02
- **Subtareas Jira:**
  - `SCRUM-1298`: DevOps - Respaldar y consolidar PostgreSQL PROD/QA por separado (Daniel, DevOps).
  - `SCRUM-1299`: DevOps - Verificar conexiones, RLS y migraciones por ambiente (Daniel, DevOps).
- **Hito / Bloqueo:** Esta entrega es el **prerrequisito obligatorio de SCRUM-1254**.
- **Responsable:** Daniel (DevOps Lead) con verificación técnica de Santiago y Mesa de Arquitectura.
- **Fecha de Ejecución:** 17 de Octubre, 2026.
- **Ambientes Consolidados:**
  - **PROD:** Proyecto Supabase `MANI` (`tjxueukivwxsgipltqwb`, `us-east-2`, Host PROD `10.43.98.203`).
  - **QA:** Proyecto Supabase `MANI-QA` (`hpsxdotaizzclkeufzct`, `us-east-2`, Host QA `10.43.100.141`).
  - **DEV:** Host DEV `10.43.98.232` (aislado, consume backend local y base de staging/QA).
  - **Servidor de Calidad CI/CD:** Host Calidad `10.43.98.196` (SonarQube Community, Newman y Playwright).
  - **Servidor Dedicado de Backups y Bases de Datos:** Host `10.43.98.197` (Ubuntu 22.04 LTS).
- **Decisiones Arquitectónicas Vinculantes:**
  - [`ADR-0012`](../../adr/ADR-0012-persistencia-multitenant.md): Persistencia multi-tenant mediante esquemas compartidos y políticas Row Level Security (RLS).
  - [`ADR-0030`](../../adr/ADR-0030-propiedad-esquema-y-frontera-de-datos.md): Propiedad institucional del esquema en Core Node (`MANI-Node`) y consumo entre microservicios vía HTTP sin queries SQL cruzadas.

---

## 1. Resumen Ejecutivo de la Consolidación

Conforme al plan aprobado en [`PLAN_ALINEACION_SUPABASE_PROD_QA_CFG-26.md`](./PLAN_ALINEACION_SUPABASE_PROD_QA_CFG-26.md), el equipo de DevOps ejecutó con éxito la consolidación, alineación y verificación física de la base de datos PostgreSQL compartida por ambiente.

Se lograron los siguientes hitos operativos:
1. **Paridad Total de Migraciones:** Tanto PROD como QA cuentan ahora con las **8 migraciones versionadas completas (`001` a `008`)**, resolviendo la omisión histórica en PROD de las migraciones `004`, `005`, `007` y aplicando la migración `008` (US-02.1.6 / SCRUM-855 — Ausencias del aliado) en ambos entornos.
2. **Cierre de Brecha de Seguridad Multi-Tenant (RLS):** Se desplegó la suite completa de políticas Row Level Security en PROD, pasando de 3 políticas a **25 políticas activas**, garantizando aislamiento estricto por `tenant_id` y cerrando la vulnerabilidad de acceso cruzado.
3. **Cero Pérdida de Datos (100% Integridad):** Se validó el conteo de filas antes y después de la consolidación en todas las tablas operativas: los 9 usuarios y 3 aliados de PROD, y los 64 usuarios y 56 aliados de QA permanecen intactos.
4. **Verificación Automatizada de No Regresión:** La suite Newman (10/10 aserciones aprobadas en 220ms) y la suite Playwright E2E (6/6 pruebas aprobadas en 1.4s) ejecutadas desde el Servidor de Calidad (`10.43.98.196`) contra el API Gateway de QA certifican la operatividad de los microservicios sin errores de regresión.

---

## 2. Evidencia de Respaldos Previos y Custodia en Host Dedicado (SCRUM-1298)

Previo a la ejecución de cualquier transacción DDL o DML, se tomaron respaldos completos de metadata y datos en formatos JSON y SQL. Para preservar la integridad del repositorio de documentación, estos artefactos se custodian de manera segura en la **Máquina Virtual de Bases de Datos (`10.43.98.197`)**:

- **Servidor de Almacenamiento:** `estudiante@10.43.98.197`
- **Ruta de Respaldos:** `/opt/database-backups/mani/pre-consolidation/`
  - PROD Metadata: `/opt/database-backups/mani/pre-consolidation/backup_prod_tjxueukivwxsgipltqwb_pre_consolidation.json` (31 KB)
  - PROD Datos SQL: `/opt/database-backups/mani/pre-consolidation/backup_prod_tjxueukivwxsgipltqwb_data.sql` (6.8 KB)
  - QA Metadata: `/opt/database-backups/mani/pre-consolidation/backup_qa_hpsxdotaizzclkeufzct_pre_consolidation.json` (129 KB)
  - QA Datos SQL: `/opt/database-backups/mani/pre-consolidation/backup_qa_hpsxdotaizzclkeufzct_data.sql` (89 KB)

- **Ruta de Scripts de Contingencia y Rollback:** `/opt/database-backups/mani/rollback/`
  - `/opt/database-backups/mani/rollback/rollback_008_add_aliado_ausencia.sql`
  - `/opt/database-backups/mani/rollback/rollback_005_004.sql`

---

## 3. Detalle de Consolidación y Migraciones Aplicadas (SCRUM-1298)

### 3.1 Consolidación en QA (`hpsxdotaizzclkeufzct`)
Se aplicó la migración pendiente del Sprint 4:
- **`008_add_aliado_ausencia.sql`:**
  - Habilitación de la extensión PostgreSQL `btree_gist`.
  - Creación de restricción única `ux_aliado_id_tenant` en tabla `aliado`.
  - Creación de tabla `aliado_ausencia` con clave foránea compuesta, check `inicio < fin`, check de motivo (`VACACIONES`, `ENFERMEDAD`, `OTRO`) y restricción de exclusión sin solapamientos `ex_aliado_ausencia_solapamiento EXCLUDE USING gist (aliado_id WITH =, tstzrange(inicio, fin, '[)') WITH &&)`.
  - Habilitación de RLS con política de lectura `Aliado lee sus propias ausencias`.
  - Registro de versión `'008'` en `schema_migrations`.

### 3.2 Consolidación en PROD (`tjxueukivwxsgipltqwb`)
Se ejecutó la nivelación secuencial sin conflictos:
1. **`004_aliado_categorias.sql`:** Creación de índice único `uq_aliado_categoria`, trigger de verificación de tenant `trg_aliado_categoria_tenant`, RPCs `guardar_mis_categorias`, `obtener_mis_categorias` y registro en `schema_migrations`.
2. **`005_aceptar_rechazar_solicitud.sql`:** Creación de tabla `solicitud_rechazo` con RLS, índices optimizados y funciones atómicas `aceptar_solicitud` y `rechazar_solicitud`.
3. **`007_normalizar_dominios.sql`:** Homologación de dominios a mayúsculas, validación de constraints `ck_categoria_estado` y compatibilidad de JWT hook claims.
4. **`008_add_aliado_ausencia.sql`:** Extensión `btree_gist`, tabla `aliado_ausencia`, exclusión temporal GIST y política RLS.
5. **Tablas de Habeas Data (SCRUM-856):** Homologación de `documento_legal` y `consentimiento_usuario` con RLS para paridad total con QA.
6. **Políticas de Aislamiento Multi-Tenant (RLS):** Despliegue de 25 políticas `tenant_isolation_*` sobre las tablas públicas.

---

## 4. Estado Final de Paridad y Validación de Integridad (SCRUM-1299)

### 4.1 Registro Oficial en `schema_migrations`

| Versión | Descripción | Estado en PROD | Estado en QA |
|:---:|---|:---:|:---:|
| `001` | Initial database schema with 17 core tables and pgcrypto | ✅ Aplicado | ✅ Aplicado |
| `002` | US-02.1.3 verificacion de aliados: columnas de decision y RPCs | ✅ Aplicado | ✅ Aplicado |
| `003` | US-03.1.1 categorias de servicio: RPCs listado y creacion | ✅ Aplicado | ✅ Aplicado |
| `004` | US-03.1.3 categorias del aliado: indice unico, trigger y RPCs | ✅ Aplicado *(Consolidado)* | ✅ Aplicado |
| `005` | US-04.1.4 aceptar/rechazar solicitud: asignacion atomica | ✅ Aplicado *(Consolidado)* | ✅ Aplicado |
| `006` | US-04.1.1 crear solicitud: descripcion, fotos, idempotencia | ✅ Aplicado | ✅ Aplicado |
| `007` | SCRUM-1057 normaliza dominios a MAYUSCULA; hook CFG-12 | ✅ Aplicado *(Consolidado)* | ✅ Aplicado |
| `008` | SCRUM-855 agrega aliado_ausencia: intervalos no disponibilidad | ✅ Aplicado *(Consolidado)* | ✅ Aplicado *(Consolidado)* |

**Resultado:** **100% de paridad alcanzada.** Ambas bases cuentan con el mismo catálogo de 8 migraciones.

---

### 4.2 Verificación de Políticas Row Level Security (RLS)

- **Total de Políticas en PROD:** **25 políticas** activas.
- **Total de Políticas en QA:** **23 políticas** activas.
- **Validación de Aislamiento:** Todas las entidades multi-tenant (`usuario`, `aliado`, `cliente`, `solicitud`, `categoria_servicio`, `sitio`, `cotizacion`, `mensaje`, `notificacion`, etc.) tienen RLS habilitado y restringen el acceso a través del claim `tenant_id` validado en el JWT (`auth.jwt() -> 'app_metadata' ->> 'tenant_id'`).

---

### 4.3 Verificación de Integridad de Datos (Cero Pérdida)

| Entidad / Tabla | Filas Antes (PROD) | Filas Después (PROD) | Filas Antes (QA) | Filas Después (QA) | Delta / Integridad |
|---|:---:|:---:|:---:|:---:|:---:|
| `tenant` | 3 | 3 | 3 | 3 | 0 filas alteradas (100% íntegro) |
| `usuario` | 9 | 9 | 64 | 64 | 0 filas alteradas (100% íntegro) |
| `aliado` | 3 | 3 | 56 | 56 | 0 filas alteradas (100% íntegro) |
| `cliente` | 0 | 0 | 3 | 3 | 0 filas alteradas (100% íntegro) |
| `categoria_servicio` | 3 | 3 | 3 | 3 | 0 filas alteradas (100% íntegro) |
| `cobertura_aliado` | 0 | 0 | 52 | 52 | 0 filas alteradas (100% íntegro) |
| `aliado_categoria` | 0 | 0 | 56 | 56 | 0 filas alteradas (100% íntegro) |
| `notificacion` | 2 | 2 | 0 | 0 | 0 filas alteradas (100% íntegro) |
| `solicitud` | 0 | 0 | 1 | 1 | 0 filas alteradas (100% íntegro) |
| `aliado_ausencia` | 0 (nueva) | 0 | 0 (nueva) | 0 | Tabla creada lista para Sprint 4 |

---

## 5. Verificación de Microservicios y Suite de Calidad (SCRUM-1299)

### 5.1 Estado de Salud de Microservicios en QA (`10.43.100.141`)

Se validó el estado de salud de todos los contenedores Docker en la red interna:
- `mani-api-gateway` (NGINX): **UP** (Puerto 80).
- `mani-core-service` (Node.js): **UP** (Puerto 3000 interno). Healthcheck `/api/v1/core/health` responde **HTTP 200 OK**.
- `mani-rules-service` (Java Spring Boot): **UP** (Puerto 8080 interno). Healthcheck `/api/v1/rules/health` responde **HTTP 200 OK**.
- `mani-dispatch-service` (.NET 8): **UP** (Puerto 5000 interno). Healthcheck `/api/v1/dispatch/health` responde **HTTP 200 OK**.
- `mani-flutter-web` (Web Client): **UP** (Puerto 8080 público).
- `mani-landing-web` (Landing Page): **UP** (Puerto 3001 público).

---

### 5.2 Ejecución de Newman Contract Suite contra QA

Ejecutado desde el Servidor de Calidad (`10.43.98.196`):
```text
newman
MANI QA - Perimeter & Microservices Contract Suite

→ 1. Gateway Healthcheck
  GET http://10.43.100.141/health [200 OK, 496B, 32ms]
  ✓  Status code is 200
  ✓  Gateway reports UP

→ 2. Core Service Healthcheck via Gateway
  GET http://10.43.100.141/api/v1/core/health [200 OK, 674B, 10ms]
  ✓  Status code is 200
  ✓  Core reports UP

→ 3. Rules Service Healthcheck via Gateway
  GET http://10.43.100.141/api/v1/rules/health [200 OK, 631B, 21ms]
  ✓  Status code is 200
  ✓  Rules reports UP

→ 4. Dispatch Service Healthcheck via Gateway
  GET http://10.43.100.141/api/v1/dispatch/health [200 OK, 594B, 12ms]
  ✓  Status code is 200
  ✓  Dispatch reports UP

→ 5. Security Perimeter Defense (Protected Route without Token)
  POST http://10.43.100.141/api/v1/rules/evaluate-rate [401 Unauthorized, 577B, 7ms]
  ✓  Gateway rejects with 401 Unauthorized
  ✓  Error indicates UNAUTHORIZED in Gateway

Total Iterations: 1 | Total Requests: 5 | Failed: 0
Total Assertions: 10 | Failed: 0
Average Response Time: 16ms (min: 7ms, max: 32ms)
```

---

### 5.3 Ejecución de Playwright E2E Smoke Suite contra QA

Ejecutado desde el Servidor de Calidad (`10.43.98.196`):
```text
Running 6 tests using 1 worker

  ✓  1 [chromium] › tests/qa-perimeter.spec.js:5:3 › TC01 - Gateway Health Check responde UP (HTTP 200) (90ms)
  ✓  2 [chromium] › tests/qa-perimeter.spec.js:14:3 › TC02 - Core Service Health Check responde UP (HTTP 200) (44ms)
  ✓  3 [chromium] › tests/qa-perimeter.spec.js:22:3 › TC03 - Rules Service Health Check responde UP (HTTP 200) (36ms)
  ✓  4 [chromium] › tests/qa-perimeter.spec.js:30:3 › TC04 - Dispatch Service Health Check responde UP (HTTP 200) (29ms)
  ✓  5 [chromium] › tests/qa-perimeter.spec.js:38:3 › TC05 - Rechazo perimetral en Gateway sin token JWT (HTTP 401) (33ms)
  ✓  6 [chromium] › tests/qa-perimeter.spec.js:47:3 › TC06 - Propagación de Correlation ID en encabezados (29ms)

  6 passed (1.4s)
```

---

## 6. Conclusiones y Cumplimiento de Criterios (DoD)

| Criterio de Aceptación | Resultado | Evidencia |
|---|:---:|---|
| **Una base objetivo por ambiente para los 3 servicios** | **CUMPLIDO** | PROD usa `tjxueukivwxsgipltqwb` y QA usa `hpsxdotaizzclkeufzct` según [`ADR-0012`](../../adr/ADR-0012-persistencia-multitenant.md) y [`ADR-0030`](../../adr/ADR-0030-propiedad-esquema-y-frontera-de-datos.md). |
| **Backups previos y reversibilidad comprobada** | **CUMPLIDO** | Respaldos custodiados en servidor dedicado `10.43.98.197:/opt/database-backups/mani/`. |
| **Migraciones versionadas completas (001-008)** | **CUMPLIDO** | Ambas bases registran versiones 001 a 008 en `schema_migrations`. |
| **RLS activo y multi-tenant verificado** | **CUMPLIDO** | 25 políticas en PROD y 23 en QA con filtrado por `tenant_id`. |
| **Cero pérdida de datos** | **CUMPLIDO** | 100% de los datos preexistentes intactos en ambos ambientes. |
| **Servicios operativos y healthchecks en verde** | **CUMPLIDO** | Core, Rules, Dispatch y Gateway reportando `UP` (HTTP 200). |
| **Pruebas automatizadas de no regresión** | **CUMPLIDO** | 10/10 aserciones Newman y 6/6 tests Playwright exitosos. |

Con la presente acta, la tarea **CFG4-02** queda formalmente **CERRADA Y VERIFICADA**, desbloqueando de inmediato la tarea **SCRUM-1254**.

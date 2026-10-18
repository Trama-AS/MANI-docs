# CFG-23a.4 — Presentación en Mesa de Arquitectura y registro de la decisión

- **Jira:** SCRUM-1198 (subtarea de CFG-23a, SCRUM-1103)
- **Presenta:** Juan Sebastián Álvarez Rodríguez
- **Decisión a tomar:** aprobar, modificar o rechazar [ADR-0032](../../adr/ADR-0032-identidad-de-servicio-en-base-de-datos.md)
- **Duración sugerida:** 30 min (estimación de la subtarea)
- **Desbloquea:** CFG-23b (SCRUM-1104) y CFG-23c (SCRUM-1105)

## 1. Qué se decide (2 min)

**De dónde toma cada política RLS el tenant y el usuario cuando quien consulta es Core o Dispatch.** La propuesta:

- cada servicio se conecta con su propio rol sin `BYPASSRLS`;
- en cada transacción fija los claims ya verificados con `app.set_context(...)`;
- las políticas leen solo de ahí, y es la misma fuente que usa PostgREST.

## 2. Por qué es urgente (5 min)

Del [inventario](01-inventario-rls.md):

1. **Hoy RLS no protege nada del tráfico de servicios.** Core y Dispatch conectan como `service_role`/`postgres`, que tienen `BYPASSRLS`. La autorización en código es la única barrera (KI-05).
2. **Exposiciones abiertas ahora, independientes de la decisión:**
   - `documento_kyc` se lee e inserta con la clave anónima, desde cualquier tenant;
   - `registrar_aliado_persona_natural` está concedida a `anon` y recibe el tenant por parámetro;
   - 11 tablas no tienen RLS.
3. **El repositorio y QA divergen.** `tenant_isolation_solicitud` existe solo en QA.

Demostración en vivo opcional (1 min): `02-casos.sql` de la [PoC](../../Entregas/PoC/PoC-CFG23a-identidad-servicio-rls/README.md), líneas L1 y L2.

## 3. Alternativas (8 min)

| # | Alternativa | Veredicto propuesto | Motivo |
|---|---|---|---|
| 1 | Seguir con `service_role` y solo autorización en código | Descartar | es el defecto SCRUM-1334; contradice ADR-0012 |
| 2 | Reenviar el JWT del usuario y acceder solo por PostgREST | Solo como paso transitorio de Core | no cubre transacciones `pg`/Npgsql, ni pre-auth, ni asíncronos |
| 3 | GUC propio por servicio | Descartar | dos fuentes de identidad por política |
| 4 | Base o esquema por tenant | Descartar | ya descartada en ADR-0012 |
| **5** | **Rol por servicio sin `BYPASSRLS` + `app.set_context` por transacción** | **Elegir** | una política para todos los caminos, falla cerrada, frontera ADR-0030 en el motor |

## 4. Evidencia (5 min)

PoC en PostgreSQL 16 con roles y funciones equivalentes a Supabase, 2026-10-17:

- **Seis casos de Políticas DevOps §13.4: aprobados** (C1–C6).
- Falla cerrada sin contexto, con claim corrupto y en autocommit (C5 y login real).
- Sin fuga entre transacciones del pool (P1), con control negativo que justifica la prohibición de `set_config` de sesión (P2).
- Dispatch recibe `permission denied` en tablas de Core (P3); un cliente no acepta solicitudes (P4).

Límite: no es Supabase real. CFG-23c repite los casos en QA.

## 5. Preguntas que la Mesa debe resolver y observaciones de la revisión previa (8 min)

En la revisión de arquitectura de PR #39 (`MANI-docs`), Sara Albarracín Niño asumió el rol de revisora (ADR-0003), aprobó el diseño y dejó tres observaciones puntuales ya incorporadas en ADR-0032 y en el documento de diseño:

| # | Pregunta / Observación | Propuesta / Estado |
|---|---|---|
| M1 | ¿Se aprueba la alternativa 5 como mecanismo único, con la 2 solo como paso transitorio de Core? | Sí (avalado en revisión de arquitectura PR #39) |
| M2 | `tarifa_referencia` y *overrides* por tenant de `rules.yaml`: ¿Rules persiste en la base compartida o en el propio servicio? | En el incremento actual (`US-03.1.1-M6`, `MANI-Java`), los *overrides* por tenant (`mani.rules.category.tenants.<tenantId>.*`) viven en la configuración del servicio y Rules no accede a PostgreSQL (ADR-0022); Core persiste `tarifa_referencia` y consulta a Rules por HTTP (ADR-0030 §2). Si en el futuro el tarifario u *overrides* se persisten desde Rules en el esquema `reglas`, se habilitará el rol `mani_rules_svc` (`ModeloDatos.md` §6.3) bajo las mismas reglas (`NOBYPASSRLS` + `app.set_context`). Mientras tanto, `mani_rules_svc` queda documentado y **no se crea** |
| M3 | ¿Se acepta el riesgo residual de Storage con `service_role`, con rutas construidas desde el contexto? | Sí, precisando que el **caso 6 de CFG-23c** debe probar explícitamente el acceso a una ruta de Storage de **otro tenant** (`{T2}/…`), no solo de otro aliado del mismo tenant |
| M4 | ¿Se acepta que `tenant` siga legible sin contexto (`slug`, `nombre`, `estado`) para resolver `X-Tenant-Slug`? | Sí: el slug ya es público por ADR-0018 |
| M5 | Nombres de rol de contexto fuera de sesión: `anonimo` (lectura pre-auth) y `servicio` (asíncrono) | Aprobar o renombrar en sesión |
| M6 | ¿Las tres exposiciones de ADR-0032 §8 se corrigen este sprint, antes de CFG-23b? | **Ejecutado:** migración `0005_cerrar_exposiciones_rls.sql` y verificación `0005_verificar_exposiciones.sql` abiertas en `MANI-Node` PR #28 bajo SCRUM-1334 |
| M7 | Revisor del ADR (ADR-0003 exige autor y revisor distintos) | **Resuelto:** Sara Albarracín Niño (aprobado en `MANI-docs` PR #39) |
| M8 | Dependencia operativa de CFG-23b (paso 5) | Los roles `mani_core_svc` y `mani_dispatch_svc` nacen `NOLOGIN` en la migración; operaciones (DevOps, Daniel Ávila) asigna `LOGIN PASSWORD` y actualiza `DATABASE_URL` fuera de git (`/opt/mani/.env.{dev,qa,prod}`, ADR-0031 §5) antes de activar RLS en QA |

## 6. Después de la sesión (2 min)

1. Completar el acta (§7) y copiar decisión y disenso en ADR-0032 (*Estado* y *Disenso registrado*).
2. Si se aprueba:
   - pasar ADR-0032 a **Aceptado**;
   - mover CFG-23b y CFG-23c fuera de *blocked* (los pasos 1 a 4 de CFG-23b pueden avanzar sin esperar el paso 5 operativo);
   - fusionar `MANI-Node` PR #28 (migración `0005` de SCRUM-1334).
3. Si se rechaza o modifica: registrar el motivo y la alternativa elegida, y reabrir CFG-23a.2.

## 7. Acta

> Se completa en la sesión de Mesa de Arquitectura (no se inventan fechas ni acuerdos sin sesión celebrada, conforme a SM4-01). Hasta entonces ADR-0032 permanece en *Propuesto* con revisión de pares aprobada en PR #39.

| Campo | Valor |
|---|---|
| Fecha y hora | *Pendiente de sesión de Mesa de Arquitectura* |
| Asistentes | *Pendiente de sesión* |
| Decisión sobre ADR-0032 | ☐ Aprobado ☐ Aprobado con cambios ☐ Rechazado |
| Cambios acordados | Incorporadas previamente las 3 observaciones de la revisión de arquitectura (PR #39): alcance de `mani_rules_svc` (M2), prueba cross-tenant de Storage `{T2}/…` en caso 6 (M3) y dependencia operativa `NOLOGIN` → `LOGIN PASSWORD` con DevOps (M8) |
| Respuestas M1–M8 | M6 (`MANI-Node` PR #28) y M7 (Revisora: Sara Albarracín Niño) cerradas; M1–M5 y M8 listas para ratificación en sesión |
| Disenso registrado (quién y por qué) | Ninguno en revisión previa |
| Revisor asignado | Sara Albarracín Niño (`MANI-docs` PR #39) |
| Responsables y fechas de lo acordado | Juan Sebastián Álvarez (CFG-23b pasos 1–4, migraciones y `withTenantContext`), Daniel Ávila (CFG-23b paso 5, `LOGIN PASSWORD` y `DATABASE_URL` en QA/PROD), Santiago Hernández (CFG-23c, ejecución de los 6 casos en QA) |

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

## 5. Preguntas que la Mesa debe resolver (8 min)

| # | Pregunta | Propuesta del autor |
|---|---|---|
| M1 | ¿Se aprueba la alternativa 5 como mecanismo único, con la 2 solo como paso transitorio de Core? | Sí |
| M2 | `tarifa_referencia`: Rules es dueño del tarifario (ADR-0022) pero no tiene base. ¿Quién la persiste y con qué rol? | Core la persiste y Rules la consume por HTTP, igual que las categorías en US-03.1.1-M6 |
| M3 | ¿Se acepta el riesgo residual de Storage con `service_role`, con rutas construidas desde el contexto? | Sí, acotado por el caso 6 de CFG-23c |
| M4 | ¿Se acepta que `tenant` siga legible sin contexto (`slug`, `nombre`, `estado`) para resolver `X-Tenant-Slug`? | Sí: el slug ya es público por ADR-0018 |
| M5 | Nombres de rol de contexto fuera de sesión: `anonimo` (lectura pre-auth) y `servicio` (asíncrono) | Aprobar o renombrar |
| M6 | ¿Las tres exposiciones de ADR-0032 §8 se corrigen este sprint, antes de CFG-23b, con defectos propios? | Sí, son independientes del modelo |
| M7 | Revisor del ADR (ADR-0003 exige autor y revisor distintos) | Sara Albarracín (autora de SCRUM-1334 y ADR-0030) |

## 6. Después de la sesión (2 min)

1. Completar el acta (§7) y copiar decisión y disenso en ADR-0032 (*Estado* y *Disenso registrado*).
2. Si se aprueba:
   - pasar ADR-0032 a **Aceptado**;
   - mover CFG-23b y CFG-23c fuera de *blocked*;
   - actualizar SCRUM-1334 con la conciliación del inventario (§6);
   - abrir los defectos de M6.
3. Si se rechaza o modifica: registrar el motivo y la alternativa elegida, y reabrir CFG-23a.2.

## 7. Acta

> Se completa en la sesión. Hasta entonces la decisión **no existe**: ADR-0032 sigue en *Propuesto*.

| Campo | Valor |
|---|---|
| Fecha y hora | |
| Asistentes | |
| Decisión sobre ADR-0032 | ☐ Aprobado ☐ Aprobado con cambios ☐ Rechazado |
| Cambios acordados | |
| Respuestas M1–M7 | |
| Disenso registrado (quién y por qué) | |
| Revisor asignado | |
| Responsables y fechas de lo acordado | |

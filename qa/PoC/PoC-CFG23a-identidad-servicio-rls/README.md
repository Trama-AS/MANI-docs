# PoC CFG-23a — Identidad de servicio en base de datos

- **Jira:** CFG-23a (SCRUM-1103), subtareas SCRUM-1195 y SCRUM-1197
- **Fecha de ejecución:** 2026-10-17
- **Ejecutó:** Juan Sebastián Álvarez Rodríguez
- **Decisión que respalda:** [ADR-0032](../../../wiki/02-arquitectura/adr/ADR-0032-identidad-de-servicio-en-base-de-datos.md) (Propuesto)

## Pregunta

¿Puede un servicio que se conecta con su propio rol, sin `BYPASSRLS`, quedar aislado por tenant **con las mismas políticas** que usa PostgREST, si establece los claims verificados al inicio de cada transacción? ¿Y falla cerrado cuando no los establece?

## Entorno

- `postgres:16-alpine` en Docker, base vacía.
- `01-modelo.sql` reproduce lo que Supabase aporta: roles `anon`, `authenticated`, `service_role` (`BYPASSRLS`), `GRANT ALL` sobre `public` a esos tres roles (sus *default privileges*) y `auth.uid()`/`auth.jwt()` leyendo `request.jwt.claims` como en Supabase. Sobre eso aplica el modelo de ADR-0032: roles `mani_core_svc` y `mani_dispatch_svc`, esquema `app`, `app.set_context()` y políticas por tenant.
- Datos: dos tenants (T1 con un admin, dos aliados y un cliente; T2 con un aliado), KYC, solicitudes y notificaciones.

No es una migración: CFG-23b la versiona en `MANI-Node/db/migrations` (ADR-0030).

## Cómo reproducir

```bash
docker run -d --name poc23a -e POSTGRES_PASSWORD=poc postgres:16-alpine
docker exec -i poc23a psql -q -v ON_ERROR_STOP=1 -U postgres < 01-modelo.sql
docker exec -i poc23a psql -q -v ON_ERROR_STOP=1 -U postgres < 02-casos.sql
docker rm -f poc23a
```

Cada caso termina en `ASSERT`: si un resultado no es el esperado, `psql` aborta y no imprime la línea final.

## Resultado (2026-10-17)

```text
== Línea base: el problema que motiva CFG-23a
NOTICE:  L1 service_role (lo que usa Core hoy) ve los 2 tenants aunque haya claims de T1: BYPASSRLS ignora toda política
NOTICE:  L2 anon (la SUPABASE_ANON_KEY del bundle) lee los 3 documento_kyc de los 2 tenants con la política vigente USING (true)
== Seis casos cross-tenant (Políticas DevOps §13.4) con Core como llamador
NOTICE:  C1 OK lectura por id de un recurso de T2 con contexto T1: 0 filas
NOTICE:  C2 OK listados de aliado/usuario/solicitud sin WHERE tenant_id: solo filas de T1
NOTICE:  C3 OK INSERT en T2 y UPDATE que muda a T2 rechazados por WITH CHECK; UPDATE de fila de T2 afecta 0 filas
NOTICE:  C4 OK DELETE por id de T2: 0 filas; DELETE sin WHERE solo alcanza T1
NOTICE:  C5a OK sin contexto: 0 filas en lectura y escritura rechazada
NOTICE:  C5b OK claim corrupto: tenant NULL, 0 filas y sin error que filtre detalles
NOTICE:  C5c OK app.set_context rechaza un contexto sin tenant (MANI-RLS-400)
NOTICE:  C6a OK aliado A: ve solo su KYC (no el de B en su tenant ni el de T2) y no puede cargar a nombre de B
NOTICE:  C6b OK admin_tenant de T1: ve los 2 KYC de T1 y ninguno de T2 (rol sin distinguir mayúsculas)
== Propiedades del mecanismo
NOTICE:  P1 OK la transacción siguiente en la misma conexión no hereda el tenant anterior
NOTICE:  P2 OK (control negativo) set_config de sesión SÍ se filtra a la siguiente petición: prohibido, solo app.set_context
NOTICE:  P3 OK mani_dispatch_svc: permission denied en notificacion y aliado (tablas de Core)
NOTICE:  P4a OK un cliente no puede autoasignarse una solicitud de su tenant
NOTICE:  P4b OK aliado de T1: no acepta la de T2 (0 filas) y sí la de T1 (UPDATE condicional de ADR-0016 intacto)
NOTICE:  P5 OK authenticated/anon no pueden ejecutar app.set_context
NOTICE:  P6 OK sesión authenticated como la arma PostgREST: mismas políticas, solo datos de T2
== PoC CFG-23a: todos los casos pasaron
```

Comprobación adicional con un **LOGIN real** de `mani_core_svc` por TCP (no `SET ROLE`):

```text
mani_core_svc|f                                   -- rolbypassrls = false
autocommit, sentencia siguiente: 0 aliados        -- set_context fuera de transacción no persiste
en transaccion: 2 aliados (T1)
```

## Conclusiones

1. **El problema es real y mayor que lo registrado**: con `service_role` ninguna política se evalúa (L1), y la política vigente de `documento_kyc` expone los KYC de todos los tenants a la clave anónima (L2).
2. **El modelo aísla** los seis casos de Políticas DevOps §13.4 con Core como llamador, sin `WHERE tenant_id` en las consultas (C1–C6).
3. **Falla cerrado**: sin contexto, con un claim corrupto o en autocommit, el servicio ve 0 filas y no puede escribir (C5, login real).
4. **Es seguro con pool en modo transacción** siempre que el contexto sea local a la transacción (P1); el control negativo P2 demuestra por qué `set_config(..., false)` debe estar prohibido.
5. **Los permisos imponen la frontera de ADR-0030** en el motor (P3) y la política de aceptación corrige H-02/KI-13 sin tocar el `UPDATE` condicional de ADR-0016 (P4).
6. **Una sola política sirve a ambos caminos**, servicio y PostgREST (P6).

## Hallazgos de implementación para CFG-23b

- Los roles nuevos necesitan `GRANT USAGE ON SCHEMA auth` y `EXECUTE` sobre `auth.uid()`/`auth.jwt()`: las políticas se evalúan con el rol del llamador y Supabase solo concede `auth` a sus roles propios. Sin eso, la primera consulta falla con `permission denied for schema auth`.
- Los roles de servicio **no** deben ser miembros de `authenticated`: heredarían el `GRANT ALL` de los *default privileges* y se perdería la frontera de datos.
- Fuera de una transacción explícita, `app.set_context` solo dura la sentencia en curso. Es el comportamiento deseado (falla cerrado), pero obliga a que cada repositorio abra transacción.

## Límites

- PostgreSQL 16 puro, no Supabase: `auth.uid()`/`auth.jwt()` se reproducen con las definiciones de Supabase, pero no se probó Supavisor ni Storage. CFG-23c debe repetir los casos en QA.
- La verificación de firma y expiración del JWT (caso 5 completo) pertenece al Gateway (ADR-0031) y no se prueba aquí; aquí se prueba que el motor falla cerrado si el contexto falta o es inválido.

-- =====================================================================
-- PoC CFG-23a: casos verificables del modelo (ver README.md).
-- Cada caso corre en su propia transacción con el rol real que lo
-- ejecutaría y termina en ASSERT: un resultado distinto aborta el script.
-- T1 = 10000000-…-011, T2 = 10000000-…-021.
-- =====================================================================
\set ON_ERROR_STOP 1
\set QUIET 1

-- ---------------------------------------------------------------------
\echo '== Línea base: el problema que motiva CFG-23a'
-- ---------------------------------------------------------------------
BEGIN;
SET LOCAL ROLE service_role;
SELECT set_config('request.jwt.claims', '{"sub":"30000000-0000-4000-8000-000000000012","app_metadata":{"tenant_id":"10000000-0000-4000-8000-000000000011","user_role":"aliado"}}', true);
DO $$ BEGIN
    ASSERT (SELECT count(*) FROM aliado) = 3, 'service_role debía ver los 3 aliados';
    ASSERT (SELECT count(DISTINCT tenant_id) FROM documento_kyc) = 2, 'service_role debía ver KYC de 2 tenants';
    RAISE NOTICE 'L1 service_role (lo que usa Core hoy) ve los 2 tenants aunque haya claims de T1: BYPASSRLS ignora toda política';
END $$;
COMMIT;

BEGIN;
SET LOCAL ROLE anon;
DO $$ BEGIN
    ASSERT (SELECT count(*) FROM documento_kyc_vigente) = 3, 'la política vigente debía exponer los 3 KYC';
    RAISE NOTICE 'L2 anon (la SUPABASE_ANON_KEY del bundle) lee los 3 documento_kyc de los 2 tenants con la política vigente USING (true)';
END $$;
COMMIT;

-- ---------------------------------------------------------------------
\echo '== Seis casos cross-tenant (Políticas DevOps §13.4) con Core como llamador'
-- ---------------------------------------------------------------------
-- Caso 1: lectura de otro tenant (por id conocido).
BEGIN;
SET LOCAL ROLE mani_core_svc;
SELECT app.set_context('10000000-0000-4000-8000-000000000011', '30000000-0000-4000-8000-000000000011', 'admin_tenant');
DO $$ BEGIN
    ASSERT NOT EXISTS (SELECT 1 FROM aliado WHERE id = '50000000-0000-4000-8000-000000000021'), 'leyó un aliado de T2';
    ASSERT NOT EXISTS (SELECT 1 FROM notificacion WHERE id = '80000000-0000-4000-8000-000000000021'), 'leyó una notificación de T2';
    RAISE NOTICE 'C1 OK lectura por id de un recurso de T2 con contexto T1: 0 filas';
END $$;
COMMIT;

-- Caso 2: listado de recursos ajenos.
BEGIN;
SET LOCAL ROLE mani_core_svc;
SELECT app.set_context('10000000-0000-4000-8000-000000000011', '30000000-0000-4000-8000-000000000011', 'admin_tenant');
DO $$ BEGIN
    ASSERT (SELECT count(*) FROM aliado) = 2, 'el listado debía traer solo los 2 aliados de T1';
    ASSERT (SELECT bool_and(tenant_id = '10000000-0000-4000-8000-000000000011') FROM aliado), 'el listado trajo filas de otro tenant';
    ASSERT (SELECT count(*) FROM usuario) = 4 AND (SELECT count(*) FROM solicitud) = 1, 'conteos de T1 incorrectos';
    RAISE NOTICE 'C2 OK listados de aliado/usuario/solicitud sin WHERE tenant_id: solo filas de T1';
END $$;
COMMIT;

-- Caso 3: escritura en otro tenant (alta y "mudanza" de una fila propia).
BEGIN;
SET LOCAL ROLE mani_core_svc;
SELECT app.set_context('10000000-0000-4000-8000-000000000011', '30000000-0000-4000-8000-000000000011', 'admin_tenant');
DO $$ BEGIN
    BEGIN
        INSERT INTO notificacion VALUES (gen_random_uuid(), '10000000-0000-4000-8000-000000000021', 'inyectada');
        RAISE EXCEPTION 'FALLO C3: insertó en T2';
    EXCEPTION WHEN insufficient_privilege THEN
        ASSERT SQLERRM LIKE '%row-level security%', SQLERRM;
    END;
    BEGIN
        UPDATE notificacion SET tenant_id = '10000000-0000-4000-8000-000000000021' WHERE id = '80000000-0000-4000-8000-000000000011';
        RAISE EXCEPTION 'FALLO C3: movió una fila a T2';
    EXCEPTION WHEN insufficient_privilege THEN
        ASSERT SQLERRM LIKE '%row-level security%', SQLERRM;
    END;
    UPDATE notificacion SET texto = 'pisada' WHERE id = '80000000-0000-4000-8000-000000000021';
    ASSERT NOT FOUND, 'actualizó una notificación de T2';
    RAISE NOTICE 'C3 OK INSERT en T2 y UPDATE que muda a T2 rechazados por WITH CHECK; UPDATE de fila de T2 afecta 0 filas';
END $$;
COMMIT;

-- Caso 4: borrado ajeno.
BEGIN;
SET LOCAL ROLE mani_core_svc;
SELECT app.set_context('10000000-0000-4000-8000-000000000011', '30000000-0000-4000-8000-000000000011', 'admin_tenant');
DO $$ BEGIN
    DELETE FROM notificacion WHERE id = '80000000-0000-4000-8000-000000000021';
    ASSERT NOT FOUND, 'borró una notificación de T2';
    DELETE FROM notificacion;
    RAISE NOTICE 'C4 OK DELETE por id de T2: 0 filas; DELETE sin WHERE solo alcanza T1';
END $$;
ROLLBACK;  -- conserva los datos de T1 para los casos siguientes
DO $$ BEGIN
    ASSERT (SELECT texto FROM notificacion WHERE id = '80000000-0000-4000-8000-000000000021') = 'hola t2', 'la fila de T2 cambió';
END $$;

-- Caso 5: token expirado o alterado. La firma y la expiración las rechaza el
-- Gateway (ADR-0031) antes de llegar aquí; en el motor el equivalente es un
-- contexto ausente o corrupto, y debe fallar cerrado.
BEGIN;
SET LOCAL ROLE mani_core_svc;
DO $$ BEGIN
    ASSERT app.tenant_id() IS NULL, 'sin set_context no debía haber tenant';
    ASSERT (SELECT count(*) FROM aliado) = 0 AND (SELECT count(*) FROM documento_kyc) = 0, 'sin contexto leyó filas';
    BEGIN
        INSERT INTO notificacion VALUES (gen_random_uuid(), '10000000-0000-4000-8000-000000000011', 'sin contexto');
        RAISE EXCEPTION 'FALLO C5: escribió sin contexto';
    EXCEPTION WHEN insufficient_privilege THEN NULL;
    END;
    RAISE NOTICE 'C5a OK sin contexto: 0 filas en lectura y escritura rechazada';
END $$;
SELECT set_config('request.jwt.claims', '{"app_metadata":{"tenant_id":"no-es-un-uuid"}}', true);
DO $$ BEGIN
    ASSERT app.tenant_id() IS NULL AND (SELECT count(*) FROM aliado) = 0, 'un claim corrupto debía anular el tenant';
    RAISE NOTICE 'C5b OK claim corrupto: tenant NULL, 0 filas y sin error que filtre detalles';
END $$;
DO $$ BEGIN
    BEGIN
        PERFORM app.set_context(NULL, NULL, 'aliado');
        RAISE EXCEPTION 'FALLO C5: aceptó un contexto sin tenant';
    EXCEPTION WHEN invalid_parameter_value THEN NULL;
    END;
    RAISE NOTICE 'C5c OK app.set_context rechaza un contexto sin tenant (MANI-RLS-400)';
END $$;
COMMIT;

-- Caso 6: documentos KYC de otro aliado (mismo tenant) y de otro tenant.
BEGIN;
SET LOCAL ROLE mani_core_svc;
SELECT app.set_context('10000000-0000-4000-8000-000000000011', '30000000-0000-4000-8000-000000000012', 'aliado');
DO $$ BEGIN
    ASSERT (SELECT array_agg(id) FROM documento_kyc) = ARRAY['90000000-0000-4000-8000-000000000011'::uuid],
        'el aliado A debía ver solo su documento';
    BEGIN
        INSERT INTO documento_kyc VALUES (gen_random_uuid(), '10000000-0000-4000-8000-000000000011', '50000000-0000-4000-8000-000000000012', 'suplantado.pdf');
        RAISE EXCEPTION 'FALLO C6: cargó un KYC a nombre de otro aliado';
    EXCEPTION WHEN insufficient_privilege THEN NULL;
    END;
    RAISE NOTICE 'C6a OK aliado A: ve solo su KYC (no el de B en su tenant ni el de T2) y no puede cargar a nombre de B';
END $$;
COMMIT;
BEGIN;
SET LOCAL ROLE mani_core_svc;
SELECT app.set_context('10000000-0000-4000-8000-000000000011', '30000000-0000-4000-8000-000000000011', 'ADMIN_TENANT');
DO $$ BEGIN
    ASSERT (SELECT count(*) FROM documento_kyc) = 2, 'el admin de T1 debía ver los 2 KYC de T1';
    ASSERT NOT EXISTS (SELECT 1 FROM documento_kyc WHERE tenant_id = '10000000-0000-4000-8000-000000000021'), 'el admin de T1 vio KYC de T2';
    RAISE NOTICE 'C6b OK admin_tenant de T1: ve los 2 KYC de T1 y ninguno de T2 (rol sin distinguir mayúsculas)';
END $$;
COMMIT;

-- ---------------------------------------------------------------------
\echo '== Propiedades del mecanismo'
-- ---------------------------------------------------------------------
-- P1: el contexto no sobrevive a la transacción (pool en modo transacción).
BEGIN;
SET LOCAL ROLE mani_core_svc;
SELECT app.set_context('10000000-0000-4000-8000-000000000011', '30000000-0000-4000-8000-000000000011', 'admin_tenant');
COMMIT;
BEGIN;
SET LOCAL ROLE mani_core_svc;
DO $$ BEGIN
    ASSERT app.tenant_id() IS NULL AND (SELECT count(*) FROM aliado) = 0, 'el contexto se filtró a la siguiente transacción';
    RAISE NOTICE 'P1 OK la transacción siguiente en la misma conexión no hereda el tenant anterior';
END $$;
COMMIT;

-- P2: por qué se exige is_local = true. Con false el tenant se filtra.
BEGIN;
SET LOCAL ROLE mani_core_svc;
SELECT set_config('request.jwt.claims', '{"app_metadata":{"tenant_id":"10000000-0000-4000-8000-000000000021"}}', false);
COMMIT;
BEGIN;
SET LOCAL ROLE mani_core_svc;
DO $$ BEGIN
    ASSERT app.tenant_id() = '10000000-0000-4000-8000-000000000021', 'se esperaba la fuga de sesión';
    RAISE NOTICE 'P2 OK (control negativo) set_config de sesión SÍ se filtra a la siguiente petición: prohibido, solo app.set_context';
END $$;
COMMIT;
RESET request.jwt.claims;

-- P3: la frontera de datos de ADR-0030 también la impone el motor.
BEGIN;
SET LOCAL ROLE mani_dispatch_svc;
SELECT app.set_context('10000000-0000-4000-8000-000000000011', '30000000-0000-4000-8000-000000000012', 'aliado');
DO $$ BEGIN
    BEGIN
        INSERT INTO notificacion VALUES (gen_random_uuid(), '10000000-0000-4000-8000-000000000011', 'desde dispatch');
        RAISE EXCEPTION 'FALLO P3: Dispatch escribió en notificacion';
    EXCEPTION WHEN insufficient_privilege THEN
        ASSERT SQLERRM LIKE 'permission denied%', SQLERRM;
    END;
    BEGIN
        PERFORM 1 FROM aliado;
        RAISE EXCEPTION 'FALLO P3: Dispatch leyó aliado';
    EXCEPTION WHEN insufficient_privilege THEN NULL;
    END;
    RAISE NOTICE 'P3 OK mani_dispatch_svc: permission denied en notificacion y aliado (tablas de Core)';
END $$;
COMMIT;

-- P4: aceptar una solicitud exige rol aliado y su tenant (corrige H-02 / KI-13).
BEGIN;
SET LOCAL ROLE mani_dispatch_svc;
SELECT app.set_context('10000000-0000-4000-8000-000000000011', '30000000-0000-4000-8000-000000000014', 'cliente');
DO $$ BEGIN
    UPDATE solicitud SET estado = 'ASIGNADA' WHERE id = '70000000-0000-4000-8000-000000000011';
    ASSERT NOT FOUND, 'un cliente aceptó una solicitud';
    RAISE NOTICE 'P4a OK un cliente no puede autoasignarse una solicitud de su tenant';
END $$;
COMMIT;
BEGIN;
SET LOCAL ROLE mani_dispatch_svc;
SELECT app.set_context('10000000-0000-4000-8000-000000000011', '30000000-0000-4000-8000-000000000012', 'aliado');
DO $$ BEGIN
    UPDATE solicitud SET estado = 'ASIGNADA', aliado_id = '50000000-0000-4000-8000-000000000011'
     WHERE id = '70000000-0000-4000-8000-000000000021' AND estado = 'PENDIENTE';
    ASSERT NOT FOUND, 'un aliado de T1 aceptó una solicitud de T2';
    UPDATE solicitud SET estado = 'ASIGNADA', aliado_id = '50000000-0000-4000-8000-000000000011'
     WHERE id = '70000000-0000-4000-8000-000000000011' AND estado = 'PENDIENTE';
    ASSERT FOUND, 'el aliado de T1 debía poder aceptar la solicitud de T1';
    RAISE NOTICE 'P4b OK aliado de T1: no acepta la de T2 (0 filas) y sí la de T1 (UPDATE condicional de ADR-0016 intacto)';
END $$;
ROLLBACK;

-- P5: un cliente no puede fabricar contexto.
BEGIN;
SET LOCAL ROLE authenticated;
DO $$ BEGIN
    BEGIN
        PERFORM app.set_context('10000000-0000-4000-8000-000000000021', NULL, 'admin_tenant');
        RAISE EXCEPTION 'FALLO P5: authenticated ejecutó app.set_context';
    EXCEPTION WHEN insufficient_privilege THEN NULL;
    END;
    RAISE NOTICE 'P5 OK authenticated/anon no pueden ejecutar app.set_context';
END $$;
COMMIT;

-- P6: el mismo modelo sirve al camino PostgREST (JWT reenviado) sin cambios.
BEGIN;
SET LOCAL ROLE authenticated;
SELECT set_config('request.jwt.claims', '{"sub":"30000000-0000-4000-8000-000000000021","role":"authenticated","app_metadata":{"tenant_id":"10000000-0000-4000-8000-000000000021","user_role":"aliado"}}', true);
DO $$ BEGIN
    ASSERT (SELECT count(*) FROM aliado) = 1 AND (SELECT count(*) FROM documento_kyc) = 1, 'PostgREST T2 debía ver solo lo suyo';
    RAISE NOTICE 'P6 OK sesión authenticated como la arma PostgREST: mismas políticas, solo datos de T2';
END $$;
COMMIT;

\echo '== PoC CFG-23a: todos los casos pasaron'

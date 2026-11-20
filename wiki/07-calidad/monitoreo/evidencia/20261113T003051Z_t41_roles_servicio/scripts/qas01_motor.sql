-- SCRUM-1678 (T-41). QAS-01, verificacion en el motor (SDD 8.12) con el rol mani_core_svc.
-- Se conecta con la URL real de Core (DATABASE_URL de /opt/mani/.env.qa), no con postgres ni con SET ROLE.
-- Todo corre en transacciones que terminan en ROLLBACK: no deja cambios en QA.
-- Variables psql (las pasa t41_qa.py): t1, t2, u_admin_t1, u_aliado_t1, sitio_t1, sitio_t2, aliado_t1, sol_t1, sol_t2, cid
-- Salida: lineas "PASA | ..." o "FALLA | ..." y NOTICE con el detalle.
\set ON_ERROR_STOP off
\set ON_ERROR_ROLLBACK on
\set SHOW_CONTEXT never
\pset footer off

\o /dev/null
SELECT set_config('t41.t1', :'t1', false), set_config('t41.t2', :'t2', false),
       set_config('t41.u_admin_t1', :'u_admin_t1', false), set_config('t41.u_aliado_t1', :'u_aliado_t1', false),
       set_config('t41.sitio_t1', :'sitio_t1', false), set_config('t41.sitio_t2', :'sitio_t2', false),
       set_config('t41.aliado_t1', :'aliado_t1', false), set_config('t41.sol_t2', :'sol_t2', false);
\o

\echo == QAS-01 motor, correlation-id de la corrida API: :cid
SELECT CASE WHEN current_user = 'mani_core_svc' AND NOT r.rolbypassrls AND NOT r.rolsuper THEN 'PASA ' ELSE 'FALLA' END
       || ' | QAS-01 motor | identidad de la conexion | mani_core_svc sin BYPASSRLS | current_user=' || current_user
       || ' bypassrls=' || r.rolbypassrls || ' super=' || r.rolsuper
  FROM pg_roles r WHERE r.rolname = current_user;

-- Caso 1: lectura por id de un recurso de T2 con contexto T1
BEGIN;
SELECT app.set_context(:'t1', :'u_admin_t1', 'admin_tenant') \g /dev/null
SELECT CASE WHEN count(*) = 0 THEN 'PASA ' ELSE 'FALLA' END || ' | QAS-01 motor | caso 1 sitio de T2 por id | 0 filas | ' || count(*)
  FROM sitio WHERE id = :'sitio_t2';
SELECT CASE WHEN count(*) = 0 THEN 'PASA ' ELSE 'FALLA' END || ' | QAS-01 motor | caso 1 solicitud de T2 por id | 0 filas | ' || count(*)
  FROM solicitud WHERE id = :'sol_t2';
ROLLBACK;

-- Caso 2: listado sin WHERE tenant_id en toda tabla con tenant_id que el rol puede leer
BEGIN;
SELECT app.set_context(:'t1', :'u_admin_t1', 'admin_tenant') \g /dev/null
DO $$
DECLARE
    t record;
    total bigint;
    ajenas bigint;
    nulas bigint;
    malas int := 0;
    leidas int := 0;
BEGIN
    FOR t IN
        SELECT c.relname FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
         WHERE n.nspname = 'public' AND c.relkind = 'r'
           AND has_table_privilege(current_user, c.oid, 'SELECT')
           AND EXISTS (SELECT 1 FROM pg_attribute a WHERE a.attrelid = c.oid AND a.attname = 'tenant_id' AND NOT a.attisdropped)
         ORDER BY 1
    LOOP
        BEGIN
            EXECUTE format('SELECT count(*), count(*) FILTER (WHERE tenant_id IS NOT NULL AND tenant_id::text <> $1), count(*) FILTER (WHERE tenant_id IS NULL) FROM public.%I', t.relname)
               INTO total, ajenas, nulas USING current_setting('t41.t1');
            leidas := leidas + 1;
            IF ajenas > 0 THEN
                malas := malas + 1;
                RAISE NOTICE 'FALLA | QAS-01 motor | caso 2 % | 0 filas de otro tenant | ajenas=% de %', t.relname, ajenas, total;
            END IF;
            IF nulas > 0 THEN
                RAISE NOTICE 'INFO  | QAS-01 motor | caso 2 % | filas con tenant_id NULL visibles=% de %', t.relname, nulas, total;
            END IF;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'INFO  | QAS-01 motor | caso 2 % | no se pudo leer | % %', t.relname, SQLSTATE, SQLERRM;
        END;
    END LOOP;
    RAISE NOTICE '% | QAS-01 motor | caso 2 listado sin filtro | 0 tablas con filas de otro tenant | tablas_leidas=% con_fuga=%',
        CASE WHEN malas = 0 AND leidas > 0 THEN 'PASA ' ELSE 'FALLA' END, leidas, malas;
END $$;
ROLLBACK;

-- Inspeccion de documento_legal (filas visibles que no son de T1)
BEGIN;
SELECT app.set_context(:'t1', :'u_admin_t1', 'admin_tenant') \g /dev/null
\echo -- documento_legal visible con contexto T1 que no es de T1 (id | tenant_id | tipo | version | is_active)
SELECT id || ' | ' || coalesce(tenant_id::text, 'NULL') || ' | ' || coalesce(tipo, '-') || ' | ' || coalesce(version::text, '-') || ' | ' || coalesce(is_active::text, '-')
  FROM documento_legal WHERE tenant_id IS DISTINCT FROM :'t1'::uuid ORDER BY tenant_id NULLS FIRST, id;
ROLLBACK;

-- Caso 3: escritura en otro tenant
BEGIN;
SELECT app.set_context(:'t1', :'u_admin_t1', 'admin_tenant') \g /dev/null
DO $$
DECLARE
    n bigint;
BEGIN
    BEGIN
        EXECUTE 'INSERT INTO public.sitio SELECT (jsonb_populate_record(NULL::public.sitio, to_jsonb(s) || jsonb_build_object(''id'', gen_random_uuid(), ''tenant_id'', $1::uuid))).* FROM public.sitio s WHERE s.id = $2::uuid'
            USING current_setting('t41.t2'), current_setting('t41.sitio_t1');
        GET DIAGNOSTICS n = ROW_COUNT;
        RAISE NOTICE 'FALLA | QAS-01 motor | caso 3 INSERT con tenant_id de T2 | 42501 por RLS | sin error, filas=%', n;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '% | QAS-01 motor | caso 3 INSERT con tenant_id de T2 | 42501 por RLS | % %',
            CASE WHEN SQLSTATE = '42501' AND SQLERRM ILIKE '%row-level security%' THEN 'PASA ' ELSE 'REVISAR' END, SQLSTATE, SQLERRM;
    END;
    BEGIN
        EXECUTE 'UPDATE public.sitio SET tenant_id = $1::uuid WHERE id = $2::uuid' USING current_setting('t41.t2'), current_setting('t41.sitio_t1');
        GET DIAGNOSTICS n = ROW_COUNT;
        RAISE NOTICE 'FALLA | QAS-01 motor | caso 3 UPDATE que muda fila de T1 a T2 | 42501 por RLS | sin error, filas=%', n;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE '% | QAS-01 motor | caso 3 UPDATE que muda fila de T1 a T2 | 42501 por RLS | % %',
            CASE WHEN SQLSTATE = '42501' AND SQLERRM ILIKE '%row-level security%' THEN 'PASA ' ELSE 'REVISAR' END, SQLSTATE, SQLERRM;
    END;
    BEGIN
        EXECUTE 'UPDATE public.sitio SET tenant_id = tenant_id WHERE id = $1::uuid' USING current_setting('t41.sitio_t2');
        GET DIAGNOSTICS n = ROW_COUNT;
        RAISE NOTICE '% | QAS-01 motor | caso 3 UPDATE de fila de T2 | 0 filas | filas=%', CASE WHEN n = 0 THEN 'PASA ' ELSE 'FALLA' END, n;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'REVISAR | QAS-01 motor | caso 3 UPDATE de fila de T2 | 0 filas | % %', SQLSTATE, SQLERRM;
    END;
END $$;
ROLLBACK;

-- Caso 4: borrado ajeno
BEGIN;
SELECT app.set_context(:'t1', :'u_admin_t1', 'admin_tenant') \g /dev/null
DO $$
DECLARE
    n bigint;
    ajenas bigint;
BEGIN
    BEGIN
        EXECUTE 'DELETE FROM public.sitio WHERE id = $1::uuid' USING current_setting('t41.sitio_t2');
        GET DIAGNOSTICS n = ROW_COUNT;
        RAISE NOTICE '% | QAS-01 motor | caso 4 DELETE de sitio de T2 | 0 filas | filas=%', CASE WHEN n = 0 THEN 'PASA ' ELSE 'FALLA' END, n;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'REVISAR | QAS-01 motor | caso 4 DELETE de sitio de T2 | 0 filas | % %', SQLSTATE, SQLERRM;
    END;
    BEGIN
        EXECUTE 'WITH d AS (DELETE FROM public.sitio RETURNING tenant_id) SELECT count(*), count(*) FILTER (WHERE tenant_id::text <> $1) FROM d'
            INTO n, ajenas USING current_setting('t41.t1');
        RAISE NOTICE '% | QAS-01 motor | caso 4 DELETE sin WHERE solo alcanza T1 | 0 filas de T2 | borradas=% ajenas=% (revertido)',
            CASE WHEN ajenas = 0 THEN 'PASA ' ELSE 'FALLA' END, n, ajenas;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'INFO  | QAS-01 motor | caso 4 DELETE sin WHERE | no ejecutable por restricciones | % %', SQLSTATE, SQLERRM;
    END;
END $$;
ROLLBACK;

-- Caso 5: sin contexto, contexto corrupto y set_context sin tenant
BEGIN;
SELECT CASE WHEN count(*) = 0 THEN 'PASA ' ELSE 'FALLA' END || ' | QAS-01 motor | caso 5 sin set_context lectura | 0 filas | ' || count(*) FROM sitio;
UPDATE sitio SET tenant_id = tenant_id;
ROLLBACK;
BEGIN;
SELECT set_config('request.jwt.claims', '{corrupto', true) \g /dev/null
SELECT CASE WHEN count(*) = 0 THEN 'PASA ' ELSE 'FALLA' END || ' | QAS-01 motor | caso 5 claim corrupto lectura | 0 filas | ' || count(*) FROM sitio;
ROLLBACK;
BEGIN;
DO $$
BEGIN
    PERFORM app.set_context(NULL, NULL, 'admin_tenant');
    RAISE NOTICE 'FALLA | QAS-01 motor | caso 5 set_context sin tenant | MANI-RLS-400 | sin error';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '% | QAS-01 motor | caso 5 set_context sin tenant | MANI-RLS-400 | % %',
        CASE WHEN SQLERRM LIKE 'MANI-RLS-400%' THEN 'PASA ' ELSE 'FALLA' END, SQLSTATE, SQLERRM;
END $$;
ROLLBACK;
\echo -- caso 5 escritura sin contexto: la linea UPDATE de arriba debe decir UPDATE 0

-- Caso 6: documento_kyc como aliado de T1 y como admin de T1; Storage con prefijo de T2
BEGIN;
SELECT app.set_context(:'t1', :'u_aliado_t1', 'aliado') \g /dev/null
SELECT CASE WHEN count(*) FILTER (WHERE aliado_id <> :'aliado_t1'::uuid OR tenant_id <> :'t1'::uuid) = 0 THEN 'PASA ' ELSE 'FALLA' END
       || ' | QAS-01 motor | caso 6 aliado T1 ve solo su documento_kyc | 0 ajenos | visibles=' || count(*)
       || ' ajenos=' || count(*) FILTER (WHERE aliado_id <> :'aliado_t1'::uuid OR tenant_id <> :'t1'::uuid)
  FROM documento_kyc;
ROLLBACK;
BEGIN;
SELECT app.set_context(:'t1', :'u_admin_t1', 'admin_tenant') \g /dev/null
SELECT CASE WHEN count(*) FILTER (WHERE tenant_id <> :'t1'::uuid) = 0 THEN 'PASA ' ELSE 'FALLA' END
       || ' | QAS-01 motor | caso 6 admin T1 sin documento_kyc de T2 | 0 de T2 | visibles=' || count(*)
       || ' de_t2=' || count(*) FILTER (WHERE tenant_id <> :'t1'::uuid)
  FROM documento_kyc;
DO $$
DECLARE
    n bigint;
BEGIN
    IF to_regclass('storage.objects') IS NULL THEN
        RAISE NOTICE 'INFO  | QAS-01 motor | caso 6 Storage | sin esquema storage visible';
        RETURN;
    END IF;
    EXECUTE 'SELECT count(*) FROM storage.objects WHERE name LIKE $1 || ''/%''' INTO n USING current_setting('t41.t2');
    RAISE NOTICE '% | QAS-01 motor | caso 6 Storage objetos bajo {T2}/ | 0 filas o permiso denegado | filas=%', CASE WHEN n = 0 THEN 'PASA ' ELSE 'FALLA' END, n;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '% | QAS-01 motor | caso 6 Storage objetos bajo {T2}/ | 0 filas o permiso denegado | % %',
        CASE WHEN SQLSTATE = '42501' THEN 'PASA ' ELSE 'REVISAR' END, SQLSTATE, SQLERRM;
END $$;
ROLLBACK;

-- P1: el contexto no se hereda entre transacciones de la misma conexion
BEGIN;
SELECT app.set_context(:'t1', :'u_admin_t1', 'admin_tenant') \g /dev/null
SELECT 'INFO  | QAS-01 motor | P1 con contexto en la primera transaccion | filas visibles=' || count(*) FROM sitio;
COMMIT;
BEGIN;
SELECT CASE WHEN count(*) = 0 THEN 'PASA ' ELSE 'FALLA' END || ' | QAS-01 motor | P1 la transaccion siguiente sin set_context | 0 filas | ' || count(*) FROM sitio;
ROLLBACK;

-- P5: un cliente no fabrica contexto
SELECT CASE WHEN NOT has_function_privilege('authenticated', 'app.set_context(uuid,uuid,text)', 'EXECUTE')
             AND NOT has_function_privilege('anon', 'app.set_context(uuid,uuid,text)', 'EXECUTE') THEN 'PASA ' ELSE 'FALLA' END
       || ' | QAS-01 motor | P5 authenticated y anon sin EXECUTE en app.set_context | false/false | '
       || has_function_privilege('authenticated', 'app.set_context(uuid,uuid,text)', 'EXECUTE') || '/'
       || has_function_privilege('anon', 'app.set_context(uuid,uuid,text)', 'EXECUTE');
\echo == fin QAS-01 motor

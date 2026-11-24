-- SCRUM-1678 (T-41). QAS-20 (frontera de datos, ADR-0030 y decision 6A) y P3 de SDD 8.12, con el rol mani_dispatch_svc.
-- Se conecta con la URL real de Dispatch (DISPATCH_DB_CONNECTION de /opt/mani/.env.qa, convertida a URL), no con postgres.
-- Todo corre en una transaccion que termina en ROLLBACK: no deja cambios en QA.
-- Variables psql: t1, u_aliado_t1, aliado_t1, sol_t1, cid
\set ON_ERROR_STOP off
\set ON_ERROR_ROLLBACK on
\set SHOW_CONTEXT never
\pset footer off

\o /dev/null
SELECT set_config('t41.t1', :'t1', false), set_config('t41.aliado_t1', :'aliado_t1', false), set_config('t41.sol_t1', :'sol_t1', false);
\o

\echo == QAS-20 motor, correlation-id de la corrida API: :cid
SELECT CASE WHEN current_user = 'mani_dispatch_svc' AND NOT r.rolbypassrls AND NOT r.rolsuper THEN 'PASA ' ELSE 'FALLA' END
       || ' | QAS-20 motor | identidad de la conexion | mani_dispatch_svc sin BYPASSRLS | current_user=' || current_user
       || ' bypassrls=' || r.rolbypassrls || ' super=' || r.rolsuper
  FROM pg_roles r WHERE r.rolname = current_user;

BEGIN;
SELECT app.set_context(:'t1', :'u_aliado_t1', 'aliado') \g /dev/null
DO $$
DECLARE
    intento record;
    n bigint;
BEGIN
    -- Escrituras y lecturas prohibidas: tablas de Core
    FOR intento IN
        SELECT * FROM (VALUES
            ('P3 INSERT en notificacion', 'INSERT INTO public.notificacion DEFAULT VALUES'),
            ('P3 UPDATE en aliado', 'UPDATE public.aliado SET id = id WHERE false'),
            ('P3 SELECT en aliado', 'SELECT count(*) FROM public.aliado'),
            ('P3 SELECT en notificacion', 'SELECT count(*) FROM public.notificacion'),
            ('6A UPDATE en solicitud', 'UPDATE public.solicitud SET estado = estado WHERE false'),
            ('0046 SELECT en solicitud', 'SELECT count(*) FROM public.solicitud'),
            ('0046 SELECT en tenant', 'SELECT count(*) FROM public.tenant'),
            ('0046 SELECT en zona', 'SELECT count(*) FROM public.zona'),
            ('INSERT en cotizacion', 'INSERT INTO public.cotizacion DEFAULT VALUES'),
            ('DELETE en pago', 'DELETE FROM public.pago WHERE false')
        ) AS v(caso, sentencia)
    LOOP
        BEGIN
            EXECUTE intento.sentencia;
            RAISE NOTICE 'FALLA | QAS-20 motor | % | permission denied | sin error', intento.caso;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE '% | QAS-20 motor | % | permission denied | % %',
                CASE WHEN SQLSTATE = '42501' AND SQLERRM ILIKE 'permission denied%' THEN 'PASA ' ELSE 'REVISAR' END, intento.caso, SQLSTATE, SQLERRM;
        END;
    END LOOP;

    -- Escritura permitida: Dispatch es dueno del rechazo (solicitud_rechazo)
    BEGIN
        EXECUTE 'INSERT INTO public.solicitud_rechazo (tenant_id, solicitud_id, aliado_id, motivo) VALUES ($1::uuid, $2::uuid, $3::uuid, ''SIN_DISPONIBILIDAD'')'
            USING current_setting('t41.t1'), current_setting('t41.sol_t1'), current_setting('t41.aliado_t1');
        GET DIAGNOSTICS n = ROW_COUNT;
        RAISE NOTICE '% | QAS-20 motor | escritura permitida INSERT en solicitud_rechazo | 1 fila (revertida) | filas=%', CASE WHEN n = 1 THEN 'PASA ' ELSE 'FALLA' END, n;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'REVISAR | QAS-20 motor | escritura permitida INSERT en solicitud_rechazo | 1 fila (revertida) | % %', SQLSTATE, SQLERRM;
    END;
END $$;
ROLLBACK;

SELECT CASE WHEN string_agg(c.relname, ',' ORDER BY c.relname) = 'solicitud_rechazo' THEN 'PASA ' ELSE 'FALLA' END
       || ' | QAS-20 motor | tablas de public con algun permiso de mani_dispatch_svc | solicitud_rechazo | ' || coalesce(string_agg(c.relname, ',' ORDER BY c.relname), '(ninguna)')
  FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
 WHERE n.nspname = 'public' AND c.relkind IN ('r', 'p', 'v', 'm')
   AND has_table_privilege('mani_dispatch_svc', c.oid, 'SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER');

\echo -- privilegios efectivos de mani_dispatch_svc por tabla (tabla | S I U D)
SELECT c.relname || ' | '
       || CASE WHEN has_table_privilege('mani_dispatch_svc', c.oid, 'SELECT') THEN 'S' ELSE '-' END
       || CASE WHEN has_table_privilege('mani_dispatch_svc', c.oid, 'INSERT') THEN 'I' ELSE '-' END
       || CASE WHEN has_table_privilege('mani_dispatch_svc', c.oid, 'UPDATE') THEN 'U' ELSE '-' END
       || CASE WHEN has_table_privilege('mani_dispatch_svc', c.oid, 'DELETE') THEN 'D' ELSE '-' END
  FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
 WHERE n.nspname = 'public' AND c.relkind = 'r'
   AND (has_table_privilege('mani_dispatch_svc', c.oid, 'SELECT') OR has_table_privilege('mani_dispatch_svc', c.oid, 'INSERT')
        OR has_table_privilege('mani_dispatch_svc', c.oid, 'UPDATE') OR has_table_privilege('mani_dispatch_svc', c.oid, 'DELETE'))
 ORDER BY 1;

\echo -- tablas de Dispatch sobre las que mani_core_svc tiene escritura (tabla | S I U D)
SELECT c.relname || ' | '
       || CASE WHEN has_table_privilege('mani_core_svc', c.oid, 'SELECT') THEN 'S' ELSE '-' END
       || CASE WHEN has_table_privilege('mani_core_svc', c.oid, 'INSERT') THEN 'I' ELSE '-' END
       || CASE WHEN has_table_privilege('mani_core_svc', c.oid, 'UPDATE') THEN 'U' ELSE '-' END
       || CASE WHEN has_table_privilege('mani_core_svc', c.oid, 'DELETE') THEN 'D' ELSE '-' END
  FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
 WHERE n.nspname = 'public' AND c.relkind = 'r' AND c.relname IN ('solicitud_rechazo')
 ORDER BY 1;

SELECT count(*) FILTER (WHERE has_table_privilege('mani_core_svc', c.oid, 'SELECT')) || ' lectura, '
       || count(*) FILTER (WHERE has_table_privilege('mani_core_svc', c.oid, 'INSERT') OR has_table_privilege('mani_core_svc', c.oid, 'UPDATE') OR has_table_privilege('mani_core_svc', c.oid, 'DELETE'))
       || ' escritura, de ' || count(*) || ' tablas (mani_core_svc)'
  FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace WHERE n.nspname = 'public' AND c.relkind = 'r';
\echo == fin QAS-20 motor

-- =====================================================================
-- PoC CFG-23a (SCRUM-1103): modelo de identidad en base de datos para
-- llamadores de servicio. PostgreSQL 16 limpio que emula lo que Supabase
-- aporta (roles anon/authenticated/service_role y auth.uid()/auth.jwt()),
-- y sobre eso aplica el modelo propuesto en ADR-0032.
--
-- Ejecutar:  psql -v ON_ERROR_STOP=1 -f 01-modelo.sql -f 02-casos.sql
-- No es una migración: la migración real la versiona CFG-23b en
-- MANI-Node/db/migrations (ADR-0030).
-- =====================================================================

-- 1. Lo que ya existe en Supabase ---------------------------------------
CREATE ROLE anon NOLOGIN;
CREATE ROLE authenticated NOLOGIN;
CREATE ROLE service_role NOLOGIN BYPASSRLS;   -- así viene en Supabase

CREATE SCHEMA auth;
-- Definiciones equivalentes a las de Supabase: ambas leen el GUC de la
-- transacción que PostgREST (o, con este modelo, el servicio) establece.
CREATE FUNCTION auth.jwt() RETURNS jsonb LANGUAGE sql STABLE AS $$
    SELECT coalesce(nullif(current_setting('request.jwt.claim', true), ''),
                    nullif(current_setting('request.jwt.claims', true), ''))::jsonb
$$;
CREATE FUNCTION auth.uid() RETURNS uuid LANGUAGE sql STABLE AS $$
    SELECT coalesce(nullif(current_setting('request.jwt.claim.sub', true), ''),
                    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub'))::uuid
$$;
GRANT USAGE ON SCHEMA auth TO anon, authenticated, service_role;

-- 2. Roles de servicio (propuesta) ---------------------------------------
-- Sin BYPASSRLS, sin SUPERUSER y sin ser dueños de las tablas: RLS aplica.
-- Rules no tiene rol: no accede a la base (ADR-0022/0030).
CREATE ROLE mani_core_svc     LOGIN NOBYPASSRLS PASSWORD 'poc';
CREATE ROLE mani_dispatch_svc LOGIN NOBYPASSRLS PASSWORD 'poc';
-- Las políticas evalúan auth.jwt()/auth.uid() con el rol del llamador: un rol
-- nuevo necesita USAGE sobre auth (Supabase solo lo da a sus roles propios).
GRANT USAGE ON SCHEMA auth TO mani_core_svc, mani_dispatch_svc;
GRANT EXECUTE ON FUNCTION auth.jwt(), auth.uid() TO mani_core_svc, mani_dispatch_svc;

-- 3. Contexto de identidad -------------------------------------------------
CREATE SCHEMA app;
REVOKE ALL ON SCHEMA app FROM PUBLIC;
GRANT USAGE ON SCHEMA app TO authenticated, mani_core_svc, mani_dispatch_svc;

-- Lectores del contexto: una sola fuente (request.jwt.claims) para PostgREST
-- y para servicios. Un claim ausente o malformado devuelve NULL, y NULL nunca
-- iguala a un tenant_id: la política falla cerrada en vez de lanzar error.
CREATE FUNCTION app.tenant_id() RETURNS uuid LANGUAGE plpgsql STABLE
SET search_path = '' AS $$
BEGIN
    RETURN (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid;
EXCEPTION WHEN invalid_text_representation OR invalid_parameter_value THEN
    RETURN NULL;
END $$;

CREATE FUNCTION app.user_id() RETURNS uuid LANGUAGE plpgsql STABLE
SET search_path = '' AS $$
BEGIN
    RETURN auth.uid();
EXCEPTION WHEN invalid_text_representation THEN
    RETURN NULL;
END $$;

CREATE FUNCTION app.user_role() RETURNS text LANGUAGE sql STABLE
SET search_path = '' AS $$
    SELECT lower(auth.jwt() -> 'app_metadata' ->> 'user_role')
$$;

GRANT EXECUTE ON FUNCTION app.tenant_id(), app.user_id(), app.user_role()
    TO authenticated, mani_core_svc, mani_dispatch_svc;

-- Escritor del contexto: lo invoca el servicio como primera sentencia de
-- cada transacción con los claims YA VERIFICADOS (X-Tenant-Id/X-User-Id/
-- X-User-Role del Gateway, ADR-0031). is_local = true: el valor muere con
-- la transacción y no se filtra a la siguiente petición del pool.
CREATE FUNCTION app.set_context(p_tenant_id uuid, p_user_id uuid, p_user_role text)
RETURNS void LANGUAGE plpgsql
SET search_path = '' AS $$
BEGIN
    IF p_tenant_id IS NULL THEN
        RAISE EXCEPTION 'MANI-RLS-400: el contexto exige tenant_id' USING ERRCODE = '22023';
    END IF;
    PERFORM pg_catalog.set_config('request.jwt.claims', pg_catalog.json_build_object(
        'sub', p_user_id,
        'role', 'authenticated',
        'app_metadata', pg_catalog.json_build_object('tenant_id', p_tenant_id, 'user_role', lower(p_user_role))
    )::text, true);
END $$;
REVOKE ALL ON FUNCTION app.set_context(uuid, uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION app.set_context(uuid, uuid, text) TO mani_core_svc, mani_dispatch_svc;

-- 4. Tablas mínimas (mismas columnas relevantes que el esquema real) -----
CREATE TABLE tenant (id uuid PRIMARY KEY, slug text UNIQUE NOT NULL);
CREATE TABLE usuario (id uuid PRIMARY KEY, tenant_id uuid NOT NULL REFERENCES tenant, rol text NOT NULL);
CREATE TABLE aliado (id uuid PRIMARY KEY, tenant_id uuid NOT NULL REFERENCES tenant, usuario_id uuid NOT NULL REFERENCES usuario, nombre text);
CREATE TABLE documento_kyc (id uuid PRIMARY KEY, tenant_id uuid NOT NULL REFERENCES tenant, aliado_id uuid NOT NULL REFERENCES aliado, ruta_storage text);
CREATE TABLE solicitud (id uuid PRIMARY KEY, tenant_id uuid NOT NULL REFERENCES tenant, estado text NOT NULL, aliado_id uuid REFERENCES aliado);
CREATE TABLE notificacion (id uuid PRIMARY KEY, tenant_id uuid NOT NULL REFERENCES tenant, texto text);
-- Réplica de la política vigente de 04-supabase-rls-and-functions.sql para medir la exposición actual.
CREATE TABLE documento_kyc_vigente (LIKE documento_kyc INCLUDING ALL);

-- 5. Privilegios ----------------------------------------------------------
-- Igual que Supabase: sus default privileges dan ALL sobre public a anon,
-- authenticated y service_role. Para esos roles RLS es la única barrera.
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;

-- Roles de servicio: NO heredan esos defaults (no son miembros de
-- authenticated). Reciben solo lo de su dominio: la frontera de datos de
-- ADR-0030 queda impuesta también por el motor.
GRANT SELECT ON tenant TO mani_core_svc, mani_dispatch_svc;
GRANT SELECT, INSERT, UPDATE, DELETE ON usuario, aliado, documento_kyc, notificacion TO mani_core_svc;
GRANT SELECT, INSERT, UPDATE ON solicitud TO mani_core_svc;
GRANT SELECT, UPDATE ON solicitud TO mani_dispatch_svc;              -- Dispatch: aceptación
-- Dispatch NO recibe permisos sobre notificacion, aliado ni documento_kyc.

-- 6. RLS: ENABLE + FORCE en toda tabla con tenant_id ----------------------
DO $$
DECLARE t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['usuario','aliado','documento_kyc','solicitud','notificacion','documento_kyc_vigente'] LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', t);
        EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', t);
    END LOOP;
END $$;
ALTER TABLE tenant ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_lectura ON tenant FOR SELECT TO anon, authenticated, mani_core_svc, mani_dispatch_svc USING (true);

-- Patrón general por tenant (usuario, aliado, notificacion). Nunca TO public.
DO $$
DECLARE t text;
BEGIN
    FOREACH t IN ARRAY ARRAY['usuario','aliado','notificacion'] LOOP
        EXECUTE format($p$CREATE POLICY %1$s_tenant ON %1$I FOR ALL TO authenticated, mani_core_svc
                         USING (tenant_id = app.tenant_id()) WITH CHECK (tenant_id = app.tenant_id())$p$, t);
    END LOOP;
END $$;

-- KYC: del propio aliado, o cualquiera del tenant si es admin_tenant (DD V2 §8.2).
CREATE POLICY documento_kyc_lectura ON documento_kyc FOR SELECT TO authenticated, mani_core_svc
    USING (tenant_id = app.tenant_id()
           AND (app.user_role() = 'admin_tenant'
                OR aliado_id IN (SELECT a.id FROM aliado a WHERE a.usuario_id = app.user_id())));
CREATE POLICY documento_kyc_alta ON documento_kyc FOR INSERT TO authenticated, mani_core_svc
    WITH CHECK (tenant_id = app.tenant_id()
                AND aliado_id IN (SELECT a.id FROM aliado a WHERE a.usuario_id = app.user_id()));

-- Solicitud: lectura por tenant; aceptar (UPDATE) solo un aliado (corrige H-02/KI-13).
CREATE POLICY solicitud_lectura ON solicitud FOR SELECT TO authenticated, mani_core_svc, mani_dispatch_svc
    USING (tenant_id = app.tenant_id());
CREATE POLICY solicitud_alta_cliente ON solicitud FOR INSERT TO authenticated, mani_core_svc
    WITH CHECK (tenant_id = app.tenant_id() AND app.user_role() = 'cliente');
CREATE POLICY solicitud_aceptar_aliado ON solicitud FOR UPDATE TO authenticated, mani_dispatch_svc
    USING (tenant_id = app.tenant_id() AND app.user_role() = 'aliado')
    WITH CHECK (tenant_id = app.tenant_id());

-- Política vigente hoy en documento_kyc (04-supabase-rls-and-functions.sql), sin cambios.
CREATE POLICY "Aliados pueden consultar sus documentos KYC" ON documento_kyc_vigente FOR SELECT USING (true);

-- 7. Datos: dos tenants, un admin y dos aliados en T1, un aliado en T2 ----
INSERT INTO tenant VALUES
  ('10000000-0000-4000-8000-000000000011', 'tenant-uno'),
  ('10000000-0000-4000-8000-000000000021', 'tenant-dos');
INSERT INTO usuario VALUES
  ('30000000-0000-4000-8000-000000000011', '10000000-0000-4000-8000-000000000011', 'ADMIN_TENANT'),
  ('30000000-0000-4000-8000-000000000012', '10000000-0000-4000-8000-000000000011', 'ALIADO'),
  ('30000000-0000-4000-8000-000000000013', '10000000-0000-4000-8000-000000000011', 'ALIADO'),
  ('30000000-0000-4000-8000-000000000014', '10000000-0000-4000-8000-000000000011', 'CLIENTE'),
  ('30000000-0000-4000-8000-000000000021', '10000000-0000-4000-8000-000000000021', 'ALIADO');
INSERT INTO aliado VALUES
  ('50000000-0000-4000-8000-000000000011', '10000000-0000-4000-8000-000000000011', '30000000-0000-4000-8000-000000000012', 'Aliado A T1'),
  ('50000000-0000-4000-8000-000000000012', '10000000-0000-4000-8000-000000000011', '30000000-0000-4000-8000-000000000013', 'Aliado B T1'),
  ('50000000-0000-4000-8000-000000000021', '10000000-0000-4000-8000-000000000021', '30000000-0000-4000-8000-000000000021', 'Aliado T2');
INSERT INTO documento_kyc VALUES
  ('90000000-0000-4000-8000-000000000011', '10000000-0000-4000-8000-000000000011', '50000000-0000-4000-8000-000000000011', 't1/a/cedula.pdf'),
  ('90000000-0000-4000-8000-000000000012', '10000000-0000-4000-8000-000000000011', '50000000-0000-4000-8000-000000000012', 't1/b/cedula.pdf'),
  ('90000000-0000-4000-8000-000000000021', '10000000-0000-4000-8000-000000000021', '50000000-0000-4000-8000-000000000021', 't2/c/cedula.pdf');
INSERT INTO documento_kyc_vigente SELECT * FROM documento_kyc;
INSERT INTO solicitud VALUES
  ('70000000-0000-4000-8000-000000000011', '10000000-0000-4000-8000-000000000011', 'PENDIENTE', NULL),
  ('70000000-0000-4000-8000-000000000021', '10000000-0000-4000-8000-000000000021', 'PENDIENTE', NULL);
INSERT INTO notificacion VALUES
  ('80000000-0000-4000-8000-000000000011', '10000000-0000-4000-8000-000000000011', 'hola t1'),
  ('80000000-0000-4000-8000-000000000021', '10000000-0000-4000-8000-000000000021', 'hola t2');

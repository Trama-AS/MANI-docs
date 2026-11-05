-- =====================================================================
-- MANI - QAS-07: verificacion en base de la aceptacion concurrente
-- =====================================================================
-- Solo lectura. Se ejecuta en el proyecto Supabase MANI-QA despues de
-- una corrida de qas07_aceptacion_concurrente.js en MODO=evidencia,
-- con la implementacion real de MANI-.NET #1 (SCRUM-1074) desplegada.
-- La implementacion asigna con un UPDATE condicional sobre solicitud
-- (estado = 'PENDIENTE'), segun ADR-0021.
--
-- Una fila de solicitud solo guarda un aliado_id: si dos aceptaciones
-- hubieran ganado, la segunda habria sobrescrito a la primera. Por eso la
-- doble asignacion se detecta asi:
--   a) k6 reporta exito_200 > 1, o
--   b) el aliado_id persistido no es el aliado que recibio el 200.
--
-- Variables (psql -v):
--   solicitud_id     id usado en la corrida
--   aliado_ganador   aliado_id del VU que recibio 200 (salida de k6)
-- =====================================================================

-- 1. Estado final: debe quedar ASIGNADA.
select id, tenant_id, estado, aliado_id, updated_at
from solicitud
where id = :'solicitud_id';

-- 2. Coincidencia con el ganador de k6: debe devolver coincide = true.
select (aliado_id::text = :'aliado_ganador') as coincide
from solicitud
where id = :'solicitud_id';

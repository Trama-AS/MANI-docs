#!/usr/bin/env bash
# T-46: verifica en la base las solicitudes de las rondas (solo lectura, transaccion revertida). Pide la contrasena de la VM.
# Equivale a qas07_verificar_asignacion.sql: estado ASIGNADA, un solo aliado y coincide con el ganador de k6.
set -u
cd "$(dirname "$0")/.."
SAL="qa_t46/evidencia/qas41_verificacion_base_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
IDS='03490d4a-cdb2-43ea-8982-9aeb312cad01 6ef93e76-9749-401a-a3a5-2499a0876931 0b226a4a-a79c-439b-8ded-d239655d47c2 04b65083-ab19-4575-84e4-9a5c00a0a3bd 5aedc113-aa96-4af8-a076-19ce91cc97c8 16188038-c41c-4a08-8d2b-6b5be7ddbee2 b94cdb40-ceec-4bbc-9b03-f2de0b87fdaa'
{ echo "const IDS='$IDS'.split(' ');"; cat <<'JS'; } | ssh -o ConnectTimeout=15 estudiante@10.43.100.141 "docker exec -i mani-core-service node" | tee "$SAL"
const { Client } = require('pg');
const T = '10000000-0000-4000-8000-000000000011';
const c = new Client({ connectionString: process.env.DATABASE_URL, connectionTimeoutMillis: 10000, ssl: { rejectUnauthorized: false } });
const q = async (titulo, sql, p) => {
  try { const r = await c.query(sql, p); console.log(`== ${titulo}`); console.table(r.rows); }
  catch (e) { console.log(`== ${titulo}: ERROR ${e.code} ${e.message}`); }
};
(async () => {
  await c.connect();
  await c.query('BEGIN READ ONLY');
  await c.query('SELECT app.set_context($1, NULL, $2)', [T, 'admin']).catch((e) => console.log('set_context:', e.message));
  console.log(`== Fecha ${new Date().toISOString()}`);
  await q('Solicitudes de T-46: estado y aliado persistido', `SELECT s.id, s.estado, s.aliado_id, u.email aliado, s.updated_at FROM solicitud s LEFT JOIN aliado a ON a.id=s.aliado_id LEFT JOIN usuario u ON u.id=a.usuario_id WHERE s.id = ANY($1::uuid[]) ORDER BY s.created_at`, [IDS]);
  await q('Notificaciones por solicitud y tipo (ofertas enviadas y avisos de asignacion)', `SELECT n.payload->>'requestId' solicitud, n.tipo, count(*)::int n FROM notificacion n WHERE n.tenant_id=$1 AND n.payload->>'requestId' = ANY($2) GROUP BY 1,2 ORDER BY 1,2`, [T, IDS]);
  await c.query('ROLLBACK'); await c.end();
})().catch((e) => { console.log('ERROR', e.code || '', e.message); process.exit(0); });
JS
echo "== salida guardada en $SAL"

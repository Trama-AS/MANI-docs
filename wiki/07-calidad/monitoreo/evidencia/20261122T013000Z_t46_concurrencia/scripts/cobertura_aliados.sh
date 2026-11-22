#!/usr/bin/env bash
# T-46: categorias y zonas que cubren los aliados del tenant 1 y sitios de cliente.t1, para crear una solicitud
# que reciba oferta de los dos aliados. Solo lectura, dentro de una transaccion que se revierte. Pide la contrasena de la VM.
set -u
cd "$(dirname "$0")/.."
SAL="qa_t46/evidencia/cobertura_aliados_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
ssh -o ConnectTimeout=15 estudiante@10.43.100.141 "docker exec -i mani-core-service node" <<'JS' | tee "$SAL"
const { Client } = require('pg');
const T = '10000000-0000-4000-8000-000000000011';
const c = new Client({ connectionString: process.env.DATABASE_URL, connectionTimeoutMillis: 10000, ssl: { rejectUnauthorized: false } });
const q = async (titulo, sql, p = []) => {
  try { const r = await c.query(sql, p); console.log(`== ${titulo}`); console.table(r.rows); }
  catch (e) { console.log(`== ${titulo}: ERROR ${e.code} ${e.message}`); }
};
(async () => {
  await c.connect();
  await c.query('BEGIN READ ONLY');
  await c.query('SELECT app.set_context($1, NULL, $2)', [T, 'admin']).catch((e) => console.log('set_context:', e.message));
  await q('Aliados del tenant 1', `SELECT a.id aliado_id, u.email, a.estado_verificacion, u.estado FROM aliado a JOIN usuario u ON u.id=a.usuario_id AND u.tenant_id=a.tenant_id WHERE a.tenant_id=$1 ORDER BY u.email`, [T]);
  await q('Categorias por aliado', `SELECT u.email, cs.nombre categoria, cs.id categoria_id FROM aliado_categoria ac JOIN aliado a ON a.id=ac.aliado_id JOIN usuario u ON u.id=a.usuario_id JOIN categoria_servicio cs ON cs.id=ac.categoria_id WHERE ac.tenant_id=$1 ORDER BY 2,1`, [T]);
  await q('Cobertura por aliado', `SELECT u.email, z.nombre zona, z.id zona_id FROM cobertura_aliado ca JOIN aliado a ON a.id=ca.aliado_id JOIN usuario u ON u.id=a.usuario_id JOIN zona z ON z.id=ca.zona_id WHERE ca.tenant_id=$1 ORDER BY 2,1`, [T]);
  await q('Sitios de cliente.t1', `SELECT s.id sitio_id, s.nombre, z.nombre zona, z.id zona_id, zp.nombre zona_padre FROM sitio s JOIN zona z ON z.id=s.zona_id LEFT JOIN zona zp ON zp.id=z.zona_padre_id JOIN cliente cl ON cl.id=s.cliente_id JOIN usuario u ON u.id=cl.usuario_id WHERE s.tenant_id=$1 AND u.email='cliente.t1@qa.mani.test'`, [T]);
  await c.query('ROLLBACK'); await c.end();
})().catch((e) => { console.log('ERROR', e.code || '', e.message); process.exit(0); });
JS
echo "== salida guardada en $SAL"

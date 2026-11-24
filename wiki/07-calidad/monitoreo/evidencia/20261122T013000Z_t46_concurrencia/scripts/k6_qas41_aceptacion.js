// =====================================================================
// MANI - T-46 (SCRUM-1683), QAS-41 y parte de conflicto de QAS-07
// Aceptacion concurrente de UNA solicitud por varios aliados, sobre
// Dispatch real (release eedb112) y el comando de asignacion de Core.
// =====================================================================
// Basado en wiki/07-calidad/monitoreo/k6/qas07_aceptacion_concurrente.js.
// Cambios: tokens reales de aliados distintos (el aliado sale del claim),
// sin allyId en el cuerpo, clasificacion por el cuerpo de la respuesta
// (asignada, reintento idempotente, 409 por codigo) y N por defecto 38:
// el Gateway admite 41 escrituras de golpe por IP (write_limit, burst 40
// nodelay); la ronda gasta 1 en crear la solicitud y 1 en el reintento.
//
// VARIABLES (-e)
//   BASE_URL        Gateway (por defecto http://10.43.100.141:8080)
//   SOLICITUD_ID    solicitud PENDIENTE recien creada (obligatoria)
//   ARCHIVO_TOKENS  JSON {"aliados":[{"correo","token"}]} (obligatoria)
//   N               aceptaciones simultaneas (por defecto 38)
//   RONDA           numero de ronda, solo para el resumen
//   SALIDA          archivo JSON del resumen
// No imprime tokens.
// =====================================================================

import http from 'k6/http';
import exec from 'k6/execution';
import { Counter } from 'k6/metrics';

const base_url = __ENV.BASE_URL || 'http://10.43.100.141:8080';
const n = parseInt(__ENV.N || '38', 10);
const solicitud_id = __ENV.SOLICITUD_ID;
if (!solicitud_id) throw new Error('Falta SOLICITUD_ID');
const aliados = JSON.parse(open(__ENV.ARCHIVO_TOKENS)).aliados;
if (!aliados || aliados.length < 1) throw new Error('ARCHIVO_TOKENS sin aliados');

const asignada = new Counter('asignada_200');
const reintento = new Counter('reintento_idempotente_200');
const conflicto = new Counter('conflicto_409');
const otros = new Counter('otros_status');
const reintento_ganador = new Counter('reintento_ganador_200');

export const options = {
  scenarios: { qas41: { executor: 'per-vu-iterations', vus: n, iterations: 1, maxDuration: '90s' } },
  thresholds: { asignada_200: ['count==1'], otros_status: ['count==0'] },
};

function aceptar(token, correlacion) {
  return http.post(`${base_url}/api/v1/dispatch/requests/${solicitud_id}/accept`, null, {
    headers: { Authorization: `Bearer ${token}`, 'X-Correlation-ID': correlacion },
    timeout: '30s',
    tags: { name: 'accept' },
  });
}

function cuerpo(r) {
  try { return JSON.parse(r.body); } catch (e) { return {}; }
}

export default function () {
  const vu = exec.vu.idInTest;
  const aliado = aliados[(vu - 1) % aliados.length];
  const r = aceptar(aliado.token, `qa-t46-${solicitud_id.slice(0, 8)}-${vu}`);
  const b = cuerpo(r);
  const linea = { vu, aliado: aliado.correo, status: r.status, ms: Math.round(r.timings.duration),
    code: b.code || b.error_code || null, isRetry: b.isRetry ?? null, assignedAllyId: b.assignedAllyId || null };
  console.log(`RESULTADO ${JSON.stringify(linea)}`);
  if (r.status === 200 && b.isRetry === false) {
    asignada.add(1);
    const rep = aceptar(aliado.token, `qa-t46-${solicitud_id.slice(0, 8)}-${vu}-reintento`);
    const rb = cuerpo(rep);
    console.log(`REINTENTO ${JSON.stringify({ vu, status: rep.status, isRetry: rb.isRetry ?? null, assignedAllyId: rb.assignedAllyId || null })}`);
    if (rep.status === 200 && rb.isRetry === true && rb.assignedAllyId === b.assignedAllyId) reintento_ganador.add(1);
  } else if (r.status === 200) {
    reintento.add(1);
  } else if (r.status === 409) {
    conflicto.add(1);
  } else {
    otros.add(1);
  }
}

function contar(data, m) {
  return data.metrics[m] && data.metrics[m].values ? data.metrics[m].values.count : 0;
}

export function handleSummary(data) {
  const d = data.metrics.http_req_duration && data.metrics.http_req_duration.values;
  const resumen = {
    escenario: 'QAS-41 / QAS-07 (asignacion y conflicto)', ticket: 'SCRUM-1683', fecha_utc: new Date().toISOString(),
    base_url, ronda: __ENV.RONDA || null, solicitud_id, aliados: aliados.map((a) => a.correo), aceptaciones_simultaneas: n,
    medido: {
      asignada_200: contar(data, 'asignada_200'),
      reintento_idempotente_200: contar(data, 'reintento_idempotente_200'),
      conflicto_409: contar(data, 'conflicto_409'),
      otros_status: contar(data, 'otros_status'),
      reintento_ganador_200: contar(data, 'reintento_ganador_200'),
      p95_ms: d ? Math.round(d['p(95)']) : null, max_ms: d ? Math.round(d.max) : null,
    },
  };
  const m = resumen.medido;
  const texto = `ronda=${resumen.ronda} solicitud=${solicitud_id} n=${n} -> asignada=${m.asignada_200} reintento_mismo_aliado=${m.reintento_idempotente_200} 409=${m.conflicto_409} otros=${m.otros_status} reintento_ganador=${m.reintento_ganador_200} p95=${m.p95_ms}ms\n`;
  const out = { stdout: texto };
  if (__ENV.SALIDA) out[__ENV.SALIDA] = JSON.stringify(resumen, null, 2);
  return out;
}

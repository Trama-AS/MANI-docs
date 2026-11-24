// QAS-18, 24 nov. Copia de qa_t42/k6_qas_carga.js con otro prefijo de correlation ID. Solo lecturas.
// MODO=consulta mide solo la consulta de aliados por categoria y zona; MODO=mezcla reparte la carga entre rutas criticas.
// Variables: ARCHIVO_TOKENS (JSON con cliente y aliado), SOLICITUD, BASE_URL, MODO, VUS, RPS, RAMPA, DURACION, SALIDA.
import http from 'k6/http';
import { check, sleep } from 'k6';
import exec from 'k6/execution';

const base_url = __ENV.BASE_URL || 'http://10.43.100.141';
const modo = __ENV.MODO || 'consulta';
const vus = parseInt(__ENV.VUS || '300', 10);
const rps = parseFloat(__ENV.RPS || '50');
const rampa = __ENV.RAMPA || '60s';
const duracion = __ENV.DURACION || '5m';
const salida = __ENV.SALIDA || '.';
const tokens = JSON.parse(open(__ENV.ARCHIVO_TOKENS));
const solicitud = __ENV.SOLICITUD;
const periodo_s = vus / rps;
const rampa_ms = parseInt(rampa, 10) * (rampa.endsWith('m') ? 60000 : 1000);
const duracion_s = parseInt(duracion, 10) * (duracion.endsWith('m') ? 60 : 1);

const CONSULTA = { nombre: 'elegibles', ruta: `/api/v1/dispatch/requests/${solicitud}/eligible-allies?pageSize=20`, rol: 'cliente' };
const RUTAS = modo === 'consulta' ? [CONSULTA] : [
  CONSULTA,
  { nombre: 'perfil', ruta: '/api/v1/core/profiles/me', rol: 'cliente' },
  { nombre: 'sitios', ruta: '/api/v1/core/solicitudes/sitios', rol: 'cliente' },
  { nombre: 'tarifa', ruta: `/api/v1/core/solicitudes/${solicitud}/tarifa-referencia`, rol: 'cliente' },
  { nombre: 'ofertas', ruta: '/api/v1/dispatch/offers/me', rol: 'aliado' },
];

const umbrales = { 'http_reqs{fase:sostenida}': ['count>=0'], 'http_req_failed{fase:sostenida}': ['rate>=0'] };
for (const r of RUTAS) {
  umbrales[`http_req_duration{fase:sostenida,nombre:${r.nombre}}`] = ['p(95)<=500'];
  umbrales[`http_reqs{fase:sostenida,nombre:${r.nombre}}`] = ['count>=0'];
  umbrales[`estado_5xx{nombre:${r.nombre}}`] = ['rate>=0'];
}

import { Rate } from 'k6/metrics';
const estado_5xx = new Rate('estado_5xx');
const estado_5xx_total = new Rate('estado_5xx_total');
umbrales.estado_5xx_total = ['rate>=0'];

export const options = {
  scenarios: {
    carga: { executor: 'ramping-vus', startVUs: 0, stages: [{ duration: rampa, target: vus }, { duration: duracion, target: vus }], gracefulRampDown: '0s', gracefulStop: '10s' },
  },
  thresholds: umbrales,
  summaryTrendStats: ['avg', 'med', 'p(90)', 'p(95)', 'p(99)', 'max', 'count'],
  discardResponseBodies: true,
};

export default function () {
  if (exec.vu.iterationInScenario === 0) sleep(Math.random() * periodo_s);
  const r = RUTAS[exec.vu.iterationInScenario % RUTAS.length];
  const fase = Date.now() - exec.scenario.startTime < rampa_ms ? 'rampa' : 'sostenida';
  const inicio = Date.now();
  const res = http.get(base_url + r.ruta, {
    headers: { Authorization: `Bearer ${tokens[r.rol]}`, 'X-Correlation-ID': `qas-18-${exec.vu.idInTest}-${exec.vu.iterationInScenario}` },
    tags: { fase, nombre: r.nombre },
    timeout: '30s',
  });
  check(res, { 'status 200': (x) => x.status === 200 }, { fase, nombre: r.nombre });
  if (fase === 'sostenida') {
    estado_5xx.add(res.status >= 500 || res.status === 0, { nombre: r.nombre });
    estado_5xx_total.add(res.status >= 500 || res.status === 0);
  }
  const espera = periodo_s - (Date.now() - inicio) / 1000;
  if (espera > 0) sleep(espera);
}

export function handleSummary(data) {
  const v = (m, c) => (data.metrics[m] && data.metrics[m].values ? data.metrics[m].values[c] : null);
  const por_ruta = {};
  for (const r of RUTAS) {
    por_ruta[r.nombre] = {
      ruta: r.ruta,
      p95_ms: v(`http_req_duration{fase:sostenida,nombre:${r.nombre}}`, 'p(95)'),
      p99_ms: v(`http_req_duration{fase:sostenida,nombre:${r.nombre}}`, 'p(99)'),
      max_ms: v(`http_req_duration{fase:sostenida,nombre:${r.nombre}}`, 'max'),
      peticiones: v(`http_reqs{fase:sostenida,nombre:${r.nombre}}`, 'count'),
      tasa_5xx: v(`estado_5xx{nombre:${r.nombre}}`, 'rate'),
    };
  }
  const n = v('http_reqs{fase:sostenida}', 'count');
  const resumen = {
    modo, fecha_utc: new Date().toISOString(), base_url,
    carga: { vus, rps, rampa, duracion },
    tasa_sostenida_rps: n === null ? null : n / duracion_s,
    peticiones_sostenidas: n,
    tasa_fallo_http: v('http_req_failed{fase:sostenida}', 'rate'),
    tasa_5xx: v('estado_5xx_total', 'rate'),
    por_ruta,
  };
  const texto = JSON.stringify(resumen, null, 1);
  return { stdout: texto + '\n', [`${salida}/k6_${modo}_${duracion}.json`]: texto };
}

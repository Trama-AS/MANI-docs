// QAS-05. Carga constante y solo lecturas contra un servicio mientras se escala. Se detiene con SIGINT al terminar los pasos.
// Variables: ARCHIVO_TOKENS, SOLICITUD, BASE_URL, SERVICIO (core|rules|dispatch), RPS, DURACION, SALIDA.
import http from 'k6/http';
import exec from 'k6/execution';
import { Counter } from 'k6/metrics';

const base_url = __ENV.BASE_URL;
const servicio = __ENV.SERVICIO;
const rps = parseInt(__ENV.RPS || '10', 10);
const tokens = JSON.parse(open(__ENV.ARCHIVO_TOKENS));
const solicitud = __ENV.SOLICITUD;
const RUTAS = {
  core: [['perfil', '/api/v1/core/profiles/me', 'cliente'], ['sitios', '/api/v1/core/solicitudes/sitios', 'cliente'], ['tarifa', `/api/v1/core/solicitudes/${solicitud}/tarifa-referencia`, 'cliente']],
  rules: [['salud_rules', '/api/v1/rules/health', null]],
  dispatch: [['ofertas', '/api/v1/dispatch/offers/me', 'aliado'], ['ofertas', '/api/v1/dispatch/offers/me', 'aliado'], ['elegibles', `/api/v1/dispatch/requests/${solicitud}/eligible-allies?pageSize=20`, 'cliente']],
}[servicio];
const fallas = new Counter('fallas');
const fallas_5xx = new Counter('fallas_5xx');

export const options = {
  scenarios: { carga: { executor: 'constant-arrival-rate', rate: rps, timeUnit: '1s', duration: __ENV.DURACION || '30m', preAllocatedVUs: 30, maxVUs: 80, gracefulStop: '15s' } },
  thresholds: Object.fromEntries([['fallas', ['count>=0']], ['fallas_5xx', ['count>=0']], ...RUTAS.map((r) => [`http_req_duration{nombre:${r[0]}}`, ['p(95)>=0']])]),
  summaryTrendStats: ['med', 'p(95)', 'max', 'count'],
  discardResponseBodies: true,
};

export default function () {
  const i = exec.scenario.iterationInTest;
  const [nombre, ruta, rol] = RUTAS[i % RUTAS.length];
  const headers = { 'X-Correlation-ID': `qas-05-${servicio}-${i}` };
  if (rol) headers.Authorization = `Bearer ${tokens[rol]}`;
  const res = http.get(base_url + ruta, { headers, tags: { nombre, name: nombre }, timeout: '30s' });
  if (res.status !== 200) {
    fallas.add(1);
    if (res.status >= 500 || res.status === 0) fallas_5xx.add(1);
    console.log(`FALLA ${new Date().toISOString()} ${nombre} estado=${res.status} codigo=${res.error_code || 0} id=qas-05-${servicio}-${i}`);
  }
}

export function handleSummary(data) {
  const v = (m, c) => (data.metrics[m] && data.metrics[m].values[c] !== undefined ? data.metrics[m].values[c] : 0);
  const por_ruta = {};
  for (const r of RUTAS) por_ruta[r[0]] = { med_ms: v(`http_req_duration{nombre:${r[0]}}`, 'med'), p95_ms: v(`http_req_duration{nombre:${r[0]}}`, 'p(95)'), max_ms: v(`http_req_duration{nombre:${r[0]}}`, 'max'), peticiones: v(`http_req_duration{nombre:${r[0]}}`, 'count') };
  const resumen = { servicio, rps, peticiones: v('http_reqs', 'count'), no_200: v('fallas', 'count'), fallas_5xx: v('fallas_5xx', 'count'), descartadas: v('dropped_iterations', 'count'), por_ruta };
  return { stdout: JSON.stringify(resumen, null, 1) + '\n', [`${__ENV.SALIDA}/k6_${__ENV.ETIQUETA || servicio}.json`]: JSON.stringify(resumen) };
}

// =====================================================================
// MANI - QAS-03 (SDD seccion 8): p95 de la consulta bajo carga nominal
// =====================================================================
// Ticket: SCRUM-1275 (QA-MON-02), tarea SCRUM-1266.
//
// UMBRAL (SDD seccion 8, QAS-03; no se modifica en este script)
//   p95 <= 500 ms para la consulta bajo carga nominal: 300 sesiones
//   concurrentes y 50 req/s sostenidos (SDD seccion 7.4).
//
// QUE MIDE
//   La ruta indicada en RUTA a traves del API Gateway, con un JWT en
//   Authorization. El p95 se calcula solo con las peticiones de la fase
//   sostenida; la rampa de subida queda fuera. Cada peticion lleva un
//   X-Correlation-ID propio (qa1266-qas03-<vu>-<iteracion>) para cruzarla
//   con el log JSON del Gateway (request_time).
//
//   La ruta del SDD es la consulta de aliados por categoria y zona. Al
//   19 oct 2026 en QA solo existe el stub de Dispatch (POST
//   /api/v1/dispatch/match, sin persistencia): la medicion sobre esa ruta
//   es linea base del perimetro (Gateway + validacion JWT en Core +
//   servicio sin base de datos) y no acredita QAS-03.
//
// MODELO DE CARGA
//   VUS sesiones concurrentes. Cada sesion envia una peticion cada
//   VUS/RPS segundos (300/50 = 6 s), descontando el tiempo de respuesta,
//   de modo que la tasa agregada se mantiene en RPS mientras la latencia
//   sea menor que el periodo.
//
// VARIABLES (todas con -e VAR=valor)
//   BASE_URL       Gateway (por defecto http://10.43.100.141)
//   RUTA           ruta medida (por defecto /api/v1/dispatch/match)
//   METODO         GET o POST (por defecto POST)
//   CUERPO         cuerpo JSON para POST
//   ARCHIVO_TOKEN  archivo con el JWT (lo genera obtener_token.sh);
//                  junto a el, <ARCHIVO_TOKEN>.fuente indica la fuente
//   VUS            sesiones concurrentes (por defecto 300)
//   RPS            tasa objetivo (por defecto 50)
//   RAMPA          subida hasta VUS (por defecto 60s)
//   DURACION       fase sostenida (por defecto 5m)
//   AMBIENTE       etiqueta del ambiente (por defecto qa)
//   SALIDA         carpeta del resumen JSON (por defecto evidencia)
//
// USO
//   k6 run -e ARCHIVO_TOKEN=$HOME/.mani_qa/token.txt k6/qas03_latencia.js
//   Humo: k6 run -e VUS=10 -e RPS=2 -e RAMPA=5s -e DURACION=30s ...
// =====================================================================

import http from 'k6/http';
import { check, sleep } from 'k6';
import exec from 'k6/execution';

const UMBRAL_P95_MS = 500; // SDD seccion 8, QAS-03

const base_url = __ENV.BASE_URL || 'http://10.43.100.141';
const ruta = __ENV.RUTA || '/api/v1/dispatch/match';
const metodo = (__ENV.METODO || 'POST').toUpperCase();
const cuerpo = __ENV.CUERPO || '{"location":"Bogota, Chapinero","category":"Manicura Tradicional"}';
const vus = parseInt(__ENV.VUS || '300', 10);
const rps = parseFloat(__ENV.RPS || '50');
const rampa = __ENV.RAMPA || '60s';
const duracion = __ENV.DURACION || '5m';
const ambiente = __ENV.AMBIENTE || 'qa';
const salida = __ENV.SALIDA || 'evidencia';

if (!__ENV.ARCHIVO_TOKEN) {
  throw new Error('Falta ARCHIVO_TOKEN (ver obtener_token.sh)');
}
const token = open(__ENV.ARCHIVO_TOKEN).trim();
let fuente_token = 'desconocida';
try {
  fuente_token = open(`${__ENV.ARCHIVO_TOKEN}.fuente`).trim();
} catch (e) {
  fuente_token = 'desconocida';
}

const periodo_s = vus / rps;

function a_milisegundos(texto) {
  const m = /^(\d+(?:\.\d+)?)(ms|s|m|h)$/.exec(texto);
  if (!m) throw new Error(`Duracion no valida: ${texto}`);
  const factor = { ms: 1, s: 1000, m: 60000, h: 3600000 }[m[2]];
  return parseFloat(m[1]) * factor;
}
const rampa_ms = a_milisegundos(rampa);

export const options = {
  scenarios: {
    qas03: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: rampa, target: vus },
        { duration: duracion, target: vus },
      ],
      gracefulRampDown: '0s',
      gracefulStop: '10s',
    },
  },
  thresholds: {
    'http_req_duration{fase:sostenida}': [`p(95)<=${UMBRAL_P95_MS}`],
    // Sin umbral: se registran para juzgar la validez de la corrida.
    'http_req_failed{fase:sostenida}': ['rate>=0'],
    'http_reqs{fase:sostenida}': ['count>=0'],
    'checks{fase:sostenida}': ['rate>=0'],
  },
  summaryTrendStats: ['avg', 'min', 'med', 'max', 'p(90)', 'p(95)', 'p(99)', 'count'],
  discardResponseBodies: true,
};

export default function () {
  if (exec.vu.iterationInScenario === 0) {
    // Reparte las sesiones dentro del primer periodo.
    sleep(Math.random() * periodo_s);
  }

  const transcurrido = Date.now() - exec.scenario.startTime;
  const fase = transcurrido < rampa_ms ? 'rampa' : 'sostenida';
  const parametros = {
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      'X-Correlation-ID': `qa1266-qas03-${exec.vu.idInTest}-${exec.vu.iterationInScenario}`,
    },
    tags: { fase, ruta },
    timeout: '30s',
  };

  const inicio = Date.now();
  const respuesta = metodo === 'GET'
    ? http.get(`${base_url}${ruta}`, parametros)
    : http.request(metodo, `${base_url}${ruta}`, cuerpo, parametros);

  check(respuesta, { 'status 200': (r) => r.status === 200 }, { fase });

  const espera = periodo_s - (Date.now() - inicio) / 1000;
  if (espera > 0) sleep(espera);
}

function valor(data, metrica, campo) {
  const m = data.metrics[metrica];
  if (!m || !m.values || m.values[campo] === undefined) return null;
  return m.values[campo];
}

export function handleSummary(data) {
  const fecha = new Date().toISOString();
  const p95 = valor(data, 'http_req_duration{fase:sostenida}', 'p(95)');
  const peticiones = valor(data, 'http_reqs{fase:sostenida}', 'count');
  const segundos_sostenidos = a_milisegundos(duracion) / 1000;
  const tasa_sostenida = peticiones === null ? null : peticiones / segundos_sostenidos;
  const errores = valor(data, 'http_req_failed{fase:sostenida}', 'rate');
  const checks_ok = valor(data, 'checks{fase:sostenida}', 'rate');

  const resumen = {
    escenario: 'QAS-03',
    ticket: 'SCRUM-1275',
    fecha_utc: fecha,
    ambiente,
    base_url,
    ruta,
    metodo,
    fuente_token,
    carga: {
      vus,
      rps_objetivo: rps,
      periodo_por_sesion_s: periodo_s,
      rampa,
      duracion_sostenida: duracion,
    },
    umbral: { metrica: 'p95 http_req_duration, fase sostenida', limite_ms: UMBRAL_P95_MS, fuente: 'SDD seccion 8, QAS-03' },
    medido: {
      p95_ms: p95,
      p90_ms: valor(data, 'http_req_duration{fase:sostenida}', 'p(90)'),
      p99_ms: valor(data, 'http_req_duration{fase:sostenida}', 'p(99)'),
      promedio_ms: valor(data, 'http_req_duration{fase:sostenida}', 'avg'),
      max_ms: valor(data, 'http_req_duration{fase:sostenida}', 'max'),
      peticiones_sostenidas: peticiones,
      tasa_sostenida_rps: tasa_sostenida,
      tasa_error_http: errores,
      tasa_status_200: checks_ok,
      vus_max: valor(data, 'vus_max', 'max'),
    },
    resultado_umbral: p95 === null ? 'sin_datos' : (p95 <= UMBRAL_P95_MS ? 'dentro_del_umbral' : 'fuera_del_umbral'),
    nota: 'La validez exige tasa_status_200 = 1 y tasa_sostenida_rps cercana a rps_objetivo; si no, la corrida se reporta como invalida, no como cumplimiento.',
  };

  const marca = fecha.replace(/[:.]/g, '-');
  const texto = [
    `QAS-03 ${fecha} ambiente=${ambiente} fuente_token=${fuente_token}`,
    `ruta=${metodo} ${base_url}${ruta}`,
    `carga: vus=${vus} rps_objetivo=${rps} rampa=${rampa} sostenida=${duracion}`,
    `p95=${p95 === null ? 'n/a' : p95.toFixed(1)} ms (umbral <= ${UMBRAL_P95_MS} ms) -> ${resumen.resultado_umbral}`,
    `peticiones_sostenidas=${peticiones} tasa=${tasa_sostenida === null ? 'n/a' : tasa_sostenida.toFixed(2)} req/s`,
    `tasa_error_http=${errores} tasa_status_200=${checks_ok}`,
    '',
  ].join('\n');

  return {
    stdout: texto,
    [`${salida}/qas03_${marca}.json`]: JSON.stringify(resumen, null, 2),
  };
}

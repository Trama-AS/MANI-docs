// =====================================================================
// MANI - QAS-07 (SDD seccion 8): aceptacion concurrente sobre Dispatch
// =====================================================================
// Ticket: SCRUM-1275 (QA-MON-02), tarea SCRUM-1266.
//
// CRITERIO (SDD seccion 8, QAS-07, parte de asignacion y conflicto)
//   N aceptaciones simultaneas de una misma solicitud: una confirmada con
//   200, las demas con 409, 0 dobles asignaciones y reintento idempotente.
//
// ESTADO AL 19 OCT 2026
//   En QA corre el stub de Dispatch (release e40f84e): guarda la
//   asignacion en un ConcurrentDictionary en memoria y no toca la base.
//   Una corrida contra el stub solo valida el arnes; no es evidencia de
//   QAS-07. La evidencia exige la implementacion real (MANI-.NET #1,
//   SCRUM-1074) desplegada en QA, una solicitud PENDIENTE sembrada y la
//   lectura de la base con qas07_verificar_asignacion.sql.
//
// QUE HACE
//   N VUs, una iteracion cada uno, todos sobre SOLICITUD_ID. Cada VU
//   envia su propio allyId (stub) y, si ARCHIVO_TOKENS trae un arreglo
//   JSON de JWT de aliados distintos, su propio token (implementacion
//   real, donde el aliado sale del claim). Al final, el VU ganador
//   repite su aceptacion para comprobar la idempotencia.
//
// VARIABLES (con -e VAR=valor)
//   BASE_URL        Gateway (por defecto http://10.43.100.141)
//   SOLICITUD_ID    solicitud objetivo (por defecto una unica por corrida)
//   N               aceptaciones simultaneas (por defecto 50)
//   ARCHIVO_TOKEN   un solo JWT para todos (stub)
//   ARCHIVO_TOKENS  arreglo JSON de JWT, uno por aliado (implementacion real)
//   MODO            arnes (stub) o evidencia (implementacion real)
//   SALIDA          carpeta del resumen JSON (por defecto evidencia)
// =====================================================================

import http from 'k6/http';
import { check } from 'k6';
import exec from 'k6/execution';
import { Counter } from 'k6/metrics';

const base_url = __ENV.BASE_URL || 'http://10.43.100.141';
const n = parseInt(__ENV.N || '50', 10);
const modo = __ENV.MODO || 'arnes';
const salida = __ENV.SALIDA || 'evidencia';

let tokens = [];
if (__ENV.ARCHIVO_TOKENS) {
  tokens = JSON.parse(open(__ENV.ARCHIVO_TOKENS));
} else if (__ENV.ARCHIVO_TOKEN) {
  tokens = [open(__ENV.ARCHIVO_TOKEN).trim()];
} else {
  throw new Error('Falta ARCHIVO_TOKEN o ARCHIVO_TOKENS');
}
let fuente_token = 'desconocida';
try {
  fuente_token = open(`${__ENV.ARCHIVO_TOKEN || __ENV.ARCHIVO_TOKENS}.fuente`).trim();
} catch (e) {
  fuente_token = 'desconocida';
}

const exito_200 = new Counter('exito_200');
const conflicto_409 = new Counter('conflicto_409');
const otros = new Counter('otros_status');
const reintento_200 = new Counter('reintento_idempotente_200');

export const options = {
  scenarios: {
    qas07: { executor: 'per-vu-iterations', vus: n, iterations: 1, maxDuration: '60s' },
  },
  thresholds: {
    exito_200: [`count==1`],
    conflicto_409: [`count==${n - 1}`],
    otros_status: ['count==0'],
  },
};

// El id se fija una sola vez en setup(): el codigo de init corre en cada VU.
export function setup() {
  return { solicitud_id: __ENV.SOLICITUD_ID || `qa1266-${Date.now()}` };
}

function aceptar(solicitud_id, token, aliado, correlacion) {
  return http.post(
    `${base_url}/api/v1/dispatch/requests/${solicitud_id}/accept`,
    JSON.stringify({ allyId: aliado }),
    {
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
        'X-Correlation-ID': correlacion,
      },
      timeout: '30s',
    },
  );
}

export default function (datos) {
  const indice = exec.vu.idInTest - 1;
  const token = tokens[indice % tokens.length];
  const aliado = `qa1266-aliado-${exec.vu.idInTest}`;
  const r = aceptar(datos.solicitud_id, token, aliado, `qa1266-qas07-${exec.vu.idInTest}`);

  if (r.status === 200) {
    exito_200.add(1);
    console.log(`ganador vu=${exec.vu.idInTest} aliado=${aliado}`);
    const repetido = aceptar(datos.solicitud_id, token, aliado, `qa1266-qas07-${exec.vu.idInTest}-reintento`);
    if (repetido.status === 200) reintento_200.add(1);
  } else if (r.status === 409) {
    conflicto_409.add(1);
  } else {
    otros.add(1);
  }
  check(r, { 'status 200 o 409': (x) => x.status === 200 || x.status === 409 });
}

function contar(data, metrica) {
  const m = data.metrics[metrica];
  return m && m.values ? m.values.count : 0;
}

export function handleSummary(data) {
  const solicitud_id = (data.setup_data && data.setup_data.solicitud_id) || 'desconocida';
  const fecha = new Date().toISOString();
  const resumen = {
    escenario: 'QAS-07 (asignacion y conflicto)',
    ticket: 'SCRUM-1275',
    fecha_utc: fecha,
    modo,
    base_url,
    solicitud_id,
    fuente_token,
    tokens_distintos: tokens.length,
    carga: { aceptaciones_simultaneas: n },
    criterio: { exito_200: 1, conflicto_409: n - 1, fuente: 'SDD seccion 8, QAS-07' },
    medido: {
      exito_200: contar(data, 'exito_200'),
      conflicto_409: contar(data, 'conflicto_409'),
      otros_status: contar(data, 'otros_status'),
      reintento_idempotente_200: contar(data, 'reintento_idempotente_200'),
    },
    pendiente: 'Las dobles asignaciones se deciden con qas07_verificar_asignacion.sql sobre la base; si la base y k6 discrepan, manda la base.',
  };
  const marca = fecha.replace(/[:.]/g, '-');
  const texto = `QAS-07 modo=${modo} solicitud=${solicitud_id} n=${n} -> 200=${resumen.medido.exito_200} 409=${resumen.medido.conflicto_409} otros=${resumen.medido.otros_status} reintento_200=${resumen.medido.reintento_idempotente_200}\n`;
  return { stdout: texto, [`${salida}/qas07_${modo}_${marca}.json`]: JSON.stringify(resumen, null, 2) };
}

// Verificador ejecutable de contratos y versionado de eventos (ARQ-06 / SCRUM-1237)
// Ejecucion: node Entregas/PoC/PoC-ARQ06-esquema-versionado-eventos/validar_contratos_eventos.mjs

import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const schemasDir = path.join(__dirname, 'schemas');

const envelopeSchema = JSON.parse(
  fs.readFileSync(path.join(schemasDir, 'event-envelope.v1.schema.json'), 'utf8'),
);

const dataSchemas = {
  'SolicitudCreada:1': JSON.parse(
    fs.readFileSync(path.join(schemasDir, 'solicitud-creada.v1.schema.json'), 'utf8'),
  ),
  'AliadoAsignado:1': JSON.parse(
    fs.readFileSync(path.join(schemasDir, 'aliado-asignado.v1.schema.json'), 'utf8'),
  ),
  'CotizacionAceptada:1': JSON.parse(
    fs.readFileSync(path.join(schemasDir, 'cotizacion-aceptada.v1.schema.json'), 'utf8'),
  ),
  'ServicioFinalizado:1': JSON.parse(
    fs.readFileSync(path.join(schemasDir, 'servicio-finalizado.v1.schema.json'), 'utf8'),
  ),
};

const UUID_REGEX = /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-8][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$/;
const ISO_UTC_REGEX = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z$/;

const OUTBOX_ROUTING = {
  SolicitudCreada: { producer: 'Core Service', outbox: 'servicio.outbox', aggregateField: 'id_solicitud' },
  AliadoAsignado: { producer: 'Dispatch Service', outbox: 'despacho.outbox', aggregateField: 'id_asignacion' },
  CotizacionAceptada: { producer: 'Core Service', outbox: 'servicio.outbox', aggregateField: 'id_cotizacion' },
  ServicioFinalizado: { producer: 'Core Service', outbox: 'servicio.outbox', aggregateField: 'id_solicitud' },
};

function validateAgainstSchema(obj, schema, { strictAdditionalProps = true } = {}) {
  const errors = [];
  if (typeof obj !== 'object' || obj === null || Array.isArray(obj)) {
    return ['El valor raiz debe ser un objeto JSON'];
  }

  for (const reqField of schema.required || []) {
    if (!(reqField in obj)) {
      errors.push(`Falta campo obligatorio: ${reqField}`);
    }
  }

  if (strictAdditionalProps && schema.additionalProperties === false) {
    for (const key of Object.keys(obj)) {
      if (!(key in (schema.properties || {}))) {
        errors.push(`Propiedad no declarada en el contrato (Strict Producer): ${key}`);
      }
    }
  }

  for (const [key, propSchema] of Object.entries(schema.properties || {})) {
    if (!(key in obj)) continue;
    const val = obj[key];
    const allowedTypes = Array.isArray(propSchema.type) ? propSchema.type : [propSchema.type];

    if (val === null) {
      if (!allowedTypes.includes('null')) {
        errors.push(`Campo ${key} no admite null`);
      }
      continue;
    }

    const jsType = typeof val;
    const typeOk = allowedTypes.some((t) => {
      if (t === 'integer') return Number.isInteger(val);
      if (t === 'number') return typeof val === 'number' && !Number.isNaN(val);
      if (t === 'object') return typeof val === 'object' && !Array.isArray(val);
      return jsType === t;
    });

    if (!typeOk) {
      errors.push(`Tipo invalido en ${key}: esperado ${allowedTypes.join('|')}, recibido ${jsType}`);
      continue;
    }

    if (propSchema.enum && !propSchema.enum.includes(val)) {
      errors.push(`Valor fuera de dominio en ${key}: ${val}`);
    }
    if ('const' in propSchema && val !== propSchema.const) {
      errors.push(`Valor constante incumplido en ${key}: esperado ${propSchema.const}, recibido ${val}`);
    }
    if (typeof propSchema.minimum === 'number' && val < propSchema.minimum) {
      errors.push(`Valor menor al minimo (${propSchema.minimum}) en ${key}: ${val}`);
    }
    if (propSchema.format === 'uuid' && !UUID_REGEX.test(val)) {
      errors.push(`Formato UUID invalido en ${key}: ${val}`);
    }
    if (propSchema.format === 'date-time' && !ISO_UTC_REGEX.test(val)) {
      errors.push(`Formato ISO-8601 UTC invalido en ${key}: ${val}`);
    }
    if (propSchema.pattern && !new RegExp(propSchema.pattern).test(val)) {
      errors.push(`Patron incumplido en ${key}: ${val}`);
    }
  }

  return errors;
}

export function validateEvent(event, { mode = 'producer' } = {}) {
  const strictAdditionalProps = mode === 'producer';
  const envErrors = validateAgainstSchema(event, envelopeSchema, { strictAdditionalProps: true });
  if (envErrors.length > 0) {
    return { valid: false, action: 'REJECT_ENVELOPE', errors: envErrors };
  }

  const schemaKey = `${event.event_type}:${event.event_version}`;
  const dataSchema = dataSchemas[schemaKey];
  if (!dataSchema) {
    return {
      valid: false,
      action: 'ROUTE_TO_DLQ_UNSUPPORTED_VERSION',
      errors: [`Version de esquema no soportada para ${ schemaKey }`],
    };
  }

  const dataErrors = validateAgainstSchema(event.data, dataSchema, { strictAdditionalProps });
  if (dataErrors.length > 0) {
    return { valid: false, action: 'REJECT_PAYLOAD', errors: dataErrors };
  }

  // Invariantes transversales y de dominio (ARQ-06)
  if (event.partition_key !== event.data.id_solicitud) {
    return {
      valid: false,
      action: 'REJECT_PARTITION_KEY',
      errors: ['partition_key debe coincidir exactamente con data.id_solicitud'],
    };
  }

  if (event.event_type === 'CotizacionAceptada') {
    const esperado = Number((event.data.valor_mano_obra + event.data.valor_materiales).toFixed(2));
    const total = Number(event.data.valor_total.toFixed(2));
    if (esperado !== total) {
      return {
        valid: false,
        action: 'REJECT_INVARIANT',
        errors: [`ck_cotizacion_total violado: ${total} != ${esperado}`],
      };
    }
  }

  if (event.event_type === 'ServicioFinalizado') {
    if (event.data.valor_acordado !== null && event.data.moneda === null) {
      return {
        valid: false,
        action: 'REJECT_INVARIANT',
        errors: ['moneda es obligatoria cuando valor_acordado no es null'],
      };
    }
  }

  const routing = OUTBOX_ROUTING[event.event_type];
  return {
    valid: true,
    action: 'ACCEPT',
    producer: routing.producer,
    outbox: routing.outbox,
    id_agregado: event.data[routing.aggregateField],
    errors: [],
  };
}

// ============================================================================
// Casos de prueba ejecutables (C1 - C12)
// ============================================================================

const eventosCanonicos = [
  {
    event_id: 'a7f4c912-3d19-4e82-9a11-7e83d1b04c21',
    event_type: 'SolicitudCreada',
    event_version: 1,
    occurred_at: '2026-10-18T15:30:00.000Z',
    tenant_id: '11111111-1111-4111-8111-111111111111',
    correlation_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    partition_key: '9b2e4d10-81c4-4f22-b890-33e019c71a01',
    data: {
      id_solicitud: '9b2e4d10-81c4-4f22-b890-33e019c71a01',
      id_cliente: '22222222-2222-4222-8222-222222222222',
      id_sitio: '33333333-3333-4333-8333-333333333333',
      id_categoria: '44444444-4444-4444-8444-444444444444',
      id_zona: '55555555-5555-4555-8555-555555555555',
      flujo_operativo: 'COTIZACION_ABLE',
      requiere_cotizacion_previa: true,
      fecha_servicio: '2026-10-19T14:00:00.000Z',
      estado: 'CREADA',
      fecha_creacion: '2026-10-18T15:30:00.000Z',
    },
  },
  {
    event_id: 'b8e5d023-4e20-4f93-8b22-8f94e2c15d32',
    event_type: 'AliadoAsignado',
    event_version: 1,
    occurred_at: '2026-10-18T15:31:15.000Z',
    tenant_id: '11111111-1111-4111-8111-111111111111',
    correlation_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    partition_key: '9b2e4d10-81c4-4f22-b890-33e019c71a01',
    data: {
      id_asignacion: '66666666-6666-4666-8666-666666666666',
      id_solicitud: '9b2e4d10-81c4-4f22-b890-33e019c71a01',
      id_aliado: '77777777-7777-4777-8777-777777777777',
      id_categoria: '44444444-4444-4444-8444-444444444444',
      id_zona: '55555555-5555-4555-8555-555555555555',
      estado_asignacion: 'ACEPTADA',
      estado_solicitud: 'ASIGNADA',
      fecha_asignacion: '2026-10-18T15:30:05.000Z',
      fecha_respuesta: '2026-10-18T15:31:15.000Z',
      segundos_respuesta: 70,
    },
  },
  {
    event_id: 'c9f6e134-5f31-4a04-9c33-9a05f3d26e43',
    event_type: 'CotizacionAceptada',
    event_version: 1,
    occurred_at: '2026-10-18T15:45:00.000Z',
    tenant_id: '11111111-1111-4111-8111-111111111111',
    correlation_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    partition_key: '9b2e4d10-81c4-4f22-b890-33e019c71a01',
    data: {
      id_cotizacion: '88888888-8888-4888-8888-888888888888',
      id_solicitud: '9b2e4d10-81c4-4f22-b890-33e019c71a01',
      id_aliado: '77777777-7777-4777-8777-777777777777',
      id_categoria: '44444444-4444-4444-8444-444444444444',
      id_tarifa: '99999999-9999-4999-8999-999999999999',
      valor_mano_obra: 85000.0,
      valor_materiales: 35000.0,
      valor_total: 120000.0,
      moneda: 'COP',
      fuera_de_rango: false,
      estado: 'ACEPTADA',
      fecha_aceptacion: '2026-10-18T15:45:00.000Z',
    },
  },
  {
    event_id: 'd0a7f245-6a42-4b15-8d44-0b16a4e37f54',
    event_type: 'ServicioFinalizado',
    event_version: 1,
    occurred_at: '2026-10-18T17:10:00.000Z',
    tenant_id: '11111111-1111-4111-8111-111111111111',
    correlation_id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
    partition_key: '9b2e4d10-81c4-4f22-b890-33e019c71a01',
    data: {
      id_solicitud: '9b2e4d10-81c4-4f22-b890-33e019c71a01',
      id_cliente: '22222222-2222-4222-8222-222222222222',
      id_aliado: '77777777-7777-4777-8777-777777777777',
      id_categoria: '44444444-4444-4444-8444-444444444444',
      id_zona: '55555555-5555-4555-8555-555555555555',
      id_cotizacion: '88888888-8888-4888-8888-888888888888',
      valor_acordado: 120000.0,
      moneda: 'COP',
      estado_anterior: 'EN_EJECUCION',
      estado_nuevo: 'FINALIZADA',
      habilita_calificacion: true,
      fecha_finalizacion: '2026-10-18T17:10:00.000Z',
    },
  },
];

let checks = 0;

// C1-C4: Validacion positiva de los 4 eventos canonicos
for (const ev of eventosCanonicos) {
  const res = validateEvent(ev, { mode: 'producer' });
  assert.equal(res.valid, true, `Evento canonico ${ev.event_type} fallo: ${res.errors.join(', ')}`);
  checks++;
  console.log(`[PASS] C${checks}: ${ev.event_type} v${ev.event_version} valido -> ${res.outbox} (${res.producer})`);
}

// C5: Aislamiento multi-tenant (RNF-01) — rechazo sin tenant_id
{
  const sinTenant = structuredClone(eventosCanonicos[0]);
  delete sinTenant.tenant_id;
  const res = validateEvent(sinTenant);
  assert.equal(res.valid, false);
  assert.equal(res.action, 'REJECT_ENVELOPE');
  checks++;
  console.log(`[PASS] C${checks}: Rechaza evento sin tenant_id (RNF-01)`);
}

// C6: Trazabilidad (RNF-07) — rechazo sin correlation_id
{
  const sinCorrelation = structuredClone(eventosCanonicos[1]);
  delete sinCorrelation.correlation_id;
  const res = validateEvent(sinCorrelation);
  assert.equal(res.valid, false);
  assert.equal(res.action, 'REJECT_ENVELOPE');
  checks++;
  console.log(`[PASS] C${checks}: Rechaza evento sin correlation_id (RNF-07)`);
}

// C7: Orden causal por solicitud — rechazo si partition_key != data.id_solicitud
{
  const malaParticion = structuredClone(eventosCanonicos[1]);
  malaParticion.partition_key = '66666666-6666-4666-8666-666666666666'; // uso id_asignacion en vez de id_solicitud
  const res = validateEvent(malaParticion);
  assert.equal(res.valid, false);
  assert.equal(res.action, 'REJECT_PARTITION_KEY');
  checks++;
  console.log(`[PASS] C${checks}: Rechaza partition_key distinta de data.id_solicitud`);
}

// C8: Invariante ck_cotizacion_total en CotizacionAceptada
{
  const sumaInvalida = structuredClone(eventosCanonicos[2]);
  sumaInvalida.data.valor_total = 999999.0;
  const res = validateEvent(sumaInvalida);
  assert.equal(res.valid, false);
  assert.equal(res.action, 'REJECT_INVARIANT');
  checks++;
  console.log(`[PASS] C${checks}: Rechaza CotizacionAceptada cuando valor_total != mano_obra + materiales`);
}

// C9: Prohibicion de PII / propiedades no declaradas en productor (Strict Producer)
{
  const conPii = structuredClone(eventosCanonicos[0]);
  conPii.data.direccion = 'Calle 100 #15-20';
  const res = validateEvent(conPii, { mode: 'producer' });
  assert.equal(res.valid, false);
  assert.equal(res.action, 'REJECT_PAYLOAD');
  checks++;
  console.log(`[PASS] C${checks}: Strict Producer rechaza filtracion de PII o campos no declarados en data`);
}

// C10: Regla Tolerant Reader (cambio compatible sin incrementar event_version)
{
  const evolucionCompatible = structuredClone(eventosCanonicos[3]);
  evolucionCompatible.data.canal_cierre = 'APP_MOVIL'; // campo opcional futuro en v1
  const resConsumer = validateEvent(evolucionCompatible, { mode: 'consumer' });
  assert.equal(resConsumer.valid, true);
  checks++;
  console.log(`[PASS] C${checks}: Tolerant Reader acepta campo opcional nuevo sin subir event_version`);
}

// C11: Cambio incompatible sin subir version (eliminacion o cambio de tipo) es rechazado
{
  const breakingChange = structuredClone(eventosCanonicos[1]);
  breakingChange.data.segundos_respuesta = '70s'; // cambio incompatible de integer a string
  const res = validateEvent(breakingChange, { mode: 'consumer' });
  assert.equal(res.valid, false);
  assert.equal(res.action, 'REJECT_PAYLOAD');
  checks++;
  console.log(`[PASS] C${checks}: Detecta y rechaza cambio incompatible de tipo en v1`);
}

// C12: Version mayor desconocida (v2 no registrada) se encamina a DLQ sin bloquear particion
{
  const versionFutura = structuredClone(eventosCanonicos[0]);
  versionFutura.event_version = 2;
  const res = validateEvent(versionFutura, { mode: 'consumer' });
  assert.equal(res.valid, false);
  assert.equal(res.action, 'ROUTE_TO_DLQ_UNSUPPORTED_VERSION');
  checks++;
  console.log(`[PASS] C${checks}: Encamina a DLQ cuando recibe event_version mayor no soportada`);
}

console.log(`\nOK ARQ-06: ${checks}/${checks} verificaciones de esquema y versionado superadas.`);

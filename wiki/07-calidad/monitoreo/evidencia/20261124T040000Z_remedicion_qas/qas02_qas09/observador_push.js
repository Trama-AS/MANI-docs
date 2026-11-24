// QAS-02: arranca el Core de la copia y observa cada intento del proveedor push desplegado (no cambia su resultado).
// Con QAS02_CUELGA=1 el proveedor no responde nunca: es el adaptador de prueba del caso de timeout.
const raiz = process.env.QAS02_RAIZ || '/app';
const proveedor = require(`${raiz}/src/container`).pushProvider;
const original = proveedor.send.bind(proveedor);
const intentos = {};
proveedor.send = async (m) => {
  const clave = m.idempotencyKey;
  intentos[clave] = (intentos[clave] || 0) + 1;
  const di = (r) => console.log(JSON.stringify({ qas02: 1, proveedor: proveedor.name, tipo: m.tipo, intento: intentos[clave], clave, cid: m.correlationId, r }));
  if (process.env.QAS02_CUELGA === '1') { di('sin_respuesta'); return new Promise(() => {}); }
  try { const r = await original(m); di('entregado'); return r; } catch (e) { di(`falla_${e.code || e.reason || e.name}`); throw e; }
};
require(`${raiz}/src/server.js`);

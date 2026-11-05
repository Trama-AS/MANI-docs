// =====================================================================
// MANI - Redacta tokens en la evidencia antes de guardarla o versionarla
// =====================================================================
// Los reportes JSON de Newman guardan cabeceras y cuerpos completos, y con
// ellos los JWT. El cuerpo de cada respuesta va como Buffer serializado
// ({"type":"Buffer","data":[...bytes]}), donde un JWT no aparece como
// texto. Este script:
//   - en archivos JSON, recorre el objeto, decodifica cada Buffer, redacta
//     su texto y lo vuelve a codificar; redacta tambien cada cadena;
//   - en cualquier otro archivo, redacta el texto completo.
// Reemplaza cualquier JWT y cualquier valor de "Bearer <...>" o
// "Token <...>" por <REDACTADO>, en sitio.
//
// Uso: node redactar_evidencia.mjs <archivo> [<archivo> ...]
// =====================================================================

import { readFileSync, writeFileSync } from 'node:fs';

const patron_jwt = /eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]+/g;
const patron_esquema = /(Bearer|Token)\s+(?!<REDACTADO>)[A-Za-z0-9._~+\/=-]{8,}/g;

let cambios = 0;

function redactar_texto(texto) {
  return texto
    .replace(patron_jwt, () => { cambios += 1; return '<REDACTADO>'; })
    .replace(patron_esquema, (_, esquema) => { cambios += 1; return `${esquema} <REDACTADO>`; });
}

function es_buffer(valor) {
  return valor && typeof valor === 'object' && valor.type === 'Buffer' && Array.isArray(valor.data);
}

function recorrer(valor) {
  if (typeof valor === 'string') return redactar_texto(valor);
  if (es_buffer(valor)) {
    const original = Buffer.from(valor.data).toString('utf8');
    const redactado = redactar_texto(original);
    return redactado === original ? valor : { type: 'Buffer', data: [...Buffer.from(redactado, 'utf8')] };
  }
  if (Array.isArray(valor)) return valor.map(recorrer);
  if (valor && typeof valor === 'object') {
    const salida = {};
    for (const [clave, interno] of Object.entries(valor)) salida[clave] = recorrer(interno);
    return salida;
  }
  return valor;
}

let total = 0;
for (const archivo of process.argv.slice(2)) {
  cambios = 0;
  const texto = readFileSync(archivo, 'utf8');
  let resultado;
  try {
    resultado = JSON.stringify(recorrer(JSON.parse(texto)), null, 2);
  } catch (e) {
    resultado = redactar_texto(texto);
  }
  writeFileSync(archivo, resultado);
  total += cambios;
  console.log(`${archivo}: ${cambios} reemplazos`);
}
console.log(`total_reemplazos=${total}`);

// =====================================================================
// MANI - Redacta tokens en la evidencia antes de guardarla o versionarla
// =====================================================================
// Los reportes JSON de Newman guardan cabeceras y cuerpos completos, y con
// ellos los JWT. Este script reemplaza en sitio cualquier JWT y cualquier
// valor de "Bearer <...>" por <REDACTADO>. Sirve para cualquier archivo
// de texto de la carpeta de evidencia.
//
// Uso: node redactar_evidencia.mjs <archivo> [<archivo> ...]
// =====================================================================

import { readFileSync, writeFileSync } from 'node:fs';

const patrones = [
  /eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]+/g,
  /(Bearer|Token)\s+[A-Za-z0-9._~+\/=-]{8,}/g,
];

let total = 0;
for (const archivo of process.argv.slice(2)) {
  let texto = readFileSync(archivo, 'utf8');
  let cambios = 0;
  for (const patron of patrones) {
    texto = texto.replace(patron, (coincidencia, prefijo) => {
      cambios += 1;
      return typeof prefijo === 'string' && /^(Bearer|Token)$/.test(prefijo)
        ? `${prefijo} <REDACTADO>`
        : '<REDACTADO>';
    });
  }
  writeFileSync(archivo, texto);
  total += cambios;
  console.log(`${archivo}: ${cambios} reemplazos`);
}
console.log(`total_reemplazos=${total}`);

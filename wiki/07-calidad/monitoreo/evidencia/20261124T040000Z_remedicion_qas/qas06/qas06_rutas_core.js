// QAS-06: rutas que Express registra de verdad en el Core desplegado, con archivo:línea. No abre puerto ni toca red.
const path = require('node:path');
const raiz = process.cwd();
const express = require(path.join(raiz, 'node_modules/express'));
const METODOS = ['get', 'post', 'put', 'patch', 'delete', 'all'];
const origen = new WeakMap();
for (const m of METODOS) {
  const original = express.Router[m];
  express.Router[m] = function (ruta, ...fns) {
    const linea = new Error().stack.split('\n').slice(2).find((l) => l.includes('/src/'));
    const antes = this.stack.length;
    const salida = original.call(this, ruta, ...fns);
    for (const capa of this.stack.slice(antes)) origen.set(capa, linea ? linea.match(/\/(src\/[^:]+:\d+)/)[1] : '?');
    return salida;
  };
}
const rutas = require(path.join(raiz, 'src/routes'));
const filas = [];
function prefijo(capa) {
  if (capa.regexp.fast_slash) return '';
  return capa.regexp.source.replace('^', '').replace('\\/?(?=\\/|$)', '').replaceAll('\\/', '/').replace(/\/$/, '');
}
(function recorrer(stack, base) {
  for (const capa of stack) {
    if (capa.route) {
      const lista = Array.isArray(capa.route.path) ? capa.route.path : [capa.route.path];
      for (const p of lista) for (const m of Object.keys(capa.route.methods))
        filas.push({ metodo: m.toUpperCase(), ruta: (base + p).replace(/\/$/, '') || '/', origen: origen.get(capa) });
    } else if (capa.handle && capa.handle.stack) recorrer(capa.handle.stack, base + prefijo(capa));
  }
})(rutas.stack, '');
console.log(JSON.stringify(filas));
process.exit(0);

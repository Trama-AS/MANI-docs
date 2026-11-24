// Proxy de inyeccion de fallas para QAS-40. Corre con la imagen de Core (node), sin dependencias.
// Puertos: 9000 control (GET /modo/<destino>/<modo>, GET /conteo/<destino>), 9001 rules, 9002 core, 9003 dispatch.
const http = require('http');
const destinos = {
  rules: { puerto: 9001, host: 'rules-service', hp: 8080 },
  core: { puerto: 9002, host: 'core-service', hp: 3000 },
  dispatch: { puerto: 9003, host: 'dispatch-service', hp: 5000 },
};
for (const d of Object.values(destinos)) { d.modo = 'pasa'; d.n = 0; }
const json = { 'Content-Type': 'application/json', Connection: 'close' };
function atender(d, req, res) {
  d.n += 1;
  const trozos = [];
  req.on('error', () => {});
  res.on('error', () => {});
  req.on('data', (t) => trozos.push(t));
  req.on('end', () => {
    if (d.modo === 'cuelga') return; // acepta y no responde
    if (d.modo === 'caido') return req.socket.destroy(); // corta la conexion
    if (d.modo === 'e503') { res.writeHead(503, json); return res.end('{"error":"caida inyectada"}'); }
    if (d.modo === 'html') { res.writeHead(200, { 'Content-Type': 'text/html', Connection: 'close' }); return res.end('<html>no es json</html>'); }
    if (d.modo === 'roto') { res.writeHead(200, json); return res.end('{"aliados": [{"id": '); }
    if (d.modo === 'vacio') { res.writeHead(200, json); return res.end('{}'); }
    if (d.modo === 'valido') { res.writeHead(200, json); return res.end('{"valid": true}'); }
    const cab = { ...req.headers, host: `${d.host}:${d.hp}`, connection: 'close' };
    const sal = http.request({ host: d.host, port: d.hp, path: req.url, method: req.method, headers: cab }, (r) => {
      res.writeHead(r.statusCode, { ...r.headers, connection: 'close' });
      r.pipe(res);
    });
    sal.on('error', () => { if (!res.headersSent) res.writeHead(502, json); res.end(); });
    sal.end(Buffer.concat(trozos));
  });
}
for (const d of Object.values(destinos)) http.createServer((q, s) => atender(d, q, s)).listen(d.puerto, '0.0.0.0');
http.createServer((q, s) => {
  const [, op, nombre, modo] = q.url.split('/');
  const d = destinos[nombre];
  if (q.url === '/salud') return s.end('ok');
  if (!d) { s.writeHead(404); return s.end(); }
  if (op === 'modo') { d.modo = modo; d.n = 0; }
  return s.end(JSON.stringify({ modo: d.modo, n: d.n }));
}).listen(9000, '0.0.0.0');

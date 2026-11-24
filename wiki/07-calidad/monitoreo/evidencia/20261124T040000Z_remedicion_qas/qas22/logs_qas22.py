# QAS-22 (SCRUM-1658), 24 nov. Correr despues de correr_qas20.sh, que deja peticiones entre servicios. Corre en la VM de QA. Solo lectura de logs y peticiones GET sin sesion.
# No imprime tokens, correos ni URLs de conexion.
import json, re, subprocess, time, urllib.request, urllib.error, uuid
SERV = {'gateway': 'mani-api-gateway', 'core': 'mani-core-service', 'dispatch': 'mani-dispatch-service', 'rules': 'mani-rules-service'}
def oculta(t):
    t = re.sub(r'eyJ[\w-]+\.[\w-]+\.[\w-]+', '<token>', t)
    t = re.sub(r'postgres(ql)?://\S+', '<url>', t)
    return re.sub(r'[\w.+-]+@[\w.-]+', '<correo>', t)
def pedir(ruta, cid=None):
    r = urllib.request.Request('http://localhost' + ruta, headers={'X-Correlation-ID': cid} if cid else {})
    try:
        with urllib.request.urlopen(r, timeout=15) as x: return x.status, x.headers.get_all('X-Correlation-ID')
    except urllib.error.HTTPError as e: return e.code, e.headers.get_all('X-Correlation-ID')
print('== QAS-22 en MANI-QA', time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()))
print('== Cabecera de respuesta (una sola, mismo ID; generada si falta)')
propios = {}
for ruta in ('/api/v1/core/catalog', '/api/v1/dispatch/offers/me', '/api/v1/rules/health', '/api/v1/dispatch/health', '/api/v1/core/health'):
    cid = 'qas22-' + uuid.uuid4().hex[:10]
    c, h = pedir(ruta, cid)
    c2, h2 = pedir(ruta)
    propios[cid] = ruta
    print(f"  {ruta} | con ID {c} {'PASA' if h == [cid] else 'FALLA'} {len(h or [])} cabecera | sin ID {c2} {'PASA' if h2 and len(h2) == 1 and h2[0] else 'FALLA'} generado={(h2 or ['-'])[0][:40]}")
time.sleep(3)
todo = {}
print('== Logs desde el arranque de cada contenedor (release del 24 nov): lineas que se leen como JSON')
for n, c in SERV.items():
    ini = subprocess.run(['docker', 'inspect', '-f', '{{.State.StartedAt}} {{index .Config.Labels "org.opencontainers.image.revision"}}', c], capture_output=True, text=True).stdout.split()
    print(f'  {n}: rev {ini[1][:7] if len(ini) > 1 else "?"}, arranque {ini[0][:19]}Z')
    p = subprocess.run(['docker', 'logs', '--since', ini[0], c], capture_output=True, text=True, errors='replace')
    ls = [l for l in (p.stdout + '\n' + p.stderr).splitlines() if l.strip()]
    ok, mal = [], []
    for l in ls:
        try:
            ok.append(l) if isinstance(json.loads(l), dict) else mal.append(l)
        except ValueError: mal.append(l)
    todo[n] = ls
    print(f"  {n}: {len(ok)} de {len(ls)} JSON ({100 * len(ok) / len(ls) if ls else 0:.1f} %)")
    # Agrupa lo que no es JSON: arranque (sin fecha de nginx o antes de 1 min) y lineas en marcha, por tipo
    tipos = {}
    for l in mal:
        m = re.match(r'^(\d{4}/\d\d/\d\d \d\d:\d\d):\d\d \[(\w+)\] [^:]*: (?:\*\d+ )?(.*)', l)
        msj = re.split(r', client|, server|, request|: |"', m.group(3))[0][:70] if m else ''
        k = f'nginx [{m.group(2)}] {msj}' if m else 'sin formato de log'
        g = tipos.setdefault(k, [0, '', '', l]); g[0] += 1
        h = m.group(1)[11:] if m else ''
        g[1] = g[1] or h; g[2] = h or g[2]
    for k, (c2, h1, h2, ej) in sorted(tipos.items(), key=lambda x: -x[1][0])[:12]: print(f'     no JSON x{c2} {h1}-{h2} | {k} | ej: {oculta(ej)[:170]}')
    for l in ok[-2:]: print('     JSON:', oculta(l)[:260])
print('== IDs de la corrida T-41, de QAS-40 (qas40-: solo lo que paso al servicio real) y de esta prueba, por servicio')
ids = {}
for n, ls in todo.items():
    for l in ls:
        for m in re.findall(r'\b(?:t41|qas22|qas40)-[0-9a-f]{10}\b', l): ids.setdefault(m, set()).add(n)
from collections import Counter
for k, v in Counter(' + '.join(sorted(s)) for s in ids.values()).most_common(): print(f'  {v} IDs en: {k}')
print('  IDs en 3 o mas servicios:', sum(len(s) >= 3 for s in ids.values()))
print('  IDs en core+dispatch:', sum({'core', 'dispatch'} <= s for s in ids.values()))
for cid, ruta in propios.items(): print('  ', cid, ruta, sorted(ids.get(cid, [])))
print('== Fin')

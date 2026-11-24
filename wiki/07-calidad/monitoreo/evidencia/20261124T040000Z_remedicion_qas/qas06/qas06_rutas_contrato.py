"""QAS-06: cruza las rutas desplegadas con docs/openapi. Solo lee archivos locales."""
import json, re, subprocess, sys, os
BASE, S = sys.argv[1], sys.argv[2]
SAL = f'{BASE}/qa_qas_24nov/evidencia/qas06'
def norm(p):
    p = re.sub(r':(\w+)(\([^)]*\))?\??', '{}', p); p = re.sub(r'\{[^}]*\}', '{}', p)
    return p.rstrip('/') or '/'
def git(repo, *a): return subprocess.run(['git', '-C', f'{BASE}/{repo}', *a], capture_output=True, text=True, check=True).stdout
def contrato(n):
    js = ("const y=require(process.argv[1]+'/node_modules/js-yaml');const d=y.load(require('fs').readFileSync(process.argv[2],'utf8'));"
          "const o=[];for(const[p,v]of Object.entries(d.paths))for(const m of['get','post','put','patch','delete'])if(v[m])o.push([m.toUpperCase(),p]);"
          "console.log(JSON.stringify({srv:(d.servers||[]).map(s=>s.url),o}))")
    return json.loads(subprocess.run(['node', '-e', js, f'{BASE}/MANI-API', f'{S}/oa_{n}.yaml'], capture_output=True, text=True, check=True).stdout)
def quita(p, pre): return p[len(pre):] or '/' if p == pre or p.startswith(pre + '/') else p
rutas = {'core': {}, 'dispatch': {}, 'rules': {}}
for r in json.load(open(f'{SAL}/rutas_core_3bb3dd3.json')):
    rutas['core'].setdefault((r['metodo'], norm(quita(r['ruta'], '/api/v1'))), r['origen'])
for l in git('MANI-.NET', 'grep', '-nE', r'\[Http(Get|Post|Put|Patch|Delete)\(|MapMetrics\(', '1fce80e', '--', '*.cs').splitlines():
    _, f, n, t = l.split(':', 3)
    if 'est' in f.split('/')[0] and 'Test' in f: continue
    m = re.search(r'\[Http(\w+)\("([^"]*)"', t)
    k = (m[1].upper(), norm('/' + m[2])) if m else ('GET', '/metrics')
    rutas['dispatch'][k] = f'{f}:{n}'
for l in git('MANI-Java', 'grep', '-nE', r'@(Get|Post|Put|Patch|Delete)Mapping\(', 'ce513cb', '--', 'src/main').splitlines():
    _, f, n, t = l.split(':', 3); m = re.search(r'@(\w+)Mapping\((.*)\)', t)
    for p in re.findall(r'"([^"]+)"', m[2]): rutas['rules'].setdefault((m[1].upper(), norm(quita(p, '/api/v1/rules'))), f"{f.split('/')[-1]}:{n}")
con = {n: contrato(n) for n in ('core', 'core-internal', 'dispatch', 'rules')}
tabla = [('servicio', 'metodo', 'ruta', 'codigo', 'contrato')]; resumen = []
for s, cs in (('core', ('core', 'core-internal')), ('dispatch', ('dispatch',)), ('rules', ('rules',))):
    doc = {}
    for c in cs:
        for m, p in con[c]['o']: doc.setdefault((m, norm(p)), []).append(f'{c}.yaml {p}')
    for k in sorted(set(doc) | set(rutas[s]), key=lambda x: (x[1], x[0])):
        tabla.append((s, k[0], k[1], rutas[s].get(k, 'SIN RUTA'), ' + '.join(doc.get(k, ['SIN CONTRATO']))))
    resumen.append(f"{s}: rutas {len(rutas[s])}, operaciones {sum(len(v) for v in doc.values())} ({len(doc)} únicas), "
                   f"sin contrato {sorted(set(rutas[s]) - set(doc))}, sin ruta {sorted(set(doc) - set(rutas[s]))}, "
                   f"en dos contratos {[k for k, v in doc.items() if len(v) > 1]}, servers {[con[c]['srv'] for c in cs]}")
open(f'{SAL}/tabla_api_contrato.csv', 'w').write('\n'.join(','.join(f'"{x}"' for x in r) for r in tabla) + '\n')
open(f'{SAL}/resumen.txt', 'w').write('\n'.join(resumen) + '\n'); print('\n'.join(resumen))

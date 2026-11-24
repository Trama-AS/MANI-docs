"""QAS-40 en la VM de QA con copias desechables de Core y Dispatch. No toca los contenedores de QA.

Levanta tres contenedores temporales en la red de QA, con las mismas imagenes desplegadas y sus mismas variables:
  qas40-proxy     inyecta fallas y cuenta las peticiones que llegan al destino
  qas40-dispatch  Dispatch con CORE_SERVICE_URL y RULES_SERVICE_URL apuntando al proxy
  qas40-core      Core con RULES_SERVICE_URL y DISPATCH_SERVICE_URL al proxy, sin KAFKA_BROKERS (no corre el relay) y 2 conexiones
Solo publica puertos en 127.0.0.1. Al salir borra los tres. Deja 1 solicitud de prueba, que cancela.
El PUT de reglas del tenant viaja con reglas invalidas y expectedVersion 0: no puede guardar una version.
No imprime claves, tokens ni variables de entorno."""
import json, os, re, signal, subprocess, sys, time, urllib.error, urllib.request, uuid

D = '/opt/mani'
GW = 'http://localhost'
SITIO = '95ec8352-ad14-4bed-a613-e22d23a72a3a'
REALES = {'core': 'mani-core-service', 'dispatch': 'mani-dispatch-service', 'rules': 'mani-rules-service', 'gateway': 'mani-api-gateway'}
TEMP = ('qas40-dispatch', 'qas40-core', 'qas40-proxy')
PROXY_JS = os.environ['PROXY_JS']
resumen = []


def di(x=''):
    try: print(x, flush=True)
    except OSError: pass  # si se corta el SSH, la limpieza sigue


def corte(*_): raise SystemExit('cortado por senal; se limpia')
for sig in (signal.SIGHUP, signal.SIGTERM, signal.SIGINT): signal.signal(sig, corte)


def sh(args, **k): return subprocess.run(args, capture_output=True, text=True, errors='replace', timeout=k.pop('timeout', 120), **k)
def oculta(t):
    t = re.sub(r'eyJ[\w-]+\.[\w-]+\.[\w-]+', '<token>', t)
    t = re.sub(r'postgres(ql)?://\S+', '<url>', t)
    return re.sub(r'(?i)(password=)[^; "]+', r'\1<oculto>', t)


def insp(fmt, x): return sh(['docker', 'inspect', '-f', fmt, x]).stdout.strip()
def foto(): return {n: insp('{{.Image}} {{.State.StartedAt}} reinicios={{.RestartCount}} {{.State.Status}}', c) for n, c in REALES.items()}


env = {}
for l in open(f'{D}/.env.qa', encoding='utf8'):
    m = re.match(r'^([A-Za-z_]\w*)=(.*)$', l.strip())
    if m: env[m.group(1)] = m.group(2).strip().strip('\'"')
anon = next(env[n] for n in ('SUPABASE_ANON_KEY', 'SUPABASE_KEY', 'ANON_KEY', 'SUPABASE_PUBLISHABLE_KEY') if env.get(n))


def http(met, url, cuerpo=None, tok=None, extra=None, plazo=45):
    cab = {'Content-Type': 'application/json', 'X-Correlation-ID': f'qas40-{uuid.uuid4().hex[:10]}', **(extra or {})}
    if tok: cab['Authorization'] = 'Bearer ' + tok
    r = urllib.request.Request(url, method=met, headers=cab, data=json.dumps(cuerpo).encode() if cuerpo is not None else None)
    i = time.time()
    try:
        with urllib.request.urlopen(r, timeout=plazo) as x: c, t = x.status, x.read().decode(errors='replace')
    except urllib.error.HTTPError as e: c, t = e.code, e.read().decode(errors='replace')
    except Exception as e: return 0, {'code': type(e).__name__}, time.time() - i
    try: return c, (json.loads(t) if t else {}), time.time() - i
    except ValueError: return c, {}, time.time() - i


def cod(b):
    if not isinstance(b, dict): return ''
    e = b.get('error')
    return (e.get('code') if isinstance(e, dict) else None) or b.get('code') or ''


def login(correo):
    c, b, _ = http('POST', env['SUPABASE_URL'].rstrip('/') + '/auth/v1/token?grant_type=password', {'email': correo, 'password': os.environ['CLAVE_CFG04']}, extra={'apikey': anon})
    if c != 200: raise SystemExit(f'ABORTA: sin sesion {correo} ({c}). No se levanto nada.')
    return b['access_token']


def puerto(c, p): return 'http://' + sh(['docker', 'port', c, str(p)]).stdout.split()[0]


def levantar(nombre, imagen, variables, interno, mem, extra=(), cmd=()):
    # Las variables viajan por el entorno de docker (-e NOMBRE): los valores no aparecen en `ps`.
    args = ['docker', 'run', '-d', '--name', nombre, '--network', RED, '--memory', mem, '--cpus', '0.75',
            '-p', f'127.0.0.1::{interno}', *sum((['-e', k] for k in variables), []), *extra, imagen, *cmd]
    r = sh(args, env={**os.environ, **variables, 'PATH': os.environ['PATH'], 'HOME': os.environ.get('HOME', '/')})
    if r.returncode: raise SystemExit(f'ABORTA: no se levanto {nombre}: ' + oculta(r.stderr)[-200:])


def entorno(c, **cambios):
    v = dict(x.split('=', 1) for x in json.loads(insp('{{json .Config.Env}}', c)) if '=' in x)
    for k in ('PATH', 'HOME', 'HOSTNAME'): v.pop(k, None)
    v.update(cambios); return v


def esperar(url, seg=60):
    fin = time.time() + seg
    while time.time() < fin:
        if http('GET', url, plazo=3)[0] == 200: return True
        time.sleep(2)
    return False


def anota(par, caso, ok, detalle):
    e = {True: 'PASA ', False: 'FALLA'}.get(ok, 'REVISAR')
    resumen.append((e.strip(), par, caso)); di(f'{e} | QAS-40 | {par} | {caso} | {detalle}')


di(f'== QAS-40 en MANI-QA con copias desechables ({time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())})')
ETQ = '{{index .Config.Labels "org.opencontainers.image.revision"}}'
for c in REALES.values(): di('  ' + c + ' rev=' + (insp(ETQ, c)[:7] or '?'))
for c in TEMP:
    if sh(['docker', 'inspect', c]).returncode == 0: raise SystemExit(f'ABORTA: ya existe {c}; borrarlo antes. No se cambio nada.')
REDES = json.loads(insp('{{json .NetworkSettings.Networks}}', REALES['dispatch']))
RED = next(iter(REDES))
IMG = {n: insp('{{.Image}}', c) for n, c in REALES.items()}
libre = sh(['free', '-m']).stdout.splitlines()
di(f'  red {RED}; memoria disponible {libre[1].split()[-1] if len(libre) > 1 else "?"} MB')
if len(libre) > 1 and int(libre[1].split()[-1]) < 1300: raise SystemExit('ABORTA: menos de 1300 MB disponibles en la VM. No se levanto nada.')
antes = foto()
CLI, ALI, ADM = (login(f'{x}.t1@qa.mani.test') for x in ('cliente', 'aliado', 'admin'))
SID = None

try:
    levantar('qas40-proxy', IMG['core'], {'QAS40': '1'}, 9000, '96m', cmd=('node', '-e', PROXY_JS))
    ctl = puerto('qas40-proxy', 9000)
    if not esperar(ctl + '/salud', 20): raise SystemExit('ABORTA: el proxy no respondio')
    P = 'http://qas40-proxy:'
    levantar('qas40-dispatch', IMG['dispatch'], entorno(REALES['dispatch'], CORE_SERVICE_URL=P + '9002', RULES_SERVICE_URL=P + '9001'), 5000, '512m')
    levantar('qas40-core', IMG['core'], entorno(REALES['core'], RULES_SERVICE_URL=P + '9001', DISPATCH_SERVICE_URL=P + '9003', KAFKA_BROKERS='', DATABASE_POOL_MAX='2'), 3000, '512m')
    UD, UC = puerto('qas40-dispatch', 5000), puerto('qas40-core', 3000)
    for nombre, url in (('qas40-dispatch', UD + '/api/v1/dispatch/health'), ('qas40-core', UC + '/health')):
        if not esperar(url):
            di(oculta(sh(['docker', 'logs', '--tail', '8', nombre]).stdout)[-800:])
            raise SystemExit(f'ABORTA: {nombre} no llego a 200')
    di('  copias listas: qas40-dispatch, qas40-core')

    _, cats, _ = http('GET', f'{GW}/api/v1/core/solicitudes/categorias', tok=CLI)
    filas = cats if isinstance(cats, list) else next((v for v in cats.values() if isinstance(v, list)), [])
    cat = next((x['id'] for x in filas if 'plomer' in str(x.get('nombre') or x.get('name') or '').lower()), None)
    c, b, _ = http('POST', f'{GW}/api/v1/core/solicitudes', {'categoriaId': cat, 'sitioId': SITIO, 'claveIdempotencia': str(uuid.uuid4()), 'descripcion': 'Prueba QA QAS-40, no atender.'}, CLI)
    SID = (b.get('solicitud') or {}).get('id') or b.get('id')
    if c not in (200, 201) or not SID: raise SystemExit(f'ABORTA: crear solicitud dio {c} {cod(b)}')
    REGLAS = {'expectedVersion': 0, 'reglas': {'ordenListado': {'criterio': 'CALIFICACION'}, 'alertaTarifa': {'toleranciaPorcentaje': 10}, 'comision': {'porcentaje': 99},
              'cancelacion': {'ventanaHoras': 2, 'penalizacionPorcentaje': 20}, 'oferta': {'minutosParaAceptar': 15}}}
    c, vig0, _ = http('GET', f'{GW}/api/v1/core/tenant/rules', tok=ADM)

    elegibles = lambda: http('GET', f'{UD}/api/v1/dispatch/requests/{SID}/eligible-allies', tok=CLI)
    # par, destino en el proxy, operacion, codigos sanos, timeout esperado, modos de respuesta malformada
    PARES = [
        ('Dispatch -> Rules', 'rules', elegibles, (200,), 3, ('html', 'roto', 'vacio'), 'qas40-dispatch'),
        ('Dispatch -> Core', 'core', elegibles, (200,), 10, ('html', 'roto', 'vacio'), 'qas40-dispatch'),
        ('Dispatch -> Core (bandeja)', 'core', lambda: http('GET', f'{UD}/api/v1/dispatch/offers/me', tok=ALI), (200,), None, ('html', 'roto', 'vacio'), 'qas40-dispatch'),
        ('Core -> Rules', 'rules', lambda: http('PUT', f'{UC}/api/v1/tenant/rules', REGLAS, ADM), (400, 422), 6, ('html', 'roto', 'vacio', 'valido'), 'qas40-core'),
        ('Core -> Dispatch', 'dispatch', lambda: http('GET', f'{UC}/api/v1/sites/{SITIO}/rules', tok=ALI), (200, 403), 6, ('html', 'roto', 'vacio'), 'qas40-core'),
    ]
    modo = lambda d, m: http('GET', f'{ctl}/modo/{d}/{m}')
    conteo = lambda d: http('GET', f'{ctl}/conteo/{d}')[1].get('n')
    for par, dest, op, sanos, tope, malos, ct in PARES:
        di(f'\n-- {par}')
        modo(dest, 'pasa'); c, b, s = op()
        anota(par, 'sin falla', c in sanos and conteo(dest) >= 1, f'{c} {cod(b)} en {s:.2f} s; llamadas al destino {conteo(dest)}')
        if c not in sanos: continue
        if tope:
            modo(dest, 'cuelga'); c, b, s = op()
            anota(par, f'demora: termina por timeout (~{tope} s)', c in (502, 503, 504) and s < tope + 4, f'{c} {cod(b)} en {s:.2f} s')
            modo(dest, 'pasa'); op()
        for m in malos:
            modo(dest, m); c, b, s = op()
            # Rechazada = no devuelve 2xx. Un 4xx rechaza, pero cuenta la falla del proveedor como error del usuario.
            anota(par, f'respuesta malformada ({m}) rechazada', True if c >= 500 else (None if 400 <= c < 500 else False), f'{c} {cod(b)} en {s:.2f} s')
            modo(dest, 'pasa'); op()
        if not tope: continue
        time.sleep(11); modo(dest, 'pasa'); op()
        modo(dest, 'caido'); tiempos, llegadas, codigos = [], [], []
        for n in range(1, 10):
            ini = conteo(dest); c, b, s = op(); lleg = conteo(dest) - ini
            tiempos.append(s); llegadas.append(lleg); codigos.append(c)
            di(f'    caida {n}: {c} {cod(b)} en {s:.2f} s; llamadas al destino {lleg}')
        anota(par, 'caidas repetidas: se corta el circuito', llegadas[0] > 0 and llegadas[-3:] == [0, 0, 0] and all(x == 503 for x in codigos), f'llamadas por intento {llegadas}; codigos {sorted(set(codigos))}')
        modo(dest, 'pasa'); c, b, s = op()
        anota(par, 'circuito abierto con el destino ya sano', c == 503 and conteo(dest) == 0, f'{c} {cod(b)} en {s:.2f} s; llamadas {conteo(dest)}')
        time.sleep(11); c, b, s = op()
        anota(par, 'se recupera a los 10 s', c in sanos and conteo(dest) >= 1, f'{c} en {s:.2f} s; llamadas {conteo(dest)}')
        r = sh(['docker', 'logs', ct]); di(f"    menciones de 'Circuito abierto' / 'circuito abierto' en logs de {ct}: {len(re.findall('(?i)circuito abierto', r.stdout + r.stderr))}")
    c, vig1, _ = http('GET', f'{GW}/api/v1/core/tenant/rules', tok=ADM)
    quita = lambda v: {k: x for k, x in v.items() if k not in ('correlationId', 'timestamp')} if isinstance(v, dict) else v
    di(); anota('reglas del tenant', 'sin cambios en la corrida', c == 200 and quita(vig0) == quita(vig1), f"{c} version={(vig1 or {}).get('version')}")
finally:
    di('\n== Limpieza')
    for c in TEMP: sh(['docker', 'rm', '-f', c])
    quedan = [c for c in TEMP if sh(['docker', 'inspect', c]).returncode == 0]
    di(f"  contenedores temporales borrados: {'si' if not quedan else 'NO, quedan ' + ', '.join(quedan)}")
    if SID:
        c, b, _ = http('PATCH', f'{GW}/api/v1/core/solicitudes/me/{SID}/cancelar', {'motivo': 'QAS-40 fin de prueba'}, CLI)
        di(f'  cancelar la solicitud de prueba: {c} {cod(b)}')
    despues = foto(); di(f"  servicios de QA sin cambios (imagen, arranque y reinicios): {'si' if despues == antes else 'NO'}")
    for r in ('/health', '/api/v1/core/health', '/api/v1/dispatch/health', '/api/v1/rules/health'): di(f'  {http("GET", GW + r, plazo=8)[0]} {r}')
    n = lambda e: sum(x[0] == e for x in resumen)
    di(f"== Resumen: {n('PASA')} PASA, {n('FALLA')} FALLA, {n('REVISAR')} REVISAR. Fin ({time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())})")

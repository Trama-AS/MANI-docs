"""QAS-02 y QAS-09 en la VM de QA con copias desechables de Core y Dispatch. No toca los contenedores de QA.

Las copias usan las imagenes desplegadas y sus mismas variables, sin KAFKA_BROKERS y con 2 conexiones. Solo publican en 127.0.0.1.
QAS-02: 4 solicitudes de prueba (crear, orquestar, aceptar, cancelar), una por caso de falla del proveedor push.
QAS-09: registros de aliado que fallan en Storage a proposito; cada uno debe quedar compensado. No queda ninguna cuenta.
La base solo se lee (transacciones READ ONLY). ENSAYO=1 levanta y borra las copias sin enviar escrituras.
No imprime claves, tokens ni variables de entorno."""
import json, os, re, secrets, signal, subprocess, sys, time, urllib.error, urllib.request, uuid

D = '/opt/mani'
GW = 'http://localhost'
SITIO = '95ec8352-ad14-4bed-a613-e22d23a72a3a'
T1 = '10000000-0000-4000-8000-000000000011'
REALES = {'core': 'mani-core-service', 'dispatch': 'mani-dispatch-service', 'rules': 'mani-rules-service', 'gateway': 'mani-api-gateway'}
TEMP = ('qas0209-dispatch', 'qas0209-core')
OBS = os.environ['OBSERVADOR_JS']
ENSAYO = os.environ.get('ENSAYO') == '1'
SOLO_RECUPERACION = os.environ.get('RECUPERACION') == '1'
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


def http(met, url, cuerpo=None, tok=None, extra=None, plazo=45, crudo=None):
    cab = {'Content-Type': 'application/json', 'X-Correlation-ID': f'qas0209-{uuid.uuid4().hex[:10]}', **(extra or {})}
    if tok: cab['Authorization'] = 'Bearer ' + tok
    r = urllib.request.Request(url, method=met, headers=cab, data=crudo if crudo is not None else json.dumps(cuerpo).encode() if cuerpo is not None else None)
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


def anota(qas, par, caso, ok, detalle):
    e = {True: 'PASA ', False: 'FALLA'}.get(ok, 'REVISAR')
    resumen.append((e.strip(), qas, caso)); di(f'{e} | {qas} | {par} | {caso} | {detalle}')

def sql(guion):
    r = subprocess.run(['docker', 'run', '--rm', '-i', '--network', 'host', '-e', 'PGURL', 'postgres:15', 'sh', '-c', 'exec psql "$@" "$PGURL"', 'sh',
                        '-X', '-q', '-A', '-t', '-F', '|', '-v', 'ON_ERROR_STOP=1'],
                       input=f'BEGIN READ ONLY;\n{guion}\nROLLBACK;\n', capture_output=True, text=True, timeout=120, env={**os.environ, 'PGURL': env['DATABASE_URL_ADMIN']})
    if r.returncode: raise RuntimeError('SELECT: ' + oculta(r.stderr)[-300:])
    return [l for l in r.stdout.splitlines() if l.strip()]


def borrar(*nombres):
    for c in nombres: sh(['docker', 'rm', '-f', c])


def copia_core(**cambios):
    borrar('qas0209-core')
    levantar('qas0209-core', IMG['core'], entorno(REALES['core'], KAFKA_BROKERS='', DATABASE_POOL_MAX='2', **cambios), 3000, '512m', cmd=('node', '-e', OBS))
    u = puerto('qas0209-core', 3000)
    if not esperar(u + '/health'):
        r = sh(['docker', 'logs', '--tail', '8', 'qas0209-core']); di(oculta(r.stdout + r.stderr)[-800:])
        raise SystemExit('ABORTA: la copia de Core no llego a 200')
    return u


def copia_dispatch():
    borrar('qas0209-dispatch')
    levantar('qas0209-dispatch', IMG['dispatch'], entorno(REALES['dispatch'], CORE_SERVICE_URL='http://qas0209-core:3000'), 5000, '512m')
    u = puerto('qas0209-dispatch', 5000)
    if not esperar(u + '/api/v1/dispatch/health'): raise SystemExit('ABORTA: la copia de Dispatch no llego a 200')
    return u


def logs(c):
    r = sh(['docker', 'logs', c]); return (r.stdout + r.stderr).splitlines()


di(f'== QAS-02 y QAS-09 en MANI-QA con copias desechables{" (ENSAYO, sin escrituras)" if ENSAYO else ""} ({time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())})')
ETQ = '{{index .Config.Labels "org.opencontainers.image.revision"}}'
for c in REALES.values(): di('  ' + c + ' rev=' + (insp(ETQ, c)[:7] or '?'))
for c in TEMP:
    if sh(['docker', 'inspect', c]).returncode == 0: raise SystemExit(f'ABORTA: ya existe {c}; borrarlo antes. No se cambio nada.')
RED = next(iter(json.loads(insp('{{json .NetworkSettings.Networks}}', REALES['dispatch']))))
IMG = {n: insp('{{.Image}}', c) for n, c in REALES.items()}
libre = sh(['free', '-m']).stdout.splitlines()
di(f'  red {RED}; memoria disponible {libre[1].split()[-1] if len(libre) > 1 else "?"} MB')
if len(libre) > 1 and int(libre[1].split()[-1]) < 1300: raise SystemExit('ABORTA: menos de 1300 MB disponibles en la VM. No se levanto nada.')
if not env.get('DATABASE_URL_ADMIN'): raise SystemExit('ABORTA: falta DATABASE_URL_ADMIN para verificar el estado persistido.')
fila = sql(f"SELECT slug, estado FROM tenant WHERE id = '{T1}';")
SLUG = fila[0].split('|')[0]
di(f'  tenant de prueba: {SLUG}')


def residuos(correo, nombre, doc, desde):
    """Filas que dejaria un registro a medias: por identidad y, en las tablas hijas, huerfanas o del aliado."""
    q = [f"SELECT 'auth.users', count(*) FROM auth.users WHERE email = '{correo}';",
         f"SELECT 'usuario', count(*) FROM public.usuario WHERE email = '{correo}';",
         f"SELECT 'aliado', count(*) FROM public.aliado WHERE nombre_razon_social = '{nombre}' OR numero_documento_identidad = '{doc}';",
         "SELECT 'aliado_categoria_huerfana', count(*) FROM public.aliado_categoria h WHERE NOT EXISTS (SELECT 1 FROM public.aliado a WHERE a.id = h.aliado_id);",
         "SELECT 'documento_kyc_huerfano', count(*) FROM public.documento_kyc h WHERE NOT EXISTS (SELECT 1 FROM public.aliado a WHERE a.id = h.aliado_id);",
         "SELECT 'consentimiento_huerfano', count(*) FROM public.consentimiento_usuario h WHERE NOT EXISTS (SELECT 1 FROM public.usuario u WHERE u.id = h.usuario_id);",
         f"SELECT 'storage_kyc_nuevo', count(*) FROM storage.objects WHERE bucket_id = 'kyc-documentos' AND created_at >= '{desde}';"]
    return {k: int(v) for k, v in (l.split('|') for l in sql('\n'.join(q)))}


def ahora(): return sql('SELECT clock_timestamp();')[0]


di('  residuos antes (lectura de prueba): ' + json.dumps(residuos('nadie@qa.mani.test', 'nadie-qas09', '0', '2999-01-01')))
antes = foto()
CLI, ALI = (login(f'{x}.t1@qa.mani.test') for x in ('cliente', 'aliado'))
_, cats, _ = http('GET', f'{GW}/api/v1/core/solicitudes/categorias', tok=CLI)
filas = cats if isinstance(cats, list) else next((v for v in cats.values() if isinstance(v, list)), [])
CAT = next((x['id'] for x in filas if 'plomer' in str(x.get('nombre') or x.get('name') or '').lower()), None)
di(f'  sesiones listas; categoria de prueba: {"si" if CAT else "NO"}')
if not CAT: raise SystemExit('ABORTA: no hay categoria de plomeria')
abiertas, quedo_a_medias = set(), []

CASOS_02 = (('control', {'PUSH_PROVIDER': 'mock'}, 1, 'entregado'),
            ('caida', {'PUSH_PROVIDER': 'mock_falla', 'PUSH_MOCK_FALLAS': 'siempre'}, 2, 'falla'),
            ('error y reintento', {'PUSH_PROVIDER': 'mock_falla', 'PUSH_MOCK_FALLAS': '1'}, 2, 'entregado'),
            ('timeout', {'PUSH_PROVIDER': 'mock', 'QAS02_CUELGA': '1'}, 2, 'sin_respuesta'))
CASOS_09 = (('natural, falla el primer documento', 'natural', {'STORAGE_FALLA': 'upload', 'STORAGE_FALLA_DESPUES_DE': '0'}),
            ('natural, falla el segundo documento', 'natural', {'STORAGE_FALLA': 'upload', 'STORAGE_FALLA_DESPUES_DE': '1'}),
            ('empresa, falla el tercer documento', 'empresa', {'STORAGE_FALLA': 'upload', 'STORAGE_FALLA_DESPUES_DE': '2'}))
PDF = b'%PDF-1.4\n% Prueba QA QAS-09, sin datos reales\n%%EOF\n'


def multipart(campos, archivos):
    lim = 'qas09' + uuid.uuid4().hex
    partes = [f'--{lim}\r\nContent-Disposition: form-data; name="{k}"\r\n\r\n{v}\r\n'.encode() for k, v in campos.items()]
    for k in archivos:
        partes.append(f'--{lim}\r\nContent-Disposition: form-data; name="{k}"; filename="{k}.pdf"\r\nContent-Type: application/pdf\r\n\r\n'.encode() + PDF + b'\r\n')
    return b''.join(partes) + f'--{lim}--\r\n'.encode(), f'multipart/form-data; boundary={lim}'


def estado(sid): return (sql(f"SELECT estado FROM solicitud WHERE id = '{sid}';") or ['?'])[0]


def caso_02(caso, cambios, esperados, desenlace):
    di(f'\n-- QAS-02 {caso}: {cambios}')
    uc, ud = copia_core(**cambios), copia_dispatch()
    if ENSAYO: di('  copias sanas'); return
    cid = f'qas02-{uuid.uuid4().hex[:10]}'; X = {'X-Correlation-ID': cid}
    c, b, _ = http('POST', f'{uc}/api/v1/solicitudes', {'categoriaId': CAT, 'sitioId': SITIO, 'claveIdempotencia': str(uuid.uuid4()), 'descripcion': 'Prueba QA QAS-02, no atender.'}, CLI, X)
    sid = (b.get('solicitud') or {}).get('id') or b.get('id')
    if c not in (200, 201) or not sid: anota('QAS-02', caso, 'crear la solicitud', None, f'{c} {cod(b)}'); return
    abiertas.add(sid)
    c, b, s = http('POST', f'{ud}/api/v1/dispatch/requests/orchestrate', {'requestId': sid}, CLI, {**X, 'Idempotency-Key': str(uuid.uuid4())})
    anota('QAS-02', caso, 'orquestar no se revierte', c in (200, 201, 202), f'{c} {cod(b)} en {s:.2f} s')
    time.sleep(8 if 'QAS02_CUELGA' in cambios else 3)
    c, b, s = http('POST', f'{ud}/api/v1/dispatch/requests/{sid}/accept', None, ALI, {**X, 'Idempotency-Key': str(uuid.uuid4())})
    e = estado(sid)
    anota('QAS-02', caso, 'aceptar queda confirmado', c == 200 and e == 'ASIGNADA', f'{c} {cod(b)} en {s:.2f} s; estado en base {e}')
    c, b, s = http('PATCH', f'{uc}/api/v1/solicitudes/me/{sid}/cancelar', {'motivo': 'QAS-02 fin de prueba'}, CLI, X)
    e = estado(sid)
    anota('QAS-02', caso, 'cancelar queda confirmado', c == 200 and e == 'CANCELADA', f'{c} {cod(b)} en {s:.2f} s; estado en base {e}')
    if e == 'CANCELADA': abiertas.discard(sid)
    avisos = dict(l.split('|') for l in sql(f"SELECT tipo, count(*) FROM notificacion WHERE payload->>'requestId' = '{sid}' GROUP BY 1 ORDER BY 1;"))
    anota('QAS-02', caso, 'avisos persistidos', all(int(avisos.get(t, 0)) >= 1 for t in ('OFERTA_DESPACHO', 'SOLICITUD_ASIGNADA', 'SOLICITUD_CANCELADA')), json.dumps(avisos))
    for quien, tok in (('cliente', CLI), ('aliado', ALI)):
        c, b, _ = http('GET', f'{GW}/api/v1/core/profiles/me/inbox', tok=tok)
        anota('QAS-02', caso, f'aviso disponible en la bandeja del {quien}', c == 200 and sid in json.dumps(b), f'{c}')
    time.sleep(1)
    ls = logs('qas0209-core')
    it = []
    for l in ls:
        if l.startswith('{"qas02"'): it.append(json.loads(l))
    ciclo = [x for x in it if x['tipo'] in ('SOLICITUD_ASIGNADA', 'SOLICITUD_CANCELADA')]
    por = {}
    for x in ciclo: por.setdefault(x['clave'], []).append(x)
    di('    intentos por aviso: ' + '; '.join(f"{v[0]['tipo']} {[x['r'] for x in v]}" for v in por.values()))
    di('    intentos de oferta: ' + json.dumps([x['r'] for x in it if x['tipo'] == 'OFERTA_DESPACHO']))
    anota('QAS-02', caso, f'reintento: {esperados} intento(s) por aviso con la misma clave', len(por) == 2 and all(len(v) == esperados and v[-1]['r'].startswith(desenlace) for v in por.values()), f'{[len(v) for v in por.values()]}')
    anota('QAS-02', caso, 'el proveedor recibe el correlation ID de la operacion', bool(ciclo) and all(x['cid'] == cid for x in ciclo), f"{sum(x['cid'] == cid for x in ciclo)} de {len(ciclo)}")
    propios = [l for l in ls if cid in l and not l.startswith('{"qas02"')]
    falla = [l for l in propios if re.search(r'(?i)push|FALLIDA|entrega', l)]
    di(f'    lineas propias de Core con ese correlation ID: {len(propios)}; que mencionan la falla de entrega: {len(falla)}')
    if caso != 'control': anota('QAS-02', caso, 'Core registra en sus logs la falla de entrega con correlation ID', True if falla else None, f'{len(falla)} linea(s)')


def caso_09(caso, tipo, cambios):
    di(f'\n-- QAS-09 {caso}: {cambios}')
    u = copia_core(**cambios)
    if ENSAYO: di('  copia sana'); return
    marca = uuid.uuid4().hex[:10]; correo = f'qas09.{marca}@qa.mani.test'; nombre = f'Prueba QAS09 {marca}'
    doc = '99' + ''.join(secrets.choice('0123456789') for _ in range(8)); clave = secrets.token_urlsafe(18) + 'aA1!'
    if tipo == 'natural':
        ruta, archivos = '/api/v1/auth/register/ally', ('cedula_ciudadania', 'rut_certificado')
        campos = {'fullName': nombre, 'email': correo, 'password': clave, 'categoriaId': CAT, 'documentType': 'CC', 'documentNumber': doc, 'acceptsTerms': 'true'}
    else:
        ruta, archivos = '/api/v1/auth/register/ally/company', ('camara_comercio', 'rut_empresa', 'cedula_representante')
        campos = {'razon_social': nombre, 'nit': doc, 'nombre_representante': 'Prueba QA', 'doc_representante': doc, 'email': correo, 'password': clave, 'categoria_id': CAT}
    desde, cids = ahora(), []
    quedo_a_medias.append((correo, nombre, doc, desde))
    for n in (1, 2):
        cid = f'qas09-{marca}-{n}'; cids.append(cid)
        cuerpo, ct = multipart(campos, archivos)
        c, b, s = http('POST', u + ruta, tok=None, extra={'Content-Type': ct, 'X-Tenant-Slug': SLUG, 'X-Correlation-ID': cid}, crudo=cuerpo)
        m = re.search(r'upload, llamada \d+', json.dumps(b))
        anota('QAS-09', caso, 'responde el error sin exito parcial' if n == 1 else 'repetir no choca con 409 (correo y documento libres)', c == 503, f'{c} {cod(b)} {m[0] if m else ""} en {s:.2f} s')
        if c in (200, 201): anota('QAS-09', caso, 'se creo una cuenta que no debia', False, 'avisar; no se borra solo')
        r = residuos(correo, nombre, doc, desde)
        anota('QAS-09', caso, f'estado persistido tras el intento {n}: sin residuos', all(v == base09.get(k, 0) for k, v in r.items()), json.dumps({k: v - base09.get(k, 0) for k, v in r.items()}))
    ls = logs('qas0209-core')
    anota('QAS-09', caso, 'logs con el correlation ID de cada intento', True if all(any(x in l for l in ls) for x in cids) else None, f'{[sum(x in l for l in ls) for x in cids]} lineas')


def recuperacion():
    """QAS-09: la orquestacion falla a mitad por un push colgado; se comprueba si repetirla con el push sano la completa."""
    caso = 'orquestacion a medias por push colgado'
    di(f'\n-- QAS-09 {caso}')
    uc, ud = copia_core(PUSH_PROVIDER='mock', QAS02_CUELGA='1'), copia_dispatch()
    if ENSAYO: di('  copias sanas'); return
    X = {'X-Correlation-ID': f'qas09-{uuid.uuid4().hex[:10]}'}
    c, b, _ = http('POST', f'{uc}/api/v1/solicitudes', {'categoriaId': CAT, 'sitioId': SITIO, 'claveIdempotencia': str(uuid.uuid4()), 'descripcion': 'Prueba QA QAS-09, no atender.'}, CLI, X)
    sid = (b.get('solicitud') or {}).get('id') or b.get('id')
    if c not in (200, 201) or not sid: anota('QAS-09', caso, 'crear la solicitud', None, f'{c} {cod(b)}'); return
    abiertas.add(sid)
    c, el, _ = http('GET', f'{ud}/api/v1/dispatch/requests/{sid}/eligible-allies', tok=CLI)
    lista = el if isinstance(el, list) else next((v for v in el.values() if isinstance(v, list)), [])
    ofertas = lambda: [int(x) for x in sql(f"SELECT count(*) || '|' || count(DISTINCT usuario_id) FROM notificacion WHERE tipo = 'OFERTA_DESPACHO' AND payload->>'requestId' = '{sid}';")[0].split('|')]
    e0 = estado(sid)
    c, b, s = http('POST', f'{ud}/api/v1/dispatch/requests/orchestrate', {'requestId': sid}, CLI, {**X, 'Idempotency-Key': str(uuid.uuid4())})
    e1, o1 = estado(sid), ofertas()
    anota('QAS-09', caso, 'la falla se reproduce', c == 503, f'{c} {cod(b)} en {s:.2f} s; ofertas {o1[0]} de {len(lista)} elegibles; estado {e0} -> {e1}')
    anota('QAS-09', caso, 'la solicitud no cambia de estado', e0 == e1, f'{e0} -> {e1}')
    time.sleep(12)
    copia_core(PUSH_PROVIDER='mock')
    time.sleep(11)
    c, b, s = http('POST', f'{ud}/api/v1/dispatch/requests/orchestrate', {'requestId': sid}, CLI, {**X, 'Idempotency-Key': str(uuid.uuid4())})
    o2 = ofertas()
    anota('QAS-09', caso, 'repetir con el push sano completa las ofertas', c == 200 and o2[0] == len(lista) and len(lista) > 0, f'{c} {cod(b)} en {s:.2f} s; ofertas {o2[0]} de {len(lista)}')
    anota('QAS-09', caso, 'sin ofertas duplicadas', o2[0] == o2[1], f'{o2[0]} ofertas a {o2[1]} aliados')
    c, b, _ = http('PATCH', f'{GW}/api/v1/core/solicitudes/me/{sid}/cancelar', {'motivo': 'QAS-09 fin de prueba'}, CLI)
    e = estado(sid); di(f'    cancelar: {c} {cod(b)}; estado {e}')
    if e == 'CANCELADA': abiertas.discard(sid)


base09 = {}
try:
    if not ENSAYO: base09 = residuos('nadie@qa.mani.test', 'nadie-qas09', '0', '2999-01-01')
    if SOLO_RECUPERACION: recuperacion()
    else:
        for x in CASOS_02: caso_02(*x)
        borrar('qas0209-dispatch')
        for x in CASOS_09: caso_09(*x)
finally:
    di('\n== Limpieza')
    borrar(*TEMP)
    quedan = [c for c in TEMP if sh(['docker', 'inspect', c]).returncode == 0]
    di(f"  contenedores temporales borrados: {'si' if not quedan else 'NO, quedan ' + ', '.join(quedan)}")
    for sid in abiertas:
        c, b, _ = http('PATCH', f'{GW}/api/v1/core/solicitudes/me/{sid}/cancelar', {'motivo': 'QAS-02 fin de prueba'}, CLI); di(f'  cancelar solicitud pendiente: {c} {cod(b)}')
    for q in quedo_a_medias:
        r = residuos(*q); di('  residuos finales de un registro: ' + json.dumps({k: v - base09.get(k, 0) for k, v in r.items()}))
    despues = foto(); di(f"  servicios de QA sin cambios (imagen, arranque y reinicios): {'si' if despues == antes else 'NO'}")
    for r in ('/health', '/api/v1/core/health', '/api/v1/dispatch/health', '/api/v1/rules/health'): di(f'  {http("GET", GW + r, plazo=8)[0]} {r}')
    for q in ('QAS-02', 'QAS-09'):
        n = lambda e: sum(x[0] == e and x[1] == q for x in resumen); di(f"== {q}: {n('PASA')} PASA, {n('FALLA')} FALLA, {n('REVISAR')} REVISAR")
    di(f"== Fin ({time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())})")

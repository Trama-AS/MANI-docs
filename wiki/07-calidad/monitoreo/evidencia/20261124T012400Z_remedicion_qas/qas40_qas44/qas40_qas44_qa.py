"""QAS-40 (circuit breaker de Dispatch hacia Rules) y QAS-44 (SCRUM-1719, rollback tras un despliegue fallido).
Corre en la VM de QA; lo lanza correr_qas40_44.sh. No imprime claves, tokens ni valores de .env.qa.
Afecta QA unos minutos: pausa rules-service y deja dispatch-service caido hasta el rollback.
Al salir, siempre reanuda Rules y deja Dispatch en su imagen :staging. Deja 1 solicitud de prueba, que cancela al final."""
import json, os, re, signal, subprocess, sys, time, urllib.error, urllib.request, uuid

D = '/opt/mani'
GW, CORE, DSP = 'http://localhost', '/api/v1/core', '/api/v1/dispatch'
SITIO, T1 = '95ec8352-ad14-4bed-a613-e22d23a72a3a', '10000000-0000-4000-8000-000000000011'
CT, SRV = 'mani-dispatch-service', 'dispatch-service'
OVER = f'{D}/docker-compose.rollback.override.yml'
OVER_MALO = f'{D}/docker-compose.qas44_falla.override.yml'
MALA = 'mani-dotnet-qas44-falla:local'
t0 = time.time()


def di(x=''):
    try: print(x, flush=True)
    except OSError: pass  # si se corta el SSH, la restauracion sigue


def corte(*_): raise SystemExit('cortado por senal; se restaura')
for sig in (signal.SIGHUP, signal.SIGTERM, signal.SIGINT): signal.signal(sig, corte)


def ahora(): return time.strftime('%H:%M:%SZ', time.gmtime())
def sh(args, **k): return subprocess.run(args, capture_output=True, text=True, cwd=D, timeout=k.pop('timeout', 240), **k)
def dc(*extra, over=()): return sh(['docker', 'compose', '-f', 'docker-compose.qa.yml', *sum((['-f', o] for o in over), []), '--env-file', '.env.qa', *extra])
def oculta(t):
    t = re.sub(r'eyJ[\w-]+\.[\w-]+\.[\w-]+', '<token>', t)
    t = re.sub(r'postgres(ql)?://\S+', '<url>', t)
    return re.sub(r'(?i)(password=)[^; "]+', r'\1<oculto>', t)


env = {}
for l in open(f'{D}/.env.qa', encoding='utf8'):
    m = re.match(r'^([A-Za-z_]\w*)=(.*)$', l.strip())
    if m: env[m.group(1)] = m.group(2).strip().strip('\'"')
anon = next(env[n] for n in ('SUPABASE_ANON_KEY', 'SUPABASE_KEY', 'ANON_KEY', 'SUPABASE_PUBLISHABLE_KEY') if env.get(n))


def http(met, ruta, cuerpo=None, tok=None, extra=None, plazo=30):
    cab = {'Content-Type': 'application/json', 'X-Correlation-ID': f'qas44-{uuid.uuid4().hex[:10]}', **(extra or {})}
    if tok: cab['Authorization'] = 'Bearer ' + tok
    r = urllib.request.Request(ruta if ruta.startswith('http') else GW + ruta, method=met, headers=cab, data=json.dumps(cuerpo).encode() if cuerpo is not None else None)
    i = time.time()
    try:
        with urllib.request.urlopen(r, timeout=plazo) as x: c, t = x.status, x.read().decode()
    except urllib.error.HTTPError as e: c, t = e.code, e.read().decode(errors='replace')
    except Exception as e: return 0, {'_error': type(e).__name__}, time.time() - i
    try: return c, (json.loads(t) if t else {}), time.time() - i
    except ValueError: return c, {}, time.time() - i


def lista(b):
    return b if isinstance(b, list) else next((v for v in b.values() if isinstance(v, list)), [])
def login(correo):
    c, b, _ = http('POST', env['SUPABASE_URL'].rstrip('/') + '/auth/v1/token?grant_type=password', {'email': correo, 'password': os.environ['CLAVE_CFG04']}, extra={'apikey': anon})
    if c != 200: raise SystemExit(f'ABORTA: sin sesion {correo} ({c}). No se cambio nada.')
    return b['access_token']
def cod(b):
    e = b.get('error')
    return (e.get('code') if isinstance(e, dict) else None) or b.get('code') or ''
def salud(ruta): return http('GET', ruta, plazo=5)[0]
def insp(fmt, x): return sh(['docker', 'inspect', '-f', fmt, x]).stdout.strip()
def rev(): return insp('{{index .Config.Labels "org.opencontainers.image.revision"}}', CT)[:7]
def base(sql):
    url = env['DATABASE_URL_ADMIN']
    r = subprocess.run(['docker', 'run', '--rm', '-i', '--network', 'host', '-e', 'PGURL', 'postgres:15', 'sh', '-c', 'psql "$PGURL" -X -A -t -F " | "'],
                       input=f'BEGIN READ ONLY;\n{sql}\nROLLBACK;\n', capture_output=True, text=True, env={**os.environ, 'PGURL': url}, timeout=90)
    return [l for l in oculta(r.stdout + r.stderr).splitlines() if l not in ('BEGIN', 'ROLLBACK', '')]


di(f'== QAS-40 y QAS-44 en MANI-QA ({time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())})')
REF, ID = insp('{{.Config.Image}}', CT), insp('{{.Image}}', CT)
digs = sh(['docker', 'image', 'inspect', '-f', '{{join .RepoDigests " "}}', ID]).stdout.split()
if not REF.endswith(':staging') or not digs: raise SystemExit(f'ABORTA: Dispatch no corre :staging con digest ({REF}). No se cambio nada.')
BUENA = digs[0]
if not os.path.exists(f'{D}/rollback_qa.sh'): raise SystemExit('ABORTA: no esta /opt/mani/rollback_qa.sh. No se cambio nada.')
if os.path.exists(OVER): raise SystemExit('ABORTA: ya existe un override de rollback. No se cambio nada.')
di(f'  Dispatch {rev()} {BUENA[-71:]}')
for r in ('/health', f'{CORE}/health', f'{DSP}/health', '/api/v1/rules/health'):
    if salud(r) != 200: raise SystemExit(f'ABORTA: {r} no esta en 200 antes de empezar. No se cambio nada.')
CLI, ALI = login('cliente.t1@qa.mani.test'), login('aliado.t1@qa.mani.test')

_, cats, _ = http('GET', f'{CORE}/solicitudes/categorias', tok=CLI)
cat = next((c for c in lista(cats) if 'plomer' in str(c.get('nombre') or c.get('name') or '').lower()), None)
if not cat: raise SystemExit('ABORTA: sin categoria Plomeria. No se cambio nada.')
c, b, _ = http('POST', f'{CORE}/solicitudes', {'categoriaId': cat['id'], 'sitioId': SITIO, 'claveIdempotencia': str(uuid.uuid4()), 'descripcion': 'Prueba QA SCRUM-1719 rollback, no atender.'}, CLI)
SID = (b.get('solicitud') or {}).get('id') or b.get('id')
if c not in (200, 201) or not SID: raise SystemExit(f'ABORTA: crear solicitud dio {c} {cod(b)}.')
c, b, _ = http('POST', f'{DSP}/requests/orchestrate', {'requestId': SID}, CLI, {'Idempotency-Key': str(uuid.uuid4())})
di(f'  solicitud de prueba {SID}; ofertas: {c}')
if c not in (200, 201, 202): raise SystemExit('ABORTA: no se pudieron enviar las ofertas. Queda la solicitud de prueba PENDIENTE.')


def restaurar():
    if insp('{{.State.Paused}}', 'mani-rules-service') == 'true': sh(['docker', 'unpause', 'mani-rules-service'])
    for o in (OVER_MALO, OVER):
        if os.path.exists(o): os.remove(o)
    if insp('{{.Config.Image}}', CT) != REF or insp('{{.Image}}', CT) != ID or insp('{{.State.Running}}', CT) != 'true':
        dc('up', '-d', '--no-deps', SRV)
    for _ in range(24):
        if salud(f'{DSP}/health') == 200: break
        time.sleep(5)
    else:
        di('  Dispatch no responde por el Gateway; se reinicia el Gateway')
        dc('restart', 'gateway'); time.sleep(8)
    sh(['docker', 'rm', '-f', 'qas44-tmp']); sh(['docker', 'image', 'rm', '-f', MALA])


try:
    if '--solo-44' not in sys.argv:
        di('\n== QAS-40: Rules sin responder (docker pause), circuit breaker de Dispatch')
        elegibles = f'{DSP}/requests/{SID}/eligible-allies'
        c, b, s = http('GET', elegibles, tok=CLI); di(f'  antes: {c} en {s:.2f} s')
        antes_s = s
        marca = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
        sh(['docker', 'pause', 'mani-rules-service']); di(f'  {ahora()} rules-service pausado')
        lentas, rapidas = [], []
        for n in range(1, 10):
            c, b, s = http('GET', elegibles, tok=CLI); di(f'  intento {n}: {c} {cod(b)} en {s:.2f} s')
            (rapidas if n > 5 else lentas).append((c, s))
        sh(['docker', 'unpause', 'mani-rules-service']); di(f'  {ahora()} rules-service reanudado')
        time.sleep(12)
        c, b, s = http('GET', elegibles, tok=CLI); di(f'  despues de 12 s: {c} en {s:.2f} s')
        logs = sh(['docker', 'logs', '--since', marca, CT])
        n_abierto = (logs.stdout + logs.stderr).count('Circuito abierto para mani-rules')
        med = lambda v: sum(x[1] for x in v) / len(v)
        di(f'  media intentos 1-5: {med(lentas):.2f} s; media 6-9: {med(rapidas):.2f} s; menciones de "Circuito abierto para mani-rules" en logs: {n_abierto}')
        ok = n_abierto > 0 and med(rapidas) < med(lentas) - 1.5 and c == 200
        di(f"{'PASA ' if ok else 'FALLA'} | QAS-40 | Dispatch corta hacia Rules tras fallas repetidas y se recupera")

    di('\n== QAS-44: despliegue fallido a proposito')
    sh(['docker', 'rm', '-f', 'qas44-tmp']); sh(['docker', 'create', '--name', 'qas44-tmp', ID])
    r = sh(['docker', 'commit', '--change', 'ENTRYPOINT ["/bin/false"]', '--change', 'CMD []', 'qas44-tmp', MALA])
    sh(['docker', 'rm', '-f', 'qas44-tmp'])
    if r.returncode: raise SystemExit('ABORTA QAS-44: no se pudo construir la imagen de prueba: ' + oculta(r.stderr)[-200:])
    open(OVER_MALO, 'w').write(f'services:\n  {SRV}:\n    image: {MALA}\n    pull_policy: never\n')
    tf = time.time(); di(f'  {ahora()} despliegue de la imagen que falla')
    r = dc('up', '-d', '--no-deps', SRV, over=(OVER_MALO,))
    time.sleep(10)
    di(f"  contenedor: {insp('{{.State.Status}} reinicios={{.RestartCount}} salida={{.State.ExitCode}}', CT)}; /dispatch/health: {salud(f'{DSP}/health')}")
    if salud(f'{DSP}/health') == 200: raise SystemExit('FALLA | QAS-44 | el despliegue fallido no tumbo Dispatch')
    LLAVE = str(uuid.uuid4())
    c, b, _ = http('POST', f'{DSP}/requests/{SID}/accept', None, ALI, {'Idempotency-Key': LLAVE}); di(f'  aceptar durante la falla: {c}')
    di(f"  estado en base: {base(f'SELECT estado FROM solicitud WHERE id = {chr(39)}{SID}{chr(39)};')}")
    os.remove(OVER_MALO)
    ti = time.time(); di(f'  {ahora()} rollback_qa.sh a {BUENA[-71:]}')
    r = sh(['bash', 'rollback_qa.sh', SRV, BUENA], timeout=420)
    dur = time.time() - ti
    for l in oculta(r.stdout + r.stderr).splitlines()[-14:]: di('    ' + l[:150])
    di(f"{'PASA ' if r.returncode == 0 and dur <= 300 else 'FALLA'} | QAS-44 | rollback en {dur:.0f} s (limite 300); desde el despliegue fallido {time.time() - tf:.0f} s; codigo {r.returncode}; Dispatch {rev()}")

    di('\n== QAS-44: peticion critica despues del rollback (misma Idempotency-Key)')
    c, b, s = http('POST', f'{DSP}/requests/{SID}/accept', None, ALI, {'Idempotency-Key': LLAVE}); di(f"  aceptar: {c} {cod(b)} isRetry={b.get('isRetry')} en {s:.2f} s")
    c2, b2, s = http('POST', f'{DSP}/requests/{SID}/accept', None, ALI, {'Idempotency-Key': LLAVE}); di(f"  repetir: {c2} {cod(b2)} isRetry={b2.get('isRetry')} en {s:.2f} s")
    filas = base(f"SELECT estado, (aliado_id IS NOT NULL) FROM solicitud WHERE id = '{SID}';\n"
                 f"SELECT tipo, count(*) FROM notificacion WHERE tenant_id = '{T1}' AND payload->>'requestId' = '{SID}' GROUP BY 1 ORDER BY 1;")
    for f in filas: di('  base: ' + f)
    ok = c == 200 and c2 == 200 and b2.get('isRetry') is True and b.get('assignedAllyId') == b2.get('assignedAllyId') and filas and filas[0].startswith('ASIGNADA')
    di(f"{'PASA ' if ok else 'REVISAR'} | QAS-44 | la aceptacion responde 200 y el reintento no duplica")
finally:
    di('\n== Restauracion')
    restaurar()
    di(f"  Dispatch {rev()} imagen={insp('{{.Config.Image}}', CT)} misma_imagen={insp('{{.Image}}', CT) == ID}; rules pausado={insp('{{.State.Paused}}', 'mani-rules-service')}")
    for r in ('/health', f'{CORE}/health', f'{DSP}/health', '/api/v1/rules/health'): di(f'  {salud(r)} {r}')
    c, b, _ = http('PATCH', f'{CORE}/solicitudes/me/{SID}/cancelar', {'motivo': 'SCRUM-1719 fin de prueba'}, CLI)
    di(f"  cancelar la solicitud de prueba: {c} {cod(b)}; estado {base(f'SELECT estado FROM solicitud WHERE id = {chr(39)}{SID}{chr(39)};')}")
    di(f'== Fin ({time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}), {time.time() - t0:.0f} s')

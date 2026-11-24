"""SCRUM-1678 (T-41). Repite QAS-01 y QAS-20 en MANI-QA con mani_core_svc y mani_dispatch_svc.

Corre en la VM de QA; lo lanza qa_qas_24nov/correr_qas20.sh, que deja aqui los .sql en T41_DIR.
No imprime claves, tokens ni valores de /opt/mani/.env.qa: de cada conexion solo muestra usuario, host y puerto.
Deja rastro en QA: 3 solicitudes de prueba canceladas y 1 rechazo de aliado.t1 (QAS-20 funcional, 24 nov).
Las verificaciones del motor corren en transacciones que terminan en ROLLBACK.
"""
import json
import os
import re
import subprocess
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid

T41_DIR = os.environ['T41_DIR']
ENV_QA = os.environ.get('ENV_QA', '/opt/mani/.env.qa')
GW = 'http://localhost'
CORE = '/api/v1/core'
DISPATCH = '/api/v1/dispatch'

# UUID fijos del seed de QA (MANI-APIGateway supabase/seed/seed_qa_multitenant.sql)
T1, T2 = '10000000-0000-4000-8000-000000000011', '10000000-0000-4000-8000-000000000021'
U_ADMIN_T1, U_ALIADO_T1 = '30000000-0000-4000-8000-000000000011', '30000000-0000-4000-8000-000000000013'
ALIADO_T1 = '50000000-0000-4000-8000-000000000011'
CATEGORIA = {1: '60000000-0000-4000-8000-000000000011', 2: '60000000-0000-4000-8000-000000000021'}
SITIO = {1: '70000000-0000-4000-8000-000000000011', 2: '70000000-0000-4000-8000-000000000021'}

# Sitio de T1 con cobertura del aliado del seed (el mismo de qa_qas_23nov); la categoria se busca por nombre
SITIO_PRUEBA = '95ec8352-ad14-4bed-a613-e22d23a72a3a'
INICIO = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())

env = {}
for linea in open(ENV_QA, encoding='utf8'):
    m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*)=(.*)$', linea.strip())
    if m:
        env[m.group(1)] = m.group(2).strip().strip('\'"')


def url_desde_adonet(cadena):
    """Convierte 'Host=..;Port=..;Username=..;Password=..;Database=..' en una URL postgresql://."""
    if cadena.startswith(('postgres://', 'postgresql://')):
        return cadena
    partes = {}
    for trozo in cadena.split(';'):
        if '=' in trozo:
            k, v = trozo.split('=', 1)
            partes[k.strip().lower().replace(' ', '')] = v.strip()
    usuario = partes.get('username') or partes.get('userid') or partes.get('user') or partes.get('uid')
    clave = partes.get('password') or partes.get('pwd') or ''
    host = partes.get('host') or partes.get('server')
    puerto = partes.get('port', '5432')
    base = partes.get('database', 'postgres')
    ssl = (partes.get('sslmode') or 'require').lower()
    return (f'postgresql://{urllib.parse.quote(usuario, safe="")}:{urllib.parse.quote(clave, safe="")}'
            f'@{host}:{puerto}/{base}?sslmode={ssl}')


def forma(url):
    """Solo usuario (sin el sufijo del proyecto), host y puerto. Nunca la clave."""
    p = urllib.parse.urlsplit(url)
    usuario = urllib.parse.unquote(p.username or '?').split('.')[0]
    return f'usuario={usuario}.<ref> host={p.hostname} puerto={p.port}'


URL = {
    'core': env['DATABASE_URL'],
    'dispatch': url_desde_adonet(env['DISPATCH_DB_CONNECTION']),
    'admin': env.get('DATABASE_URL_ADMIN'),
}
sb = env['SUPABASE_URL'].rstrip('/')
anon = next(env[n] for n in ('SUPABASE_ANON_KEY', 'SUPABASE_KEY', 'ANON_KEY', 'SUPABASE_PUBLISHABLE_KEY') if env.get(n))


def oculta(texto):
    texto = re.sub(r'postgres(ql)?://\S+', '<url>', texto)
    texto = re.sub(r'(?i)(password=)[^; ]+', r'\1<oculto>', texto)
    return re.sub(r'eyJ[\w-]+\.[\w-]+\.[\w-]+', '<token>', texto)


def psql(conexion, archivo=None, guion=None, variables=None):
    # La URL viaja por la variable de entorno PGURL y se expande dentro del contenedor: no aparece en `ps`.
    args = ['docker', 'run', '--rm', '-i', '--network', 'host', '-e', 'PGURL', 'postgres:15',
            'sh', '-c', 'exec psql "$@" "$PGURL"', 'sh', '-X', '-A', '-t', '-F', ' | ']
    for k, v in (variables or {}).items():
        args += ['-v', f'{k}={v}']
    entrada = guion if guion is not None else open(os.path.join(T41_DIR, archivo), encoding='utf8').read()
    r = subprocess.run(args, input=entrada, capture_output=True, text=True, timeout=300,
                       env={**os.environ, 'PGURL': URL[conexion]})
    return oculta(r.stdout + r.stderr)


def http(metodo, ruta, cuerpo=None, token=None, extra=None):
    datos = json.dumps(cuerpo).encode() if cuerpo is not None else None
    cab = {'Content-Type': 'application/json', **(extra or {})}
    cab.setdefault('X-Correlation-ID', f't41-{uuid.uuid4().hex[:10]}')
    if token:
        cab['Authorization'] = f'Bearer {token}'
    req = urllib.request.Request(ruta if ruta.startswith('http') else GW + ruta, data=datos, method=metodo, headers=cab)
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            codigo, texto = r.status, r.read().decode()
    except urllib.error.HTTPError as e:
        codigo, texto = e.code, e.read().decode(errors='replace')
    except Exception as e:
        return 0, {'_error': str(e)[:120]}, cab['X-Correlation-ID']
    try:
        return codigo, (json.loads(texto) if texto else {}), cab['X-Correlation-ID']
    except ValueError:
        return codigo, {'_texto': texto[:100]}, cab['X-Correlation-ID']


def cod(r):
    e = r.get('error')
    return (e.get('code') if isinstance(e, dict) else None) or r.get('code') or ''


def chequeo(escenario, caso, esperado, obtenido, ok, cid=''):
    print(f"{'PASA ' if ok else 'FALLA'} | {escenario} | {caso} | esperado {esperado} | obtenido {obtenido} | cid={cid}")


print(f'== SCRUM-1678 T-41 en MANI-QA ({time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())})')
print('\n== Conexiones (solo forma)')
for nombre in ('core', 'dispatch', 'admin'):
    print(f'  {nombre}: {forma(URL[nombre]) if URL[nombre] else "sin URL"}')

print('\n== Revisiones desplegadas')
for s in ('mani-api-gateway', 'mani-core-service', 'mani-dispatch-service', 'mani-rules-service'):
    r = subprocess.run(['docker', 'inspect', '-f', '{{index .Config.Labels "org.opencontainers.image.revision"}}', s],
                       capture_output=True, text=True)
    print(f'  {s} rev={r.stdout.strip()[:7] or "?"}')

print('\n== Precondicion: db/verify/0037_verificar_sin_bypassrls.sql (URL admin, solo lectura)')
if URL['admin']:
    print(psql('admin', '0037_verificar_sin_bypassrls.sql', variables={'ON_ERROR_STOP': '1'}))
else:
    print('  REVISAR: no hay DATABASE_URL_ADMIN; precondicion sin verificar')
for fila in psql('admin', guion="SELECT 'migraciones: ' || string_agg(version, ',' ORDER BY version) FROM schema_migrations WHERE version IN ('0037','0038','0039','0044','0045','0046');\n").splitlines():
    print(f'  {fila}')

print('\n== Sesiones de las cuentas del seed')
tk = {}
for nombre in ('cliente.t1', 'aliado.t1', 'admin.t1', 'cliente.t2', 'aliado.t2', 'admin.t2'):
    c, r, _ = http('POST', f'{sb}/auth/v1/token?grant_type=password',
                   {'email': f'{nombre}@qa.mani.test', 'password': os.environ['CLAVE_CFG04']}, extra={'apikey': anon})
    tk[nombre] = r.get('access_token') if c == 200 else None
    print(f'  {nombre}: {"ok" if tk[nombre] else f"sin sesion ({c})"}')
if not all(tk.values()):
    raise SystemExit('ABORTA: faltan sesiones')
C1, AL1, C2, AL2, A2 = (tk[k] for k in ('cliente.t1', 'aliado.t1', 'cliente.t2', 'aliado.t2', 'admin.t2'))


def crear(t, token):
    c, r, cid = http('POST', f'{CORE}/solicitudes', {'categoriaId': CATEGORIA[t], 'sitioId': SITIO[t],
                     'descripcion': f'SCRUM-1678 T-41 tenant {t}', 'claveIdempotencia': str(uuid.uuid4())}, token)
    sid = (r.get('solicitud') or {}).get('id') or r.get('id')
    chequeo('preparacion', f'crear solicitud de T{t}', '201', f'{c} {cod(r)}', c == 201 and bool(sid), cid)
    return sid


S1, S2 = crear(1, C1), crear(2, C2)
if not (S1 and S2):
    raise SystemExit('ABORTA: no se pudieron crear las solicitudes de prueba')


def estado(sid):
    fila = psql('admin', guion=f"BEGIN READ ONLY;\nSELECT estado FROM solicitud WHERE id = '{sid}';\nROLLBACK;\n").splitlines()
    fila = [l for l in fila if l not in ('BEGIN', 'ROLLBACK', '')]
    return fila[0] if fila else 'SIN_LECTURA'


print('\n== QAS-01 por el Gateway (los seis casos de Politicas DevOps 13.4, mismos que el 5-nov)')
antes = estado(S1)
c, r, cid1 = http('GET', f'{CORE}/solicitudes/me/{S1}', token=C2)
chequeo('QAS-01', 'caso 1 lectura de otro tenant', '403/404', f'{c} {cod(r)}', c in (403, 404), cid1)
c, r, cid = http('GET', f'{CORE}/solicitudes/me', token=C2)
chequeo('QAS-01', 'caso 2 listado sin recursos ajenos', 'sin la solicitud de T1', f'{c} fuga={S1 in json.dumps(r)}', c == 200 and S1 not in json.dumps(r), cid)
c, r, cid = http('POST', f'{CORE}/solicitudes/{S1}/cotizaciones', {'valorManoObra': 1000, 'valorMateriales': 0, 'total': 1000}, AL2)
chequeo('QAS-01', 'caso 3 escritura en otro tenant', '403/404', f'{c} {cod(r)}', c in (403, 404), cid)
c, r, cid = http('PATCH', f'{CORE}/solicitudes/me/{S1}/cancelar', {'motivo': 'T-41 cross-tenant'}, C2)
chequeo('QAS-01', 'caso 4 borrado o cancelacion ajena', '403/404', f'{c} {cod(r)}', c in (403, 404), cid)
c, r, cid = http('GET', f'{CORE}/solicitudes/me/{S1}', token='a.b.c')
chequeo('QAS-01', 'caso 5 token alterado', '401', c, c == 401, cid)
c, r, cid = http('GET', f'{CORE}/aliados/{ALIADO_T1}/verificacion', token=A2)
chequeo('QAS-01', 'caso 6 verificacion KYC de otro tenant', '403/404', f'{c} {cod(r)}', c in (403, 404), cid)
despues = estado(S1)
chequeo('QAS-01', 'la solicitud de T1 no cambio', antes, despues, despues == antes)

print('\n== QAS-01 P4 rol en la aceptacion (por el Gateway)')
c, r, cid = http('POST', f'{DISPATCH}/requests/{S1}/accept', None, C1, {'Idempotency-Key': str(uuid.uuid4())})
chequeo('QAS-01', 'P4 un cliente no acepta', '403', f'{c} {cod(r)}', c == 403, cid)
c, r, cid = http('POST', f'{DISPATCH}/requests/{S2}/accept', None, AL1, {'Idempotency-Key': str(uuid.uuid4())})
chequeo('QAS-01', 'P4 aliado de T1 no acepta solicitud de T2', '403/404', f'{c} {cod(r)}', c in (403, 404), cid)
chequeo('QAS-01', 'P4 la solicitud de T2 sigue sin asignar', 'sin cambio', estado(S2), estado(S2) not in ('ASIGNADA', 'ACEPTADA'))

variables = {'t1': T1, 't2': T2, 'u_admin_t1': U_ADMIN_T1, 'u_aliado_t1': U_ALIADO_T1, 'sitio_t1': SITIO[1],
             'sitio_t2': SITIO[2], 'aliado_t1': ALIADO_T1, 'sol_t1': S1, 'sol_t2': S2, 'cid': cid1}

time.sleep(5)
print('\n== QAS-01 en el motor como mani_core_svc')
print(psql('core', 'qas01_motor.sql', variables=variables))

time.sleep(5)
print('\n== QAS-20 en el motor como mani_dispatch_svc')
print(psql('dispatch', 'qas20_frontera.sql', variables=variables))


print('\n== QAS-20 funcional: bandeja y rechazo de Dispatch con sesion, sin permisos sobre tablas de Core (0046)')
c, r, cid = http('GET', f'{CORE}/solicitudes/categorias', token=C1)
lista = r if isinstance(r, list) else next((v for v in r.values() if isinstance(v, list)), [])
plomeria = next((x['id'] for x in lista if 'plomer' in str(x.get('nombre') or x.get('name') or '').lower()), None)
c, r, cid = http('POST', f'{CORE}/solicitudes', {'categoriaId': plomeria, 'sitioId': SITIO_PRUEBA, 'claveIdempotencia': str(uuid.uuid4()),
                 'descripcion': 'Prueba QA QAS-20, no atender.'}, C1)
S3 = (r.get('solicitud') or {}).get('id') or r.get('id')
chequeo('QAS-20', 'crear solicitud de plomeria', '201', f'{c} {cod(r)}', c in (200, 201) and bool(S3), cid)
if S3:
    def en_bandeja():
        c, r, cid = http('GET', f'{DISPATCH}/offers/me', token=AL1)
        return c, S3 in json.dumps(r), cod(r), cid
    c, r, cid = http('POST', f'{DISPATCH}/requests/orchestrate', {'requestId': S3}, C1, {'Idempotency-Key': str(uuid.uuid4())})
    chequeo('QAS-20', 'orquestar las ofertas', '200', f'{c} {cod(r)}', c in (200, 201, 202), cid)
    c, esta, k, cid = en_bandeja()
    chequeo('QAS-20', 'la bandeja del aliado trae la oferta', '200 y la oferta', f'{c} {k} oferta={esta}', c == 200 and esta, cid)
    c, r, cid = http('GET', f'{DISPATCH}/assignments/me', token=AL1)
    chequeo('QAS-20', 'asignaciones del aliado', '200', f'{c} {cod(r)}', c == 200, cid)
    c, r, cid = http('POST', f'{DISPATCH}/requests/{S3}/reject', {'motivo': 'SIN_DISPONIBILIDAD'}, AL1)
    chequeo('QAS-20', 'rechazar la oferta', '200 isRetry=False', f"{c} {cod(r)} isRetry={r.get('isRetry')}", c == 200 and r.get('isRetry') is False, cid)
    c, r, cid = http('POST', f'{DISPATCH}/requests/{S3}/reject', {'motivo': 'SIN_DISPONIBILIDAD'}, AL1)
    chequeo('QAS-20', 'repetir el rechazo no duplica', '200 isRetry=True', f"{c} {cod(r)} isRetry={r.get('isRetry')}", c == 200 and r.get('isRetry') is True, cid)
    c, esta, k, cid = en_bandeja()
    chequeo('QAS-20', 'la bandeja ya no trae la rechazada', '200 sin la oferta', f'{c} {k} oferta={esta}', c == 200 and not esta, cid)
    c, r, cid = http('POST', f'{DISPATCH}/requests/{S3}/accept', None, AL1, {'Idempotency-Key': str(uuid.uuid4())})
    chequeo('QAS-20', 'aceptar lo rechazado', '409', f'{c} {cod(r)}', c == 409, cid)
    p = subprocess.run(['docker', 'logs', '--since', INICIO, 'mani-dispatch-service'], capture_output=True, text=True, errors='replace')
    n = (p.stdout + p.stderr).count('permission denied')
    chequeo('QAS-20', 'logs de Dispatch sin permission denied en la corrida', 0, n, n == 0)

print('\n== Limpieza: cancelar las solicitudes de prueba')
for sid, token in ((S1, C1), (S2, C2), (S3, C1)):
    if not sid:
        continue
    c, r, cid = http('PATCH', f'{CORE}/solicitudes/me/{sid}/cancelar', {'motivo': 'SCRUM-1678 fin de prueba'}, token)
    print(f'  {sid}: {c} {cod(r)} estado={estado(sid)}')
print(f'\n== Fin ({time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())})')

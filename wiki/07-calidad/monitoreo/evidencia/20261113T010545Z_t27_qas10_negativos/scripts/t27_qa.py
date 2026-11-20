"""SCRUM-1664 (T-27). Negativos de las operaciones criticas en MANI-QA (QAS-10 Integridad).

Corre en la VM de QA; lo lanza qa_t27/correr_t27_qa.sh junto con generar_coleccion_t27.py.
  1. Prepara datos con la API: una solicitud PENDIENTE, una CANCELADA y una con cotizacion aceptada y pagada.
     Lee el estado KYC de aliado.t1 y la tarifa activa de plomeria de T1 (si falta una version reemplazada, edita la
     activa con los mismos valores para tenerla).
  2. Toma una huella (md5 de las filas) de todo lo que los negativos podrian tocar.
  3. Corre la coleccion Newman (postman/newman:6-alpine): cada caso comprueba el HTTP y el codigo MANI del cuerpo.
  4. Vuelve a tomar la huella y la compara: el estado persistido no debe cambiar.
  5. Comprueba en el motor, con mani_core_svc y en ROLLBACK, las restricciones que respaldan cada operacion.
  6. Cancela la solicitud PENDIENTE.
No imprime claves, tokens ni valores de /opt/mani/.env.qa. Las URL de la base viajan por variable de entorno.
"""
import base64
import json
import os
import re
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request
import uuid

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from generar_coleccion_t27 import CASOS, coleccion  # noqa: E402

ENV_QA = os.environ.get('ENV_QA', '/opt/mani/.env.qa')
GW = 'http://localhost'
CORE = '/api/v1/core'
T1 = '10000000-0000-4000-8000-000000000011'
U_ADMIN_T1 = '30000000-0000-4000-8000-000000000011'
PLOMERIA_T1, SITIO_T1, ALIADO_T1 = '60000000-0000-4000-8000-000000000011', '70000000-0000-4000-8000-000000000011', '50000000-0000-4000-8000-000000000011'
CORRIDA = uuid.uuid4().hex[:8]

env = {}
for linea in open(ENV_QA, encoding='utf8'):
    m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*)=(.*)$', linea.strip())
    if m:
        env[m.group(1)] = m.group(2).strip().strip('\'"')
sb = env['SUPABASE_URL'].rstrip('/')
anon = next(env[n] for n in ('SUPABASE_ANON_KEY', 'SUPABASE_KEY', 'ANON_KEY', 'SUPABASE_PUBLISHABLE_KEY') if env.get(n))
URL = {'admin': env.get('DATABASE_URL_ADMIN'), 'core': env.get('DATABASE_URL')}
resultados = []


def http(metodo, ruta, cuerpo=None, token=None, extra=None):
    datos = json.dumps(cuerpo).encode() if cuerpo is not None else None
    cab = {'Content-Type': 'application/json', **(extra or {})}
    cab.setdefault('X-Correlation-ID', f't27-{CORRIDA}-{uuid.uuid4().hex[:6]}')
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
    e = r.get('error') if isinstance(r, dict) else None
    return ((e.get('code') if isinstance(e, dict) else None) or (r.get('code') if isinstance(r, dict) else None)) or ''


def psql(conexion, guion, variables=None):
    """La URL viaja por PGURL y se expande dentro del contenedor: no aparece en `ps` ni en la salida."""
    if not URL.get(conexion):
        return ['SIN_URL_' + conexion.upper()]
    args = ['docker', 'run', '--rm', '-i', '--network', 'host', '-e', 'PGURL', 'postgres:15',
            'sh', '-c', 'exec psql "$@" "$PGURL" 2>&1', 'sh', '-X', '-A', '-t', '-F', ' | ']
    for k, v in (variables or {}).items():
        args += ['-v', f'{k}={v}']
    r = subprocess.run(args, input=guion, capture_output=True, text=True, timeout=180,
                       env={**os.environ, 'PGURL': URL[conexion]})
    return [l for l in (r.stdout + r.stderr).splitlines() if l.strip()]


def leer(consulta):
    return [l for l in psql('admin', f'BEGIN READ ONLY;\n{consulta};\nROLLBACK;\n') if l not in ('BEGIN', 'ROLLBACK')]


def chequeo(grupo, caso, esperado, obtenido, ok, cid=''):
    resultados.append(ok)
    marca = 'PASA ' if ok is True else ('FALLA' if ok is False else 'REVISAR')
    print(f'{marca} | {grupo} | {caso} | esperado {esperado} | obtenido {obtenido} | cid={cid}')


print(f'== SCRUM-1664 T-27 negativos de operaciones criticas en MANI-QA ({time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}) corrida={CORRIDA}')
print('\n== Revisiones desplegadas')
for cont in ('mani-api-gateway', 'mani-core-service', 'mani-dispatch-service', 'mani-rules-service'):
    r = subprocess.run(['docker', 'inspect', '-f', '{{index .Config.Labels "org.opencontainers.image.revision"}}', cont],
                       capture_output=True, text=True)
    print(f'  {cont} rev={r.stdout.strip()[:7] or "?"}')

tk = {}
for nombre in ('cliente.t1', 'aliado.t1', 'admin.t1', 'cliente.t2', 'aliado.t2', 'admin.t2'):
    c, rr, _ = http('POST', f'{sb}/auth/v1/token?grant_type=password',
                    {'email': f'{nombre}@qa.mani.test', 'password': os.environ['CLAVE_CFG04']}, extra={'apikey': anon})
    tk[nombre.replace('.', '_')] = rr.get('access_token') if c == 200 else None
if not all(tk.values()):
    raise SystemExit('ABORTA: faltan sesiones ' + ','.join(k for k, v in tk.items() if not v))
print('  6 sesiones (cliente, aliado y admin de T1 y T2): ok')
C1, AL1, A1 = tk['cliente_t1'], tk['aliado_t1'], tk['admin_t1']

# ---------------------------------------------------------------- 1. datos de prueba
print('\n== 1. Datos de prueba (operaciones positivas, antes de la huella)')


def crear(desc, clave):
    c, rr, cid = http('POST', f'{CORE}/solicitudes', {'categoriaId': PLOMERIA_T1, 'sitioId': SITIO_T1,
                     'descripcion': desc, 'claveIdempotencia': clave}, C1)
    sid = (rr.get('solicitud') or {}).get('id') or rr.get('id')
    if c != 201 or not sid:
        raise SystemExit(f'ABORTA: no se creo la solicitud "{desc}": {c} {cod(rr)}')
    return sid


desc_pend, clave_pend = f'SCRUM-1664 T-27 {CORRIDA} solicitud pendiente', str(uuid.uuid4())
s_pend = crear(desc_pend, clave_pend)
s_cancel = crear(f'SCRUM-1664 T-27 {CORRIDA} solicitud cancelada', str(uuid.uuid4()))
c, rr, _ = http('PATCH', f'{CORE}/solicitudes/me/{s_cancel}/cancelar', {'motivo': 'SCRUM-1664 T-27 dato de prueba'}, C1)
print(f'  s_pend={s_pend} (PENDIENTE); s_cancel={s_cancel} cancelar={c} {cod(rr)}')

s_full = crear(f'SCRUM-1664 T-27 {CORRIDA} solicitud con pago', str(uuid.uuid4()))
http('POST', '/api/v1/dispatch/requests/orchestrate', {'requestId': s_full}, C1)
ca = 0
for _ in range(5):
    ca, _, _ = http('POST', f'/api/v1/dispatch/requests/{s_full}/accept', None, AL1, {'Idempotency-Key': str(uuid.uuid4())})
    if ca != 503:
        break
    time.sleep(3)
time.sleep(1)
cq, rr, _ = http('POST', f'{CORE}/solicitudes/{s_full}/cotizaciones', {'valorManoObra': 100000, 'valorMateriales': 0, 'total': 100000}, AL1)
cot = (rr.get('cotizacion') or {}).get('id')
cc, _, _ = http('POST', f'{CORE}/cotizaciones/{cot}/aceptar', {}, C1)
clave_pago = str(uuid.uuid4())
cp, rr, _ = http('POST', f'{CORE}/pagos', {'cotizacionId': cot, 'claveIdempotencia': clave_pago}, C1)
pago_id = (rr.get('pago') or {}).get('id')
print(f'  s_full={s_full}: aceptar={ca} cotizacion={cq} aceptar_cot={cc} pagar={cp} pago={pago_id}')
if not (cot and pago_id and cc == 200 and cp in (200, 201)):
    raise SystemExit('ABORTA: no quedo lista la solicitud con cotizacion aceptada y pagada')

f = leer(f"SELECT row_to_json(a)::text FROM aliado a WHERE id = '{ALIADO_T1}'")
fila_aliado = json.loads(f[0]) if f and f[0].startswith('{') else {}
estado_kyc = next((str(v) for k, v in fila_aliado.items() if 'verific' in k and isinstance(v, str)), '?')
aliado_resuelto = estado_kyc.upper() in ('VERIFICADO', 'APROBADO', 'RECHAZADO', 'VERIFIED', 'REJECTED')
print(f'  aliado.t1 estado KYC={estado_kyc} (resuelto={aliado_resuelto})')


def tarifas():
    filas = leer(f"SELECT id, estado, coalesce(vigencia_hasta::text, '-'), valor_min, valor_tipico, valor_max, version "
                 f"FROM tarifa_referencia WHERE tenant_id = '{T1}' AND categoria_id = '{PLOMERIA_T1}' ORDER BY version")
    return [l.split(' | ') for l in filas if l.count(' | ') == 6]


tt = tarifas()
if not any(t[1] == 'ACTIVA' for t in tt):
    c, rr, _ = http('POST', f'{CORE}/tarifas', {'categoriaId': PLOMERIA_T1, 'valorMin': 80000, 'valorTipico': 100000, 'valorMax': 150000,
                    'condiciones': 'SCRUM-1664 T-27'}, A1)
    print(f'  no habia tarifa activa de plomeria T1; se creo: {c} {cod(rr)}')
    tt = tarifas()
activa = next((t for t in tt if t[1] == 'ACTIVA'), None)
if activa and not any(t[1] == 'REEMPLAZADA' for t in tt):
    c, rr, _ = http('PUT', f'{CORE}/tarifas/{activa[0]}', {'categoriaId': PLOMERIA_T1, 'valorMin': float(activa[3]),
                    'valorTipico': float(activa[4]), 'valorMax': float(activa[5])}, A1)
    print(f'  no habia version reemplazada; se edito la activa con los mismos valores: {c} {cod(rr)}')
    tt = tarifas()
    activa = next((t for t in tt if t[1] == 'ACTIVA'), None)
if not activa:
    raise SystemExit('ABORTA: no hay tarifa activa de plomeria en T1')
vieja = next((t for t in tt if t[1] == 'REEMPLAZADA'), None)
tarifa_abierta = activa[2] == '-' or activa[2] >= time.strftime('%Y-%m-%d')
print(f'  tarifa activa={activa[0]} v{activa[6]} ({activa[3]}/{activa[4]}/{activa[5]}, hasta {activa[2]}); '
      f'reemplazada={vieja[0] if vieja else "-"}; {len(tt)} versiones')

# ---------------------------------------------------------------- 2. huella antes
HUELLA = {
    'crear_solicitud': "SELECT count(*) || ' solicitudes de T1 creadas desde la huella; ' || "
                       f"(SELECT count(*) FROM solicitud x WHERE x.descripcion LIKE 'SCRUM-1664 T-27 {CORRIDA}%') || ' de esta corrida' "
                       f"FROM solicitud s WHERE s.tenant_id = '{T1}' AND s.created_at > '{{t0}}'",
    'aceptar_solicitud': f"SELECT md5(string_agg(s::text, ',' ORDER BY s.id)) || ' rechazos=' || "
                         f"(SELECT count(*) FROM solicitud_rechazo r WHERE r.solicitud_id IN ('{s_pend}', '{s_cancel}', '{s_full}')) "
                         f"FROM solicitud s WHERE s.id IN ('{s_pend}', '{s_cancel}', '{s_full}')",
    'aceptar_cotizacion': f"SELECT estado || ' ' || md5(c::text) FROM cotizacion c WHERE c.id = '{cot}'",
    'cancelar_solicitud': f"SELECT string_agg(s.estado, ',' ORDER BY s.id) || ' ' || md5(string_agg(s::text, ',' ORDER BY s.id)) "
                          f"FROM solicitud s WHERE s.id IN ('{s_pend}', '{s_cancel}', '{s_full}')",
    'pagar': f"SELECT count(*) || ' pagos ' || md5(coalesce(string_agg(p::text, ',' ORDER BY p.id), '')) || ' retencion ' || "
             f"(SELECT md5(coalesce(string_agg(r::text, ','), '')) FROM retencion_fondos r JOIN pago q ON q.id = r.pago_id "
             f"WHERE q.cotizacion_id = '{cot}') FROM pago p WHERE p.cotizacion_id = '{cot}'",
    'aprobar_aliado': f"SELECT md5(a::text) FROM aliado a WHERE a.id = '{ALIADO_T1}'",
    'cambiar_tarifa': f"SELECT count(*) || ' versiones ' || md5(string_agg(t::text, ',' ORDER BY t.id)) FROM tarifa_referencia t "
                      f"WHERE t.tenant_id = '{T1}' AND t.categoria_id = '{PLOMERIA_T1}'",
}


def huella():
    return {op: (leer(q.replace('{t0}', t0)) or ['SIN_LECTURA'])[0] for op, q in HUELLA.items()}


time.sleep(5)  # deja asentar avisos y eventos de los positivos antes de medir
t0 = (leer('SELECT now()') or ['now'])[0]
antes = huella()
print('\n== 2. Huella antes de los negativos')
for op, v in antes.items():
    print(f'  {op}: {v}')

# ---------------------------------------------------------------- 3. Newman
print('\n== 3. Coleccion Newman')
omitir = [g for g, ok in (('aliado_resuelto', aliado_resuelto), ('tarifa_abierta', tarifa_abierta), ('tarifa_vieja', bool(vieja))) if not ok]
col = coleccion(omitir)
n_casos = sum(len(c['item']) for c in col['item'])
print(f'  {n_casos} casos; omitidos por el estado de los datos: {", ".join(omitir) or "ninguno"}')
for g in omitir:
    for caso in CASOS:
        if caso[10] == g:
            chequeo(caso[0], caso[1], 'caso aplicable', f'omitido ({g} no se cumple)', None)

valores = {'gw': GW, 'corrida': CORRIDA, 's_pend': s_pend, 's_cancel': s_cancel, 's_full': s_full, 'cot': cot, 'aliado': ALIADO_T1,
           'desc_s_pend': desc_pend, 'clave_s_pend': clave_pend, 'clave_pago': clave_pago,
           'tarifa': activa[0], 'tarifa_vieja': vieja[0] if vieja else '', 't_min': activa[3], 't_tip': activa[4], 't_max': activa[5]}
valores.update({f'tk_{k}': v for k, v in tk.items()})
valores.update({f'clave_nueva_{i}': str(uuid.uuid4()) for i in range(1, 12)})

d = tempfile.mkdtemp(prefix='t27_', dir=os.environ.get('T27_DIR') or None)
os.chmod(d, 0o777)  # el contenedor de Newman escribe el reporte
json.dump(col, open(os.path.join(d, 'coleccion.json'), 'w', encoding='utf8'), ensure_ascii=False)
json.dump({'name': 't27', 'values': [{'key': k, 'value': v, 'enabled': True} for k, v in valores.items()]},
          open(os.path.join(d, 'entorno.json'), 'w', encoding='utf8'))
r = subprocess.run(['docker', 'run', '--rm', '--network', 'host', '-v', f'{d}:/etc/newman', 'postman/newman:6-alpine',
                    'run', 'coleccion.json', '-e', 'entorno.json', '--reporters', 'cli,json',
                    '--reporter-json-export', 'reporte.json', '--color', 'off', '--timeout-request', '30000',
                    '--reporter-cli-no-console'], capture_output=True, text=True, timeout=600)
salida_newman = r.stdout + r.stderr
for v in tk.values():
    salida_newman = salida_newman.replace(v, '<token>')
print(salida_newman)

reporte = {}
try:
    reporte = json.load(open(os.path.join(d, 'reporte.json'), encoding='utf8'))
except Exception as e:
    print(f'  no se pudo leer el reporte de Newman: {e}')
for archivo in ('entorno.json', 'reporte.json'):  # el entorno y el reporte llevan los tokens
    try:
        os.remove(os.path.join(d, archivo))
    except OSError as e:
        print(f'  REVISAR: no se pudo borrar {archivo}: {e}')

print('== 3b. Resultado por caso (HTTP y codigo MANI)')
cuerpos = {}
for ej in (reporte.get('run') or {}).get('executions', []):
    nombre = ej.get('item', {}).get('name', '?')
    cid, op, tipo = (nombre.split(' | ') + ['?', '?'])[:3]
    resp = ej.get('response') or {}
    try:
        cuerpo = json.loads(bytes(resp.get('stream', {}).get('data', [])).decode() or '{}')
    except Exception:
        cuerpo = {}
    cuerpos[cid] = cuerpo
    fallas = [a.get('assertion') for a in ej.get('assertions', []) if a.get('error')]
    caso = next(c for c in CASOS if c[1] == cid)
    chequeo(op, f'{cid} ({tipo})', f'http {"/".join(map(str, caso[8]))} codigo {caso[9] or "-"}',
            f'http {resp.get("code")} codigo {cod(cuerpo) or "-"}', not fallas and bool(ej.get('assertions')),
            f't27-{CORRIDA}-{cid}')

if 'C-DUP' in cuerpos:
    sid = (cuerpos['C-DUP'].get('solicitud') or {}).get('id') or cuerpos['C-DUP'].get('id')
    chequeo('crear_solicitud', 'C-DUP misma solicitud', s_pend, sid, sid == s_pend, f't27-{CORRIDA}-C-DUP')
if 'P-DUP' in cuerpos:
    pid = (cuerpos['P-DUP'].get('pago') or {}).get('id')
    chequeo('pagar', 'P-DUP mismo pago', pago_id, pid, pid == pago_id, f't27-{CORRIDA}-P-DUP')

# ---------------------------------------------------------------- 4. huella despues
time.sleep(3)
despues = huella()
print('\n== 4. Estado persistido despues de los negativos')
for op in HUELLA:
    chequeo(op, 'estado sin cambios', antes[op], despues[op], antes[op] == despues[op] and 'SIN_' not in antes[op])

# ---------------------------------------------------------------- 5. restricciones en el motor
print('\n== 5. Restricciones del motor (mani_core_svc, contexto admin de T1, todo en ROLLBACK)')
GUION = r"""
\set ON_ERROR_ROLLBACK on
\set VERBOSITY verbose
BEGIN;
SELECT app.set_context(:'t1', :'u_admin', 'admin_tenant') \g /dev/null
\echo R|pago_duplicado
INSERT INTO pago SELECT (jsonb_populate_record(NULL::pago, to_jsonb(p) || jsonb_build_object('id', gen_random_uuid()))).* FROM pago p WHERE p.id = :'pago';
\echo R|retencion_duplicada
INSERT INTO retencion_fondos SELECT (jsonb_populate_record(NULL::retencion_fondos, to_jsonb(r) || jsonb_build_object('id', gen_random_uuid()))).* FROM retencion_fondos r WHERE r.pago_id = :'pago';
\echo R|tarifa_activa_solapada
INSERT INTO tarifa_referencia SELECT (jsonb_populate_record(NULL::tarifa_referencia, to_jsonb(t) || jsonb_build_object('id', gen_random_uuid(), 'version', t.version + 100))).* FROM tarifa_referencia t WHERE t.id = :'tarifa';
\echo R|tarifa_valores_invertidos
INSERT INTO tarifa_referencia SELECT (jsonb_populate_record(NULL::tarifa_referencia, to_jsonb(t) || jsonb_build_object('id', gen_random_uuid(), 'version', t.version + 200, 'estado', 'REEMPLAZADA', 'valor_min', t.valor_max + 1))).* FROM tarifa_referencia t WHERE t.id = :'tarifa';
\echo R|solicitud_estado_invalido
UPDATE solicitud SET estado = 'INVENTADO_T27' WHERE id = :'s_pend';
\echo R|cotizacion_estado_invalido
UPDATE cotizacion SET estado = 'INVENTADO_T27' WHERE id = :'cot';
\echo R|pago_estado_invalido
UPDATE pago SET estado = 'INVENTADO_T27' WHERE id = :'pago';
\echo R|fin
ROLLBACK;
"""
salida = psql('core', GUION, {'t1': T1, 'u_admin': U_ADMIN_T1, 'pago': pago_id, 'tarifa': activa[0], 's_pend': s_pend, 'cot': cot})
bloques, actual = {}, None
for l in salida:
    if l.startswith('R|'):
        actual = l[2:]
        bloques[actual] = []
    elif actual:
        bloques[actual].append(l)
ESPERA = {'pago_duplicado': ('23505',), 'retencion_duplicada': ('23505',), 'tarifa_activa_solapada': ('23P01', '23505'),
          'tarifa_valores_invertidos': ('23514',), 'solicitud_estado_invalido': ('23514', '22P02'),
          'cotizacion_estado_invalido': ('23514', '22P02'), 'pago_estado_invalido': ('23514', '22P02')}
for caso, estados in ESPERA.items():
    lineas = bloques.get(caso, [])
    err = next((l for l in lineas if l.startswith('ERROR:')), '')
    m = re.match(r'ERROR:\s+([0-9A-Z]{5}):\s*(.*)', err)
    restr = re.search(r'"([a-z0-9_]+)"', m.group(2)).group(1) if m and re.search(r'"([a-z0-9_]+)"', m.group(2)) else ''
    escrito = next((l for l in lineas if re.match(r'^(INSERT 0 [1-9]|UPDATE [1-9])', l)), '')
    if escrito:
        chequeo('motor', caso, '/'.join(estados), f'la base acepto la escritura ({escrito})', False)
    elif m:
        chequeo('motor', caso, '/'.join(estados), f'{m.group(1)} {restr or m.group(2)[:70]}'.strip(), m.group(1) in estados)
    else:
        chequeo('motor', caso, '/'.join(estados), ' '.join(lineas)[:90] or 'sin salida', None)

print('\n== 5b. Restricciones CHECK y tipo de la columna estado (catalogo, solo lectura)')
for l in leer("SELECT c.relname || ' | estado:' || coalesce((SELECT format_type(a.atttypid, a.atttypmod) FROM pg_attribute a "
              "WHERE a.attrelid = c.oid AND a.attname = 'estado'), '-') || ' | ' || coalesce((SELECT string_agg(k.conname, ', ' ORDER BY k.conname) "
              "FROM pg_constraint k WHERE k.conrelid = c.oid AND k.contype = 'c'), 'sin CHECK') FROM pg_class c "
              "WHERE c.relnamespace = 'public'::regnamespace AND c.relname IN ('solicitud', 'cotizacion', 'pago', 'retencion_fondos', "
              "'liquidacion', 'aliado', 'tarifa_referencia') ORDER BY 1"):
    print(f'  {l}')

# ---------------------------------------------------------------- 6. limpieza
print('\n== 6. Limpieza')
c, rr, _ = http('PATCH', f'{CORE}/solicitudes/me/{s_pend}/cancelar', {'motivo': 'SCRUM-1664 T-27 fin de la prueba'}, C1)
print(f'  s_pend cancelada: {c} {cod(rr)}. Quedan en QA: s_cancel y s_full ({s_full}) con pago simulado RETENIDO.')

pasa = sum(1 for x in resultados if x is True)
falla = sum(1 for x in resultados if x is False)
revisar = sum(1 for x in resultados if x is None)
print(f'\n== T-27 corrida {CORRIDA}: {pasa} PASA, {falla} FALLA, {revisar} REVISAR')

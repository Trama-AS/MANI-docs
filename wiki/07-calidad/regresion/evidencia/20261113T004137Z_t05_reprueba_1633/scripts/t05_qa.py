"""SCRUM-1642 (T-05). Re-prueba de SCRUM-1633 en MANI-QA: un pago hecho despues de finalizar libera la retencion y liquida.

Corre en la VM de QA; lo lanza qa_t05/correr_t05_qa.sh. Usa solicitudes NUEVAS: el fallo del 5-nov se midio sobre un
pago creado a las 05:42Z, antes de que existiera el commit 098bf38 (14:57Z), por eso no prueba el codigo corregido.
Caminos:
  A. solicitud FINALIZADA -> pagar -> retencion LIBERADA y liquidacion del aliado
  B. solicitud CERRADA (con ambas calificaciones) -> pagar -> retencion LIBERADA y liquidacion del aliado
  C. control: pago antes de finalizar queda RETENIDA (892 C2) y se libera al finalizar
Deja rastro en QA: 3 solicitudes de prueba de cliente.t1 con aliado.t1, con pagos simulados y 2 calificaciones.
No imprime claves, tokens ni valores de /opt/mani/.env.qa. Las lecturas de la base son READ ONLY con la URL admin.
"""
import json
import os
import re
import subprocess
import time
import urllib.error
import urllib.request
import uuid

ENV_QA = os.environ.get('ENV_QA', '/opt/mani/.env.qa')
GW = 'http://localhost'
CORE = '/api/v1/core'
PLOMERIA_T1, SITIO_T1, ALIADO_T1 = '60000000-0000-4000-8000-000000000011', '70000000-0000-4000-8000-000000000011', '50000000-0000-4000-8000-000000000011'
PAGO_ANTIGUO = '087f7259-f43f-4d8e-a28d-f0fda5b4abdc'  # pago del fallo del 5-nov (05:42Z), anterior al commit 098bf38

env = {}
for linea in open(ENV_QA, encoding='utf8'):
    m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*)=(.*)$', linea.strip())
    if m:
        env[m.group(1)] = m.group(2).strip().strip('\'"')
sb = env['SUPABASE_URL'].rstrip('/')
anon = next(env[n] for n in ('SUPABASE_ANON_KEY', 'SUPABASE_KEY', 'ANON_KEY', 'SUPABASE_PUBLISHABLE_KEY') if env.get(n))
db_admin = env.get('DATABASE_URL_ADMIN')
resultados = []


def http(metodo, ruta, cuerpo=None, token=None, extra=None):
    datos = json.dumps(cuerpo).encode() if cuerpo is not None else None
    cab = {'Content-Type': 'application/json', **(extra or {})}
    cab.setdefault('X-Correlation-ID', f't05-{uuid.uuid4().hex[:10]}')
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


def leer(consulta):
    """Lectura READ ONLY con la URL admin; la URL viaja por variable de entorno y no aparece en `ps`."""
    if not db_admin:
        return ['SIN_URL_ADMIN']
    r = subprocess.run(['docker', 'run', '--rm', '-i', '--network', 'host', '-e', 'PGURL', 'postgres:15',
                        'sh', '-c', 'exec psql -X -A -t -F " | " "$PGURL"'],
                       input=f'BEGIN READ ONLY;\n{consulta};\nROLLBACK;\n', capture_output=True, text=True, timeout=120,
                       env={**os.environ, 'PGURL': db_admin})
    return [l for l in (r.stdout + r.stderr).splitlines() if l not in ('BEGIN', 'ROLLBACK', '')]


def chequeo(camino, caso, esperado, obtenido, ok, cid=''):
    resultados.append(ok)
    print(f"{'PASA ' if ok else 'FALLA'} | {camino} | {caso} | esperado {esperado} | obtenido {obtenido} | cid={cid}")


print(f'== SCRUM-1642 T-05 re-prueba de SCRUM-1633 en MANI-QA ({time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())})')
print('\n== Revision de Core desplegada (debe contener 098bf38)')
r = subprocess.run(['docker', 'inspect', '-f', '{{index .Config.Labels "org.opencontainers.image.revision"}}', 'mani-core-service'],
                   capture_output=True, text=True)
print(f'  mani-core-service rev={r.stdout.strip()[:7] or "?"}')

tk = {}
for nombre in ('cliente.t1', 'aliado.t1', 'admin.t1', 'cliente.t2'):
    c, rr, _ = http('POST', f'{sb}/auth/v1/token?grant_type=password',
                    {'email': f'{nombre}@qa.mani.test', 'password': os.environ['CLAVE_CFG04']}, extra={'apikey': anon})
    tk[nombre] = rr.get('access_token') if c == 200 else None
if not all(tk.values()):
    raise SystemExit('ABORTA: faltan sesiones ' + ','.join(k for k, v in tk.items() if not v))
C1, AL1, A1, C2 = (tk[k] for k in ('cliente.t1', 'aliado.t1', 'admin.t1', 'cliente.t2'))
print('  sesiones de cliente.t1, aliado.t1, admin.t1 y cliente.t2: ok')

c, com, _ = http('GET', f'{CORE}/pagos/comision', token=A1)
porcentaje = None
for k in ('porcentaje', 'comision'):
    v = com.get(k) if isinstance(com, dict) else None
    if isinstance(v, dict):
        v = v.get('porcentaje')
    if isinstance(v, (int, float)):
        porcentaje = v
print(f'  comision vigente de T1: {c} porcentaje={porcentaje}')


def solicitud_lista(etiqueta, total=100000):
    """Solicitud de cliente.t1 aceptada por aliado.t1, con cotizacion aceptada, iniciada y finalizada. Sin pago."""
    c, rr, cid = http('POST', f'{CORE}/solicitudes', {'categoriaId': PLOMERIA_T1, 'sitioId': SITIO_T1,
                     'descripcion': f'SCRUM-1642 T-05: {etiqueta}', 'claveIdempotencia': str(uuid.uuid4())}, C1)
    sid = (rr.get('solicitud') or {}).get('id') or rr.get('id')
    if c != 201 or not sid:
        raise SystemExit(f'ABORTA: no se creo la solicitud {etiqueta}: {c} {cod(rr)}')
    http('POST', '/api/v1/dispatch/requests/orchestrate', {'requestId': sid}, C1)
    ca = 0
    for _ in range(5):
        ca, _, _ = http('POST', f'/api/v1/dispatch/requests/{sid}/accept', None, AL1, {'Idempotency-Key': str(uuid.uuid4())})
        if ca != 503:
            break
        time.sleep(3)
    time.sleep(1)
    _, rr, _ = http('POST', f'{CORE}/solicitudes/{sid}/cotizaciones', {'valorManoObra': total, 'valorMateriales': 0, 'total': total}, AL1)
    cot = (rr.get('cotizacion') or {}).get('id')
    cc, _, _ = http('POST', f'{CORE}/cotizaciones/{cot}/aceptar', {}, C1)
    return sid, cot, ca, cc


def estado(sid):
    f = leer(f"SELECT estado FROM solicitud WHERE id = '{sid}'")
    return f[0] if f else 'SIN_LECTURA'


def pagar(cot, clave=None):
    return http('POST', f'{CORE}/pagos', {'cotizacionId': cot, 'claveIdempotencia': clave or str(uuid.uuid4())}, C1)


def retencion(pago, token=None):
    c, rr, cid = http('GET', f'{CORE}/pagos/{pago}/retencion', token=token or C1)
    return c, (rr.get('retencion') or {}), cid


def verificar_liberacion(camino, sid, pago, total, cid_pago):
    c, ret, cid = retencion(pago)
    chequeo(camino, 'retencion del pago', 'LIBERADA con fecha', f"{c} {ret.get('estado')} {ret.get('liberadaEn')}",
            c == 200 and ret.get('estado') == 'LIBERADA' and bool(ret.get('liberadaEn')), cid)
    filas = leer(f"SELECT r.estado || ' | ' || coalesce(r.liberada_at::text, '-') || ' | ' || count(l.id) || ' | ' || "
                 f"coalesce(max(l.monto_bruto)::text, '-') || ' | ' || coalesce(max(l.comision)::text, '-') || ' | ' || "
                 f"coalesce(max(l.monto_neto)::text, '-') || ' | ' || coalesce(max(l.porcentaje_comision)::text, '-') "
                 f"FROM retencion_fondos r LEFT JOIN liquidacion l ON l.retencion_id = r.id "
                 f"WHERE r.pago_id = '{pago}' GROUP BY r.estado, r.liberada_at")
    print(f'  motor (estado | liberada_at | liquidaciones | bruto | comision | neto | %): {filas}')
    partes = filas[0].split(' | ') if filas and ' | ' in filas[0] else []
    if len(partes) == 7:
        n_liq, bruto, comision, neto, pct = partes[2], partes[3], partes[4], partes[5], partes[6]
        chequeo(camino, 'una sola liquidacion del aliado en la base', '1', n_liq, n_liq == '1')
        try:
            cuadra = abs(float(bruto) - float(total)) < 0.01 and abs(float(bruto) - float(comision) - float(neto)) < 0.01
            esperado_com = round(float(total) * float(pct) / 100, 2)
            cuadra = cuadra and abs(float(comision) - esperado_com) < 0.01
        except ValueError:
            cuadra = False
        chequeo(camino, 'liquidacion cuadra: bruto = total, neto = bruto - comision, comision = bruto x %',
                f'bruto {total}', f'bruto={bruto} comision={comision} neto={neto} pct={pct}', cuadra)
    else:
        chequeo(camino, 'lectura de retencion y liquidacion en la base', 'una fila', filas, False)
    c, rr, cid = http('GET', f'{CORE}/pagos/aliado', token=AL1)
    texto = json.dumps(rr)
    chequeo(camino, 'aliado.t1 ve el cobro liquidado', 'pago presente con liquidacion', f'{c} presente={pago in texto}',
            c == 200 and pago in texto and 'liquidacion' in texto, cid)
    c, _, cid = retencion(pago, C2)
    chequeo(camino, 'otro tenant no ve la retencion', '403/404', c, c in (403, 404), cid)


# ---------------------------------------------------------------- Camino A
print('\n== Camino A: pagar con la solicitud FINALIZADA')
SA, COTA, ca, cc = solicitud_lista('A pago tras finalizar')
print(f'  solicitud …{SA[-4:]}: aceptar oferta {ca}, aceptar cotizacion {cc}')
c, rr, cid = http('POST', f'{CORE}/solicitudes/{SA}/iniciar', {}, AL1)
c2, rr2, cid2 = http('POST', f'{CORE}/solicitudes/{SA}/finalizar', {}, AL1)
print(f'  iniciar {c} {cod(rr)} | finalizar {c2} {cod(rr2)}')
chequeo('A', 'estado antes de pagar', 'FINALIZADA', estado(SA), estado(SA) == 'FINALIZADA', cid2)
clave_a = str(uuid.uuid4())
c, rr, cid_pago_a = pagar(COTA, clave_a)
pago_a = (rr.get('pago') or {}).get('id')
chequeo('A', 'pagar tras finalizar (decision PO 891/892: permitido)', '200/201 APROBADO',
        f"{c} {(rr.get('pago') or {}).get('estado')} {cod(rr)}", c in (200, 201) and (rr.get('pago') or {}).get('estado') == 'APROBADO', cid_pago_a)
if pago_a:
    verificar_liberacion('A', SA, pago_a, 100000, cid_pago_a)
    c, rr, cid = pagar(COTA, clave_a)
    chequeo('A', 'repetir el pago con la misma clave no duplica', 'mismo pago', f"{c} mismo={(rr.get('pago') or {}).get('id') == pago_a}",
            (rr.get('pago') or {}).get('id') == pago_a, cid)
    f = leer(f"SELECT count(*) FROM liquidacion l JOIN retencion_fondos r ON r.id = l.retencion_id WHERE r.solicitud_id = '{SA}'")
    chequeo('A', 'sigue habiendo una sola liquidacion por la solicitud', '1', f[0] if f else '?', bool(f) and f[0] == '1')

# ---------------------------------------------------------------- Camino B
print('\n== Camino B: pagar con la solicitud CERRADA (camino exacto de SCRUM-1633)')
SB, COTB, ca, cc = solicitud_lista('B pago tras cerrar')
print(f'  solicitud …{SB[-4:]}: aceptar oferta {ca}, aceptar cotizacion {cc}')
http('POST', f'{CORE}/solicitudes/{SB}/iniciar', {}, AL1)
c, rr, _ = http('POST', f'{CORE}/solicitudes/{SB}/finalizar', {}, AL1)
c1, _, _ = http('POST', f'{CORE}/solicitudes/{SB}/calificaciones', {'puntaje': 5, 'comentario': 'T-05'}, C1)
c2, _, _ = http('POST', f'{CORE}/solicitudes/{SB}/calificaciones', {'puntaje': 5}, AL1)
c3, rr3, cid = http('POST', f'{CORE}/solicitudes/{SB}/cerrar', {}, C1)
print(f'  finalizar {c} | califica cliente {c1} | califica aliado {c2} | cerrar {c3} {cod(rr3)}')
chequeo('B', 'estado antes de pagar', 'CERRADA', estado(SB), estado(SB) == 'CERRADA', cid)
c, rr, cid_pago_b = pagar(COTB)
pago_b = (rr.get('pago') or {}).get('id')
chequeo('B', 'pagar con la solicitud cerrada (decision PO: permitido)', '200/201 APROBADO',
        f"{c} {(rr.get('pago') or {}).get('estado')} {cod(rr)}", c in (200, 201) and (rr.get('pago') or {}).get('estado') == 'APROBADO', cid_pago_b)
if pago_b:
    verificar_liberacion('B', SB, pago_b, 100000, cid_pago_b)

# ---------------------------------------------------------------- Camino C (control 892 C2)
print('\n== Camino C (control): pago antes de finalizar')
SC, COTC, ca, cc = solicitud_lista('C pago antes de finalizar')
c, rr, cid = pagar(COTC)
pago_c = (rr.get('pago') or {}).get('id')
if pago_c:
    _, ret, cid = retencion(pago_c)
    chequeo('C', 'sin finalizar sigue retenida (892 C2)', 'RETENIDA', ret.get('estado'), ret.get('estado') == 'RETENIDA', cid)
    http('POST', f'{CORE}/solicitudes/{SC}/iniciar', {}, AL1)
    http('POST', f'{CORE}/solicitudes/{SC}/finalizar', {}, AL1)
    _, ret, cid = retencion(pago_c)
    chequeo('C', 'al finalizar se libera', 'LIBERADA', ret.get('estado'), ret.get('estado') == 'LIBERADA', cid)
else:
    chequeo('C', 'pago antes de finalizar', 'pago creado', f'{c} {cod(rr)}', False, cid)

# ---------------------------------------------------------------- Dato del fallo original
print('\n== Dato del fallo del 5-nov (informativo, no cuenta)')
_, ret, _ = retencion(PAGO_ANTIGUO)
print(f"  pago {PAGO_ANTIGUO[:8]}…: retencion {ret.get('estado')} creada {ret.get('creadaEn')} (anterior al commit 098bf38 de 2026-11-05T14:57Z)")

print(f'\n== Fin ({time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())}): {sum(resultados)} PASA, {len(resultados) - sum(resultados)} FALLA')
print(f'  solicitudes de prueba: A=…{SA[-8:]} B=…{SB[-8:]} C=…{SC[-8:]}')

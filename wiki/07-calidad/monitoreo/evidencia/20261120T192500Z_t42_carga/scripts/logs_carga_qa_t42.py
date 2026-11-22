# SCRUM-1679 (T-42), 20 nov. Copia de qa_s5_corte2/logs_carga_qa.py para la carga del 20 nov. Corre en la VM de QA: resume los logs de la ventana de carga y consulta metadatos de la base.
# Solo lectura. Oculta tokens, URLs de conexion y claves antes de imprimir; no imprime valores de /opt/mani/.env.qa.
import collections
import json
import os
import re
import subprocess

DESDE = '2026-11-20T19:25:40Z'
HASTA = '2026-11-20T19:49:10Z'
UUID = re.compile(r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}')
OCULTAR = (
    (re.compile(r'eyJ[\w-]+\.[\w-]+(\.[\w-]+)?'), '<token>'),
    (re.compile(r'(?i)bearer\s+\S+'), 'Bearer <token>'),
    (re.compile(r'(?i)postgres(ql)?://\S+'), '<url_bd>'),
    (re.compile(r'(?i)(password|passwd|pwd|apikey|api_key|secret)(["\']?\s*[=:]\s*)\S+'), r'\1\2<oculto>'),
)


def limpiar(texto):
    for patron, cambio in OCULTAR:
        texto = patron.sub(cambio, texto)
    return texto


def normalizar(texto):
    texto = UUID.sub('{id}', limpiar(texto))
    texto = re.sub(r'\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(\.\d+)?(Z|[+-]\d{2}:?\d{2})?', '{hora}', texto)
    texto = re.sub(r'qas-t42-\d+-\d+', '{cid}', texto)
    texto = re.sub(r'\b\d+(\.\d+)?\b', '#', texto)
    return texto[:170]


def logs(servicio):
    r = subprocess.run(['docker', 'logs', '--since', DESDE, '--until', HASTA, servicio], capture_output=True, text=True, errors='replace')
    return (r.stdout + r.stderr).splitlines()


print(f'== Ventana {DESDE} a {HASTA}')

print('\n== Gateway: estado por ruta')
lineas = logs('mani-api-gateway')
print(f'  lineas: {len(lineas)}')
muestra_vista = False
por_ruta = collections.Counter()
tiempos = collections.defaultdict(list)
no_json = collections.Counter()
for linea in lineas:
    try:
        d = json.loads(linea)
    except ValueError:
        no_json[normalizar(linea)] += 1
        continue
    if not muestra_vista:
        print('  campos: ' + ','.join(sorted(d)))
        muestra_vista = True
    ruta = d.get('uri') or d.get('path') or d.get('request') or d.get('request_uri') or '?'
    ruta = re.sub(r'\?.*', '', UUID.sub('{id}', str(ruta)))
    estado = d.get('status') or d.get('status_code') or '?'
    aguas = d.get('upstream_status') or d.get('upstream_code') or '-'
    por_ruta[(ruta, str(estado), str(aguas))] += 1
    t = d.get('request_time') or d.get('duration') or d.get('upstream_response_time')
    try:
        tiempos[(ruta, str(estado))].append(float(t))
    except (TypeError, ValueError):
        pass
for (ruta, estado, aguas), n in por_ruta.most_common(30):
    ts = sorted(tiempos.get((ruta, estado), []))
    med = f' mediana={ts[len(ts) // 2]}' if ts else ''
    print(f'  {n:6} {estado} aguas={aguas} {ruta[:80]}{med}')
for texto, n in no_json.most_common(10):
    print(f'  {n:6} no_json {texto}')

for servicio in ('mani-dispatch-service', 'mani-core-service', 'mani-rules-service'):
    print(f'\n== {servicio}: mensajes mas repetidos')
    lineas = logs(servicio)
    print(f'  lineas: {len(lineas)}')
    claves = collections.Counter()
    mensajes = collections.Counter()
    for linea in lineas:
        texto = linea
        try:
            d = json.loads(linea)
            if isinstance(d, dict):
                texto = ' | '.join(str(d.get(k)) for k in ('level', 'msg', 'message', 'code', 'err', 'error') if d.get(k))
        except ValueError:
            pass
        mensajes[normalizar(texto)] += 1
        bajo = linea.lower()
        for clave in ('emaxconn', 'max clients', 'too many', 'timeout exceeded', 'timeout', 'pool', 'taskcanceled', 'econnrefused', 'econnreset', 'socket hang up', ' 503', ' 500', ' 504', ' 502'):
            if clave in bajo:
                claves[clave] += 1
    print('  palabras: ' + ', '.join(f'{k}={v}' for k, v in claves.most_common()))
    for texto, n in mensajes.most_common(25):
        print(f'  {n:6} {texto}')

print('\n== Reinicios')
for servicio in ('mani-api-gateway', 'mani-core-service', 'mani-dispatch-service', 'mani-rules-service'):
    r = subprocess.run(['docker', 'inspect', '-f', '{{.RestartCount}} {{.State.StartedAt}} oom={{.State.OOMKilled}}', servicio], capture_output=True, text=True)
    print(f'  {servicio}: {r.stdout.strip()}')

print('\n== Base: metadatos')
env = {}
for linea in open('/opt/mani/.env.qa', encoding='utf8'):
    m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*)=(.*)$', linea.strip())
    if m:
        env[m.group(1)] = m.group(2).strip().strip('\'"')
consultas = r"""
BEGIN READ ONLY;
\echo [max_connections]
SHOW max_connections;
\echo [latencia_ida_y_vuelta: 10 consultas SELECT 1, tiempos en ms]
\timing on
SELECT 1;
SELECT 1;
SELECT 1;
SELECT 1;
SELECT 1;
SELECT 1;
SELECT 1;
SELECT 1;
SELECT 1;
SELECT 1;
\timing off
\echo [conexiones_por_usuario]
SELECT usename, state, count(*) FROM pg_stat_activity GROUP BY 1, 2 ORDER BY 3 DESC LIMIT 12;
\echo [triggers_en_tablas_de_rastro]
SELECT event_object_table, trigger_name, string_agg(event_manipulation, ',') FROM information_schema.triggers WHERE trigger_schema = 'public' AND (event_object_table ~* 'audit|bitacora|log|evento|transaccion|historial|pago|consulta' OR action_statement ~* 'inmut|audit') GROUP BY 1, 2 ORDER BY 1, 2;
\echo [columnas_de_rastro]
SELECT table_name, string_agg(column_name, ',' ORDER BY column_name) FROM information_schema.columns WHERE table_schema = 'public' AND column_name IN ('actor_id', 'actor_rol', 'correlation_id') GROUP BY 1 ORDER BY 1;
\echo [tablas_candidatas]
SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename ~* 'audit|bitacora|log|evento|transaccion|historial' ORDER BY 1;
ROLLBACK;
"""
r = subprocess.run(['docker', 'run', '--rm', '-i', '--network', 'host', '-e', 'PGURL=' + env['DATABASE_URL'], 'postgres:15',
                    'sh', '-c', 'psql "$PGURL" -X -A -t -F "|" 2>&1'],
                   input=consultas, capture_output=True, text=True, timeout=120)
for linea in r.stdout.splitlines():
    if linea not in ('BEGIN', 'ROLLBACK', 'SET', ''):
        print('  ' + limpiar(linea)[:200])

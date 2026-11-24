# QAS-05. Lee en la entrada el JSON de `docker compose config` de QA y escribe en la salida un proyecto aislado (qas05).
# No se guarda en disco: la salida trae los valores de .env.qa. Variables: QAS05_CONF (nginx.conf), QAS05_POOL_CORE, QAS05_POOL_DISPATCH, QAS05_CPU.
import json, os, re, sys
# Dispatch usa el puerto 5432 en QA (24 nov): solo entra si se va a escalar y su conexion pasa la revision.
CON_DISPATCH = os.environ.get('QAS05_DISPATCH', '0') == '1'
ESCALABLES = ('core-service', 'rules-service') + (('dispatch-service',) if CON_DISPATCH else ())
# Topes acordados con DevOps el 24 nov.
MEMORIA = {'core-service': '256M', 'dispatch-service': '256M', 'rules-service': '512M'}
conf, cpu = os.environ['QAS05_CONF'], float(os.environ.get('QAS05_CPU', '0.5'))
pool_core, pool_disp = os.environ.get('QAS05_POOL_CORE', '5'), os.environ.get('QAS05_POOL_DISPATCH', '2')
entrada = json.load(sys.stdin)['services']
servicios = {}
for n in ESCALABLES + ('gateway',):
    s = entrada[n]
    for k in ('container_name', 'hostname', 'ports', 'volumes', 'depends_on', 'healthcheck', 'build', 'env_file', 'logging', 'labels', 'profiles'):
        s.pop(k, None)
    s['restart'] = 'no'
    s['pull_policy'] = 'never'
    s['networks'] = {'qas05': None}
    env = s.get('environment') or {}
    # Sin Kafka: las copias no publican eventos ni corren el relevo de la bandeja de salida.
    s['environment'] = {k: v for k, v in env.items() if not k.startswith(('KAFKA', 'Kafka', 'OUTBOX'))}
    limites = s.setdefault('deploy', {}).setdefault('resources', {}).setdefault('limits', {})
    s['deploy']['resources'].pop('reservations', None)
    s['deploy'].pop('replicas', None)
    if n in ESCALABLES:
        limites['cpus'] = cpu
        limites['memory'] = MEMORIA[n]
    servicios[n] = s
servicios['core-service']['environment']['DATABASE_POOL_MAX'] = pool_core
# DevOps pidio entrar por el pooler (:6543). No se imprimen los valores.
url = servicios['core-service']['environment'].get('DATABASE_URL') or ''
if not re.search(r':6543(/|$)', url):
    sys.exit('DATABASE_URL de Core no usa el puerto 6543: no se genera el proyecto.')
if CON_DISPATCH:
    d = servicios['dispatch-service']['environment']
    cambios = 0
    for k, v in list(d.items()):
        if isinstance(v, str) and re.search(r'maximum pool size\s*=', v, re.I):
            d[k] = re.sub(r'(maximum pool size\s*=\s*)\d+', r'\g<1>' + pool_disp, v, flags=re.I); cambios += 1
    if not any(isinstance(v, str) and re.search(r'port\s*=\s*[\'"]?6543\b', v, re.I) for v in d.values()):
        formas = []
        for k, v in d.items():
            if isinstance(v, str) and re.search(r'maximum pool size|postgres(ql)?://', v, re.I):
                formas.append(k + ': puerto por clave ' + str(re.findall(r'port\s*=\s*[\'"]?(\d+)', v, re.I)) + ', por direccion ' + str(re.findall(r'(?<=[a-z0-9]):(\d{4})(?=[/;]|$)', v)))
        sys.exit('La conexion de Dispatch no usa el puerto 6543: no se genera el proyecto. ' + ' | '.join(formas))
    if not cambios:
        sys.exit('Dispatch no tiene Maximum Pool Size: no se genera el proyecto.')
servicios['gateway']['ports'] = [{'mode': 'ingress', 'host_ip': '127.0.0.1', 'target': 80, 'published': '18090', 'protocol': 'tcp'}]
servicios['gateway']['volumes'] = [{'type': 'bind', 'source': conf, 'target': '/etc/nginx/nginx.conf', 'read_only': True}]
json.dump({'name': 'qas05', 'services': servicios, 'networks': {'qas05': {'name': 'qas05-network', 'driver': 'bridge'}}}, sys.stdout)

#!/usr/bin/env bash
# SCRUM-1679 (T-42), despliegue del 20 nov. Pools de conexion de QA segun MANI-APIGateway#97 (SCRUM-1652):
#   docker-compose.qa.yml: en core-service, DATABASE_POOL_MAX: ${CORE_DATABASE_POOL_MAX:-30}
#   .env.qa: CORE_DATABASE_POOL_MAX=30 y ';Maximum Pool Size=10' al final de DISPATCH_DB_CONNECTION
#   ensayo  (por omision): muestra que cambiaria, sin escribir.
#   aplicar: respalda los dos archivos en /opt/mani/respaldo_t42_<fecha>/, escribe y valida con docker compose config.
#            Si la validacion falla, restaura los respaldos.
# No reinicia contenedores: los valores entran al recrear Core y Dispatch con desplegar_release_qa_t42.sh.
# No imprime claves ni URLs: de .env.qa solo muestra nombres de variables y numeros del pool.
# Pide la contrasena de la VM de QA una vez. Uso: bash qa_t42/configurar_pools_qa.sh [ensayo|aplicar]
set -u
cd "$(dirname "$0")/.."
MODO=${1:-ensayo}
case "$MODO" in ensayo|aplicar) ;; *) echo "Modo: ensayo o aplicar"; exit 1 ;; esac
mkdir -p qa_t42/evidencia
SAL="qa_t42/evidencia/pools_${MODO}_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
echo "Modo $MODO. Se pide la contrasena de la VM de QA:"
{ printf 'MODO=%s\n' "$MODO"; cat <<'REMOTO'
set -u
cd /opt/mani || { echo "ABORTA: no existe /opt/mani"; exit 1; }
echo "== Fecha $(date -u +%FT%TZ), modo $MODO"
python3 - "$MODO" <<'PY'
import re, sys, os, shutil, subprocess, datetime
modo = sys.argv[1]
comp, env = 'docker-compose.qa.yml', '.env.qa'
c = open(comp, encoding='utf8').read().split('\n')
e = open(env, encoding='utf8').read().split('\n')

# compose: bloque de core-service y su linea DATABASE_URL
inicio = next((i for i, l in enumerate(c) if re.match(r'^  core-service:\s*$', l)), None)
if inicio is None:
    sys.exit('ABORTA: no hay servicio core-service en el compose')
fin = next((i for i in range(inicio + 1, len(c)) if re.match(r'^  \S', c[i])), len(c))
bloque = c[inicio:fin]
cambios = []
if any('DATABASE_POOL_MAX' in l for l in bloque):
    print('compose: core-service ya tiene DATABASE_POOL_MAX')
else:
    j = next((k for k in range(inicio, fin) if re.match(r'^\s+DATABASE_URL:', c[k])), None)
    if j is None:
        sys.exit('ABORTA: core-service no tiene DATABASE_URL en environment')
    sangria = re.match(r'^(\s+)', c[j]).group(1)
    c.insert(j + 1, sangria + 'DATABASE_POOL_MAX: ${CORE_DATABASE_POOL_MAX:-30}')
    cambios.append(f'compose: linea {j + 2} agrega DATABASE_POOL_MAX en core-service')

# .env.qa
if any(re.match(r'^CORE_DATABASE_POOL_MAX=', l) for l in e):
    print('env: ya existe ' + next(l for l in e if l.startswith('CORE_DATABASE_POOL_MAX=')))
else:
    e.insert(len(e) - 1 if e and e[-1] == '' else len(e), 'CORE_DATABASE_POOL_MAX=30')
    cambios.append('env: agrega CORE_DATABASE_POOL_MAX=30')
idx = [i for i, l in enumerate(e) if l.startswith('DISPATCH_DB_CONNECTION=')]
if len(idx) != 1:
    sys.exit(f'ABORTA: DISPATCH_DB_CONNECTION aparece {len(idx)} veces en .env.qa')
i = idx[0]
m = re.search(r'maximum pool size\s*=\s*(\d+)', e[i], re.I)
if m:
    print(f'env: DISPATCH_DB_CONNECTION ya tiene Maximum Pool Size={m.group(1)}')
else:
    v = e[i].rstrip()
    comilla = v[-1] if v[-1] in '"\'' else ''
    cuerpo = v[:-1] if comilla else v
    e[i] = cuerpo.rstrip(';') + ';Maximum Pool Size=10' + comilla
    cambios.append('env: DISPATCH_DB_CONNECTION termina en ;Maximum Pool Size=10')

print('== cambios: ' + ('; '.join(cambios) if cambios else 'ninguno'))
if modo != 'aplicar' or not cambios:
    sys.exit(0)
dest = '/opt/mani/respaldo_t42_' + datetime.datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')
os.makedirs(dest)
for f in (comp, env):
    shutil.copy2(f, os.path.join(dest, f))
os.chmod(os.path.join(dest, env), 0o600)
print('respaldo en ' + dest)
open(comp, 'w', encoding='utf8').write('\n'.join(c))
open(env, 'w', encoding='utf8').write('\n'.join(e))
r = subprocess.run(['docker', 'compose', '-f', comp, '--env-file', env, 'config', '--format', 'json'], capture_output=True, text=True)
ok = False
if r.returncode == 0:
    import json
    s = json.loads(r.stdout)['services']
    pool_core = s['core-service'].get('environment', {}).get('DATABASE_POOL_MAX')
    m = re.search(r'maximum pool size\s*=\s*(\d+)', json.dumps(s['dispatch-service'].get('environment', {})), re.I)
    print(f'validacion: Core DATABASE_POOL_MAX={pool_core}; Dispatch Maximum Pool Size={m.group(1) if m else None}')
    ok = pool_core == '30' and m and m.group(1) == '10'
if not ok:
    for f in (comp, env):
        shutil.copy2(os.path.join(dest, f), f)
    sys.exit('ABORTA: docker compose config no valido los pools; se restauraron los dos archivos')
print('== aplicado')
PY
REMOTO
} | ssh -o ConnectTimeout=15 estudiante@10.43.100.141 'f=$(mktemp); cat > "$f"; bash "$f" </dev/null; r=$?; rm -f "$f"; exit $r' 2>&1 \
  | sed -E 's#postgres(ql)?://[^ "]+#<url>#g; s/(Password=)[^; ]+/\1<oculto>/Ig' | tee "$SAL"
echo "== salida guardada en $SAL"

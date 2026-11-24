#!/usr/bin/env bash
# QAS-18 y QAS-27 (SCRUM-1715), 24 nov. Pide las contrasenas de QA y de Calidad, una vez cada una.
#   bash qa_qas_24nov/correr_qas18_27.sh ensayo   -> solo lectura, 1 minuto, sin carga
#   bash qa_qas_24nov/correr_qas18_27.sh          -> carga real, unos 22 minutos
# QAS-18: carga nominal (300 VU, 50 req/s, 5 min) con k6 desde el Mac por tunel SSH al Gateway. QAS-27: satura Rules y despues Core por la red interna de QA.
# Solo lecturas. No reinicia, escala ni reconfigura nada.
set -u
cd "$(dirname "$0")/.."
QA=estudiante@10.43.100.141
CAL=estudiante@10.43.98.196
SOLICITUD=cb68d899-f579-46a8-b30f-7eed71878baf
MODO=${1:-real}
D=$(mktemp -d); chmod 700 "$D"
SQ="$D/qa"; SC="$D/cal"
MARCA=$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z')
SAL="qa_qas_24nov/evidencia/qas18_27_${MODO}_${MARCA}.txt"
cerrar() {
  ssh -S "$SQ" "$QA" 'pkill -u estudiante -f "qas2[7]_coexistencia"; rm -f /tmp/qas27_coexistencia.py' 2>/dev/null
  ssh -S "$SQ" -O exit "$QA" 2>/dev/null; ssh -S "$SC" -O exit "$CAL" 2>/dev/null
  rm -rf "$D"; unset CLAVE_CFG04
}
trap cerrar EXIT
trap 'exit 130' INT TERM
echo "Se pide la contrasena de la VM de QA (10.43.100.141):"
ssh -M -S "$SQ" -o ControlPersist=3600 -o ConnectTimeout=15 -o ServerAliveInterval=30 -o ExitOnForwardFailure=yes -L 127.0.0.1:18080:127.0.0.1:80 -fN "$QA" || { echo "No se pudo abrir QA"; exit 1; }
echo "Se pide la contrasena de la VM de Calidad (10.43.98.196):"
ssh -M -S "$SC" -o ControlPersist=3600 -o ConnectTimeout=15 -o ServerAliveInterval=30 -fN "$CAL" || { echo "No se pudo abrir Calidad"; exit 1; }
prom() { ssh -S "$SC" "$CAL" "python3 - $1 $2 $3" < qa_qas_24nov/prom_qas18_27.py 2>&1 | tee -a "$SAL"; }
ssh -S "$SQ" "$QA" 'cat > /tmp/qas27_coexistencia.py' < qa_qas_24nov/qas27_coexistencia.py

{ echo "== Ensayo $(date -u +%FT%TZ)"; curl -s -o /dev/null -m 10 -w "Gateway por el tunel: %{http_code}\n" http://127.0.0.1:18080/health; } | tee "$SAL"
ssh -S "$SQ" "$QA" 'docker ps --format "{{.Names}} {{.Image}}" | grep -E "cadvisor|mani-(api|core|rules|dispatch)"; df -h / | tail -1; python3 -u /tmp/qas27_coexistencia.py ensayo' 2>&1 | tee -a "$SAL"
[ "${PIPESTATUS[0]}" = 0 ] || { echo "El ensayo no paso: no se lanza carga. Salida en $SAL"; exit 1; }
T=$(date +%s); prom ensayo $((T-300)) "$T"
[ "${PIPESTATUS[0]}" = 0 ] || true
if [ "$MODO" = ensayo ]; then echo "== Fin del ensayo; salida en $SAL"; exit 0; fi

patron=$(sed -nE 's/^CLAVE_CFG04=\$\(git -C MANI-API show origin\/release:supabase\/seed\/seed_qa_multitenant.sql \| (.*)\)$/\1/p' qa_s5_corte2/correr_varios.sh)
CLAVE_CFG04=$(git -C MANI-API show origin/release:supabase/seed/seed_qa_multitenant.sql | bash -c "$patron")
[ -n "$CLAVE_CFG04" ] || { echo "No se encontro la contrasena de CFG-04 en su semilla. No se corre nada."; exit 1; }
printf '%s' "$CLAVE_CFG04" | ssh -S "$SQ" "$QA" 'python3 -c "
import json, re, sys, urllib.request
clave = sys.stdin.read()
env = {}
for l in open(\"/opt/mani/.env.qa\", encoding=\"utf8\"):
    m = re.match(r\"^([A-Za-z_][A-Za-z0-9_]*)=(.*)$\", l.strip())
    if m:
        env[m.group(1)] = m.group(2).strip().strip(chr(39) + chr(34))
anon = next(env[n] for n in (\"SUPABASE_ANON_KEY\", \"SUPABASE_KEY\", \"ANON_KEY\", \"SUPABASE_PUBLISHABLE_KEY\") if env.get(n))
salida = {}
for rol, correo in ((\"cliente\", \"cliente.t1@qa.mani.test\"), (\"aliado\", \"aliado.t1@qa.mani.test\")):
    req = urllib.request.Request(env[\"SUPABASE_URL\"].rstrip(\"/\") + \"/auth/v1/token?grant_type=password\", data=json.dumps({\"email\": correo, \"password\": clave}).encode(), headers={\"Content-Type\": \"application/json\", \"apikey\": anon})
    salida[rol] = json.load(urllib.request.urlopen(req, timeout=30))[\"access_token\"]
print(json.dumps(salida))
"' > "$D/tokens.json"
unset CLAVE_CFG04
[ -s "$D/tokens.json" ] || { echo "No se obtuvieron tokens. No se corre nada." | tee -a "$SAL"; exit 1; }
correr() { k6 run --quiet --no-usage-report -e ARCHIVO_TOKENS="$D/tokens.json" -e SOLICITUD=$SOLICITUD -e BASE_URL=http://127.0.0.1:18080 -e MODO=mezcla -e VUS=$1 -e RPS=$2 -e RAMPA=$3 -e DURACION=$4 -e SALIDA="$D" qa_qas_24nov/k6_qas18.js 2>&1 | tail -70; }

echo "== Humo 30 s ($(date -u +%H:%M:%SZ))" | tee -a "$SAL"
HUMO=$(correr 10 2 5s 30s); printf '%s\n' "$HUMO" | tee -a "$SAL"
if ! printf '%s\n' "$HUMO" | grep -qE '"tasa_fallo_http": 0,?$'; then echo "El humo no paso: no se lanza la carga." | tee -a "$SAL"; exit 1; fi

echo "== QAS-18 carga nominal 300 VU, 50 req/s, 1 min de rampa y 5 sostenidos ($(date -u +%H:%M:%SZ))" | tee -a "$SAL"
I=$(date +%s); correr 300 50 60s 5m | tee -a "$SAL"
sleep 45
# La ventana de 2 min de la tasa queda completa dentro de los 5 min sostenidos.
prom qas18_sostenido $((I+185)) $((I+360))
echo "== Pausa de 2 min y QAS-27 ($(date -u +%H:%M:%SZ))" | tee -a "$SAL"
sleep 120
J=$(date +%s)
ssh -S "$SQ" "$QA" 'python3 -u /tmp/qas27_coexistencia.py 120 210 60 4 rules core' 2>&1 | tee -a "$SAL"
sleep 45
for o in rules core; do
  F=$(awk -v o="$o" '/^== Objetivo/{a=($3==o",")} a&&/^saturado desde/{print $5}' "$SAL" | head -1)
  [ -n "$F" ] && prom "qas27_${o}_saturado" $((F+125)) $((F+210))
done
ssh -S "$SQ" "$QA" 'docker ps --format "{{.Names}} {{.Status}}" | grep -E "mani-(api|core|dispatch|rules)"' | tee -a "$SAL"
echo "== Fin ($(date -u +%H:%M:%SZ)); salida en $SAL" | tee -a "$SAL"

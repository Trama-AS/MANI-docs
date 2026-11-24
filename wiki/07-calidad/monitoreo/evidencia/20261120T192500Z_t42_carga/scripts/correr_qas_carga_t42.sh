#!/usr/bin/env bash
# SCRUM-1679 (T-42), 20 nov. Remedicion de QAS-03, 15 y 19 (y 18) tras desplegar 1651 y 1652. Copia de qa_s5_corte2/correr_qas_carga.sh: k6 desde la VM de Calidad contra el Gateway de QA, con docker stats en la VM de QA.
# Solo lecturas. Unos 22 minutos. Pide las contrasenas de las dos VM y las reutiliza con ControlMaster.
# Los tokens de prueba no tocan el disco del Mac; en Calidad quedan con permisos 600 y se borran al terminar.
# Uso: bash qa_t42/correr_qas_carga_t42.sh
set -u
cd "$(dirname "$0")/.."
QA=estudiante@10.43.100.141
CAL=estudiante@10.43.98.196
SOLICITUD=cb68d899-f579-46a8-b30f-7eed71878baf
SOCK_DIR=$(mktemp -d)
SQ="$SOCK_DIR/qa"
SC="$SOCK_DIR/cal"
MARCA=$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z')
mkdir -p qa_t42/evidencia
SAL="qa_t42/evidencia/qas_carga_${MARCA}.txt"
MUESTRA_PID=""
cerrar() {
  [ -n "$MUESTRA_PID" ] && kill "$MUESTRA_PID" 2>/dev/null
  ssh -S "$SC" "$CAL" 'rm -rf ~/qas_t42' 2>/dev/null
  ssh -S "$SQ" -O exit "$QA" 2>/dev/null
  ssh -S "$SC" -O exit "$CAL" 2>/dev/null
  rm -rf "$SOCK_DIR"
  unset CLAVE_CFG04 TOKENS
}
trap cerrar EXIT

# Mismo patron que correr_varios.sh, leido de ese script para no mantenerlo en dos sitios.
patron=$(sed -nE 's/^CLAVE_CFG04=\$\(git -C MANI-API show origin\/release:supabase\/seed\/seed_qa_multitenant.sql \| (.*)\)$/\1/p' qa_s5_corte2/correr_varios.sh)
CLAVE_CFG04=$(git -C MANI-API show origin/release:supabase/seed/seed_qa_multitenant.sql | bash -c "$patron")
[ -n "$CLAVE_CFG04" ] || { echo "No se encontro la contrasena de CFG-04 en su semilla. No se corre nada."; exit 1; }

echo "Se pide la contrasena de la VM de QA (10.43.100.141):"
ssh -M -S "$SQ" -o ControlPersist=3000 -o ConnectTimeout=15 -o ServerAliveInterval=30 -fN "$QA" || { echo "No se pudo abrir QA"; exit 1; }
echo "Se pide la contrasena de la VM de Calidad (10.43.98.196):"
ssh -M -S "$SC" -o ControlPersist=3000 -o ConnectTimeout=15 -o ServerAliveInterval=30 -fN "$CAL" || { echo "No se pudo abrir Calidad"; exit 1; }

{
echo "== Carga QAS $(date -u +%FT%TZ)"
ssh -S "$SC" "$CAL" '/opt/quality/runners/k6/k6 version 2>&1 | head -1; nproc; for p in 80 8080; do curl -s -o /dev/null -m 5 -w "gateway puerto $p: %{http_code}\n" http://10.43.100.141:$p/health; done'
} | tee "$SAL"

ssh -S "$SC" "$CAL" 'test -x /opt/quality/runners/k6/k6' || { echo "Calidad no tiene k6 en /opt/quality/runners/k6. No se corre nada." | tee -a "$SAL"; exit 1; }
# Limpia muestreos de una corrida anterior; el corchete evita que pkill se mate a si mismo.
ssh -S "$SQ" "$QA" "pkill -u estudiante -f 'docker stat[s] --no-stream'; pgrep -u estudiante -fc 'docker stat[s] --no-stream'" | sed 's/^/muestreos vivos tras limpiar: /' | tee -a "$SAL"
PUERTO=$(ssh -S "$SC" "$CAL" 'for p in 80 8080; do c=$(curl -s -o /dev/null -m 5 -w "%{http_code}" http://10.43.100.141:$p/health); [ "$c" = 200 ] && { echo $p; break; }; done')
[ -n "$PUERTO" ] || { echo "Calidad no alcanza el Gateway de QA. No se corre nada." | tee -a "$SAL"; exit 1; }

TOKENS=$(printf '%s' "$CLAVE_CFG04" | ssh -S "$SQ" "$QA" 'python3 -c "
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
"')
[ -n "$TOKENS" ] || { echo "No se obtuvieron tokens. No se corre nada." | tee -a "$SAL"; exit 1; }

printf '%s' "$TOKENS" | python3 -c '
import base64, json, sys
t = json.load(sys.stdin)["cliente"].split(".")[1]
c = json.loads(base64.urlsafe_b64decode(t + "=" * (-len(t) % 4)))
print("vigencia del token en minutos:", (c["exp"] - c["iat"]) // 60)' | tee -a "$SAL"

ssh -S "$SC" "$CAL" 'umask 077; rm -rf ~/qas_t42; mkdir -p ~/qas_t42; cat > ~/qas_t42/k6_qas_carga.js' < qa_t42/k6_qas_carga.js
printf '%s' "$TOKENS" | ssh -S "$SC" "$CAL" 'umask 077; cat > ~/qas_t42/tokens.json'
unset TOKENS

correr() {  # modo vus rps rampa duracion
  ssh -S "$SC" "$CAL" "cd ~/qas_t42 && /opt/quality/runners/k6/k6 run --quiet --no-usage-report -e ARCHIVO_TOKENS=tokens.json -e SOLICITUD=$SOLICITUD -e BASE_URL=http://10.43.100.141:$PUERTO -e MODO=$1 -e VUS=$2 -e RPS=$3 -e RAMPA=$4 -e DURACION=$5 k6_qas_carga.js 2>&1 | tail -60"
}
muestrear() {  # etiqueta veces; el bucle remoto termina solo aunque se corte la conexion
  ssh -S "$SQ" "$QA" "for i in \$(seq 1 $2); do date -u +%H:%M:%S; docker stats --no-stream --format '{{.Name}} cpu={{.CPUPerc}} mem={{.MemPerc}}' | grep -E 'mani-(api|core|dispatch|rules)'; sleep 30; done" > "qa_t42/evidencia/qas_stats_${1}_${MARCA}.txt" 2>/dev/null &
  MUESTRA_PID=$!
}
parar() {
  [ -n "$MUESTRA_PID" ] && kill "$MUESTRA_PID" 2>/dev/null
  MUESTRA_PID=""
  ssh -S "$SQ" "$QA" "pkill -u estudiante -f 'docker stat[s] --no-stream'" 2>/dev/null
}

echo "== Humo 30 s ($(date -u +%H:%M:%SZ))" | tee -a "$SAL"
HUMO=$(correr mezcla 10 2 5s 30s)
printf '%s\n' "$HUMO" | tee -a "$SAL"
if ! printf '%s\n' "$HUMO" | grep -qE '"tasa_fallo_http": 0,?$' || ! printf '%s\n' "$HUMO" | grep -qE '"peticiones_sostenidas": [1-9]'; then
  echo "El humo no paso: no se lanza la carga." | tee -a "$SAL"
  exit 1
fi

echo "== QAS-03 consulta 5 min ($(date -u +%H:%M:%SZ))" | tee -a "$SAL"
muestrear qas03 14
correr consulta 300 50 60s 5m | tee -a "$SAL"
parar
echo "== Salud tras QAS-03 ($(date -u +%H:%M:%SZ))" | tee -a "$SAL"
ssh -S "$SC" "$CAL" "for r in /health /api/v1/core/health /api/v1/rules/health /api/v1/dispatch/health; do curl -s -o /dev/null -m 10 -w \"\$r %{http_code} %{time_total}s\n\" http://10.43.100.141:$PUERTO\$r; done" | tee -a "$SAL"
sleep 60

echo "== QAS-15 y QAS-19 mezcla 15 min ($(date -u +%H:%M:%SZ))" | tee -a "$SAL"
muestrear qas19 34
correr mezcla 300 50 60s 15m | tee -a "$SAL"
parar
echo "== Salud tras la mezcla ($(date -u +%H:%M:%SZ))" | tee -a "$SAL"
ssh -S "$SC" "$CAL" "for r in /health /api/v1/core/health /api/v1/rules/health /api/v1/dispatch/health; do curl -s -o /dev/null -m 10 -w \"\$r %{http_code} %{time_total}s\n\" http://10.43.100.141:$PUERTO\$r; done" | tee -a "$SAL"
ssh -S "$SQ" "$QA" "docker ps --format '{{.Names}} {{.Status}}' | grep -E 'mani-(api|core|dispatch|rules)'; docker logs --since 25m mani-api-gateway 2>&1 | grep -cE '\" 50[0-9] |\"status\": *\"?50[0-9]'" | tee -a "$SAL"
echo "== Fin ($(date -u +%H:%M:%SZ)); salida en $SAL"

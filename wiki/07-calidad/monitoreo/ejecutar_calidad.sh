#!/usr/bin/env bash
# =====================================================================
# MANI - Corrida completa de SCRUM-1266 desde la VM de Calidad
# =====================================================================
# Ejecuta, en orden, contra el Gateway de QA:
#   1. Instalacion de k6 en /opt/quality/runners/k6 si falta (binario
#      oficial de grafana/k6 con verificacion sha256).
#   2. Token de prueba (obtener_token.sh) y token vencido si la fuente
#      lo permite.
#   3. QA-MON-01 modo calidad (verificar_monitoreo.sh).
#   4. Newman: coleccion qas01_perimetro (healthchecks, caso 5, dev-token).
#   5. k6 QAS-03: humo corto y, si el humo es valido, carga nominal.
#   6. k6 QAS-07 en modo arnes (solo valida el arnes contra el stub).
#   7. Redaccion de tokens en toda la evidencia.
#
# El progreso sale por stderr. Si EMPAQUETAR=1, al final se imprime por
# stdout la carpeta de evidencia como tar.gz en base64, para traerla con
# la misma sesion SSH.
#
# Variables:
#   FUENTE_TOKEN   dev_token o supabase (obligatoria; ver obtener_token.sh)
#   BASE_URL       Gateway de QA (por defecto http://10.43.100.141)
#   K6_VERSION     version de k6 (por defecto 2.3.0)
#   DIR_K6         carpeta de k6 (por defecto /opt/quality/runners/k6)
#   DURACION       fase sostenida de QAS-03 (por defecto 5m)
#   SALTAR_NOMINAL 1 para correr solo el humo de QAS-03
#   EMPAQUETAR     1 para emitir la evidencia por stdout
# =====================================================================
set -uo pipefail

: "${FUENTE_TOKEN:?definir FUENTE_TOKEN}"
export FUENTE_TOKEN
export BASE_URL=${BASE_URL:-http://10.43.100.141}
K6_VERSION=${K6_VERSION:-2.3.0}
DIR_K6=${DIR_K6:-/opt/quality/runners/k6}
DURACION=${DURACION:-5m}
AQUI=$(cd "$(dirname "$0")" && pwd)
MARCA=$(date -u +%Y%m%dT%H%M%SZ)
EVID="$AQUI/evidencia/$MARCA"
mkdir -p "$EVID"
export ARCHIVO_TOKEN="$HOME/.mani_qa/token.txt"

log() { echo "[$(date -u +%H:%M:%SZ)] $*" >&2; }

# ---- 1. k6 ----------------------------------------------------------
K6="$DIR_K6/k6"
if [ ! -x "$K6" ]; then
  log "Instalando k6 v$K6_VERSION en $DIR_K6"
  mkdir -p "$DIR_K6"
  paquete="k6-v$K6_VERSION-linux-amd64.tar.gz"
  url="https://github.com/grafana/k6/releases/download/v$K6_VERSION"
  curl -sSL -o "$DIR_K6/$paquete" "$url/$paquete"
  curl -sSL -o "$DIR_K6/checksums.txt" "$url/k6-v$K6_VERSION-checksums.txt"
  if ! (cd "$DIR_K6" && grep " $paquete\$" checksums.txt | sha256sum -c -); then
    log "Checksum de k6 no coincide; se detiene la corrida"
    exit 1
  fi
  tar -xzf "$DIR_K6/$paquete" -C "$DIR_K6" --strip-components=1
  rm -f "$DIR_K6/$paquete"
fi
"$K6" version > "$EVID/k6_version.txt" 2>&1
log "$(head -1 "$EVID/k6_version.txt")"

# ---- 2. Tokens --------------------------------------------------------
log "Obteniendo token (FUENTE_TOKEN=$FUENTE_TOKEN)"
bash "$AQUI/obtener_token.sh" > "$EVID/token_metadatos.txt" 2>&1 || { cat "$EVID/token_metadatos.txt" >&2; exit 1; }
token_vencido=""
if [ "$FUENTE_TOKEN" = "dev_token" ]; then
  ARCHIVO_TOKEN="$HOME/.mani_qa/token_vencido.txt" VIGENCIA=1s bash "$AQUI/obtener_token.sh" >/dev/null 2>&1 \
    && token_vencido=$(cat "$HOME/.mani_qa/token_vencido.txt")
  sleep 3
fi

# ---- 3. QA-MON-01 modo calidad --------------------------------------
log "QA-MON-01 modo calidad"
bash "$AQUI/verificar_monitoreo.sh" calidad > "$EVID/qa_mon_01_calidad.txt" 2>&1

# ---- 4. Newman --------------------------------------------------------
log "Newman qas01_perimetro"
ambiente="$HOME/.mani_qa/newman_ambiente.json"
umask 077
TOKEN_VAL=$(cat "$ARCHIVO_TOKEN") TOKEN_VENC="$token_vencido" python3 -c 'import json,os
print(json.dumps({"name":"qa_scrum_1266","values":[
 {"key":"base_url","value":os.environ["BASE_URL"],"enabled":True},
 {"key":"token","value":os.environ["TOKEN_VAL"],"enabled":True},
 {"key":"token_vencido","value":os.environ.get("TOKEN_VENC",""),"enabled":True}]}))' > "$ambiente"
umask 022
newman run "$AQUI/newman/qas01_perimetro.postman_collection.json" -e "$ambiente" \
  --reporters cli,json --reporter-json-export "$EVID/newman_qas01_perimetro.json" \
  > "$EVID/newman_qas01_perimetro.txt" 2>&1
echo "codigo_salida_newman=$?" >> "$EVID/newman_qas01_perimetro.txt"
rm -f "$ambiente"

# ---- 5. k6 QAS-03 -----------------------------------------------------
log "k6 QAS-03 humo (10 VUs, 2 req/s, 30 s)"
"$K6" run -q -e ARCHIVO_TOKEN="$ARCHIVO_TOKEN" -e BASE_URL="$BASE_URL" -e VUS=10 -e RPS=2 -e RAMPA=5s -e DURACION=30s \
  -e SALIDA="$EVID" "$AQUI/k6/qas03_latencia.js" > "$EVID/k6_qas03_humo.txt" 2>&1
humo_ok=$(grep -c "tasa_status_200=1$" "$EVID/k6_qas03_humo.txt")
for f in "$EVID"/qas03_*.json; do [ -e "$f" ] && mv "$f" "${f%.json}_humo.json"; done
if [ "$humo_ok" = "1" ] && [ "${SALTAR_NOMINAL:-0}" != "1" ]; then
  log "k6 QAS-03 nominal (300 VUs, 50 req/s, rampa 60 s, sostenida $DURACION)"
  "$K6" run -q -e ARCHIVO_TOKEN="$ARCHIVO_TOKEN" -e BASE_URL="$BASE_URL" -e DURACION="$DURACION" \
    -e SALIDA="$EVID" "$AQUI/k6/qas03_latencia.js" > "$EVID/k6_qas03_nominal.txt" 2>&1
  echo "codigo_salida_k6=$?" >> "$EVID/k6_qas03_nominal.txt"
elif [ "$humo_ok" != "1" ]; then
  log "Humo invalido (status distinto de 200); no se corre la carga nominal"
else
  log "SALTAR_NOMINAL=1: no se corre la carga nominal"
fi

# ---- 6. k6 QAS-07 arnes -------------------------------------------------
log "k6 QAS-07 arnes contra el stub (50 aceptaciones)"
"$K6" run -q -e ARCHIVO_TOKEN="$ARCHIVO_TOKEN" -e BASE_URL="$BASE_URL" -e N=50 -e MODO=arnes \
  -e SALIDA="$EVID" "$AQUI/k6/qas07_aceptacion_concurrente.js" > "$EVID/k6_qas07_arnes.txt" 2>&1

# ---- 7. Redaccion -------------------------------------------------------
log "Redactando tokens en la evidencia"
node "$AQUI/redactar_evidencia.mjs" "$EVID"/* > "$EVID/redaccion.txt" 2>&1
rm -f "$HOME/.mani_qa/token_vencido.txt" "$HOME/.mani_qa/token_vencido.txt.fuente"
log "Evidencia en $EVID"
ls -la "$EVID" >&2

if [ "${EMPAQUETAR:-0}" = "1" ]; then
  echo "==INICIO_EVIDENCIA=="
  tar -czf - -C "$AQUI/evidencia" "$MARCA" | base64
  echo "==FIN_EVIDENCIA=="
fi

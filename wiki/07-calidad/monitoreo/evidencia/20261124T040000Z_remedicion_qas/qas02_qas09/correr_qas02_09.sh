#!/usr/bin/env bash
# QAS-02 y QAS-09 en MANI-QA con copias desechables de Core y Dispatch. No pausa ni reinicia servicios de QA.
# La clave del seed (CFG-04) viaja por stdin. Pide la contrasena de la VM una vez. Tarda unos 6 minutos. No imprime claves.
# Uso: bash qa_qas_24nov/correr_qas02_09.sh          (ensayo: levanta y borra las copias, no escribe datos)
#      bash qa_qas_24nov/correr_qas02_09.sh real     (corrida real)
#      bash qa_qas_24nov/correr_qas02_09.sh recuperacion  (solo la recuperacion de una orquestacion a medias; 1 solicitud)
set -u
ENSAYO=1; [ "${1:-}" = real ] && ENSAYO=0
RECUPERACION=0; [ "${1:-}" = recuperacion ] && { ENSAYO=0; RECUPERACION=1; }
cd "$(dirname "$0")/.."
CLAVE_CFG04=$(git -C MANI-API show origin/release:supabase/seed/seed_qa_multitenant.sql | sed -nE "s/.*'admin\.t1@qa\.mani\.test', *crypt\('([^']+)'.*/\1/p" | head -1)
[ -n "$CLAVE_CFG04" ] || { echo "No se encontro la clave de CFG-04 en su semilla. No se corre nada."; exit 1; }
mkdir -p qa_qas_24nov/evidencia
SAL="qa_qas_24nov/evidencia/qas02_09_$([ $ENSAYO = 1 ] && echo ensayo || echo real)$([ $RECUPERACION = 1 ] && echo _recuperacion)_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
echo "Se pide la contrasena de la VM de QA:"
{ printf 'ENSAYO=%s\nRECUPERACION=%s\nCLAVE_CFG04=%q\nB64=%s\nB64_JS=%s\n' "$ENSAYO" "$RECUPERACION" "$CLAVE_CFG04" "$(base64 < qa_qas_24nov/qas02_qas09_qa.py | tr -d '\n')" "$(base64 < qa_qas_24nov/observador_push.js | tr -d '\n')"; cat <<'REMOTO'
export CLAVE_CFG04 ENSAYO RECUPERACION
OBSERVADOR_JS=$(printf '%s' "$B64_JS" | base64 -d); export OBSERVADOR_JS
d=$(mktemp -d); trap 'rm -rf "$d"; unset CLAVE_CFG04' EXIT
printf '%s' "$B64" | base64 -d > "$d/q.py"; python3 -u "$d/q.py"
REMOTO
} | ssh -o ConnectTimeout=15 -o ServerAliveInterval=15 estudiante@10.43.100.141 'f=$(mktemp); cat > "$f"; bash "$f" </dev/null; r=$?; rm -f "$f"; exit $r' 2>&1 | tee "$SAL"
unset CLAVE_CFG04
echo "== salida guardada en $SAL"

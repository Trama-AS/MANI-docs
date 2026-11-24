#!/usr/bin/env bash
# QAS-40 en MANI-QA con copias desechables de Core y Dispatch y un proxy que inyecta fallas. No pausa ni reinicia servicios de QA.
# La clave del seed (CFG-04) viaja por stdin. Pide la contrasena de la VM una vez. Tarda unos 4 minutos. No imprime claves.
# Uso: bash qa_qas_24nov/correr_qas40.sh
set -u
cd "$(dirname "$0")/.."
CLAVE_CFG04=$(git -C MANI-API show origin/release:supabase/seed/seed_qa_multitenant.sql | sed -nE "s/.*'admin\.t1@qa\.mani\.test', *crypt\('([^']+)'.*/\1/p" | head -1)
[ -n "$CLAVE_CFG04" ] || { echo "No se encontro la clave de CFG-04 en su semilla. No se corre nada."; exit 1; }
mkdir -p qa_qas_24nov/evidencia
SAL="qa_qas_24nov/evidencia/qas40_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
echo "Se pide la contrasena de la VM de QA:"
{ printf 'CLAVE_CFG04=%q\nB64=%s\nB64_JS=%s\n' "$CLAVE_CFG04" "$(base64 < qa_qas_24nov/qas40_qa.py | tr -d '\n')" "$(base64 < qa_qas_24nov/proxy_fallas.js | tr -d '\n')"; cat <<'REMOTO'
export CLAVE_CFG04
PROXY_JS=$(printf '%s' "$B64_JS" | base64 -d); export PROXY_JS
d=$(mktemp -d); trap 'rm -rf "$d"; unset CLAVE_CFG04' EXIT
printf '%s' "$B64" | base64 -d > "$d/q.py"; python3 -u "$d/q.py"
REMOTO
} | ssh -o ConnectTimeout=15 -o ServerAliveInterval=15 estudiante@10.43.100.141 'f=$(mktemp); cat > "$f"; bash "$f" </dev/null; r=$?; rm -f "$f"; exit $r' 2>&1 | tee "$SAL"
unset CLAVE_CFG04
echo "== salida guardada en $SAL"

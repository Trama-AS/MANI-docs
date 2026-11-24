#!/usr/bin/env bash
# QAS-40 y QAS-44 (SCRUM-1719) en MANI-QA. AFECTA QA unos minutos: avisar al equipo antes.
# Pausa rules-service menos de 1 min y deja dispatch-service caido hasta el rollback; al salir restaura todo.
# La clave del seed (CFG-04) viaja por stdin, como en qa_t41. Pide la contrasena de la VM una vez. No imprime claves.
# Uso: bash qa_qas_23nov/correr_qas40_44.sh [--solo-44]
set -u
cd "$(dirname "$0")/.."
CLAVE_CFG04=$(git -C MANI-API show origin/release:supabase/seed/seed_qa_multitenant.sql | sed -nE "s/.*'admin\.t1@qa\.mani\.test', *crypt\('([^']+)'.*/\1/p" | head -1)
[ -n "$CLAVE_CFG04" ] || { echo "No se encontro la clave de CFG-04 en su semilla. No se corre nada."; exit 1; }
SAL="qa_qas_23nov/evidencia/qas40_44_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
echo "Se pide la contrasena de la VM de QA:"
{ printf 'ARG=%q\nCLAVE_CFG04=%q\nB64=%s\n' "${1:-}" "$CLAVE_CFG04" "$(base64 < qa_qas_23nov/qas40_qas44_qa.py | tr -d '\n')"; cat <<'REMOTO'
export CLAVE_CFG04
d=$(mktemp -d); trap 'rm -rf "$d"; unset CLAVE_CFG04' EXIT
printf '%s' "$B64" | base64 -d > "$d/q.py"; python3 -u "$d/q.py" $ARG
REMOTO
} | ssh -o ConnectTimeout=15 -o ServerAliveInterval=15 estudiante@10.43.100.141 'f=$(mktemp); cat > "$f"; bash "$f" </dev/null; r=$?; rm -f "$f"; exit $r' 2>&1 | tee "$SAL"
unset CLAVE_CFG04
echo "== salida guardada en $SAL"

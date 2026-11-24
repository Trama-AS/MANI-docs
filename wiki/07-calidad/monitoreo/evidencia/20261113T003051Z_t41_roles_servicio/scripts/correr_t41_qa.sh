#!/usr/bin/env bash
# SCRUM-1678 (T-41). Repite QAS-01 y QAS-20 en MANI-QA con los roles mani_core_svc y mani_dispatch_svc.
# Envia a la VM de QA t41_qa.py, qas01_motor.sql, qas20_frontera.sql y db/verify/0037 de MANI-Node, y guarda la salida.
# La contrasena de las cuentas del seed (CFG-04) se lee de su semilla en MANI-APIGateway y viaja por stdin.
# ssh pide la contrasena de la VM; ningun script la guarda.
# Deja 2 solicitudes de prueba canceladas en QA. Las verificaciones del motor terminan en ROLLBACK.
# Uso: bash qa_t41/correr_t41_qa.sh
set -u
cd "$(dirname "$0")/.."
VERIFY="MANI-Node/db/verify/0037_verificar_sin_bypassrls.sql"
for f in qa_t41/t41_qa.py qa_t41/qas01_motor.sql qa_t41/qas20_frontera.sql "$VERIFY"; do
    [ -f "$f" ] || { echo "No esta $f. No se corre nada."; exit 1; }
done
CLAVE_CFG04=$(git -C MANI-API show origin/release:supabase/seed/seed_qa_multitenant.sql | sed -nE "s/.*'admin\.t1@qa\.mani\.test', *crypt\('([^']+)'.*/\1/p" | head -1)
[ -n "$CLAVE_CFG04" ] || { echo "No se encontro la contrasena de CFG-04 en su semilla. No se corre nada."; exit 1; }
mkdir -p qa_t41/evidencia
SALIDA=qa_t41/evidencia/t41_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt
b64() { base64 < "$1" | tr -d '\n'; }
echo "Se pide la contrasena de la VM de QA:"
{
    printf 'CLAVE_CFG04=%q\n' "$CLAVE_CFG04"
    printf 'B64_PY=%s\nB64_Q01=%s\nB64_Q20=%s\nB64_VER=%s\n' \
        "$(b64 qa_t41/t41_qa.py)" "$(b64 qa_t41/qas01_motor.sql)" "$(b64 qa_t41/qas20_frontera.sql)" "$(b64 "$VERIFY")"
    cat <<'REMOTO'
set -u
export CLAVE_CFG04
T41_DIR=$(mktemp -d)
trap 'rm -rf "$T41_DIR"; unset CLAVE_CFG04' EXIT
printf '%s' "$B64_PY" | base64 -d > "$T41_DIR/t41_qa.py"
printf '%s' "$B64_Q01" | base64 -d > "$T41_DIR/qas01_motor.sql"
printf '%s' "$B64_Q20" | base64 -d > "$T41_DIR/qas20_frontera.sql"
printf '%s' "$B64_VER" | base64 -d > "$T41_DIR/0037_verificar_sin_bypassrls.sql"
echo "== conectado a la VM; corriendo t41_qa.py (tarda unos minutos)"
T41_DIR="$T41_DIR" python3 -u "$T41_DIR/t41_qa.py"
REMOTO
} | ssh -o ConnectTimeout=15 estudiante@10.43.100.141 'f=$(mktemp); cat > "$f"; bash "$f" </dev/null; r=$?; rm -f "$f"; exit $r' 2>&1 \
  | sed -l -E 's#postgres(ql)?://[^ "]+#<url>#g; s/(Password=)[^; ]+/\1<oculto>/Ig; s/eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/<token>/g' \
  | tee "$SALIDA"
unset CLAVE_CFG04
echo "== salida guardada en $SALIDA"
echo "== resumen: $(grep -cE '^(NOTICE:  )?PASA' "$SALIDA") PASA, $(grep -cE '^(NOTICE:  )?FALLA' "$SALIDA") FALLA, $(grep -cE '^(NOTICE:  )?REVISAR' "$SALIDA") REVISAR"

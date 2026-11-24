#!/usr/bin/env bash
# SCRUM-1642 (T-05). Re-prueba de SCRUM-1633 en MANI-QA: un pago hecho despues de finalizar libera la retencion y liquida.
# Envia t05_qa.py a la VM de QA y guarda la salida. ssh pide la contrasena de la VM; ningun script la guarda.
# La contrasena de las cuentas del seed (CFG-04) se lee de su semilla en MANI-APIGateway y viaja por stdin.
# Deja 3 solicitudes de prueba de cliente.t1 con pagos simulados. Uso: bash qa_t05/correr_t05_qa.sh
set -u
cd "$(dirname "$0")/.."
[ -f qa_t05/t05_qa.py ] || { echo "No esta qa_t05/t05_qa.py. No se corre nada."; exit 1; }
CLAVE_CFG04=$(git -C MANI-API show origin/release:supabase/seed/seed_qa_multitenant.sql | sed -nE "s/.*'admin\.t1@qa\.mani\.test', *crypt\('([^']+)'.*/\1/p" | head -1)
[ -n "$CLAVE_CFG04" ] || { echo "No se encontro la contrasena de CFG-04 en su semilla. No se corre nada."; exit 1; }
mkdir -p qa_t05/evidencia
SALIDA=qa_t05/evidencia/t05_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt
echo "Se pide la contrasena de la VM de QA:"
{
    printf 'CLAVE_CFG04=%q\n' "$CLAVE_CFG04"
    printf 'B64_PY=%s\n' "$(base64 < qa_t05/t05_qa.py | tr -d '\n')"
    cat <<'REMOTO'
set -u
export CLAVE_CFG04
D=$(mktemp -d)
trap 'rm -rf "$D"; unset CLAVE_CFG04' EXIT
printf '%s' "$B64_PY" | base64 -d > "$D/t05_qa.py"
echo "== conectado a la VM; corriendo t05_qa.py (tarda 1 a 2 minutos)"
python3 -u "$D/t05_qa.py"
REMOTO
} | ssh -o ConnectTimeout=15 estudiante@10.43.100.141 'f=$(mktemp); cat > "$f"; bash "$f" </dev/null; r=$?; rm -f "$f"; exit $r' 2>&1 \
  | sed -l -E 's#postgres(ql)?://[^ "]+#<url>#g; s/(Password=)[^; ]+/\1<oculto>/Ig; s/eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/<token>/g' \
  | tee "$SALIDA"
unset CLAVE_CFG04
echo "== salida guardada en $SALIDA"
echo "== resumen: $(grep -cE '^PASA' "$SALIDA") PASA, $(grep -cE '^FALLA' "$SALIDA") FALLA"

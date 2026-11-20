#!/usr/bin/env bash
# SCRUM-1664 (T-27). Negativos de las operaciones criticas en MANI-QA (QAS-10): Newman + estado persistido + restricciones.
# Envia t27_qa.py y generar_coleccion_t27.py a la VM de QA y guarda la salida. ssh pide la contrasena de la VM; ningun script la guarda.
# La contrasena de las cuentas del seed (CFG-04) se lee de su semilla en MANI-APIGateway y viaja por stdin.
# Deja 2 solicitudes de prueba de cliente.t1 (una cancelada y una con pago simulado). Uso: bash qa_t27/correr_t27_qa.sh
set -u
cd "$(dirname "$0")/.."
[ -f qa_t27/t27_qa.py ] || { echo "No esta qa_t27/t27_qa.py. No se corre nada."; exit 1; }
CLAVE_CFG04=$(git -C MANI-API show origin/release:supabase/seed/seed_qa_multitenant.sql | sed -nE "s/.*'admin\.t1@qa\.mani\.test', *crypt\('([^']+)'.*/\1/p" | head -1)
[ -n "$CLAVE_CFG04" ] || { echo "No se encontro la contrasena de CFG-04 en su semilla. No se corre nada."; exit 1; }
mkdir -p qa_t27/evidencia
SALIDA=qa_t27/evidencia/t27_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt
echo "Se pide la contrasena de la VM de QA:"
{
    printf 'CLAVE_CFG04=%q\n' "$CLAVE_CFG04"
    printf 'B64_PY=%s\n' "$(base64 < qa_t27/t27_qa.py | tr -d '\n')"
    printf 'B64_GEN=%s\n' "$(base64 < qa_t27/generar_coleccion_t27.py | tr -d '\n')"
    cat <<'REMOTO'
set -u
export CLAVE_CFG04
D=$(mktemp -d)
trap 'rm -rf "$D"; unset CLAVE_CFG04' EXIT
printf '%s' "$B64_PY" | base64 -d > "$D/t27_qa.py"
printf '%s' "$B64_GEN" | base64 -d > "$D/generar_coleccion_t27.py"
export T27_DIR="$D"
echo "== conectado a la VM; corriendo t27_qa.py (tarda 2 a 4 minutos)"
python3 -u "$D/t27_qa.py"
REMOTO
} | ssh -o ConnectTimeout=15 estudiante@10.43.100.141 'f=$(mktemp); cat > "$f"; bash "$f" </dev/null; r=$?; rm -f "$f"; exit $r' 2>&1 \
  | sed -l -E 's#postgres(ql)?://[^ "]+#<url>#g; s/(Password=)[^; ]+/\1<oculto>/Ig; s/eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/<token>/g' \
  | tee "$SALIDA"
unset CLAVE_CFG04
echo "== salida guardada en $SALIDA"
echo "== resumen: $(grep -cE '^PASA' "$SALIDA") PASA, $(grep -cE '^FALLA' "$SALIDA") FALLA, $(grep -cE '^REVISAR' "$SALIDA") REVISAR"

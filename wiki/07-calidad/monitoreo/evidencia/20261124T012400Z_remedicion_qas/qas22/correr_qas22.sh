#!/usr/bin/env bash
# QAS-22, 23 nov. Manda logs_qas22.py a la VM de QA y guarda la salida. Solo lectura. Pide la contrasena de la VM una vez.
set -u
cd "$(dirname "$0")/.."
SAL="qa_qas_23nov/evidencia/qas22_logs_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
echo "Se pide la contrasena de la VM de QA:"
ssh -o ConnectTimeout=15 estudiante@10.43.100.141 'f=$(mktemp); cat > "$f"; python3 -u "$f" </dev/null; r=$?; rm -f "$f"; exit $r' < qa_qas_23nov/logs_qas22.py 2>&1 | tee "$SAL"
echo "== salida guardada en $SAL"

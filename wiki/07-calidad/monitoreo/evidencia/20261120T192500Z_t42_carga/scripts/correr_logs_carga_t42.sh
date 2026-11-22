#!/usr/bin/env bash
# SCRUM-1679 (T-42), 20 nov. Lee en QA los logs de la ventana de carga. Solo lectura. Pide la contrasena de la VM de QA una vez.
# Uso: bash qa_t42/correr_logs_carga_t42.sh
set -u
cd "$(dirname "$0")/.."
QA=estudiante@10.43.100.141
MARCA=$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z')
SAL="qa_t42/evidencia/logs_carga_${MARCA}.txt"
echo "Se pide la contrasena de la VM de QA (10.43.100.141):"
ssh -o ConnectTimeout=15 "$QA" 'python3 -' < qa_t42/logs_carga_qa_t42.py > "$SAL" 2>&1
echo "== Fin $(date -u +%H:%M:%SZ); salida en $SAL ($(wc -l < "$SAL") lineas)"

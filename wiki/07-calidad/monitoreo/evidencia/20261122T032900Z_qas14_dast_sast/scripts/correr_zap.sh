#!/usr/bin/env bash
# QAS-14 (resistencia), DAST con OWASP ZAP contra MANI-QA (Gateway 10.43.100.141:8080), corte del 22 nov.
#   baseline:  zap-baseline.py sobre la app web (spider + reglas pasivas; no ataca).
#   api [svc]: zap-api-scan.py (spider + escaneo activo) con el contrato OpenAPI de release (MANI-API ee5000c) de
#              core, dispatch y rules, con el servidor reescrito al Gateway de QA. Sin token: las escrituras dan 401
#              y no crean datos. 2 hilos por host y tope de 15 min por servicio para no cargar el QA compartido.
#   Los contratos se generan antes con el bloque de preparacion (servers -> http://10.43.100.141:8080/api/v1/<svc>).
# Uso: bash qa_zap/correr_zap.sh baseline | api [core|dispatch|rules]
set -u
cd "$(dirname "$0")"
IMG=ghcr.io/zaproxy/zaproxy:stable
GW=http://10.43.100.141:8080
MARCA=$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z')
mkdir -p salida
zap() { docker run --rm -v "$PWD:/zap/wrk:rw" "$IMG" "$@"; }
case "${1:-}" in
baseline)
  zap zap-baseline.py -t "$GW/" -m 3 -I -j \
    -r "salida/zap_baseline_${MARCA}.html" -J "salida/zap_baseline_${MARCA}.json" 2>&1 | tee "salida/zap_baseline_${MARCA}.txt"
  ;;
api)
  for svc in ${2:-core dispatch rules}; do
    echo "== API $svc $(date -u +%TZ)"
    zap zap-api-scan.py -t "/zap/wrk/contratos/$svc.yaml" -f openapi -I \
      -z "-config scanner.threadPerHost=2 -config scanner.maxScanDurationInMins=15 -config scanner.maxRuleDurationInMins=3" \
      -r "salida/zap_api_${svc}_${MARCA}.html" -J "salida/zap_api_${svc}_${MARCA}.json" 2>&1 | tee "salida/zap_api_${svc}_${MARCA}.txt"
  done
  ;;
*) echo "Uso: bash qa_zap/correr_zap.sh baseline | api [core|dispatch|rules]"; exit 1 ;;
esac

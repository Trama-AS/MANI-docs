#!/usr/bin/env bash
# D-T43-1: busca en los logs del Core de QA los correlationId del 500 de verificación KYC.
# Uso: bash qa_t43/revisar_logs_d_t43_1.sh   (pide la contraseña SSH)
set -euo pipefail
salida="qa_t43/evidencia/d_t43_1_logs_core_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
ssh estudiante@10.43.100.141 'bash -s' <<'REMOTO' \
  | sed -E 's/eyJ[A-Za-z0-9._-]+/<token>/g; s/(password|secret|key|authorization)([^,}]{0,6})[:=][^,} ]+/\1\2=<oculto>/Ig' \
  | tee "$salida"
C=mani-core-service
echo "== contenedor =="; docker ps --filter name=$C --format '{{.Names}} {{.Image}} {{.Status}}'
for id in c8a271e6-ba48-4b83-8738-20a3cce029ec 6ee02b95-cb27-4f86-a61e-99b53289ada0; do
  echo; echo "== correlationId $id =="
  docker logs --since 6h $C 2>&1 | grep -n -B3 -A25 "$id" | head -80 || echo "(sin coincidencias)"
done
echo; echo "== KYC / documentos (últimas 6 h) =="
docker logs --since 6h $C 2>&1 | grep -iE "kyc|documento|storage|bucket" | tail -40 || true
echo; echo "== variables de almacenamiento definidas (solo nombres) =="
docker exec $C sh -c 'env | cut -d= -f1 | grep -iE "storage|bucket|supabase|s3|kyc" | sort' || true
REMOTO
echo; echo "Guardado en $salida"

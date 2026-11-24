#!/usr/bin/env bash
# SCRUM-1678 (T-41). QAS-20, revision acotada del codigo de Dispatch: busca en la revision desplegada en QA
# los nombres de tablas que no son de Dispatch dentro de SQL (FROM, JOIN, INTO, UPDATE, DELETE FROM).
# Local, solo lectura sobre git (no cambia la rama ni el arbol de trabajo).
# Uso: bash qa_t41/qas20_tablas_core_en_dispatch.sh [revision]   (por defecto 930a15b, la desplegada en QA el 5-nov)
set -u
cd "$(dirname "$0")/.."
REV=${1:-930a15b}
REPO=MANI-.NET
mkdir -p qa_t41/evidencia
SALIDA=qa_t41/evidencia/qas20_codigo_dispatch_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt
# Tablas de Core (GRANT de la 0007 a mani_core_svc) y otras ajenas a Dispatch
CORE='usuario|categoria_servicio|aliado|cliente|sitio|aliado_categoria|cobertura_aliado|documento_kyc|tarifa_referencia|cotizacion|mensaje|evento_servicio|calificacion|notificacion|pago|documento_legal|consentimiento_usuario|aliado_ausencia|solicitud_foto|regla_tenant|queja|outbox_evento'
# Tablas que Dispatch puede tocar segun ADR-0030 y 6A: solicitud (lectura), solicitud_rechazo (lectura y alta), tenant y zona (lectura)
PERMITIDAS='solicitud|solicitud_rechazo|tenant|zona'
{
echo "== QAS-20 codigo de Dispatch en $REPO@$(git -C "$REPO" rev-parse --short "$REV") ($(date -u +%FT%TZ))"
echo "-- archivos .cs fuera de pruebas: $(git -C "$REPO" ls-tree -r --name-only "$REV" | grep -E '\.cs$' | grep -vic test)"
echo "-- uso de tablas ajenas en SQL (archivo:linea: texto)"
git -C "$REPO" grep -n -i -E "(from|join|into|update|delete from)[[:space:]]+(public\.)?\"?($CORE)\"?([[:space:]]|$|[;,)\"])" "$REV" -- '*.cs' '*.sql' \
    ':(exclude)*Test*' ':(exclude)*test*' ':(exclude)*migrations*' | sed -E "s#^$REV:##" || echo "   (ninguno)"
echo "-- uso de tablas permitidas en SQL (para contrastar)"
git -C "$REPO" grep -n -i -E "(from|join|into|update|delete from)[[:space:]]+(public\.)?\"?($PERMITIDAS)\"?([[:space:]]|$|[;,)\"])" "$REV" -- '*.cs' '*.sql' \
    ':(exclude)*Test*' ':(exclude)*test*' ':(exclude)*migrations*' | sed -E "s#^$REV:##" | cut -c1-200 || echo "   (ninguno)"
} | tee "$SALIDA"
echo "== salida guardada en $SALIDA"

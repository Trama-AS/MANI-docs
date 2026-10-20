#!/usr/bin/env bash
# =====================================================================
# MANI - Obtiene el token de prueba para las corridas de SCRUM-1266
# =====================================================================
# Escribe el token en un archivo fuera del repositorio (chmod 600) y
# nunca lo imprime. Los scripts de medicion lo leen de ARCHIVO_TOKEN.
#
# FUENTE_TOKEN (obligatoria):
#   supabase   password grant contra el proyecto Supabase de QA.
#              Requiere SUPABASE_URL, SUPABASE_ANON_KEY, QA_EMAIL y
#              QA_PASSWORD. El Core desplegado en QA solo valida HS*,
#              y MANI-QA firma con ES256: hoy este camino da 401.
#   dev_token  POST /api/v1/core/auth/dev-token del Gateway de QA.
#              Usa el defecto registrado en el informe (endpoint
#              publico que firma para cualquier tenant). Toda corrida
#              con esta fuente se declara asi en la evidencia.
#
# Variables opcionales:
#   BASE_URL       Gateway de QA (por defecto http://10.43.100.141)
#   TENANT_ID      tenant del token dev_token (por defecto tenant_t2)
#   USER_ID        sub del token dev_token
#   ROL            user_role del token dev_token (por defecto cliente)
#   VIGENCIA       vigencia del token dev_token (por defecto 2h)
#   ARCHIVO_TOKEN  destino (por defecto $HOME/.mani_qa/token.txt)
#
# Uso:
#   FUENTE_TOKEN=dev_token bash obtener_token.sh
# =====================================================================
set -euo pipefail

: "${FUENTE_TOKEN:?definir FUENTE_TOKEN=supabase o FUENTE_TOKEN=dev_token}"
BASE_URL=${BASE_URL:-http://10.43.100.141}
TENANT_ID=${TENANT_ID:-10000000-0000-4000-8000-000000000021}
USER_ID=${USER_ID:-30000000-0000-4000-8000-000000000022}
ROL=${ROL:-cliente}
VIGENCIA=${VIGENCIA:-2h}
ARCHIVO_TOKEN=${ARCHIVO_TOKEN:-$HOME/.mani_qa/token.txt}

mkdir -p "$(dirname "$ARCHIVO_TOKEN")"
chmod 700 "$(dirname "$ARCHIVO_TOKEN")"

extraer() {
  # Lee JSON por stdin e imprime el campo pedido; vacio si no existe.
  python3 -c 'import sys,json
try:
    print(json.load(sys.stdin).get(sys.argv[1], ""))
except Exception:
    print("")' "$1"
}

case "$FUENTE_TOKEN" in
  supabase)
    : "${SUPABASE_URL:?falta SUPABASE_URL}"
    : "${SUPABASE_ANON_KEY:?falta SUPABASE_ANON_KEY}"
    : "${QA_EMAIL:?falta QA_EMAIL}"
    : "${QA_PASSWORD:?falta QA_PASSWORD}"
    export QA_EMAIL QA_PASSWORD
    cuerpo=$(python3 -c 'import json,os;print(json.dumps({"email":os.environ["QA_EMAIL"],"password":os.environ["QA_PASSWORD"]}))')
    respuesta=$(curl -s -m 15 -X POST "$SUPABASE_URL/auth/v1/token?grant_type=password" \
      -H "apikey: $SUPABASE_ANON_KEY" -H "Content-Type: application/json" -d "$cuerpo")
    token=$(printf '%s' "$respuesta" | extraer access_token)
    ;;
  dev_token)
    export TENANT_ID USER_ID ROL VIGENCIA
    cuerpo=$(python3 -c 'import json,os;print(json.dumps({"tenantId":os.environ["TENANT_ID"],"userId":os.environ["USER_ID"],"role":os.environ["ROL"],"expiresIn":os.environ["VIGENCIA"]}))')
    respuesta=$(curl -s -m 15 -X POST "$BASE_URL/api/v1/core/auth/dev-token" \
      -H "Content-Type: application/json" -H "X-Correlation-ID: qa1266-obtener-token" -d "$cuerpo")
    token=$(printf '%s' "$respuesta" | extraer token)
    ;;
  *)
    echo "FUENTE_TOKEN no valida: $FUENTE_TOKEN" >&2
    exit 2
    ;;
esac

if [ -z "$token" ]; then
  echo "No se obtuvo token con FUENTE_TOKEN=$FUENTE_TOKEN" >&2
  exit 1
fi

umask 077
printf '%s' "$token" > "$ARCHIVO_TOKEN"
printf '%s' "$FUENTE_TOKEN" > "$ARCHIVO_TOKEN.fuente"

# Solo metadatos del token: algoritmo, tenant, rol y vigencia.
printf '%s' "$token" | python3 -c 'import sys,base64,json
partes = sys.stdin.read().split(".")
dec = lambda s: json.loads(base64.urlsafe_b64decode(s + "=" * (-len(s) % 4)))
cabecera, cuerpo = dec(partes[0]), dec(partes[1])
meta = cuerpo.get("app_metadata", {})
print("token_ok alg=%s tenant_id=%s user_role=%s vigencia_s=%s" % (
    cabecera.get("alg"), meta.get("tenant_id"), meta.get("user_role"),
    cuerpo.get("exp", 0) - cuerpo.get("iat", 0)))'
echo "fuente_token=$FUENTE_TOKEN archivo=$ARCHIVO_TOKEN"

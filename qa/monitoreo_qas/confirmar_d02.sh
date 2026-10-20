#!/usr/bin/env bash
# Confirmacion de D-02 (SCRUM-1266): login real en MANI-QA y llamada por el Gateway de QA.
# Pide la anon key, el correo y la contrasena con entrada oculta. No imprime el token.
set -uo pipefail
SUPABASE_URL=https://hpsxdotaizzclkeufzct.supabase.co
GATEWAY=http://10.43.100.141

printf 'Anon key de MANI-QA (oculta): ' > /dev/tty; read -rs ANON < /dev/tty; echo > /dev/tty
printf 'Correo del usuario de prueba: ' > /dev/tty; read -r CORREO < /dev/tty
printf 'Contrasena del usuario de prueba (oculta): ' > /dev/tty; read -rs CLAVE < /dev/tty; echo > /dev/tty
export CORREO CLAVE

echo "fecha_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ) host=$(hostname) usuario=$CORREO"
cuerpo=$(python3 -c 'import json,os;print(json.dumps({"email":os.environ["CORREO"],"password":os.environ["CLAVE"]}))')
respuesta=$(curl -s -m 15 -w '\n%{http_code}' -X POST "$SUPABASE_URL/auth/v1/token?grant_type=password" \
  -H "apikey: $ANON" -H "Content-Type: application/json" -d "$cuerpo")
codigo_login=$(printf '%s' "$respuesta" | tail -1)
token=$(printf '%s' "$respuesta" | sed '$d' | python3 -c 'import sys,json
try: print(json.load(sys.stdin).get("access_token",""))
except Exception: print("")')
unset CLAVE ANON cuerpo
echo "1 login MANI-QA: HTTP=$codigo_login token_obtenido=$([ -n "$token" ] && echo si || echo no)"
if [ -z "$token" ]; then
  printf '%s' "$respuesta" | sed '$d' | python3 -c 'import sys,json
try:
    j=json.load(sys.stdin); print("  error_login=%s %s" % (j.get("error_code") or j.get("error"), j.get("msg") or j.get("error_description")))
except Exception: print("  respuesta no JSON")'
  exit 1
fi

printf '%s' "$token" | python3 -c 'import sys,base64,json
p=sys.stdin.read().split(".")
d=lambda s: json.loads(base64.urlsafe_b64decode(s+"="*(-len(s)%4)))
h,b=d(p[0]),d(p[1]); m=b.get("app_metadata",{})
print("2 token: alg=%s kid=%s iss=%s app_metadata.tenant_id=%s user_role=%s" % (h.get("alg"), str(h.get("kid"))[:8], b.get("iss"), m.get("tenant_id"), m.get("user_role") or m.get("rol")))'

for ruta in /api/v1/core/profiles/me /api/v1/rules/evaluate-rate /api/v1/dispatch/match; do
  metodo=GET; [ "$ruta" != "/api/v1/core/profiles/me" ] && metodo=POST
  salida=$(curl -s -m 10 -w ' HTTP=%{http_code}' -X $metodo -H "Authorization: Bearer $token" \
    -H 'Content-Type: application/json' -H "X-Correlation-ID: qa1266-d02-$(date +%s)" \
    $([ $metodo = POST ] && echo "-d {}") "$GATEWAY$ruta")
  echo "3 $metodo $ruta por el Gateway con el token real: $(printf '%s' "$salida" | python3 -c 'import sys,re
t=sys.stdin.read(); m=re.search(r" HTTP=(\d+)$",t); b=t[:m.start()]
print("HTTP=%s cuerpo=%s" % (m.group(1), re.sub(r"eyJ[\w.-]+","<REDACTADO>",b)[:200]))')"
done
unset token
echo "fin"

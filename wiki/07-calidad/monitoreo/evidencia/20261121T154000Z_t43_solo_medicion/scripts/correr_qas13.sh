#!/usr/bin/env bash
# SCRUM-1680 (T-43), QAS-13. Dos pasos, separados por la vigencia del token de Supabase (1 h):
#   obtener: login real de cliente.t1 en Supabase de QA (desde la VM de QA, con la clave de la semilla de CFG-04),
#            registra alg y respuesta de una ruta protegida con el token vigente, y guarda el token en el
#            scratchpad con permisos 600 para usarlo vencido. Pide la contrasena de la VM de QA.
#   probar:  con el token ya vencido, corre qa_t43/qas13_tokens.py por el Gateway (sin SSH) y borra el token.
# No imprime tokens ni claves. Uso: bash qa_t43/correr_qas13.sh obtener|probar
set -u
cd "$(dirname "$0")/.."
MODO=${1:-}
TOK="${QAS13_TOKEN:-${TMPDIR:-/tmp}/qas13_token_vencer.json}"
QA=estudiante@10.43.100.141
mkdir -p qa_t43/evidencia
MARCA=$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z')

case "$MODO" in
obtener)
  SAL="qa_t43/evidencia/qas13_login_real_${MARCA}.txt"
  patron=$(sed -nE 's/^CLAVE_CFG04=\$\(git -C MANI-API show origin\/release:supabase\/seed\/seed_qa_multitenant.sql \| (.*)\)$/\1/p' qa_s5_corte2/correr_varios.sh)
  CLAVE_CFG04=$(git -C MANI-API show origin/release:supabase/seed/seed_qa_multitenant.sql | bash -c "$patron")
  [ -n "$CLAVE_CFG04" ] || { echo "No se encontro la contrasena de CFG-04 en su semilla."; exit 1; }
  echo "Se pide la contrasena de la VM de QA (10.43.100.141):"
  TOKEN=$(printf '%s' "$CLAVE_CFG04" | ssh -o ConnectTimeout=15 "$QA" 'python3 -c "
import json, re, sys, urllib.request
clave = sys.stdin.read()
env = {}
for l in open(\"/opt/mani/.env.qa\", encoding=\"utf8\"):
    m = re.match(r\"^([A-Za-z_][A-Za-z0-9_]*)=(.*)$\", l.strip())
    if m:
        env[m.group(1)] = m.group(2).strip().strip(chr(39) + chr(34))
anon = next(env[n] for n in (\"SUPABASE_ANON_KEY\", \"SUPABASE_KEY\", \"ANON_KEY\", \"SUPABASE_PUBLISHABLE_KEY\") if env.get(n))
req = urllib.request.Request(env[\"SUPABASE_URL\"].rstrip(\"/\") + \"/auth/v1/token?grant_type=password\", data=json.dumps({\"email\": \"cliente.t1@qa.mani.test\", \"password\": clave}).encode(), headers={\"Content-Type\": \"application/json\", \"apikey\": anon})
print(json.load(urllib.request.urlopen(req, timeout=30))[\"access_token\"])
"')
  unset CLAVE_CFG04
  [ -n "$TOKEN" ] || { echo "No se obtuvo token."; exit 1; }
  umask 077
  printf '{"access_token": "%s"}' "$TOKEN" > "$TOK"
  chmod 600 "$TOK"
  {
    echo "== QAS-13 login real $(date -u +%FT%TZ)"
    TOKEN_QAS13="$TOKEN" python3 - <<'PY'
import base64, json, os, time
p = os.environ["TOKEN_QAS13"].split(".")
d = lambda s: json.loads(base64.urlsafe_b64decode(s + "=" * (-len(s) % 4)))
h, c = d(p[0]), d(p[1])
am = c.get("app_metadata", {})
print(f"  cuenta cliente.t1@qa.mani.test; alg={h.get('alg')}; kid presente={'kid' in h}; vigencia={(c['exp']-c['iat'])//60} min; vence {time.strftime('%H:%M:%SZ', time.gmtime(c['exp']))}")
print(f"  claims de MANI presentes: tenant_id={'tenant_id' in c or 'tenant_id' in am}; rol={'user_role' in c or 'user_role' in am}")
PY
    for r in /api/v1/core/profiles/me /api/v1/core/solicitudes/me; do
      printf '  GET %s con token vigente: ' "$r"
      curl -s -o /dev/null -m 20 -w '%{http_code}\n' -H "Authorization: Bearer $TOKEN" -H "X-Correlation-ID: qas13-t43-login" "http://10.43.100.141:8080$r"
    done
  } | tee "$SAL"
  unset TOKEN
  echo "== token guardado en el scratchpad (600). Correr 'probar' despues de la hora de vencimiento."
  echo "== salida guardada en $SAL"
  ;;
probar)
  [ -f "$TOK" ] || { echo "No hay token guardado; correr primero: bash qa_t43/correr_qas13.sh obtener"; exit 1; }
  SAL="qa_t43/evidencia/qas13_tokens_${MARCA}.txt"
  python3 qa_t43/qas13_tokens.py "$TOK" 2>&1 | tee "$SAL"
  r=${PIPESTATUS[0]}
  if grep -q '^ABORTA' "$SAL"; then rm -f "$SAL"; echo "== no se guarda salida: el token vence a la hora indicada arriba (UTC)"; exit 1; fi
  [ "$r" = 0 ] && rm -f "$TOK" && echo "== token borrado"
  echo "== salida guardada en $SAL"
  ;;
probar_vigente)
  # Ausente, firma alterada y otro emisor no necesitan esperar; el token vigente se conserva para el caso vencido.
  [ -f "$TOK" ] || { echo "No hay token guardado; correr primero: bash qa_t43/correr_qas13.sh obtener"; exit 1; }
  SAL="qa_t43/evidencia/qas13_tokens_vigente_${MARCA}.txt"
  QAS13_CASOS=ausente,firma_alterada,otro_emisor_es256 python3 qa_t43/qas13_tokens.py "$TOK" 2>&1 | tee "$SAL"
  echo "== salida guardada en $SAL; el token se conserva para 'probar' cuando venza"
  ;;
*) echo "Uso: bash qa_t43/correr_qas13.sh obtener|probar_vigente|probar"; exit 1 ;;
esac

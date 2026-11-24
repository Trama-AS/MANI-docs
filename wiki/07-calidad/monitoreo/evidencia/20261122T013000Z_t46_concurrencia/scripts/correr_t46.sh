#!/usr/bin/env bash
# SCRUM-1683 (T-46), QAS-41 y conflicto de QAS-07: aceptacion concurrente sobre Dispatch real.
#   tokens:      login real (Supabase de QA, desde la VM) de cliente.t1 y aliado.t1 con la clave de la semilla
#                CFG-04, y de empleado_directo.t1 con la clave de la semilla de Sprint 5 que escribes tu.
#                Son los dos aliados verificados que atienden Plomeria en Suba (cobertura_aliados_22nov_0132z.txt).
#                Pide la contrasena de la VM una vez. Guarda los tokens en un archivo temporal con permisos 600.
#   rondas [R]:  R rondas (por defecto 5). En cada una: cliente.t1 crea una solicitud nueva por el Gateway,
#                k6 lanza 38 aceptaciones simultaneas repartidas entre los aliados, el ganador repite la suya
#                (idempotencia) y el cliente lee la solicitud para ver estado y aliado persistidos.
#                Entre rondas espera 62 s para que se recargue el limite de escrituras del Gateway. Sin SSH.
#   borrar:      borra el archivo de tokens.
# No imprime tokens ni claves. Uso: bash qa_t46/correr_t46.sh tokens|rondas [R]|borrar
set -u
cd "$(dirname "$0")/.."
MODO=${1:-}
TOK="${T46_TOKENS:-${TMPDIR:-/tmp}/t46_tokens.json}"
QA=estudiante@10.43.100.141
GW=http://10.43.100.141:8080
MARCA=$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z')
mkdir -p qa_t46/evidencia "$(dirname "$TOK")"

case "$MODO" in
tokens)
  CLAVE_CFG04=$(git -C MANI-API show origin/release:supabase/seed/seed_qa_multitenant.sql | sed -nE "s/.*'admin\.t1@qa\.mani\.test', *crypt\('([^']+)'.*/\1/p" | head -1)
  [ -n "$CLAVE_CFG04" ] || { echo "No se encontro la clave de CFG-04 en la semilla."; exit 1; }
  read -rsp "Clave de empleado_directo.t1@qa.mani.test (semilla de Sprint 5; probablemente la misma de aliado_empresa.t1): " CLAVE_EMP; echo
  echo "Ahora se pide la contrasena de la VM de QA (10.43.100.141):"
  umask 077
  printf '%s\n%s\n' "$CLAVE_CFG04" "$CLAVE_EMP" | ssh -o ConnectTimeout=15 "$QA" 'python3 -c "
import json, re, sys, urllib.request, urllib.error
cfg, emp = [l.rstrip(chr(10)) for l in sys.stdin.readlines()[:2]]
env = {}
for l in open(\"/opt/mani/.env.qa\", encoding=\"utf8\"):
    m = re.match(r\"^([A-Za-z_][A-Za-z0-9_]*)=(.*)$\", l.strip())
    if m:
        env[m.group(1)] = m.group(2).strip().strip(chr(39) + chr(34))
anon = next(env[n] for n in (\"SUPABASE_ANON_KEY\", \"SUPABASE_KEY\", \"ANON_KEY\", \"SUPABASE_PUBLISHABLE_KEY\") if env.get(n))
def login(correo, clave):
    req = urllib.request.Request(env[\"SUPABASE_URL\"].rstrip(\"/\") + \"/auth/v1/token?grant_type=password\", data=json.dumps({\"email\": correo, \"password\": clave}).encode(), headers={\"Content-Type\": \"application/json\", \"apikey\": anon})
    try:
        return json.load(urllib.request.urlopen(req, timeout=30))[\"access_token\"]
    except urllib.error.HTTPError as e:
        sys.stderr.write(\"login fallido %s: %s\n\" % (correo, e.code)); return None
out = {\"cliente\": {\"correo\": \"cliente.t1@qa.mani.test\", \"token\": login(\"cliente.t1@qa.mani.test\", cfg)}, \"aliados\": []}
for correo, clave in ((\"aliado.t1@qa.mani.test\", cfg), (\"empleado_directo.t1@qa.mani.test\", emp)):
    if clave:
        t = login(correo, clave)
        if t: out[\"aliados\"].append({\"correo\": correo, \"token\": t})
print(json.dumps(out))
"' > "$TOK"
  unset CLAVE_CFG04 CLAVE_EMP
  chmod 600 "$TOK"
  python3 - "$TOK" "$GW" <<'PY'
import json, sys, urllib.request, urllib.error, base64, time
d = json.load(open(sys.argv[1])); gw = sys.argv[2]
def get(tok, ruta):
    r = urllib.request.Request(gw + ruta, headers={"Authorization": "Bearer " + tok, "X-Correlation-ID": "qa-t46-tokens"})
    try:
        with urllib.request.urlopen(r, timeout=30) as x: return x.status, json.load(x)
    except urllib.error.HTTPError as e: return e.code, {}
if not d["cliente"]["token"]: sys.exit("Sin token de cliente.t1")
c = json.loads(base64.urlsafe_b64decode(d["cliente"]["token"].split(".")[1] + "=="))
print(f"tokens: cliente.t1 y {len(d['aliados'])} aliados; vencen {time.strftime('%H:%M:%SZ', time.gmtime(c['exp']))}")
for a in d["aliados"]:
    s, b = get(a["token"], "/api/v1/core/profiles/me")
    perfil = b.get("perfil") or b.get("profile") or b
    campos = {k: v for k, v in perfil.items() if isinstance(v, str) and any(p in k.lower() for p in ("rol", "role", "estado", "status", "verific"))}
    print(f"  {a['correo']}: profiles/me {s} {campos}")
PY
  ;;
rondas)
  R=${2:-5}
  [ -s "$TOK" ] || { echo "No hay tokens; correr primero: bash qa_t46/correr_t46.sh tokens"; exit 1; }
  SAL="qa_t46/evidencia/qas41_rondas_${MARCA}.txt"
  {
    echo "== T-46 QAS-41 $(date -u +%FT%TZ), $R rondas, Gateway $GW"
    k6 version | head -1
    for i in $(seq 1 "$R"); do
      [ "$i" -gt 1 ] && { echo "-- espera 62 s (limite de escrituras del Gateway)"; sleep 62; }
      echo "== Ronda $i $(date -u +%TZ)"
      SID=$(python3 - "$TOK" "$GW" "$i" <<'PY'
import json, os, sys, urllib.request, urllib.error, uuid
tok = json.load(open(sys.argv[1]))["cliente"]["token"]; gw = sys.argv[2]; ronda = sys.argv[3]
def req(metodo, ruta, cuerpo=None):
    r = urllib.request.Request(gw + ruta, method=metodo, data=json.dumps(cuerpo).encode() if cuerpo else None,
        headers={"Authorization": "Bearer " + tok, "Content-Type": "application/json", "X-Correlation-ID": f"qa-t46-crear-{ronda}"})
    try:
        with urllib.request.urlopen(r, timeout=30) as x: return x.status, json.load(x)
    except urllib.error.HTTPError as e:
        return e.code, json.loads(e.read() or b"{}")
def lista(b):
    if isinstance(b, list): return b
    for v in b.values():
        if isinstance(v, list): return v
    return []
_, cats = req("GET", "/api/v1/core/solicitudes/categorias"); cats = lista(cats)
_, sitios = req("GET", "/api/v1/core/solicitudes/sitios"); sitios = lista(sitios)
cat = next((c for c in cats if "plomer" in str(c.get("nombre") or c.get("name") or "").lower()), cats[0] if cats else None)
sitio_id = os.environ.get("T46_SITIO", "95ec8352-ad14-4bed-a613-e22d23a72a3a")  # Niza, dentro de Suba
sitio = next((x for x in sitios if x.get("id") == sitio_id), None)
if not cat or not sitio: sys.stderr.write(f"sin categoria o sitio (categorias {len(cats)}, sitios {len(sitios)})\n"); sys.exit(1)
cuerpo = {"categoriaId": cat["id"], "sitioId": sitio["id"], "claveIdempotencia": str(uuid.uuid4()),
          "descripcion": f"Prueba QA T-46 ronda {ronda}: aceptacion concurrente de aliados, no atender."}
s, b = req("POST", "/api/v1/core/solicitudes", cuerpo)
sol = b.get("solicitud") or {}
sys.stderr.write(f"crear solicitud: {s}, categoria {cat.get('nombre') or cat.get('name')}, sitio {sitio_id[:8]} ({sitio.get('zona')}), estado {sol.get('estado')}\n")
if s not in (200, 201) or not sol.get("id"): sys.exit(1)
# Mismo paso que la app (avisarAliados): Dispatch transmite la oferta a los aliados elegibles.
r = urllib.request.Request(gw + "/api/v1/dispatch/requests/orchestrate", method="POST",
    data=json.dumps({"requestId": sol["id"]}).encode(),
    headers={"Authorization": "Bearer " + tok, "Content-Type": "application/json",
             "Idempotency-Key": str(uuid.uuid4()), "X-Correlation-ID": f"qa-t46-orquestar-{ronda}"})
try:
    with urllib.request.urlopen(r, timeout=30) as x: so, bo = x.status, json.load(x)
except urllib.error.HTTPError as e: so, bo = e.code, json.loads(e.read() or b"{}")
resumen = {k: v for k, v in bo.items() if isinstance(v, (int, str, bool)) and k not in ("message", "timestamp", "correlationId")}
sys.stderr.write(f"orquestar (ofertas): {so} {json.dumps(resumen, ensure_ascii=False)}\n")
if so not in (200, 201, 202): sys.exit(1)
print(sol["id"])
PY
) || { echo "No se pudo crear la solicitud; se detiene."; break; }
      echo "solicitud $SID"
      sleep 2
      k6 run --quiet --no-color -e N="${T46_N:-37}" -e SOLICITUD_ID="$SID" -e ARCHIVO_TOKENS="$TOK" -e RONDA="$i" \
        -e SALIDA="qa_t46/evidencia/qas41_ronda${i}_${MARCA}.json" qa_t46/k6_qas41_aceptacion.js 2>&1 \
        | sed -nE 's/.*msg="((RESULTADO|REINTENTO).*)" source=console/\1/p; /^ronda=/p; /thresholds .* crossed/p' | sed 's/\\"/"/g'
      python3 - "$TOK" "$GW" "$SID" <<'PY'
import json, sys, urllib.request, urllib.error
tok = json.load(open(sys.argv[1]))["cliente"]["token"]; gw, sid = sys.argv[2], sys.argv[3]
r = urllib.request.Request(f"{gw}/api/v1/core/solicitudes/me/{sid}", headers={"Authorization": "Bearer " + tok, "X-Correlation-ID": "qa-t46-leer"})
try:
    with urllib.request.urlopen(r, timeout=30) as x: s, b = x.status, json.load(x)
except urllib.error.HTTPError as e: s, b = e.code, {}
sol = b.get("solicitud") or b
campos = {k: v for k, v in sol.items() if any(p in k.lower() for p in ("estado", "status", "aliado", "ally", "asign"))}
print(f"persistido (cliente lee su solicitud): {s} {json.dumps(campos, ensure_ascii=False)}")
PY
    done
    echo "== fin $(date -u +%TZ)"
  } 2>&1 | tee "$SAL"
  echo "== salida guardada en $SAL"
  ;;
borrar) rm -f "$TOK" && echo "tokens borrados" ;;
*) echo "Uso: bash qa_t46/correr_t46.sh tokens|rondas [R]|borrar"; exit 1 ;;
esac

#!/usr/bin/env bash
# QAS-11 (no repudio), QAS-37 (restriccion operativa) y QAS-42 (idempotencia) en MANI-QA, corte del 22 nov.
#   tokens:     login real (Supabase de QA, desde la VM) de cliente.t1 y aliado.t1 con la clave de la semilla CFG-04.
#               Pide la contrasena de la VM una vez. Tokens en el scratchpad con permisos 600.
#   probar:     por el Gateway (8080). Sobre la solicitud 6ef93e76 de T-46 (ASIGNADA a aliado.t1):
#               cotizacion, segunda cotizacion (409P), pago de cotizacion pendiente (409E), aceptacion, segunda
#               respuesta (409R), cotizar una solicitud ACEPTADA (409E), pago sandbox (mock, sin dinero real),
#               reintento del pago (200), misma clave con otro escenario (409K) y otro pago (409A).
#               Con una solicitud nueva: creacion idempotente (200 mismo id), misma clave con otro cuerpo (409K),
#               cancelacion, segunda cancelacion (409C), aceptar y cotizar la cancelada.
#               Despues de cada rechazo lee el estado persistido para ver que no cambio. ~16 escrituras, bajo el limite.
#   verificar:  por SSH y el contenedor del Core, transaccion que se revierte: filas de pago, evento_servicio y
#               transaccion_evento de la prueba (actor, rol, correlation ID), y los intentos de UPDATE, DELETE y
#               TRUNCATE sobre esos registros.
#   borrar:     borra tokens y estado.
# No imprime tokens ni claves. Uso: bash qa_barrido/correr_qas11_37_42.sh tokens|probar|verificar|borrar
set -u
cd "$(dirname "$0")/.."
MODO=${1:-}
SCR=/private/tmp/claude-501/-Users-santiagohernandezbarbosa-Desktop-Universidad-8-semestre-Proyecto-Mani/53648705-d1ec-4f11-bcd4-060aef7ca8f3/scratchpad
TOK="$SCR/qas11_tokens.json"
EST="$SCR/qas11_estado.json"
QA=estudiante@10.43.100.141
GW=http://10.43.100.141:8080
MARCA=$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z')
mkdir -p qa_barrido/evidencia "$SCR"

case "$MODO" in
tokens)
  CLAVE_CFG04=$(git -C MANI-API show origin/release:supabase/seed/seed_qa_multitenant.sql | sed -nE "s/.*'admin\.t1@qa\.mani\.test', *crypt\('([^']+)'.*/\1/p" | head -1)
  [ -n "$CLAVE_CFG04" ] || { echo "No se encontro la clave de CFG-04 en la semilla."; exit 1; }
  echo "Ahora se pide la contrasena de la VM de QA (10.43.100.141):"
  umask 077
  printf '%s\n' "$CLAVE_CFG04" | ssh -o ConnectTimeout=15 "$QA" 'python3 -c "
import json, re, sys, urllib.request, urllib.error
cfg = sys.stdin.readline().rstrip(chr(10))
env = {}
for l in open(\"/opt/mani/.env.qa\", encoding=\"utf8\"):
    m = re.match(r\"^([A-Za-z_][A-Za-z0-9_]*)=(.*)$\", l.strip())
    if m:
        env[m.group(1)] = m.group(2).strip().strip(chr(39) + chr(34))
anon = next(env[n] for n in (\"SUPABASE_ANON_KEY\", \"SUPABASE_KEY\", \"ANON_KEY\", \"SUPABASE_PUBLISHABLE_KEY\") if env.get(n))
def login(correo):
    req = urllib.request.Request(env[\"SUPABASE_URL\"].rstrip(\"/\") + \"/auth/v1/token?grant_type=password\", data=json.dumps({\"email\": correo, \"password\": cfg}).encode(), headers={\"Content-Type\": \"application/json\", \"apikey\": anon})
    try:
        return json.load(urllib.request.urlopen(req, timeout=30))[\"access_token\"]
    except urllib.error.HTTPError as e:
        sys.stderr.write(\"login fallido %s: %s\n\" % (correo, e.code)); return None
print(json.dumps({\"cliente\": login(\"cliente.t1@qa.mani.test\"), \"aliado\": login(\"aliado.t1@qa.mani.test\")}))
"' > "$TOK"
  unset CLAVE_CFG04
  chmod 600 "$TOK"
  python3 -c "import json,sys; d=json.load(open(sys.argv[1])); print('tokens:', {k: bool(v) for k, v in d.items()})" "$TOK"
  ;;
probar)
  [ -s "$TOK" ] || { echo "No hay tokens; correr primero: bash qa_barrido/correr_qas11_37_42.sh tokens"; exit 1; }
  SAL="qa_barrido/evidencia/qas11_37_42_api_${MARCA}.txt"
  python3 - "$TOK" "$GW" "$EST" "${QAS_SOLICITUD:-6ef93e76}" 2>&1 <<'PY' | tee "$SAL"
import json, sys, time, uuid, urllib.request, urllib.error
tok = json.load(open(sys.argv[1])); gw, est_path, prefijo = sys.argv[2], sys.argv[3], sys.argv[4]
CLI, ALI = tok["cliente"], tok["aliado"]
corrida = time.strftime("%H%M", time.gmtime())
casos = []

def req(token, metodo, ruta, cuerpo=None, corr="x", extra=None):
    h = {"Authorization": "Bearer " + token, "X-Correlation-ID": f"qa-qas11-{corrida}-{corr}"}
    if cuerpo is not None: h["Content-Type"] = "application/json"
    h.update(extra or {})
    r = urllib.request.Request(gw + ruta, method=metodo, data=json.dumps(cuerpo).encode() if cuerpo is not None else None, headers=h)
    try:
        with urllib.request.urlopen(r, timeout=30) as x: return x.status, json.load(x)
    except urllib.error.HTTPError as e:
        try: return e.code, json.loads(e.read() or b"{}")
        except Exception: return e.code, {}

def codigo(b):
    if not isinstance(b, dict): return None
    e = b.get("error")
    return b.get("code") or b.get("error_code") or (e.get("code") if isinstance(e, dict) else e)

def estado_sol(sid):
    s, b = req(CLI, "GET", f"/api/v1/core/solicitudes/me/{sid}", corr="leer")
    sol = b.get("solicitud") or {}
    return sol.get("estado")

def caso(qas, nombre, esperado, s, b, antes=None, despues=None):
    cod = codigo(b)
    ok = s in esperado[0] and (esperado[1] is None or (cod or "").startswith(esperado[1]) or esperado[1] in json.dumps(b, ensure_ascii=False))
    if antes is not None: ok = ok and antes == despues
    linea = {"qas": qas, "caso": nombre, "status": s, "code": cod, "esperado": f"{'/'.join(map(str, esperado[0]))} {esperado[1] or ''}".strip(), "ok": ok}
    if antes is not None: linea["estado_antes"], linea["estado_despues"] = antes, despues
    msg = b.get("message") or b.get("mensaje")
    if msg and s >= 400: linea["mensaje"] = str(msg)[:140]
    casos.append(linea); print(json.dumps(linea, ensure_ascii=False)); return ok

print(f"== QAS-11/37/42 {time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}, Gateway {gw}, correlation qa-qas11-{corrida}-*")
_, lst = req(CLI, "GET", "/api/v1/core/solicitudes/me", corr="listar")
items = next((v for v in (lst.values() if isinstance(lst, dict) else []) if isinstance(v, list)), lst if isinstance(lst, list) else [])
s1 = next((x["id"] for x in items if str(x.get("id", "")).startswith(prefijo)), None)
if not s1: sys.exit(f"no se encontro la solicitud {prefijo} entre {len(items)} del cliente")
print(f"solicitud A {s1}: estado {estado_sol(s1)}")

# --- A: cotizacion, aceptacion y pago
s, b = req(ALI, "POST", f"/api/v1/core/solicitudes/{s1}/cotizaciones", {"valorManoObra": 120000, "valorMateriales": 30000}, "cotizar")
cot = (b.get("cotizacion") or b) if isinstance(b, dict) else {}
q1 = cot.get("id")
caso("37", "aliado cotiza la solicitud ASIGNADA", ([200, 201], None), s, b)
if not q1: sys.exit("sin cotizacion; se detiene")
print(f"cotizacion {q1}: estado solicitud {estado_sol(s1)}")
a = estado_sol(s1); s, b = req(ALI, "POST", f"/api/v1/core/solicitudes/{s1}/cotizaciones", {"valorManoObra": 1000, "valorMateriales": 0}, "cotizar2")
caso("37", "segunda cotizacion con una pendiente", ([409], "MANI-COT-409P"), s, b, a, estado_sol(s1))
a = estado_sol(s1); s, b = req(CLI, "POST", "/api/v1/core/pagos", {"cotizacionId": q1, "claveIdempotencia": str(uuid.uuid4())}, "pagar-pendiente")
caso("37", "pagar una cotizacion PENDIENTE", ([409], "MANI-PAG-409E"), s, b, a, estado_sol(s1))
s, b = req(CLI, "POST", f"/api/v1/core/cotizaciones/{q1}/aceptar", {}, "aceptar-cot")
caso("37", "cliente acepta la cotizacion", ([200], None), s, b)
print(f"estado solicitud tras aceptar: {estado_sol(s1)}")
a = estado_sol(s1); s, b = req(CLI, "POST", f"/api/v1/core/cotizaciones/{q1}/rechazar", {"motivo": "prueba de transicion invalida"}, "rechazar-aceptada")
caso("37", "rechazar una cotizacion ya ACEPTADA", ([409], "MANI-COT-409R"), s, b, a, estado_sol(s1))
a = estado_sol(s1); s, b = req(ALI, "POST", f"/api/v1/core/solicitudes/{s1}/cotizaciones", {"valorManoObra": 1000, "valorMateriales": 0}, "cotizar-aceptada")
caso("37", "cotizar una solicitud ACEPTADA", ([409], "MANI-COT-409E"), s, b, a, estado_sol(s1))
k_pago = str(uuid.uuid4())
s, b = req(CLI, "POST", "/api/v1/core/pagos", {"cotizacionId": q1, "claveIdempotencia": k_pago, "escenario": "APROBADO"}, "pagar")
pago = b.get("pago") or {}
caso("11", "pago sandbox APROBADO (mock, sin dinero real)", ([201], None), s, b)
print(f"pago {pago.get('id')}: estado {pago.get('estado')}, simulado {pago.get('simulado')}, proveedor {pago.get('proveedor')}, monto {pago.get('monto')}")
s, b = req(CLI, "POST", "/api/v1/core/pagos", {"cotizacionId": q1, "claveIdempotencia": k_pago, "escenario": "APROBADO"}, "pagar-reintento")
mismo = (b.get("pago") or {}).get("id") == pago.get("id")
caso("42", f"reintento del pago, misma clave y cuerpo (mismo id: {mismo})", ([200], None), s, b)
casos[-1]["ok"] = casos[-1]["ok"] and mismo
s, b = req(CLI, "POST", "/api/v1/core/pagos", {"cotizacionId": q1, "claveIdempotencia": k_pago, "escenario": "RECHAZADO"}, "pagar-otro-cuerpo")
caso("42", "pago con la misma clave y otro escenario", ([409], "MANI-PAG-409K"), s, b)
a = estado_sol(s1); s, b = req(CLI, "POST", "/api/v1/core/pagos", {"cotizacionId": q1, "claveIdempotencia": str(uuid.uuid4())}, "pagar-doble")
caso("37", "segundo pago con otra clave sobre cotizacion pagada", ([409], "MANI-PAG-409A"), s, b, a, estado_sol(s1))

# --- B: creacion idempotente, cancelacion y transiciones sobre una CANCELADA
_, cats = req(CLI, "GET", "/api/v1/core/solicitudes/categorias", corr="cat")
cats = next((v for v in cats.values() if isinstance(v, list)), []) if isinstance(cats, dict) else cats
cat = next((c for c in cats if "plomer" in str(c.get("nombre") or "").lower()), cats[0])
k_sol = str(uuid.uuid4())
cuerpo = {"categoriaId": cat["id"], "sitioId": "95ec8352-ad14-4bed-a613-e22d23a72a3a", "claveIdempotencia": k_sol,
          "descripcion": "Prueba QA QAS-37/42: idempotencia y cancelacion, no atender."}
s, b = req(CLI, "POST", "/api/v1/core/solicitudes", cuerpo, "crear")
s2 = (b.get("solicitud") or {}).get("id")
caso("42", "crear solicitud con clave de idempotencia", ([201, 200], None), s, b)
if not s2: sys.exit("sin solicitud B; se detiene")
s, b = req(CLI, "POST", "/api/v1/core/solicitudes", cuerpo, "crear-reintento")
mismo = (b.get("solicitud") or {}).get("id") == s2
caso("42", f"reintento: misma clave y cuerpo (mismo id: {mismo})", ([200, 201], None), s, b)
casos[-1]["ok"] = casos[-1]["ok"] and mismo
s, b = req(CLI, "POST", "/api/v1/core/solicitudes", dict(cuerpo, descripcion=cuerpo["descripcion"] + " Otro cuerpo."), "crear-otro-cuerpo")
caso("42", "misma clave con otra descripcion", ([409], "MANI-SOL-409K"), s, b)
s, b = req(CLI, "PATCH", f"/api/v1/core/solicitudes/me/{s2}/cancelar", {"motivo": "prueba QA de transiciones"}, "cancelar")
caso("37", "cancelar solicitud PENDIENTE", ([200], None), s, b)
a = estado_sol(s2); s, b = req(CLI, "PATCH", f"/api/v1/core/solicitudes/me/{s2}/cancelar", {"motivo": "otra vez"}, "cancelar2")
caso("37", "cancelar una solicitud CANCELADA", ([409], "MANI-SOL-409C"), s, b, a, estado_sol(s2))
a = estado_sol(s2); s, b = req(ALI, "POST", f"/api/v1/dispatch/requests/{s2}/accept", None, "aceptar-cancelada")
caso("37", "aliado acepta una solicitud CANCELADA", ([403, 404, 409], None), s, b, a, estado_sol(s2))
a = estado_sol(s2); s, b = req(ALI, "POST", f"/api/v1/core/solicitudes/{s2}/cotizaciones", {"valorManoObra": 1000, "valorMateriales": 0}, "cotizar-cancelada")
caso("37", "aliado cotiza una solicitud CANCELADA sin asignar", ([403, 404, 409], None), s, b, a, estado_sol(s2))
ok = sum(c["ok"] for c in casos)
print(f"== resumen: {ok} de {len(casos)} casos como se esperaba")
json.dump({"corrida": corrida, "solicitud_a": s1, "solicitud_b": s2, "cotizacion": q1, "pago": pago.get("id")}, open(est_path, "w"))
PY
  echo "== salida guardada en $SAL"
  ;;
verificar)
  [ -s "$EST" ] || { echo "No hay estado; correr primero probar"; exit 1; }
  SAL="qa_barrido/evidencia/qas11_37_42_base_${MARCA}.txt"
  echo "Ahora se pide la contrasena de la VM de QA (10.43.100.141):"
  ssh -o ConnectTimeout=15 "$QA" "docker exec -i -e ESTADO='$(cat "$EST")' mani-core-service node" <<'JS' 2>&1 | tee "$SAL"
const { Client } = require('pg');
const T = '10000000-0000-4000-8000-000000000011';
const E = JSON.parse(process.env.ESTADO);
const c = new Client({ connectionString: process.env.DATABASE_URL, connectionTimeoutMillis: 10000, ssl: { rejectUnauthorized: false } });
const q = async (t, sql, p = []) => { try { const r = await c.query(sql, p); console.log(`-- ${t}`); console.table(r.rows); return r.rows; } catch (e) { console.log(`-- ${t}: ERROR ${e.code} ${e.message}`); return []; } };
(async () => {
  await c.connect();
  console.log(`== QAS-11/37/42 base de QA ${new Date().toISOString()} corrida ${E.corrida}`);
  await c.query('BEGIN');
  await c.query('SELECT app.set_context($1, NULL, $2)', [T, 'admin']).catch((e) => console.log('set_context:', e.message));
  await q('solicitudes de la prueba', `SELECT left(id::text,8) id, estado, (aliado_id IS NOT NULL) con_aliado FROM solicitud WHERE id = ANY($1::uuid[])`, [[E.solicitud_a, E.solicitud_b]]);
  await q('QAS-42: solicitudes con la descripcion de la prueba (debe ser 1)', `SELECT count(*)::int n FROM solicitud WHERE descripcion LIKE 'Prueba QA QAS-37/42%' AND created_at > now() - interval '2 hours'`);
  await q('cotizaciones de la solicitud A', `SELECT left(id::text,8) id, version, estado, valor_mano_obra, valor_materiales FROM cotizacion WHERE solicitud_id = $1`, [E.solicitud_a]);
  await q('QAS-11/42: pagos de la cotizacion (debe haber 1 APROBADO)', `SELECT left(id::text,8) id, estado, monto, simulado, proveedor, (cliente_id IS NOT NULL) cliente, correlation_id, (clave_idempotencia IS NOT NULL) clave, (huella_idempotencia IS NOT NULL) huella FROM pago WHERE cotizacion_id = $1`, [E.cotizacion]);
  await q('QAS-11: evento_servicio de la prueba', `SELECT left(solicitud_id::text,8) solicitud, tipo_evento, (actor_id IS NOT NULL) actor, actor_rol, correlation_id FROM evento_servicio WHERE solicitud_id = ANY($1::uuid[]) ORDER BY correlation_id NULLS FIRST`, [[E.solicitud_a, E.solicitud_b]]);
  await q('QAS-11: transaccion_evento de la prueba', `SELECT * FROM transaccion_evento WHERE correlation_id LIKE $1`, [`qa-qas11-${E.corrida}-%`]);
  const intentos = [
    ['UPDATE evento_servicio (pago de la prueba)', `UPDATE evento_servicio SET actor_rol = 'cliente' WHERE solicitud_id = $1`, [E.solicitud_a]],
    ['DELETE evento_servicio (pago de la prueba)', `DELETE FROM evento_servicio WHERE solicitud_id = $1`, [E.solicitud_a]],
    ['UPDATE transaccion_evento de la prueba', `UPDATE transaccion_evento SET correlation_id = 'alterado' WHERE correlation_id LIKE $1`, [`qa-qas11-${E.corrida}-%`]],
    ['DELETE transaccion_evento de la prueba', `DELETE FROM transaccion_evento WHERE correlation_id LIKE $1`, [`qa-qas11-${E.corrida}-%`]],
    ['UPDATE pago (monto)', `UPDATE pago SET monto = 1 WHERE id = $1`, [E.pago]],
    ['DELETE pago', `DELETE FROM pago WHERE id = $1`, [E.pago]],
    ['TRUNCATE evento_servicio', `TRUNCATE evento_servicio`, []],
    ['TRUNCATE transaccion_evento', `TRUNCATE transaccion_evento`, []],
  ];
  for (const [t, sql, p] of intentos) {
    await c.query('SAVEPOINT s');
    try { const r = await c.query(sql, p); console.log(`-- QAS-11 intento ${t}: ACEPTADO (${r.rowCount} filas) -> se revierte`); }
    catch (e) { console.log(`-- QAS-11 intento ${t}: rechazado ${e.code} ${e.message}`); }
    await c.query('ROLLBACK TO SAVEPOINT s');
  }
  await c.query('ROLLBACK'); await c.end();
  console.log('-- transaccion revertida: nada cambio en la base');
})().catch((e) => { console.log('ERROR', e.code || '', e.message); process.exit(0); });
JS
  echo "== salida guardada en $SAL"
  ;;
borrar) rm -f "$TOK" "$EST" && echo "tokens y estado borrados" ;;
*) echo "Uso: bash qa_barrido/correr_qas11_37_42.sh tokens|probar|verificar|borrar"; exit 1 ;;
esac

#!/usr/bin/env bash
# SCRUM-1679 (T-42), 20 nov. Despliega en MANI-QA las cabezas de release de Core, Dispatch, Rules, Flutter y Gateway.
# Basado en qa_s5_corte2/desplegar_release_qa.sh. Orden: primero Core (Dispatch usa su endpoint nuevo, MANI-Node#139),
# luego Dispatch, Rules, Flutter y Gateway. No toca Kafka, Landing, .env.qa ni el compose, y no aplica migraciones.
# Antes: fusionar las promociones, migrar_0040_0042_qa.sh aplicar y configurar_pools_qa.sh aplicar.
#
# Antes de recrear contenedores comprueba: migraciones de release registradas en QA, CORE_SERVICE_URL de Dispatch absoluta
# (MANI-.NET#31: sin ella Dispatch no arranca) e imagenes :staging iguales a las cabezas. Si algo falla, no cambia nada.
# Tambien aborta si el compose no trae los pools de QA (Core 30, Dispatch 10).
# Si tras recrear algun servicio no responde, vuelve a las cinco imagenes anteriores.
#
# No imprime claves ni URLs de conexion. Pide la contrasena de la VM de QA una vez.
# Uso: bash qa_t42/desplegar_release_qa_t42.sh
set -u
cd "$(dirname "$0")/.."
VM=estudiante@10.43.100.141
cabeza() { gh api "repos/Trama-AS/$1/branches/release" --jq '.commit.sha'; }
SHA_NODE=$(cabeza MANI-Node) || exit 1
SHA_NET=$(cabeza MANI-.NET) || exit 1
SHA_FLUTTER=$(cabeza MANI-Flutter) || exit 1
SHA_GW=$(cabeza MANI-APIGateway) || exit 1
SHA_JAVA=$(cabeza MANI-Java) || exit 1
SHA_LANDING=$(cabeza MANI-Landing) || exit 1
ESPERADAS=$(gh api "repos/Trama-AS/MANI-Node/git/trees/release?recursive=1" --jq '.tree[].path' \
  | sed -nE 's#^db/migrations/(00[0-9]{2})_.*#\1#p' | sort -u | awk '$1 >= "0005"' | tr '\n' ' ')
VER=$(gh api "repos/Trama-AS/MANI-Node/contents/db/verify/0037_verificar_sin_bypassrls.sql?ref=release" -H 'Accept: application/vnd.github.raw' | base64 | tr -d '\n')
[ -n "$ESPERADAS" ] && [ -n "$VER" ] || { echo "No se pudo leer MANI-Node en release. No se hizo nada."; exit 1; }
mkdir -p qa_t42/evidencia
SAL="qa_t42/evidencia/despliegue_release_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
echo "cabezas de release: core ${SHA_NODE:0:7} dispatch ${SHA_NET:0:7} flutter ${SHA_FLUTTER:0:7} gateway ${SHA_GW:0:7} rules ${SHA_JAVA:0:7}" | tee "$SAL"
echo "Se pide la contrasena de la VM de QA ($VM):"
{
  printf 'SHA_NODE=%s SHA_NET=%s SHA_FLUTTER=%s SHA_GW=%s SHA_JAVA=%s SHA_LANDING=%s\n' "$SHA_NODE" "$SHA_NET" "$SHA_FLUTTER" "$SHA_GW" "$SHA_JAVA" "$SHA_LANDING"
  printf 'VER=%s\nESPERADAS="%s"\n' "$VER" "$ESPERADAS"
  cat <<'REMOTO'
set -u -o pipefail
cd /opt/mani || exit 1
DC="docker compose -f docker-compose.qa.yml --env-file .env.qa"
oculta() { sed -E 's/[0-9a-f]{64}/<oculto>/g; s#postgres(ql)?://[^ "]+#<url>#g; s/(Password=)[^; ]+/\1<oculto>/Ig'; }
pg() { local url=$1; shift; PGURL="$url" docker run --rm -i --network host -e PGURL postgres:15 sh -c 'psql "$PGURL" -X -A -t -F " | " "$@"' sh "$@"; }
ADMIN=$(python3 -c '
import re
for l in open("/opt/mani/.env.qa", encoding="utf8"):
    m = re.match(r"^DATABASE_URL_ADMIN=(.*)$", l.strip())
    if m:
        print(m.group(1).strip().strip("\x27\""))
')
[ -n "$ADMIN" ] || { echo "== ABORTA: sin DATABASE_URL_ADMIN. No se cambio nada."; exit 1; }
rev_imagen() { docker image inspect -f '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$1"; }
rev_cont() { docker inspect -f '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$1" | cut -c1-7; }
salud() { curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$1" || echo 000; }

C_CORE=mani-core-service C_DISP=mani-dispatch-service C_FLUT=mani-flutter-web C_GW=mani-api-gateway C_RUL=mani-rules-service
SERVICIOS="core-service dispatch-service rules-service flutter-web gateway"
for c in $C_CORE $C_DISP $C_FLUT $C_GW $C_RUL; do
  eval "REF_${c//-/_}=\$(docker inspect -f '{{.Config.Image}}' $c)"
  eval "ID_${c//-/_}=\$(docker inspect -f '{{.Image}}' $c)"
done
restaurar_tags() {
  for c in $C_CORE $C_DISP $C_FLUT $C_GW $C_RUL; do
    eval "docker tag \"\$ID_${c//-/_}\" \"\$REF_${c//-/_}\""
  done
}
abortar() { restaurar_tags; echo "== ABORTA: $1"; echo "== Contenedores sin cambios."; exit 1; }

echo "== Antes ($(date -u +%FT%TZ))"
for c in $C_CORE $C_DISP $C_FLUT $C_GW mani-rules-service mani-landing-web; do echo "  $c $(rev_cont "$c" 2>/dev/null)"; done

echo "== Comprobaciones sin cambios"
FALTAN=$(pg "$ADMIN" -c "SELECT string_agg(e, ' ') FROM unnest(string_to_array(trim('$ESPERADAS'), ' ')) e WHERE NOT EXISTS (SELECT 1 FROM schema_migrations s WHERE s.version = e)" 2>&1 | oculta | cut -c1-160)
if [ -n "$FALTAN" ]; then echo "== ABORTA: migraciones de release sin registrar en QA: $FALTAN. No se cambio nada."; exit 1; fi
echo "  migraciones de release registradas: ultima $(echo "$ESPERADAS" | awk '{print $NF}')"
URL_CORE=$($DC config --format json 2>/dev/null | python3 -c 'import json,sys; print(json.load(sys.stdin)["services"]["dispatch-service"].get("environment",{}).get("CORE_SERVICE_URL",""))')
echo "  CORE_SERVICE_URL de Dispatch: ${URL_CORE:-<vacia>}"
echo "$URL_CORE" | grep -qE '^https?://[^/ ]+' || { echo "== ABORTA: Dispatch no arrancaria sin una URL absoluta de Core. No se cambio nada."; exit 1; }
POOLS=$($DC config --format json 2>/dev/null | python3 -c '
import json, re, sys
s = json.load(sys.stdin)["services"]
c = s["core-service"].get("environment", {}).get("DATABASE_POOL_MAX")
m = re.search(r"maximum pool size\s*=\s*(\d+)", json.dumps(s["dispatch-service"].get("environment", {})), re.I)
print(f"{c} {m.group(1) if m else None}")')
echo "  pools en el compose: Core ${POOLS% *}, Dispatch ${POOLS#* }"
[ "$POOLS" = "30 10" ] || { echo "== ABORTA: faltan los pools de QA; correr configurar_pools_qa.sh aplicar. No se cambio nada."; exit 1; }
[ "$(docker inspect -f '{{index .Config.Labels "org.opencontainers.image.revision"}}' mani-landing-web)" = "$SHA_LANDING" ] && echo "  landing ya en release" || echo "  aviso: landing no esta en la cabeza de release; este script no lo toca"

echo "== Pull de imagenes :staging"
$DC pull -q $SERVICIOS 2>&1 | oculta | tail -4 | cut -c1-140
[ "${PIPESTATUS[0]}" = 0 ] || abortar "fallo el pull"
FALLA=0
for par in "$REF_mani_core_service=$SHA_NODE" "$REF_mani_dispatch_service=$SHA_NET" "$REF_mani_rules_service=$SHA_JAVA" "$REF_mani_flutter_web=$SHA_FLUTTER" "$REF_mani_api_gateway=$SHA_GW"; do
  img=${par%%=*}; sha=${par#*=}; rev=$(rev_imagen "$img")
  if [ "$rev" = "$sha" ]; then echo "  ok  $img ${rev:0:7}"; else echo "  NO  $img imagen=${rev:0:7} release=${sha:0:7}"; FALLA=1; fi
done
[ "$FALLA" = 0 ] || abortar "alguna imagen no es la cabeza de release"

echo "== Redespliegue 1/2: core-service"
$DC up -d --no-deps core-service 2>&1 | oculta | tail -4 | cut -c1-110
for i in $(seq 1 24); do [ "$(salud http://localhost/api/v1/core/health)" = 200 ] && break; sleep 5; done
echo "  core: $(salud http://localhost/api/v1/core/health)"
echo "== Redespliegue 2/2: dispatch-service rules-service flutter-web gateway"
$DC up -d --no-deps dispatch-service rules-service flutter-web gateway 2>&1 | oculta | tail -8 | cut -c1-110

esperar() {
  for i in $(seq 1 24); do
    A=$(salud http://localhost/api/v1/core/health); B=$(salud http://localhost/api/v1/dispatch/health); G=$(salud http://localhost/health); F=$(salud http://localhost:8080/); R=$(salud http://localhost/api/v1/rules/health)
    [ "$A" = 200 ] && [ "$B" = 200 ] && [ "$G" = 200 ] && [ "$F" = 200 ] && [ "$R" = 200 ] && return 0
    sleep 5
  done
  return 1
}
echo "== Espera y salud"
if ! esperar; then
  echo "== Algun servicio no respondio (core $A, dispatch $B, rules $R, gateway $G, flutter $F). Logs:"
  docker logs --tail 25 $C_CORE 2>&1 | oculta | cut -c1-170
  docker logs --tail 25 $C_DISP 2>&1 | oculta | cut -c1-170
  docker logs --tail 15 $C_GW 2>&1 | oculta | cut -c1-170
  docker logs --tail 15 $C_RUL 2>&1 | oculta | cut -c1-170
  echo "== REVERSA: las cinco imagenes anteriores"
  restaurar_tags
  $DC up -d --no-deps $SERVICIOS 2>&1 | oculta | tail -5 | cut -c1-110
  esperar
  echo "  tras la reversa: core $A, dispatch $B, rules $R, gateway $G, flutter $F"
  echo "== Fin con REVERSA ($(date -u +%FT%TZ))"
  exit 1
fi
docker ps -a --filter "name=mani-" --format '{{.Names}} | {{.Status}}' | sort
for u in http://localhost/health http://localhost/api/v1/core/health http://localhost/api/v1/rules/health http://localhost/api/v1/dispatch/health http://localhost:8080/ http://localhost:3001/; do
  echo "  $(salud "$u") $u"
done
echo "== Rol de arranque en logs"
docker logs --since 10m $C_CORE 2>&1 | grep -E 'PostgreSQL: Core conecta|BYPASSRLS' | oculta | tail -2 | cut -c1-130
docker logs --since 10m $C_DISP 2>&1 | grep -E 'conecta como|BYPASSRLS' | oculta | tail -2 | cut -c1-130
echo "== Verificacion oficial (termina con 'roles y politicas conformes' si cumple)"
echo "$VER" | base64 -d | pg "$ADMIN" -v ON_ERROR_STOP=1 -f - 2>&1 | oculta | tail -3 | cut -c1-120
echo "== Pools en los contenedores"
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' $C_CORE | grep -E '^DATABASE_POOL_MAX='
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' $C_DISP | grep -oiE 'maximum pool size *= *[0-9]+'
echo "== Revisiones finales"
for c in $C_CORE $C_DISP $C_FLUT $C_GW mani-rules-service mani-landing-web; do echo "  $c $(rev_cont "$c" 2>/dev/null)"; done
echo "== Fin ($(date -u +%FT%TZ))"
REMOTO
} | ssh -o ConnectTimeout=15 "$VM" 'f=$(mktemp); cat > "$f"; bash "$f" </dev/null; r=$?; rm -f "$f"; exit $r' 2>&1 | tee -a "$SAL"
echo "== salida guardada en $SAL"

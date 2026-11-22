#!/usr/bin/env bash
# SCRUM-1679 (T-42). Verificacion previa, SOLO LECTURA, de MANI-QA antes de remedir QAS-03, 15 y 19.
# Responde: que commit de Core, Dispatch, Gateway y Rules corre en QA; si incluye los PR de SCRUM-1651 y 1652;
# y con cuantas conexiones quedaron los pools de Core y Dispatch.
# No reinicia, no despliega, no toca .env.qa ni el compose, y no imprime claves, tokens ni URLs de base:
# de las variables de entorno solo se leen los nombres y numeros del pool.
# ssh pide la contrasena de la VM de QA; ningun script la guarda. Uso: bash qa_t42/verificar_qa_t42.sh
set -u
cd "$(dirname "$0")/.."
VM=estudiante@10.43.100.141
mkdir -p qa_t42/evidencia
SALIDA=qa_t42/evidencia/verificar_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt

echo "Se pide la contrasena de la VM de QA:"
REMOTA=$(ssh -o ConnectTimeout=15 "$VM" 'bash -s' 2>&1 <<'REMOTO'
set -u
rev() { docker inspect -f '{{index .Config.Labels "org.opencontainers.image.revision"}}' "$1" 2>/dev/null; }
echo "== contenedores"
docker ps -a --filter "name=mani-" --format '{{.Names}} | {{.Status}} | creado {{.CreatedAt}}' | sort
echo "== revisiones desplegadas"
for c in mani-core-service mani-dispatch-service mani-api-gateway mani-rules-service; do
  echo "REV $c $(rev $c)"
done
echo "== pool de Core (variables del contenedor)"
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' mani-core-service \
  | grep -E '^DATABASE_POOL_[A-Z_]+=' || echo "Core sin DATABASE_POOL_* (usa el valor por omision del codigo)"
echo "== pool de Dispatch (solo el parametro Maximum Pool Size)"
n=$(docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' mani-dispatch-service | grep -oiE 'maximum pool size *= *[0-9]+' | head -1)
echo "${n:-Dispatch sin Maximum Pool Size (Npgsql abre hasta 100 por omision)}"
echo "== compose y .env.qa en /opt/mani (solo nombres y numeros del pool)"
cd /opt/mani 2>/dev/null || { echo "no existe /opt/mani"; exit 0; }
grep -nE 'DATABASE_POOL_MAX' docker-compose.qa.yml || echo "compose sin DATABASE_POOL_MAX"
grep -oE '^CORE_DATABASE_POOL_MAX=[0-9]+' .env.qa || echo ".env.qa sin CORE_DATABASE_POOL_MAX"
grep -E '^DISPATCH_DB_CONNECTION=' .env.qa | grep -oiE 'maximum pool size *= *[0-9]+' || echo ".env.qa: DISPATCH_DB_CONNECTION sin Maximum Pool Size"
if [ -d .git ]; then echo "git /opt/mani: $(git log -1 --format='%h %cI' 2>/dev/null)"; fi
REMOTO
)
r=$?

{
  echo "== SCRUM-1679 (T-42) verificacion previa de QA, $(date -u +%FT%TZ)"
  printf '%s\n' "$REMOTA" | sed -E 's#postgres(ql)?://[^ "]+#<url>#g; s/(Password=)[^; ]+/\1<oculto>/Ig; s/eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+/<token>/g'
  echo "== PR de SCRUM-1651 y 1652 contenidos en lo desplegado (comparado en los clones locales)"
  git -C MANI-Node fetch -q origin; git -C MANI-.NET fetch -q origin; git -C MANI-API fetch -q origin
  revisar() {  # repo, contenedor, pares sha:etiqueta
    local repo=$1 cont=$2; shift 2
    local sha; sha=$(printf '%s\n' "$REMOTA" | awk -v c="$cont" '$1=="REV" && $2==c {print $3}')
    if [ -z "$sha" ]; then echo "  $cont: sin etiqueta de revision; no se puede comparar"; return; fi
    git -C "$repo" cat-file -e "$sha^{commit}" 2>/dev/null || { echo "  $cont: $sha no existe en $repo"; return; }
    echo "  $cont: $(git -C "$repo" log -1 --format='%h %cI %s' "$sha" | cut -c1-110)"
    for par in "$@"; do
      git -C "$repo" merge-base --is-ancestor "${par%%:*}" "$sha" && echo "    SI  ${par#*:}" || echo "    NO  ${par#*:}"
    done
  }
  revisar MANI-Node mani-core-service 940bc3a:"Node#133 pool configurable (1651)" fb4036f:"Node#138 contexto en una sentencia (1652)" 01d97f9:"Node#139 elegibles por solicitud (1652)"
  revisar MANI-.NET mani-dispatch-service 9357b54:".NET#36 lecturas en paralelo (1652)" 80cc801:".NET#37 una sola llamada a Core (1652)"
  revisar MANI-API mani-api-gateway dac41f0:"Gateway#97 contrato y pools de QA (1652)"
  echo "== referencia: origin/release Node $(git -C MANI-Node rev-parse --short origin/release), .NET $(git -C MANI-.NET rev-parse --short origin/release), Gateway $(git -C MANI-API rev-parse --short origin/release)"
  echo "== codigo de salida de ssh: $r"
} | tee "$SALIDA"
echo "== salida guardada en $SALIDA"

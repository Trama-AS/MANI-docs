#!/usr/bin/env bash
# QAS-05, corre en la VM de QA desde /tmp/qas05. Solo crea y borra el proyecto Compose "qas05"; no toca los contenedores mani-*.
set -u -o pipefail
D=/tmp/qas05
export QAS05_CONF=$D/nginx.conf
P=qas05
DISP=${QAS05_DISPATCH:-0}
cd /opt/mani || exit 1
oculta() { sed -E 's/[0-9a-f]{64}/<oculto>/g; s#postgres(ql)?://[^ "]+#<url>#g; s/(Password=)[^; ]+/\1<oculto>/Ig; s/eyJ[A-Za-z0-9._-]+/<token>/g'; }
origen() { docker compose -f docker-compose.qa.yml --env-file .env.qa config --format json; }
dc() { origen | python3 $D/generar_compose.py | docker compose -p $P --project-directory /opt/mani -f - "$@"; }
puerto() { case $1 in core-service) echo 3000;; rules-service) echo 8080;; dispatch-service) echo 5000;; esac; }
ruta() { case $1 in core-service) echo /health;; rules-service) echo /api/v1/rules/health;; dispatch-service) echo /api/v1/dispatch/health;; esac; }
codigo() { local c; c=$(curl -s -o /dev/null -w '%{http_code}' --max-time 5 "$1"); echo "${c:-000}"; }
ids() { docker ps -q --filter label=com.docker.compose.project=$P --filter label=com.docker.compose.service="$1"; }
ip() { docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"; }
libre_mb() { awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo; }
mani() { case $1 in core-service) echo mani-core-service;; rules-service) echo mani-rules-service;; dispatch-service) echo mani-dispatch-service;; gateway) echo mani-api-gateway;; esac; }
salud_qa() {
  local a b c g m
  g=$(codigo http://127.0.0.1/health); a=$(codigo http://127.0.0.1/api/v1/core/health); b=$(codigo http://127.0.0.1/api/v1/dispatch/health); c=$(codigo http://127.0.0.1/api/v1/rules/health); m=$(libre_mb)
  echo "  QA real: gateway $g core $a dispatch $b rules $c; memoria libre $m MB; carga $(cut -d' ' -f1-2 /proc/loadavg)"
  [ "$g$a$b$c" = 200200200200 ] && [ "$m" -ge "${MIN_MB:-600}" ]
}
huella_qa() { docker inspect -f '{{.Name}} {{.Image}} {{.State.StartedAt}} {{.RestartCount}}' mani-api-gateway mani-core-service mani-dispatch-service mani-rules-service mani-flutter-web mani-landing-web; }
bajar() {
  [ -f $D/guardian.pid ] && kill "$(cat $D/guardian.pid)" 2>/dev/null
  docker compose -p $P down -t 5 --remove-orphans >/dev/null 2>&1
  local n r; n=$(docker ps -aq --filter label=com.docker.compose.project=$P | wc -l | tr -d ' '); r=$(docker network ls -q --filter label=com.docker.compose.project=$P | wc -l | tr -d ' ')
  echo "  restos de qas05: $n contenedores, $r redes"
  [ "$n" = 0 ] && [ "$r" = 0 ]
}
case ${1:-} in
  revisar)
    echo "== Revision sin cambios ($(date -u +%FT%TZ))"
    echo "  compose $(docker compose version --short); nucleos $(nproc); disco $(df -h / | awk 'END{print $4}') libre"
    MIN_MB=2500 salud_qa || { echo "  ABORTA: QA no esta sano o hay menos de 2500 MB libres"; exit 1; }
    [ -z "$(docker ps -aq --filter label=com.docker.compose.project=$P)" ] || { echo "  ABORTA: ya existe el proyecto $P; correr primero el modo limpiar"; exit 1; }
    ss -ltn | grep -q '127.0.0.1:18090 ' && { echo "  ABORTA: el puerto 18090 esta ocupado"; exit 1; }
    [ "$(docker inspect -f '{{index .Config.Labels "com.docker.compose.project"}}' mani-core-service)" != $P ] || exit 1
    for s in gateway core-service rules-service dispatch-service; do
      c=$(mani $s); etq=$(docker inspect -f '{{.Config.Image}}' $c)
      [ "$(docker inspect -f '{{.Image}}' $c)" = "$(docker image inspect -f '{{.Id}}' "$etq")" ] && echo "  ok  $s corre la imagen de $etq" || { echo "  ABORTA: $s no corre la imagen local de $etq"; exit 1; }
    done
    docker run --rm --network none --entrypoint cat "$(docker inspect -f '{{.Image}}' mani-api-gateway)" /etc/nginx/nginx.conf | python3 $D/preparar_nginx.py > $D/nginx.conf || { echo "  ABORTA: nginx.conf"; exit 1; }
    chmod 644 $D/nginx.conf
    dc config -q 2>&1 | oculta | tail -3; [ "${PIPESTATUS[0]}" = 0 ] || { echo "  ABORTA: el compose aislado no es valido"; exit 1; }
    echo "  compose aislado valido; pools por replica: Core ${QAS05_POOL_CORE:-5}, Dispatch $([ "$DISP" = 1 ] && echo "${QAS05_POOL_DISPATCH:-2}" || echo 'no se levanta'); CPU por replica ${QAS05_CPU:-0.5}" ;;
  subir)
    huella_qa > $D/huella_antes.txt
    setsid nohup sh -c "sleep 3000; docker compose -p $P down -t 5 --remove-orphans" >/dev/null 2>&1 & echo $! > $D/guardian.pid
    echo "== Se levanta el proyecto aislado: Core 2, Rules 1$([ "$DISP" = 1 ] && echo ', Dispatch 2') ($(date -u +%FT%TZ))"
    dc up -d --scale core-service=2 --scale rules-service=1 $([ "$DISP" = 1 ] && echo --scale dispatch-service=2) 2>&1 | oculta | tail -12 | cut -c1-120
    [ "${PIPESTATUS[0]}" = 0 ] || exit 1
    bash $0 esperar core-service 2 && bash $0 esperar rules-service 1 || exit 1; if [ "$DISP" = 1 ]; then bash $0 esperar dispatch-service 2 || exit 1; fi
    for i in $(seq 1 20); do [ "$(codigo http://127.0.0.1:18090/api/v1/core/health)" = 200 ] && break; sleep 3; done
    for s in core rules $([ "$DISP" = 1 ] && echo dispatch); do echo "  gateway aislado -> $s: $(codigo http://127.0.0.1:18090/api/v1/$s/health)"; done ;;
  esperar)
    s=$2; n=$3; t0=$(date +%s)
    for i in $(seq 1 60); do
      l=0; for c in $(ids $s); do [ "$(codigo "http://$(ip $c):$(puerto $s)$(ruta $s)")" = 200 ] && l=$((l+1)); done
      [ "$l" = "$n" ] && { echo "  $s: $l replicas listas en $(( $(date +%s) - t0 )) s"; exit 0; }
      sleep 3
    done
    echo "  ABORTA: $s solo tiene $l de $n replicas listas"; docker logs --tail 5 "$(ids $s | head -1)" 2>&1 | oculta | cut -c1-160; exit 1 ;;
  escalar)
    s=$2; n=$3
    echo "ESCALAR $s $n $(date +%s)"
    dc up -d --no-deps --no-recreate --scale $s=$n $s 2>&1 | oculta | tail -3 | cut -c1-120
    [ "${PIPESTATUS[0]}" = 0 ] || exit 1
    bash $0 esperar $s "$n" || exit 1
    echo "PASO $s $n $(date +%s)"
    ref=$(docker inspect -f '{{.Image}}' "$(mani $s)")
    for c in $(ids $s); do
      i=$(docker inspect -f '{{.Image}}' $c)
      echo "REPLICA $s $n $(ip $c) $(docker inspect -f '{{.Name}}' $c) $([ "$i" = "$ref" ] && echo misma_imagen || echo OTRA_IMAGEN) ${i#sha256:}" | cut -c1-120
    done
    salud_qa || { echo "  ABORTA: QA real no esta sano o falta memoria"; exit 1; } ;;
  reducir) dc up -d --no-deps --no-recreate --scale $2=2 $2 2>&1 | oculta | tail -2 | cut -c1-120; [ "${PIPESTATUS[0]}" = 0 ] || exit 1; bash $0 esperar $2 2 ;;
  fin_paso) echo "FIN_PASO $2 $3 $(date +%s)"; salud_qa || { echo "  ABORTA: QA real no esta sano o falta memoria"; exit 1; } ;;
  logs) for c in $(ids gateway); do docker logs "$c" 2>/dev/null; done | grep -F '"x_correlation_id": "qas-05-' ;;
  errores) for c in $(ids gateway); do docker logs "$c" 2>&1 >/dev/null; done | grep -E '\[(error|crit|alert)\]' | oculta | tail -20 | cut -c1-260 ;;
  bajar)
    echo "== Limpieza ($(date -u +%FT%TZ))"; bajar; r=$?
    if [ -f $D/huella_antes.txt ]; then huella_qa > $D/huella_despues.txt; cmp -s $D/huella_antes.txt $D/huella_despues.txt && echo "  QA real sin cambios (imagen, arranque y reinicios): si" || { echo "  QA real sin cambios: NO"; diff $D/huella_antes.txt $D/huella_despues.txt | cut -c1-160; r=1; }; fi
    salud_qa || r=1
    [ "$r" = 0 ] && rm -rf $D
    exit $r ;;
  *) echo "uso: revisar | subir | escalar SERVICIO N | reducir SERVICIO | fin_paso SERVICIO N | logs | errores | bajar"; exit 2 ;;
esac

#!/usr/bin/env bash
# =====================================================================
# MANI - QA-MON-01 (SCRUM-1274): verificacion de monitoreo en QA
# =====================================================================
# Solo lectura. Dos modos:
#
#   calidad  Se ejecuta en la VM de Calidad (10.43.98.196). Consulta por
#            HTTP los healthchecks del Gateway de QA, el rechazo 401
#            perimetral, la propagacion de X-Correlation-ID y los puertos
#            de Kafka y de observabilidad.
#   vm_qa    Se ejecuta en la VM de QA (10.43.100.141). Lee el estado de
#            los contenedores (imagen, revision, healthcheck, reinicios),
#            busca contenedores de Kafka u observabilidad, comprueba si
#            las variables de autenticacion del Core estan definidas (sin
#            imprimir valores), busca en el log del Gateway las peticiones
#            con un prefijo de correlation id y muestrea docker stats.
#
# Variables:
#   BASE_URL      Gateway de QA (modo calidad; por defecto http://10.43.100.141)
#   QA_HOST       host de QA para puertos (por defecto 10.43.100.141)
#   PREFIJO_CORR  prefijo de correlation id a buscar (por defecto qa1266)
#   DESDE         ventana de logs de docker (por defecto 3h)
#   MUESTRAS      muestras de docker stats (por defecto 1)
#   INTERVALO     segundos entre muestras (por defecto 10)
#   COMPOSE       archivo compose de QA (por defecto /opt/mani/docker-compose.qa.yml)
#   LIMPIAR_TAIL  1 para eliminar un tail residual en el Gateway (unica accion
#                 de escritura; autorizada el 19 oct 2026)
#
# La salida va a stdout; quien lo ejecuta la guarda como evidencia.
# Uso: bash verificar_monitoreo.sh calidad | bash verificar_monitoreo.sh vm_qa
# =====================================================================
set -uo pipefail

MODO=${1:-}
BASE_URL=${BASE_URL:-http://10.43.100.141}
QA_HOST=${QA_HOST:-10.43.100.141}
PREFIJO_CORR=${PREFIJO_CORR:-qa1266}
DESDE=${DESDE:-3h}
MUESTRAS=${MUESTRAS:-1}
INTERVALO=${INTERVALO:-10}
COMPOSE=${COMPOSE:-/opt/mani/docker-compose.qa.yml}

seccion() { printf '\n== %s\n' "$1"; }

modo_calidad() {
  seccion "contexto"
  echo "host=$(hostname) fecha_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ) base_url=$BASE_URL"

  seccion "healthchecks por el Gateway (ruta codigo tiempo propagacion de X-Correlation-ID)"
  for ruta in /health /api/v1/core/health /api/v1/rules/health /api/v1/dispatch/health; do
    corr="$PREFIJO_CORR-mon-$(date +%s%N)"
    cabeceras=$(mktemp)
    codigo=$(curl -s -m 5 -o /dev/null -D "$cabeceras" -w '%{http_code} %{time_total}s' -H "X-Correlation-ID: $corr" "$BASE_URL$ruta")
    cantidad=$(grep -c -i '^x-correlation-id:' "$cabeceras")
    iguales=$(grep -i '^x-correlation-id:' "$cabeceras" | tr -d '\r' | awk -v c="$corr" '$2 == c' | wc -l | tr -d ' ')
    [ "$iguales" -ge 1 ] && propaga=si || propaga=no
    [ "$cantidad" -gt 1 ] && duplicado=si || duplicado=no
    echo "$ruta $codigo correlation_propagado=$propaga cabeceras_x_correlation_id=$cantidad duplicado=$duplicado"
    rm -f "$cabeceras"
  done

  seccion "rechazo perimetral sin token"
  curl -s -m 5 -w ' HTTP=%{http_code}\n' -H "X-Correlation-ID: $PREFIJO_CORR-mon-401" "$BASE_URL/api/v1/core/profiles/me"

  seccion "puertos de QA (aplicacion, Kafka y observabilidad)"
  for par in 80:gateway 3001:landing 8080:flutter_web 9092:kafka 9093:kafka_controller 2181:zookeeper \
             9090:prometheus 3000:grafana 9100:node_exporter 8081:cadvisor 3100:loki 8126:datadog_apm; do
    puerto=${par%%:*}; nombre=${par#*:}
    if timeout 3 bash -c "</dev/tcp/$QA_HOST/$puerto" 2>/dev/null; then estado=abierto; else estado=cerrado; fi
    echo "$puerto $nombre $estado"
  done
}

modo_vm_qa() {
  seccion "contexto"
  echo "host=$(hostname) fecha_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  docker --version

  seccion "contenedores del compose"
  docker compose -f "$COMPOSE" ps 2>&1

  seccion "imagen, revision, healthcheck y reinicios por contenedor"
  for c in $(docker ps -q); do
    docker inspect --format '{{.Name}} | {{.Config.Image}} | rev={{index .Config.Labels "org.opencontainers.image.revision"}} | {{if .Config.Healthcheck}}healthcheck=declarado{{else}}healthcheck=no_declarado{{end}} | {{if .State.Health}}estado={{.State.Health.Status}}{{else}}estado=sin_healthcheck{{end}} | inicio={{.State.StartedAt}} | reinicios={{.RestartCount}}' "$c"
  done

  seccion "Kafka y observabilidad en ejecucion"
  docker ps --format '{{.Names}} {{.Image}}' | grep -i -E 'kafka|zookeeper|redpanda|prom|grafana|cadvisor|exporter|loki|datadog|otel' || echo "ninguno"

  seccion "variables de autenticacion del Core (definida o vacia, sin valor)"
  core=$(docker ps --format '{{.Names}}' | grep -i core | head -1)
  docker exec "$core" sh -c 'echo NODE_ENV=$NODE_ENV; for v in SUPABASE_JWT_SECRET JWT_SECRET SUPABASE_URL; do if [ -n "$(printenv $v)" ]; then echo "$v=definida"; else echo "$v=vacia"; fi; done' 2>&1
  docker exec "$core" sh -c 'printenv SUPABASE_URL | sed -E "s#https://([a-z0-9]+)\.supabase\.co.*#ref_supabase=\1#"' 2>&1

  gateway=$(docker ps --format '{{.Names}}' | grep -i gateway | head -1)
  if [ "${LIMPIAR_TAIL:-0}" = "1" ]; then
    seccion "limpieza autorizada: tail residual en el Gateway"
    docker exec "$gateway" sh -c 'pkill -f "[t]ail -n 8 /var/log/nginx/access.log" && echo eliminado || echo no_habia' 2>&1
  fi

  seccion "docker stats ($MUESTRAS muestras cada ${INTERVALO}s)"
  for i in $(seq 1 "$MUESTRAS"); do
    echo "-- muestra $i $(date -u +%H:%M:%SZ)"
    docker stats --no-stream --format '{{.Name}} cpu={{.CPUPerc}} mem={{.MemUsage}} red={{.NetIO}} pids={{.PIDs}}'
    [ "$i" -lt "$MUESTRAS" ] && sleep "$INTERVALO"
  done

  seccion "log del Gateway: peticiones con correlation $PREFIJO_CORR (ultimas $DESDE)"
  docker logs --since "$DESDE" "$gateway" 2>&1 | grep -c "\"x_correlation_id\": \"$PREFIJO_CORR" | sed 's/^/lineas=/'
  docker logs --since "$DESDE" "$gateway" 2>&1 | grep "\"x_correlation_id\": \"$PREFIJO_CORR" | tail -5 | cut -c1-400
  echo "-- conteo por status (todas las lineas JSON de la ventana)"
  docker logs --since "$DESDE" "$gateway" 2>&1 | grep -o '"status": "[0-9]*"' | sort | uniq -c

  seccion "log de servicios: ultima linea con correlation $PREFIJO_CORR"
  for patron in core rules dispatch; do
    c=$(docker ps --format '{{.Names}}' | grep -i "$patron" | head -1)
    echo "-- $c: $(docker logs --since "$DESDE" "$c" 2>&1 | grep -c "$PREFIJO_CORR") lineas"
    docker logs --since "$DESDE" "$c" 2>&1 | grep "$PREFIJO_CORR" | tail -2 | cut -c1-300
  done

  seccion "procesos dentro del Gateway"
  docker top "$gateway" 2>&1

  seccion "latencia en el Gateway (request_time) de las peticiones $PREFIJO_CORR-qas03"
  docker logs --since "$DESDE" "$gateway" 2>&1 | grep "\"x_correlation_id\": \"$PREFIJO_CORR-qas03" \
    | grep -o '"request_time": "[0-9.]*"' | grep -o '[0-9.]*' | sort -n \
    | awk '{v[NR]=$1} END {if (NR==0) {print "sin_datos"; exit} i=int(NR*0.95); if (i<1) i=1; j=int(NR*0.5); if (j<1) j=1; printf "n=%d p50_s=%s p95_s=%s max_s=%s\n", NR, v[j], v[i], v[NR]}'
  echo "-- status de las peticiones $PREFIJO_CORR-qas03"
  docker logs --since "$DESDE" "$gateway" 2>&1 | grep "\"x_correlation_id\": \"$PREFIJO_CORR-qas03" | grep -o '"status": "[0-9]*"' | sort | uniq -c

  seccion "recursos del host"
  nproc; free -h | head -2; df -h / | tail -1
}

case "$MODO" in
  calidad) modo_calidad ;;
  vm_qa) modo_vm_qa ;;
  *) echo "Uso: bash verificar_monitoreo.sh calidad|vm_qa" >&2; exit 2 ;;
esac

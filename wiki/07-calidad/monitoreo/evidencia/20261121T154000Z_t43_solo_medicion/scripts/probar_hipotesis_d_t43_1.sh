#!/usr/bin/env bash
# D-T43-1: ¿cambió la cuenta o el proyecto de Supabase? ¿Quién ocupa el pooler?
# Solo lectura. Oculta contraseñas. Uso: bash qa_t43/probar_hipotesis_d_t43_1.sh (pide la contraseña SSH)
set -euo pipefail
salida="qa_t43/evidencia/d_t43_1_hipotesis_cuentas_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
ssh estudiante@10.43.100.141 'bash -s' <<'REMOTO' | sed -E 's/eyJ[A-Za-z0-9._-]+/<token>/g' | tee "$salida"
echo "== 1. Conexión a base por contenedor (host, puerto, usuario; sin contraseña) =="
for c in $(docker ps --format '{{.Names}}'); do
  docker exec "$c" sh -c 'env' 2>/dev/null \
   | grep -iE '^(DATABASE_URL|DB_URL|SPRING_DATASOURCE_URL|CONNECTIONSTRINGS__[A-Z_]*|DATABASE_POOL_MAX|SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE|SUPABASE_URL)=' \
   | sed -E 's#(://[^:/@]+):[^@]*@#\1:***@#; s#(Password|Pwd)=[^;]*#\1=***#Ig' \
   | sed "s#^#$c  #" || true
done
echo
echo "== 2. Creación de los contenedores y del .env (¿cambió algo hace poco?) =="
docker ps --format '{{.Names}}\t{{.Status}}\t{{.Image}}'
ls -l --time-style=+%Y-%m-%dT%H:%M ~/*/.env* ~/.env* 2>/dev/null | awk '{print $6, $7}' || true
echo
echo "== 3. EMAXCONNSESSION por hora en el Core (últimas 48 h) =="
docker logs --since 48h --timestamps mani-core-service 2>&1 | grep EMAXCONNSESSION | cut -c1-13 | sort | uniq -c || echo "(ninguno)"
echo
echo "== 4. Nueva petición de hoy (correlationId bea96af4…) =="
docker logs --since 30m mani-core-service 2>&1 | grep -A12 "bea96af4-598c-4b0d-b99c-f725c9e97d20" | grep -E "Correlation|cause|EMAX|pool_size|DomainError" | head
echo
echo "== 5. Quién ocupa las conexiones de la base (pg_stat_activity, vía el Core) =="
docker exec mani-core-service node -e '
const {Client}=require("pg");
const c=new Client({connectionString:process.env.DATABASE_URL,connectionTimeoutMillis:8000,ssl:{rejectUnauthorized:false}});
c.connect().then(()=>c.query(`select usename, coalesce(nullif(application_name,\x27\x27),\x27(sin nombre)\x27) app, coalesce(host(client_addr),\x27local\x27) ip, state, count(*)::int n from pg_stat_activity where datname=current_database() group by 1,2,3,4 order by n desc`))
 .then(r=>{console.table(r.rows);return c.query("show max_connections")}).then(r=>{console.log("max_connections",r.rows[0].max_connections);return c.end()})
 .catch(e=>{console.log("ERROR:",e.code||"",e.message);process.exit(0)})' 2>&1
echo
echo "== 6. Cantidad de aliados del tenant (el caso de uso abre 3 conexiones por aliado) =="
docker exec mani-core-service node -e '
const {Client}=require("pg");
const c=new Client({connectionString:process.env.DATABASE_URL,connectionTimeoutMillis:8000,ssl:{rejectUnauthorized:false}});
c.connect().then(()=>c.query("select tenant_id, count(*)::int aliados from aliados group by 1 order by 2 desc limit 5")).then(r=>{console.table(r.rows);return c.end()})
 .catch(e=>{console.log("ERROR:",e.code||"",e.message);process.exit(0)})' 2>&1
REMOTO
echo; echo "Guardado en $salida"

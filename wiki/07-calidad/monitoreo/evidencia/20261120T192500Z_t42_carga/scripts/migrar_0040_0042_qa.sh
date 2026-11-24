#!/usr/bin/env bash
# SCRUM-1679 (T-42), despliegue del 20 nov. Migraciones 0040, 0041 y 0042 de MANI-Node en la base de MANI-QA.
#   ensayo  (por omision): aplica las tres dentro de una transaccion que termina en ROLLBACK. No deja cambios.
#   aplicar: las aplica en una sola transaccion con COMMIT. Si una falla, no queda ninguna.
# Lee las migraciones de origin/release de MANI-Node (tras fusionar la promocion), no de la copia de trabajo.
# Las tres son idempotentes (IF NOT EXISTS, ON CONFLICT DO NOTHING). No reinicia servicios ni toca .env.qa.
# Ojo: tras la 0042, evento_servicio no admite UPDATE, DELETE ni TRUNCATE (SCRUM-1656).
# No imprime claves ni URLs de conexion. Pide la contrasena de la VM de QA una vez.
# Uso: bash qa_t42/migrar_0040_0042_qa.sh [ensayo|aplicar]
set -u
cd "$(dirname "$0")/.."
MODO=${1:-ensayo}
case "$MODO" in ensayo) FIN=ROLLBACK ;; aplicar) FIN=COMMIT ;; *) echo "Modo: ensayo o aplicar"; exit 1 ;; esac
git -C MANI-Node fetch -q origin || exit 1
B64=""
for m in 0040 0041 0042; do
  f=$(git -C MANI-Node ls-tree --name-only origin/release db/migrations/ | grep "/${m}_")
  [ -n "$f" ] || { echo "La $m no esta en origin/release de MANI-Node. Falta fusionar la promocion. No se hizo nada."; exit 1; }
  echo "  $f"
  B64="$B64 $(git -C MANI-Node show "origin/release:$f" | base64 | tr -d '\n')"
done
mkdir -p qa_t42/evidencia
SAL="qa_t42/evidencia/${MODO}_0040_0042_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
echo "Modo $MODO. Se pide la contrasena de la VM de QA:"
{ printf 'MIGS="%s"\nFIN=%s\n' "$B64" "$FIN"; cat <<'REMOTO'
oculta() { sed -E 's/[0-9a-f]{64}/<oculto>/g; s#postgres(ql)?://[^ "]+#<url>#g; s/(Password=)[^; ]+/\1<oculto>/Ig'; }
ADMIN=$(python3 -c '
import re
for l in open("/opt/mani/.env.qa", encoding="utf8"):
    m = re.match(r"^DATABASE_URL_ADMIN=(.*)$", l.strip())
    if m:
        print(m.group(1).strip().strip("\x27\""))
')
[ -n "$ADMIN" ] || { echo "ABORTA: sin DATABASE_URL_ADMIN"; exit 1; }
pg() { PGURL="$ADMIN" docker run --rm -i --network host -e PGURL postgres:15 sh -c 'psql "$PGURL" -X -A -F " | " -v ON_ERROR_STOP=1' 2>&1 | oculta | cut -c1-210; }
estado() {
pg <<'SQL'
\echo -- migraciones registradas (0037 a 0042)
SELECT version, applied_at FROM schema_migrations WHERE version BETWEEN '0037' AND '0042' ORDER BY 1;
\echo -- columnas nuevas presentes
SELECT table_name, column_name FROM information_schema.columns WHERE table_schema = 'public' AND ((table_name = 'pago' AND column_name IN ('huella_idempotencia', 'actor_usuario_id', 'actor_rol')) OR (table_name = 'evento_servicio' AND column_name IN ('actor_rol', 'correlation_id'))) ORDER BY 1, 2;
\echo -- triggers de inmutabilidad y politicas de documento_legal
SELECT tgname FROM pg_trigger WHERE tgrelid = 'public.evento_servicio'::regclass AND tgname LIKE 'trg_evento_servicio%' ORDER BY 1;
SELECT policyname, cmd, roles, qual FROM pg_policies WHERE schemaname = 'public' AND tablename = 'documento_legal' ORDER BY 1;
\echo -- documento_legal por tenant (NULL = global)
SELECT coalesce(tenant_id::text, 'NULL') AS tenant, count(*) FILTER (WHERE is_active) AS activos FROM documento_legal GROUP BY 1 ORDER BY 1;
SQL
}
echo "== Fecha $(date -u +%FT%TZ)"
echo "== Antes"
estado
echo "== Migraciones 0040 a 0042 en una transaccion, termina en $FIN"
{
  echo 'BEGIN;'
  for b in $MIGS; do printf '%s' "$b" | base64 -d; echo; done
  echo '\echo -- dentro de la transaccion'
  echo "SELECT string_agg(version, ' ' ORDER BY version) AS registradas FROM schema_migrations WHERE version IN ('0040', '0041', '0042');"
  echo "$FIN;"
  echo "\\echo -- $FIN hecho"
} | pg
echo "== Despues"
estado
echo "== Fin"
REMOTO
} | ssh -o ConnectTimeout=15 estudiante@10.43.100.141 'f=$(mktemp); cat > "$f"; bash "$f" </dev/null; r=$?; rm -f "$f"; exit $r' 2>&1 | tee "$SAL"
echo "== salida guardada en $SAL"

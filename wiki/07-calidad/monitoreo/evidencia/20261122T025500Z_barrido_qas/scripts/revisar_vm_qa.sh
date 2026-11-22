#!/usr/bin/env bash
# Barrido de QAS viejos, VM de QA. Solo lectura, salvo el intento de UPDATE/DELETE/TRUNCATE de QAS-11, que corre dentro
# de una transaccion que se revierte siempre. Oculta claves y tokens. Pide la contrasena de la VM una vez.
set -u
cd "$(dirname "$0")/.."
SAL="qa_barrido/evidencia/vm_qa_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
ssh -o ConnectTimeout=15 estudiante@10.43.100.141 'bash -s' <<'REMOTO' | sed -E 's/eyJ[A-Za-z0-9._-]+/<token>/g; s#(postgres(ql)?://[^:/@]+):[^@]*@#\1:***@#g; s/(Password=)[^; ]+/\1***/Ig' | tee "$SAL"
echo "== Fecha $(date -u +%FT%TZ)"
echo; echo "== QAS-43: puertos y TLS desde la propia VM"
ss -tln 2>/dev/null | awk 'NR==1 || /:(80|443|8080) /'
for v in tls1_1 tls1_2 tls1_3; do printf "%s: " $v; echo | timeout 6 openssl s_client -connect 127.0.0.1:443 -$v 2>&1 | grep -E "^New,|Protocol *:|alert|no protocols|wrong version|refused" | head -1; done
echo | timeout 6 openssl s_client -connect 127.0.0.1:443 2>/dev/null | openssl x509 -noout -subject -issuer -enddate 2>/dev/null
curl -s -o /dev/null -m 6 -w "HTTP :80 -> %{http_code} %{redirect_url}\n" http://127.0.0.1/
curl -s -o /dev/null -m 6 -w "HTTP :8080 -> %{http_code} %{redirect_url}\n" http://127.0.0.1:8080/
echo; echo "== QAS-18/27: limites de CPU y memoria por contenedor"
for c in $(docker ps --format '{{.Names}}' | sort); do docker inspect -f '{{.Name}} cpus={{.HostConfig.NanoCpus}} mem={{.HostConfig.Memory}}' "$c"; done | sed 's#^/##'
echo; echo "== QAS-24: imagen y digest en QA"
for c in mani-api-gateway mani-core-service mani-dispatch-service mani-rules-service mani-flutter-web mani-landing-web; do printf "%s " "$c"; docker inspect -f '{{.Config.Image}} {{.Image}}' "$c"; docker image inspect -f '  repodigest={{join .RepoDigests ","}}' "$(docker inspect -f '{{.Image}}' "$c")"; done
echo; echo "== QAS-02/09: proveedores configurados en el Core (nombres y valores no secretos)"
docker exec mani-core-service sh -c 'env | grep -E "^(PUSH_PROVIDER|PUSH_MOCK_FALLAS|PUSH_PROVIDER_RETRIES|PAYMENT_PROVIDER|STORAGE_FALLA|STORAGE_FALLA_DESPUES_DE|KAFKA_BROKERS)=" | sort' || true
echo; echo "== QAS-22: formato de las ultimas lineas de log por servicio"
for c in mani-api-gateway mani-core-service mani-dispatch-service mani-rules-service; do echo "-- $c"; docker logs --tail 3 "$c" 2>&1 | cut -c1-300; done
echo; echo "== QAS-11/12: base de datos (via Core)"
docker exec -i mani-core-service node <<'JS'
const { Client } = require('pg');
const T = '10000000-0000-4000-8000-000000000011';
const c = new Client({ connectionString: process.env.DATABASE_URL, connectionTimeoutMillis: 10000, ssl: { rejectUnauthorized: false } });
const q = async (t, sql, p = []) => { try { const r = await c.query(sql, p); console.log(`-- ${t}`); console.table(r.rows); } catch (e) { console.log(`-- ${t}: ERROR ${e.code} ${e.message}`); } };
(async () => {
  await c.connect();
  await q('migraciones 0040 a 0045 aplicadas', `SELECT version, description FROM schema_migrations WHERE version >= '0040' ORDER BY version`);
  await q('columnas de actor, rol, fecha y correlation ID en tablas de auditoria', `SELECT table_name, string_agg(column_name, ', ' ORDER BY column_name) columnas FROM information_schema.columns WHERE table_schema='public' AND (column_name ~ '(actor|correlation|creado_por|usuario_id|created_at|registrado)') AND table_name IN ('evento_servicio','pago','transaccion_evento','consulta_conversacion','tenant_estado_auditoria','tarifa_referencia','tarifa_referencia_historial','regla_tenant','documento_kyc','aliado','solicitud','queja','cotizacion','adicion') GROUP BY 1 ORDER BY 1`);
  await q('triggers de inmutabilidad', `SELECT event_object_table tabla, string_agg(DISTINCT event_manipulation, ',') ops, string_agg(DISTINCT trigger_name, ',') triggers FROM information_schema.triggers WHERE trigger_name ~ 'inmutable|sin_truncate' GROUP BY 1`);
  await c.query('BEGIN');
  await c.query('SELECT app.set_context($1, NULL, $2)', [T, 'admin']).catch((e) => console.log('set_context:', e.message));
  await q('QAS-12: evento_servicio de las solicitudes de T-46 (asignacion)', `SELECT left(e.solicitud_id::text, 8) solicitud, e.tipo_evento, (e.actor_id IS NOT NULL) actor, e.actor_rol, (to_jsonb(e) ->> 'created_at') creado, e.correlation_id FROM evento_servicio e WHERE e.solicitud_id::text LIKE ANY (ARRAY['03490d4a%','6ef93e76%','0b226a4a%','04b65083%','5aedc113%'])`);
  await q('QAS-12: ultimos 8 eventos con correlation (cualquier tipo)', `SELECT tipo_evento, actor_rol, (actor_id IS NOT NULL) actor, left(correlation_id, 28) correlation FROM evento_servicio WHERE correlation_id IS NOT NULL LIMIT 8`);
  for (const [t, sql] of [['UPDATE', `UPDATE evento_servicio SET actor_rol = actor_rol WHERE id = (SELECT id FROM evento_servicio LIMIT 1)`], ['DELETE', `DELETE FROM evento_servicio WHERE id = (SELECT id FROM evento_servicio LIMIT 1)`], ['TRUNCATE', `TRUNCATE evento_servicio`], ['UPDATE transaccion_evento', `UPDATE transaccion_evento SET id = id WHERE id = (SELECT id FROM transaccion_evento LIMIT 1)`]]) {
    await c.query('SAVEPOINT s');
    try { const r = await c.query(sql); console.log(`-- QAS-11 intento ${t}: ACEPTADO (${r.rowCount} filas) -> se revierte`); }
    catch (e) { console.log(`-- QAS-11 intento ${t}: rechazado ${e.code} ${e.message}`); }
    await c.query('ROLLBACK TO SAVEPOINT s');
  }
  await c.query('ROLLBACK'); await c.end();
  console.log('-- transaccion revertida');
})().catch((e) => { console.log('ERROR', e.code || '', e.message); process.exit(0); });
JS
REMOTO
echo "== salida guardada en $SAL"

# 04 · Respaldos y Restauración (`SCRUM-1666` / T-29)

[← Volver a `08-infraestructura`](README.md)

> **Fuente:** Implementación real verificada en la VM de Backups (`10.43.98.197`) y réplica externa en Calidad (`10.43.98.196`) el `2026-11-14`, scripts versionados en `MANI-APIGateway/infra/backups/`, [`PROPUESTA_RNF_PROTECCION_Y_RECUPERACION.md`](../01-producto/requisitos.md), [SCRUM-1666](https://maniservices.atlassian.net/browse/SCRUM-1666) y [SCRUM-1684](https://maniservices.atlassian.net/browse/SCRUM-1684).
> **Finalidad:** Documentar la automatización diaria cifrada de respaldos (`pg_dump` 17), retención GFS, copia externa redundante, monitoreo en Prometheus, tiempos reales medidos en simulacro cronometrado de restauración y procedimiento operativo de recuperación.
> **Mantiene:** Daniel Ávila (DevOps) · **Consume:** DevOps, Arquitectura, QA, PO · **Frecuencia:** Ante cambios de retención/esquemas o ejecución de simulacros periódicos · **Versión:** 2.0 (`2026-11-14`)

---

## 1. Arquitectura y estado real verificado (`10.43.98.197` + `10.43.98.196`)

Estado operativo verificado por SSH el `2026-11-14` (`NBIG03`, Ubuntu `22.04.5 LTS`, `/dev/sda2` `68G`, `49G` libres):

| Componente | Ubicación / Puerto | Configuración verificada |
|---|---|---|
| **Cliente y clúster aislado PostgreSQL** | `10.43.98.197` · `PostgreSQL 17.12` (`PGDG`) | `pg_dump` / `psql` `17.12` + clúster aislado `17/drill` ligado únicamente a `127.0.0.1:5433` para simulacros sin tocar bases compartidas |
| **Programación automática (`systemd`)** | `/etc/systemd/system/mani-backup.{service,timer}` | Activo (`enabled`, `Persistent=true`); ejecuta `backup_databases.sh` diariamente a las **`02:00:00 COT`** (`07:00:00 UTC`) |
| **Cifrado e integridad** | `/etc/mani-backups/backup.passphrase` (`chmod 400`) | OpenSSL **`AES-256-CBC` + `PBKDF2` (`600 000` iteraciones)**, borrado inmediato del `.pgdump` temporal y firma `.sha256` + `.meta.json` sin secretos |
| **Custodia primaria y retención GFS** | `/opt/database-backups/mani/{daily,weekly}/{qa,prod}/` | Esquemas `public` y `app` (`pg_dump -Fc -Z9`); retención **`14` diarios** + **`4` semanales** dominicales por ambiente |
| **Copia externa cifrada (off-host)** | `10.43.98.196:/opt/database-backups-replica/mani/` | Sincronización automática por `rsync`/SSH (`ed25519` dedicado) solo de artefactos cifrados (`.pgdump.enc`, `.sha256`, `.meta.json`) |
| **Monitoreo y alertas** | `10.43.98.197:9100` → Prometheus Calidad | `prometheus-node-exporter` con `textfile_collector` (`mani_backups.prom`, `mani_backup_drill.prom`); alertas `BackupFailed`, `BackupStale` (`>26h`) y `BackupOffsiteSyncFailed` |
| **Snapshots históricos conservados** | `/opt/database-backups/mani/{pre-consolidation,rollback}/` | Respaldos manuales previos del `2026-10-17` y scripts de rollback `005`/`008` preservados intactos |

> **Aclaración de RPO frente a `QAS-17` y `SCRUM-1684`:**
> - El simulacro confirma **`RTO = 2 s`** (objetivo `QAS-17`: `≤ 30 min = 1800 s`, cumplido con amplia holgura).
> - El cron diario con `pg_dump` garantiza **`RPO ≤ 24 h`** (corte diario `02:00 COT`), cumpliendo el alcance operativo de [`SCRUM-1666`](https://maniservices.atlassian.net/browse/SCRUM-1666). Alcanzar `RPO ≤ 5 min` (umbral provisional de `QAS-17` sujeto al acta A/B [`SCRUM-1684`](https://maniservices.atlassian.net/browse/SCRUM-1684)) requiere WAL archiving continuo / Supabase Pro PITR, fuera del plan gratuito actual.

---

## 2. Primer respaldo real y simulacro cronometrado (`2026-11-14`)

Ejecución real de `mani-backup.service` y `restore_drill.sh` contra la instancia aislada `127.0.0.1:5433`:

| Ambiente | Artefacto cifrado (`AES-256-CBC`) | Tamaño cifrado | Tiempo backup + réplica | Tiempo `pg_restore` | **RTO total medido** | Validación de integridad |
|---|---|---:|---:|---:|---:|---|
| **QA** (`hpsxdotaizzclkeufzct`) | `qa_20261115T034503Z.pgdump.enc` | `951 472 B` (~930 KB) | `19 s` | `1 s` | **`2 s`** (`PASS ≤ 1800 s`) | SHA-256 OK · `38/38` tablas `public` · `38` con RLS · `tenant=3`, `usuario=150`, `aliado=124`, `cliente=20`, `categoria_servicio=23`, `solicitud=120`, `schema_migrations=45` |
| **PROD** (`tjxueukivwxsgipltqwb`) | `prod_20261115T034503Z.pgdump.enc` | `736 288 B` (~719 KB) | `19 s` | `1 s` | **`2 s`** (`PASS ≤ 1800 s`) | SHA-256 OK · `37/37` tablas `public` · `37` con RLS · `tenant=5`, `usuario=31`, `aliado=14`, `cliente=12`, `categoria_servicio=7`, `solicitud=20`, `schema_migrations=45` |

---

## 3. Operación diaria y simulacro en base aislada (`MANI-APIGateway/infra/backups/`)

```bash
# 1. Verificar programación del timer diario en 10.43.98.197
systemctl list-timers mani-backup.timer --no-pager

# 2. Ejecutar respaldo manual inmediato (QA + PROD + réplica cifrada a 10.43.98.196)
sudo systemctl start mani-backup.service && sudo journalctl -u mani-backup.service -n 30 --no-pager

# 3. Ejecutar simulacro cronometrado de restauración en base aislada (no toca QA/PROD compartidas)
/opt/mani-backups/bin/restore_drill.sh --env qa
/opt/mani-backups/bin/restore_drill.sh --env prod
```

---

## 4. Procedimiento de restauración ante incidente real en QA o PROD

1. **Identificar el artefacto válido** en `/opt/database-backups/mani/daily/<env>/` (o en la réplica externa `10.43.98.196:/opt/database-backups-replica/mani/daily/<env>/`) y verificar integridad:
   ```bash
   sha256sum -c <archivo>.pgdump.enc.sha256
   ```
2. **Validar primero en el clúster aislado (`127.0.0.1:5433`)** con `--keep-db` si se requiere inspeccionar registros antes de impactar el entorno vivo:
   ```bash
   /opt/mani-backups/bin/restore_drill.sh --env <qa|prod> --artifact /ruta/<archivo>.pgdump.enc --keep-db
   ```
3. **Detener escrituras en la VM destino** durante la ventana de mantenimiento:
   ```bash
   docker compose -f docker-compose.<env>.yml --env-file .env.<env> stop core-service dispatch-service
   ```
4. **Descifrar en archivo temporal `0600` y restaurar** sobre `$DATABASE_URL_ADMIN` (nunca en historial bash) eliminando de inmediato el archivo descifrado:
   ```bash
   TMP_DUMP="$(mktemp /tmp/restore-XXXXXX.pgdump)" && chmod 0600 "$TMP_DUMP"
   openssl enc -d -aes-256-cbc -pbkdf2 -iter 600000 -in <archivo>.pgdump.enc -out "$TMP_DUMP" -pass file:/etc/mani-backups/backup.passphrase
   pg_restore --no-owner --no-privileges --clean --if-exists -d "$DATABASE_URL_ADMIN" "$TMP_DUMP"
   rm -f "$TMP_DUMP"
   ```
5. **Validar aislamiento y reanudar servicios:** correr `supabase/seed/verificar_aislamiento.sql` (en QA), levantar contenedores (`docker compose ... start core-service dispatch-service`) y validar `/opt/mani/check-<env>.sh`.

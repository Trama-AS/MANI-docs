# 04 · Respaldos y Restauración

[← Volver a `08-infraestructura`](README.md)

> **Fuente:** Inspección directa por SSH sobre la VM de Backups (`10.43.98.197`) el `2026-11-14` (`D9` de `VALIDACION_HU-VAL-01.md`), [`PROPUESTA_RNF_PROTECCION_Y_RECUPERACION.md`](../06-gobernanza/PROPUESTA_RNF_PROTECCION_Y_RECUPERACION.md), [SCRUM-1666](https://maniservices.atlassian.net/browse/SCRUM-1666) y [SCRUM-1675](https://maniservices.atlassian.net/browse/SCRUM-1675).
> **Finalidad:** Registrar el inventario real de respaldos en `10.43.98.197`, declarar sin adornos la ausencia actual de cron automático y proveer el procedimiento base de restauración para el futuro simulacro cronometrado.
> **Mantiene:** Daniel Ávila (DevOps) · **Consume:** DevOps, Arquitectura, QA, PO · **Frecuencia:** Al implementar `SCRUM-1666` o ejecutar `SCRUM-1675` · **Versión:** 1.0 (`2026-11-14`)

---

## 1. Estado real verificado en la VM de Backups (`10.43.98.197`)

Inspección realizada el `2026-11-14` (`NBIG03`, disco `/dev/sda2` `68G`, `49G` libres):

- **Tareas programadas (`cron` / `systemd`):** `no crontab for estudiante`; sin scripts de respaldo en `/etc/cron.d` ni `/etc/cron.daily`; sin timers de respaldo en `systemctl list-timers`; Docker no está instalado.
- **Archivos existentes en `/opt/database-backups/mani/`** (fecha `2026-10-17 18:04`):
  - `pre-consolidation/backup_prod_tjxueukivwxsgipltqwb_data.sql` (`6 834` bytes)
  - `pre-consolidation/backup_prod_tjxueukivwxsgipltqwb_pre_consolidation.json` (`31 035` bytes)
  - `pre-consolidation/backup_qa_hpsxdotaizzclkeufzct_data.sql` (`90 550` bytes)
  - `pre-consolidation/backup_qa_hpsxdotaizzclkeufzct_pre_consolidation.json` (`131 113` bytes)
  - `rollback/rollback_005_004.sql` (`2 133` bytes)
  - `rollback/rollback_008_add_aliado_ausencia.sql` (`1 414` bytes)

> **Conclusión verificada:** A la fecha (`2026-11-14`), los respaldos existentes en `10.43.98.197` son **snapshots estáticos manuales del `2026-10-17`**. La automatización diaria con retención (`pg_dump` / script cron) pertenece a **[SCRUM-1666](https://maniservices.atlassian.net/browse/SCRUM-1666)** (pendiente) y el simulacro cronometrado de restauración pertenece a **[SCRUM-1675](https://maniservices.atlassian.net/browse/SCRUM-1675)** (pendiente).

---

## 2. Procedimiento base de restauración (SQL)

> **Nota de medición:** Aún **no hay tiempo medido en simulacro** porque [SCRUM-1675](https://maniservices.atlassian.net/browse/SCRUM-1675) no se ha ejecutado; el tiempo real se registrará aquí una vez corrido el simulacro sobre un entorno aislado.

1. **Identificar el artefacto de respaldo válido** en `/opt/database-backups/mani/` (o en el futuro directorio diario de `SCRUM-1666`) y verificar integridad no vacía (`ls -lh` / `sha256sum`).
2. **Obtener cadena de conexión administrativa** del proyecto destino (QA o instancia temporal de prueba) desde el gestor privado; nunca en texto plano en historia bash (`export PGPASSWORD=...` o archivo `.pgpass` `0600`).
3. **Detener temporalmente escrituras** o escalar a 0 las réplicas de `core-service` y `dispatch-service` en la VM destino durante la ventana de mantenimiento declarada:
   ```bash
   docker compose -f docker-compose.<env>.yml --env-file .env.<env> stop core-service dispatch-service
   ```
4. **Restaurar el snapshot** con `psql` o `pg_restore` sobre el esquema/base destino (usando primero una base/instancia de verificación si es prueba de DR):
   ```bash
   psql "$DATABASE_URL_ADMIN" -v ON_ERROR_STOP=1 -f /opt/database-backups/mani/pre-consolidation/<archivo>.sql
   ```
5. **Validar conteos y políticas RLS** contra consultas de verificación (`supabase/seed/verificar_aislamiento.sql` en QA).
6. **Reanudar servicios** y validar `/opt/mani/check-<env>.sh`:
   ```bash
   docker compose -f docker-compose.<env>.yml --env-file .env.<env> start core-service dispatch-service
   ```

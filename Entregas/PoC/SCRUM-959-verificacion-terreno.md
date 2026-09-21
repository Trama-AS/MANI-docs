# SCRUM-959 — Resultado de la verificacion de terreno

- **Ticket padre:** SCRUM-926 (CFG-09) — PoC de exclusion concurrente
- **Ejecutado:** 2026-09-21, SQL Editor del proyecto QA `hpsxdotaizzclkeufzct` (MANI-QA)
- **Script que produjo esta salida:** `supabase/poc-cfg09/00_verificar_terreno.sql`
  del repositorio de codigo `Trama-AS/MANI-Flutter`, rama
  `feature/SCRUM-926-poc-exclusion-concurrente`. Por ADR-0001 los scripts
  ejecutables viven en el repo de codigo y este informe en MANI-docs (ADR-0007).
- **Rol de ejecucion:** `postgres` (dashboard) — bypassa RLS, correcto para introspeccion
- **Motor:** PostgreSQL 17.6 · `read committed` · `max_connections = 60`

## Veredicto

**La dependencia CFG-04 esta satisfecha.** El esquema de solicitud/asignacion existe en
QA y admite el `UPDATE` condicional de ADR-0021. La PoC puede proceder.

Quedan **dos condiciones previas** (una de trabajo, una de metodo) y **cinco derivas**
respecto de `Product/DDL_MANI.sql` de MANI-docs.

## Lo que habilita la PoC

| Verificacion | Resultado | Consecuencia |
| --- | --- | --- |
| `solicitud.aliado_id` | `uuid`, NULLABLE | El `WHERE ... AND aliado_id IS NULL` es valido |
| `solicitud.estado` | `text`, NOT NULL | El `WHERE estado = 'pending'` es valido |
| GRANTs a `authenticated` | SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER | k6 puede ejecutar la RPC via PostgREST |
| `USAGE` sobre `public` | `anon` y `authenticated`: true | La API alcanza el esquema |
| RLS sobre `solicitud` | `relrowsecurity = true`, `relforcerowsecurity = false` | Aisla por tenant; `postgres`/`service_role` bypassan (por eso el harness usa JWT de aliado, nunca la service key) |
| Politica `tenant_isolation_solicitud` | `cmd = ALL`, `with_check = NULL` | **No bloquea el UPDATE**: con `ALL`, Postgres reutiliza la expresion `USING` como `WITH CHECK`. El UPDATE no toca `tenant_id`, asi que la fila resultante sigue cumpliendo |
| `pgcrypto` | instalada, 1.3 | El seed de la Fase 0 puede crear usuarios de Auth con `crypt()` |
| Funcion de aceptacion previa | 0 filas | SCRUM-960 se escribe desde cero, no hay duplicacion |

## Condiciones previas

### C1 — No hay poblacion con la que correr una carrera (bloqueante)

| slug | aliados_aprobados | aliados_total | solicitudes | pending |
| --- | --- | --- | --- | --- |
| acme-servicios | 1 | 1 | 0 | 0 |
| nova-mantenimiento | 1 | 1 | 0 | 0 |

Con 1 aliado por tenant no hay N aceptaciones simultaneas posibles. El seed de CFG-04
ademas borra `solicitud` en su Parte A. La Fase 0 (seed de concurrencia) es obligatoria.

### C2 — `max_connections = 60` acota el N util (metodologico)

El riesgo principal de esta PoC es un **falso verde**: si el pooler de PostgREST serializa
las N peticiones, el resultado sera "1 exito" sin que haya existido concurrencia real. Con
60 conexiones de motor y el pool propio de PostgREST por debajo de eso, N=200 no produce
200 transacciones solapadas.

Mitigacion obligatoria en la Fase 3, **no opcional**: control negativo con una variante de
la RPC sin el predicado `estado = 'pending'`, que DEBE producir dobles asignaciones. Si el
control negativo tambien da 1 exito, el harness no esta midiendo concurrencia y el verde
del caso principal no vale.

## Derivas frente a `Product/DDL_MANI.sql`

El DDL del repositorio de documentacion esta desactualizado respecto de QA. La fuente de
verdad para esta PoC es la base. Diferencias encontradas:

| # | DDL documentado | QA real | Impacto en la PoC |
| --- | --- | --- | --- |
| D1 | `estado text NOT NULL DEFAULT 'pending'` | sin DEFAULT | El seed debe escribir `'pending'` explicito |
| D2 | `CHECK (estado IN ('pending','assigned','in_progress','closed','cancelled'))` | **no existe ningun CHECK** | La maquina de estados de RF-14 no esta respaldada por la base; `estado` es texto libre |
| D3 | `CREATE INDEX idx_solicitud_tenant_id` | solo existe `solicitud_pkey` | Sin impacto en correccion; toda evaluacion de RLS filtra por `tenant_id` sin indice |
| D4 | FK sin clausula `ON DELETE` declarada | `aliado_id` con `ON DELETE SET NULL`; `tenant_id`/`cliente_id` CASCADE; `sitio_id`/`categoria_id`/`zona_id` RESTRICT | Ninguno en la PoC; el DDL debe recoger las clausulas reales |
| D5 | — | `anon` tiene UPDATE, DELETE y TRUNCATE sobre `solicitud` | Ninguno en la PoC. Es el grant por defecto de Supabase y deja el aislamiento dependiendo de una sola capa (RLS). Ver ADR-0005 |

Las 10 columnas que el DDL declara existen todas en QA: la deriva es de restricciones,
indices y defaults, no de estructura.

## Hallazgo de autorizacion (fuera del alcance de CFG-09)

`tenant_isolation_solicitud` aisla **solo por tenant**: `roles = {public}`, sin distincion
de rol ni de propietario. Cualquier usuario autenticado del tenant —incluido uno con rol
`cliente`— puede hacer `UPDATE` sobre cualquier `solicitud` y autoasignarsela. DD-MANI.md
§5.4 restringe `POST /solicitudes/:id/aceptar` al rol `aliado`; hoy la base no lo impone.

No bloquea esta PoC (mide exclusion concurrente, no autorizacion), pero debe levantarse
como ticket propio.

## Siguiente paso

Fase 0 — `supabase/poc-cfg09/10_seed_concurrencia.sql`: N aliados aprobados en un mismo
tenant, misma zona y categoria, mas 1 solicitud en `pending` con UUID fijo. Pendiente de
decision: sembrar sobre `acme-servicios` o crear un tercer tenant desechable.

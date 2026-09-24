# Informe consolidado de PoC — Sprint 2

**Ticket:** SCRUM-952 (DOC-16) · **Responsable:** Santiago (QA) · **Fecha:** 2026-09-22

## Alcance

Este informe consolida las PoC ejecutadas durante el Sprint 2 para validar, con evidencia medida,
las decisiones de arquitectura críticas del esqueleto vertical (multi-tenant, identidad, despacho
concurrente, almacenamiento de documentos).

**Nota de alcance:** CFG-06 (pipeline de pruebas automatizadas) se evaluó como candidata pero
**no es una PoC** — no tiene métrica ni umbral, tiene un criterio de terminado. Se excluye de este
informe.

Este documento consolida las **4 PoC** cerradas en el Sprint 2: CFG-09, CFG-10, CFG-12 y CFG-13.

---

## PoC-001 — Exclusión concurrente en la aceptación de solicitudes (CFG-09 / SCRUM-926)

**1. Pregunta que respondía**
¿El `UPDATE` condicional sobre `solicitud` garantiza exactamente 1 asignación exitosa cuando N
aliados aceptan la misma solicitud de forma simultánea?

**2. Métrica y umbral de éxito**

| Métrica | Umbral |
|---|---|
| Asignaciones exitosas por solicitud | = 1 |
| Dobles asignaciones | = 0 |
| Respuestas `200 OK` | = 1 |
| Respuestas `409 ya_no_disponible` | = N − 1 = 49 |
| Reintento del ganador (idempotencia, RNF-03) | `200` sin fila nueva en bitácora |
| Control negativo (validación del instrumento) | > 1 asignación |

N = 50.

**3. Resultado real obtenido**

Corrida de referencia r4-exclusion, N=50: 1 asignación en bitácora (1 `txid`), 0 dobles
asignaciones, 1×`200 OK`, 49×`409 ya_no_disponible`, 0 otras respuestas, 50/50 checks k6 en verde.

Corridas de control:

| Corrida | Configuración | Asignaciones | txid distintos | Ventana |
|---|---|---|---|---|
| r1-sin-exclusion | sin exclusión, ventana 50 ms | 1 | 1 | 0 ms |
| r2-sin-exclusion-3s | sin exclusión, ventana 3 s | **10** | **10** | **136 ms** |
| r3-control-malo | una sola guarda, ventana 3 s | 1 | 1 | 0 ms |
| r4-exclusion | mecanismo completo, ventana 3 s | 1 | 1 | — |
| r5-idempotencia | reintento sobre HTTP real | 0 filas nuevas | — | — |

r5 (idempotencia) devolvió `200` con el mismo `aliado_id` para el ganador en el reintento, `409
PT409` para otro aliado, y `404 PT404` para una solicitud ya no visible.

`http_req_duration`: 3.09 s promedio en r2 frente a 9.04 s promedio y 15.27 s máximo en r4 — la
diferencia es la cola sobre el bloqueo de fila. **No es latencia de producción**: los 3 s de
alineación son artificiales, por eso quedó fuera del criterio de aceptación.

El dato que sostiene el resultado es r2: bajo idéntica alineación y el mismo N, el control negativo
produjo 10 asignaciones de 10 transacciones distintas en 136 ms — la única diferencia entre r2 y r4
es el mecanismo, lo que descarta que el 1 de r4 venga de ausencia de carrera.

Dos falsos verdes quedaron documentados y descartados: r1 (ventana 15 veces menor que la dispersión
de llegada) y r3 (control negativo mal diseñado: quitaba una sola de las dos guardas del `WHERE`).

**4. ¿Cumplió el umbral?**
**Sí**, los ocho umbrales definidos.

**5. Evidencia disponible**

`Trama-AS/MANI-Flutter`, rama `release` (PR #6, **mergeado**, commit `9825e2f`):
```
supabase/poc-cfg09/00_verificar_terreno.sql
supabase/poc-cfg09/10_seed_concurrencia.sql
supabase/poc-cfg09/11_reset_solicitud.sql
supabase/poc-cfg09/20_rpc_aceptar_solicitud.sql
supabase/poc-cfg09/30_verificar_corrida.sql
qa/k6/aceptar_concurrente.js
qa/k6/obtener_tokens.sh
qa/k6/reset.sh
qa/k6/README.md
qa/k6/evidencia/bitacora.json        <- 13 filas crudas, fuente de verdad
qa/k6/evidencia/resumen-corridas.md
```

`Trama-AS/MANI-docs`, rama `main`: `Entregas/PoC/PoC-001-exclusion-concurrente-aceptacion.md`,
`Entregas/PoC/SCRUM-959-verificacion-terreno.md`.

Jira SCRUM-926: comentario con resultados y checklist de cierre del DoD.

**Herramientas:** k6 v2.3.0 (darwin/arm64) · PostgreSQL 17.6 · proyecto QA `hpsxdotaizzclkeufzct` ·
nivel de aislamiento `READ COMMITTED`.

Sin capturas de pantalla — la evidencia es la bitácora de base de datos y las salidas de k6, ambas
en texto y reproducibles con los comandos del `README.md`.

**6. Conclusión para el ADR relacionado**
**ADR-0021 queda confirmado y puede pasar de Propuesto a Aceptado en Mesa de Arquitectura**, con
cinco deudas declaradas: concurrencia acotada por el pool de PostgREST, `solicitud.estado` sin
`CHECK`/`DEFAULT` en QA, la política RLS no restringe el rol que acepta, la cola de reintento de
KI-06 pendiente, y `Product/DDL_MANI.sql` desactualizado.

---

## PoC-002 — Identidad y propagación de claims de tenant (CFG-12 / SCRUM-929)

**1. Pregunta que respondía**
¿El JWT emitido por Supabase Auth propaga `tenant_id` y `user_role` correctamente en el 100% de
los inicios de sesión, y son esos claims — no una cabecera enviada por el cliente — los que
determinan el acceso a los datos?

**2. Métrica y umbral de éxito**

| Métrica | Umbral |
|---|---|
| Propagación correcta de `tenant_id` y `user_role` | 100% de los logins |
| Casos borde con comportamiento determinista | 3 de 3 |
| Fugas de datos entre tenants | = 0 |
| Casos positivos de las suites en verde | 100% |
| Intentos de suplantación rechazados | 100% |
| Verificación de firma ES256 contra el JWKS, p95 | < 5 ms (orientativo) |
| Delta de latencia autenticado vs. anónimo | se registra, no decide |
| Control negativo | con el hook apagado, la suite debe ponerse roja |

**3. Resultado real obtenido**

| Métrica | Valor medido |
|---|---|
| Propagación correcta | 100% — 2 tenants, 2 roles, contra cuentas sin claims pre-escritos |
| Casos borde | 2 de 3 — el tercero no es representable en el modelo (sin tabla de membresía multi-rol) |
| Fugas entre tenants | 0 en lectura, listado, escritura, borrado e inserción |
| Suite `mani-claims` | 40/40 aserciones, 13 peticiones |
| Suite `mani-aislamiento` | 36/36 aserciones, 22 peticiones |
| Suplantación | 4 de 4 vectores rechazados (401 en payload alterado y firma inválida) |
| Firma ES256, p95 en caliente | 0.1033 ms (avg 0.0672 ms) |
| Verificación en frío (fetch JWKS) | 159.97 ms — costo de arranque, no por petición |
| Delta E2E autenticado vs. anónimo | avg 1.39 ms, mediana 0.07 ms (114.41 ms vs. 113.03 ms) |
| Control negativo | **13 de 40 aserciones fallan** con el hook apagado (corrida de control: 27/40) |

**4. ¿Cumplió el umbral?**
**Sí**, con dos casos declarados no ejecutables y documentados: usuario multi-rol (no representable
en el modelo de datos) y el caso 6 de ADR-0015 (KYC en Storage), que en el momento de esta PoC aún
no tenía bucket en QA — **ese caso lo resolvió después CFG-13 (SCRUM-930)**.

**5. Evidencia disponible**

`Trama-AS/MANI-Flutter`, rama `feature/SCRUM-929-poc-claims-tenant` — PR #7 (11 commits, 21
archivos) quedó **cerrado sin merge propio**: su código entró a `release` con el merge del PR #8
(commit `f6a7bff`), que estaba apilado sobre él:

| Tipo | Ruta |
|---|---|
| Mecanismo | `supabase/poc-cfg12/10_hook_claims_tenant.sql` |
| Verificación de terreno | `supabase/poc-cfg12/00_verificar_terreno.sql`, `01_resumen_terreno.sql` |
| Seed | `supabase/poc-cfg12/20_seed_identidad.sql` |
| Suites | `qa/newman/mani-claims.postman_collection.json`, `mani-aislamiento.postman_collection.json` |
| Reportes (credenciales redactadas) | `qa/newman/evidencia/claims-hook-activo.redactado.json`, `claims-control-hook-apagado.redactado.json`, `aislamiento-adr0015.redactado.json` |
| Medición de firma | `qa/jwt/bench_verificacion.mjs` + `qa/jwt/evidencia/bench-*.json` (2 corridas) |
| Delta E2E | `qa/k6/latencia_claims.js` + `qa/k6/evidencia/latencia-claims.json` |

`Trama-AS/MANI-docs` — PR #6, **pendiente de merge**: `Entregas/PoC/PoC-002-identidad-propagacion-claims-tenant.md`,
`Entregas/PoC/SCRUM-971-verificacion-terreno.md`.

**6. Conclusión para el ADR relacionado**
**ADR-0018 queda confirmado tal como está redactado**, pero la PoC reveló que estaba decidido y
**no implementado**: el `tenant_id` solo llegaba al JWT porque el seed lo escribía a mano; un alta
por el flujo real habría salido sin tenant. La PoC construyó el hook
(`public.custom_access_token_hook`) que cierra esa brecha, y aporta la cifra real de la "sobrecarga
marginal" que el ADR estimaba (0.07 ms), más la recomendación de cachear el JWKS.

**Verificación posterior:** tras los cambios de CFG-13, la suite de regresión
`claims-regresion-cfg13` dio **40/40** — el mecanismo de CFG-12 sigue intacto.

---

## PoC-003 — Almacenamiento de documentos KYC y URLs firmadas (CFG-13 / SCRUM-930)

**1. Pregunta que respondía**
¿El bucket único con rutas `tenant_id/<usuario>/archivo` y la política RLS de ADR-0013 impiden que
otro tenant acceda a los documentos KYC de un aliado, y en cuánto tiempo se carga un documento?

**2. Métrica y umbral de éxito** (publicados en SCRUM-930 antes de medir)

| Métrica | Umbral |
|---|---|
| Carga de un PDF de 1 MB, 30 corridas | p95 < 2000 ms |
| Emisión de URL firmada (`createSignedUrl`) | p95 < 500 ms |
| Acceso denegado entre tenants (QS-02) | 100% de los casos, cada uno con su positivo en verde |
| Control negativo (política sin aislamiento) | los negativos deben fallar |

**3. Resultado real obtenido**

| Métrica | Valor medido |
|---|---|
| Carga de 1 MB | p95 **1180 ms** (p50 688 ms, máx. 1280 ms) |
| `createSignedUrl` | peor p95 **423 ms** (máx. 537 ms) |
| Suite ADR-0015 completa (casos 1 a 6) | 95/95 aserciones, 0 accesos entre tenants |
| Regresión `mani-claims` | 40/40 aserciones |
| Control negativo | 20 aserciones en rojo; los positivos siguieron en verde |

Complementario, fuera de criterio: carga de 100 KB (p95 752 ms) y de 5 MB (p95 1427 ms). Medido
desde un Mac arm64 contra QA — cota inferior respecto a un celular en red móvil.

**4. ¿Cumplió el umbral?**
**Sí**, en las cuatro métricas. La emisión de URL firmada cumple con margen estrecho (423 ms
medidos frente a un techo de 500 ms, con un máximo de 537 ms que ya lo excede).

**5. Evidencia disponible**
- `Trama-AS/MANI-Flutter`, rama `feature/SCRUM-930-poc-storage-kyc` — PR #8, **mergeado** en `release` (commit `f6a7bff`): `supabase/poc-cfg13/` (incluye el bloque del control negativo en `10_bucket_kyc.sql`), `qa/storage/` (harness de carga y medición), `qa/newman/mani-aislamiento.postman_collection.json` (carpeta "06 caso 6"). CI: commit `c7afd46`, job "Flutter Lint, Test & Build Check" exitoso.
- `Trama-AS/MANI-docs` — PR #7, **pendiente de merge**: `Entregas/PoC/PoC-003-almacenamiento-kyc-urls-firmadas.md`.
- Sin capturas de pantalla; las salidas del SQL Editor se verificaron en pantalla pero no quedaron guardadas como archivo.

**6. Conclusión para el ADR relacionado**
**ADR-0013 se sostiene** en cuanto al aislamiento entre tenants, pero el texto necesita corrección
antes de pasar a Aceptado por tres hallazgos: la URL firmada es un token al portador por diseño de
Supabase — se mitiga con TTL corto, no se elimina (H-01); el ADR dice `aliado_id` donde la política
real usa `auth.uid()` (H-02); y la política `kyc_isolation` es `FOR ALL`, por lo que `admin_tenant`
puede también escribir y borrar, no solo leer (H-04) — hay que decidir si eso es intencional.

---

## PoC-004 — Cobertura geográfica (CFG-10 / SCRUM-927)

**1. Pregunta que respondía**
¿La consulta "aliados válidos por cobertura y categoría" de ADR-0011 (match por `zona_id`) cumple
la latencia con volumen, y si algún día hay que resolver la zona desde coordenadas (ADR-0011 §6),
qué mecanismo conviene entre PostGIS, bounding box y geohash?

**Nota importante:** a diferencia de lo asumido al pedir esta PoC, **sí existía un ADR previo**
(ADR-0011) — la PoC no informa una decisión nueva desde cero, sino que confirma la decisión ya
tomada (match por `zona_id`) y evalúa además, como escenario secundario, las tres alternativas
geográficas para el caso futuro de ADR-0011 §6.

**2. Métrica y umbral de éxito**

- **Umbral que decide:** p95 de la consulta en base de datos, variante `zona_id` (ADR-0011), menor
  a 50 ms. Se mide con **1000 consultas más 50 de calentamiento**, como `authenticated` con RLS
  activo, en **tres volúmenes**: 1k, 10k y 100k aliados por tenant.
- **Se reporta, no decide:** p95 extremo a extremo con 20 usuarios concurrentes, contra el objetivo
  de QS-08 (< 1000 ms); y la precisión de la zona resuelta por cada alternativa geográfica.
- El umbral se publicó en SCRUM-927 antes de medir.

**3. Resultado real obtenido**

p95 en base de datos, variante `zona_id`:

| Aliados por tenant | Índices actuales del DDL | Con 2 índices propuestos |
|---|---|---|
| 1k | 1.10 ms | 0.23 ms |
| 10k | 15.58 ms | 0.95 ms |
| 100k | 123.91 ms | 9.48 ms |

Variantes geográficas a 100k, con índices: PostGIS 7.17 ms, bounding box 9.52 ms, geohash 8.35 ms.

Extremo a extremo (k6, 20 VUs, nivel 10k): p95 entre 287 y 296 ms en las 4 variantes, 100% de
checks correctos.

Precisión de zona: PostGIS 100%, bounding box refinado 100%, geohash 93.78%.

**4. ¿Cumplió el umbral?**
**Sí, pero solo con los 2 índices propuestos** — `(tenant_id, zona_id)` en `cobertura_aliado` y
`(tenant_id, categoria_id)` en `aliado_categoria`. **No cumple con los índices actuales del DDL a
100k** (123.91 ms frente al umbral de 50 ms). El extremo a extremo sí cumple (296 ms en el peor
caso, frente a 1000 ms).

**5. Evidencia disponible**
- `Trama-AS/MANI-Flutter`, rama `feature/SCRUM-927-poc-cobertura-release` — **PR #16, mergeado** en `release` (commit `640130e`): scripts `supabase/poc-cfg10/00_` a `90_` y harness de extremo a extremo `qa/k6/latencia_cobertura.js`.
  - Evidencia: `supabase/poc-cfg10/evidencia/medicion-db.json` (las 48 mediciones), `precision-y-planes-100k.json` (precisión y planes `EXPLAIN ANALYZE`), `seed-1k.json`, `seed-10k.json`, `seed-100k.json`, `terreno-2026-09-22.json`; y `qa/k6/evidencia/latencia-cobertura-2026-09-22T22-58-31-985Z.json`.
- `Trama-AS/MANI-docs`, rama `main` (PR #8, mergeado): `Entregas/PoC/PoC-004-cobertura-geografica.md`.
- Jira: umbral y resultado en SCRUM-927, evidencia en SCRUM-965 a SCRUM-970, **la deuda de los índices quedó registrada en SCRUM-1054**.
- Sin capturas de pantalla; el esquema de prueba ya se borró de QA pero es reproducible con los scripts.

**6. Conclusión para el ADR relacionado**
**ADR-0011 se confirma y no se reabre**, pero exige agregar los 2 índices al DDL (seguimiento en
SCRUM-1054). Si algún día se activa el escenario de ADR-0011 §6 (resolver zona desde
coordenadas), la recomendación es **usar PostGIS y descartar geohash**, por su error de
precisión del 6.2% en los bordes.

---

## Hallazgos transversales del sprint

**El código de las cuatro PoC ya está en `release` de MANI-Flutter; faltan dos informes en
MANI-docs.** Estado de los PR al 2026-09-23:

| PoC | Repo | PR | Estado |
|---|---|---|---|
| CFG-09 | MANI-Flutter | #6 | Mergeado (`9825e2f`) |
| CFG-09 | MANI-docs | #4 | Mergeado (`53ff932`) |
| CFG-12 | MANI-Flutter | #7 | Cerrado; código integrado vía #8 (`f6a7bff`) |
| CFG-12 | MANI-docs | #6 | Pendiente de merge |
| CFG-13 | MANI-Flutter | #8 | Mergeado (`f6a7bff`) |
| CFG-13 | MANI-docs | #7 | Pendiente de merge |
| CFG-10 | MANI-Flutter | #16 | Mergeado (`640130e`) |
| CFG-10 | MANI-docs | #8 | Mergeado (`9b20574`) |

Hay **desfase entre el tablero de Jira y el repositorio**: CFG-12 y CFG-13 figuran como Finalizada
en Jira, pero sus informes (`PoC-002` y `PoC-003`) siguen sin mergear en MANI-docs. Vale la pena
decidir si "Finalizada" debería requerir merge, dado que ya se identificó antes que el DoD estándar
no encaja bien con entregables tipo PoC.

**El control negativo de CFG-12 es el hallazgo metodológico más útil del sprint.** Con el hook de
claims apagado, 27 de 40 aserciones de `mani-claims` seguían pasando — eran las negativas, y
pasaban precisamente porque en ese estado nadie veía nada. Es un falso verde reproducido de forma
controlada: confirma que toda suite de aislamiento debe llevar cada caso negativo con su espejo
positivo, o el "0 fugas" no es confiable.

## Deuda técnica identificada (excede el alcance de las PoC individuales)

- **No hay autorización por rol dentro de un mismo tenant**: las políticas RLS relevantes tienen
  `roles = {public}`, es decir, distinguen tenant pero no distinguen rol dentro del tenant.
- **Las políticas RLS viven solo en la base de QA, sin versionar** en `database/migrations/`. Es
  el riesgo más serio de los dos: la cadena de migraciones gobierna DEV, QA y PROD y no contiene un
  solo `CREATE POLICY`. Mitigante parcial: `schema_migrations` todavía no existe en QA, así que esa
  cadena nunca ha corrido — pero el problema debe resolverse antes de que corra.
- `Product/DDL_MANI.sql` desactualizado frente al estado real de QA (señalado también en la
  conclusión de CFG-09).
- **Faltan 2 índices** (`(tenant_id, zona_id)` en `cobertura_aliado` y `(tenant_id, categoria_id)`
  en `aliado_categoria`) sin los cuales la consulta de cobertura no cumple su umbral de latencia a
  100k aliados por tenant — seguimiento en **SCRUM-1054**.

## Estado de los ADR relacionados

| ADR | Estado antes | Resultado de la PoC | Acción sugerida |
|---|---|---|---|
| ADR-0021 (exclusión mutua en despacho) | Propuesto | Confirmado, sin correcciones al texto | Pasar a Aceptado en Mesa de Arquitectura |
| ADR-0018 (identidad y propagación de tenant) | Aceptado (pero no implementado) | Confirmado; mecanismo implementado por la PoC | Ninguna corrección de texto; dejar constancia de la implementación |
| ADR-0013 (almacenamiento KYC) | Propuesto | Se sostiene, con 3 correcciones de texto pendientes (H-01, H-02, H-04) | Corregir texto antes de pasar a Aceptado |
| ADR-0011 (cobertura por `zona_id`) | Aceptado | Confirmado; no cumple latencia a 100k sin los 2 índices propuestos | Agregar los 2 índices al DDL (seguimiento SCRUM-1054); si se activa §6, usar PostGIS y descartar geohash |

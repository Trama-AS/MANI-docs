# Validación de discrepancias entre documentos (HU-VAL-01)

[← Índice de la wiki](../Home.md) · [← 06 Gobernanza](README.md)

| Campo | Valor |
|---|---|
| **Finalidad** | Dejar una sola cifra y un solo estado por cada punto en que los documentos del proyecto se contradicen, con la verificación hecha en el sistema o en el código, no en otro documento. |
| **Origen** | [SCRUM-1696](https://maniservices.atlassian.net/browse/SCRUM-1696) (HU-VAL-01) |
| **Coordina** | Sara Albarracín (Scrum Master) |
| **Consume** | PO, Arquitectura, DevOps y QA antes de la sustentación |
| **Versión** | 2.0 |
| **Fecha de corte** | 2026-11-11 |
| **Estado** | **PARCIAL.** **6 de 15 filas verificadas con evidencia de sistema o de código**: D2, D3, D11, D13, D14 (lado QA) y D15 (el dato de Jira). **5 puntos decididos** por Sara el 2026-11-11, que no requieren evidencia de sistema porque no son verificaciones: D4, D12, P-D2, P-D14 y P-D15a ([§4](#4-decisiones-tomadas)). **7 filas pendientes de validar**: D1, D5, D6, D7, D8, D9 y D10. |
| **Corrección de conteo** | La versión 1.0 y la 1.1 decían «8 de 15 verificadas» contando D4 y D12 como verificadas. No lo eran: en esas dos filas se verificó que **existía el conflicto**, no cuál era el dato correcto. El avance real verificado es **6 de 15**. |
| **Cuántas evidencias faltan: 7 u 8** | Las dos cifras eran correctas con distinta unidad. **7 filas** pendientes (D1, D5–D10), que suman **8 comprobaciones** porque D14 llevaba una consulta de PROD aparte. Tras la decisión P-D14 esa consulta queda **informativa y no bloquea el cierre**: lo exigible para cerrar SCRUM-1696 son **7 comprobaciones en 7 filas**. |
| **Se actualiza** | Cada vez que se cierra una fila; obligatorio antes de cada sustentación. |

> **Regla de este documento.** Una fila sin evidencia pegada se declara «pendiente de validar», nunca como hecho. **Una decisión no es una verificación** y se cuenta aparte: las decisiones viven en [§4](#4-decisiones-tomadas) con su alternativa descartada y su trazabilidad; las verificaciones viven en §2 con su evidencia.

## 1. Estado por fila

| ID | Tema | Estado | Validador |
|---|---|---|---|
| D1 | Versión de PROD y rutas del front | Pendiente de validar | Daniel y Camila |
| D2 | Botón «Pagar» tras finalizar | **Verificado en código** y **decidido** (P-D2) | Camila y Nicolás Álvarez |
| D3 | Pantallas con actualización automática | **Verificado en código** | Nicolás Álvarez |
| D4 | RPO/RTO | **Decidido** (D4): rige el umbral de QAS-17 | Daniel, Camila y Sara |
| D5 | Servicios por ambiente | Pendiente de validar | Daniel y Sara |
| D6 | Puertos de QA | Pendiente de validar | Daniel y Santiago |
| D7 | Kafka en DEV y QA | Pendiente de validar | Daniel y Sara |
| D8 | Observabilidad | Pendiente de validar | Daniel y Sara |
| D9 | Respaldos | Pendiente de validar | Daniel |
| D10 | Migraciones y `BYPASSRLS` | Pendiente de validar | Daniel y Santiago |
| D11 | Cifras del Sprint 5 | **Verificado en Jira** | Sara y Camila |
| D12 | Quién firma el acta de ajustes | **Decidido** (D12): firma Camila Beltrán como PO | Sara y Camila |
| D13 | HU-M04-05 sin historia en Jira | **Verificado en Jira** | Sara y Camila |
| D14 | Jardinería activa en PROD, inactiva en QA | **Verificado** el lado QA y **decidido** (P-D14): es configuración de operación, no discrepancia documental | Camila y Daniel |
| D15 | Responsable de SCRUM-1383 | **Verificado en Jira**; responsabilidad **decidida** (P-D15a); el mecanismo de cifrado **sigue abierto** (P-D15b, [§5](#5-lo-único-que-sigue-abierto)) | Sara, Daniel y Nicolás Álvarez |

## 2. Filas verificadas

### D2 · El botón «Pagar» no está condicionado a que el servicio no haya finalizado

**Verificación:** lectura del código de `main` en `MANI-Flutter`.

```
git grep -n "alPagar" origin/main -- lib/
git show origin/main:lib/features/services/quotes/presentation/cotizacion_page.dart | sed -n '665,700p'
```

**Resultado.** El botón `btn-pagar-cotizacion` se muestra con una sola condición: `vigente.estado == EstadoCotizacion.aceptada && alPagar != null` (`cotizacion_page.dart:678`). `alPagar` se inyecta para el cliente y se anula para el aliado (`app_router.dart:203`). **No existe ninguna condición sobre el estado de la ejecución**: el código permite pagar una cotización aceptada aunque el servicio ya esté finalizado.

**Conclusión.** El código concuerda con la decisión 891/892 (permitir el pago, liberar y liquidar) y **no** con la Idea 1 de Nicolás Álvarez (ocultar «Pagar» tras finalizar). Quien debe corregirse es el documento que recoge la Idea 1, no el código.

**El commit citado por la discrepancia sí existe** (corregido el 2026-11-11). La búsqueda de la versión 1.0 falló porque los clones locales no tenían aún las referencias en que vive; tras `git fetch --all --prune` en los siete repositorios aparece:

| Campo | Valor |
|---|---|
| Repositorio | `MANI-Node` |
| SHA completo | `098bf38c3f8f77cd863ea3daa592608eaf5c74c2` |
| Autor y fecha | Nicolas11Leon, 2026-11-05 09:57 -0500 |
| Asunto | `[SCRUM-892][SCRUM-1378][SCRUM-1618] Libera al pagar sobre solicitud finalizada y uniforma la recuperación ante fallos del proveedor` |
| Ramas que lo contienen | `origin/main`, `origin/develop`, `origin/release` y 12 ramas de trabajo |

```
git -C MANI-Node log -1 --format=%H 098bf38
git -C MANI-Node show 098bf38 -- src/infrastructure/repositories/PgPaymentRepository.js
```

**Resultado.** El commit **refuerza la conclusión de esta fila, no la contradice.** Añade en `PgPaymentRepository.js:126-136` la liberación y liquidación inmediatas cuando el pago entra sobre una solicitud ya `FINALIZADA` o `CERRADA`:

```js
// SCRUM-892: si el cliente paga cuando el servicio ya terminó, la condición de cierre ya se cumplió y no habrá
// otra transición a FINALIZADA que libere la retención: se libera y liquida aquí, en la misma transacción.
if (sol.length > 0 && ['FINALIZADA', 'CERRADA'].includes(sol[0].estado)) {
  await liberarYLiquidar(client, ctx, sol[0].id);
}
```

Su propio mensaje lo declara: antes del commit la retención «quedaba RETENIDA para siempre». Es decir, el backend **no solo permite el pago tardío: lo trata como caso de negocio soportado** y lo liquida. Ocultar «Pagar» tras finalizar (Idea 1) dejaría este código sin uso. Queda en pie la pregunta P-D2: ratificar la decisión por escrito y fijar si hay plazo máximo para el pago tardío.

### D3 · Pantallas con actualización automática: dos, no tres ni cuatro

**Verificación:** búsqueda en `main` de `MANI-Flutter`.

```
git grep -n "Timer.periodic" origin/main -- lib/
git grep -nE "onPostgresChanges|RealtimeChannel|subscribe\(" origin/main -- lib/   # sin resultados
git grep -ln "" origin/main -- "lib/**/*_page.dart" | wc -l                        # 37 pantallas
```

**Resultado.** Tres usos de `Timer.periodic` en `main`:

| Archivo | Intervalo | Qué es |
|---|---|---|
| `lib/features/asignacion/presentation/pages/solicitudes_aliado_page.dart:56` | 30 s | **Refresco de pantalla** (bandeja de solicitudes del aliado) |
| `lib/features/messaging/presentation/chat_cubit.dart:127`, usado por `chat_page.dart` | 5 s | **Refresco de pantalla** (chat; pausa y reanuda por ciclo de vida, `chat_page.dart:39`) |
| `lib/features/services/events/presentation/eventos_cubit.dart:167`, usado por `eventos_seccion.dart` | 30 s | **Reintento de sincronización** mientras no hay conexión, en una sección, no en una pantalla |

No hay suscripciones en tiempo real (`realtime`, `RealtimeChannel`, `.stream(`). Los otros dos `Timer` del proyecto son *debounce* de búsqueda (`declarar_cobertura_page.dart:80`, `crear_solicitud_page.dart:64`), no refresco.

**Conclusión.** La cifra correcta es **2 pantallas con refresco automático**; 3 solo si se cuenta la sección de eventos, cuyo temporizador es un reintento. **La cifra 4 no tiene respaldo en el código.** Corregir `contexto_plataforma` y el documento de mejoras de producto, declarando qué se cuenta como «pantalla con actualización automática».

### D11 · Cifras del Sprint 5

**Verificación:** consultas JQL contra Jira el 2026-11-10 (el nombre del sprint en el tablero es `SCRUM Sprint 5`).

| JQL | Resultado |
|---|---|
| `project = SCRUM AND sprint = "SCRUM Sprint 5"` | **124** ítems |
| `… AND statusCategory = Done` | **123** |
| `… AND issuetype = Historia` | **85** |
| `… AND issuetype = Historia AND statusCategory = Done` | **84** |
| `project = SCRUM` | **741** ítems |
| `project = SCRUM AND statusCategory = Done` | **648** |

**Resultado.** La cifra **84/85 historias** del Sprint 5 es la correcta y es la que hay que publicar. El único ítem abierto del sprint es [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383) (HU-M02-15, cifrado), en estado `Reopened`.

**Conclusión.** `82/510` y `532/537` **no se reproducen** con ningún conteo de hoy, ni por tipo de ítem ni por estado: son cortes anteriores al lote `backlog-9nov`. El Excel debe quedar con la cifra 84/85 **y su fecha de corte escrita**; una cifra sin fecha de corte vuelve a producir esta discrepancia.

### D13 · HU-M04-05 no tiene historia en Jira

**Verificación:** consultas JQL.

```
key = SCRUM-1394                                                      -> 0 resultados
project = SCRUM AND (summary ~ "HU-M04-05" OR description ~ "HU-M04-05")  -> 2 resultados
```

**Resultado.** **SCRUM-1394 no existe.** Las dos únicas menciones a HU-M04-05 en Jira son esta misma historia de validación ([SCRUM-1696](https://maniservices.atlassian.net/browse/SCRUM-1696)) y [SCRUM-1687](https://maniservices.atlassian.net/browse/SCRUM-1687) («PO - Decisiones pendientes de producto», `In Progress`, Camila), que la lista como decisión pendiente.

**Conclusión.** El plan de módulos cita una historia inexistente. La decisión —crear la historia o retirar el ítem— ya está asignada en SCRUM-1687 y es del PO; hasta que se tome, el plan de módulos debe marcar HU-M04-05 como **sin historia en Jira**, no como planificada.

### D14 · Jardinería en QA está inactiva a propósito

**Verificación:** lectura de la semilla de QA versionada.

```
grep -n -i "jardiner" MANI-APIGateway/supabase/seed/seed_qa_sprint5.sql
```

**Resultado.** `seed_qa_sprint5.sql:351` inserta `Jardineria` con `estado = 'INACTIVO'` y `flujo_operativo = NULL`, igual que `Carpinteria` en el tenant 2. El encabezado del propio archivo (líneas 81-84) lo declara como diseño: una categoría activa y una inactiva por tenant, para poder probar el flujo de categoría inactiva.

**Conclusión.** En QA **no es un error**: es un dato de prueba deliberado. La discrepancia real es si Jardinería debe estar activa en PROD, que es decisión del PO, y el estado de PROD sigue sin verificar (ver la consulta en §3, D14-PROD).

### D15 · El responsable de SCRUM-1383 en Jira es Daniel Ávila

**Verificación:** consulta JQL.

```
project = SCRUM AND sprint = "SCRUM Sprint 5" AND statusCategory != Done
```

**Resultado.** Devuelve un único ítem: [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383) «HU-M02-15 - Cifrado de credenciales y de datos sensibles», tipo Historia, estado `Reopened`, **asignada a Daniel Ávila Medina**.

**Conclusión.** El dato de Jira no está en duda. Lo que falta es la decisión de alcance: si parte del cifrado se implementa en Core, el responsable único o el reparto debe quedar escrito (ver §4).

## 3. Filas pendientes: comando exacto, responsable y evidencia a pegar

Datos de infraestructura tomados de [`DOCUMENTO_INFRAESTRUCTURA_V4.md`](DOCUMENTO_INFRAESTRUCTURA_V4.md) §3 y §6: DEV `10.43.98.232`, QA `10.43.100.141`, PROD `10.43.98.203`, Calidad `10.43.98.196`; Supabase PROD `tjxueukivwxsgipltqwb`, QA `hpsxdotaizzclkeufzct`.

**Reglas para quien ejecute.** Pegar la salida completa, sin recortar, con la fecha y el host donde se corrió. No pegar contraseñas, tokens ni cadenas de conexión: si la salida los contiene, reemplazarlos por `<redactado>`. El usuario SSH se solicita al DevOps Lead; aquí va como `<usuario>`.

### D1 · Versión real de PROD y rutas del front — Daniel y Camila

```bash
ssh <usuario>@10.43.98.203 '
  docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
  for c in $(docker ps --format "{{.Names}}"); do
    echo "== $c"; docker inspect --format "{{.Image}} {{index .RepoDigests 0}}" "$c" 2>/dev/null
  done
'
```

**Evidencia a pegar:** tabla de contenedores con **tag e *image digest* por servicio**, más el resultado de abrir las 18 rutas del front en PROD (una línea por ruta: ruta, código HTTP, pantalla carga sí/no), que es lo que pide [SCRUM-1638](https://maniservices.atlassian.net/browse/SCRUM-1638).

**Antecedente que ya está escrito:** Infraestructura V4 §9 afirma que el último commit de `main` en los seis repositorios es la promoción del Sprint 4, de modo que `:latest` sería el incremento del Sprint 4. Si los digests lo confirman, la afirmación de «PROD en v1.0.4 al 100 %» cae por sí sola.

### D5 · Servicios por ambiente — Daniel y Sara

```bash
for h in 10.43.98.232 10.43.100.141 10.43.98.203; do
  echo "===== $h"; ssh <usuario>@$h 'docker ps --format "{{.Names}}\t{{.Image}}\t{{.Status}}"'
done
```

**Evidencia a pegar:** `docker ps` de los tres hosts, contrastado contra la tabla de contenedores de [`../02-arquitectura/SAD.md`](../02-arquitectura/SAD.md). Decir explícitamente si `Availability` corre o no en PROD y si `mani-landing-web` está en PROD.

### D6 · Puertos de QA — Daniel y Santiago

Desde la red de la universidad, **no desde el propio host** (el punto en disputa es el alcance externo):

```bash
nc -vz 10.43.100.141 80
nc -vz 10.43.100.141 443
curl -sS -o /dev/null -w "http %{http_code}\n"  http://10.43.100.141/health
curl -sSk -o /dev/null -w "https %{http_code}\n" https://10.43.100.141/health
```

Y en el host, para separar «puerto cerrado» de «TLS mal montado»:

```bash
ssh <usuario>@10.43.100.141 'ss -tulpn | grep -E ":(80|443|3001|8080)"; docker logs --tail 50 mani-api-gateway'
```

**Evidencia a pegar:** las cuatro salidas de red **indicando desde qué red se corrió**, más `ss -tulpn` y las últimas líneas del log del Gateway. Si 443 responde en el host pero no desde la red, la discrepancia es de perímetro, no de configuración.

### D7 · Kafka en DEV y QA — Daniel y Sara

```bash
for h in 10.43.98.232 10.43.100.141; do
  echo "===== $h"
  ssh <usuario>@$h '
    docker ps -a --filter name=kafka --format "{{.Names}}\t{{.Image}}\t{{.Status}}"
    docker exec $(docker ps -q --filter name=kafka | head -1) \
      kafka-topics.sh --bootstrap-server localhost:9092 --list 2>/dev/null
  '
done
```

**Evidencia a pegar:** contenedores de Kafka por host y la lista de tópicos, contra los tópicos canónicos de [`../02-arquitectura/ARQ-05-despliegue-kafka-dev-qa.md`](../02-arquitectura/ARQ-05-despliegue-kafka-dev-qa.md). Además, el estado vigente de ADR-0029. Si no hay contenedor, se escribe «Kafka no desplegado en \<host\>», no «pendiente».

### D8 · Observabilidad — Daniel y Sara

```bash
ssh <usuario>@10.43.100.141 '
  docker ps --filter name=prometheus --filter name=grafana --format "{{.Names}}\t{{.Image}}\t{{.Status}}"
  curl -sS localhost:9090/-/ready; echo
  curl -sS localhost:9090/api/v1/targets | head -c 2000; echo
'
curl -sS http://10.43.100.141/metrics | head -20
```

**Evidencia a pegar:** contenedores de Prometheus y Grafana **con su fecha de creación** (para fijar si existen desde el 6-nov), los *targets* que realmente recolecta y la cabecera de `/metrics`. Con eso se corrige SDD §8 e Infraestructura V4 §7, que hoy declaran la observabilidad como futura ([SCRUM-1686](https://maniservices.atlassian.net/browse/SCRUM-1686)).

### D9 · Respaldos — Daniel

```bash
ssh <usuario>@<host-de-backups> '
  ls -lh /opt/database-backups/mani/pre-consolidation/ | tail -20
  ls -lt /opt/database-backups/mani/ | head -20
  crontab -l 2>/dev/null | grep -i -E "dump|backup"
  grep -rl "pg_dump" /opt/database-backups /opt/scripts 2>/dev/null | head
'
```

**Evidencia a pegar:** el script de `pg_dump` **con su ruta y su commit en git si está versionado**, la entrada de `cron` que lo ejecuta y la **fecha del último respaldo**. Si el script no está versionado, la fila se cierra como «solo volcados puntuales» y se corrige el informe de DevOps.

### D10 · Migraciones y `BYPASSRLS` en PROD — Daniel y Santiago

Contra el proyecto Supabase de PROD (`tjxueukivwxsgipltqwb`), en el editor SQL o con `psql`:

```sql
SELECT rolname, rolbypassrls, rolsuper
  FROM pg_roles
 WHERE rolname IN ('postgres','service_role','authenticator','authenticated','anon')
 ORDER BY rolname;

SELECT count(*) AS migraciones, max(version) AS ultima
  FROM supabase_migrations.schema_migrations;

SELECT count(*) AS politicas_activas FROM pg_policies;
```

Repetir **lo mismo** contra QA (`hpsxdotaizzclkeufzct`) para poder afirmar o negar paridad.

**Evidencia a pegar:** las tres salidas por ambiente, con la fecha. Comparar el conteo de migraciones con la serie real `0001`–`0033` de `MANI-Node/db/migrations` (Infraestructura V4 §6.2). La afirmación «roles sin `BYPASSRLS` en PROD» se sostiene solo si `rolbypassrls` es `f` para `service_role` **y** para `postgres`.

### D14-PROD · Estado de Jardinería en PROD — Camila y Daniel *(informativo, no bloquea)*

> Tras la decisión **P-D14** ([§4](#4-decisiones-tomadas)), el estado de una categoría es configuración de operación. Esta consulta se conserva porque el dato es útil, pero **no es requisito para cerrar SCRUM-1696**.

```sql
SELECT tenant_id, nombre, estado, flujo_operativo
  FROM categoria_servicio
 WHERE lower(btrim(nombre)) = 'jardineria'
 ORDER BY tenant_id;
```

**Evidencia a pegar:** la fila por tenant en PROD. El lado QA ya está verificado en la semilla (§2, D14).

### Bloque único para copiar y pegar

Las siete comprobaciones pendientes en un solo bloque. **Nada de lo que sigue se ha ejecutado desde este entorno**: no hay acceso a las VMs (`10.43.x.x`), a los proyectos de Supabase ni a la red de la universidad. Las salidas se pegan en este documento, en la fila que corresponde.

**Antes de pegar:** revisar que la salida no traiga contraseñas, tokens ni cadenas de conexión. Si las trae, sustituirlas por `<redactado>`. Pegar la salida completa, con fecha y host.

```bash
# =====================================================================
#  HU-VAL-01 — 7 comprobaciones pendientes
#  Pedir el usuario SSH al DevOps Lead y sustituir <usuario>.
#  DEV 10.43.98.232 · QA 10.43.100.141 · PROD 10.43.98.203
# =====================================================================

# ---- D1 · version real de PROD (Daniel y Camila) --------------------
ssh <usuario>@10.43.98.203 '
  docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
  for c in $(docker ps --format "{{.Names}}"); do
    echo "== $c"; docker inspect --format "{{.Image}} {{index .RepoDigests 0}}" "$c" 2>/dev/null
  done
'
# Pegar tambien: las 18 rutas del front en PROD, una linea por ruta
# (ruta, codigo HTTP, carga si/no). Es lo que pide SCRUM-1638.

# ---- D5 · servicios por ambiente (Daniel y Sara) -------------------
for h in 10.43.98.232 10.43.100.141 10.43.98.203; do
  echo "===== $h"; ssh <usuario>@$h 'docker ps --format "{{.Names}}\t{{.Image}}\t{{.Status}}"'
done
# Decir explicitamente si Availability corre en PROD y si Landing esta en PROD.

# ---- D6 · puertos de QA (Daniel y Santiago) ------------------------
# DESDE LA RED DE LA UNIVERSIDAD, no desde el propio host:
nc -vz 10.43.100.141 80
nc -vz 10.43.100.141 443
curl -sS  -o /dev/null -w "http  %{http_code}\n"  http://10.43.100.141/health
curl -sSk -o /dev/null -w "https %{http_code}\n" https://10.43.100.141/health
# Y en el host, para separar puerto cerrado de TLS mal montado:
ssh <usuario>@10.43.100.141 'ss -tulpn | grep -E ":(80|443|3001|8080)"; docker logs --tail 50 mani-api-gateway'

# ---- D7 · Kafka en DEV y QA (Daniel y Sara) ------------------------
for h in 10.43.98.232 10.43.100.141; do
  echo "===== $h"
  ssh <usuario>@$h '
    docker ps -a --filter name=kafka --format "{{.Names}}\t{{.Image}}\t{{.Status}}"
    docker exec $(docker ps -q --filter name=kafka | head -1) \
      kafka-topics.sh --bootstrap-server localhost:9092 --list 2>/dev/null
  '
done
# Si no hay contenedor, escribir "Kafka no desplegado en <host>", no "pendiente".

# ---- D8 · observabilidad (Daniel y Sara) ---------------------------
ssh <usuario>@10.43.100.141 '
  docker ps --filter name=prometheus --filter name=grafana \
    --format "{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.CreatedAt}}"
  curl -sS localhost:9090/-/ready; echo
  curl -sS localhost:9090/api/v1/targets | head -c 2000; echo
'
curl -sS http://10.43.100.141/metrics | head -20
# La fecha de creacion de los contenedores es la que fija si existen desde el 6-nov.

# ---- D9 · respaldos (Daniel) ---------------------------------------
ssh <usuario>@<host-de-backups> '
  ls -lh /opt/database-backups/mani/pre-consolidation/ | tail -20
  ls -lt /opt/database-backups/mani/ | head -20
  crontab -l 2>/dev/null | grep -i -E "dump|backup"
  grep -rl "pg_dump" /opt/database-backups /opt/scripts 2>/dev/null | head
'
# Hace falta: ruta del script, su commit en git si esta versionado,
# la entrada de cron y la fecha del ultimo respaldo.
```

```sql
-- ---- D10 · migraciones y BYPASSRLS (Daniel y Santiago) -------------
-- Correr en el editor SQL de Supabase, PRIMERO en PROD
-- (tjxueukivwxsgipltqwb) y DESPUES en QA (hpsxdotaizzclkeufzct).

SELECT rolname, rolbypassrls, rolsuper
  FROM pg_roles
 WHERE rolname IN ('postgres','service_role','authenticator','authenticated','anon')
 ORDER BY rolname;

SELECT count(*) AS migraciones, max(version) AS ultima
  FROM supabase_migrations.schema_migrations;

SELECT count(*) AS politicas_activas FROM pg_policies;

-- Informativo, D14-PROD (ya no bloquea):
SELECT tenant_id, nombre, estado, flujo_operativo
  FROM categoria_servicio
 WHERE lower(btrim(nombre)) = 'jardineria'
 ORDER BY tenant_id;
```

«Roles sin `BYPASSRLS` en PROD» se sostiene **solo** si `rolbypassrls` es `f` para `service_role` **y** para `postgres`. El conteo de migraciones se compara con la serie real `0001`–`0033` de `MANI-Node/db/migrations` (Infraestructura V4 §6.2).

## 4. Decisiones tomadas

**Decisión tomada: Sara Albarracín (Scrum Master), 2026-11-11.** Cada una registra la opción elegida, lo descartado y la cadena necesidad → requisito → atributo de calidad → decisión. Una decisión que no se pudo anclar a un requisito **no se tomó** y está en [§5](#5-lo-único-que-sigue-abierto).

### D4 · RPO y RTO: rige el umbral de QAS-17

- **A.** Adoptar el par de DevOps, `RPO < 24 h` y `RTO < 2 h`.
- **B.** Mantener el de QAS-17, `RPO ≤ 5 min` y `RTO ≤ 30 min`. ← **elegida**
- **C.** Declarar dos niveles, objetivo arquitectónico y compromiso del MVP, con umbrales distintos.

**Decisión: B.** El umbral de QAS-17 ([`SDD.md`](../02-arquitectura/SDD.md) §8.3) es el único de los tres que vive en un artefacto vigente y además trae su método de medición y su evidencia esperada. El SDD es, por su propia cabecera, **el único lugar donde viven los umbrales de calidad**. Las cifras de DevOps y de la opción B no están en ningún artefacto con autoridad, y [`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §1 dice que lo que no está documentado no se exige.

**A y C descartadas.** A cambiaría un umbral vigente sin acta que lo respalde. C duplica el umbral y multiplica por dos el trabajo de medición de QA sin que ningún requisito pida dos niveles; es sobrearquitectura.

**Qué implica.** No se cambia QAS-17. Se corrigen a esa cifra el informe de DevOps y el material de la opción B. Esta decisión **no se cuenta como verificación**: el escenario sigue **No medido**, porque no hay respaldo periódico ni prueba de restauración (fila D9).

**Trazabilidad:** necesidad = restaurar el servicio y los datos tras una pérdida → **requisito: no existe un RNF de recuperabilidad** (los RNF van de RNF-01 a RNF-11 y ninguno la cubre) → atributo de calidad = Recuperabilidad P1, QAS-17 → decisión = mantener el umbral documentado. **El hueco del requisito queda abierto en [§5](#5-lo-único-que-sigue-abierto):** por eso esta decisión se limita a no cambiar lo que ya está escrito y no fija una cifra nueva.

### D12 · El acta de ajustes la firma Camila Beltrán como Product Owner

- **A.** Firma Sara como PO, según el análisis de calidad.
- **B.** Firma Camila Beltrán como PO; Sara firma como Scrum Master. ← **elegida**
- **C.** Firma Nicolás León, que es el PO en la tabla de roles de gobernanza.

**Decisión: B.** Tres artefactos del backlog del 9 de noviembre la designan PO de forma independiente: [SCRUM-1661](https://maniservices.atlassian.net/browse/SCRUM-1661) («Camila (PO) lo valida»), [SCRUM-1687](https://maniservices.atlassian.net/browse/SCRUM-1687) («PO - Decisiones pendientes de producto», asignada a ella) y [SCRUM-1700](https://maniservices.atlassian.net/browse/SCRUM-1700) («con decisión de Camila Beltrán (PO)»).

**A descartada** porque [`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §2.3 separa la autoridad del PO de la del SM: quien facilita no acepta el incremento. **C descartada** porque ningún artefacto vigente asigna decisiones de producto a Nicolás León.

**Consecuencia que hay que arreglar.** [`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §2.1 sigue diciendo que el PO es Nicolás León y que Santiago es su segundo rol. Queda una **enmienda** anotada en ese documento; la tabla no se reescribe por decisión de una sola persona, porque un cambio de rol se acuerda en equipo.

**Trazabilidad:** necesidad = un acta válida y auditable → requisito = RNF-04 (trazabilidad y auditabilidad suficientes para reconstruir el ciclo) → atributo de calidad = Mantenibilidad/gobernanza, con la autoridad por rol de §2.3 → decisión = firma el PO de los artefactos vigentes.

### P-D2 · El pago tardío se mantiene como está; no se añade plazo

- **A.** Ocultar «Pagar» cuando el servicio ya finalizó (Idea 1).
- **B.** Mantener el comportamiento actual: pagar, liberar y liquidar. ← **elegida**
- **C.** Mantenerlo pero con un plazo máximo para pagar.

**Decisión: B.** Es lo que el código ya hace (§2, D2) y lo que fijaron las decisiones 891/892. **A descartada** porque contradice el código verificado y la decisión vigente. **C descartada** porque ningún requisito pide un plazo: RF-24 (cobro en línea con operador certificado) y RF-25 (liquidación con comisión configurable) están en el **segundo incremento y fuera del MVP**, y el botón actual es sandbox. Inventar un plazo sería crear alcance sin requisito.

**Qué implica.** Se retira la Idea 1 del documento de mejoras de producto. No se toca el código.

**Trazabilidad:** necesidad = cobrar el servicio prestado → requisito = RF-24 y RF-25, **fuera del MVP** → atributo de calidad = Adecuación funcional P2 ([`SDD.md`](../02-arquitectura/SDD.md) §8.8) → decisión = no cambiar nada y no añadir reglas.

### P-D14 · El estado de una categoría es configuración de operación, no una discrepancia documental

- **A.** Activar Jardinería en PROD.
- **B.** Desactivarla en PROD para igualar QA.
- **C.** Tratarlo como dato de operación por tenant, sin cambio documental. ← **elegida**

**Decisión: C.** RF-10 define activar y desactivar categorías como una **función del producto**, y RNF-02 y RNF-10 las hacen configurables por tenant sin código ni despliegue. Que una categoría esté activa en un ambiente e inactiva en otro no es una contradicción entre documentos: es el administrador del tenant ejerciendo RF-10. En QA, además, `INACTIVO` es un **fixture deliberado** (§2, D14).

**A y B descartadas** porque fijarían en un documento el valor de un dato que el producto expone como configurable, y el documento quedaría desactualizado en la primera operación del administrador.

**Qué implica.** D14 deja de ser discrepancia. La consulta de PROD de §3 queda **informativa** y **no bloquea** el cierre de SCRUM-1696.

**Trazabilidad:** necesidad = cada tenant ofrece su propio catálogo → requisito = RF-10, con RNF-02 y RNF-10 → atributo de calidad = Flexibilidad P1 ([`SDD.md`](../02-arquitectura/SDD.md) §8.6) → decisión = es dato de operación.

### P-D15a · SCRUM-1383 conserva un responsable único

- **A.** Partir la historia en dos tickets, uno de infraestructura y otro de Core.
- **B.** Mantener [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383) con un responsable único, Daniel Ávila, y el trabajo de Core como subtarea del mismo ticket. ← **elegida**

**Decisión: B.** [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699) dice explícitamente que la implementación «sigue en el ticket existente SCRUM-1383, que no se duplica». Partirlo rompería esa instrucción y dejaría dos historias que solo se pueden verificar juntas, porque la comprobación de Santiago —que ya no quede texto en claro— es una sola consulta sobre las mismas tablas.

**Trazabilidad:** necesidad = poder reconstruir quién hizo qué sobre un dato sensible → requisito = RNF-04 → atributo de calidad = Mantenibilidad P1 → decisión = un responsable y una historia.

**Lo que esta decisión NO resuelve:** qué se cifra y con qué mecanismo. Eso es P-D15b, en §5.

## 5. Lo único que sigue abierto

### P-D15b · Mecanismo de cifrado de datos personales — no decidido, falta el requisito

La decisión de cifrar `aliado.numero_documento_identidad`, `usuario.telefono`, `cliente.nit`, `cliente.telefono` y `sitio.contacto_telefono` **no se toma aquí**, y no por falta de criterio técnico sino porque **la cadena de trazabilidad está rota en dos eslabones**:

- **No hay requisito.** Los RNF vigentes van de RNF-01 a RNF-11 y ninguno exige cifrado en reposo. RNF-01 es aislamiento entre tenants, que es otra cosa; RNF-06 dice que PCI DSS recae en el operador de pagos, no en MANI.
- **No hay atributo de calidad medible.** El SDD tiene QAS-01 (confidencialidad entre tenants) y QAS-43 (confidencialidad **en tránsito**, TLS). **No existe un escenario de confidencialidad en reposo**, de modo que no hay umbral ni método con el que QA pueda verificar la decisión.

Lo que sí está documentado es la **necesidad**: [`SRS.md`](../01-producto/SRS.md) cita la **Ley 1581 de 2012** como el marco que obligó a ADR-0024 en pagos, y los cinco campos son datos personales bajo esa misma ley.

**Para desbloquear hacen falta dos artefactos que son del PO, no del SM** (`GOBIERNO_DEL_EQUIPO.md` §2.3: los requisitos y los criterios los decide el PO):

1. Un **RNF nuevo** de protección de datos personales en reposo, con su prioridad.
2. Un **escenario QAS** derivado de él, con umbral y método (por ejemplo: «0 campos de la lista legibles en una consulta directa a la tabla con un rol sin privilegio de descifrado»).

Con esos dos, el ADR de [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699) se puede escribir y decidir entre pgcrypto en el motor y cifrado desde Core con la llave en un secreto. Sin ellos, cualquier elección sería una cifra inventada.

## 6. Cierre

[SCRUM-1696](https://maniservices.atlassian.net/browse/SCRUM-1696) **no se cierra** hasta que las **siete** filas de §3 (D1, D5, D6, D7, D8, D9, D10) tengan su evidencia pegada aquí y el historial de cambios lo registre. La consulta de D14-PROD queda informativa y no bloquea. Mientras eso no ocurra, en la sustentación esas siete filas se presentan como **pendientes de validar**.

Las decisiones de §4 están cerradas y no esperan evidencia. P-D15b sigue abierto y espera dos artefactos del PO.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 2.0 | 2026-11-11 | Sara asume la autoridad de decisión y se cierran cinco puntos: D4 (rige QAS-17), D12 (firma Camila como PO, con enmienda anotada en `GOBIERNO_DEL_EQUIPO.md` §2.1), P-D2 (el pago tardío se mantiene, sin plazo nuevo), P-D14 (el estado de una categoría es configuración de operación) y P-D15a (un solo responsable para SCRUM-1383). Cada una con alternativa descartada y trazabilidad. **Se corrige el conteo a 6 de 15 verificadas**: D4 y D12 se contaban como verificadas y no lo eran. Se aclara 7 filas / 8 comprobaciones, y que lo exigible para cerrar son 7. Se añade el bloque único de comandos para las comprobaciones pendientes. **P-D15b (mecanismo de cifrado) no se decide**: faltan un RNF y un QAS, que son del PO. | Sara Albarracín |
| 1.1 | 2026-11-11 | D2: se localiza el commit `098bf38c3f8f77cd863ea3daa592608eaf5c74c2` en `MANI-Node` tras `git fetch --all` en los siete repositorios, se retira la reserva de la versión 1.0 y se pega el fragmento de `PgPaymentRepository.js` que libera y liquida el pago tardío. Se reconfirman D3, D13 y D15 contra Jira y `origin/main`; el recuento de filas no cambia (8 de 15). | Sara Albarracín |
| 1.0 | 2026-11-10 | Documento inicial. 8 filas verificadas (D2, D3, D4, D11, D12, D13, D14 lado QA, D15), 7 pendientes con su comando y responsable, 5 preguntas de decisión abiertas. | Sara Albarracín |

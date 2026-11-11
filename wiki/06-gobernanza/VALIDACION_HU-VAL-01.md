# Validación de discrepancias entre documentos (HU-VAL-01)

[← Índice de la wiki](../Home.md) · [← 06 Gobernanza](README.md)

| Campo | Valor |
|---|---|
| **Finalidad** | Dejar una sola cifra y un solo estado por cada punto en que los documentos del proyecto se contradicen, con la verificación hecha en el sistema o en el código, no en otro documento. |
| **Origen** | [SCRUM-1696](https://maniservices.atlassian.net/browse/SCRUM-1696) (HU-VAL-01) |
| **Coordina** | Sara Albarracín (Scrum Master) |
| **Consume** | PO, Arquitectura, DevOps y QA antes de la sustentación |
| **Versión** | 1.1 |
| **Fecha de corte** | 2026-11-11 |
| **Estado** | **PARCIAL.** 8 de 15 filas verificadas. 7 filas (D1, D5, D6, D7, D8, D9, D10) exigen sesión en las VMs, consulta a Supabase o prueba desde la red de la universidad, y quedan **pendientes de validar**. |
| **Se actualiza** | Cada vez que se cierra una fila; obligatorio antes de cada sustentación. |

> **Regla de este documento.** Una fila sin evidencia pegada se declara «pendiente de validar», nunca como hecho. Las filas de decisión no se resuelven aquí: se formulan como pregunta al rol con autoridad sobre el artefacto ([`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §2.3).

## 1. Estado por fila

| ID | Tema | Estado | Validador |
|---|---|---|---|
| D1 | Versión de PROD y rutas del front | Pendiente de validar | Daniel y Camila |
| D2 | Botón «Pagar» tras finalizar | **Verificado en código** (queda una decisión escrita) | Camila y Nicolás Álvarez |
| D3 | Pantallas con actualización automática | **Verificado en código** | Nicolás Álvarez |
| D4 | RPO/RTO | Verificado el conflicto; **falta la decisión** | Daniel, Camila y Sara |
| D5 | Servicios por ambiente | Pendiente de validar | Daniel y Sara |
| D6 | Puertos de QA | Pendiente de validar | Daniel y Santiago |
| D7 | Kafka en DEV y QA | Pendiente de validar | Daniel y Sara |
| D8 | Observabilidad | Pendiente de validar | Daniel y Sara |
| D9 | Respaldos | Pendiente de validar | Daniel |
| D10 | Migraciones y `BYPASSRLS` | Pendiente de validar | Daniel y Santiago |
| D11 | Cifras del Sprint 5 | **Verificado en Jira** | Sara y Camila |
| D12 | Quién firma el acta de ajustes | Verificado el conflicto; **falta la decisión** | Sara y Camila |
| D13 | HU-M04-05 sin historia en Jira | **Verificado en Jira** | Sara y Camila |
| D14 | Jardinería activa en PROD, inactiva en QA | **Verificado en código el lado QA**; PROD pendiente | Camila y Daniel |
| D15 | Responsable de SCRUM-1383 | **Verificado en Jira**; el alcance en Core es decisión | Sara, Daniel y Nicolás Álvarez |

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

### D14-PROD · Estado de Jardinería en PROD — Camila y Daniel

```sql
SELECT tenant_id, nombre, estado, flujo_operativo
  FROM categoria_servicio
 WHERE lower(btrim(nombre)) = 'jardineria'
 ORDER BY tenant_id;
```

**Evidencia a pegar:** la fila por tenant en PROD. El lado QA ya está verificado en la semilla (§2, D14).

## 4. Preguntas de decisión abiertas

Ninguna se resuelve en este documento. Cada una va al rol con autoridad y su respuesta se escribe donde se indica.

| # | Pregunta | Responde | Dónde se escribe |
|---|---|---|---|
| P-D4 | ¿Cuál es el **RPO y el RTO exigibles** del MVP? Hoy conviven tres pares incompatibles: `< 24 h / < 2 h` (DevOps), `5 min / 30 min` (QAS-17) y `24 h / 30 min` (opción B). ¿Se adopta uno, o se declaran dos niveles —objetivo arquitectónico y compromiso del MVP— con su umbral verificable? | Arquitectura con DevOps; ratifica la Mesa | Una sola cifra en el acta A/B, y de ahí a QAS-17, a SDD §7 y a Infraestructura V4 ([SCRUM-1685](https://maniservices.atlassian.net/browse/SCRUM-1685)) |
| P-D12 | ¿**Quién firma el acta de ajustes** como Product Owner? El análisis de calidad dice «Sara como PO»; la tabla de roles asigna el PO a Camila. ¿Firma Camila como PO y Sara como SM, o se corrige el rol? | PO y SM, según [`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §2.3 | El acta firmada, y corrección del documento que atribuyó mal el rol |
| P-D2 | El código permite pagar después de finalizar el servicio (§2, D2). ¿Se **ratifica** la decisión 891/892 —pagar, liberar y liquidar— y se retira la Idea 1 de ocultar «Pagar»? ¿Hay un plazo máximo para el pago tardío? | PO | Decisión escrita y retiro o reformulación de la Idea 1; si se ratifica, prueba del pago tardío |
| P-D14 | ¿**Jardinería debe estar activa en PROD**? En QA está inactiva a propósito como caso de prueba. | PO | Decisión escrita; si debe estar activa en PROD, el dato se corrige en PROD, no en la semilla de QA |
| P-D15 | El cifrado ([SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383)) está asignado a Daniel, pero parte del trabajo está en Core. ¿Se **mantiene un responsable único** o se parte la historia por repositorio? ¿Qué se cifra, con qué mecanismo y dónde viven las llaves? | Arquitectura con el PO; el mecanismo va a ADR | Reasignación o división en Jira, y el ADR de cifrado ([SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699)) |

## 5. Cierre

[SCRUM-1696](https://maniservices.atlassian.net/browse/SCRUM-1696) **no se cierra** hasta que las siete filas de §3 tengan su evidencia pegada aquí y el documento corregido lo registre en su historial de cambios. Mientras eso no ocurra, en la sustentación estas siete filas se presentan como **pendientes de validar**.

Las cinco filas de §4 son decisiones, no verificaciones: se cierran con la decisión escrita y firmada por el rol con autoridad, no con una corrección documental.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.1 | 2026-11-11 | D2: se localiza el commit `098bf38c3f8f77cd863ea3daa592608eaf5c74c2` en `MANI-Node` tras `git fetch --all` en los siete repositorios, se retira la reserva de la versión 1.0 y se pega el fragmento de `PgPaymentRepository.js` que libera y liquida el pago tardío. Se reconfirman D3, D13 y D15 contra Jira y `origin/main`; el recuento de filas no cambia (8 de 15). | Sara Albarracín |
| 1.0 | 2026-11-10 | Documento inicial. 8 filas verificadas (D2, D3, D4, D11, D12, D13, D14 lado QA, D15), 7 pendientes con su comando y responsable, 5 preguntas de decisión abiertas. | Sara Albarracín |

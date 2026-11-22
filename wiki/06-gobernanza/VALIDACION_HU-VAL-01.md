# Validación de discrepancias entre documentos (HU-VAL-01)

[← Índice de la wiki](../Home.md) · [← 06 Gobernanza](README.md)

| Campo | Valor |
|---|---|
| **Finalidad** | Dejar una sola cifra y un solo estado por cada punto en que los documentos del proyecto se contradicen, con la verificación hecha en el sistema o en el código, no en otro documento. |
| **Origen** | [SCRUM-1696](https://maniservices.atlassian.net/browse/SCRUM-1696) (HU-VAL-01) |
| **Coordina** | Sara Albarracín (Scrum Master) |
| **Consume** | PO, Arquitectura, DevOps y QA antes de la sustentación |
| **Versión** | 2.3 |
| **Fecha de corte** | 2026-11-19 |
| **Estado** | **14 de 15 filas cerradas.** **12 verificadas con evidencia de sistema o de código**: D1, D2, D3, D5, D6, D7, D8, D9, D11, D13, D14 y D15. **2 cerradas por decisión**, que no son verificaciones: D4 y D12, más las decisiones P-D2, P-D14 y P-D15a. **Queda una sola pendiente: D10**, migraciones y `BYPASSRLS` en PROD. |
| **Corrección de conteo** | La versión 1.0 y la 1.1 decían «8 de 15 verificadas» contando D4 y D12 como verificadas. No lo eran: en esas dos filas se verificó que **existía el conflicto**, no cuál era el dato correcto. El avance real verificado es **6 de 15**. |
| **Salto del 2026-11-19** | Seis filas (D1, D5, D6, D7, D8 y D9) se cerraron de una vez con la evidencia que DevOps capturó el 14 y el 15 de noviembre y publicó en `wiki/08-infraestructura/`. No hubo que ejecutar nada nuevo: la evidencia ya estaba escrita y solo faltaba contrastarla contra cada fila. |
| **Se actualiza** | Cada vez que se cierra una fila; obligatorio antes de cada sustentación. |

> **Regla de este documento.** Una fila sin evidencia pegada se declara «pendiente de validar», nunca como hecho. **Una decisión no es una verificación** y se cuenta aparte: las decisiones viven en [§4](#4-decisiones-tomadas) con su alternativa descartada y su trazabilidad; las verificaciones viven en §2 con su evidencia.

## 1. Estado por fila

| ID | Tema | Estado | Validador |
|---|---|---|---|
| D1 | Versión de PROD y rutas del front | **VERIFICADO** el 2026-11-14 en sistema real | Daniel y Camila |
| D2 | Botón «Pagar» tras finalizar | **Verificado en código** y **decidido** (P-D2) | Camila y Nicolás Álvarez |
| D3 | Pantallas con actualización automática | **Verificado en código** | Nicolás Álvarez |
| D4 | RPO/RTO | **Decidido** (D4): rige el umbral de QAS-17 | Daniel, Camila y Sara |
| D5 | Servicios por ambiente | **VERIFICADO** el 2026-11-14 (`docker ps` por ambiente) | Daniel y Sara |
| D6 | Puertos de QA | **VERIFICADO** el 2026-11-14 (`ss -tulpn`): 443 **sí** escucha | Daniel y Santiago |
| D7 | Kafka en DEV y QA | **VERIFICADO** el 2026-11-14: en DEV y QA sí, en PROD no | Daniel y Sara |
| D8 | Observabilidad | **VERIFICADO** el 2026-11-14: no está en la VM de QA, está en la de Calidad | Daniel y Sara |
| D9 | Respaldos | **VERIFICADO** el 2026-11-15: automatización diaria cifrada, con simulacro `PASS` | Daniel |
| D10 | Migraciones y `BYPASSRLS` | **Pendiente de validar — la única que queda** | Daniel y Santiago |
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

**Conclusión.** El plan de módulos cita una historia inexistente. La decisión —crear la historia o retirar el ítem— ya está asignada en SCRUM-1687 y es del PO; el plan de módulos marcaba HU-M04-05 como planificada cuando no tenía historia.

**Decisión del PO, 2026-11-10 (Camila Beltrán, en [SCRUM-1687](https://maniservices.atlassian.net/browse/SCRUM-1687)): el ítem se retira porque su alcance ya está cubierto.** Las tres historias que lo cubren existen y están `Done`, verificado el 2026-11-13:

| Historia | Qué cubre | Estado |
|---|---|---|
| [SCRUM-1390](https://maniservices.atlassian.net/browse/SCRUM-1390) | HU-M04-01, crear categoría de servicio con flujo operativo | `Done` |
| [SCRUM-1391](https://maniservices.atlassian.net/browse/SCRUM-1391) | HU-M04-02, activar y desactivar categoría sin afectar servicios en curso | `Done` |
| [SCRUM-1393](https://maniservices.atlassian.net/browse/SCRUM-1393) | HU-M04-04, catálogo jerárquico de zonas geográficas | `Done` |

**Precisión de forma, para que el plan de módulos quede bien redactado.** Las tres son **HU-M04-01, 02 y 04**; ninguna es HU-M04-05. Lo correcto es escribir «**HU-M04-05 se retira del plan de módulos porque su alcance queda cubierto por 1390, 1391 y 1393**», y no que HU-M04-05 exista o esté hecha. La historia que el plan citaba, SCRUM-1394, nunca se creó. **Fila cerrada.**

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

## 3. Filas cerradas con la evidencia de infraestructura

Seis filas se cerraron el **2026-11-19** con evidencia que DevOps capturó el **14 y 15 de noviembre** y publicó en [`08-infraestructura/01-mapa-ambientes-y-versiones.md`](../08-infraestructura/01-mapa-ambientes-y-versiones.md) §5 y [`04-respaldos-y-restauracion.md`](../08-infraestructura/04-respaldos-y-restauracion.md). No se ejecutó nada nuevo: la evidencia ya estaba escrita y faltaba contrastarla contra cada fila.

### D1 · La versión de PROD coincide con `v1.0.4`

**Evidencia.** El digest de `mani-flutter-web` en PROD es `sha256:79b3d323976857d17f2ad150dc81a0dad44c1f507304b6b47119e0af1c77d2d7`, y **coincide exacto** con el tag `v1.0.4` publicado en GHCR (commit `7d7521a`). Además `check-prod.sh` devuelve **`200 OK` en los seis endpoints y en las dieciocho rutas** de la aplicación.

**Conclusión.** La discrepancia desaparece por los dos lados: la versión es la que el informe de DevOps decía, **y** las rutas abren. El front antiguo con 12 de 18 rutas rotas que vio Camila el 9 de noviembre correspondía a un despliegue anterior. Esta evidencia es también la que pedía [SCRUM-1638](https://maniservices.atlassian.net/browse/SCRUM-1638).

### D5 · Servicios por ambiente

**Evidencia.** Conteo de contenedores por ambiente: **QA** ejecuta 7 servicios de aplicación más 6 de observabilidad y logs; **PROD** ejecuta 6, sin Kafka; **Calidad** ejecuta 6 contenedores de monitoreo. Cada servicio con su imagen y su digest en el mapa de ambientes §2.

**Conclusión.** La lista de DevOps era correcta en el número. El punto en disputa —si `Availability` corre en PROD— se resuelve en negativo: no aparece entre los contenedores de ningún ambiente, de modo que **lo que hay que corregir es el SAD**, que lo incluye en su tabla de contenedores.

### D6 · En QA el 443 sí escucha

**Evidencia.** `ss -tulpn` en QA (`10.43.100.141`) muestra escuchando: `80`, **`443` con TLS 1.2+**, `8080`, `3001`, `9092`, los exportadores (`9100`, `8081`, `9187`, `9113`, `4040`), Promtail (`9080`) y `10050`.

**Conclusión.** **El informe de DevOps tenía razón y el reporte de QA estaba equivocado**, o medía desde una red sin acceso. El puerto está abierto y con TLS moderno. Si alguien vuelve a ver un rechazo, es un problema de perímetro o de la red desde la que se prueba, no de configuración del servidor.

### D7 · Kafka corre en DEV y QA, no en PROD

**Evidencia.** `mani-kafka` (`apache/kafka:3.8.0`, digest `sha256:c89f315cff9673…`, estado *healthy*) escuchando en `9092` en **DEV** y en **QA**. En **PROD no existe**.

**Conclusión.** La descripción de la VM de QA que no lo listaba estaba incompleta. Queda un dato nuevo que conviene no perder: **PROD no tiene Kafka**, así que cualquier flujo que dependa de eventos asíncronos no funciona allí todavía. Eso afecta a ADR-0029 y a la restricción **PROY-10**, y no es parte de esta fila.

### D8 · La observabilidad existe, pero no donde la fila suponía

**Evidencia.** Prometheus, Grafana, Alertmanager, Loki, Blackbox y Mailpit corren en la **VM de Calidad (`10.43.98.196`)**, con versiones fijas y ligados a `127.0.0.1`: Prometheus `:9090`, Alertmanager `:9093`, Grafana `:3000`, Loki `0.0.0.0:3100`. **No corren en la VM de QA.**

**Conclusión.** La respuesta es más precisa que la pregunta. Las tres fuentes se reconcilian así: el análisis de monitoreo tenía razón en que existen, DevOps tenía razón en que no están en QA, y el SDD §8 estaba desactualizado. **Con esto se desbloquea [SCRUM-1686](https://maniservices.atlassian.net/browse/SCRUM-1686)**, que esperaba justo este dato, y hay que escribir en el SDD que el monitoreo vive en Calidad y se consulta por túnel, no que «no hay».

### D9 · Respaldos automáticos, cifrados y con simulacro

**Evidencia.** Automatización diaria activa: `pg_dump` 17 con timer `mani-backup.timer` a las `02:00 COT`, cifrado **AES-256-CBC**, retención `14d`/`4w`, réplica fuera del host y clúster aislado de restauración. Simulacro cronometrado con resultado **`PASS`**: en QA y PROD, 19 s de volcado y **2 s de restauración**, muy por debajo del objetivo. Archivos con nombre y tamaño (`qa_20261115T034503Z.pgdump.enc`, 951 472 B; `prod_20261115T034503Z.pgdump.enc`, 736 288 B).

**Conclusión.** La afirmación de «solo volcados puntuales» ya no es cierta. **Y hay una consecuencia fuera de esta fila:** QAS-17 (recuperabilidad) figura en el SDD como `No medido`, y este simulacro **es** una medición. Hay que actualizarlo.

---

## 3.1 La única fila que queda: D10

### D10 · Migraciones y `BYPASSRLS` en PROD — Daniel y Santiago

**Sigue pendiente de validar.** Es la única.

**Aviso sobre el documento de origen.** La §5 del mapa de ambientes rotula una fila como «D10», pero su contenido responde a **D7** (Kafka en PROD frente a QA y DEV). La D10 real —cuántas migraciones hay aplicadas en PROD y si los roles tienen `BYPASSRLS`— **no está respondida en ningún documento**. Se deja dicho para que nadie la dé por cerrada leyendo esa etiqueta.

**Qué falta.** La consulta a la base de PROD (`tjxueukivwxsgipltqwb`) y la misma contra QA (`hpsxdotaizzclkeufzct`) para poder afirmar o negar paridad:

```sql
SELECT rolname, rolbypassrls, rolsuper
  FROM pg_roles
 WHERE rolname IN ('postgres','service_role','authenticator','authenticated','anon')
 ORDER BY rolname;

SELECT count(*) AS migraciones,
       count(*) FILTER (WHERE version LIKE '00__') AS serie_core,
       count(*) FILTER (WHERE version LIKE '00_')  AS serie_gateway,
       max(version) FILTER (WHERE version LIKE '00__') AS ultima_core
  FROM public.schema_migrations;

SELECT count(*) AS politicas_activas FROM pg_policies;
```

**Evidencia a pegar:** las tres salidas por ambiente, con su fecha. Valor esperado al 2026-11-22, contado sobre los repositorios: **45 filas** = 37 de `MANI-Node/db/migrations` (`0001`–`0039`, sin `0011` ni `0012`) + 8 de `MANI-APIGateway/database/migrations` (`001`–`008`), con `ultima_core = '0039'`.

> **Corrección del 2026-11-22.** La versión anterior de esta consulta leía `supabase_migrations.schema_migrations` y comparaba contra la serie `0001`–`0033`. Las dos cosas estaban mal: las migraciones del proyecto se registran en la tabla propia `public.schema_migrations` (cada archivo hace `INSERT INTO schema_migrations`), no en la de la CLI de Supabase, y la serie de Core llega hoy a `0039`. Además, `max(version)` sin filtro devolvía `'008'`, porque compara texto y `'008'` > `'0039'`. La afirmación «roles sin `BYPASSRLS` en PROD» se sostiene solo si `rolbypassrls` es `f` para `service_role` **y** para `postgres`.

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

**Ratificado por el PO el 2026-11-10.** Camila Beltrán respondió las cuatro preguntas de pagos de Nicolás en [SCRUM-1687](https://maniservices.atlassian.net/browse/SCRUM-1687): **10 % de comisión, liberar al finalizar, liquidar todo lo retenido menos la comisión, y pago aparte**. Confirma la opción B desde la autoridad que corresponde, así que esta decisión deja de ser solo de la SM. Las dos primeras respuestas son exactamente lo que el código ya hace (§2, D2) y lo que añadió el commit `098bf38c3f8f77cd863ea3daa592608eaf5c74c2`. **El 10 % de comisión y el pago aparte no se verificaron en el código en esta revisión** y no se dan por implementados: son decisión registrada, no hallazgo.

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

[SCRUM-1696](https://maniservices.atlassian.net/browse/SCRUM-1696) **no se cierra** hasta que la **única** fila que queda, D10, tenga su evidencia pegada aquí y el historial de cambios lo registre. La consulta de D14-PROD queda informativa y no bloquea. Mientras eso no ocurra, en la sustentación esas siete filas se presentan como **pendientes de validar**.

Las decisiones de §4 están cerradas y no esperan evidencia. P-D15b sigue abierto y espera dos artefactos del PO.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 2.3 | 2026-11-19 | **Se cierran seis filas de una vez** con la evidencia que DevOps capturó el 2026-11-14 y 15 y publicó en `wiki/08-infraestructura/`, cuya §5 ya la mapeaba a estas filas. **D1**: el digest de `mani-flutter-web` en PROD coincide exacto con el tag `v1.0.4`, y `check-prod.sh` devuelve `200 OK` en los seis endpoints y las dieciocho rutas. **D5**: conteo de contenedores por ambiente. **D6**: `ss -tulpn` muestra que en QA el 443 **sí** escucha con TLS 1.2+, de modo que el reporte de QA que decía que rechazaba queda corregido. **D7**: Kafka corre en DEV y QA y **no** en PROD. **D8**: Prometheus y Grafana **no corren en la VM de QA** sino en la de Calidad, ligados a `127.0.0.1`; la respuesta es más precisa que la pregunta. **D9**: respaldo diario cifrado AES-256-CBC con simulacro cronometrado `PASS`. Se corrige además un desajuste de etiqueta en el documento de origen: lo que rotula «D10» responde en realidad a D7, y la **D10 verdadera sigue abierta**. | Sara Albarracín |
| 2.2 | 2026-11-13 | Se registran las decisiones del PO del 2026-11-10 (Camila Beltrán, [SCRUM-1687](https://maniservices.atlassian.net/browse/SCRUM-1687)). **D13 se cierra**: HU-M04-05 se retira del plan porque su alcance lo cubren 1390, 1391 y 1393, las tres `Done` y verificadas, con la precisión de que son HU-M04-01, 02 y 04 y ninguna es la 05. **D14-PROD se cierra**: Jardinería activa en PROD y desactivada en QA, con SCRUM-1641 `Done`. **P-D2 queda ratificado por el PO**, con la reserva de que el 10 % de comisión y el pago aparte no se verificaron en el código. | Sara Albarracín |
| 2.1 | 2026-11-13 | D8: se registra que la observabilidad con Prometheus y Grafana **la exige el profesor**, de modo que es una restricción de proyecto no escrita hasta hoy y el alcance deja de estar en duda. La fila **sigue pendiente de validar**: una exigencia no es una verificación. Se apuntan sus dos consecuencias: proponer PROY-09 en el SRS §3.1 y revisar ADR-0006, que está `Aceptado` con Datadog y no con Prometheus. | Sara Albarracín |
| 2.0 | 2026-11-11 | Sara asume la autoridad de decisión y se cierran cinco puntos: D4 (rige QAS-17), D12 (firma Camila como PO, con enmienda anotada en `GOBIERNO_DEL_EQUIPO.md` §2.1), P-D2 (el pago tardío se mantiene, sin plazo nuevo), P-D14 (el estado de una categoría es configuración de operación) y P-D15a (un solo responsable para SCRUM-1383). Cada una con alternativa descartada y trazabilidad. **Se corrige el conteo a 6 de 15 verificadas**: D4 y D12 se contaban como verificadas y no lo eran. Se aclara 7 filas / 8 comprobaciones, y que lo exigible para cerrar son 7. Se añade el bloque único de comandos para las comprobaciones pendientes. **P-D15b (mecanismo de cifrado) no se decide**: faltan un RNF y un QAS, que son del PO. | Sara Albarracín |
| 1.1 | 2026-11-11 | D2: se localiza el commit `098bf38c3f8f77cd863ea3daa592608eaf5c74c2` en `MANI-Node` tras `git fetch --all` en los siete repositorios, se retira la reserva de la versión 1.0 y se pega el fragmento de `PgPaymentRepository.js` que libera y liquida el pago tardío. Se reconfirman D3, D13 y D15 contra Jira y `origin/main`; el recuento de filas no cambia (8 de 15). | Sara Albarracín |
| 1.0 | 2026-11-10 | Documento inicial. 8 filas verificadas (D2, D3, D4, D11, D12, D13, D14 lado QA, D15), 7 pendientes con su comando y responsable, 5 preguntas de decisión abiertas. | Sara Albarracín |

# PoC-001: Exclusion concurrente en la aceptacion de solicitudes

- **Ticket Jira:** SCRUM-926 (CFG-09)
- **Fecha:** 2026-09-21
- **Sprint:** 2
- **Responsable:** Santiago Hernandez — QA Tester
- **ADR relacionado:** ADR-0021 (Mecanismo de exclusion concurrente en el despacho de solicitudes, SP-04.1.2) — estado Propuesto
- **Origen:** Sprint 2 Planning, hoja "2. DevOps y QA"

## 1. Pregunta que responde la PoC

¿El `UPDATE` condicional sobre `solicitud` garantiza exactamente 1 asignacion exitosa
cuando N aliados aceptan la misma solicitud de forma simultanea?

## 2. Metrica y criterio de exito

| Metrica | Umbral de exito | Como se mide |
| --- | --- | --- |
| Asignaciones exitosas por solicitud | = 1 | Filas en `poc_asignacion_log` para esa solicitud y corrida |
| Dobles asignaciones | = 0 | `count(*) - 1` sobre la misma consulta |
| Respuestas `200 OK` | = 1 | Contador `exito_200` del harness k6 |
| Respuestas `409 ya_no_disponible` | = N - 1 | Contador `conflicto_409` del harness k6 |
| Respuestas distintas de 200/409 | = 0 | Contador `otros` del harness k6 |
| Reintento del ganador | `200 OK` sin cambiar `aliado_id`, sin fila nueva en la bitacora | Corrida de idempotencia (RNF-03, DD-MANI.md §7.1) |
| **Concurrencia real (validacion del instrumento)** | Control negativo > 1 asignacion | Misma carga contra una RPC sin exclusion |

La ultima fila no mide el sistema: mide la prueba. Si el control negativo tambien produce
1 sola asignacion, las peticiones no se solaparon y el verde de las demas metricas no
significa nada.

### Por que las dobles asignaciones NO se cuentan sobre `solicitud`

Hay una sola fila de solicitud. Si dos aliados ganan, el segundo sobrescribe al primero y
la fila final queda con un `estado` y un `aliado_id` — exactamente igual que si el
mecanismo hubiera funcionado. El estado final no distingue el exito del fallo.

Por eso la RPC escribe en `poc_asignacion_log`, una bitacora append-only con `UPDATE` y
`DELETE` revocados para los roles de la API: dos filas para la misma solicitud y corrida
son una doble asignacion probada del lado de la base, sin depender de lo que reporte el
cliente que se esta midiendo.

## 3. Alcance

**Incluye:**

- El `UPDATE` condicional de ADR-0021 desplegado como RPC en el proyecto QA, con
  `SECURITY INVOKER` para que RLS aplique igual que en produccion.
- Un harness de N aceptaciones simultaneas sobre la misma solicitud, cada una autenticada
  con el JWT real de su aliado.
- Los cuatro escenarios de `DD-MANI.md` §7.1: primer aceptante, conflicto, reintento
  idempotente y solicitud inexistente.
- Un control negativo que demuestra que la carga genera concurrencia real.
- La medicion del control negativo mal disenado, como evidencia metodologica.

**No incluye (fuera de alcance de esta PoC):**

- El aislamiento multi-tenant en si (CFG-12, ADR-0015). Aqui RLS esta activa porque afecta
  al mecanismo, pero no se mide.
- La cola de reintento ante caida de base de datos: deuda tecnica declarada en ADR-0021 y
  trazada en KI-06.
- El broadcast del despacho (RF-12, RF-13). Esta PoC empieza con la solicitud ya ofrecida.
- Latencia P95 como criterio de aceptacion. Se registra, no se evalua contra umbral.
- La autorizacion por rol en la aceptacion. Ver hallazgo H-02.

## 4. Metodologia

1. **Verificacion de terreno** (SCRUM-959). Se interroga el catalogo de QA en vez de partir
   de `Product/DDL_MANI.sql`, que esta desactualizado. Resultado en
   `Entregas/PoC/SCRUM-959-verificacion-terreno.md`.
2. **Seed de concurrencia.** Tercer tenant desechable `poc-concurrencia` con 50 aliados
   aprobados —misma zona y categoria que el sitio, para que el despacho de ADR-0016 los
   considere validos— y 1 solicitud en `pending` con UUID fijo. Aparte de los 2 tenants de
   CFG-04, cuyas pruebas de aislamiento asumen 1 aliado por tenant.
3. **Despliegue de la RPC** y de la bitacora append-only. Probado contra los 4 escenarios
   de §7.1 bajo sesion `authenticated` simulada, dentro de una transaccion con `ROLLBACK`.
4. **Cacheo de tokens.** Los logins se sacan fuera de la ventana medida (ver H-03).
5. **Corridas**, en este orden deliberado:
   1. Control negativo correcto — establece que hay concurrencia real.
   2. Control negativo mal disenado — evidencia del falso verde.
   3. Mecanismo de ADR-0021 — la medicion que responde la pregunta.
6. **Lectura de la bitacora** como fuente de verdad. k6 reporta lo que el cliente recibio;
   la bitacora, lo que la base hizo.

El orden importa: si el caso principal corriera primero y saliera verde, no se podria
distinguir exclusion de ausencia de carrera.

**Herramientas usadas:** k6 v2.3.0 (darwin/arm64) · Supabase/PostgreSQL 17.6, proyecto QA
`hpsxdotaizzclkeufzct` · `READ COMMITTED` · `max_connections = 60`

## 5. Resultado

Corrida de referencia: **r4-exclusion**, N=50, 2026-09-21.

| Metrica | Umbral | Resultado obtenido | ¿Cumple? |
| --- | --- | --- | --- |
| Asignaciones exitosas por solicitud | = 1 | 1 | Si |
| Dobles asignaciones | = 0 | 0 | Si |
| Respuestas `200 OK` | = 1 | 1 | Si |
| Respuestas `409` | = N - 1 = 49 | 49 | Si |
| Respuestas distintas de 200/409 | = 0 | 0 | Si |
| Reintento del ganador | 200, sin fila nueva | 200 con su mismo `aliado_id`, 0 filas nuevas | Si |
| Control negativo (validacion del instrumento) | > 1 asignacion | **10 asignaciones, 10 txid distintos** | Si |
| Control negativo mal disenado | 1 asignacion (demuestra el falso verde) | 1 asignacion bajo la misma carga | Si |

**Ventana de solapamiento observada:** 136 ms entre la primera y la ultima de las 10
asignaciones del control negativo.

### Las cinco corridas

| corrida | RPC | ventana | asignaciones | txid distintos | 200 | 409 | otros |
| --- | --- | --- | --- | --- | --- | --- | --- |
| r1-sin-exclusion | sin exclusion | 50 ms | 1 | 1 | 1 | 49 | 0 |
| r2-sin-exclusion-3s | sin exclusion | 3 s | **10** | **10** | 10 | 40 | 0 |
| r3-control-malo | control mal disenado | 3 s | 1 | 1 | 1 | 49 | 0 |
| **r4-exclusion** | **ADR-0021** | **3 s** | **1** | 1 | **1** | **49** | **0** |
| r5-idempotencia | ADR-0021 | — | 0 nuevas | — | 1 | 1 | 0 |

**r2 es lo que hace que r4 signifique algo.** Corrieron con la misma alineacion y el mismo
N; la unica diferencia es el mecanismo. Diez transacciones distintas asignaron la misma
solicitud en 136 ms, lo que descarta que el 1 de r4 venga de falta de carrera.

**r1 documenta el falso verde.** Mismo codigo sin exclusion que r2, con ventana de 50 ms en
vez de 3 s: da 1 asignacion. Las peticiones llegan repartidas en ~900 ms, mas de quince
veces la ventana, y nunca se solapan. El harness reporto "1 exito" sin que existiera
carrera. Es el riesgo C2 materializado y atrapado por el propio control.

**r3 confirma H-01** con datos: el control negativo que proponia la primera version del
informe da 1 asignacion bajo exactamente la carga donde r2 dio 10.

**r5** cubre los tres caminos de `DD-MANI.md` §7.1 contra HTTP real: `200` idempotente para
el ganador, `409 ya_no_disponible` para otro aliado, `404 no_encontrada` para una solicitud
invisible. Cero filas nuevas en la bitacora, asi que un reintento legitimo no infla el
conteo de dobles asignaciones (RNF-03).

### Lectura de los tiempos

De 50 peticiones enviadas solo 10 llegan a solaparse, cifra que coincide con el tamano
tipico del pool de PostgREST. **La concurrencia efectiva la acota el pool, no N**: enviar
N=200 produciria mas cola, no mas carrera.

`http_req_duration` pasa de avg 3.09 s en r2 a avg 9.04 s con max 15.27 s en r4. Ese salto
es la cola sobre el bloqueo de fila: la firma del mecanismo funcionando. No es una medida
de latencia de produccion —los 3 s de alineacion son artificiales— y por eso la latencia
quedo fuera del criterio de aceptacion (seccion 3).

**Evidencia:** `qa/k6/evidencia/bitacora.json` (13 filas crudas leidas via PostgREST con
JWT de aliado) y `qa/k6/evidencia/resumen-corridas.md`, en `Trama-AS/MANI-Flutter`, PR #6.
Codigo en `supabase/poc-cfg09/` y `qa/k6/`. Verificacion en base:
`supabase/poc-cfg09/30_verificar_corrida.sql`.

## 6. Conclusion y siguiente paso

**Si.** El `UPDATE` condicional sobre `solicitud` garantiza exactamente 1 asignacion bajo
50 aceptaciones simultaneas, con 0 dobles asignaciones, validado contra un control negativo
que bajo identica carga produce 10.

- **Implicacion sobre ADR-0021:** confirma la decision tal como esta redactada. El
  mecanismo cumple RNF-05 (resolucion determinista de aceptaciones concurrentes) y RNF-03
  (reintento sin duplicados). El ADR puede pasar de **Propuesto** a **Aceptado** en la Mesa
  de Arquitectura. No hay que revisar las alternativas descartadas: ni el bloqueo pesimista
  ni la cola de reintento aportarian al problema medido aqui.

- **Deuda tecnica o riesgo declarado:**
  1. **Concurrencia acotada por el pool.** La PoC demuestra exclusion correcta hasta la
     concurrencia que el pool permite (10 observadas). Por encima de eso las peticiones
     hacen cola; el mecanismo sigue siendo correcto, pero el comportamiento bajo saturacion
     sostenida no se midio.
  2. **La maquina de estados no esta respaldada por la base** (deriva D2): `solicitud.estado`
     no tiene `CHECK` ni `DEFAULT` en QA. La exclusion depende de que el codigo escriba el
     vocabulario correcto. Requiere ticket para alinear el esquema con RF-14.
  3. **La autorizacion por rol no esta impuesta** (hallazgo H-02). Fuera del alcance de esta
     PoC, requiere ticket propio.
  4. **La cola de reintento ante caida de base** sigue siendo deuda declarada de ADR-0021,
     trazada en KI-06. Esta PoC no la aborda ni la contradice.
  5. **`Product/DDL_MANI.sql` desactualizado** frente al esquema real de QA (anexo B).

**Siguiente paso:** llevar ADR-0021 a la Mesa para pasarlo a Aceptado, con este informe como
evidencia; y abrir los tickets de los puntos 2 y 3.

## 7. Estado

**Completada — cumple** — ultima actualizacion: 2026-09-21

## 8. Trazabilidad

- Ticket Jira: SCRUM-926 (CFG-09)
- Subtareas relacionadas: SCRUM-959, SCRUM-960, SCRUM-961, SCRUM-962, SCRUM-963, SCRUM-964
- ADR relacionado: ADR-0021 · activado por ADR-0016 · motor y RLS por ADR-0012
- Requisitos: RF-14, RNF-03, RNF-05 · `DD-MANI.md` §5.4, §6.1, §7.1
- Dependencia: CFG-04 (SCRUM-921), satisfecha — ver `SCRUM-959-verificacion-terreno.md`
- Codigo: `supabase/poc-cfg09/` y `qa/k6/` en `Trama-AS/MANI-Flutter`, PR #6
- Informe consolidado del sprint: DOC-16 (SCRUM-952)

---

## Anexo A — Hallazgos metodologicos

Hallazgos sobre **como se prueba**, no sobre el sistema. Se declaran porque condicionan la
validez del resultado.

### H-01 — Un control negativo que no puede fallar no valida nada

El primer diseño proponia quitarle al `UPDATE` solo el predicado `estado = 'pending'`. No
sirve: el `WHERE` lleva dos guardas y la otra, `aliado_id IS NULL`, sigue excluyendo sola.
En `READ COMMITTED` la segunda transaccion espera a la primera y re-evalua el `WHERE`
contra la version ya comprometida (EvalPlanQual); ve `aliado_id` no nulo y afecta 0 filas.
Habria dado 1 exito con o sin concurrencia real.

Detectado en la revision del PR #4 de MANI-docs. Corregido en `d01b8d7`. El diseño valido
separa comprobacion y escritura, reproduciendo la ventana check-then-act.

Se conservo la variante equivocada desplegada y se midio a proposito (corrida r3): da
**1 asignacion** bajo exactamente la carga donde el control correcto dio **10**. El
contraste es la evidencia de que el instrumento tambien hay que validarlo.

### H-02 — La politica RLS no restringe quien acepta

`tenant_isolation_solicitud` tiene `roles = {public}` y aisla solo por tenant. Cualquier
usuario autenticado del tenant —incluido uno con rol `cliente`— puede hacer `UPDATE` sobre
cualquier `solicitud` y autoasignarsela. `DD-MANI.md` §5.4 restringe
`POST /solicitudes/:id/aceptar` al rol `aliado`; hoy la base no lo impone.

No bloquea esta PoC, que mide exclusion concurrente y no autorizacion. Requiere ticket
propio.

### H-03 — Supabase Auth limita el login y obliga a sacarlo de la ventana medida

El endpoint de token responde `429 over_request_rate_limit` alrededor de la peticion 30 en
5 minutos por IP. Autenticar N=50 aliados de corrido aborta la corrida.

Hay dos razones para separar los logins, y solo una es el limite. La otra es de metodo:
cada login cuesta un verify de bcrypt, y hacerlo dentro del escenario escalonaria las
peticiones por el costo del login en vez de por el comportamiento de la base.

Cualquier prueba de carga futura contra Supabase autenticada tiene que provisionar
credenciales antes de medir. Aplica a CFG-12 y a la suite de ADR-0015.

### H-04 — El pool de PostgREST acota el N util, no `max_connections`

`max_connections = 60` en el motor, pero el pool de PostgREST queda por debajo: de 50
peticiones enviadas, **solo 10 llegaron a solaparse** (r2). N muy alto no produce mas
concurrencia, produce mas cola. Es el motivo por el que el control negativo es obligatorio
y no opcional.

### H-05 — La ventana de la prueba debe superar la dispersion de llegada

La primera corrida del control negativo uso una ventana de 50 ms y dio 1 asignacion: un
falso verde. Las peticiones llegan repartidas en ~900 ms —mas de quince veces la ventana—
asi que ninguna se solapo. Con la ventana en 3 s, el mismo codigo dio 10.

Corolario para pruebas de concurrencia futuras: la ventana artificial tiene que medirse
contra la dispersion real de llegada observada, no elegirse a ojo. Y las variantes que se
comparan deben correr con la misma alineacion, o la comparacion no dice nada sobre el
mecanismo.

### H-06 — `aliado_previo` no detecta sobrescrituras

La bitacora incluye una columna `aliado_previo` pensada para registrar el valor pisado.
Salio nula en las 10 filas de r2, porque registra lo que la transaccion **leyo**, no lo que
**sobrescribio**: las 10 leyeron `NULL` antes de que ninguna escribiera. La evidencia de
doble asignacion son las filas en si —una por transaccion ganadora—, no esa columna. Se
deja documentado para que nadie la interprete como ausencia de sobrescritura.

## Anexo B — Derivas de esquema detectadas

Detalle completo en `SCRUM-959-verificacion-terreno.md`. Resumen de lo que afecta a esta
PoC:

| # | Deriva | Efecto |
| --- | --- | --- |
| D1 | `solicitud.estado` sin `DEFAULT` en QA | El seed escribe `'pending'` explicito |
| D2 | `solicitud.estado` sin `CHECK` en QA | La maquina de estados de RF-14 no esta respaldada por la base |
| D5 | `anon` con `UPDATE`, `DELETE` y `TRUNCATE` sobre `solicitud` | Grant por defecto de Supabase; el aislamiento depende de una sola capa. Ver ADR-0005 |

`Product/DDL_MANI.sql` debe actualizarse contra el esquema real de QA. Confirmado de forma
independiente: el `database/init/01-schema.sql` que DevOps subio a `develop` coincide con
QA y no con el DDL documentado.

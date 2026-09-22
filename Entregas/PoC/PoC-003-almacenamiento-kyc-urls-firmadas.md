# PoC-003: Almacenamiento de documentos KYC y URLs firmadas en Supabase Storage

- **Ticket Jira:** SCRUM-930 (CFG-13)
- **Fecha:** 2026-09-22
- **Sprint:** 2
- **Responsable:** Santiago Hernandez — QA Tester
- **ADR relacionado:** ADR-0013 (Almacenamiento de documentos KYC de aliados) — estado
  Propuesto. Toca ademas ADR-0015 (su caso 6) y ADR-0018 (de cuyos claims depende la
  politica).
- **Origen:** Sprint 2 Planning, hoja "2. DevOps y QA"

## 1. Pregunta que responde la PoC

¿El bucket unico con rutas `tenant_id/<usuario>/archivo` y una politica RLS sobre
`storage.objects` —la decision de ADR-0013— impide que un usuario de otro tenant acceda a
los documentos KYC de un aliado, y en cuanto tiempo se carga un documento?

## 2. Metrica y criterio de exito

Fijadas antes de ejecutar la medicion y publicadas en SCRUM-930 (comentario del
2026-09-22), como exige la excepcion para PoC del DoR (spike SCRUM-945).

| Metrica | Umbral de exito | Como se mide |
| --- | --- | --- |
| Carga de un PDF de 1 MB | p95 **< 2 s** | 30 corridas, `qa/storage/bench_carga.mjs` |
| Carga de 100 KB y 5 MB | Se reporta, **no decide** | Idem, 30 corridas c/u |
| Emision de URL firmada (`createSignedUrl`) | p95 **< 500 ms** | Idem, sobre cada objeto subido |
| Acceso denegado entre tenants (QS-02) | **100%** de los casos | Caso 6 de la suite de ADR-0015 |
| Casos positivos | **100%** en verde | El dueño y su `admin_tenant` si acceden |
| **Control negativo (validacion del instrumento)** | **Con una politica sin aislamiento, los negativos deben ponerse rojos** | Misma suite, misma base, politica reemplazada |

### Por que un verde podia no significar nada, dos veces

1. **Storage con RLS y sin politicas lo niega todo.** Es la trampa que SCRUM-1039 encontro
   en las tablas de `public`: los negativos pasan porque nadie accede a nada. Por eso cada
   negativo tiene su positivo, y por eso **quitar la politica no sirve de control
   negativo** — seguiria verde. El control correcto es una politica que deja pasar a
   cualquier autenticado (seccion 5.2).
2. **Sin bucket, todo negativo pasa.** Se comprobo antes de aprovisionarlo (seccion 5.3).

## 3. Alcance

**Incluye:**

- El **aprovisionamiento** en QA de lo que ADR-0013 decide y no existia: bucket privado
  `kyc-documentos` y la politica `kyc_isolation` del DDL. Resuelve SCRUM-1053 para QA.
- La carga de documentos con el JWT del propio aliado —nunca `service_role`, que salta
  RLS— y la emision y uso de URLs firmadas con expiracion.
- La medicion del tiempo de carga en tres tamaños.
- El caso 6 de ADR-0015, que hasta hoy era no ejecutable: cruce entre tenants, cruce
  dentro del mismo tenant (bug previsible B-02.1.1), acceso sin sesion, manipulacion y
  expiracion de la URL firmada.
- La suite completa de ADR-0015 y la de claims de CFG-12 como regresion.

**No incluye:**

- El endpoint `POST /aliados/:id/documentos` del SAD, que no existe. La carga va directa
  del cliente a la API de Storage, que es lo que `supabase_flutter` hace por debajo.
- La pantalla de carga en Flutter. No hay cambio de interfaz: no aplica Maestro.
- DEV y PROD. SCRUM-1053 pide evaluar si tienen el mismo hueco; queda abierto.
- La configurabilidad por tenant de los documentos exigidos (RNF-10).
- La tabla `documento_kyc` como registro de la carga: la PoC no la escribe al subir, solo
  alinea las dos filas sembradas por CFG-12.

## 4. Metodologia

1. **Verificacion de terreno** (`supabase/poc-cfg13/00_verificar_terreno.sql`): 0 buckets,
   0 politicas sobre `storage.objects`, 0 objetos. Hook de CFG-12 montado. Las rutas
   sembradas por CFG-12 no cumplian ADR-0013 (hallazgo H-03).
2. **Suite contra QA sin bucket**, para fijar la linea base del instrumento (seccion 5.3).
3. **Aprovisionamiento** (`10_bucket_kyc.sql`): bucket privado, 10 MB, solo PDF/JPEG/PNG;
   `kyc_isolation` copiada del DDL con un unico cambio, `TO authenticated`.
4. **Alineacion de rutas** (`20_seed_storage.sql`) y **carga de fixtures**
   (`qa/storage/cargar_kyc.mjs`): cada aliado sube su cedula con su JWT.
5. **Publicacion del umbral** en SCRUM-930.
6. **Benchmark de carga** (`qa/storage/bench_carga.mjs`).
7. **Suite completa** de ADR-0015 y de claims.
8. **Control negativo**, al final: politica permisiva, suite, restauracion, suite otra vez.

Los PDFs son sinteticos (cabecera PDF valida + relleno). No hay datos reales de nadie en
el bucket.

**Herramientas:** Newman 6.2.2 · Node v25.9.0 (`fetch` nativo, sin dependencias) ·
Supabase Storage, proyecto QA `hpsxdotaizzclkeufzct` · darwin/arm64.

## 5. Resultado

**Cumple las dos metricas.**

### 5.1 Tiempo de carga

30 corridas por tamaño, 3 de calentamiento descartadas, desde la maquina del QA contra QA.

| Tamaño | Carga p50 | Carga p95 | Carga max | Firma p95 | Descarga firmada p50 / p95 |
| --- | --- | --- | --- | --- | --- |
| 100 KB | 336 ms | 752 ms | 887 ms | 205 ms | 1118 / 1282 ms |
| **1 MB** | 688 ms | **1180 ms** | 1280 ms | **423 ms** | 1593 / 1978 ms |
| 5 MB | 784 ms | 1427 ms | 1445 ms | 227 ms | 1898 / 2437 ms |

- **Carga de 1 MB: p95 1180 ms < 2000 ms. Cumple**, con margen amplio.
- **Firma: peor p95 423 ms < 500 ms. Cumple, con margen estrecho.** Una corrida de la
  serie de 1 MB llego a 537 ms. Con 30 muestras el p95 es la corrida 29: dos picos mas lo
  habrian pasado del umbral. La firma no depende del tamaño del objeto (p50 ~150 ms en las
  tres series), asi que la variacion es de red o del servicio, no del archivo.
- **La descarga es mas lenta que la subida**, sobre todo en proporcion en archivos chicos
  (100 KB: 1,1 s bajando, 336 ms subiendo). Cada descarga es la primera de un objeto
  recien creado; la hipotesis es cache fria del CDN, **no verificada**. Fuera del criterio.

**Limitacion que condiciona la lectura:** es una cota inferior. Se midio desde un equipo
de escritorio con buena conexion, no desde un celular en red movil, que es donde el aliado
carga su cedula. Ni el SRS ni el SAD fijan en que condicion de red debe cumplirse un
tiempo de carga; el umbral de 2 s lo definio esta PoC (ver recomendaciones).

### 5.2 Acceso denegado — y el control negativo

Evidencia: `qa/newman/evidencia/aislamiento-cfg13-*.redactado.json` en MANI-Flutter.

| Corrida | Peticiones | Aserciones | Fallos |
| --- | --- | --- | --- |
| Suite ADR-0015 completa, `kyc_isolation` activa | 52 | 95 | **0** |
| `mani-claims` (regresion CFG-12) | 13 | 40 | **0** |
| **Control negativo: politica solo por bucket** | 52 | 95 | **20** |
| Politica restaurada | 52 | 95 | **0** |

Detalle del caso 6. "Respuesta" es lo que devuelve Storage con la politica activa:

| # | Actor → objeto de aliado.t1 | Respuesta | Con politica permisiva |
| --- | --- | --- | --- |
| P1–P3 | aliado.t1 y admin.t1 descargan, firman, listan | 200 | 200 |
| N1 | aliado.t2 / admin.t2 **firman** la URL | 400 `Object not found` | **200 — rojo** |
| N2 | aliado.t2 / admin.t2 descargan | 400 `Object not found` | **200 — rojo** |
| N3 | aliado.t2 / admin.t2 listan el tenant 1 | lista vacia | **ven el objeto — rojo** |
| N4–N5 | aliado.t2 sube al tenant 1 (con uid ajeno y con el suyo) | 400 `violates row-level security` | **200 — rojo** |
| N6–N6c | hook.t1, **otro aliado del mismo tenant**, descarga, firma, sube | denegado | **200 — rojo** |
| N6d | hook.t1 sube a SU carpeta | 200 | 200 |
| N7 | cliente.t1 descarga | 400 `Object not found` | **200 — rojo** |
| N8–N8b | anonimo, y la ruta publica del bucket | 400 | 400 |
| N9–N9b | token firmado reusado en otra ruta / firma alterada | 400 `InvalidSignature` / `InvalidJWT` | 400 |
| N10 | URL firmada tras su TTL | 400 `"exp" claim timestamp check failed` | 400 |
| N11 | aliado.t1 sube a `<tenant>/<aliado.id>/` | 400 `violates row-level security` | **200 — rojo** |
| **C1** | **URL firmada de t1 usada sin sesion** | **200 — control positivo esperado** | 200 |

**Lectura:**

- **Cero accesos entre tenants** en todos los vectores: emision de URL, descarga
  autenticada, listado y subida. **QS-02 se cumple.**
- **El control negativo demuestra que el verde viene de `kyc_isolation`**: todo lo que
  depende de su predicado cae en rojo, y los positivos siguen verdes.
- **N8, N9 y N10 siguen verdes en el control, y es correcto**: no los protege el
  predicado de tenant, sino `TO authenticated`, el bucket privado y la firma del token.
  El control deja ver que protege cada capa.
- **La lectura denegada responde "Object not found", no "forbidden".** Storage no revela
  si el objeto existe: un atacante no puede enumerar documentos ajenos probando rutas.
- **B-02.1.1 esta cubierto a nivel de Storage**: un aliado no ve los documentos de otro
  aliado de su tenant (N6), y un cliente tampoco (N7). Esto difiere de las tablas de
  `public`: PoC-002 (H-02) encontro que alli un cliente si puede leer la **fila**
  `documento_kyc` de un aliado de su tenant, porque esas politicas no distinguen usuario.
  El archivo esta protegido; su metadato, no.

### 5.3 Linea base: la suite sin bucket

Antes de aprovisionar, la carpeta del caso 6 dio **todos los positivos en rojo y todos los
negativos en verde** (73 aserciones, 18 fallidas; los negativos respondian `Bucket not
found`). Es la trampa de la seccion 2 reproducida: sin los positivos, esa corrida se habria
leido como aislamiento perfecto. Evidencia: `caso6-antes-del-bucket.redactado.json`.

## 6. Conclusion y siguiente paso

**Si.** Con el bucket y la politica que ADR-0013 decide, ningun usuario de otro tenant
accede a los documentos KYC de un aliado por ninguna de las vias de la API de Storage, y
un documento de 1 MB se carga con p95 de 1,2 s desde un cliente de escritorio. El control
negativo confirma que el resultado lo produce la politica y no el entorno.

Tres matices que el ADR tiene que recoger antes de pasar a Aceptado:

- **H-01 — Una URL firmada es un token al portador, por diseño de Supabase.** La descarga
  por `/object/sign/...?token=` no lleva JWT de usuario ni pasa por RLS. `kyc_isolation`
  decide quien puede **emitir** la URL (N1, N6b la niegan); una vez emitida, quien la tenga
  la usa hasta que expire (C1). No es un defecto de la politica ni del hook de CFG-12, y no
  se puede "arreglar" con RLS. Lo que si se puede es acotar el daño de una URL filtrada.
  **Mitigaciones propuestas** —la decision es del Backend Lead como dueño del backend que
  emitira las URLs—:
  1. TTL corto (segundos a pocos minutos), no horas.
  2. Emitir la URL bajo demanda, en el momento de mostrar el documento, y **no persistirla**
     en `documento_kyc` ni en ningun log.
  3. `ruta_storage` guarda la ruta, nunca la URL firmada (asi quedo en QA).

- **H-02 — El texto del ADR no coincide con la politica.** ADR-0013 dice
  `tenant_id/aliado_id/documento.pdf`; la politica compara el segundo segmento con
  `auth.uid()`, que es `usuario.id`. En el modelo son valores distintos (`aliado.id`
  `50000000-…` frente a `usuario_id` `30000000-…` en QA). N11 lo demuestra: si el backend
  construye la ruta con `aliado.id`, como dice el ADR, **el propio aliado no puede subir ni
  leer sus documentos**. Es exactamente el riesgo KI-05 del SAD ("el aislamiento depende de
  la disciplina del backend al construir la ruta"), ahora con un caso concreto. La PoC
  adopto `auth.uid()`. **El ADR debe corregir el texto de la ruta.**

- **H-04 — `admin_tenant` puede escribir y borrar, no solo leer.** La politica no tiene
  clausula `FOR`, asi que es `FOR ALL`: el admin de un tenant puede subir, reemplazar o
  borrar cualquier documento de sus aliados. ADR-0013 solo le da lectura ("solo debe poder
  ver"). Si la intencion es de solo lectura, hay que partir la politica en una de `SELECT`
  para el admin y otra de escritura solo para el dueño.

**Implicaciones:**

- **ADR-0013:** la decision se sostiene. Requiere corregir H-02 y decidir H-04 y las
  mitigaciones de H-01 antes de pasar a Aceptado.
- **ADR-0015:** el caso 6 ya es ejecutable; la suite queda con sus seis casos reales.
  Sigue sin estar en CI (ver deuda).
- **SAD:** mapea ADR-0013 a QS-04, que habla de la bandeja de verificacion del admin, no de
  aislamiento. El escenario que esta PoC valida es QS-02. Revisar el mapeo.

**Deuda tecnica y riesgos declarados:**

1. **La suite de ADR-0015 no corre en CI.** QS-17 exige que GitHub Actions la ejecute y
   bloquee el merge. Hoy `ci.yml` no llama a Newman, asi que el gate del DoD punto 2 y de
   QS-17 se cumple a mano. Para el caso 6, el pipeline ademas debe correr
   `qa/storage/cargar_kyc.mjs` antes de la suite.
2. **La politica de Storage vive en QA y en `supabase/poc-cfg13/`, no en
   `database/migrations/`.** Es la misma deuda que SCRUM-1051 para las tablas de `public`.
3. **DEV y PROD sin evaluar** (SCRUM-1053 punto 4).
4. **La metrica de carga no tiene requisito de red** (seccion 5.1).

**Siguiente paso:** llevar H-01, H-02 y H-04 a la revision de ADR-0013; cerrar SCRUM-1053
para QA; incluir el caso 6 en el trabajo pendiente de enganchar Newman al pipeline.

## 7. Estado

**Completada — cumple** — ultima actualizacion: 2026-09-22

## 8. Trazabilidad

- Ticket Jira: SCRUM-930 (CFG-13)
- Subtareas: SCRUM-977 (bucket y politica), SCRUM-978 (carga y URL firmada), SCRUM-979
  (tiempo de carga), SCRUM-980 (acceso cruzado), SCRUM-981 (este informe)
- ADR relacionados: ADR-0013 (validado con observaciones H-01, H-02, H-04) · ADR-0015 (caso
  6 implementado) · ADR-0018 (sus claims alimentan la politica)
- Requisitos: RNF-01 · Escenarios de calidad: QS-02, QS-17 · Riesgo: KI-05 · Bug previsible:
  B-02.1.1
- Resuelve en QA: SCRUM-1053 · Relacionado: SCRUM-1051, SCRUM-1052
- Antecedentes: PoC-002 (CFG-12), de la que viene el hook, el seed de identidad y la suite;
  PoC-001 (CFG-09), de donde viene el metodo del control negativo
- Codigo y evidencia: `Trama-AS/MANI-Flutter`, rama `feature/SCRUM-930-poc-storage-kyc`:
  `supabase/poc-cfg13/`, `qa/storage/`, `qa/newman/`
- Norma aplicada: DoR y DoD del spike SCRUM-945 (revision 2026-09-17)

---

## Anexo A — Hallazgos metodologicos

### M-01 — La suite tenia un bug que la corrida detecto en rojo

La primera corrida completa dio `ERR` en los cuatro casos que usan la URL firmada como URL
completa (N9, N9b, N10, C1): la suite leia `base_url` con `pm.collectionVariables`, pero
llega por `--env-var` y devolvia `undefined`. Se corrigio a `pm.variables`. Se declara
porque el fallo fue **visible**: si esos casos hubieran estado escritos para pasar ante
cualquier error, habrian dado verde sin probar nada.

### M-02 — Desviacion del DoR: umbral publicado antes de medir, pero despues de preparar

La excepcion PoC del DoR pide la metrica "definida antes de iniciar". El umbral se fijo en
el plan aprobado al inicio y se publico en SCRUM-930 **antes de cualquier medicion**, pero
despues de aprovisionar el bucket y de correr la suite una vez sin bucket (linea base). El
comentario del ticket lo declara. Ningun umbral se ajusto despues de ver un resultado.

### M-03 — El control negativo "obvio" no servia

La primera version del script de rollback quitaba la politica. Se descarto antes de
correrlo: sin politicas Storage lo niega todo, y los negativos habrian seguido verdes. Se
reemplazo por una politica que solo mira el bucket.

### M-04 — La evidencia contiene URLs firmadas

Una URL firmada es una credencial. Su token es un JWT, asi que
`qa/newman/redactar_evidencia.mjs` lo redacta con la misma regla que los `access_token`.
Verificado: 0 JWT restantes en las cuatro evidencias, y la anon key tampoco sobrevive.

---

## Anexo B — Hallazgos sobre el sistema

| # | Hallazgo | Impacto | Quien decide |
| --- | --- | --- | --- |
| H-01 | Una URL firmada filtrada descarga sin sesion hasta su TTL | Por diseño de la plataforma; mitigable con TTL corto y no persistencia | Backend Lead |
| H-02 | ADR-0013 dice `aliado_id`, la politica usa `auth.uid()` | Si se sigue el texto del ADR, el dueño queda bloqueado | Autor de ADR-0013 |
| H-03 | CFG-12 sembro `ruta_storage = 'kyc/<tenant>/...'` | Ruta ilegible para cualquiera, incluido el dueño. Corregido en QA con `20_seed_storage.sql` | — (resuelto) |
| H-04 | `kyc_isolation` es `FOR ALL`: `admin_tenant` escribe y borra | El ADR solo le da lectura | Autor de ADR-0013 / Mesa |
| H-05 | La fila `documento_kyc` si es legible dentro del tenant por cualquier rol (PoC-002 H-02) | El archivo esta protegido, su metadato no | SCRUM-1052 |

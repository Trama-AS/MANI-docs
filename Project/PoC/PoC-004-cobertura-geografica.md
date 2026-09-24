# PoC-004: Cobertura geografica — consulta de despacho por zona vs. PostGIS, bounding box y geohash

- **Ticket Jira:** SCRUM-927 (CFG-10) · subtareas SCRUM-965 a SCRUM-970
- **Fecha:** 2026-09-22
- **Sprint:** 2
- **Responsable:** Santiago Hernandez — QA Tester
- **ADR relacionado:** ADR-0011 (Modelo de cobertura geografica del aliado) — Aceptado. La
  PoC ejerce su condicion de revision §6.4 y mide la evolucion aditiva que preve su §6.
- **Decision que alimenta:** SP-02.1.1 (SCRUM-506, Finalizada) ya se resolvio en ADR-0011.
  Esta PoC no abre un ADR nuevo: confirma o corrige ADR-0011 con datos.
- **Origen:** Sprint 2 Planning, hoja "2. DevOps y QA"
- **Codigo y evidencia:** MANI-Flutter, rama `feature/SCRUM-927-poc-cobertura-geografica`,
  `supabase/poc-cfg10/` y `qa/k6/latencia_cobertura.js`

## 1. Pregunta que responde la PoC

El ticket pide comparar PostGIS, bounding box y geohash para "aliados validos por
cobertura y categoria" y elegir la de mejor p95. Cuando se planifico la PoC, esa decision
ya estaba tomada: ADR-0011 (ratificado el 2026-08-31, origen SP-02.1.1) fija que la
cobertura se declara por zonas de un catalogo y que el match es **igualdad de `zona_id`,
sin calculo geoespacial** (REST-01 prohibe radio y geolocalizacion). Comparar tres
mecanismos geoespaciales como si la decision estuviera abierta habria contradicho un ADR
aceptado.

La PoC se reencuadro (comentario en SCRUM-927 del 2026-09-22, antes de medir) en dos
preguntas:

1. **¿La consulta de ADR-0011 cumple el umbral de latencia con volumen?** Es la condicion
   §6.4: el ADR se reabre si "la medicion en QA demuestra que la consulta de despacho
   incumple RNF-07".
2. **Si ADR-0011 §6 se activa, ¿que mecanismo conviene para resolver la zona de un sitio
   desde coordenadas?** §6 preve asociar geometria a `Zona` sin tocar la relacion aliado
   ↔ zona ni el match. PostGIS, bounding box y geohash se miden en ese papel, no como
   reemplazo del modelo.

## 2. Metrica y criterio de exito

Fijados antes de medir y publicados en SCRUM-927 (comentario del 2026-09-22).

| Metrica | Umbral | Como se mide |
| --- | --- | --- |
| **p95 en base de datos, variante zona (ADR-0011)** | **< 50 ms — decide** | `40_medir.sql`: 1000 consultas + 50 de calentamiento, como `authenticated` con RLS |
| p95 en base de datos, variantes geograficas | < 50 ms, se reporta | Idem |
| p95 extremo a extremo, 20 usuarios a la vez | < 1000 ms (QS-08) | `qa/k6/latencia_cobertura.js`, 20 VUs, via PostgREST |
| Precision de la zona resuelta | Se reporta, no decide | `50_precision.sql`, 3150 puntos contra PostGIS |

**Por que el umbral que decide es el de base de datos.** PoC-001 (CFG-09) documento que
el pool de PostgREST de QA domina los tiempos de extremo a extremo. Un numero por red
contra un ambiente compartido depende del pool y de la maquina que corre k6 mas que del
mecanismo. Se reporta contra QS-08, pero la comparacion entre variantes se hace dentro de
Postgres.

**Por que 50 ms.** QS-08 da 1 s de extremo a extremo con 20 usuarios buscando a la vez.
La consulta es una parte de ese presupuesto, junto con red, TLS, PostgREST, JWT y el
render en Flutter. 50 ms deja el 95 % del presupuesto al resto.

## 3. Alcance

**Incluye:**

- La consulta de despacho de ADR-0011 sobre copias de las tablas del DDL
  (`cobertura_aliado`, `aliado_categoria`, `aliado`, `zona`, `categoria_servicio`), con
  sus restricciones UNIQUE, sus indices por `tenant_id` y sus mismas politicas RLS.
- Dos juegos de indices: los del DDL tal cual y los propuestos
  `(tenant_id, zona_id) INCLUDE (aliado_id)` y `(tenant_id, categoria_id) INCLUDE (aliado_id)`.
- Tres mecanismos para resolver la zona desde un punto: PostGIS (`ST_Contains` + GiST),
  bounding box (btree + ray casting en SQL puro, sin PostGIS) y geohash de precision 6
  (tabla celda → zona, sin PostGIS en consulta).
- Tres niveles de volumen, dos tenants medidos y la precision de cada mecanismo.

**No incluye:**

- El orden del listado por la regla del tenant (RF-13) ni la paginacion. La consulta
  devuelve los aliados validos sin ordenar.
- El filtro por categoria activa ni por zona desactivada del lado del sitio.
- La geocodificacion de direcciones. Los puntos llegan como coordenadas.
- DEV y PROD.
- Otro tamaño de instancia. QA es plan gratuito: los numeros absolutos cambian con la
  instancia de produccion; la comparacion entre variantes y entre juegos de indices no.

## 4. Volumen sintetico

No hay volumen confirmado por el cliente (SAD KI-09; QS-08 lo marca "pendiente validar con
volumen real"). Por eso no se fijo un numero sino tres niveles:

| Nivel | Tenant grande | Tenants chicos | Aliados | Coberturas | Aliado-categoria | Aliados por localidad (grande) |
| --- | --- | --- | --- | --- | --- | --- |
| 1k | 1.000 | 2 × 100 | 1.200 | ~3.600 | ~2.400 | ~30 |
| 10k | 10.000 | 2 × 1.000 | 12.000 | 36.220 | 23.994 | ~303 |
| 100k | 100.000 | 2 × 10.000 | 120.000 | 360.067 | 240.427 | ~3.000 |

- **Tenants:** los tres de QA, para que los JWT reales pasen RLS. El grande es
  "PoC Concurrencia CFG-09" (5 ciudades). Los chicos son ACME (ciudad 1) y Nova (ciudades
  2 y 3): **comparten ciudad con el grande a proposito**, para ver si el volumen de un
  vecino le cuesta a un tenant chico.
- **Catalogo fijo:** 5 ciudades, 100 localidades (5 × 4 por ciudad, ~5,5 km de lado) y
  1000 barrios sin geometria (existen, pero ADR-0011 §2.2 no los usa para cobertura).
- **Localidades irregulares:** octogonos con vertices desplazados que cubren toda la
  ciudad sin huecos ni solapes. Con rectangulos el bounding box seria exacto y la
  comparacion quedaria sesgada a su favor.
- **Por aliado:** 1 a 5 localidades de una misma ciudad, 1 a 3 de las 15 categorias del
  tenant, 80 % aprobado.
- **Reproducible:** semillas fijas. Las 1050 entradas por tenant (punto + categoria) son
  las mismas en los tres niveles.

Cada nivel se verifico con `verificar_seed()` antes de medir: geometrias validas, sin
solapes, teselado exacto, geohash propio igual a `ST_GeoHash` y ray casting igual a
`ST_Contains` en todas las entradas (evidencia `seed-*.json`).

## 5. Metodologia

1. **Terreno** (`00_verificar_terreno.sql`): PostGIS 3.3.7 disponible y no instalado,
   Postgres 17.6, base de 12 MB. Hallazgo H-01 (seccion 8).
2. **Aprovisionamiento** (`10_esquema.sql`): PostGIS en el esquema `extensions` (aprobado
   por Santiago) y esquema aislado `poc_cfg10`. No se toco ninguna tabla de `public`.
3. **Funciones** (`20`, `30`, `40`, `50`, `60`): seed, las cuatro variantes, medicion,
   precision y RPC de entradas para k6.
4. **Publicacion del umbral** en SCRUM-927.
5. **Medicion en base** por nivel: sembrar, medir las 4 variantes × 2 juegos de indices ×
   2 tenants (grande y ACME), 1000 consultas cada una.
6. **Precision y planes de ejecucion** a 100k.
7. **Extremo a extremo** con k6 a 10k, solo indices del DDL (el peor caso que cumple).

Las cuatro variantes tienen la misma forma: una funcion PL/pgSQL que resuelve la zona (o
la recibe, en la variante zona) y luego ejecuta **exactamente la misma** consulta de match.
Asi la diferencia entre variantes aisla el costo de resolver la zona.

**Herramientas:** Supabase MANI-QA (Postgres 17.6, plan gratuito) · PostGIS 3.3.7 · k6
v2.3.0 · darwin/arm64.

## 6. Resultado

**Cumple, con una condicion: ADR-0011 cumple el umbral en los tres niveles solo con los
indices propuestos. Con los indices del DDL cumple hasta 10k y falla a 100k.**

### 6.1 Latencia en base de datos — tenant grande

p95 en ms, 1000 consultas por celda.

| Nivel | zona | postgis | bbox | geohash | zona | postgis | bbox | geohash |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| | **DDL** | DDL | DDL | DDL | **DDL + propuestos** | + prop. | + prop. | + prop. |
| 1k | **1,10** | 1,15 | 1,14 | 1,57 | **0,23** | 0,28 | 0,27 | 0,34 |
| 10k | **15,58** | 16,49 | 10,71 | 10,69 | **0,95** | 1,01 | 0,84 | 0,88 |
| 100k | **123,91** | 128,24 | 178,68 | 132,45 | **9,48** | 7,17 | 9,52 | 8,35 |

Filas devueltas por consulta (media): 3,2 · 31,8 · 321,3.

### 6.2 Latencia en base de datos — tenant chico (ACME, comparte ciudad con el grande)

| Nivel | zona DDL | postgis DDL | bbox DDL | geohash DDL | zona + prop. | postgis + prop. | bbox + prop. | geohash + prop. |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1k | 0,22 | 0,27 | 0,26 | 0,32 | 0,14 | 0,20 | 0,19 | 0,25 |
| 10k | 1,23 | 1,77 | 1,73 | 1,90 | 0,34 | 0,48 | 0,67 | 0,45 |
| 100k | 17,81 | 18,16 | 18,60 | 18,64 | 2,27 | 2,30 | 2,33 | 2,35 |

**Lectura:**

- **Con los indices del DDL la latencia crece lineal con el volumen**: unas 10 veces por
  cada nivel. A 100k el tenant grande queda en 124 ms: **no cumple**.
- **La causa se ve en el plan** (evidencia `precision-y-planes-100k.json` y seccion 8,
  H-02). El DDL solo tiene indice por `tenant_id` en `cobertura_aliado`, y
  `UNIQUE (aliado_id, zona_id)` tiene `zona_id` en segunda posicion. Para encontrar las
  coberturas de una zona, Postgres recorre ese indice completo.
- **Con los indices propuestos la consulta llega directo a (tenant, zona)**: 13 veces mas
  rapida a 100k (9,5 ms). Lo que queda es proporcional a las filas devueltas (321).
- **Un tenant chico no paga el volumen del grande**: ACME a 100k (10k aliados propios)
  tarda lo mismo que el grande a 10k.
- **Resolver la zona desde un punto no cuesta casi nada**: 0,04 a 0,07 ms por consulta
  en los planes. Con los indices propuestos, las cuatro variantes quedan dentro del
  ruido entre ellas. Lo que decide la latencia es el match, no la geografia.

### 6.3 Latencia extremo a extremo (QS-08)

Nivel 10k, **solo indices del DDL**, 20 VUs en lazo cerrado sin pausa (siempre 20
consultas en vuelo, mas exigente que 20 personas reales), 60 s por variante, una variante
despues de otra. JWT real de `aliado.poc.1` (tenant grande) contra la RPC via PostgREST.
Corrido el 2026-09-22 desde un equipo de escritorio (darwin/arm64) contra MANI-QA.
Evidencia: `qa/k6/evidencia/latencia-cobertura-2026-09-22T22-58-31-985Z.json`.

| Variante | Peticiones | p50 | **p95** | p99 | max | Filas media |
| --- | --- | --- | --- | --- | --- | --- |
| zona | 5.428 | 221 ms | **294 ms** | 404 ms | 719 ms | 31,9 |
| postgis | 5.508 | 219 ms | **287 ms** | 350 ms | 765 ms | 31,9 |
| bbox | 5.523 | 219 ms | **289 ms** | 330 ms | 636 ms | 31,8 |
| geohash | 5.408 | 223 ms | **296 ms** | 357 ms | 642 ms | 32,0 |

Checks 100 % (todas las respuestas 200 con lista).

- **Las cuatro cumplen QS-08** (p95 < 1000 ms) con margen de mas de 3 veces.
- **La consulta es ~5 % del tiempo total**: 11-16 ms en base (6.1) contra ~220 ms de
  mediana. El resto es red, TLS, PostgREST y verificacion del JWT. Entre variantes no hay
  diferencia medible por red, como anticipaba PoC-001.
- **No se corrio k6 a 100k.** En base, sin indices, el tenant grande ya tarda 124 ms por
  consulta; con 20 en vuelo eso se suma a la cola del pool. Queda como medicion
  pendiente si el cliente confirma ese volumen (seccion 7).

### 6.4 Precision de la zona resuelta

3150 puntos (1050 por tenant), referencia `ST_Contains`.

| Mecanismo | Acierta la localidad | Nota |
| --- | --- | --- |
| PostGIS | 100 % | Referencia |
| Bounding box + ray casting | 100 % | Exacto, pero el refinado es codigo propio |
| Bounding box sin refinar | — | El 25,5 % de los puntos cae en 2 a 4 cajas a la vez |
| **Geohash precision 6** | **93,78 %** | **6,2 % de los puntos devuelve los aliados de otra localidad** |

El error de geohash no es de implementacion: el geohash propio coincide con
`ST_GeoHash` en el 100 % de las entradas. Es inherente al metodo: una celda de ~1,2 ×
0,6 km que cruza un limite de localidad se asigna entera a una sola. Subir la precision
reduce el error pero no lo elimina, y multiplica las celdas a mantener.

### 6.5 Comparativa

| Criterio | zona (ADR-0011) | PostGIS | Bounding box | Geohash |
| --- | --- | --- | --- | --- |
| p95 a 100k con indices propuestos | 9,5 ms | 7,2 ms | 9,5 ms | 8,3 ms |
| Precision | Exacta por definicion | 100 % | 100 % refinado | 93,8 % |
| Dependencias | Ninguna | Extension PostGIS | Ninguna | Ninguna |
| Requiere coordenadas del sitio | No | Si | Si | Si |
| Mantenimiento | Catalogo de zonas | Geometria por zona | Geometria en arreglos + funcion propia | Tabla celda → zona, recalcular si cambia un limite |
| Explicable al cliente (ADR-0011 §4) | "No declaro esa zona" | Igual, una vez resuelta la zona | Igual | Falla en bordes sin explicacion para el cliente |

## 7. Conclusion y siguiente paso

1. **ADR-0011 se confirma.** El match por igualdad de `zona_id` cumple el umbral en los
   tres niveles, con p95 maximo de 9,5 ms a 100k, siempre que existan los indices
   propuestos. La condicion §6.4 no se activa: no hay volumen confirmado por el cliente
   y el defecto se mitiga con un indice, no con otro modelo. Es la mitigacion que el SAD
   ya preve para TO-01 ("si QS-08 se degrada, la mitigacion es indexacion").
2. **Recomendacion obligatoria: agregar los dos indices al DDL** antes de que la
   consulta de US-04.1.2 (SCRUM-861) llegue a produccion:

   ```sql
   CREATE INDEX idx_cobertura_aliado_tenant_zona
     ON cobertura_aliado (tenant_id, zona_id) INCLUDE (aliado_id);
   CREATE INDEX idx_aliado_categoria_tenant_categoria
     ON aliado_categoria (tenant_id, categoria_id) INCLUDE (aliado_id);
   ```

   Sin ellos, la consulta de despacho incumple el umbral entre 10k y 100k aliados por
   tenant.
3. **Si ADR-0011 §6 se activa, usar PostGIS.** Es exacto, tan rapido como las demas
   (resolver la zona cuesta ~0,06 ms), usa un indice nativo y Supabase lo trae
   disponible. Bounding box logra lo mismo, pero con geometria duplicada en arreglos y una
   funcion de punto-en-poligono propia que habria que mantener y probar. **Geohash queda
   descartado**: su 6,2 % de error en bordes rompe la propiedad que hace defendible a
   ADR-0011, que la exclusion de un aliado sea explicable.
4. **Nada de esto justifica activar §6 hoy.** Resolver la zona desde coordenadas solo
   sirve si aparece un requisito que lo pida (condiciones §6.1 a §6.3).
5. **Pendiente si el cliente confirma volumen:** repetir `qa/k6/latencia_cobertura.js` a
   ese nivel, con los indices ya en el DDL. A 10k el extremo a extremo tiene 3 veces de
   margen sobre QS-08; a 100k no se midio por red.

## 8. Hallazgos sobre el sistema

| # | Hallazgo | Impacto | Quien decide |
| --- | --- | --- | --- |
| H-01 | **QA no tiene los indices por `tenant_id` ni las UNIQUE `(aliado_id, zona_id)` / `(aliado_id, categoria_id)` que declara `DDL_MANI.sql`**: solo llaves primarias | QA no refleja el DDL. Ademas de latencia, sin las UNIQUE se puede declarar dos veces la misma cobertura | Dueño del DDL / DevOps |
| H-02 | El DDL no tiene indice que empiece por `zona_id` ni por `categoria_id`. La consulta de despacho recorre el indice UNIQUE completo | A 100k aliados por tenant, p95 124 ms en base (umbral 50 ms) | Dueño del DDL — recomendacion 7.2 |
| H-03 | A 100k la consulta devuelve ~320 aliados por zona y categoria | Sin orden (RF-13) ni paginacion, el listado de US-04.1.2 no escala en la interfaz | Autor de US-04.1.2 |

## 9. Estado

- Subtareas SCRUM-965 a SCRUM-970: evidencia en MANI-Flutter
  `supabase/poc-cfg10/evidencia/` y `qa/k6/evidencia/`.
- QA: esquema `poc_cfg10` y PostGIS pendientes de retirar con `90_limpiar.sql` una vez
  aprobado este informe.

## 10. Trazabilidad

`C-08 → REST-01 → RF-07, RF-12 → SP-02.1.1 → ADR-0011 → CFG-10 (SCRUM-927) → RNF-07 /
QS-08 → US-04.1.2 (SCRUM-861)`

| Artefacto | Elemento |
| --- | --- |
| ADR | ADR-0011 §4, §6, §6.4 |
| SRS | RF-07, RF-12, RNF-07, RNF-09, REST-01 |
| SAD | QS-08, KI-09, TO-01 |
| DDL | `cobertura_aliado`, `aliado_categoria` (indices recomendados) |
| Backlog | US-04.1.2 (SCRUM-861), US-02.1.4 (SCRUM-849) |

## Anexo A — Hallazgos metodologicos

### M-01 — El dashboard corta las peticiones de mas de ~2 minutos

A 100k sin indices, cada medicion del tenant grande tarda unos 2 minutos. El SQL Editor
devolvio `Failed to fetch` en tres de ellas, pero la consulta siguio en el servidor y
escribio su fila en `poc_cfg10.medicion`. Se comprobo con `pg_stat_activity` que no
quedaba ninguna activa antes de lanzar la siguiente, para que dos mediciones no
compitieran. Ninguna medicion se solapo con otra.

### M-02 — PostgREST corta en 1000 filas

La primera corrida de k6 fallo en `setup()`: la RPC de entradas devolvio 1000 de 1050
filas (`max-rows` de Supabase). No midio nada; su JSON vacio se borro. k6 usa 1000
entradas; las 50 que faltan eran las de calentamiento de la medicion en base.

### M-03 — Los scripts se ejecutaron verificando que eran los del repo

Cada script se cargo en el SQL Editor y se comparo su SHA-256 con el del archivo en la
rama antes de ejecutarlo. Despues de ejecutar solo cambio un comentario de
`20_seed_sintetico.sql` (filas por consulta medidas).

### M-04 — `entrada` y `medicion` sin RLS

Supabase lo advirtio al crear el esquema. Son tablas internas de la medicion, en un
esquema no expuesto por la API y sin grants a `anon`; `entrada` se lee desde k6 solo
por una RPC que filtra por el tenant del JWT.

### M-05 — Umbral publicado antes de medir, pero despues de preparar

Como en PoC-003 (M-02): el comentario con el umbral se publico despues de crear el
esquema y el primer seed, y antes de la primera medicion.

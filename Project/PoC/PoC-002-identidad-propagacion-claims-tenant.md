# PoC-002: Identidad y propagacion de claims de tenant en Supabase Auth

- **Ticket Jira:** SCRUM-929 (CFG-12)
- **Fecha:** 2026-09-22
- **Sprint:** 2
- **Responsable:** Santiago Hernandez — QA Tester
- **ADR relacionado:** ADR-0018 (Mecanismo de identificacion y propagacion de tenant) —
  estado Aceptado. Toca ademas ADR-0012, ADR-0013, ADR-0015 y ADR-0022.
- **Origen:** Sprint 2 Planning, hoja "2. DevOps y QA"

## 1. Pregunta que responde la PoC

¿El JWT emitido por Supabase Auth propaga `tenant_id` y `user_role` correctamente en el
100% de los inicios de sesion, y son esos claims —no una cabecera enviada por el cliente—
los que determinan el acceso a los datos?

## 2. Metrica y criterio de exito

Fijadas antes de ejecutar, como exige la excepcion para PoC del DoR.

| Metrica | Umbral de exito | Como se mide |
| --- | --- | --- |
| Propagacion correcta de `tenant_id` y `user_role` | **100%** de los logins | Decodificar el JWT emitido y contrastarlo contra un oraculo independiente del claim |
| Casos borde con comportamiento determinista y documentado | 3 de 3 | Usuario sin tenant, usuario sin vinculo, usuario multi-rol |
| Fugas de datos entre tenants | **= 0** | Suite Newman de ADR-0015, 6 casos de acceso cruzado |
| Casos positivos de las suites | **100%** en verde | Cada tenant si ve lo suyo |
| Intentos de suplantacion rechazados | **100%** | Suite anti-spoofing, 4 vectores |
| Verificacion de firma ES256 contra el JWKS | p95 **< 5 ms** (orientativo) | Benchmark offline con `jose`, 1000 iteraciones |
| Delta de latencia autenticado vs. anonimo | Se registra, **no decide** pasa/no pasa | k6 contra PostgREST |
| **Control negativo (validacion del instrumento)** | **Con el hook apagado, la suite debe ponerse roja** | Misma coleccion, mismo ambiente, hook desactivado |

La ultima fila no mide el sistema: mide la prueba. Si la suite siguiera verde con el
mecanismo apagado, estaria midiendo el seed y no el mecanismo, y el 100% de las demas
metricas no significaria nada.

### Por que el 100% podia ser tautologico, y como se evito

El seed de CFG-04 escribe `tenant_id`, `user_role` y `rol` directamente en
`auth.users.raw_app_meta_data`. GoTrue copia ese objeto a `app_metadata` del JWT. Medir la
propagacion contra esas cuentas habria dado 100% **con hook o sin hook**: se estaria
comprobando que el seed escribio lo que el seed escribio.

Por eso esta PoC siembra cuentas propias cuyo `raw_app_meta_data` lleva unicamente
`provider` y `providers`. El tenant vive solo en `public.usuario`. Si el token sale con
`tenant_id`, lo puso el mecanismo. La seccion 5 muestra que apagar el hook deja esas
cuentas con `app_metadata: { provider, providers }` y nada mas.

## 3. Alcance

**Incluye:**

- La **construccion** del mecanismo de ADR-0018, que no existia: un Custom Access Token
  Hook de Supabase Auth que resuelve tenant y rol desde `public.usuario` al emitir el
  token.
- La verificacion de la propagacion en dos tenants y con dos roles distintos, contra
  cuentas sin claims pre-escritos.
- Los casos borde que el modelo admite: usuario sin tenant y usuario sin vinculo.
- Una suite anti-spoofing de cuatro vectores contra las afirmaciones de ADR-0018.
- Los seis casos de acceso cruzado de ADR-0015, cada uno con su espejo positivo, mas un
  septimo sobre `WITH CHECK`.
- La medicion del costo de verificar la firma, aislado y en contexto.
- Un control negativo que demuestra que las mediciones anteriores miden el mecanismo.

**No incluye (fuera de alcance de esta PoC):**

- La autorizacion por rol dentro de un tenant. Es un hueco real del sistema —ver
  hallazgo H-02— pero RNF-01 habla de aislamiento **entre** tenants, que si se mide aqui.
- La implementacion de ADR-0013 (KYC en Supabase Storage). Su ausencia hace que el caso 6
  de ADR-0015 no sea ejecutable; sembrarlo desde esta PoC seria implementar el ADR de
  contrabando.
- El versionado de las politicas RLS en la cadena de migraciones. Se declara como riesgo
  (H-04), no se resuelve aqui.
- La integracion del hook en el flujo de registro de la aplicacion Flutter. La PoC
  demuestra que el mecanismo funciona al emitir el token; conectarlo al alta de usuarios
  es trabajo de producto.
- Latencia como criterio de aceptacion. Se registra y se interpreta.

## 4. Metodologia

1. **Verificacion de terreno.** Se interroga el catalogo de QA en vez de partir del DDL
   documentado, que SCRUM-959 ya encontro desactualizado. Resultado en
   `Entregas/PoC/SCRUM-971-verificacion-terreno.md`. De aqui sale el bloqueante B1 y la
   constatacion de que dos casos del ticket no son ejecutables.
2. **Construccion del hook.** Funcion `public.custom_access_token_hook`, `SECURITY
   INVOKER`, `STABLE`, `search_path` vacio, que falla cerrado. Mas el `GRANT` y la
   politica de lectura que B1 exigia. Registrado a mano en el dashboard.
3. **Seed de identidad.** Cuatro cuentas con `raw_app_meta_data` sin claims de tenant,
   en un dominio de correo propio (`@cfg12.mani.test`) para no interferir con los seeds de
   CFG-04 ni de CFG-09.
4. **Suites de Newman**, en este orden: propagacion, casos borde, anti-spoofing, acceso
   cruzado. Cada caso negativo con su espejo positivo.
5. **Medicion de tiempos**, fuera de las suites: verificacion de firma aislada y delta
   contra la API.
6. **Control negativo**, al final: se desactiva el hook y se repite la suite de claims.
   Va al final a proposito, cuando ya hay un verde que poner en duda.

**Herramientas usadas:** Newman 6.2.2 · k6 v2.3.0 (darwin/arm64) · Node v25.9.0 con `jose`
· Supabase/PostgreSQL 17.6, proyecto QA `hpsxdotaizzclkeufzct` · `READ COMMITTED` ·
`max_connections = 60`

### Por que Newman y no un script propio

La revision del 2026-09-17 del DoR y el DoD reparte las herramientas por modulo —Maestro
para pantallas de Flutter, Postman/Newman para endpoints de Java y .NET— pero deja el
aislamiento multi-tenant **fuera de ese reparto**, marcado como transversal en los dos
documentos (DoR punto 4, DoD punto 2). CFG-12 toca autenticacion y RLS. Ademas el DoD pide
el reporte de Newman como evidencia de cierre: un JSON de un script propio no lo es.

### El oraculo no es circular

El `tenant_id` del claim **no** se compara contra `public.usuario`. RLS filtra esa tabla
usando ese mismo claim, asi que la comprobacion confirmaria cualquier claim consigo mismo.
Se compara contra `public.tenant`, que tiene `lectura_global_tenant USING (true)` y se lee
sin depender de ningun claim: la asercion real es que el `tenant_id` del token corresponde
al tenant cuyo `slug` es el esperado.

## 5. Resultado

| Metrica | Umbral | Resultado obtenido | ¿Cumple? |
| --- | --- | --- | --- |
| Propagacion correcta de `tenant_id` y `user_role` | 100% | **100%** — 2 tenants, 2 roles, contra cuentas sin claims pre-escritos | Si |
| Casos borde deterministas | 3 de 3 | **2 de 3.** El tercero no es representable en el modelo | Parcial — ver 5.2 |
| Fugas entre tenants | 0 | **0** en lectura, listado, escritura, borrado e insercion | Si |
| Casos positivos en verde | 100% | **100%** | Si |
| Suplantacion rechazada | 100% | **4 de 4 vectores** | Si |
| Verificacion de firma ES256, p95 | < 5 ms | **0.1033 ms** | Si |
| Delta de latencia autenticado vs. anonimo | se registra | avg **1.39 ms**, mediana **0.07 ms** | n/a |
| **Control negativo** | la suite debe ponerse roja | **13 de 40 aserciones fallan** con el hook apagado | Si |

**Suites:** `mani-claims` 40/40 · `mani-aislamiento` 36/36 · corrida de control 27/40.

### 5.1 El control negativo, que es lo que hace que el resto signifique algo

Con el hook desactivado desde Authentication > Hooks, la misma coleccion, contra la misma
base y las mismas cuentas, cae a **13 aserciones fallidas**. El mensaje de una de ellas es
la evidencia completa:

```
expected [ 'provider', 'providers' ] to include 'tenant_id'
```

Sin el hook, `app_metadata` queda con solo `provider` y `providers`. Los claims de tenant
venian del hook y de ningun otro lado.

**Y hay un segundo hallazgo en esa misma corrida:** *27 de las 40 aserciones siguen
pasando* con el mecanismo apagado. Son las negativas —"ve 0 filas", "no devuelve filas del
tenant suplantado", los 401 del anti-spoofing— y pasan porque en ese estado **nadie ve
nada**. Es exactamente el falso verde que SCRUM-1039 anticipo para la suite de ADR-0015
cuando QA tenia RLS habilitado y cero politicas, reproducido aqui de forma controlada.

Es la justificacion empirica de por que cada caso negativo lleva su espejo positivo. Sin
los positivos, una suite de aislamiento da verde tanto cuando el aislamiento funciona como
cuando el acceso esta completamente roto.

### 5.2 Los dos casos que no son ejecutables

Se declaran en vez de omitirse, como pide la plantilla.

**Usuario con multiples roles (SCRUM-973).** `public.usuario` tiene una sola columna `rol`
y una sola columna `tenant_id`, y no existe tabla de membresia: las unicas tablas con
`usuario_id` y `tenant_id` a la vez son `aliado`, `cliente` y `notificacion`, que son
perfiles y notificaciones. La doble pertenencia **no es representable en el modelo**. No es
que la prueba falle: el caso no existe.

No contradice a ADR-0018, que ya admite como consecuencia negativa que cambiar de contexto
de tenant exige reexpedir el token. Lo que esta PoC agrega es que hoy ese escenario ni
siquiera se puede modelar: antes de reexpedir el token habria que poder representar la
doble pertenencia. Si el producto la necesita —hay RF de superadministrador— requiere
cambio de esquema y ticket propio.

**Caso 6 de ADR-0015, aislamiento de KYC en Storage.** QA tiene **cero buckets** en
`storage.buckets` y cero politicas sobre `storage.objects`: ADR-0013 no esta implementado.
La suite no omite el caso: lo **comprueba en cada corrida**, de modo que el dia que aparezca
un bucket el test falle y avise que hay que escribir el caso de verdad, en vez de quedar
declarado no ejecutable por inercia.

Queda un sustituto parcial que cubre el aislamiento de la **fila** de `documento_kyc`. Es
el caso 1 aplicado a la tabla mas sensible del modelo, **no** un sustituto del caso 6, que
es el del **objeto** en Storage.

### 5.3 Lectura de los tiempos

| Medicion | Valor |
| --- | --- |
| Verificacion ES256 contra JWKS, en caliente (avg / p50 / **p95**) | 0.0672 / 0.0607 / **0.1033** ms |
| Verificacion en frio, incluyendo el fetch del JWKS | 159.97 ms |
| Peticion autenticada a PostgREST (avg) | 114.41 ms |
| Peticion anonima a PostgREST (avg) | 113.03 ms |
| **Delta** (avg / mediana) | **1.39 / 0.07 ms** |

ADR-0018 califica la verificacion criptografica como "sobrecarga de computo marginal en
cada microservicio" sin haberla medido nunca. **Lo es, y por un margen amplio:** 0.07 ms
frente a los ~104 ms de ida y vuelta de red, unas mil quinientas veces menor.

Dos precisiones que el numero exige:

- **El costo real esta en el arranque, no en la peticion.** Los 159.97 ms en frio son el
  fetch del JWKS y se pagan una vez por proceso. Un middleware que no cachee la clave
  pagaria eso en cada peticion, que es un orden de magnitud distinto. La recomendacion
  operativa para Java y .NET es cachear el JWKS, no re-descargarlo.
- **El p95 del delta salio negativo (-34.20 ms).** No significa que autenticar sea mas
  rapido: significa que la diferencia es menor que el ruido de red y el signo es
  arbitrario. Reportarlo como mejora seria leer ruido como señal.

El delta tampoco es atribuible solo a la firma: incluye la evaluacion de RLS con el claim,
que la peticion anonima no paga porque no tiene claim que evaluar. El numero aislado es el
del benchmark.

**Evidencia:** `qa/newman/evidencia/` (reportes de las tres corridas, redactados),
`qa/jwt/evidencia/` (dos corridas del benchmark) y `qa/k6/evidencia/latencia-claims.json`,
en `Trama-AS/MANI-Flutter`, rama `feature/SCRUM-929-poc-claims-tenant`. Codigo en
`supabase/poc-cfg12/`, `qa/newman/`, `qa/jwt/` y `qa/k6/latencia_claims.js`.

## 6. Conclusion y siguiente paso

**Si, una vez construido el mecanismo que faltaba.** El JWT propaga `tenant_id` y
`user_role` en el 100% de los logins medidos, y son esos claims —no la cabecera
`X-Tenant-Slug`— los que determinan el acceso: un token con el `tenant_id` reescrito se
rechaza con 401, y la cabecera apuntando a otro tenant no cambia una sola fila de lo que el
usuario ve. Cero fugas entre tenants en los seis casos de ADR-0015.

El matiz importante: **ADR-0018 estaba decidido pero no implementado.** El `tenant_id`
llegaba al JWT solo porque el seed de QA lo escribia a mano en `raw_app_meta_data`. Un
usuario dado de alta por el flujo real de registro habria salido sin tenant y, contra las
politicas del ADR, sin acceso a nada. La PoC construyo el hook que cierra esa brecha.

- **Implicacion sobre ADR-0018:** confirma la decision tal como esta redactada. El
  mecanismo hibrido funciona, la firma protege el `tenant_id` frente a suplantacion
  (RNF-01, DR-01) y la cabecera de contexto queda confinada a la pre-autenticacion. El ADR
  **no requiere cambios**, pero deberia incorporar dos cosas que esta PoC aporta: la cifra
  real de la "sobrecarga marginal" y la recomendacion de cachear el JWKS en los middlewares
  de Java y .NET.

- **Implicacion sobre ADR-0015:** la suite de seis casos que el ADR define **ahora existe**
  (`qa/newman/mani-aislamiento.postman_collection.json`). El DoR punto 4 y el DoD punto 2 la
  daban por hecha; hasta hoy no estaba escrita en ningun repositorio. Queda pendiente
  engancharla al pipeline: `.github/workflows/ci.yml` solo dispara en `release/**` y no
  corre Newman.

- **Deuda tecnica y riesgos declarados:**
  1. **No existe autorizacion por rol dentro del tenant** (H-02). Las 15 politicas tienen
     `roles = {public}` y aislan solo por tenant. Un `cliente` puede modificar el perfil de
     un `aliado` de su tenant o leer sus documentos KYC. Requiere ticket propio y
     probablemente una decision de arquitectura.
  2. **Las politicas RLS no estan versionadas** (H-04) y `database/migrations/001_initial_schema.sql`
     no contiene ni un `CREATE POLICY`. Reconstruir DEV o PROD desde esa cadena produce el
     esquema sin aislamiento: el estado que SCRUM-1039 clasifico como "RNF-01 no
     implementado". Es el riesgo mas serio que deja esta PoC.
  3. **ADR-0013 no esta implementado en QA**, lo que deja el caso 6 de ADR-0015 sin poder
     ejecutarse.
  4. **La desviacion sobre `tenant` y `zona` sigue sin aprobar** (H-03), pendiente del
     Backend Lead desde SCRUM-1039.
  5. **`usuario.rol` es texto libre** (H-05). El hook copia al JWT el valor que encuentre;
     un `'Aliado'` mal escrito produciria un claim que ninguna politica reconoce.
  6. **La ampliacion de superficie del hook.** La politica `hook_lee_usuario` da a
     `supabase_auth_admin` lectura de todas las filas de `usuario`, cruzando tenants. Es
     inevitable —el hook resuelve el tenant antes de conocerlo— y queda acotada a `SELECT`
     sobre una sola tabla, con el rol no alcanzable desde la API. Se declara, no se esconde.
  7. **El token expirado no se probo** (ver anexo A, hallazgo M-04).

**Siguiente paso:** llevar el resultado a la Mesa junto con los puntos 1 y 2 de la deuda,
que exceden a CFG-12 y son los que mas comprometen RNF-01. Abrir los tickets de los cuatro
hallazgos. Enganchar `mani-aislamiento` al pipeline para que el gate del DoD sea ejecutable.

## 7. Estado

**Completada — cumple, con dos casos declarados no ejecutables** — ultima actualizacion:
2026-09-22

## 8. Trazabilidad

- Ticket Jira: SCRUM-929 (CFG-12)
- Subtareas: SCRUM-971, SCRUM-972, SCRUM-973, SCRUM-974, SCRUM-975, SCRUM-976
- ADR relacionados: ADR-0018 (validado) · ADR-0015 (su suite queda implementada) ·
  ADR-0012 y ADR-0022 (motor y proveedor) · ADR-0013 (no implementado, bloquea el caso 6)
- Requisitos: RNF-01, RNF-10, REST-01 · Objetivos de diseño: DR-01, DR-06
- Antecedentes: SCRUM-1039 (politicas RLS faltantes) · CFG-04 (SCRUM-921, seed
  multi-tenant) · PoC-001 (CFG-09), de donde viene el metodo del control negativo
- Verificacion de terreno: `Entregas/PoC/SCRUM-971-verificacion-terreno.md`
- Codigo y evidencia: `Trama-AS/MANI-Flutter`, rama `feature/SCRUM-929-poc-claims-tenant`
- Informe consolidado del sprint: DOC-16 (SCRUM-952)

---

## Anexo A — Hallazgos metodologicos

Hallazgos sobre **como se probo**, no sobre el sistema. Se declaran porque condicionan la
validez del resultado.

### M-01 — El fail closed del hook no existia, y lo atrapo la verificacion que parecia redundante

La primera version del hook construia los claims asi:

```sql
jsonb_set(v_claims, '{app_metadata,tenant_id}', to_jsonb(v_tenant::text))
```

con un comentario que afirmaba que `to_jsonb(NULL::text)` produce el literal JSON `null`.
**Es falso: produce SQL NULL.** Y `jsonb_set` con un `new_value` nulo devuelve NULL, que se
propaga hacia arriba. Para cualquier usuario sin fila en `usuario` o sin `tenant_id`, la
funcion **retornaba NULL entero** a GoTrue: comportamiento indefinido, no degradado seguro.
Justo el caso borde que SCRUM-973 tenia que medir.

Lo detecto la verificacion V4 del propio script, que existia para comprobar que las claves
salieran presentes y nulas. Devolvio `null` donde esperaba un objeto. La correccion fue
envolver cada valor en `coalesce(..., 'null'::jsonb)`.

Es el mismo patron que `r1` en PoC-001: una comprobacion que parece redundante hasta que
atrapa algo que ninguna otra habria visto. El comentario equivocado es lo mas instructivo —
la suposicion estaba escrita y documentada, y aun asi era falsa.

### M-02 — Un caracter corrupto en el transporte del SQL

Los scripts se aplicaron pegandolos en el SQL Editor del dashboard. En una de las
transferencias un caracter del texto codificado se altero y llego `string_agh` en vez de
`string_agg`. Postgres lo rechazo, asi que el fallo fue ruidoso.

**El riesgo no era ese, sino el silencioso:** un caracter alterado dentro de un literal —un
UUID de tenant, un correo— habria pasado sin error y contaminado la evidencia. Desde ese
punto se verifica el SHA-256 del contenido del editor contra el archivo del repositorio
antes de cada ejecucion. Las dos corridas siguientes coincidieron.

Recomendacion para quien repita estos pasos: no confiar en pegar textos largos sin
verificar un hash.

### M-03 — El reporte de Newman publicaba credenciales

El reporte JSON de newman guarda la peticion y la respuesta completas. Las cabeceras
`apikey` y `Authorization` son visibles, pero los cuerpos **no se guardan como texto**:
viven en `response.stream` como Buffer serializado. Ahi estaban enteros los `access_token`
y `refresh_token` de cada login.

La primera version del redactor solo inspeccionaba cadenas y reportaba "0 tokens
redactados" sobre un archivo que los tenia todos. El conteo en cero fue lo que levanto la
sospecha. El redactor final decodifica los buffers, y su auditoria posterior tambien, y
falla con codigo 1 si sobrevive algo con forma de JWT.

Vale para cualquier equipo que versione reportes de Newman: revisar `response.stream`, no
solo las cabeceras.

### M-04 — El token expirado no se probo

Los JWT de QA duran una hora. Probar el rechazo por expiracion exige esperar o bajar
temporalmente el TTL del proyecto, que es un cambio de configuracion de autenticacion con
efecto sobre todo el ambiente. Se decidio no hacerlo dentro de esta PoC.

El caso 5 de ADR-0015 —"endpoints con tokens expirados o alterados"— queda cubierto a
medias: el vector de token **alterado** demuestra que cualquier modificacion del payload,
`exp` incluido, invalida la firma y produce 401. Lo que no se probo es que un token
integro pero vencido sea rechazado por su `exp`.

### M-05 — Desviacion del DoR: la metrica se fijo antes, pero se publico despues

La excepcion para PoC del DoR exige metrica cuantitativa **definida antes de iniciar** y
evidencia adjunta al ticket. Los umbrales de la seccion 2 se fijaron antes de ejecutar
—constan en el plan aprobado al inicio del trabajo— pero no se publicaron en SCRUM-929
hasta despues de las primeras corridas.

La sustancia se cumplio: ningun umbral se ajusto despues de ver un resultado. El tramite no.
Se declara para que quede constancia y no se repita.

---

## Anexo B — Hallazgos sobre el sistema, heredados de la verificacion de terreno

Detalle completo en `Entregas/PoC/SCRUM-971-verificacion-terreno.md`. Resumen:

| # | Hallazgo | Impacto |
| --- | --- | --- |
| B1 | `supabase_auth_admin` no podia leer `public.usuario`: faltaba el `GRANT` y, aun con el, ese rol no bypassa RLS y la politica de la tabla compara contra `auth.jwt()`, que dentro del hook todavia no existe | Bloqueante, resuelto en la Fase 1. Sin resolverlo el hook habria emitido claims vacios **en silencio** |
| H-01 | `with_check = NULL` en 17 de 18 politicas | Funciona —Postgres reutiliza `USING`, comprobado por el caso 3b— pero depende de un comportamiento implicito |
| H-02 | Ninguna politica distingue rol ni propietario | No hay autorizacion dentro del tenant. Excede a RNF-01, requiere ticket |
| H-03 | `tenant` y `zona` con `FOR SELECT USING (true)` en vez de RLS apagado | Desviacion de ADR-0012 pendiente de aprobacion desde SCRUM-1039 |
| H-04 | Las politicas RLS existen solo en la base de QA; `database/migrations/` no las versiona | Reconstruir un ambiente produce el esquema sin aislamiento |
| H-05 | `usuario.rol` sin `CHECK` | El hook copia al JWT el valor que encuentre |

Dato adicional: `public.schema_migrations` **no existe en QA**. El paso "Apply DB Migrations
to Supabase QA" que CI incorporo la crea con `CREATE TABLE IF NOT EXISTS` en su primer
push, asi que nunca ha corrido contra ese ambiente. Eso da margen para corregir H-04 antes
de que la cadena aplique, en vez de despues.

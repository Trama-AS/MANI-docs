# ADR-0030 — Propiedad del esquema de base de datos y frontera de datos entre servicios

- **Estado:** Propuesto
- **Decisión de:** persistencia y fronteras de servicio
- **Autor:** Sara Albarracín Niño
- **Fecha:** 2026-10-17
- **Jira:** ARQ-02 (SCRUM-1233) y ARQ-03 (SCRUM-1234)
- **Relacionado con:** ADR-0012, ADR-0015, ADR-0019, ADR-0022, ADR-0029, RNF-01
- **Enmienda:** precisa SDD §4.2 y §12.3

---

## Contexto

La revisión de los dieciséis Pull Request abiertos del Sprint 4, hecha el 2026-10-16, encontró dos desviaciones que no son de un PR en particular sino de la falta de una decisión registrada. Ambas estaban asignadas como ARQ-02 y ARQ-03 y ninguna podía cerrarse sin fijar primero el criterio.

### Hallazgo 1: el esquema de la misma base tiene cuatro dueños y tres convenciones

| Ubicación | Convención | Registro de aplicación |
|---|---|---|
| `MANI-APIGateway/database/` | `init/` + `migrations/001`–`007` | ninguno |
| `MANI-Flutter/database/` | **copia byte a byte idéntica de la anterior** | ninguno |
| `MANI-Node/db/migrations/` | `0001`–`0004` | `schema_migrations` |
| `MANI-.NET` (propuesto en su PR #1) | `schema_and_seed_dotnet.sql`, DDL completo del esquema compartido | ninguno |

La duplicación entre Gateway y Flutter se verificó comparando hashes de `database/init/01-schema.sql` y `database/migrations/007_normalizar_dominios.sql`: son el mismo archivo en dos repositorios, sin ninguna indicación de cuál manda.

SDD §12.3 asume una serie incremental e inmutable (`V001__`, `V002__`…). Hoy hay tres numeraciones que avanzan en paralelo sobre la misma base de Supabase, y un cuarto repositorio proponiendo recrear las tablas desde cero con `CREATE TABLE IF NOT EXISTS`.

Además, `ModeloDatos.md` describe un esquema que no es el implementado: documenta `core.aliado` con `id_aliado`, `id_usuario` y `nivel_verificacion`, mientras la base real tiene `aliado` con `id`, `usuario_id`, `tenant_id` y `estado_verificacion`, sin esquemas nombrados. La divergencia se repite en varias entidades, y el síntoma visible es que los servicios inventan valores para cubrirla: la consulta de elegibilidad de Dispatch acepta `'VERIFICADO' OR 'aprobado'` porque el valor canónico no está fijado en ninguna parte.

### Hallazgo 2: los servicios cruzan la frontera de datos con SQL

SDD §4.2 dice que cada servicio es dueño de su almacén, que los servicios no acceden directamente a tablas propiedad de otro dominio, y que «Dispatch consulta a Core la elegibilidad por categoría y zona, y a Rules el orden del listado; son llamadas HTTPS entre servicios, no accesos cruzados a datos».

En los PR abiertos, Dispatch resuelve la elegibilidad con un `JOIN` directo contra `aliado`, `aliado_categoria` y `cobertura_aliado`, ordena el resultado con `ORDER BY nombre_razon_social` (el ranking es capacidad de Rules) e **inserta en `notificacion`**, que es la tabla de mensajería de Core. La misma regla de elegibilidad queda así implementada dos veces, en dos lenguajes, y la copia de Dispatch no se entera de los filtros que Core aplique después.

Al mismo tiempo, el PR #23 de Core resuelve el caso simétrico como el SDD manda: puerto declarado en el dominio, cliente HTTP en infraestructura, `timeout`, reintento y `503` si el otro servicio no responde. Existe, por tanto, un patrón correcto ya construido en el mismo sprint.

## Alternativas

### Para la propiedad del esquema

1. **Una base por servicio desde ya**, como describe SDD §4.2 en su estado objetivo. Descartada para el MVP: ADR-0012 ya rechazó la sobrecarga operativa de multiplicar bases, y hoy no hay capacidad de infraestructura para operarlas.
2. **Dejar que cada repositorio versione el DDL que necesita.** Es el estado actual. Descartada: sin una secuencia única no existe «el esquema», sino cuatro aproximaciones que sólo coinciden por suerte.
3. **Una base compartida por ambiente, con una única serie de migraciones y un dueño declarado.** Elegida.

### Para la frontera de datos

1. **Permitir el acceso cruzado a tablas cuando sea más rápido.** Descartada: contradice SDD §4.2 y duplica reglas de negocio, que es precisamente lo que ADR-0022 acababa de eliminar.
2. **Prohibir el acceso cruzado sin excepciones, desde ahora.** Descartada en la forma absoluta: hay trabajo en vuelo que ya lo hace y frenarlo en seco no entrega nada.
3. **Prohibirlo como regla, con excepciones explícitas, fechadas y con ticket.** Elegida.

## Decisión

### 1. Una base compartida por ambiente y una sola serie de migraciones, propiedad de Core

Mientras rija ADR-0012, hay **una base PostgreSQL por ambiente** y el esquema es **uno**, compartido por los tres servicios.

**Core Service (`MANI-Node`) es el dueño de la evolución del esquema.** Toda migración vive en `MANI-Node/db/migrations/`, con numeración incremental e inmutable y registro en `schema_migrations`. Se elige Core porque es la única serie que ya lleva registro de aplicación y porque Core es dueño de identidad, catálogo, clientes y aliados, que es la mayor parte del esquema (ADR-0022).

Consecuencias operativas, en firme:

- **Rules y Dispatch no versionan DDL.** Un servicio que necesite una tabla o una columna abre un PR de migración contra `MANI-Node`. El `schema_and_seed_dotnet.sql` propuesto en `MANI-.NET` #1 no entra.
- **`MANI-APIGateway/database/` y `MANI-Flutter/database/` quedan congelados como histórico**, con un `README` que declare que no son la fuente y apunte a la serie viva. No se agrega nada allí. Son el origen del esquema actual y por eso no se borran.
- **Toda tabla nueva nace con `tenant_id`, `ENABLE ROW LEVEL SECURITY` y su política por tenant** en la misma migración que la crea. ADR-0012 mantiene RLS como defensa en profundidad y ADR-0015 acredita el aislamiento asumiendo que existe; una tabla sin política queda fuera de esa evidencia. La revisión encontró tres tablas nuevas que incumplen esto, una de ellas de habeas data.
- **`ModeloDatos.md` se corrige para describir el esquema real**, y lo que hoy describe pasa a estar marcado explícitamente como estado objetivo. Incluye fijar el valor canónico de verificación del aliado, hoy inexistente. Ese trabajo es DOC4-04 (SCRUM-1247).

La propiedad por servicio que enuncia SDD §4.2 se mantiene como **estado objetivo**, no como descripción del presente. Migrar a una base por servicio exige un ADR nuevo que revise ADR-0012.

### 2. La frontera de datos se cruza por HTTP, nunca por SQL

Ningún servicio consulta ni escribe tablas de un dominio ajeno. Las dependencias entre servicios son llamadas HTTP sobre la red interna, con el patrón que `RulesServiceHttpClient` (Core, PR #23) ya implementa:

- puerto declarado en el dominio y cliente en infraestructura;
- `timeout` explícito y reintento sólo para operaciones idempotentes;
- propagación de `X-Tenant-Id`, `X-User-Role` y `X-Correlation-ID` tomados del claim verificado, nunca del cuerpo de la petición;
- **falla cerrado:** si la dependencia no responde, el llamador devuelve `503` y no sustituye la respuesta por lógica local ni por un valor por omisión.

En concreto, y según el reparto de ADR-0022: Dispatch pide a **Core** la elegibilidad por categoría y zona, pide a **Rules** el orden del listado, y notifica a través de **Core**, que es quien integra FCM/APNs, Storage y Realtime.

### 3. Excepciones: explícitas, fechadas y con ticket

Una desviación admitida por capacidad del sprint se registra en este ADR con el servicio, el acceso concreto, la razón y el ticket de salida con fecha. **Una excepción no registrada es un defecto**, no una decisión. Hoy no hay ninguna excepción vigente: el acceso cruzado que la revisión encontró está en PR sin fusionar, así que se corrige antes de entrar.

## Justificación

Las dos reglas apuntan al mismo problema: sin un dueño declarado, cada repositorio resuelve la parte que le toca y el resultado sólo es coherente por casualidad. Nombrar un dueño del esquema convierte un conflicto latente en un PR revisable, y prohibir el SQL entre dominios evita que la misma regla de negocio exista en dos lenguajes, que es justo lo que ADR-0022 vino a eliminar.

Ninguna de las dos exige construir nada nuevo: el registro de migraciones ya existe en Core y el patrón de cliente HTTP ya está implementado y probado de extremo a extremo en el mismo sprint.

## Consecuencias

### Positivas

- Existe «el esquema», con una secuencia y un lugar donde revisarlo.
- Las tablas nuevas entran con aislamiento por tenant, y la evidencia de ADR-0015 cubre lo que dice cubrir.
- Las reglas de negocio dejan de duplicarse entre servicios; el dueño de cada capacidad es el único que la implementa.
- Las desviaciones quedan visibles y con fecha, en lugar de vivir en el código sin que nadie las haya aceptado.

### Negativas

- Rules y Dispatch dependen de un PR en otro repositorio para evolucionar su persistencia, lo que añade latencia de proceso y hace de Core un punto de coordinación.
- Reemplazar el SQL cruzado de Dispatch por llamadas a Core es trabajo que no estaba estimado, y añade un salto de red a la ruta de elegibilidad, que es la que mide QAS-03 (p95 ≤ 500 ms). Hay que medirla después del cambio.
- Una dependencia caída deja de degradar y pasa a devolver `503`. Es lo correcto, pero cambia el comportamiento observable en QA y debe anunciarse antes de ejecutar la matriz.
- Corregir `ModeloDatos.md` contra el esquema real es más trabajo que ajustar unos nombres, porque la divergencia alcanza varias entidades.

## Condición de revisión

Revisar si el volumen o los requisitos regulatorios exigen aislamiento físico por tenant o una base por servicio (revisaría ADR-0012); si la medición de QAS-03 tras eliminar el SQL cruzado incumple el umbral del SDD §7.4 de forma atribuible al salto de red; o si Core se convierte en un cuello de botella de proceso para las migraciones de los otros servicios.

## Trazabilidad

| Elemento | Referencia |
|---|---|
| ADR relacionados | ADR-0012 (persistencia y RLS), ADR-0015 (pruebas de aislamiento), ADR-0019 (SOA políglota), ADR-0022 (lógica en servicios), ADR-0029 (comunicación asíncrona) |
| Documentos que precisa | SDD §4.2 (reglas de dependencia), SDD §12.3 (migraciones), `ModeloDatos.md` |
| Tareas que cierra | SCRUM-1233 (ARQ-02), SCRUM-1234 (ARQ-03) |
| Tareas que desbloquea | SCRUM-1247 (DOC4-04, DD V4) |
| PR afectados | `MANI-.NET` #1, #2 y #3 (SQL cruzado y DDL propio), `MANI-Node` #14 (tablas sin RLS) |
| Requisitos | RNF-01, RNF-05, QAS-03 |

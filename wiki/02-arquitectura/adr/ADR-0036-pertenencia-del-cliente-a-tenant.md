# ADR-0036 — Pertenencia del cliente a un tenant

- **Estado:** Propuesto
- **Decisión de:** modelo de datos, identidad y aislamiento multitenant
- **Proponente:** Sara Albarracín Niño (arquitectura)
- **Decide:** María Camila Beltrán Carreño (Product Owner); ratifica la Mesa de Arquitectura (ADR-0003)
- **Fecha:** 2026-11-11
- **Jira:** [SCRUM-1700](https://maniservices.atlassian.net/browse/SCRUM-1700) (T-55), origen [SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637)
- **Relacionado con:** ADR-0012 (persistencia multitenant), ADR-0018 (identificación y propagación del tenant), ADR-0015 (pruebas de aislamiento), ADR-0030 (frontera de datos), ADR-0031 (configuración de JWT por ambiente), SAD §7.3
- **Responde a la pregunta:** ¿puede un cliente pertenecer a más de un tenant?

---

## Contexto

El 5 de noviembre de 2026, en una prueba manual del flujo en MANI-QA, Santiago reportó que **cada cliente queda
asociado a un tenant** y lo señaló como defecto ([SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637)).
El reporte no trae el comportamiento esperado, así que lo primero que este ADR debe fijar es si el hecho observado es
un defecto o es el diseño vigente.

**Es el diseño vigente, y está escrito en tres capas que se sostienen entre sí.**

**1. Esquema.** En `MANI-APIGateway/database/init/01-schema.sql`:

```sql
CREATE TABLE IF NOT EXISTS usuario (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES tenant(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    rol TEXT NOT NULL, ...
);

CREATE TABLE IF NOT EXISTS cliente (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES tenant(id) ON DELETE CASCADE,
    usuario_id UUID NOT NULL UNIQUE REFERENCES usuario(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL
);
```

`cliente.usuario_id` es **UNIQUE**: un usuario tiene como máximo un perfil de cliente, y ese perfil cuelga de un
`tenant_id` escalar y obligatorio. La pertenencia a un solo tenant no es un efecto de la lógica de registro; es una
restricción de integridad.

**2. Token.** ADR-0018 §2 hace del claim `app_metadata.tenant_id` del JWT la **única fuente de verdad** del tenant, y
el Gateway rechaza con `401` todo token que no lo traiga. El claim es un escalar, no una lista.

**3. Base de datos.** `MANI-Node/db/migrations/0006_contexto_identidad.sql` deriva el tenant del token y lo rechaza si
viene nulo:

```sql
CREATE OR REPLACE FUNCTION app.tenant_id() ...
    RETURN (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid;
-- app.set_context: IF p_tenant_id IS NULL THEN
--   RAISE EXCEPTION 'MANI-RLS-400: el contexto exige tenant_id' USING ERRCODE = '22023';
```

Sobre esa función descansa el aislamiento completo: **64 usos de `app.tenant_id()` en 15 migraciones**, dentro de
**37 políticas RLS** sobre 14 tablas con RLS habilitada (`pago`, `queja`, `documento_legal`, `transaccion_evento`,
`regla_tenant`, `consentimiento_usuario`, `tarifa_referencia`, entre otras). Cada política compara la fila contra un
tenant único. No hay ninguna evidencia por API en contra: los lotes de prueba parten de este modelo y lo que
comprueban es precisamente el aislamiento por tenant (ADR-0015).

Lo que el reporte expone, entonces, no es una regresión sino **una pregunta de producto que nunca se decidió**: si una
misma persona natural o empresa que es cliente de dos tenants debe poder usar una sola cuenta.

## Alternativas

**A. Mantener un tenant por cliente (una cuenta por tenant).** El modelo actual. Si la misma persona es cliente de dos
tenants, se registra dos veces, con dos filas en `usuario` y dos perfiles de cliente. Nada cambia en esquema, token ni
RLS. Coste: la persona gestiona dos credenciales y no ve su historial unificado. `usuario.email` **no** tiene
restricción UNIQUE en el esquema, pero Supabase Auth (GoTrue) sí impone unicidad global del correo en `auth.users`
(ADR-0018 §1), de modo que la segunda cuenta exige **otro correo**. Esta es la fricción real de la opción A, y hoy no
está documentada en ninguna parte.

**B. Cuenta única con varias membresías y un tenant activo por sesión.** Se introduce una tabla
`usuario_tenant (usuario_id, tenant_id, rol, estado)`, se retira el `UNIQUE` de `cliente.usuario_id` y el token sigue
llevando **un** `tenant_id` escalar: el del tenant elegido al iniciar sesión. Las 37 políticas RLS **no se reescriben**,
porque `app.tenant_id()` sigue devolviendo un escalar. Lo que cambia es la emisión del token (hook de Supabase Auth,
ADR-0031), el flujo de login (selector de tenant) y el cambio de tenant sin cerrar sesión (reemitir el token). Coste:
migración de datos de las cuentas duplicadas que ya existan y un camino nuevo de autenticación que hay que probar
contra el lote de aislamiento.

**C. Token con varios tenants a la vez (claim de lista).** El JWT llevaría `tenant_ids: [...]` y las políticas
compararían con pertenencia a conjunto. **Descartada.** Obliga a reescribir las 64 comparaciones de
`app.tenant_id()` y las 37 políticas, rompe la firma escalar de `app.tenant_id()` en que se apoyan cuatro servicios
políglotas, e invalida el lote de pruebas de aislamiento de ADR-0015. Además amplía el radio de daño de un token
filtrado de un tenant a todos.

**D. Cliente global sin tenant (`cliente.tenant_id` nullable).** **Descartada.** Rompe la invariante de ADR-0012 y la
de `app.set_context`, que rechaza explícitamente `tenant_id` nulo (`MANI-RLS-400`). Dejaría filas de negocio sin
dueño y sin política aplicable.

## Decisión propuesta

**Se adopta la opción A para el MVP: un cliente pertenece a exactamente un tenant.** El comportamiento observado en
MANI-QA el 5 de noviembre **no es un defecto**; es el diseño vigente de ADR-0012 y ADR-0018, y así se declara.

Consecuencias inmediatas:

1. **[SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637) no se corrige en código.** Se reclasifica: de
   `Bug` pasa a documentación del modelo, o se cierra como «funciona según diseño» con enlace a este ADR. **No se
   toca código mientras este ADR no esté aprobado**, conforme al criterio de aceptación de
   [SCRUM-1700](https://maniservices.atlassian.net/browse/SCRUM-1700).
2. **Se documenta la fricción del correo.** La restricción de GoTrue (un correo, una cuenta) se escribe en `SAD.md`
   §7.3 y en el flujo de registro: si una persona es cliente de dos tenants, necesita un correo distinto por cuenta.
   Hoy esto no está escrito y es lo que hace que el modelo parezca un defecto a quien lo prueba.
3. **La opción B queda como evolución, no como deuda silenciosa.** Si el PO decide que la cuenta única es requisito,
   se abre una historia propia con el alcance de la opción B y este ADR se supersede. No se implementa por partes.

**Lo que esta decisión no hace:** no cambia el modelo de datos, no altera ninguna política RLS, no toca el claim del
token y no exige migración. Es la única de las cuatro alternativas con coste cero de implementación, y por eso es la
propuesta para el MVP; no porque la cuenta única carezca de valor.

## Consecuencias

### Positivas

- ADR-0012 y ADR-0018 quedan intactos y coherentes: un tenant escalar, no falsificable, de extremo a extremo.
- Las 37 políticas RLS y el lote de aislamiento de ADR-0015 siguen siendo válidos sin reescritura ni nueva evidencia.
- El radio de daño de un token filtrado permanece acotado a un tenant.
- El equipo deja de tratar como defecto abierto algo que es diseño, y lo presenta como tal en la sustentación.

### Negativas

- Una persona cliente de dos tenants gestiona dos cuentas **con dos correos distintos** y no ve su historial unificado.
- Si más adelante se adopta la opción B, habrá que unificar a mano las cuentas duplicadas creadas mientras rige esta
  decisión. El coste crece con el número de clientes reales, no con el tiempo.

## Verificación

Lo que debe comprobarse antes de dar este ADR por aplicado:

```sql
-- 1. La restricción que materializa la decisión sigue en pie, por ambiente.
SELECT conname, contype FROM pg_constraint
 WHERE conrelid = 'cliente'::regclass AND contype IN ('u','f');

-- 2. Ningún usuario tiene dos perfiles de cliente (debe devolver 0 filas).
SELECT usuario_id, count(*) FROM cliente GROUP BY usuario_id HAVING count(*) > 1;

-- 3. Ningún cliente quedó sin tenant (debe devolver 0).
SELECT count(*) FROM cliente WHERE tenant_id IS NULL;
```

```bash
# 4. El claim sigue siendo escalar y las políticas siguen comparando contra un escalar.
grep -rn "app.tenant_id()" MANI-Node/db/migrations/ | wc -l   # 64 al 2026-11-11
```

Y el lote de aislamiento multitenant de ADR-0015 debe seguir en verde sin cambios.

## Pendiente para aprobar

Este ADR está **Propuesto**. Para pasar a `Aceptado` necesita:

| # | Pregunta | Responde |
|---|---|---|
| M1 | ¿Se acepta que un cliente pertenezca a **un solo tenant** en el MVP, con la fricción de un correo por cuenta? | PO (Camila Beltrán) |
| M2 | ¿Se reclasifica [SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637) como «funciona según diseño», o se cierra con la documentación del modelo como entregable? | PO con SM |
| M3 | ¿La cuenta única con varias membresías (opción B) entra al backlog con historia propia, o se descarta para el alcance del producto? | PO |
| M4 | Si M3 es afirmativa, ¿quién es dueño del flujo de selección de tenant en el login: Core o el cliente Flutter? | Mesa de Arquitectura |

Mientras M1 no esté respondida por escrito, [SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637) se
presenta como **decisión pendiente del PO**, no como defecto abierto ni como defecto resuelto.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.0 | 2026-11-11 | Ficha inicial en estado `Propuesto`. Cuatro alternativas, dos descartadas por su impacto en RLS y en la invariante de tenant. Recomendación: opción A para el MVP. Cuatro preguntas abiertas para el PO y la Mesa. | Sara Albarracín |

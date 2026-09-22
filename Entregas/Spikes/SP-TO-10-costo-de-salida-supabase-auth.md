# SP-TO-10 — Costo de salida de Supabase Auth (vendor lock-in)

- **Trade-off que resuelve:** TO-10 (nuevo) — QS-01/QS-02 (Autenticación y confidencialidad)
  vs. AC-14 (Portabilidad)
- **Decisiones afectadas:** ADR-0022 (Supabase Auth como IdP), ADR-0012 (RLS), ADR-0018
  (identificación de tenant por claims del JWT)
- **Evidencia hoy:** ninguna. ADR-0022 asume explícitamente "acoplamiento moderado" y
  renuncia a "la portabilidad inmediata a un Postgres vanilla sin rehacer la capa de
  autenticación", pero ese costo nunca se cuantificó ni figuraba como trade-off en §6.
- **Ticket Jira:** pendiente de creación (Sprint 2)
- **Timebox:** 4 h (análisis, sin implementación)
- **Responsable propuesto:** Backend Lead con PO
- **Sprint destino:** 2

## 1. Pregunta que responde

Si el proyecto tuviera que dejar Supabase Auth, ¿qué piezas exactas habría que reescribir y
con qué esfuerzo estimado, y qué parte de ese acoplamiento es evitable hoy con decisiones de
diseño que no cuestan nada?

## 2. Hipótesis que se pone a prueba

El acoplamiento se concentra en dos puntos —la emisión del JWT y la función `auth.jwt()`
dentro de las políticas RLS— y puede aislarse tras una función de base de datos propia sin
perder ninguna ventaja de la integración Auth↔Database.

## 3. Métrica y criterio de decisión

| Métrica | Umbral | Cómo se mide |
| --- | --- | --- |
| Políticas RLS que invocan `auth.jwt()` directamente | Se registra | `pg_policies` de QA |
| Puntos de código cliente/backend atados al SDK de Supabase Auth | Se registra | Inventario sobre los tres repos |
| Esfuerzo estimado de sustitución del IdP | Se registra en días-persona | Estimación de la Mesa sobre el inventario |
| Puntos de acoplamiento evitables sin costo | Se registra | Propuesta de indirección (función propia `mani.tenant_id()`) |

Criterio de decisión: si el acoplamiento evitable es mayoritario y la indirección cuesta
menos de 1 día, la Mesa debería adoptarla ahora y bajar TO-10 de riesgo a costo conocido.

## 4. Alcance

**Incluye:** inventario de acoplamiento y la propuesta de indirección.

**No incluye:** migrar nada, ni evaluar IdP alternativos (ADR-0022 ya descartó Auth0 y
Firebase con motivo).

## 5. Método

1. Volcar `pg_policies` y contar invocaciones directas a `auth.jwt()`.
2. Inventariar los usos del SDK de Supabase Auth en Repo A, B y C.
3. Redactar la indirección propuesta y estimarla con el equipo.

## 6. Qué desbloquea

- Incorpora TO-10 a §6 con un costo estimado en vez de un "acoplamiento moderado" sin cifra.
- Cierra el revisor pendiente de ADR-0022 (`<Pendiente por asignar>`), que hoy incumple el
  punto 7 del checklist de Gobierno del Equipo §2.6.

## 7. Riesgo si no se ejecuta

El proyecto tiene tres ADR (0012, 0018, 0022) apoyados en la misma integración propietaria y
ninguna estimación de lo que cuesta salir de ella.

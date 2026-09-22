# SP-TO-01 — Overhead de RLS por consulta en la ruta de búsqueda de aliados

- **Trade-off que resuelve:** TO-01 — QS-02 (Confidencialidad, RLS) vs. QS-08 (Capacidad, búsqueda)
- **Decisión afectada:** ADR-0012 (Backend Dart, Supabase/PostgreSQL, aislamiento por RLS)
- **Evidencia hoy:** ninguna. La Tabla C del SAD §6 dice "se acepta el costo de RLS" sin
  haber medido ese costo. QS-08 fija "< 1 s con 20 usuarios buscando a la vez" y el propio
  escenario marca la medida como "pendiente validar con volumen real".
- **Ticket Jira:** pendiente de creación (Sprint 2)
- **Timebox:** 6 h
- **Responsable propuesto:** Backend Lead con apoyo de QA
- **Sprint destino:** 2

## 1. Pregunta que responde

¿Cuánto cuesta la evaluación de políticas RLS en la consulta de listado de aliados
(categoría + zona + orden configurable), y a partir de cuántas políticas o de qué volumen
de filas ese costo pone en riesgo el umbral de QS-08?

## 2. Hipótesis que se pone a prueba

El costo de RLS sobre la ruta de búsqueda es despreciable frente al costo del propio join
aliado↔zona↔categoría, y la mitigación correcta ante degradación es indexación, no relajar
RLS — que es exactamente lo que la Tabla C ya afirma sin evidencia.

## 3. Métrica y criterio de decisión

| Métrica | Umbral | Cómo se mide |
| --- | --- | --- |
| Latencia P95 del listado con RLS activa | < 1 s con 20 usuarios concurrentes (QS-08) | k6 contra QA, JWT real por usuario |
| Delta de latencia RLS on/off | Se registra; sin umbral | Misma consulta con `SECURITY DEFINER` sin política vs. `SECURITY INVOKER` con política |
| Filas examinadas / tiempo de planificación | Se registra | `EXPLAIN (ANALYZE, BUFFERS)` de la consulta con y sin política |
| Sensibilidad al número de políticas | Se registra | Repetir con 1, 3 y 5 políticas sobre las tablas de la consulta |

Criterio de decisión: si el delta atribuible a RLS supera el 20 % de la latencia total, el
trade-off deja de ser "aceptado sin más" y pasa a exigir un plan de indexación explícito
en ADR-0012 antes del MVP.

## 4. Alcance

**Incluye:** la consulta de listado de aliados de RF-12/RF-13 sobre el proyecto QA, con los
tres órdenes configurables de RF-13 (cobertura, calificación, comisión).

**No incluye:** la corrección del aislamiento (eso lo cubre ADR-0015 / CFG-12), el
dimensionamiento del hosting (KI-03) ni la búsqueda textual.

## 5. Método

1. Sembrar un tenant de volumen con al menos 5 000 aliados y su relación N:M con zonas.
2. Medir la consulta con `EXPLAIN (ANALYZE, BUFFERS)` con política activa y sin ella.
3. Correr k6 con 20 VUs autenticados. Provisionar los JWT **antes** de la ventana medida
   (hallazgo H-03 de PoC-001: Supabase Auth responde `429` alrededor de la petición 30).
4. Repetir variando el número de políticas sobre las tablas implicadas.

## 6. Qué desbloquea

- Cierra la Tabla C de TO-01 con un número en vez de una afirmación.
- Alimenta KI-06 (si el aislamiento lógico por RLS sobre esquema compartido basta a futuro).
- ADR destino: nota de alcance sobre ADR-0012 si el resultado exige plan de indexación.

## 7. Riesgo si no se ejecuta

El SAD declara aceptado un costo que nadie ha medido sobre el atributo de calidad de
prioridad Alta (QS-08). Si degrada en producción, la presión será relajar RLS — la única
mitigación que DR-01 no permite.

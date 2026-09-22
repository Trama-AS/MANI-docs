# SP-TO-02 — Combinatoria de configuración por tenant frente al aislamiento

- **Trade-off que resuelve:** TO-02 — QS-02 (Confidencialidad) vs. QS-07 (Adaptabilidad)
- **Decisiones afectadas:** ADR-0012 (RLS), ADR-0014 (Feature Toggle)
- **Evidencia hoy:** ninguna. La Tabla C declara TO-02 como "requisito cruzado" sin
  enumerar cuántas combinaciones existen ni cuáles tocan una política RLS.
- **Ticket Jira:** pendiente de creación (Sprint 2)
- **Timebox:** 4 h
- **Responsable propuesto:** Backend Lead
- **Sprint destino:** 2

## 1. Pregunta que responde

¿Cuántos puntos de configuración por tenant existen hoy, cuáles de ellos intervienen en una
política RLS o en la construcción de una ruta de Storage, y existe alguna combinación
válida de esos puntos que rompa el aislamiento?

## 2. Hipótesis que se pone a prueba

Ninguna configuración de tenant puede alterar el predicado de una política RLS, porque el
`tenant_id` se extrae del JWT verificado (ADR-0018) y no de datos configurables. Si la
hipótesis se sostiene, TO-02 baja de "tensión abierta" a "acotada por construcción".

## 3. Métrica y criterio de decisión

| Métrica | Umbral | Cómo se mide |
| --- | --- | --- |
| Puntos de configuración inventariados | 100 % de los de RF-02, RF-10, RF-11, RF-13 y los toggles de ADR-0014 | Inventario sobre el esquema de QA y el backlog |
| Puntos que entran en un predicado RLS | = 0 | Lectura de `pg_policies` cruzada con el inventario |
| Puntos que entran en una ruta de Storage | Se registra | ADR-0013: ruta `tenant_id/aliado_id/archivo` |
| Combinaciones que rompen aislamiento | = 0 | Casos de acceso cruzado sobre las combinaciones identificadas |

Criterio de decisión: un solo punto de configuración dentro de un predicado RLS invalida la
hipótesis y obliga a un ADR nuevo sobre separación entre configuración y política.

## 4. Alcance

**Incluye:** inventario de configuración por tenant y su cruce con `pg_policies` y con las
rutas de Storage de ADR-0013.

**No incluye:** la ejecución completa de la suite de ADR-0015 (eso es SP-TO-05) ni el
rendimiento (SP-TO-01).

## 5. Método

1. Inventariar los puntos de configuración por tenant declarados en el SRS y el backlog.
2. Volcar `pg_policies` de QA y marcar qué columnas participan en cada predicado.
3. Cruzar ambos conjuntos. Documentar cada intersección como riesgo con nombre propio.
4. Para cada intersección (si la hay), escribir un caso de acceso cruzado que la explote.

## 6. Qué desbloquea

- Convierte TO-02 de "requisito cruzado declarado" en una lista finita y verificable.
- Da a ADR-0014 el alcance real de la superficie de toggles que debe cubrirse en pruebas.
- ADR destino: ADR nuevo solo si aparece una intersección real.

## 7. Riesgo si no se ejecuta

El equipo sigue sin saber cuántas combinaciones debe cubrir la suite de QS-17, y TO-05
(crecimiento de la suite) no se puede dimensionar.

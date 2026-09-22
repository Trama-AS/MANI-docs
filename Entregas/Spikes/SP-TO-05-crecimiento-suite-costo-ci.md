# SP-TO-05 — Crecimiento de la suite de aislamiento y su costo en CI

- **Trade-offs que resuelve:** TO-05 — QS-07 (Adaptabilidad) vs. QS-17 (Verificabilidad) ·
  TO-08 — QS-17 (Verificabilidad) vs. QS-08 (Capacidad)
- **Decisiones afectadas:** ADR-0015 (suite Newman en CI), ADR-0014 (Feature Toggle)
- **Evidencia hoy:** ninguna. TO-08 afirma que "el costo se paga en CI, no en producción" y
  que ADR-0015 "no lo considera bloqueante", sin haber cronometrado la suite. La suite son
  hoy 6 casos (QS-17) y TO-05 declara que debe crecer con cada regla configurable, sin un
  ritmo de crecimiento estimado.
- **Ticket Jira:** pendiente de creación (Sprint 2)
- **Timebox:** 4 h
- **Responsable propuesto:** QA & Security Testing Lead
- **Sprint destino:** 2

## 1. Pregunta que responde

¿Cuánto tarda hoy la suite de aislamiento en un PR que toca auth/RLS/esquema, cuántos casos
añade cada nuevo punto de configuración por tenant, y a partir de qué número de casos el
tiempo de CI deja de ser aceptable para el ritmo de PR del equipo?

## 2. Hipótesis que se pone a prueba

El crecimiento de la suite es lineal en el número de puntos de configuración (no
combinatorio), y el tiempo total se mantiene por debajo del umbral de tolerancia del equipo
durante todo el MVP.

## 3. Métrica y criterio de decisión

| Métrica | Umbral | Cómo se mide |
| --- | --- | --- |
| Duración de la suite actual (6 casos) | Se registra | Tiempo de job en GitHub Actions, 5 corridas |
| Minutos de CI por PR que toca auth/RLS/esquema | < 10 min | Ídem, incluyendo instalación de dependencias |
| Casos nuevos por punto de configuración | Lineal (≤ 2 casos por punto) | Derivado del inventario de SP-TO-02 |
| Proyección a los puntos de configuración del MVP | < 10 min | Extrapolación con el costo por caso medido |

Criterio de decisión: si la proyección supera los 10 min, ADR-0015 debe adoptar ejecución
selectiva por área tocada en vez de suite completa en cada PR — y eso es un ADR nuevo.

## 4. Alcance

**Incluye:** la colección Postman/Newman de ADR-0015 ejecutada en GitHub Actions sobre QA.

**No incluye:** la corrección de los casos (verifican aislamiento, no se reescriben aquí) ni
la carga de producción.

## 5. Método

1. Cronometrar el job actual cinco veces y tomar la mediana.
2. Calcular el costo marginal por caso añadiendo dos casos artificiales.
3. Cruzar con el inventario de puntos de configuración de SP-TO-02 para proyectar.
4. Provisionar credenciales antes de la corrida: el límite de Supabase Auth (H-03 de
   PoC-001) también aplica a esta suite.

## 6. Qué desbloquea

- Cierra TO-05 y TO-08 con tiempos reales en vez de una afirmación de no-bloqueo.
- Da a ADR-0014 el costo de verificación de cada toggle nuevo.

## 7. Riesgo si no se ejecuta

La regla de proceso de TO-05 ("la suite crece con cada regla configurable") no tiene techo
declarado: el equipo la cumplirá hasta que el CI se vuelva insoportable y entonces la
relajará sin decisión formal.

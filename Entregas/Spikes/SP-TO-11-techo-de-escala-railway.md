# SP-TO-11 — Techo de escala de Railway + Docker Hub como plataforma de despliegue

- **Trade-off que resuelve:** TO-11 (nuevo) — QS-16 (Disponibilidad) vs. restricción
  financiera (KI-03: sin costos fijos de infraestructura)
- **Decisiones afectadas:** ADR-0023 (eliminación de Azure, migración a Docker Hub +
  Railway), ADR-0004, ADR-0006
- **Evidencia hoy:** ninguna medición. ADR-0023 declara como trade-off que "Railway tiene
  menor techo de escala que Azure", sin cuantificar ese techo. KI-03 sigue abierto en el
  "cómo": dónde y con qué nodos corre el clúster.
- **Ticket Jira:** pendiente de creación (Sprint 2)
- **Timebox:** 5 h
- **Responsable propuesto:** DevOps
- **Sprint destino:** 2

## 1. Pregunta que responde

¿Cuáles son los límites concretos del plan de Railway que el proyecto puede pagar (CPU,
memoria, conexiones concurrentes, minutos de build, límites de pull de Docker Hub), y a qué
carga de usuarios equivalen frente al objetivo de QS-16 (≥ 99.5 % mensual)?

## 2. Hipótesis que se pone a prueba

El plan asumible de Railway sostiene la carga del MVP académico con margen, y el techo solo
se vuelve relevante en un escenario de producción real que el proyecto no alcanzará durante
el curso.

## 3. Métrica y criterio de decisión

| Métrica | Umbral | Cómo se mide |
| --- | --- | --- |
| CPU/memoria disponibles por servicio en el plan | Se registra | Documentación del plan contratado |
| Peticiones concurrentes sostenidas antes de degradar | Se registra | k6 escalonado hasta degradación |
| Disponibilidad observada en una ventana de 7 días | ≥ 99.5 % (QS-16) | Observabilidad de ADR-0006 |
| Límite de pulls de Docker Hub por hora | Se registra | Política vigente de la cuenta usada |
| Relación de la huella de observabilidad con el techo | < 10 % (enlaza con SP-TO-04) | Métricas de Railway |

Criterio de decisión: si la degradación aparece por debajo de la carga de QS-08 (20 usuarios
concurrentes en búsqueda), el techo de Railway deja de ser aceptable y KI-03 pasa de abierto
a bloqueante.

## 4. Alcance

**Incluye:** el plan de Railway efectivamente en uso, el registro en Docker Hub y los tres
servicios containerizados de ADR-0023.

**No incluye:** volver a evaluar Azure (ADR-0023 lo descartó con motivo financiero) ni
dimensionar el clúster Kubernetes de PROY-08, que sigue siendo un ADR abierto.

## 5. Método

1. Documentar los límites publicados del plan en uso, con fecha y fuente.
2. Carga escalonada con k6 hasta observar degradación; registrar el punto de quiebre.
3. Dejar la ventana de observabilidad corriendo 7 días y medir disponibilidad real.

## 6. Qué desbloquea

- Incorpora TO-11 a §6 y da cifra al trade-off que ADR-0023 declaró en prosa.
- Aporta el dato que falta en KI-03 para cerrar el "cómo" del hosting.

## 7. Riesgo si no se ejecuta

Se eliminó el proveedor anterior por costo sin caracterizar el techo del sustituto, y tres
ADR (0004, 0006, 0023) dependen de esa plataforma.

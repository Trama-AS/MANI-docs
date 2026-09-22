# SP-TO-04 — Huella de recursos de los agentes de observabilidad

- **Trade-off que resuelve:** TO-04 — QS-16 (Disponibilidad) vs. QS-18 (Analizabilidad)
- **Decisión afectada:** ADR-0006 (Prometheus + Grafana + Datadog)
- **Evidencia hoy:** ninguna medición. ADR-0006 reconoce el costo como desventaja de la
  opción elegida, pero el consumo nunca se cuantificó — y el destino de despliegue cambió
  de Azure a Railway (ADR-0023), donde el techo de recursos es otro.
- **Ticket Jira:** pendiente de creación (Sprint 2)
- **Timebox:** 5 h
- **Responsable propuesto:** DevOps
- **Sprint destino:** 2

## 1. Pregunta que responde

¿Cuánta CPU y memoria consumen los agentes de observabilidad por servicio instrumentado
sobre Railway, y qué porcentaje del presupuesto de recursos del plan contratado se llevan
frente al servicio principal?

## 2. Hipótesis que se pone a prueba

La huella de instrumentación cabe dentro del plan de Railway sin degradar el servicio
principal; el trade-off es de costo operativo, no de disponibilidad.

## 3. Métrica y criterio de decisión

| Métrica | Umbral | Cómo se mide |
| --- | --- | --- |
| CPU del agente / CPU del servicio | < 10 % | Métricas del propio Railway, 1 h de carga sintética |
| Memoria residente del agente | Se registra por servicio | Ídem |
| Delta de latencia P95 con y sin instrumentación | < 5 % | k6 sobre el mismo endpoint |
| Tiempo de detección de anomalía | < 5 min (QS-18) | Inyectar un error y cronometrar la alerta |

Criterio de decisión: si la huella supera el 10 % de CPU o el delta de latencia supera el
5 %, ADR-0006 debe reducir alcance (por ejemplo, muestreo o un solo backend de métricas en
vez de tres) antes del MVP.

## 4. Alcance

**Incluye:** un servicio Java (Repo B) y uno .NET (Repo C) desplegados en Railway con la
instrumentación de ADR-0006.

**No incluye:** el costo monetario del plan de Datadog, la definición de umbrales de falsos
positivos (declarada pendiente en QS-18) ni el dimensionamiento del clúster (KI-03).

## 5. Método

1. Desplegar un servicio instrumentado y su gemelo sin instrumentar en Railway.
2. Aplicar carga sintética equivalente durante 1 h a ambos.
3. Comparar CPU, memoria y latencia P95.
4. Inyectar un error controlado y cronometrar hasta la alerta y el issue en Jira.

## 6. Qué desbloquea

- Da a TO-04 un número y cierra la dependencia con KI-11, ya resuelto en cuanto al
  destinatario técnico (Java/.NET preservados) pero no en cuanto al costo.
- ADR destino: nota de alcance sobre ADR-0006 si hay que recortar la instrumentación.

## 7. Riesgo si no se ejecuta

Se instrumentan tres backends de observabilidad sobre una plataforma de hosting cuyo techo
de recursos tampoco está caracterizado (ver SP-TO-11), sobre un atributo (QS-16) cuyo
objetivo es 99.5 % mensual.

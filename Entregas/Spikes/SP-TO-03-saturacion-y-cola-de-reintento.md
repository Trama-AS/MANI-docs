# SP-TO-03 — Saturación sostenida del despacho y necesidad de cola de reintento

- **Trade-off que resuelve:** TO-03 — QS-09 (Tolerancia a fallos, despacho) vs. QS-16 (Disponibilidad)
- **Decisiones afectadas:** ADR-0021 (exclusión concurrente), ADR-0016 (despacho broadcast)
- **Evidencia hoy:** **parcial y empírica.** PoC-001 (SCRUM-926, 2026-09-21) midió el
  mecanismo: 1 asignación de 50 aceptaciones simultáneas, 0 dobles, contra un control
  negativo que bajo idéntica carga produjo 10 asignaciones en 136 ms. Lo que **no** está
  medido es el residual: el comportamiento bajo saturación sostenida (solo 10 de 50
  peticiones llegaron a solaparse por el pool de PostgREST, hallazgo H-04) y el costo real
  de no tener cola de reintento ante caída de base.
- **Ticket Jira:** pendiente de creación (Sprint 2)
- **Timebox:** 8 h
- **Responsable propuesto:** QA Tester (autor de PoC-001) con DevOps
- **Sprint destino:** 2

## 1. Pregunta que responde

Por encima de la concurrencia que el pool de PostgREST permite, ¿el despacho sigue siendo
correcto y a qué costo de latencia?, y ¿cuál es la frecuencia esperada de indisponibilidad
de base que justificaría —o no— construir la cola de reintento que ADR-0021 descartó?

## 2. Hipótesis que se pone a prueba

La exclusión concurrente se mantiene correcta bajo cola (las peticiones se serializan, no se
pierden), y la frecuencia de caída de base es lo bastante baja frente al objetivo de QS-16
(≥ 99.5 % mensual) como para que la cola de reintento siga siendo deuda aceptable y no
bloqueante del MVP.

## 3. Métrica y criterio de decisión

| Métrica | Umbral | Cómo se mide |
| --- | --- | --- |
| Asignaciones por solicitud bajo saturación | = 1 | `poc_asignacion_log`, reutilizando el harness de PoC-001 |
| Concurrencia efectiva observada | Se registra por nivel de carga | Solapamiento real en la bitácora (no el N enviado) |
| Latencia P95 de la aceptación en cola | Se registra; sin umbral de aceptación | k6 |
| Peticiones perdidas (ni 200 ni 409) | = 0 | Contador `otros` del harness |
| Aceptaciones fallidas ante base caída | Se registra | Corrida con la base deliberadamente inaccesible |

Criterio de decisión: si bajo saturación aparece alguna respuesta distinta de 200/409, o
más de 1 asignación, ADR-0021 no puede pasar a Aceptado sin la cola de reintento.

## 4. Alcance

**Incluye:** reutilización del harness y la RPC de PoC-001 elevando el N y ampliando el pool
de PostgREST; una corrida con la base inaccesible para caracterizar el fallo que hoy se
traslada al cliente.

**No incluye:** construir la cola (eso sería otra decisión), el broadcast de RF-12/RF-13 ni
la autorización por rol (SP-TO-06 / hallazgo H-02).

## 5. Método

1. Partir del estado ya verificado en `Entregas/PoC/SCRUM-959-verificacion-terreno.md`.
2. Subir el pool de PostgREST hasta acercarse a `max_connections = 60` y repetir la corrida
   de 50 aceptaciones. Medir el solapamiento real, no el N enviado (H-04).
3. Mantener la ventana artificial por encima de la dispersión de llegada observada (H-05) y
   correr todas las variantes con la misma alineación.
4. Corrida de indisponibilidad: cortar el acceso a la base durante el despacho y registrar
   qué recibe el cliente.

## 6. Qué desbloquea

- Cierra el residual de TO-03 y permite que la Tabla C cite evidencia en vez de remitir a
  KI-06 suelto — actualización que el propio ADR-0021 pide en su trazabilidad.
- Habilita el paso de ADR-0021 de Propuesto a Aceptado con el residual acotado.

## 7. Riesgo si no se ejecuta

ADR-0021 pasaría a Aceptado con una evidencia que solo cubre hasta la concurrencia que el
pool dejó pasar, y el SAD registraría como cerrado un trade-off que sigue abierto por
encima de ese punto.

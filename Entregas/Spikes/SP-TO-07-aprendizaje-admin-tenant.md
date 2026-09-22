# SP-TO-07 — Superficie de configuración frente a la capacidad de aprendizaje del Admin. tenant

- **Trade-off que resuelve:** TO-07 — QS-07 (Adaptabilidad) vs. QS-19 (Aprendizaje)
- **Decisión afectada:** ninguna. **TO-07 es el único trade-off del SAD sin ADR asociado**
  y sin decisión tomada: la Tabla C dice "se deja como tensión abierta para que la Mesa la
  resuelva junto con el diseño de UX".
- **Evidencia hoy:** ninguna. QS-19 fija ≥ 80 % de usuarios nuevos completando el flujo
  crítico sin abandonar, pero ese escenario mide al Cliente y al Aliado, no al Admin. tenant
  —que es quien sufre la superficie de configuración.
- **Ticket Jira:** pendiente de creación (Sprint 2)
- **Timebox:** 6 h
- **Responsable propuesto:** Frontend Lead con PO
- **Sprint destino:** 2

## 1. Pregunta que responde

¿Cuántas decisiones de configuración debe tomar un Admin. tenant para dejar su tenant
operativo desde cero, y cuántas de ellas puede resolver la plataforma con un valor por
defecto sin sacrificar adaptabilidad?

## 2. Hipótesis que se pone a prueba

La mayor parte de la superficie de configuración admite un valor por defecto sensato, de
modo que la adaptabilidad de QS-07 se conserva y la curva de aprendizaje se paga solo cuando
el tenant se aparta del valor por defecto.

## 3. Métrica y criterio de decisión

| Métrica | Umbral | Cómo se mide |
| --- | --- | --- |
| Decisiones obligatorias para dejar el tenant operativo | ≤ 8 | Recorrido del flujo de alta sobre el inventario de SP-TO-02 |
| Puntos que admiten valor por defecto | Se registra (% del total) | Revisión con el PO |
| Tiempo de alta de un tenant sin capacitación | < 30 min | Prueba con un integrante que no haya trabajado el módulo |
| Puntos que el Admin. no puede interpretar sin ayuda | Se registra | Observación en la misma prueba |

Criterio de decisión: más de 8 decisiones obligatorias justifica un ADR de "configuración
por defecto + configuración avanzada" como patrón de producto.

## 4. Alcance

**Incluye:** el flujo de alta y configuración de tenant (RF-02, RF-10, RF-11, RF-13).

**No incluye:** el diseño visual de la interfaz (ADR-0020 cubre las herramientas, no las
decisiones de UX) ni los flujos de Cliente/Aliado, ya cubiertos por QS-19.

## 5. Método

1. Tomar el inventario de puntos de configuración de SP-TO-02.
2. Clasificar cada punto: obligatorio, con valor por defecto, o avanzado.
3. Prueba de recorrido con un integrante del equipo ajeno al módulo, cronometrada, sin
   ayuda y registrando cada punto de duda.

## 6. Qué desbloquea

- Da a la Mesa la primera base objetiva para resolver TO-07, que lleva abierto desde la V1
  del SAD sin decisión.
- ADR destino: ADR nuevo sobre estrategia de configuración por defecto (no existe hoy).

## 7. Riesgo si no se ejecuta

TO-07 sigue siendo el único trade-off del SAD sin decisión ni ADR: una tensión declarada que
nadie posee y que se resolverá de facto en el código de la interfaz.

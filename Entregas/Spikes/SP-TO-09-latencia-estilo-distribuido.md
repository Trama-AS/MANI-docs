# SP-TO-09 — Latencia y trazabilidad del estilo macroarquitectónico distribuido

- **Trade-off que resuelve:** TO-09 (nuevo) — QS-08 (Capacidad, latencia extremo a extremo)
  vs. AC-12 (Modularidad, despliegue independiente)
- **Decisión afectada:** ADR-0019 (estilo distribuido orientado a servicios multi-tenant)
- **Evidencia hoy:** ninguna. ADR-0019 declara como consecuencia negativa la "latencia
  inherente a las comunicaciones HTTP/REST entre cliente y servicios" y asume la sobrecarga
  de trazabilidad distribuida, sin que ningún trade-off del SAD recogiera esa tensión ni la
  midiera. Este spike y TO-09 la incorporan.
- **Ticket Jira:** pendiente de creación (Sprint 2)
- **Timebox:** 6 h
- **Responsable propuesto:** DevOps con Backend Lead
- **Sprint destino:** 2

## 1. Pregunta que responde

¿Cuánta latencia añade cada salto de red en los flujos que atraviesan más de un servicio
(Flutter → Java → .NET → Supabase), y es posible reconstruir un flujo completo con la
instrumentación de ADR-0006 tal como está definida hoy?

## 2. Hipótesis que se pone a prueba

Los flujos críticos del MVP atraviesan como máximo dos saltos de servicio, y el costo
agregado de red cabe dentro de los umbrales de QS-08 (< 1 s) y QS-14 (< 2 s).

## 3. Métrica y criterio de decisión

| Métrica | Umbral | Cómo se mide |
| --- | --- | --- |
| Saltos de servicio por flujo crítico | ≤ 2 | Traza de los flujos de RF-12, RF-13, RF-14 |
| Latencia añadida por salto (P95) | Se registra | Instrumentación de ADR-0006 sobre Railway |
| Latencia extremo a extremo del despacho | < 1 s (QS-08) | k6 desde el cliente |
| Flujos reconstruibles de extremo a extremo | 100 % | ¿Hay un `correlation-id` que sobreviva los tres servicios? |

Criterio de decisión: si un flujo crítico no es reconstruible extremo a extremo, ADR-0019
necesita una decisión complementaria sobre propagación de contexto de traza —hoy solo está
definida la propagación de tenant (ADR-0018, *token relay*), no la de traza.

## 4. Alcance

**Incluye:** los flujos del ciclo de servicio que cruzan Repo A, Repo B, Repo C y Supabase.

**No incluye:** el rendimiento interno de cada servicio (SP-TO-01 cubre la capa de datos) ni
el costo de hosting (SP-TO-11).

## 5. Método

1. Mapear qué servicios atraviesa cada flujo crítico del MVP, con evidencia de código.
2. Medir la latencia de cada salto con la instrumentación ya definida.
3. Intentar reconstruir una petición completa desde los tableros de observabilidad. Si no
   se puede, ese es el resultado del spike.

## 6. Qué desbloquea

- Incorpora al SAD la tensión que ADR-0019 declaró y §6 no recogía.
- Determina si hace falta un ADR de trazabilidad distribuida (`correlation-id`) como
  complemento de ADR-0018.

## 7. Riesgo si no se ejecuta

El estilo distribuido es un *killer* no negociable del proyecto: no se puede revertir. Lo
único gobernable es su costo, y hoy no está medido ni declarado en §6.

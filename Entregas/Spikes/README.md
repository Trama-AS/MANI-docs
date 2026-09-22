# Spikes de evidencia de trade-offs (DOC-14)

Cada trade-off del SAD §6 declara una tensión entre escenarios de calidad y una decisión
tomada sobre esa tensión. DOC-14 exige que esa decisión cite la evidencia que la respalda.

Al abrir DOC-14, de los ocho trade-offs vigentes **solo TO-03 tenía evidencia empírica**
(PoC-001, 2026-09-21). El resto se apoyaba en razonamiento documental o en nada. Estos
spikes son el trabajo que convierte cada afirmación en un dato medido.

Todos están **abiertos**: ninguno se ha ejecutado. Lo que está listo es la pregunta, la
métrica, el umbral y la decisión que cada uno desbloquea.

| Spike | Trade-off | Decisión afectada | Timebox | Estado |
| --- | --- | --- | --- | --- |
| [SP-TO-01](SP-TO-01-overhead-rls-busqueda.md) | TO-01 | ADR-0012 | 6 h | Abierto |
| [SP-TO-02](SP-TO-02-combinatoria-configuracion-aislamiento.md) | TO-02 | ADR-0012, ADR-0014 | 4 h | Abierto |
| [SP-TO-03](SP-TO-03-saturacion-y-cola-de-reintento.md) | TO-03 (residual) | ADR-0021, ADR-0016 | 8 h | Abierto |
| [SP-TO-04](SP-TO-04-huella-agentes-observabilidad.md) | TO-04 | ADR-0006 | 5 h | Abierto |
| [SP-TO-05](SP-TO-05-crecimiento-suite-costo-ci.md) | TO-05, TO-08 | ADR-0015, ADR-0014 | 4 h | Abierto |
| [SP-TO-06](SP-TO-06-autorizacion-canal-realtime.md) | TO-06 | ADR-0017, ADR-0012 | 6 h | Abierto |
| [SP-TO-07](SP-TO-07-aprendizaje-admin-tenant.md) | TO-07 | ninguna (sin ADR) | 6 h | Abierto |
| [SP-TO-09](SP-TO-09-latencia-estilo-distribuido.md) | TO-09 (nuevo) | ADR-0019 | 6 h | Abierto |
| [SP-TO-10](SP-TO-10-costo-de-salida-supabase-auth.md) | TO-10 (nuevo) | ADR-0022, ADR-0012, ADR-0018 | 4 h | Abierto |
| [SP-TO-11](SP-TO-11-techo-de-escala-railway.md) | TO-11 (nuevo) | ADR-0023, ADR-0004, ADR-0006 | 5 h | Abierto |
| [SP-TO-12](SP-TO-12-sincronizacion-artefactos-visuales.md) | TO-12 (nuevo) | ADR-0020, ADR-0024 | 3 h | Abierto |

Total: **57 h** de timebox. No caben en un sprint: la Mesa debe priorizar (ver
`Project/DOC-14-mesa-arquitectura-2026-09-22.md`).

## Por qué no hay SP-TO-08

TO-08 (verificabilidad vs. capacidad de CI) y TO-05 (adaptabilidad vs. verificabilidad)
tocan la misma decisión, ADR-0015, y se miden con la misma corrida. SP-TO-05 los cubre a
ambos. La numeración se conserva alineada con los trade-offs para que ningún ID quede
huérfano.

## Relación con PoC-001

PoC-001 no es un spike: es la validación empírica de una decisión ya redactada (ADR-0021).
Un spike responde una pregunta abierta **antes** de decidir; una PoC verifica una decisión
ya tomada. SP-TO-03 existe porque PoC-001 dejó un residual explícito fuera de su alcance.

Los hallazgos metodológicos de PoC-001 (Anexo A) son de obligada lectura antes de ejecutar
cualquiera de estos spikes que implique carga o autenticación:

- **H-03** — Supabase Auth limita el login (`429` hacia la petición 30 en 5 min por IP). Hay
  que provisionar credenciales **antes** de la ventana medida. Aplica a SP-TO-01, SP-TO-03,
  SP-TO-05, SP-TO-06, SP-TO-11.
- **H-04** — El pool de PostgREST acota la concurrencia efectiva, no `max_connections`. Un N
  alto no produce más concurrencia, produce más cola. Aplica a SP-TO-01, SP-TO-03, SP-TO-11.
- **H-05** — La ventana de medición debe superar la dispersión real de llegada, y las
  variantes comparadas deben correr con la misma alineación.
- **H-01** — Un control negativo que no puede fallar no valida nada. Todo spike que mida
  concurrencia necesita uno que demuestre que la carga se solapa de verdad.

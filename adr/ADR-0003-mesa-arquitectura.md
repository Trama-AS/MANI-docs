# ADR-0003 — Gobierno mediante Mesa de Arquitectura

- **Estado:** Aceptado
- **Decisión de:** gobierno técnico

## Contexto

Las decisiones arquitectónicas afectan múltiples módulos y no deben quedar concentradas en una sola persona ni registradas de forma informal.

## Alternativas

1. **Arquitecto único permanente.** Descartada por concentración de conocimiento y autoridad.
2. **Decisiones informales sin ADR.** Descartada por falta de trazabilidad.
3. **Mesa de Arquitectura con responsabilidad transversal.** Elegida.

## Decisión

Las decisiones técnicas costosas de revertir se discuten en la **Mesa de Arquitectura** y se registran mediante ADR. La responsabilidad arquitectónica es transversal al equipo técnico.

Cada ADR debe:
- evaluar alternativas reales;
- expresar una decisión inequívoca;
- documentar consecuencias;
- tener autor y revisor distintos cuando aplique.

## Justificación

Distribuye conocimiento y permite reconstruir por qué se tomó cada decisión.

## Consecuencias

### Positivas
- Decisiones trazables y defendibles.
- Menor dependencia de una sola persona.

### Negativas
- Requiere disciplina y tiempo de revisión.

## Condición de revisión

Revisar si cambia el modelo de gobierno técnico del proyecto.

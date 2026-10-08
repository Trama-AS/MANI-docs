# ADR-0011 — Modelo de cobertura geográfica por zonas

- **Estado:** Aceptado
- **Decisión de:** dominio y datos
- **Relacionado con:** REST-01, RF-07, RF-12, RNF-09

## Contexto

MANI debe determinar qué aliados pueden atender un sitio sin usar radio geográfico ni geolocalización en tiempo real.

## Alternativas

1. **Radio de cobertura.** Descartada por incumplir REST-01.
2. **Polígonos/geometría libre.** Descartada por complejidad no requerida en el MVP.
3. **Catálogo administrativo de zonas.** Elegida.

## Decisión

La cobertura de un aliado se modela como una relación entre el aliado y zonas de un catálogo jerárquico:

`ciudad → localidad/comuna → barrio`

En el MVP la granularidad operativa es **localidad/comuna**.

El catálogo de zonas es global de plataforma; la cobertura declarada por cada aliado pertenece al tenant. Las zonas se desactivan, no se eliminan.

Un sitio solo puede originar una solicitud si tiene una zona asignada.

## Justificación

El match por identificador es simple, auditable y coherente con el requisito de negocio.

## Consecuencias

### Positivas
- Consulta de elegibilidad simple.
- No requiere motor geoespacial.

### Negativas
- No soporta cobertura parcial de una localidad en el MVP.

## Condición de revisión

Reabrir si se exige distancia, rutas, geometría o precisión inferior a localidad/comuna.

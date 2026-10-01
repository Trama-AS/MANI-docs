# ADR-0001 — Gestión documental del proyecto

- **Estado:** Aceptado
- **Decisión de:** gobierno documental
- **Relacionado con:** ADR-0008

## Contexto

MANI necesita una fuente de verdad clara para documentación técnica y documentos formales, evitando duplicidad entre GitHub, OneDrive y otras herramientas.

## Alternativas

1. **Todo en OneDrive.** Descartada porque la documentación técnica pierde trazabilidad junto al código.
2. **Todo en GitHub.** Descartada porque actas y documentos administrativos no requieren versionado técnico.
3. **Separación GitHub/OneDrive.** Elegida.

## Decisión

La documentación técnica oficial vive en GitHub, dentro de `MANI-Docs`; OneDrive se reserva para documentación formal, administrativa y académica.

En `MANI-Docs` deben vivir como mínimo:
- `SDD.md`;
- `SAD_MANI.md`;
- `MANI_Modelo_de_Datos.md`;
- `/adr/`;
- `/diagramas/`;
- guías técnicas versionables.

## Justificación

Favorece trazabilidad, revisión por Pull Request y consistencia entre arquitectura y código, sin forzar documentos administrativos a un flujo Git.

## Consecuencias

### Positivas
- Una fuente técnica oficial y versionada.
- Revisión de cambios mediante PR.

### Negativas
- Exige disciplina para no mantener copias técnicas divergentes en OneDrive.

## Condición de revisión

Revisar si la organización adopta un repositorio documental único con control de versiones equivalente.

## Trazabilidad

- SDD: documentación y gobierno.
- Sustituye funcionalmente a ADR-0007.

# ADR-0008 — Organización y versionado de diagramas técnicos

- **Estado:** Aceptado
- **Decisión de:** documentación técnica
- **Relacionado con:** ADR-0001

## Contexto

Los diagramas deben ser localizables, versionables y coherentes con la documentación arquitectónica vigente.

## Alternativas

1. **Solo herramientas externas.** Descartada por falta de respaldo versionado.
2. **Imágenes sueltas sin fuente editable.** Descartada por baja mantenibilidad.
3. **Fuentes y exportaciones dentro de `MANI-Docs`.** Elegida.

## Decisión

Los diagramas oficiales se almacenan en:

```text
docs/diagramas/
├── c4/
│   ├── contexto/
│   ├── contenedores/
│   ├── componentes/
│   └── codigo/
├── datos/
├── despliegue/
└── flujos/
```

Cuando sea viable se conserva una fuente versionable, por ejemplo Mermaid o Draw.io, además de la exportación utilizada en entregas.

## Justificación

Permite revisar cambios y mantener alineados SAD, SDD y diagramas.

## Consecuencias

### Positivas
- Fuente editable y exportación oficial.
- C4 L1-L4 organizados de forma explícita.

### Negativas
- Requiere actualizar fuente y exportación cuando cambia un diagrama.

## Condición de revisión

Revisar si se adopta una herramienta única que genere automáticamente los artefactos versionados.

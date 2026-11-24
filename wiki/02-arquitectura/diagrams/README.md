# Diagramas de MANI

Estructura definida por [ADR-0008 — Organización y versionado de diagramas técnicos](../adr/ADR-0008-diagramacion-tecnica.md).

```text
diagrams/
├── c4/
│   ├── workspace.dsl        fuente editable del modelo C4 (Structurizr DSL)
│   ├── contexto/            C4 N1, panorama y diagrama de alto nivel
│   ├── contenedores/        C4 N2
│   ├── componentes/         C4 N3
│   └── codigo/              C4 N4 (aceptación concurrente)
├── datos/                   modelo de datos
├── despliegue/              topología de despliegue e infraestructura
└── flujos/                  secuencias por historia
    └── dinamicos/           vistas dinámicas C4
```

## Fuente editable y exportación

| Artefacto | Fuente versionada | Exportación |
|---|---|---|
| Vistas C4 (N1–N3, dinámicas, despliegue) | [`c4/workspace.dsl`](c4/workspace.dsl), Structurizr DSL | PNG en `c4/`, `despliegue/` y `flujos/dinamicos/` |
| Código (N4) | [`c4/codigo/aceptacion-concurrente.puml`](c4/codigo/aceptacion-concurrente.puml) | PNG en la misma carpeta |
| Diagramas de alto nivel del SAD | dibujados a mano (SAD §4.2) | `c4/contexto/alto-nivel-arquitectura.png`, `despliegue/infraestructura.png` |
| Secuencias por historia | herramienta de secuencias | `flujos/secuencia-*.jpeg` |
| Secuencias de los flujos críticos | PlantUML en SDD §21 | — |
| Modelo de datos | [`ModeloDatos.md`](../ModeloDatos.md) define tablas y DDL | `datos/ModeloDatos.png` |

El DSL manda: un diagrama C4 no se edita en la imagen, se cambia en el modelo y se vuelve a exportar. Si una imagen contradice al texto del [SDD](../SDD.md), manda el texto.

Para regenerar las imágenes desde el DSL: `docker run -p 8080:8080 -v diagrams/c4:/usr/local/structurizr structurizr/structurizr local` y, para cada vista, `structurizr.scripting.exportCurrentDiagramToPNG({ includeMetadata: true, crop: false })` desde el navegador, en modo claro. El renderizador PlantUML recorta a 4096 px por defecto: antes de exportar, `export PLANTUML_LIMIT_SIZE=16384`.

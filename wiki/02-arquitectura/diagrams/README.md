# Diagramas de MANI

Estructura definida por [ADR-0008 — Organización y versionado de diagramas técnicos](../adr/ADR-0008-diagramacion-tecnica.md).

```text
diagrams/
├── AltoNivel/
│   ├── MANI_Arquitectura_SaaS_Multi-Tenant.png   arquitectura de alto nivel del SAD
│   ├── MANI_Despliegue_e_Infraestructura.png     despliegue e infraestructura del SAD
│   └── actualizados/        vistas adicionales (PNG, SVG y PDF)
├── c4/
│   ├── workspace.dsl        fuente editable del modelo C4 (Structurizr DSL)
│   ├── contexto/            C4 N1 y panorama
│   ├── contenedores/        C4 N2
│   ├── componentes/         C4 N3
│   ├── codigo/              C4 N4 (aceptación en Dispatch)
│   └── despliegue/          vista de despliegue de producción
├── datos/                   modelo de datos
└── flujos/                  vistas dinámicas C4
```

## Fuente editable y exportación

| Artefacto | Fuente versionada | Exportación |
|---|---|---|
| Diagramas de alto nivel del SAD | [`AltoNivel/actualizados/generar_diagramas.py`](AltoNivel/actualizados/generar_diagramas.py) | PNG, SVG y PDF en [`AltoNivel/actualizados/`](AltoNivel/actualizados/) |
| Vistas C4 (N1 a N3, dinámicas y despliegue) | [`c4/workspace.dsl`](c4/workspace.dsl), Structurizr DSL | PNG en `c4/` y `flujos/` |
| Código (N4) | dibujado a mano desde el código de `MANI-.NET` | PNG en `c4/codigo/` |
| Modelo de datos | [`ModeloDatos.puml`](datos/ModeloDatos.puml), generado desde la base | [`ModeloDatos.png`](datos/ModeloDatos.png) |

El DSL manda: un diagrama C4 no se edita en la imagen, se cambia en el modelo y se vuelve a exportar. Si una imagen contradice al texto del [SDD](../SDD.md), manda el texto.

Para regenerar las vistas C4: `structurizr export -workspace workspace.dsl -format plantuml/structurizr` y renderizar cada `.puml` con PlantUML, con `PLANTUML_LIMIT_SIZE=16384` para que no recorte las imágenes anchas.

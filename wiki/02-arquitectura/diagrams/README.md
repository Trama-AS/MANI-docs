# Diagramas de MANI

Estructura definida por [ADR-0008 — Organización y versionado de diagramas técnicos](../adr/ADR-0008-diagramacion-tecnica.md).

```text
diagrams/
├── c4/
│   ├── workspace.dsl        fuente editable del modelo C4 (Structurizr DSL)
│   ├── contexto/            C4 N1 y panorama
│   ├── contenedores/        C4 N2
│   ├── componentes/         C4 N3
│   └── codigo/              C4 N4 — sin diagramas por ahora
├── datos/                   modelo de datos
├── despliegue/              topología de despliegue e infraestructura
├── flujos/                  flujos de negocio en texto
│   └── dinamicos/           vistas dinámicas C4 y secuencias por historia
├── MOCKUPS/                 fuera del alcance de ADR-0008 (ver abajo)
└── TechRadar.png            fuera del alcance de ADR-0008 (ver abajo)
```

## Fuente editable y exportación

ADR-0008 exige conservar una fuente versionable además de la exportación usada en entregas.

| Artefacto | Fuente versionada | Exportación |
|---|---|---|
| Vistas C4 (N1–N3, dinámicas, despliegue) | [`c4/workspace.dsl`](c4/workspace.dsl) — Structurizr DSL, se edita en el playground de C4 model | PNG en `c4/`, `despliegue/` y `flujos/dinamicos/` |
| Flujos de negocio | los `.txt` de [`flujos/`](flujos/) son la fuente | — |
| DHL de arquitectura e infraestructura | dibujados a mano, sin fuente DSL (SAD §4.2) | `c4/contexto/alto-nivel-arquitectura.png`, `despliegue/infraestructura.png` |
| Secuencias por historia | exportadas desde la herramienta de secuencias | `flujos/dinamicos/secuencia-*.jpeg` |
| Modelo de datos | `architecture/ModeloDatos.md` define tablas y DDL | `datos/ModeloDatos.png` |

El DSL manda: un diagrama C4 no se edita en la imagen, se cambia en el modelo y se vuelve a exportar.

> ⚠️ Las exportaciones PNG de las vistas C4 están desactualizadas respecto al `workspace.dsl` vigente, salvo `panorama`, `contexto` y `contenedores`, regeneradas desde el DSL el 2026-10-19 al agregar la landing (SCRUM-1348). Mientras no se regeneren las demás, manda el DSL y manda el texto del SDD. Ver SDD §4.0.
>
> Cómo se regeneraron, para repetirlo: `docker run -p 8080:8080 -v diagrams/c4:/usr/local/structurizr structurizr/structurizr local` (Structurizr Lite ya no se mantiene), y para cada vista `structurizr.scripting.exportCurrentDiagramToPNG({ includeMetadata: true, crop: false })` desde el navegador, en modo claro.

## Reubicaciones aplicadas (DOC-29 / SCRUM-1084)

La estructura previa era `HLD/` y `LLD/` — nombres heredados de `ALTO_NIVEL/` y `C4Model/`. Mapeo:

| Antes | Ahora | Criterio |
|---|---|---|
| `LLD/workspace.dsl` | `c4/workspace.dsl` | fuente del modelo C4 |
| `LLD/png/contexto.png` | `c4/contexto/contexto.png` | C4 N1 |
| `LLD/png/panorama.png` | `c4/contexto/panorama.png` | System Landscape, nivel de contexto |
| `HLD/DHL.png` | `c4/contexto/alto-nivel-arquitectura.png` | SAD §5 lo usa como vista de contexto C4 N1 |
| `LLD/png/contenedores.png` | `c4/contenedores/contenedores.png` | C4 N2 |
| `LLD/png/componentes-{core,dispatch,rules}.png` | `c4/componentes/` | C4 N3 |
| `ModeloDatos.png` | `datos/ModeloDatos.png` | datos |
| `LLD/png/despliegue-prod.png` | `despliegue/despliegue-prod.png` | despliegue |
| `HLD/Infra.png` | `despliegue/infraestructura.png` | SAD §16 lo usa como vista de despliegue |
| `LLD/png/dinamico-*.png` | `flujos/dinamicos/` | vistas dinámicas = flujos |
| `LLD/4.Dinamicos/*.jpeg` | `flujos/dinamicos/secuencia-*.jpeg` | secuencias = flujos; se renombraron a kebab-case sin espacios ni acentos porque los espacios rompen los enlaces Markdown |

Al verificar el contenido de las cinco secuencias apareció un archivo mal nombrado: `Aceptación de orden concurrente (Exclusión mutua).jpeg` no contenía ningún diagrama de exclusión mutua, sino una copia en 1600×1197 del mismo diagrama de cotización y despacho que ya estaba en 1190×896. Se conservó la versión de mayor resolución bajo el nombre correcto (`secuencia-cotizacion-y-despacho.jpeg`) y se eliminó la de menor resolución.

**Falta el diagrama de secuencia de exclusión mutua.** Existió como `Diagramas/diagrama_secuencia_exclusion_mutua.png` y se eliminó en la reestructuración V4 (`cc28e0c`). Se restauró únicamente como activo congelado de la Entrega 4 (`Entregas/Entrega4/img/`), no en esta estructura, porque documenta el mecanismo CAS descrito en SAD §8.2 de esa entrega. Si el flujo sigue vigente, hay que rehacerlo como vista del `workspace.dsl`.

### Retirados

Ocho archivos sin trackear eran copias byte-idénticas de archivos ya versionados (verificado con `cmp`), así que se eliminaron en lugar de duplicarlos en la estructura nueva: `HLD/DHL-ARQ.png`, `HLD/DHL-INFRA.png`, `LLD/2.panorama.png`, `LLD/1.Software/1.contexto.png`, `LLD/1.Software/2.contenedores.png` y los tres `LLD/1.Software/3.Componentes/componentes-*.png`. Cada uno tiene su equivalente en la tabla de arriba.

### Fuera del alcance de ADR-0008

ADR-0008 cubre diagramas de arquitectura: C4, datos, despliegue y flujos. Estos dos no son diagramas de arquitectura, así que se quedan fuera del árbol en lugar de forzarlos a una carpeta que no les corresponde:

- **`MOCKUPS/`** — mockups de interfaz exportados desde Figma. Los referencia el SAD §8.4.
- **`TechRadar.png`** — priorización tecnológica (adoptar / evaluar / descartar). Lo referencia [`TECH_RADAR.md`](../TECH_RADAR.md).

### Pendiente

`c4/codigo/` (C4 N4) está vacío: el proyecto no tiene diagramas de nivel código. El SDD §4.4 documenta ese nivel como texto. La carpeta se mantiene con un `.gitkeep` porque ADR-0008 la declara parte de la estructura.

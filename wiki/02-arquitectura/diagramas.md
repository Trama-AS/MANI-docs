# Diagramas

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SDD.md`](../../architecture/SDD.md) §4.0 — inventario oficial de vistas · [`diagrams/LLD/workspace.dsl`](../../diagrams/LLD/workspace.dsl) · [`adr/ADR-0008`](../../adr/ADR-0008-diagramacion-tecnica.md).

> El **inventario oficial** de diagramas, con el archivo y la sección que corresponde a cada vista,
> está en [`SDD.md`](../../architecture/SDD.md) §4.0. Esta página no lo duplica: explica la
> organización y cómo se regeneran.

## Organización de carpetas

| Carpeta | Qué contiene |
|---|---|
| [`diagrams/HLD/`](../../diagrams/HLD/) | vistas de alto nivel: landscape, infraestructura y Tech Radar |
| [`diagrams/LLD/workspace.dsl`](../../diagrams/LLD/workspace.dsl) | el modelo Structurizr: **la fuente** |
| [`diagrams/LLD/Software/`](../../diagrams/LLD/Software/) | vistas exportadas desde el modelo |

**El DSL es la fuente y el PNG es el resultado.** El modelo no se dibuja en Mermaid ni se edita en
la imagen: se cambia el DSL y se regenera.

Mermaid sí se usa para los diagramas embebidos en los documentos —el DER lógico y el modelo
dimensional de [`ModeloDatos.md`](../../architecture/ModeloDatos.md) §5 y §9–§10—, que no forman
parte del modelo de vistas.

## Las doce vistas del modelo

Declaradas en [`workspace.dsl`](../../diagrams/LLD/workspace.dsl):

| Clave de la vista | Tipo | Qué muestra |
|---|---|---|
| `landscape` | System Landscape | el panorama completo de actores y sistemas |
| `contexto` | C4 Nivel 1 | MANI, sus cuatro actores y los sistemas externos |
| `contenedores` | C4 Nivel 2 | Flutter, Gateway, los **tres** servicios, Supabase, CDC/ELT e integraciones |
| `componentes-rules` | C4 Nivel 3 | Rules Service (Java) |
| `componentes-dispatch` | C4 Nivel 3 | Dispatch Service (.NET), con el **Concurrency Guard** |
| `componentes-core` | C4 Nivel 3 | Core Service (Node.js), dominios de negocio |
| `componentes-availability` | C4 Nivel 3 | Core Service, módulo de disponibilidades |
| `secuencia-despacho` | Dinámica | aceptación concurrente y el `409` |
| `secuencia-cotizacion` | Dinámica | cotización y validación tarifaria |
| `secuencia-mensajeria` | Dinámica | mensajería por Realtime y push |
| `despliegue-qa` | Despliegue | VM de QA con Docker |
| `despliegue-prod` | Despliegue | VM productiva con Docker y Supabase productivo |

Las cuatro últimas filas de vistas dinámicas y `despliegue-qa` están **definidas en el modelo y
pendientes de exportar**: el SDD §4.6 y §9.1 describen el flujo en texto, así que los documentos se
leen sin la imagen.

El **Nivel 4 (Code)** no se modela en el DSL —Structurizr describe contenedores y componentes, no clases— y se mantiene en [`SDD.md`](../../architecture/SDD.md) §4.5.

## Cómo regenerar

```bash
# desde diagrams/LLD/
structurizr validate -w workspace.dsl               # comprueba el modelo antes de un PR
structurizr export -w workspace.dsl -f plantuml     # también: dot, websequencediagrams, json
```

Sin instalación local, la misma imagen oficial en contenedor:

```bash
docker run --rm -v "$PWD":/work -w /work structurizr/structurizr export -w workspace.dsl -f plantuml
```

Notas de uso comprobadas al crear el modelo:

- el DSL **no** declara `theme default`: ese tema se descarga de un servicio remoto, falla sin red y llega a su fin de vida; los estilos están definidos en el propio archivo;
- un cambio en el modelo se valida antes de abrir el PR, igual que cualquier otro artefacto versionado;
- las vistas exportadas van a `diagrams/LLD/Software/` con el nombre de su clave.

## Política

ADR-0008: los diagramas deben ser localizables, versionables y coherentes con la documentación arquitectónica vigente. Las herramientas concretas son parte del Tech Radar y pueden cambiar sin nueva decisión ([ADR-0020](../../adr/ADR-0020-herramientas-visuales.md), `Superseded`).

Un diagrama que contradiga al documento no se «interpreta»: se regenera. Si el DHL muestra un camino
que la arquitectura ya no admite —por ejemplo acceso directo de Flutter a datos—, el diagrama está
desactualizado, no el documento ([SAD §8.3](../../architecture/SAD.md)).

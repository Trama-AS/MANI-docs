# Diagramas

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [`diagrams/c4/workspace.dsl`](../../diagrams/c4/workspace.dsl) · [`adr/ADR-0008`](../../adr/ADR-0008-diagramacion-tecnica.md) · [`architecture/TECH_RADAR.md`](../../architecture/TECH_RADAR.md) · contenido de [`diagrams/`](../../diagrams/).

## Dos familias, cada una con su documento

| Familia | Fuente | Documento que la referencia |
|---|---|---|
| **C4** — panorama, contexto, contenedores, componentes, dinámicas y despliegue | [`diagrams/c4/workspace.dsl`](../../diagrams/c4/workspace.dsl) (Structurizr DSL), exportado a [`diagrams/c4/`](../../diagrams/c4/), [`diagrams/despliegue/`](../../diagrams/despliegue/) y [`diagrams/flujos/dinamicos/`](../../diagrams/flujos/dinamicos/) | [`SDD.md`](../../architecture/SDD.md) §4 y §9 |
| **DHL** — diagramas de alto nivel e infraestructura ilustrativa | [`diagrams/c4/contexto/alto-nivel-arquitectura.png`](../../diagrams/c4/contexto/alto-nivel-arquitectura.png), [`diagrams/despliegue/infraestructura.png`](../../diagrams/despliegue/infraestructura.png) y [`diagrams/TechRadar.png`](../../diagrams/TechRadar.png) (PNG) | [`SAD.md`](../../architecture/SAD.md) §5, §6 y §16 |

El modelo C4 **no se dibuja en Mermaid**: el DSL es la fuente y los documentos la referencian por nombre de vista.

> ⚠️ **Las imágenes exportadas están desactualizadas respecto al `workspace.dsl`.**
> Muestran `Availability Service` como contenedor propio y los nombres `MANI-Core-Node` y
> `MANI-Rules-Java`, que el modelo ya no usa. Cuatro están además recortadas por el borde derecho
> —`contenedores`, `componentes-rules`, `componentes-dispatch` y `dinamico-aceptacion`, las que
> miden exactamente 4096 px— por el límite `PLANTUML_LIMIT_SIZE` del renderizador.
>
> Hasta que se regeneren, manda el DSL y manda el texto del
> [`SDD.md`](../../architecture/SDD.md); el detalle está en su §4.0.

Aparte de las dos familias hay un tercer artefacto: [`architecture/SECUENCIAS.md`](../../architecture/SECUENCIAS.md), con los cinco flujos críticos en **PlantUML suelto**. No sustituye a las vistas dinámicas del DSL —esas mantienen la coherencia con el modelo— sino que añade lo que el C4 no expresa: dos actores compitiendo por la misma solicitud, ramas `alt` y respuestas de error como `409 Conflict`.

## Vistas C4 definidas

Declaradas en [`workspace.dsl`](../../diagrams/c4/workspace.dsl):

| Vista | Nivel C4 | Contenido | Imagen |
|---|---|---|---|
| `panorama` | Landscape | El mapa de sistemas: MANI como único sistema propio, sus cuatro actores y las plataformas externas de las que depende | [PNG](../../diagrams/c4/contexto/panorama.png) |
| `contexto` | 1 | MANI, sus cuatro actores y los sistemas externos | [PNG](../../diagrams/c4/contexto/contexto.png) |
| `contenedores` | 2 | Flutter, Gateway y los tres servicios agrupados por bloque —Java decide, .NET asigna, Node opera—, Supabase por dominio (Rules, Dispatch, Core) más Auth, Storage y Realtime, CDC/ELT e integraciones | [PNG](../../diagrams/c4/contenedores/contenedores.png) |
| `componentes-rules` | 3 | Rules Service (Java): controller, application service, estrategias, puerto y adaptador | [PNG](../../diagrams/c4/componentes/componentes-rules.png) |
| `componentes-dispatch` | 3 | Dispatch Service (.NET): selector, coordinador, **Concurrency Guard**, auditoría, puerto y adaptador | [PNG](../../diagrams/c4/componentes/componentes-dispatch.png) |
| `componentes-core` | 3 | Core Service (Node.js): usuarios/tenants, KYC, catálogo, **disponibilidad**, notificación, reportes, adaptadores externos | [PNG](../../diagrams/c4/componentes/componentes-core.png) |
| `dinamico-solicitud` | Dinámica | Solicitud y conformación del listado de aliados: el despacho pregunta elegibilidad a Core y el orden a Reglas (RF-12, RF-13) | [PNG](../../diagrams/flujos/dinamicos/dinamico-solicitud.png) |
| `dinamico-aceptacion` | Dinámica | Exclusión concurrente a nivel de componentes de Despacho: la primera aceptación gana, la segunda recibe `409 Conflict` (RF-14, RNF-05) | [PNG](../../diagrams/flujos/dinamicos/dinamico-aceptacion.png) |
| `dinamico-cotizacion` | Dinámica | Cotización en Core y validación contra el tarifario en Reglas (RF-15, RF-16, RF-22) | [PNG](../../diagrams/flujos/dinamicos/dinamico-cotizacion.png) |
| `dinamico-kyc` | Dinámica | Carga de documentos al bucket privado y aprobación por el administrador del tenant (RF-05, RF-06) | [PNG](../../diagrams/flujos/dinamicos/dinamico-kyc.png) |
| `dinamico-mensajeria` | Dinámica | Mensaje persistido, transportado por Realtime y notificado por push cuando el destinatario no está conectado (RF-20, RF-21) | [PNG](../../diagrams/flujos/dinamicos/dinamico-mensajeria.png) |
| `despliegue-prod` | Despliegue | Producción: borde con balanceo, clúster Kubernetes con 2..6 réplicas y secretos externos, Supabase por dominio, pipeline de CI/CD que promueve la imagen y observabilidad Prometheus/Grafana | [PNG](../../diagrams/despliegue/despliegue-prod.png) |

Las cuatro vistas del C4 que Structurizr puede describir están cubiertas: **panorama**, **estática** (contexto, contenedores, componentes), **dinámica** y **despliegue**. No hay vista por ambiente: Local, DEV y QA comparten la topología de producción y solo cambian escalado, secretos y datos ([`SDD.md`](../../architecture/SDD.md) §10).

El **Nivel 4 (Code)** no se modela en el DSL —Structurizr describe contenedores y componentes, no clases— y se mantiene en [`SDD.md`](../../architecture/SDD.md) §4.4.

## Cómo renderizar

```bash
# desde diagrams/c4/
export PLANTUML_LIMIT_SIZE=16384                    # si no, PlantUML recorta a 4096 px
structurizr validate -w workspace.dsl               # comprueba el modelo antes de un PR
structurizr export -w workspace.dsl -f plantuml     # también: dot, websequencediagrams, json
```

`validate` termina en 0 y sin salida cuando el modelo está bien.

Los PNG publicados se generaron desde ese PlantUML con el motor **Smetana**, que no necesita Graphviz instalado:

```bash
java -jar plantuml.jar -tpng -Playout=smetana structurizr-*.puml
```

Las vistas dinámicas llevan la propiedad `plantuml.sequenceDiagram` en el DSL y por eso se dibujan como diagramas de secuencia, que es como se lee un flujo.

Las imágenes publicadas viven en [`diagrams/c4/`](../../diagrams/c4/), [`diagrams/despliegue/`](../../diagrams/despliegue/) y [`diagrams/flujos/dinamicos/`](../../diagrams/flujos/dinamicos/), y se regeneran cuando cambia el modelo: **el DSL es la fuente, el PNG es el resultado.**

**`PLANTUML_LIMIT_SIZE` no es opcional.** Su valor por defecto, 4096 px, no escala el diagrama: lo
**corta**. Es lo que dejó cuatro de las vistas actuales con nodos partidos por el borde derecho.

Sin instalación local, la misma imagen oficial en contenedor:

```bash
docker run --rm -v "$PWD":/work -w /work structurizr/structurizr export -w workspace.dsl -f plantuml
```

Notas de uso comprobadas al crear el modelo:

- el DSL **no** declara `theme default`: ese tema se descarga de un servicio remoto, falla sin red y llega a su fin de vida; los estilos están definidos en el propio archivo;
- las llamadas entre servicios se declaran **una sola vez**, entre componentes: Structurizr las propaga solo al nivel de contenedor y declararlas también ahí es una relación duplicada que hace fallar `validate`;
- las vistas dinámicas solo pueden usar relaciones que ya existen en el modelo: si un paso no valida, falta la relación, no la vista;
- un cambio en el modelo se valida antes de abrir el PR, igual que cualquier otro artefacto versionado.

## Diagramas de alto nivel (DHL)

| Archivo | Contenido | Referenciado en |
|---|---|---|
| [`DHL.png`](../../diagrams/c4/contexto/alto-nivel-arquitectura.png) | Diagrama de alto nivel de la solución | SAD §5 y §6 |
| [`Infra.png`](../../diagrams/despliegue/infraestructura.png) | Vista de infraestructura | SAD §16, SDD §9.1 |
| [`TechRadar.png`](../../diagrams/TechRadar.png) | Tech Radar en imagen | Encabezado del SAD |

El DHL muestra acceso directo de Flutter a Supabase para disponibilidades. **Eso ya no es la arquitectura:** el único acceso del cliente a Supabase es Auth y Realtime ([Acceso del cliente a Supabase](estilo-y-contenedores.md#acceso-del-cliente-a-supabase), SAD §8.3, SDD §2.2). La imagen está desactualizada y hay que regenerarla; manda el documento, no el dibujo.

## Galería

### Vistas C4 — fuente: [`workspace.dsl`](../../diagrams/c4/workspace.dsl)

**Nivel 1 — Contexto**

<a href="../../diagrams/c4/contexto/contexto.png"><img src="../../diagrams/c4/contexto/contexto.png" alt="C4 Nivel 1 — contexto: MANI, sus actores y los sistemas externos" width="760"></a>

**Nivel 2 — Contenedores**

<a href="../../diagrams/c4/contenedores/contenedores.png"><img src="../../diagrams/c4/contenedores/contenedores.png" alt="C4 Nivel 2 — contenedores: Flutter, Gateway, los cuatro servicios, Supabase e integraciones" width="760"></a>

**Nivel 3 — Componentes por servicio**

<a href="../../diagrams/c4/componentes/componentes-rules.png"><img src="../../diagrams/c4/componentes/componentes-rules.png" alt="C4 Nivel 3 — Rules Service en Java" width="620"></a>

<a href="../../diagrams/c4/componentes/componentes-dispatch.png"><img src="../../diagrams/c4/componentes/componentes-dispatch.png" alt="C4 Nivel 3 — Dispatch Service en .NET" width="620"></a>

<a href="../../diagrams/c4/componentes/componentes-core.png"><img src="../../diagrams/c4/componentes/componentes-core.png" alt="C4 Nivel 3 — Core Service en Node.js" width="620"></a>

**Despliegue — producción**

<a href="../../diagrams/despliegue/despliegue-prod.png"><img src="../../diagrams/despliegue/despliegue-prod.png" alt="Vista de despliegue de producción: borde con balanceo, clúster Kubernetes, Supabase por dominio, CI/CD y observabilidad" width="760"></a>

**Panorama — System Landscape**

<a href="../../diagrams/c4/contexto/panorama.png"><img src="../../diagrams/c4/contexto/panorama.png" alt="Panorama de sistemas: MANI como único sistema propio y las plataformas externas" width="760"></a>

**Vistas dinámicas**

<a href="../../diagrams/flujos/dinamicos/dinamico-solicitud.png"><img src="../../diagrams/flujos/dinamicos/dinamico-solicitud.png" alt="Vista dinámica — solicitud y listado de aliados" width="760"></a>

<a href="../../diagrams/flujos/dinamicos/dinamico-aceptacion.png"><img src="../../diagrams/flujos/dinamicos/dinamico-aceptacion.png" alt="Vista dinámica — aceptación concurrente y 409 Conflict" width="760"></a>

<a href="../../diagrams/flujos/dinamicos/dinamico-cotizacion.png"><img src="../../diagrams/flujos/dinamicos/dinamico-cotizacion.png" alt="Vista dinámica — cotización y validación contra el tarifario" width="760"></a>

<a href="../../diagrams/flujos/dinamicos/dinamico-kyc.png"><img src="../../diagrams/flujos/dinamicos/dinamico-kyc.png" alt="Vista dinámica — carga y verificación de documentos KYC" width="760"></a>

<a href="../../diagrams/flujos/dinamicos/dinamico-mensajeria.png"><img src="../../diagrams/flujos/dinamicos/dinamico-mensajeria.png" alt="Vista dinámica — mensajería con notificación de respaldo" width="760"></a>

### Diagramas de alto nivel (DHL) — los referencia el [`SAD.md`](../../architecture/SAD.md)

<a href="../../diagrams/c4/contexto/alto-nivel-arquitectura.png"><img src="../../diagrams/c4/contexto/alto-nivel-arquitectura.png" alt="Diagrama de alto nivel de MANI" width="760"></a>

<a href="../../diagrams/despliegue/infraestructura.png"><img src="../../diagrams/despliegue/infraestructura.png" alt="Vista de alto nivel de la infraestructura de MANI" width="760"></a>

<a href="../../diagrams/TechRadar.png"><img src="../../diagrams/TechRadar.png" alt="Tech Radar de MANI" width="620"></a>

## Política

ADR-0008: los diagramas deben ser localizables, versionables y coherentes con la documentación arquitectónica vigente. Las herramientas concretas son parte del Tech Radar y pueden cambiar sin nueva decisión ([ADR-0020](../../adr/ADR-0020-herramientas-visuales.md), `Superseded`).

Otros diagramas del proyecto: el DER lógico y el modelo dimensional viven en [`architecture/ModeloDatos.md`](../../architecture/ModeloDatos.md) §5 y §9–§10.

# Multi-repo

[← 04 · Repositorios](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §4 · [`architecture/SAD.md`](../../architecture/SAD.md) §17 · [`architecture/SDD.md`](../../architecture/SDD.md) §13 · [`adr/ADR-0004`](../../adr/ADR-0004-cicd-multirepo-ambientes.md) · [`adr/ADR-0023`](../../adr/ADR-0023-consolidacion-repositorios-ambientes.md).

MANI adopta estrategia **multi-repo**: cada unidad desplegable mantiene ciclo técnico independiente.

## Los seis repositorios

Estos nombres son los únicos válidos. No hay variantes.

| Repositorio | Tecnología | Responsabilidad principal |
|---|---|---|
| `MANI-Frontend` | Flutter / Dart | Cliente web y móvil |
| `MANI-API-Gateway` | NGINX | Punto de entrada y enrutamiento de APIs |
| `MANI-Rules-Service` | Java | Reglas de negocio por tenant |
| `MANI-Dispatch-Service` | .NET | Solicitudes, despacho y asignación |
| `MANI-Core-Service` | Node.js | Servicios core y disponibilidades |
| `MANI-Docs` | Markdown / diagramas / ADR | Documentación arquitectónica y técnica ← **este repositorio** |

Cinco son desplegables. `MANI-Docs` mantiene SRS, SAD, SDD, ADR, modelo de datos, políticas,
infraestructura y diagramas: **no contiene código desplegable**.

Cada repositorio desplegable mantiene de forma independiente: código · dependencias · pruebas · `Dockerfile` · pipeline · configuración de build · versionamiento · artefactos · documentación técnica inmediata.

### Dos repositorios que ya no existen

[ADR-0023](../../adr/ADR-0023-consolidacion-repositorios-ambientes.md) los retiró:

- **`MANI-Availability`** — la cobertura y la disponibilidad son un dominio del
  `MANI-Core-Service`: un componente entre los demás y sus tablas en el esquema `core`. No tienen
  desplegable, esquema ni vista propios. Su único consumidor es Dispatch, que consulta la
  elegibilidad por la Core API.
- **`MANI-Infra`** — su contenido vive en `MANI-API-Gateway`, que es la raíz de composición del
  despliegue: configuración de NGINX, Compose por ambiente y configuración de observabilidad.

Si encuentras una referencia a `MANI-Flutter`, `MANI-Gateway`, `MANI-APIGateway`, `MANI-Node`,
`MANI-Core-Node`, `MANI-Rules-Java`, `MANI-Dispatch-DotNet`, `MANI-Availability` o `MANI-Infra`,
es un nombre muerto: corrígelo contra la tabla de arriba.

## Consecuencias prácticas

- Un cambio que cruza repositorios se parte en un PR por repositorio, cada uno con su referencia Jira.
- Un contrato compartido (OpenAPI entre Gateway y servicios) se acuerda antes de implementar: es la tarea `CFG-16` del backlog.
- Crear los repositorios que faltan del modelo es `CFG-15`; replicar el pipeline en cada uno es `CFG-29`.
- Los artefactos de infraestructura (`database/`, `docker-compose.yml`, `scripts/`, `nginx.conf`) deben salir del repositorio Flutter hacia su repositorio dueño: tarea `CFG-33`.
- Renombrar los repositorios rompe remotos de git, workflows, URLs de imágenes en GHCR y enlaces en
  Jira. Es trabajo mecánico, pero hay que hacerlo de una vez (ADR-0023, consecuencias).

## Estado real a tener en cuenta

Backlog §3, verificado sobre `MANI-Frontend`:

- `main` contiene sólo el scaffold por defecto de Flutter; **el producto vive en `develop` y `release`**;
- hay 13 ramas `feature`/`fix` con trabajo sin fusionar, que deben reconciliarse antes de migrar (`CFG-37`, `CFG-38`);
- la lógica de negocio está repartida entre el cliente y ~32 funciones PL/pgSQL bajo `database/`. [ADR-0022](../../adr/ADR-0022-logica-de-negocio-en-servicios.md) decide migrarla a los servicios: las historias `-M2` **reimplementan**, no invocan la función.

Quien vaya a trabajar en ese repositorio revisa primero [Orden de ejecución](../06-backlog/orden-de-ejecucion.md).

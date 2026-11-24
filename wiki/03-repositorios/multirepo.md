# Multi-repo

[← 03 · Repositorios](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md) §4 · [`architecture/SAD.md`](../02-arquitectura/SAD.md) §17 · [`architecture/SDD.md`](../02-arquitectura/SDD.md) §13 · [`adr/ADR-0004`](../02-arquitectura/adr/ADR-0004-cicd-multirepo-ambientes.md).

| Campo | Valor |
|---|---|
| **Finalidad** | Mapa de los repositorios de MANI: cómo se llama cada uno en GitHub, qué responsabilidad tiene y si su README dice cómo levantarlo, probarlo y desplegarlo |
| **Mantiene** | Responsable de la carpeta 03 (Juan Sebastián Álvarez) |
| **Consume** | Todo el equipo; en especial quien entra nuevo o abre un cambio que cruza repositorios |
| **Cada cuánto se actualiza** | Cuando se crea, renombra o archiva un repositorio, o cuando cambia su README |
| **Versión y fecha** | 2.0 · 2026-11-23 ([SCRUM-1693](https://maniservices.atlassian.net/browse/SCRUM-1693)) |
| **Origen y destino** | ADR-0004 (multi-repo) y ADR-0028 (nombres) → esta página → [Ramas, flujo y protección](ramas-flujo-y-proteccion.md) |

MANI adopta estrategia **multi-repo**: cada unidad desplegable mantiene ciclo técnico independiente.

## Mapa de los 6 repositorios

Nombres reales en la organización `Trama-AS` de GitHub, verificados el 2026-11-23. Son los que se usan en `git clone`, en los PR y en los pipelines.

| # | Repositorio en GitHub | Nombre en ADR-0028 | Tecnología | Responsabilidad | Se despliega |
|---|---|---|---|---|---|
| 1 | [`MANI-docs`](https://github.com/Trama-AS/MANI-docs) | `MANI-Docs` | Markdown, diagramas, ADR | Documentación: SRS, SAD, SDD, ADR, modelo de datos, políticas, infraestructura y esta wiki. **Sin código desplegable** | No |
| 2 | [`MANI-Node`](https://github.com/Trama-AS/MANI-Node) | `MANI-Core-Service` | Node.js | Core: identidad, tenants, catálogo, clientes, aliados, solicitudes, pagos, cobertura y disponibilidad. **Dueño único de las migraciones** (ADR-0030) | Sí |
| 3 | [`MANI-Flutter`](https://github.com/Trama-AS/MANI-Flutter) | `MANI-Frontend` | Flutter / Dart | Cliente web y móvil; solo capa de presentación, consume todo por el Gateway | Sí |
| 4 | [`MANI-.NET`](https://github.com/Trama-AS/MANI-.NET) | `MANI-Dispatch-Service` | .NET 8 | Despacho y emparejamiento: elegibles, ofertas, aceptación con exclusión concurrente (409) | Sí |
| 5 | [`MANI-Java`](https://github.com/Trama-AS/MANI-Java) | `MANI-Rules-Service` | Java 17 / Spring Boot | Motor de reglas: categorías, tarifas, ranking de aliados y reglas operativas del tenant. No guarda datos | Sí |
| 6 | [`MANI-APIGateway`](https://github.com/Trama-AS/MANI-APIGateway) | `MANI-API-Gateway` | NGINX | Punto de entrada y enrutamiento (`/api/v1/core`, `/rules`, `/dispatch`); dueño de `monitoring/`, del Compose y del histórico `database/` | Sí |

`MANI-Landing` (página comercial, ADR-0028) vive fuera de estos seis y tiene su propio pipeline; no accede a datos ni al Gateway.

> **Discrepancia con ADR-0028.** El ADR fija los nombres de la segunda columna y dice que no hay otro válido; GitHub usa los de la primera. Mientras la Mesa de Arquitectura no decida renombrar los repositorios o enmendar el ADR, en comandos, PR y pipelines se usa el nombre de GitHub, y en prosa de arquitectura el del ADR («Core Service», «Rules Service»…). Esta tabla es la equivalencia.

## Estado de los README

Cada repositorio debe explicar en su README cómo **levantarlo**, **probarlo** y **desplegarlo**. Revisión del 2026-11-23 sobre `main`:

| Repositorio | Levantar en local | Probar | Desplegar a QA / PROD |
|---|---|---|---|
| `MANI-Node` | Sí (Node local y Docker) | Sí (`npm test`; CI con `npm run lint` y `npm test`) | **Falta**: solo Docker local |
| `MANI-Flutter` | Sí | Sí (formato, `flutter analyze`, `flutter test` con cobertura) | **Falta**: solo build local |
| `MANI-.NET` | Sí (.NET CLI y Docker) | Sí (`dotnet test`, con cobertura) | **Falta**: solo Docker local |
| `MANI-Java` | Sí (Maven y Docker) | **Falta** `mvn test` | **Falta**: solo Docker local |
| `MANI-APIGateway` | Sí (NGINX, imagen, Compose completo) | **Falta**: no menciona `tests/gateway/*.sh` ni Newman | Parcial: quién ejecuta las migraciones por ambiente |
| `MANI-docs` | No aplica | No aplica | No aplica |

El despliegue lo hace DevOps con los workflows de cada repositorio y la promoción de [Ambientes y promoción](../08-infraestructura/03-despliegue-y-rollback.md); lo que falta es que cada README lo enlace en una sección corta «Despliegue».

Nombres de ADR-0028 (ver la equivalencia con GitHub en el [mapa](#mapa-de-los-6-repositorios)):

```text
MANI-Frontend
MANI-API-Gateway  ← también es dueño de database/, scripts/, supabase/ y el Compose
MANI-Rules-Service
MANI-Dispatch-Service
MANI-Core-Service   ← incluye cobertura, disponibilidad y elegibilidad
MANI-Landing        ← página comercial pública; no accede a datos ni al Gateway
MANI-Docs           ← este repositorio
```

`MANI-Landing` es la entrada pública para quien aún no tiene sesión: redirige al login de
`MANI-Frontend` Web y tiene su propio pipeline. Su registro (propósito, imagen y ambientes) está
en [ADR-0028](../02-arquitectura/adr/ADR-0028-nombres-repositorios-y-ambientes.md) y su detalle técnico en
`MANI-Landing/docs/ARQUITECTURA_E_INTEGRACION.md`; esta página no lo repite.

`MANI-Infra` ya no existe: DevOps lo borró el 2026-10-06 y su alcance quedó repartido según la [enmienda de ADR-0004](../02-arquitectura/adr/ADR-0004-cicd-multirepo-ambientes.md).

`MANI-Availability` tampoco: la cobertura y la disponibilidad son un dominio del `MANI-Core-Service` ([ADR-0028](../02-arquitectura/adr/ADR-0028-nombres-repositorios-y-ambientes.md)). Los nombres de la lista son los únicos válidos.

Cada repositorio desplegable mantiene de forma independiente: código · dependencias · pruebas · `Dockerfile` · pipeline · configuración de build · versionamiento · artefactos · documentación técnica inmediata.

`MANI-Docs` mantiene SRS, SAD, SDD, ADR, modelo de datos, políticas, infraestructura y diagramas: **no contiene código desplegable**.

## Consecuencias prácticas

- Un cambio que cruza repositorios se parte en un PR por repositorio, cada uno con su referencia Jira.
- Un contrato compartido (OpenAPI entre Gateway y servicios) se acuerda antes de implementar: es la tarea `CFG-16` del backlog de transición.
- Crear los repositorios que faltan del modelo es `CFG-15`; replicar el pipeline en cada uno es `CFG-29`.
- Los artefactos de infraestructura salieron del repositorio Flutter (tarea `CFG-33`, SCRUM-1110): `database/`, `scripts/`, `supabase/` y el Compose pasan a `MANI-API-Gateway`; `nginx.conf` queda en `MANI-Frontend` como `docker/nginx-web.conf` porque sirve la SPA dentro de la imagen web. El responsable de las migraciones por ambiente es DevOps ([`INFRAESTRUCTURA_MANI.md`](../08-infraestructura/README.md) §15).

## Estado real a tener en cuenta (histórico, 2026-10-07)

> **Histórico.** Esta sección describe la reconciliación de ramas de `MANI-Frontend` (`MANI-Flutter`) de octubre; se conserva como registro, no se actualiza. El flujo vigente está en [Ramas, flujo y protección](ramas-flujo-y-proteccion.md).

Verificado sobre `MANI-Frontend` el 2026-10-07 (`CFG-38`, SCRUM-1097):

- **`develop` es la base única de código**: `main` y `release` están contenidos en `develop` (no tienen commits propios);
- las 13 ramas `feature`/`fix` que señalaba el Backlog V4 §3 quedaron reconciliadas: todas están fusionadas en `develop` o fueron reemplazadas por un PR posterior (detalle abajo). No queda trabajo sin fusionar;
- la lógica de negocio está en ~32 funciones PL/pgSQL bajo `database/` (hoy en `MANI-API-Gateway`, antes en `MANI-Frontend`), no en el cliente.

### Reconciliación de ramas de MANI-Frontend (CFG-38)

| Rama / PR | Commits fuera de `develop` | Dictamen |
|---|---|---|
| `feature/SCRUM-1060-registro-empresa-gateway` (#33) | 0 | Fusionada; borrada del remoto el 2026-10-07 |
| `feature/SCRUM-1061-auth-remote-gateway` (#34) | 0 | Fusionada; borrada del remoto el 2026-10-07 |
| `feature/SCRUM-1111-capa-http-gateway` (#33) | 0 | Fusionada; borrada del remoto el 2026-10-07 |
| `feature/SCRUM-1114-trazabilidad-jira-github` (#32) | 0 | Fusionada; borrada del remoto el 2026-10-07 |
| #11, #12, #13 (`develop` → `main` / `Feature-RegisterAndLogin`) | 0 | Sin trabajo pendiente; descartados |
| #15 `feature/SCRUM-927-poc-cobertura-geografica` | 0 (parches equivalentes en `develop`) | Reemplazado por #16 |
| #2 `feature/SCRUM-923-pipeline-pruebas-automatizadas` | 7 | Reemplazado por #4 (SCRUM-955), #21 (asignación en arquitectura limpia) y los workflows actuales |
| #10 `feature/us-03-1-3-categorias-aliado` | 1 | Reemplazado por #19 (`categorias-aliado-clean`) |
| #17 `feature/us-03-1-3-categorias-aliado-v2` | 2 | Reemplazado por #19; `categories_local_datasource.dart` no pasó a `develop` (pendiente de confirmar con la autora) |

Las ramas nuevas de MANI-Frontend salen de `develop` y vuelven a `develop` por PR (ver [Git: ramas y commits](../04-proceso/git-ramas-y-commits.md)).

Quien vaya a trabajar en ese repositorio revisa primero [Backlog §10.5](../05-backlog/BACKLOG_MANI.md#105-orden-en-que-se-ejecutó-la-transición).

## Historial

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.0 | 2026-10-07 | Modelo multi-repo y reconciliación de ramas de MANI-Frontend (CFG-38) | — |
| 2.0 | 2026-11-23 | Ficha, mapa de los 6 repositorios con su nombre de GitHub y estado de sus README; la reconciliación queda como histórico (SCRUM-1693) | Juan Sebastián Álvarez |

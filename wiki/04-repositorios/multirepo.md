# Multi-repo

[← 04 · Repositorios](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §4 · [`architecture/SAD.md`](../../architecture/SAD.md) §17 · [`architecture/SDD.md`](../../architecture/SDD.md) §13 · [`adr/ADR-0004`](../../adr/ADR-0004-cicd-multirepo-ambientes.md).

MANI adopta estrategia **multi-repo**: cada unidad desplegable mantiene ciclo técnico independiente.

```text
MANI-Frontend
MANI-API-Gateway  ← también es dueño de database/, scripts/, supabase/ y el Compose
MANI-Rules-Service
MANI-Dispatch-Service
MANI-Core-Service   ← incluye cobertura, disponibilidad y elegibilidad
MANI-Docs           ← este repositorio
```

`MANI-Infra` ya no existe: DevOps lo borró el 2026-10-06 y su alcance quedó repartido según la [enmienda de ADR-0004](../../adr/ADR-0004-cicd-multirepo-ambientes.md).

`MANI-Availability` tampoco: la cobertura y la disponibilidad son un dominio del `MANI-Core-Service` ([ADR-0028](../../adr/ADR-0028-nombres-repositorios-y-ambientes.md)). Los nombres de la lista son los únicos válidos.

Cada repositorio desplegable mantiene de forma independiente: código · dependencias · pruebas · `Dockerfile` · pipeline · configuración de build · versionamiento · artefactos · documentación técnica inmediata.

`MANI-Docs` mantiene SRS, SAD, SDD, ADR, modelo de datos, políticas, infraestructura y diagramas: **no contiene código desplegable**.

## Consecuencias prácticas

- Un cambio que cruza repositorios se parte en un PR por repositorio, cada uno con su referencia Jira.
- Un contrato compartido (OpenAPI entre Gateway y servicios) se acuerda antes de implementar: es la tarea `CFG-16` del backlog de transición.
- Crear los repositorios que faltan del modelo es `CFG-15`; replicar el pipeline en cada uno es `CFG-29`.
- Los artefactos de infraestructura salieron del repositorio Flutter (tarea `CFG-33`, SCRUM-1110): `database/`, `scripts/`, `supabase/` y el Compose pasan a `MANI-API-Gateway`; `nginx.conf` queda en `MANI-Frontend` como `docker/nginx-web.conf` porque sirve la SPA dentro de la imagen web. El responsable de las migraciones por ambiente es DevOps ([`INFRAESTRUCTURA_MANI.md`](../../governance/INFRAESTRUCTURA_MANI.md) §15).

## Estado real a tener en cuenta

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

Las ramas nuevas de MANI-Frontend salen de `develop` y vuelven a `develop` por PR (ver [Git: ramas y commits](../05-proceso/git-ramas-y-commits.md)).

Quien vaya a trabajar en ese repositorio revisa primero [Orden de ejecución](../06-backlog/orden-de-ejecucion.md).

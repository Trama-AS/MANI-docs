# ADR-0004 — CI/CD multi-repositorio y promoción de ambientes

- **Estado:** Aceptado
- **Decisión de:** entrega y despliegue
- **Relacionado con:** ADR-0005, ADR-0006, ADR-0019

## Contexto

MANI utiliza componentes políglotas con ciclos de build independientes y debe promover artefactos de forma controlada entre ambientes.

## Alternativas

1. **Monorepo con pipeline único.** Descartada porque acopla ciclos de entrega de componentes heterogéneos.
2. **Jenkins autoalojado.** Descartada por carga operativa innecesaria.
3. **Multi-repo + GitHub Actions + artefactos OCI inmutables.** Elegida.

## Decisión

MANI mantiene una estrategia **multi-repo** y utiliza GitHub Actions para CI/CD. Los artefactos Docker/OCI se construyen una vez y se promueven sin reconstrucción por:

`DEV → TEST/QA → PROD`

No existe un ambiente STAGING obligatorio.

Repositorios de referencia:
- `MANI-Flutter`;
- `MANI-APIGateway`;
- `MANI-Rules-Java`;
- `MANI-Dispatch-DotNet`;
- `MANI-Core-Node`;
- `MANI-Availability`;
- `MANI-Docs`.

> Lista actualizada por la enmienda del 2026-10-07 (ver abajo): `MANI-Infra` ya no existe y `MANI-Gateway` es `MANI-APIGateway`.
>
> **Superseded por [ADR-0028](./ADR-0028-nombres-repositorios-y-ambientes.md)** en cuanto a los
> nombres de los repositorios y de los ambientes. La decisión de fondo de este ADR —multi-repo,
> GitHub Actions, build once deploy many, promoción sin reconstrucción y rollback por imagen
> previa— sigue vigente. La lista de arriba se conserva como registro histórico.

Se utiliza versionamiento semántico para releases y rollback mediante una imagen previamente validada.

## Justificación

Favorece independencia de despliegue, reproducibilidad y trazabilidad.

## Consecuencias

### Positivas
- Build once, deploy many.
- Versionamiento independiente.
- QA previo obligatorio antes de PROD.

### Negativas
- Más pipelines, secretos y configuraciones distribuidas.

## Condición de revisión

Revisar si el costo operativo del multi-repo supera sus beneficios o si el equipo migra formalmente a monorepo.

## Enmienda 2026-10-07 — destino de la infraestructura (CFG-33, SCRUM-1110)

- **`MANI-Infra` no se crea.** DevOps borró el repositorio el 6 de octubre de 2026 porque ya no se necesitaba. La decisión multi-repo de este ADR no cambia.
- **`MANI-APIGateway` es el repositorio dueño de la infraestructura de datos y del stack local**: `database/` (init, migraciones versionadas y verificaciones), `scripts/` (migración local y sincronización desde QA), `supabase/` (PoC de CFG-09/10/12/13 y seeds de QA) y el `docker-compose.yml` con los perfiles `db` y `web`.
- **`MANI-Flutter` deja de contener infraestructura.** Conserva solo lo que empaqueta el cliente web: el `Dockerfile` y `docker/nginx-web.conf`, que sirve la SPA dentro de su imagen y no es configuración del Gateway.
- **Responsable de las migraciones por ambiente:** DevOps. El detalle está en `governance/INFRAESTRUCTURA_MANI.md` §15.
- **Pendiente:** el SDD §13 asigna a `MANI-Infra` los manifests de Kubernetes, la configuración transversal y la observabilidad. Dónde vivirán queda por resolver junto con INFRA-01 e INFRA-02 (`INFRAESTRUCTURA_MANI.md` §25). `SAD`, `SDD`, `README` y `POLITICAS_DEVOPS_HERRAMIENTAS` siguen nombrando `MANI-Infra` y se actualizan aparte.

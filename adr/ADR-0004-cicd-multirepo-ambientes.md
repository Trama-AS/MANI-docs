# ADR-0004 — CI/CD multi-repositorio y promoción de ambientes

- **Estado:** Aceptado, **parcialmente superseded por ADR-0023**
- **Decisión de:** entrega y despliegue
- **Relacionado con:** ADR-0005, ADR-0006, ADR-0019, ADR-0023

> **Qué sigue vigente y qué no.** La decisión de fondo —multi-repo, GitHub Actions, artefactos OCI
> construidos una vez y promovidos sin reconstrucción, `DEV → QA → PROD` sin STAGING, versionamiento
> semántico y rollback por imagen previa— **sigue vigente**.
>
> Lo que [ADR-0023](./ADR-0023-consolidacion-repositorios-ambientes.md) supersede es la **lista de
> repositorios** de la sección «Decisión» y la plataforma de los ambientes: son seis repositorios,
> no ocho, y QA y PROD corren con Docker sobre una VM por ambiente. La lista de abajo se conserva
> como registro histórico de la decisión original.

## Contexto

MANI utiliza componentes políglotas con ciclos de build independientes y debe promover artefactos de forma controlada entre ambientes.

## Alternativas

1. **Monorepo con pipeline único.** Descartada porque acopla ciclos de entrega de componentes heterogéneos.
2. **Jenkins autoalojado.** Descartada por carga operativa innecesaria.
3. **Multi-repo + GitHub Actions + artefactos OCI inmutables.** Elegida.

## Decisión

MANI mantiene una estrategia **multi-repo** y utiliza GitHub Actions para CI/CD. Los artefactos Docker/OCI se construyen una vez y se promueven sin reconstrucción por:

`DEV → QA → PROD`

No existe un ambiente STAGING obligatorio.

Repositorios de referencia **en el momento de esta decisión** (superseded por ADR-0023, que fija
seis repositorios y retira `MANI-Availability` y `MANI-Infra`):

- `MANI-Frontend`;
- `MANI-API-Gateway`;
- `MANI-Rules-Service`;
- `MANI-Dispatch-Service`;
- `MANI-Core-Service`;
- ~~`MANI-Availability`~~ — retirado: módulo del Core Service;
- ~~`MANI-Infra`~~ — retirado: su contenido vive en `MANI-API-Gateway`;
- `MANI-Docs`.

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

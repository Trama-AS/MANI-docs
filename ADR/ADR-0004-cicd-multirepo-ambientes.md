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
- `MANI-Gateway`;
- `MANI-Rules-Java`;
- `MANI-Dispatch-DotNet`;
- `MANI-Core-Node`;
- `MANI-Availability`;
- `MANI-Infra`;
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

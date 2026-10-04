# Multi-repo

[← 04 · Repositorios](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §4 · [`architecture/SAD.md`](../../architecture/SAD.md) §17 · [`architecture/SDD.md`](../../architecture/SDD.md) §13 · [`adr/ADR-0004`](../../adr/ADR-0004-cicd-multirepo-ambientes.md).

MANI adopta estrategia **multi-repo**: cada unidad desplegable mantiene ciclo técnico independiente.

```text
MANI-Flutter
MANI-Gateway
MANI-Rules-Java
MANI-Dispatch-DotNet
MANI-Core-Node
MANI-Availability
MANI-Infra
MANI-Docs        ← este repositorio
```

Cada repositorio desplegable mantiene de forma independiente: código · dependencias · pruebas · `Dockerfile` · pipeline · configuración de build · versionamiento · artefactos · documentación técnica inmediata.

`MANI-Docs` mantiene SRS, SAD, SDD, ADR, modelo de datos, políticas, infraestructura y diagramas: **no contiene código desplegable**.

## Consecuencias prácticas

- Un cambio que cruza repositorios se parte en un PR por repositorio, cada uno con su referencia Jira.
- Un contrato compartido (OpenAPI entre Gateway y servicios) se acuerda antes de implementar: es la tarea `CFG-16` del backlog de transición.
- Crear los repositorios que faltan del modelo es `CFG-15`; replicar el pipeline en cada uno es `CFG-29`.
- Los artefactos de infraestructura (`database/`, `docker-compose.yml`, `scripts/`, `nginx.conf`) deben salir del repositorio Flutter hacia su repositorio dueño: tarea `CFG-33`.

## Estado real a tener en cuenta

Backlog V4 §3, verificado sobre `MANI-Flutter`:

- `main` contiene sólo el scaffold por defecto de Flutter; **el producto vive en `develop` y `release`**;
- hay 13 ramas `feature`/`fix` con trabajo sin fusionar, que deben reconciliarse antes de migrar (`CFG-37`, `CFG-38`);
- la lógica de negocio está en ~32 funciones PL/pgSQL bajo `database/`, no en el cliente.

Quien vaya a trabajar en ese repositorio revisa primero [Orden de ejecución](../06-backlog/orden-de-ejecucion.md).

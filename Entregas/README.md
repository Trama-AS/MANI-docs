# Entregas — histórico académico

> **Esta carpeta no es fuente de verdad. No se consulta para resolver una duda ni para
> implementar, y no se actualiza.**

Contiene los entregables presentados en cada corte académico, tal como se entregaron. Su valor es
de registro: muestra qué se sabía y qué se había decidido en cada momento.

## Por qué no se consulta

Los archivos Markdown de `Entrega4/` son **copias congeladas** de documentos que siguieron
evolucionando en `main`. Ya divergieron:

| Copia en `Entregas/Entrega4/` | Documento vivo |
|---|---|
| `SRS_MANI_V3.md` | [`product/SRS.md`](../product/SRS.md) |
| `SAD_V3.md` | [`architecture/SAD.md`](../architecture/SAD.md) |
| `SDD_V1.md` | [`architecture/SDD.md`](../architecture/SDD.md) |
| `DD_V2.md` | [`architecture/ModeloDatos.md`](../architecture/ModeloDatos.md) |
| `Backlog_V3.md` | [`product/BACKLOG_MANI.md`](../product/BACKLOG_MANI.md) |
| `Documento_Infraestructura_V1.md` | [`governance/INFRAESTRUCTURA_MANI.md`](../governance/INFRAESTRUCTURA_MANI.md) |
| `Documento_Herramientas_Politicas_Lineamientos_V3.md` | [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) |

## La trampa de la numeración de ADR

Estas copias usan una numeración de ADR **abandonada**, en la que `ADR-0022` era «proveedor de
identidad», `ADR-0023` el cierre de KI-02 y existían borradores `ADR-0028` y `ADR-0029`.

En la numeración vigente, `ADR-0022` es la lógica de negocio en los servicios y `ADR-0023` la
consolidación de repositorios y ambientes. **Son decisiones distintas con el mismo número.**

El índice vigente, con el hueco de `ADR-0024` a `ADR-0026` explicado, está en
[Decisiones ADR](../wiki/02-arquitectura/decisiones-adr.md).

## Dónde está la verdad

En los documentos vivos de `main`, cuya tabla de fuente de verdad por tema está en el
[`README.md`](../README.md) §12. Esos documentos no llevan número de versión: la versión es el
commit.

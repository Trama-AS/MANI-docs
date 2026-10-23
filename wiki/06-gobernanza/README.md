# 06 · Gobernanza

[← Índice de la wiki](../Home.md)

**Fuente:** [`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) · [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](POLITICAS_DEVOPS_HERRAMIENTAS.md) · [`INFRAESTRUCTURA_MANI.md`](INFRAESTRUCTURA_MANI.md).

Esta carpeta responde a **quién decide** y **bajo qué políticas y sobre qué infraestructura** se trabaja. No describe el producto ni la arquitectura: eso es [01-producto](../01-producto/README.md) y [02-arquitectura](../02-arquitectura/README.md).

| Documento | De qué responde |
|---|---|
| [`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) | Roles, autoridad por artefacto, desempates, ceremonias, plazos exigibles y qué pasa con un incremento no entregado |
| [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](POLITICAS_DEVOPS_HERRAMIENTAS.md) | Políticas de ramas, PR, promoción, CI/CD, contenedores, testing, DevSecOps, secretos, observabilidad, uso de IA, versionamiento de despliegue y, en §22, la política de JWT entre ambientes |
| [`INFRAESTRUCTURA_MANI.md`](INFRAESTRUCTURA_MANI.md) | Vista física vigente: ambientes DEV, QA y PROD, VMs, registro de imágenes, Supabase, red y TLS, backups, escalabilidad y, en §27, el plan de alineación y rollback de Supabase PROD y QA |
| [`DOCUMENTO_INFRAESTRUCTURA_V3.md`](DOCUMENTO_INFRAESTRUCTURA_V3.md) | Vista física del modelo 4+1 al cierre del Sprint 4, con evidencia empírica y runbook |

## Dos documentos que dejaron de existir aparte

El 22 de octubre de 2026 se absorbieron dos documentos que vivían sueltos, porque su contenido pertenece a una política y a la infraestructura, no a un documento propio:

| Antes | Ahora |
|---|---|
| `POLITICA_CONFIGURACION_JWT_CFG4-04.md` | [`POLITICAS_DEVOPS_HERRAMIENTAS.md` §22](POLITICAS_DEVOPS_HERRAMIENTAS.md#22-política-de-configuración-validación-perimetral-y-propagación-de-jwt-entre-ambientes-cfg4-04) |
| `PLAN_ALINEACION_SUPABASE_PROD_QA_CFG-26.md` | [`INFRAESTRUCTURA_MANI.md` §27](INFRAESTRUCTURA_MANI.md#27-plan-de-auditoría-alineación-y-migraciónrollback-de-supabase-prod-y-qa-cfg-26) |

Se citan por su sección. Sus versiones originales quedan en el historial de git y, congeladas, en [`Entregas/Entrega4/`](../../Entregas/Entrega4).

## Las reglas que resuelven discusiones

De [`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §1:

- **Lo que no está documentado no se exige.**
- Lo acordado se cumple durante su vigencia.
- Ninguna conversación informal sustituye un artefacto oficial.

La autoridad es del **rol** y del **artefacto**, no de la persona (§2.3): el PO decide los criterios de aceptación, QA decide el DoD, y una contradicción estructural va a Mesa de Arquitectura y produce un ADR.

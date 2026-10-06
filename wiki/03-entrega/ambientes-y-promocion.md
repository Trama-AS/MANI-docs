# Ambientes y promoción

[← 03 · Entrega](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §7–§12 · [`architecture/SDD.md`](../../architecture/SDD.md) §10–§12 · [`governance/INFRAESTRUCTURA_MANI.md`](../../governance/INFRAESTRUCTURA_MANI.md) §4–§10 · [`adr/ADR-0004`](../../adr/ADR-0004-cicd-multirepo-ambientes.md).

## Secuencia oficial

```text
DEV → TEST/QA → PROD
```

`TEST/QA` es **un único ambiente**. `staging` puede aparecer como etiqueta técnica histórica, pero no es un cuarto entorno. Existe además el entorno **local** de cada persona (Docker Compose + Flutter + Supabase local, datos sintéticos) según SDD §10.

| Ambiente | Para qué | Datos |
|---|---|---|
| **DEV** | Desarrollo, integración temprana, pruebas locales, validación previa al release | Sintéticos. Sin datos reales de usuarios ni KYC |
| **TEST/QA** | Funcionales, integración multi-servicio, contratos, aislamiento, carga, DAST, aceptación QA | Dataset controlado y anonimizado |
| **PROD** | Operación real | Datos reales, secretos exclusivos, controles productivos |

Reglas de ambiente (SDD §10, Políticas §2 y §15):

- no se comparten bases, secretos ni credenciales entre ambientes;
- **no se copian datos KYC ni datos personales reales a DEV o TEST/QA**;
- configuración y secretos son externos a las imágenes;
- la definición de esquema y las políticas de seguridad se mantienen equivalentes entre ambientes;
- `DEV/QA → base de datos PROD` es una dependencia prohibida (SDD §14).

## Build once, deploy many

La imagen se construye **una sola vez** y la misma imagen validada se promueve mediante digest, tag inmutable y release versionado. Reconstruir código específicamente para PROD como mecanismo ordinario de promoción está **prohibido** (Políticas §9). Entre ambientes sólo cambian parámetros externos, secretos y escalado.

Esto es también el punto 7 del criterio de aceptación arquitectónica: el artefacto desplegado es el mismo que se validó antes ([Criterios de éxito](../01-producto/criterios-de-exito.md)).

## Registro de imágenes

Registro oficial: **GitHub Container Registry (GHCR)**.

```text
ghcr.io/trama-as/<repositorio>:<tag>
```

Los tags deben distinguir desarrollo, release/QA, producción, versión semántica y commit SHA cuando se requiera trazabilidad:

```text
dev-<sha>
qa-<sha>
v1.2.0
```

`latest` puede existir por conveniencia, pero **no sustituye** el tag inmutable usado para trazabilidad.

## Kubernetes y Docker Compose

- **Kubernetes es requisito obligatorio del proyecto** (PROY-08) y es la arquitectura objetivo de orquestación.
- El **proveedor de cómputo y la topología del clúster siguen pendientes** (INFRA-01, INFRA-02). No se asume AKS ni Azure.
- Hasta que exista decisión: no se inventan nodos, no se fija proveedor, no se documenta capacidad como definitiva.
- **Docker Compose sobre VMs** puede continuar como mecanismo operativo de despliegue, descargando imágenes desde GHCR. No sustituye el requisito de Kubernetes.
- La transición a Kubernetes conserva los mismos artefactos OCI publicados en GHCR.

Compose debe declarar servicios, usar variables externas, evitar secretos embebidos, fijar imágenes por tag/digest, separar redes cuando aplique y declarar health checks cuando aplique (Políticas §11).

## Reglas físicas en producción

SDD §9.1: contenedores inmutables · al menos dos réplicas para servicios críticos · readiness y liveness probes · requests/limits de CPU y memoria · HPA para servicios sensibles a carga · secretos desde gestor seguro · bases productivas sin exposición pública salvo controles explícitos · acceso administrativo con privilegio mínimo.

## Rollback

La estrategia de rollback y la compatibilidad de migraciones están en [`SDD.md`](../../architecture/SDD.md) §12.5 y §12.3. Una versión no se promueve sin estrategia de rollback para sus migraciones.

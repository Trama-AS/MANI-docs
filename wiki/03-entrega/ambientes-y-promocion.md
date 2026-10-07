# Ambientes y promoción

[← 03 · Entrega](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §7–§12 · [`architecture/SDD.md`](../../architecture/SDD.md) §9–§12 · [`governance/INFRAESTRUCTURA_MANI.md`](../../governance/INFRAESTRUCTURA_MANI.md) §4–§10 · [`adr/ADR-0004`](../../adr/ADR-0004-cicd-multirepo-ambientes.md) · [`adr/ADR-0023`](../../adr/ADR-0023-consolidacion-repositorios-ambientes.md).

## Secuencia oficial

```text
DEV → QA → PROD
```

**Son exactamente tres ambientes.** El de pruebas se llama **QA** en todo documento, pipeline y tag.
No existen «TEST», «TEST/QA», «Local» ni «Staging» como nombres de ambiente.

| Ambiente | Dónde corre | Para qué | Datos |
|---|---|---|---|
| **DEV** | máquina personal de cada desarrollador, con Docker local y Supabase de DEV | desarrollo, integración temprana y pruebas antes del PR | sintéticos; sin datos reales de usuarios ni KYC |
| **QA** | VM de QA con Docker | funcionales, integración multi-servicio, contratos, aislamiento, carga, DAST y aceptación | dataset controlado y anonimizado |
| **PROD** | VM productiva con Docker | operación real | reales, secretos exclusivos, controles productivos |

DEV no es un ambiente desplegado: el pipeline promueve **de QA a PROD**, y DEV es donde se
construye y se prueba antes del Pull Request.

Reglas de ambiente (SDD §10, Políticas §2 y §15):

- no se comparten bases, secretos ni credenciales entre ambientes;
- **no se copian datos KYC ni datos personales reales a DEV o QA**;
- configuración y secretos son externos a las imágenes;
- la definición de esquema y las políticas de seguridad se mantienen equivalentes entre ambientes;
- `DEV/QA → base de datos PROD` es una dependencia prohibida (SDD §14).

## Build once, deploy many

La imagen se construye **una sola vez** y la misma imagen validada se promueve mediante digest, tag
inmutable y release versionado. Reconstruir código específicamente para PROD como mecanismo
ordinario de promoción está **prohibido** (Políticas §9). Entre ambientes sólo cambian parámetros
externos y secretos.

Es también el punto 7 del criterio de aceptación arquitectónica: el artefacto desplegado es el mismo
que se validó antes ([Criterios de éxito](../01-producto/criterios-de-exito.md)).

## Registro de imágenes

Registro oficial: **GitHub Container Registry (GHCR)**. Decisión cerrada.

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

## Orquestación: decisión abierta

- El despliegue **vigente** de QA y PROD es **Docker sobre una VM por ambiente**, con Compose. Los
  archivos viven en `MANI-API-Gateway`, uno por ambiente.
- **Kubernetes es la plataforma objetivo** exigida por PROY-08, pero **no está decidida ni
  desplegada**: siguen abiertas `INFRA-01` e `INFRA-02`, y requieren ADR.
- Hasta que exista decisión: no se inventan nodos, no se fija proveedor, no se documenta capacidad
  como definitiva y **no se asume AKS ni Azure**.
- La transición futura conserva los mismos artefactos OCI publicados en GHCR: es la restricción que
  mantiene la decisión reversible.

Compose debe declarar los servicios, usar variables externas, evitar secretos embebidos, fijar
imágenes por tag **y digest**, declarar la red interna, declarar health checks y límites de CPU y
memoria por contenedor, y usar `restart: unless-stopped` (Políticas §11).

## Reglas físicas en producción

SDD §9.2: contenedores inmutables fijados por tag y digest · health check por contenedor ·
`restart: unless-stopped` · límites de CPU y memoria declarados · secretos desde el gestor del
ambiente · TLS terminado en el borde · base productiva sin exposición pública salvo controles
explícitos · acceso administrativo con privilegio mínimo · rollback por imagen anterior.

**Lo que el modelo actual no da**, y por eso no se promete: autoescalado, réplicas gestionadas,
recuperación ante la caída del host y rolling update sin ventana. El techo de capacidad es la VM
(INFRAESTRUCTURA §22).

## Rollback

La estrategia de rollback y la compatibilidad de migraciones están en [`SDD.md`](../../architecture/SDD.md) §12.5 y §12.3. Una versión no se promueve sin estrategia de rollback para sus migraciones.

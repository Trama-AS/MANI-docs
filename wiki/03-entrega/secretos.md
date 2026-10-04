# Secretos

[← 03 · Entrega](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §15 y §16 · [`governance/INFRAESTRUCTURA_MANI.md`](../../governance/INFRAESTRUCTURA_MANI.md) §17 · [`architecture/SDD.md`](../../architecture/SDD.md) §14.

## Prohibido

- commit de `.env`;
- contraseñas en el repositorio;
- tokens en código;
- claves productivas en imágenes;
- credenciales hard-coded en un servicio (dependencia prohibida, SDD §14).

Sin secretos en repositorio es uno de los diez principios de DevOps del proyecto (Políticas §2.5).

## Por ambiente

| Ambiente | Regla |
|---|---|
| **DEV** | Variables locales fuera de Git; credenciales exclusivamente de desarrollo |
| **TEST/QA** | Secretos propios del ambiente; sin acceso a credenciales productivas |
| **PROD** | Secretos exclusivos, acceso restringido, aprobación de despliegue y rotación según necesidad |

Al migrar a Kubernetes se usarán Secrets/ConfigMaps o un gestor equivalente aprobado.

## Identidad de tenant en tránsito

El `tenant_id` del JWT firmado es la fuente canónica; el Gateway valida inicialmente, cada servicio valida autorización y RLS refuerza el aislamiento. `X-Tenant-Slug` sirve sólo para resolución contextual antes de autenticar y **no autoriza acceso a datos** (Políticas §16). Detalle en [Multi-tenancy y seguridad](../02-arquitectura/multitenancy-y-seguridad.md).

## Riesgo abierto registrado

El artefacto web publicado hoy incluye la `SUPABASE_ANON_KEY`, lo que permite llamar a PostgREST directamente con sólo RLS como contención. Retirarla del bundle y **rotarla** es la tarea `CFG-36` del backlog de transición, y que deje de viajar en el artefacto es parte de la [definición de llegada](../01-producto/criterios-de-exito.md).

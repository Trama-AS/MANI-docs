# Secretos

[← 04 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md) §15 y §16 · [`governance/INFRAESTRUCTURA_MANI.md`](../08-infraestructura/README.md) §17 · [`architecture/SDD.md`](../02-arquitectura/SDD.md) §14.

| Campo | Valor |
|---|---|
| **Finalidad** | Decir qué está prohibido subir al repositorio y cómo se manejan los secretos por ambiente |
| **Mantiene** | La página: Nicolás Álvarez (responsable de la carpeta). La fuente: DevOps |
| **Consume** | Todo el equipo |
| **Cada cuánto se actualiza** | Cuando cambia la política de secretos o se rota una credencial |
| **Versión y fecha** | Viva, sin número · contenido del 2026-11-04; ficha añadida el 2026-11-16 ([SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694)) |
| **Origen y destino** | Requisito de seguridad → política §15 y §16 → secretos por ambiente → barrido de secretos |

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
| **QA** | Secretos propios del ambiente; sin acceso a credenciales productivas |
| **PROD** | Secretos exclusivos, acceso restringido, aprobación de despliegue y rotación según necesidad |

Si se adopta una plataforma de orquestación, los secretos pasan a su gestor nativo —Secrets/ConfigMaps o equivalente aprobado— sin cambiar el principio: la configuración y los secretos son externos al artefacto.

## Identidad de tenant en tránsito

El `tenant_id` del JWT firmado es la fuente canónica; el Gateway valida inicialmente, cada servicio valida autorización y RLS refuerza el aislamiento. `X-Tenant-Slug` sirve sólo para resolución contextual antes de autenticar y **no autoriza acceso a datos** (Políticas §16). Detalle en [Multi-tenancy y seguridad](../02-arquitectura/SAD.md#8-multi-tenancy-y-seguridad).

## Riesgo abierto registrado

El artefacto web publicado hoy incluye la `SUPABASE_ANON_KEY`, lo que permite llamar a PostgREST directamente con sólo RLS como contención. Retirarla del bundle y **rotarla** es la tarea `CFG-36` del backlog de transición, y que deje de viajar en el artefacto es parte de la [definición de llegada](../01-producto/criterios-de-exito.md).

# Orden de ejecución

[← 06 · Backlog](README.md) · [Índice](../Home.md)

**Fuente:** [`product/BACKLOG_MANI.md`](../../product/BACKLOG_MANI.md) §4.1, §4.2 y §4.5.

Este orden no es una sugerencia: las fases 1 y 2 **bloquean** el resto.

| Fase | Trabajo | Por qué va aquí |
|---:|---|---|
| 1 | `CFG-37`, `CFG-38` — reconciliar las ramas de `MANI-Flutter` y fijar la base de código | Sin esto, todo lo demás se construye sobre una base incompleta |
| 2 | `SP-05` — decidir si los servicios **reescriben** o **invocan** la lógica PL/pgSQL | **Bloquea toda estimación funcional**: sin esta decisión las subtareas `-M2` no son estimables |
| 3 | `CFG-15 … CFG-21` — repositorios, contratos OpenAPI, Gateway y esqueletos de servicio | Es la plataforma mínima para implementar casos de uso |
| 4 | `CFG-22 … CFG-25` — identidad y propagación de JWT, **rediseño del modelo de identidad en base de datos**, inventario de funciones PL/pgSQL y propiedad de datos por dominio | `CFG-23` es el punto que puede tumbar el aislamiento multi-tenant |
| 5 | `CFG-26 … CFG-30`, `CFG-33` — Supabase por ambiente, GHCR, Compose, CI/CD, observabilidad y sacar `database/`, Compose, `scripts/` y `nginx.conf` del repo Flutter | Entrega y operación por repositorio |
| 6 | `CFG-34 … CFG-36`, `CFG-39` — capa HTTP del cliente, recorte de `supabase_flutter`, **retirar y rotar la `SUPABASE_ANON_KEY`** y mock del Gateway para pruebas | Saca al cliente de la base de datos |
| 7 | Subtareas `-M1 … -Mn` por historia, en el orden de las épicas funcionales | El trabajo funcional propiamente dicho |
| 8 | `CFG-40` — regresión completa sobre todo lo legacy preservado | Demuestra que nada se rompió |
| 9 | `CFG-31`, `CFG-32` — cerrar Kubernetes por ADR y ejecutar la transición de despliegue sin romper el Compose actual | Depende de INFRA-01 e INFRA-02 |
| 10 | `DOC-25 … DOC-28` — documentación, en paralelo y cerrando al final | Deja SAD, SDD, ADR y contexto alineados con lo que de verdad se hizo |

> **Corrección registrada en el documento fuente:** `SP-05` y `CFG-23` estaban ausentes de la versión anterior del backlog y son **bloqueantes del trabajo funcional**. Van en las fases 1 y 2, no al final.

## Dependencias que conviene tener a la vista

| Tarea | Depende de |
|---|---|
| `CFG-16` contratos OpenAPI | `CFG-15` |
| `CFG-17` Gateway NGINX | `CFG-15`, `CFG-16` |
| `CFG-22` JWT entre Auth, Gateway y servicios | `CFG-17 … CFG-21` |
| `CFG-23` modelo de identidad en base de datos | `CFG-22`, `SP-05` |
| `CFG-24` inventario de funciones PL/pgSQL | `SP-05` |
| `CFG-28` Compose por ambiente desde GHCR | `CFG-27`, `CFG-33` |
| `CFG-34` capa HTTP del cliente | `CFG-16`, `CFG-17` |
| `CFG-36` retirar y rotar la anon key | `CFG-34`, `CFG-35` |
| `CFG-40` regresión | `CFG-23`, `CFG-34`, `CFG-38` |

## Cuándo se considera terminada la transición

Los once puntos de la definición de llegada están en [Criterios de éxito](../01-producto/criterios-de-exito.md).

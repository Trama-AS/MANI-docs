# Criterios de éxito

[← 01 · Producto](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SDD.md`](../../architecture/SDD.md) §19 · [`product/BACKLOG_MANI.md`](../../product/BACKLOG_MANI.md) §9 · [`governance/GOBIERNO_DEL_EQUIPO.md`](../../governance/GOBIERNO_DEL_EQUIPO.md) §9–§11.

Hay tres niveles de «terminado» y no se confunden entre sí.

## 1. Una historia está terminada

Cumple el [DoD del equipo](../05-proceso/dor-y-dod.md): criterios de aceptación verificados, PR integrado y revisado, CI en verde, QA ejecutado, documentación afectada actualizada y trazabilidad registrada.

## 2. Una versión puede promoverse a producción

SDD §19 — criterio de aceptación arquitectónica. Sólo si:

1. cumple los Quality Gates de seguridad y mantenibilidad;
2. contract tests e integración están en verde;
3. no introduce accesos cruzados de datos no autorizados;
4. mantiene los umbrales P1 del SDD;
5. las migraciones tienen estrategia de compatibilidad y rollback;
6. existe telemetría para las operaciones críticas;
7. **el artefacto desplegado es el mismo que se validó en los ambientes previos.**

## 3. La transición arquitectónica está completa

Backlog V4 §9 — definición de llegada:

- Flutter consume todo a través del NGINX Gateway y **no queda ningún acceso PostgREST desde el cliente**.
- La `SUPABASE_ANON_KEY` ya no viaja en el artefacto web.
- Rules corre en Java, Dispatch en .NET y el Core Service —con su módulo de disponibilidades— en Node.js.
- Dispatch conserva exactamente una asignación válida bajo concurrencia, con el PoC-001 revalidado.
- RLS sigue aislando **con el modelo de identidad rediseñado** para un llamador que es un servicio, no el usuario final.
- Auth, Storage y Realtime integrados según el SAD, y el destino de cada función PL/pgSQL decidido y registrado en ADR.
- `database/`, Compose y scripts viven en su repositorio dueño, con responsable definido de las migraciones por ambiente.
- Cada repositorio publica su imagen en GHCR y las VMs pueden levantarla con Compose.
- CI/CD y pruebas de aislamiento funcionan por repositorio.
- Las nueve historias preservadas pasan la regresión.
- Plataforma de orquestación, proveedor y topología cerrados por ADR (`INFRA-01`, `INFRA-02`), desplegando las mismas imágenes OCI.

## Salud del sprint

El estado general del sprint se mide con los indicadores de equipo E1–E6 y el semáforo de `GOBIERNO_DEL_EQUIPO.md` §11.4: **verde** con carry-over ≤ 10 % y Sprint Goal cumplido; **amarillo** entre 10 % y 25 % o con el objetivo en riesgo; **rojo** con carry-over > 25 %, objetivo incumplido, bloqueo crítico sin resolver o trabajo arrastrado tres sprints o más.

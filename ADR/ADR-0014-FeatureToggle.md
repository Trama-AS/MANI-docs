# ADR-0014: Adopción del patrón Feature Toggle

- Fecha: 2026-09-02
- Sprint: <n>
- Autor: <nombre y rol>
- Origen: <Mesa Técnica | Sprint Planning | issue #NNN>
- Revisor: <integrante distinto del autor que aprueba el pull request>

## Contexto

MANI declara como driver que cada tenant configure sus reglas sin requerir código
específico ni nuevo despliegue de la plataforma (driver #14, trazado a RNF-02), y el
trabajo funcional está dividido en dos incrementos: RF-01 a RF-23 (MVP) y RF-24 a RF-28
(2º incremento).

El pipeline de CI/CD del proyecto está actualmente en un estado de contradicción activa:
ADR-0004 (GitHub Actions + Azure, sobre 3 repos Flutter/Java/.NET) y ADR-0012 (Serverpod +
Supabase, ratificado como stack primario) están ambos en estado Aceptado sin que ningún ADR
posterior declare "supersedes" sobre el otro (ver KI-02 y el hallazgo transversal registrado
en la hoja ADR del SAD). Bajo cualquiera de los dos escenarios de pipeline que se termine
consolidando, el equipo necesita poder llevar código a producción antes de que una
funcionalidad esté lista para todos los tenants, sin depender de ramas de larga duración ni
de coordinar manualmente el momento exacto del release por incremento.

## Alternativas evaluadas

1. **Feature branching de larga duración** (mantener una rama por incremento hasta que el
   conjunto de RF esté completo) — descartada porque incrementa el costo de merge conforme
   crece la divergencia entre ramas, y no resuelve el requisito de activar/desactivar una
   regla por tenant sin desplegar código (RNF-02).
2. **Despliegue coordinado sin toggles** (fusionar a `main` solo cuando el incremento
   completo esté listo) — descartada porque bloquea la entrega continua de RF-01 a RF-23
   mientras se desarrolla RF-24 a RF-28, y no ofrece un mecanismo para que un tenant
   individual reciba una función antes que otro.

<!-- Si la Mesa evaluó otras alternativas (p. ej. despliegue canario, branch by abstraction),
agregarlas aquí con su motivo objetivo de descarte antes de aceptar este ADR. -->

## Decisión

Usaremos un patrón de feature toggles para desacoplar el despliegue de código de la
activación de la funcionalidad.

## Trade-off asumido

Se asume la deuda técnica de mantener el ciclo de vida de los toggles (riesgo de código
muerto si no se retiran tras estabilizarse una función), y una superficie de configuración
adicional por tenant que debe cubrirse en la suite de pruebas de aislamiento multi-tenant
(ADR-0015), ampliando el alcance ya declarado en TO-05 (verificabilidad vs. adaptabilidad).

## Estado

Propuesto — última actualización: 2026-09-02

## Consecuencias

- Positivas: permite entregar RF-24 a RF-28 de forma incremental sin bloquear `main`;
  permite activar o desactivar una regla por tenant sin nuevo despliegue, alineado con el
  driver #14 (RNF-02); reduce la necesidad de ramas de larga duración.
- Negativas: añade una superficie de configuración adicional que debe cubrirse en la suite
  de QS-17 (aislamiento multi-tenant), ampliando su alcance; introduce el riesgo de código
  muerto si los toggles no se retiran una vez estabilizada la función.
- Neutras: queda pendiente decidir el mecanismo de almacenamiento y evaluación del toggle
  (p. ej. tabla de configuración por tenant en Supabase vs. servicio externo dedicado) —
  esa decisión de implementación no se toma en este ADR y requiere uno propio.


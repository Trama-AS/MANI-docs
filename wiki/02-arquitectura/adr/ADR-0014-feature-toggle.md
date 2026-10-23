# ADR-0014 — Feature Toggle

- **Estado:** Rejected
- **Decisión de:** gestión de funcionalidades
- **Relacionado con:** RNF-02, REST-05

## Contexto

Se evaluó utilizar feature toggles para soportar diferencias entre tenants y desacoplar despliegue de activación.

## Alternativas

1. **Feature toggles por tenant.**
2. **Reglas y configuración por tenant almacenadas como datos.** Elegida para los requisitos actuales.

## Decisión

No se adopta Feature Toggle como mecanismo requerido por la arquitectura actual.

Las diferencias funcionales exigidas por RNF-02 y REST-05 se resuelven mediante **configuración y reglas por tenant**, no mediante ramas de código ni flags permanentes.

## Justificación

El SRS exige configurabilidad por tenant, pero no exige rollout progresivo o activación de código por tenant. Introducir toggles sin ese driver añade estados y deuda técnica innecesarios.

## Consecuencias

### Positivas
- Menor complejidad de configuración.
- Menor riesgo de código muerto.

### Negativas
- Si se requiere rollout selectivo futuro deberá introducirse un mecanismo específico.

## Condición de revisión

Reabrir si aparece un requisito explícito de habilitar o deshabilitar funcionalidades desplegadas por tenant o cohorte.

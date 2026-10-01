# ADR-0018 — Identificación y propagación segura del tenant

- **Estado:** Aceptado
- **Decisión de:** seguridad e identidad
- **Relacionado con:** RF-03, RNF-01, ADR-0012, ADR-0019

## Contexto

Los servicios distribuidos necesitan identificar el tenant de forma no falsificable y propagar ese contexto entre componentes.

## Alternativas

1. **Subdominio como única fuente.** Descartada por complejidad y limitaciones móviles.
2. **Header `X-Tenant-ID` confiado por backend.** Descartada por spoofing.
3. **JWT firmado + contexto de preautenticación.** Elegida.

## Decisión

Para operaciones autenticadas, la fuente de verdad del tenant es un **JWT firmado** que contiene `tenant_id`.

El API Gateway valida inicialmente el token y los servicios Java, .NET y Node.js validan autorización y contexto.

`X-Tenant-Slug` puede utilizarse únicamente para resolución de tenant antes de autenticación; nunca autoriza acceso a datos.

En llamadas entre servicios se preserva el contexto autenticado mediante token relay o un mecanismo equivalente de identidad verificable.

## Justificación

Evita que el cliente suplante el tenant y permite defensa en profundidad con RLS.

## Consecuencias

### Positivas
- Contexto de tenant verificable extremo a extremo.

### Negativas
- Cada runtime debe implementar validación y propagación coherente.

## Condición de revisión

Revisar si se adopta un IdP o esquema de identidad de servicio distinto.

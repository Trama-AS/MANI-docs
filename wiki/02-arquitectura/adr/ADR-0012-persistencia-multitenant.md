# ADR-0012 — Persistencia operacional y aislamiento multi-tenant

- **Estado:** Aceptado
- **Decisión de:** persistencia y seguridad
- **Relacionado con:** RNF-01, REST-04, ADR-0018

## Contexto

MANI requiere persistencia relacional y aislamiento estricto entre tenants sin depender únicamente de filtros implementados en código.

## Alternativas

1. **MongoDB + filtrado en aplicación.** Descartada por no aportar RLS nativo.
2. **Base o esquema por tenant.** Descartada para el MVP por sobrecarga operativa.
3. **Supabase con PostgreSQL + RLS.** Elegida.

## Decisión

MANI utiliza **Supabase como plataforma administrada** y **PostgreSQL como motor de base de datos**.

El aislamiento multi-tenant se refuerza mediante **Row-Level Security (RLS)** basada en `tenant_id`.

Supabase puede aportar además Auth, Storage y Realtime cuando corresponda.

RLS no reemplaza la autorización de los servicios: funciona como una barrera adicional de defensa en profundidad.

## Justificación

Alinea el modelo relacional con aislamiento verificable a nivel de motor y evita introducir un backend Serverpod/Dart como dependencia arquitectónica.

## Consecuencias

### Positivas
- Persistencia relacional.
- Aislamiento reforzado.
- Integración con Auth y Storage.

### Negativas
- Dependencia operacional de Supabase como plataforma administrada.

## Condición de revisión

Revisar si el volumen o requisitos regulatorios exigen aislamiento físico por tenant.

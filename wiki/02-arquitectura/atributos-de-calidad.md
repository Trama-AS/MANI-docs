# Atributos de calidad

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SAD.md`](../../architecture/SAD.md) §20 · [`architecture/SDD.md`](../../architecture/SDD.md) §7 y §8 (ISO/IEC 25010:2023).

Los umbrales de esta página son los que se verifican en CI y en revisión. No se ajustan en un PR: se ajustan en el SAD/SDD.

## Prioridades

P1: seguridad, fiabilidad, eficiencia de desempeño, mantenibilidad, flexibilidad. P2: compatibilidad, adecuación funcional, capacidad de interacción. P3: protección/safety (SDD §7.1).

## Umbrales P1 (SAD §20)

### Seguridad

- 100 % de endpoints privados autenticados;
- 100 % de pruebas cross-tenant deben **negar** acceso;
- 0 vulnerabilidades `Blocker` / `Critical` en release;
- 0 `High` conocidas abiertas en producción;
- TLS para tráfico externo;
- cambios críticos auditados.

### Fiabilidad

- disponibilidad objetivo de APIs críticas ≥ 99.9 %;
- **0 dobles asignaciones**;
- operaciones críticas idempotentes;
- un fallo de push no revierte una operación confirmada.

### Eficiencia de desempeño

- consulta de disponibilidad/ranking **p95 ≤ 1 s** en el escenario provisional del SRS;
- objetivo inicial de pruebas: **20 usuarios concurrentes** para el escenario de RNF-07;
- la saturación se detecta por observabilidad.

Los volúmenes definitivos se ajustan cuando existan datos reales del cliente.

### Mantenibilidad

- un servicio no escribe tablas privadas de otro dominio;
- cobertura de código nuevo **≥ 80 %**; casos críticos **≥ 90 %**;
- `correlation_id` en requests distribuidos;
- contratos de API versionados.

### Flexibilidad

- la misma imagen es promovible entre ambientes;
- configuración externa al artefacto;
- integraciones externas encapsuladas mediante Adapter;
- servicios escalables de forma independiente.

## Escenarios de calidad

El SDD §8 define los escenarios con los que se comprueban estos atributos: QAS-01 aislamiento multi-tenant · QAS-02 concurrencia de asignación · QAS-03 disponibilidad · QAS-04 falla de notificaciones · QAS-05 modificación de regla · QAS-06 recuperación.

Una historia que toque uno de esos temas debe demostrar su escenario, no solo sus criterios funcionales.

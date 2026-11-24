# QAS-38: operaciones sensibles ↔ riesgo ↔ mitigación

Corte 2026-11-21. Análisis de riesgos revisado: SAD §23 «Riesgos arquitectónicos» (`wiki/02-arquitectura/SAD.md`), SDD §16 «Architectural Killers y mitigaciones» y su resumen en `02-arquitectura/guia/riesgos-y-puntos-abiertos.md`.

Operaciones sensibles: las cuatro que nombra el umbral (pagos, asignación, KYC, cancelación) y las demás del backlog que mueven dinero, cambian reglas o deciden sobre una persona.

| Operación sensible | Historia | Riesgo en el análisis | Mitigación registrada | ¿Figura? |
|---|---|---|---|---|
| Pago en línea al aceptar cotización | SCRUM-888 (US-07.1.1) | SDD §16 «falta de idempotencia»: pagos duplicados | idempotency keys y constraints | Sí |
| Retención y liberación de fondos (escrow) | SCRUM-891, 892 | SAD §23 «Custodia de pagos»: captación de dineros del público | custodia en operador regulado (ADR-0024) | Sí |
| Aceptar solicitud (asignación) | SCRUM-863, 1403 | SAD §23 «Doble asignación»; SDD §16 «falta de idempotencia» | exclusión atómica en PostgreSQL; idempotency keys | Sí |
| Aislamiento de datos entre tenants (transversal) | SCRUM-1364 y todas | SAD §23 «Pérdida de aislamiento multi-tenant» | JWT + autorización + RLS + pruebas | Sí |
| Aprobar o rechazar aliado (KYC) | SCRUM-848, 1066, 1384 | — | — | **No** |
| Carga y consulta de documentos KYC | SCRUM-1372, 1066 | Solo indirecto: «pérdida de aislamiento» cubre la fuga entre tenants, no la aprobación indebida ni el acceso a documentos dentro del tenant | — | **No** |
| Cancelar solicitud y penalización | SCRUM-877, 878 | — | — | **No** |
| Liquidación al aliado (comisión configurable) | SCRUM-893 | — | — | **No** |
| Cambiar tarifa de referencia por categoría | SCRUM-885 | — | — | **No** |
| Configurar reglas operativas del tenant (comisión, penalización, ventanas) | SCRUM-1366 | — | — | **No** |
| Adición de monto por imprevisto | SCRUM-872 | — | — | **No** |
| Registro inmutable de transacciones | SCRUM-889 | SDD §16 «sin observabilidad» trata el diagnóstico, no la alteración del registro | — | **No** |

**Resultado:** 4 de 12 operaciones sensibles figuran en el análisis con su mitigación (33 %). El análisis vigente es arquitectónico (estructura del sistema) y no recorre las operaciones de negocio. Faltan, entre las que nombra el umbral, **KYC** y **cancelación**.

Los controles existen en el código para varias de las que faltan (por ejemplo `MANI-SOL-409C` en cancelar dos veces, triggers de inmutabilidad en `transaccion` y `evento_servicio`, idempotencia de pagos por SCRUM-1653), pero el escenario pide que la operación figure en el análisis de riesgo, no que el control exista.

# Reporte de QA del Sprint 6

> **Finalidad:** qué midió QA en el Sprint 6, con qué resultado y qué queda pendiente. **Mantiene:** QA (Santiago Hernández). **Consume:** PO, SM, desarrollo y DevOps. **Se actualiza:** al cierre del sprint. **Versión:** 1.0, 2026-11-22. **HU:** [SCRUM-1692](https://maniservices.atlassian.net/browse/SCRUM-1692). Estados de los QAS: [SDD §8](../02-arquitectura/SDD.md) y [tabla operativa](QAS_45_ESTADO_METODO_EVIDENCIA.md).

## 1. Resultado

**Conteo final de los 45 QAS:** Cumple 18 · Parcial 14 · No cumple 7 · No medido 6. Al cierre del Sprint 5 eran 9 Cumple. Todo lo que QA podía medir por su cuenta quedó medido; lo pendiente depende de DevOps, de los equipos de desarrollo o de una decisión de la PO.

## 2. Qué se midió

| Tarea | Escenarios | Resultado | Informe |
|---|---|---|---|
| T-41 (SCRUM-1678) | 01, 20 y roles de servicio | Cumple | [t41_roles_servicio](monitoreo/evidencia/20261113T003051Z_t41_roles_servicio) |
| T-27 (SCRUM-1664) | 10 (negativos de operaciones críticas) | Parcial: falta CHECK de estado (SCRUM-1713) | [t27_qas10_negativos](monitoreo/evidencia/20261113T010545Z_t27_qas10_negativos) |
| T-44 (SCRUM-1681) | 45 (Quality Gate) | Cumple | [t44_quality_gate](monitoreo/evidencia/20261115T182000Z_t44_quality_gate) |
| T-42 (SCRUM-1679) | 03, 15, 19 | No cumple (corrida completa del 22 nov en §7) | [informe de carga](monitoreo/evidencia/20261120T192500Z_t42_carga/informe_qas03_qas15_qas19.md) |
| T-43 (SCRUM-1680) | 04, 08, 13, 21, 28, 29, 33 a 36, 38, 39, 44 | 8 Cumple, 3 Parcial, 3 No cumple | [t43_solo_medicion](monitoreo/evidencia/20261121T154000Z_t43_solo_medicion) |
| T-46 (SCRUM-1683) | 07, 41 | Cumple | [t46_concurrencia](monitoreo/evidencia/20261122T013000Z_t46_concurrencia) |
| SCRUM-1685 | 17 (recuperabilidad) | Cumple con el umbral del acta A/B | SDD §8 |
| Barrido del 22 nov | Las 22 filas sin medir del sprint, más 11, 37, 42 | 11, 16, 25, 37 y 42 Cumple | [informe del barrido](monitoreo/evidencia/20261122T025500Z_barrido_qas/informe_barrido.md) |
| QAS-14 | SAST, OWASP ZAP y rate limiting | Cumple | [informe de QAS-14](monitoreo/evidencia/20261122T032900Z_qas14_dast_sast/informe_qas14.md) |
| QAS-23 | Cobertura de casos de uso críticos | Parcial | [informe de QAS-23](monitoreo/evidencia/20261122T040500Z_qas23_cobertura/informe_qas23.md) |
| T-45 (SCRUM-1682) | 30, 31, 32 | No medido: la PO no eligió el método | — |

## 3. Bugs abiertos (Jira, 22 nov)

| Clave | Resumen | Estado | Asignado |
|---|---|---|---|
| [SCRUM-1633](https://maniservices.atlassian.net/browse/SCRUM-1633) | Pago hecho después de finalizar queda RETENIDA y no se libera | En revisión | Nicolás León |
| [SCRUM-1634](https://maniservices.atlassian.net/browse/SCRUM-1634) | Cambiar la foto de perfil no funciona en la app | En revisión | Juan Sebastián Álvarez |
| [SCRUM-1635](https://maniservices.atlassian.net/browse/SCRUM-1635) | Ver los aliados de una solicitud no funciona en la app | En revisión | Juan Sebastián Álvarez |
| [SCRUM-1636](https://maniservices.atlassian.net/browse/SCRUM-1636) | Los cambios de estado no se actualizan en vivo | Por hacer | José Nicolás Álvarez |
| [SCRUM-1713](https://maniservices.atlassian.net/browse/SCRUM-1713) | Falta CHECK de estado en `solicitud` y `cotizacion` (QAS-10) | En revisión | Nicolás León |

D-T43-1 (pooler agotado) no se abrió como bug: DevOps lo corrigió el 21 nov con el modo transacción (SCRUM-1680, comentarios 11235, 11236 y 11279).

## 4. Quality Gate por repositorio

Gate `MANI ADR-0005` sobre código nuevo: 0 issues nuevos, 100 % de hotspots revisados, cobertura ≥ 80 % y duplicación ≤ 3 %. Bloqueo probado con un PR rojo en cada repositorio (T-44):

| Repositorio | Dónde | PR de prueba bloqueado | Observación |
|---|---|---|---|
| MANI-Node (Core) | SonarQube de la VM de Calidad | #42 | — |
| MANI-Java (Rules) | SonarQube de la VM | #12 | — |
| MANI-.NET (Dispatch) | SonarQube de la VM | #35 | — |
| MANI-APIGateway | SonarQube de la VM | #96 | No exige cobertura de código nuevo (QAS-23) |
| MANI-Landing | SonarQube de la VM | #7 | — |
| MANI-Flutter | SonarCloud | #141 | 42 Critical de mantenibilidad abiertos en código existente |

## 5. Pendientes por responsable

- **DevOps:** cAdvisor por contenedor (18, 27), `mock_falla` y `STORAGE_FALLA` en QA (02, 09), cerrar el 8080 sin TLS (43), rollback con fallo forzado (44), promover la misma imagen (24), ventana para escalar (05), cabeceras CSP y anti-clickjacking (14).
- **Core y Dispatch:** SCRUM-1651 (timeout de Dispatch), menos consultas por petición y CPU del Core (03, 15, 19); actor en la aprobación de aliado (12); logs JSON (22); circuit breaker (40); segundo adaptador de pagos (26); validación de reglas solo en Rules (21); pruebas de los 3 casos críticos bajo 90 % y contract tests en CI (23).
- **Flutter:** mensaje al redirigir por rol y errores útiles (35); sistema de diseño (33).
- **PO y arquitectura:** método de T-45 (30 a 32), nivel WCAG (34), confirmaciones de QAS-39, riesgos de las 8 operaciones sensibles (38), fusionar MANI-docs#81 (06).

El detalle de cada pendiente, con su posible solución, está en la [tabla de los 45 QAS](QAS_45_ESTADO_METODO_EVIDENCIA.md).

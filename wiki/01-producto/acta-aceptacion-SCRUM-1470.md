# Acta de aceptación del incremento · Sprint 5 ([SCRUM-1470](https://maniservices.atlassian.net/browse/SCRUM-1470))

[← 01 · Producto](README.md) · [Índice](../Home.md)

| Campo | Valor |
|---|---|
| Finalidad | Dejar escrito qué acepta el PO del incremento del Sprint 5, con qué evidencia y con qué condiciones |
| Mantiene | Camila Beltrán (PO) |
| Consume | Sustentación, SM, QA |
| Frecuencia | Una por incremento |
| Versión y fecha | 1.1 · 2026-11-21 · **firmada por la PO el 2026-11-21** |
| Ambiente validado | QA (2026-11-03 a 2026-11-05) y PROD (2026-11-21) |

## 1. Evidencia

| Fuente | Qué dice |
|---|---|
| Jira, JQL del 2026-11-10 ([D11](../06-gobernanza/VALIDACION_HU-VAL-01.md)) | **84 de 85** historias del Sprint 5 en Done; **123 de 124** ítems. Abierta: SCRUM-1383 |
| [`REPORTE_QA_SPRINT5.md`](../07-calidad/REPORTE_QA_SPRINT5.md), corte 2 (2026-11-05) | Lotes por API: 806 casos pasan y 41 fallan; 45 escenarios de calidad medidos: 0 cumplen, 13 parciales, 10 no cumplen, 3 bloqueados, 19 no medidos; 5 bugs abiertos (1633 a 1637) |
| Prueba de la PO desde la app en QA (2026-11-03 y 04) | 53 pruebas de la guía de QA: 39 funcionan, 12 fallaban (10 por pantallas sin conectar, corregidas y cerradas después) y 2 sin probar |
| Prueba de la PO, corte 2 (2026-11-05) | Recorrido principal hasta la ejecución, con pago antes de iniciar y doble pago bloqueado; incompleto porque QA se cayó |
| Revisión de producción (2026-11-09 y 2026-11-14) | El 9-nov se vio un front anterior con 12 de 18 rutas rotas. El 14-nov DevOps verificó que el digest del front en producción coincide con el tag v1.0.4 y que check-prod.sh responde 200 en los 6 endpoints y las 18 rutas ([D1](../06-gobernanza/VALIDACION_HU-VAL-01.md)). Availability no es un contenedor sino un componente interno del Core Service ([`SDD.md`](../02-arquitectura/SDD.md) §4.3.3), por eso no aparece en ningún ambiente ([D5](../06-gobernanza/VALIDACION_HU-VAL-01.md#d5--servicios-por-ambiente)) |
| Recorrido de la PO en producción (2026-11-21) | Ciclo completo en PROD (v1.0.4) con las cuentas de prueba de ACME: solicitud, oferta con reglas del sitio, cotización de $30.000, ejecución con bitácora, pago después de finalizar aprobado, doble pago rechazado, liquidación con comisión del 10 % (neto $27.000), calificaciones, cierre y auditoría. Capturas en [SCRUM-1687](https://maniservices.atlassian.net/browse/SCRUM-1687). Observación: después de pagar, la pantalla del cliente sigue mostrando «Pagar» y no muestra el comprobante |

## 2. Lo que se acepta

- El ciclo completo del servicio en QA: solicitud, elegibilidad, oferta, aceptación **sin doble asignación** (probado con dos aliados en navegadores distintos), cotización con ajuste, ejecución con eventos y adiciones con tope del 50 %, pago simulado con comprobante y sin doble pago, calificación y cierre.
- Aislamiento entre empresas desde la app: ninguna cuenta de un tenant vio datos de otro.
- Las historias del M-03 (1384 a 1389) con su video aprobado.

## 3. Decisión

**Se acepta el incremento con condiciones.**

| # | Condición | Responsable | Cómo se verifica |
|---|---|---|---|
| 1 | Cifrar los datos personales de [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383). Antes, el PO define el RNF y el QAS (P-D15b) | PO (requisito), Daniel Ávila (implementación) | QAS nuevo de confidencialidad en reposo |
| 2 | Corregir los bugs [SCRUM-1633](https://maniservices.atlassian.net/browse/SCRUM-1633) a [SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637) | Equipo, según asignación de la SM | QA repite el caso que falló |
| 3 | Rendimiento bajo carga (QAS-03, 15 y 19): ampliar el pool de conexiones de Core y alinear los tiempos de Dispatch | Desarrollo con DevOps | QA repite k6 con la carga nominal |
| 4 | Decisión A/B por escenario de calidad | SM redacta, PO firma | Acta de la [SCRUM-1684](https://maniservices.atlassian.net/browse/SCRUM-1684) en `06-gobernanza` |
| 5 | La PO repite el recorrido principal en **producción** (v1.0.4, verificada en D1) | PO | Recorrido en producción con evidencia |

La firma se hace cuando se cumpla la condición 5. Las condiciones 1 a 4 no bloquean la firma: quedan como compromiso con su responsable.

## 4. Firma

| Rol | Nombre | Fecha | Firma |
|---|---|---|---|
| Product Owner | Camila Beltrán | 2026-11-21 | Aprobado |
| Scrum Master | Sara Albarracín | | |

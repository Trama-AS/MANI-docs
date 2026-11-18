# Acta de aceptación del incremento · Sprint 5 ([SCRUM-1470](https://maniservices.atlassian.net/browse/SCRUM-1470))

[← 01 · Producto](README.md) · [Índice](../Home.md)

| Campo | Valor |
|---|---|
| Finalidad | Dejar escrito qué acepta el PO del incremento del Sprint 5, con qué evidencia y con qué condiciones |
| Mantiene | Camila Beltrán (PO) |
| Consume | Sustentación, SM, QA |
| Frecuencia | Una por incremento |
| Versión y fecha | 1.0 · 2026-11-17 · **borrador, sin firma** |
| Ambiente validado | QA (2026-11-03 a 2026-11-05). Producción pendiente: ver condición 5 |

## 1. Evidencia

| Fuente | Qué dice |
|---|---|
| Jira, JQL del 2026-11-10 ([D11](../06-gobernanza/VALIDACION_HU-VAL-01.md)) | **84 de 85** historias del Sprint 5 en Done; **123 de 124** ítems. Abierta: SCRUM-1383 |
| [`REPORTE_QA_SPRINT5.md`](../07-calidad/REPORTE_QA_SPRINT5.md), corte 2 (2026-11-05) | Lotes por API: 806 casos pasan y 41 fallan; 45 escenarios de calidad medidos: 0 cumplen, 13 parciales, 10 no cumplen, 3 bloqueados, 19 no medidos; 5 bugs abiertos (1633 a 1637) |
| Prueba de la PO desde la app en QA (2026-11-03 y 04) | 53 pruebas de la guía de QA: 39 funcionan, 12 fallaban (10 por pantallas sin conectar, corregidas y cerradas después) y 2 sin probar |
| Prueba de la PO, corte 2 (2026-11-05) | Recorrido principal hasta la ejecución, con pago antes de iniciar y doble pago bloqueado; incompleto porque QA se cayó |
| Revisión de producción (2026-11-09) | `docker ps` de producción: todos los servicios con `:latest` encendidos hace 4 días; el front no corresponde a la v1.0.4 (12 de 18 rutas no existen) y **no hay contenedor de Availability** |

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
| 5 | **Producción con la v1.0.4** y el servicio Availability desplegados, y la PO repite el recorrido principal allí | Daniel Ávila (despliegue), PO (validación) | Recorrido en producción con evidencia |

La firma se hace cuando se cumpla la condición 5. Las condiciones 1 a 4 no bloquean la firma: quedan como compromiso con su responsable.

## 4. Firma

| Rol | Nombre | Fecha | Firma |
|---|---|---|---|
| Product Owner | Camila Beltrán | | |
| Scrum Master | Sara Albarracín | | |

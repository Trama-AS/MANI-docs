# SCRUM-1642 (T-05): re-prueba de SCRUM-1633 en QA con el Core actual

**Fecha:** 2026-11-13, de 00:41:37Z a 00:46:17Z (12 nov, hora Colombia)
**Ambiente:** MANI-QA. Core `cfa503a`, que contiene `098bf38` (verificado con `git merge-base --is-ancestor`).
**Cuentas:** cliente.t1 y aliado.t1. Comisión vigente de T1: 10 %.
**Resultado de la corrida:** 18 PASA, 0 FALLA.

## 1. Por qué falló el 5 nov

El chequeo "892 C1" de `qa_s5_corte2/lote_f3_qa.sh` no creó un pago nuevo. Consultó un pago ya existente, `087f7259…`, que se había creado el 5 nov a las 05:42Z.

El commit `098bf38` es de las 14:57Z del mismo día. Ese commit hace que pagar sobre una solicitud FINALIZADA o CERRADA libere la retención y liquide al aliado en la misma transacción. Por lo tanto, ese pago se retuvo con el código anterior al arreglo. Además, su solicitud ya estaba cerrada, así que no iba a pasar otra vez a FINALIZADA, que es el otro momento en que se libera.

Conclusión: el FALLA del 5 nov midió un dato viejo, no el código corregido.

## 2. Resultado

Se respeta la decisión del PO (891 y 892, 5 nov): pagar después de finalizar está permitido, y ese pago libera y liquida.

| Camino | Verificación | Resultado |
|---|---|---|
| **A** Pago con la solicitud FINALIZADA | Pago `201 APROBADO`; retención LIBERADA con fecha | PASA |
| | 1 liquidación: bruto 100 000, comisión 10 000 (10 %), neto 90 000 | PASA |
| | aliado.t1 ve el cobro liquidado; cliente.t2 recibe `404` | PASA |
| | Repetir el pago con la misma clave devuelve el mismo pago y sigue habiendo 1 sola liquidación | PASA |
| **B** Pago con la solicitud CERRADA (camino de SCRUM-1633) | Finalizar `200`, las dos calificaciones `201`, cerrar `200` → estado CERRADA | PASA |
| | Pago `201 APROBADO`; retención LIBERADA con fecha | PASA |
| | 1 liquidación: bruto 100 000, comisión 10 000, neto 90 000 | PASA |
| | aliado.t1 ve el cobro; cliente.t2 recibe `404` | PASA |
| **C** Control (892 C2) | Pago antes de finalizar → RETENIDA; al finalizar → LIBERADA | PASA |

Cada verificación tiene, en la evidencia, su `X-Correlation-ID` (`t05-…`) y la lectura en el motor (`retencion_fondos` y `liquidacion`, en modo READ ONLY).

## 3. Observación

El pago viejo `087f7259…` hoy aparece **LIBERADA**, aunque el 5 nov a las 22:57Z estaba RETENIDA. Algo lo liberó después, ya sea a mano o con un backfill. Esta re-prueba no lo explica y no forma parte del criterio. Si importa saber cómo pasó, hay que preguntarle a Nicolás.

## 4. Conclusión

SCRUM-1633 **no se reproduce** con el Core actual. Un pago hecho después de finalizar, o con la solicitud ya cerrada, libera la retención y liquida al aliado.

Según el criterio de SCRUM-1642, SCRUM-1633 se cierra con esta evidencia.

## 5. Evidencia

| Archivo | Contenido |
|---|---|
| [`t05_13nov_0041z.txt`](t05_13nov_0041z.txt) | Salida completa, con los secretos redactados |
| [`scripts/t05_qa.py`](scripts/t05_qa.py), [`scripts/correr_t05_qa.sh`](scripts/correr_t05_qa.sh) | Scripts para repetir la prueba. Se corren desde la raíz del espacio de trabajo, con los scripts en `qa_t05/` y el clon de MANI-APIGateway en `MANI-API/` (`bash qa_t05/correr_t05_qa.sh`) |

**Rastro en QA:** 3 solicitudes de prueba de cliente.t1 (`…ed2f6f45`, `…6ae49f3d` y `…cc4ad67e`), con pagos simulados liquidados y 2 calificaciones.

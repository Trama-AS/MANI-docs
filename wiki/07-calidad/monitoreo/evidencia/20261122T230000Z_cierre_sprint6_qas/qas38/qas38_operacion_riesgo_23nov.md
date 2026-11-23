# QAS-38: operaciones sensibles ↔ riesgo ↔ mitigación (remedición del 23 nov)

> Evidencia de QA. Resultado en el [SDD §8](../../../../../02-arquitectura/SDD.md). Corte anterior: [21 nov, 4 de 12](../../20261121T154000Z_t43_solo_medicion/qas38_operacion_riesgo.md). Mantiene: QA (Santiago Hernández).

**Análisis revisado:** [SAD §23.1](../../../../../02-arquitectura/SAD.md) «Riesgos de las operaciones sensibles de negocio», agregado en MANI-docs#91 (`77e7dd4`, fusionado el 23 nov).

**Lista de operaciones:** las mismas 12 que QA levantó del backlog el 21 nov. Están las cuatro que nombra el umbral: pagos, asignación, KYC y cancelación.

## Método

1. Verificar que cada operación figure en SAD §23.1 con su riesgo y su mitigación.
2. Verificar que el control descrito exista en el código desplegado en QA (MANI-Node `cdebf74`), buscando el código de error o el disparador que nombra la fila.

## Resultado

| # | Operación | ¿Figura con riesgo y mitigación? | Control encontrado en `cdebf74` |
|---|---|---|---|
| 1 | Pago al aceptar cotización | Sí | `MANI-PAG-409K` (2 archivos). Verificado en QA por T-27: la misma clave con otro cuerpo responde 409 |
| 2 | Retención y liberación de fondos | Sí | Decisión de custodia (ADR-0024). La liberación al finalizar se verificó en SCRUM-1642 |
| 3 | Asignación | Sí | Exclusión atómica y ADR-0035. Verificado por T-46 (QAS-07 y 41) |
| 4 | Aislamiento entre tenants | Sí | RLS con roles de servicio sin `BYPASSRLS` (T-41, QAS-01 y 20) |
| 5 | Aprobar o rechazar aliado (KYC) | Sí | `MANI-VER-422K` y `MANI-VER-422M` |
| 6 | Documentos KYC | Sí | `GetKycDocumentSignedUrlUseCase`: solo `ADMIN`, `MANI-VER-404` y vencimiento de 300 s por defecto, 900 s como máximo |
| 7 | Cancelar solicitud y penalización | Sí | `MANI-SOL-403C` y `MANI-SOL-409C`. Verificado en QA por T-27 |
| 8 | Liquidación con comisión | Sí | Comisión tomada de la regla del tenant; verificado en SCRUM-1642 (10 %) |
| 9 | Tarifa de referencia | Sí | Disparador `trg_tarifa_referencia_inmutable` y `MANI-TAR-409I` (migración `0030`) |
| 10 | Reglas operativas del tenant | Sí | `MANI-RGL-409C` (3 archivos) |
| 11 | Adición de monto | Sí | `MANI-ADI-409E`, `MANI-ADI-409P` y `MANI-ADI-400T` |
| 12 | Registro inmutable | Sí | Disparadores sobre `transaccion_evento` (0020) y `evento_servicio` (0042). Verificado en QA el 22 nov (barrido) |

**12 de 12 operaciones** figuran con riesgo y mitigación (100 %), y el control que describe cada fila existe en el código de QA. **QAS-38: Cumple.**

## Observaciones para arquitectura (no cambian el resultado)

- **Fila 3:** el riesgo residual dice que «Dispatch corta a los 3 s». Desde SCRUM-1651 (Dispatch `ba460e4`, en QA el 22 nov) el timeout es de 10 s. El riesgo residual sigue (QAS-03 y 19 en No cumple), pero ahora la causa es la base y el pool.
- **Fila 6:** el 23 nov QA vio que las fotos de perfil se guardan en el mismo bucket `kyc-documentos` (SCRUM-1634). Conviene decir en la fila si eso es intencional.

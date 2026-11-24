# 07 · Calidad

[← Índice de la wiki](../Home.md)

Esta carpeta responde a **qué se probó, cómo, en qué ambiente y con qué resultado**, de modo que cualquier persona pueda repetir una prueba y entender su resultado. La estrategia de pruebas vive en [`01-producto/TD.md`](../01-producto/TD.md); aquí están su ejecución y su evidencia.

> **Regla que manda sobre el tablero.** Una historia no se considera aprobada por su estado en Jira, sino por su ejecución en QA con evidencia versionada. Un escenario cuya herramienta o dependencia no está disponible se reporta como No medido, nunca como cumplido.

## Ficha de la carpeta

| Campo | Valor |
|---|---|
| **Propósito** | Que cada prueba de MANI se pueda repetir y su resultado se pueda rastrear hasta el escenario de calidad, el ADR y la historia que la originan. |
| **Responsable** | Santiago Hernández (QA) |
| **Suplente** | Camila (QA de apoyo), por confirmar con la SM |
| **Quién la consume** | Desarrollo (los seis repositorios), DevOps, la PO y la SM |
| **Cada cuánto se actualiza** | Al cierre de cada sprint (reporte de QA) y en cada corte de los escenarios QAS |
| **Última revisión** | 2026-11-22 ([SCRUM-1692](https://maniservices.atlassian.net/browse/SCRUM-1692), HU-WIKI-04) |
| **Barrido de secretos** | 2026-11-22, sobre los documentos nuevos y modificados: sin JWT (`eyJ…`), llaves de Supabase (`sb_…`), llaves de AWS, bloques de llave privada ni asignaciones `password=`. Las contraseñas de las cuentas de QA nunca se versionan. La contraseña de SonarQube que publicó la guía CFG4-03 sigue en el historial de git (ver la nota al final). |

## Orden de lectura

| # | Documento | Para qué sirve | Mantiene | Consume | Se actualiza |
|---|---|---|---|---|---|
| 1 | [`01-producto/TD.md`](../01-producto/TD.md) | Estrategia de pruebas: niveles, herramientas y criterios | QA | Todo el equipo | Cuando cambia la estrategia |
| 2 | [`guias/GUIA_PRUEBA_MANUAL_S5_CORTE2.md`](guias/GUIA_PRUEBA_MANUAL_S5_CORTE2.md) | Guía para repetir a mano el recorrido de un corte | QA | QA de apoyo | En cada corte manual |
| 3 | [`REPORTE_QA_SPRINT6.md`](REPORTE_QA_SPRINT6.md) | **Reporte vigente.** Qué se midió en el Sprint 6, bugs abiertos, Quality Gate y pendientes | QA | PO, SM, equipos | Al cierre del sprint |
| 3a | [`REPORTE_QA_SPRINT5.md`](REPORTE_QA_SPRINT5.md) | Reporte del Sprint 5, corte 2 (histórico) | QA | Consulta | Congelado |
| 3b | [`monitoreo/REPORTE_QA_SPRINT4.md`](monitoreo/REPORTE_QA_SPRINT4.md) | Reporte único del Sprint 4: ambientes, cadena de calidad, QAS-01 a 09, regresión (histórico) | QA | Consulta | Congelado |
| 4 | [`QAS_45_ESTADO_METODO_EVIDENCIA.md`](QAS_45_ESTADO_METODO_EVIDENCIA.md) | Los 45 QAS con estado, herramienta, evidencia, qué falta y posible solución. La fuente es el [SDD §8](../02-arquitectura/SDD.md) | QA | Todo el equipo | En cada corte de QAS |
| 5 | [`regresion/`](regresion) y [`MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md`](MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md) | Matrices de pruebas y de ejecución, y qué historia toca qué repositorio | QA | Desarrollo, PO | Por sprint |
| 6 | [`REPORTE_QA_SPRINT6.md` §3](REPORTE_QA_SPRINT6.md#3-bugs-abiertos-jira-22-nov) | Bugs abiertos | QA | Equipos | Al cierre del sprint |
| 7 | [`REPORTE_QA_SPRINT6.md` §4](REPORTE_QA_SPRINT6.md#4-quality-gate-por-repositorio) | Quality Gate por repositorio | QA | Desarrollo, DevOps | Cuando cambia el gate |

Documentos de apoyo: [`monitoreo/REPORTE_SEGURIDAD_IDENTIDAD_H01_H02.md`](monitoreo/REPORTE_SEGURIDAD_IDENTIDAD_H01_H02.md) (hallazgos de identidad), [`monitoreo/SPRINT4_INDICADORES_Y_ACUERDOS.md`](monitoreo/SPRINT4_INDICADORES_Y_ACUERDOS.md) y [`monitoreo/SPRINT4_IMPEDIMENTOS_Y_TRAZABILIDAD.md`](monitoreo/SPRINT4_IMPEDIMENTOS_Y_TRAZABILIDAD.md) (históricos).

## Carpetas

| Carpeta | Qué contiene |
|---|---|
| [`monitoreo/`](monitoreo/README.md) | Arnés de los QAS (Newman, k6, scripts de verificación, redactor de evidencia) |
| [`monitoreo/evidencia/`](monitoreo/evidencia) | Una carpeta por corrida, con nombre `AAAAMMDDTHHMMSSZ_tarea`. Cada una trae su informe, las salidas y los scripts para repetirla |
| [`guias/`](guias) | Guías de prueba manual por corte |
| [`regresion/`](regresion) | Matrices del Sprint 4 y plan de regresión de US-02.1.1-M4 |
| [`PoC/`](PoC) | Pruebas de concepto: exclusión concurrente, identidad de servicio con RLS y versionado de eventos |
| `td_v2/` | **Obsoleta.** Retirada en el commit `ea8076b`; la medición queda congelada en [`Entregas/Entrega6/7.TD_V2.pdf`](../../Entregas/Entrega6/7.TD_V2.pdf) |

## Qué ambiente prueba cada herramienta

**QA confirma QA, no lo promovido a PROD.** Un resultado en QA no se extrapola a PROD.

| Herramienta | Ambiente | Para qué |
|---|---|---|
| Newman | QA (`10.43.100.141`, Gateway 8080) | Contratos, negativos y regresión de API |
| k6 | QA, lanzado desde la VM de Calidad (`10.43.98.196`) | Carga, concurrencia (QAS-03, 15, 19, 41) |
| OWASP ZAP | QA | DAST (QAS-14) |
| Prueba manual y Playwright | QA | Recorridos de interfaz |
| SonarQube y SonarCloud | Rama `develop` de cada repositorio | SAST, cobertura y Quality Gate |
| Prometheus (blackbox) | QA y PROD (`10.43.98.203`), solo sondas | Disponibilidad (QAS-16) |
| `flutter test`, `node --test`, `dotnet test`, `mvn test` | Código de `release` o `develop`, local o CI | Pruebas unitarias y cobertura |

## Proceso de reporte de fallas

1. **Reproducir** en QA y anotar: clave de la historia, paso exacto, cuenta usada (correo, nunca la contraseña), hora en UTC y correlation ID de la respuesta.
2. **Guardar la evidencia** (salida, captura o log) en la carpeta de la corrida.
3. **Registrar en Jira:** si la falla está en una historia cerrada, se abre un **Bug** enlazado a esa historia, sin reabrirla. Si la historia sigue abierta, se comenta en ella.
4. **Seguir:** el bug se lista en el reporte de QA del sprint hasta que se cierre con una nueva prueba en QA.

## Trazabilidad

Cada escenario sigue la cadena necesidad → requisito → atributo de calidad → ADR → componente → prueba. La cadena hasta el ADR está en el [SDD §8](../02-arquitectura/SDD.md) (columnas de estímulo, artefacto y medida); la prueba y su evidencia, en la [tabla de los 45 QAS](QAS_45_ESTADO_METODO_EVIDENCIA.md) y en el informe de cada corrida, que cita su historia de Jira.

## Documentos absorbidos y obsoletos

Se marcan, no se borran. El 23 de octubre de 2026 se reunieron en el reporte del Sprint 4 cinco documentos sueltos: `ACTA_AUDITORIA_DEV_QA_CFG4-01.md` (§2), `GUIA_OPERATIVA_CALIDAD_QA_CFG4-03.md` (§3), `PLAN_PRUEBAS_EP-02_MIGRACION.md` (§6), `REPORTE_QA_MONITOREO_QAS_SCRUM-1266.md` (§7) y `REPORTE_QA_REGRESION_SCRUM-1267.md` (§8). El acta de consolidación de PostgreSQL vive en [`Entregas/Entrega4/`](../../Entregas/Entrega4).

## Qué falta para cerrar HU-WIKI-04

- Que otro responsable de carpeta revise y apruebe este README (criterio común de las 8 HU de wiki).
- Confirmar con la SM la suplencia de la carpeta.
- Enlazar las discrepancias de HU-VAL-01 que correspondan a esta carpeta, cuando estén publicadas.
- Agregar cabecera (finalidad, mantenedor, versión y fecha) a los documentos históricos del Sprint 4 y 5 que no la tienen.

## Nota de seguridad

La guía CFG4-03 original publicaba la contraseña de administrador de SonarQube y el token global de análisis. Los documentos vigentes los tienen redactados, pero **siguen en el historial de git** (sin reescritura de historial por decisión del proyecto).

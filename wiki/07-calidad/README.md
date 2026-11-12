# 07 · Calidad

[← Índice de la wiki](../Home.md)

**Fuente:** [`REPORTE_QA_SPRINT4.md`](monitoreo/REPORTE_QA_SPRINT4.md) · [`01-producto/TD.md`](../01-producto/TD.md).

Esta carpeta responde a **qué se probó, cómo y con qué resultado**. La estrategia de pruebas vive en [`TD.md`](../01-producto/TD.md); aquí está su ejecución y su evidencia.

> **Regla que manda sobre el tablero.** Una historia no se considera aprobada por su estado en Jira, sino por su ejecución en QA con evidencia versionada. Un escenario cuya herramienta o dependencia no está disponible se reporta como bloqueado o no medible, nunca como cumplido.

## Documentos

| Documento | De qué responde |
|---|---|
| [`REPORTE_QA_SPRINT4.md`](monitoreo/REPORTE_QA_SPRINT4.md) | **Reporte único de QA del Sprint 4.** Ambientes (§2), cadena de calidad (§3), calidad estática (§4), plan de pruebas (§5), paridad de EP-02 (§6), monitoreo y QAS-01 a QAS-09 (§7), regresión funcional, API, E2E y multi-tenant (§8), [defectos consolidados](monitoreo/REPORTE_QA_SPRINT4.md#9-defectos-consolidados-del-sprint) (§9), DoD y gates (§10), pendientes (§11), índice de evidencia (§12) y trazabilidad (§13) |
| [`REPORTE_QA_SPRINT5.md`](REPORTE_QA_SPRINT5.md) | **Reporte de QA del Sprint 5, corte 2.** Estado de QA, prueba manual del flujo, matriz por historia, 45 escenarios QAS y lo que falta ejecutar. |
| [`REPORTE_SEGURIDAD_IDENTIDAD_H01_H02.md`](monitoreo/REPORTE_SEGURIDAD_IDENTIDAD_H01_H02.md) | Los dos hallazgos de identidad, H-01 y H-02, con su análisis de seguridad |
| `MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md` | Qué historia toca qué repositorio (SCRUM-1256). **Retirado del repositorio** en el commit `ea8076b`; su texto está en el historial de git |
| [`SPRINT4_INDICADORES_Y_ACUERDOS.md`](monitoreo/SPRINT4_INDICADORES_Y_ACUERDOS.md) | Indicadores del sprint y acuerdos del equipo (SCRUM-1242) |
| [`SPRINT4_IMPEDIMENTOS_Y_TRAZABILIDAD.md`](monitoreo/SPRINT4_IMPEDIMENTOS_Y_TRAZABILIDAD.md) | Impedimentos del sprint y su trazabilidad (SCRUM-1243) |
| [`ACTA_CONSOLIDACION_POSTGRESQL_CFG4-02.md`](../../Entregas/Entrega4/ACTA_CONSOLIDACION_POSTGRESQL_CFG4-02.md) | Acta de la consolidación de PostgreSQL en Supabase. Salió de esta carpeta en el commit `ea8076b`; la copia congelada vive en [`Entregas/Entrega4/`](../../Entregas/Entrega4) |

## Carpetas

| Carpeta | Qué contiene |
|---|---|
| [`monitoreo/`](monitoreo/README.md) | Arnés de los escenarios QAS: Newman, k6, scripts de verificación, redactor de evidencia y las corridas en `evidencia/` |
| [`regresion/`](regresion) | Matriz de pruebas y matriz de ejecución del Sprint 4, el plan de regresión de US-02.1.1-M4 y su evidencia |
| `td_v2/` | Evidencia que respaldaba el TD V2. **Retirada del repositorio** en el commit `ea8076b`; la medición queda congelada en [`Entregas/Entrega6/7.TD_V2.pdf`](../../Entregas/Entrega6/7.TD_V2.pdf) |
| [`PoC/`](PoC) | Pruebas de concepto: exclusión concurrente, identidad de servicio con RLS y versionado de eventos |

## Qué absorbió el reporte único

El 23 de octubre de 2026 se reunieron en [`REPORTE_QA_SPRINT4.md`](monitoreo/REPORTE_QA_SPRINT4.md) cinco documentos que estaban sueltos. Se citan por su sección:

| Antes | Ahora |
|---|---|
| `ACTA_AUDITORIA_DEV_QA_CFG4-01.md` | [§2 Ambientes DEV y QA](monitoreo/REPORTE_QA_SPRINT4.md#2-ambientes-dev-y-qa-cfg4-01) |
| `GUIA_OPERATIVA_CALIDAD_QA_CFG4-03.md` | [§3 Cadena de calidad](monitoreo/REPORTE_QA_SPRINT4.md#3-cadena-de-calidad-en-qa-cfg4-03) |
| `PLAN_PRUEBAS_EP-02_MIGRACION.md` | [§6 Paridad de EP-02](monitoreo/REPORTE_QA_SPRINT4.md#6-antecedente-plan-de-paridad-de-las-historias-migradas-de-ep-02-scrum-1094) y anexo B |
| `REPORTE_QA_MONITOREO_QAS_SCRUM-1266.md` | [§7 Monitoreo y QAS](monitoreo/REPORTE_QA_SPRINT4.md#7-monitoreo-de-qa-y-escenarios-qas-01-a-qas-09-scrum-1266) |
| `REPORTE_QA_REGRESION_SCRUM-1267.md` | [§8 Regresión](monitoreo/REPORTE_QA_SPRINT4.md#8-regresión-funcional-api-e2e-y-multi-tenant-scrum-1267) |

## Nota de seguridad pendiente

La guía CFG4-03 original publicaba la contraseña de administrador de SonarQube y el token global de análisis. El reporte no los reproduce, pero **siguen en el historial de git**: hay que rotarlos. Registrado por QA en el PR que consolidó esta carpeta.

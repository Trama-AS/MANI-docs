# 01 · Producto

[← Índice de la wiki](../Home.md)

**Fuente:** [`SRS.md`](SRS.md) · [`README.md`](../../README.md) del repositorio.

**Qué responde esta carpeta:** qué se construye, para quién, qué se dejó fuera, qué decidió el PO y qué se aceptó.

## Ficha de la carpeta

| Campo | Valor |
|---|---|
| **Propósito** | Que cualquier integrante sepa qué hace MANI, por qué, con qué reglas de negocio y qué se aceptó de cada incremento, y pueda rastrear cada decisión de producto hasta su historia en Jira. |
| **Responsable** | Camila Beltrán (Product Owner) |
| **Suplente** | Sara Albarracín (Scrum Master). Ver [§1.1](#11-suplencia). |
| **Quién la consume** | Desarrollo (qué construir y con qué criterio), QA (de dónde salen los casos de prueba), Arquitectura (qué requisito origina cada decisión) y la sustentación (qué se entregó). |
| **Cada cuánto se actualiza** | Al cerrar cada sprint, y el mismo día en que el PO toma una decisión de producto. |
| **Última revisión de la carpeta** | 2026-11-17 ([SCRUM-1689](https://maniservices.atlassian.net/browse/SCRUM-1689), HU-WIKI-01) |
| **Barrido de secretos** | 2026-11-17: sin credenciales en la carpeta. Se buscaron valores, no palabras: JWT (`eyJ…`), llaves de Supabase (`sb_…`), llaves de AWS (`AKIA…`), bloques `BEGIN … PRIVATE KEY` y asignaciones del tipo `password=…`, `secret=…`, `token=…`. **0 coincidencias.** Las cuentas de prueba de QA **no** se publican aquí. |

La carpeta tiene dos capas, y cada documento vive en una sola:

| Capa | Qué es | Dónde |
|---|---|---|
| Páginas de lectura | Ordenan y resumen; no deciden | `vision-y-alcance.md`, `actores-y-ciclo-del-servicio.md`, `requisitos.md`, `criterios-de-exito.md`, `mapa-de-modulos.md` |
| Fuentes | Lo que manda: requisitos, decisiones del PO, actas, estrategia de pruebas y reespecificaciones | `SRS.md`, `decisiones-del-po.md`, `acta-aceptacion-SCRUM-1470.md`, `TD.md`, `reespecificacion-cobertura-US-02.1.4-R1.md` |

Si una página de lectura y una fuente se contradicen, manda la fuente. Si el SRS y una decisión del PO posterior se contradicen, manda la decisión del PO con su fecha, y el SRS se corrige.

### 1.1 Suplencia

Decidido por la PO el 2026-11-17. Suple la **Scrum Master**, porque ya es quien facilita y redacta las actas que firma el PO ([`VALIDACION_HU-VAL-01.md`](../06-gobernanza/VALIDACION_HU-VAL-01.md), fila D12) y quien registra las decisiones del PO en la wiki. La suplencia cubre **mantener** la carpeta; **no** cubre decidir: si falta la PO, una decisión de producto espera o se escala según [Roles y decisiones](../04-proceso/roles-y-decisiones.md).

## 1. Orden de lectura

| # | Qué leer | Dónde | Por qué va aquí |
|---|---|---|---|
| 1 | **Visión y alcance**: qué resuelve MANI y qué entra en el MVP | [Visión y alcance](vision-y-alcance.md) | Sin el problema, nada de lo demás tiene sentido |
| 2 | **Actores y ciclo del servicio** | [Actores y ciclo del servicio](actores-y-ciclo-del-servicio.md) | Quién usa el sistema y por qué pasos avanza un servicio |
| 3 | **Mapa de módulos M-01 a M-13 con su dueño** | [Mapa de módulos](mapa-de-modulos.md) | Cómo se reparte el producto y a quién preguntar |
| 4 | **Requisitos y reglas de negocio** | [`SRS.md`](SRS.md) §3, §4 y §6, y su índice [Requisitos](requisitos.md) | Qué debe hacer el sistema y con qué restricciones |
| 5 | **Decisiones del PO** (con fecha y enlace a Jira) | [Decisiones del PO](decisiones-del-po.md) | Precisan o cambian reglas del SRS; mandan sobre él |
| 6 | **Criterios de éxito y actas de aceptación** | [Criterios de éxito](criterios-de-exito.md) y [Acta de la SCRUM-1470](acta-aceptacion-SCRUM-1470.md) | Qué se considera terminado y qué se aceptó del incremento |

## 2. Documentos

| Documento | Finalidad | Mantiene | Consume | Frecuencia | Versión y fecha |
|---|---|---|---|---|---|
| [`SRS.md`](SRS.md) | Requisitos funcionales, no funcionales, restricciones de proyecto y de producto, interfaces externas. Fuente de las reglas de negocio | PO | Todo el equipo | Cuando cambia un requisito | Vivo · 2026-11-16 |
| [`decisiones-del-po.md`](decisiones-del-po.md) | Registro de las decisiones de producto, con fecha, motivo y enlace a la historia | PO | Desarrollo, QA, Arquitectura | El día de cada decisión | 1.0 · 2026-11-17 |
| [`acta-aceptacion-SCRUM-1470.md`](acta-aceptacion-SCRUM-1470.md) | Acta de aceptación del incremento del Sprint 5 | PO | Sustentación, SM | Al cerrar cada incremento | 1.0 · 2026-11-17 (borrador, sin firma) |
| [`mapa-de-modulos.md`](mapa-de-modulos.md) | Módulos M-01 a M-13 con épica, dueño y estado al cierre del Sprint 5 | PO | Todo el equipo | Al cerrar cada sprint | 1.0 · 2026-11-17 |
| [`vision-y-alcance.md`](vision-y-alcance.md) | Problema, MVP y fuera de alcance (resume el SRS §1 y §2) | PO | Todo el equipo, sustentación | Cuando cambia el alcance | Vivo · 2026-11-16 |
| [`actores-y-ciclo-del-servicio.md`](actores-y-ciclo-del-servicio.md) | Actores y estados del servicio (resume el SRS §2.3) | PO | Desarrollo, QA | Cuando cambia un actor o un estado | Vivo · 2026-11-16 |
| [`requisitos.md`](requisitos.md) | Índice navegable de RF, RNF y restricciones (resume el SRS §3, §4 y §6) | PO | Desarrollo, QA | Cuando cambia el SRS | Vivo · 2026-11-16 |
| [`criterios-de-exito.md`](criterios-de-exito.md) | Los tres niveles de «terminado»: historia, incremento y transición | PO con SM | Todo el equipo | Por sprint | Vivo · 2026-11-16 |
| [`TD.md`](TD.md) | Estrategia de pruebas. El resultado de ejecutarla vive en [07-calidad](../07-calidad/README.md) | Santiago Hernández (QA) | QA, Desarrollo | Por sprint | V2 · 2026-10-21. **Desactualizado:** la V3 del Sprint 5 vive en [`REPORTE_QA_SPRINT5.md`](../07-calidad/REPORTE_QA_SPRINT5.md) |
| [`reespecificacion-cobertura-US-02.1.4-R1.md`](reespecificacion-cobertura-US-02.1.4-R1.md) | Reespecificación de la cobertura por catálogo jerárquico hasta barrio (SCRUM-1067). **Restaurado el 2026-11-12** desde `ea8076b^`: se había retirado en `ea8076b` sin que su contenido pasara a ningún otro documento | José Nicolás Álvarez | Desarrollo, QA | Cerrado | R1 · 2026-10-26. Implementado en [SCRUM-1385](https://maniservices.atlassian.net/browse/SCRUM-1385) (Finalizada) |

Cada documento enlaza su origen y su destino: **necesidad** (visión) → **requisito** (SRS) → **atributo de calidad** ([`SDD.md`](../02-arquitectura/SDD.md) §7 y §8) → **ADR** ([`adr/`](../02-arquitectura/adr/)) → **componente** (SAD) → **prueba** ([07-calidad](../07-calidad/README.md)). Las decisiones del PO enlazan además su historia en Jira.

El SRS define **qué** debe hacer el sistema. Cómo se construye está en [02-arquitectura](../02-arquitectura/README.md); cómo se trabaja, en [04-proceso](../04-proceso/README.md); qué se probó y con qué resultado, en [07-calidad](../07-calidad/README.md).

## 3. Qué decide el PO y qué decide la SM

Según [Roles y decisiones](../04-proceso/roles-y-decisiones.md) y [`GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §2.3:

| Decide el **PO** | Decide la **SM** |
|---|---|
| Prioridad del backlog y alcance del sprint | Reglas de proceso |
| Criterios de aceptación de cada historia | Umbrales de los indicadores del equipo (KPI) |
| Aceptación del incremento (actas) | Declarar un bloqueo relevante |
| Requisitos y reglas de negocio | Si un desarrollador no alcanza, se escala a la SM, no al PO |
| Aprobación de la documentación | Facilita y redacta las actas que firma el PO |

Las decisiones de arquitectura son de la **Mesa de Arquitectura** (ADR), y liberar a producción es de **DevOps**.

## 4. Cifras finales del Sprint 5

| Cifra | Valor | Fuente y corte |
|---|---|---|
| Historias del Sprint 5 en Done | **84 de 85** | JQL `project = SCRUM AND sprint = "SCRUM Sprint 5" AND issuetype = Historia`, 2026-11-10 ([`VALIDACION_HU-VAL-01.md`](../06-gobernanza/VALIDACION_HU-VAL-01.md), D11) |
| Ítems del Sprint 5 en Done | **123 de 124** | Misma consulta sin filtrar por tipo |
| Historia abierta | [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383) (HU-M02-15, cifrado de datos sensibles), `Reopened` | Ídem |

Las cifras `82/85`, `510 SP` y `532/537` circularon antes del lote `backlog-9nov` y **no se reproducen**: no se usan.

## 5. Discrepancias de HU-VAL-01 que tocan esta carpeta

| Fila | Tema | Estado | Dónde quedó |
|---|---|---|---|
| D2 / P-D2 | Pagar después de finalizar | Decidido por el PO | [Decisiones del PO](decisiones-del-po.md#pagos) |
| D11 | Cifras del Sprint 5 | Verificado: 84/85 | [§4](#4-cifras-finales-del-sprint-5) |
| D13 | HU-M04-05 sin historia en Jira | Decidido: se retira del plan | [Decisiones del PO](decisiones-del-po.md#catálogo) |
| D14 / P-D14 | Jardinería activa en PROD | Decidido por el PO | [Decisiones del PO](decisiones-del-po.md#catálogo) |
| P-D15b | Cifrado de datos personales | **Abierto: faltan un RNF y un QAS de confidencialidad en reposo**, que son del PO | Pendiente en [`SRS.md`](SRS.md) §6.1 |

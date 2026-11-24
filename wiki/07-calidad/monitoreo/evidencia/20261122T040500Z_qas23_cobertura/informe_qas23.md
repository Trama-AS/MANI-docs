# QAS-23 (capacidad para ser probado): cobertura de casos de uso críticos

> Evidencia de QA del Sprint 6. Resultado en el [SDD §8](../../../../02-arquitectura/SDD.md). Mantiene: QA (Santiago Hernández).

22 de noviembre de 2026, 04:05Z a 04:15Z. Pruebas de `release` (Core `73c28f4`, Dispatch `eedb112`, Rules `348f6d9`) con cobertura, en una copia aparte de cada repositorio.

**Umbral (SDD §8):** cobertura de código nuevo ≥ 80 %; casos de uso críticos ≥ 90 %; contract tests obligatorios.

## 1. Resultado

| Parte | Medición | Cumple |
|---|---|---|
| Código nuevo ≥ 80 % | El gate `MANI ADR-0005` lo exige en Node, Java, .NET, Landing y Flutter. **El Gateway lo excluye.** | En 5 de 6 |
| Casos de uso críticos ≥ 90 % | Core 97,2 % en conjunto, Rules 100 %, Dispatch 86 a 94 %. **3 casos por debajo de 90 %** (§2). | No del todo |
| Contract tests obligatorios | Solo el CI del Gateway los exige (`validate:openapi`, Spectral y gate de contrato con Newman). Core tiene contract tests de proveedores y de reglas dentro de su suite; Dispatch y Rules no tienen. | No |
| Casos de prueba por historia crítica | 51 de 51 historias críticas con caso en las matrices (QAS-28, T-43). | Sí |

**Estado: Parcial.**

## 2. Cobertura por caso de uso crítico (líneas)

**Core** (`npm run test:coverage`, 1.490 pruebas pasan, 0 fallan, 214 omitidas porque necesitan base de datos):

| Caso de uso | Líneas | % | Ramas % |
|---|---|---|---|
| Crear solicitud | 136/138 | 98,6 | 91,9 |
| Asignar (aceptar) solicitud | 51/51 | 100 | 90,5 |
| Cancelar solicitud | 50/50 | 100 | 100 |
| Cotizar | 75/75 | 100 | 100 |
| Responder cotización | 69/69 | 100 | 92,6 |
| Pagar | 157/157 | 100 | 97,4 |
| Retención y liberación | 40/42 | 95,2 | 81,8 |
| **Aprobar aliado (KYC)** | 114/128 | **89,1** | 80,5 |
| Tarifa de referencia | 172/172 | 100 | 91,1 |
| **Reglas del tenant** | 64/72 | **88,9** | 69,2 |
| Elegibles (Core) | 80/80 | 100 | 100 |
| Ejecución y cierre | 328/341 | 96,2 | 89,7 |
| **Total** | 1.336/1.375 | **97,2** | |

Todo `src` del Core: 86,4 %.

**Dispatch** (`dotnet test` con coverlet; 273 pasan, las 22 que fallan son pruebas de integración con Testcontainers y no corrieron porque Docker estaba apagado; ninguna de ellas usa los casos de uso de oferta):

| Caso de uso | Líneas | % |
|---|---|---|
| Orquestar despacho | 97/103 | 94,2 |
| Elegibles | 164/175 | 93,7 |
| **Aceptar oferta** | 25/29 | **86,2** |
| Rechazar oferta | 57/65 | 87,7 |
| Ofertas del aliado | 19/21 | 90,5 |

Lo que falta en aceptar y rechazar oferta son validaciones de entrada (`RequestId` vacío o no UUID) y los rechazos por aliado sin perfil o sin verificar.

**Rules** (`mvn test`, 142 de 142): `AllyRanker`, `RateEvaluator`, `CategoryRuleEvaluator`, `TenantRulesValidator` y `CriterioRanking` al **100 %** de líneas. Total del servicio: 99,5 %.

## 3. Hallazgos

| # | Hallazgo | Responsable sugerido |
|---|---|---|
| H-23-1 | El gate del Gateway no exige cobertura de código nuevo. | DevOps |
| H-23-2 | Core, Dispatch y Rules no tienen contract tests obligatorios contra su contrato OpenAPI en el CI. | Equipos de Core, Dispatch y Rules |
| H-23-3 | Aprobar aliado (89,1 %), reglas del tenant (88,9 %) y aceptar oferta (86,2 %) quedan por debajo de 90 %. | Equipos de Core y Dispatch |
| H-23-4 | El `pom.xml` de Rules usa JaCoCo 0.8.12, que no soporta Java 25; con un JDK nuevo hay que usar 0.8.14. En CI, con su JDK, funciona. | Equipo de Rules |

## 4. Método y evidencia

- Casos de uso críticos: las operaciones de QAS-10 (crear, aceptar, cotizar, responder cotización, cancelar, pagar, aprobar aliado, cambiar tarifa) más retención, reglas del tenant, elegibles, ejecución y cierre en Core; orquestar, elegibles y ofertas en Dispatch; ranking, tarifa, categorías y reglas en Rules.
- Para Rules se usó JaCoCo 0.8.14 en la copia aparte (el repositorio no se modificó). Para Dispatch, SDK 10 con roll forward a net8.
- `qas23_corridas_22nov.txt`: resumen de las tres corridas. `core_lcov_release.info`, `dispatch_cobertura_release.xml` y `rules_jacoco_release.xml`: reportes de cobertura.

# Revisión: escenarios de calidad sin requisito que los respalde

[← Índice de la wiki](../Home.md) · [← 06 Gobernanza](README.md)

| Campo | Valor |
|---|---|
| **Estado** | **PROPUESTA, PENDIENTE DE PO.** Ninguna fila de este documento es una decisión. Nada de aquí se lleva a la sustentación como hecho. |
| **Finalidad** | Recorrer los 45 escenarios de calidad del SDD contra los once requisitos no funcionales del SRS y decir, uno por uno, cuáles **no tienen un requisito detrás**. Un escenario sin requisito compromete a QA a medir algo que nadie pidió. |
| **Origen** | Bloqueo **B-09** de [`REGISTRO_BLOQUEOS.md`](REGISTRO_BLOQUEOS.md), y la tercera causa recurrente que registra: «el requisito que la decisión debería cumplir no existe». Apareció dos veces por casualidad, al decidir D4 (recuperabilidad) y P-D15a (cifrado), nunca por una revisión. Esta es la revisión. |
| **Redacta** | Sara Albarracín (SM), como propuesta |
| **Decide** | María Camila Beltrán (PO): los requisitos son suyos ([`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §2.3) |
| **Versión** | 1.0 · corte 2026-11-11 |

> **Lo que este documento no hace.** No crea requisitos, no cambia umbrales, no retira escenarios y no toca el SDD. Propone una clasificación para que el PO decida qué hacer con cada grupo.

## 1. El hallazgo estructural, antes de las filas

**No existe en ningún artefacto un mapeo de escenario de calidad a requisito.** Comprobado en los tres sitios donde debería estar:

| Dónde se buscó | Qué hay |
|---|---|
| Tabla de los 45 QAS, [`SDD.md`](../02-arquitectura/SDD.md) §8 | Columnas de atributo, prioridad, estímulo, entorno, artefacto, respuesta, umbral, método y estado. **No hay columna de requisito de origen.** |
| Cuerpo del SDD | Solo **cinco** RNF aparecen citados en todo el documento, y en prosa: RNF-03, RNF-04, RNF-05, RNF-07 y RNF-10. Los otros seis no se mencionan. |
| [`SRS.md`](../01-producto/SRS.md) §7, «Trazabilidad mínima» | Agrupa RF y RNF por tema y **se detiene ahí**: no llega a los escenarios de calidad. |

Por eso la cadena `necesidad → requisito → atributo de calidad → ADR → componente → prueba` que exigen las ocho HU de wiki **está cortada en el segundo eslabón para la mayoría de los escenarios**. Las asignaciones de la §2 son interpretación por contenido hecha en esta revisión, no citas: ninguna está escrita en un artefacto vigente.

## 2. Los once RNF y lo que cubren

| RNF | Requisito | Prioridad | Escenarios que lo cubren |
|---|---|---|---|
| **RNF-01** | Aislamiento estricto entre tenants, verificable por el servidor | Crítica | QAS-01, QAS-10, QAS-13 |
| **RNF-02** | Cada tenant configura sus reglas sin código ni despliegue | Crítica | QAS-04, QAS-24 |
| **RNF-03** | Operaciones críticas resistentes a reintentos, sin duplicados | Alta | QAS-42, y en parte QAS-02 y QAS-09 |
| **RNF-04** | Trazabilidad y auditabilidad suficientes | Alta | QAS-11, QAS-12, QAS-22 |
| **RNF-05** | Aceptaciones concurrentes deterministas, una asignación por solicitud | Alta | QAS-41 |
| **RNF-06** | PCI DSS recae en el operador de pagos, no en MANI | Alta | **Ninguno, y es correcto:** es una exclusión de responsabilidad, no una propiedad del sistema. No debe tener escenario |
| **RNF-07** | Concurrencia en consultas, aceptación y comunicación; **remite al SDD §7.4 y a QAS-03 para las cifras** | Media | QAS-03, QAS-18, QAS-19 |
| **RNF-08** | Interfaz utilizable desde dispositivos móviles | Media | QAS-30, QAS-32, QAS-34 |
| **RNF-09** | Cobertura por zonas geográficas, no por radio | Alta | QAS-07, en parte |
| **RNF-10** | KYC, tiempos, comisiones y penalizaciones configurables por tenant | Alta | QAS-04, QAS-24 |
| **RNF-11** | Pagos centralizados con operador certificado | Media | **Ninguno.** Es una restricción de diseño, no un umbral medible; su cumplimiento se acredita con ADR-0024, no con un escenario |

**Trece escenarios de 45 tienen un requisito detrás.** RNF-01 es el único Crítica con cobertura sólida.

## 3. Escenarios sin requisito, por grupo

### 3.1 Grupo A — Prioridad P1 sin requisito: once escenarios

Son los graves. Cada uno compromete a QA a medir un umbral que **ningún requisito pidió**, y todos están marcados P1, es decir, exigibles.

| QAS | Atributo | Umbral que compromete | De dónde sale, si no es de un RNF | Qué propongo |
|---|---|---|---|---|
| **QAS-05** | Escalabilidad | Escalar de 2 a 6 réplicas sin cambio de código | De la arquitectura objetivo (Kubernetes, HPA). INFRA-01 e INFRA-02 están **abiertos** y QA corre en Docker Compose | **Bajar a P2 o declarar no exigible en el MVP** hasta que exista un RNF de escalabilidad. Hoy es no medible por diseño |
| **QAS-14** | Resistencia | — | Parcialmente de RNF-03, pero resistencia no es idempotencia | Anclar a RNF-03 ampliándolo, o crear RNF |
| **QAS-15** | Ausencia de fallos | — | Ningún RNF | Revisar si es un escenario o una aspiración |
| **QAS-16** | Disponibilidad | **≥ 99.9% mensual** para APIs críticas | Ningún RNF exige disponibilidad. El umbral es del SDD | **Crear un RNF de disponibilidad o bajar el umbral a algo que el MVP pueda sostener.** 99.9% con una VM sin monitoreo no es sostenible |
| **QAS-17** | Recuperabilidad | `RPO ≤ 5 min` y `RTO ≤ 30 min` | Ningún RNF exige recuperabilidad. **Ya detectado al decidir D4** | **Crear RNF de recuperabilidad.** La decisión D4 mantuvo el umbral porque era el único documentado, no porque un requisito lo pida |
| **QAS-20** | Modularidad | El servicio no accede a datos de otro dominio | De ADR-0030 y ADR-0022, que son decisiones | Aceptable que nazca de un ADR; **anotarlo así** en vez de dejarlo sin origen |
| **QAS-23** | Capacidad para ser probado | — | De la política DevOps | Igual: anclar a la política, no a un RNF inexistente |
| **QAS-25** | Instalabilidad | — | Ningún RNF | Revisar prioridad |
| **QAS-43** | Confidencialidad **en tránsito** (TLS) | TLS en el perímetro | RNF-01 cubre aislamiento entre tenants, **no cifrado de transporte** | Anclar a un RNF de protección de datos, el mismo que falta para B-09 |
| **QAS-44** | Reversión de despliegue | — | De ADR-0004 | Anclar al ADR explícitamente |
| **QAS-45** | Quality Gate de código nuevo | — | De la política DevOps y SonarQube | Anclar a la política explícitamente |

### 3.2 Grupo B — P2 y P3 sin requisito: diecinueve escenarios

QAS-06, QAS-08, QAS-21, QAS-26, QAS-27, QAS-28, QAS-29, QAS-31, QAS-33, QAS-35, QAS-36, QAS-37, QAS-38, QAS-39 y QAS-40.

No son urgentes por su prioridad, pero **inflan la cuenta de 45**: el equipo presenta 45 escenarios de calidad cuando una parte no responde a ningún requisito del producto. QAS-28 (completitud funcional) y QAS-29 (pertinencia funcional) son el caso más claro: miden el conjunto de los RF, no un RNF, y probablemente no deberían ser escenarios.

**Propuesta para este grupo:** no crear requisitos para cubrirlos. Decidir, escenario por escenario, si se **retira**, se **baja de prioridad** o se **declara derivado de un ADR o de una política**, que es un origen legítimo y hoy no está escrito.

### 3.3 Grupo C — El hueco inverso: necesidad sin requisito y sin escenario

| Necesidad | Documentada en | Requisito | Escenario | Consecuencia |
|---|---|---|---|---|
| Protección de datos personales **en reposo** (`aliado.numero_documento_identidad`, `usuario.telefono`, `cliente.nit`, `cliente.telefono`, `sitio.contacto_telefono`) | Ley 1581 de 2012, citada en [`SRS.md`](../01-producto/SRS.md) | **No existe** | **No existe** | **B-09.** El ADR de cifrado ([SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699)) no se puede escribir: sin umbral, QA no puede verificar la decisión |

Este es el caso que originó la revisión, y es el único donde falta **todo** el eslabón, no solo la cita.

## 4. Lo que propongo al PO, en orden

Ninguna de estas cuatro acciones la puede tomar la SM.

| # | Acción | Por qué primero |
|---|---|---|
| 1 | **Crear dos RNF: recuperabilidad y protección de datos personales en reposo.** Con su prioridad | Son los dos que ya bloquean trabajo hoy: D4 quedó decidida sin requisito detrás, y B-09 impide escribir el ADR de cifrado |
| 2 | **Derivar un QAS de confidencialidad en reposo** del segundo RNF, con umbral y método (por ejemplo: «0 campos de la lista legibles en una consulta directa con un rol sin privilegio de descifrado») | Es lo que desbloquea [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699) y con él [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383) |
| 3 | **Decidir sobre los otros nueve P1 del grupo A**: crear requisito, bajar prioridad, o declarar el ADR o la política como origen legítimo | Son P1, es decir exigibles, y hoy QA está comprometida a medirlos sin que nadie los haya pedido |
| 4 | **Añadir al SDD una columna de requisito de origen** en la tabla de los 45 escenarios | Es lo que impide que esto vuelva a pasar. Sin ella, el próximo escenario nacerá igual de huérfano |

## 5. Lo que esta revisión no resolvió

- **Las asignaciones de la §2 son interpretación por contenido, no citas.** Un escenario que aquí aparece cubierto puede no estarlo si el PO lee el RNF de otra forma. La §2 es una propuesta de mapeo, no un hallazgo verificado.
- **No revisé los RF**, solo los RNF. Es posible que QAS-07, QAS-28 y QAS-29 estén respaldados por requisitos funcionales; eso lo tendría que confirmar quien mantiene [`SRS.md`](../01-producto/SRS.md).
- **No toqué el SDD.** La columna de origen de la acción 4 es trabajo de 02-arquitectura, no de esta carpeta.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.0 | 2026-11-11 | Revisión inicial, como propuesta. Recorrido de los 45 QAS contra RNF-01 a RNF-11: 13 escenarios con requisito detrás, **11 de prioridad P1 sin ninguno**, 19 de P2 y P3 sin ninguno, y un hueco inverso (cifrado en reposo, B-09). Hallazgo estructural: no existe mapeo QAS→requisito en el SDD, ni en el cuerpo del SDD, ni en la trazabilidad del SRS §7. Cuatro acciones propuestas al PO. | Sara Albarracín |

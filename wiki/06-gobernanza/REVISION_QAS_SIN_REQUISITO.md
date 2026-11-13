# Revisión: escenarios de calidad sin requisito que los respalde

[← Índice de la wiki](../Home.md) · [← 06 Gobernanza](README.md)

| Campo | Valor |
|---|---|
| **Estado** | **PROPUESTA, PENDIENTE DE PO.** Ninguna fila de este documento es una decisión. Nada de aquí se lleva a la sustentación como hecho. |
| **Finalidad** | Recorrer los 45 escenarios de calidad del SDD contra los once requisitos no funcionales del SRS y decir, uno por uno, cuáles **no tienen un requisito detrás**. Un escenario sin requisito compromete a QA a medir algo que nadie pidió. |
| **Origen** | Bloqueo **B-09** de [`REGISTRO_BLOQUEOS.md`](REGISTRO_BLOQUEOS.md), y la tercera causa recurrente que registra: «el requisito que la decisión debería cumplir no existe». Apareció dos veces por casualidad, al decidir D4 (recuperabilidad) y P-D15a (cifrado), nunca por una revisión. Esta es la revisión. |
| **Redacta** | Sara Albarracín (SM), como propuesta |
| **Decide** | María Camila Beltrán (PO): los requisitos son suyos ([`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §2.3) |
| **Versión** | 2.1 · corte 2026-11-13 |

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

### 3.1 Los once P1, clasificados

**Corrección de la versión 1.0.** La v1.0 los dio por «sin requisito» sin distinguir, y era demasiado duro: solo había mirado los once RNF. El SRS tiene además **ocho restricciones de proyecto (PROY-01 a PROY-08, §3.1)** y **cinco de producto (REST-01 a REST-05, §3.2)**, y varias de ellas sí respaldan un escenario. Con eso, **siete de los once tienen origen legítimo** y solo cuatro quedan sin respaldo.

Clasificación en las tres categorías pedidas: **(a)** tiene requisito, solo falta enlazarlo · **(b)** deriva de una restricción, un riesgo o un *driver* · **(c)** sin respaldo.

| QAS | Atributo | Cat. | Origen propuesto | Por qué |
|---|---|---|---|---|
| **QAS-15** | Ausencia de fallos | **(a)** | `RNF-07` | Es el caso más claro de requisito sin enlazar. RNF-07 exige soportar concurrencia y **remite explícitamente al SDD §7.4** para los umbrales; las cifras del escenario (300 sesiones concurrentes, 50 req/s sostenidos) son justo las de §7.4. El requisito existe y la cita está escrita en el RNF, pero no en el escenario |
| **QAS-05** | Escalabilidad | **(b)** | `restricción` — PROY-08 | **PROY-08: «El proyecto exige el uso de Kubernetes como orquestador».** El escenario de escalar de 2 a 6 réplicas con HPA deriva de esa restricción de proyecto, no de una necesidad del producto. Explica por qué es `No medido`: la restricción se impuso, el clúster no existe y INFRA-01/INFRA-02 siguen abiertos |
| **QAS-20** | Modularidad | **(b)** | `restricción` — ADR-0030 | La frontera de datos de ADR-0030 y la lógica en los servicios de ADR-0022 son decisiones `Aceptado`, y por tanto vinculantes. El escenario verifica esa frontera, no un requisito de producto |
| **QAS-23** | Capacidad para ser probado | **(b)** | `restricción` — ADR-0005 | Deriva de la política de PR y CI y del *Quality Gate* de ADR-0005, reforzada por PROY-06 (herramientas aprobadas por el equipo) |
| **QAS-25** | Instalabilidad | **(b)** | `restricción` — ADR-0004 | El despliegue por *pipeline* de CD y el procedimiento por ambiente son ADR-0004 |
| **QAS-44** | Reversión de despliegue | **(b)** | `restricción` — ADR-0004 | Las imágenes versionadas en GHCR y la vuelta a la anterior son parte del mismo ADR-0004 |
| **QAS-45** | *Quality Gate* de código nuevo | **(b)** | `restricción` — ADR-0005 | El propio escenario ya cita ADR-0005 en su columna de artefacto. Solo falta declararlo como origen |
| **QAS-14** | Resistencia | **(c)** | `supuesto` | El escenario habla de un atacante externo que envía ráfagas o explota una vulnerabilidad conocida. **Ningún RNF, REST o PROY menciona resistencia a ataques ni abuso de consumo.** ADR-0005 (DevSecOps) aporta el medio, no el requisito |
| **QAS-16** | Disponibilidad | **(c)** | `supuesto` | El umbral **≥ 99.9% mensual** no tiene fuente en ningún artefacto, y eso no cambia. Lo que sí cambió el 2026-11-13: **el medio para medirlo sí tiene origen**, porque el profesor exige Prometheus y Grafana (ver abajo). Sigue `supuesto` el **umbral**: nadie ha pedido 99.9%, y una exigencia de herramienta no fija una cifra de disponibilidad |
| **QAS-17** | Recuperabilidad | **(c)** | `supuesto` | Ningún RNF exige recuperabilidad. Detectado al decidir D4, que mantuvo `RPO ≤ 5 min` y `RTO ≤ 30 min` **porque era el único par documentado, no porque un requisito lo pida** |
| **QAS-43** | Confidencialidad en tránsito | **(c)** | `supuesto` | RNF-01 y REST-04 exigen aislamiento **entre tenants**, que es otra cosa que cifrar el transporte. Es el escenario que el RNF de protección de datos propuesto en [`PROPUESTA_RNF_PROTECCION_Y_RECUPERACION.md`](PROPUESTA_RNF_PROTECCION_Y_RECUPERACION.md) cubriría de forma natural |

**La observabilidad tiene origen desde el 2026-11-13, y conviene no confundir qué cubre.** El profesor exige **Prometheus y Grafana** como entregable del corte académico. Es una **restricción de proyecto** del mismo tipo que PROY-07 y PROY-08, y hasta ese día no estaba escrita en ningún artefacto: ni en el SRS §3.1, ni en el SDD, ni en ADR-0006. Queda propuesta como **PROY-09**.

Eso da origen al **medio** de medición —el servidor de métricas y sus tableros, que es lo que QAS-22 (analizabilidad) necesita— pero **no fija ningún umbral**. QAS-16 sigue en **(c)**: exigir la herramienta no es pedir un 99.9% mensual. La distinción importa porque es la que evita el error de dar por respaldado un umbral solo porque llegó la herramienta con que se mide.

**Y deja una contradicción abierta que no es de esta revisión:** [ADR-0006](../02-arquitectura/adr/ADR-0006-observabilidad.md) está `Aceptado` **con Datadog**, mientras lo exigido y lo que se despliega es Prometheus y Grafana. Un ADR `Aceptado` es vinculante, así que esto se corrige revisando el ADR en Mesa, no contradiciéndolo desde otro documento.

**Recuento: (a) 1 · (b) 6 · (c) 4.** No se inventa ningún RNF para cubrir los de (c): quedan marcados `supuesto`, que es información honesta y suficiente para que el PO decida si los adopta, los baja de prioridad o los retira.

### 3.1.1 Columna de origen propuesta para el SDD

Propuesta de valores controlados para una columna nueva en la tabla de los 45 escenarios, **que no se aplica aquí**: el SDD es de `02-arquitectura` y su edición está repartida con la otra sesión que trabaja la wiki.

| Valor | Significado | Ejemplo |
|---|---|---|
| `RNF-xx` | El escenario mide un requisito no funcional del SRS §6 | QAS-01 → `RNF-01` |
| `restricción` | Deriva de una restricción de proyecto o producto (SRS §3.1 y §3.2) o de un ADR `Aceptado`, que es vinculante | QAS-05 → `restricción (PROY-08)` |
| `riesgo` | Deriva de un riesgo registrado o de un *architectural killer* | — |
| `supuesto` | **No tiene respaldo.** El umbral se adoptó sin requisito que lo pida | QAS-16, QAS-17 |

Un escenario marcado `supuesto` no es inválido: es un compromiso que el equipo asumió por su cuenta. Lo que no puede es presentarse en la sustentación como si lo exigiera el producto.

### 3.2 Los P2 y P3 sin requisito: diecinueve escenarios

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
| 3 | **Aprobar la clasificación de §3.1**: enlazar QAS-15 a RNF-07, declarar el origen de los seis de **(b)**, y decidir sobre los cuatro de **(c)** —adoptarlos como requisito, bajar su prioridad o retirarlos | Son P1, es decir exigibles. Los cuatro de **(c)** son los únicos que hoy comprometen a QA sin respaldo |
| 4 | **Añadir al SDD la columna de origen** con los valores controlados de §3.1.1 | Es lo que impide que esto vuelva a pasar. Sin ella, el próximo escenario nacerá igual de huérfano. La aplica quien mantiene `02-arquitectura` |

## 5. Lo que esta revisión no resolvió

- **Las asignaciones de la §2 son interpretación por contenido, no citas.** Un escenario que aquí aparece cubierto puede no estarlo si el PO lee el RNF de otra forma. La §2 es una propuesta de mapeo, no un hallazgo verificado.
- **No revisé los RF**, solo los RNF. Es posible que QAS-07, QAS-28 y QAS-29 estén respaldados por requisitos funcionales; eso lo tendría que confirmar quien mantiene [`SRS.md`](../01-producto/SRS.md).
- **No toqué el SDD.** La columna de origen de la acción 4 es trabajo de 02-arquitectura, no de esta carpeta.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 2.1 | 2026-11-13 | Se registra que la observabilidad con Prometheus y Grafana la exige el profesor y es por tanto una restricción de proyecto, propuesta como PROY-09, que hasta hoy no estaba escrita. Da origen al **medio** de medición, no a un umbral: QAS-16 sigue en (c), porque exigir la herramienta no es pedir 99.9% mensual. Se anota la contradicción con ADR-0006, `Aceptado` con Datadog. | Sara Albarracín |
| 2.0 | 2026-11-11 | Clasificación de los once P1 en (a) requisito sin enlazar, (b) restricción, riesgo o *driver*, y (c) sin respaldo, a petición de la SM. **Corrige a la v1.0**, que los daba todos por huérfanos: la v1.0 solo había mirado los once RNF y no las restricciones PROY-01 a PROY-08 y REST-01 a REST-05 del SRS §3. Con ellas, **siete de los once tienen origen legítimo** y solo cuatro quedan sin respaldo (QAS-14, 16, 17 y 43). Se añade la propuesta de columna de origen con valores controlados. No se inventa ningún RNF. | Sara Albarracín |
| 1.0 | 2026-11-11 | Revisión inicial, como propuesta. Recorrido de los 45 QAS contra RNF-01 a RNF-11: 13 escenarios con requisito detrás, **11 de prioridad P1 sin ninguno**, 19 de P2 y P3 sin ninguno, y un hueco inverso (cifrado en reposo, B-09). Hallazgo estructural: no existe mapeo QAS→requisito en el SDD, ni en el cuerpo del SDD, ni en la trazabilidad del SRS §7. Cuatro acciones propuestas al PO. | Sara Albarracín |

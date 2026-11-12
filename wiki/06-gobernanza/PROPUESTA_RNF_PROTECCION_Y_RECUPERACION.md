# Propuesta: dos requisitos no funcionales y un escenario de calidad

[← Índice de la wiki](../Home.md) · [← 06 Gobernanza](README.md)

| Campo | Valor |
|---|---|
| **Estado** | **PROPUESTO, PENDIENTE DE APROBACIÓN DEL PO.** Nada de este documento es un requisito vigente. Mientras no se apruebe, los RNF del SRS siguen siendo RNF-01 a RNF-11. |
| **Finalidad** | Redactar los dos requisitos que hoy faltan y el escenario derivado del segundo, para desbloquear [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699) y [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383). |
| **Origen** | Bloqueo **B-09** de [`REGISTRO_BLOQUEOS.md`](REGISTRO_BLOQUEOS.md) y la §3.1 de [`REVISION_QAS_SIN_REQUISITO.md`](REVISION_QAS_SIN_REQUISITO.md), donde QAS-17 y QAS-43 quedan marcados `supuesto`. |
| **Redacta** | Sara Albarracín (SM), como propuesta |
| **Aprueba** | María Camila Beltrán (PO). Los requisitos son del PO, no de la SM ([`GOBIERNO_DEL_EQUIPO.md`](GOBIERNO_DEL_EQUIPO.md) §2.3) |
| **Versión** | 1.0 · 2026-11-11 |

> **Regla de umbrales de este documento.** Cada umbral dice **de dónde sale**. Si no sale de ningún artefacto, se marca `supuesto` y no se presenta como exigible. No se inventa ninguna cifra con apariencia de fuente.

## 1. RNF-12 (propuesto) · Recuperabilidad

| Campo | Contenido |
|---|---|
| **Enunciado** | El sistema debe poder restaurarse tras una falla de infraestructura o una corrupción de datos, con una pérdida máxima de datos y un tiempo máximo de restablecimiento acotados y verificables. |
| **Prioridad propuesta** | Alta. **No Crítica:** el MVP es un corte académico (PROY-02) y hoy no hay respaldo automático ni prueba de restauración (fila D9, pendiente). Declararlo Crítica sin respaldo sería incumplirlo por definición. |
| **Umbral** | `RPO ≤ 5 min` y `RTO ≤ 30 min`. **Fuente: QAS-17 del SDD §8.** No es una cifra nueva: es la que ya rige, ratificada en la decisión **D4** del 2026-11-11 por ser la única que vive en un artefacto vigente. |
| **Reserva sobre el umbral** | La decisión D4 lo mantuvo **porque era el único par documentado, no porque un requisito lo pidiera.** Al crear este RNF el PO decide si adopta esa cifra como exigible o fija otra. Si la adopta sin más, el umbral deja de ser `supuesto` y pasa a tener requisito. |
| **Método de medición** | QA restaura en QA un volcado reciente de la base y mide dos tiempos: la antigüedad del último respaldo disponible (RPO real) y el tiempo desde el inicio del procedimiento hasta que las APIs críticas responden (RTO real). Evidencia: fecha y hora del volcado, traza del procedimiento y salida de las sondas `/health` al terminar. |
| **Qué desbloquea** | Da requisito a **QAS-17**, hoy `supuesto`. No lo vuelve medible por sí solo: eso depende de la fila **D9** (¿existe un script de `pg_dump` versionado y cuál fue el último respaldo?), que sigue pendiente de evidencia. |
| **Trazabilidad** | necesidad = restablecer el servicio y los datos tras una pérdida → **requisito: RNF-12 (propuesto)** → atributo de calidad = Recuperabilidad P1, QAS-17 → prueba = restauración en QA con evidencia |

## 2. RNF-13 (propuesto) · Protección de datos personales en reposo

| Campo | Contenido |
|---|---|
| **Enunciado** | Los datos personales que la plataforma almacena deben estar protegidos en reposo, de modo que no sean legibles por quien acceda al almacenamiento sin el privilegio de descifrado correspondiente. |
| **Prioridad propuesta** | Alta |
| **Alcance: los cinco campos** | `aliado.numero_documento_identidad`, `usuario.telefono`, `cliente.nit`, `cliente.telefono` y `sitio.contacto_telefono`. Son los que enumera [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699), que además registra **68 de 68 documentos de identidad y 26 de 26 teléfonos de usuario en claro**. Esas dos cifras son del ticket, no de una consulta hecha en esta revisión. |
| **Necesidad que lo respalda** | **Ley 1581 de 2012**, citada en [`SRS.md`](../01-producto/SRS.md) como el marco que obligó a ADR-0024 en pagos. Los cinco campos son datos personales bajo esa misma ley. La necesidad está documentada; el requisito es lo que falta. |
| **Umbral** | **`supuesto`.** Ninguna fuente del proyecto fija un umbral de cifrado en reposo. La propuesta es binaria y verificable: **0 de los cinco campos legibles** en una consulta directa a la tabla con un rol que no tenga privilegio de descifrado. Se marca `supuesto` porque la cifra la propone esta revisión, no un artefacto. |
| **Método de medición** | QA consulta las cinco columnas en QA con un rol sin privilegio de descifrado y comprueba que ninguna devuelve texto legible; repite la consulta con el rol autorizado y comprueba que la aplicación sigue funcionando. Evidencia: las dos salidas, con los valores **redactados**, y la fecha. Complemento de C1 de SCRUM-1383: los valores tampoco aparecen en logs. |
| **Qué desbloquea** | Es el requisito que falta para que se pueda escribir el ADR de [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699) y, con él, implementar [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383). Da requisito además a **QAS-43** (confidencialidad en tránsito), hoy `supuesto`, si el PO decide que el enunciado cubra también el transporte. |
| **Trazabilidad** | necesidad = Ley 1581 de 2012 (SRS) → **requisito: RNF-13 (propuesto)** → atributo de calidad = **QAS-46 (propuesto)**, §3 → prueba = consulta con rol sin privilegio |

### 2.1 Un dato que conviene corregir en SCRUM-1383

[SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383) declara en su descripción **«Requisito: RNF-01 / REST-02»**. Ninguno de los dos exige cifrado:

- **RNF-01** y **REST-04** exigen **aislamiento entre tenants**, que es que un tenant no vea datos de otro. Un dato puede estar perfectamente aislado y seguir estando en claro.
- **REST-02** exige que los documentos KYC **dependan del tenant y estén aislados entre aliados y tenants**. Otra vez aislamiento, no cifrado.

El criterio **C1** de la historia («los secretos y datos sensibles se almacenan cifrados y nunca aparecen en logs») **no está respaldado por ninguno de los requisitos que la propia historia cita.** Eso es B-09 visto desde el otro lado: no es que falte el requisito en abstracto, es que la historia se ancló al requisito equivocado. Si se aprueba RNF-13, la historia debería citar `RNF-13` y no `RNF-01`.

## 3. QAS-46 (propuesto) · Confidencialidad en reposo

| Columna del SDD | Valor propuesto |
|---|---|
| **ID** | QAS-46 |
| **Atributo** | Confidencialidad en reposo |
| **Prioridad** | P1 |
| **Origen** (columna nueva) | `RNF-13` |
| **Fuente del estímulo** | Quien tenga acceso al almacenamiento sin privilegio de descifrado: un rol de base de datos sin ese privilegio, un volcado de respaldo o una copia de la base |
| **Estímulo** | Consulta directamente las columnas que contienen datos personales |
| **Entorno** | QA, con datos de prueba representativos |
| **Artefacto** | Las cinco columnas del §2, los roles de base de datos y el mecanismo de descifrado |
| **Respuesta** | Ninguna de las cinco columnas devuelve texto legible; la aplicación sigue operando con el rol autorizado |
| **Medida de la respuesta** | **0 de 5 campos legibles** sin privilegio de descifrado · `supuesto` |
| **Método de medición** | El del §2 |
| **Estado inicial** | **No medido.** Hoy los campos están en claro (68 de 68 y 26 de 26 según SCRUM-1699) |

## 4. El desacuerdo de SCRUM-1383: volumen contra columna

Hay dos formas de cumplir RNF-13 y **el equipo no ha elegido**. Las dos cumplen el enunciado; no cumplen lo mismo.

| | **Cifrado de volumen** (en reposo, a nivel de disco o de instancia) | **Cifrado por columna** (pgcrypto, o desde Core con la llave en un secreto) |
|---|---|---|
| **Qué protege** | El disco y los respaldos: alguien que se lleve el medio o un volcado no lee nada | Cada valor: ni un rol de base de datos sin privilegio ni un volcado en claro muestran el dato |
| **Contra quién NO protege** | **No protege contra un rol de base de datos con acceso de lectura:** la base descifra de forma transparente y el `SELECT` devuelve el dato en claro | No protege el resto de la fila ni los índices que no se cifren |
| **Umbral de QAS-46** | **No lo cumple.** El método del §2 consulta con un rol sin privilegio de descifrado, y con cifrado de volumen ese `SELECT` devuelve texto legible | **Lo cumple** |
| **Coste** | Prácticamente nulo si el proveedor lo ofrece: es configuración de infraestructura | Alto: migración de los cinco campos, cambios en los repositorios de Core, gestión de la llave, y pérdida de búsqueda e índice sobre esas columnas |
| **Quién lo haría** | DevOps (Daniel) | Core (Nicolás Álvarez) con DevOps para el secreto de la llave |
| **Relación con C1 de 1383** | Ambiguo: «se almacenan cifrados» es cierto en disco | Inequívoco |

**Lo que hay que decidir, y no se decide aquí:** si C1 de SCRUM-1383 se cumple con cifrado de volumen o exige cifrado por columna. **De esa elección depende el umbral de QAS-46**, no al revés: si se elige volumen, el umbral «0 de 5 legibles con un rol sin privilegio» es inalcanzable y hay que reescribirlo. Es el motivo por el que el ADR de SCRUM-1699 no se puede escribir antes de que el PO apruebe RNF-13 y el equipo elija el mecanismo.

**Recomendación de esta propuesta:** cifrado **por columna** para `aliado.numero_documento_identidad` y los tres teléfonos, y evaluar aparte `cliente.nit`, que es un identificador de empresa y se usa en búsquedas (tiene un `UNIQUE (tenant_id, nit)` en la migración `0002` de Core, que el cifrado determinista permitiría conservar y el aleatorio no). No es una decisión: es lo que esta revisión propone al PO.

## 5. Lo que esta propuesta no hace

- **No crea los requisitos.** Mientras el PO no los apruebe, el SRS sigue con RNF-01 a RNF-11 y no existe QAS-46.
- **No toca el SRS ni el SDD.** Ambos son de otras carpetas; la numeración RNF-12, RNF-13 y QAS-46 es la siguiente libre y queda a confirmar por quien los mantenga.
- **No fija el mecanismo de cifrado.** El §4 expone el desacuerdo, no lo resuelve.
- **No aporta cifras nuevas.** Las dos que aparecen (68 de 68 y 26 de 26) son de SCRUM-1699 y se citan como suyas.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.0 | 2026-11-11 | Propuesta inicial: RNF-12 de recuperabilidad con el umbral ya vigente de QAS-17 como fuente, RNF-13 de protección de datos personales en reposo con umbral marcado `supuesto`, y QAS-46 derivado del segundo. Se documenta que SCRUM-1383 cita `RNF-01 / REST-02`, que exigen aislamiento y no cifrado, de modo que su criterio C1 no tiene requisito detrás. Se expone el desacuerdo entre cifrado de volumen y por columna, y por qué el umbral de QAS-46 depende de esa elección. | Sara Albarracín |

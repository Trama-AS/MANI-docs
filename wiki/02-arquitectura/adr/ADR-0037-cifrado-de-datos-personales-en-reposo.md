# ADR-0037 — Cifrado de datos personales en reposo

- **Estado:** **Decidido por la Scrum Master el 2026-11-12; pendiente de ratificación en Mesa.** No es `Aceptado`: ADR-0003 reserva la ratificación a la Mesa de Arquitectura y la SM es aquí la proponente. Vinculante para la implementación desde ya; su estado formal cambia cuando la Mesa lo ratifique.
- **Decisión de:** protección de datos personales y frontera de responsabilidad
- **Proponente y decide:** Sara Albarracín Niño (Scrum Master)
- **Fecha:** 2026-11-12
- **Jira:** [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699) (T-54); implementa [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383) (HU-M02-15)
- **Relacionado con:** RNF-13 y QAS-46 (propuestos), ADR-0012, ADR-0018, ADR-0024, ADR-0030, Ley 1581 de 2012
- **Responde a:** ¿se cifran los datos personales por columna o basta el cifrado del medio?

---

## Contexto

[SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383) exige en su criterio **C1** que «los secretos y datos sensibles se almacenen cifrados y nunca aparezcan en logs». Cinco campos están hoy en claro, y el ticket [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699) cuantifica dos de ellos: **68 de 68 documentos de identidad** y **26 de 26 teléfonos de usuario**. Los cinco son `aliado.numero_documento_identidad`, `usuario.telefono`, `cliente.nit`, `cliente.telefono` y `sitio.contacto_telefono`.

**La cadena de trazabilidad estaba rota, y por eso esta decisión no se pudo tomar antes.** La historia declara «Requisito: RNF-01 / REST-02», y ninguno de los dos exige cifrado: los dos exigen **aislamiento entre tenants**, que es otra cosa. Un dato puede estar perfectamente aislado y seguir almacenado en claro. Tampoco existía un escenario de calidad de confidencialidad **en reposo**: el SDD tiene QAS-01 (entre tenants) y QAS-43 (en tránsito, TLS), y nada más. Sin requisito ni umbral, cualquier elección de mecanismo habría sido una cifra inventada.

Lo que sí está documentado es la **necesidad**: la **Ley 1581 de 2012**, citada en [`SRS.md`](../../01-producto/SRS.md) como el marco que obligó a ADR-0024 en pagos. Los cinco campos son datos personales bajo esa misma ley.

Por eso este ADR va acompañado de **RNF-13** y **QAS-46**, redactados en [`PROPUESTA_RNF_PROTECCION_Y_RECUPERACION.md`](../../06-gobernanza/PROPUESTA_RNF_PROTECCION_Y_RECUPERACION.md) y pendientes de aprobación del PO.

## Alternativas

**A. Cifrado del medio en reposo, a nivel de disco o de instancia. ← elegida**
Lo provee la plataforma. Protege el medio físico y los volcados de respaldo. **No protege frente a un rol de base de datos con permiso de lectura**: el motor descifra de forma transparente y un `SELECT` devuelve el dato en claro.

**B. Cifrado por columna** (pgcrypto en el motor, o desde Core con la llave en un secreto).
Protege cada valor, también frente a ese rol y frente a un volcado. Coste: migración de los cinco campos, cambios en los repositorios de Core, gestión del ciclo de vida de la llave, y pérdida de búsqueda e índice sobre esas columnas salvo que se use cifrado determinista.

**C. No hacer nada y dejar C1 sin cumplir.** Descartada: hay una necesidad legal documentada.

## Decisión

**Se adopta la opción A: cifrado del medio en reposo, con exclusión documentada del documento de identidad y los teléfonos frente a un rol con privilegios sobre la base de datos.**

**El criterio que la sostiene, y es el que hay que poder defender:** se cifra por columna **solo si un requisito exige proteger frente a un rol con privilegios sobre la base de datos**. Ese requisito **no existe**. Ni RNF-01, ni REST-02, ni REST-04, ni RNF-13 tal como está propuesto, exigen esa protección. Implementar cifrado por columna sin requisito que lo pida sería sobrearquitectura: añadiría migración, gestión de llaves y pérdida de índices para cubrir una amenaza que nadie ha declarado en alcance.

**Consecuencia directa sobre el umbral.** El umbral propuesto para QAS-46 —«0 de 5 campos legibles con un rol sin privilegio de descifrado»— **es inalcanzable con la opción A y queda sin efecto**. Se sustituye por:

> **QAS-46, umbral revisado (`supuesto`):** el almacenamiento y los respaldos están cifrados en reposo, verificable en la configuración del proveedor; y **ningún dato personal de los cinco campos aparece en logs, trazas ni respuestas de error**. Marcado `supuesto` porque ninguna fuente del proyecto fija un umbral de cifrado en reposo.

**Método de medición.** QA acredita dos cosas, y ninguna exige leer el dato: (1) la configuración de cifrado en reposo del proveedor, con captura fechada; (2) una búsqueda de los cinco campos en logs del Gateway y de los servicios, y en las respuestas de error, que debe devolver **0 coincidencias**. La parte de C1 que sigue siendo exigible y verificable es la de los logs.

**Exclusión que queda escrita, y es el precio de esta decisión.** Un rol de base de datos con permiso de lectura —`service_role`, o cualquier rol con `BYPASSRLS`— **puede leer en claro el documento de identidad y los teléfonos**. No es un efecto no previsto: es el alcance aceptado. Se mitiga con lo que ya existe —RLS, separación de roles por servicio (ADR-0032) y auditoría de operaciones administrativas (T10 de SCRUM-1383)—, no con cifrado.

## Consecuencias

### Positivas
- Cumple C1 en lo verificable y en lo que la ley exige del responsable del tratamiento, sin migración, sin llaves que gestionar y sin perder índices ni búsqueda sobre `cliente.nit`.
- Desbloquea [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383), parada desde el Sprint 5 por falta de decisión.
- No toca el modelo de datos ni las 37 políticas RLS.

### Negativas
- **El riesgo de un rol con privilegios sobre la base no queda cubierto**, y queda escrito arriba como exclusión.
- Si más adelante aparece un requisito que lo exija —una exigencia del cliente, una auditoría o un incidente—, este ADR se supersede y la migración a cifrado por columna será más cara cuanto más datos haya.

## Condición de revisión

Se revisa si ocurre cualquiera de estas tres: aparece un requisito que exija proteger frente a un rol con privilegios; la plataforma deja de ofrecer cifrado en reposo; o se amplía el alcance a datos de categoría especial bajo la Ley 1581 (salud, biometría), que sí justificarían cifrado por columna.

## Pendiente para ratificar

| # | Qué | Quién |
|---|---|---|
| M1 | Ratificar en Mesa el criterio «cifrado por columna solo si un requisito lo exige» | Mesa de Arquitectura |
| M2 | Aprobar **RNF-13** y **QAS-46** con el umbral revisado de este ADR | Camila Beltrán (PO) |
| M3 | Confirmar que C1 de SCRUM-1383 se da por cumplido con la opción A, al ser decisión registrada | Santiago, que decide el DoD |
| M4 | Acreditar la configuración de cifrado en reposo del proveedor | Daniel Ávila (DevOps) |

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.0 | 2026-11-12 | Decisión inicial: cifrado del medio en reposo con exclusión documentada del documento de identidad y los teléfonos frente a un rol con privilegios. Se descarta el cifrado por columna por ausencia de requisito que lo exija. Se sustituye el umbral de QAS-46, que era inalcanzable con esta opción, por uno verificable sin leer el dato. | Sara Albarracín |

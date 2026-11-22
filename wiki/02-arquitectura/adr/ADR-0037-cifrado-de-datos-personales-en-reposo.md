# ADR-0037 — Cifrado de datos personales en reposo

- **Estado:** `Aceptado` · **ratificado por la Scrum Master (Sara Albarracín) el 2026-11-19**, sin sesión de Mesa de Arquitectura. ADR-0003 reserva la ratificación a la Mesa; al no haberse convocado ninguna en el Sprint 6 y con la entrega en curso, la SM ratifica para que la decisión no quede sin respaldo formal mientras el código ya la cumple. **La Mesa puede confirmarla o revertirla** cuando se reúna.
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
| M4 | Acreditar la configuración de cifrado en reposo del proveedor | Daniel Ávila (DevOps) — **Acreditado el `2026-11-14`** (ver sección siguiente) |

## Acreditación técnica M4, auditoría de logs y plan de respaldo/migración condicional ([SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699))

Verificación realizada el `2026-11-14` sobre los proyectos gestionados de Supabase Cloud y el entorno desplegado en QA:

### 1. Acreditación en proveedor y metadata de base de datos (M4)

| Aspecto verificado | Resultado observado en QA (`hpsxdotaizzclkeufzct.supabase.co`) | Resultado observado en PROD (`tjxueukivwxsgipltqwb.supabase.co`) |
|---|---|---|
| **Motor y plataforma** | PostgreSQL `17.6` administrado en Supabase Cloud (AWS `us-east-2`, almacenamiento en volumen EBS y snapshots cifrados en reposo con `AES-256` por la plataforma) | PostgreSQL `17.6` administrado en Supabase Cloud (AWS `us-east-2`, cifrado de volumen y respaldos gestionados en reposo `AES-256`) |
| **Transporte (`pg` / Pool)** | `ssl = on`, `ssl_min_protocol_version = TLSv1.2` | `ssl = on`, `ssl_min_protocol_version = TLSv1.2` |
| **Roles y privilegios (`pg_roles`)** | `anon` y `authenticated` (`rolbypassrls = false`), `postgres` y `service_role` (`rolbypassrls = true`) | Separación equivalente de roles gestionada por Supabase |
| **Extensiones criptográficas disponibles** | `pgcrypto 1.3` (`extensions`) y `supabase_vault 0.3.1` (`vault`) instaladas (sin uso activo bajo Opción A) | `pgcrypto 1.3` (`extensions`) y `supabase_vault 0.3.1` (`vault`) instaladas |
| **Conteo de registros no nulos en los 5 campos (`text`, sin leer valores)** | `aliado.numero_documento_identidad`: `68`, `usuario.telefono`: `27`, `cliente.nit`: `14`, `cliente.telefono`: `11`, `sitio.contacto_telefono`: `14` | `aliado.numero_documento_identidad`: `0`, `usuario.telefono`: `8`, `cliente.nit`: `0`, `cliente.telefono`: `0`, `sitio.contacto_telefono`: `0` |

### 2. Verificación de ausencia de PII en logs y errores (`C1` / `QAS-46`)

- **Código (`MANI-Node`):** `src/middlewares/errorHandler.middleware.js` responde `INTERNAL_ERROR` genérico ante fallas no previstas (fallo cerrado `T9`, sin exponer SQLSTATE ni valores de filas); los casos de uso de sitios (`AddSiteToCompanyClientUseCase.js`, `UpdateCompanyClientSiteUseCase.js`) registran identificadores de operación, nombres de sitio y claves modificadas, no teléfonos ni documentos.
- **Logs centralizados en QA (`Grafana Loki` `10.43.98.196:3100`):** consulta `{ambiente="qa"}` sobre los flujos activos devuelve **`0`** coincidencias para `numero_documento_identidad`, `contacto_telefono`, `password` y `SUPABASE_JWT_SECRET`.

### 3. Plan de respaldo previo y migración condicional

Bajo la **Opción A** decidida en este ADR, **no corresponde ejecutar migración destructiva ni alteración de columnas en `SCRUM-1383`**: el almacenamiento en reposo ya opera cifrado en el proveedor y la exclusión de lectura directa con roles con `BYPASSRLS` queda documentada arriba.

En caso de activarse la [condición de revisión](#condición-de-revisión) hacia **Opción B (cifrado por columna)**, debe ejecutarse obligatoriamente en este orden:

1. **Respaldo previo verificable:** ejecutar exportación lógica completa antes de cualquier `ALTER TABLE` (`pg_dump --format=custom --no-owner`) hacia almacenamiento seguro (VM de Backups `10.43.98.197` / snapshot de plataforma) y validar restauración en entorno de pruebas.
2. **Fase Expand (migración aditiva sin pérdida de índice):** añadir columnas cifradas (`*_enc bytea` con `pgp_sym_encrypt` desde `extensions.pgcrypto` o cifrado en aplicación Core con clave gestionada fuera de Git / `supabase_vault`) y columna de huella determinista HMAC indexada (`*_hash`) solo donde exista restricción de unicidad o búsqueda exacta (`cliente.nit`).
3. **Fase Migrate + verificación QA:** activar doble escritura y backfill por lotes verificando paridad contra la vista autorizada, sin exponer llaves ni datos en claro en logs.
4. **Fase Contract:** retirar la lectura de columnas en claro, aplicar nulificación/borrado controlado y validar nuevamente en QA (`SCRUM-1383`).

## Ratificación del 2026-11-19

**Ratificado por Sara Albarracín (Scrum Master), sin sesión de Mesa de Arquitectura.**

**Por qué sin Mesa.** [ADR-0003](ADR-0003-mesa-arquitectura.md) reserva la ratificación de una decisión estructural a la Mesa. En el Sprint 6 **no se convocó ninguna sesión**, y la decisión ya estaba siendo cumplida por el código y la infraestructura. Dejarla indefinidamente como «pendiente de ratificar» habría significado llevar a la sustentación una decisión que el proyecto aplica y que formalmente nadie aprobó.

**Qué significa esta ratificación y qué no.** Da respaldo formal a la decisión para que sea exigible y citable. **No sustituye a la Mesa:** cuando se reúna puede **confirmarla o revertirla**, y si la revierte, esta ratificación y su fecha quedan en el historial como lo que fueron. Se registra así, y no como una ratificación ordinaria, para que cualquiera pueda auditar cómo se tomó.

**La exclusión sigue en pie, y ratificarla es ratificarla también.** Un rol de base de datos con permiso de lectura —`service_role`, o cualquiera con `BYPASSRLS`— **puede leer en claro el documento de identidad y los teléfonos**. Eso no es un efecto no previsto: es el alcance aceptado, y queda firme con esta ratificación.

## Historial de cambios

| Versión | Fecha | Cambio | Autor |
|---|---|---|---|
| 1.0 | 2026-11-12 | Decisión inicial: cifrado del medio en reposo con exclusión documentada del documento de identidad y los teléfonos frente a un rol con privilegios. Se descarta el cifrado por columna por ausencia de requisito que lo exija. Se sustituye el umbral de QAS-46, que era inalcanzable con esta opción, por uno verificable sin leer el dato. | Sara Albarracín |
| 1.1 | 2026-11-14 | Acreditación técnica M4 en Supabase QA/PROD (PostgreSQL 17.6, TLS >= 1.2, AES-256 de plataforma, conteo de los 5 campos), auditoría `0` coincidencias PII en Loki QA / `MANI-Node`, y plan explícito de respaldo previo y migración condicional para [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699). | Daniel Ávila |

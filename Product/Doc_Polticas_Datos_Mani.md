# TRAMA · MANI — Política de Datos (DOC-22)

Sep 23, 2026 · @Nicolas

**Proyecto:** MANI — Plataforma Multi-Tenant de Formalización y Gestión de Servicios\
**Organización:** TRAMA · Ingeniería de Software\
**Documento:** Política de Datos — Seed, Anonimización y Política de Datos en APP (DOC-22)\
**Documento destino:** Infraestructura V1\
**Versión:** 1.0 (Propuesta — Sprint 2)\
**Responsable (plan de sprint):** Nicolas Alvarez (Arquitecto)\
**Criterio de terminado:** Define qué datos pueden existir en QA y cómo se generan.\
**Origen:** Sprint 2 Planning — hoja '1. Doc y Arquitectura'\
**Fuentes y Trazabilidad:** ADR-0009, ADR-0012, ADR-0013, ADR-0018, ADR-0022; `Product/DDL_MANI.sql`; `Product/Modelo_Datos_MANI.md`; `DD-MANI.md` §8; `Gobierno_del_Equipo.md` §2; RNF-01 (SRS).

> **Ubicación en el repositorio:** `Product/Politica_Datos_MANI.md` (junto a `SAD-MANI.md`, `DD-MANI.md` y `Modelo_Datos_MANI.md`, con los que esta política se relaciona directamente — §6), siguiendo la convención de nombres y la estructura `Product/` de `MANI-docs` (README, ADR-0007). **Cumplimiento ADR-0009 (Política de Uso de IA):** documento elaborado con asistencia de IA; sujeto a revisión y autoría humana antes de commit (autoría de contenido: Nicolas Alvarez); no contiene credenciales reales ni información sensible real, únicamente datos sintéticos de ejemplo (§2–§3).

## Control de Versiones del Documento

| Versión | Fecha | Autor(es) | Descripción del Cambio | Estado |
| :-: | :-: | :-- | :-- | :-: |
| **1.0** | 2026-09-23 | Nicolas Alvarez | Versión inicial de la Política de Datos: diferencias entre ambientes DEV/QA/PROD, anonimización de campos reales del esquema (`DDL_MANI.sql`), seed de datos y política de datos en la app (DOC-22, Sprint 2). | **Propuesta — pendiente ratificación Mesa de Arquitectura** |

## 0. Propósito y Reglas de Gobierno

Esta política gobierna qué datos existen en cada ambiente de MANI (`dev`, `qa`/`staging`, `prod`), cómo se generan los datos de prueba, y qué tratamiento reciben los datos sensibles cuando salen de producción. Aplica a todas las entidades tenant-scoped del esquema real (`Product/DDL_MANI.sql`, `Product/Modelo_Datos_MANI.md`) y a los objetos de Storage (documentos KYC).

**Principio rector:** ningún dato real de `prod` (de clientes, aliados o tenants reales) se copia hacia `dev` o `qa` sin pasar primero por el proceso de anonimización (§2). `qa`/`staging` solo contiene datos sintéticos generados por seed (§3), nunca un volcado (dump/restore) directo de producción.

Este documento asume la arquitectura confirmada del proyecto: app Flutter que consume Supabase directamente (Auth + Postgres + Storage + Realtime), sin backend intermedio propio, y aislamiento multi-tenant por Row-Level Security (RLS) sobre `tenant_id` (ADR-0012, ADR-0018; §8 de `DD-MANI.md`).

### Reglas de Uso y Vigencia

1. **Lo que no está aquí, no se exige:** ninguna validación de datos en QA, ni criterio de rechazo en Pull Requests o revisión de entregables, puede fundamentarse en un lineamiento de manejo de datos que no conste explícitamente en este documento o en un ADR ratificado (ADR-0012, ADR-0013, ADR-0018, ADR-0022).
2. **Lo que está aquí, se cumple:** cualquier excepción — un caso de incidente real anonimizado (§2), un dato manual insertado en `qa` fuera del seed (§3) — debe someterse a la Mesa de Arquitectura o quedar registrada con responsable, justificación y fecha en el acta de la ceremonia correspondiente.
3. **Mecanismo de modificación:** toda actualización a esta política requiere acuerdo en retrospectiva de sprint o ratificación formal en la Mesa de Arquitectura (`Gobierno_del_Equipo.md` §1.1.3) y entra en vigencia a partir del sprint siguiente.

# 1. Diferencias entre Ambientes

Conforme a `Gobierno_del_Equipo.md` §2.2 y §2.5 (ambientes contemplados: **DEV, QA, PROD**; contenerización con Docker/Docker Compose; ningún despliegue a PROD ocurre sin pasar por DEV y QA con CI en verde):

| Ambiente | Propósito | Proyecto Supabase | Contenido de datos | Quién genera/altera datos |
| --- | --- | --- | --- | --- |
| **DEV** | Integración diaria del equipo, desarrollo local/individual | Proyecto Supabase de desarrollo, separado de `prod` | 100% sintéticos, generados por el script de seed (§3). Se puede resetear libremente | Cualquier integrante del equipo, en cualquier momento |
| **QA / staging** | Validación previa a Sprint Review/demo, pruebas funcionales y de carga (Postman/Newman, k6) | Proyecto Supabase de staging, espejo de `prod` en esquema, RLS y roles | 100% sintéticos vía seed versionado (§3), más los datos generados por las suites de prueba automatizadas. **Nunca** un dump/restore de `prod`. Un caso derivado de un incidente real solo entra tras anonimización (§2), documentado como excepción con fecha y responsable | DevOps (seed) y QA (datos de suites de prueba); reset coordinado antes de cada ciclo de pruebas |
| **PROD** | Operación real, primer tenant (cliente real) | Proyecto Supabase de producción | Datos reales de tenants, aliados, clientes y operación, sujetos a §4 | Únicamente vía la aplicación (flujos de negocio normales) o migraciones DDL aprobadas por Mesa de Arquitectura; ningún dato de prueba se escribe manualmente en `prod` |

**Reglas de frontera entre ambientes:**

- El esquema (DDL) es el mismo archivo en los tres ambientes — `Product/DDL_MANI.sql` es la única fuente física.
- La promoción de un cambio de esquema sigue `develop` → `release/QA` → `main` (ADR-0004): ningún cambio llega a `prod` sin pasar antes por `QA` con CI en verde.
- Las credenciales de cada proyecto Supabase (`dev`, `qa`, `prod`) deben gestionarse como secretos independientes, sin exponerse en repositorio ni pipelines (gestión de secretos, `Gobierno_del_Equipo.md` §2.4): una fuga de credenciales de `dev` no debe comprometer `prod`.
- Ningún export de `prod` (backup, dump, extracto de debugging) se descarga a un equipo local ni se adjunta a un ticket de Jira/Discord sin pasar por anonimización.

# 2. Anonimización de Datos

Aplica a cualquier dato que se mueva desde `prod` hacia un ambiente de menor confianza (`qa`, `dev`) o hacia un canal de soporte/debugging (ticket, log compartido, sesión de pair-debugging).

### 2.1 Campos sujetos a anonimización

Tabla construida directamente sobre las columnas reales de `Product/DDL_MANI.sql` (no sobre un modelo conceptual aspiracional):

| Tabla | Campo(s) | Técnica |
| --- | --- | --- |
| `usuario` | `email` | Sustitución determinística (hash + formato sintético: `usuario_<hash8>@ejemplo-mani.test`) — determinística para poder seguir referenciando el mismo registro entre corridas |
| `aliado` | `nombre_razon_social` (un único campo cubre persona natural, empresa y empleado directo según `tipo`) | Sustitución por nombre/razón social sintéticos (Faker, locale `es_CO`), sin relación reversible con el dato real |
| `sitio` | `direccion` | Generalización a nivel de `zona` (se conserva `zona_id` para no romper pruebas de cobertura geográfica; se descarta el detalle de calle/número) |
| `documento_kyc` | `ruta_storage` (archivo binario referenciado) | **No se copia el archivo real.** En `qa`/`dev` se sube un documento de prueba genérico (imagen/PDF placeholder); se conserva la metadata necesaria para probar el flujo (`estado`, `tipo_documento`) |
| `mensaje` | `contenido` | No se replica contenido real de conversaciones; se generan mensajes sintéticos para pruebas de mensajería (ADR-0017) |
| `calificacion` | `comentario` (nullable) | Se sustituye por texto genérico de prueba cuando no es nulo |
| `evento_servicio` | `descripcion` (nullable, texto libre) | Mismo criterio: se anonimiza únicamente si el texto libre contiene dato personal; el resto del log (tipo\_evento, timestamps) no se toca por ser append-only e inmutable |
| `notificacion` | `payload` (jsonb libre) | Se sustituye por un payload sintético equivalente en forma cuando su contenido pueda incluir texto identificable (p. ej. extractos de `mensaje`) |

**Fuera de este DDL:** `usuario` es 1:1 con `auth.users` de Supabase Auth (`Modelo_Datos_MANI.md`, ADR-0022). Cualquier atributo de identidad adicional que Supabase Auth llegue a almacenar (p. ej. teléfono, si se habilita login por SMS) queda sujeto a esta misma política aunque no aparezca en `DDL_MANI.sql`, y se anonimiza con el mismo criterio que `email`.

Campos que **no** requieren anonimización por no ser dato personal identificable: `tenant_id`, `zona` (nombre, nivel), `categoria_servicio`, `tarifa_referencia`, `estado`/`estado_verificacion` y demás enumerados, `tipo_evento`, `tipo_documento`, timestamps operativos.

> Nota de alcance: el esquema vigente (Sprint 2) no define columnas de teléfono, documento de identidad (cédula) ni NIT en `usuario`, `aliado` o `cliente` — `cliente` no tiene columnas propias de identificación además de `tipo`. Si una futura iteración del modelo de datos agrega estos campos, deben incorporarse a esta tabla antes de habilitarse en `qa` (ver §5).

### 2.2 Reglas de anonimización

1. **Irreversibilidad:** la sustitución no debe permitir reconstruir el dato original (nombres generados de forma independiente al dato real, no un simple hash reversible).
2. **Consistencia referencial:** un mismo `id` de origen produce siempre el mismo dato sintético dentro de una misma corrida de anonimización, para no romper relaciones FK ni pruebas que dependan de repetibilidad (p. ej. el mismo aliado aparece con el mismo `nombre_razon_social` sintético en todas sus solicitudes).
3. **Aislamiento multi-tenant preservado:** la anonimización nunca mezcla datos entre tenants ni reasigna `tenant_id`; se anonimiza dentro de cada tenant, respetando la misma frontera que RLS ya impone en producción.
4. **Nunca anonimización manual ad-hoc:** el proceso vive en un script versionado (§3), no en ediciones manuales de una copia de `prod`.
5. **KYC nunca sale de `prod` como archivo real**, ni siquiera anonimizado — se reemplaza por un placeholder (regla más estricta que para el resto de campos, dado el riesgo del documento de identidad como imagen).

# 3. Seed de Datos (Qué Existe en QA y Cómo se Genera)

**Criterio de terminado de DOC-22:** esta sección responde explícitamente qué datos pueden existir en QA y cómo se generan.

### 3.1 Qué puede existir en QA

Solo estas tres fuentes, nunca otra:

1. **Seed base versionado** — conjunto mínimo y determinístico de datos sintéticos para que la app arranque en estado usable: 2–3 `tenant` de prueba, un `usuario` por rol (`admin_plataforma`, `admin_tenant`, `aliado`, `cliente`) por tenant, catálogo de `zona` (el mismo catálogo global que en `prod`, por ser dato de plataforma no personal), `categoria_servicio` y `tarifa_referencia` de ejemplo por tenant, y la cobertura mínima (`cobertura_aliado`, `aliado_categoria`) para que un `aliado` de prueba sea elegible en el despacho.
2. **Datos generados por las suites de prueba automatizadas** (Postman/Newman funcionales, k6 de carga, incluida la suite de aislamiento multi-tenant referenciada en `Gobierno_del_Equipo.md`) — se ejecutan contra `qa`, generan `solicitud`, `cotizacion`, `mensaje`, `calificacion`, `evento_servicio`, `notificacion`, etc. de forma efímera y se limpian o resetean entre ciclos de prueba.
3. **Casos anonimizados de incidentes reales**, únicamente como excepción documentada (§2), nunca como práctica regular.

Explícitamente **no** puede existir en QA: ningún documento KYC real, ningún dato de un tenant real que no sea uno de los tenants de prueba definidos en el seed, ningún dato copiado directamente de `prod` sin pasar por §2.

### 3.2 Cómo se generan

- El seed es un script versionado en el repositorio (`MANI-flutter` o `MANI-docs`, según se resuelva su ubicación final con DevOps — ver §5) que inserta datos directamente contra el esquema de `Product/DDL_MANI.sql`, respetando las políticas RLS (se ejecuta con las credenciales de servicio del proyecto Supabase de `dev`/`qa`, nunca bypaseando RLS de forma permanente).
- El seed es **idempotente**: correrlo dos veces sobre el mismo ambiente no duplica filas (upsert por clave natural, p. ej. `slug` de `tenant`, `email` de `usuario`).
- El seed se ejecuta automáticamente en la promoción a `qa`/`staging` dentro del pipeline de CI/CD (etapa Deploy de `Gobierno_del_Equipo.md` §2.1), y de forma manual/local para `dev`.
- Los datos generados por Faker (`es_CO`) usan una semilla numérica del generador fija por corrida documentada, para que los reportes de bugs sean reproducibles sin necesitar el dato real.
- Todo dato sintético queda marcado como tal por convención (p. ej. dominio de correo `@ejemplo-mani.test`, prefijo reconocible en `tenant.nombre`/`tenant.slug` de prueba) para que nadie lo confunda con un tenant real durante una demo.

### 3.3 Responsable y frecuencia

- **DevOps** (Daniel Ávila titular, Nicolás León secundario, `Gobierno_del_Equipo.md` §2) es responsable de mantener el script de seed y su ejecución en el pipeline.
- El seed se re-ejecuta en cada reset de `qa` previo a un ciclo de pruebas formal (antes de Sprint Review) y cada vez que el esquema cambia de forma incompatible con el seed vigente.

# 4. Política de Datos en la Aplicación (APP)

Reglas que aplican en todo ambiente, incluido `prod`, sobre el tratamiento de datos personales dentro de la app:

1. **Minimización:** la app solicita y persiste solo los campos necesarios para el flujo de negocio correspondiente (RF de `SRS_MANI.md`); no se agregan campos "por si acaso" — el propio esquema vigente refleja esto (p. ej. `cliente` no persiste nombre propio, solo `tipo`).
2. **Aislamiento por tenant como control de privacidad, no solo de negocio:** RLS (§8.1 de `DD-MANI.md`, RNF-01 del SRS) es el mecanismo que garantiza que ningún dato de un tenant sea visible para otro, incluyendo en `qa`/`staging` donde conviven varios tenants de prueba en la misma base.
3. **Documentos KYC:** además del aislamiento por RLS de Storage (`storage.objects`, política `kyc_isolation`, ADR-0013), el acceso está limitado al propio aliado y a `admin_tenant` de su tenant — ningún otro rol, en ningún ambiente, puede leer un documento KYC ajeno.
4. **`tenant_id` nunca viaja desde el cliente:** se resuelve siempre del JWT firmado por Supabase Auth (`app_metadata.tenant_id`, §6.3/§8.1 de `DD-MANI.md`), lo que también evita que un dato quede mal clasificado por un error del cliente al momento de anonimizar o exportar.
5. **Retención:** 🔴 pendiente de definir con Mesa de Arquitectura — plazo de retención de `mensaje`, `evento_servicio` y `documento_kyc` tras el cierre de una `solicitud` o la baja de un `aliado`/`cliente`. Queda como punto abierto de esta V1, a resolver antes de que la política llegue a producción real con el primer tenant.
6. **Eliminación a solicitud del titular:** 🔴 pendiente de definir el procedimiento operativo (qué endpoint/proceso ejecuta el borrado o anonimización de un usuario que solicita salir de la plataforma). Se deja registrado como brecha para la siguiente iteración de esta política (Infraestructura V2, Sprint 3).

# 5. Puntos Abiertos (Mesa de Arquitectura)

- Plazo de retención de datos por entidad (§4, punto 5).
- Procedimiento de eliminación/anonimización a solicitud del titular (§4, punto 6).
- Ubicación definitiva del script de seed dentro del repositorio (`MANI-flutter` vs. `MANI-docs`).
- Herramienta de anonimización (script propio vs. librería especializada) — a evaluar junto con DevOps dentro del punto pendiente de Security Testing de `Gobierno_del_Equipo.md` §2.4.
- Si una futura iteración del modelo de datos agrega teléfono, documento de identidad o NIT (no presentes en el esquema vigente, §2.1), incorporarlos a la tabla de anonimización antes de habilitarlos en `qa`.

Estos puntos no bloquean el cierre de DOC-22 para Sprint 2 (el criterio de terminado — qué datos pueden existir en QA y cómo se generan — queda cubierto en §1 y §3), pero deben resolverse antes de Infraestructura V2/V3.

# 6. Trazabilidad

| Referencia | Relación |
| --- | --- |
| ADR-0012, ADR-0018 | Fundamento del aislamiento multi-tenant por RLS que esta política reutiliza para anonimización y seed |
| ADR-0013 | Aislamiento de Storage/KYC, base de la regla "KYC nunca sale como archivo real" |
| ADR-0022 | Relación 1:1 `usuario` ↔ `auth.users` de Supabase Auth (fundamento de la nota sobre atributos de identidad fuera del DDL, §2.1) |
| ADR-0009 | Política de Uso de IA — este documento se elaboró con asistencia de IA; requiere revisión y autoría humana antes de commit al repositorio `MANI-docs` |
| `Product/DDL_MANI.sql`, `Product/Modelo_Datos_MANI.md` | Entidades y columnas reales sobre las que aplica la anonimización (§2) |
| `Gobierno_del_Equipo.md` §2.1, §2.2, §2.4, §2.5 | Definición de ambientes DEV/QA/PROD, pipeline CI/CD, gestión de secretos y contenerización |
| RNF-01 (SRS) | No fuga de datos entre tenants — principio que esta política extiende a los ambientes de prueba |

# 7. Resumen de Aprobación y Trazabilidad

Esta Política de Datos (DOC-22) se somete al mismo mecanismo de gobierno que el resto de decisiones técnicas del proyecto (`Gobierno_del_Equipo.md` §1.1.3, ADR-0003):

| Rol | Integrante | Responsabilidad en este Documento | Estado |
| :-- | :-- | :-- | :-: |
| **Arquitecto (Responsable)** | Nicolas Alvarez | Elaboración de la política: seed, anonimización, diferencias entre ambientes y política de datos en la app | **Elaborado** |
| **DevOps** | Daniel Ávila / Nicolás León | Revisión de §1 (ambientes), §3 (seed) y gestión de credenciales por proyecto Supabase | 🔴 Pendiente de revisión |
| **QA / Security Testing** | Santiago | Revisión de §2 (anonimización) y su relación con Security Testing (`Gobierno_del_Equipo.md` §2.4) | 🔴 Pendiente de revisión |
| **Mesa de Arquitectura** | Equipo pleno | Ratificación formal como línea base (§0, regla 3) y resolución de los puntos abiertos de §5 | 🔴 Pendiente de ratificación |

Mientras no se registre la ratificación de la Mesa de Arquitectura, este documento tiene estado **Propuesta** (ver Control de Versiones) y no debe citarse como criterio vinculante de aceptación en Pull Requests, conforme a la regla 1 de §0.

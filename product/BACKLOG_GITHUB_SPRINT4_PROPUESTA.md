# Backlog técnico en GitHub: estado verificado e issues propuestos del cierre del Sprint 4

| Campo | Valor |
|---|---|
| Propósito | Verificar el estado real de los issues de GitHub en los siete repositorios, distinguir el trabajo ya implementado del pendiente y dejar listos para registro los issues de los hallazgos bloqueantes de QA |
| Presenta | Sara Albarracín |
| Corte de la verificación | 20 de octubre de 2026 |
| Alcance | Organización `Trama-AS`: MANI-docs, MANI-Node, MANI-.NET, MANI-Java, MANI-Flutter, MANI-APIGateway, MANI-Landing |
| Fuentes | `gh issue list` y `gh pr list` sobre los siete repositorios; código de `release` y `develop` de MANI-Node, MANI-APIGateway y MANI-.NET; [reporte de monitoreo QA](REPORTE_QA_MONITOREO_QAS_SCRUM-1266.md) (SCRUM-1266) y [reporte de regresión](REPORTE_QA_REGRESION_SCRUM-1267.md) (SCRUM-1267) |
| Estado | Propuesta. Ningún issue se ha creado en GitHub; los borradores de §4 esperan aprobación |

> Este documento no registra hallazgos nuevos ni cambia estados históricos. Los hallazgos son los de
> SCRUM-1266 y SCRUM-1267; aquí se verifica cuáles siguen vigentes en el código y qué unidad de
> trabajo corresponde a cada uno.

## 1. Estado verificado de GitHub

**Los siete repositorios tienen cero issues**, incluidos los cerrados (`gh issue list --state all`,
20 de octubre de 2026). El seguimiento vive en Jira y en los pull requests.

La organización **no tiene ningún GitHub Project**, y los siete repositorios conservan solo las
etiquetas por defecto de GitHub (`bug`, `documentation`, `enhancement`, `duplicate`, `invalid`,
`question`, `wontfix`, `help wanted`, `good first issue`, `accessibility`). El modelo de trabajo que
se pretende administrar en GitHub —estados *bloqueado*, *listo*, *en curso*, *en revisión* y
*terminado*, prioridades, dependencias y responsables— **no existe todavía como estructura**. Antes
de crear issues hace falta decidir:

1. Un proyecto único cross-repo (recomendado, porque los hallazgos cruzan repositorios) o uno por
   repositorio.
2. Los campos del proyecto: estado, prioridad, componente, referencia Jira, dependencia.
3. Un conjunto mínimo de etiquetas: `seguridad`, `qa`, `devops`, `deuda-tecnica`, `multi-tenant`,
   `adr`, `prioridad:highest|high|medium|low`.

Esa decisión no está tomada y no se asume en este documento.

## 2. Las referencias de trabajo existente son pull requests, no issues

Las referencias que circulan como «MANI-Node #43» o «MANI-.NET #1» son **números de pull request**.
Todas están fusionadas, así que ninguna genera un issue nuevo.

| Referencia | Qué es | Jira | Estado |
|---|---|---|---|
| MANI-Node #43 | Endpoints de elegibilidad, contexto de solicitud y notificaciones para Dispatch | SCRUM-1073 | Fusionado el 19 de octubre |
| MANI-Node #44 | Creación de la solicitud de servicio en Core, separada del despacho | SCRUM-1072 | Fusionado el 19 de octubre |
| MANI-Node #46 | El filtro por tipo de la elegibilidad acepta `EMPLEADO_DIRECTO` | SCRUM-862 | Fusionado el 19 de octubre |
| MANI-.NET #1 | Exclusión concurrente en la aceptación de solicitudes | SCRUM-1074 | Fusionado el 19 de octubre |
| MANI-.NET #2 | Orquestación de despacho a aliados elegibles | SCRUM-1073 | Fusionado el 19 de octubre |
| MANI-.NET #3 | Consulta de aliados válidos por cobertura y categoría | SCRUM-861 | Fusionado el 19 de octubre |
| MANI-.NET #8 | Filtro de aliados elegibles por tipo | SCRUM-862 | Fusionado el 19 de octubre |
| MANI-Java #2 | Reglas de categoría en el Rules Service | SCRUM-1070 | Fusionado el 17 de octubre |

La promoción de `develop` a `release` se hizo el 20 de octubre en los seis repositorios de código
(MANI-APIGateway#17, MANI-Node#48, MANI-Java#6, MANI-.NET#10, MANI-Flutter#50, MANI-Landing#5).

Pull requests abiertos al corte: MANI-docs#58 (línea base documental de los 23 hallazgos) y las
promociones a `release` de las correcciones de la regresión en MANI-Node#51, MANI-.NET#12 y
MANI-APIGateway#21, que llevan R-01, R-02 y R-03. Ninguno toca la validación de algoritmos de JWT.

## 3. H-01: corregido y validado, no genera tarea de desarrollo

El hallazgo H-01 de SCRUM-1266 (el endpoint `POST /api/v1/core/auth/dev-token` emitía, sin
autenticación y con el secreto real del ambiente, tokens para cualquier `tenantId` y rol) **ya está
corregido en el código y verificado en el ambiente**:

- `MANI-Node` `release` (2745bb0), `src/config/jwtSecret.js:37`: `isDevTokenEnabled` solo devuelve
  `true` con `NODE_ENV` igual a `development` o `test`.
- `src/routes/auth.routes.js:130`: la ruta se registra dentro de esa condición, así que en cualquier
  otro entorno no existe.
- `tests/auth.security.test.js:70`: prueba de regresión que exige 404 con `NODE_ENV` igual a
  `production`, `qa` y `staging`, incluso con el secreto real presente.
- Verificación en ambiente: SCRUM-1267 §3 registra que `/auth/dev-token` responde **404 en QA**
  (PER-05).
- Origen de la corrección: MANI-Node#27 y MANI-Node#29 (SCRUM-1333), promovidos en MANI-Node#48.

Por lo tanto H-01 se cierra documentalmente y **no se abre un issue de corrección**. Quedan tres
residuos, que son del mismo vector pero no del mismo hallazgo:

1. La llave **HS256 previa de `MANI-QA` sigue habilitada**: toda la regresión del Sprint 4 firmó
   tokens válidos con ella dentro de la VM (SCRUM-1267 §3). Quien tenga ese secreto emite tokens
   para cualquier tenant y rol, y Core los acepta.
2. `src/config/jwtSecret.js:4` versiona el valor literal `INSECURE_DEV_SECRET`. Fuera de
   `development` y `test` el servicio ya no arranca sin `SUPABASE_JWT_SECRET`, pero el valor está en
   el historial de Git y firma tokens válidos en cualquier entorno local.
3. ADR-0031 §1 todavía autoriza `/auth/dev-token` «exclusivamente para pruebas automatizadas y
   CI/CD» sin restricción de ambiente: el texto no refleja la guarda que el código ya aplica. Es una
   corrección documental en MANI-docs, no trabajo de desarrollo.

Los residuos 1 y 2 son el issue propuesto **S-01** (§4.2). El 3 es una enmienda de ADR-0031 que
corresponde a Arquitectura.

## 4. Issues propuestos

### 4.1 Issue 1 — MANI-Node. Validación de tokens ES256 (H-02 / R-10 / SCRUM-1362)

**Título:** `[SCRUM-1362] validate-token rechaza los tokens ES256 de Supabase: ningún usuario real accede a las rutas protegidas`

**Problema verificable.** `POST /api/v1/auth/validate-token` de Core acepta únicamente HS256
(`src/routes/auth.routes.js:9`, `ALLOWED_ALGORITHMS = ['HS256']`; igual en `develop` 8e198ff y en
`release` 2745bb0). Supabase Auth de `MANI-QA` y de `MANI` firma con ECC P-256 (ES256) y su JWKS
publica una sola llave ES256 (`kid` `a069a215-25f2-4958-8b90-ef5b289a025a`); HS256 solo sobrevive
como llave previa. Como el Gateway resuelve toda ruta protegida con `auth_request` hacia ese
endpoint (`nginx.conf:85`), el token real de un usuario autenticado recibe 401 en Core, Rules y
Dispatch.

**Contexto.** Comprobado el 20 de octubre a las 02:05 UTC: un password grant real de
`admin.t1@qa.mani.test` en `MANI-QA` devolvió 200 y un token ES256 con el `tenant_id` de t1, y el
Gateway lo rechazó con 401 `UNAUTHORIZED` en `core/profiles/me`, `rules/evaluate-rate` y
`dispatch/match`. La consecuencia es que la regresión completa del Sprint 4 se ejecutó con tokens
HS256 sintéticos firmados dentro de la VM: ninguna de las 27 historias quedó en *Aprobado* y QAS-01
no cumple.

**Componente responsable.** MANI-Node (Core), en `src/routes/auth.routes.js` y
`src/config/jwtSecret.js`. MANI-.NET (Dispatch) valida además con llave simétrica
(`Infrastructure/Auth/JwtAuthHelper.cs:46`, `SymmetricSecurityKey`): es un issue relacionado y
distinto, no parte de este alcance.

**Referencia a requisito o ADR.** ADR-0031 §1 (Aprobado) fija «HS256 en ambientes de desarrollo y
staging; preparado para RS256 vía JWKS de Supabase en producción». El emisor real usa **ES256**, que
el ADR no contempla. Este issue **depende de una enmienda a ADR-0031** que declare el algoritmo y la
fuente de llaves por ambiente, y no se implementa antes de esa enmienda.

**Evidencia existente.**

- [SCRUM-1266](REPORTE_QA_MONITOREO_QAS_SCRUM-1266.md) §5 (H-02) y §5.1 (D-02).
- [SCRUM-1267](REPORTE_QA_REGRESION_SCRUM-1267.md) §8 (R-10).
- `qa/monitoreo_qas/evidencia/20261020T020546Z_d02/confirmacion_d02_login_real.txt`.
- Reproducible con `qa/monitoreo_qas/confirmar_d02.sh` desde la VM de Calidad.
- `MANI-APIGateway` `qa/README.md:73-74`.

**Alcance.**

- Validar ES256 contra el JWKS del proyecto Supabase del ambiente, con caché de llaves y rotación
  por `kid`.
- Mantener el rechazo estricto por el `alg` declarado (sin confusión de algoritmo) y la
  obligatoriedad del claim `app_metadata.tenant_id`.
- Conservar la emisión de `X-Tenant-Id`, `X-User-Role` y `X-User-Id` para `auth_request_set`.
- Configuración por variable de entorno: URL del JWKS y algoritmos permitidos por ambiente.

**Exclusiones.** La validación propia de Dispatch; el retiro de la llave HS256 previa de `MANI-QA`
(issue S-01); cualquier cambio en el flujo de refresh del cliente Flutter.

**Criterios de aceptación.**

1. Un password grant real en `MANI-QA` devuelve un token ES256 y `GET /api/v1/core/profiles/me` por
   el Gateway responde 200 con el `tenantId` del claim; se adjunta al PR la corrida de
   `confirmar_d02.sh`.
2. Las tres rutas de la comprobación de H-02 (`core/profiles/me`, `rules/evaluate-rate`,
   `dispatch/match`) responden 200 con ese token.
3. Un token ES256 con firma alterada, vencido, con `kid` desconocido o sin
   `app_metadata.tenant_id` sigue recibiendo 401, con el código específico de ADR-0031 §3.
4. Un token que declara `alg: none` o un algoritmo no permitido recibe 401.
5. Pruebas automatizadas nuevas cubren los puntos 1 a 4 contra un JWKS de prueba, y
   `tests/auth.security.test.js` sigue en verde.
6. El Quality Gate de SonarQube del Core pasa.
7. La suite Newman de `MANI-APIGateway/qa/` se ejecuta con identidad real, no con tokens HS256
   sintéticos, y los casos que hoy dependen de ellos conservan su resultado.

**Dependencias y bloqueos.** Bloquea QAS-01 (casos 1 a 4 y 6), la aprobación de las 27 historias del
Sprint 4, SCRUM-1278 (E2E desde Flutter Web) y SCRUM-1263 (pase a producción). Está bloqueado por la
enmienda de ADR-0031. Relacionado: R-04 / SCRUM-1361 (la imagen de Flutter en QA apunta a
producción) impide el recorrido E2E real aunque esto se corrija.

**Prioridad.** Máxima: riesgo de seguridad —hoy el único camino que funciona es el inseguro— y
bloqueo de integración y despliegue.

**Responsable.** Core (MANI-Node). Sin persona asignada: el reporte de QA sugiere «Core y Dispatch»
sin nombre.

**Trazabilidad.** Jira SCRUM-1362 (BUG-SEC-04), enlazado a SCRUM-1267. QA: H-02 de SCRUM-1266 y
R-10 de SCRUM-1267. Sin pull request todavía.

### 4.2 Issue S-01 — MANI-Node y DevOps. Retiro del secreto HS256 legado

**Título:** `Retirar el secreto HS256 legado: llave previa activa en MANI-QA y secreto de desarrollo versionado`

**Problema verificable.**

1. `MANI-QA` conserva habilitada su llave HS256 previa. Toda la regresión del Sprint 4 firmó tokens
   válidos con ella desde la VM de QA (SCRUM-1267 §3). Quien tenga ese secreto emite tokens para
   cualquier `tenant_id` y rol, que Core acepta hoy.
2. `src/config/jwtSecret.js:4` versiona el valor literal de `INSECURE_DEV_SECRET`. Fuera de
   `NODE_ENV` igual a `development` o `test` el servicio ya no arranca sin `SUPABASE_JWT_SECRET`
   —corrección de SCRUM-1333—, pero el valor queda en el historial de Git y sigue firmando tokens
   válidos en cualquier entorno local.

Este issue **no es H-01**: la exposición de `/auth/dev-token` ya está corregida y validada (§3). Es
el residuo del mismo vector por otra vía.

**Componente responsable.** MANI-Node (Core) para el código; DevOps para las llaves de Supabase y
los secretos de ambiente.

**Referencia a requisito o ADR.** ADR-0031 §3 (segregación estricta de secretos por ambiente, llaves
fuera del control de versiones), ADR-0018 (identificación de tenant).

**Evidencia existente.** `src/config/jwtSecret.js:4` en `release` 2745bb0; SCRUM-1266 §5, última
frase de H-01; SCRUM-1267 §3, «Identidad de prueba»; `MANI-APIGateway` `qa/ejecutar_newman_qa.sh:32`
y `qa/README.md:73`.

**Alcance.** Dejar la llave ES256 como única llave válida de `MANI-QA` y de `MANI` una vez el issue 1
esté desplegado en QA; sustituir el secreto de desarrollo versionado por uno generado localmente y
rotar el que esté en uso; migrar las suites de QA a identidad real cuando el issue 1 lo permita.

**Exclusiones.** Purgar el historial de Git —decisión aparte; el valor debe considerarse comprometido
igual— y la validación ES256, que es el issue 1.

**Criterios de aceptación.**

1. Una búsqueda en el repositorio no devuelve ningún secreto JWT literal, y el arranque en
   `development` o `test` sin `SUPABASE_JWT_SECRET` no usa un valor conocido del repositorio.
2. En `MANI-QA`, la llave HS256 previa queda revocada: un token firmado con ella recibe 401 en
   `validate-token`, con la corrida adjunta como evidencia.
3. Las suites de `MANI-APIGateway/qa/` pasan sin firmar tokens HS256 propios.
4. ADR-0031 y [POLITICA_CONFIGURACION_JWT_CFG4-04](POLITICA_CONFIGURACION_JWT_CFG4-04.md) reflejan
   el estado final de las llaves por ambiente.

**Dependencias y bloqueos.** Bloqueado por el issue 1 desplegado en QA: revocar HS256 antes dejaría
QA sin ninguna identidad usable.

**Prioridad.** Alta por riesgo de seguridad. No bloquea el Sprint mientras se respete el orden con
el issue 1.

**Responsable.** Core y DevOps. Sin persona asignada.

**Trazabilidad.** Deriva del residuo de H-01 tras SCRUM-1333. Sin ticket de Jira propio: la Scrum
Master decide si se registra como defecto nuevo o como subtarea de SCRUM-1362.

## 5. Decisiones pendientes antes de crear los issues

1. Confirmar que H-01 se cierra documentalmente (§3) y que solo se abre S-01. Si se prefiere dejar
   rastro explícito en GitHub, el issue de H-01 se crearía ya cerrado, con la evidencia de §3.
2. El issue 1 está bloqueado por la enmienda de ADR-0031. Decidir si se registra ahora en estado
   *bloqueado* —registrar no es implementar— o si se espera la enmienda.
3. Confirmar MANI-Node como repositorio destino del issue 1, con la validación de Dispatch como
   issue separado en MANI-.NET.
4. Decidir quién crea el GitHub Project y el conjunto de etiquetas descritos en §1.

## 6. Lo que falta de este trabajo

Pendiente de la siguiente iteración, no cubierto aquí: el mapeo de H-03 a H-08 y de R-01 a R-11 al
repositorio responsable, con la decisión de issue único o tareas relacionadas; el dictamen sobre los
issues propuestos por arquitectura N3 (TLS en el borde), N4 (documentos KYC por tenant) y N6
(frontera de datos de Dispatch); y la comprobación de N1 (distancia en Dispatch) y N2 (acceso
directo de Flutter a Supabase), que no deben crearse automáticamente. N5 (seis esquemas de base de
datos) sigue dependiendo de la decisión asociada a ADR-0030.

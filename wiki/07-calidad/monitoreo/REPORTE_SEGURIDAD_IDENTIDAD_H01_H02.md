# Agente 3 — H-01 y H-02: flujo real de identidad en MANI

Corte: 2026-10-20. Fuentes: código de `MANI-Node` y `MANI-APIGateway` (ramas `develop`,
`release`, `main` y la revisión desplegada en QA), `MANI-docs` (ADR-0031, reporte QA
SCRUM-1266, reporte QA SCRUM-1267). No se ejecutó ninguna prueba contra ambientes: todo lo
de abajo es análisis de código y configuración más la evidencia QA ya existente.

Ningún secreto se transcribe en este documento.

---

## 1. Flujo de identidad reconstruido

```
Flutter ──HTTP──► NGINX Gateway (:80)
                   │
                   ├─ /api/v1/core/auth/*            → PRE-AUTH, sin auth_request
                   ├─ /api/v1/core/legal/documents/active (GET), /api/v1/core/catalog (GET) → pre-auth
                   ├─ /health, /api/v1/{core,rules,dispatch}/health → público
                   ├─ regex allies/eligible | solicitudes/*/context | notifications → 404 (SCRUM-1073)
                   └─ resto de /api/v1/{core,rules,dispatch}/
                          │ auth_request /_auth_validate
                          ▼
                      Core: POST/ALL /api/v1/auth/validate-token
                          · jwt.verify(token, SUPABASE_JWT_SECRET, { algorithms: ['HS256'] })
                          · exige app_metadata.tenant_id, app_metadata.user_role, sub
                          · responde 200 + X-Tenant-Id / X-User-Role / X-User-Id
                          ▼
                      auth_request_set captura esas tres cabeceras y el Gateway las
                      inyecta al upstream (Core / Rules / Dispatch) junto con Authorization
```

Dentro de Core, además, cada ruta protegida vuelve a validar por su cuenta:
`src/middlewares/auth.middleware.js` → `container.tokenService.verifyToken(authHeader)`
(`src/infrastructure/security/TokenService.js`). **Core no confía en `X-Tenant-Id`** del
Gateway: deriva tenant y rol del JWT que él mismo verifica. Eso es correcto y es la razón
por la que una eventual elusión del Gateway no basta por sí sola para falsificar tenant.

Punto clave del diagnóstico: **hay dos validadores distintos**.

| Camino | Archivo | Algoritmos | Claves |
|---|---|---|---|
| Perímetro (`auth_request`) | `src/routes/auth.routes.js` | `['HS256']` | solo `SUPABASE_JWT_SECRET` |
| Interno por ruta | `src/infrastructure/security/TokenService.js` | `['HS256','ES256']` | HS256 → secreto; ES256 → JWKS `${SUPABASE_URL}/auth/v1/.well-known/jwks.json` |

El perímetro es el más restrictivo, así que **rechaza tokens que el propio servicio sabe
verificar**. Eso es exactamente H-02.

---

## 2. H-01 — emisión insegura de `dev-token`

### Diagnóstico
`POST /api/v1/core/auth/dev-token` firma, con el secreto del ambiente, un JWT con
`tenantId`, `userId`, `role` y `expiresIn` tomados del cuerpo de la petición, sin
autenticación previa.

### Estado por rama (código)
| Rama | `dev-token` | Guarda |
|---|---|---|
| `origin/develop` | condicional | `isDevTokenEnabled(env)` → solo `NODE_ENV=development\|test` |
| `origin/release` | condicional | igual (contiene `c5ec252`) |
| `origin/main` | condicional | igual (contiene `c122f7e`) |
| `6ca27ab` (**revisión desplegada en QA** según SCRUM-1266 §2.1) | **incondicional** | ninguna |

En las tres ramas, además, `resolveJwtSecret()` falla cerrado: fuera de
`development|test`, si falta `SUPABASE_JWT_SECRET` lanza `JwtConfigurationError` y el
servicio no arranca, en vez de degradar al secreto de desarrollo.

**Conclusión: H-01 está corregido en `develop`, `release` y `main`; sigue vivo en QA**
porque la imagen `mani-node:staging` desplegada corresponde a `6ca27ab`, anterior al fix
(SCRUM-1333). La evidencia de SCRUM-1266 §4.1 (200 en `dev-token`, 200 en
`profiles/me`, `rules/*` y `dispatch/match` con ese token) es consistente con esa revisión.

### Lo que el 404 no cubre (revisado explícitamente)
1. **El Gateway no bloquea la ruta en ninguna rama.** `location /api/v1/core/auth/` es
   un prefijo pre-auth sin `auth_request`: cualquier ruta que Core registre bajo
   `/auth/` queda expuesta a internet sin token. El 404 depende solo de `NODE_ENV` del
   contenedor de Core. Un solo error de variable de entorno reabre el agujero.
2. **Core monta sus rutas en `/` y en `/api/v1`, y Express no distingue mayúsculas**
   (así lo documenta el propio `nginx.conf` en el bloque de SCRUM-1073). Rutas
   alternativas a probar: `/api/v1/core/api/v1/auth/dev-token`,
   `/api/v1/core/AUTH/Dev-Token`, con barra final y con `;` adosado.
3. **`validate-token` también está expuesto externamente** por ese mismo prefijo
   pre-auth. El Gateway lo consume por `/_auth_validate` contra `core-service:3000`, no
   por la ruta pública, así que la ruta pública no hace falta y sirve de oráculo: devuelve
   `userId`, `tenantId` y `role` de cualquier token que se le presente.
4. **DEV sí emite tokens arbitrarios por diseño.** `MANI-Node/.github/workflows/cd.yml`
   despliega DEV con `-e NODE_ENV=development`, luego `dev-token` queda habilitado en una
   VM compartida alcanzable por red, no en un portátil. Es aceptable solo si el secreto de
   DEV no vale en QA ni PROD.
5. **Hay dos caminos de despliegue.** `cd.yml` (disparado solo por CI en `main`, contenedores
   `mani-core-dev` / `mani-core-qa` desde GHCR por SHA) y el Docker Compose con imágenes
   `:staging` que es lo que SCRUM-1266 encontró corriendo en QA. Mientras los dos coexistan,
   "está corregido en `main`" no implica "está corregido en QA".
6. **Material de firma publicado.** La revisión desplegada lleva el literal
   `SUPABASE_JWT_SECRET || JWT_SECRET || '<secreto de desarrollo fijo>'` en el repositorio,
   y ADR-0031 §5 transcribe los secretos de DEV y de QA en texto plano dentro de
   `MANI-docs`. Con cualquiera de los dos, un tercero con acceso de lectura al repositorio
   firma tokens válidos **sin necesidad de `dev-token`**. Cerrar el endpoint no cierra esto.

### Impacto
Ruptura del aislamiento multitenant y de la autorización: elección libre de `tenant_id`
y de `user_role` (incluido `admin_tenant`) sobre Core, Rules y Dispatch.

### Causa raíz
Dos causas independientes:
- **Código/operación:** endpoint de emisión sin guarda, en una imagen promovida a QA, bajo
  un prefijo del Gateway deliberadamente pre-auth.
- **Gobierno:** ADR-0031 §1 declara `dev-token` como emisor legítimo "exclusivamente para
  pruebas automatizadas y CI/CD", sin excluir QA. El código nuevo (SCRUM-1333) contradice
  al ADR vigente. Esto lo resuelve el agente de gobierno ADR, no este informe.

### Repositorios responsables
`MANI-Node` (código, ya corregido), `MANI-APIGateway` (falta la defensa en profundidad),
infraestructura QA (imagen desplegada y variables), `MANI-docs` (ADR-0031).

---

## 3. H-02 — rechazo de tokens reales (ES256 de Supabase)

### Diagnóstico
`MANI-QA` (proyecto `hpsxdotaizzclkeufzct`) emite access tokens **ES256** con claves de
firma asimétricas. El validador del perímetro acepta únicamente **HS256**:

- `src/routes/auth.routes.js`: `const ALLOWED_ALGORITHMS = ['HS256'];` en `develop`,
  `release` y `main`.
- En la revisión desplegada `6ca27ab`: `['HS256','HS384','HS512']` — tampoco ES256.

Un token real de Supabase falla en `jwt.verify` con `JsonWebTokenError` y el Gateway
responde 401 `INVALID_SIGNATURE`. **H-02 sigue vivo en las tres ramas y en QA.** El fix de
SCRUM-1333 no lo toca.

### Lo que sí existe y no se está usando
`TokenService` ya resuelve la clave por el header del token: HS256 → secreto; ES256 →
`jwks-rsa` contra `${SUPABASE_URL}/auth/v1/.well-known/jwks.json`, con `kid`, y sin clave
por omisión. Es la base correcta; solo no la consulta el endpoint que el Gateway interroga.

### Huecos de validación en ambos caminos
Revisado contra emisor, audiencia, algoritmo, firma, vigencia, claves, rotación e identidad:

| Control | Perímetro | `TokenService` |
|---|---|---|
| Firma | sí (HS256) | sí (HS256/ES256) |
| Algoritmo fijado | sí | sí |
| Expiración | sí | sí |
| **`iss` verificado** | **no** | **no** |
| **`aud` = `authenticated`** | **no** | **no** |
| `kid` / rotación | n/a | vía `jwks-rsa` 4.1.0 con sus valores por omisión (caché activa 10 h, 5 entradas; **`rateLimit` desactivado**) |
| `tenant_id` obligatorio | sí, solo `app_metadata` | sí, solo `app_metadata` |
| `user_role` obligatorio | sí (`user_role`) | sí (`user_role \|\| rol`) |
| Confianza en cabeceras del cliente | el Gateway sobreescribe `X-Tenant-Id/Role/Id` con los valores de `auth_request` | Core no las lee; usa el JWT |

Sin `iss` ni `aud`, un token válido de **otro proyecto de Supabase** cuyo JWKS fuese
alcanzable, o un token de otro ambiente con el mismo secreto HS256, pasa la validación. La
caché de JWKS sí está activa por omisión en `jwks-rsa` 4.1.0, pero `rateLimit` no: un
atacante que varíe el `kid` fuerza una llamada de red al endpoint JWKS por petición, con el
endpoint JWKS en el camino crítico de cada petición ES256.

### Dependencia bloqueante: H-08
SCRUM-1266 §2.2 y D-08 reportan `SUPABASE_URL` del Core en QA apuntando a
`mock.supabase.co`, y SCRUM-1267 §3 indica que `.env.qa` tenía credenciales de relleno,
corregidas luego hacia `MANI-QA`. Mientras `SUPABASE_URL` no apunte al proyecto real, el
URI del JWKS es falso y **ES256 seguirá fallando aunque se habilite el algoritmo**. H-08
es prerrequisito de H-02, no un hallazgo paralelo.

### Nota sobre la evidencia Newman
`MANI-APIGateway/.github/workflows/qa-regresion.yml` firma los tokens de prueba dentro del
job con `QA_JWT_SECRET` ("JWT secret legado de MANI-QA"), es decir **HS256 sintético**. Esa
suite puede quedar verde sin que un token real de Supabase funcione nunca. Las pruebas de
aceptación de H-02 tienen que usar un token obtenido de GoTrue de QA, no uno firmado en CI.

### Impacto
Todo escenario funcional autenticado queda bloqueado por el camino legítimo, lo que empuja
a usar el camino inseguro (`dev-token`). H-01 y H-02 se refuerzan mutuamente: el único
acceso que funciona en QA es el falsificable.

### Causa raíz
Divergencia entre el emisor real del ambiente (Supabase ES256 con claves asimétricas) y la
política implementada en el perímetro (HS256 con secreto compartido), más la duplicación de
la lógica de verificación en dos archivos. ADR-0031 §1 fija "HS256 en desarrollo y staging,
preparado para RS256 en producción": ni describe ES256 ni el proyecto real de QA.

### Repositorios responsables
`MANI-Node` (unificar validación), infraestructura QA (`SUPABASE_URL`, secretos),
`MANI-docs` (ADR-0031 §1).

---

## 4. N3 — TLS en el borde (lo que el repositorio sí permite afirmar)

En `develop`, `release` y `main`, `nginx.conf` tiene **un solo `server` con `listen 80`**,
sin `ssl_certificate`, sin `listen 443`, sin `return 301` a HTTPS, y propaga
`X-Forwarded-Proto $scheme` (es decir, `http`) hacia los upstreams. `MANI-APIGateway` no
tiene workflow de CD ni compose de QA, y su `docker-compose.yml` publica `80:80`.

Eso **no demuestra que no haya TLS**: un terminador delante del contenedor sería invisible
aquí. Lo que sí se puede afirmar es que **no hay evidencia de terminación TLS en ninguno de
los repositorios**, y que si existe un terminador, el Gateway no está configurado para
confiar en su `X-Forwarded-Proto` (lo sobreescribe con `$scheme`).

Verificación pendiente, en la VM, por ambiente DEV/QA/PROD:
`ss -lntp` en los puertos 80/443; contenedores o servicios de borde (Traefik, Caddy,
nginx host, balanceador del campus); `openssl s_client -connect <host>:443` para cadena,
emisor y vigencia; `curl -I http://<host>/health` para ver si redirige; y qué esquema usa
realmente `QA_GATEWAY_URL`.

---

## 5. Gobierno (para el agente ADR, sin modificar nada)

Tres contradicciones del ADR-0031 vigente respecto al ambiente real y al código corregido:

1. **§1** legitima `/api/v1/auth/dev-token` como emisor para "pruebas automatizadas y
   CI/CD" sin excluir QA, mientras el código de `develop`/`release`/`main` ya lo restringe a
   `development|test`.
2. **§1** fija HS256 para desarrollo y staging y "preparado para RS256" en producción,
   cuando `MANI-QA` emite **ES256**.
3. **§5** transcribe los secretos JWT de DEV y de QA en texto plano dentro de `MANI-docs`,
   lo que contradice su propio requisito de mantenerlos fuera del control de versiones
   (Contexto, punto 3).

La mitigación urgente debe quedar trazable por separado de la decisión permanente: los
cambios de los puntos 1 y 2 de abajo son mitigación (no cambian política declarada); los
puntos 5 a 8 requieren que el ADR se actualice primero o en paralelo.

---

## 6. Plan mínimo para eliminar H-01 y H-02 sin debilitar el control multitenant

### Mitigación inmediata (sin tocar ADR, sin tocar algoritmos de autorización)

1. **Gateway: negar `dev-token` y la ruta pública de `validate-token`.** En
   `MANI-APIGateway/nginx.conf`, antes del prefijo `/api/v1/core/auth/`, con el mismo
   patrón que el bloque de SCRUM-1073 (regex insensible a mayúsculas, tolerante a prefijo
   repetido y a barra final):

   ```nginx
   location ~* "^/api/v1/core/(.*/)?auth/(dev-token|validate-token)([/;].*)?$" {
       default_type application/json;
       return 404 '{"error":"NOT_FOUND","message":"Ruta no disponible a traves del Gateway","correlationId":"$correlation_id"}';
   }
   ```
   Repos/ramas: `MANI-APIGateway` `develop` y `release`. No afecta a `/_auth_validate`,
   que va directo a `core-service:3000`.

2. **Redesplegar el Core de QA con una revisión que contenga `c5ec252`** (cabeza de
   `release`), con `NODE_ENV=qa` y `SUPABASE_JWT_SECRET` del proyecto `MANI-QA`. Con el fix
   presente, si el secreto falta el contenedor no arranca: eso es el comportamiento
   deseado, no un fallo de despliegue.

3. **Tratar como comprometido** el secreto de desarrollo fijo que está en el historial de
   `MANI-Node` y los valores de DEV/QA publicados en ADR-0031 §5: rotar el JWT secret de
   `MANI-QA` y de DEV, dejar los valores solo en `/opt/mani/.env.*`, y pedir al agente ADR
   que los retire del documento. Sin rotación, cerrar `dev-token` no quita la capacidad de
   firmar tokens válidos.

4. **Corregir `SUPABASE_URL` en QA** hacia el proyecto `MANI-QA` (H-08). Prerrequisito de
   cualquier prueba ES256.

### Corrección definitiva

5. **Un solo validador.** `validate-token` debe delegar en `TokenService` en vez de llamar
   a `jwt.verify` por su cuenta. Elimina por construcción que el perímetro sea más estricto
   que el interior.
6. **Algoritmos y claves por ambiente, explícitos:** `['ES256','HS256']` con ES256 vía
   JWKS del proyecto del ambiente; HS256 solo mientras exista el secreto legado de QA, con
   fecha de retiro. Fijar explícitamente en `jwks-rsa` `cache`, `cacheMaxAge` y, sobre todo, `rateLimit`, hoy desactivado por omisión.
7. **Verificar `iss` y `aud`.** `issuer: ${SUPABASE_URL}/auth/v1`, `audience: 'authenticated'`,
   ambos desde configuración, fallando cerrado si no están definidos fuera de dev/test.
8. **Mantener la regla de claims tal cual está en `develop`:** `tenant_id` y `user_role`
   solo desde `app_metadata`, sin respaldo a la raíz del token, y 401 si falta cualquiera.
   Esto es lo que sostiene el aislamiento multitenant; no debe relajarse para desbloquear
   ES256.
9. **`dev-token`, decisión permanente:** retirarlo del código y dejar que CI obtenga tokens
   de GoTrue con usuarios sembrados, o conservarlo solo bajo `NODE_ENV=test` y nunca en una
   imagen promovible. Requiere que ADR-0031 §1 se actualice primero.

### Pruebas de regresión (mínimo exigible antes de promover)

Negativas, todas por el Gateway, todas con aserción de código **y** de cuerpo:

| # | Caso | Esperado |
|---|---|---|
| 1 | Sin `Authorization` en ruta protegida | 401 |
| 2 | Esquema distinto de `Bearer` | 401 |
| 3 | Firma alterada | 401 `INVALID_SIGNATURE` |
| 4 | Token vencido | 401 `TOKEN_EXPIRED` |
| 5 | `alg: none` y `alg: HS256` firmado con la clave pública del JWKS (alg confusion) | 401 |
| 6 | Token válido sin `app_metadata.tenant_id` | 401 `MISSING_TENANT_CLAIM` |
| 7 | Token válido sin `app_metadata.user_role` | 401 |
| 8 | `tenant_id` en la raíz del token pero no en `app_metadata` | 401 |
| 9 | Token del tenant A leyendo un recurso del tenant B | 403/404, nunca 200 |
| 10 | `user_role` elevado a `admin_tenant` por reemisión con secreto ajeno | 401 |
| 11 | `sub` falsificado que no existe en `public.usuario` | sin acceso a datos |
| 12 | `X-Tenant-Id`, `X-User-Id`, `X-User-Role` enviados por el cliente en ruta protegida | ignorados; prevalece el claim |
| 13 | `iss` de otro proyecto de Supabase | 401 |
| 14 | `aud` distinto de `authenticated` | 401 |
| 15 | `POST /api/v1/core/auth/dev-token` desde QA y PROD | 404 |
| 16 | Variantes de la ruta: doble prefijo, mayúsculas, barra final, `;` | 404 |
| 17 | `POST /api/v1/core/auth/validate-token` desde fuera | 404 |

Positivas: token real emitido por GoTrue de `MANI-QA` (ES256), aceptado de extremo a
extremo en Core, Rules y Dispatch, con el `tenant_id` del claim y no otro. **La suite no
debe poder pasar firmando tokens en el propio job**: el caso positivo tiene que venir de
`signInWithPassword` contra el proyecto del ambiente.

### Condiciones de seguridad para promover una versión

- Casos 1 a 17 verdes contra el ambiente destino, con evidencia Newman redactada.
- Revisión desplegada == cabeza de la rama promovida (H-03 del reporte QA sigue abierto:
  el Gateway de QA corre `6b475f9` contra `release` `9874e93`).
- `SUPABASE_JWT_SECRET` y `SUPABASE_URL` del ambiente, verificados sin imprimirlos, y
  distintos por ambiente.
- `dev-token` responde 404 por el Gateway y por el puerto directo del servicio.
- TLS confirmado en el borde con certificado vigente y redirección 80→443.
- ADR-0031 actualizado o con enmienda registrada para los puntos 1 a 3 de la sección 5.

---

## 7. Riesgo residual tras el plan

- **DEV sigue emitiendo tokens arbitrarios** (`NODE_ENV=development` en `cd.yml`). Mitigado
  solo por la separación de secretos: si alguna vez DEV y QA comparten `SUPABASE_JWT_SECRET`,
  H-01 vuelve con alcance QA. Conviene una verificación automática de que los secretos
  difieren entre ambientes.
- **Core publica su puerto 3000 en el host** (`-p ${HOST_PORT:-3000}:3000`), así que es
  alcanzable sin pasar por el Gateway. Hoy no rompe el aislamiento porque Core revalida el
  JWT, pero las defensas que viven solo en `nginx.conf` (el 404 del punto 1, los bloqueos
  de SCRUM-1073) se eluden por ahí. Debería escuchar solo en la red interna.
- **HS256 coexistiendo con ES256** mantiene vivo un secreto compartido que, si se filtra,
  permite falsificar cualquier tenant. El riesgo solo desaparece al retirar HS256.
- **No hay identidad de servicio** entre Dispatch y Core: las rutas internas se protegen
  cerrándolas en el Gateway, no autenticando al llamante (así lo dice el propio comentario
  de `nginx.conf`).
- **Sin `/metrics` ni alertas** (SCRUM-1266 H-05), un abuso de autenticación no se detecta;
  la única traza es el log JSON de nginx con `x_correlation_id`.

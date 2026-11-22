# QAS-14 (resistencia): SAST, DAST y rate limiting

> Evidencia de QA del Sprint 6. Resultado en el [SDD §8](../../../../02-arquitectura/SDD.md). Mantiene: QA (Santiago Hernández).

22 de noviembre de 2026, de 03:29Z a 03:53Z. Ambiente MANI-QA (`10.43.100.141`, Gateway por el puerto 8080) con `release` del 20 nov (Core `73c28f4`, Dispatch `eedb112`, Rules `348f6d9`, Gateway `ee5000c`).

**Umbral (SDD §8):** 0 vulnerabilidades Critical/High conocidas abiertas en release de producción; rate limiting en el Gateway. **Método:** SonarQube y SonarCloud en los seis repositorios, OWASP ZAP contra QA y una ráfaga que reciba 429.

## 1. Resultado

| Parte | Medición | Cumple |
|---|---|---|
| SAST | 0 vulnerabilidades de seguridad High o Blocker abiertas en los seis repositorios (§2) | Sí |
| DAST | 0 FAIL en los cuatro escaneos de ZAP. Las 5 alertas High de inyección SQL son falsos positivos verificados (§3). Quedan Medium de cabeceras y CORS | Sí, con hallazgos Medium |
| Rate limiting | 429 por `write_limit` en QAS-13 y 3 respuestas 429 durante el escaneo activo (dispatch 1, rules 2) | Sí |

**Estado propuesto: Cumple**, con las diferencias de la §5.

## 2. SAST

SonarQube de la VM de Calidad (Community Build 26.10, consulta por túnel) y SonarCloud para Flutter. Issues abiertos o confirmados con impacto en seguridad y hotspots, en la rama principal de cada proyecto (`develop`).

| Repositorio | Último análisis | Seguridad abiertas | Severidad | Hotspots |
|---|---|---|---|---|
| Core (Node) | 19 nov | 4 | Medium: límite de tamaño del cuerpo en `auth.routes.js` (S5693, 2) y `Math.random` en dos repositorios en memoria (S2245, 2) | 0 |
| Dispatch (.NET) | 19 nov | 3 | Medium: CORS abierto en `Program.cs` (S5122) y lectura directa de la petición en `DispatchController` (S6932); Low: imagen como root (S6471) | 0 |
| Rules (Java) | 19 nov | 0 | — | 0 |
| Gateway | 19 nov | 1 | Low: nginx como root (S6471) | 0 |
| Landing | 20 oct (proyecto de PR: 15 nov) | 0 | — | 0 |
| Flutter (SonarCloud) | 21 nov | 0 | — (70 issues de mantenibilidad y confiabilidad) | 0 |

Con la severidad clásica tampoco hay Critical ni Blocker: Node 4 Major, .NET 1 Major y 1 Minor, Gateway 1 Minor.

## 3. DAST (OWASP ZAP 2.x, imagen `ghcr.io/zaproxy/zaproxy:stable`)

| Escaneo | Alcance | FAIL | High | Medium | Low |
|---|---|---|---|---|---|
| Baseline (pasivo) | App web en `/` | 0 | 0 | 2: falta CSP y cabecera anti-clickjacking | 7: cabeceras de aislamiento, `Permissions-Policy`, `X-Content-Type-Options`, versión en `Server`, timestamps en JS |
| API core (activo) | 139 rutas del contrato `core.yaml` | 0 | 1 (falso positivo) | 1: CORS permisivo | 5 |
| API dispatch (activo) | 16 rutas de `dispatch.yaml` | 0 | 1 (falso positivo) | 1: CORS permisivo | 3 |
| API rules (activo) | 12 rutas de `rules.yaml` | 0 | 3 (falsos positivos) | 1: CORS permisivo | 3 |

**Alertas High de inyección SQL (regla 40018, confianza media).** Son de tipo booleano: ZAP compara las respuestas a `AND 1=1` y `AND 1=2`. Se repitieron sin token sobre `core/admin/employees`, `dispatch/match`, `rules/categories/evaluate` y `rules/rates/evaluate`: las 12 variantes devuelven el **mismo 401 del Gateway con el mismo cuerpo**, así que la petición no llega al servicio. En el código, Core arma las consultas con parámetros (`$1`, `$2`…) y las columnas dinámicas del perfil salen de una lista fija; Dispatch usa una consulta constante con `NpgsqlCommand`; Rules no tiene SQL nativo. La diferencia que vio ZAP coincide con respuestas 429 del rate limit durante el escaneo. Reproducción: `zap_sqli_reproduccion_22nov.txt`.

## 4. Hallazgos

| # | Hallazgo | Severidad | Responsable sugerido |
|---|---|---|---|
| H-14-1 | La app web no envía `Content-Security-Policy` ni cabecera anti-clickjacking (`X-Frame-Options` o `frame-ancestors`). | Medium | DevOps (nginx del Gateway) |
| H-14-2 | CORS permisivo en las respuestas de core, dispatch y rules (ZAP 10098), y política CORS abierta en Dispatch (Sonar S5122). | Medium | Equipo de Dispatch y DevOps |
| H-14-3 | La cabecera `Server` revela la versión de nginx y Core envía `X-Powered-By`. | Low | DevOps y equipo de Core |
| H-14-4 | Las imágenes del Gateway y de Dispatch corren como root (S6471). | Low | DevOps |
| H-14-5 | Core: límite de tamaño del cuerpo en rutas de auth sin revisar (S5693). | Medium | Equipo de Core |

## 5. Diferencias con el método del SDD

- **Sonar analiza `develop`, no `release`.** La edición Community no analiza ramas; `release` se cortó de `develop` el 20 nov y los análisis son del 19 al 21 nov. Landing no se analiza en su proyecto principal desde el 20 oct.
- **DAST sin autenticación.** ZAP no tenía token, así que las rutas protegidas responden 401 en el Gateway y el escaneo activo no llega a la lógica de los servicios. Cubre el borde (Gateway, cabeceras, CORS, autenticación obligatoria) y las rutas públicas.
- **Solo QA.** No se escaneó el candidato a release de producción (PROD, `10.43.98.203`).
- **Carga sobre QA.** El escaneo activo usó 2 hilos por host y un tope de 15 min por servicio. Sin token no creó datos.

## 6. Evidencia

- `sonar_selfhosted_seguridad_22nov_0331z.json` y `sonarcloud_flutter_seguridad_22nov.json`: consulta de seguridad por proyecto.
- `zap_baseline_22nov_0329z.{json,txt}` y `zap_api_{core,dispatch,rules}_22nov_0331z.{json,txt}`: reportes de ZAP (los HTML quedan en la copia local de QA).
- `zap_sqli_reproduccion_22nov.txt`: reproducción de las alertas de inyección SQL.
- Script: `scripts/correr_zap.sh`. Los contratos usados son `MANI-API/docs/openapi/{core,dispatch,rules}.yaml` de `release` (`ee5000c`) con el servidor cambiado al Gateway de QA.

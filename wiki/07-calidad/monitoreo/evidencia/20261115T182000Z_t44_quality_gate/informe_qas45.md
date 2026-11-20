# SCRUM-1681 (T-44): QAS-45 Quality Gate de código nuevo en los 5 repositorios faltantes

**Fecha:** 2026-11-15 (hora Colombia). Los PR de prueba se abrieron a las 18:20Z; el segundo análisis del Gateway terminó a las 19:18Z.
**Alcance:** MANI-Java, MANI-.NET, MANI-APIGateway, MANI-Landing y MANI-Flutter. MANI-Node ya tenía su prueba de bloqueo: PR #42 en SCRUM-1265.
**Método:** SDD §8, QAS-45. Para cada repositorio se consulta el gate en Sonar y se abre un PR de prueba que lo incumple, para verificar que GitHub lo bloquea.
**Umbral:** 0 issues Blocker/Critical en código nuevo, duplicación de código nuevo < 3 % y pipeline que falla si el gate no se cumple.

## 1. Configuración del gate por repositorio

| Repo | Sonar | Gate | Condiciones sobre código nuevo | Ruleset (develop, release, main) |
|---|---|---|---|---|
| Java | self-hosted (VM) | `MANI ADR-0005` | issues > 0, hotspots revisados < 100 %, cobertura < 80 %, duplicación > 3 % | 25414209: exige "Pruebas y cobertura" y "Sonar Quality Gate", sin bypass |
| .NET | self-hosted | `MANI ADR-0005` | igual | 25451353: igual |
| APIGateway | self-hosted | `MANI ADR-0005` | igual (sin cobertura: `coverage.exclusions=**/*`) | 25451676: exige "Sonar Quality Gate" |
| Landing | self-hosted | `MANI ADR-0005` | igual | 25448535: exige "Pruebas y cobertura" y "Sonar Quality Gate" |
| Flutter | SonarQube Cloud (`trama-as`) | **`Sonar way`** (el único disponible en la organización) | ratings de confiabilidad, seguridad y mantenibilidad > A, cobertura < 80 %, duplicación > 3 %, hotspots < 100 % | 22166140: exige "Flutter Lint, Test & Build Check". Ese job corre Sonar con `qualitygate.wait=true` |

Antes de la prueba, el último gate de `develop` estaba en verde en los 5 repositorios.

## 2. PR de prueba ("NO FUSIONAR")

Cada PR agrega un archivo nuevo con issues a propósito y no toca código existente. En los repositorios del Sonar self-hosted el archivo trae un `if/else` con ramas idénticas (S3923) y, en Java y .NET, variables sin usar. En Flutter trae una función con complejidad cognitiva 16 o más (S3776) y un literal repetido (S1192); ambos son **Critical**.

| PR | Gate | Condición que falló | Estado de merge |
|---|---|---|---|
| [MANI-Java#12](https://github.com/Trama-AS/MANI-Java/pull/12) | **FAILED** (`mani-java-pr`) | `new_violations` = 1 > 0 (java:S3923) | **BLOCKED** |
| [MANI-.NET#35](https://github.com/Trama-AS/MANI-.NET/pull/35) | **FAILED** (`mani-dotnet-pr`) | `new_violations` = 2 > 0 (csharpsquid:S3923, CS0414) | **BLOCKED** |
| [MANI-Landing#7](https://github.com/Trama-AS/MANI-Landing/pull/7) | **FAILED** (`mani-landing-pr`) | `new_violations` = 1 > 0 (javascript:S3923) | **BLOCKED** |
| [MANI-APIGateway#96](https://github.com/Trama-AS/MANI-APIGateway/pull/96) | **FAILED** (`mani-apigateway-pr`), segundo intento | `new_violations` = 1 > 0 (javascript:S3923) | **BLOCKED** |
| [MANI-Flutter#139](https://github.com/Trama-AS/MANI-Flutter/pull/139) | **ERROR** (SonarCloud) | **solo** `new_coverage` = 0 % < 80. Los 2 Critical nuevos (S3776, S1192) dejaron `new_maintainability_rating` en A | **BLOCKED** |

En los tres repositorios del self-hosted que fallaron, la cobertura y la duplicación no se evaluaron (`ignoredConditions: true`), porque el cambio tiene menos de unas 20 líneas. El bloqueo lo produjo el issue nuevo, que es lo que se quería probar.

**Primer intento en el Gateway:** el archivo quedó en `qa/evidencia/`, que `qa/.gitignore` ignora, y Sonar no analiza los archivos ignorados por git (`1289 files ignored because of scm ignore settings`). El gate pasó con 0 issues nuevos porque el archivo nunca se analizó, no por una falla del gate. Se movió a `scripts/evidencia/` en la misma rama.

## 3. Hallazgo: en Flutter el gate no bloquea issues Critical nuevos

`Sonar way` no tiene una condición sobre issues por severidad. Solo exige que el *rating* de mantenibilidad del código nuevo sea A, y ese rating depende de la proporción de deuda técnica, no de la severidad. Un issue Critical en un archivo de tamaño normal no lo baja de A.

**Pruebas:**
- **PR #139** (esta prueba): el gate falló solo por cobertura. Con pruebas, el PR habría pasado con 2 Critical nuevos.
- **PR #137** (`[SCRUM-1710]`, fusionado el 15 nov 17:42Z): gate **OK**, con 1 issue Critical nuevo (S3776 en `mis_solicitudes_page.dart`, complejidad 31). Hoy ese issue está en `develop`.
- De los 42 Critical abiertos en `develop`, 25 se crearon el 27 oct o después, todos con el gate en verde.

**Por qué no se corrige desde la configuración:** la organización `trama-as` en SonarQube Cloud solo tiene `Sonar way` y no permite crear gates (`actions.create: false`). Los gates personalizados son una función de pago.

**Propuesta** (aplicada en la §8): agregar en `ci.yml`, después del paso de Sonar, un paso que consulte la API pública de SonarQube Cloud. Si el PR tiene issues abiertos de severidad Blocker o Critical, el paso falla y el job obligatorio también:

```yaml
- name: Sin issues Blocker/Critical nuevos (QAS-45)
  if: github.event_name == 'pull_request'
  run: |
    total=$(curl -s "https://sonarcloud.io/api/issues/search?componentKeys=Trama-AS_MANI-Flutter&pullRequest=${{ github.event.number }}&severities=BLOCKER,CRITICAL&issueStatuses=OPEN,CONFIRMED&ps=1" | jq .total)
    echo "Issues Blocker/Critical nuevos: $total"
    test "$total" = "0"
```

Con ese paso, el PR #137 habría quedado bloqueado.

## 4. Los 42 Critical de Flutter

Hay 42 abiertos en `develop` (no 41): 35 son S3776 (complejidad cognitiva) y 7 son S1192 (literal repetido). El detalle, uno por uno, está en [`flutter_critical_tabla.md`](flutter_critical_tabla.md).

**Qué son.** Son problemas de mantenibilidad, no fallas: la app funciona igual con ellos.
- **S3776, complejidad cognitiva:** Sonar suma puntos por cada `if`, `else`, `for`, `&&` o `? :`, y suma más si están anidados. Un método no debe pasar de 15. Se corrige partiendo el método en widgets o métodos pequeños, sin cambiar lo que ve el usuario.
- **S1192, literal repetido:** el mismo texto escrito tres veces o más, como una ruta o una cabecera HTTP. Se corrige con una constante.

**Por qué siguen ahí.** El paso de la §8 solo bloquea los issues que trae cada PR. Los 42 que ya estaban en `develop` no bloquean a nadie, pero tampoco desaparecen solos: hay que corregirlos en el código.

Sprint 6 es el último del proyecto, así que **ninguno queda como deuda**: los 42 se corrigen en este sprint. La tabla solo fija el orden y el tipo de arreglo.

| Prioridad | Cantidad | Arreglo |
|---|---|---|
| **1. Constantes** | 7 | Los S1192: rutas repetidas en `app_router.dart` (pasan a `AppRoutes`), cabeceras HTTP en `gateway_client.dart` (pasan a constantes) y "Cerrar sesión" en `app_shell.dart` (pasa a l10n). Bajo esfuerzo y bajo riesgo |
| **2. Refactor de lógica y pantallas grandes** | 7 | Lógica central: `gateway_client.dart` (42) y `app_router.dart` (25). Pantallas con complejidad de 30 o más: `cotizacion_page.dart` (64), `categories_page.dart` (42), `registrar_empleado_directo_page.dart` (33), `declarar_cobertura_page.dart` (31) y `mis_solicitudes_page.dart` (31) |
| **3. Extraer widgets** | 28 | Complejidad entre 16 y 28 en métodos de pantallas que arman el árbol según el estado (cargando, error, vacío o rol). Se bajan a 15 o menos extrayendo cada estado a un widget o método propio |

En la tabla de detalle, la columna "Justificado" equivale a la prioridad 3. No se marcó ningún issue como aceptado en SonarQube Cloud. Corregir los 42 es condición para pasar SCRUM-1681 a Finalizada.

**Pendiente de decisión.** Corregirlos es trabajo de desarrollo de Flutter, no de QA, y en Jira no hay ninguna tarea para eso. Sara, que maneja el backlog, debe decidir quién los corrige y si se corrigen los 42 o se prioriza. Hay que tener en cuenta el riesgo: los 35 de complejidad tocan cerca de 30 pantallas en el último sprint.

## 5. Estado propuesto de QAS-45

**Cumple** (actualizado el 15 nov a las 19:55Z, después de la §8).
- En Node (PR #42), Java, .NET, Landing y APIGateway el gate rechaza cualquier issue nuevo, exige duplicación < 3 % y cobertura ≥ 80 %, y el ruleset bloquea el merge.
- En Flutter, el paso de CI de la §8 bloquea los PR con issues Blocker o Critical nuevos, aunque `Sonar way` pase. Se probó con el PR #141.

Primer corte, antes de la §8: **Parcial**, porque el gate de Flutter dejaba pasar issues Critical nuevos.

## 6. Cierre de los PR de prueba

El 15 nov, ~19:25Z, los 5 PR se cerraron **sin fusionar** (`mergedAt: null`). Cada uno lleva un comentario de cierre y su rama `evidencia/SCRUM-1681-gate-rojo` quedó borrada. En `develop` no entró ningún cambio.

## 7. Evidencia

| Archivo | Contenido |
|---|---|
| `github_*_pr*.json` | Estado de cada PR (checks y `mergeStateStatus`) y su ruleset |
| `sonar_selfhosted_gates.json` | Gate asignado, condiciones e issues nuevos de cada proyecto `-pr` del Sonar de la VM |
| `sonarcloud_flutter_*.json` | Gate de los PR #139 y #137, sus issues Critical y el gate asignado en SonarQube Cloud |
| `flutter_critical_develop.json`, `flutter_critical_tabla.md` | Los 42 Critical de `develop` con su clasificación |

## 8. Corrección en Flutter y prueba en rojo

**Cambio:** [MANI-Flutter#140](https://github.com/Trama-AS/MANI-Flutter/pull/140) (`[SCRUM-1681]`), fusionado a `develop` el 15 nov a las 19:46Z (`957fdb3`). Agrega en `ci.yml`, después de la espera del gate y dentro del job obligatorio `Flutter Lint, Test & Build Check`, el paso **"Sin issues Blocker o Critical nuevos (QAS-45)"**.
- El paso consulta `api/issues/search` del PR, autenticado con `SONAR_TOKEN`, con `severities=BLOCKER,CRITICAL` e `issueStatuses=OPEN,CONFIRMED`.
- Falla si el total es mayor que 0, si la API no responde o si la respuesta no trae el total.
- Antes de fusionarlo, el script se probó contra la API real: con el #139 da 2 y falla, con el #137 da 1 y falla, con el #136 da 0 y pasa, y con un token inválido devuelve 401 y falla.
- En el CI del propio #140 el paso dio 0 y pasó.

**Prueba en rojo:** [MANI-Flutter#141](https://github.com/Trama-AS/MANI-Flutter/pull/141), "NO FUSIONAR". Agrega una función con complejidad cognitiva 20 (`dart:S3776`, Critical) y una prueba que cubre todas sus ramas ([corrida 43754418082](https://github.com/Trama-AS/MANI-Flutter/actions/runs/43754418082)).

| Paso | Resultado |
|---|---|
| Análisis de SonarQube Cloud y espera del gate | `QUALITY GATE STATUS: PASSED`: cobertura nueva 100 %, mantenibilidad A, duplicación 0 % |
| Sin issues Blocker o Critical nuevos (QAS-45) | **failure**: `Issues Blocker o Critical nuevos en el PR #141: 1`, `CRITICAL dart:S3776` |
| Check obligatorio y merge | `fail` y **BLOCKED** |

Es el caso del #137: sin el paso nuevo, este PR se habría podido fusionar. El #141 se cerró sin fusionar a las ~19:54Z y su rama se borró.

Evidencia: `github_mani-flutter_pr141.json`, `sonarcloud_flutter_pr141_gate.json` y `sonarcloud_flutter_pr141_issues.json`.

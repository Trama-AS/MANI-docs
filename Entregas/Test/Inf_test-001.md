# Informe de test — Sprint 2

**Ticket:** SCRUM-953 (DOC-24) · **Responsable:** Santiago (QA) · **Fecha:** 2026-09-22

## Alcance

Este informe documenta los resultados de las pruebas automatizadas ejecutadas en el sprint,
según lo acotado por la subtarea SCRUM-985: **CFG-06** (job de pruebas unitarias/integración en
el pipeline) y la parte de **concurrencia de CFG-09**. No es un informe de las 4 PoC — ese es
`Inf_PoC-001` (SCRUM-952) — aunque comparte con él la evidencia de concurrencia de CFG-09, que
aquí se reutiliza en vez de remedirse.

---

## CFG-06 — Job de pruebas automatizadas en el pipeline (SCRUM-923)

### 1. Qué job se agregó y en qué etapa corre

Un único job, **`Flutter Lint, Test & Build Check`**, concentra validación estática, pruebas y
build. Las tres ramas de larga vida declaran ese mismo nombre de job en `.github/workflows/ci.yml`,
de modo que el check es homogéneo en todo el flujo de promoción:

| Rama | Nombre del workflow | Dispara en |
|---|---|---|
| `develop` | `CI - Develop Pull Request Validation` | `push` y `pull_request` a `develop` |
| `release` | `CI - Release & Staging Validation` | `push` y `pull_request` a `release`, `release/**` |
| `main` | `CI - Production Validation (main)` | `push` y `pull_request` a `main` |

Las pruebas corren en tercera posición del job, después de las validaciones baratas y antes del
build (el paso caro):

```
1. Checkout repository
2. Ensure environment file exists      (cp .env.example .env)
3. Setup Flutter                       (canal stable, con caché)
4. Install dependencies                (flutter pub get)
5. Check code formatting               (dart format --set-exit-if-changed)
6. Analyze code (Linter)               (flutter analyze)
7. Run widget & unit tests with coverage   <-- unitarias y de widget
8. Run integration tests (RF-14)           <-- integración
9. Verify Web Build                    (flutter build web --release)
```

El orden es deliberado: un error de formato o de análisis aborta antes de gastar minutos de
runner en compilar. Los dos pasos de prueba, tal como están en `develop`:

```yaml
      - name: Run widget & unit tests with coverage
        run: flutter test --coverage

      - name: Run integration tests (RF-14)
        run: flutter test test/integration
```

El primero genera `coverage/lcov.info`, que SonarQube consume vía
`sonar.dart.coverage.reportPaths`.

**Nota sobre el paso 8:** el paso con nombre propio "Run integration tests (RF-14)" existe hoy
solo en `develop`. En `release` y `main` la prueba de integración **igual se ejecuta**, porque
`test/integration/` es subcarpeta de `test/` y queda cubierta por `flutter test --coverage` — lo
que no aparece en esas ramas es la línea identificable con nombre propio en la interfaz de
GitHub Actions.

### 2. Qué pasa si una prueba falla

**El pipeline se detiene**, por tres capas:

- **Capa 1 — el comando:** `flutter test` devuelve exit code 1 cuando cualquier aserción falla o
  un archivo de prueba no compila.
- **Capa 2 — el paso:** ningún paso de prueba lleva `continue-on-error: true`, `|| true`,
  `set +e` ni `if: always()` — un exit distinto de cero marca el paso como *failure*.
- **Capa 3 — el job:** GitHub Actions, ante un paso fallido sin `if:` que lo exima, aborta el
  job: los pasos posteriores pasan a *skipped* y el job se reporta como *failed*.

**Demostración A — fallo de aserción provocado.** Se rompió a propósito el assert de la prueba de
integración (invirtiendo el resultado esperado del segundo aliado):
```
EXIT CON TEST ROTO = 1
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Asignada a aliado-b": []>
  00:00 +0 -1: Some tests failed.
EXIT RESTAURADO = 0
```
El cambio se revirtió de inmediato; nunca se commiteó.

**Demostración B — corte real observado en CI.** Run
[35798085628](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35798085628) de `develop`,
commit `de47f43`:
```
[ok   ] Set up job
[ok   ] Checkout repository
[ok   ] Ensure environment file exists
[ok   ] Setup Flutter
[ok   ] Install dependencies
[FALLA] Check code formatting
[skip ] Analyze code (Linter)
[skip ] Run widget & unit tests with coverage
[skip ] Run integration tests (RF-14)
[skip ] Verify Web Build
```
Un solo paso rojo detiene la cadena completa; el job queda en *failed* y nada continúa "por si
acaso".

**Alcance del bloqueo:** el job se pone rojo siempre, pero que ese rojo **impida el merge**
depende del ruleset de la rama destino. Hoy solo está configurado en `main`, que exige el check
`Flutter Lint, Test & Build Check` en verde con *strict required status checks*. En `develop` y
`release` el check es informativo, no bloqueante.

### 3. Resultado real

Medición del 22/09/2026, Flutter 3.47.5 stable / Dart 3.13.4, sobre worktrees limpios de cada
rama.

**Rama `release`:** `flutter test --coverage` sale con exit 0 — **7 pruebas, 7 pasan, 0 fallan, 0
en skip.**

| Archivo | Casos | Detalle |
|---|---|---|
| `test/features/asignacion/asignacion_repository_test.dart` | 5 | unitarias |
| `test/integration/asignacion_rf14_test.dart` | 1 | integración |
| `test/widget_test.dart` | 1 | smoke |

Unitarias — grupo `RF-14 · aceptación de solicitud`:
1. el primer aliado en aceptar se queda con la solicitud
2. un segundo aliado recibe `ya_no_disponible`
3. el reintento del mismo aliado es idempotente
4. una solicitud inexistente no se puede aceptar

Grupo `RNF-05 · exclusión concurrente`:
5. cinco aceptaciones simultáneas producen exactamente una asignación

Integración RF-14: *una solicitud se asigna a un único aliado y el resto ve `ya_no_disponible`*.
Recorre la interfaz completa: el aliado A acepta y ve la asignación, el aliado B intenta sobre la
misma solicitud y obtiene el rechazo, y se comprueba que el estado persistido sigue siendo el del
primero. `flutter test test/integration` por separado: exit 0, 1/1. Formato y análisis también en
verde.

**Rama `develop`:** 39 pruebas pasan. Un archivo no compila, por lo que `flutter test` sale con
exit 1 — el gate reportando correctamente.

| Ruta | Casos | Estado |
|---|---|---|
| `test/features/asignacion/` | 7 | pasan (los 5 de `release` más dos de `obtener`) |
| `test/features/profiles/coverage/` | 30 | pasan (de otra tarea, cobertura de aliados) |
| `test/integration/asignacion_rf14_test.dart` | 1 | pasa |
| `test/widget_test.dart` | 1 | pasa |
| `test/integration/verificacion_aliados_us0213_test.dart` | 0 | no compila |

Ninguna prueba en skip en ninguna rama. El único fallo no es una aserción rota sino un archivo
que no resuelve sus imports — sirve igual como caso real de detección.

**Rama `main`:** solo `test/widget_test.dart`. Recibirá el resto por promoción
`develop → release → main`.

### 4. Evidencia disponible

**Definición del pipeline:** `.github/workflows/ci.yml` en `develop`, `release` y `main` — tres
versiones, mismo nombre de job.

**Pruebas:**
- `test/features/asignacion/asignacion_repository_test.dart` — unitarias de RF-14 y RNF-05
- `test/integration/asignacion_rf14_test.dart` — integración de RF-14
- `lib/features/asignacion/` — modelo `Solicitud`, `AsignacionRepository` y la pantalla que la prueba ejercita
- `test/features/profiles/coverage/` — unitarias de cobertura
- `test/widget_test.dart` — smoke

**Runs de CI:**

| Propósito | Run | Rama | Commit | Resultado |
|---|---|---|---|---|
| Pipeline completo en verde | [35798590605](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35798590605) | `release` | `640130e` | success |
| Paso de integración ejecutado y en verde | [35553915665](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35553915665) | `develop` | — | success |
| Gate cortando la cadena ante un paso rojo | [35798085628](https://github.com/Trama-AS/MANI-Flutter/actions/runs/35798085628) | `develop` | `de47f43` | failure, 4 pasos skipped |

**Trazabilidad de la integración:** `MANI-Flutter#4`, que introdujo las pruebas y el paso del
workflow en `develop` (6 archivos, +315 líneas, sin líneas borradas).

**Gobernanza:** sección 2.3.1 propuesta en `MANI-docs#3`.

### 5. Cumplimiento del criterio de terminado

El ticket define, textualmente:
> **Entregable / salida verificable:** Pipeline falla si falla una prueba
> **Criterio de terminado / métrica:** Al menos una prueba de integración que cubra el flujo de asignación.

**Ambos se cumplen.** El criterio de terminado se satisface con `asignacion_rf14_test.dart`, que
cubre exactamente el flujo de RF-14 y DD-MANI.md §7.1 (una solicitud se asigna a un único aliado,
los demás reciben `ya_no_disponible`) y está presente y en verde en `develop` y `release`. El
entregable se satisface con las tres capas descritas en el punto 2, demostradas por partida
doble: fallo provocado en local y corte real observado en CI.

**Estado por subtarea:**

| Subtarea | Estado |
|---|---|
| SCRUM-954 — job de pruebas unitarias | Cerrada, con evidencia de ejecución |
| SCRUM-955 — job de integración RF-14 | Cerrada, mergeada en `MANI-Flutter#4` |
| SCRUM-956 — el pipeline falla si falla una prueba | Cerrada, verificada dos veces |
| SCRUM-957 — gate verificado en un PR | **Pendiente** de evidencia del bloqueo de merge |
| SCRUM-958 — regla documentada como gobernanza | Redactada, `MANI-docs#3` en revisión |

### 6. Hallazgos de CFG-06

- **El paso de integración con nombre propio vive solo en `develop`.** En `release` y `main` la
  prueba se ejecuta igual dentro de `flutter test --coverage`; la diferencia es de visibilidad en
  la interfaz de Actions, no de cobertura real. Se uniformará por promoción.
- **El alcance del bloqueo depende de la rama.** El ruleset con check requerido solo existe en
  `main`. En `develop` y `release` el job se pone rojo pero no impide integrar — es lo que
  mantiene abierta SCRUM-957 y lo que la sección 2.3.1 propuesta registra como brecha conocida,
  con responsable asignado.
- **Cobertura de seguridad parcial dentro del pipeline.** SonarQube quedó restringido a `main`
  tras los 403 del Quality Gate del 20/09. OWASP ZAP no está en ningún workflow, y las suites
  Newman de aislamiento de ADR-0015 siguen siendo corrida manual. El job de CFG-06 cubre pruebas
  funcionales, no la cadena DevSecOps completa.
- **Las pruebas verifican el contrato, no la base de datos real.**
  `InMemoryAsignacionRepository` reproduce el `UPDATE` condicional atómico de ADR-0021, y el `await` interno actúa como punto de
  entrelazado real entre aceptaciones concurrentes. La exclusión efectiva en PostgreSQL requerirá
  un job con `services: postgres` cuando exista el backend; el contrato está definido de modo que
  ese cambio no obligue a reescribir las pruebas.
- **Posible contradicción (por confirmar) con la deuda reportada en CFG-12** (ver informe `Inf_PoC-001`): el
  workflow de `release` incluye un paso **`Apply DB Migrations to Supabase QA`** que aplica
  `database/migrations/*.sql` contra QA **en cada push**. Esto parece chocar con lo que reportó
  CFG-12 — que la cadena de migraciones nunca ha corrido porque `schema_migrations` no existe en
  QA. Puede no ser una contradicción real (el job corre, pero las políticas RLS simplemente no
  están en esos archivos `.sql` porque nunca se escribió un `CREATE POLICY`), pero vale la pena
  que alguien lo confirme antes de dar la deuda de CFG-12 por cerrada o reabierta.

---

## CFG-09 — Prueba de concurrencia (SCRUM-926), parte reutilizada de la PoC

Se incluye aquí solo el resultado del test de concurrencia, ya medido en la PoC de SCRUM-926
(`Inf_PoC-001`) — no se vuelve a ejecutar para este informe.

**Pregunta que respondía:** ¿el `UPDATE` condicional sobre `solicitud` garantiza exactamente 1
asignación exitosa cuando N aliados aceptan la misma solicitud de forma simultánea?

**Resultado (corrida de referencia r4-exclusion, N=50):** 1 asignación en bitácora, 0 dobles
asignaciones, 1×`200 OK`, 49×`409 ya_no_disponible`, 50/50 checks k6 en verde. Control negativo
(r2): 10 asignaciones de 10 transacciones distintas en 136 ms bajo la misma alineación — confirma
que el mecanismo, no la ausencia de carrera, produce el resultado de r4.

**Evidencia:** `qa/k6/aceptar_concurrente.js`, `qa/k6/evidencia/bitacora.json` (fuente de verdad),
`Entregas/PoC/PoC-001-exclusion-concurrente-aceptacion.md` — ver el detalle completo (las 5
corridas r1–r5, tiempos de `http_req_duration`, herramientas) en `Inf_PoC-001`, sección PoC-001.

**Relación con CFG-06:** las unitarias de `RNF-05 · exclusión concurrente` en
`asignacion_repository_test.dart` (punto 3 arriba) prueban el mismo contrato a nivel de código
(`InMemoryAsignacionRepository`), mientras que esta prueba de CFG-09 lo valida contra el
`UPDATE` condicional real en PostgreSQL vía k6 — son dos capas de la misma garantía, no una
duplicación.

---

## Hallazgos transversales de este informe

- **Doble capa de validación de la exclusión concurrente:** unitaria (CFG-06, contrato en
  memoria) + de integración real (CFG-09, PostgreSQL bajo carga). Vale la pena dejarlo explícito
  como fortaleza del sprint, no solo como dato suelto.
- **El gate de CI no bloquea merges fuera de `main`** — mismo tipo de brecha proceso-vs-tablero
  que ya se documentó para CFG-12/CFG-13 en `Inf_PoC-001` (ahí era Jira vs. repo; aquí es
  "pipeline en rojo" vs. "PR igual se puede mergear").
- **Punto abierto de reconciliación:** confirmar si el job `Apply DB Migrations to Supabase QA`
  contradice o no la deuda de "políticas RLS sin versionar" reportada en CFG-12.

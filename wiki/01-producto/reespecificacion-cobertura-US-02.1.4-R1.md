# Reespecificación US-02.1.4-R1 · Cobertura por catálogo jerárquico (SCRUM-1067)

[← 01 · Producto](README.md)

| Campo | Valor |
|---|---|
| Historia | [SCRUM-1067](https://maniservices.atlassian.net/browse/SCRUM-1067) · US-02.1.4-R1 |
| Reespecifica | [SCRUM-849](https://maniservices.atlassian.net/browse/SCRUM-849) · US-02.1.4 Declarar zona de cobertura |
| Requisitos | RF-07, REST-01, RNF-09 · [ADR-0011](../02-arquitectura/adr/ADR-0011-cobertura-geografica.md) |
| Responsable | José Nicolás Álvarez |
| Estado | Propuesta para revisión de la PO (Camila) y QA (Santiago) |
| Corte del código | MANI-Flutter, MANI-Node, MANI-.NET y MANI-APIGateway `develop` del 26-oct-2026 |

## 1. Qué cambia

**Antes (SCRUM-849):** la historia original admitía la selección libre de la cobertura en un mapa (así la describe `BACKLOG_MANI.md` §3.5). Eso contradice REST-01 y RNF-09: la cobertura se declara por zonas de un catálogo administrativo, no por radio, coordenadas ni geometría propia (ADR-0011, alternativas 1 y 2 descartadas).

**Ahora:** la cobertura de un aliado es un **conjunto de zonas activas del catálogo jerárquico** `ciudad → localidad/comuna → barrio`, con **barrio como el nivel más fino** que se puede seleccionar en el MVP del Sprint 5.

No se conserva ninguna forma de selección libre: ni puntos, ni polígonos, ni radio, ni ubicación del dispositivo.

## 2. Reglas de la cobertura

1. **Solo zonas del catálogo.** Cada zona declarada debe existir en `zona` y estar `ACTIVO` en el momento de declararla.
2. **La jerarquía cubre hacia abajo.** Declarar una zona cubre a todas sus descendientes: quien declara una localidad cubre sus barrios. Por eso la selección se guarda **normalizada**: nunca contiene a la vez una zona y un ancestro suyo. Si se agrega un ancestro, las descendientes ya seleccionadas se absorben.
3. **El match es por identificador.** Una solicitud en la zona `Z` hace match con un aliado que declaró `Z` o algún ancestro de `Z`. Ni distancia ni geometría.
4. **Zonas desactivadas.** El catálogo desactiva zonas, no las elimina (ADR-0011). Una zona declarada que luego se desactiva deja de producir match y se muestra al aliado como desactivada para que la reemplace.
5. **La cobertura pertenece al tenant.** `cobertura_aliado` lleva `tenant_id`. Un aliado solo lee y escribe su propia cobertura, y el tenant y el aliado salen del JWT verificado (T4).

## 3. Criterios de aceptación propuestos

Toman los de la descripción de Jira y los precisan con las reglas anteriores. Los aprueba la PO.

- **C1.** El aliado aprobado recorre `ciudad → localidad/comuna → barrio`, selecciona zonas activas en cualquiera de esos niveles y, al guardar, la selección persiste normalizada y se ve igual al recargar.
- **C2.** Una zona inexistente o inactiva se rechaza con error del contrato y **sin cambios parciales**: si una zona del lote es inválida, no se guarda ninguna.
- **C3.** Un aliado no lee ni modifica la cobertura de otro aliado ni la de otro tenant. Tenant y aliado salen del JWT, nunca del cuerpo ni de cabeceras.

## 4. Frontera con las historias vecinas

| Historia | Responsable | Qué hace | Qué **no** hace |
|---|---|---|---|
| **SCRUM-1067** (esta) | José Nicolás Álvarez | Fija la regla de negocio y los criterios de la selección jerárquica, y verifica que no quede selección libre | Construir el catálogo, la pantalla o la persistencia |
| SCRUM-1393 | Sara Albarracín | Catálogo de zonas como recurso: consulta por padre y búsqueda, estados y consistencia entre niveles | La declaración del aliado |
| SCRUM-1395 | Sara Albarracín | Barrio como nivel del catálogo y sus relaciones con la zona padre | La pantalla del aliado (1385) |
| SCRUM-1385 | Camila Beltrán | Experiencia del aliado: seleccionar, consultar y conservar sus zonas | El catálogo (1393) |
| SCRUM-1068 | Nicolás León | Persistir la cobertura y exponerla al despacho por un contrato aprobado | La pantalla (1385) |

## 5. Verificación del estado actual

| Comprobación | Resultado | Cómo se verificó |
|---|---|---|
| ¿Queda selección libre en mapa? | **No.** No hay dependencias de mapas ni coordenadas en la app. | `git grep -i -E "flutter_map\|google_maps\|LatLng"` sobre `lib/` y `pubspec.yaml` de MANI-Flutter `develop`: sin resultados |
| ¿La pantalla ya es jerárquica? | **Sí.** `declarar_cobertura_page.dart` es un selector `ciudad → localidad → barrio`, y `SeleccionCobertura` aplica la regla 2 (normalización por ancestros). | Lectura de `lib/features/profiles/coverage/` |
| ¿La elegibilidad aplica la regla 3? | **Sí.** `PgElegibilidadRepository` sube por `zona_padre_id` desde la zona de la solicitud y solo cuenta coberturas declaradas en zonas `ACTIVO`. | Lectura de `src/infrastructure/repositories/PgElegibilidadRepository.js` en MANI-Node |
| ¿Qué niveles existen? | `zona.nivel` es texto libre, sin `CHECK`. La migración 007 normaliza `CIUDAD` y `LOCALIDAD`, pero no hay normalización ni restricción para `BARRIO`. | `001_initial_schema.sql` y `007_normalizar_dominios.sql` de MANI-APIGateway |
| ¿Por dónde lee y escribe la app? | Por las RPC de Supabase `listar_zonas`, `buscar_zonas`, `obtener_mi_cobertura` y `declarar_cobertura`, **que no están en ninguna migración versionada** de ningún repositorio. Core no tiene endpoints de zonas ni de cobertura. | `git grep` de esas funciones en los cuatro repos y de las rutas en `src/routes` de MANI-Node |

**Qué se reutiliza:** el dominio y la UI de `lib/features/profiles/coverage/` (entidades `Zona` y `SeleccionCobertura`, controlador y pantalla) ya cumplen las reglas 1 a 4. Cuando la 1393 y la 1068 expongan sus endpoints por el Gateway, solo cambia la fuente de datos (`cobertura_remote_datasource.dart`), sin rehacer la pantalla.

## 6. Decisiones que necesita el equipo

Las decide la SM con la Mesa de Arquitectura; aquí solo se dejan planteadas.

1. **Granularidad del ADR-0011.** El ADR dice que en el MVP la granularidad operativa es *localidad/comuna*, y su condición de revisión es justamente exigir una precisión menor. El Sprint 5 (1067 y 1395) pone barrio como nivel más fino. **Propuesta:** actualizar el ADR-0011 a «barrio como nivel más fino seleccionable; la jerarquía cubre hacia abajo». El modelo de datos no cambia.
2. **¿Catálogo global o por tenant?** El ADR-0011 y el esquema (`zona` sin `tenant_id`) dicen que el catálogo es **global de plataforma** y que lo que pertenece al tenant es la cobertura. Los criterios de la 1393 (C1, «acotado al tenant») y de la 1385 (C3, «zonas de otros tenants no aparecen») suponen zonas por tenant. Hay que elegir entre:
   - **(a)** catálogo global; C3 se cumple sobre la cobertura y no sobre las zonas; o
   - **(b)** habilitación de zonas por tenant, que necesita una tabla nueva con `tenant_id` y RLS.
3. **Normalizar `BARRIO` en `zona.nivel`.** Si se agrega el nivel (1395), conviene que la misma migración fije los valores permitidos (`CIUDAD`, `LOCALIDAD`, `BARRIO`), en el repositorio que define el ADR-0030 (MANI-Node `db/migrations`).
4. **Sacar las RPC de cobertura de Supabase.** Las cuatro RPC no están versionadas, así que no se pueden revisar ni recrear en otro ambiente, y la lógica vive en PL/pgSQL, en contra del ADR-0022. Lo natural es que Core exponga:
   - el catálogo (1393): por ejemplo, zonas por padre y búsqueda;
   - la cobertura propia (1068 y 1385): por ejemplo, consultar y reemplazar la cobertura del aliado de la sesión.

   La ruta exacta la define el contrato de esas historias.

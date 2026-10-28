# Cumplimiento de ADR-0027 en MANI-Flutter: inventario de accesos directos a Supabase

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [ADR-0027](adr/ADR-0027-alcance-supabase-cliente-flutter.md) (solo `supabase.auth` en el cliente) · [ADR-0022](adr/ADR-0022-logica-de-negocio-en-servicios.md) (lógica de negocio en servicios, no en PL/pgSQL) · criterio transversal **T6** del libro de módulos del Sprint 5. Tarea: **SCRUM-1619** (ARQ-ADR0027).

Fecha de examen: 2026-10-28. Solo lectura: este documento no cambia código. Responde a los criterios C1 (inventario), C2 (historia responsable de cada archivo) y C3 (búsqueda de verificación) de la tarea, y deja preparado el registro de C4 (desviación aceptada).

## 1. Código examinado

| Repositorio | `develop` |
|---|---|
| MANI-Flutter | `3b28b76` |
| MANI-Node (Core) | `3983922` |
| MANI-APIGateway | `65c4d7a` |

Todo lo que sigue se refiere a `develop`. `main` de los tres repositorios sigue en el corte del 21-oct y no tiene ninguno de los retiros del Sprint 5.

## 2. Qué cuenta como incumplimiento

ADR-0027 conserva `supabase_flutter` **solo para identidad y sesión** y prohíbe `.from()` (PostgREST), `.rpc()` y `.storage.from()`. Por eso este inventario separa tres cosas:

- **Acceso a datos (incumple):** una llamada `.rpc(…)`, `.from('tabla')` o `.storage.from(…)`.
- **Uso de Auth (cumple):** `Supabase.initialize`, `auth.signInWithPassword`, `auth.signOut`, `auth.currentSession`, `auth.currentUser`, `onAuthStateChange`, los tipos `User`, `Session` y `GoTrueClient`.
- **Residuo sin acceso (cumple, limpieza opcional):** un `catch` de `PostgrestException` o `StorageException` que quedó en un repositorio cuyo datasource ya va por el Gateway. No llama a Supabase, pero ya no puede ocurrir.

**Ajuste al método de la auditoría.** La búsqueda original (`\.rpc(|storage\.from(|Supabase\.instance`) marca como «acceso a datos» cualquier `Supabase.instance`, que también es la forma de leer la sesión. Además, un patrón `\.from\(` sin comillas captura `Map<String, dynamic>.from(…)`, que no es Supabase. La búsqueda de la sección 5 solo cuenta las llamadas prohibidas.

## 3. Los nueve archivos de la auditoría (C1 y C2)

| # | Archivo (`lib/…`) | Acceso hoy | Historia responsable | Estado |
|---|---|---|---|---|
| 1 | `core/di/injection_container.dart` | Solo Auth: registra el cliente y lee el token y el usuario de la sesión (líneas 83, 92, 97, 248) | — | **Cumple** |
| 2 | `core/routing/app_router.dart` | Solo Auth: `onAuthStateChange` y `currentSession` (líneas 65, 193, 276, 291) | — | **Cumple** |
| 3 | `features/asignacion/data/datasources/asignacion_remote_datasource.dart` | Ninguno: ya no usa el SDK (la coincidencia de la línea 54 es `Map.from`) | SCRUM-1403 (Flutter #76) | **Retirado** |
| 4 | `features/auth/data/datasources/auth_remote_data_source.dart` | Solo Auth: `signInWithPassword` (171), `signOut` (374), token de sesión (160). La línea 190 es un comentario que menciona `.rpc()` | SCRUM-1380 (alcance de Auth) | **Cumple** |
| 5 | `features/profile_categories/data/datasources/categories_remote_datasource.dart` | **`.rpc`**: `listar_categorias_tenant` (23), `obtener_mis_categorias` (29), `guardar_mis_categorias` (33) | **SCRUM-1392** (HU-M04-03, aliado declara sus categorías) | **Pendiente** |
| 6 | `features/profiles/coverage/cobertura_injection.dart` | Crea el datasource de la fila 7 con `Supabase.instance.client` (línea 14) | **SCRUM-1385** | **Pendiente** (se va con la fila 7) |
| 7 | `features/profiles/coverage/data/datasources/cobertura_remote_datasource.dart` | **`.rpc`**: `listar_zonas` (34), `buscar_zonas` (40), `obtener_mi_cobertura` (44), `declarar_cobertura` (48). Su cabecera dice «no hay backend intermedio» | **SCRUM-1385** (HU-M03-02) | **Pendiente** |
| 8 | `features/profiles/verification/data/datasources/verificacion_remote_datasource.dart` | Solo Auth: lee el usuario de la sesión (línea 93); los datos van por `GatewayVerificacionDataSource` | SCRUM-1384 (Flutter #83) | **Retirado** |
| 9 | `features/services/requests/data/datasources/solicitudes_cliente_remote_datasource.dart` | Solo Auth: `currentUser` (201, 205); categorías, sitios y zonas van por Core | SCRUM-1465 (Flutter #66 y #79) | **Retirado** |

Ningún archivo quedó sin historia, así que C2 no requiere abrir historias nuevas.

## 4. Archivos fuera de la lista de la auditoría

La auditoría listó los archivos que coinciden con su patrón, pero `supabase_flutter` se importa en **19 archivos** de `lib/`. Los diez restantes también se revisaron:

| Archivo (`lib/…`) | Uso | Clasificación |
|---|---|---|
| `main.dart` | `Supabase.initialize` | Auth, cumple |
| `core/session/sesion_expirada.dart` | `GoTrueClient`, `Session` | Auth, cumple |
| `features/auth/data/datasources/recuperacion_contrasena_remote_data_source.dart` | `auth.signOut` | Auth, cumple |
| `features/auth/data/models/user_model.dart` | tipo `User` | Auth, cumple |
| `features/auth/data/repositories/auth_repository_impl.dart` | `AuthException`, `User` | Auth, cumple |
| `features/services/categories/data/datasources/categorias_remote_datasource.dart` | `auth.currentUser` | Auth, cumple |
| `features/profile_categories/data/repositories/categories_repository_impl.dart` | `catch` de `PostgrestException` | Se va con la fila 5 (SCRUM-1392) |
| `features/profiles/coverage/data/repositories/cobertura_repository_impl.dart` | `catch` de `PostgrestException` | Se va con la fila 7 (SCRUM-1385) |
| `features/profiles/verification/data/repositories/verificacion_aliados_repository_impl.dart` | `catch` de `PostgrestException` y `StorageException` | Residuo sin acceso (SCRUM-1384) |
| `features/services/categories/data/repositories/categorias_repository_impl.dart` y `features/services/requests/data/repositories/solicitudes_cliente_repository_impl.dart` | `catch` de `PostgrestException` | Residuo sin acceso (SCRUM-1465) |

No hay ningún uso de `.from('tabla')`, `.storage`, `.functions` ni `.channel(` (Realtime) en `lib/`.

## 5. Lo que falta para retirar los dos accesos pendientes

| Historia | RPC que reemplaza | Equivalente en Core (`develop`) | Contrato en el Gateway | Falta |
|---|---|---|---|---|
| **SCRUM-1392** (Sara) | `listar_categorias_tenant` | `GET /profiles/me/categories/available` | **No está** en `core.yaml` | Declarar las tres rutas en `core.yaml` (T8) y cambiar el datasource de Flutter al `GatewayClient` |
| | `obtener_mis_categorias` | `GET /profiles/me/categories` | **No está** | |
| | `guardar_mis_categorias` | `PUT /profiles/me/categories` | **No está** | |
| **SCRUM-1385** (Camila) | `listar_zonas`, `buscar_zonas` | `GET /catalog/zones` (SCRUM-1393) | Sí (`/catalog/zones`) | Cambiar la lectura del catálogo al Gateway |
| | `obtener_mi_cobertura`, `declarar_cobertura` | **No existe** | No | Endpoint de cobertura del aliado. El servicio dueño está **pendiente de decisión** (SCRUM-1068, en `blocked` por SAD/ADR) |

Dos observaciones del mismo examen:

- Las RPC `listar_zonas`, `obtener_mi_cobertura` y `declarar_cobertura` **no están versionadas** en ninguna migración (ni en `MANI-Node/db/migrations` ni en `MANI-APIGateway/database`). Se crearon a mano en Supabase, así que un ambiente nuevo no las tiene.
- La cobertura es el único caso en que no basta con conectar el front a un endpoint existente: falta la decisión del servicio dueño. Es el candidato más probable a desviación aceptada (C4).

## 6. Verificación de cierre (C3)

Desde la raíz de MANI-Flutter, con `develop` actualizado:

```bash
git fetch origin
git grep -n -E '\.rpc\(|\.storage\b|\.from\(\s*['"'"'"]|\.functions\b|\.channel\(' origin/develop -- 'lib/**' \
  | grep -v -E '^[^:]+:[^:]+:[0-9]+:\s*//'
```

- La segunda línea descarta comentarios. Sin ella, el comentario de `auth_remote_data_source.dart:190` aparece como falso positivo.
- **Resultado esperado para acreditar ADR-0027: ninguna línea.**
- **Resultado al 2026-10-28 (`3b28b76`): 2 líneas**, las de `categories_remote_datasource.dart:17` y `cobertura_remote_datasource.dart:25`. Son los métodos `_rpc` que usan las 7 RPC de las filas 5 y 7.

Según la tarea, la búsqueda debe repetirse antes del despliegue del 5-nov y su resultado se anota en esta sección.

## 7. Desviaciones aceptadas (C4)

Se completa al cierre del sprint solo si quedan accesos. Cada fila necesita la aprobación de la SM y una fecha de retiro.

| Archivo | RPC vivas | Motivo | Historia de retiro | Fecha de retiro | Aprobó |
|---|---|---|---|---|---|
| _(vacío hasta el cierre)_ | | | | | |

# Menú, rutas y guardas por rol

[← 02 · Arquitectura](../README.md) · [Índice](../../Home.md)

**Fuente:** MANI-Flutter `lib/core/session/rol_usuario.dart`, `lib/core/session/guardas_ruta.dart`, `lib/core/shell/menu_por_rol.dart`, `lib/core/shell/app_shell.dart`, `lib/core/session/contexto_plataforma.dart`, `lib/core/routing/app_router.dart`, `lib/features/home/` y `docker/nginx-web.conf` · [`SAD.md`](../SAD.md) §8.3.1 · [ADR-0027](../adr/ADR-0027-alcance-supabase-cliente-flutter.md).

Esta página es de la capa **guía**: explica lo que ya está construido y no decide nada. Si contradice al código, manda el código y esta página se corrige.

| Campo | Valor |
|---|---|
| **Finalidad** | Decir qué menú ve cada rol, qué rutas puede abrir, cuál es su pantalla de inicio y cómo se contrasta eso con las 18 rutas de SCRUM-1638 |
| **Mantiene** | Nicolás Álvarez (desarrollo del menú, las guardas y el inicio) |
| **Consume** | Desarrollo (al añadir una pantalla), QA (casos por rol), DevOps (verificación de rutas tras un despliegue), PO |
| **Cada cuánto se actualiza** | Cuando se añade o se retira una ruta, una entrada del menú o un rol |
| **Versión y fecha** | 1.0 · 2026-11-16 |
| **Corte del código** | MANI-Flutter `develop` `957fdb3` (2026-11-15). El router declara las mismas 46 rutas que `main` `7d7521a`, que es el tag `v1.0.4` desplegado en PROD |
| **Historias** | Funcionalidad: [SCRUM-1444](https://maniservices.atlassian.net/browse/SCRUM-1444) (menú), [SCRUM-1445](https://maniservices.atlassian.net/browse/SCRUM-1445) (guardas) y [SCRUM-1446](https://maniservices.atlassian.net/browse/SCRUM-1446) (inicio); contexto de plataforma en [SCRUM-901](https://maniservices.atlassian.net/browse/SCRUM-901) · Esta página: [SCRUM-1705](https://maniservices.atlassian.net/browse/SCRUM-1705) (T-60) |

## 1. La regla que no hay que olvidar

**El menú y las guardas solo deciden qué pinta la app. No son la autorización.** La autorización la aplican el Gateway y los servicios con el token verificado: Core y Dispatch responden 403 a un rol que no corresponde, aunque alguien fuerce la ruta en el navegador. Por eso la app lee el rol del token sin verificar la firma: ese dato solo decide qué se muestra.

## 2. De dónde sale el rol

La app decodifica el *access token* de la sesión y lee `app_metadata.user_role` (o `app_metadata.rol`). No lee `user_metadata`, porque el propio usuario puede editarlo.

| Valor del claim | Rol en la app | Etiqueta en la cabecera |
|---|---|---|
| `cliente`, `client` | `cliente` | Cliente |
| `aliado`, `ally` | `aliado` | Aliado |
| `admin_tenant`, `admin` | `adminTenant` | Administrador |
| `admin_plataforma`, `platform_admin` | `adminPlataforma` | Administración de plataforma |
| Cualquier otro, ausente o token mal formado | `desconocido` | Sin rol |

La comparación no distingue mayúsculas. Un rol que no se reconoce cae en `desconocido` y no abre ninguna pantalla de negocio.

## 3. Tabla por rol: menú, rutas e inicio

**La pantalla de inicio es `/inicio` para todos los roles** (SCRUM-1446). Es la primera entrada del menú, y a ella llega quien entra con sesión a `/login` o a una ruta que no es de su rol. Lo que cambia por rol es su contenido (§5).

| Rol | Menú superior, en orden | Prefijos de ruta que puede abrir | Inicio |
|---|---|---|---|
| **Cliente** | Inicio · Nueva solicitud · Mis solicitudes · Historial · Mis sedes · Mis quejas · Avisos · Mi perfil | `/inicio`, `/cliente/`, `/catalogo/`, `/sitios/`, `/perfil/` | `/inicio` |
| **Aliado** | Inicio · Solicitudes · Historial · Cobertura · Categorías · Mis cobros · Disponibilidad · Avisos · Mi perfil | `/inicio`, `/aliado/`, `/categories`, `/catalogo/`, `/sitios/`, `/perfil/` | `/inicio` |
| **Administrador del tenant** | Inicio · Verificación de aliados · Categorías · Cancelaciones · Tarifario · Fuera de rango · Empleados · Auditoría · Conversaciones · Reglas · Quejas · Métricas · Mapa de zonas · Avisos · Mi perfil | `/inicio`, `/admin/`, `/catalogo/`, `/sitios/`, `/perfil/` | `/inicio` |
| **Administrador de plataforma** | Inicio · Tenants · las entradas del rol con el que actúa (§4) · Avisos · Mi perfil | Todos: `/inicio`, `/plataforma/`, `/admin/`, `/cliente/`, `/aliado/`, `/categories`, `/catalogo/`, `/sitios/`, `/perfil/` | `/inicio` |
| **Sin rol** | Inicio · Mi perfil | `/inicio`, `/catalogo/`, `/perfil/` | `/inicio`, con el aviso «Tu cuenta no tiene un rol asignado» |

Dos diferencias entre el menú y las guardas, que son intencionales:

- **«Mapa de zonas» (`/catalogo/mapa`) solo aparece en el menú del administrador**, pero la guarda la abre a todos los roles. El cliente y el aliado llegan a ella desde sus propias pantallas.
- **`/sitios/:id/reglas` no está en ningún menú.** Se abre desde las sedes del cliente o desde la solicitud del aliado.

En pantallas angostas el menú pasa a un botón compacto con las mismas entradas y «Cerrar sesión».

## 4. Administrador de plataforma: «Actuar como»

El administrador de plataforma elige un tenant y, si quiere, un usuario de ese tenant con el que actuar ([SCRUM-901](https://maniservices.atlassian.net/browse/SCRUM-901)).

- Sin usuario elegido, su menú suma las entradas del **administrador del tenant**.
- Si actúa como un cliente o un aliado, suma las entradas de ese rol. El inicio muestra el resumen y los accesos de ese mismo rol.
- La app manda el contexto en las cabeceras `X-Mani-Tenant` y `X-Mani-Actuar-Como` solo cuando la sesión es de administrador de plataforma. Core rechaza con 403 `MANI-PLA-403` a cualquier otro rol que las envíe.
- El contexto se borra al iniciar o cerrar sesión.

## 5. Qué muestra el inicio de cada rol

El inicio saluda con el nombre de la sesión, muestra un resumen y repite como tarjetas las entradas del menú del rol (menos «Inicio»).

| Rol | Indicadores del resumen | De dónde salen |
|---|---|---|
| Cliente | Sedes registradas | `GET /api/v1/core/solicitudes/sitios` |
| Aliado | Categorías que atiendo · Estado ahora · Ausencias programadas | `GET /api/v1/core/profiles/me/categories` y `/profiles/me/unavailability` |
| Administrador del tenant | Aliados por verificar · Categorías del catálogo | `GET /api/v1/core/aliados/verificacion` y `/catalog/categories` |
| Administrador de plataforma | Los del rol con el que actúa | Los de ese rol |
| Sin rol | Ninguno; solo el aviso | No aplica |

## 6. Cómo decide la guarda

El router llama a `resolverRedireccion` en cada navegación y cada vez que cambia el estado de autenticación:

```text
¿La ruta es pública?
 ├─ Sí ─► ¿hay sesión y la ruta es /login? ─► sí: va a /inicio · no: sigue
 └─ No ─► ¿hay sesión?
           ├─ No ─► /login
           └─ Sí ─► ¿el rol puede abrir el prefijo de la ruta?
                     ├─ Sí ─► sigue
                     └─ No ─► /inicio
```

- **Rutas públicas:** `/login`, `/register-cliente`, `/register-aliado`, `/register-empresa`, `/register-cliente-empresa`, `/forgot-password`, `/reset-password`, y las redirecciones de compatibilidad `/register`, `/registro` y `/registro-*`.
- **`/`** redirige a `/login`.
- **Gana el primer prefijo que coincide** en la tabla de `guardas_ruta.dart`.
- **Una ruta con sesión que no figura en la tabla se niega.** Así una pantalla nueva no queda abierta a todos los roles por olvido.

### Al añadir una pantalla

1. Declarar la ruta en `app_router.dart`, dentro del `ShellRoute`.
2. Si usa un prefijo nuevo, añadirlo a `_rolesPorPrefijo` en `guardas_ruta.dart`. Sin eso, la guarda la niega a todos.
3. Si debe salir en el menú, añadir la entrada en `menu_por_rol.dart`. Solo se listan rutas que ya existen en el router.
4. Actualizar las pruebas de §8 y esta página.

## 7. Contraste con las 18 rutas de SCRUM-1638

[SCRUM-1638](https://maniservices.atlassian.net/browse/SCRUM-1638) (T-01) pide repetir en PROD las 18 rutas del front `v1.0.4`. La lista usada es la del comentario de DevOps del 2026-11-14 en esa tarea. Aquí se contrasta cada una con el router de `v1.0.4` (`7d7521a`).

| # | Ruta de la lista | ¿Está en el router? | Quién la abre | Entrada del menú |
|---|---|---|---|---|
| 1 | `/` | Sí, como redirección a `/login` | Todos | No aplica |
| 2 | `/login` | Sí, pública | Todos; con sesión lleva a `/inicio` | No aplica |
| 3 | `/perfil` | **No.** Existen `/perfil/editar` y `/perfil/avisos` | No aplica | «Mi perfil» apunta a `/perfil/editar` |
| 4 | `/perfil/avisos` | Sí | Todos los roles | Avisos |
| 5 | `/cliente/historial` | Sí | Cliente, plataforma | Historial (cliente) |
| 6 | `/aliado/historial` | Sí | Aliado, plataforma | Historial (aliado) |
| 7 | `/admin/aliados/pendientes` | **No.** La pantalla es `/admin/verificacion-aliados` | No aplica | «Verificación de aliados» |
| 8 | `/admin/servicios/categorias` | **No.** La pantalla es `/admin/categorias` | No aplica | «Categorías» (administrador) |
| 9 | `/admin/politica-cancelacion` | Sí | Administrador, plataforma | Cancelaciones |
| 10 | `/admin/tarifas` | Sí | Administrador, plataforma | Tarifario |
| 11 | `/admin/reportes/cotizaciones-fuera-de-rango` | Sí | Administrador, plataforma | Fuera de rango |
| 12 | `/admin/empleados/nuevo` | Sí | Administrador, plataforma | Empleados |
| 13 | `/admin/auditoria-transacciones` | Sí | Administrador, plataforma | Auditoría |
| 14 | `/admin/conversaciones` | Sí | Administrador, plataforma | Conversaciones |
| 15 | `/admin/reglas` | Sí | Administrador, plataforma | Reglas |
| 16 | `/admin/quejas` | Sí | Administrador, plataforma | Quejas |
| 17 | `/admin/metricas` | Sí | Administrador, plataforma | Métricas |
| 18 | `/plataforma/tenants` | Sí | Solo plataforma | Tenants |

**Resultado: 15 de las 18 están declaradas en el router y 3 no** (filas 3, 7 y 8).

Dos cosas que se desprenden del contraste y que se reportan, no se corrigen desde aquí:

- **Un HTTP 200 no prueba que la pantalla exista.** El servidor web del front responde `index.html` a cualquier ruta (`try_files $uri $uri/ /index.html` en `docker/nginx-web.conf`). Por eso las 18 responden 200, incluidas las 3 que el router no declara. Lo que prueba la ruta es abrirla en el navegador con la sesión del rol correspondiente, que es lo que pide [`VALIDACION_HU-VAL-01.md`](../../06-gobernanza/VALIDACION_HU-VAL-01.md) para la fila D1: «ruta, código HTTP, pantalla carga sí/no».
- **Tres rutas de la lista no son las del front.** Si la lista original es otra, hay que corregir esta tabla; si es esta, hay que corregir la lista con las rutas reales de las filas 3, 7 y 8. Lo decide quien responde por SCRUM-1638 (DevOps) con la PO.

Rutas con sesión del router que la lista de 18 no cubre: `/inicio`, las del cliente (`/cliente/solicitudes`, `/cliente/solicitudes/nueva`, `/cliente/solicitudes/:id/aliados`, `/cliente/solicitudes/:id/cotizacion`, `/cliente/solicitudes/:id/chat`, `/cliente/pagos/:cotizacionId`, `/cliente/sedes`, `/cliente/quejas`), las del aliado (`/aliado/solicitudes`, `/aliado/solicitudes/:id/cotizacion`, `/aliado/solicitudes/:id/chat`, `/aliado/cobertura`, `/aliado/cobros`, `/aliado/disponibilidad`, `/categories`), `/admin/verificacion-aliados`, `/admin/categorias`, `/catalogo/mapa`, `/sitios/:id/reglas` y `/perfil/editar`.

## 8. Pruebas

| Qué cubre | Archivo en MANI-Flutter |
|---|---|
| Rol leído del token y contexto «Actuar como» | `test/core/shell/app_shell_test.dart` y `test/core/session/contexto_plataforma_test.dart` |
| Redirección sin sesión, por rol y desde `/login` | `test/core/session/guardas_ruta_test.dart` |
| Menú por rol y cierre de sesión | `test/core/shell/app_shell_test.dart` |
| Router completo dentro del shell, con sesión de cada rol | `test/core/routing/app_router_shell_test.dart` |
| Inicio por rol | `test/features/home/inicio_test.dart` |

## 9. Historial

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-11-16 | Versión inicial, contrastada con MANI-Flutter `develop` `957fdb3` y con el tag `v1.0.4` ([SCRUM-1705](https://maniservices.atlassian.net/browse/SCRUM-1705)) |

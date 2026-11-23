# QAS-34 y QAS-35: revisión del 23 de noviembre de 2026

> Evidencia de QA. Resultado en el [SDD §8](../../../../../02-arquitectura/SDD.md). Mantiene: QA (Santiago Hernández).

Versiones revisadas: Flutter `95a3e42` (en QA, `http://10.43.100.141:8080`) y Landing `a82b94e` (la de QA, compilada y servida en local, porque la Landing de QA no responde desde el equipo de QA). Revisión de experto con el navegador, el árbol de accesibilidad y pruebas automatizadas. No se usó lector de pantalla real ni Lighthouse.

## QAS-34 Inclusividad: No cumple

**Paso 1, criterio publicado.** Ahora existe: `PRODUCT.md` de MANI-Flutter (commit `8ee8fcf`, 10 nov) fija WCAG 2.2 AA: contraste de texto ≥ 4,5:1, controles y foco ≥ 3:1, uso completo con teclado en web, áreas táctiles ≥ 44 px y respeto de movimiento reducido. El corte del 21 nov no lo encontró. Falta llevarlo al SDD (§7.9) y a MANI-Landing, que no tiene criterio propio.

**Paso 2, comprobación contra WCAG 2.2 AA.**

| Criterio | Flutter Web (QA) | Landing |
|---|---|---|
| 1.4.3 Contraste de texto | Cumple en los tokens: `test/core/theme/contrast_test.dart`, 38 de 38 pruebas (claro y oscuro) | **No cumple**: 33 de 316 textos bajo el umbral. Botón principal blanco sobre `#E4572E` = 3,68:1; texto amarillo `#F2B705` sobre blanco = 1,82:1 |
| 3.1.1 Idioma de la página | **No cumple**: la app cambia `lang` a `en-US` al cargar (no declara `locale` en `MaterialApp`), aunque `web/index.html` dice `es`. Un lector de pantalla lee el español con voz en inglés | Cumple (`lang="es"`) |
| 1.3.1 y 4.1.2 Nombre de los campos | **No cumple**: en el login, el árbol de accesibilidad nombra los campos por su ejemplo (`hola@mani.app`, `••••••••`), no por su rótulo visible («Correo electrónico», «Contraseña»). `semanticsLabel`: 0 usos en `lib` | No hay campos |
| 1.4.4 Cambiar tamaño del texto | **No cumple en celular**: al cargar, Flutter reescribe el viewport a `maximum-scale=1.0, user-scalable=no` y bloquea el zoom con los dedos. 0 pruebas de escalado de texto (`textScaler`) | Cumple (viewport sin bloqueo) |
| 1.4.10 Reflujo | Cumple: el login a 400x432 (equivale a zoom de 200 %) se reorganiza en una columna sin cortar contenido | No revisado |
| 2.1.1 Teclado | Cumple en el login: Tab recorre correo, contraseña, mostrar contraseña, «¿Olvidaste…?» e «Ingresar», y Enter envía el formulario | Sin revisar a fondo |
| 2.4.7 Foco visible | **No cumple**: con el foco en «Ingresar» llegado por Tab no se ve ningún indicador; en «Mostrar contraseña» el indicador es un gris muy tenue | Sin revisar a fondo |
| 1.1.1 Texto alternativo | Logo con nombre «MANI» | Cumple: 4 imágenes con `alt`, 68 controles con nombre |
| 2.3.3 / movimiento reducido | Sin revisar | **No cumple el criterio del producto**: no hay regla `prefers-reduced-motion` |
| Estructura | — | `main`, `nav`, un `h1` y 27 encabezados. Sin enlace para saltar al contenido |

Resultado: **No cumple**. El criterio ya existe (avance frente al 21 nov), pero Flutter falla 3.1.1, 1.3.1, 1.4.4 en celular y 2.4.7, y la Landing falla 1.4.3.

Qué corregir (Flutter): declarar `locale: Locale('es', 'CO')` y `supportedLocales` en `MaterialApp`; rótulo de los campos como `labelText` o `Semantics(label:)`; indicador de foco con contraste ≥ 3:1 en `ManiButton`; prueba de escalado con `MediaQuery(textScaler: TextScaler.linear(2))` en las pantallas principales. (Landing) oscurecer el naranja de los botones a ≥ 4,5:1 con texto blanco, no usar el amarillo como color de texto y agregar `@media (prefers-reduced-motion: reduce)`. (Arquitectura) copiar el criterio de `PRODUCT.md` al SDD §7.9.

## QAS-35 Asistencia al usuario: No cumple

`flutter test` de las 41 suites que verifican mensajes por tipo de falla (`mensajeUsuario`, sin conexión): **594 de 594** pasan.

| Caso | Resultado | Cómo se verificó |
|---|---|---|
| Validación de formularios | Orienta: «El correo es requerido», «La contraseña es requerida» bajo cada campo | QA, login enviado vacío con Enter |
| Sin conexión | Orienta: «Sin conexión…» con Reintentar | Pruebas automáticas (suites de `sinConexion`) |
| Estados vacíos | Orientan al siguiente paso | Corte del 21 nov y revisión heurística de T-45 |
| Ruta de otro rol | **No orienta**: `resolverRedireccion` devuelve al inicio del rol sin mensaje (sin cambios desde el 21 nov) | Código en `95a3e42`, `lib/core/routing/app_router.dart` y `lib/core/session/guardas_ruta.dart` |
| Error del servidor (5xx) | **No orienta**: la verificación de aliados y la asignación muestran «Algo salió mal. Inténtalo de nuevo.» (`VerificacionErrorTipo.desconocido`, `AsignacionErrorTipo.desconocido`) | Código en `95a3e42` |
| Archivo demasiado grande en el registro | **No orienta**: el mensaje no dice el límite de 10 MB | Revisión heurística de T-45 (H9) |

Resultado: **No cumple**. 3 de 6 casos orientan. Qué corregir: mostrar un aviso al redirigir por rol («Esa sección es para…»), un mensaje para 5xx que diga qué hacer si persiste, y el límite en el error de tamaño.

# QAS-35, 24 de noviembre de 2026 (UTC), Flutter `a98fa12`

`flutter test` de 39 suites (patrón `mensajeUsuario|sinConexion`, lista en `qas35_suites.txt`): 579 de 579. El 23 nov fueron 41 suites y 594 pruebas con un patrón más amplio; las cifras no se comparan entre sí.

| Caso | Resultado | Cómo se verificó |
|---|---|---|
| Validación de formularios | Orienta | QA, `qas35_validacion_login_a98fa12.jpg` |
| Sin conexión | Orienta | Pruebas automáticas |
| Estados vacíos | Orientan en general, con una excepción | Código: los de Mis pedidos, Avisos, Cobros, Categorías, Aliados elegibles y Mensajes dicen qué falta y, donde aplica, el siguiente paso. Excepción vista en QA: en una solicitud **cancelada** sin cotización, la pantalla dice «El aliado aún no ha enviado la cotización. Desliza hacia abajo para actualizar.», que hace esperar algo que no va a llegar (`qas35_cancelada_sin_cotizacion_a98fa12.jpg`). Menores, por código: la sección vacía de Mis pedidos («No tienes solicitudes en la sección…») y los eventos («Aún no hay eventos registrados.») no dan siguiente paso. La cuenta de prueba tiene datos, así que las listas vacías no se vieron en pantalla |
| Ruta de otro rol | No orienta | QA, cliente: `/admin/categorias` y `/aliado/solicitudes` llevan a `/inicio` sin aviso a los 2, 4 y 5 s (`qas35_redireccion_rol_2s_a98fa12.jpg`). Código: `resolverRedireccion` no emite mensaje. Una ruta que no existe hace lo mismo |
| Error 5xx | Asignación orienta; verificación no | Código. Asignación traduce los 5xx a «El servicio de asignación no responde en este momento. Inténtalo en unos minutos.». Verificación cae en «Algo salió mal. Inténtalo de nuevo.» |
| Archivo grande en el registro | No orienta | Código. El selector no valida ni anuncia el límite; Core corta en 10 MB (multer, 400) y Gateway responde 413 con «Los archivos adjuntos superan el tamaño permitido.». Sin provocar el error en QA |

Corrección al informe del 23 nov: decía que los 5xx de asignación no orientan. `lib/features/asignacion` no cambió entre `95a3e42` y `a98fa12`, así que ya orientaban. El caso sigue sin cumplir por verificación.

Otras observaciones en QA: una solicitud inexistente dice «No encontramos esta solicitud o cotización.» con Reintentar, que no resuelve un 404 (`qas35_solicitud_inexistente_a98fa12.jpg`). Durante la primera pasada la sesión terminó porque el usuario la cerró en otra pestaña; no es hallazgo.

Resultado: No cumple. Validación y sin conexión orientan; estados vacíos orientan con una excepción; ruta de otro rol, 5xx de verificación y archivo grande no orientan.

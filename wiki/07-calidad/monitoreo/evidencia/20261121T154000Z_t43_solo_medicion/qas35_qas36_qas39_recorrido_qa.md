# QAS-35, 36 y 39: recorrido en la app de QA

Corte 2026-11-21, de 19:27Z a 19:50Z. App Flutter web de MANI-QA (`http://10.43.100.141:8080`), versión desplegada el 20 nov (Flutter `b74d923`, Core `73c28f4`), que incluye todo `develop`. Cuentas CFG-04 del tenant ACME Servicios: `cliente.t1`, `aliado.t1` y `admin.t1`. El responsable de QA inició sesión y el recorrido se hizo en el navegador integrado.

**Datos.** No se enviaron solicitudes, rechazos ni cancelaciones; los diálogos se cerraron con «Volver». Se creó una ausencia de prueba y se borró enseguida (empezaba en el futuro, así que el aliado nunca dejó de estar disponible). Una categoría de prueba ya oculta («Categoria QA 25355805») se activó y se volvió a ocultar: el catálogo quedó en 2 visibles y 17 ocultas, como estaba.

**Sin conexión** se simuló solo en la pestaña, reemplazando `fetch` y `XMLHttpRequest`, y se restauró enseguida.

Las capturas están en `capturas/`, con el nombre `qasNN_rol_paso.jpg`.

## QAS-35: errores y estados vacíos con orientación

| Caso | Rol | Mensaje o comportamiento | ¿Orienta? | Captura |
|---|---|---|---|---|
| Descripción corta en «Nueva solicitud» | Cliente | «Escribe al menos 20 caracteres más», «Describe el problema para continuar», Continuar deshabilitado y guía de qué escribir | Sí | `qas35_qas36_cliente_validacion_problema.jpg` |
| Sin conexión al actualizar | Cliente | «Sin conexión. Revisa tu internet e inténtalo de nuevo.» con «Reintentar»; la lista se conserva | Sí | `qas35_cliente_sin_conexion.jpg` |
| Ruta de otro rol (`/aliado/solicitudes` como cliente) | Cliente | Redirige al inicio del cliente **sin ningún mensaje** | **No** | `qas35_cliente_ruta_aliado_redirige.jpg` |
| Sin ausencias | Aliado | «No tienes ausencias programadas. Recibes solicitudes con normalidad.» | Sí | `qas35_aliado_ausencias_vacio.jpg` |
| Error del servidor en «Verificación de aliados» | Admin | «Algo salió mal. Inténtalo de nuevo.» con «Reintentar». El Core responde 500 de forma persistente (ver defecto D-T43-1) y el mensaje no da otra salida | Parcial | `qas35_admin_verificacion_error_500.jpg` |

**Resultado:** **No cumple.** 3 de 5 casos orientan. La redirección sin mensaje deja al usuario sin saber qué pasó, y el error genérico solo propone reintentar algo que falla siempre.

## QAS-36: formularios y estados críticos con siguiente paso

| Pantalla o estado | Rol | Texto que indica el siguiente paso | Captura |
|---|---|---|---|
| Nueva solicitud | Cliente | Asistente de 4 pasos con nombre (Servicio, Problema, Ubicación, Revisar) y guía «Una buena descripción responde…» | `qas36_cliente_nueva_solicitud_paso1.jpg`, `qas35_qas36_cliente_validacion_problema.jpg` |
| Mis solicitudes | Cliente | Estado de cada una y acciones disponibles; aviso de que la zona es la declarada, no la ubicación del aliado | `qas36_cliente_mis_solicitudes.jpg` |
| Cotización aceptada | Cliente | «Aceptaste esta cotización.» con «Pagar» al lado, adiciones disponibles y ejecución «pendiente» | `qas36_cliente_cotizacion_aceptada_1.jpg`, `_2.jpg` |
| Mis quejas | Cliente | «Para presentar una nueva, ve a Mis solicitudes.» | `qas36_cliente_mis_quejas.jpg` |
| Bandeja del aliado | Aliado | «El primero en aceptar se queda con el trabajo» y botones Rechazar y Aceptar | `qas36_aliado_bandeja.jpg` |
| Marcar no disponible | Aliado | «Durante este intervalo no recibirás solicitudes nuevas.» | `qas36_aliado_form_ausencia.jpg` |
| Activar categoría | Admin | «Ya vuelve a aparecer en el catálogo de tus clientes.» | `qas36_admin_categoria_activada.jpg` |
| Mi perfil | Aliado | Muestra «Rol: ALLY» y «Estado: VERIFIED», códigos internos en inglés (observación, no bloquea un siguiente paso) | `qas36_aliado_perfil_codigos_ingles.jpg` |

**Resultado:** **Cumple.** Todos los formularios y estados críticos recorridos indican el siguiente paso. Queda la observación de los códigos en inglés del perfil. El estado «verificación KYC pendiente» no se pudo ver porque `aliado.t1` ya está verificado; lo cubren las pruebas de Flutter.

## QAS-39: aviso antes de cancelar o revertir, y «Volver»

| Acción | Rol | Aviso previo | «Volver» conserva el estado | Captura |
|---|---|---|---|---|
| Cancelar solicitud | Cliente | «¿Cancelar la solicitud? … Esta acción no se puede deshacer», con la penalización ($0) | Sí, sigue en «Cotización aceptada» | `qas39_cliente_cancelar_dialogo.jpg`, `qas39_cliente_volver_conserva.jpg` |
| Rechazar solicitud | Aliado | «¿Rechazar Plomeria? No volverás a verla…», con motivo obligatorio | Sí, siguen 4 disponibles | `qas39_aliado_rechazar_dialogo.jpg`, `qas39_aliado_volver_conserva.jpg` |
| Eliminar ausencia | Aliado | «¿Eliminar esta ausencia? Volverás a recibir solicitudes entre…» | No aplica | `qas39_aliado_eliminar_ausencia_dialogo.jpg`, `qas39_aliado_ausencia_eliminada.jpg` |
| Ocultar categoría | Admin | **Ninguno**: pasa directo a «Guardando…». Después avisa «No recibirá nuevas solicitudes» | — | `qas39_admin_ocultar_categoria_sin_confirmacion.jpg`, `qas39_admin_categoria_ocultada.jpg` |
| Cerrar sesión | Cliente | **Ninguno**: un clic y vuelve al login | — | `qas39_cliente_cerrar_sesion_sin_confirmacion.jpg` |
| Aprobar o rechazar aliado | Admin | No se pudo probar por el defecto D-T43-1; lo cubren las pruebas de Flutter | — | — |

**Resultado:** **Parcial.** Las cancelaciones y rechazos tienen aviso y «Volver» funciona. Ocultar categoría y cerrar sesión no piden confirmación; falta que la PO decida si son reversiones críticas.

## Defecto encontrado

**D-T43-1. «Verificación de aliados» del admin responde 500.**

- `GET /api/v1/core/aliados/verificacion` responde 500 `INTERNAL_ERROR` «Error consultando documentos KYC» en 3 de 3 intentos (correlationId `c8a271e6-ba48-4b83-8738-20a3cce029ec`).
- En la misma sesión, `GET /api/v1/core/profiles/me` respondió una vez 500 «Error consultando perfil» (`6ee02b95-cb27-4f86-a61e-99b53289ada0`) y la siguiente vez 200.
- Efecto: el admin de ACME no puede ver ni aprobar aliados en QA.
- **Causa (logs del Core, 21 nov 21:05Z, `d_t43_1_logs_core_21nov_2105z.txt`):** `EMAXCONNSESSION max clients reached in session mode - max clients are limited to pool_size: 15`. El pooler de Supabase en modo sesión ya tenía sus 15 clientes ocupados y rechazó la conexión de `withTenantContext`. No es un fallo de la lógica de KYC: la consulta ni llegó a la base.
- Lo agrava el código: `ListAlliesVerificationUseCase` hidrata todos los aliados en paralelo y cada uno abre 3 conexiones a la vez (usuario, categorías y documentos KYC), así que esta pantalla es la primera en chocar con el límite. El pool propio de Core es de 5 por instancia (`DATABASE_POOL_MAX`), de modo que los otros cupos del pooler los ocupan otros clientes del mismo proyecto de Supabase.
- En los logs, el error que aparece junto a `6ee02b95…` (`profiles/me`) es el de una petición de verificación intercalada; el 500 de perfil tiene la misma causa probable.

# QAS-08, 35, 36 y 39: pruebas de Flutter

Corte 2026-11-21. `flutter test` local sobre MANI-Flutter `develop` `daba130` (test/core, test/features y widget_test; sin integración).

Total: 1145 de 1147 pasan. Las 2 que fallan son de `core/arquitectura/supabase_solo_auth_test.dart` y fallan solo en esta copia local por duplicados de iCloud sin versionar (`* 2.dart`, `?? ` en `git status`). El CI de `daba130` ("CI - Flutter") está en verde.

Selección por nombre de prueba o de archivo (expresiones regulares en este script). Una prueba puede aparecer en más de un escenario.

## QAS-08 confirmación previa y entradas inválidas

102 de 102 pasan.

| Archivo | Prueba | Resultado |
|---|---|---|
| `core/network/gateway_client_test.dart` | cabeceras sin sesión no envía Authorization | success |
| `core/widgets/refresco_periodico_test.dart` | SCRUM-1644 · RefrescoPeriodico un diálogo abierto encima también pausa | success |
| `features/asignacion/asignacion_repository_test.dart` | Rechazar un 422D de Dispatch se traduce a detalleInvalido | success |
| `features/asignacion/domain/dominio_test.dart` | ReglaSitio.desdeMapa conserva TODAS las reglas, ordenadas | success |
| `features/asignacion/presentation/formato_reglas_sitio_test.dart` | reglasParaMostrar reglas antiguas con true/false se conservan | success |
| `features/asignacion/presentation/solicitud_cancelada_test.dart` | una asignada sin cancelar conserva «Cotización» | success |
| `features/asignacion/presentation/solicitudes_aliado_cubit_test.dart` | aceptar Dispatch caído (5xx) conserva la solicitud y lo explica | success |
| `features/asignacion/presentation/solicitudes_aliado_cubit_test.dart` | aceptar un error de red conserva la solicitud para reintentar | success |
| `features/asignacion/presentation/solicitudes_aliado_cubit_test.dart` | cargar un error al refrescar conserva la bandeja y avisa | success |
| `features/asignacion/presentation/solicitudes_aliado_page_test.dart` | cambiar de «Otro» a otro motivo no envía el texto escrito | success |
| `features/asignacion/presentation/solicitudes_aliado_page_test.dart` | mientras acepta, deshabilita las demás acciones | success |
| `features/asignacion/presentation/solicitudes_aliado_page_test.dart` | rechazar pide confirmación y un motivo obligatorio | success |
| `features/asignacion/presentation/solicitudes_aliado_page_test.dart` | volver del diálogo no rechaza nada | success |
| `features/auth/data/login_errores_test.dart` | el correo sin confirmar tiene mensaje propio, por decisión de la PO | success |
| `features/auth/data/registro_cliente_empresa_gateway_test.dart` | datasource sin teléfono no envía phone | success |
| `features/auth/data/registro_cliente_gateway_test.dart` | repositorio: errores visibles 400 muestra el mensaje de validación | success |
| `features/auth/presentation/login_por_tipo_test.dart` | C2: credenciales inválidas muestran el mensaje genérico, no navegan y no crean sesión | success |
| `features/auth/presentation/registro_cliente_empresa_test.dart` | HU-M02-07 validadores NIT: acepta 9 o 10 dígitos con DV opcional y con puntos | success |
| `features/auth/presentation/registro_cliente_empresa_test.dart` | HU-M02-07 validadores NIT: rechaza vacío, corto, con letras o DV de dos cifras | success |
| `features/auth/presentation/registro_cliente_empresa_test.dart` | HU-M02-07 validadores email, contraseña (mínimo 8, como Core) y obligatorios | success |
| `features/auth/presentation/registro_cliente_empresa_test.dart` | HU-M02-07 validadores normalizarNit quita puntos y espacios | success |
| `features/auth/presentation/terminos_condiciones_test.dart` | SCRUM-856 (US-02.3.2) — Aceptación de Términos y Condiciones y Habeas Data US-02.3.2: muestra checkbox desmarcado, enlaces legales y mensaje de error cuando es  | success |
| `features/auth/recuperacion/recuperacion_gateway_test.dart` | repositorio: errores visibles un 400 muestra el mensaje de validación de Core | success |
| `features/auth/recuperacion/recuperacion_pantallas_test.dart` | pantalla: olvidé mi contraseña valida el correo antes de enviar | success |
| `features/auth/recuperacion/recuperacion_pantallas_test.dart` | pantalla: restablecer contraseña si el servicio rechaza el enlace se muestra su mensaje y no hay diálogo de éxito | success |
| `features/auth/recuperacion/recuperacion_pantallas_test.dart` | pantalla: restablecer contraseña valida la longitud y que la confirmación coincida | success |
| `features/auth/recuperacion/recuperacion_pantallas_test.dart` | validadores CredencialesValidators: correo, contraseña de 8 y confirmación | success |
| `features/auth/recuperacion/recuperacion_pantallas_test.dart` | validadores el formulario de cliente empresa sigue usando las mismas reglas | success |
| `features/availability/disponibilidad_cubit_test.dart` | BorradorAusencia.validar acepta un intervalo futuro bien formado | success |
| `features/availability/disponibilidad_cubit_test.dart` | BorradorAusencia.validar rechaza fin no posterior al inicio, ausencias pasadas y largas | success |
| `features/availability/disponibilidad_page_test.dart` | el formulario no envía un horario inválido | success |
| `features/availability/disponibilidad_page_test.dart` | eliminar pide confirmación y devuelve a Disponible | success |
| `features/conversation_review/conversacion_queja_test.dart` | ConversacionQuejaCubit valida lo mismo que Core y no consulta con datos inválidos (la consulta queda auditada) | success |
| `features/m12/gateway_m12_test.dart` | SCRUM-900 · métricas pide el periodo y conserva ceros y tasas nulas | success |
| `features/messaging/chat_cubit_page_test.dart` | ChatCubit un 409 deja el hilo en solo lectura y conserva lo leído | success |
| `features/messaging/chat_cubit_page_test.dart` | ChatCubit un fallo de red al consultar conserva los mensajes y se recupera solo | success |
| `features/messaging/chat_cubit_page_test.dart` | ChatPage C2: si el envío falla, avisa y conserva el texto para reintentar | success |
| `features/payments/cobros_test.dart` | SCRUM-1710 · sondeo de Mis cobros un fallo conserva los cobros y no muestra error | success |
| `features/payments/pago_cubit_page_test.dart` | PagoCubit un doble toque mientras se paga no envía otro pago | success |
| `features/payments/pagos_gateway_test.dart` | errores C2: un 504 conserva el texto de Core que dice que no se cobró y el correlationId | success |
| `features/profile_categories/categories_cubit_test.dart` | guardar si el servidor rechaza el guardado, la selección vuelve a lo último confirmado | success |
| `features/profile_categories/categories_cubit_test.dart` | guardar sin conexión la selección se conserva, porque la petición no llegó al servidor | success |
| `features/profiles/company_sites/sedes_empresa_test.dart` | EditarSedeEmpresaUseCase nombre, dirección y zona siguen siendo obligatorios | success |
| `features/profiles/company_sites/sedes_empresa_test.dart` | SCRUM-852 / SCRUM-1387 — sedes del cliente empresa por el Gateway si Core rechaza la edición, el diálogo sigue abierto con el motivo | success |
| `features/profiles/company_sites/sedes_empresa_test.dart` | SedesEmpresaRemoteDataSource valida la respuesta de Core sin "sitios" la lista queda vacía | success |
| `features/profiles/company_sites/sedes_empresa_test.dart` | SedesEmpresaRemoteDataSource valida la respuesta de Core sin "zones" o sin "sitio" es un error, no una lista falsa | success |
| `features/profiles/coverage/cobertura_controller_test.dart` | CoberturaController guardar con error conserva la selección del usuario | success |
| `features/profiles/coverage/cobertura_controller_test.dart` | CoberturaController guardar con éxito resetea cambios y confirma | success |
| `features/profiles/coverage/cobertura_usecases_repo_test.dart` | CoberturaRepositoryImpl éxito devuelve ids guardados y log INFO con campos obligatorios | success |
| `features/profiles/coverage/cobertura_usecases_repo_test.dart` | DeclararCobertura (use case) con zonas desactivadas no envía | success |
| `features/profiles/coverage/declarar_cobertura_page_test.dart` | muestra localidades y el botón Guardar inicia deshabilitado | success |
| `features/profiles/direct_employees/empleado_directo_test.dart` | SCRUM-1376 (RF-05) — Registrar empleado directo Datasource envía multipart con los datos obligatorios y la copia del documento, y lee la respuesta de Core | success |
| `features/profiles/direct_employees/empleado_directo_test.dart` | SCRUM-1376 (RF-05) — Registrar empleado directo sin la copia del documento la pantalla avisa y no envía nada | success |
| `features/profiles/own_profile/editar_perfil_propio_test.dart` | US-02.3.1 (SCRUM-854 / SCRUM-1029 / SCRUM-1030 / SCRUM-1031) — Editar perfil propio EditarPerfilPage muestra datos actuales, valida campos, sube foto y refleja  | success |
| `features/profiles/own_profile/foto_perfil_jpg_png_test.dart` | validación previa en la app WEBP se rechaza sin llamar al Gateway | success |
| `features/profiles/own_profile/foto_perfil_jpg_png_test.dart` | validación previa en la app el mensaje es exactamente el acordado | success |
| `features/profiles/own_profile/foto_perfil_jpg_png_test.dart` | validación previa en la app esFotoValida: formatos y límite exacto de 5 MB | success |
| `features/profiles/own_profile/foto_perfil_jpg_png_test.dart` | validación previa en la app un archivo de 5 MB + 1 byte se rechaza sin llamar al Gateway | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl urlDocumento sin red conserva sinConexion | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos 422 MANI-VER-422M se traduce a motivoInvalido | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C3 - permisos y aislamiento de tenant 401 del Gateway (sin sesión o JWT inválido) es sinSesion | success |
| `features/profiles/verification/domain/usecases_test.dart` | RechazarAliado valida el motivo antes de llamar a la red | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | aprobar un error conserva el estado y lo informa | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | cargar un error al refrescar conserva la lista y muestra un aviso | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | rechazar con motivo inválido no llama al servidor | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) aprobar pide confirmación, aprueba y pasa al siguiente pendiente | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) cancelar la confirmación no aprueba | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) rechazar valida el motivo, admite motivos rápidos y rechaza | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) sin documentos el botón Aprobar está deshabilitado y se explica por qué | success |
| `features/services/additions/adiciones_test.dart` | SCRUM-872 · Cubit no envía dos acciones a la vez | success |
| `features/services/additions/adiciones_test.dart` | SCRUM-872 · sección en la pantalla el aliado pide la adición: valida, envía y el formulario se cierra | success |
| `features/services/additions/adiciones_test.dart` | SCRUM-872 · sección en la pantalla el cliente acepta con confirmación y rechaza con comentario | success |
| `features/services/categories/data/gateway_datasource_test.dart` | cambiarEstado: PATCH deactivate y conserva el conteo de aliados | success |
| `features/services/categories/data/repository_impl_test.dart` | CategoriasRepositoryImpl registra un log estructurado con los campos obligatorios | success |
| `features/services/categories/presentation/categorias_cubit_test.dart` | cargar un error al refrescar conserva el catálogo y avisa | success |
| `features/services/categories/presentation/categorias_cubit_test.dart` | crear datos inválidos devuelven la falla sin llamar al servidor | success |
| `features/services/categories/presentation/gestion_categorias_page_test.dart` | Formulario (escritorio) Crear inicia deshabilitado y explica qué falta | success |
| `features/services/categories/presentation/gestion_categorias_page_test.dart` | Formulario (escritorio) crea la categoría, cierra el diálogo y la resalta | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1400/1401 · cubit un error conserva la lista del mismo filtro | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · datasource por el Gateway sin filtro no envía "tipo" | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · modelo NO_DISPONIBLE conserva el motivo | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · modelo conserva el orden del backend aunque los puntajes estén invertidos | success |
| `features/services/events/cola_eventos_test.dart` | ColaEventos dos rondas a la vez no envían dos veces | success |
| `features/services/events/eventos_test.dart` | SCRUM-869 · cubit la clave se conserva si el envío falla y se renueva cuando queda registrado | success |
| `features/services/execution/ejecucion_test.dart` | SCRUM-1644 · sondeo silencioso un fallo conserva lo que se ve y no muestra error | success |
| `features/services/execution/ejecucion_test.dart` | SCRUM-868 · fuente por el Gateway iniciar y finalizar van a su ruta y no envían fechas | success |
| `features/services/quotes/cotizacion_test.dart` | Cotización · cubit SCRUM-1644: un sondeo fallido conserva la lista y no avisa | success |
| `features/services/quotes/cotizacion_test.dart` | Cotización · cubit un fallo de la acción se avisa como error y conserva la lista | success |
| `features/services/quotes/cotizacion_test.dart` | Cotización · fuente por el Gateway un 409 conserva el texto de Core sin el código MANI-COT | success |
| `features/services/quotes/cotizacion_test.dart` | Cotización · pantalla SCRUM-865: importes inválidos o total en cero no se envían | success |
| `features/services/requests/data/errores_por_codigo_test.dart` | el 403 del cliente sí conserva su mensaje cuando el código lo dice | success |
| `features/services/requests/data/repository_impl_test.dart` | Publicar si la respuesta se pierde las fotos se conservan y el reintento recupera la misma solicitud | success |
| `features/services/requests/data/repository_impl_test.dart` | Publicar sin sesión no envía nada a Core | success |
| `features/services/requests/presentation/crear_solicitud_cubit_test.dart` | publicar ante un error conserva todo y reintenta con la MISMA clave | success |
| `features/services/requests/presentation/crear_solicitud_page_test.dart` | revisar, editar y publicar muestra la confirmación con lo publicado | success |
| `features/services/requests/presentation/crear_solicitud_page_test.dart` | una foto inválida se explica sin perder las demás | success |
| `features/services/tracking/cancelacion_test.dart` | SCRUM-1710 · sondeo de Mis solicitudes un fallo conserva la lista y no muestra error | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · cubit un fallo de red conserva la lista y avisa, sin reconsultar | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · pantalla al confirmar cancela con el motivo y la tarjeta queda Cancelada | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · pantalla pide confirmación; «Volver» no cancela | success |
| `features/services/tracking/seguimiento_test.dart` | HU-M07-04 (SCRUM-871) · cubit si una nueva consulta falla, conserva lo anterior y avisa | success |
| `features/tariffs/tarifas_gateway_test.dart` | SCRUM-885/886/887 · tarifario crear envía la categoría y los valores; no envía tenant ni actor | success |

## QAS-35 errores y estados vacíos con orientación

289 de 290 pasan.

| Archivo | Prueba | Resultado |
|---|---|---|
| `core/arquitectura/supabase_solo_auth_test.dart` | el escáner detecta lo que dice detectar no marca código legítimo ni lo que solo aparece en comentarios | success |
| `core/arquitectura/supabase_solo_auth_test.dart` | la app respeta ADR-0027 y T6 C3: el tenant y el rol no salen de user_metadata en ningún lugar del código | failure |
| `core/arquitectura/supabase_solo_auth_test.dart` | la app respeta ADR-0027 y T6 hay código que revisar | success |
| `core/network/gateway_client_test.dart` | errores (CA-4) 400 usa el detalle del servicio | success |
| `core/network/gateway_client_test.dart` | errores (CA-4) 401 pide iniciar sesión y tiene helper isUnauthorized | success |
| `core/network/gateway_client_test.dart` | errores (CA-4) 403 tiene helper isForbidden | success |
| `core/network/gateway_client_test.dart` | errores (CA-4) 409 sin detalle da un mensaje de duplicado y tiene helper isConflict | success |
| `core/network/gateway_client_test.dart` | errores (CA-4) 5xx no filtra el error interno | success |
| `core/network/gateway_client_test.dart` | errores (CA-4) cuerpo no JSON no rompe el manejo de errores | success |
| `core/network/gateway_client_test.dart` | errores (CA-4) fallo de red se traduce sin status y tiene helper isConnectionError | success |
| `core/network/gateway_client_test.dart` | errores (CA-4) timeout se traduce sin quedarse esperando | success |
| `core/network/gateway_client_test.dart` | manejo de 401 y refresco de sesión (onTokenExpired) 401 con onTokenExpired exitoso refresca sesión y reintenta | success |
| `core/network/gateway_client_test.dart` | manejo de 401 y refresco de sesión (onTokenExpired) 401 con onTokenExpired que devuelve false lanza GatewayException | success |
| `core/network/gateway_client_test.dart` | manejo de 401 y refresco de sesión (onTokenExpired) 401 que tras refresco sigue devolviendo 401 no produce bucle infinito | success |
| `core/network/gateway_client_test.dart` | reintentos y backoff exponencial (idempotencia) GET ante 500 (Internal Server Error) no se reintenta | success |
| `core/network/gateway_exception_codigo_test.dart` | codigo acepta los códigos con letra final y los de tres letras | success |
| `core/network/gateway_exception_codigo_test.dart` | codigo sale del campo `code` del cuerpo | success |
| `core/network/gateway_exception_codigo_test.dart` | codigo si el cuerpo no lo trae, sale del prefijo del mensaje | success |
| `core/network/gateway_exception_codigo_test.dart` | codigo un valor que no tiene la forma MANI-XXX-NNN no es un código | success |
| `core/network/gateway_exception_codigo_test.dart` | referencia y línea de diagnóstico la línea tiene el formato «Código: … · Ref: …» | success |
| `core/network/gateway_exception_codigo_test.dart` | referencia y línea de diagnóstico omite la parte que falta y es null si faltan las dos | success |
| `core/network/gateway_exception_codigo_test.dart` | referencia y línea de diagnóstico prefiere el correlationId del cuerpo y cae al de la cabecera | success |
| `core/routing/app_router_shell_test.dart` | US-11.2.2 (SCRUM-1445) — guardas sobre el router real un 401 sin refresco posible cierra la sesión local | success |
| `core/session/guardas_ruta_test.dart` | US-11.2.2 (SCRUM-1445) — sesión expirada (401) si el refresco da sesión nueva, se reintenta y no se cierra | success |
| `core/session/guardas_ruta_test.dart` | US-11.2.2 (SCRUM-1445) — sesión expirada (401) si el refresco lanza, también se cierra la sesión | success |
| `core/session/guardas_ruta_test.dart` | US-11.2.2 (SCRUM-1445) — sesión expirada (401) si el refresco no da sesión, se cierra y no se reintenta | success |
| `core/session/guardas_ruta_test.dart` | US-11.2.2 (SCRUM-1445) — sesión expirada (401) un fallo al cerrar no se propaga al cliente HTTP | success |
| `core/session/tenant_sesion_test.dart` | tokens ausentes, mal formados o con tenant vacío o no textual dan null | success |
| `core/shell/app_shell_test.dart` | US-11.2.1 (SCRUM-1444) — datos de la cabecera por el Gateway un nombre de tenant vacío también queda sin tenant | success |
| `core/shell/app_shell_test.dart` | US-11.2.1 (SCRUM-1444) — rol de la sesión un rol vacío o desconocido no abre entradas de negocio | success |
| `features/asignacion/asignacion_repository_test.dart` | Errores de Dispatch y Core por el Gateway aceptar lo que ya rechacé responde yaRechazada (409R) | success |
| `features/asignacion/asignacion_repository_test.dart` | Errores de Dispatch y Core por el Gateway mapearGateway usa el code y, sin él, el status | success |
| `features/asignacion/asignacion_repository_test.dart` | Errores de Dispatch y Core por el Gateway si la bandeja no responde tras ganar, igual informa la asignación | success |
| `features/asignacion/asignacion_repository_test.dart` | Trazabilidad errores de red se traducen a sinConexion | success |
| `features/asignacion/asignacion_repository_test.dart` | Trazabilidad registra log INFO con duración al ganar y ERROR al perder | success |
| `features/asignacion/data/asignacion_gateway_test.dart` | aceptar: POST accept con cuerpo vacío y una Idempotency-Key por toque; luego lee la bandeja para traer la dirección | success |
| `features/asignacion/data/asignacion_gateway_test.dart` | los errores de Dispatch se traducen por code | success |
| `features/asignacion/data/asignacion_gateway_test.dart` | rechazar: POST reject con el código del motivo, y detalle solo con «Otro» | success |
| `features/asignacion/data/asignacion_gateway_test.dart` | sin red: sinConexion | success |
| `features/asignacion/domain/dominio_test.dart` | ModalidadServicio usa los códigos de flujo operativo (US-03.1.1) | success |
| `features/asignacion/presentation/formato_reglas_sitio_test.dart` | reglasParaMostrar valores vacíos no se muestran | success |
| `features/asignacion/presentation/solicitudes_aliado_cubit_test.dart` | aceptar si otro aliado ganó (409) la quita, explica y refresca | success |
| `features/asignacion/presentation/solicitudes_aliado_cubit_test.dart` | aceptar si ya la había rechazado (409R) la quita y explica | success |
| `features/asignacion/presentation/solicitudes_aliado_cubit_test.dart` | aceptar un error de red conserva la solicitud para reintentar | success |
| `features/asignacion/presentation/solicitudes_aliado_cubit_test.dart` | cargar un aliado sin verificar queda en estado error explicativo | success |
| `features/asignacion/presentation/solicitudes_aliado_cubit_test.dart` | cargar un error al refrescar conserva la bandeja y avisa | success |
| `features/audit/auditoria_test.dart` | AuditoriaCubit C3: un 403 de Core (no es administrador) se muestra y no deja datos | success |
| `features/audit/auditoria_test.dart` | AuditoriaCubit un error de formato da un mensaje genérico | success |
| `features/audit/auditoria_test.dart` | AuditoriaCubit un pago válido filtra la consulta; un filtro vacío la deja sin filtro | success |
| `features/audit/auditoria_test.dart` | AuditoriaView sin eventos muestra el estado vacío | success |
| `features/audit/auditoria_test.dart` | AuditoriaView un error muestra el mensaje y permite reintentar | success |
| `features/audit/auditoria_test.dart` | GatewayFuenteAuditoria una respuesta sin la lista eventos es un error de formato | success |
| `features/auth/data/cierre_sesion_gateway_test.dart` | si Core responde error, el cierre de sesión no falla | success |
| `features/auth/data/consentimiento_legal_gateway_test.dart` | si Core rechaza el consentimiento no se lanza, pero queda un log ERROR sin datos personales | success |
| `features/auth/data/login_errores_test.dart` | C2: contraseña incorrecta y correo inexistente dan el MISMO mensaje | success |
| `features/auth/data/login_errores_test.dart` | C2: el mensaje no repite el texto crudo del servidor ni menciona el correo | success |
| `features/auth/data/login_errores_test.dart` | demasiados intentos se distingue porque no dice nada de la cuenta | success |
| `features/auth/data/login_errores_test.dart` | el correo sin confirmar tiene mensaje propio, por decisión de la PO | success |
| `features/auth/data/login_errores_test.dart` | un error inesperado no expone la excepción al usuario | success |
| `features/auth/data/login_errores_test.dart` | un fallo de red no se presenta como credenciales incorrectas | success |
| `features/auth/data/registro_aliado_gateway_test.dart` | repositorio: errores visibles 400 muestra el campo faltante | success |
| `features/auth/data/registro_aliado_gateway_test.dart` | repositorio: errores visibles 409 informa el correo duplicado | success |
| `features/auth/data/registro_aliado_gateway_test.dart` | repositorio: errores visibles 5xx da un mensaje genérico sin detalles internos | success |
| `features/auth/data/registro_cliente_empresa_gateway_test.dart` | repositorio: errores visibles 409 informa el NIT ya registrado | success |
| `features/auth/data/registro_cliente_empresa_gateway_test.dart` | repositorio: errores visibles 5xx da un mensaje genérico sin detalles internos | success |
| `features/auth/data/registro_cliente_gateway_test.dart` | repositorio: errores visibles 400 muestra el mensaje de validación | success |
| `features/auth/data/registro_cliente_gateway_test.dart` | repositorio: errores visibles 409 informa el correo duplicado (CA-4) | success |
| `features/auth/data/registro_cliente_gateway_test.dart` | repositorio: errores visibles 5xx da un mensaje genérico sin detalles internos | success |
| `features/auth/data/registro_empresa_gateway_test.dart` | datasource envía los datos limpios y omite los opcionales vacíos | success |
| `features/auth/data/registro_empresa_gateway_test.dart` | repositorio: errores visibles (CA-4) 400 muestra el campo faltante | success |
| `features/auth/data/registro_empresa_gateway_test.dart` | repositorio: errores visibles (CA-4) 401 pide volver a iniciar sesión | success |
| `features/auth/data/registro_empresa_gateway_test.dart` | repositorio: errores visibles (CA-4) 409 informa la empresa duplicada | success |
| `features/auth/data/registro_empresa_gateway_test.dart` | repositorio: errores visibles (CA-4) 5xx da un mensaje genérico sin detalles internos | success |
| `features/auth/presentation/registro_cliente_empresa_test.dart` | HU-M02-07 validadores NIT: rechaza vacío, corto, con letras o DV de dos cifras | success |
| `features/auth/presentation/selector_categoria_catalogo_test.dart` | catálogo vacío muestra el aviso | success |
| `features/auth/presentation/selector_categoria_catalogo_test.dart` | si falla la carga muestra error y reintenta | success |
| `features/auth/presentation/terminos_condiciones_test.dart` | SCRUM-856 (US-02.3.2) — Aceptación de Términos y Condiciones y Habeas Data US-02.3.2: muestra checkbox desmarcado, enlaces legales y mensaje de error cuando es  | success |
| `features/auth/recuperacion/enlace_recuperacion_test.dart` | EnlaceRecuperacion.desde un enlace vencido (error_code en el fragmento) no es válido aunque traiga otros datos | success |
| `features/auth/recuperacion/recuperacion_gateway_test.dart` | repositorio: errores visibles un 400 muestra el mensaje de validación de Core | success |
| `features/auth/recuperacion/recuperacion_gateway_test.dart` | repositorio: errores visibles un 401 del restablecimiento dice que el enlace no sirve, no que la sesión venció | success |
| `features/auth/recuperacion/recuperacion_gateway_test.dart` | repositorio: errores visibles un 5xx da un mensaje genérico sin detalles internos | success |
| `features/auth/recuperacion/recuperacion_pantallas_test.dart` | cubit un AuthFailure llega como error con su mensaje | success |
| `features/auth/recuperacion/recuperacion_pantallas_test.dart` | pantalla: olvidé mi contraseña un error del servicio se muestra y el formulario sigue disponible | success |
| `features/availability/disponibilidad_cubit_test.dart` | un error de carga queda en falla y se puede reintentar | success |
| `features/availability/disponibilidad_cubit_test.dart` | un solapamiento devuelve false y avisa el error de negocio | success |
| `features/availability/disponibilidad_page_test.dart` | sin ausencias muestra Disponible y el estado vacío | success |
| `features/availability/disponibilidad_page_test.dart` | un error de carga ofrece reintentar | success |
| `features/availability/disponibilidad_repository_impl_test.dart` | crear envía fechas en UTC, el código del motivo y la nota limpia | success |
| `features/availability/disponibilidad_repository_impl_test.dart` | traduce los errores de Core a DisponibilidadFailure | success |
| `features/availability/disponibilidad_repository_impl_test.dart` | un fallo de red se reporta como sinConexion | success |
| `features/catalog/map/mapa_test.dart` | MapaCubit sin localidades en el catálogo el estado es vacío y no se pide geometría | success |
| `features/catalog/map/mapa_test.dart` | MapaCubit sin ninguna geometría dibujable el estado es vacío, no listo | success |
| `features/catalog/map/mapa_test.dart` | conversión de GeoJSON devuelve vacío ante geometría nula, tipo desconocido o puntos insuficientes | success |
| `features/catalog/map/mapa_test.dart` | panorámica: todas las localidades a la vez (SCRUM-1396) sin localidades queda vacío, no en error | success |
| `features/catalog/map/mapa_test.dart` | panorámica: todas las localidades a la vez (SCRUM-1396) sin ningún límite dibujable queda vacío | success |
| `features/catalog/map/mapa_test.dart` | parseo de sedes sin la clave sitios devuelve vacío en vez de fallar | success |
| `features/catalog/map/mapa_zonas_page_test.dart` | el error ofrece reintentar | success |
| `features/catalog/map/mapa_zonas_page_test.dart` | sin geometrías muestra el estado vacío y no dibuja un mapa | success |
| `features/conversation_review/conversacion_queja_test.dart` | ConversacionQuejaCubit un 403 (no es administrador) y un 404 (solicitud ajena) se muestran sin mensajes | success |
| `features/conversation_review/conversacion_queja_test.dart` | ConversacionQuejaCubit un error de formato da un mensaje genérico | success |
| `features/conversation_review/conversacion_queja_test.dart` | ConversacionQuejaView un motivo corto muestra el error sin consultar | success |
| `features/conversation_review/conversacion_queja_test.dart` | GatewayFuenteConversacionQueja sin referencia no la envía; una respuesta sin consulta o mensajes es un error de formato | success |
| `features/home/inicio_test.dart` | US-11.2.3 (SCRUM-1446) — resumen de inicio por el Gateway aliado: si falla una consulta, solo ese dato queda vacío | success |
| `features/home/inicio_test.dart` | US-11.2.3 (SCRUM-1446) — resumen de inicio por el Gateway aliado: sin la consulta de ausencias, estado y ausencias quedan vacíos | success |
| `features/home/inicio_test.dart` | US-11.2.3 (SCRUM-1446) — resumen de inicio por el Gateway cliente sin sedes ve 0, no un error | success |
| `features/home/inicio_test.dart` | US-11.2.3 (SCRUM-1446) — resumen de inicio por el Gateway cliente: si Core no devuelve las sedes, el valor queda vacío | success |
| `features/messaging/chat_cubit_page_test.dart` | ChatCubit C2: si el envío falla, no hay mensaje, el error queda y se puede reintentar con la misma clave | success |
| `features/messaging/chat_cubit_page_test.dart` | ChatCubit C3: un 404 o 403 en la lectura deja el hilo inaccesible | success |
| `features/messaging/chat_cubit_page_test.dart` | ChatCubit un 409 deja el hilo en solo lectura y conserva lo leído | success |
| `features/messaging/chat_cubit_page_test.dart` | ChatCubit vacío, solo espacios o más de 1000 caracteres no llegan a Core | success |
| `features/messaging/mensajes_gateway_test.dart` | errores C3: 404 y 403 son definitivos; no se reintenta el hilo | success |
| `features/messaging/mensajes_gateway_test.dart` | errores el correlationId de Core queda en el fallo | success |
| `features/messaging/mensajes_gateway_test.dart` | errores sin red se explica y no es definitivo | success |
| `features/messaging/mensajes_gateway_test.dart` | errores un 400 muestra el texto de Core sin el código | success |
| `features/messaging/mensajes_gateway_test.dart` | errores un 409 es servicio cerrado: se lee pero no se escribe | success |
| `features/messaging/mensajes_gateway_test.dart` | errores un 5xx no filtra detalles internos y no es definitivo | success |
| `features/notifications/avisos_test.dart` | AvisosCubit un error del Gateway se muestra con su mensaje; uno de formato, genérico | success |
| `features/notifications/avisos_test.dart` | AvisosView sin avisos muestra el estado vacío | success |
| `features/notifications/avisos_test.dart` | AvisosView un error muestra el mensaje y permite reintentar | success |
| `features/payments/cobros_test.dart` | CobrosAliadoCubit y pantalla sin cobros muestra el estado vacío y el aviso simulado | success |
| `features/payments/cobros_test.dart` | CobrosAliadoCubit y pantalla un fallo muestra el error y permite reintentar | success |
| `features/payments/cobros_test.dart` | GatewayFuenteCobros traduce 401, 403, 404 y 500 a un fallo de pago | success |
| `features/payments/cobros_test.dart` | RetencionPagoCard un error que no es de pago usa un mensaje genérico | success |
| `features/payments/cobros_test.dart` | SCRUM-1710 · sondeo de Mis cobros un fallo conserva los cobros y no muestra error | success |
| `features/payments/pago_cubit_page_test.dart` | PagoCubit C2: si el pago falla vuelve al formulario con el error y sin pago | success |
| `features/payments/pago_cubit_page_test.dart` | PagoSandboxPage C2: un fallo del proveedor muestra el mensaje accionable y el código de seguimiento, sin resultado | success |
| `features/payments/pagos_gateway_test.dart` | comprobante un 409 (pago no aprobado) es un conflicto | success |
| `features/payments/pagos_gateway_test.dart` | errores 401, 403, 404, 400 y 503 se traducen a su tipo | success |
| `features/payments/pagos_gateway_test.dart` | errores C2: un 502 también es proveedor sin respuesta válida | success |
| `features/payments/pagos_gateway_test.dart` | errores C2: un 504 conserva el texto de Core que dice que no se cobró y el correlationId | success |
| `features/payments/pagos_gateway_test.dart` | errores sin red se explica y avisa de consultar antes de repetir | success |
| `features/payments/pagos_gateway_test.dart` | errores un 409 muestra el texto de Core sin el código | success |
| `features/payments/pagos_gateway_test.dart` | errores un 5xx genérico no filtra detalles internos | success |
| `features/profile_categories/categories_cubit_test.dart` | carga un error de carga queda en loadFailure y se puede reintentar | success |
| `features/profile_categories/categories_cubit_test.dart` | guardar cambiar la selección limpia el éxito y el error anteriores | success |
| `features/profile_categories/categories_cubit_test.dart` | guardar si el servidor rechaza, expone el error y no deja marcado lo que no se guardó | success |
| `features/profile_categories/categories_cubit_test.dart` | guardar sin conexión la selección se conserva, porque la petición no llegó al servidor | success |
| `features/profile_categories/categories_cubit_test.dart` | guardar sin selección muestra error y no llama al backend | success |
| `features/profile_categories/categories_gateway_test.dart` | el repositorio traduce el code que devuelve Core 401 → sinSesion; 500 → desconocido | success |
| `features/profile_categories/categories_gateway_test.dart` | el repositorio traduce el code que devuelve Core 403 MANI-CAT-403 y 403 sin code → noEsAliado | success |
| `features/profile_categories/categories_gateway_test.dart` | el repositorio traduce el code que devuelve Core 422 MANI-CAT-422C → categoriaNoDisponible | success |
| `features/profile_categories/categories_gateway_test.dart` | el repositorio traduce el code que devuelve Core 422 MANI-CAT-422V → seleccionVacia | success |
| `features/profile_categories/categories_gateway_test.dart` | el repositorio traduce el code que devuelve Core sin red → sinConexion | success |
| `features/profile_categories/categories_gateway_test.dart` | una respuesta sin la lista esperada es un error, no un conjunto vacío | success |
| `features/profile_categories/categories_page_test.dart` | error de carga ofrece reintentar | success |
| `features/profile_categories/categories_page_test.dart` | guardar sin selección muestra el error y no llama al backend | success |
| `features/profile_categories/categories_page_test.dart` | sin conexión el error se muestra pero la selección sigue ahí | success |
| `features/profile_categories/categories_page_test.dart` | un error del servidor se muestra y desmarca lo que no se guardó | success |
| `features/profile_categories/categories_repository_impl_test.dart` | traduce el code MANI-CAT-* del Gateway MANI-CAT-401: sesión requerida | success |
| `features/profile_categories/categories_repository_impl_test.dart` | traduce el code MANI-CAT-* del Gateway MANI-CAT-403: la verificación del aliado debe estar aprobada para declarar categorías | success |
| `features/profile_categories/categories_repository_impl_test.dart` | traduce el code MANI-CAT-* del Gateway MANI-CAT-403: solo un aliado activo | success |
| `features/profile_categories/categories_repository_impl_test.dart` | traduce el code MANI-CAT-* del Gateway MANI-CAT-422C: categoría no disponible | success |
| `features/profile_categories/categories_repository_impl_test.dart` | traduce el code MANI-CAT-* del Gateway MANI-CAT-422V: selecciona al menos una categoría | success |
| `features/profile_categories/categories_repository_impl_test.dart` | traduce el code MANI-CAT-* del Gateway el mensaje del 403 no afirma que baste con ser aliado | success |
| `features/profile_categories/categories_repository_impl_test.dart` | traduce el code MANI-CAT-* del Gateway sin red -> sinConexion | success |
| `features/profiles/company_sites/sedes_empresa_test.dart` | SedesEmpresaRemoteDataSource valida la respuesta de Core sin "zones" o sin "sitio" es un error, no una lista falsa | success |
| `features/profiles/company_sites/sedes_empresa_test.dart` | SedesEmpresaRepositoryImpl traduce los errores las demás operaciones también traducen el error | success |
| `features/profiles/company_sites/sedes_empresa_test.dart` | SedesEmpresaRepositoryImpl traduce los errores un 400 muestra el detalle del Gateway | success |
| `features/profiles/company_sites/sedes_empresa_test.dart` | SedesEmpresaRepositoryImpl traduce los errores un 404 sin código conocido usa el mensaje de la operación | success |
| `features/profiles/company_sites/sedes_empresa_test.dart` | SedesEmpresaRepositoryImpl traduce los errores un error que no es del Gateway usa el mensaje de la operación | success |
| `features/profiles/coverage/cobertura_controller_test.dart` | CoberturaController error de carga deja estado error y permite reintentar | success |
| `features/profiles/coverage/cobertura_controller_test.dart` | CoberturaController guardar con error conserva la selección del usuario | success |
| `features/profiles/coverage/cobertura_controller_test.dart` | CoberturaController primera declaración: no se puede guardar vacío | success |
| `features/profiles/coverage/cobertura_usecases_repo_test.dart` | CoberturaRepositoryImpl GatewayException se convierte en CoberturaFailure y se registra log ERROR | success |
| `features/profiles/coverage/cobertura_usecases_repo_test.dart` | CoberturaRepositoryImpl mapea códigos MANI-COB-* de la RPC | success |
| `features/profiles/coverage/data/cobertura_gateway_test.dart` | el repositorio traduce el code que devuelve Core 401 → sinSesion; 403 sin code → noEsAliado; 500 → desconocido | success |
| `features/profiles/coverage/data/cobertura_gateway_test.dart` | el repositorio traduce el code que devuelve Core cada código MANI-COB-* llega a su tipo | success |
| `features/profiles/direct_employees/empleado_directo_test.dart` | SCRUM-1376 (RF-05) — Registrar empleado directo un 409 de Core llega al usuario como falla con su mensaje | success |
| `features/profiles/own_profile/foto_perfil_jpg_png_test.dart` | subida por el Gateway otros errores no se disfrazan de error de foto | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl ante un 409 lanza yaResuelta y registra el error | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl errores de red se traducen a sinConexion | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl urlDocumento sin red conserva sinConexion | success |
| `features/profiles/verification/data/repository_impl_test.dart` | mapearMensaje traduce cada código MANI-VER-* de la RPC | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos 409 MANI-VER-409 se traduce a yaResuelta | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos 422 MANI-VER-422K se traduce a sinDocumentos | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos 422 MANI-VER-422M se traduce a motivoInvalido | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos caída de red se traduce a sinConexion | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C3 - permisos y aislamiento de tenant 401 del Gateway (sin sesión o JWT inválido) es sinSesion | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C3 - permisos y aislamiento de tenant 403 MANI-VER-403 (rol distinto de admin) es noAutorizado | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | aprobar si otro admin se adelantó (409) avisa y refresca el aliado | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | aprobar un error conserva el estado y lo informa | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | cargar un error al refrescar conserva la lista y muestra un aviso | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | cargar un error inicial deja la pantalla en estado error | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) error de carga ofrece reintentar | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) la búsqueda filtra y muestra un estado vacío claro | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) muestra la bandeja de pendientes con conteos y el panel vacío | success |
| `features/services/additions/adiciones_test.dart` | SCRUM-872 · fuente por el Gateway el tope de Core (400T) llega con su texto, sin el código | success |
| `features/services/additions/adiciones_test.dart` | SCRUM-872 · fuente por el Gateway los errores de listar y responder se traducen igual | success |
| `features/services/additions/adiciones_test.dart` | SCRUM-872 · fuente por el Gateway sin cotización aceptada el resumen es null; sin lista es un error | success |
| `features/services/additions/adiciones_test.dart` | SCRUM-872 · sección en la pantalla un error al cargar ofrece reintentar | success |
| `features/services/categories/data/catalogo_publico_datasource_test.dart` | un tenant inexistente propaga el error de Core | success |
| `features/services/categories/data/catalogo_publico_datasource_test.dart` | una respuesta sin "categories" es un error, no un catálogo vacío | success |
| `features/services/categories/data/gateway_datasource_test.dart` | errores de Core 403 → noAutorizado | success |
| `features/services/categories/data/gateway_datasource_test.dart` | errores de Core 409 CATEGORY_NAME_ALREADY_EXISTS → nombreDuplicado | success |
| `features/services/categories/data/gateway_datasource_test.dart` | errores de Core Rules rechaza el flujo (violations MANI-CAT-422F) | success |
| `features/services/categories/data/gateway_datasource_test.dart` | errores de Core Rules rechaza el nombre (violations MANI-CAT-422N) | success |
| `features/services/categories/data/repository_impl_test.dart` | CategoriasRepositoryImpl crear envía el código del flujo y la visibilidad | success |
| `features/services/categories/data/repository_impl_test.dart` | CategoriasRepositoryImpl errores de red se traducen a sinConexion | success |
| `features/services/categories/data/repository_impl_test.dart` | CategoriasRepositoryImpl un nombre repetido en el tenant responde nombreDuplicado y log ERROR | success |
| `features/services/categories/data/repository_impl_test.dart` | mapearMensaje traduce cada código MANI-CAT-* | success |
| `features/services/categories/domain/entidades_test.dart` | FlujoOperativo traduce los códigos de BD usados en los seeds | success |
| `features/services/categories/domain/entidades_test.dart` | FlujoOperativo un código desconocido o nulo devuelve null (no inventa un flujo) | success |
| `features/services/categories/domain/usecases_test.dart` | CambiarEstadoCategoria con id vacío falla con noEncontrada sin llamar al repositorio | success |
| `features/services/categories/presentation/categorias_cubit_test.dart` | cambiarEstado (US-03.1.2) si la categoría ya no existe (404), recarga el catálogo y avisa el error | success |
| `features/services/categories/presentation/categorias_cubit_test.dart` | cargar un error al refrescar conserva el catálogo y avisa | success |
| `features/services/categories/presentation/categorias_cubit_test.dart` | cargar un error inicial deja la pantalla en estado error | success |
| `features/services/categories/presentation/categorias_cubit_test.dart` | crear si otro admin la creó antes (409) recarga el catálogo | success |
| `features/services/categories/presentation/categorias_cubit_test.dart` | crear un error de red se devuelve y no altera el catálogo | success |
| `features/services/categories/presentation/gestion_categorias_page_test.dart` | Catálogo error de carga ofrece reintentar | success |
| `features/services/categories/presentation/gestion_categorias_page_test.dart` | Formulario (escritorio) un error del servidor se muestra y el formulario sigue abierto | success |
| `features/services/categories/presentation/gestion_categorias_page_test.dart` | Formulario (escritorio) un nombre sin letras muestra el error al terminar de escribir | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1400/1401 · cubit carga y filtra por tipo | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1400/1401 · cubit la respuesta tardía de un filtro anterior se descarta | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1400/1401 · cubit un error conserva la lista del mismo filtro | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1400/1401 · cubit un error inesperado se informa como desconocido | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · acceso el cliente y el admin de plataforma abren la ruta de elegibles | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · acceso «Ver aliados» solo aparece en las solicitudes pendientes | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · datasource por el Gateway cada error tiene un mensaje para el usuario | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · datasource por el Gateway consulta la solicitud con el filtro de tipo y el JWT | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · datasource por el Gateway sin filtro no envía "tipo" | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · datasource por el Gateway traduce 400, 401, 403, 404, 503, otros y sin red | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · modelo NO_DISPONIBLE conserva el motivo | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · modelo conserva el orden del backend aunque los puntajes estén invertidos | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · modelo dos lecturas de la misma respuesta son iguales | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · modelo sin "ranking" se trata como NO_DISPONIBLE | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · modelo un 200 sin "matchedAllies" no es una lista vacía | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · modelo un tipo desconocido se muestra como lo envía Dispatch | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · pantalla los chips filtran por tipo y el vacío lo dice | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · pantalla mientras carga muestra el indicador | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · pantalla muestra el orden del backend con puesto y razones | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · pantalla sin aliados y sin filtro lo dice | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · pantalla sin ranking dice «Orden no disponible» y no numera | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1401 · pantalla un error se muestra y «Reintentar» vuelve a consultar | success |
| `features/services/events/cola_eventos_test.dart` | ColaEventos en la web (y en las pruebas en escritorio) no hay modo sin conexión | success |
| `features/services/events/cola_eventos_test.dart` | EventosCubit sin conexión C1: sin red el evento queda pendiente con la clave del intento y la hora de captura; al volver la red se envía solo | success |
| `features/services/events/cola_eventos_test.dart` | EventosCubit sin conexión al cargar se envía lo pendiente; un rechazo de Core se avisa | success |
| `features/services/events/cola_eventos_test.dart` | EventosCubit sin conexión con la cola llena no se registra y se pide conectarse | success |
| `features/services/events/cola_eventos_test.dart` | EventosCubit sin conexión sin cola (web o cliente) un fallo de red se informa como antes | success |
| `features/services/events/cola_eventos_test.dart` | EventosCubit sin conexión un rechazo distinto de la red no se encola | success |
| `features/services/events/cola_eventos_test.dart` | EventosCubit sin conexión varios enviados se cuentan; si la lista no carga no es un fallo | success |
| `features/services/events/eventos_test.dart` | SCRUM-869 · fuente por el Gateway listar lee la secuencia; una respuesta sin la lista es un error | success |
| `features/services/events/eventos_test.dart` | SCRUM-869 · fuente por el Gateway un 409 de Core se traduce con su texto, sin el código | success |
| `features/services/events/eventos_test.dart` | SCRUM-870 · ramas de error al ver la foto si el sistema no puede abrir la URL, se avisa | success |
| `features/services/events/eventos_test.dart` | SCRUM-870 · ramas de error al ver la foto un 404 de Core al pedir la foto llega como fallo de no encontrada | success |
| `features/services/execution/ejecucion_test.dart` | SCRUM-1644 · sondeo silencioso un fallo conserva lo que se ve y no muestra error | success |
| `features/services/execution/ejecucion_test.dart` | SCRUM-868 · fuente por el Gateway un 409 de Core llega con su texto, sin el código | success |
| `features/services/execution/ejecucion_test.dart` | SCRUM-868 · sección en la pantalla un 409 de Core se avisa y no cambia lo que se ve | success |
| `features/services/quotes/cotizacion_test.dart` | Cotización · cubit cargar trae las versiones; un fallo sin datos muestra el error | success |
| `features/services/quotes/cotizacion_test.dart` | Cotización · cubit un fallo de la acción se avisa como error y conserva la lista | success |
| `features/services/quotes/cotizacion_test.dart` | Cotización · fuente por el Gateway 401, 403, 404, 503 y sin red tienen su propio tipo; nunca lista vacía | success |
| `features/services/quotes/cotizacion_test.dart` | Cotización · fuente por el Gateway un 409 conserva el texto de Core sin el código MANI-COT | success |
| `features/services/quotes/cotizacion_test.dart` | Cotización · fuente por el Gateway una respuesta sin la lista es un error | success |
| `features/services/quotes/cotizacion_test.dart` | Cotización · pantalla un error de carga se muestra con «Reintentar» | success |
| `features/services/ratings/m08_gateway_contrato_test.dart` | SCRUM-878 · política de cancelación del tenant un 403 de Core (rol sin permiso) llega como sinPermiso | success |
| `features/services/requests/data/datasource_gateway_test.dart` | SCRUM-1465: búsqueda de zonas en el catálogo de Core, sin RPC un error de Core llega como GatewayException y no se guarda | success |
| `features/services/requests/data/datasource_gateway_test.dart` | SCRUM-1465: búsqueda de zonas en el catálogo de Core, sin RPC una respuesta sin `zones` es un error, no una lista vacía | success |
| `features/services/requests/data/datasource_gateway_test.dart` | SCRUM-1465: categorías y sitios por Core, sin RPC un 403 de Core llega como GatewayException, no como lista vacía | success |
| `features/services/requests/data/datasource_gateway_test.dart` | SCRUM-1465: categorías y sitios por Core, sin RPC una respuesta sin la lista es un error, no una lista vacía | success |
| `features/services/requests/data/datasource_gateway_test.dart` | el 422 de Core llega con su código MANI-SOL | success |
| `features/services/requests/data/datasource_gateway_test.dart` | una respuesta sin solicitud es un error | success |
| `features/services/requests/data/errores_por_codigo_test.dart` | cada código MANI-SOL conocido se traduce a su tipo, sea cual sea el status | success |
| `features/services/requests/data/errores_por_codigo_test.dart` | con un código desconocido o sin código decide el status HTTP | success |
| `features/services/requests/data/errores_por_codigo_test.dart` | el 403 del cliente sí conserva su mensaje cuando el código lo dice | success |
| `features/services/requests/data/errores_por_codigo_test.dart` | el error lleva el código y la referencia para el diagnóstico | success |
| `features/services/requests/data/errores_por_codigo_test.dart` | un 403 con MANI-PLA-403 ya no dice «solo los clientes pueden publicar» | success |
| `features/services/requests/data/errores_por_codigo_test.dart` | un error local (sin servicio) no tiene línea de diagnóstico | success |
| `features/services/requests/data/repository_impl_test.dart` | Aviso a los aliados (SCRUM-1402) reintentar el aviso usa una clave nueva y traduce errores | success |
| `features/services/requests/data/repository_impl_test.dart` | Publicar errores de red se traducen a sinConexion | success |
| `features/services/requests/data/repository_impl_test.dart` | Trazabilidad log ERROR al fallar | success |
| `features/services/requests/data/repository_impl_test.dart` | mapearGateway traduce el status y el código MANI-SOL de Core | success |
| `features/services/requests/data/repository_impl_test.dart` | mapearMensaje traduce cada código MANI-SOL | success |
| `features/services/requests/domain/dominio_test.dart` | ModalidadCobro usa los códigos de flujo operativo de US-03.1.1 | success |
| `features/services/requests/presentation/crear_solicitud_cubit_test.dart` | cargar un error de carga deja la pantalla en error | success |
| `features/services/requests/presentation/crear_solicitud_cubit_test.dart` | publicar ante un error conserva todo y reintenta con la MISMA clave | success |
| `features/services/requests/presentation/crear_solicitud_cubit_test.dart` | publicar un error de zona lleva al paso de ubicación | success |
| `features/services/requests/presentation/crear_solicitud_page_test.dart` | un error al publicar se informa y permite reintentar | success |
| `features/services/tracking/cancelacion_test.dart` | SCRUM-1710 · sondeo de Mis solicitudes un fallo conserva la lista y no muestra error | success |
| `features/services/tracking/cancelacion_test.dart` | SCRUM-1710 · sondeo de Mis solicitudes un sondeo exitoso borra el error de una carga fallida | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · fuente por el Gateway 404, 409, 422 y una respuesta sin solicitud se traducen | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · fuente por el Gateway sin motivo envía un cuerpo vacío | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · pantalla si Core la rechaza muestra el motivo del error | success |
| `features/services/tracking/seguimiento_test.dart` | HU-M07-04 (SCRUM-871) · cubit un error inesperado se muestra como desconocido | success |
| `features/services/tracking/seguimiento_test.dart` | HU-M07-04 (SCRUM-871) · fuente por el Gateway 401, 403, 5xx y sin red se traducen sin disfrazarse | success |
| `features/services/tracking/seguimiento_test.dart` | HU-M07-04 (SCRUM-871) · fuente por el Gateway cada error tiene mensaje para el usuario | success |
| `features/services/tracking/seguimiento_test.dart` | HU-M07-04 (SCRUM-871) · fuente por el Gateway una respuesta sin lista es un error, no «sin solicitudes» (T2) | success |
| `features/services/tracking/seguimiento_test.dart` | HU-M07-04 (SCRUM-871) · pantalla un error se muestra y se puede reintentar | success |
| `features/tariffs/tarifas_gateway_test.dart` | SCRUM-885/886/887 · tarifario un 409 de Core se muestra sin su código | success |
| `features/tenant_rules/tenant_rules_datasource_test.dart` | SCRUM-1366 · fuente de reglas operativas del tenant un 409 de Core llega como GatewayException | success |
| `features/tenant_rules/tenant_rules_test.dart` | TenantRules Domain & Cubit (SCRUM-1366) TenantRulesCubit recarga versión vigente tras un 409 y limpia mensaje crudo | success |
| `features/tenant_rules/tenant_rules_test.dart` | TenantRules Domain & Cubit (SCRUM-1366) TenantRulesCubit usa mensajeErrorGateway al fallar cargar | success |

## QAS-36 siguiente paso en formularios y estados críticos

100 de 100 pasan.

| Archivo | Prueba | Resultado |
|---|---|---|
| `core/network/gateway_client_test.dart` | errores (CA-4) timeout se traduce sin quedarse esperando | success |
| `features/asignacion/domain/dominio_test.dart` | BandejaSolicitudes disponibles FIFO: el cliente que más espera va primero | success |
| `features/asignacion/domain/dominio_test.dart` | SolicitudEntity minutosEsperando cuenta desde la creación | success |
| `features/asignacion/presentation/formato_reglas_sitio_test.dart` | reglasParaMostrar asignado ve también el contacto y las instrucciones | success |
| `features/asignacion/presentation/formato_reglas_sitio_test.dart` | reglasParaMostrar en la oferta quita el contacto, las instrucciones y las vacías | success |
| `features/asignacion/presentation/solicitudes_aliado_page_test.dart` | SCRUM-1388: reglas del sitio en la tarjeta asignada: también el contacto y las instrucciones | success |
| `features/asignacion/presentation/solicitudes_aliado_page_test.dart` | marca como urgente a quien espera 30+ minutos | success |
| `features/asignacion/presentation/solicitudes_aliado_page_test.dart` | un aliado en revisión ve por qué no puede tomar trabajos | success |
| `features/audit/auditoria_test.dart` | AuditoriaView cargar más agrega los eventos siguientes | success |
| `features/audit/auditoria_test.dart` | AuditoriaView filtrar por pago consulta con ese id; cargar más agrega la siguiente página | success |
| `features/auth/data/login_errores_test.dart` | un error inesperado no expone la excepción al usuario | success |
| `features/auth/data/registro_aliado_gateway_test.dart` | datasource los documentos KYC viajan como archivos en el multipart | success |
| `features/auth/data/registro_aliado_gateway_test.dart` | datasource mantiene la forma de respuesta que espera la UI | success |
| `features/auth/data/registro_cliente_empresa_gateway_test.dart` | datasource devuelve la forma que espera la UI | success |
| `features/auth/data/registro_cliente_gateway_test.dart` | datasource mantiene la forma de respuesta que espera la UI | success |
| `features/auth/data/registro_empresa_gateway_test.dart` | datasource mantiene la forma de respuesta que espera la UI | success |
| `features/messaging/chat_cubit_page_test.dart` | ChatCubit las consultas siguientes piden solo lo posterior al último mensaje y no duplican | success |
| `features/messaging/chat_cubit_page_test.dart` | ChatPage un mensaje del otro aparece en la siguiente consulta, sin acción de la persona | success |
| `features/payments/cobros_test.dart` | GatewayFuenteCobros una respuesta sin la forma esperada es un fallo controlado | success |
| `features/payments/pagos_gateway_test.dart` | pagar cada escenario viaja con el texto que Core espera | success |
| `features/profile_categories/categories_cubit_test.dart` | guardar un guardado exitoso mueve el punto de retorno: el siguiente rechazo vuelve ahí | success |
| `features/profile_categories/categories_gateway_test.dart` | una respuesta sin la lista esperada es un error, no un conjunto vacío | success |
| `features/profile_categories/categories_repository_impl_test.dart` | traduce el code MANI-CAT-* del Gateway MANI-CAT-403: la verificación del aliado debe estar aprobada para declarar categorías | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl ante un 409 lanza yaResuelta y registra el error | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl aprobar envía VERIFICADO y devuelve la entidad actualizada | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl errores de red se traducen a sinConexion | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl rechazar envía RECHAZADO con el motivo | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl registra un log estructurado sin datos personales al resolver | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl sin rol de admin lanza noAutorizado | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl un aliado de otro tenant responde noEncontrado | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl urlDocumento de un archivo inexistente lanza documentoNoDisponible | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl urlDocumento devuelve la URL firmada de un archivo existente | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl urlDocumento sin red conserva sinConexion | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C1 - operaciones por el Gateway aprobar: PATCH con decision VERIFICADO y sin motivo | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C1 - operaciones por el Gateway detalle: GET /aliados/:id/verificacion | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C1 - operaciones por el Gateway listar: GET con JWT y X-Correlation-ID, mapea la vista | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C1 - operaciones por el Gateway rechazar: PATCH con decision RECHAZADO y el motivo | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C1 - operaciones por el Gateway urlDocumento: GET /aliados/:id/documentos/:documentoId/url | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos 409 MANI-VER-409 se traduce a yaResuelta | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos 422 MANI-VER-422K se traduce a sinDocumentos | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos 422 MANI-VER-422M se traduce a motivoInvalido | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos caída de red se traduce a sinConexion | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos documento inexistente se traduce a documentoNoDisponible | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos documento sin aliado no llama al Gateway y no está disponible | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos lista con forma inesperada lanza desconocido | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos respuesta sin URL se trata como documento no disponible | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C2 - escenarios negativos sin code de negocio, se decide por el status HTTP | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C3 - permisos y aislamiento de tenant 401 del Gateway (sin sesión o JWT inválido) es sinSesion | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C3 - permisos y aislamiento de tenant 403 MANI-VER-403 (rol distinto de admin) es noAutorizado | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C3 - permisos y aislamiento de tenant aliado de otro tenant responde 404 y se ve como noEncontrado | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C3 - permisos y aislamiento de tenant ninguna petición envía tenant_id: Core lo toma del JWT | success |
| `features/profiles/verification/domain/entidades_test.dart` | DecisionVerificacion aprobar no requiere datos y es igual por valor | success |
| `features/profiles/verification/domain/entidades_test.dart` | DecisionVerificacion rechazar exige un motivo de 10 a 500 caracteres (sin contar espacios extremos) | success |
| `features/profiles/verification/domain/entidades_test.dart` | DecisionVerificacion rechazar recorta el motivo válido | success |
| `features/profiles/verification/domain/entidades_test.dart` | DocumentoKyc expone nombre de archivo y detecta imágenes | success |
| `features/profiles/verification/domain/entidades_test.dart` | DocumentoKyc mapea los tipos que envía el registro y degrada lo desconocido a "otro" | success |
| `features/profiles/verification/domain/entidades_test.dart` | EstadoVerificacion.desde traduce los valores de BD, incluido VERIFICADO de los seeds | success |
| `features/profiles/verification/domain/entidades_test.dart` | EstadoVerificacion.desde un valor desconocido se trata como pendiente (nunca se pierde en la bandeja) | success |
| `features/profiles/verification/domain/entidades_test.dart` | SolicitudAliado diasEnEspera cuenta desde el registro | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | abrirDocumento abre la URL firmada | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | abrirDocumento si el archivo no está disponible avisa sin romper | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | abrirDocumento si el sistema no puede abrir la URL avisa | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | aprobar al aprobar el último pendiente retrocede al anterior | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | aprobar aprueba, avisa y avanza al siguiente pendiente | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | aprobar marca procesando y bloquea una segunda decisión simultánea | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | aprobar si otro admin se adelantó (409) avisa y refresca el aliado | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | aprobar un error conserva el estado y lo informa | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | cargar al refrescar descarta la selección si el aliado ya no existe | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | cargar pasa por cargando y queda listo con la lista ordenada | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | cargar un error al refrescar conserva la lista y muestra un aviso | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | cargar un error inicial deja la pantalla en estado error | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | dos avisos iguales seguidos tienen ids distintos (ambos se muestran) | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | filtros buscar filtra dentro de la pestaña actual | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | filtros cambiarFiltro muestra solo ese estado y limpia la selección | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | rechazar con motivo inválido no llama al servidor | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | rechazar rechaza con motivo y avisa | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | seleccionar si el aliado ya no existe lo quita de la bandeja y avisa | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | seleccionar trae el detalle fresco del servidor | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) al tocar una tarjeta muestra el perfil con sus documentos | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) aprobar pide confirmación, aprueba y pasa al siguiente pendiente | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) bandeja sin pendientes celebra que está al día | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) cancelar la confirmación no aprueba | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) error de carga ofrece reintentar | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) la búsqueda filtra y muestra un estado vacío claro | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) la pestaña Rechazados muestra el resultado con el motivo | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) marca como urgente a quien lleva 3+ días esperando | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) muestra la bandeja de pendientes con conteos y el panel vacío | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) rechazar valida el motivo, admite motivos rápidos y rechaza | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) sin documentos el botón Aprobar está deshabilitado y se explica por qué | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) ver un documento abre su URL firmada | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Móvil tocar una tarjeta abre el perfil en su propia pantalla | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Móvil tras aprobar vuelve a la bandeja con el conteo actualizado | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Navegación del admin el botón de categorías invoca la navegación inyectada | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Navegación del admin sin callback no muestra el acceso a categorías | success |
| `features/services/additions/adiciones_test.dart` | SCRUM-872 · sección en la pantalla el aliado ve su adición esperando al cliente | success |
| `features/services/categories/presentation/categorias_cubit_test.dart` | cambiarEstado (US-03.1.2) marca cambiandoEstadoIds e ignora toques repetidos mientras espera | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1400/1401 · cubit un error inesperado se informa como desconocido | success |
| `features/services/quotes/cotizacion_test.dart` | Cotización · pantalla SCRUM-865: con ajuste solicitado el aliado puede enviar la siguiente versión | success |
| `features/services/tracking/seguimiento_test.dart` | HU-M07-04 (SCRUM-871) · cubit un error inesperado se muestra como desconocido | success |
| `features/tenant_rules/tenant_rules_datasource_test.dart` | SCRUM-1366 · fuente de reglas operativas del tenant actualizar envía la versión esperada y las reglas con PUT | success |

## QAS-39 aviso antes de cancelar o revertir y volver

116 de 116 pasan.

| Archivo | Prueba | Resultado |
|---|---|---|
| `core/arquitectura/supabase_solo_auth_test.dart` | la app respeta ADR-0027 y T6 C1: supabase.auth solo se usa para iniciar, renovar y cerrar sesión (y leerla) | success |
| `core/config/tenant_config_test.dart` | rechaza un UUID en lugar del slug | success |
| `core/platform/selector_foto_perfil_test.dart` | seleccionarFotoPerfil (SCRUM-1389) devuelve null cuando el usuario cancela la selección | success |
| `core/session/contexto_plataforma_test.dart` | SCRUM-901 · contexto del administrador de plataforma el contexto se borra al iniciar o cerrar sesión, no al refrescar el token | success |
| `core/shell/app_shell_test.dart` | US-11.2.1 (SCRUM-1444) — menú superior cerrar sesión está disponible y llama al cierre | success |
| `core/shell/app_shell_test.dart` | US-11.2.1 (SCRUM-1444) — menú superior en móvil el menú desplegable incluye cerrar sesión y ejecuta onCerrarSesion | success |
| `core/widgets/refresco_periodico_test.dart` | SCRUM-1644 · RefrescoPeriodico pausa con la pestaña oculta y consulta enseguida al volver | success |
| `core/widgets/refresco_periodico_test.dart` | SCRUM-1644 · RefrescoPeriodico pausa mientras otra ruta tapa la pantalla y al volver solo reanuda el intervalo | success |
| `features/asignacion/asignacion_repository_test.dart` | Errores de Dispatch y Core por el Gateway aceptar lo que ya rechacé responde yaRechazada (409R) | success |
| `features/asignacion/asignacion_repository_test.dart` | Rechazar no se puede rechazar una solicitud que ya es tuya | success |
| `features/asignacion/asignacion_repository_test.dart` | Rechazar oculta la solicitud solo para quien la rechaza | success |
| `features/asignacion/asignacion_repository_test.dart` | Rechazar rechazar dos veces es idempotente | success |
| `features/asignacion/asignacion_repository_test.dart` | Rechazar un 422D de Dispatch se traduce a detalleInvalido | success |
| `features/asignacion/asignacion_repository_test.dart` | Rechazar «Otro» llega con su detalle | success |
| `features/asignacion/data/asignacion_gateway_test.dart` | rechazar: POST reject con el código del motivo, y detalle solo con «Otro» | success |
| `features/asignacion/domain/dominio_test.dart` | Casos de uso RechazarSolicitud envía el motivo y no rechaza lo propio | success |
| `features/asignacion/domain/dominio_test.dart` | los motivos de rechazo coinciden con el CHECK de la migración 005 | success |
| `features/asignacion/presentation/solicitud_cancelada_test.dart` | US-04.5.1 (SCRUM-877): CANCELADA se reconoce y no queda disponible | success |
| `features/asignacion/presentation/solicitud_cancelada_test.dart` | US-04.5.1 (SCRUM-877): el aliado ve su trabajo cancelado por el cliente y sin «Cotización» | success |
| `features/asignacion/presentation/solicitud_cancelada_test.dart` | una asignada sin cancelar conserva «Cotización» | success |
| `features/asignacion/presentation/solicitudes_aliado_cubit_test.dart` | aceptar si ya la había rechazado (409R) la quita y explica | success |
| `features/asignacion/presentation/solicitudes_aliado_cubit_test.dart` | rechazar la quita de mi bandeja con el motivo elegido | success |
| `features/asignacion/presentation/solicitudes_aliado_cubit_test.dart` | rechazar marca "rechazando" mientras se envía | success |
| `features/asignacion/presentation/solicitudes_aliado_page_test.dart` | rechazar pide confirmación y un motivo obligatorio | success |
| `features/asignacion/presentation/solicitudes_aliado_page_test.dart` | volver del diálogo no rechaza nada | success |
| `features/asignacion/presentation/solicitudes_aliado_page_test.dart` | «Otro» pide el texto y no deja rechazar hasta tener 3 caracteres | success |
| `features/audit/auditoria_test.dart` | AuditoriaCubit un filtro de pago que no es UUID se rechaza sin consultar a Core | success |
| `features/auth/data/consentimiento_legal_gateway_test.dart` | si Core rechaza el consentimiento no se lanza, pero queda un log ERROR sin datos personales | success |
| `features/auth/data/registro_empresa_gateway_test.dart` | repositorio: errores visibles (CA-4) 401 pide volver a iniciar sesión | success |
| `features/auth/presentation/registro_cliente_empresa_test.dart` | HU-M02-07 validadores NIT: rechaza vacío, corto, con letras o DV de dos cifras | success |
| `features/auth/presentation/selector_categoria_catalogo_test.dart` | una categoría elegida que ya no existe se descarta | success |
| `features/auth/recuperacion/enlace_recuperacion_test.dart` | EnlaceRecuperacion.desde un token de otro tipo (no recovery) se descarta | success |
| `features/auth/recuperacion/recuperacion_gateway_test.dart` | restablecer si falla no intenta cerrar sesión en Supabase | success |
| `features/auth/recuperacion/recuperacion_pantallas_test.dart` | pantalla: restablecer contraseña si el servicio rechaza el enlace se muestra su mensaje y no hay diálogo de éxito | success |
| `features/availability/disponibilidad_cubit_test.dart` | BorradorAusencia.validar rechaza fin no posterior al inicio, ausencias pasadas y largas | success |
| `features/availability/disponibilidad_cubit_test.dart` | editar y eliminar actualizan la lista desde el servidor | success |
| `features/availability/disponibilidad_page_test.dart` | eliminar pide confirmación y devuelve a Disponible | success |
| `features/availability/disponibilidad_repository_impl_test.dart` | editar usa PATCH sobre el id y eliminar usa DELETE | success |
| `features/home/inicio_test.dart` | US-11.2.3 (SCRUM-1446) — pantalla de inicio muestra tarjeta de cerrar sesión cuando onCerrarSesion está configurado y lo ejecuta | success |
| `features/messaging/chat_cubit_page_test.dart` | ChatPage al pasar a segundo plano deja de consultar y al volver consulta de inmediato | success |
| `features/payments/cobros_test.dart` | SCRUM-1710 · sondeo de Mis cobros la retención pasa a liquidación sin volver a cargando | success |
| `features/payments/cotizacion_boton_pago_test.dart` | una cotización pendiente, rechazada o con ajuste no se paga | success |
| `features/payments/pago_cubit_page_test.dart` | PagoCubit un pago rechazado o pendiente se muestra y no pide comprobante | success |
| `features/payments/pago_cubit_page_test.dart` | PagoSandboxPage SCRUM-890: cancelar la descarga no muestra mensaje | success |
| `features/payments/pago_cubit_page_test.dart` | PagoSandboxPage SCRUM-890: si guardar falla lo dice; si se cancela no muestra nada; sin guardador no hay botón | success |
| `features/payments/pago_cubit_page_test.dart` | PagoSandboxPage SCRUM-891 C2: un pago rechazado no consulta ni muestra retención | success |
| `features/payments/pago_cubit_page_test.dart` | PagoSandboxPage un rechazo muestra el motivo y no hay comprobante | success |
| `features/profile_categories/categories_cubit_test.dart` | guardar si el servidor rechaza el guardado, la selección vuelve a lo último confirmado | success |
| `features/profile_categories/categories_cubit_test.dart` | guardar si el servidor rechaza, expone el error y no deja marcado lo que no se guardó | success |
| `features/profile_categories/categories_cubit_test.dart` | guardar un guardado exitoso mueve el punto de retorno: el siguiente rechazo vuelve ahí | success |
| `features/profiles/company_sites/sedes_empresa_test.dart` | SCRUM-852 / SCRUM-1387 — sedes del cliente empresa por el Gateway si Core rechaza la edición, el diálogo sigue abierto con el motivo | success |
| `features/profiles/coverage/cobertura_controller_test.dart` | CoberturaController descartarCambios vuelve a lo guardado | success |
| `features/profiles/coverage/declarar_cobertura_page_test.dart` | mapa dentro de la pantalla (HU-M04-07 / SCRUM-1396) volver a tocarla la quita | success |
| `features/profiles/direct_employees/empleado_directo_test.dart` | SCRUM-1376 (RF-05) — Registrar empleado directo rechaza copias que no son PDF, JPG o PNG, vacías o de más de 5 MB | success |
| `features/profiles/direct_employees/empleado_directo_test.dart` | SCRUM-1376 (RF-05) — Registrar empleado directo un archivo de más de 5 MB se rechaza en la pantalla | success |
| `features/profiles/own_profile/foto_perfil_jpg_png_test.dart` | validación previa en la app WEBP se rechaza sin llamar al Gateway | success |
| `features/profiles/own_profile/foto_perfil_jpg_png_test.dart` | validación previa en la app un archivo de 5 MB + 1 byte se rechaza sin llamar al Gateway | success |
| `features/profiles/verification/data/repository_impl_test.dart` | VerificacionAliadosRepositoryImpl rechazar envía RECHAZADO con el motivo | success |
| `features/profiles/verification/data/verificacion_gateway_test.dart` | C1 - operaciones por el Gateway rechazar: PATCH con decision RECHAZADO y el motivo | success |
| `features/profiles/verification/domain/entidades_test.dart` | DecisionVerificacion rechazar exige un motivo de 10 a 500 caracteres (sin contar espacios extremos) | success |
| `features/profiles/verification/domain/entidades_test.dart` | DecisionVerificacion rechazar recorta el motivo válido | success |
| `features/profiles/verification/domain/usecases_test.dart` | RechazarAliado envía el motivo recortado | success |
| `features/profiles/verification/domain/usecases_test.dart` | RechazarAliado no rechaza una solicitud ya resuelta | success |
| `features/profiles/verification/domain/usecases_test.dart` | RechazarAliado permite rechazar a un aliado sin documentos (para pedirle que los cargue) | success |
| `features/profiles/verification/domain/usecases_test.dart` | RechazarAliado valida el motivo antes de llamar a la red | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | cargar al refrescar descarta la selección si el aliado ya no existe | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | rechazar con motivo inválido no llama al servidor | success |
| `features/profiles/verification/presentation/bandeja_verificacion_cubit_test.dart` | rechazar rechaza con motivo y avisa | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) cancelar la confirmación no aprueba | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) la pestaña Rechazados muestra el resultado con el motivo | success |
| `features/profiles/verification/presentation/bandeja_verificacion_page_test.dart` | Escritorio (maestro-detalle) rechazar valida el motivo, admite motivos rápidos y rechaza | success |
| `features/services/additions/adiciones_test.dart` | SCRUM-872 · fuente por el Gateway aceptar y rechazar van a su ruta con el comentario opcional | success |
| `features/services/additions/adiciones_test.dart` | SCRUM-872 · sección en la pantalla el cliente acepta con confirmación y rechaza con comentario | success |
| `features/services/additions/adiciones_test.dart` | SCRUM-872 · sección en la pantalla si Core rechaza el pedido el formulario sigue abierto con lo escrito | success |
| `features/services/categories/data/gateway_datasource_test.dart` | errores de Core Rules rechaza el flujo (violations MANI-CAT-422F) | success |
| `features/services/categories/data/gateway_datasource_test.dart` | errores de Core Rules rechaza el nombre (violations MANI-CAT-422N) | success |
| `features/services/categories/domain/entidades_test.dart` | NuevaCategoria rechaza nombres de menos de 3 o más de 60 caracteres | success |
| `features/services/categories/domain/entidades_test.dart` | NuevaCategoria rechaza nombres sin letras | success |
| `features/services/categories/presentation/gestion_categorias_page_test.dart` | Formulario (escritorio) cancelar no crea nada | success |
| `features/services/eligible_allies/aliados_elegibles_test.dart` | SCRUM-1400/1401 · cubit la respuesta tardía de un filtro anterior se descarta | success |
| `features/services/events/cola_eventos_test.dart` | ColaEventos C2: un rechazo de Core saca el evento de la cola, se informa y sigue con los demás | success |
| `features/services/events/cola_eventos_test.dart` | EventosCubit sin conexión C1: sin red el evento queda pendiente con la clave del intento y la hora de captura; al volver la red se envía solo | success |
| `features/services/events/cola_eventos_test.dart` | EventosCubit sin conexión al cargar se envía lo pendiente; un rechazo de Core se avisa | success |
| `features/services/events/cola_eventos_test.dart` | EventosCubit sin conexión un rechazo distinto de la red no se encola | success |
| `features/services/quotes/cotizacion_test.dart` | Cotización · fuente por el Gateway SCRUM-867: cada decisión va a su ruta; el rechazo envía «motivo» y el ajuste «comentario» | success |
| `features/services/quotes/cotizacion_test.dart` | Cotización · pantalla SCRUM-867: rechazar exige un motivo de 5 caracteres | success |
| `features/services/ratings/m08_gateway_contrato_test.dart` | SCRUM-878 · política de cancelación del tenant GET y PUT a /tenants/me/politica-cancelacion con la forma de Core | success |
| `features/services/ratings/m08_gateway_contrato_test.dart` | SCRUM-878 · política de cancelación del tenant un 403 de Core (rol sin permiso) llega como sinPermiso | success |
| `features/services/ratings/m08_gateway_contrato_test.dart` | SCRUM-878 · vista previa de cancelación lee la respuesta real de Core: cancelación tardía con monto | success |
| `features/services/ratings/m08_gateway_contrato_test.dart` | SCRUM-878 · vista previa de cancelación sin política vigente no hay penalización | success |
| `features/services/ratings/m08_gateway_contrato_test.dart` | SCRUM-878 · vista previa de cancelación una solicitud ya cancelada no es cancelable | success |
| `features/services/requests/data/repository_impl_test.dart` | Publicar si Core rechaza la solicitud no quedan fotos huérfanas | success |
| `features/services/requests/data/repository_impl_test.dart` | Publicar una categoría de otro tenant o inactiva se rechaza | success |
| `features/services/requests/domain/dominio_test.dart` | FotoAdjunta rechaza formatos que no son imagen | success |
| `features/services/requests/domain/dominio_test.dart` | FotoAdjunta rechaza fotos vacías o de más de 5 MB | success |
| `features/services/requests/presentation/crear_solicitud_cubit_test.dart` | fotos agrega las válidas e informa las rechazadas | success |
| `features/services/requests/presentation/crear_solicitud_cubit_test.dart` | fotos rechaza fotos de más de 5 MB | success |
| `features/services/tracking/cancelacion_test.dart` | SCRUM-1710 · pantalla de Mis solicitudes con sondeo a los 20 s muestra el estado nuevo sin recargar | success |
| `features/services/tracking/cancelacion_test.dart` | SCRUM-1710 · pantalla de Mis solicitudes con sondeo sin intervalo no vuelve a consultar | success |
| `features/services/tracking/cancelacion_test.dart` | SCRUM-1710 · sondeo de Mis solicitudes no borra el motivo de una cancelación rechazada | success |
| `features/services/tracking/cancelacion_test.dart` | SCRUM-1710 · sondeo de Mis solicitudes no consulta mientras hay una cancelación en curso | success |
| `features/services/tracking/cancelacion_test.dart` | SCRUM-1710 · sondeo de Mis solicitudes trae el estado nuevo sin pasar por cargando y actualiza la hora de consulta | success |
| `features/services/tracking/cancelacion_test.dart` | SCRUM-1710 · sondeo de Mis solicitudes un fallo conserva la lista y no muestra error | success |
| `features/services/tracking/cancelacion_test.dart` | SCRUM-1710 · sondeo de Mis solicitudes un sondeo exitoso borra el error de una carga fallida | success |
| `features/services/tracking/cancelacion_test.dart` | SCRUM-1710: una respuesta vieja del sondeo no deshace una cancelación posterior | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · cubit reemplaza la tarjeta por la solicitud cancelada | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · cubit si ya empezó la ejecución avisa y vuelve a consultar el estado real | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · cubit un fallo de red conserva la lista y avisa, sin reconsultar | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · fuente por el Gateway 404, 409, 422 y una respuesta sin solicitud se traducen | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · fuente por el Gateway PATCH /core/solicitudes/me/{id}/cancelar con el motivo y sin ids del cliente | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · fuente por el Gateway sin motivo envía un cuerpo vacío | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · modelo se ofrece cancelar en todo estado anterior a la ejecución | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · pantalla al confirmar cancela con el motivo y la tarjeta queda Cancelada | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · pantalla pide confirmación; «Volver» no cancela | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · pantalla si Core la rechaza muestra el motivo del error | success |
| `features/services/tracking/cancelacion_test.dart` | US-04.5.1 (SCRUM-877) · pantalla solo ofrece cancelar antes de la ejecución | success |

## QAS-39: revisión del código de las reversiones críticas (develop daba130)

| Acción | Confirmación antes de ejecutar | Fuente |
|---|---|---|
| Cancelar solicitud, rechazar oferta, aprobar o rechazar aliado, eliminar ausencia | Sí, diálogo con prueba | SDD §8 QAS-39 (corte 2026-11-04) y pruebas de la tabla anterior |
| Desactivar categoría (visible para clientes) | **No.** `gestion_categorias_page.dart:133` llama a `cambiarEstado` sin diálogo; en `categories/presentation` solo hay `showDialog` en `formulario_categoria.dart` (crear) | revisión de código |
| Cerrar sesión | **No.** `app_shell.dart:111` `_cerrarSesion` llama directo a `onCerrarSesion` | revisión de código |

Falta decidir si desactivar categoría y cerrar sesión son "reversiones críticas" (análisis del 9 nov, QAS-39). Desactivar categoría deja de mostrar la categoría a todos los clientes del tenant, así que QA la propone como crítica.

## Lo que no cubre este informe

El método pide además capturas recorriendo la app en QA. QA no inicia sesión con cuentas de prueba en `10.43.100.141` desde el navegador de Claude (no es un host local ni un ambiente de prueba con nombre); ese recorrido queda para hacerlo con la sesión del responsable de QA.

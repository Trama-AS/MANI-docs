# Lista de chequeo: revisión heurística de QAS-30, 31 y 32 (T-45, opción B)

Ambiente: MANI-QA (`10.43.100.141`), Flutter web de `release`. Evaluador: QA. Cuentas de prueba por rol (se citan por correo, nunca la contraseña).
Base: las 10 heurísticas de Nielsen. Severidad: 0 no es problema, 1 cosmético, 2 menor, 3 mayor, 4 bloqueante.

## Flujos por rol

| Rol | Flujo | Ruta | Base (QAS-31) | Crítico (QAS-32) |
|---|---|---|---|---|
| Cliente | F1 Registrarse | `/registro-cliente` | Sí | Sí |
| Cliente | F2 Crear solicitud | `/cliente/solicitudes/nueva` | Sí | Sí |
| Cliente | F3 Ver aliados y aceptar cotización | `/cliente/solicitudes/:id/aliados`, `/cotizacion` | Sí (aceptación) | Sí |
| Cliente | F4 Pagar | `/cliente/pagos/:id` | | Sí |
| Cliente | F5 Cancelar solicitud | `/cliente/solicitudes` | | Sí |
| Cliente | F6 Poner una queja | `/cliente/quejas` | | |
| Aliado | F7 Registrarse | `/registro-aliado` | Sí | Sí |
| Aliado | F8 Ver bandeja y cotizar | `/aliado/solicitudes`, `/cotizacion` | | Sí |
| Aliado | F9 Configurar disponibilidad y cobertura | `/aliado/disponibilidad`, `/cobertura` | | |
| Aliado | F10 Ver cobros | `/aliado/cobros` | | |
| Admin | F11 Verificar aliado | `/admin/verificacion-aliados` | | Sí |
| Admin | F12 Gestionar categorías | `/admin/categorias` | | Sí |
| Admin | F13 Reglas y tarifas | `/admin/reglas`, `/admin/tarifas` | | |
| Admin | F14 Atender quejas | `/admin/quejas` | | |

## Por flujo se registra

**QAS-30 (reconocibilidad).** ¿La acción principal se ve en la primera pantalla del flujo, sin desplazarse, con un verbo claro y sin necesitar documentación? Sí / No. Cumple si es Sí en el 100 % de los flujos.

**QAS-31 (aprendizabilidad).** En los flujos base (F1, F2, F3, F7): puntos de asistencia = pasos donde una persona nueva necesitaría ayuda (rótulo ambiguo, paso oculto, error sin indicación de cómo seguir, dato que no sabe de dónde sacar). Cumple si cada flujo tiene ≤ 1.

**QAS-32 (operabilidad).** En los flujos críticos: se ejecuta la tarea en QA y se anota si termina sin error de operación. Éxito = tareas completadas / tareas intentadas. Cumple con ≥ 90 %.

**Heurísticas (H1 a H10).** Por flujo, cada hallazgo con su heurística y severidad:
H1 visibilidad del estado · H2 lenguaje del usuario · H3 control y libertad (deshacer, volver) · H4 consistencia · H5 prevención de errores · H6 reconocer antes que recordar · H7 flexibilidad · H8 diseño minimalista · H9 ayuda a reconocer y corregir errores · H10 ayuda y documentación.

## Plantilla de registro

| Flujo | Acción principal visible (30) | Asistencias (31) | Completó sin error (32) | Hallazgos (heurística, severidad) | Captura |
|---|---|---|---|---|---|

## Límite del método

Es una revisión de experto, no una prueba con usuarios reales: el evaluador conoce el sistema, así que subestima las asistencias de una persona nueva. La opción B la aceptó la SM el 22 nov; la opción A (3 a 5 personas por rol) queda como mejora.

## Registro (22 nov, viewport 800x600, cuenta admin.t1@qa.mani.test)

| Flujo | Acción principal visible (30) | Asistencias (31) | Completó sin error (32) | Hallazgos (heurística, severidad) |
|---|---|---|---|---|
| F11 Verificar aliado | Sí: «Aprobar» y «Rechazar» fijos abajo del detalle; el panel vacío dice «Selecciona un aliado» | — | Pendiente de autorización (cambia datos) | H1 sev 2: la lista tardó ~15 s con solo un punto de carga; al recargar, las primeras llamadas dan 401 y se reintentan |
| F12 Categorías | Sí: «Nueva categoría» arriba a la derecha; «Activar» en cada tarjeta | — | Pendiente | — |
| F13a Tarifario | Sí: «Cargar tarifa», «Editar» y «Otra vigencia» por categoría | — | — | — |
| F13b Reglas del tenant | **No**: «Guardar nueva versión» queda debajo del pliegue, después de 5 parámetros | — | — | H2 sev 2: rótulos con códigos de requisito («(RF-13)», «(RNF-10)»); H4 sev 1: encabezado en mayúsculas, sin el ícono ni el subtítulo de las demás páginas |
| F14 Quejas | Sí: filtros por estado y «Historial» | — | — | — |

### Ejecuciones (autorizadas por Santiago, 22 nov)

| Flujo | Resultado (32) | Asistencias (31) | Notas |
|---|---|---|---|
| F11 Verificar aliado | Completó: «Aliado QA Final» aprobado | 0 | Rechazar abre diálogo con motivos sugeridos y ejemplo (H5, H9 bien); Aprobar confirma y explica qué pasa (H1 bien) |
| F12 Crear categoría | Completó: «Categoria QA T45 heuristica» (cotización previa) | 0 | Formulario por pasos con sugerencias. **Quedó visible para clientes en QA: ocultarla al terminar** |
| Cerrar sesión | Sin confirmación (QAS-39: esperado, #149 no está en QA) | — | — |
| F1 Registro cliente | En curso: correo qa.t45.cliente.1822@qa.mani.test, falta contraseña y consentimiento (los pone Santiago) | — | QAS-30: «Crear mi cuenta de cliente» bajo el pliegue a 800x600. H9 sev 2: al enviar sin contraseña el error queda fuera de vista y no avisa del consentimiento faltante |

## Registro sobre la interfaz final (Flutter 77cd696, 22 nov ~22:55Z, viewport 800x865, admin.t1@qa.mani.test)

Las filas anteriores se tomaron sobre 0de1255 (interfaz vieja). Estas las reemplazan.

| Flujo | Acción principal visible (30) | Asistencias (31) | Completó sin error (32) | Hallazgos (heurística, severidad) |
|---|---|---|---|---|
| F11 Verificar aliado | Sí: pestañas Pendientes/Aprobados/Rechazados y buscador; con la bandeja vacía dice «¡Bandeja al día!» | — | No ejecutable: 0 pendientes (se encadena con F7) | H1 sev 2: ~12 s con solo un indicador de carga antes de mostrar la lista (persiste) |
| F12 Categorías | Sí: «Nueva categoría» arriba a la derecha; «Ocultar/Activar» en cada tarjeta | — | Completó: ocultar «Categoria QA T45 heuristica» (confirmación + aviso de resultado) | H1 bien: el aviso explica qué pasa con los servicios en curso |
| F13a Tarifario | Sí: «Cargar tarifa», «Editar», «Otra vigencia» e «Historial» por categoría | — | — | — |
| F13b Reglas del tenant | **No**: «Guardar nueva versión» bajo el pliegue, después de 5 parámetros (persiste) | — | — | H2 sev 2: rótulos con códigos «(RF-13)», «(RNF-10)»; H4 sev 2: sin el encabezado con ícono y subtítulo que tienen las demás páginas, título y secciones en mayúsculas |
| F14 Quejas | Sí: filtros por estado y «Historial»; texto «Cada cambio queda registrado con tu usuario» | — | — | — |
| F2 Crear solicitud (cliente.t1) | Sí: categorías como tarjetas en el paso 1; «Continuar» fijo abajo | 0 | Completó: Plomería, 4 pasos, «¡Solicitud publicada!» con resumen | H1 bien: barra de pasos «Paso n de 4»; H5 bien: contador de 20 caracteres mínimos y ejemplo; H6 bien: direcciones guardadas para elegir |
| F3 Ver aliados / aceptar | Sí: «Ver aliados» y «Ver cotización» en cada tarjeta | 0 (ver) | Ver aliados: completó. Aceptar: no ejecutable (la solicitud nueva no tiene aliados en su zona; las demás ya tienen cotización aceptada) | H2 sev 1: «Orden no disponible: los aliados no están ordenados por recomendación» expone un estado técnico al cliente |
| F4 Pagar | Sí: «Pagar (sandbox)» bajo la cotización aceptada | — | No ejecutado por QA-agente (transacción; la ejecuta Santiago si se quiere contar) | H2 sev 1: «(sandbox)» es jerga técnica |
| F5 Cancelar solicitud | Sí: «Cancelar solicitud» en cada tarjeta | 0 | Completó: confirmación con penalización ($0) y motivo opcional; aviso «Cancelaste la solicitud» | H1 sev 1: el «Consultado: 17:53» de la cabecera no se actualiza tras cancelar |
| F6 Poner queja | Sí, indirecta: la pantalla dice «Para presentar una nueva, ve a Mis pedidos», donde está «Presentar queja» | — | — | H6 sev 1: la acción no está en la pantalla de quejas |
| F8 Bandeja y cotizar (aliado.t1) | Sí: «Aceptar»/«Rechazar» en cada solicitud; aviso de que el primero en aceptar se queda con el trabajo | 0 | Completó: aceptó «Corte 2 lote C» y envió cotización v1 de $120.000 (dentro del rango de referencia); aviso «Cotización v1 enviada al cliente» | H1 bien: «Asegurando…» al aceptar y etiqueta «NUEVA» en Mis trabajos; H5 bien: rango de referencia junto al formulario |
| F9 Disponibilidad y cobertura | Sí: «Marcar no disponible» fijo abajo; «Guardar cobertura» abajo a la derecha | — | — | H4 sev 1: «Mis zonas» sin el encabezado con ícono y subtítulo de las demás páginas |
| F10 Cobros | Sí (consulta): por liquidar y liquidado arriba; franja «Simulación: no mueve dinero real» | — | — | H6 sev 2: cada cobro muestra el monto y el estado, pero no a qué servicio corresponde; H4 sev 1: sin encabezado con ícono |
| F7 Registro aliado (intento 1, Santiago) | No a 800x865: «Enviar registro a revisión» bajo el pliegue, después de 3 secciones | ≥ 1 | **Falló**: cédula PDF de 1,7 MB → `POST /api/v1/core/auth/register/ally` 413 de NGINX (×4 reintentos). El formulario no dice el tamaño máximo y el error solo dice que los archivos superan el límite | **Defecto D-T45-1 (sev 3):** en el Gateway, `location /api/v1/core/auth/` no fija `client_max_body_size` (queda en 1 MB por defecto), mientras foto de perfil tiene 6m y solicitudes 5 MB. Una cédula escaneada normal no pasa. Responsable: Gateway (DevOps). H9 sev 3: el error no dice el límite ni cómo seguir; H2 sev 2: «Backoffice», «KYC», «Garantía Multi-tenant»; H4 sev 2: estilo viejo (mayúsculas) distinto al resto |
| D-T45-1 corregido | — | — | Gateway#100 (develop f8b5835) y #101 (release e454bcf), desplegado en QA 23:10Z. `POST /api/v1/core/auth/register/ally` con 2 MB inválidos: antes 413 de NGINX, ahora 400 de Core (llega al servicio). Falta repetir F7 con la cédula de 1,7 MB | — |
| F7 (intentos 2 y 3) | — | — | **Falló** otra vez, con dos defectos más detrás del 413: D-T45-2, 400 «Tipo de archivo no permitido: application/octet-stream» (Flutter no ponía tipo MIME a los documentos; MANI-Flutter#159 → release 003f57e, desplegado 00:01Z); D-T45-3, 400 TERMS_NOT_ACCEPTED con la casilla marcada (Core exige `acceptsTerms` desde SCRUM-856, 7 oct, y Flutter no lo envía en aliado persona natural; MANI-Flutter#161, CI en verde) | El registro de aliado persona natural no funcionaba en QA desde el 7 oct |
| F7 (intento 4, con los tres arreglos: Gateway e454bcf, Flutter 95a3e42) | — | — | **Completó**: `POST /auth/register/ally` 201, diálogo «¡Registro Enviado a Revisión!» con estado PENDIENTE DE REVISIÓN y botón «Ir al inicio de sesión» (23 nov 00:25Z, qa.t45.aliado.2240@qa.mani.test) | H2 sev 2: el diálogo dice «El Backoffice validará…» |
| F11 Verificar aliado (ejecución, admin.t1) | Sí: «Aprobar» y «Rechazar» fijos abajo del perfil | 0 | Completó: aprobó «Aliado QA T45 Heuristica»; confirmación explica qué pasa al aprobar y pide confirmar que se revisaron los 2 documentos; aviso «…fue aprobado. Ya puede recibir solicitudes» y contador Aprobados 68 → 69 | H1 sev 2: la lista tardó ~18 s con solo un indicador de carga. Documentos del registro: cédula JPG (137 KB) y RUT PDF; el límite >1 MB quedó probado aparte con `curl` (2 MB → 400 de Core, ya no 413) |
| F3 Aceptar cotización (ejecución, cliente.t1) | Sí: «Aceptar cotización» ancho bajo la cotización, con «Pedir ajuste» y «Rechazar» | 0 | Completó: aceptó la cotización v1 de $120.000 que envió aliado.t1 en F8; aviso «Aceptaste la cotización» y aparece «Pagar (sandbox)» | H5 sev 2: aceptar un compromiso de pago no pide confirmación (rechazar tampoco se probó); H1 bien: «Dentro del rango de referencia» junto al total |

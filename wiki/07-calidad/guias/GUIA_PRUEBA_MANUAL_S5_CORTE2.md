> **Finalidad:** guía para repetir a mano el recorrido de QA de un corte. **Mantiene:** QA (Santiago Hernández). **Consume:** QA de apoyo (Camila) y quien repita la prueba. **Se actualiza:** en cada corte de prueba manual. **Versión:** 1.0, Sprint 5 corte 2 (5 nov 2026). **HU:** [SCRUM-1692](https://maniservices.atlassian.net/browse/SCRUM-1692). Las contraseñas de las cuentas de QA no están aquí: se entregan por un canal privado.

# Guía de prueba manual: Sprint 5, corte 2, en MANI-QA

5-nov-2026 · Santiago

## Para qué es esta guía

QA repitió las pruebas por API el 5 nov con los roles nuevos de base de datos, sin fallas nuevas, y el equipo recorrió el flujo en la app. Lo previsto para el sprint funciona, salvo lo de la tabla de abajo. QA se queda en la versión actual, sin las últimas correcciones de `release` (901, 1418 y 1453): recarga la app sin caché antes de probar. La evidencia de API está en `QA_PRUEBAS_S5_CORTE2.md`.

- **Estado en Jira:** casi todas las historias se cerraron el 5 nov por decisión del equipo, con los videos validados en persona. Tu prueba sigue valiendo: si una historia cerrada falla, se abre un bug.
- **Si algo falla:** anota clave SCRUM, paso, cuenta y hora, y pásamelo. Se abre un bug con ese dato; la historia no se reabre.
- **Si falla por datos o despliegue:** avísame; no se reabre, se corrige el ambiente y se repite.

## Acceso y cuentas

App: **http://10.43.100.141:8080**, con red de la universidad o VPN. Las contraseñas y la forma de entrar se entregan por un canal privado, nunca en la wiki.

t1 es ACME Servicios y t2 es Nova Mantenimiento. Usa t2 para comprobar que no se ve nada de t1.

| Cuenta | Para qué sirve |
|---|---|
| cliente.t1 | solicitudes, cotizaciones, pagos, quejas, calificar |
| aliado.t1 | ofertas, cotizar, ejecutar, cobertura, disponibilidad, cobros |
| admin.t1 | categorías, tarifas, reglas, quejas, métricas, verificación |
| cliente_empresa.t1 | sedes y reglas de sitio |
| admin.t2, cliente.t2, aliado.t2 | casos de otro tenant |
| cliente_natural.t2, empleado_directo.t2 | estados vacíos |

Para los registros usa correos nuevos, con dominio que reciba correo si necesitas confirmarlo. No cambies la contraseña de las cuentas compartidas.

Los pagos son simulados: no se usa tarjeta real ni se mueve dinero.

## Lo que ya sabemos que falla

Lo de esta tabla no hace falta reportarlo de nuevo. Lo de la tabla siguiente sí, si vuelve a pasar.

| Clave | Qué pasa | Estado |
|---|---|---|
| SCRUM-1383 | Documento y teléfono en claro en la base. | Reabierta |
| SCRUM-1634, Foto de perfil | Cambiar la imagen no funciona en la app. | Por hacer |
| SCRUM-1635, Aliados por solicitud | Ver los aliados de una solicitud no funciona en la app. | Por hacer |
| SCRUM-1636, Estado en vivo | Los cambios de estado requieren recargar la página. | Por hacer |
| SCRUM-1637, Clientes y tenant | Los clientes quedan asociados a un tenant. | Por hacer; por decidir |
| SCRUM-901 | C1 no se puede probar: no hay cuenta PLATFORM_ADMIN en QA. | En revisión |
| SCRUM-1403 | Con varias aceptaciones casi simultáneas, algunas dan 503. Nunca hay doble asignación. | Observación |
| Aliados elegibles y ofertas | Tardan unos 2 s o más aun sin carga. Bajo carga fallan porque se agotan las conexiones de Core. Si solo es lentitud, no es defecto nuevo; si da error sin carga, sí avísame. | No cumple QAS-03 |
| SCRUM-1396, mapa | MANI-Flutter#131 sin fusionar: con más de 20 zonas el mapa puede no cargar. Las geometrías ya están en QA. | En revisión |

Sigue fallando por API (SCRUM-1633) y la historia está en Finalizada:

| Clave | Qué fallaba |
|---|---|
| SCRUM-892 | Si se paga después de finalizar, el dinero queda RETENIDA para siempre. La app muestra Pagar con cotización aceptada, sin mirar el estado de la solicitud. |

## Recorrido principal

Un solo recorrido cubre casi todo. Hazlo primero con t1:

1. cliente.t1 crea una solicitud de Plomería (`/cliente/solicitudes/nueva`).
2. Abre aliados elegibles y lanza la oferta.
3. aliado.t1 acepta (`/aliado/solicitudes`) y cotiza.
4. cliente.t1 acepta la cotización y paga en sandbox **antes de que termine el servicio**.
5. aliado.t1 inicia, registra un avance con foto y finaliza.
6. Ambos califican. Con las dos calificaciones la solicitud pasa a CERRADA.

Después repite una lectura con t2: no debe ver nada de ese servicio.

## Sesión, registro y perfil

| Clave | Pasos en la app | Debe pasar |
|---|---|---|
| SCRUM-1369, 1370 | Entra con cliente.t1, aliado.t1 y admin.t1. Luego prueba una contraseña incorrecta. | Cada rol llega a su inicio. La contraseña mala no entra. |
| SCRUM-1372 | `/register-aliado` con correo nuevo y documentos. Repite sin documento. | Queda en verificación, sin aprobarse solo. Sin documento no se habilita. |
| SCRUM-1373 | `/register-empresa` con razón social, identificación y representante. Repite con datos inválidos. | Queda en verificación. Los inválidos muestran error. |
| SCRUM-1374 | `/register-cliente` con correo nuevo. Repite con el mismo documento. | Entra como cliente. El duplicado se rechaza. |
| SCRUM-1375 | `/register-cliente-empresa` con NIT válido. Repite con el mismo NIT. | La primera se crea y puede entrar. La segunda dice que ya existe. |
| SCRUM-1376 | admin.t1 en `/admin/empleados/nuevo` registra un empleado. Repite el documento. Entra como cliente.t1 y busca la opción. | Se crea en t1. El duplicado se rechaza. El cliente no tiene la opción. |
| SCRUM-1379 | Durante un registro intenta seguir sin aceptar términos, y luego acéptalos. | Sin aceptar no avanza. Aceptados, continúa. |
| SCRUM-1377, 1628, 1629 | `/perfil/editar`: sube un JPG o PNG menor de 5 MB y recarga. Prueba un WEBP y uno de más de 5 MB. | La foto queda. El WEBP y el pesado dan mensaje claro con el límite, sin «File too large». |
| SCRUM-1380 | Deja la sesión abierta más de una hora y navega. | Se renueva o vuelve al login; nunca muestra datos de otro tenant. |
| SCRUM-1446 | Entra con cliente.t1, cliente_empresa.t1 y cliente.t2. | Cada uno ve su propio inicio y sus sedes. |
| SCRUM-1378 | `/forgot-password` con un correo real tuyo que tenga cuenta; solo si QA envía correos. | Llega el correo y se restablece. Si no llega, anótalo; no uses cuentas compartidas. |

## Catálogo, cobertura y disponibilidad

| Clave | Pasos en la app | Debe pasar |
|---|---|---|
| SCRUM-1390 | admin.t1 en `/admin/categorias` crea una categoría. Repite el código. Entra como cliente.t1. | Se crea. El duplicado se rechaza. El cliente no puede crear. |
| SCRUM-1391 | admin.t1 desactiva una categoría de prueba; cliente.t1 abre nueva solicitud. Reactívala al terminar. | Desaparece del formulario y vuelve al activarla. |
| SCRUM-1392, 1632 | aliado.t1 en `/categories` marca una categoría y recarga. Si puedes provocar un rechazo, mira la pantalla. | Persiste al recargar. Tras un rechazo la casilla vuelve a su estado anterior y el contador no sube. |
| SCRUM-1395, 1385 | aliado.t1 en `/aliado/cobertura` elige zona y barrio, y recarga. Compara con aliado.t2. | Solo zonas activas de su tenant; persisten al recargar. |
| SCRUM-1396 | `/catalogo/mapa`: abre una localidad y un barrio con límite, y uno sin límite. | Muestra la forma correcta. Sin geometría muestra estado vacío, sin coordenadas inventadas ni GPS en vivo. |
| SCRUM-1386 | aliado.t1 en `/aliado/disponibilidad` agrega una ausencia. Prueba fechas invertidas o solapadas. Borra la ausencia al terminar. | Se guarda. Lo inválido da error. |
| SCRUM-1388 | cliente_empresa.t1 define reglas en `/sitios/:id/reglas`. Las abre el aliado asignado, y luego otro no asignado. | El asignado las ve al recargar. El otro no. Un sitio sin reglas muestra vacío, no error. |
| SCRUM-1389 | aliado.t1 abre su perfil. | Muestra sus propios datos. |

## Reglas y tarifas

Deja las reglas y las tarifas de t1 con los valores con que las encontraste.

| Clave | Pasos en la app | Debe pasar |
|---|---|---|
| SCRUM-1366 | admin.t1 en `/admin/reglas` cambia un valor. Prueba uno inválido. Entra como cliente.t1. | Crea versión nueva. El inválido no cambia nada; también vale para comisión mayor a 30 o con más de 2 decimales. El cliente no accede. La comisión de t1 está en 10 %. |
| SCRUM-885 | admin.t1 en `/admin/tarifas` carga una tarifa con mínimo, máximo y vigencia. Prueba mínimo mayor que máximo. | Queda versionada. El rango invertido se rechaza y la vigente sigue igual. |
| SCRUM-886 | aliado.t1 cotiza en una categoría con tarifa y en una sin tarifa. | Con tarifa muestra la referencia. Sin tarifa dice no disponible, sin datos falsos. |
| SCRUM-866 | aliado.t1 cotiza fuera de rango; revisa cotizante y cliente. | Ambos ven la advertencia. El valor no cambia por sí solo. |
| SCRUM-887 | admin.t1 en `/admin/reportes/cotizaciones-fuera-de-rango`. Compara con admin.t2. | Aparece la cotización anterior. t2 no la ve; sin datos, muestra vacío. |

## Pagos y cobros

| Clave | Pasos en la app | Debe pasar |
|---|---|---|
| SCRUM-1432, 888 | cliente.t1 en `/cliente/pagos/:cotizacionId`: un escenario rechazado y uno aprobado. | Se identifica como simulado. El rechazado no registra pago exitoso. No deja pagar dos veces. |
| SCRUM-890 | Abre y descarga el comprobante del aprobado. Busca uno de un pago rechazado. | Se descarga el propio. Sin comprobante, mensaje claro. |
| SCRUM-891 | Revisa el estado después de pagar. | Dice retención simulada, no custodia real. El pago fallido no retiene. |
| SCRUM-893, 894 | aliado.t1 en `/aliado/cobros`. Entra con empleado_directo.t2. | Ve desglose de sus pagos y liquidaciones. Las nuevas usan 10 %, que es lo que dicen las reglas de t1; cuatro de prueba del 5 nov tienen 12 %, 10 % o 10,56 % a propósito, y las anteriores pueden mostrar otro valor. El otro ve vacío. |
| SCRUM-889 | admin.t1 en `/admin/auditoria-transacciones`. Luego admin.t2. | Aparece el pago con actor, valor y hora. t2 no lo ve. |

## Calificación, historial, avisos y quejas

| Clave | Pasos en la app | Debe pasar |
|---|---|---|
| SCRUM-874, 875, 1418 | Califica como cliente y como aliado. Intenta calificar otra vez. Mira el estado tras cada una. | Una por persona. Con una sigue FINALIZADA; con las dos, CERRADA. |
| SCRUM-878 | admin.t1 activa la política en `/admin/politica-cancelacion`; cliente.t1 cancela una solicitud asignada. **Al terminar, desactívala.** | Avisa de la penalización antes de cancelar y la aplica. Sin política no cobra. |
| SCRUM-877 | cliente.t1 cancela una PENDIENTE. Intenta cancelar una en ejecución. | La primera queda CANCELADA; la segunda no deja. |
| SCRUM-879, 880 | `/cliente/historial` y `/aliado/historial`. Luego cliente_natural.t2 y empleado_directo.t2. | Lista propia en orden; los de t2 ven estado vacío. |
| SCRUM-882, 884, 1423 | Revisa `/perfil/avisos` de cliente y aliado durante el recorrido. | Llegan los avisos de cada cambio a quien corresponde; nadie se avisa a sí mismo; el aviso no muestra el texto del mensaje. |
| SCRUM-895 | cliente.t1 en `/cliente/quejas` presenta una queja sobre un servicio propio. Prueba sin motivo. | Queda registrada. Sin motivo se rechaza. |
| SCRUM-896 | admin.t1 en `/admin/quejas` avanza el estado. Intenta una transición no permitida. Entra con admin.t2. | Cambia con actor y fecha. La no permitida no cambia nada. t2 no la ve. |
| SCRUM-883 | admin.t1 en `/admin/conversaciones` abre el chat por la queja. Prueba con cliente.t1. | El admin lo ve y queda registrado. El cliente no tiene la opción. |
| SCRUM-900 | admin.t1 en `/admin/metricas` con periodo con datos y sin datos. Compara con admin.t2. | Cifras del propio tenant; sin datos, vacío o cero real. |
| SCRUM-901 | C1 no se puede probar: no hay cuenta PLATFORM_ADMIN en QA. | En revisión |

## Pruebas que solo se hacen a mano

| Clave | Pasos | Debe pasar |
|---|---|---|
| SCRUM-873 | En el celular del aliado, sin red, registra una evidencia; recupera la red. | Queda en cola y se sube sin duplicarse. |
| SCRUM-1465 | Con la app abierta corta la red y navega. | Mensaje claro, sin pantalla rota. |
| SCRUM-1365, 1068 | Con cliente.t2 y aliado.t2 busca lo creado en t1. Crea una solicitud en una zona sin aliados. | Nada de t1 aparece. Sin cobertura no ofrece aliados inventados. |

No tienen pantalla, así que no te tocan: 1449, 1450, 1451, 1452, 1453, 1462, 1466, 1468, 1618, 1619, 1620, 1621, 1622 y 1630.

## Qué devolverme

Por cada clave: **Pasa**, **Falla** (con paso, cuenta y hora) o **No se pudo probar** (con motivo). Si revisaste el video, indícalo.

Si al probar ves mensajes o estados confusos, anótalos con la pantalla: sirven para QAS-35, QAS-36 y QAS-39.

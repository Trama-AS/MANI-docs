# Decisiones del PO

[← 01 · Producto](README.md) · [Índice](../Home.md)

| Campo | Valor |
|---|---|
| Finalidad | Registro de las decisiones de producto: qué se decidió, cuándo, por qué y en qué historia consta |
| Mantiene | Camila Beltrán (PO). Suplente para mantener, no para decidir: Sara Albarracín (SM) |
| Consume | Desarrollo (cómo implementar), QA (qué esperar en la prueba), Arquitectura (qué requisito precisa cada ADR) |
| Frecuencia | El mismo día de cada decisión |
| Versión y fecha | 1.0 · 2026-11-17 |

**Cómo se lee.** Cada fila copia la decisión tal como quedó en el comentario «Decisión del PO» de la historia enlazada, que es la fuente. Si la historia y esta página difieren, manda la historia y esta página se corrige. Una decisión posterior **reemplaza** a la anterior solo si lo dice; la anterior no se borra, se marca como reemplazada.

## Usuario, sesión y shell

| Fecha | Historia | Decisión | Motivo |
|---|---|---|---|
| 2026-10 | [SCRUM-1370](https://maniservices.atlassian.net/browse/SCRUM-1370) | El login **no** tiene selector de empresa ni pestañas de rol: la empresa sale del correo y el rol, de la cuenta. | Menos pasos y ningún error de elegir la empresa equivocada; el tenant viene del token. |
| 2026-11-04 | [SCRUM-1376](https://maniservices.atlassian.net/browse/SCRUM-1376) | Los empleados directos los registra el **administrador del tenant**; la opción vive solo en el menú del admin. | El empleado es de la empresa, no de un aliado, y Core exige el rol de administrador. Acordado con la SM. |
| 2026-11-17 | [SCRUM-1650](https://maniservices.atlassian.net/browse/SCRUM-1650) | **Cerrar sesión** y **desactivar una categoría** son acciones críticas y piden confirmación. Activar una categoría no la pide. | QAS-39: cerrar sesión interrumpe un trabajo en curso; desactivar una categoría la oculta a todos los clientes del tenant. |
| 2026-11-17 | [SCRUM-1648](https://maniservices.atlassian.net/browse/SCRUM-1648) | **Opción B** para el sistema de diseño: `ManiButton` y `ManiTextField` son obligatorios en toda pantalla nueva o modificada; las existentes se migran al tocarlas. | 48 botones y 44 campos en pantallas ya aceptadas: migrarlos no cambia nada para el usuario y obliga a revalidarlas. Se registra en el acta A/B ([SCRUM-1684](https://maniservices.atlassian.net/browse/SCRUM-1684)), fila QAS-33. |
| 2026-11-17 | [SCRUM-1645](https://maniservices.atlassian.net/browse/SCRUM-1645) | Aprobados la pantalla de arranque con marca, el título «MANI \| Servicios a domicilio para tu hogar» y la descripción para compartir el enlace. | Propuesta UI/UX §4. Falta el video de validación en QA. |

## Directorio y cobertura (M-03)

| Fecha | Historia | Decisión | Motivo |
|---|---|---|---|
| 2026-11-03 | [SCRUM-1385](https://maniservices.atlassian.net/browse/SCRUM-1385) | El alcance de la cobertura es la declaración del aliado por el contrato de Core a través del Gateway (`/api/v1/core/profiles/me/coverage`), sin RPC directo, con catálogo de zonas global y cobertura aislada por aliado. La consulta desde Dispatch para elegibilidad es alcance de [SCRUM-1068](https://maniservices.atlassian.net/browse/SCRUM-1068). | Condición para desbloquear la 1068 (ADR-0027: la app solo habla con el Gateway). |
| 2026-11-10 | [SCRUM-1387](https://maniservices.atlassian.net/browse/SCRUM-1387) | La baja de una sede es **lógica** (desactivar, nunca borrar), pero **no entra en lo entregado**: pasa al siguiente incremento como historia nueva. Mientras tanto, ninguna pantalla ni API borra sedes. | Una sede puede tener servicios e historial asociados. |
| 2026-11-04 | [SCRUM-1388](https://maniservices.atlassian.net/browse/SCRUM-1388) | En la oferta el aliado ve solo los **requisitos** del sitio (protección, permisos, horario), en texto legible. El **contacto de acceso** y las **instrucciones de ingreso** se ven solo después de la asignación. Reemplaza la decisión anterior de mostrar todas las reglas solo tras la asignación. | Cumple QS-06 (el aliado decide con los requisitos a la vista) sin exponer a unos 50 aliados el teléfono de la portería. Acordado con la SM. |

## Ciclo del servicio

| Fecha | Historia | Decisión | Motivo |
|---|---|---|---|
| 2026-10 | [SCRUM-1617](https://maniservices.atlassian.net/browse/SCRUM-1617) | Rechazar una oferta **exige** un motivo. | El motivo alimenta la elegibilidad y el análisis de rechazos. |
| 2026-10 | [SCRUM-867](https://maniservices.atlassian.net/browse/SCRUM-867) | El cliente acepta, rechaza o pide ajuste de la cotización; rechazar la cotización deja la solicitud rechazada, y una cotización no se decide dos veces. | Flujo de decisión único y auditable. |
| 2026-10 | [SCRUM-872](https://maniservices.atlassian.net/browse/SCRUM-872) | Las adiciones por imprevisto aceptadas no pueden superar el **50 %** de la cotización aceptada; el cobro es la cotización aceptada **más** las adiciones aceptadas. | Protege al cliente de sobrecostos sin bloquear imprevistos reales. |
| 2026-10 | [SCRUM-873](https://maniservices.atlassian.net/browse/SCRUM-873) | Las evidencias registradas sin conexión quedan en cola y se suben al volver la red, sin duplicarse. | El aliado trabaja en sitios sin señal. |
| 2026-10 | [SCRUM-884](https://maniservices.atlassian.net/browse/SCRUM-884) | El aviso de «solicitud asignada» le llega **al cliente**. | El cliente es quien espera saber que su servicio tiene técnico. |

## Pagos

| Fecha | Historia | Decisión | Motivo |
|---|---|---|---|
| 2026-11-03 | [SCRUM-1432](https://maniservices.atlassian.net/browse/SCRUM-1432) | Las ocho historias de pagos (1432, 888 a 894) **entran** en el Sprint 5; 891 se hace como estado simulado y 890 es la última prioridad. Reemplaza la propuesta del 29-oct de pasar 890 a 894 al 2.º incremento. | Decisión de la SM; son funcionalidades comprometidas con el cliente. |
| 2026-11-05 | [SCRUM-892](https://maniservices.atlassian.net/browse/SCRUM-892) · [SCRUM-891](https://maniservices.atlassian.net/browse/SCRUM-891) | Si el pago llega con la solicitud ya finalizada o cerrada, la retención se libera y se liquida al aliado **en ese momento**. No se prohíbe pagar una solicitud finalizada. | El total (cotización + adiciones) solo se conoce al terminar el servicio. Fila D2 / P-D2 de HU-VAL-01. QA midió que aún falla: [SCRUM-1633](https://maniservices.atlassian.net/browse/SCRUM-1633). |
| 2026-11-10 | [SCRUM-1687](https://maniservices.atlassian.net/browse/SCRUM-1687) | Comisión del **10 %** por defecto, editable por API, sin pantalla de administración. La retención se libera **al finalizar**, no al cierre. La liquidación es sobre todo lo retenido **menos** la comisión. [SCRUM-888](https://maniservices.atlassian.net/browse/SCRUM-888) mantiene el **pago aparte**. | Respuesta a las cuatro preguntas de Nicolás León. Que el pago al aliado no dependa de que el cliente califique. La regla de t1 que dice 15 % se corrige al 10 %. |

## Catálogo

| Fecha | Historia | Decisión | Motivo |
|---|---|---|---|
| 2026-11-10 | [SCRUM-1641](https://maniservices.atlassian.net/browse/SCRUM-1641) | En **producción** la categoría Jardinería queda **activa**; en **QA** queda **desactivada**, como la crea la semilla, y vuelve a ese estado después de cada prueba. | En PROD es una categoría real; en QA es el dato de prueba de categoría inactiva ([SCRUM-1391](https://maniservices.atlassian.net/browse/SCRUM-1391)). Fila D14 / P-D14. |
| 2026-11-10 (forma corregida el 2026-11-17) | [SCRUM-1687](https://maniservices.atlassian.net/browse/SCRUM-1687) | **HU-M04-05 se retira del plan de módulos** porque su alcance (consulta del catálogo por tenant) queda cubierto por [SCRUM-1390](https://maniservices.atlassian.net/browse/SCRUM-1390), [SCRUM-1391](https://maniservices.atlassian.net/browse/SCRUM-1391) y [SCRUM-1393](https://maniservices.atlassian.net/browse/SCRUM-1393) (HU-M04-01, 02 y 04). La SCRUM-1394 que citaba el plan nunca se creó. | Comprobado desde la app en QA el 2026-11-03 con cliente.t1 y cliente.t2. Fila D13. |

## Aceptación

| Fecha | Historia | Decisión | Motivo |
|---|---|---|---|
| 2026-11-10 | [SCRUM-1470](https://maniservices.atlassian.net/browse/SCRUM-1470) | El incremento del Sprint 5 se acepta **con condiciones**. Detalle en el [acta](acta-aceptacion-SCRUM-1470.md). | El flujo principal funciona de punta a punta en QA; quedan condiciones medibles. |

## Pendientes que son del PO

| Tema | Qué falta | Dónde |
|---|---|---|
| Cifrado de datos personales (P-D15b) | Un **RNF** de protección de datos personales en reposo y un **QAS** con umbral y método; sin ellos no se puede escribir el ADR de [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699) | [`VALIDACION_HU-VAL-01.md`](../06-gobernanza/VALIDACION_HU-VAL-01.md) §5 |
| Acta A/B por escenario de calidad | Firma de la PO sobre el acta que redacta la SM | [SCRUM-1684](https://maniservices.atlassian.net/browse/SCRUM-1684), en `06-gobernanza` |

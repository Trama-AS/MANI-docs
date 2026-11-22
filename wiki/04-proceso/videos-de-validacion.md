# Videos de validación

[← 04 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** el criterio «Video de validación» de las tareas del Sprint 6 en Jira (por ejemplo [SCRUM-1644](https://maniservices.atlassian.net/browse/SCRUM-1644), [SCRUM-1638](https://maniservices.atlassian.net/browse/SCRUM-1638) y [SCRUM-1697](https://maniservices.atlassian.net/browse/SCRUM-1697)) y los criterios de [SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694) · [`GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §2.3 y §9.1 · [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md) §15 y §22.

| Campo | Valor |
|---|---|
| **Finalidad** | Decir cómo se graba, se entrega y se valida el video que demuestra un cambio funcionando en QA |
| **Mantiene** | La página: Nicolás Álvarez (responsable de la carpeta). La regla: el PO y la Scrum Master |
| **Consume** | Quien implementa, QA y el PO |
| **Cada cuánto se actualiza** | Cuando cambia el criterio de video en el backlog |
| **Versión y fecha** | 1.0 · 2026-11-16 ([SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694)) |
| **Origen y destino** | Criterio de aceptación → cambio desplegado en QA → video → validación del PO → «Finalizada» |

> **De dónde sale esta regla.** Hoy está escrita solo en los criterios de aceptación de las tareas del Sprint 6. Todavía no está en `GOBIERNO_DEL_EQUIPO.md` ni en el [DoD](dor-y-dod.md). Esta página la ordena tal como está en Jira y no le añade nada; llevarla al documento de gobierno es un pendiente de la Scrum Master ([README §6](README.md#6-lo-que-falta)).

## 1. La regla

Textual, de los criterios del Sprint 6:

> Quien implementa graba el cambio funcionando en QA, a través del Gateway y con token real ES256 (sin mostrar credenciales), lo adjunta a la tarea y Camila (PO) lo valida; sin su visto bueno la tarea no pasa a Finalizado.

## 2. Ficha del proceso

| Campo | Valor |
|---|---|
| **Responsable** | Quien implementa graba y adjunta. La PO (Camila Beltrán) valida |
| **Entradas** | El cambio integrado y **desplegado en QA**; los criterios de aceptación de la tarea; cuentas de prueba de QA por rol |
| **Salidas** | El video adjunto a la tarea de Jira; un comentario de la PO con su visto bueno o con lo que falta; el paso a «Finalizada» |

## 3. Paso a paso

1. **Confirmar que el cambio está en QA.** Un PR integrado en `develop` no está en QA hasta que DevOps lo despliega ([Ambientes y promoción](ambientes-y-promocion.md)). Si no está, la tarea se queda en «En revisión» y se dice en un comentario qué despliegue falta.
2. **Preparar la sesión.** Una ventana privada por usuario y, si el caso tiene dos usuarios, cada uno en un navegador distinto ([Reporte de fallas §2](reporte-de-fallas.md#2-reglas-acordadas-para-probar)).
3. **Entrar por la aplicación de QA**, con una cuenta de prueba real. Así la petición pasa por el Gateway y el token es el ES256 que emite la autenticación de QA. No se usan tokens fabricados ni llamadas directas a un servicio.
4. **Grabar el cambio de principio a fin**, un criterio de aceptación a la vez, diciendo o mostrando cuál se está probando.
5. **No mostrar credenciales.** Ni contraseñas, ni el token, ni el contenido de las herramientas del navegador donde aparezca el token, ni archivos `.env` ([Secretos](secretos.md)). Si algo se coló, el video se graba otra vez: no se sube.
6. **Adjuntar el video a la tarea** y comentar qué criterio cubre cada tramo, la versión desplegada (commit o tag) y la fecha.
7. **La PO lo valida** en un comentario. Con su visto bueno, la tarea pasa a «Finalizada». Sin él, no pasa.

## 4. Qué no cuenta como video de validación

- Un video grabado en local o en DEV: el criterio dice QA.
- Un video de una llamada directa a Core, Dispatch o Rules sin pasar por el Gateway.
- Un video que no muestra el criterio, solo que la pantalla abre.

## 5. Ejemplo real del Sprint 5

[SCRUM-866](https://maniservices.atlassian.net/browse/SCRUM-866) (alerta de tarifa): el 5 de noviembre QA registró que la prueba por API pasaba y que faltaba la validación; ese mismo día la historia pasó a «Finalizada» con el comentario «video validado en persona y funcionalidad disponible en MANI-QA». En el Sprint 5 la validación podía hacerse en persona; desde el Sprint 6 el criterio pide que el video quede **adjunto a la tarea** y que la PO lo valide por escrito.

## 6. Tareas de esta carpeta que esperan video

Al 2026-11-16, del responsable de la carpeta: [SCRUM-1644](https://maniservices.atlassian.net/browse/SCRUM-1644) y [SCRUM-1710](https://maniservices.atlassian.net/browse/SCRUM-1710) (sondeo de estado), integradas en `develop` el 15 de noviembre y pendientes de despliegue en QA.

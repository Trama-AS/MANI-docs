# Reporte de fallas

[← 04 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** [`REPORTE_QA_SPRINT5.md`](../07-calidad/REPORTE_QA_SPRINT5.md), «Prueba manual del flujo» · [`GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §2.2, §2.3 y §6 · los criterios de [SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694), [SCRUM-1698](https://maniservices.atlassian.net/browse/SCRUM-1698) y [SCRUM-1642](https://maniservices.atlassian.net/browse/SCRUM-1642) en Jira.

| Campo | Valor |
|---|---|
| **Finalidad** | Decir cómo se prueba a mano en QA, a quién se le reporta una falla y con qué datos |
| **Mantiene** | La página: Nicolás Álvarez (responsable de la carpeta). La regla: QA (Santiago Hernández) con la Scrum Master |
| **Consume** | Todo el que prueba en QA: desarrollo, PO, QA |
| **Cada cuánto se actualiza** | Cuando QA cambia la forma de reportar o de registrar un defecto |
| **Versión y fecha** | 1.0 · 2026-11-16 ([SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694)) |
| **Origen y destino** | Criterio de aceptación → prueba en QA → falla reportada a QA → defecto en Jira → corrección por PR → re-prueba → cierre |

> **De dónde salen estas reglas.** Las de §2 son acuerdos del equipo que hoy están escritos solo en los criterios de SCRUM-1694. Todavía no están en `GOBIERNO_DEL_EQUIPO.md`. Esta página las ordena y no les añade nada; llevarlas al documento de gobierno es un pendiente de la Scrum Master ([README §6](README.md#6-lo-que-falta)).

## 1. Ficha del proceso

| Campo | Valor |
|---|---|
| **Responsable** | QA (Santiago Hernández) recibe, confirma y registra. Quien encuentra la falla la reporta |
| **Entradas** | Una falla vista en QA, con clave, paso, cuenta y hora |
| **Salidas** | La falla confirmada o descartada por QA; si se confirma, un defecto en Jira creado por QA, con su evidencia; al corregirse, la re-prueba y el cierre |

## 2. Reglas acordadas para probar

1. **Cada usuario en un navegador distinto.** Si el caso tiene un cliente y un aliado, uno va en un navegador y el otro en otro. Dos sesiones en el mismo navegador comparten almacenamiento y la segunda pisa a la primera.
2. **Ventana privada.** Evita que la caché sirva una versión anterior del front y que quede una sesión vieja.
3. **Las fallas se reportan a Santiago (QA).** El canal del equipo para pruebas y defectos es `#qa` ([Ceremonias y tiempos](ceremonias-y-tiempos.md)).
4. **No se crean incidencias.** Quien encuentra la falla no abre el ítem en Jira: lo hace QA después de confirmarla. Así no se duplican defectos ni se registra como defecto un dato viejo o un problema de ambiente.

## 3. Qué lleva un reporte

Los cuatro datos que piden los criterios de SCRUM-1698 y SCRUM-1642:

| Dato | Para qué |
|---|---|
| **Clave** | La historia o tarea de Jira que se estaba probando |
| **Paso** | Qué se hizo justo antes, de modo que otro lo pueda repetir |
| **Cuenta** | Con qué cuenta de prueba y qué rol. Nunca la contraseña |
| **Hora** | Con zona horaria, para cruzarla con los logs por `correlation_id` ([Observabilidad](observabilidad.md)) |

Además: el ambiente y la versión desplegada si se conoce, lo esperado, lo obtenido y una captura **sin credenciales ni datos personales** ([Secretos](secretos.md)).

## 4. Qué pasa después

1. QA intenta reproducirla. Si no se reproduce, se descarta y se dice por qué.
2. Si se confirma, QA la registra en Jira como defecto, con la evidencia. La Scrum Master y el PO la priorizan.
3. La corrección entra por rama y PR, como cualquier cambio ([Git](git-ramas-y-commits.md), [Pull requests](pull-requests.md)).
4. QA la vuelve a probar en QA y la cierra con evidencia, o la reabre con clave, paso, cuenta y hora.

Una falla que impide avanzar a otra persona es además un **bloqueo**: se registra como dice [Jira y trazabilidad](jira-y-trazabilidad.md#registro-de-un-bloqueo).

## 5. Ejemplo real del Sprint 5

El 5 de noviembre el equipo recorrió el flujo a mano en QA. Lo que falló se le reportó a Santiago, y **él abrió cinco defectos** (SCRUM-1633 a SCRUM-1637) en lugar de reabrir las historias, como quedó en [`REPORTE_QA_SPRINT5.md`](../07-calidad/REPORTE_QA_SPRINT5.md).

Dos de ellos muestran por qué importan los cuatro datos:

- **SCRUM-1636** («los cambios de estado no se actualizan en vivo») se abrió sin registrar en qué pantallas ni con qué cuentas se vio. En el Sprint 6 hizo falta una tarea aparte, [SCRUM-1698](https://maniservices.atlassian.net/browse/SCRUM-1698), solo para reproducirla y anotar esos datos.
- **SCRUM-1633** («un pago después de finalizar queda retenido») se re-probó el 12 de noviembre en [SCRUM-1642](https://maniservices.atlassian.net/browse/SCRUM-1642): 18 chequeos pasaron y ninguno falló. La falla del 5 de noviembre había medido un pago creado antes de la corrección, es decir, un dato viejo.

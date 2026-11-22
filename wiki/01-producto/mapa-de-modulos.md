# Mapa de módulos M-01 a M-13

[← 01 · Producto](README.md) · [Índice](../Home.md)

| Campo | Valor |
|---|---|
| Finalidad | Cómo se reparte el producto en módulos, quién responde por cada uno y en qué estado quedó al cerrar el Sprint 5 |
| Mantiene | Camila Beltrán (PO) |
| Consume | Todo el equipo; QA para saber a quién reportar una falla |
| Frecuencia | Al cerrar cada sprint |
| Versión y fecha | 1.0 · 2026-11-17 |
| Fuente | [`MANI_MODULOS_SERVICIOS_Y_BACKLOG_S5.xlsx`](../05-backlog/MANI_MODULOS_SERVICIOS_Y_BACKLOG_S5.xlsx) (hojas 01 y 24) y Jira al 2026-11-10 |

El **dueño** es quien tiene asignadas las historias del módulo en el Sprint 5. Donde hay dos, se nombra primero a quien tiene más historias.

| Módulo | Nombre | Épica | Dueño | Servicios | Estado al cierre del Sprint 5 |
|---|---|---|---|---|---|
| M-01 | Plataforma multi-tenant y aislamiento | EP-01 · [SCRUM-441](https://maniservices.atlassian.net/browse/SCRUM-441) | Daniel Ávila (con Nicolás León y Juan Sebastián Álvarez) | Core, Rules, Dispatch | Completo |
| M-02 | Usuario: identidad, registro, sesión y perfil | EP-11 · [SCRUM-1363](https://maniservices.atlassian.net/browse/SCRUM-1363) | Daniel Ávila y Nicolás León | Core, Dispatch | 14 de 15: falta [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383) (cifrado), `Reopened` |
| M-03 | Directorio, KYC y cobertura | EP-02 · [SCRUM-442](https://maniservices.atlassian.net/browse/SCRUM-442) | Camila Beltrán | Core, Dispatch | Completo |
| M-04 | Catálogo, zonas y barrios | EP-03 · [SCRUM-443](https://maniservices.atlassian.net/browse/SCRUM-443) | Sara Albarracín | Core, Rules, Dispatch | Completo. HU-M04-05 retirada del plan (ver [Decisiones del PO](decisiones-del-po.md#catálogo)) |
| M-05 | Solicitud y asignación | EP-04A · [SCRUM-444](https://maniservices.atlassian.net/browse/SCRUM-444) | Santiago Hernández | Core, Dispatch, Rules | Completo |
| M-06 | Cotización | EP-04B · [SCRUM-445](https://maniservices.atlassian.net/browse/SCRUM-445) | José Nicolás Álvarez | Core, Rules | Completo |
| M-07 | Ejecución y trazabilidad | EP-04C · [SCRUM-446](https://maniservices.atlassian.net/browse/SCRUM-446) | José Nicolás Álvarez | Core, Rules | Completo |
| M-08 | Calificación, cancelación y cierre | EP-04D · [SCRUM-447](https://maniservices.atlassian.net/browse/SCRUM-447) | Juan Sebastián Álvarez | Core, Rules | Completo |
| M-09 | Comunicación y notificaciones | EP-05 · [SCRUM-448](https://maniservices.atlassian.net/browse/SCRUM-448) | Nicolás León | Core, Dispatch | Completo |
| M-10 | Tarifario de referencia y reportes | EP-06 · [SCRUM-449](https://maniservices.atlassian.net/browse/SCRUM-449) | Juan Sebastián Álvarez | Rules, Core | Completo |
| M-11 | Pagos y facturación (pasarela simulada) | EP-07 · [SCRUM-450](https://maniservices.atlassian.net/browse/SCRUM-450) | Nicolás León | Core, Rules | Completo, con el bug [SCRUM-1633](https://maniservices.atlassian.net/browse/SCRUM-1633) abierto |
| M-12 | Operación, quejas y comercialización | EP-08 · [SCRUM-451](https://maniservices.atlassian.net/browse/SCRUM-451) | Juan Sebastián Álvarez | Core | Completo lo comprometido; disputa financiera, redes y campañas quedan fuera (2.º incremento) |
| M-13 | Shell de aplicación y navegación | EP-11 · [SCRUM-1363](https://maniservices.atlassian.net/browse/SCRUM-1363) | José Nicolás Álvarez | Core | Completo; dividir el front en módulos quedó fuera |

**Qué significa «completo».** Todas las historias del módulo comprometidas en el Sprint 5 están en Done en Jira. No significa que su escenario de calidad se cumpla: eso lo dice el [`REPORTE_QA_SPRINT5.md`](../07-calidad/REPORTE_QA_SPRINT5.md) y lo resume el [acta de la SCRUM-1470](acta-aceptacion-SCRUM-1470.md).

**Bugs abiertos por QA el 2026-11-05**, fuera del sprint: [SCRUM-1633](https://maniservices.atlassian.net/browse/SCRUM-1633) (pago tras finalizar), [SCRUM-1634](https://maniservices.atlassian.net/browse/SCRUM-1634) (foto de perfil en la app), [SCRUM-1635](https://maniservices.atlassian.net/browse/SCRUM-1635) (aliados por solicitud en la app), [SCRUM-1636](https://maniservices.atlassian.net/browse/SCRUM-1636) (estado en vivo) y [SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637) (clientes atados a un tenant; requiere ADR).

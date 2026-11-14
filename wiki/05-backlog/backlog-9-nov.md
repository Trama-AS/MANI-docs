# Backlog del 9 de noviembre de 2026 (Sprint 6)

[← 05 · Backlog](README.md) · [Índice](../Home.md)

| | |
|---|---|
| **Versión** | 1.0 |
| **Fecha** | 2026-11-10 |
| **Finalidad** | Registrar cada ítem creado el 9-nov con su clave de Jira, su responsable y su estado, y listar los defectos SCRUM-1633 a 1637 |
| **Lo mantiene** | Nicolás León (suplente: Nicolás Álvarez), a partir de Jira |
| **Lo consumen** | Product Owner (prioriza), Scrum Master (facilita), QA (cierra) y Desarrollo (ejecuta) |
| **Se actualiza** | En cada refinamiento y al cerrar el Sprint 6; el estado de cada ítem lo manda Jira |
| **Origen** | Jira, proyecto `SCRUM`, consulta del 10-nov-2026 de las claves SCRUM-1633 a SCRUM-1710 (78 ítems) |
| **Destino** | [`BACKLOG_MANI.md`](BACKLOG_MANI.md) §0 (plan del sprint) y el cierre del Sprint 6 (`SCRUM-1708`) |
| **Historia en Jira** | [SCRUM-1695](https://maniservices.atlassian.net/browse/SCRUM-1695) (HU-WIKI-07) |

> **Jira es la fuente.** Esta página es una fotografía del 10-nov-2026: si difiere del tablero, manda el tablero. Todos los ítems están en el **SCRUM Sprint 6** (estado «futuro» en esa fecha) salvo los defectos, que se abrieron el 5-nov.

## Resumen

| Dimensión | Reparto |
|---|---|
| Ítems | **78**, SCRUM-1633 a SCRUM-1710 sin huecos |
| Tipo | Tarea 55, Historia 17, Error 5, Epic 1 |
| Prioridad | Highest 3, High 29, Medium 34, Low 12 |
| Estado | Tareas por hacer 76, Finalizada 1, En curso 1 |

### Por responsable

| Responsable | Ítems |
|---|---:|
| Daniel Ávila | 19 |
| Nicolás León | 12 |
| José Nicolás Álvarez | 12 |
| Juan Sebastián Álvarez | 10 |
| Sara Albarracín | 9 |
| Santiago Hernández | 9 |
| Camila Beltrán | 7 |

## Defectos SCRUM-1633 a SCRUM-1637

Reportados por QA en la prueba manual del Sprint 5 (corte 2) del 5-nov. Situación según Jira y las descripciones de cada defecto al 10-nov:

| Clave | Defecto | Responsable | Situación |
|---|---|---|---|
| [SCRUM-1633](https://maniservices.atlassian.net/browse/SCRUM-1633) | Pago hecho después de finalizar queda RETENIDA y no se libera | Nicolás León | Arreglo en Core fusionado (MANI-Node#121, 5-nov); las dos retenciones que quedaron atascadas en QA se liberaron y liquidaron el 10-nov. Falta que QA lo vuelva a probar (`SCRUM-1642`). La parte de la app es `SCRUM-1697` |
| [SCRUM-1634](https://maniservices.atlassian.net/browse/SCRUM-1634) | Cambiar la foto de perfil no funciona en la app | Juan Sebastián Álvarez | La API responde bien; el fallo apunta a la pantalla. `SCRUM-1643` (errores con código y referencia) permite diagnosticarlo |
| [SCRUM-1635](https://maniservices.atlassian.net/browse/SCRUM-1635) | Ver los aliados de una solicitud no funciona en la app | Juan Sebastián Álvarez | La API responde bien; el fallo apunta a la pantalla. `SCRUM-1643` permite diagnosticarlo |
| [SCRUM-1636](https://maniservices.atlassian.net/browse/SCRUM-1636) | Los cambios de estado no se actualizan en vivo; hay que recargar la página | José Nicolás Álvarez | Se atiende con el sondeo de estado en `SCRUM-1644` y `SCRUM-1710` |
| [SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637) | Los clientes quedan asociados a un tenant | Sara Albarracín | No es un arreglo puntual: ADR-0018 hace del claim `tenant_id` la única fuente de tenant. Requiere decisión del equipo y un ADR nuevo antes de corregir |

## Todos los ítems

Ordenados por clave. Prioridad y estado son los de Jira en la fecha de consulta.

| Clave | Tipo | Prioridad | Estado | Responsable | Resumen |
|---|---|---|---|---|---|
| [SCRUM-1633](https://maniservices.atlassian.net/browse/SCRUM-1633) | Error | Medium | Tareas por hacer | Nicolás León | Pago hecho después de finalizar queda RETENIDA y no se libera |
| [SCRUM-1634](https://maniservices.atlassian.net/browse/SCRUM-1634) | Error | Medium | Tareas por hacer | Juan Sebastián Álvarez | Cambiar la foto de perfil no funciona en la app |
| [SCRUM-1635](https://maniservices.atlassian.net/browse/SCRUM-1635) | Error | Medium | Tareas por hacer | Juan Sebastián Álvarez | Ver los aliados de una solicitud no funciona en la app |
| [SCRUM-1636](https://maniservices.atlassian.net/browse/SCRUM-1636) | Error | Medium | Tareas por hacer | José Nicolás Álvarez | Los cambios de estado no se actualizan en vivo; hay que recargar la página |
| [SCRUM-1637](https://maniservices.atlassian.net/browse/SCRUM-1637) | Error | Medium | Tareas por hacer | Sara Albarracín | Los clientes quedan asociados a un tenant |
| [SCRUM-1638](https://maniservices.atlassian.net/browse/SCRUM-1638) | Tarea | Highest | Tareas por hacer | Daniel Ávila | OPS - Desplegar en PROD el front Flutter v1.0.4 y repetir las 18 rutas (T-01) |
| [SCRUM-1639](https://maniservices.atlassian.net/browse/SCRUM-1639) | Tarea | Highest | Tareas por hacer | Daniel Ávila | SEC - Retirar y rotar las contraseñas de VM publicadas en MANI-docs (T-02) |
| [SCRUM-1640](https://maniservices.atlassian.net/browse/SCRUM-1640) | Tarea | High | Tareas por hacer | Daniel Ávila | SEC - Cambiar o desactivar los usuarios semilla de PROD con clave QaSeed2026! (T-03) |
| [SCRUM-1641](https://maniservices.atlassian.net/browse/SCRUM-1641) | Tarea | Medium | Finalizada | Camila Beltrán | PO - Decidir el estado de Jardinería en PROD (T-04) |
| [SCRUM-1642](https://maniservices.atlassian.net/browse/SCRUM-1642) | Tarea | High | Tareas por hacer | Santiago Hernández | QA - Re-probar SCRUM-1633 en QA con el Core actual y cerrar (T-05) |
| [SCRUM-1643](https://maniservices.atlassian.net/browse/SCRUM-1643) | Historia | High | Tareas por hacer | Nicolás León | FRONT - Errores por código MANI-XXX-NNN con «Código · Ref» en todo estado de error (T-06) |
| [SCRUM-1644](https://maniservices.atlassian.net/browse/SCRUM-1644) | Historia | High | Tareas por hacer | José Nicolás Álvarez | FRONT - Sondeo de estado en cotización, estado del servicio y ejecución, SCRUM-1636 (T-07) |
| [SCRUM-1645](https://maniservices.atlassian.net/browse/SCRUM-1645) | Historia | Medium | Tareas por hacer | Nicolás León | UX - Etapa 1: arranque con marca, metadatos, fuentes empaquetadas y caché (T-08) |
| [SCRUM-1646](https://maniservices.atlassian.net/browse/SCRUM-1646) | Historia | Medium | Tareas por hacer | Nicolás León | UX - Etapa 2: tokens unificados, gesto de botón, transiciones y estados vacíos (T-09) |
| [SCRUM-1647](https://maniservices.atlassian.net/browse/SCRUM-1647) | Historia | Low | Tareas por hacer | Nicolás León | UX - Etapa 3: inicio por rol, entrada por rol desde la landing, carga diferida y accesibilidad (T-10) |
| [SCRUM-1648](https://maniservices.atlassian.net/browse/SCRUM-1648) | Tarea | Low | Tareas por hacer | Camila Beltrán | FRONT - Migrar botones y campos al sistema de diseño ManiButton / ManiTextField (T-11) |
| [SCRUM-1649](https://maniservices.atlassian.net/browse/SCRUM-1649) | Tarea | Low | Tareas por hacer | Camila Beltrán | FRONT - Configuración de Flutter en runtime: misma imagen en DEV, QA y PROD (T-12) |
| [SCRUM-1650](https://maniservices.atlassian.net/browse/SCRUM-1650) | Tarea | Low | Tareas por hacer | Camila Beltrán | FRONT - Confirmación en cerrar sesión y desactivar categoría (T-13) |
| [SCRUM-1651](https://maniservices.atlassian.net/browse/SCRUM-1651) | Tarea | Highest | Tareas por hacer | Nicolás León | BACK - Pool de Core configurable y timeouts de Dispatch alineados (T-14) |
| [SCRUM-1652](https://maniservices.atlassian.net/browse/SCRUM-1652) | Tarea | High | Tareas por hacer | Juan Sebastián Álvarez | BACK - Optimizar eligible-allies: perfilar los 2,6 s sin carga (T-15) |
| [SCRUM-1653](https://maniservices.atlassian.net/browse/SCRUM-1653) | Tarea | High | Tareas por hacer | Nicolás León | BACK - Idempotencia en pagos: misma clave con otro cuerpo devuelve 409 (T-16) |
| [SCRUM-1654](https://maniservices.atlassian.net/browse/SCRUM-1654) | Tarea | Medium | Tareas por hacer | Juan Sebastián Álvarez | BACK - Cancelar dos veces una solicitud devuelve 409 (T-17) |
| [SCRUM-1655](https://maniservices.atlassian.net/browse/SCRUM-1655) | Tarea | High | Tareas por hacer | Daniel Ávila | OPS - Rate limit (limit_req) en el Gateway NGINX (T-18) |
| [SCRUM-1656](https://maniservices.atlassian.net/browse/SCRUM-1656) | Tarea | Medium | Tareas por hacer | Nicolás León | BACK - Inmutabilidad de evento_servicio y asignación registrada en tabla (T-19) |
| [SCRUM-1657](https://maniservices.atlassian.net/browse/SCRUM-1657) | Tarea | Medium | Tareas por hacer | Nicolás León | BACK - Actor y correlation ID en el 100 % de los cambios (T-20) |
| [SCRUM-1658](https://maniservices.atlassian.net/browse/SCRUM-1658) | Tarea | Medium | Tareas por hacer | Juan Sebastián Álvarez | BACK - Logs JSON con correlation ID en Core, Dispatch y Rules (T-21) |
| [SCRUM-1659](https://maniservices.atlassian.net/browse/SCRUM-1659) | Tarea | High | Tareas por hacer | Nicolás León | SEC - Corregir la política RLS de documento_legal (tenant_id IS NULL) (T-22) |
| [SCRUM-1660](https://maniservices.atlassian.net/browse/SCRUM-1660) | Tarea | Medium | Tareas por hacer | Juan Sebastián Álvarez | BACK - Retirar lecturas de Dispatch sobre tablas de Core, TEC-13a a c (T-23) |
| [SCRUM-1661](https://maniservices.atlassian.net/browse/SCRUM-1661) | Tarea | Medium | Tareas por hacer | Juan Sebastián Álvarez | BACK - Escribir los 22 contratos OpenAPI faltantes y correr contract tests (T-24) |
| [SCRUM-1662](https://maniservices.atlassian.net/browse/SCRUM-1662) | Tarea | Medium | Tareas por hacer | Nicolás León | BACK - Adaptadores con falla inyectable (notificaciones y Storage KYC) con reintento y compensación (T-25) |
| [SCRUM-1663](https://maniservices.atlassian.net/browse/SCRUM-1663) | Tarea | Low | Tareas por hacer | Juan Sebastián Álvarez | BACK - Circuit breaker en Core (opossum), Dispatch (Polly) y Rules (resilience4j) (T-26) |
| [SCRUM-1664](https://maniservices.atlassian.net/browse/SCRUM-1664) | Tarea | Medium | Tareas por hacer | Santiago Hernández | QA - Inventario de operaciones críticas y un negativo Newman por cada una (T-27) |
| [SCRUM-1665](https://maniservices.atlassian.net/browse/SCRUM-1665) | Historia | High | Tareas por hacer | Daniel Ávila | OPS - Dominio público, TLS 443 y redirección HTTP a HTTPS (T-28) |
| [SCRUM-1666](https://maniservices.atlassian.net/browse/SCRUM-1666) | Historia | High | Tareas por hacer | Daniel Ávila | OPS - Respaldo automático diario y simulacro de restauración (T-29) |
| [SCRUM-1667](https://maniservices.atlassian.net/browse/SCRUM-1667) | Tarea | High | Tareas por hacer | Daniel Ávila | OPS - Versionar el stack de monitoreo en un repositorio (T-30) |
| [SCRUM-1668](https://maniservices.atlassian.net/browse/SCRUM-1668) | Tarea | High | Tareas por hacer | Daniel Ávila | OPS - Retención de Prometheus a 35 días (T-31) |
| [SCRUM-1669](https://maniservices.atlassian.net/browse/SCRUM-1669) | Historia | High | Tareas por hacer | Daniel Ávila | OPS - Alertmanager, canal de aviso y alertas de umbral (T-32) |
| [SCRUM-1670](https://maniservices.atlassian.net/browse/SCRUM-1670) | Tarea | Medium | Tareas por hacer | Juan Sebastián Álvarez | OPS - Métricas de Dispatch (prometheus-net) y Rules (Micrometer/Actuator) (T-33) |
| [SCRUM-1671](https://maniservices.atlassian.net/browse/SCRUM-1671) | Tarea | Medium | Tareas por hacer | Daniel Ávila | OPS - Exporters de base, contenedores, VM y NGINX (T-34) |
| [SCRUM-1672](https://maniservices.atlassian.net/browse/SCRUM-1672) | Tarea | Medium | Tareas por hacer | Daniel Ávila | OPS - Límites de CPU y memoria en el Compose de QA, versionado (T-35) |
| [SCRUM-1673](https://maniservices.atlassian.net/browse/SCRUM-1673) | Tarea | Medium | Tareas por hacer | Daniel Ávila | OPS - Monitorear PROD (T-36) |
| [SCRUM-1674](https://maniservices.atlassian.net/browse/SCRUM-1674) | Tarea | Medium | Tareas por hacer | Daniel Ávila | OPS - Despliegue automatizado o script versionado y cronometrado (T-37) |
| [SCRUM-1675](https://maniservices.atlassian.net/browse/SCRUM-1675) | Tarea | Medium | Tareas por hacer | Daniel Ávila | OPS - Simulacro cronometrado de rollback en QA, máximo 5 min (T-38) |
| [SCRUM-1676](https://maniservices.atlassian.net/browse/SCRUM-1676) | Historia | Low | Tareas por hacer | Daniel Ávila | OPS - Logs centralizados y trazas distribuidas (T-39) |
| [SCRUM-1677](https://maniservices.atlassian.net/browse/SCRUM-1677) | Epic | Low | Tareas por hacer | Daniel Ávila | OPS - Épica post-MVP: Kafka en PROD, clúster de 3 nodos, gestor de secretos y blue/green (T-40) |
| [SCRUM-1678](https://maniservices.atlassian.net/browse/SCRUM-1678) | Tarea | High | Tareas por hacer | Santiago Hernández | QA - Repetir QAS-01 y QAS-20 con los roles mani_core_svc y mani_dispatch_svc (T-41) |
| [SCRUM-1679](https://maniservices.atlassian.net/browse/SCRUM-1679) | Tarea | High | Tareas por hacer | Santiago Hernández | QA - Remedir QAS-03, 15 y 19 tras ampliar el pool y optimizar eligible-allies (T-42) |
| [SCRUM-1680](https://maniservices.atlassian.net/browse/SCRUM-1680) | Tarea | Medium | Tareas por hacer | Santiago Hernández | QA - Ejecutar el método de los escenarios de solo medición (T-43) |
| [SCRUM-1681](https://maniservices.atlassian.net/browse/SCRUM-1681) | Tarea | Medium | Tareas por hacer | Santiago Hernández | QA - Quality Gate de los 5 repos faltantes y PR de prueba que lo incumpla (T-44) |
| [SCRUM-1682](https://maniservices.atlassian.net/browse/SCRUM-1682) | Tarea | Low | Tareas por hacer | Santiago Hernández | QA - Pruebas de usabilidad con 3 a 5 personas por rol, QAS-30, 31 y 32 (T-45) |
| [SCRUM-1683](https://maniservices.atlassian.net/browse/SCRUM-1683) | Tarea | Medium | Tareas por hacer | Santiago Hernández | QA - Arnés k6 de aceptación concurrente sobre Dispatch real, QAS-07 y 41 (T-46) |
| [SCRUM-1684](https://maniservices.atlassian.net/browse/SCRUM-1684) | Tarea | High | Tareas por hacer | Camila Beltrán | PO - Acta de decisión A/B por escenario de calidad (T-47) |
| [SCRUM-1685](https://maniservices.atlassian.net/browse/SCRUM-1685) | Tarea | Medium | Tareas por hacer | Sara Albarracín | ARQ - Reescribir SDD §7 y §8 en los escenarios con opción B (T-48) |
| [SCRUM-1686](https://maniservices.atlassian.net/browse/SCRUM-1686) | Tarea | Medium | Tareas por hacer | Sara Albarracín | DOC - Actualizar SDD §8, Infraestructura V4 §7 y Excel de estado a 82/84 (T-49) |
| [SCRUM-1687](https://maniservices.atlassian.net/browse/SCRUM-1687) | Tarea | Medium | En curso | Camila Beltrán | PO - Decisiones pendientes de producto: baja de sedes, preguntas de pagos, HU-M04-05 y acta 1470 (T-50) |
| [SCRUM-1688](https://maniservices.atlassian.net/browse/SCRUM-1688) | Tarea | High | Tareas por hacer | Daniel Ávila | OPS - Reemitir el informe de DevOps con evidencia por servicio y ambiente (T-51) |
| [SCRUM-1689](https://maniservices.atlassian.net/browse/SCRUM-1689) | Historia | High | Tareas por hacer | Camila Beltrán | WIKI - Carpeta 01-producto: orden, estructura, responsabilidades y finalidad (HU-WIKI-01) |
| [SCRUM-1690](https://maniservices.atlassian.net/browse/SCRUM-1690) | Historia | High | Tareas por hacer | Sara Albarracín | WIKI - Carpeta 02-arquitectura: orden, estructura, responsabilidades y finalidad (HU-WIKI-02) |
| [SCRUM-1691](https://maniservices.atlassian.net/browse/SCRUM-1691) | Historia | High | Tareas por hacer | Daniel Ávila | WIKI - Crear carpeta 08-infraestructura: orden, estructura, responsabilidades y finalidad (HU-WIKI-03) |
| [SCRUM-1692](https://maniservices.atlassian.net/browse/SCRUM-1692) | Historia | High | Tareas por hacer | Santiago Hernández | WIKI - Carpeta 07-calidad: orden, estructura, responsabilidades y finalidad (HU-WIKI-04) |
| [SCRUM-1693](https://maniservices.atlassian.net/browse/SCRUM-1693) | Historia | Medium | Tareas por hacer | Juan Sebastián Álvarez | WIKI - Carpeta 03-repositorios: orden, estructura, responsabilidades y finalidad (HU-WIKI-05) |
| [SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694) | Historia | Medium | Tareas por hacer | José Nicolás Álvarez | WIKI - Carpeta 04-proceso: orden, estructura, responsabilidades y finalidad (HU-WIKI-06) |
| [SCRUM-1695](https://maniservices.atlassian.net/browse/SCRUM-1695) | Historia | Medium | Tareas por hacer | Nicolás León | WIKI - Carpeta 05-backlog: orden, estructura, responsabilidades y finalidad (HU-WIKI-07) |
| [SCRUM-1696](https://maniservices.atlassian.net/browse/SCRUM-1696) | Historia | High | Tareas por hacer | Sara Albarracín | VAL - Validar los puntos en que los documentos no concuerdan (HU-VAL-01) |
| [SCRUM-1697](https://maniservices.atlassian.net/browse/SCRUM-1697) | Tarea | High | Tareas por hacer | José Nicolás Álvarez | FRONT - Botón «Pagar» según el estado de la solicitud, SCRUM-1633 (T-52) |
| [SCRUM-1698](https://maniservices.atlassian.net/browse/SCRUM-1698) | Tarea | High | Tareas por hacer | José Nicolás Álvarez | QA - Reproducir SCRUM-1636 y registrar pantallas y cuentas antes de implementar el sondeo (T-53) |
| [SCRUM-1699](https://maniservices.atlassian.net/browse/SCRUM-1699) | Tarea | High | Tareas por hacer | Daniel Ávila | SEC - SCRUM-1383: decidir el cifrado de datos sensibles y dejar el ADR (T-54) |
| [SCRUM-1700](https://maniservices.atlassian.net/browse/SCRUM-1700) | Tarea | Medium | Tareas por hacer | Sara Albarracín | ARQ - ADR del tenant de clientes, SCRUM-1637 (T-55) |
| [SCRUM-1701](https://maniservices.atlassian.net/browse/SCRUM-1701) | Tarea | Medium | Tareas por hacer | José Nicolás Álvarez | DOC - Documentar el módulo M-04: cotización y ejecución, 865 a 870 y 872 (T-56) |
| [SCRUM-1702](https://maniservices.atlassian.net/browse/SCRUM-1702) | Tarea | Low | Tareas por hacer | José Nicolás Álvarez | DOC - Documentar la cola offline de evidencias, 873 (T-57) |
| [SCRUM-1703](https://maniservices.atlassian.net/browse/SCRUM-1703) | Tarea | Low | Tareas por hacer | José Nicolás Álvarez | DOC - Documentar alerta de tarifa (866) y contratos con proveedores externos (1240) (T-58) |
| [SCRUM-1704](https://maniservices.atlassian.net/browse/SCRUM-1704) | Tarea | Medium | Tareas por hacer | José Nicolás Álvarez | ARQ - ADR de la decisión 6A: asignación idempotente, 1620 (T-59) |
| [SCRUM-1705](https://maniservices.atlassian.net/browse/SCRUM-1705) | Tarea | Low | Tareas por hacer | José Nicolás Álvarez | DOC - Documentar menú, rutas y guardas por rol, 1444 a 1446 (T-60) |
| [SCRUM-1706](https://maniservices.atlassian.net/browse/SCRUM-1706) | Tarea | Low | Tareas por hacer | José Nicolás Álvarez | Pendientes menores de Nicolás Álvarez: enlaces de la 866, videos ES256 y limpieza de worktrees (T-61) |
| [SCRUM-1707](https://maniservices.atlassian.net/browse/SCRUM-1707) | Tarea | High | Tareas por hacer | Sara Albarracín | SM - Seguimiento de los acuerdos de la reunión de planning del Sprint 6 (T-62) |
| [SCRUM-1708](https://maniservices.atlassian.net/browse/SCRUM-1708) | Tarea | High | Tareas por hacer | Sara Albarracín | SM - Informe de cierre del Sprint 6: resultados, lecciones aprendidas y deuda abierta (T-63) |
| [SCRUM-1709](https://maniservices.atlassian.net/browse/SCRUM-1709) | Tarea | High | Tareas por hacer | Sara Albarracín | SM - Trazabilidad de bloqueos: registro, causa, responsable y tiempo de resolución (T-64) |
| [SCRUM-1710](https://maniservices.atlassian.net/browse/SCRUM-1710) | Tarea | High | Tareas por hacer | José Nicolás Álvarez | FRONT - Sondeo de estado en Mis solicitudes, pagos y calificación, SCRUM-1636 (T-65) |

## Los ítems de wiki

`SCRUM-1689` a `SCRUM-1695` son las siete historias de orden de carpeta de la wiki (HU-WIKI-01 a 07) y `SCRUM-1696` es `HU-VAL-01`, que recoge los puntos en que los documentos no concuerdan. La de esta carpeta es `SCRUM-1695`.

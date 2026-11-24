# Incremento de valor — versión 1.0.5

[Entrega final](README.md) · [Índice de la wiki](../../wiki/Home.md)

Este documento es el entregable 4 de la entrega final. Dice qué versión se entrega, dónde está cada pieza y qué trae de nuevo respecto a la anterior.

## 1. Versión entregada

Los siete repositorios tienen publicada la versión `v1.0.5`, el 24 de noviembre de 2026:

| Repositorio | Contenido | Versión |
|---|---|---|
| `MANI-APIGateway` | API Gateway (NGINX), Compose por ambiente, monitoreo y contratos OpenAPI | [v1.0.5](https://github.com/Trama-AS/MANI-APIGateway/releases/tag/v1.0.5) |
| `MANI-Node` | Core Service y la serie de migraciones | [v1.0.5](https://github.com/Trama-AS/MANI-Node/releases/tag/v1.0.5) |
| `MANI-.NET` | Dispatch Service | [v1.0.5](https://github.com/Trama-AS/MANI-.NET/releases/tag/v1.0.5) |
| `MANI-Java` | Rules Service | [v1.0.5](https://github.com/Trama-AS/MANI-Java/releases/tag/v1.0.5) |
| `MANI-Flutter` | Aplicación cliente, web y móvil | [v1.0.5](https://github.com/Trama-AS/MANI-Flutter/releases/tag/v1.0.5) |
| `MANI-Landing` | Página comercial | [v1.0.5](https://github.com/Trama-AS/MANI-Landing/releases/tag/v1.0.5) |
| `MANI-docs` | Documentación: wiki, ADR y diagramas | [v1.0.5](https://github.com/Trama-AS/MANI-docs/releases/tag/v1.0.5) |

La versión anterior verificada en PROD (14 de noviembre) era `v1.0.4` de Flutter Web ([`01-mapa-ambientes-y-versiones.md`](../../wiki/08-infraestructura/01-mapa-ambientes-y-versiones.md)).

## 2. Qué aporta el incremento

El producto funcional (registro y verificación de aliados, cobertura, solicitud y despacho, cotización, ejecución, calificación, mensajería y tarifario) se construyó hasta el Sprint 5, cuyo último día de desarrollo fue el 30 de octubre. El Sprint 6 (6 al 25 de noviembre) lo valida, lo endurece y lo documenta. Al 24 de noviembre cerró **95 de 103 ítems**, entre ellos estas **18 historias**:

| Historia | Qué entrega |
|---|---|
| [SCRUM-1383](https://maniservices.atlassian.net/browse/SCRUM-1383) | Cifrado de credenciales y de datos sensibles |
| [SCRUM-1644](https://maniservices.atlassian.net/browse/SCRUM-1644) | Sondeo de estado en la cotización, el estado del servicio y la ejecución |
| [SCRUM-1645](https://maniservices.atlassian.net/browse/SCRUM-1645) | Etapa 1 de UX: arranque con marca, metadatos, fuentes empaquetadas y caché |
| [SCRUM-1646](https://maniservices.atlassian.net/browse/SCRUM-1646) | Etapa 2 de UX: tokens unificados, gesto de botón, transiciones y estados vacíos |
| [SCRUM-1647](https://maniservices.atlassian.net/browse/SCRUM-1647) | Etapa 3 de UX: inicio por rol, entrada por rol desde la landing, carga diferida y accesibilidad |
| [SCRUM-1665](https://maniservices.atlassian.net/browse/SCRUM-1665) | Dominio público, TLS en el 443 y redirección de HTTP a HTTPS |
| [SCRUM-1666](https://maniservices.atlassian.net/browse/SCRUM-1666) | Respaldo automático diario y simulacro de restauración |
| [SCRUM-1669](https://maniservices.atlassian.net/browse/SCRUM-1669) | Alertmanager, canal de aviso y alertas de umbral |
| [SCRUM-1676](https://maniservices.atlassian.net/browse/SCRUM-1676) | Logs centralizados y trazas distribuidas |
| [SCRUM-1689](https://maniservices.atlassian.net/browse/SCRUM-1689) a [SCRUM-1695](https://maniservices.atlassian.net/browse/SCRUM-1695) y [SCRUM-1711](https://maniservices.atlassian.net/browse/SCRUM-1711) | Wiki ordenada por carpetas: producto, arquitectura, infraestructura, calidad, repositorios, proceso, backlog y gobernanza |
| [SCRUM-1696](https://maniservices.atlassian.net/browse/SCRUM-1696) | Validación de las 15 discrepancias entre documentos |

Además del trabajo de las historias, el sprint dejó el modelo C4 y el modelo de datos actualizados al sistema real, cinco decisiones de arquitectura ratificadas y el acta A/B de los escenarios de calidad firmada por la PO.

## 3. Cómo se acepta

Cada historia termina con QA ejecutado, un video en QA con token real y el visto bueno de la PO. El estado y la evidencia de cada una están en su ítem de Jira. El informe de cierre del Sprint 6 declara que algunos ítems se cerraron con la evidencia de QA pero sin el video de la PO ([`INFORME_CIERRE_SPRINT_6.md`](../../wiki/06-gobernanza/INFORME_CIERRE_SPRINT_6.md) §4.5), y el [acta de cierre](ACTA_DE_CIERRE.md) §6 lo recoge como riesgo aceptado.

## 4. Qué no incluye

Los escenarios de calidad que no se cumplen, las funcionalidades que siguen abiertas en Jira y los riesgos aceptados están en el [acta de cierre](ACTA_DE_CIERRE.md) §5 y §6 y en el [informe de proyecto](INFORME_DE_PROYECTO.md) §6.

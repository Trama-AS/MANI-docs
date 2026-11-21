# QAS-29: tabla ruta ↔ historia

Corte 2026-11-21. Fuente: contratos OpenAPI de `origin/develop` de MANI-APIGateway (`docs/openapi/core.yaml`, `core-internal.yaml`, `dispatch.yaml`, `rules.yaml`).

- Operaciones en los contratos: 141. Operativas (health y métricas), fuera del alcance de "endpoint productivo": 4.
- Productivas: 137. Con historia citada en el propio contrato: 109. Sin historia citada: 28, asociadas por QA abajo.
- Rutas productivas sin caso de uso identificable: **0**. Una asociación es inferida (`GET /catalog`).

## A. Rutas cuyo contrato no cita historia (asociación hecha por QA)

| Contrato | Operación | Referencia en el contrato | Historia asociada por QA |
|---|---|---|---|
| core | `POST /auth/register/ally` | — | SCRUM-846 (US-02.1.1), SCRUM-1372 (HU-M02-04) |
| core | `GET /solicitudes/categorias` | SCRUM-1465 | SCRUM-860 (US-04.1.1), SCRUM-1397 (HU-M05-01) |
| core | `GET /solicitudes/sitios` | SCRUM-1465 | SCRUM-860 (US-04.1.1), SCRUM-1397 (HU-M05-01) |
| core | `GET /profiles/me/unavailability` | — | SCRUM-855 (US-02.1.6), SCRUM-1386 (HU-M03-03) |
| core | `PATCH /profiles/me/unavailability/{absenceId}` | — | SCRUM-855, SCRUM-1386 |
| core | `DELETE /profiles/me/unavailability/{absenceId}` | — | SCRUM-855, SCRUM-1386 |
| core | `GET /profiles/me/inbox` | — | SCRUM-884 (US-05.1.4), SCRUM-1423 (HU-M09-01) |
| core | `GET /profiles/me/categories` | — | SCRUM-859 (US-03.1.3), SCRUM-1392 (HU-M04-03) |
| core | `PUT /profiles/me/categories` | — | SCRUM-859, SCRUM-1392 |
| core | `GET /profiles/me/categories/available` | — | SCRUM-859, SCRUM-1392 |
| core | `GET /profiles/me/coverage` | — | SCRUM-849 (US-02.1.4), SCRUM-1385 (HU-M03-02) |
| core | `PUT /profiles/me/coverage` | — | SCRUM-849, SCRUM-1385 |
| core | `GET /legal/documents/active` | — | SCRUM-856 (US-02.3.2) |
| core | `GET /catalog` | — | SCRUM-1069 (US-03.1.1-M2), inferida: vitrina publica de categorias |
| core | `GET /catalog/categories` | — | SCRUM-857 (US-03.1.1), SCRUM-1390 (HU-M04-01) |
| core | `GET /catalog/categories/{id}` | — | SCRUM-857, SCRUM-1390 |
| core | `PUT /catalog/categories/{id}` | — | SCRUM-857, SCRUM-1390 |
| core | `PATCH /catalog/categories/{id}/activate` | — | SCRUM-858 (US-03.1.2), SCRUM-1391 (HU-M04-02) |
| core | `GET /clients/{id}/sites` | — | SCRUM-852 (US-02.2.2), SCRUM-1387 (HU-M03-04) |
| core | `GET /catalog/zones/{id}` | — | SCRUM-1393 (HU-M04-04) |
| core | `POST /profiles/me/photo` | SCRUM-1629 | SCRUM-854 (US-02.3.1), SCRUM-1377 (HU-M02-09) |
| core-internal | `GET /allies/eligible/by-request/{id}` | SCRUM-1652 | SCRUM-1398 (HU-M05-02) |
| core-internal | `GET /allies/me` | — | SCRUM-1389 (HU-M03-06) |
| core-internal | `GET /notifications` | — | SCRUM-1402 (HU-M05-06) |
| dispatch | `POST /match` | SCRUM-1661 | SCRUM-861 (US-04.1.2), SCRUM-1398 (HU-M05-02) |
| rules | `POST /categories/evaluate` | — | SCRUM-1070 (US-03.1.1-M6) |
| rules | `POST /rates/evaluate` | — | SCRUM-886 (US-06.1.2), SCRUM-866 (US-04.2.2) |
| rules | `POST /tenant-rules/validate` | — | SCRUM-1366 (HU-M01-03) |

## B. Rutas con historia citada en el contrato

| Contrato | Operación | Historias citadas |
|---|---|---|
| core | `POST /auth/logout` | HU-M02-03, RF-03 |
| core | `POST /auth/password-recovery` | HU-M02-10, RF-04 |
| core | `POST /auth/password-reset` | HU-M02-10, RF-04 |
| core | `POST /auth/register/ally/company` | US-02.1.2-M2 |
| core | `POST /auth/register/client` | US-02.2.1-M2 |
| core | `POST /auth/register/client/company` | HU-M02-07 |
| core | `POST /allies/employees` | HU-M02-08, RF-05, SCRUM-1376, SCRUM-850 |
| core | `POST /solicitudes` | HU-M05-09, SCRUM-1405 |
| core | `GET /solicitudes/me` | HU-M07-04, SCRUM-871 |
| core | `GET /solicitudes/me/{id}` | HU-M07-04, SCRUM-871 |
| core | `PATCH /solicitudes/me/{id}/cancelar` | SCRUM-877, US-04.5.1 |
| core | `POST /solicitudes/{id}/cotizaciones` | RF-15, SCRUM-865, SCRUM-866, US-04.2.1 |
| core | `GET /solicitudes/{id}/cotizaciones` | SCRUM-865, US-04.2.1 |
| core | `POST /cotizaciones/{id}/aceptar` | RF-17, SCRUM-867, US-04.2.3 |
| core | `POST /cotizaciones/{id}/rechazar` | RF-17, SCRUM-867, US-04.2.3 |
| core | `POST /cotizaciones/{id}/ajustar` | RF-17, SCRUM-867, US-04.2.3 |
| core | `POST /solicitudes/{id}/iniciar` | RF-18, SCRUM-868, US-04.3.1 |
| core | `POST /solicitudes/{id}/finalizar` | RF-18, SCRUM-868, US-04.3.1 |
| core | `GET /solicitudes/{id}/ejecucion` | SCRUM-868, US-04.3.1 |
| core | `POST /solicitudes/{id}/eventos` | RF-18, SCRUM-869, SCRUM-873, US-04.3.2, US-04.3.6 |
| core | `GET /solicitudes/{id}/eventos` | SCRUM-869, SCRUM-873, US-04.3.2 |
| core | `GET /solicitudes/{id}/eventos/{eventoId}/evidencia` | RF-18, SCRUM-870, US-04.3.3 |
| core | `POST /solicitudes/{id}/adiciones` | RF-34, SCRUM-872, US-04.3.5 |
| core | `GET /solicitudes/{id}/adiciones` | SCRUM-1432, SCRUM-872, US-04.3.5 |
| core | `POST /adiciones/{id}/aceptar` | RF-34, SCRUM-872, US-04.3.5 |
| core | `POST /adiciones/{id}/rechazar` | RF-34, SCRUM-872, US-04.3.5 |
| core | `POST /pagos` | HU-M11-01, RF-24, SCRUM-1432 |
| core | `GET /pagos/aliado` | SCRUM-894, US-07.2.2 |
| core | `GET /pagos/comision` | SCRUM-1366, SCRUM-893, US-07.2.1 |
| core | `GET /pagos/{id}/retencion` | SCRUM-891, SCRUM-892, US-07.1.4, US-07.1.5 |
| core | `GET /pagos/{id}` | HU-M11-01, SCRUM-1432 |
| core | `GET /pagos/{id}/comprobante` | HU-M11-01, SCRUM-1432 |
| core | `GET /pagos/{id}/eventos` | HU-M11-03, SCRUM-889 |
| core | `GET /auditoria/transacciones` | HU-M11-03, SCRUM-889 |
| core | `POST /solicitudes/{id}/mensajes` | HU-M09-02, RF-20, SCRUM-881 |
| core | `GET /solicitudes/{id}/mensajes` | HU-M09-02, RF-20, SCRUM-881 |
| core | `POST /solicitudes/{id}/conversacion/consultas` | HU-M09-04, RF-21, SCRUM-883 |
| core | `GET /auditoria/consultas-conversacion` | HU-M09-04, SCRUM-883 |
| core | `POST /profiles/me/unavailability` | SCRUM-861 |
| core | `POST /profiles/me/categories` | SCRUM-1380 |
| core | `POST /catalog/categories` | SCRUM-1226, US-03.1.1-M6 |
| core | `PATCH /catalog/categories/{id}/deactivate` | US-03.1.2 |
| core | `POST /clients/{id}/sites` | RF-09 |
| core | `PATCH /clients/{id}/sites/{siteId}` | RF-09 |
| core | `GET /catalog/geometrias` | HU-M04-07 |
| core | `GET /catalog/zones` | HU-M04-04 |
| core | `POST /solicitudes/{id}/calificaciones` | SCRUM-1418, SCRUM-874, SCRUM-875 |
| core | `GET /solicitudes/{id}/calificaciones` | SCRUM-1418, SCRUM-874, SCRUM-875 |
| core | `POST /solicitudes/{id}/cerrar` | HU-M08-03, RF-19, SCRUM-1418 |
| core | `GET /aliados/calificaciones` | HU-M08-04, SCRUM-876, US-04.4.3 |
| core | `GET /aliados/{id}/calificacion` | SCRUM-876 |
| core | `GET /tenants/me/politica-cancelacion` | SCRUM-878 |
| core | `PUT /tenants/me/politica-cancelacion` | SCRUM-878 |
| core | `GET /solicitudes/me/{id}/cancelacion-preview` | SCRUM-878 |
| core | `GET /solicitudes/me/historial` | HU-M08-06, SCRUM-879, US-04.6.1 |
| core | `GET /allies/me/history` | HU-M08-07, SCRUM-880, US-04.6.2 |
| core | `GET /allies/me/history/{id}` | SCRUM-880 |
| core | `GET /tarifas` | HU-M10-01, SCRUM-885 |
| core | `POST /tarifas` | HU-M10-01, SCRUM-885 |
| core | `PUT /tarifas/{id}` | HU-M10-01, SCRUM-885 |
| core | `GET /tarifas/categorias/{categoriaId}/historial` | HU-M10-01, SCRUM-885 |
| core | `GET /solicitudes/{id}/tarifa-referencia` | HU-M10-02, SCRUM-886 |
| core | `GET /cotizaciones/{id}/evaluacion-tarifa` | HU-M06-02, RF-16, SCRUM-866, SCRUM-887 |
| core | `GET /reportes/cotizaciones-fuera-de-rango` | HU-M10-03, SCRUM-887 |
| core | `GET /tenant/rules` | HU-M01-03, SCRUM-1366 |
| core | `PUT /tenant/rules` | HU-M01-03, SCRUM-1366 |
| core | `GET /tenant/rules/history` | HU-M01-03, SCRUM-1366 |
| core | `POST /solicitudes/{id}/quejas` | HU-M12-01, SCRUM-895 |
| core | `GET /quejas/mias` | HU-M12-01, SCRUM-895 |
| core | `GET /quejas` | HU-M12-02, SCRUM-896 |
| core | `GET /quejas/{id}` | HU-M12-01 |
| core | `PATCH /quejas/{id}/estado` | HU-M12-02, SCRUM-896 |
| core | `GET /metricas/operativas` | HU-M12-06, SCRUM-900 |
| core | `GET /tenants` | HU-M12-07, SCRUM-1364 |
| core | `PATCH /tenants/{id}/estado` | HU-M12-07, SCRUM-901 |
| core | `GET /tenants/{id}/estado/historial` | HU-M12-07, SCRUM-901 |
| core | `GET /plataforma/contexto` | SCRUM-901 |
| core | `GET /tenants/{id}/usuarios` | SCRUM-901 |
| core | `GET /profiles/me` | SCRUM-1377 |
| core | `PATCH /profiles/me` | RF-422, SCRUM-1377 |
| core | `GET /aliados/verificacion` | SCRUM-1066, US-02.1.3-M2 |
| core | `GET /aliados/{id}/verificacion` | SCRUM-1066 |
| core | `PATCH /aliados/{id}/verificacion` | SCRUM-1066 |
| core | `GET /aliados/{id}/documentos/{documentoId}/url` | SCRUM-1066 |
| core | `GET /allies/me/historial` | SCRUM-880 |
| core | `GET /allies/me/historial/{id}` | SCRUM-880 |
| core | `GET /sites/{id}/rules` | SCRUM-853 |
| core | `PATCH /sites/{id}/rules` | SCRUM-853 |
| core | `PUT /sites/{id}/rules` | SCRUM-853 |
| core | `GET /sites/{id}/reglas` | SCRUM-853 |
| core | `PATCH /sites/{id}/reglas` | SCRUM-853 |
| core | `PUT /sites/{id}/reglas` | SCRUM-853 |
| core | `POST /sites/{id}/validate-schedule` | SCRUM-853 |
| core | `POST /legal/consents` | SCRUM-856, US-02.3.2 |
| core | `POST /clients/company` | SCRUM-852, US-02.2.2 |
| core | `POST /allies/direct-employees` | SCRUM-850 |
| core | `POST /admin/employees` | SCRUM-850 |
| core-internal | `GET /allies/eligible` | HU-M05-03, HU-M05-05, SCRUM-1398, SCRUM-1400 |
| core-internal | `GET /solicitudes/{id}/context` | HU-M05-04, SCRUM-1399 |
| core-internal | `POST /solicitudes/{id}/asignacion` | HU-M05-07, SCRUM-1403 |
| core-internal | `GET /allies/me/offers` | HU-M05-06, HU-M05-08, SCRUM-1402, SCRUM-1404 |
| core-internal | `POST /notifications` | HU-M05-07, SCRUM-1402 |
| dispatch | `GET /requests/{requestId}/eligible-allies` | HU-M05-03, HU-M05-05, SCRUM-1398, SCRUM-1400 |
| dispatch | `POST /requests/orchestrate` | HU-M05-07, SCRUM-1402, SCRUM-1405 |
| dispatch | `POST /requests/{requestId}/accept` | HU-M05-07, SCRUM-1403 |
| dispatch | `POST /requests/{requestId}/reject` | HU-M05-08, SCRUM-1404 |
| dispatch | `GET /offers/me` | HU-M05-06, HU-M05-08, SCRUM-1402, SCRUM-1404 |
| dispatch | `GET /assignments/me` | SCRUM-853 |
| rules | `POST /rank-allies` | RF-13 |

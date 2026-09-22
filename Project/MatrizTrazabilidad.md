# MANI — Matriz de Trazabilidad HU ↔ RNF ↔ ADR ↔ Componente ↔ PoC

SDD V1 · Sprint 2 · SCRUM-934 (DOC-03)

Alcance: RF-01 a RF-23 (MVP, EP-01..EP-06) — el mismo corte que `Product/DD-MANI.md` V4. RF-24..RF-28 (2º incremento) se listan aparte, sin diseñar (ver tabla al final).

Criterio de terminado del ticket: ninguna fila con celda vacía. Donde no existe evidencia de un ADR, Componente o PoC, la celda dice explícitamente "Sin evidencia registrada" en vez de quedar vacía.

## Matriz de Trazabilidad

| RF | Descripción RF | HU (Product Backlog) | Épica / Módulo | RNF relacionado(s) | ADR relacionado(s) | Estado ADR | Componente técnico | PoC / Validación | Estado PoC |
|---|---|---|---|---|---|---|---|---|---|
| RF-01 | Registrar y administrar tenants con aislamiento de datos | US-01.1.1 Registrar tenant | EP-01 / M-01 | RNF-01 (Aislamiento multi-tenant, Crítica) | Sin ADR propio (entidad Tenant sin decisión técnica dedicada) | No aplica | Backend Serverpod + Supabase PostgreSQL/RLS | Sin PoC registrado en Entregas/PoC/ | Pendiente |
| RF-02 | Configuración de reglas propias por tenant (documentos, orden, categorías, tarifas) | US-01.1.2 Configurar documentos por tipo de aliado · US-01.1.3 Configurar regla de posicionamiento | EP-01 / M-01 | RNF-02 (Configurabilidad, Crítica) · RNF-10 (KYC/tiempos configurables) | Sin ADR propio | No aplica | Backend Serverpod + Supabase Postgres (Tenant.config, CategoriaServicio, TarifaReferencia) | Sin PoC registrado | Pendiente |
| RF-03 | Autenticar usuarios y restringir acceso por tenant/rol | US-01.2.1 Login restringido al tenant | EP-01 / M-01 | RNF-01 (Aislamiento) · RNF-03 (Idempotencia, vía middleware) | ADR-0018 (Identificación/propagación de tenant) · ADR-0022 (Supabase Auth como IdP) | Aceptado (ambos) | Supabase Auth (IdP) + middleware JWT en cada servicio | Sin PoC ejecutado — suite Newman de ADR-0015 (6 casos) aún no corrida (ADR-0015 Propuesto) | Diseñada, no ejecutada |
| RF-04 | Recuperar contraseña de forma segura | US-01.2.2 Recuperar contraseña | EP-01 / M-01 | Sin RNF específico asociado en SRS | ADR-0022 (delegado a Supabase Auth) | Aceptado | Supabase Auth | Sin PoC registrado | Pendiente |
| RF-05 | Registrar aliados (persona natural, empresa, empleado directo) con documentos configurables | US-02.1.1 · US-02.1.2 · US-02.1.5 | EP-02 / M-02 | RNF-10 (Configurabilidad KYC) | ADR-0013 (Almacenamiento seguro de documentos KYC en Supabase Storage) | Aceptado | Backend Serverpod + Supabase Storage (bucket único, ruta tenant_id/aliado_id/…) | Sin PoC registrado (riesgo residual aceptado en KI-05, no medido) | Pendiente |
| RF-06 | Aprobar/rechazar registros de aliados | US-02.1.3 Aprobar/rechazar registro de aliado | EP-02 / M-02 | Sin RNF específico asociado | ADR-0013 (mismo mecanismo de storage/verificación) | Aceptado | Backend Serverpod (Aliado.estado_verificacion, DocumentoKYC) | Sin PoC registrado | Pendiente |
| RF-07 | Aliados declaran zona de cobertura (por zonas, no radio) | US-02.1.4 Declarar zona de cobertura | EP-02 / M-02 | RNF-09 (Cobertura por zonas, Alta) | ADR-0011 (Modelo de cobertura geográfica por zonas) | Aceptado | Backend Serverpod (CoberturaAliado, Zona — catálogo jerárquico ciudad→localidad→barrio) | Sin PoC registrado | Pendiente |
| RF-08 | Registrar clientes (persona natural / empresa, múltiples sitios) | US-02.2.1 · US-02.2.2 | EP-02 / M-03 | Sin RNF específico asociado | Sin ADR propio | No aplica | Backend Serverpod + Supabase Postgres (Cliente) | Sin PoC registrado | Pendiente |
| RF-09 | Reglas contextuales de sitio visibles al aliado | US-02.2.3 Reglas contextuales del sitio visibles al aliado | EP-02 / M-03 | Sin RNF específico asociado | ADR-0011 (mismo modelo de Sitio/Zona) | Aceptado | Backend Serverpod (Sitio) | Sin PoC registrado | Pendiente |
| RF-10 | Definir categorías de servicio por tenant, con flujo operativo | US-03.1.1 · US-03.1.2 | EP-03 / M-04 | RNF-02 (Configurabilidad) | Sin ADR propio | No aplica | Backend Serverpod (CategoriaServicio) | Sin PoC registrado | Pendiente |
| RF-11 | Asociar aliados a categorías que atienden | US-03.1.3 Aliado declara categorías que atiende | EP-03 / M-04 | Sin RNF específico asociado | Sin ADR propio | No aplica | Backend Serverpod (AliadoCategoria) | Sin PoC registrado | Pendiente |
| RF-12 | Crear solicitud y presentar aliados válidos por cobertura/categoría | US-04.1.1 Crear solicitud · US-04.1.2 Ver aliados válidos · US-04.1.3 Filtrar por tipo | EP-04 / M-05..M-08 | RNF-07 (Concurrencia en búsqueda, killer candidato KI-09 — sin cifra de volumen) | ADR-0011 (cobertura/zonas usada en el match) | Aceptado | Backend Serverpod (Solicitud, CoberturaAliado, AliadoCategoria) | Sin PoC registrado — KI-09 sigue sin cifra de volumen concurrente | Pendiente |
| RF-13 | Ordenar listado de aliados según regla configurada por tenant | US-04.1.5 Priorizar por comisión ofrecida | EP-04 / M-05..M-08 | Sin RNF específico asociado | Sin ADR propio | No aplica | Backend Serverpod (Solicitud — orden calculado, no persistido) | Sin PoC registrado | Pendiente |
| RF-14 | Aceptar/rechazar solicitud asignada, sin dobles asignaciones | US-04.1.4 Aceptar/rechazar solicitud | EP-04 / M-05..M-08 | RNF-03 (Idempotencia, Alta) · RNF-05 (Concurrencia en despacho, Alta) | ADR-0016 (Despacho simultáneo/broadcast, Propuesto — KI-10: faltan Redactor/Disenso/Quórum) · ADR-0021 (Exclusión concurrente, activado por ADR-0016; colisión de numeración con otro ADR-0021, ver hoja Gaps) | Propuesto (ambos) | Backend Serverpod (Solicitud.estado, Solicitud.aliado_id — UPDATE condicional atómico) | PoC-001 (SCRUM-926/959-964) — corrida r4-exclusion, N=50, 2026-09-21, Supabase/PostgreSQL 17.6 | Completada — cumple |
| RF-15 | Elaborar cotización con mano de obra y materiales separados | US-04.2.1 Cotización con mano de obra y materiales separados | EP-04 / M-05..M-08 | Sin RNF específico asociado | Sin ADR propio | No aplica | Backend Serverpod (Cotizacion) | Sin PoC registrado | Pendiente |
| RF-16 | Alertar cotización fuera de rango de tarifas | US-04.2.2 Alerta de tarifa bidireccional | EP-04 / M-05..M-08 | Sin RNF específico asociado | Sin ADR propio | No aplica | Backend Serverpod (Cotizacion, TarifaReferencia) | Sin PoC registrado | Pendiente |
| RF-17 | Cliente acepta, rechaza o ajusta cotización | US-04.2.3 Cliente acepta/rechaza/ajusta cotización | EP-04 / M-05..M-08 | Sin RNF específico asociado | Sin ADR propio | No aplica | Backend Serverpod (Cotizacion.estado, Cotizacion.version) | Sin PoC registrado | Pendiente |
| RF-18 | Registrar eventos y observaciones durante la ejecución (log) | US-04.3.1 Marcar inicio/fin · US-04.3.2 Registrar eventos · US-04.3.3 Consultar log | EP-04 / M-05..M-08 | RNF-04 (Auditabilidad, Alta) | Sin ADR propio | No aplica | Backend Serverpod (EventoServicio, tabla append-only) | Sin PoC registrado | Pendiente |
| RF-19 | Calificación bidireccional cliente-aliado al cierre | US-04.4.1 · US-04.4.2 · US-04.4.3 | EP-04 / M-05..M-08 | Sin RNF específico asociado | Sin ADR propio | No aplica | Backend Serverpod (Calificacion) | Sin PoC registrado | Pendiente |
| RF-20 | Mensajería cliente-aliado por servicio, con notificaciones | US-05.1.1 Mensajería cliente-aliado · US-05.1.2 Notificaciones de mensajes nuevos | EP-05 / M-09 | Sin RNF específico asociado | ADR-0017 (Mensajería/notificaciones en tiempo real — Supabase Realtime + FCM/APNs) | Propuesto, condicionado (KI-10) | Supabase Realtime (Broadcast) + FCM/APNs (Mensaje, Notificacion) | Sin PoC registrado | Pendiente |
| RF-21 | Consultar conversaciones de un servicio para atender quejas | US-05.1.3 Consultar conversación para atender queja | EP-05 / M-09 | Sin RNF específico asociado | ADR-0017 (mismo mecanismo) | Propuesto, condicionado | Supabase Realtime (Mensaje — consulta) | Sin PoC registrado | Pendiente |
| RF-22 | Mantener tabla de tarifas de referencia por categoría | US-06.1.1 Cargar tabla de tarifas · US-06.1.2 Ver tarifa de referencia | EP-06 / M-11 | Sin RNF específico asociado | Sin ADR propio | No aplica | Backend Serverpod + Supabase Postgres (TarifaReferencia) | Sin PoC registrado | Pendiente |
| RF-23 | Reportar cotizaciones fuera de rango por período | US-06.1.3 Reporte de cotizaciones fuera de rango | EP-06 / M-11 | Sin RNF específico asociado | Sin ADR propio | No aplica | Backend Serverpod (Cotizacion + TarifaReferencia — reporte de desviación) | Sin PoC registrado | Pendiente |

## Fuera de Alcance (2º incremento)

RF-24 a RF-28 — pagos, facturación, quejas, comercialización, administración avanzada. No diseñados en DD V4.

| RF | Descripción | Épica | Motivo de exclusión de este corte |
|---|---|---|---|
| RF-24 | Cobrar al cliente en línea vía operador certificado y registrar transacción | EP-07 | DD-MANI.md §12: depende del operador de pagos aún no seleccionado (SRS §8) y del cierre de RNF-06/RNF-11 — no diseñado en DD V4 |
| RF-25 | Liquidar al aliado descontando comisión configurable | EP-07 | Depende de RF-24 (pago) — 2º incremento, no diseñado |
| RF-26 | Registrar y gestionar quejas ligadas al servicio | EP-08 | 2º incremento, no diseñado en DD V4 |
| RF-27 | Consola de comercialización y publicación del tenant | EP-08 | 2º incremento, no diseñado en DD V4 |
| RF-28 | Métricas operativas por tenant y administración de estado de tenants | EP-08 | 2º incremento, no diseñado en DD V4 |

# MANI — Product Backlog V3

**Empresa:** TRAMA · Ingeniería de Software
**Documento:** Product Backlog V3 (Entrega 4)
**Fecha:** 2026-09-23
**Estado:** Borrador para refinamiento con el Product Owner
**Fuentes:** `Product/Product_Backlog.md`, SRS V3, `Project/MatrizTrazabilidad.md`,
`Project/Test/Inf_test-002.md`, `Entregas/Entrega4/Inf_PoC-001.md`, `Entregas/Spikes/README.md`,
DOC-14, SDD V1, Documento de Infraestructura V1

## Historial de versiones

| Versión | Entrega | Cambios |
| --- | --- | --- |
| V1 | Entrega 2 | Backlog inicial por épicas (formato INVEST). |
| V2 | Entrega 3 | Enablers de Sprint 1 (CFG-01.x) + historias de negocio EP-02..EP-08. |
| **V3** | Entrega 4 | Se agregan las historias de **EP-01** que ya usaba la matriz de trazabilidad (US-01.x). **Estado real** de cada historia del Sprint 2 (Jira + código). **Criterios de aceptación Gherkin** para las historias promovidas a QA (cierra parte de SCRUM-1055). Nuevas secciones: **PoC** (CFG-09/10/12/13), **documentación** (DOC-xx), **spikes de trade-offs** (SP-TO-xx), **deuda técnica y de proceso** (SCRUM-1051..1059) y **propuesta de Sprint 3**. Trazabilidad HU → RF. |

## Convenciones

| Campo | Valores |
| --- | --- |
| Tipo | HU (historia de usuario), Task, Spike, PoC, Doc, Deuda |
| Estado | ⬜ Por hacer · 🔵 En curso · 🟣 En revisión · ✅ Finalizada · ⚠️ Desalineado (Jira ≠ código) |
| Prioridad | Crítica / Alta / Media / Baja (heredada del RF, SRS V3) |
| Est. | Puntos de historia (Fibonacci), heredados del RF cuando la HU no tiene estimación propia |

> **Advertencia de alcance.** Los estados de Jira se toman de `Inf_test-002` (consulta del
> 2026-09-23). Los criterios Gherkin de §3 son **propuestos** para validación del PO; hasta que
> el PO los acepte, las historias no cumplen el DoR (ADR-0026 Propuesto).

---

## 1. Resumen por épica

| Épica | Módulo | RF | HU | En `develop`/`release` | Alcance |
| --- | --- | --- | :---: | :---: | --- |
| EP-01 Plataforma multi-tenant y acceso | M-01 | RF-01..04 | 5 | 0 (login vía EP-02) | MVP |
| EP-02 Registro y perfiles | M-02/03 | RF-05..09 | 11 | 5 | MVP |
| EP-03 Categorías | M-04 | RF-10, RF-11 | 3 | 2 | MVP |
| EP-04 Flujo core del servicio | M-05..08 | RF-12..19 | 20 | 2 | MVP |
| EP-05 Comunicación | M-09 | RF-20, RF-21 | 4 | 0 | MVP |
| EP-06 Tarifas | M-11 | RF-22, RF-23 | 3 | 0 | MVP |
| EP-07 Pagos | M-10 | RF-24, RF-25 | 7 | 0 | 2º incremento |
| EP-08 Soporte y métricas | M-12..14 | RF-26..28 | 7 | 0 | 2º incremento |
| Enablers | — | — | — | — | Transversal |

---

## 2. Historias de usuario

### EP-01 — Plataforma multi-tenant y acceso (nueva en V3)

| ID | Historia | RF | Prior. | Est. | Estado |
| --- | --- | --- | :---: | :---: | :---: |
| US-01.1.1 | **Como** Admin. de plataforma, **quiero** registrar una empresa como tenant, **para** que opere aislada desde el primer momento. | RF-01 | Crítica | 8 | ⬜ |
| US-01.1.2 | **Como** Admin. del tenant, **quiero** configurar qué documentos exijo por tipo de aliado, **para** adaptar el KYC a mi empresa sin desarrollo. | RF-02 | Crítica | 5 | ⬜ |
| US-01.1.3 | **Como** Admin. del tenant, **quiero** configurar la regla de posicionamiento del listado (cobertura, calificación o comisión), **para** priorizar según mi negocio. | RF-02, RF-13 | Crítica | 3 | ⬜ |
| US-01.2.1 | **Como** usuario, **quiero** iniciar sesión indicando mi empresa, **para** acceder solo a los datos de mi tenant. | RF-03 | Crítica | 8 | ◐ login implementado en `features/auth`; resolución por slug pendiente |
| US-01.2.2 | **Como** usuario, **quiero** recuperar mi contraseña de forma segura, **para** no perder acceso. | RF-04 | Alta | 3 | ⬜ |

### EP-02 — Registro y perfiles

| ID | Historia (resumen) | RF | Jira | Estado Jira | Código | Estado real |
| --- | --- | --- | --- | --- | --- | :---: |
| US-02.1.1 | Registro aliado persona natural (con documentos) | RF-05 | SCRUM-846 | En revisión | PR #14 en `develop` | ⚠️ |
| US-02.1.2 | Registro aliado empresa (Cámara de Comercio) | RF-05 | SCRUM-847 | En revisión | PR #14 | ⚠️ |
| US-02.1.3 | Aprobar/rechazar registro de aliado | RF-06 | SCRUM-848 | Finalizada | `d9c6ef8` (commit directo) | ◐ bandeja incompleta (SDD B-03) |
| US-02.1.4 | Declarar zona de cobertura | RF-07 | SCRUM-849 | Finalizada | `d9c6ef8` | ✅ (sin criterios) |
| US-02.1.5 | Registrar empleado directo | RF-05 | — | — | — | ⬜ |
| US-02.1.6 | Aliado gestiona su disponibilidad | RF-14 (apoyo) | — | — | — | ⬜ |
| US-02.2.1 | Registro cliente persona natural | RF-08 | SCRUM-851 | En revisión | PR #14 | ⚠️ |
| US-02.2.2 | Cliente empresa con múltiples sitios | RF-08 | — | — | — | ⬜ |
| US-02.2.3 | Reglas contextuales del sitio visibles al aliado | RF-09 | — | — | — | ⬜ |
| US-02.3.1 | Editar perfil propio | RF-05/08 | — | — | — | ⬜ |
| US-02.3.2 | Aceptación de Términos y Habeas Data (Ley 1581) | RF-05/08 | — | — | — | ⬜ |

Texto completo de cada historia: `Product/Product_Backlog.md` (sin cambios de redacción).

### EP-03 — Categorías

| ID | Historia | RF | Jira | Estado Jira | Código | Estado real |
| --- | --- | --- | --- | --- | --- | :---: |
| US-03.1.1 | Crear categoría con flujo operativo | RF-10 | SCRUM-857 | Finalizada | PR #18 | ✅ (única con criterios G/W/T) |
| US-03.1.2 | Desactivar categoría sin afectar servicios en curso | RF-10 | — | — | — | ⬜ |
| US-03.1.3 | Aliado declara categorías que atiende | RF-11 | SCRUM-859 | En curso (subtareas 1016–1021 "por hacer") | PR #19 | ⚠️ |

### EP-04 — Flujo core del servicio

| ID | Historia | RF | Jira | Estado real |
| --- | --- | --- | --- | :---: |
| US-04.1.1 | Crear solicitud (fotos y descripción) | RF-12 | SCRUM-860 (En revisión) | ⚠️ PR #22 en `develop` |
| US-04.1.2 | Ver aliados válidos por cobertura y categoría (**paginado**, PoC-004 H-03) | RF-12 | — | ⬜ |
| US-04.1.3 | Filtrar por tipo de aliado | RF-12 | — | ⬜ |
| US-04.1.4 | Aceptar/rechazar solicitud sin doble asignación | RF-14 | SCRUM-863 (En revisión) | ⚠️ PR #21; RPC validada por PoC-001; app con datasource en memoria |
| US-04.1.5 | Priorizar por comisión ofrecida | RF-13 | — | ⬜ |
| US-04.2.1 | Cotización con mano de obra y materiales | RF-15 | — | ⬜ |
| US-04.2.2 | Alerta de tarifa bidireccional | RF-16 | — | ⬜ |
| US-04.2.3 | Cliente acepta/rechaza/ajusta cotización | RF-17 | — | ⬜ |
| US-04.3.1 | Marcar inicio/fin de ejecución | RF-18 | — | ⬜ |
| US-04.3.2 | Registrar eventos durante la ejecución | RF-18 | — | ⬜ |
| US-04.3.3 | Cliente consulta el log del servicio | RF-18 | — | ⬜ |
| US-04.3.4 | Rastreo del aliado en vivo | — | — | 🚫 **Fuera de alcance del MVP** (SRS §1.2: geolocalización en tiempo real descartada) |
| US-04.3.5 | Adición por imprevisto | RF-17 | — | ⬜ |
| US-04.3.6 | Evidencias sin conexión (offline) | RF-18 | — | ⬜ |
| US-04.4.1 | Cliente califica al aliado | RF-19 | — | ⬜ |
| US-04.4.2 | Aliado califica al cliente | RF-19 | — | ⬜ |
| US-04.4.3 | Calificación agregada en el listado | RF-13, RF-19 | — | ⬜ |
| US-04.5.1 | Cancelar solicitud antes de la ejecución | RF-14 | — | ⬜ |
| US-04.5.2 | Penalización por cancelación tardía | RF-25 | — | ⬜ (depende de pagos, 2º incremento) |
| US-04.6.1 | Historial de servicios del cliente | RF-18 | — | ⬜ |
| US-04.6.2 | Historial de trabajos del aliado | RF-18 | — | ⬜ |

### EP-05 — Comunicación

| ID | Historia | RF | Estado |
| --- | --- | --- | :---: |
| US-05.1.1 | Mensajería cliente–aliado por servicio | RF-20 | ⬜ |
| US-05.1.2 | Notificaciones de mensajes nuevos | RF-20 | ⬜ |
| US-05.1.3 | Consultar conversación para atender queja | RF-21 | ⬜ |
| US-05.1.4 | Notificaciones push del ciclo del servicio | RF-20 | ⬜ |

### EP-06 — Tarifas

| ID | Historia | RF | Estado |
| --- | --- | --- | :---: |
| US-06.1.1 | Cargar tabla de tarifas por categoría | RF-22 | ⬜ |
| US-06.1.2 | Ver tarifa de referencia al cotizar | RF-22, RF-16 | ⬜ |
| US-06.1.3 | Reporte de cotizaciones fuera de rango | RF-23 | ⬜ |

### EP-07 — Pagos (2º incremento)

US-07.1.1 Pago en línea · US-07.1.2 Audit log inmutable · US-07.1.3 Soporte de pago ·
US-07.1.4 Escrow · US-07.1.5 Liberación automática · US-07.2.1 Liquidación con comisión ·
US-07.2.2 Detalle de pagos del aliado. Todas ⬜; bloqueadas por la selección del operador de
pagos (SRS §3.2).

### EP-08 — Soporte y métricas (2º incremento)

US-08.1.1 Queja del cliente · US-08.1.2 Bandeja de quejas · US-08.1.3 Resolución de disputa ·
US-08.2.1 Publicación en redes · US-08.2.2 Campañas · US-08.3.1 Métricas por tenant ·
US-08.3.2 Estado de tenants. Todas ⬜.

---

## 3. Criterios de aceptación propuestos (historias promovidas a QA)

Formato BDD. Cada criterio incluye caso positivo, negativo e intento de violar la regla
crítica (DoR de SCRUM-945 / ADR-0026). **Pendientes de validación del PO.**

### US-02.1.1 / US-02.1.2 — Registro de aliado

```gherkin
Escenario: Registro exitoso de aliado persona natural
  Dado un tenant activo que exige "cédula" y "antecedentes" para persona natural
  Cuando el aliado completa el formulario y adjunta ambos documentos
  Entonces el aliado queda con estado_verificacion "PENDIENTE"
  Y los documentos quedan en la ruta <tenant_id>/<uid>/ del bucket kyc-documentos

Escenario: Falta un documento exigido
  Dado un tenant que exige "cédula" y "antecedentes"
  Cuando el aliado adjunta solo la cédula
  Entonces el registro se rechaza indicando el documento faltante

Escenario: Intento de leer documentos de otro aliado (regla crítica REST-02)
  Dado dos aliados A y B del mismo tenant con documentos cargados
  Cuando A solicita el documento de B
  Entonces el sistema no devuelve el archivo
```

### US-02.1.3 — Aprobar/rechazar aliado

```gherkin
Escenario: Admin aprueba un aliado pendiente
  Dado un aliado con estado "PENDIENTE" en mi tenant
  Cuando el admin del tenant lo aprueba
  Entonces el estado pasa a "VERIFICADO" y el aliado ve el resultado

Escenario: Un aliado intenta aprobarse a sí mismo (regla crítica de rol)
  Dado un usuario con rol aliado
  Cuando invoca la verificación sobre su propio registro
  Entonces recibe 403 y el estado no cambia

Escenario: Admin de otro tenant
  Dado un aliado del tenant T1
  Cuando el admin del tenant T2 intenta verlo o aprobarlo
  Entonces no lo encuentra (404)
```

### US-02.1.4 — Declarar zona de cobertura

```gherkin
Escenario: Declaración de localidades
  Dado un aliado verificado
  Cuando selecciona las localidades "Chapinero" y "Usaquén"
  Entonces quedan guardadas como su cobertura y se usan en la búsqueda de aliados válidos

Escenario: Zona desactivada
  Dada una zona desactivada en el catálogo
  Cuando el aliado busca zonas
  Entonces esa zona no aparece como seleccionable

Escenario: Intento de declarar radio o coordenadas (REST-01)
  Cuando el aliado intenta enviar un radio o coordenadas
  Entonces el sistema no ofrece esa opción ni la acepta
```

### US-03.1.3 — Aliado declara categorías

```gherkin
Escenario: Asociar categorías activas
  Dado un aliado verificado y las categorías activas "Plomería" y "Cerrajería"
  Cuando las selecciona
  Entonces queda asociado a ambas

Escenario: Categoría inactiva
  Dada la categoría "Pintura" inactiva
  Cuando el aliado intenta asociarla
  Entonces el sistema la rechaza

Escenario: Categoría de otro tenant (RNF-01)
  Cuando el aliado envía el id de una categoría de otro tenant
  Entonces el sistema la rechaza y no se crea la relación
```

### US-04.1.1 — Crear solicitud

```gherkin
Escenario: Solicitud desde un sitio con zona
  Dado un cliente con un sitio que tiene zona asignada
  Cuando crea una solicitud con categoría, descripción y fotos
  Entonces la solicitud queda "PENDIENTE" y visible para los aliados válidos

Escenario: Sitio sin zona (RF-09)
  Dado un sitio sin zona
  Cuando el cliente intenta crear una solicitud desde él
  Entonces el sistema la rechaza

Escenario: Reintento con la misma Idempotency-Key (RNF-03)
  Cuando el cliente envía dos veces la misma solicitud con la misma clave
  Entonces existe una sola solicitud
```

### US-04.1.4 — Aceptar/rechazar sin doble asignación

```gherkin
Escenario: Primera aceptación gana
  Dada una solicitud "PENDIENTE" enviada a 50 aliados válidos
  Cuando los 50 aceptan simultáneamente
  Entonces exactamente 1 recibe 200 y la solicitud queda "ASIGNADA" a él
  Y los otros 49 reciben 409 "ya_no_disponible"

Escenario: Reintento del ganador
  Dado que el aliado A ya fue asignado
  Cuando A reintenta aceptar
  Entonces recibe 200 con el mismo resultado y no se crea un registro nuevo

Escenario: Un cliente intenta aceptar (regla crítica de rol, H-02)
  Dado un usuario con rol cliente del mismo tenant
  Cuando invoca aceptar sobre una solicitud pendiente
  Entonces recibe 403 y la solicitud sigue "PENDIENTE"
```

---

## 4. Enablers (ÉPICA 1 técnica)

| ID | Tarea | Tipo | Estado |
| --- | --- | --- | :---: |
| CFG-01.1 | Inicialización de repositorios | Task | ✅ |
| CFG-01.2 | Base de datos en Supabase | Task | ✅ (proyecto QA) |
| CFG-01.3 | Tablas, esquema y RLS básicas | Task | ◐ políticas sin versionar (SCRUM-1051) |
| CFG-01.4 | Proyecto Flutter base | Task | ✅ |
| CFG-01.5 | Supabase Auth | Task | ✅ |
| CFG-01.6 | CI/CD y linters | Task | ✅ (3 workflows por rama) |
| CFG-01.7 | Redacción del SAD | Task | ✅ V2 |
| CFG-04 | Seed QA multi-tenant (SCRUM-921) | Task | ✅ (normalizado por 007) |
| CFG-06 | Pruebas automatizadas en el pipeline | Task | ◐ reglas propuestas (Gobierno §2.3.1); brechas de rulesets |

### 4.1 Nuevos enablers propuestos (derivados de SDD V1 e Infraestructura V1)

| ID | Tarea | Origen | Prior. |
| --- | --- | --- | :---: |
| CFG-14 | Migración 008: políticas `tenant_isolation_*` versionadas con restricción de rol | KI-12, KI-13 | 🔴 Crítica |
| CFG-15 | Migración 010: promover hook de claims, bucket KYC y RPC de cobertura desde PoC | SDD B-04/B-05 | Alta |
| CFG-16 | Esqueleto del API Gateway (ruta `/api/v1/**` → Core mínimo, `/health`) | ADR-0027 (borrador) | Alta |
| CFG-17 | Esqueleto del Core Serverpod (`/tenants/resolve`, `/health`, `/metrics`) | ADR-0012 | Alta |
| CFG-18 | Esqueleto del Motor de Despacho .NET (`POST /solicitudes`, `/aceptar`) | ADR-0028 (borrador) | Alta |
| CFG-19 | Esqueleto del Motor de Reglas Java (`/reglas/ranking`) | ADR-0028 (borrador) | Media |
| CFG-20 | Cliente HTTP en Flutter (interceptor Bearer + `flutter_secure_storage`) | SDD B-08 | Alta |
| CFG-21 | Rulesets en `develop`/`release` + Environments `release` y `production` | Infra S-05 | Alta |
| CFG-22 | Manifiestos Kustomize + clúster k3d de referencia | ADR-0029 (borrador) | Media |
| CFG-23 | Newman + ZAP baseline automáticos en el workflow de `release` | QS-17, Infra S-07 | Media |
| CFG-24 | Publicación GHCR con tags `dev`/`staging` | Infra I-06 | Media |

---

## 5. Pruebas de concepto (Sprint 2)

| ID | Ticket | Pregunta | ADR | Resultado | Estado |
| --- | --- | --- | --- | --- | :---: |
| PoC-001 | CFG-09 / SCRUM-926 (959–964) | Exclusión concurrente en la aceptación | 0021, 0016 | 1/50, 0 dobles; control 10/50 | ✅ |
| PoC-002 | CFG-12 / SCRUM-929 (971) | Propagación de claims de tenant | 0018, 0022 | 100 %, 0 fugas, 4/4 suplantaciones | ✅ (informe sin merge en docs) |
| PoC-003 | CFG-13 / SCRUM-930 | Storage KYC y URLs firmadas | 0013 | p95 1180 ms / 423 ms; 95/95 | ✅ (informe sin merge en docs) |
| PoC-004 | CFG-10 / SCRUM-927 (965–970) | Cobertura geográfica | 0011 | Cumple solo con 2 índices | ✅ |
| Inf_PoC-001 | DOC-16 / SCRUM-952 | Informe consolidado | — | — | ✅ |

---

## 6. Documentación

| ID | Ticket | Entregable | Estado |
| --- | --- | --- | :---: |
| DOC-03 | SCRUM-934 | Matriz de trazabilidad HU ↔ RNF ↔ ADR ↔ Componente ↔ PoC | ✅ |
| DOC-08 | — | Topología de ambientes DEV/QA/PROD | ✅ Aprobada |
| DOC-14 | — | Mesa de Arquitectura 2026-09-22 (trade-offs con evidencia) | ✅ |
| DOC-15 | SCRUM-946 | SAD V2 — sección de infraestructura | ✅ (integrada en SAD V3 §10) |
| DOC-16 | SCRUM-952 | Informe consolidado de PoC | ✅ |
| — | SCRUM-953 | Informe de test Inf_test-001 | ✅ |
| — | SCRUM-932 | ADR-0024 Framework de modelado | ✅ Aprobado |
| — | SCRUM-945 | ADR-0025 DoD / ADR-0026 DoR | 🟣 Propuestos |
| — | Entrega 4 | SRS V3, Backlog V3, SAD V3, DD V2, SDD V1, Infraestructura V1, Herramientas V3 | 🟣 Este paquete |

---

## 7. Spikes de trade-offs (DOC-14)

| ID | Trade-off | Pregunta | h | Prioridad (D-06) | Estado |
| --- | --- | --- | :---: | :---: | :---: |
| SP-TO-06 | TO-06 | ¿Realtime autoriza el canal con el rol correcto? | 6 | 1 | ⬜ |
| SP-TO-03 | TO-03 | Saturación sostenida y caída de base sin cola | 8 | 2 | ⬜ |
| SP-TO-01 | TO-01 | Overhead de RLS en la búsqueda | 6 | 3 | ⬜ |
| SP-TO-05 | TO-05, TO-08 | Crecimiento de la suite y costo de CI | 4 | 4 | ⬜ |
| SP-TO-02 | TO-02 | Combinatoria de configuración vs aislamiento | 4 | Sprint 3 | ⬜ |
| SP-TO-04 | TO-04 | Huella de agentes de observabilidad | 5 | Sprint 3 | ⬜ |
| SP-TO-07 | TO-07 | Aprendizaje del admin. tenant | 6 | Sprint 3 | ⬜ |
| SP-TO-09 | TO-09 | Latencia del estilo distribuido (incluye gateway) | 6 | Sprint 3 | ⬜ |
| SP-TO-10 | TO-10 | Costo de salida de Supabase Auth | 4 | Sprint 3 | ⬜ |
| SP-TO-11 | TO-11 | Techo de escala de Railway (alimenta ADR-0029) | 5 | Sprint 3 | ⬜ |
| SP-TO-12 | TO-12 | Sincronización de artefactos visuales | 3 | Sprint 3 | ⬜ |

Total 57 h; corte propuesto para el sprint en curso: 24 h (SP-TO-06, 03, 01, 05).

---

## 8. Deuda técnica y de proceso

| Ticket | Descripción | Origen | Prior. | Estado |
| --- | --- | --- | :---: | :---: |
| SCRUM-1051 | 16 políticas `tenant_isolation_*` solo en QA, sin versionar | Inf_test-002 | 🔴 | ⬜ |
| SCRUM-1054 | 2 índices de cobertura para cumplir 50 ms a 100k | PoC-004 | Alta | ⬜ |
| SCRUM-1055 | Historias sin criterios de aceptación ni evidencia en Jira | Inf_test-002 §2.3 | Alta | 🔵 (§3 propone criterios) |
| SCRUM-1056 | PR sin revisión (#9, #14), commits directos a `develop`, protección de rama | Inf_test-002 §2.2 | Alta | ⬜ |
| SCRUM-1057 | Normalización de dominios en QA (migración 007) | Inf_test-002 §4.3 | — | ✅ |
| SCRUM-1058 | Brecha de proceso de la promoción (ver Inf_test-002) | Inf_test-002 | Media | ⬜ |
| SCRUM-1059 | Alinear scripts de poc-cfg09 con el dominio normalizado | Rama `fix/SCRUM-1059-alinear-poc-cfg09` | Media | 🔵 |
| (crear) | H-02: RLS sin restricción de rol en `solicitud` | PoC-001, DOC-14 D-03 | 🔴 | ⬜ |
| (crear) | Correcciones de texto de ADR-0013 (H-01, H-02, H-04) | PoC-003 | Media | ⬜ |
| (crear) | Regenerar `Product/DDL_MANI.sql` desde la cadena de migraciones | PoC-001 | Media | ⬜ |
| (crear) | Merge de PoC-002 y PoC-003 en MANI-docs (PR #6, #7) | Inf_PoC-001 | Baja | ⬜ |
| (crear) | Correcciones documentales D-01, D-02, D-06, D-08 | SDD V1 §15.3 | Baja | ⬜ |

---

## 9. Propuesta de Sprint 3 (para Planning)

Objetivo propuesto: **"Cerrar el aislamiento en el esquema versionado y levantar el primer
recorrido vertical detrás del gateway."**

| Orden | Ítem | Justificación |
| :---: | --- | --- |
| 1 | CFG-14 (migración 008 con rol) + H-02 | Riesgo crítico de seguridad; bloquea PROD |
| 2 | SCRUM-1054 (índices) + CFG-15 (promover PoC) | Cierra deuda con evidencia ya medida |
| 3 | SCRUM-1055 / 1056 | Condición del gate DEV→QA |
| 4 | SP-TO-06, SP-TO-03 | Prioridad 1 y 2 de DOC-14 |
| 5 | CFG-16, CFG-17, CFG-20 | Fase 2 del plan de migración del SDD |
| 6 | CFG-18 + US-04.1.4 conectada al backend real | Fase 3; quita el datasource en memoria |
| 7 | US-04.1.2 (aliados válidos paginados) | Siguiente historia crítica de RF-12 |
| 8 | CFG-21, CFG-23 | Gates automáticos (QS-17) |

Capacidad y compromiso final: a definir en Sprint Planning con el equipo (PROY-01).

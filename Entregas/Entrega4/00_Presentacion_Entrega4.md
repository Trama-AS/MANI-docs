# TRAMA · MANI — Presentación de la Entrega 4

**Proyecto:** MANI — Plataforma SaaS multi-tenant de formalización de operaciones de servicio
**Equipo:** TRAMA · Ingeniería de Software
**Hito:** Entrega 4 — Sprint 2 Review / Planning Sprint 3
**Fecha:** 2026-09-23

| Integrante | Rol principal | Segundo rol |
| --- | --- | --- |
| Nicolás León | Product Owner | DevOps |
| Sara Albarracín | Scrum Master | Frontend |
| Daniel Ávila Medina | DevOps | Backend |
| Santiago Hernández | QA & Security Testing Lead | Product Owner |
| Juan Sebastián Álvarez | Backend Lead | Frontend |
| Camila Beltrán | Frontend Lead | Scrum Master |
| Nicolás Álvarez | Frontend Lead | QA |

---

## 1. Qué contiene esta entrega

| # | Documento | Versión | Archivo | Qué cambia respecto de la entrega anterior |
| :-: | --- | :-: | --- | --- |
| 1 | Presentación de la Entrega | — | `00_Presentacion_Entrega4.md` | Este documento |
| 2 | Documento de Herramientas, Políticas y Lineamientos | **V3** | `Documento_Herramientas_Politicas_Lineamientos_V3.md` | Construido sobre V2.1 (se conserva completo, cambios con 🆕): retiro de Azure, Railway + GHCR, Kubernetes sin AKS, Tech Radar V3, DoR/DoD de ADR-0025/0026, políticas de PoC y de migraciones, estado de cumplimiento verificado |
| 3 | Documento de Requerimientos (SRS) | **V3** | `SRS_MANI_V3.md` | Evidencia de PoC en RNF-01/03/05/07; autorización por rol en RNF-01; listado paginado en RF-12; IdP resuelto; SUP-06 |
| 4 | Product Backlog | **V3** | `Backlog_V3.md` | Historias EP-01; estado real Jira vs código; criterios Gherkin; PoC, DOC, spikes, deuda; propuesta de Sprint 3 |
| 5 | Documento de Arquitectura (SAD) | **V3** | `SAD_V3.md` | Construido sobre el SAD V2 del repositorio (completo, cambios con 🆕): PoC-002..004, KI-12/KI-13, ADR-0025..0029, QS-21/22, Tabla E de evidencia, vistas 4+1 ↔ C4, vista física |
| 6 | Documento de Diseño (DD) | **V2** | `DD_V2.md` | Reparto por servicio, migraciones 001–010, RLS con rol, KYC corregido, índices, despliegue alineado con DOC-08; **incluye el Glosario de términos (§14)** |
| 7 | Documento de Infraestructura | **V1** | `Documento_Infraestructura_V1.md` | **Nuevo** — vista física: DEV/QA/PROD, seguridad por capas, secretos, Kubernetes, brechas |
| 8 | Documento de Diseño de Software (SDD) | **V1** | `SDD_V1.md` | **Nuevo** (sobre el borrador 0.1) — 4+1 realizado con C4, gateway, Java/.NET, validación con PoC y ADR |

> Nota de versión: la lista original de la entrega pedía "SAD V2". Por indicación del equipo,
> el SAD de esta entrega se publica como **V3**, construido sobre el SAD V2 que ya estaba en el
> repositorio (`Product/SAD-MANI.md` + `Product/SADV2.md`).

---

## 2. Los tres temas de esta entrega

### 2.1 SDD — Framework de modelado (4+1 | C4 model)

**Decisión vigente:** ADR-0024 (Aprobado) — framework híbrido: C4 para arquitectura de
software, UML para bajo nivel, BPMN para procesos, MER para datos.

**Cómo se combina con 4+1:** 4+1 define **qué vistas** debe cubrir la arquitectura; C4 y las
demás notaciones definen **cómo se dibuja** cada vista.

| Vista 4+1 | Realización | Dónde |
| --- | --- | --- |
| Escenarios (+1) | 22 escenarios de calidad + BPMN | SAD V3 §5, §7.5 |
| Lógica | C4 L1 Contexto + C4 L2 Contenedores + modelo de dominio + MER | SDD V1 §5 |
| Procesos | Secuencias UML: login/tenant, despacho concurrente, cotización | SDD V1 §6 |
| Desarrollo | C4 L3 Componentes, repositorios, Clean Architecture | SDD V1 §7 |
| Física | C4 Deployment + configuración por ambiente | Infraestructura V1 |

Fuente editable única: `Diagramas/c4/workspace-as-built.dsl` (Structurizr).

**Aportes nuevos del SDD V1:** API Gateway (Spring Cloud Gateway) y alcance concreto de Java
(Motor de Reglas por Tenant) y .NET (Motor de Despacho) — borradores **ADR-0027** y
**ADR-0028**.

### 2.2 PoC + ADR — Benchmarking, pruebas de concepto y ADR

Protocolo común: umbral publicado **antes** de medir, **control negativo** obligatorio,
evidencia cruda versionada, conclusión explícita para el ADR.

| PoC | Decisión | Resultado clave | Efecto en el ADR |
| --- | --- | --- | --- |
| PoC-001 Exclusión concurrente | ADR-0021 | 50 aceptaciones simultáneas → **1** asignación; control negativo → **10** en 136 ms | Propuesto → **Aceptar** |
| PoC-002 Claims de tenant | ADR-0018 | 100 % de propagación, 0 fugas, 4/4 suplantaciones rechazadas; firma ES256 p95 0,10 ms | Confirmado; el hook se implementó en la PoC |
| PoC-003 Storage KYC | ADR-0013 | Carga 1 MB p95 1180 ms; URL firmada p95 423 ms; 95/95 | Se sostiene con 3 correcciones |
| PoC-004 Cobertura | ADR-0011 | 100k aliados: 123,91 ms → **9,48 ms** con 2 índices; E2E 296 ms | Confirmado; exige índices |

**Benchmarking de alternativas:**
- Geográfico (PoC-004): PostGIS 7,17 ms / 100 % · bounding box 9,52 ms / 100 % · geohash
  8,35 ms / **93,78 %** → si algún día se resuelve la zona desde coordenadas, PostGIS; geohash
  descartado.
- API Gateway (SDD V1 §9.2): Spring Cloud Gateway vs YARP vs KrakenD CE vs Kong OSS vs Nginx vs
  sin gateway.
- Kubernetes (Infraestructura V1 §9.2): k3d/kind + Railway vs K3s en VM gratuita vs clúster
  gestionado vs solo Railway.

**Evidencia de los trade-offs (SAD V3 Tabla E):** de 12, 1 empírica, 3 parciales, 1 adversa,
3 documentales, 4 sin evidencia. 11 spikes abiertos (57 h).

**Hallazgo más importante:** la política RLS de `solicitud` aísla por tenant **pero no por
rol** (PoC-001 H-02 → KI-13). Un cliente puede autoasignarse una solicitud. Corrección
propuesta en DD V2 §8.1.

### 2.3 Vista física — Seguridad y configuración de ambientes Dev, QA y Prod

| | DEV | QA | PROD |
| --- | --- | --- | --- |
| Rama | `develop` | `release` | `main` |
| Cómputo | Docker Compose local | Railway Staging + zip de staging | Railway Production |
| Base de datos | `postgres:16-alpine` local | Supabase QA (migraciones 001–007) ✅ | Supabase PROD ⬜ |
| Gates | format, analyze, 313 tests, build | + migraciones, Newman (135/135), ZAP ⬜ | + SonarCloud Quality Gate ✅, aprobación de Environment ⬜ |
| Secretos | `.env` | GitHub Secrets | GitHub Environment `production` ⬜ |

**Seguridad por capas:** identidad (JWT con claims) → borde (gateway) → servicio (revalida JWT
y rol) → datos (RLS) → archivos (bucket privado + URL firmada) → red (TLS, red privada,
`NetworkPolicy`) → proceso (rulesets, Environments, Sonar, ZAP).

**Kubernetes (PROY-08):** propuesta ADR-0029 — Railway sirve QA/PROD del MVP; clúster
k3d/kind de referencia con las mismas imágenes y manifiestos Kustomize (base + overlays
dev/qa/prod).

**Brecha crítica:** las 16 políticas `tenant_isolation_*` solo existen en QA (KI-12). Ningún
ambiente nuevo (PROD) se aprovisiona hasta versionarlas (migración 008).

---

## 3. Estado del producto al cierre del Sprint 2

| Indicador | Valor | Fuente |
| --- | --- | --- |
| Historias con código integrado en `develop`/`release` | 9 (EP-02, EP-03, EP-04) | Inf_test-002 |
| Pruebas Flutter | 313 (18 de integración), cobertura de líneas 85,4 % | Inf_test-002 |
| Suites de aislamiento en QA | 135/135 aserciones | Inf_test-002 |
| Migraciones aplicadas por CI en QA | 001–007 | Inf_test-002 |
| PoC completadas | 4 de 4 | Inf_PoC-001 |
| ADR en la carpeta | 26 (18 Aceptados/Aprobados, 8 Propuestos) + 3 borradores | SAD V3 §3 |
| Gate DEV→QA | CI ✅ · revisión por pares ❌ · DoR ❌ (promovido con excepción) | Inf_test-002 |

---

## 4. Decisiones que pedimos a la Mesa

1. Ratificar numeración ADR-0021/0023 y pasar **ADR-0021** a Aceptado.
2. **KI-12 / KI-13:** migración 008 con RLS por rol antes de aprovisionar PROD.
3. **ADR-0013** (con correcciones) y **ADR-0015** a Aceptado.
4. Borradores **ADR-0027** (gateway), **ADR-0028** (Java/.NET), **ADR-0029** (Kubernetes).
5. Unificar el registro de imágenes en **GHCR**.
6. Aceptar **QS-21/QS-22** y priorizar los spikes (SP-TO-06, 03, 01, 05 primero).
7. Aprobar el Documento de Herramientas V3 (quórum 5/7).

---

## 5. Propuesta de objetivo de Sprint 3

> **"Cerrar el aislamiento en el esquema versionado y levantar el primer recorrido vertical
> detrás del gateway."**

Detalle y orden en `Backlog_V3.md` §9.

---

## 6. Declaración de uso de IA (ADR-0009)

Estos documentos se consolidaron con asistencia de IA a partir de los artefactos del
repositorio (`MANI-docs`, `MANI-Flutter`). No se introdujeron credenciales ni datos personales.
Todo lo marcado como 🟡 / borrador es una **propuesta** y no es decisión vigente hasta que la
Mesa de Arquitectura la ratifique (ADR-0003, PROY-05). Cada integrante responsable revisa su
sección antes de la sustentación.

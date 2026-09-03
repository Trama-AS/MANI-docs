# Perfil del Proyecto — MANI

**Empresa:** TRAMA · Ingeniería de Software
**Documento:** Perfil de Proyecto V1
**Fecha:** 2026-08-19
**Fuentes:** SRS_MANI.md, Analisis_de_Requerimientos.md, Product_Backlog_MANI.md,
Gobierno_del_Equipo.md, Matriz_de_Herramientas.md, ADR-0001..0003.
🔴 No incorpora aún ADR-0004..0006 (mismo 2026-08-19); ver notas en §4.4 y §7.

> 🔴 = sin dato disponible en la documentación actual del proyecto / pendiente de decisión
> del equipo. No se inventan cifras ni fechas que no existan en la carpeta.

---

## 1. Nombre del Proyecto

**MANI** — plataforma multi-tenant de formalización de operaciones de servicio.

---

## 2. Descripción y Problemática

El cliente opera (y quiere ofrecer a otras empresas del sector) un servicio que hoy
funciona de forma **informal**: coordinación por WhatsApp, llamadas y contactos, sin
trazabilidad ni auditabilidad operativa.

**Problemática:** no existe registro estructurado del ciclo solicitud → cotización →
ejecución → calificación → cierre. Esto impide auditar operaciones, estandarizar tarifas,
verificar aliados y escalar el negocio más allá del control manual.

**Doble naturaleza del negocio:** el cliente quiere (a) montar una empresa de plataforma
que sirva a terceros y (b) operar su propia empresa de servicios sobre esa misma
plataforma. Por eso MANI se diseña como **SaaS multi-tenant**: una única instancia sirve a
múltiples empresas (tenants) con datos, configuración y usuarios aislados entre ellas; la
empresa del cliente actual es el primer tenant.

MANI conecta **clientes** que solicitan un servicio con **aliados** (prestadores) que lo
cotizan y ejecutan, dejando trazabilidad de extremo a extremo hasta el cierre y
calificación.

---

## 3. Objetivos

### 3.1 Objetivo general

Formalizar digitalmente la operación de servicios del cliente mediante una plataforma
SaaS multi-tenant que soporte el ciclo completo solicitud–cotización–ejecución–
calificación–cierre, con trazabilidad operativa y configuración propia por empresa.

### 3.2 Objetivos específicos

- Implementar una plataforma multi-tenant con aislamiento estricto de datos, configuración
  y usuarios entre empresas (RF-01 a RF-04).
- Construir el directorio diferenciado de aliados (persona natural, empresa, empleado
  directo) y clientes (persona natural, empresa), con verificación configurable por tenant
  (RF-05 a RF-09).
- Habilitar el catálogo de categorías de servicio y la declaración de cobertura por zonas
  (RF-10, RF-11).
- Cubrir el ciclo del servicio de extremo a extremo: solicitud, cotización, ejecución,
  calificación y cierre, sin dobles asignaciones (RF-12 a RF-19).
- Proveer mensajería y notificaciones asociadas a cada servicio (RF-20, RF-21).
- Mantener un tarifario de referencia por categoría con alerta cuando una cotización se
  sale de rango (RF-22, RF-23).
- *(2º incremento, fuera de este corte)* Habilitar cobro, liquidación, gestión de quejas,
  comercialización y métricas operativas por tenant (RF-24 a RF-28).

---

## 4. Alcances y Limitaciones

### 4.1 Alcance del producto

- **MVP (este corte):** plataforma multi-tenant, directorio de actores, catálogo y
  cobertura, ciclo del servicio, comunicación y tarifario — Épicas EP-01 a EP-06.
- **Segundo incremento (fuera de este corte):** pagos y facturación, quejas,
  comercialización y administración avanzada — Épicas EP-07, EP-08.

### 4.2 Limitaciones del producto

- Cobertura de aliados por **zonas**, no por radio geográfico ni geolocalización en tiempo
  real (descartada).
- Fuera de alcance del MVP: pasarela de pago, facturación electrónica, consola de
  comercialización.
- El modelo de pagos, cuando exista, es centralizado vía operador certificado; la
  responsabilidad PCI DSS recae en el operador, no en la plataforma.
- Aislamiento de datos entre tenants estricto en toda funcionalidad; cada tenant configura
  sus reglas (documentos, tiempos, comisión) sin despliegue de código específico.

### 4.3 Alcance del proyecto

- Ejecución bajo metodología **Scrum**, con sprints y ceremonias ajustados al cronograma
  académico vigente.
- Equipo de **7 integrantes** con roles y disponibilidad definidos (Gobierno del Equipo).
- Decisiones tecnológicas de producto dependen de Spikes (Sprint 0) y de la Mesa de
  Arquitectura; se registran como ADR solo cuando la Mesa decide.

### 4.4 Limitaciones del proyecto

- Este corte académico se limita al MVP (EP-01..EP-06); el 2º incremento queda excluido.
- **Java, .NET y Kubernetes ya no están en evaluación**: son requerimiento de
  proyecto (PROY-07, PROY-08); Kubernetes sin costo de licencia (ver SRS_MANI.md §1.4). 🔴 Azure, que en
  este corte (2026-08-19) era consecuencia directa de ADR-0004, se retiró de la ecuación el
  2026-09-03 (ADR-0021) — este bullet queda desactualizado en ese punto, ver §7.2. Siguen en anillo
  **Evaluar**: NestJS (alcance sin ratificar), MongoDB, Supabase, Flutter + Dart y
  OpenTelemetry; Docker/Compose en **Probar**. Nada más pasa a "Adoptar" sin ADR.
- **Security Testing** parcialmente definido: SAST (SonarQube) y DAST (OWASP ZAP) resueltos
  por ADR-0005 (2026-08-19). Análisis de dependencias y gestión de secretos siguen 🔴
  pendientes de Mesa de Arquitectura.
- **Java y .NET son requerimiento de proyecto** (constraint externo, no elección de stack)
  para algún módulo del backend — ver Análisis de Requerimientos PROY-07. Alcance exacto por
  módulo, y si NestJS sigue vigente para el resto del backend, 🔴 pendiente de ratificar en
  Mesa (Matriz de Herramientas, incompatibilidad 6bis).
- **Observabilidad sigue 🔴 pendiente** (2026-08-23): pese a que ADR-0006 propone Prometheus +
  Grafana + Datadog, el equipo confirma que la decisión no está cerrada; no planificar
  instrumentación de Sprint 1 dando por hecha ninguna herramienta todavía.
- 🔴 **Documento desactualizado respecto a ADR-0004/0005/0006** (mismo corte, 2026-08-19):
  CI/CD y Security Testing ya tienen Mesa/ADR. Pendiente de sincronizar este Perfil en su
  próxima versión (V2, Sem 4).
- 🔴 Volumen esperado de tenants y de solicitudes concurrentes en el lanzamiento: sin dato
  (vacío identificado en Análisis de Requerimientos, alimenta RNF-07).
- 🔴 Requisitos legales de facturación electrónica en Colombia: sin dato (alimenta RF-24,
  2º incremento).

---

## 5. Módulos Funcionales

| Módulo | Nombre | Épica | Incremento |
| --- | --- | --- | --- |
| M-01 | Plataforma multi-tenant (aislamiento + configuración) | EP-01 | MVP |
| M-02 / M-03 | Directorio de aliados / directorio de clientes | EP-02 | MVP |
| M-04 | Catálogo de categorías y cobertura | EP-03 | MVP |
| M-05..M-08 | Ciclo del servicio (solicitud, cotización, ejecución, calificación) | EP-04 | MVP |
| M-09 | Comunicación / notificaciones | EP-05 | MVP |
| M-11 | Tarifario de referencia | EP-06 | MVP |
| M-10 | Pagos y facturación | EP-07 | 2º incremento |
| M-12..M-14 | Quejas, comercialización y administración | EP-08 | 2º incremento |

---

## 6. Cronograma

Ancla: **Calendario General 2026 (Javeriana, segundo período)** y cronograma de entregas
del profesor. Inicio de clases **lunes 27 de julio de 2026**; sprints de **2 semanas
académicas**; Sprint Review en semanas 6, 8, 10, 12 y 14.

| Sprint | Semanas | Fechas aprox. | Hitos / Entregables (todos incluyen presentación) | Peso |
| --- | --- | --- | --- | --- |
| **Sprint 0** (corte actual) | Sem 1–4 | 27 jul – 22 ago | **Sem 3:** Documento de Proyecto V1. **Sem 4 (Planning Sprint 1):** Documento de Proyecto V2, Herramientas/Políticas/Lineamientos V1, SRS V1, Backlog V1 | 0 % |
| **Sprint 1** | Sem 4–6 | 17 ago – 5 sep | SAD V1, DD V1 (modelos de datos + contratos), Herramientas V2, SRS V2, Backlog V2 | 0 % |
| **Sprint 2** | Sem 6–8 | 31 ago – 19 sep | SAD V2, DD V2, Infraestructura V1, Diseño SDD V1, Herramientas V3, SRS V3, Backlog V3 | 0 % |
| **Sprint 3** | Sem 8–10 | 14 sep – 3 oct | SAD V3, DD V3, Infraestructura V2, Diseño SDD V2, Pruebas TD V1, SRS V4, Backlog V4 + despliegue en QA, informe de pruebas, incremento de valor | 0 % |
| **Sprint 4** | Sem 10–12 | 28 sep – 17 oct | SAD V4, DD V4, Infraestructura V3, Diseño SDD V3, Pruebas TD V2, SRS V5, Backlog V5 + despliegue en QA, informe de pruebas, incremento de valor | **15 %** |
| **Sprint 5** (Review + Lanzamiento) | Sem 12–14 | 12 oct – 31 oct | SAD V5, DD V5, Infraestructura V4, Diseño SDD V4, Pruebas TD V3, Acta de Cierre + despliegue en QA, informe de pruebas, incremento de valor | 0 % |
| **Cierre** | Sem 14–16 | 26 oct – 14 nov | Versión final de todos los documentos y productos, Informe de proyecto (resultados, lecciones aprendidas, conclusiones), Acta de Cierre | **25 %** |

**Peso total del proyecto: 40 %** (15 % Sprint 4 + 25 % Cierre); el resto de entregas son
formativas (0 %).

🔴 **Advertencias sobre las fechas (no tomarlas como exactas):**

- **Festivos dentro de semanas clave.** Lunes 17 de agosto (Asunción — semana del Planning
  Sprint 1, por eso la Mesa de Arquitectura se hizo ese día), lunes 12 de octubre y lunes 2
  de noviembre son festivos; restan una sesión a esas semanas.
- **Semana Javeriana (28–30 sep)** cae en el tramo Sprint 3/4. Si no cuenta como semana de
  clase, todo el tramo final se corre ~1 semana y el Cierre se acerca al fin de período
  (28 nov).
- **Supuestos:** inicio 27 jul, sprints de 2 semanas, numeración continua Sem 1–16. Si el
  profesor fijó fechas de Review distintas en el cronograma oficial, ajustar esta tabla.

**Cadencia de ceremonias (Gobierno del Equipo §1.3.3):** Sprint Planning al inicio de cada
sprint (2 h) · Daily diario en días hábiles · Sprint Review al cierre (1 h, con profesor) ·
Retrospectiva al cierre (1 h + reporte) · Mesa de Arquitectura según necesidad (~1 h).

---

## 7. Presupuesto

Estimado a partir de precios públicos vigentes (agosto 2026) de las herramientas
preseleccionadas en Matriz_de_Herramientas.md — **no es una cifra oficial del proyecto**,
es un cálculo de referencia para presupuestar. Fuentes al final de la sección.

**Actualización 2026-08-23:** se incorporan costos de Azure, SonarQube, OWASP ZAP,
Kubernetes/AKS, Azure Container Registry, Prometheus, Grafana y Datadog (ADR-0004/0005/0006 +
PROY-07/PROY-08), con fuentes agregadas al final de la sección.

🔴 **Advertencia — RNF-07 aún sin umbral.** El SRS y el Análisis de Requerimientos no fijan
todavía volumen de tenants ni de solicitudes/usuarios concurrentes (vacío señalado en el
Análisis de Requerimientos §7, ver también la aclaración de RNF-07 en ese mismo documento).
Por eso el tamaño de clúster/tier de base de datos **no se puede fijar con precisión** — la
orquestación (Kubernetes) ya no depende de esa decisión (es requisito de proyecto, PROY-08),
pero cuántos nodos y de qué tamaño, sí.

### 7.1 Presupuesto de Proyecto (herramientas de proceso, durante el desarrollo)

Equipo: 7 integrantes (Gobierno_del_Equipo.md §1.1.1). Precios de lista, mensual, USD.

| Herramienta | Plan asumido | Precio | Seats estimados | Costo/mes |
| --- | --- | --- | --- | --- |
| Jira | Free (hasta 10 usuarios) | $0 | 7 | **$0** |
| GitHub | Free (repos privados ilimitados) | $0 | 7 | **$0** |
| GitHub Actions | Incluido en Free (2.000 min/mes) | $0 | — | **$0** (🔴 si se excede: $0.006/min Linux) |
| OneDrive / Microsoft 365 | Business Basic | $6/usuario/mes | 7 | **$42** |
| Discord | Free (servidor comunidad) | $0 | 7 | **$0** |
| Postman | Team (colaboración requerida desde mar-2026; Free ya no admite equipo) | $19/usuario/mes | 3 (QA, Backend, DevOps) | **$57** |
| k6 | Open source local / Grafana Cloud free (500 VUh/mes) | $0 | — | **$0** |
| Figma | Professional | $12/editor/mes (anual) | 3 (Frontend ×2, PO) | **$36** |
| Miro | Free (miembros ilimitados) | $0 | 7 | **$0** |
| Mermaid | Open source (embebido en Markdown) | $0 | — | **$0** |
| SonarQube Cloud | Team (hasta ~100k LOC) — ADR-0005 | $32–34/mes | 1 (proyecto) | **≈ $33** |
| OWASP ZAP | Open source — ADR-0005 | $0 | — | **$0** |
| **Total estimado / mes** | | | | **≈ $168 USD/mes** |
| **Total Sprint 0–Cierre (≈ 16 semanas ≈ 3.7 meses)** | | | | **≈ $620 USD** |

Notas:
- Postman, Figma y SonarQube Cloud son los rubros no cubiertos por tier gratuito: Postman
  retiró la colaboración del plan Free en marzo 2026; Figma cobra por editor; SonarQube Cloud
  Free cubre 50k LOC privadas — insuficiente si el código de los tres repos (Flutter, Java,
  .NET) supera ese umbral, de ahí el plan Team.
- Se clasifican SonarQube y OWASP ZAP como herramientas de **proceso** (corren en CI, como
  Postman/k6), no como tecnología de producto — por eso están aquí y no en §7.2.
- Si la universidad ya provee Microsoft 365 Education a los estudiantes, el rubro de
  OneDrive ($42/mes) podría bajar a $0 — 🔴 sin confirmar en la documentación.
- Jira, GitHub, Discord, Miro, k6 y OWASP ZAP cubren el equipo completo sin costo en sus
  tiers gratuitos al tamaño actual (7 personas).

### 7.2 Presupuesto de Producto

Parte confirmada por requerimiento de proyecto (PROY-07 Java+.NET, PROY-08 Kubernetes, este
último sin costo de licencia — ver SRS_MANI.md §1.4); Azure ya no aplica como proveedor de
infraestructura (ADR-0021); parte aún en evaluación (Matriz_de_Herramientas.md §B) — se marca
cada fila.

| Tecnología | Rol | Escenario mínimo (dev/demo) | Escenario producción pequeña | Nota |
| --- | --- | --- | --- | --- |
| Java + Maven | Backend (Repo B) — **confirmado**, PROY-07/ADR-0004 | $0 (open source) | $0 (open source) | Sin costo de licencia |
| .NET | Backend (Repo C) — **confirmado**, PROY-07/ADR-0004 | $0 (open source, .NET SDK) | $0 (open source) | Sin costo si se hospeda en Linux; evitar licencia Windows Server |
| NestJS | Framework backend — 🔴 alcance sin ratificar (¿algún módulo además de Java/.NET?) | $0 (open source) | $0 (open source) | Ver Matriz de Herramientas, incompatibilidad 6bis |
| Flutter + Dart | Cliente multiplataforma | $0 (open source) | $0 + publicación: Google Play $25 único, Apple Developer $99/año | Costo de publicación en tiendas, no de la tecnología |
| MongoDB Atlas | Persistencia (candidata) | M0 free — $0 | M10 dedicado $57/mes/nodo × 3 nodos (replica set) ≈ **$171/mes** | 🔴 excluye RLS; contradice opción Supabase (incompatibilidad #1) |
| Supabase | BaaS sobre PostgreSQL (candidata alterna) | Free — $0 | Pro **$25/mes** por proyecto | 🔴 mutuamente excluyente con MongoDB hasta que la Mesa decida (SP-01.1.1) |
| Docker / Docker Compose | Contenerización DEV/QA | $0 | $0 | Gratis para <250 empleados y <$10M ingresos anuales — el proyecto califica |
| **Kubernetes** | Orquestación — **confirmado obligatorio**, PROY-08 | $0 | $0 | Software open source, sin costo de licencia (ver SRS_MANI.md §1.4). No incluye el cómputo que aloja el clúster — ver fila siguiente |
| Cómputo/hosting del clúster | Nodos donde corre Kubernetes | 🔴 sin cifra | 🔴 sin cifra | 🔴 Ya no es AKS (Azure retirado, ADR-0021); falta ADR de distribución concreta (proveedor, nodos) — la estimación previa de $450–650/mes era de Azure AKS y ya no aplica |
| Docker Hub | Registro de imágenes (Java y .NET unificado) — ADR-0021 | $0 (plan Free/Team básico) | 🔴 sin cotizar si se requiere plan de pago por repos privados | Reemplaza a Azure Container Registry |
| Railway | Hosting de contenedores — ADR-0021 | 🔴 sin cotizar | 🔴 sin cotizar | Reemplaza a Azure como proveedor de infraestructura |
| OpenTelemetry | Observabilidad — 🔴 en evaluación | $0 (open source) | $0 + backend opcional | Compite con la fila siguiente; observabilidad sigue sin ratificar (ver Matriz de Herramientas) |
| Prometheus + Grafana | Observabilidad — 🔴 propuesta ADR-0006, sin ratificar | $0 (open source, self-hosted) | $0 (self-hosted) o Grafana Cloud free hasta 10k series | Sin costo de licencia |
| Datadog | APM/logs/alertas — 🔴 propuesta ADR-0006, sin ratificar | $0 (free trial 14 días) | Infra ≈ $15/host/mes + APM ≈ $31/host/mes (3 hosts ≈ $138) + logs desde $0.10/GB ≈ **$150–300/mes** | Reportado como frecuente que el costo real termine 2–3× la estimación inicial por logs/APM/métricas custom — no comprometer sin tope de gasto |
| **Total estimado / mes** | | **≈ $0–5** (Java/.NET/Flutter/Docker/Kubernetes/Docker Hub en $0) | **≈ $25–471** + 🔴 cómputo del clúster sin cifra (rango por: persistencia Mongo vs. Supabase, y si además de Prometheus/Grafana se ratifica Datadog) | Kubernetes ya no es la variable de costo (ver SRS_MANI.md §1.4); persistencia, observabilidad y el cómputo/hosting del clúster (Railway u otro, ADR-0021) sí lo son |

**Integraciones del 2º incremento** (operador de pagos certificado, proveedor de
identidad, servicio de notificaciones — SRS_MANI.md §8): 🔴 sin costo estimable, ninguna
está seleccionada todavía (pendiente de spike y ADR).

### 7.3 Resumen

| Rubro | Estimado |
| --- | --- |
| Proyecto (proceso, ~16 semanas, incluye SonarQube+ZAP) | ≈ $620 USD |
| Producto — escenario mínimo (dev/demo, MVP en curso) | ≈ $0–5 USD/mes |
| Producto — producción pequeña, Supabase + sin Datadog (solo Prometheus/Grafana) | ≈ $25 USD/mes + 🔴 cómputo del clúster |
| Producto — producción pequeña, MongoDB + sin Datadog (solo Prometheus/Grafana) | ≈ $171 USD/mes + 🔴 cómputo del clúster |
| Producto — producción pequeña, Supabase + Datadog | ≈ $25–325 USD/mes + 🔴 cómputo del clúster |
| Producto — producción pequeña, MongoDB + Datadog | ≈ $171–471 USD/mes + 🔴 cómputo del clúster |

Kubernetes ya no es la variable de costo abierta (PROY-08, ver SRS_MANI.md §1.4): el orquestador en sí es
$0. Azure se retiró de la ecuación (ADR-0021), así que la antigua cifra de AKS (~$450–650/mes)
tampoco aplica. 🔴 Lo que sigue sin decidir y mueve el rango real: **persistencia** (MongoDB
vs. Supabase, SP-01.1.1), **observabilidad** (Prometheus/Grafana solamente, o además Datadog —
sin ratificar) y, ahora como ítem propio, **dónde y con cuántos nodos corre el clúster de
Kubernetes** (proveedor de cómputo, sin ADR de dimensionamiento todavía). No se recomienda
fijar presupuesto de producto en firme hasta que esas decisiones existan.

**Fuentes de precios:**

*Consultadas 2026-08-19:*
[Jira Pricing](https://automationatlas.io/answers/jira-pricing-explained-2026/) ·
[GitHub Pricing](https://www.getpricepulse.com/blog/github-pricing-2026-complete-guide.html) ·
[GitHub Actions Pricing](https://cicdcost.com/github-actions-pricing) ·
[Microsoft 365 Business Pricing](https://www.microsoft.com/en-us/microsoft-365/business/microsoft-365-plans-and-pricing) ·
[Postman Pricing 2026](https://costbench.com/software/developer-tools/postman/) ·
[Figma Pricing 2026](https://aitoolpick.org/blog/figma-pricing-2026/) ·
[Miro Pricing 2026](https://comparedge.com/tools/miro/pricing) ·
[k6 / Grafana Cloud Pricing](https://cubeapm.com/blog/grafana-cloud-pricing-and-review/) ·
[MongoDB Atlas Pricing](https://www.budgetforge.dev/tools/mongodb-atlas-pricing-2026) ·
[Supabase Pricing 2026](https://www.nocode.mba/articles/supabase-pricing) ·
[Docker Pricing 2026](https://www.runxbuild.com/blog/docker-pricing/)

*Añadidas 2026-08-23 (ADR-0004/0005/0006 y PROY-07/08):*
[SonarQube Cloud Pricing 2026](https://www.sonarsource.com/products/sonarqube/cloud/new-pricing-plans/) ·
[Datadog Pricing 2026](https://costbench.com/software/observability/datadog/) ·
[Azure Kubernetes Service (AKS) Pricing 2026](https://sedai.io/blog/understanding-azure-kubernetes-service-aks-pricing-costs) ·
[Azure Container Registry Pricing](https://azure.microsoft.com/en-us/pricing/details/container-registry/) (página dinámica,
cifra estimada — confirmar en calculadora Azure antes de comprometer presupuesto)

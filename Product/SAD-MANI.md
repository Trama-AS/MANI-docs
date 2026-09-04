# MANI SAD

## Índice

1. [Drivers](#1-drivers)
2. [Killers](#2-killers)
3. [ADR](#3-adr)
4. [Atributos_Calidad](#4-atributos-calidad)
5. [Escenarios_Calidad](#5-escenarios-calidad)
6. [Trade-offs](#6-trade-offs)
7. [Arquitectura_de_Negocio](#7-arquitectura-de-negocio)

---

## 1. Drivers

**Drivers Arquitectónicos**

*Objetivos de Diseño: qué debe lograr la arquitectura de MANI (Parte 1.1 del SAD)*

**Tabla A — Prioridad y trazabilidad**

| # | Prioridad | Fuente (trazabilidad) |
|---|---|---|
| 1 | Crítica | RF-01 |
| 2 | Crítica | RF-02 |
| 3 | Crítica | RF-03 |
| 4 | Crítica | RF-05 |
| 5 | Alta | RF-07 |
| 6 | Crítica | RF-12 |
| 7 | Alta | RF-13 |
| 8 | Crítica | RF-14 |
| 9 | Alta | RF-15 / RF-17 |
| 10 | Media | RF-18 |
| 11 | Media | RF-19 |
| 13 | Crítica | RNF-01 |
| 14 | Crítica | RNF-02 |
| 15 | Alta | RNF-03 |
| 16 | Alta | RNF-05 |
| 17 | Media | RNF-07 |
| 18 | Alta | RNF-04 |
| 19 | Media | RNF-08 |
| 20 | Alta | RNF-09 |
| 21 | Alta | RNF-10 |
| 22 | Alta | RNF-06 / RNF-11 |

> No existe el # 12: numeración original del equipo, no se reasigna (ver SRS §4.2).

**Tabla B — Descripción de cada driver**

| # | Descripción del driver |
|---|---|
| 1 | Registro y administración de tenants con aislamiento de datos garantizado. |
| 2 | Configuración de reglas propias por tenant (documentos, orden de listado, categorías, tarifas) sin desarrollo específico. |
| 3 | Autenticación y control de acceso restringido por tenant y por rol. |
| 4 | Registro de aliados diferenciando persona natural, empresa y empleado directo, con documentos configurables por tenant. |
| 5 | Declaración de cobertura de aliados por zonas geográficas, no por radio. |
| 6 | Creación de solicitudes de servicio y presentación de aliados válidos según categoría y cobertura. |
| 7 | Ordenamiento del listado de aliados según regla configurable por tenant (cobertura, calificación o comisión). |
| 8 | Aceptación/rechazo de solicitud por el aliado, sin dobles asignaciones. |
| 9 | Elaboración de cotización (mano de obra y materiales separados) y su aceptación/rechazo/ajuste por el cliente. |
| 10 | Registro cronológico de eventos durante la ejecución (log del servicio). |
| 11 | Calificación bidireccional cliente–aliado al cierre del servicio. |
| 13 | Aislamiento estricto de datos; un usuario o mecanismo de acceso de un tenant no puede acceder a información de otro. |
| 14 | Cada tenant configura sus reglas sin requerir código específico ni nuevo despliegue de la plataforma. |
| 15 | Idempotencia en operaciones críticas (aceptar solicitud, aceptar cotización, calificar) ante reintentos. |
| 16 | El despacho debe resolver aceptaciones concurrentes garantizando exactamente una asignación válida. |
| 17 | Soportar concurrencia de usuarios en búsqueda de aliados y comunicación (candidato a riesgo crítico de diseño). |
| 18 | Trazabilidad suficiente para reconstruir eventos del ciclo del servicio; registro financiero inmutable en el 2º incremento. |
| 19 | Interfaz utilizable desde dispositivos móviles por clientes y aliados. |
| 20 | Cobertura declarada por zonas, no por radio geográfico. |
| 21 | KYC, tiempos y comisiones configurables por tenant, no codificados. |
| 22 | Responsabilidad PCI-DSS delegada al operador de pagos certificado; modelo de pagos centralizado, priorizando integración sobre construcción propia. |

---

## 2. Killers

**Killers Arquitectónicos**

*Objetivos de Diseño: limitaciones y riesgos que pueden invalidar la arquitectura (Parte 1.2 del SAD)*

**Tabla A — Identificación**

| ID | Killer | Categoría |
|---|---|---|
| KI-01 | MongoDB sin RLS nativo | Incompatibilidad técnica |
| KI-03 | Dimensionamiento de cómputo para alojar el clúster Kubernetes, sin proveedor ni configuración de nodos ratificada | Restricción económica |
| KI-04 | Ventana de riesgo entre revisiones manuales de seguridad | Seguridad de proceso |
| KI-05 | Aislamiento en Storage depende de la disciplina del backend al construir la ruta | Seguridad |
| KI-06 | Volumen de tenants desconocido | Escalabilidad |
| KI-07 | Sin soporte para cobertura parcial de una localidad | Limitación de producto |
| KI-08 | Dependencia de datos oficiales de división político-administrativa | Dependencia externa |
| KI-09 | Volumen concurrente de búsqueda + mensajería sin cifra conocida | Rendimiento |
| KI-10 | ADR-0016/0017 incompletos (Redactor, Disenso, Quórum [completar]) | Gobernanza |
| KI-11 | Observabilidad instrumentada sobre Java Spring/.NET, en riesgo si prevalece Dart/Serverpod | Mantenibilidad |

**Tabla B — Descripción del riesgo**

| ID | Descripción |
|---|---|
| KI-01 | El backend propuesto originalmente (MongoDB) no soporta RLS, quedando incompatible con DR-01 |
| KI-03 | **Resuelto el "si": Kubernetes se adopta** — es requisito curricular no negociable (PROY-08) y no tiene costo de licencia (software open source; ver SRS_MANI.md §1.4). Lo único abierto es el "cómo": dónde y con qué nodos corre el clúster (ya no ligado a Azure/AKS, retirado por ADR-0021) |
| KI-04 | Sin automatización, un cambio que rompa el aislamiento puede llegar a producción sin detectarse, alguien puede pasar devops a main sin revision |
| KI-05 | La ruta tenant_id/aliado_id/archivo no tiene límite físico de respaldo como un bucket separado. Hacer bien las conexiones entre repositorios "Clean Arqui" para hacer el llamado correcto |
| KI-06 | Condiciona si el aislamiento lógico por RLS sobre esquema compartido basta a futuro, o si hará falta separar por base/esquema |
| KI-07 | El modelo de zonas obliga a declarar la localidad completa o nada |
| KI-08 | El modelo de zonas depende de que exista esa información por ciudad |
| KI-09 | RNF-07 señalado como riesgo crítico en el SRS pese a prioridad Media, sin volumen definido para fijar umbrales |
| KI-10 | No cumplen el checklist de cierre del Gobierno del Equipo §2.6, pese a que ya se están usando como base de diseño |
| KI-11 | La instrumentación completa (ADR-0006) quedaría sin destinatario técnico si KI-02 se resolviera eliminando Java/.NET |

**Tabla C — Mitigación / estado**

| ID | Mitigación / Estado |
|---|---|
| KI-01 | Resuelto — migración completa a PostgreSQL/Supabase (ADR-0012) |
| KI-03 | Kubernetes adoptado (Sí o sí, ADR-0010) — abierto solo el ADR de dimensionamiento/hosting del clúster |
| KI-04 | Mitigación diseñada, ADR-0015 aún Propuesto |
| KI-05 | Riesgo residual aceptado conscientemente (ADR-0013) |
| KI-06 | No resuelto — deuda declarada (ADR-0012) |
| KI-07 | Aceptado con condiciones explícitas de reapertura (ADR-0011) |
| KI-08 | Degrada a nivel ciudad si no existe (ADR-0011) |
| KI-09 | Sin resolver — Análisis de Requerimientos §7 no fija cifra |
| KI-10 | Abierto — requiere sesión formal de la Mesa |
| KI-11 | Resuelto — KI-02 cerrado por ADR-0021: Java/.NET preservados, ADR-0006 conserva destinatario técnico |

---

## 3. ADR

**ADR Consolidados**

*Los 15 ADR originales del repositorio Trama-AS/MANI-docs (no existe ADR-0014), más
ADR-0021 (2026-09-03), que cierra el hallazgo transversal KI-02 sin reemplazar ninguno de
los cuatro ADR que aclara.*

Cada ADR se presenta como una tabla de 2 columnas (Campo / Valor) en vez de una fila de
una tabla ancha, para mantener legible el resumen y el detalle a la vez.

**ADR-0001 — Gestión documental**

| Campo | Valor |
|---|---|
| Estado | 🟢 Aceptado |
| Decisión (resumen) | GitHub (código/ADR) + OneDrive (documentos formales), dividido por tipo de contenido |
| Alternativas descartadas | Todo en GitHub; Confluence + Jira |
| Objetivo de Diseño | DR-11 |
| AC / Escenario | — |
| Trade-off | — |

**ADR-0002 — Herramientas de gestión: Jira**

| Campo | Valor |
|---|---|
| Estado | 🟢 Aceptado |
| Decisión (resumen) | Jira para gestión de proyecto + GitHub para lo técnico, separados |
| Alternativas descartadas | Todo en GitHub Projects; GitLab Issues |
| Objetivo de Diseño | DR-08 |
| AC / Escenario | — |
| Trade-off | — |

**ADR-0003 — Mesa de Arquitectura**

| Campo | Valor |
|---|---|
| Estado | 🟢 Aceptado |
| Decisión (resumen) | Mesa con Arquitecto transversal y rotación de autoría de ADR; quórum 5/7, disenso documentado |
| Alternativas descartadas | Responsable único (SM); sin reglamento formal |
| Objetivo de Diseño | DR-09 |
| AC / Escenario | — |
| Trade-off | — |

**ADR-0004 — Pipeline CI/CD multi-repositorio**

| Campo | Valor |
|---|---|
| Estado | 🟢 Aceptado, alcance aclarado por ADR-0021 (Azure reemplazado por Docker Hub + Railway) |
| Decisión (resumen) | GitHub Actions + Webhooks Jira↔GitHub + promoción de contenedores, sobre 3 repos (Flutter/Java/.NET) + backend Serverpod |
| Alternativas descartadas | Monorepositorio; Jenkins auto-hospedado |
| Objetivo de Diseño | DR-08 |
| AC / Escenario | — |
| Trade-off | Cierra KI-02 vía ADR-0021 (coexistencia, no reemplazo) |

**ADR-0005 — DevSecOps: SAST + DAST**

| Campo | Valor |
|---|---|
| Estado | 🟢 Aceptado, alcance aclarado por ADR-0021 |
| Decisión (resumen) | SonarQube (SAST) + OWASP ZAP (DAST) en GitHub Actions, sobre Flutter/Java/.NET y backend Serverpod |
| Alternativas descartadas | Revisión manual; plataformas comerciales unificadas |
| Objetivo de Diseño | DR-07 |
| AC / Escenario | — |
| Trade-off | Cierra KI-02 vía ADR-0021 (coexistencia, no reemplazo) |

**ADR-0006 — Observabilidad**

| Campo | Valor |
|---|---|
| Estado | 🟢 Aceptado, alcance aclarado por ADR-0021 (Azure reemplazado por Docker Hub + Railway) |
| Decisión (resumen) | Prometheus + Grafana + Datadog, instrumentando Java Spring/.NET (y backend Serverpod si aplica) |
| Alternativas descartadas | Stack ELK auto-alojado; Azure Monitor/App Insights exclusivo |
| Objetivo de Diseño | KI-11 |
| AC / Escenario | AC-11 / QS-18 |
| Trade-off | TO-04 · KI-11 resuelto (Java/.NET preservados, ver ADR-0021) |

**ADR-0007 — Documentación en el repositorio**

| Campo | Valor |
|---|---|
| Estado | 🟢 Aceptado |
| Decisión (resumen) | Carpeta /docs versionada junto al código, reemplaza Confluence/Drive/Discord |
| Alternativas descartadas | Confluence como fuente única; Google Drive compartido |
| Objetivo de Diseño | DR-11 |
| AC / Escenario | — |
| Trade-off | — |

**ADR-0008 — Carpeta de diagramas**

| Campo | Valor |
|---|---|
| Estado | 🟢 Aceptado |
| Decisión (resumen) | /docs/diagramas con subcarpetas por tipo; Mermaid versionado como texto (.mmd) |
| Alternativas descartadas | Solo en herramientas de origen (Figma/Miro); imágenes sueltas en Confluence |
| Objetivo de Diseño | DR-11 |
| AC / Escenario | — |
| Trade-off | — |

**ADR-0009 — Política de uso de IA**

| Campo | Valor |
|---|---|
| Estado | 🟢 Aceptado |
| Decisión (resumen) | Uso de IA permitido bajo lineamientos del equipo; ninguna sugerencia de IA es decisión válida sin pasar por la Mesa |
| Alternativas descartadas | Prohibición total; uso libre sin lineamientos |
| Objetivo de Diseño | DR-09 |
| AC / Escenario | — |
| Trade-off | — |

**ADR-0010 — Tech Radar del proyecto**

| Campo | Valor |
|---|---|
| Estado | 🟢 Aceptado |
| Decisión (resumen) | Radar visual consolidado (círculos de confianza, cuadrantes por categoría); Kubernetes en "Sí o sí" (PROY-08, sin costo de licencia — actualizado 2026-09-03) |
| Alternativas descartadas | Mantener disperso en ADR individuales |
| Objetivo de Diseño | KI-03 |
| AC / Escenario | — |
| Trade-off | — |

**ADR-0011 — Modelo de cobertura geográfica**

| Campo | Valor |
|---|---|
| Estado | 🟢 Aceptado |
| Decisión (resumen) | Catálogo de zonas administrativas, relación N:M aliado↔zona, sin geometría propia |
| Alternativas descartadas | Radio de cobertura; polígonos dibujados; catálogo con geometría asociada |
| Objetivo de Diseño | DR-02, DR-03 |
| AC / Escenario | AC-01 / QS-05 |
| Trade-off | KI-07, KI-08 |

**ADR-0012 — Backend Dart, motor de persistencia y aislamiento multi-tenant**

| Campo | Valor |
|---|---|
| Estado | 🟢 Aceptado, alcance aclarado por ADR-0021 |
| Decisión (resumen) | Serverpod (Dart) + Supabase (PostgreSQL) + RLS nativo — capa de persistencia/identidad, coexiste con Java (Repo B) y .NET (Repo C) |
| Alternativas descartadas | NestJS+MongoDB; BaaS puro; filtrado manual sin RLS; base/esquema separado por tenant |
| Objetivo de Diseño | DR-01 |
| AC / Escenario | AC-01, AC-02 / QS-02 |
| Trade-off | TO-01, TO-02, TO-06 · resuelve KI-01 · KI-02 cerrado (ADR-0021) · abre KI-06 |

**ADR-0013 — Almacenamiento de documentos KYC**

| Campo | Valor |
|---|---|
| Estado | 🟡 Propuesto |
| Decisión (resumen) | Bucket único de Storage con ruta tenant_id/aliado_id/archivo + RLS sobre storage.objects |
| Alternativas descartadas | Bucket privado por tenant; aislamiento solo en capa de aplicación |
| Objetivo de Diseño | DR-05, DR-01 |
| AC / Escenario | AC-01 / QS-04 |
| Trade-off | KI-05 |

**ADR-0015 — Estrategia de pruebas de aislamiento multi-tenant**

| Campo | Valor |
|---|---|
| Estado | 🟡 Propuesto |
| Decisión (resumen) | Colección Postman con 6 casos de acceso cruzado, automatizada con Newman en GitHub Actions |
| Alternativas descartadas | Revisión manual periódica; k6 u OWASP ZAP |
| Objetivo de Diseño | DR-06 |
| AC / Escenario | AC-10 / QS-17 |
| Trade-off | TO-05, TO-08 · mitiga KI-04 |

**ADR-0016 — Estrategia de despacho de solicitudes**

| Campo | Valor |
|---|---|
| Estado | 🟡 Propuesto, incompleto |
| Decisión (resumen) | Despacho simultáneo (broadcast) con UPDATE condicional atómico |
| Alternativas descartadas | Despacho secuencial según orden de RF-13 |
| Objetivo de Diseño | DR-04 |
| AC / Escenario | AC-04 / QS-09 |
| Trade-off | TO-03 · pendiente en KI-10 |

**ADR-0017 — Mensajería y notificaciones en tiempo real**

| Campo | Valor |
|---|---|
| Estado | 🟡 Propuesto, condicionado |
| Decisión (resumen) | Supabase Realtime (Broadcast) + push notifications (FCM/APNs) |
| Alternativas descartadas | WebSockets propios (Socket.io); Polling |
| Objetivo de Diseño | — |
| AC / Escenario | AC-13 / QS-14 |
| Trade-off | TO-06 · pendiente en KI-10 |

**ADR-0021 — Consolidación del stack de backend distribuido y eliminación de Azure (cierre de KI-02)**

| Campo | Valor |
|---|---|
| Estado | 🟢 Aceptado |
| Decisión (resumen) | Java (Repo B), .NET (Repo C) y el backend Serverpod/Supabase de ADR-0012 **coexisten** como módulos distintos (reglas de negocio, transaccional de alta concurrencia, y persistencia/identidad, respectivamente); se elimina Microsoft Azure como proveedor de infraestructura, migrando a Docker Hub + Railway |
| Alternativas descartadas | Mantener la contradicción sin trazar; declarar ADR-0012 reemplazo total de Java/.NET; mantener Azure como proveedor |
| Objetivo de Diseño | Cierra KI-02 |
| AC / Escenario | — |
| Trade-off | Migración de registro de contenedores (.NET) de Azure Container Registry a Docker Hub; Railway con menor techo de escala que Azure |

✅ **KI-02 — resuelto (2026-09-03).** ADR-0004/0005/0006 (Java/.NET, CI/CD/DevSecOps/
Observabilidad) y ADR-0012 (Dart/Serverpod/Supabase) **no son mutuamente excluyentes**: la
contradicción real estaba en el proveedor de infraestructura (Azure, fijado por ADR-0004/0006),
no en el lenguaje de backend. ADR-0021 lo aclara explícitamente sin declarar `supersedes` sobre
ninguno de los cuatro: Java, .NET y Serverpod/Dart gobiernan módulos distintos de la
arquitectura y coexisten; solo la porción de infraestructura Azure de ADR-0004/0006 queda
reemplazada (Docker Hub + Railway). Ver la nota de alcance agregada en ADR-0005 y ADR-0012.

---

## 4. Atributos_Calidad

**Atributos de Calidad**

*ISO/IEC 25010:2023 — Categoría y Subcategoría siempre nombradas; incluye atributos sin ADR marcados para discusión de la Mesa*

| ID | Categoría | Subcategoría |
|---|---|---|
| AC-01 | Seguridad | Confidencialidad |
| AC-02 | Seguridad | Integridad |
| AC-03 | Seguridad | No repudio / Rendición de cuentas |
| AC-04 | Fiabilidad | Tolerancia a fallos (despacho concurrente) |
| AC-05 | Fiabilidad | Tolerancia a fallos (idempotencia) |
| AC-06 | Fiabilidad | Disponibilidad |
| AC-07 | Flexibilidad | Adaptabilidad (configuración por tenant) |
| AC-08 | Eficiencia de desempeño | Capacidad |
| AC-09 | Eficiencia de desempeño | Utilización de recursos |
| AC-10 | Mantenibilidad | Verificabilidad (Testability) |
| AC-11 | Mantenibilidad | Analizabilidad |
| AC-12 | Mantenibilidad | Modularidad |
| AC-13 | Compatibilidad | Interoperabilidad |
| AC-14 | Portabilidad | Adaptabilidad |
| AC-15 | Usabilidad | Capacidad de aprendizaje |
| AC-16 | Seguridad | Autenticación |
| AC-17 | Idoneidad funcional | Corrección |
| AC-18 | Usabilidad | Atractivo |
| AC-19 | Seguridad | Cumplimiento normativo |

> Excluidos deliberadamente: RNF-06 (responsabilidad PCI DSS) y RNF-11 (modelo de pagos) no son atributos de calidad ISO 25010 por sí mismos — están representados vía AC-19. RNF-09 (cobertura por zonas) es una restricción de producto (REST-01/DR-02), no un atributo de calidad.

---

## 5. Escenarios_Calidad

**Escenarios de Calidad**

*24 escenarios organizados por módulo funcional — cubren RF-01 a RF-28 completos, con formato Source/Stimulus/Artifact/Environment/Response/Response Measure*

Cada escenario se presenta como una tabla de 2 columnas (Campo / Valor) en vez de una fila
de una tabla de 13 columnas, para que Source/Stimulus/Response se puedan leer completos.

**QS-01 — Mód. 1 — Acceso (RF-01)**

| Campo | Valor |
|---|---|
| Atributo | Seguridad / Confidencialidad |
| Source (Fuente) | Admin. plataforma |
| Stimulus (Estímulo) | Da de alta una nueva empresa (tenant) en la plataforma |
| Artifact (Artefacto) | Módulo de administración de tenants |
| Environment (Entorno) | Producción, operación normal |
| Response (Respuesta) | El sistema crea el tenant con su propio espacio de datos, aislado desde el primer momento |
| Response Measure (Medida) | El tenant queda operativo en menos de 5 minutos; 0 datos de otros tenants visibles desde su creación |
| Prioridad / Impacto / Complejidad | Alta / Alto / Media |

**QS-02 — Mód. 1 — Acceso (RF-03)**

| Campo | Valor |
|---|---|
| Atributo | Seguridad / Confidencialidad |
| Source (Fuente) | Usuario ya registrado (Cliente, Aliado o Admin.) |
| Stimulus (Estímulo) | Inicia sesión y navega la app |
| Artifact (Artefacto) | Capa de acceso a datos (RLS en Supabase) + módulo de autenticación |
| Environment (Entorno) | Producción, uso normal |
| Response (Respuesta) | El sistema autentica al usuario y solo le muestra datos del tenant al que pertenece |
| Response Measure (Medida) | 0 registros de otro tenant visibles en el 100% de 6 pruebas automáticas de acceso cruzado, ejecutadas en cada cambio que toque autenticación, RLS o el esquema |
| Prioridad / Impacto / Complejidad | Alta / Alto / Media |

**QS-03 — Mód. 1 — Acceso (RF-04)**

| Campo | Valor |
|---|---|
| Atributo | Seguridad / Autenticación |
| Source (Fuente) | Usuario que olvidó su contraseña |
| Stimulus (Estímulo) | Solicita recuperar el acceso a su cuenta |
| Artifact (Artefacto) | Flujo de recuperación de contraseña |
| Environment (Entorno) | Producción, cualquier hora |
| Response (Respuesta) | El sistema verifica la identidad del usuario antes de permitir el cambio de contraseña |
| Response Measure (Medida) | 0 cambios de contraseña sin verificación exitosa; el código o enlace de verificación expira antes de 15 minutos |
| Prioridad / Impacto / Complejidad | Media / Alto / Baja |

**QS-04 — Mód. 2 — Directorio (RF-05, RF-06)**

| Campo | Valor |
|---|---|
| Atributo | Idoneidad funcional / Corrección |
| Source (Fuente) | Admin. tenant revisando la bandeja de verificación |
| Stimulus (Estímulo) | Un aliado envía su registro con los documentos que el tenant exige |
| Artifact (Artefacto) | Bandeja de verificación de aliados |
| Environment (Entorno) | Producción, operación normal |
| Response (Respuesta) | El sistema muestra el registro pendiente con todos sus documentos, y permite aprobarlo o rechazarlo |
| Response Measure (Medida) | 100% de los registros nuevos aparecen en la bandeja en menos de 1 minuto; el aliado ve el resultado sin tener que preguntar |
| Prioridad / Impacto / Complejidad | Alta / Alto / Media |

**QS-05 — Mód. 2 — Directorio (RF-07)**

| Campo | Valor |
|---|---|
| Atributo | Idoneidad funcional / Corrección |
| Source (Fuente) | Aliado configurando su perfil |
| Stimulus (Estímulo) | Declara las zonas donde presta servicio |
| Artifact (Artefacto) | Selector de zonas (catálogo jerárquico ciudad → localidad → barrio) |
| Environment (Entorno) | Producción, primera configuración o edición posterior |
| Response (Respuesta) | El sistema guarda la selección y la usa después para las búsquedas de cobertura de RF-12 |
| Response Measure (Medida) | El aliado completa la selección en menos de 2 minutos; 0 errores al guardar |
| Prioridad / Impacto / Complejidad | Alta / Medio / Baja |

**QS-06 — Mód. 2 — Directorio (RF-08, RF-09)**

| Campo | Valor |
|---|---|
| Atributo | Flexibilidad / Adaptabilidad |
| Source (Fuente) | Cliente empresa con varios sitios |
| Stimulus (Estímulo) | Registra un nuevo sitio con reglas propias (ej. horario de acceso) |
| Artifact (Artefacto) | Módulo de gestión de sitios del cliente |
| Environment (Entorno) | Producción, operación normal |
| Response (Respuesta) | El sistema guarda el sitio con sus reglas y se las muestra al aliado antes de que acepte una solicitud de ese sitio |
| Response Measure (Medida) | 100% de las reglas del sitio visibles para el aliado antes de aceptar la solicitud |
| Prioridad / Impacto / Complejidad | Media / Medio / Media |

**QS-07 — Mód. 3 — Catálogo (RF-02, RF-10, RF-11)**

| Campo | Valor |
|---|---|
| Atributo | Flexibilidad / Adaptabilidad |
| Source (Fuente) | Admin. tenant |
| Stimulus (Estímulo) | Activa o desactiva una categoría de servicio, o ajusta una regla del tenant (documentos, tarifas, orden de listado) |
| Artifact (Artefacto) | Módulo de configuración de categorías y reglas del tenant |
| Environment (Entorno) | Producción, operación normal |
| Response (Respuesta) | El cambio se refleja de inmediato para clientes y aliados de ese tenant, sin necesidad de desplegar código nuevo |
| Response Measure (Medida) | Tiempo entre guardar el cambio y que quede activo < 1 min; 0 despliegues de código requeridos |
| Prioridad / Impacto / Complejidad | Alta / Alto / Alta |

**QS-08 — Mód. 4 — Ciclo servicio (RF-12, RF-13)**

| Campo | Valor |
|---|---|
| Atributo | Eficiencia de desempeño / Capacidad |
| Source (Fuente) | Cliente creando una solicitud de servicio |
| Stimulus (Estímulo) | Pide ver los aliados disponibles para su categoría y zona, en hora pico |
| Artifact (Artefacto) | Módulo de búsqueda y listado de aliados |
| Environment (Entorno) | Producción, pico de tráfico |
| Response (Respuesta) | El sistema muestra el listado de aliados válidos, ordenado según la regla configurada por el tenant |
| Response Measure (Medida) | Objetivo propuesto: listado entregado en menos de 1 segundo con 20 usuarios buscando a la vez; pendiente validar con volumen real |
| Prioridad / Impacto / Complejidad | Alta / Alto / Alta |

**QS-09 — Mód. 4 — Ciclo servicio (RF-14)**

| Campo | Valor |
|---|---|
| Atributo | Fiabilidad / Tolerancia a fallos |
| Source (Fuente) | Varios aliados recibiendo la misma solicitud a la vez |
| Stimulus (Estímulo) | Dos o más aliados aceptan la solicitud al mismo tiempo |
| Artifact (Artefacto) | Tabla solicitud (columnas status, aliado_id) |
| Environment (Entorno) | Producción, alta concurrencia (la solicitud se envía a todos los aliados válidos a la vez) |
| Response (Respuesta) | El sistema asigna la solicitud a un solo aliado y avisa "ya no disponible" a los demás |
| Response Measure (Medida) | Exactamente 1 asignación válida por solicitud en el 100% de los casos; el aliado recibe respuesta en menos de 500 ms |
| Prioridad / Impacto / Complejidad | Alta / Alto / Media |

**QS-10 — Mód. 4 — Ciclo servicio (RF-15, RF-16)**

| Campo | Valor |
|---|---|
| Atributo | Idoneidad funcional / Corrección |
| Source (Fuente) | Aliado elaborando una cotización |
| Stimulus (Estímulo) | Ingresa el valor de mano de obra y materiales, y el total queda fuera del rango de tarifas del tenant |
| Artifact (Artefacto) | Formulario de cotización + tarifario de referencia |
| Environment (Entorno) | Producción, operación normal |
| Response (Respuesta) | El sistema muestra una alerta visible antes de que el aliado envíe la cotización |
| Response Measure (Medida) | 100% de las cotizaciones fuera de rango muestran la alerta antes del envío; el evento queda disponible para el reporte de QS-15 |
| Prioridad / Impacto / Complejidad | Media / Medio / Baja |

**QS-11 — Mód. 4 — Ciclo servicio (RF-17)**

| Campo | Valor |
|---|---|
| Atributo | Fiabilidad / Tolerancia a fallos (idempotencia) |
| Source (Fuente) | Cliente revisando una cotización, con conexión inestable |
| Stimulus (Estímulo) | Toca "aceptar" y, por un reintento de red, el sistema recibe la misma acción dos veces |
| Artifact (Artefacto) | Capa de API con clave de idempotencia por solicitud |
| Environment (Entorno) | Producción, condición de red inestable |
| Response (Respuesta) | El sistema procesa la aceptación una sola vez, sin duplicar el efecto |
| Response Measure (Medida) | 0 aceptaciones duplicadas en el 100% de reintentos con la misma clave de idempotencia |
| Prioridad / Impacto / Complejidad | Media / Medio / Baja |

**QS-12 — Mód. 4 — Ciclo servicio (RF-18)**

| Campo | Valor |
|---|---|
| Atributo | Seguridad / No repudio |
| Source (Fuente) | Cualquier actor del ciclo de servicio (Cliente, Aliado, Admin. tenant) |
| Stimulus (Estímulo) | Ocurre un evento relevante del servicio (cambio de estado, mensaje, cotización) |
| Artifact (Artefacto) | Log cronológico del servicio |
| Environment (Entorno) | Producción |
| Response (Respuesta) | El sistema registra el evento con actor, fecha/hora y descripción, visible en la línea de tiempo del servicio |
| Response Measure (Medida) | 100% de los eventos del ciclo de servicio quedan registrados; tiempo de escritura < 200 ms adicionales sobre la operación original |
| Prioridad / Impacto / Complejidad | Media / Alto / Media |

**QS-13 — Mód. 4 — Ciclo servicio (RF-19)**

| Campo | Valor |
|---|---|
| Atributo | Fiabilidad / Tolerancia a fallos (idempotencia) |
| Source (Fuente) | Cliente o Aliado al cierre del servicio |
| Stimulus (Estímulo) | Envía su calificación del otro actor |
| Artifact (Artefacto) | Módulo de calificación mutua |
| Environment (Entorno) | Producción, cierre del servicio |
| Response (Respuesta) | El sistema guarda una sola calificación por actor y por servicio, incluso si el botón se toca más de una vez |
| Response Measure (Medida) | Máximo 1 calificación registrada por actor y servicio en el 100% de los casos |
| Prioridad / Impacto / Complejidad | Media / Medio / Baja |

**QS-14 — Mód. 5 — Comunicación (RF-20, RF-21)**

| Campo | Valor |
|---|---|
| Atributo | Compatibilidad / Interoperabilidad |
| Source (Fuente) | Cliente o Aliado con un servicio activo |
| Stimulus (Estímulo) | Envía un mensaje, o se genera una notificación del ciclo de servicio |
| Artifact (Artefacto) | Supabase Realtime (Broadcast) + servicio de push (FCM/APNs) |
| Environment (Entorno) | Producción, app en primer o segundo plano |
| Response (Respuesta) | El mensaje llega por WebSocket si el otro actor está conectado, o por notificación push si no lo está |
| Response Measure (Medida) | Latencia de entrega < 2 s en clientes conectados; 100% de mensajes con al menos un canal de entrega exitoso |
| Prioridad / Impacto / Complejidad | Media / Medio / Media |

**QS-15 — Mód. 6 — Tarifario (RF-22, RF-23)**

| Campo | Valor |
|---|---|
| Atributo | Mantenibilidad / Analizabilidad |
| Source (Fuente) | Admin. tenant |
| Stimulus (Estímulo) | Consulta el reporte de cotizaciones fuera de rango en un período |
| Artifact (Artefacto) | Módulo de reportes, con filtro por fecha |
| Environment (Entorno) | Producción, operación normal |
| Response (Respuesta) | El sistema entrega la tabla filtrada, apoyada en los eventos registrados en QS-10 |
| Response Measure (Medida) | Reporte generado en menos de 3 segundos para un rango de hasta 12 meses |
| Prioridad / Impacto / Complejidad | Media / Medio / Baja |

**QS-16 — Transversal (todos los módulos)**

| Campo | Valor |
|---|---|
| Atributo | Fiabilidad / Disponibilidad |
| Source (Fuente) | Infraestructura (Supabase, hosting del backend Serverpod) |
| Stimulus (Estímulo) | Falla o cae un componente (base de datos, backend, Storage) |
| Artifact (Artefacto) | Sistema completo (backend + Supabase) |
| Environment (Entorno) | Producción, horario operativo del tenant |
| Response (Respuesta) | El sistema se recupera automáticamente o entra en modo degradado documentado |
| Response Measure (Medida) | Disponibilidad objetivo ≥ 99.5% mensual (≈ 3.6 h de indisponibilidad/mes); tiempo de detección de fallo < 5 min |
| Prioridad / Impacto / Complejidad | Media / Alto / Media |

**QS-17 — Transversal (protege RF-01 a RF-28)**

| Campo | Valor |
|---|---|
| Atributo | Mantenibilidad / Verificabilidad |
| Source (Fuente) | Cualquier integrante del equipo de desarrollo |
| Stimulus (Estímulo) | Un Pull Request modifica autenticación, políticas RLS o el esquema de datos |
| Artifact (Artefacto) | Pipeline de CI (GitHub Actions + Newman) |
| Environment (Entorno) | Pipeline de CI, antes de fusionar a la rama principal |
| Response (Respuesta) | GitHub Actions ejecuta automáticamente la colección Postman de aislamiento multi-tenant |
| Response Measure (Medida) | 6 casos de prueba ejecutados en el 100% de los PR que tocan auth/RLS/esquema; el pipeline bloquea el merge si algún caso falla |
| Prioridad / Impacto / Complejidad | Alta / Alto / Media |

**QS-18 — Transversal (todos los módulos)**

| Campo | Valor |
|---|---|
| Atributo | Mantenibilidad / Analizabilidad |
| Source (Fuente) | Cualquier servicio instrumentado |
| Stimulus (Estímulo) | Ocurre una anomalía o error en producción |
| Artifact (Artefacto) | Stack de observabilidad (Prometheus + Grafana + Datadog) |
| Environment (Entorno) | Producción |
| Response (Respuesta) | El sistema genera una alerta y, para anomalías críticas, crea automáticamente un issue en Jira |
| Response Measure (Medida) | Tiempo de detección de la anomalía < 5 min desde que ocurre; tasa de falsos positivos aún sin umbral definido |
| Prioridad / Impacto / Complejidad | Media / Alto / Alta |

**QS-19 — Transversal (RF-12, flujo crítico)**

| Campo | Valor |
|---|---|
| Atributo | Usabilidad / Capacidad de aprendizaje |
| Source (Fuente) | Cliente o Aliado nuevo, primera sesión en la app |
| Stimulus (Estímulo) | Completa su primer flujo crítico (solicitar un servicio / aceptar una solicitud) |
| Artifact (Artefacto) | Interfaz de usuario (Flutter) |
| Environment (Entorno) | Primer uso, sin capacitación previa |
| Response (Respuesta) | El usuario completa el flujo guiado por la interfaz, sin soporte externo |
| Response Measure (Medida) | ≥ 80% de usuarios nuevos completan el flujo crítico sin abandonar en su primera sesión; tiempo promedio < 3 min |
| Prioridad / Impacto / Complejidad | Media / Medio / Baja |

**QS-20 — Transversal (todos los módulos)**

| Campo | Valor |
|---|---|
| Atributo | Portabilidad / Adaptabilidad |
| Source (Fuente) | Cliente o Aliado instalando/usando la app |
| Stimulus (Estímulo) | Abre la aplicación desde Android o iOS |
| Artifact (Artefacto) | Cliente Flutter |
| Environment (Entorno) | Dispositivo móvil del usuario final |
| Response (Respuesta) | La aplicación se ejecuta con la misma base de código, sin rama de plataforma específica |
| Response Measure (Medida) | 1 sola base de código para Android e iOS; 0 líneas de UI condicionadas por plataforma fuera de lo estrictamente necesario |
| Prioridad / Impacto / Complejidad | Baja / Medio / Baja |

> Cobertura funcional: los 24 escenarios cubren RF-01 a RF-28 completos — RF-01 a RF-23 (MVP) en QS-01 a QS-15, y RF-24 a RF-28 (2º incremento) en QS-21 a QS-24. QS-16 a QS-20 son transversales: no prueban un RF puntual, sino una condición de calidad que protege a todos los módulos a la vez.

---

## 6. Trade-offs

**Trade-offs Explícitos**

*Tensiones documentadas entre escenarios de calidad y la decisión tomada o propuesta*

**Tabla A — Escenarios en tensión**

| ID | Escenarios en tensión |
|---|---|
| TO-01 | QS-02 (Confidencialidad, login) vs. QS-08 (Capacidad, búsqueda) |
| TO-02 | QS-02 (Confidencialidad) vs. QS-07 (Adaptabilidad, catálogo/config) |
| TO-03 | QS-09 (Tolerancia a fallos, despacho) vs. QS-16 (Disponibilidad) |
| TO-04 | QS-16 (Disponibilidad) vs. QS-18 (Analizabilidad) |
| TO-05 | QS-07 (Adaptabilidad) vs. QS-17 (Verificabilidad) |
| TO-06 | QS-02 (Confidencialidad) vs. QS-14 (Interoperabilidad, mensajería) |
| TO-07 | QS-07 (Adaptabilidad) vs. QS-19 (Aprendizaje) |
| TO-08 | QS-17 (Verificabilidad) vs. QS-08 (Capacidad) |

**Tabla B — Naturaleza de la tensión**

| ID | Naturaleza de la tensión |
|---|---|
| TO-01 | RLS evalúa una política en cada consulta; a mayor número de políticas y tablas protegidas, mayor costo de cómputo por request, presionando la latencia bajo carga |
| TO-02 | Cuanto más configurable es una regla por tenant, más difícil es garantizar que ninguna combinación de configuración rompa el aislamiento |
| TO-03 | El UPDATE atómico exige que la base de datos esté disponible en el momento exacto del despacho; si la base cae, el despacho completo se detiene |
| TO-04 | Más agentes de observabilidad (Prometheus/Datadog) consumen recursos de cómputo que compiten con el servicio principal |
| TO-05 | Más puntos de configuración por tenant significan más combinaciones que la suite de pruebas debe cubrir |
| TO-06 | Reutilizar RLS como mecanismo de autorización de canal en mensajería (ADR-0017) acopla la seguridad del canal en tiempo real a la misma política que protege los datos |
| TO-07 | Mientras más configurable es la plataforma para el Admin. tenant, más superficie de interfaz debe aprender un usuario no técnico |
| TO-08 | Ejecutar 6+ casos de prueba en cada PR que toque auth/RLS/esquema añade tiempo al pipeline de CI, no al sistema en producción |

**Tabla C — Decisión tomada / propuesta**

| ID | Decisión tomada / propuesta |
|---|---|
| TO-01 | Se acepta el costo de RLS porque DR-01 es innegociable (Crítica); si QS-08 se degrada, la mitigación es indexación y no relajar RLS (ADR-0012) |
| TO-02 | La configurabilidad (QS-07) debe validarse contra la misma suite de QS-17 antes de habilitarse — no se resuelve, se declara como requisito cruzado |
| TO-03 | Aceptado — no hay cola de reintento diseñada todavía; queda como deuda técnica declarada (ver KI-06) |
| TO-04 | Aceptado como costo operativo; ADR-0006 lo reconoce explícitamente como desventaja de la opción elegida |
| TO-05 | Se declara que la suite de QS-17 debe crecer junto con cada nueva regla configurable — no queda como pendiente, es una regla del proceso |
| TO-06 | Aceptado deliberadamente porque evita duplicar lógica de autorización (ADR-0017), a cambio de concentrar el riesgo en un solo mecanismo |
| TO-07 | Sin decisión tomada — se deja como tensión abierta para que la Mesa la resuelva junto con el diseño de UX |
| TO-08 | Aceptado — el costo se paga en CI, no en producción; ADR-0015 no lo considera bloqueante |

---

## 7. Arquitectura_de_Negocio

**Diseño de Arquitectura de Negocio**

*Capacidades, actores, cadena de valor y procesos que sustentan los Drivers (§1) y se
traducen en los Escenarios de Calidad (§5). Fuente: SRS_MANI.md §2, Analisis_de_
Requerimientos.md §1-3, Perfil_de_Proyecto_MANI.md §2-3, Glosario_Terminos_MANI.md. No
introduce actores, procesos ni entidades que no existan ya en esos documentos.*

### 7.0 Diagramas de esta sección

| # | Diagrama | Ruta | Descrito en | Estado |
|---|---|---|---|---|
| 1 | Mapa de capacidades de negocio | `Diagramas/Negocio/v1/MAPA DE CAPACIDADES.jpg` | §7.3 | 🟢 Incluido |
| 2 | Cadena de valor del ciclo del servicio | `Diagramas/Negocio/v1/CADENA DE VALOR.jpg` | §7.4 | 🟢 Incluido |
| 3 | BPMN — Alta y verificación de aliado | `Diagramas/Negocio/v1/VERIFICACION ALIADO.jpg` | §7.5.1 | 🟢 Incluido |
| 4 | BPMN — Ciclo completo del servicio | `Diagramas/Negocio/v1/BPMN CICLO SERVICIO.jpg` | §7.5.2 | 🟢 Incluido |
| 5 | Modelo de dominio conceptual | `Diagramas/Negocio/negocio-modelo-dominio_conceptual_v1.png` (+ `.mmd`) | §7.6 | 🔴 Pendiente |

Convención de nombres y carpeta según ADR-0008 (`[tipo]_[nombre-descriptivo]_v[N]`);
`Diagramas/Negocio/` es la tercera subcarpeta junto a `c4` y `flujos`, porque un mapa de
capacidades y un modelo de dominio conceptual no son ni diagramas C4 ni diagramas de flujo
técnico. Los 4 diagramas ya provistos viven en `Diagramas/Negocio/v1/` (existe además una
carpeta `v2/` vacía, reservada para su próxima revisión); pendiente renombrarlos a la
convención `[tipo]_[nombre-descriptivo]_v[N]` de ADR-0008 cuando se regeneren desde la
fuente.

### 7.1 Contexto de negocio

MANI tiene una **doble naturaleza de negocio**: TRAMA opera MANI como plataforma SaaS
multi-tenant que se ofrece a terceros, y el cliente actual del proyecto opera su propia
empresa de servicios sobre esa misma plataforma como su **primer tenant**. Cada tenant
(empresa suscrita) mantiene datos, configuración y usuarios estrictamente aislados de los
demás (RNF-01). El problema de negocio que resuelve MANI es la formalización digital de una
operación hoy informal (coordinación por WhatsApp y llamadas, sin trazabilidad ni
auditabilidad) mediante un ciclo de servicio completo: solicitud, cotización, ejecución,
calificación y cierre.

### 7.2 Actores de negocio

| Actor | Rol de negocio | Gobierna / configura |
|---|---|---|
| Administrador de plataforma | Opera MANI como negocio SaaS; no participa en la operación diaria de un tenant | Alta y estado de tenants |
| Administrador de tenant | Dueño operativo de la empresa suscrita | Categorías de servicio, tarifas, documentos KYC exigidos, orden del listado, comisión |
| Aliado (persona natural / empresa / empleado directo) | Presta el servicio | Zonas de cobertura, categorías atendidas, cotización, ejecución |
| Cliente (persona natural / empresa) | Solicita el servicio; el cliente empresa administra múltiples sitios | Sitios de servicio, aceptación/ajuste de cotización, calificación |

> Matriz completa de actor × función (quién hace qué en cada capacidad): ver
> `SRS_MANI.md` §2.2.1 — no se duplica aquí para evitar que ambos documentos diverjan.

### 7.3 Mapa de capacidades de negocio

| Dominio de negocio | Capacidad | Módulo | Épica | Incremento |
|---|---|---|---|---|
| Plataforma | Gestión de tenants y aislamiento | M-01 | EP-01 | MVP |
| Identidad | Autenticación y control de acceso por rol/tenant | M-01 | EP-01 | MVP |
| Directorio | Registro y verificación de aliados (KYC) | M-02 | EP-02 | MVP |
| Directorio | Registro de clientes y sitios de servicio | M-03 | EP-02 | MVP |
| Catálogo | Categorías de servicio y reglas de cobertura | M-04 | EP-03 | MVP |
| Ciclo de servicio | Despacho y asignación de solicitudes | M-05..M-08 | EP-04 | MVP |
| Ciclo de servicio | Cotización y ajuste | M-05..M-08 | EP-04 | MVP |
| Ciclo de servicio | Ejecución y trazabilidad (log) | M-05..M-08 | EP-04 | MVP |
| Ciclo de servicio | Calificación bidireccional | M-05..M-08 | EP-04 | MVP |
| Comunicación | Mensajería y notificaciones | M-09 | EP-05 | MVP |
| Tarifario | Tarifas de referencia y reportes de desviación | M-11 | EP-06 | MVP |
| Financiero | Cobro y liquidación | M-10 | EP-07 | 2º incremento |
| Operación | Quejas, comercialización, administración avanzada | M-12..M-14 | EP-08 | 2º incremento |

**📊 Mapa de capacidades de negocio (Business Capability Map).**
Cuadrícula de las 13 capacidades de la tabla anterior, agrupadas por dominio, con distinción
visual entre capacidades MVP vigentes y capacidades de 2º incremento fuera de este corte.

![Mapa de capacidades de negocio](<../Diagramas/Negocio/v1/MAPA DE CAPACIDADES.jpg>)

### 7.4 Cadena de valor del ciclo del servicio

| Etapa | Actor que dispara | Entrada | Resultado / Salida | RF relacionados |
|---|---|---|---|---|
| Solicitud | Cliente | Categoría + sitio con zona | Solicitud visible a aliados válidos (match de cobertura) | RF-12, RF-13 |
| Despacho | Sistema (broadcast) | Solicitud creada | Exactamente 1 aliado asignado, resto notificado "ya no disponible" | RF-14, RNF-05 |
| Cotización | Aliado | Solicitud asignada | Cotización (mano de obra + materiales separados) | RF-15, RF-16 |
| Aceptación de cotización | Cliente | Cotización enviada | Cotización aceptada, rechazada o ajustada | RF-17 |
| Ejecución | Aliado | Cotización aceptada | Log cronológico de eventos del servicio | RF-18 |
| Calificación y cierre | Cliente y Aliado | Servicio ejecutado | Calificación bidireccional; el servicio no cierra hasta que ambas partes califiquen | RF-19 |

**📊 Cadena de valor / Value Stream Map del ciclo del servicio.**
Flujo horizontal de las 6 etapas de la tabla anterior, con el actor y el artefacto de negocio
bajo cada etapa; marcar explícitamente el punto de despacho concurrente (broadcast, ver
ADR-0016) como una bifurcación, no un paso lineal más.

![Cadena de valor del ciclo del servicio](<../Diagramas/Negocio/v1/CADENA DE VALOR.jpg>)

### 7.5 Procesos de negocio clave

#### 7.5.1 Alta y verificación de aliado

El aliado se registra diferenciando persona natural, empresa o empleado directo, y adjunta
los documentos KYC que exige el tenant (configurables, RF-05). El registro entra a una
bandeja de verificación del administrador de tenant, quien lo aprueba o rechaza (RF-06); los
documentos de un aliado nunca son visibles para otro aliado del mismo tenant ni para usuarios
de otro tenant (REST-02).

**📊 BPMN: Alta y verificación de aliado.**
Swimlanes: Aliado / Administrador de tenant / Sistema. Incluir el nodo de decisión
aprobar/rechazar y los documentos KYC como artefacto adjunto al registro.

![BPMN — Alta y verificación de aliado](<../Diagramas/Negocio/v1/VERIFICACION ALIADO.jpg>)

#### 7.5.2 Ciclo completo del servicio

Desde la creación de la solicitud hasta el cierre: la solicitud se presenta simultáneamente a
todos los aliados válidos (broadcast); el sistema resuelve la primera aceptación como
asignación única y notifica al resto (ADR-0016); el aliado cotiza y el cliente puede aceptar,
rechazar o pedir ajuste (bucle, RF-17); durante la ejecución se registra cada evento
(RF-18); el cierre queda condicionado a que ambas partes hayan calificado (join, RF-19).

**📊 BPMN: Ciclo completo del servicio (solicitud→cierre).**
Swimlanes: Cliente / Aliado(s) / Sistema. Incluir el gateway paralelo de despacho con
resolución "primera aceptación válida", el bucle de ajuste de cotización, y el join de
calificación bidireccional antes del cierre.

![BPMN — Ciclo completo del servicio](<../Diagramas/Negocio/v1/BPMN CICLO SERVICIO.jpg>)

### 7.6 Modelo de dominio conceptual

Entidades de negocio y sus relaciones, a nivel conceptual — sin tipos de dato ni claves
técnicas, eso corresponde al Documento de Diseño (DD), no al SAD:

- **Tenant** (1) —< **Usuario** (con rol: Admin. tenant, Aliado, Cliente)
- **Tenant** (1) —< **Aliado** ; **Tenant** (1) —< **Cliente**
- **Cliente** (1) —< **Sitio** de servicio
- **Aliado** (N) —< **Zona de cobertura** (M) ; **Aliado** (N) —< **Categoría** (M)
- **Solicitud** (1) → **Cotización** (1) → **Ejecución** (1..N eventos de log) →
  **Calificación** (1..2, una por parte)
- **Categoría** (1) —< **Tarifa de referencia**

**📊 Diagrama pendiente 5 — Modelo de dominio conceptual (diagrama de clases de negocio).**
Entidades: Tenant, Usuario, Aliado, Cliente, Sitio, Categoría, Zona de Cobertura, Solicitud,
Cotización, Evento, Calificación, Tarifa, con las cardinalidades listadas arriba.

### 7.7 Trazabilidad: negocio → arquitectura técnica

| Capacidad de negocio | Contenedor C4 / Repo | ADR relacionado |
|---|---|---|
| Gestión de tenants y aislamiento | Backend Serverpod + Supabase (RLS) | ADR-0012, ADR-0018 |
| Directorio de aliados / KYC | Supabase Storage + Backend | ADR-0013 |
| Catálogo y cobertura | Backend / catálogo de zonas en base de datos | ADR-0011 |
| Despacho de solicitudes | Backend Serverpod (UPDATE condicional atómico) | ADR-0016 |
| Mensajería y notificaciones | Supabase Realtime + FCM/APNs | ADR-0017 |
| Reglas de negocio empresariales | Repo B — microservicio Java | ADR-0004, ADR-0019, ADR-0021 |
| Transaccional de alta concurrencia | Repo C — microservicio .NET | ADR-0004, ADR-0019, ADR-0021 |

---
## 7. Vista de Contenedores
 
**Diagrama C4 — Nivel 2 (Contenedores)**
 
*Vista de alto nivel de la arquitectura de MANI: cliente móvil, backend principal, infraestructura
compartida de CI/CD y observabilidad, y los módulos adicionales exigidos por el enunciado del
proyecto (PROY-07).*
 
<img width="3744" height="1150" alt="c4-contenedores_arquitectura-alto-nivel_v1" src="https://github.com/user-attachments/assets/c2c0ea8e-9dc2-42b1-b31b-c719c4a693fc" />

 

diagramas/c4/c4-contenedores_arquitectura-alto-nivel_v1.jpg` — ver ADR-0008 para
convención de versionado.*
 
### Lectura del diagrama
 
| Bloque | Contenido | ADR / requerimiento relacionado |
|---|---|---|
| Cliente | Flutter App (Android/iOS) | PROY-07 (constraint de plataforma), RNF-08 |
| Backend principal | Serverpod (Dart) + Supabase PostgreSQL/RLS + Supabase Storage (KYC) + Supabase Realtime Broadcast | ADR-0012, ADR-0013, ADR-0017 |
| Infraestructura compartida | SonarQube + OWASP ZAP (SAST/DAST) ×2, Prometheus + Grafana + Datadog, GitHub Actions CI/CD multi-repositorio, FCM/APNs | ADR-0004, ADR-0005, ADR-0006 |
| Módulos adicionales | Módulo en Java Spring, Módulo en .NET, persistencia del módulo (pendiente de definir) | PROY-07 (constraint crítico), ADR-0004 |

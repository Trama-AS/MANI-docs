# MANI SAD

## Índice

1. [Drivers](#1-drivers)
2. [Killers](#2-killers)
3. [ADR](#3-adr)
4. [Atributos_Calidad](#4-atributos-calidad)
5. [Escenarios_Calidad](#5-escenarios-calidad)
6. [Trade-offs](#6-trade-offs)

---

## 1. Drivers

**Drivers Arquitectónicos**

*Objetivos de Diseño: qué debe lograr la arquitectura de MANI (Parte 1.1 del SAD)*

| # | Descripción del driver | Prioridad | Fuente (trazabilidad) |
|---|---|---|---|
| 1 | Registro y administración de tenants con aislamiento de datos garantizado. | Crítica | RF-01 |
| 2 | Configuración de reglas propias por tenant (documentos, orden de listado, categorías, tarifas) sin desarrollo específico. | Crítica | RF-02 |
| 3 | Autenticación y control de acceso restringido por tenant y por rol. | Crítica | RF-03 |
| 4 | Registro de aliados diferenciando persona natural, empresa y empleado directo, con documentos configurables por tenant. | Crítica | RF-05 |
| 5 | Declaración de cobertura de aliados por zonas geográficas, no por radio. | Alta | RF-07 |
| 6 | Creación de solicitudes de servicio y presentación de aliados válidos según categoría y cobertura. | Crítica | RF-12 |
| 7 | Ordenamiento del listado de aliados según regla configurable por tenant (cobertura, calificación o comisión). | Alta | RF-13 |
| 8 | Aceptación/rechazo de solicitud por el aliado, sin dobles asignaciones. | Crítica | RF-14 |
| 9 | Elaboración de cotización (mano de obra y materiales separados) y su aceptación/rechazo/ajuste por el cliente. | Alta | RF-15 / RF-17 |
| 10 | Registro cronológico de eventos durante la ejecución (log del servicio). | Media | RF-18 |
| 11 | Calificación bidireccional cliente–aliado al cierre del servicio. | Media | RF-19 |
| 13 | Aislamiento estricto de datos; un usuario o mecanismo de acceso de un tenant no puede acceder a información de otro. | Crítica | RNF-01 |
| 14 | Cada tenant configura sus reglas sin requerir código específico ni nuevo despliegue de la plataforma. | Crítica | RNF-02 |
| 15 | Idempotencia en operaciones críticas (aceptar solicitud, aceptar cotización, calificar) ante reintentos. | Alta | RNF-03 |
| 16 | El despacho debe resolver aceptaciones concurrentes garantizando exactamente una asignación válida. | Alta | RNF-05 |
| 17 | Soportar concurrencia de usuarios en búsqueda de aliados y comunicación (candidato a riesgo crítico de diseño). | Media | RNF-07 |
| 18 | Trazabilidad suficiente para reconstruir eventos del ciclo del servicio; registro financiero inmutable en el 2º incremento. | Alta | RNF-04 |
| 19 | Interfaz utilizable desde dispositivos móviles por clientes y aliados. | Media | RNF-08 |
| 20 | Cobertura declarada por zonas, no por radio geográfico. | Alta | RNF-09 |
| 21 | KYC, tiempos y comisiones configurables por tenant, no codificados. | Alta | RNF-10 |
| 22 | Responsabilidad PCI-DSS delegada al operador de pagos certificado; modelo de pagos centralizado, priorizando integración sobre construcción propia. | Alta | RNF-06 / RNF-11 |

---

## 2. Killers

**Killers Arquitectónicos**

*Objetivos de Diseño: limitaciones y riesgos que pueden invalidar la arquitectura (Parte 1.2 del SAD)*

| ID | Killer | Categoría | Descripción | Mitigación / Estado |
|---|---|---|---|---|
| KI-01 | MongoDB sin RLS nativo | Incompatibilidad técnica | El backend propuesto originalmente (MongoDB) no soporta RLS, quedando incompatible con DR-01 | Resuelto — migración completa a PostgreSQL/Supabase (ADR-0012) |
| KI-03 | Costo de Kubernetes (~$450–650 USD/mes) sin driver que lo justifique | Restricción económica | Veto explícito por costo-beneficio, no por incapacidad técnica | Abierto, pospuesto deliberadamente (ADR-0010) |
| KI-04 | Ventana de riesgo entre revisiones manuales de seguridad | Seguridad de proceso | Sin automatización, un cambio que rompa el aislamiento puede llegar a producción sin detectarse, alguien puede pasar devops a main sin revision | Mitigación diseñada, ADR-0015 aún Propuesto |
| KI-05 | Aislamiento en Storage depende de la disciplina del backend al construir la ruta | Seguridad | La ruta tenant_id/aliado_id/archivo no tiene límite físico de respaldo como un bucket separado Hacer bien las conexiones entre repositorios "Clean Arqui"  para hacer el llamado correcto | Riesgo residual aceptado conscientemente (ADR-0013) |
| KI-06 | Volumen de tenants desconocido | Escalabilidad | Condiciona si el aislamiento lógico por RLS sobre esquema compartido basta a futuro, o si hará falta separar por base/esquema | No resuelto — deuda declarada (ADR-0012) |
| KI-07 | Sin soporte para cobertura parcial de una localidad | Limitación de producto | El modelo de zonas obliga a declarar la localidad completa o nada | Aceptado con condiciones explícitas de reapertura (ADR-0011) |
| KI-08 | Dependencia de datos oficiales de división político-administrativa | Dependencia externa | El modelo de zonas depende de que exista esa información por ciudad | Degrada a nivel ciudad si no existe (ADR-0011) |
| KI-09 | Volumen concurrente de búsqueda + mensajería sin cifra conocida | Rendimiento | RNF-07 señalado como riesgo crítico en el SRS pese a prioridad Media, sin volumen definido para fijar umbrales | Sin resolver — Análisis de Requerimientos §7 no fija cifra |
| KI-10 | ADR-0016/0017 incompletos (Redactor, Disenso, Quórum [completar]) | Gobernanza | No cumplen el checklist de cierre del Gobierno del Equipo §2.6, pese a que ya se están usando como base de diseño | Abierto — requiere sesión formal de la Mesa |
| KI-11 | Observabilidad instrumentada sobre Java Spring/.NET, en riesgo si prevalece Dart/Serverpod | Mantenibilidad | La instrumentación completa (ADR-0006) quedaría sin destinatario técnico si KI-02 se resuelve a favor de ADR-0012 | Depende directamente de que se cierre KI-02 |

---

## 3. ADR

**ADR Consolidados**

*Los 15 ADR reales del repositorio Trama-AS/MANI-docs (no existe ADR-0014)*

| ADR | Título | Estado | Decisión (resumen) | Alternativas descartadas | Objetivo de Diseño | AC / Escenario | Trade-off |
|---|---|---|---|---|---|---|---|
| ADR-0001 | Gestión documental | 🟢 Aceptado | GitHub (código/ADR) + OneDrive (documentos formales), dividido por tipo de contenido | Todo en GitHub; Confluence + Jira | DR-11 | — | — |
| ADR-0002 | Herramientas de gestión: Jira | 🟢 Aceptado | Jira para gestión de proyecto + GitHub para lo técnico, separados | Todo en GitHub Projects; GitLab Issues | DR-08 | — | — |
| ADR-0003 | Mesa de Arquitectura | 🟢 Aceptado | Mesa con Arquitecto transversal y rotación de autoría de ADR; quórum 5/7, disenso documentado | Responsable único (SM); sin reglamento formal | DR-09 | — | — |
| ADR-0004 | Pipeline CI/CD multi-repositorio | 🔴 En contradicción | GitHub Actions + Webhooks Jira↔GitHub + promoción de contenedores en Azure, sobre 3 repos (Flutter/Java/.NET) | Monorepositorio; Jenkins auto-hospedado | DR-08 | — | Base de KI-02 |
| ADR-0005 | DevSecOps: SAST + DAST | 🔴 En contradicción | SonarQube (SAST) + OWASP ZAP (DAST) en GitHub Actions, sobre Flutter/Java/.NET | Revisión manual; plataformas comerciales unificadas | DR-07 | — | Base de KI-02 |
| ADR-0006 | Observabilidad | 🔴 En contradicción | Prometheus + Grafana + Datadog, instrumentando Java Spring/.NET en Azure | Stack ELK auto-alojado; Azure Monitor/App Insights exclusivo | KI-11 | AC-11 / QS-18 | TO-04 |
| ADR-0007 | Documentación en el repositorio | 🟢 Aceptado | Carpeta /docs versionada junto al código, reemplaza Confluence/Drive/Discord | Confluence como fuente única; Google Drive compartido | DR-11 | — | — |
| ADR-0008 | Carpeta de diagramas | 🟢 Aceptado | /docs/diagramas con subcarpetas por tipo; Mermaid versionado como texto (.mmd) | Solo en herramientas de origen (Figma/Miro); imágenes sueltas en Confluence | DR-11 | — | — |
| ADR-0009 | Política de uso de IA | 🟢 Aceptado | Uso de IA permitido bajo lineamientos del equipo; ninguna sugerencia de IA es decisión válida sin pasar por la Mesa | Prohibición total; uso libre sin lineamientos | DR-09 | — | — |
| ADR-0010 | Tech Radar del proyecto | 🟢 Aceptado | Radar visual consolidado (círculos de confianza, cuadrantes por categoría); Kubernetes en "Tal vez" por costo | Mantener disperso en ADR individuales | KI-03 | — | — |
| ADR-0011 | Modelo de cobertura geográfica | 🟢 Aceptado | Catálogo de zonas administrativas, relación N:M aliado↔zona, sin geometría propia | Radio de cobertura; polígonos dibujados; catálogo con geometría asociada | DR-02, DR-03 | AC-01 / QS-05 | KI-07, KI-08 |
| ADR-0012 | Backend Dart, motor de persistencia y aislamiento multi-tenant | 🔴 En contradicción | Serverpod (Dart) + Supabase (PostgreSQL) + RLS nativo | NestJS+MongoDB; BaaS puro; filtrado manual sin RLS; base/esquema separado por tenant | DR-01 | AC-01, AC-02 / QS-02 | TO-01, TO-02, TO-06 · resuelve KI-01 · abre KI-02, KI-06 |
| ADR-0013 | Almacenamiento de documentos KYC | 🟡 Propuesto | Bucket único de Storage con ruta tenant_id/aliado_id/archivo + RLS sobre storage.objects | Bucket privado por tenant; aislamiento solo en capa de aplicación | DR-05, DR-01 | AC-01 / QS-04 | KI-05 |
| ADR-0015 | Estrategia de pruebas de aislamiento multi-tenant | 🟡 Propuesto | Colección Postman con 6 casos de acceso cruzado, automatizada con Newman en GitHub Actions | Revisión manual periódica; k6 u OWASP ZAP | DR-06 | AC-10 / QS-17 | TO-05, TO-08 · mitiga KI-04 |
| ADR-0016 | Estrategia de despacho de solicitudes | 🟡 Propuesto, incompleto | Despacho simultáneo (broadcast) con UPDATE condicional atómico | Despacho secuencial según orden de RF-13 | DR-04 | AC-04 / QS-09 | TO-03 · pendiente en KI-10 |
| ADR-0017 | Mensajería y notificaciones en tiempo real | 🟡 Propuesto, condicionado | Supabase Realtime (Broadcast) + push notifications (FCM/APNs) | WebSockets propios (Socket.io); Polling | — | AC-13 / QS-14 | TO-06 · pendiente en KI-10 |

> ⚠ Hallazgo transversal: ADR-0004/0005/0006 (Java/.NET/Azure) y ADR-0012 (Dart/Serverpod/Supabase) están Aceptados a la vez y son mutuamente excluyentes — ver KI-02. Ningún ADR posterior declara supersedes sobre el otro.

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

| ID | Módulo | RF cubiertos | Atributo (Categoría / Subcategoría) | Source (Fuente) | Stimulus (Estímulo) | Artifact (Artefacto) | Environment (Entorno) | Response (Respuesta) | Response Measure (Medida) | Prioridad | Impacto | Complejidad |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| QS-01 | Mód. 1 — Acceso | RF-01 | Seguridad / Confidencialidad | Admin. plataforma | Da de alta una nueva empresa (tenant) en la plataforma | Módulo de administración de tenants | Producción, operación normal | El sistema crea el tenant con su propio espacio de datos, aislado desde el primer momento | El tenant queda operativo en menos de 5 minutos; 0 datos de otros tenants visibles desde su creación | Alta | Alto | Media |
| QS-02 | Mód. 1 — Acceso | RF-03 | Seguridad / Confidencialidad | Usuario ya registrado (Cliente, Aliado o Admin.) | Inicia sesión y navega la app | Capa de acceso a datos (RLS en Supabase) + módulo de autenticación | Producción, uso normal | El sistema autentica al usuario y solo le muestra datos del tenant al que pertenece | 0 registros de otro tenant visibles en el 100% de 6 pruebas automáticas de acceso cruzado, ejecutadas en cada cambio que toque autenticación, RLS o el esquema | Alta | Alto | Media |
| QS-03 | Mód. 1 — Acceso | RF-04 | Seguridad / Autenticación | Usuario que olvidó su contraseña | Solicita recuperar el acceso a su cuenta | Flujo de recuperación de contraseña | Producción, cualquier hora | El sistema verifica la identidad del usuario antes de permitir el cambio de contraseña | 0 cambios de contraseña sin verificación exitosa; el código o enlace de verificación expira antes de 15 minutos | Media | Alto | Baja |
| QS-04 | Mód. 2 — Directorio | RF-05, RF-06 | Idoneidad funcional / Corrección | Admin. tenant revisando la bandeja de verificación | Un aliado envía su registro con los documentos que el tenant exige | Bandeja de verificación de aliados | Producción, operación normal | El sistema muestra el registro pendiente con todos sus documentos, y permite aprobarlo o rechazarlo | 100% de los registros nuevos aparecen en la bandeja en menos de 1 minuto; el aliado ve el resultado sin tener que preguntar | Alta | Alto | Media |
| QS-05 | Mód. 2 — Directorio | RF-07 | Idoneidad funcional / Corrección | Aliado configurando su perfil | Declara las zonas donde presta servicio | Selector de zonas (catálogo jerárquico ciudad → localidad → barrio) | Producción, primera configuración o edición posterior | El sistema guarda la selección y la usa después para las búsquedas de cobertura de RF-12 | El aliado completa la selección en menos de 2 minutos; 0 errores al guardar | Alta | Medio | Baja |
| QS-06 | Mód. 2 — Directorio | RF-08, RF-09 | Flexibilidad / Adaptabilidad | Cliente empresa con varios sitios | Registra un nuevo sitio con reglas propias (ej. horario de acceso) | Módulo de gestión de sitios del cliente | Producción, operación normal | El sistema guarda el sitio con sus reglas y se las muestra al aliado antes de que acepte una solicitud de ese sitio | 100% de las reglas del sitio visibles para el aliado antes de aceptar la solicitud | Media | Medio | Media |
| QS-07 | Mód. 3 — Catálogo | RF-02, RF-10, RF-11 | Flexibilidad / Adaptabilidad | Admin. tenant | Activa o desactiva una categoría de servicio, o ajusta una regla del tenant (documentos, tarifas, orden de listado) | Módulo de configuración de categorías y reglas del tenant | Producción, operación normal | El cambio se refleja de inmediato para clientes y aliados de ese tenant, sin necesidad de desplegar código nuevo | Tiempo entre guardar el cambio y que quede activo < 1 min; 0 despliegues de código requeridos | Alta | Alto | Alta |
| QS-08 | Mód. 4 — Ciclo servicio | RF-12, RF-13 | Eficiencia de desempeño / Capacidad | Cliente creando una solicitud de servicio | Pide ver los aliados disponibles para su categoría y zona, en hora pico | Módulo de búsqueda y listado de aliados | Producción, pico de tráfico | El sistema muestra el listado de aliados válidos, ordenado según la regla configurada por el tenant | Objetivo propuesto: listado entregado en menos de 1 segundo con 20 usuarios buscando a la vez; pendiente validar con volumen real | Alta | Alto | Alta |
| QS-09 | Mód. 4 — Ciclo servicio | RF-14 | Fiabilidad / Tolerancia a fallos | Varios aliados recibiendo la misma solicitud a la vez | Dos o más aliados aceptan la solicitud al mismo tiempo | Tabla solicitud (columnas status, aliado_id) | Producción, alta concurrencia (la solicitud se envía a todos los aliados válidos a la vez) | El sistema asigna la solicitud a un solo aliado y avisa "ya no disponible" a los demás | Exactamente 1 asignación válida por solicitud en el 100% de los casos; el aliado recibe respuesta en menos de 500 ms | Alta | Alto | Media |
| QS-10 | Mód. 4 — Ciclo servicio | RF-15, RF-16 | Idoneidad funcional / Corrección | Aliado elaborando una cotización | Ingresa el valor de mano de obra y materiales, y el total queda fuera del rango de tarifas del tenant | Formulario de cotización + tarifario de referencia | Producción, operación normal | El sistema muestra una alerta visible antes de que el aliado envíe la cotización | 100% de las cotizaciones fuera de rango muestran la alerta antes del envío; el evento queda disponible para el reporte de QS-15 | Media | Medio | Baja |
| QS-11 | Mód. 4 — Ciclo servicio | RF-17 | Fiabilidad / Tolerancia a fallos (idempotencia) | Cliente revisando una cotización, con conexión inestable | Toca "aceptar" y, por un reintento de red, el sistema recibe la misma acción dos veces | Capa de API con clave de idempotencia por solicitud | Producción, condición de red inestable | El sistema procesa la aceptación una sola vez, sin duplicar el efecto | 0 aceptaciones duplicadas en el 100% de reintentos con la misma clave de idempotencia | Media | Medio | Baja |
| QS-12 | Mód. 4 — Ciclo servicio | RF-18 | Seguridad / No repudio | Cualquier actor del ciclo de servicio (Cliente, Aliado, Admin. tenant) | Ocurre un evento relevante del servicio (cambio de estado, mensaje, cotización) | Log cronológico del servicio | Producción | El sistema registra el evento con actor, fecha/hora y descripción, visible en la línea de tiempo del servicio | 100% de los eventos del ciclo de servicio quedan registrados; tiempo de escritura < 200 ms adicionales sobre la operación original | Media | Alto | Media |
| QS-13 | Mód. 4 — Ciclo servicio | RF-19 | Fiabilidad / Tolerancia a fallos (idempotencia) | Cliente o Aliado al cierre del servicio | Envía su calificación del otro actor | Módulo de calificación mutua | Producción, cierre del servicio | El sistema guarda una sola calificación por actor y por servicio, incluso si el botón se toca más de una vez | Máximo 1 calificación registrada por actor y servicio en el 100% de los casos | Media | Medio | Baja |
| QS-14 | Mód. 5 — Comunicación | RF-20, RF-21 | Compatibilidad / Interoperabilidad | Cliente o Aliado con un servicio activo | Envía un mensaje, o se genera una notificación del ciclo de servicio | Supabase Realtime (Broadcast) + servicio de push (FCM/APNs) | Producción, app en primer o segundo plano | El mensaje llega por WebSocket si el otro actor está conectado, o por notificación push si no lo está | Latencia de entrega < 2 s en clientes conectados; 100% de mensajes con al menos un canal de entrega exitoso | Media | Medio | Media |
| QS-15 | Mód. 6 — Tarifario | RF-22, RF-23 | Mantenibilidad / Analizabilidad | Admin. tenant | Consulta el reporte de cotizaciones fuera de rango en un período | Módulo de reportes, con filtro por fecha | Producción, operación normal | El sistema entrega la tabla filtrada, apoyada en los eventos registrados en QS-10 | Reporte generado en menos de 3 segundos para un rango de hasta 12 meses | Media | Medio | Baja |
| QS-16 | Transversal | Transversal (todos los módulos) | Fiabilidad / Disponibilidad | Infraestructura (Supabase, hosting del backend Serverpod) | Falla o cae un componente (base de datos, backend, Storage) | Sistema completo (backend + Supabase) | Producción, horario operativo del tenant | El sistema se recupera automáticamente o entra en modo degradado documentado | Disponibilidad objetivo ≥ 99.5% mensual (≈ 3.6 h de indisponibilidad/mes); tiempo de detección de fallo < 5 min | Media | Alto | Media |
| QS-17 | Transversal | Transversal (protege RF-01 a RF-28) | Mantenibilidad / Verificabilidad | Cualquier integrante del equipo de desarrollo | Un Pull Request modifica autenticación, políticas RLS o el esquema de datos | Pipeline de CI (GitHub Actions + Newman) | Pipeline de CI, antes de fusionar a la rama principal | GitHub Actions ejecuta automáticamente la colección Postman de aislamiento multi-tenant | 6 casos de prueba ejecutados en el 100% de los PR que tocan auth/RLS/esquema; el pipeline bloquea el merge si algún caso falla | Alta | Alto | Media |
| QS-18 | Transversal | Transversal (todos los módulos) | Mantenibilidad / Analizabilidad | Cualquier servicio instrumentado | Ocurre una anomalía o error en producción | Stack de observabilidad (Prometheus + Grafana + Datadog) | Producción | El sistema genera una alerta y, para anomalías críticas, crea automáticamente un issue en Jira | Tiempo de detección de la anomalía < 5 min desde que ocurre; tasa de falsos positivos aún sin umbral definido | Media | Alto | Alta |
| QS-19 | Transversal | RF-12 (flujo crítico) | Usabilidad / Capacidad de aprendizaje | Cliente o Aliado nuevo, primera sesión en la app | Completa su primer flujo crítico (solicitar un servicio / aceptar una solicitud) | Interfaz de usuario (Flutter) | Primer uso, sin capacitación previa | El usuario completa el flujo guiado por la interfaz, sin soporte externo | ≥ 80% de usuarios nuevos completan el flujo crítico sin abandonar en su primera sesión; tiempo promedio < 3 min | Media | Medio | Baja |
| QS-20 | Transversal | Transversal (todos los módulos) | Portabilidad / Adaptabilidad | Cliente o Aliado instalando/usando la app | Abre la aplicación desde Android o iOS | Cliente Flutter | Dispositivo móvil del usuario final | La aplicación se ejecuta con la misma base de código, sin rama de plataforma específica | 1 sola base de código para Android e iOS; 0 líneas de UI condicionadas por plataforma fuera de lo estrictamente necesario | Baja | Medio | Baja |

> Cobertura funcional: los 24 escenarios cubren RF-01 a RF-28 completos — RF-01 a RF-23 (MVP) en QS-01 a QS-15, y RF-24 a RF-28 (2º incremento) en QS-21 a QS-24. QS-16 a QS-20 son transversales: no prueban un RF puntual, sino una condición de calidad que protege a todos los módulos a la vez.

---

## 6. Trade-offs

**Trade-offs Explícitos**

*Tensiones documentadas entre escenarios de calidad y la decisión tomada o propuesta*

| ID | Escenarios en tensión | Naturaleza de la tensión | Decisión tomada / propuesta |
|---|---|---|---|
| TO-01 | QS-02 (Confidencialidad, login) vs. QS-08 (Capacidad, búsqueda) | RLS evalúa una política en cada consulta; a mayor número de políticas y tablas protegidas, mayor costo de cómputo por request, presionando la latencia bajo carga | Se acepta el costo de RLS porque DR-01 es innegociable (Crítica); si QS-08 se degrada, la mitigación es indexación y no relajar RLS (ADR-0012) |
| TO-02 | QS-02 (Confidencialidad) vs. QS-07 (Adaptabilidad, catálogo/config) | Cuanto más configurable es una regla por tenant, más difícil es garantizar que ninguna combinación de configuración rompa el aislamiento | La configurabilidad (QS-07) debe validarse contra la misma suite de QS-17 antes de habilitarse — no se resuelve, se declara como requisito cruzado |
| TO-03 | QS-09 (Tolerancia a fallos, despacho) vs. QS-16 (Disponibilidad) | El UPDATE atómico exige que la base de datos esté disponible en el momento exacto del despacho; si la base cae, el despacho completo se detiene | Aceptado — no hay cola de reintento diseñada todavía; queda como deuda técnica declarada (ver KI-06) |
| TO-04 | QS-16 (Disponibilidad) vs. QS-18 (Analizabilidad) | Más agentes de observabilidad (Prometheus/Datadog) consumen recursos de cómputo que compiten con el servicio principal | Aceptado como costo operativo; ADR-0006 lo reconoce explícitamente como desventaja de la opción elegida |
| TO-05 | QS-07 (Adaptabilidad) vs. QS-17 (Verificabilidad) | Más puntos de configuración por tenant significan más combinaciones que la suite de pruebas debe cubrir | Se declara que la suite de QS-17 debe crecer junto con cada nueva regla configurable — no queda como pendiente, es una regla del proceso |
| TO-06 | QS-02 (Confidencialidad) vs. QS-14 (Interoperabilidad, mensajería) | Reutilizar RLS como mecanismo de autorización de canal en mensajería (ADR-0017) acopla la seguridad del canal en tiempo real a la misma política que protege los datos | Aceptado deliberadamente porque evita duplicar lógica de autorización (ADR-0017), a cambio de concentrar el riesgo en un solo mecanismo |
| TO-07 | QS-07 (Adaptabilidad) vs. QS-19 (Aprendizaje) | Mientras más configurable es la plataforma para el Admin. tenant, más superficie de interfaz debe aprender un usuario no técnico | Sin decisión tomada — se deja como tensión abierta para que la Mesa la resuelva junto con el diseño de UX |
| TO-08 | QS-17 (Verificabilidad) vs. QS-08 (Capacidad) | Ejecutar 6+ casos de prueba en cada PR que toque auth/RLS/esquema añade tiempo al pipeline de CI, no al sistema en producción | Aceptado — el costo se paga en CI, no en producción; ADR-0015 no lo considera bloqueante |

---
## 7. Vista de Contenedores
 
**Diagrama C4 — Nivel 2 (Contenedores)**
 
*Vista de alto nivel de la arquitectura de MANI: cliente móvil, backend principal, infraestructura
compartida de CI/CD y observabilidad, y los módulos adicionales exigidos por el enunciado del
proyecto (PROY-07).*
 

 
*Fuente: `/<img width="3744" height="1150" alt="c4-contenedores_arquitectura-alto-nivel_v1" src="https://github.com/user-attachments/assets/7fa5707d-79d8-4284-b7f0-f04e8a90f2a5" />
diagramas/c4/c4-contenedores_arquitectura-alto-nivel_v1.jpg` — ver ADR-0008 para
convención de versionado.*
 
### Lectura del diagrama
 
| Bloque | Contenido | ADR / requerimiento relacionado |
|---|---|---|
| Cliente | Flutter App (Android/iOS) | PROY-07 (constraint de plataforma), RNF-08 |
| Backend principal | Serverpod (Dart) + Supabase PostgreSQL/RLS + Supabase Storage (KYC) + Supabase Realtime Broadcast | ADR-0012, ADR-0013, ADR-0017 |
| Infraestructura compartida | SonarQube + OWASP ZAP (SAST/DAST) ×2, Prometheus + Grafana + Datadog, GitHub Actions CI/CD multi-repositorio, FCM/APNs | ADR-0004, ADR-0005, ADR-0006 |
| Módulos adicionales | Módulo en Java Spring, Módulo en .NET, persistencia del módulo (pendiente de definir) | PROY-07 (constraint crítico), ADR-0004 |

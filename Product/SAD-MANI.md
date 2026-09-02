# MANI — Objetivos de Diseño, Atributos de Calidad, Escenarios de Calidad y Trade-offs

**Proyecto:** MANI — TRAMA · Ingeniería de Software
**Documento:** Parte del SAD (Software Architecture Document)
**Metodología:** ADD (Attribute-Driven Design) + ATAM, siguiendo Bass/Clements/Kazman y
ISO/IEC 25000:2014 / ISO/IEC 25010:2023
**Fecha:** 2026-09-01
**Fuentes:** SRS_MANI.md §5, Análisis_de_Requerimientos.md, los 15 ADR reales del repositorio
`Trama-AS/MANI-docs` (0001–0013, 0015–0017; no existe 0014)

**Convención de estado usada en todo el documento:**
- 🟢 **Ratificado** — respaldado por un ADR en estado *Aceptado*
- 🟡 **Propuesto** — respaldado por un ADR en estado *Propuesto* (aún sin quórum/disenso)
- 🔵 **Arquitectura** — sin ADR propio; incorporado por criterio arquitectónico para
  cerrar un vacío de diseño real. Se marca explícitamente para que la Mesa lo discuta y lo
  ratifique o lo descarte — no se presenta como decisión ya tomada.

---

## 0. Cómo leer este documento

Siguiendo el framework de diseño orientado a atributos (ADD): cada **Objetivo de Diseño**
(driver o killer) es el "para qué"; cada **Atributo de Calidad** es la categoría/subcategoría
ISO 25010 que ese objetivo activa; cada **Escenario de Calidad** aterriza el atributo en un
estímulo/respuesta/medida verificable (Estímulo → Artefacto → Respuesta, ver diapositiva 9 y
12 de la guía de clase); y la sección de **Trade-offs** documenta explícitamente dónde dos
escenarios entran en tensión — siguiendo la matriz de puntos de acuerdo de la diapositiva 6,
la tensión **no es un error del diseño, es información que hay que dejar visible.**

---

## 1. Objetivos de Diseño — Drivers y Killers Arquitectónicos

Este es el santo grial del diseño de MANI: los **drivers** son lo que el sistema *debe
lograr* de forma no negociable; los **killers** son las limitaciones/riesgos que, si se
subestiman, pueden invalidar la arquitectura elegida. Toda decisión posterior (atributos,
escenarios, trade-offs, ADR) debe poder trazarse hasta uno de estos objetivos.

### 1.1 Drivers (qué debe lograr la arquitectura)

| ID | Driver | Categoría | Descripción | Estado / ADR |
| --- | --- | --- | --- | --- |
| **DR-01** | Aislamiento multi-tenant a nivel de motor | Seguridad | Los datos de un tenant no deben ser accesibles por otro tenant bajo ninguna circunstancia; el filtro debe vivir en el motor (RLS), no solo en el código de aplicación | 🟢 ADR-0012, ADR-0013, ADR-0015 |
| **DR-02** | Cobertura declarada por zonas, no por radio | Restricción de negocio | El cliente exige que la cobertura de un aliado se declare por catálogo de zonas (REST-01), descartando de raíz cualquier alternativa geoespacial | 🟢 ADR-0011 |
| **DR-03** | Independencia del modelo de cobertura frente al motor de persistencia | Diseño / secuenciación | El modelo de zonas debe funcionar con cualquier motor candidato, sin cerrar por adelantado la decisión de persistencia | 🟢 ADR-0011 |
| **DR-04** | Concurrencia determinista en el despacho | Fiabilidad | Ante aceptaciones simultáneas de una misma solicitud, debe quedar exactamente una asignación válida | 🟡 ADR-0016 (Propuesto) |
| **DR-05** | Escalabilidad operativa por número creciente de tenants | Escalabilidad | La incorporación de un tenant nuevo no debe generar trabajo de infraestructura manual recurrente | 🟢 ADR-0013 |
| **DR-06** | Verificación repetible del aislamiento, no revisión manual puntual | Mantenibilidad (Testability) | Cada cambio que toque autenticación/RLS/esquema debe validarse automáticamente, no en auditorías esporádicas | 🟡 ADR-0015 (Propuesto) |
| **DR-07** | Restricción de presupuesto en herramientas de seguridad | Restricción económica | Las herramientas DevSecOps deben ser open-source; plataformas comerciales unificadas quedan fuera de presupuesto académico | 🟢 ADR-0005 |
| **DR-08** | Trazabilidad extremo a extremo gestión↔código | Gobernanza | Un movimiento en el backlog debe reflejarse automáticamente en el repositorio, sin trabajo manual duplicado | 🟢 ADR-0002, ADR-0004 |
| **DR-09** | Defendibilidad de decisiones ante evaluador/auditor externo | Gobernanza | Toda decisión técnica debe ser explicable y sostenible ante preguntas externas (quórum 5/7, disenso documentado) | 🟢 ADR-0003 |
| **DR-10** | Configurabilidad por tenant sin redeploy | Flexibilidad | Cada tenant debe poder ajustar reglas, documentos KYC, tiempos y comisiones sin requerir despliegue de código específico | 🔵 Sin ADR (RNF-02, Crítica en el SRS) |
| **DR-11** | Documentación técnica única, versionada y auditable | Gobernanza | Toda la documentación vive en `/docs`, versionada junto al código, evitando fuentes dispersas sin control de versiones | 🟢 ADR-0007, ADR-0008 |

### 1.2 Killers (limitaciones / riesgos que pueden invalidar el diseño)

| ID | Killer | Categoría | Descripción | Mitigación / Estado |
| --- | --- | --- | --- | --- |
| **KI-01** | MongoDB sin RLS nativo | Incompatibilidad técnica | El backend propuesto originalmente (MongoDB) no soporta RLS, quedando incompatible con DR-01 | 🟢 **Resuelto** — migración completa a PostgreSQL/Supabase (ADR-0012) |
| **KI-02** | Contradicción de stack: Java/.NET (ADR-0004/05/06, Aceptados) vs. Dart/Serverpod (ADR-0012, Aceptado) | Gobernanza / deuda crítica | Dos bloques de ADR **Aceptados a la vez** son mutuamente excluyentes; ninguno declara `supersedes` sobre el otro | 🔴 **Sin resolver** — el killer más severo de todo el conjunto de ADR |
| **KI-03** | Costo de Kubernetes (~$450–650 USD/mes) sin driver que lo justifique | Restricción económica | Veto explícito por costo-beneficio, no por incapacidad técnica | 🟡 Abierto, pospuesto deliberadamente (ADR-0010) |
| **KI-04** | Ventana de riesgo entre revisiones manuales de seguridad | Seguridad de proceso | Sin automatización, un cambio que rompa el aislamiento puede llegar a producción sin detectarse | 🟡 Mitigación diseñada, ADR-0015 aún Propuesto |
| **KI-05** | Aislamiento en Storage depende de la disciplina del backend al construir la ruta | Seguridad | La ruta `tenant_id/aliado_id/archivo` no tiene límite físico de respaldo como un bucket separado | 🟡 Riesgo residual aceptado conscientemente (ADR-0013) |
| **KI-06** | Volumen de tenants desconocido | Escalabilidad | Condiciona si el aislamiento lógico por RLS sobre esquema compartido basta a futuro, o si hará falta separar por base/esquema | 🔴 No resuelto — deuda declarada (ADR-0012) |
| **KI-07** | Sin soporte para cobertura parcial de una localidad | Limitación de producto | El modelo de zonas obliga a declarar la localidad completa o nada | 🟢 Aceptado con condiciones explícitas de reapertura (ADR-0011) |
| **KI-08** | Dependencia de datos oficiales de división político-administrativa | Dependencia externa | El modelo de zonas depende de que exista esa información por ciudad | 🟡 Degrada a nivel ciudad si no existe (ADR-0011) |
| **KI-09** | Volumen concurrente de búsqueda + mensajería sin cifra conocida | Rendimiento | RNF-07 señalado como riesgo crítico en el SRS pese a prioridad "Media", sin volumen definido para fijar umbrales | 🔴 Sin resolver — Análisis de Requerimientos §7 no fija cifra |
| **KI-10** | ADR-0016/0017 incompletos (Redactor, Disenso, Quórum `[completar]`) | Gobernanza | No cumplen el checklist de cierre del Gobierno del Equipo §2.6, pese a que ya se están usando como base de diseño | 🔴 Abierto — requiere sesión formal de la Mesa |
| **KI-11** | Observabilidad instrumentada sobre Java Spring/.NET, en riesgo si prevalece Dart/Serverpod | Mantenibilidad | La instrumentación completa (ADR-0006) quedaría sin destinatario técnico si KI-02 se resuelve a favor de ADR-0012 | 🔴 Depende directamente de que se cierre KI-02 |

---

## 2. Atributos de Calidad (ISO/IEC 25010:2023)

Se nombra siempre **Categoría** (característica ISO 25010) y **Subcategoría**
(subcaracterística). Se incluyen atributos con ADR de respaldo **y** atributos que la
arquitectura necesita cerrar aunque hoy no exista un ADR — estos últimos quedan marcados 🔵
para que la Mesa los discuta, no como decisión ya tomada.

| ID | Categoría | Subcategoría | Origen (RNF/RF) | Objetivo de Diseño relacionado | Estado / ADR |
| --- | --- | --- | --- | --- | --- |
| **AC-01** | Seguridad | Confidencialidad | RNF-01 (Crítica) | DR-01 | 🟢 ADR-0012, ADR-0013, ADR-0015 |
| **AC-02** | Seguridad | Integridad | RNF-01 (Crítica) | DR-01 | 🔵 Sin ADR propio — la integridad entre tenants no tiene escenario dedicado, solo confidencialidad |
| **AC-03** | Seguridad | No repudio / Rendición de cuentas | RNF-04 | DR-09 | 🔵 Sin ADR — mecanismo de auditoría no definido |
| **AC-04** | Fiabilidad | Tolerancia a fallos (despacho concurrente) | RNF-05 | DR-04 | 🟡 ADR-0016 |
| **AC-05** | Fiabilidad | Tolerancia a fallos (idempotencia) | RNF-03 | — | 🔵 Mención lateral en ADR-0016, sin decisión dedicada |
| **AC-06** | Fiabilidad | Disponibilidad | — (no numerado en SRS) | DR-05 | 🔵 Sin ADR — no hay RPO/RTO ni SLA definido aún |
| **AC-07** | Flexibilidad | Adaptabilidad (configuración por tenant) | RNF-02, RNF-10 | DR-10 | 🔵 Sin ADR que lo resuelva |
| **AC-08** | Eficiencia de desempeño | Capacidad | RNF-07 | KI-09 | 🟡 ADR-0017 |
| **AC-09** | Eficiencia de desempeño | Utilización de recursos | — | DR-05 | 🔵 Sin ADR — Serverpod permite escalado horizontal stateless, no evaluado formalmente |
| **AC-10** | Mantenibilidad | Verificabilidad (Testability) | — (proceso QA) | DR-06 | 🟡 ADR-0015 |
| **AC-11** | Mantenibilidad | Analizabilidad | — (observabilidad) | KI-11 | 🟢 ADR-0006 (bajo contradicción con KI-02) |
| **AC-12** | Mantenibilidad | Modularidad | — | DR-10 | 🔵 Sin ADR — patrones Strategy/Repository/Hexagonal explorados, no ratificados |
| **AC-13** | Compatibilidad | Interoperabilidad | RF-20, RF-21 (mensajería) | — | 🟡 ADR-0017 |
| **AC-14** | Portabilidad | Adaptabilidad | — | — | 🔵 Sin ADR — Flutter multiplataforma (móvil), sin decisión formal sobre web |
| **AC-15** | Usabilidad | Capacidad de aprendizaje | — | — | 🔵 Sin ADR — actores Cliente/Aliado no técnicos, sin lineamiento de UX ratificado |

**Excluidos deliberadamente de esta tabla:** RNF-06 (responsabilidad PCI DSS del operador de
pagos) y RNF-11 (modelo de pagos centralizado) son asignación contractual y decisión de
diseño, no atributos de calidad ISO 25010. RNF-09 (cobertura por zonas) es una restricción de
producto (REST-01/DR-02), no un atributo de calidad, aunque el SRS lo clasifique por error
bajo "Usabilidad".

---

## 3. Escenarios de Calidad

Un escenario por atributo priorizado, con el formato completo Fuente→Estímulo→Artefacto→
Entorno→Respuesta→Medida de la respuesta (diapositivas 9–12 de la guía), más **Prioridad**,
**Impacto** y **Complejidad** para poder priorizar el trabajo de diseño.

- **Prioridad:** qué tan crítico es el atributo para el negocio/cliente (Alta/Media/Baja)
- **Impacto:** qué tan grave es no resolverlo bien — efecto sobre el sistema si falla
  (Alto/Medio/Bajo)
- **Complejidad:** costo de implementación y validación (Alta/Media/Baja)

### QS-01 — Seguridad: Confidencialidad

| Campo | Detalle |
| --- | --- |
| **ID** | QS-01 |
| **Atributo** | AC-01 — Seguridad / Confidencialidad |
| **Prioridad** | Alta |
| **Impacto** | Alto — una fuga entre tenants invalida la propuesta de valor del SaaS |
| **Complejidad** | Media — resuelto con RLS nativo, pero exige suite de pruebas dedicada |
| **Source (Fuente)** | Usuario autenticado perteneciente a un tenant |
| **Stimulus (Estímulo)** | Solicitud de datos vía API con token de autenticación válido |
| **Artifact (Artefacto)** | Capa de acceso a datos (RLS sobre PostgreSQL/Supabase) |
| **Environment (Entorno)** | Operación normal, producción |
| **Response (Respuesta)** | El sistema retorna únicamente registros cuyo `tenant_id` coincide con el del token; el filtro se aplica a nivel de motor, no de aplicación |
| **Response Measure (Medida)** | 0 filas de otro tenant expuestas en el 100% de 6 casos de prueba de acceso cruzado (lectura, listado, escritura, borrado, control de autenticación), ejecutados en cada Pull Request vía Newman/GitHub Actions |
| **Estado / ADR** | 🟢 ADR-0012, ADR-0013, ADR-0015 |

### QS-02 — Seguridad: No repudio / Rendición de cuentas

| Campo | Detalle |
| --- | --- |
| **ID** | QS-02 |
| **Atributo** | AC-03 — Seguridad / No repudio |
| **Prioridad** | Media |
| **Impacto** | Alto — sin auditoría, una disputa cliente-aliado-tenant no tiene evidencia verificable |
| **Complejidad** | Media — requiere tabla de auditoría o event sourcing, aún sin diseñar |
| **Source** | Cualquier actor (Cliente, Aliado, Admin. tenant) que ejecuta una operación crítica del ciclo de servicio |
| **Stimulus** | Se ejecuta una operación crítica (aceptación, cambio de estado, pago del 2º incremento) |
| **Artifact** | Módulo de registro de eventos (`LOG_EVENTO`, propuesto sin ADR) |
| **Environment** | Producción |
| **Response** | El sistema registra un evento inmutable con actor, timestamp y operación |
| **Response Measure** | 100% de las operaciones críticas del ciclo de servicio (RF-12 a RF-19) generan un registro; tiempo de escritura del log < 200 ms adicionales sobre la operación original |
| **Estado / ADR** | 🔵 Propuesto por arquitectura — sin ADR, requiere ratificación de la Mesa |

### QS-03 — Fiabilidad: Tolerancia a fallos (despacho concurrente)

| Campo | Detalle |
| --- | --- |
| **ID** | QS-03 |
| **Atributo** | AC-04 — Fiabilidad / Tolerancia a fallos |
| **Prioridad** | Alta |
| **Impacto** | Alto — una doble asignación rompe la confianza del ciclo de servicio completo |
| **Complejidad** | Media — resuelto con `UPDATE` atómico apoyado en MVCC, sin locks explícitos |
| **Source** | Múltiples aliados, clientes móviles concurrentes |
| **Stimulus** | Dos o más aliados aceptan la misma solicitud simultáneamente |
| **Artifact** | Tabla `solicitud` (columnas `status`, `aliado_id`) |
| **Environment** | Producción, alta concurrencia (broadcast a todos los aliados válidos a la vez) |
| **Response** | Un `UPDATE` condicional atómico (`WHERE status='pending' AND aliado_id IS NULL`) resuelve la carrera |
| **Response Measure** | Exactamente 1 fila afectada por la sentencia ganadora; 0 filas afectadas en cualquier intento posterior sobre la misma solicitud; tiempo de resolución < 500 ms desde el primer `UPDATE` recibido |
| **Estado / ADR** | 🟡 ADR-0016 (Propuesto, incompleto) |

### QS-04 — Fiabilidad: Tolerancia a fallos (idempotencia)

| Campo | Detalle |
| --- | --- |
| **ID** | QS-04 |
| **Atributo** | AC-05 — Fiabilidad / Tolerancia a fallos |
| **Prioridad** | Media |
| **Impacto** | Medio — un reintento duplicado genera cobros o notificaciones repetidas, no pérdida de datos |
| **Complejidad** | Baja — puede resolverse con clave de idempotencia por operación |
| **Source** | Cliente o aliado con conexión inestable |
| **Stimulus** | Reintento de una operación crítica (aceptación, confirmación, cierre de servicio) tras timeout de red |
| **Artifact** | Capa de API / clave de idempotencia por request |
| **Environment** | Producción, condición de red inestable |
| **Response** | El sistema detecta el reintento por su clave de idempotencia y devuelve el resultado de la operación original sin ejecutarla dos veces |
| **Response Measure** | 0 operaciones duplicadas en 100% de reintentos con la misma clave de idempotencia dentro de una ventana de 24 h |
| **Estado / ADR** | 🔵 Propuesto por arquitectura — mención lateral en ADR-0016, sin decisión dedicada |

### QS-05 — Fiabilidad: Disponibilidad

| Campo | Detalle |
| --- | --- |
| **ID** | QS-05 |
| **Atributo** | AC-06 — Fiabilidad / Disponibilidad |
| **Prioridad** | Media |
| **Impacto** | Alto — MANI es la única vía operativa del ciclo de servicio de sus tenants |
| **Complejidad** | Media — depende de la estrategia de hosting/infraestructura, aún no decidida (KI-03) |
| **Source** | Infraestructura (Supabase, hosting del backend Serverpod) |
| **Stimulus** | Falla o caída de un componente (base de datos, backend, Storage) |
| **Artifact** | Sistema completo (backend + Supabase) |
| **Environment** | Producción, horario operativo del tenant |
| **Response** | El sistema se recupera automáticamente o entra en modo degradado documentado |
| **Response Measure** | Disponibilidad objetivo ≥ 99.5% mensual (≈ 3.6 h de indisponibilidad/mes); tiempo de detección de fallo < 5 min |
| **Estado / ADR** | 🔵 Propuesto por arquitectura — sin SLA/RPO/RTO ratificado por la Mesa |

### QS-06 — Flexibilidad: Adaptabilidad (configuración por tenant)

| Campo | Detalle |
| --- | --- |
| **ID** | QS-06 |
| **Atributo** | AC-07 — Flexibilidad / Adaptabilidad |
| **Prioridad** | Alta (RNF-02 es Crítica en el SRS) |
| **Impacto** | Alto — sin esto, cada tenant nuevo exigiría cambios de código |
| **Complejidad** | Alta — requiere motor de reglas o tabla de configuración, ningún spike lo ha evaluado |
| **Source** | Admin. tenant |
| **Stimulus** | El administrador de un tenant modifica reglas, documentos KYC, tiempos o comisiones desde la configuración |
| **Artifact** | Módulo de configuración por tenant (sin diseño ratificado) |
| **Environment** | Producción, operación normal |
| **Response** | El cambio se aplica sin requerir despliegue de código específico para ese tenant |
| **Response Measure** | Tiempo entre guardar el cambio y que quede activo < 1 min; 0 despliegues de código requeridos por cambio de configuración |
| **Estado / ADR** | 🔵 Propuesto por arquitectura — sin ADR ni spike |

### QS-07 — Eficiencia de desempeño: Capacidad

| Campo | Detalle |
| --- | --- |
| **ID** | QS-07 |
| **Atributo** | AC-08 — Eficiencia de desempeño / Capacidad |
| **Prioridad** | Media (SRS), pero señalada como riesgo crítico en §5.7 |
| **Impacto** | Alto — degradación en búsqueda/mensajería afecta directamente la experiencia del ciclo de servicio |
| **Complejidad** | Alta — volumen de tenants/solicitudes concurrentes aún sin cifra (KI-09) |
| **Source** | Carga de usuarios concurrentes (clientes y aliados) |
| **Stimulus** | Aumento simultáneo de búsquedas de aliados y mensajes en hora pico |
| **Artifact** | Módulo de búsqueda/listado + canal de mensajería (Supabase Realtime propuesto) |
| **Environment** | Producción, pico de tráfico |
| **Response** | El sistema mantiene tiempos de respuesta aceptables sin degradar otras operaciones |
| **Response Measure** | Objetivo propuesto: tiempo de respuesta de búsqueda < 1 s con 20 usuarios concurrentes (análogo al ejemplo de la diapositiva 9); pendiente validar con cifra real de volumen esperado |
| **Estado / ADR** | 🟡 ADR-0017 (Propuesto, incompleto); medida numérica 🔵 propuesta por arquitectura |

### QS-08 — Mantenibilidad: Verificabilidad (Testability)

| Campo | Detalle |
| --- | --- |
| **ID** | QS-08 |
| **Atributo** | AC-10 — Mantenibilidad / Verificabilidad |
| **Prioridad** | Alta |
| **Impacto** | Alto — sin esto, DR-01 (aislamiento) depende de disciplina humana, no de control automático |
| **Complejidad** | Media — colección Postman ya definida, falta ratificar |
| **Source** | Cualquier integrante del equipo de desarrollo |
| **Stimulus** | Un Pull Request modifica autenticación, políticas RLS o el esquema de datos |
| **Artifact** | Pipeline de CI (GitHub Actions + Newman) |
| **Environment** | Pipeline de CI, antes de fusionar a la rama principal |
| **Response** | GitHub Actions ejecuta automáticamente la colección Postman de aislamiento multi-tenant |
| **Response Measure** | 6 casos de prueba ejecutados en el 100% de los PR que tocan auth/RLS/esquema; pipeline debe fallar (bloquear merge) ante cualquier caso no superado |
| **Estado / ADR** | 🟡 ADR-0015 (Propuesto) |

### QS-09 — Mantenibilidad: Analizabilidad

| Campo | Detalle |
| --- | --- |
| **ID** | QS-09 |
| **Atributo** | AC-11 — Mantenibilidad / Analizabilidad |
| **Prioridad** | Media |
| **Impacto** | Alto — sin observabilidad, diagnosticar una falla en producción depende de revisión manual de logs |
| **Complejidad** | Alta — instrumentación construida sobre Java/.NET, en riesgo por KI-02/KI-11 |
| **Source** | Cualquier servicio instrumentado |
| **Stimulus** | Ocurre una anomalía o error en producción |
| **Artifact** | Stack de observabilidad (Prometheus + Grafana + Datadog) |
| **Environment** | Producción |
| **Response** | El sistema genera una alerta y, para anomalías críticas, crea automáticamente un issue en Jira |
| **Response Measure** | Tiempo de detección de la anomalía < 5 min desde que ocurre; 🔴 tasa de falsos positivos aún sin umbral definido en el ADR |
| **Estado / ADR** | 🟢 ADR-0006 (Aceptado, pero sobre stack en disputa — ver KI-02, KI-11) |

### QS-10 — Compatibilidad: Interoperabilidad (mensajería)

| Campo | Detalle |
| --- | --- |
| **ID** | QS-10 |
| **Atributo** | AC-13 — Compatibilidad / Interoperabilidad |
| **Prioridad** | Media |
| **Impacto** | Medio — afecta RF-20/RF-21 (mensajería), no el núcleo transaccional del ciclo de servicio |
| **Complejidad** | Media — dos canales a coordinar (Realtime + push) |
| **Source** | Cliente o Aliado enviando/recibiendo un mensaje asociado a un servicio |
| **Stimulus** | Se publica un mensaje o evento relevante del ciclo de servicio |
| **Artifact** | Supabase Realtime (Broadcast) + servicio de push (FCM/APNs) |
| **Environment** | Producción, app en primer o segundo plano |
| **Response** | El mensaje se distribuye por WebSocket a clientes conectados y por push a los desconectados |
| **Response Measure** | Latencia de entrega < 2 s en clientes conectados; 100% de mensajes con al menos un canal de entrega exitoso (Realtime o push) |
| **Estado / ADR** | 🟡 ADR-0017 (Propuesto, incompleto y con condición ya obsoleta — ver KI-10) |

### QS-11 — Portabilidad: Adaptabilidad

| Campo | Detalle |
| --- | --- |
| **ID** | QS-11 |
| **Atributo** | AC-14 — Portabilidad / Adaptabilidad |
| **Prioridad** | Baja (no es RNF numerado, pero condiciona el alcance de plataformas soportadas) |
| **Impacto** | Medio — limita a qué dispositivos puede llegar el MVP |
| **Complejidad** | Baja — Flutter ya es multiplataforma por defecto |
| **Source** | Cliente o Aliado instalando/usando la app |
| **Stimulus** | El usuario abre la aplicación desde Android o iOS |
| **Artifact** | Cliente Flutter |
| **Environment** | Dispositivo móvil del usuario final |
| **Response** | La aplicación se ejecuta con la misma base de código, sin rama de plataforma específica |
| **Response Measure** | 1 sola base de código para Android e iOS; 0 líneas de UI condicionadas por plataforma fuera de lo estrictamente necesario |
| **Estado / ADR** | 🔵 Propuesto por arquitectura — sin ADR formal sobre alcance de plataformas |

### QS-12 — Usabilidad: Capacidad de aprendizaje

| Campo | Detalle |
| --- | --- |
| **ID** | QS-12 |
| **Atributo** | AC-15 — Usabilidad / Capacidad de aprendizaje |
| **Prioridad** | Media |
| **Impacto** | Medio — actores Cliente/Aliado no son técnicos; una curva de aprendizaje alta reduce adopción |
| **Complejidad** | Baja — resoluble con guías in-app, sin nueva infraestructura |
| **Source** | Cliente o Aliado nuevo, primera sesión en la app |
| **Stimulus** | El usuario completa su primer flujo crítico (solicitar un servicio / aceptar una solicitud) |
| **Artifact** | Interfaz de usuario (Flutter) |
| **Environment** | Primer uso, sin capacitación previa |
| **Response** | El usuario completa el flujo guiado por la interfaz, sin soporte externo |
| **Response Measure** | ≥ 80% de usuarios nuevos completan el flujo crítico sin abandonar en su primera sesión; tiempo promedio del flujo < 3 min |
| **Estado / ADR** | 🔵 Propuesto por arquitectura — sin ADR ni prueba de usabilidad realizada |

---

## 4. Trade-offs y Tensiones entre Escenarios de Calidad

La tensión entre atributos **no es un problema a eliminar — es información de diseño que hay
que dejar explícita** (diapositiva 4). Cada fila describe qué escenario se ve favorecido y
cuál se ve presionado por la misma decisión.

### 4.1 Matriz de tensión entre atributos de calidad

Convención de la diapositiva 6: **[+]** la fila favorece a la columna, **[-]** la fila
presiona negativamente a la columna, **[ ]** sin interacción relevante detectada.

| Atributo (fila ↓ / columna →) | Confidencialidad | Tolerancia a fallos | Disponibilidad | Adaptabilidad | Capacidad (Eficiencia) | Verificabilidad | Analizabilidad | Interoperabilidad | Aprendizaje (Usabilidad) |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| **Confidencialidad (AC-01)** | — | [ ] | [-] | [-] | [-] | [+] | [ ] | [-] | [-] |
| **Tolerancia a fallos (AC-04)** | [ ] | — | [+] | [ ] | [-] | [+] | [ ] | [ ] | [ ] |
| **Disponibilidad (AC-06)** | [-] | [+] | — | [ ] | [-] | [ ] | [+] | [ ] | [ ] |
| **Adaptabilidad (AC-07)** | [-] | [ ] | [ ] | — | [+] | [+] | [ ] | [+] | [+] |
| **Capacidad (AC-08)** | [-] | [-] | [-] | [+] | — | [-] | [-] | [ ] | [ ] |
| **Verificabilidad (AC-10)** | [+] | [+] | [ ] | [+] | [-] | — | [+] | [ ] | [ ] |
| **Analizabilidad (AC-11)** | [ ] | [ ] | [+] | [ ] | [-] | [+] | — | [ ] | [ ] |
| **Interoperabilidad (AC-13)** | [-] | [ ] | [ ] | [+] | [ ] | [ ] | [ ] | — | [ ] |
| **Aprendizaje (AC-15)** | [-] | [ ] | [ ] | [+] | [ ] | [ ] | [ ] | [ ] | — |

### 4.2 Trade-offs explícitos documentados

| ID | Escenarios en tensión | Naturaleza de la tensión | Decisión tomada / propuesta |
| --- | --- | --- | --- |
| **TO-01** | QS-01 (Confidencialidad) vs. QS-07 (Capacidad) | RLS evalúa una política en cada consulta; a mayor número de políticas y tablas protegidas, mayor costo de cómputo por request, presionando la latencia bajo carga | Se acepta el costo de RLS porque DR-01 es innegociable (Crítica); si QS-07 se degrada, la mitigación es indexación y no relajar RLS (ADR-0012) |
| **TO-02** | QS-01 (Confidencialidad) vs. QS-06 (Adaptabilidad) | Cuanto más configurable es una regla por tenant, más difícil es garantizar que ninguna combinación de configuración rompa el aislamiento | La configurabilidad (QS-06) debe validarse contra la misma suite de QS-08 antes de habilitarse — no se resuelve, se declara como requisito cruzado |
| **TO-03** | QS-03 (Tolerancia a fallos, despacho) vs. QS-05 (Disponibilidad) | El `UPDATE` atómico exige que la base de datos esté disponible en el momento exacto del despacho; si la base cae, el despacho completo se detiene | Aceptado — no hay cola de reintento diseñada todavía; queda como deuda técnica declarada (ver KI-06) |
| **TO-04** | QS-05 (Disponibilidad) vs. QS-09 (Analizabilidad) | Más agentes de observabilidad (Prometheus/Datadog) consumen recursos de cómputo que compiten con el servicio principal | Aceptado como costo operativo; ADR-0006 lo reconoce explícitamente como desventaja de la opción elegida |
| **TO-05** | QS-06 (Adaptabilidad) vs. QS-08 (Verificabilidad) | Más puntos de configuración por tenant significan más combinaciones que la suite de pruebas debe cubrir | Se declara que la suite de QS-08 debe crecer junto con cada nueva regla configurable — no queda como pendiente, es una regla del proceso |
| **TO-06** | QS-01 (Confidencialidad) vs. QS-10 (Interoperabilidad) | Reutilizar RLS como mecanismo de autorización de canal en mensajería (ADR-0017) acopla la seguridad del canal en tiempo real a la misma política que protege los datos — un error en una política afecta a ambos atributos a la vez | Aceptado deliberadamente porque evita duplicar lógica de autorización (ADR-0017), a cambio de concentrar el riesgo en un solo mecanismo |
| **TO-07** | QS-06 (Adaptabilidad) vs. QS-12 (Aprendizaje) | Mientras más configurable es la plataforma para el Admin. tenant, más superficie de interfaz debe aprender un usuario no técnico | Sin decisión tomada — se deja como tensión abierta para que la Mesa la resuelva junto con el diseño de UX |
| **TO-08** | QS-08 (Verificabilidad) vs. QS-07 (Capacidad) | Ejecutar 6+ casos de prueba en cada PR que toque auth/RLS/esquema añade tiempo al pipeline de CI, no al sistema en producción, pero compite por los mismos minutos de cómputo que otras validaciones de rendimiento | Aceptado — el costo se paga en CI, no en producción; ADR-0015 no lo considera bloqueante |

---

## 5. ADR Consolidados

Los 15 ADR reales del repositorio `Trama-AS/MANI-docs` (rama `main`, carpeta `/ADR`; no
existe un ADR-0014). Cada uno se conecta explícitamente con su(s) Objetivo(s) de Diseño
(§1), su Atributo/Escenario de Calidad (§2–3) y su Trade-off (§4), para que la trazabilidad
del SAD sea verificable de punta a punta.

**Convención de Estado:** 🟢 Aceptado · 🟡 Propuesto · 🔴 Aceptado pero en contradicción activa
con otro ADR también Aceptado (ver KI-02).

### 5.1 Tabla maestra de ADR

| ADR | Título | Estado | Decisión (resumen) | Alternativas descartadas | Objetivo de Diseño | AC / Escenario | Trade-off |
| --- | --- | --- | --- | --- | --- | --- | --- |
| **ADR-0001** | Gestión documental | 🟢 Aceptado | GitHub (código/ADR) + OneDrive (documentos formales), dividido por tipo de contenido | Todo en GitHub; Confluence + Jira | DR-11 | — | — |
| **ADR-0002** | Herramientas de gestión: Jira | 🟢 Aceptado | Jira para gestión de proyecto + GitHub para lo técnico, separados | Todo en GitHub Projects; GitLab Issues | DR-08 | — | — |
| **ADR-0003** | Mesa de Arquitectura | 🟢 Aceptado | Mesa con Arquitecto transversal y rotación de autoría de ADR; quórum 5/7, disenso documentado | Responsable único (SM); sin reglamento formal | DR-09 | — | — |
| **ADR-0004** | Pipeline CI/CD multi-repositorio | 🔴 Aceptado (en contradicción) | GitHub Actions + Webhooks Jira↔GitHub + promoción de contenedores en Azure, sobre 3 repos (Flutter/Java/.NET) | Monorepositorio; Jenkins auto-hospedado | DR-08 | — | Base de KI-02 |
| **ADR-0005** | DevSecOps: SAST + DAST | 🔴 Aceptado (en contradicción) | SonarQube (SAST) + OWASP ZAP (DAST) en GitHub Actions, sobre Flutter/Java/.NET | Revisión manual; plataformas comerciales unificadas | DR-07 | — | Base de KI-02 |
| **ADR-0006** | Observabilidad | 🔴 Aceptado (en contradicción) | Prometheus + Grafana + Datadog, instrumentando Java Spring/.NET en Azure | Stack ELK auto-alojado; Azure Monitor/App Insights exclusivo | KI-11 | AC-11 / QS-09 | TO-04 |
| **ADR-0007** | Documentación en el repositorio | 🟢 Aceptado | Carpeta `/docs` versionada junto al código, reemplaza Confluence/Drive/Discord | Confluence como fuente única; Google Drive compartido | DR-11 | — | — |
| **ADR-0008** | Carpeta de diagramas | 🟢 Aceptado | `/docs/diagramas` con subcarpetas por tipo; Mermaid versionado como texto (`.mmd`) | Solo en herramientas de origen (Figma/Miro); imágenes sueltas en Confluence | DR-11 | — | — |
| **ADR-0009** | Política de uso de IA | 🟢 Aceptado | Uso de IA permitido bajo lineamientos del equipo; ninguna sugerencia de IA es decisión válida sin pasar por la Mesa | Prohibición total; uso libre sin lineamientos | DR-09 | — | — |
| **ADR-0010** | Tech Radar del proyecto | 🟢 Aceptado | Radar visual consolidado (círculos de confianza, cuadrantes por categoría); Kubernetes en "Tal vez" por costo | Mantener disperso en ADR individuales | KI-03 | — | — |
| **ADR-0011** | Modelo de cobertura geográfica | 🟢 Aceptado | Catálogo de zonas administrativas, relación N:M aliado↔zona, sin geometría propia | Radio de cobertura; polígonos dibujados; catálogo con geometría asociada | DR-02, DR-03 | — | KI-07, KI-08 |
| **ADR-0012** | Backend Dart, motor de persistencia y aislamiento multi-tenant | 🔴 Aceptado (en contradicción) | Serverpod (Dart) + Supabase (PostgreSQL) + RLS nativo | NestJS+MongoDB; BaaS puro; filtrado manual sin RLS; base/esquema separado por tenant | DR-01 | AC-01, AC-02 / QS-01 | TO-01, TO-02 · resuelve KI-01 · abre KI-02, KI-06 |
| **ADR-0013** | Almacenamiento de documentos KYC | 🟡 Propuesto | Bucket único de Storage con ruta `tenant_id/aliado_id/archivo` + RLS sobre `storage.objects` | Bucket privado por tenant; aislamiento solo en capa de aplicación | DR-05, DR-01 | AC-01 | KI-05 |
| **ADR-0015** | Estrategia de pruebas de aislamiento multi-tenant | 🟡 Propuesto | Colección Postman con 6 casos de acceso cruzado, automatizada con Newman en GitHub Actions | Revisión manual periódica; k6 u OWASP ZAP | DR-06 | AC-10 / QS-08 | TO-05, TO-08 · mitiga KI-04 |
| **ADR-0016** | Estrategia de despacho de solicitudes | 🟡 Propuesto, incompleto | Despacho simultáneo (broadcast) con `UPDATE` condicional atómico | Despacho secuencial según orden de RF-13 | DR-04 | AC-04 / QS-03 | TO-03 · pendiente en KI-10 |
| **ADR-0017** | Mensajería y notificaciones en tiempo real | 🟡 Propuesto, incompleto, condicionado | Supabase Realtime (Broadcast) + push notifications (FCM/APNs) | WebSockets propios (Socket.io); Polling | — | AC-13 / QS-10 | TO-06 · pendiente en KI-10 |

### 5.2 Hallazgo transversal: contradicción activa entre bloques de ADR

**ADR-0004, ADR-0005 y ADR-0006** (Aceptados, 2026-08-19/24) construyen pipeline, seguridad y
observabilidad completos sobre el supuesto de tres repositorios en **Flutter + Java + .NET**,
desplegados en Azure. **ADR-0012** (Aceptado, 2026-08-29) decide un backend distinto —
**Dart/Serverpod sobre Supabase** — sin declarar `supersedes` sobre ninguno de los tres.
Ambos bloques están formalmente vigentes (Aceptados) y son mutuamente excluyentes: es
KI-02, el killer más severo del conjunto. Ningún ADR posterior lo resuelve; el Tech Radar
(ADR-0010) tampoco lo refleja, pese a ratificarse 4 días antes que ADR-0012.

### 5.3 ADR sin ratificar formalmente (checklist de cierre incompleto)

| ADR | Campos pendientes | Impacto |
| --- | --- | --- |
| ADR-0013 | Estado formal aún Propuesto | KI-05 permanece como riesgo residual sin cobertura de pruebas ratificada |
| ADR-0015 | Redactor/Disenso/Quórum sin confirmar en algunas versiones | KI-04 (ventana de riesgo) mitigado en diseño, no en gobernanza |
| ADR-0016 | Redactor, Disenso y Quórum marcados `[completar]` | No cumple Gobierno del Equipo §2.6 pese a ya usarse como base de diseño (KI-10) |
| ADR-0017 | Redactor, Disenso y Quórum marcados `[completar]`; condición de activación (adopción de Supabase) ya se cumplió con ADR-0012 pero el texto sigue redactado como pendiente | KI-10; requiere actualización de su autor |

---

## 6. Trazabilidad: de Objetivo de Diseño a Escenario

| Objetivo de Diseño | Atributo(s) de Calidad | Escenario(s) de Calidad | ADR relacionado |
| --- | --- | --- | --- |
| DR-01 (Aislamiento multi-tenant) | AC-01, AC-02 | QS-01 | ADR-0012, ADR-0013, ADR-0015 |
| DR-04 (Concurrencia en despacho) | AC-04 | QS-03 | ADR-0016 |
| DR-05 (Escalabilidad operativa) | AC-06, AC-09 | QS-05 | ADR-0013 (parcial) — sin ADR propio para AC-06/AC-09 |
| DR-06 (Verificación repetible) | AC-10 | QS-08 | ADR-0015 |
| DR-09 (Defendibilidad ante auditor) | AC-03 | QS-02 | ADR-0003 (gobernanza) — sin ADR propio de auditoría de datos |
| DR-10 (Configurabilidad sin redeploy) | AC-07, AC-12 | QS-06 | Sin ADR |
| KI-09 (Volumen concurrente sin cifra) | AC-08 | QS-07 | ADR-0017 (parcial) |
| KI-11 (Observabilidad en riesgo) | AC-11 | QS-09 | ADR-0006 |
| — (RF-20/RF-21 mensajería) | AC-13 | QS-10 | ADR-0017 |
| — (multiplataforma) | AC-14 | QS-11 | Sin ADR |
| — (adopción de usuarios no técnicos) | AC-15 | QS-12 | Sin ADR |
| — (idempotencia, RNF-03) | AC-05 | QS-04 | Sin ADR propio (mención lateral en ADR-0016) |

---

## Nota metodológica

Los escenarios marcados 🔵 (sin ADR) incluyen una medida de respuesta **propuesta por
arquitectura** para que el documento sea accionable — no se dejan en blanco — pero se marcan
explícitamente como pendientes de validación en la Mesa, distinguiéndolos de los que ya
citan un número verificado en un ADR real (🟢/🟡). Esto responde directamente a la
instrucción de la clase: se pueden añadir atributos sin ADR asociado, siempre que quede claro
cuáles están ratificados y cuáles son propuesta de diseño abierta a discusión.

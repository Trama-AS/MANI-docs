# MANI

**MANI** es una plataforma SaaS multi-tenant para formalizar y gestionar operaciones de servicio, conectando clientes con aliados durante todo el ciclo:

`Solicitud → Cotización → Ejecución → Calificación → Cierre`

El proyecto es desarrollado por **TRAMA · Ingeniería de Software**.

> Los documentos de este repositorio son **documentos vivos y sin número de versión**. La versión
> vigente de cada uno es la de `main`; el historial está en el log del repositorio. La carpeta
> [`Entregas/`](Entregas/) es un **histórico de entregables académicos** y no es fuente de verdad:
> no se consulta para resolver una duda ni para implementar.

---

## 1. Problema que resuelve

La operación objetivo se gestiona actualmente de forma informal mediante llamadas, mensajería y contactos directos, lo que dificulta:

- mantener trazabilidad de los servicios;
- verificar aliados;
- estandarizar tarifas;
- controlar solicitudes y asignaciones;
- auditar la operación;
- escalar el modelo hacia múltiples empresas.

MANI busca centralizar este proceso en una única plataforma configurable por empresa, manteniendo aislamiento estricto entre tenants.

---

## 2. Alcance

### MVP

El primer incremento contempla:

- administración de tenants;
- autenticación y control de acceso;
- directorio de aliados y clientes;
- documentos KYC;
- catálogo de categorías;
- cobertura por zonas;
- creación y despacho de solicitudes;
- cotizaciones;
- ejecución del servicio;
- calificación bidireccional;
- mensajería y notificaciones;
- tarifario de referencia;
- reportes asociados al tarifario.

### Segundo incremento

Quedan previstos para una fase posterior:

- pagos y liquidaciones;
- gestión de quejas;
- comercialización;
- administración avanzada;
- métricas operativas por tenant.

El detalle de requisitos está en [`product/SRS.md`](product/SRS.md) y la cobertura de cada uno a
nivel de datos en [`architecture/ModeloDatos.md`](architecture/ModeloDatos.md) §14.

---

## 3. Principios del producto

- **Multi-tenancy:** cada empresa opera con datos, usuarios y configuración aislados.
- **Configurabilidad:** las reglas de cada tenant cambian mediante configuración, no mediante una versión distinta del software.
- **Trazabilidad:** las operaciones relevantes del ciclo del servicio deben poder reconstruirse.
- **Idempotencia:** las operaciones críticas deben soportar reintentos sin duplicar efectos.
- **Concurrencia controlada:** una solicitud solo puede terminar con una asignación válida.
- **Cobertura por zonas:** el MVP no utiliza geolocalización en tiempo real ni cálculo por radio.
- **Seguridad en profundidad:** identidad, autorización y aislamiento de datos se validan en más de una capa.

---

## 4. Arquitectura

La arquitectura de MANI es:

> **SOA distribuida + API Gateway + enfoque políglota + multi-tenancy**

### Servicios y repositorios

| Repositorio | Tecnología | Responsabilidad principal |
|---|---|---|
| `MANI-Frontend` | Flutter / Dart | Cliente web y móvil |
| `MANI-API-Gateway` | NGINX | Punto de entrada y enrutamiento de APIs |
| `MANI-Rules-Service` | Java | Reglas de negocio por tenant |
| `MANI-Dispatch-Service` | .NET | Solicitudes, despacho y asignación |
| `MANI-Core-Service` | Node.js | Servicios core y disponibilidades |
| `MANI-Docs` | Markdown / diagramas / ADR | Documentación arquitectónica y técnica |

Son **seis repositorios** y **tres servicios de negocio**. Las disponibilidades son un módulo del
`MANI-Core-Service`, con esquema de datos propio, no un servicio desplegable aparte.

`MANI-API-Gateway` guarda además el Compose por ambiente y la configuración de observabilidad: es
la raíz de composición del despliegue.

### Persistencia

| Componente | Tecnología | Responsabilidad |
|---|---|---|
| Persistencia | Supabase | Plataforma administrada |
| Motor de datos | PostgreSQL | Persistencia relacional y RLS |

Supabase se utiliza como **plataforma administrada** y PostgreSQL como su **motor de base de datos**. No son dos alternativas distintas.

### Acceso del cliente a Supabase

El cliente Flutter alcanza Supabase por **exactamente dos caminos**, y **no hay excepciones**:

| Camino | Para qué |
|---|---|
| `Flutter → Supabase Auth` | sesión, registro y refresco del JWT |
| `Flutter ← Supabase Realtime` | recepción de eventos de mensajería; es transporte, no acceso a datos |

Todo lo demás pasa por `Flutter → API Gateway → servicio → Supabase`. Están retirados del cliente
`.from()`, `.rpc()` y `.storage.from()`, incluida la consulta de disponibilidades, que no es una
excepción (ADR-0022, ADR-0027; SAD §8.3).

### Seguridad multi-tenant

La identificación autenticada del tenant se basa en un **JWT firmado**.

El aislamiento se aplica mediante:

1. validación inicial en el API Gateway;
2. autorización dentro de los servicios;
3. Row-Level Security (RLS) en PostgreSQL;
4. aislamiento equivalente para documentos KYC en Storage.

---

## 5. Servicios externos

MANI contempla integración con:

- **FCM / APNs** para notificaciones push;
- **operador de pagos certificado** en el segundo incremento;
- herramientas de observabilidad;
- Data Warehouse / BI para analítica.

---

## 6. Ambientes

La línea base contempla exactamente tres ambientes:

```text
DEV → QA → PROD
```

| Ambiente | Dónde corre | Datos |
|---|---|---|
| **DEV** | máquina personal de cada desarrollador, con Docker local | sintéticos |
| **QA** | máquina virtual de QA con Docker | dataset controlado y anonimizado |
| **PROD** | máquina virtual productiva con Docker | reales |

El ambiente de pruebas se llama **QA** en todos los documentos, pipelines y tags. No existe
STAGING ni un cuarto ambiente con otro nombre.

La promoción mantiene el principio:

> **Build once, deploy many**

El mismo artefacto validado se promueve de QA a PROD sin reconstruirse.

---

## 7. Contenerización y orquestación

- Docker / OCI para empaquetado.
- Un contenedor por servicio, con health check y límites de recursos.
- Compose por ambiente, en `MANI-API-Gateway`.
- GitHub Actions para CI/CD.
- Configuración y secretos externos al artefacto.

### Orquestación: decisión abierta

**Kubernetes es el objetivo exigido por el proyecto (PROY-08), pero no es el estado actual y no
está decidido.** Hoy el despliegue es Docker sobre máquina virtual, una por ambiente.

Siguen abiertas dos decisiones, registradas en
[`governance/INFRAESTRUCTURA_MANI.md`](governance/INFRAESTRUCTURA_MANI.md) §25:

| ID | Decisión pendiente |
|---|---|
| `INFRA-01` | Proveedor y dimensionamiento de la plataforma de orquestación |
| `INFRA-02` | Topología final: nodos, namespaces o clusters por ambiente, y networking |

Hasta que un ADR las cierre: no se fija proveedor, no se declara un clúster como estado actual y no
se asume AKS ni Azure.

**Ya están decididas** y no se vuelven a discutir sin ADR:

- GHCR como registro de imágenes;
- Supabase de desarrollo compartido para DEV;
- Docker sobre VM como mecanismo de despliegue de QA y PROD.

---

## 8. DevSecOps

El flujo de calidad y seguridad contempla:

```text
Pull Request
   ↓
Pruebas unitarias / integración / contratos
   ↓
SonarQube
   ↓
Build Docker/OCI
   ↓
Escaneo de dependencias e imagen
   ↓
QA
   ↓
Newman
   ↓
OWASP ZAP
   ↓
Promoción a PROD
```

Herramientas principales:

- **SonarQube:** SAST y Quality Gates.
- **OWASP ZAP:** DAST sobre QA.
- **Postman / Newman:** pruebas funcionales, contratos y aislamiento multi-tenant.
- **k6:** pruebas de carga y concurrencia.

El detalle del pipeline vive en
[`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §8.

---

## 9. Observabilidad

- **Prometheus** para métricas;
- **Grafana** para visualización;
- **Datadog** para logs, APM y trazas;
- `correlation_id` para seguimiento distribuido;
- Jira como destino de incidentes relevantes.

---

## 10. Gestión del proyecto

El proyecto se ejecuta bajo **Scrum**.

Herramientas principales:

- **Jira:** backlog, épicas, historias, bugs, sprints y seguimiento.
- **GitHub:** código, Pull Requests, issues técnicos, CI/CD y documentación técnica versionable.
- **Discord:** comunicación operativa del equipo.
- **OneDrive:** documentación administrativa, actas e informes cuando corresponda.

Las decisiones técnicas costosas de revertir pasan por la **Mesa de Arquitectura** y se registran mediante ADR.

---

## 11. Equipo

| Integrante | Rol principal | Segundo rol |
|---|---|---|
| Sara Albarracín | Scrum Master | Frontend |
| Juan Sebastián Álvarez | Backend | Frontend |
| Camila Beltrán | Frontend | Scrum Master |
| Nicolás Álvarez | Frontend | QA |
| Santiago | QA | Product Owner |
| Daniel Ávila | DevOps | Backend |
| Nicolás León | Product Owner | DevOps |

Todos los integrantes técnicos participan transversalmente en la **Mesa de Arquitectura**.

---

## 12. Documentación

La documentación se divide por responsabilidad para evitar duplicidad.

```text
MANI-Docs/
├── README.md
├── CONTRIBUTING.md
├── product/
│   ├── SRS.md
│   └── BACKLOG_MANI.md
├── architecture/
│   ├── SAD.md
│   ├── SDD.md
│   ├── ModeloDatos.md
│   └── TECH_RADAR.md
├── adr/
│   └── ADR-00XX-*.md
├── governance/
│   ├── GOBIERNO_DEL_EQUIPO.md
│   ├── POLITICAS_DEVOPS_HERRAMIENTAS.md
│   └── INFRAESTRUCTURA_MANI.md
├── diagrams/
│   ├── HLD/                 landscape, infraestructura y Tech Radar
│   ├── LLD/
│   │   ├── workspace.dsl    modelo Structurizr, fuente de las vistas
│   │   └── Software/        vistas exportadas que incrusta el SDD
│   └── ModeloDatos.png
├── wiki/                    navegación por tema; no añade reglas propias
└── Entregas/                histórico académico; no es fuente de verdad
```

### Fuente de verdad por tema

| Tema | Documento |
|---|---|
| Requerimientos | [`product/SRS.md`](product/SRS.md) |
| Backlog | [`product/BACKLOG_MANI.md`](product/BACKLOG_MANI.md) |
| Arquitectura y drivers | [`architecture/SAD.md`](architecture/SAD.md) |
| Diseño detallado, vistas y diagramas | [`architecture/SDD.md`](architecture/SDD.md) |
| **Umbrales de calidad y escenarios de QA** | [`architecture/SDD.md`](architecture/SDD.md) §7 y §8 — **único lugar** |
| Modelo de datos, DDL y diccionario | [`architecture/ModeloDatos.md`](architecture/ModeloDatos.md) |
| Decisiones arquitectónicas | [`adr/`](adr/) |
| Modelo de diagramas | [`diagrams/LLD/workspace.dsl`](diagrams/LLD/workspace.dsl) |
| Tecnologías vigentes | [`architecture/TECH_RADAR.md`](architecture/TECH_RADAR.md) |
| Gobierno y reglas de trabajo | [`governance/GOBIERNO_DEL_EQUIPO.md`](governance/GOBIERNO_DEL_EQUIPO.md) |
| DevOps, calidad y herramientas | [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) |
| Infraestructura y ambientes | [`governance/INFRAESTRUCTURA_MANI.md`](governance/INFRAESTRUCTURA_MANI.md) |

Un dato que aparece en dos documentos tiene **un solo dueño**: el de esta tabla. Si otro documento
lo contradice, manda el dueño y el otro se corrige.

---

## 13. Modelo de datos

El documento de modelo de datos contiene glosario, modelo conceptual, lógico y físico, DER, DDL
operacional, diccionario de datos, Data Warehouse, modelo dimensional, DDL analítico, controles de
calidad, propiedad de datos por servicio y la **matriz de cobertura de requisitos** (§14), que
mapea cada RF del SRS a las tablas que lo soportan.

La analítica permanece separada del OLTP para no degradar la operación transaccional.

---

## 14. Convenciones

- Ninguna decisión arquitectónica se considera oficial únicamente por aparecer en una conversación o propuesta.
- Los cambios arquitectónicos relevantes se formalizan mediante ADR.
- Los ADR históricos no se eliminan; cuando una decisión cambia se marca como `Superseded`.
- Los requerimientos se mantienen separados de las decisiones de implementación.
- No se duplican decisiones completas entre SRS, SAD, SDD, ADR, políticas e infraestructura.
- Los documentos no llevan número de versión. La versión es el commit.
- Los umbrales de calidad se definen una sola vez, en el SDD.

---

## 15. Licencia y uso

Proyecto académico desarrollado por **TRAMA · Ingeniería de Software**.

El uso, distribución y publicación del código y documentación se rige por las condiciones definidas por el equipo y el contexto académico del proyecto.

# MANI

**MANI** es una plataforma SaaS multi-tenant para formalizar y gestionar operaciones de servicio, conectando clientes con aliados durante todo el ciclo:

`Solicitud → Cotización → Ejecución → Calificación → Cierre`

El proyecto es desarrollado por **TRAMA · Ingeniería de Software**.

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

---

## 3. Principios del producto

MANI se diseña bajo los siguientes criterios:

- **Multi-tenancy:** cada empresa opera con datos, usuarios y configuración aislados.
- **Configurabilidad:** las reglas de cada tenant cambian mediante configuración, no mediante una versión distinta del software.
- **Trazabilidad:** las operaciones relevantes del ciclo del servicio deben poder reconstruirse.
- **Idempotencia:** las operaciones críticas deben soportar reintentos sin duplicar efectos.
- **Concurrencia controlada:** una solicitud solo puede terminar con una asignación válida.
- **Cobertura por zonas:** el MVP no utiliza geolocalización en tiempo real ni cálculo por radio.
- **Seguridad en profundidad:** identidad, autorización y aislamiento de datos se validan en más de una capa.

---

## 4. Arquitectura

La arquitectura objetivo de MANI es:

> **SOA distribuida + API Gateway + enfoque políglota + multi-tenancy**

### Componentes principales

| Componente | Tecnología | Responsabilidad |
|---|---|---|
| Cliente | Flutter / Dart | Aplicación web y móvil |
| API Gateway | NGINX | Entrada única, routing y políticas transversales |
| Rules Service | Java | Reglas configurables por tenant, ranking y tarifarios |
| Dispatch Service | .NET | Despacho, asignación y control de concurrencia |
| Core Services | Node.js | Tenants, usuarios, aliados, clientes, KYC, cotizaciones, ejecución y comunicación |
| Availability Service | Node.js | Cobertura, disponibilidad y elegibilidad |
| Persistencia | Supabase | Plataforma administrada |
| Motor de datos | PostgreSQL | Persistencia relacional y RLS |

Supabase se utiliza como **plataforma administrada** y PostgreSQL como su **motor de base de datos**. No son dos alternativas distintas.

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
DEV → TEST/QA → PROD
```

No se define un cuarto ambiente STAGING independiente.

La promoción debe mantener el principio:

> **Build once, deploy many**

El mismo artefacto validado debe promoverse entre ambientes sin reconstruirse.

### Decisiones de infraestructura pendientes

La ubicación concreta del clúster Kubernetes, la configuración definitiva de DEV y el registro oficial de imágenes se encuentran pendientes de cierre con DevOps.

Hasta que esas decisiones queden ratificadas, este README no fija un proveedor de hosting ni un registro de contenedores como parte de la arquitectura oficial.

---

## 7. Contenerización y orquestación

- Docker / OCI para empaquetado.
- Kubernetes como orquestador requerido por el proyecto.
- GitHub Actions para CI/CD.
- Despliegues segregados por ambiente.
- Configuración y secretos externos al artefacto.

El dimensionamiento y proveedor de cómputo del clúster se documentan en el documento de Infraestructura cuando exista decisión ratificada.

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
TEST/QA
   ↓
Newman
   ↓
OWASP ZAP
   ↓
Promoción a PROD
```

Herramientas principales:

- **SonarQube:** SAST y Quality Gates.
- **OWASP ZAP:** DAST sobre TEST/QA.
- **Postman / Newman:** pruebas funcionales, contratos y aislamiento multi-tenant.
- **k6:** pruebas de carga y concurrencia cuando corresponda.

---

## 9. Observabilidad

La estrategia definida utiliza:

- **Prometheus** para métricas;
- **Grafana** para visualización;
- **Datadog** para logs, APM y trazas;
- `correlation_id` para seguimiento distribuido;
- Jira como destino de incidentes relevantes.

---

## 10. Estrategia de repositorios

MANI adopta una estrategia **multi-repo**.

Estructura objetivo:

```text
MANI-Flutter
MANI-Gateway
MANI-Rules-Java
MANI-Dispatch-DotNet
MANI-Core-Node
MANI-Availability
MANI-Infra
MANI-Docs
```

Cada unidad desplegable mantiene de forma independiente:

- código fuente;
- dependencias;
- pruebas;
- pipeline;
- versionamiento;
- artefacto contenerizado.

---

## 11. Gestión del proyecto

El proyecto se ejecuta bajo **Scrum**.

Herramientas principales:

- **Jira:** backlog, épicas, historias, bugs, sprints y seguimiento.
- **GitHub:** código, Pull Requests, issues técnicos, CI/CD y documentación técnica versionable.
- **Discord:** comunicación operativa del equipo.
- **OneDrive:** documentación administrativa, actas e informes cuando corresponda.

Las decisiones técnicas costosas de revertir pasan por la **Mesa de Arquitectura** y se registran mediante ADR.

---

## 12. Equipo

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

## 13. Documentación

La documentación del proyecto se divide por responsabilidad para evitar duplicidad.

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
│   ├── ALTO_NIVEL/          DHL, infraestructura y Tech Radar
│   ├── C4Model/
│   │   ├── workspace.dsl    modelo Structurizr, fuente de las vistas C4
│   │   └── png/             vistas exportadas que incrusta el SDD
│   └── ModeloDatos.png
├── wiki/                    consulta por tema; no añade reglas propias
└── Entregas/                entregables academicos por corte
```

### Fuente de verdad por tema

| Tema | Documento |
|---|---|
| Requerimientos | [`product/SRS.md`](product/SRS.md) |
| Backlog | [`product/BACKLOG_MANI.md`](product/BACKLOG_MANI.md) |
| Arquitectura | [`architecture/SAD.md`](architecture/SAD.md) |
| Diseño detallado y vistas C4 | [`architecture/SDD.md`](architecture/SDD.md) |
| Modelo de datos, DDL y diccionario | [`architecture/ModeloDatos.md`](architecture/ModeloDatos.md) |
| Decisiones arquitectónicas | [`adr/`](adr/) |
| Modelo C4 | [`diagrams/C4Model/workspace.dsl`](diagrams/C4Model/workspace.dsl) |
| Tecnologías vigentes | [`architecture/TECH_RADAR.md`](architecture/TECH_RADAR.md) |
| Gobierno y reglas de trabajo | `GOBIERNO_DEL_EQUIPO.md` |
| DevOps, calidad y herramientas | `POLITICAS_DEVOPS_HERRAMIENTAS.md` |
| Infraestructura y ambientes | `INFRAESTRUCTURA_MANI.md` |

---

## 14. Modelo de datos

El documento de modelo de datos contiene:

- glosario de datos;
- modelo conceptual;
- modelo lógico;
- DER;
- modelo físico;
- DDL operacional;
- diccionario de datos;
- Data Warehouse;
- modelo dimensional;
- DDL del Data Warehouse;
- calidad de datos;
- relación datos ↔ servicios.

La analítica permanece separada del OLTP para no degradar la operación transaccional.

---

## 15. Estado documental

La arquitectura, requerimientos, ADR y modelo de datos ya fueron depurados hacia la línea base actual.

Se mantiene pendiente el cierre con DevOps de tres decisiones de infraestructura:

1. ubicación concreta de Kubernetes en TEST/QA y PROD;
2. estrategia definitiva de DEV para Supabase/local;
3. registro oficial de imágenes.

Estas decisiones deberán actualizar el documento de Infraestructura y las políticas DevOps sin modificar los requerimientos funcionales del producto.

---

## 16. Convenciones

- Ninguna decisión arquitectónica se considera oficial únicamente por aparecer en una conversación o propuesta.
- Los cambios arquitectónicos relevantes se formalizan mediante ADR.
- Los ADR históricos no se eliminan; cuando una decisión cambia se marca como `Superseded`.
- Los requerimientos se mantienen separados de las decisiones de implementación.
- No se duplican decisiones completas entre SRS, SAD, SDD, ADR, políticas e infraestructura.

---

## 17. Licencia y uso

Proyecto académico desarrollado por **TRAMA · Ingeniería de Software**.

El uso, distribución y publicación del código y documentación se rige por las condiciones definidas por el equipo y el contexto académico del proyecto.

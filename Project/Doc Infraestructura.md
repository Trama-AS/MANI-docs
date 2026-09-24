# TRAMA · MANI — DOC-08: Topología de Ambientes DEV / QA / PROD
## Estrategia de Segregación, Convivencia y Trazabilidad de Requisitos

| Metadato | Valor |
| :--- | :--- |
| **Proyecto** | MANI — Plataforma Multi-Tenant de Formalización de Operaciones de Servicio |
| **Organización** | TRAMA · Ingeniería de Software |
| **Identificador** | **DOC-08** |
| **Documento** | Topología de Ambientes DEV / QA / PROD (Qué se comparte, qué se aísla y por qué) |
| **Versión** | 1.0 (Línea Base para Sprint 2) |
| **Fecha** | 2026-09-21 |
| **Responsables** | Daniel Ávila (DevOps Titular), Santiago (QA / Product Owner), Sara Albarracín (Scrum Master) y Mesa de Arquitectura |
| **Fuentes y Trazabilidad** | ADR-0004, ADR-0005, ADR-0010, ADR-0012, ADR-0013, ADR-0015, ADR-0018, ADR-0023, SRS V3 (RNF-01, RNF-07, RNF-09, REST-02, PROY-07, PROY-08), Gobierno del Equipo (§2.2, §2.4, §2.5) |

---

## Control de Versiones

| Versión | Fecha | Autor(es) | Descripción del Cambio | Estado |
| :---: | :---: | :--- | :--- | :---: |
| **1.0** | 2026-09-21 | Daniel Ávila, Santiago, Mesa de Arquitectura | Versión inicial de la topología de ambientes DEV, QA (Release) y PROD. Se define la arquitectura híbrida (Docker Local para DEV, instancias dedicadas de Supabase para QA y PROD), la matriz exhaustiva de segregación/convivencia y la trazabilidad hacia los requisitos funcionales, no funcionales, restricciones y decisiones arquitectónicas (ADR). | **Aprobada** |

---

## 0. Resumen Ejecutivo y Propósito

El presente documento formaliza la **Topología de Ambientes DEV / QA / PROD** para la plataforma **MANI**, resolviendo la necesidad operativa y arquitectónica de establecer fronteras claras entre el trabajo de desarrollo individual, la estabilización y aseguramiento de calidad (QA), y la operación productiva en vivo.

### Objetivos Clave
1. **Unificación de Nomenclatura:** Homologar la correspondencia unívoca entre las ramas del repositorio Gitflow (`develop`, `release`, `main`) y los ambientes de despliegue (**DEV**, **QA/Testing**, **PROD**), resolviendo el hallazgo registrado en *Gobierno del Equipo §2.2*.
2. **Definición de Infraestructura Híbrida:** Especificar la ubicación física y lógica de la persistencia de datos:
   - **DEV:** Entorno local autocontenido en **Docker** (PostgreSQL 16 Alpine + Adminer).
   - **QA (Release):** Proyecto dedicado en **Supabase Cloud** (esquema y base de datos de Testing/Staging).
   - **PROD (Main):** Proyecto dedicado y estrictamente aislado en **Supabase Cloud** (esquema y base de datos de Producción).
3. **Trazabilidad Rigurosa:** Justificar cada decisión técnica de **qué se comparte** y **qué se aísla** a partir de los requerimientos no funcionales (seguridad, aislamiento multi-tenant, disponibilidad), restricciones de costo y decisiones de la Mesa de Arquitectura (ADRs).

---

## 1. Homologación de Nomenclatura y Mapeo Gitflow ➔ Ambientes

En cumplimiento con el [ADR-0004](file:///C:/Users/santi/OneDrive/Documentos/MANI-docs/MANI-docs/ADR/ADR-0004-pipeline-cicd-promocion-ambientes.md) y *Gobierno del Equipo §2.2*, se establece la equivalencia vinculante entre ramas, ambientes, propósitos y artefactos:

| Ambiente | Rama Git | Propósito Operativo | Tipo de Persistencia | Registro y Tags (GHCR) | Artefactos Emitidos |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **DEV** (Development) | `develop` | Integración continua de funcionalidades, pruebas locales de desarrollador y sandbox individual. | **Docker Local** (PostgreSQL 16 Alpine + Seeds controlados). | `ghcr.io/trama-as/mani-flutter:dev`, `dev-<sha>` | Contenedor local, builds web locales. |
| **QA** (Testing / Staging) | `release` / `release/*` | Validación funcional, pruebas de integración multi-servicio, pruebas de carga (k6), pruebas de seguridad (DAST) y aceptación por QA. | **Supabase Cloud (Proyecto QA)**. | `ghcr.io/trama-as/mani-flutter:staging`, `testing`, `release`, `staging-<sha>` | Imagen Docker de Staging, bundle descargable `flutter-web-staging.zip`. |
| **PROD** (Production) | `main` | Entorno productivo oficial, alta disponibilidad, usuarios finales y transaccionalidad real de negocio. | **Supabase Cloud (Proyecto PROD)** aislado. | `ghcr.io/trama-as/mani-flutter:latest`, `v[0-9]+.[0-9]+.[0-9]+*` | Imagen de Producción inmutable, GitHub Release oficial con tag semántico. |

---

## 2. Arquitectura Detallada por Ambiente

### 2.1 Ambiente DEV (Desarrollo Local / Sandbox)
* **Destinatarios:** Ingenieros de Frontend y Backend en su máquina de trabajo.
* **Infraestructura de Cómputo:** Localhost (Flutter Run en Web/Chrome/Emulador móvil).
* **Persistencia & Base de Datos:** Contenedor Docker `mani-postgres` corriendo `postgres:16-alpine` orquestado mediante `docker-compose.yml`:
  - **Esquema:** Inicializado automáticamente mediante el script oficial `database/init/01-schema.sql` (17 tablas, extensiones `pgcrypto`, llaves foráneas e integridad referencial idéntica a producción).
  - **Datos Semilla:** Inicializados con `database/init/02-seed.sql` conteniendo un tenant ficticio (`TRAMA Servicios Demo`), zonas (`Bogotá D.C.`, `Chapinero`, `Usaquén`), categorías de servicio y usuarios de prueba.
* **Herramientas de Gestión:** Interfaz Web ligera **Adminer** en `http://localhost:8088`.
* **Aislamiento:**
  - El ambiente DEV **NO se conecta a la nube de Supabase**, protegiendo los límites de uso de proyectos en la capa gratuita (*REST-02*) y garantizando que los desarrolladores puedan trabajar de forma autónoma y offline sin riesgo de interferencias cruzadas.

### 2.2 Ambiente QA (Testing / Staging / Release)
* **Destinatarios:** Rol de QA (Santiago), Product Owner y automatizaciones de prueba (Newman, k6).
* **Infraestructura de Cómputo:** Despliegue contenerizado en staging (Railway / GHCR Staging Package) y artefacto empaquetado `flutter-web-staging.zip` para auditoría y validación en navegadores de testing.
* **Persistencia & Base de Datos:** **Proyecto Cloud Supabase dedicado exclusivamente a QA**:
  - Contiene exactamente el mismo DDL (17 tablas) que el entorno de desarrollo y producción.
  - Implementa el motor de políticas de seguridad por fila (**Row-Level Security - RLS**) para validar que el aislamiento multi-tenant opere correctamente antes de pasar a producción.
* **Datos:** Datos sintéticos, generados mediante suites de prueba de QA o seeds avanzados, reseteables bajo demanda sin impacto en operaciones reales.
* **Almacenamiento de Archivos:** Bucket de Supabase Storage segregado para pruebas de carga de documentos KYC (*ADR-0013*).
* **Seguridad DevSecOps:** Pruebas dinámicas DAST (OWASP ZAP) y pruebas de API automatizadas con Postman/Newman (*ADR-0005*).

### 2.3 Ambiente PROD (Producción / Main)
* **Destinatarios:** Clientes finales, Aliados prestadores de servicios, Administradores de Tenant y Dirección de TRAMA.
* **Infraestructura de Cómputo:** Contenedor inmutable de producción desplegado sobre la plataforma oficial de hosting, registrado con tag semántico en GitHub Container Registry (`ghcr.io/trama-as/mani-flutter:vX.Y.Z`).
* **Persistencia & Base de Datos:** **Proyecto Cloud Supabase dedicado exclusivamente a Producción**:
  - Acceso restringido por red y autenticación robusta mediante secretos inyectados exclusivamente en tiempo de ejecución.
  - Políticas de RLS estrictas y vinculantes (*ADR-0012*).
  - Backups diarios automatizados, retención de logs transaccionales y cifrado en tránsito (TLS 1.3) y en reposo (AES-256).
* **Almacenamiento de Archivos:** Bucket de Supabase Storage productivo con aislamiento criptográfico por tenant y acceso temporal mediante URLs prefirmadas de corta duración (*ADR-0013*).
* **Control de Calidad:** Pipeline de CI/CD vinculado a **Quality Gate aprobatorio de SonarCloud** (*ADR-0005*).

---

## 3. Matriz Exhaustiva: ¿Qué se Comparte vs. Qué se Aísla?

La siguiente matriz documenta la totalidad de los componentes técnicos de la arquitectura, clasificando su estado de convivencia y trazando la justificación técnica a los requerimientos del proyecto:

| # | Capa / Componente | Estado | Detalle de Implementación | Justificación Técnica y Operativa | Requisito Trazable |
| :-: | :--- | :---: | :--- | :--- | :--- |
| **1** | **Motor de Base de Datos** | **Aislado** | • **DEV:** Docker PostgreSQL 16 Alpine en máquina local.<br>• **QA:** Proyecto Supabase Cloud (QA Instance).<br>• **PROD:** Proyecto Supabase Cloud (PROD Instance). | Evita contención de recursos, previene caídas accidentales de producción por pruebas de carga o spikes en DEV/QA, y garantiza que incidentes en desarrollo no afecten la disponibilidad. | **RNF-07** (Disponibilidad)<br>**REST-02** (Control de costos cloud)<br>**ADR-0023** |
| **2** | **Esquema DDL (Tablas y Tipos)** | **Compartido** (Homogéneo) | Exactamente el mismo script DDL (17 tablas, `pgcrypto`, llaves foráneas, índices) se aplica en los 3 ambientes de manera versionada (`database/init/01-schema.sql`). | Principio de *Paridad de Ambientes* (Twelve-Factor App). Garantiza que una funcionalidad probada en DEV o QA no falle en PROD por discrepancias estructurales de esquema. | **RNF-09** (Integridad referencial)<br>**ADR-0004** (Build Once, Deploy Anywhere)<br>**Gobierno §2.8** |
| **3** | **Datos y Registros (Persistencia)** | **Aislado** | • **DEV:** Datos semilla mock (`02-seed.sql`).<br>• **QA:** Datos sintéticos de prueba y fixtures de QA.<br>• **PROD:** Datos reales de empresas (tenants), clientes y aliados. | Prohibición legal y de seguridad de exponer información real de clientes/aliados en entornos no productivos. Protege la confidencialidad de la información. | **RNF-01** (Aislamiento de datos)<br>**ADR-0012** (Multi-tenant)<br>**ADR-0015** (Estrategia pruebas) |
| **4** | **Autenticación e Identidad (Auth)** | **Aislado** | • **DEV:** Mock/Bypass local o JWT estático para desarrollo ágil.<br>• **QA:** Supabase GoTrue (Auth) de la instancia de QA con usuarios dummy.<br>• **PROD:** Supabase GoTrue productivo con verificación real de correo, hashing bcrypt y emisión de JWT firmados. | Previene la contaminación de directorios de usuarios. Las credenciales creadas para tests nunca deben coexistir con usuarios reales en producción. | **RNF-01** (Seguridad e identidad)<br>**ADR-0018** (Identificación de tenant no falsificable)<br>**ADR-0022** |
| **5** | **Almacenamiento de Archivos (KYC)** | **Aislado** | • **DEV:** Almacenamiento local o mock en filesystem.<br>• **QA:** Bucket `kyc-documents-staging` en Supabase QA Storage.<br>• **PROD:** Bucket `kyc-documents-prod` en Supabase PROD Storage con políticas de acceso cifrado. | Cumplimiento estricto de la política de aislamiento de documentos de identidad y soporte de aliados. Los documentos sensibles de personas reales solo existen en PROD. | **ADR-0013** (Almacenamiento KYC)<br>**RF-05 / RF-06** (Aislamiento de documentos KYC)<br>**RNF-01** |
| **6** | **Registro de Contenedores (GHCR)** | **Compartido** (con Tags Segregados) | Se utiliza el mismo registro `ghcr.io/trama-as/mani-flutter` pero con etiquetas mutuamente excluyentes:<br>• DEV: `dev`, `dev-<sha>`<br>• QA: `staging`, `testing`, `release`<br>• PROD: `latest`, `vX.Y.Z` | Centraliza el repositorio de artefactos bajo la misma gobernanza institucional en GitHub, pero aísla estrictamente las versiones promovibles mediante inmutabilidad de tags. | **ADR-0004** (Pipeline CI/CD)<br>**PROY-08** (Contenerización)<br>**Gobierno §2.1** |
| **7** | **Variables de Entorno y Secretos** | **Aislado** | • **DEV:** Archivo `.env` local (ignorado en Git por `.gitignore`).<br>• **QA:** GitHub Secrets para rama `release`.<br>• **PROD:** GitHub Environment Secrets con protección de ambiente `production` (aprobación requerida). | *Zero Trust*: Las credenciales de base de datos y llaves de servicio de producción nunca deben ser visibles ni accesibles para ramas de desarrollo o testing. | **ADR-0005** (DevSecOps / Gestión de Secretos)<br>**Gobierno §2.4** |
| **8** | **Políticas de Row-Level Security (RLS)** | **Compartido** (Reglas) / **Aislado** (Ejecución) | La definición de las políticas de RLS es idéntica en código (DDL), pero su ejecución se evalúa contra los datos aislados de cada base de datos (QA y PROD). | Asegura que el comportamiento de seguridad multi-tenant sea auditado y validado en QA con el mismo rigor que operará en producción. | **ADR-0012** (Aislamiento Multi-Tenant)<br>**ADR-0018** (Propagación de Tenant)<br>**RNF-01** |
| **9** | **Red y Nombres de Dominio** | **Aislado** | • **DEV:** `http://localhost:8080`, `localhost:5432`.<br>• **QA:** Dominio de staging (ej. `https://staging-app.mani.trama.com`).<br>• **PROD:** Dominio principal (ej. `https://app.mani.trama.com`). | Aislamiento a nivel de DNS y certificados TLS (HTTPS). Evita errores de cross-origin (CORS) y confusión de los usuarios entre entornos de prueba y producción. | **RNF-07** (Confiabilidad y disponibilidad) |
| **10** | **Pipeline y Quality Gates (CI/CD)** | **Aislado** (Diferenciado por Ambiente) | • **DEV:** Linter (`analyze`), formato (`format`), tests con cobertura y build check.<br>• **QA:** Mismo CI + publicación en GHCR staging + empaquetado de artefacto QA.<br>• **PROD:** Mismo CI + **SonarCloud SAST & Quality Gate vinculante** + Release oficial. | Adaptado a las restricciones de licenciamiento de herramientas (plan gratuito de SonarCloud para ramas no principales) sin comprometer el estándar de producción. | **ADR-0004** (Promoción de Ambientes)<br>**ADR-0005** (SAST en CI/CD)<br>**REST-02** |

---

## 4. Diagramas Oficiales del Flujo Gitflow y Mapeo a Ambientes

De acuerdo con el estándar definido en la **Wiki del repositorio `MANI-Flutter`** ([`Gitflow-Workflow.md`](file:///C:/Users/santi/OneDrive/Documentos/MANI-Flutter-Wiki/Gitflow-Workflow.md)), el proyecto adopta formalmente el modelo estricto de Gitflow (Vincent Driessen / Atlassian). A continuación se presentan los diagramas oficiales de la Wiki y su correspondencia con la topología de ambientes:

### 4.1 Estructura de Ramas Principales (`main` y `develop`)

Las dos ramas históricas gobiernan el estado base de los ambientes de **Desarrollo (DEV)** y **Producción (PROD)**:

![Estructura general de ramas historicas main y develop](https://dam-cdn.atl.orangelogic.com/AssetLink/3we6dfk04vp4y2f0f2188t6j13n4424h.svg)

* **`develop` ➔ Ambiente DEV:** Rama de integración continua donde convergen las características. Gobierna las pruebas en el entorno local de desarrollo respaldado por **Docker** (`postgres:16-alpine` + Adminer).
* **`main` ➔ Ambiente PROD:** Rama de código productivo oficial. Cada commit en `main` representa una versión liberada respaldada por **Supabase Cloud (PROD)** y publicada con tag semántico (`vX.Y.Z`).

---

### 4.2 Ramas de Característica (`feature/*`)

Cada nueva funcionalidad nace y muere en `develop`, aislada del resto del equipo hasta su integración:

![Diagrama de ramas Feature](https://dam-cdn.atl.orangelogic.com/AssetLink/7yu4h3oai315s158nq6t313p25e82o32.svg)

* **Mapeo a Ambiente:** Se ejecutan y validan exclusivamente en el **Ambiente DEV** del desarrollador usando su base de datos local contenerizada.
* **Integración:** Ingresan a `develop` únicamente mediante Pull Request con validación de CI en verde (`dart format`, `flutter analyze`, `flutter test`).

---

### 4.3 Ramas de Estabilización y Testing (`release/*`)

Cuando `develop` acumula suficientes características para un lanzamiento planificado, se corta la rama `release`:

![Diagrama de ramas Release](https://dam-cdn.atl.orangelogic.com/AssetLink/le16ot34d0e862mba18e7j7i502585eb.svg)

* **Mapeo a Ambiente:** Alimenta directamente el **Ambiente QA (Testing / Staging)**.
* **Persistencia:** Se conecta a la instancia dedicada de **Supabase Cloud (QA)**.
* **Artefactos:** Dispara la compilación y publicación de la imagen en GHCR con tags `staging`, `testing`, `release` y empaqueta el artefacto `flutter-web-staging.zip` para auditoría de QA.
* **Cierre:** Al ser aprobada por QA y PO, se mezcla hacia `main` (con tag de versión `vX.Y.Z`) y de regreso a `develop`.

---

### 4.4 Ramas de Mantenimiento Urgente (`hotfix/*`)

Permiten solucionar defectos críticos detectados en producción sin arrastrar trabajo en curso de `develop`:

![Diagrama de ramas Hotfix](https://dam-cdn.atl.orangelogic.com/AssetLink/t8b1bnptx6bn40wc43g83j02u5b61064.svg)

* **Flujo:** Nace de `main`, se valida en el entorno de **QA**, se promueve directamente a `main` (emitiendo tag de corrección `vX.Y.Z+1`) y se sincroniza inmediatamente de regreso hacia `develop`.

---

## 5. Políticas Operativas de Gestión y Promoción

### 5.1 Principio *Schema-First* y Versionamiento de Migraciones
1. **Evolución Controlada:** Ninguna modificación al esquema DDL de la base de datos se realiza manualmente en Supabase Cloud.
2. **Versionamiento:** Todo cambio en tablas, columnas, restricciones o extensiones debe plasmarse primero en un script SQL versionado en el repositorio (carpeta `database/init/` en `MANI-Flutter` o repositorio backend correspondiente).
3. **Flujo de Despliegue de Esquema:**
   $$\text{Script SQL en Git} \longrightarrow \text{Verificación en Docker DEV} \longrightarrow \text{Ejecución en Supabase QA} \longrightarrow \text{Ejecución en Supabase PROD}$$

### 5.2 Criterios de Paso entre Ambientes (Gates de Calidad)

#### Paso 1: DEV ➔ QA (Merge a `release`)
* Rama `develop` con pipeline de GitHub Actions en verde (formato, linter y tests de cobertura aprobados).
* PR revisado y aprobado por mínimo un par técnico (*Gobierno §2.3*).
* DoR cumplida y criterios de aceptación funcionales validados en local.

#### Paso 2: QA ➔ PROD (Merge a `main`)
* Pruebas de QA satisfactorias en el ambiente de Staging (sin defectos abiertos de severidad Crítica o Alta, *E6 ≤ 2* según *Gobierno §1.4.3*).
* Artefacto `flutter-web-staging.zip` validado por el rol de QA (Santiago).
* Aceptación formal del incremento por el Product Owner (*Gobierno §1.1.3*).
* Autorización y ejecución del merge a cargo de **Daniel Ávila (DevOps Titular)**.
* **Quality Gate de SonarCloud aprobado en el pipeline de `main`** (*ADR-0005*).

### 5.3 Gestión de Secretos y Control de Acceso por Roles
* **Desarrolladores:** Acceso total a su contenedor Docker local (`postgres:postgres`). Sin acceso a credenciales de la base de datos de producción.
* **QA (Santiago):** Acceso al dashboard de Supabase QA para inspección de datos de prueba, depuración de RLS y reseteo de fixtures.
* **DevOps Titular (Daniel Ávila):** Custodia de las credenciales maestras (`service_role_key`, strings de conexión) de los proyectos Supabase QA y PROD en los repositorios de GitHub Secrets correspondientes.

---

## 6. Matriz de Trazabilidad Cruzada de Requisitos

La siguiente tabla sintetiza la correspondencia directa entre los requisitos y decisiones del proyecto y las directrices topológicas de este documento:

| Código de Requisito / Decisión | Descripción del Requisito | Directriz Topológica Adoptada en DOC-08 |
| :--- | :--- | :--- |
| **RNF-01** | Aislamiento lógico estricto multi-tenant de datos y archivos. | Segregación total de bases de datos y buckets de storage entre QA y PROD; ejecución de políticas RLS en Supabase; datos reales confinados a PROD. |
| **RNF-07** | Disponibilidad y confiabilidad operacional en producción. | Base de datos de PROD totalmente aislada e inmune a pruebas de carga o errores de desarrollo generados en DEV o QA. |
| **RNF-09** | Integridad referencial y consistencia de datos. | Esquema DDL compartido e idéntico (17 tablas con llaves foráneas y tipos comunes) en los tres ambientes. |
| **REST-02** | Restricción financiera y control de costos de infraestructura cloud. | Uso de Docker local para DEV (evitando consumir límites de proyectos cloud) y optimización de tiers en Supabase. |
| **PROY-07** | Arquitectura multi-servicio distribuida y heterogénea. | Soporte de conexión simultánea para clientes Flutter y backends contenerizados hacia la capa de persistencia. |
| **PROY-08** | Requisito de contenerización y portabilidad. | Empaquetado Docker con tags diferenciados en GHCR (`dev`, `staging`, `release`, `latest`). |
| **ADR-0004** | Promoción formal de ambientes (`develop` ➔ `release` ➔ `main`). | Homologación unívoca de ramas Gitflow con los ambientes DEV, QA y PROD. |
| **ADR-0005** | DevSecOps, SAST, DAST y Quality Gates. | Análisis estático SonarCloud obligatorio en PROD; pruebas dinámicas y funcionales ejecutadas sobre QA. |
| **ADR-0012** | Persistencia sobre Supabase/PostgreSQL con RLS. | Selección de Supabase Cloud como motor gestionado para QA y PROD, y PostgreSQL 16 local para DEV. |
| **ADR-0013** | Almacenamiento seguro de documentos KYC. | Buckets de Supabase Storage segregados e independientes entre Staging y Producción. |
| **ADR-0015** | Estrategia de pruebas de aislamiento multi-tenant. | Entorno QA habilitado con datos sintéticos para verificación exhaustiva de RLS sin riesgo de fuga de datos. |
| **ADR-0018** | Identificación criptográfica de tenant vía JWT. | Emisión de tokens independientes por proyecto de Supabase (GoTrue QA vs GoTrue PROD). |
| **ADR-0023** | Consolidación de stack y eliminación de Azure. | Persistencia centrada en Supabase y contenedores Docker sin dependencia de infraestructura Azure. |
| **Gobierno §2.2** | Definición de los tres ambientes y resolución de inconsistencias. | Cierre formal de la nomenclatura DEV / QA / PROD y definición de sus fronteras operativas. |
| **Gobierno §2.4** | Gestión de secretos y seguridad. | Aislamiento estricto de credenciales por ramas mediante GitHub Secrets y Environments. |
| **Gobierno §2.5** | Paso obligatorio por ambientes DEV y QA antes de PROD. | Prohibición técnica de despliegues directos a producción sin pasar por la validación previa en DEV y QA. |

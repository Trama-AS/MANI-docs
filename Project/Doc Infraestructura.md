# TRAMA · MANI — DOC-08: Topología de Ambientes DEV / QA / PROD
## Estrategia de Segregación, Convivencia, Despliegue en VMs y Trazabilidad de Requisitos

| Metadato | Valor |
| :--- | :--- |
| **Proyecto** | MANI — Plataforma Multi-Tenant de Formalización de Operaciones de Servicio |
| **Organización** | TRAMA · Ingeniería de Software |
| **Identificador** | **DOC-08** |
| **Documento** | Topología de Ambientes DEV / QA / PROD, Despliegue en Servidores Linux y Monitoreo |
| **Versión** | **2.0 (Línea Base Operativa Sprint 2 — Despliegue en VMs y CI/CD)** |
| **Fecha** | 2026-09-23 |
| **Responsables** | Daniel Ávila (DevOps Titular), Santiago (QA / Product Owner), Sara Albarracín (Scrum Master) y Mesa de Arquitectura |
| **Fuentes y Trazabilidad** | ADR-0004, ADR-0005, ADR-0010, ADR-0012, ADR-0013, ADR-0015, ADR-0018, ADR-0023, SRS V3 (RNF-01, RNF-07, RNF-09, REST-02, PROY-07, PROY-08), Gobierno del Equipo (§2.2, §2.4, §2.5) |

---

## Control de Versiones

| Versión | Fecha | Autor(es) | Descripción del Cambio | Estado |
| :---: | :---: | :--- | :--- | :---: |
| **1.0** | 2026-09-21 | Daniel Ávila, Santiago, Mesa de Arquitectura | Versión inicial de la topología de ambientes DEV, QA (Release) y PROD. Se define la arquitectura híbrida (Docker Local para DEV, instancias dedicadas de Supabase para QA y PROD), matriz de segregación/convivencia y trazabilidad de requisitos. | **Superada** |
| **2.0** | 2026-09-23 | Daniel Ávila, Santiago, Mesa de Arquitectura | Incorporación de la infraestructura física/virtual de cómputo en **Linux VMs (Red Universitaria)** para PROD (`10.43.98.203`) y QA (`10.43.100.141`). Especificación de aprovisionamiento con Docker Engine, scripts de despliegue atómicos (`deploy-prod.sh`, `deploy-qa.sh`), autenticación GHCR con Personal Access Tokens (PAT), sincronización periódica automatizada con Cron (1h en PROD, 30m en QA), scripts de observabilidad y healthchecks continuos cada 15s, y reglas de segregación en pipelines CI/CD de GitHub Actions (resolución de limitaciones de SonarCloud en branches no-main). | **Aprobada** |

---

## 0. Resumen Ejecutivo y Propósito

El presente documento formaliza la **Topología de Ambientes DEV / QA / PROD** y la **Guía Operativa de Despliegue en Infraestructura de Cómputo** para la plataforma **MANI**, resolviendo la necesidad operativa y arquitectónica de establecer fronteras claras entre el trabajo de desarrollo individual, la estabilización y aseguramiento de calidad (QA), y la operación productiva en vivo.

### Objetivos Clave
1. **Unificación de Nomenclatura y Ciclo Gitflow:** Homologar la correspondencia unívoca entre las ramas del repositorio (`develop`, `release`, `main`) y los ambientes de ejecución (**DEV**, **QA/Testing**, **PROD**).
2. **Definición de Infraestructura Híbrida y Persistencia:**
   - **DEV:** Entorno local autocontenido en **Docker** (PostgreSQL 16 Alpine + Adminer).
   - **QA (Testing / Staging):** Proyecto dedicado en **Supabase Cloud** (Testing/Staging DB con RLS activo) y Servidor Virtual Linux dedicado en red institucional (`10.43.100.141`).
   - **PROD (Producción):** Proyecto dedicado y estrictamente aislado en **Supabase Cloud** (Producción DB con RLS estricto) y Servidor Virtual Linux dedicado en red institucional (`10.43.98.203`).
3. **Automatización de Despliegue Continuo (CD) Pull-Based:** Implementación de scripts atómicos y tareas programadas en Cron para jalar las imágenes contenerizadas desde **GitHub Container Registry (GHCR)** sin saturar recursos de red ni cómputo.
4. **Observabilidad y Healthchecks en Red Universitaria:** Disponibilidad de rutinas de sondeo periódicas cada 15 segundos para validar el estado operativo (`200 OK`) y latencia de respuesta de ambas máquinas virtuales desde cualquier terminal de la red.
5. **Trazabilidad y Calidad DevSecOps:** Mapeo de reglas de análisis estático (SonarCloud en `main`, linter y pruebas de cobertura en `develop` y `release`), respetando los límites de licenciamiento y asegurando cero bloqueos operativos.

---

## 1. Homologación de Nomenclatura y Mapeo Gitflow ➔ Ambientes

En cumplimiento con el [ADR-0004](file:///C:/Users/santi/OneDrive/Documentos/MANI-docs/MANI-docs/ADR/ADR-0004-pipeline-cicd-promocion-ambientes.md) y *Gobierno del Equipo §2.2*, se establece la equivalencia vinculante entre ramas, ambientes, propósitos, infraestructura de cómputo y artefactos:

| Ambiente | Rama Git | Propósito Operativo | Tipo de Persistencia | Infraestructura de Cómputo | Registro y Tags (GHCR) | Frecuencia de Actualización | Artefactos Emitidos |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **DEV** (Development) | `develop` | Integración continua, desarrollo de características y pruebas locales. | **Docker Local** (PostgreSQL 16 Alpine + Seeds). | Localhost / Docker Compose de cada ingeniero. | `ghcr.io/trama-as/mani-flutter:develop`, `dev`, `dev-<sha>` | En cada push/PR a `develop` | Contenedor local, builds web locales. |
| **QA** (Testing / Staging) | `release` / `release/*` | Validación funcional, pruebas de integración, auditoría de QA y aceptación PO. | **Supabase Cloud (Proyecto QA)** con RLS. | **Linux VM 2 (QA)**<br>`10.43.100.141:80` | `ghcr.io/trama-as/mani-flutter:staging`, `testing`, `release`, `staging-<sha>` | **Cada 30 minutos** vía Cron (`*/30 * * * *`) | Contenedor `mani-flutter-qa`, bundle descargable `flutter-web-staging.zip`. |
| **PROD** (Production) | `main` | Entorno productivo oficial, transaccionalidad real de negocio y alta disponibilidad. | **Supabase Cloud (Proyecto PROD)** aislado. | **Linux VM 1 (PROD)**<br>`10.43.98.203:80` | `ghcr.io/trama-as/mani-flutter:latest`, `v[0-9]+.[0-9]+.[0-9]+*` | **Cada 1 hora** vía Cron (`0 * * * *`) | Contenedor inmutable `mani-flutter-prod`, GitHub Release oficial con tag semántico. |

---

## 2. Arquitectura Detallada por Ambiente

### 2.1 Ambiente DEV (Desarrollo Local / Sandbox)
* **Destinatarios:** Ingenieros de Frontend y Backend en su estación de trabajo.
* **Infraestructura de Cómputo:** Localhost (Flutter Web / Chrome / Emulador móvil).
* **Persistencia & Base de Datos:** Contenedor Docker `mani-postgres` corriendo `postgres:16-alpine` orquestado mediante `docker-compose.yml`:
  - **Esquema:** Inicializado automáticamente mediante el script oficial `database/init/01-schema.sql` (17 tablas, extensiones `pgcrypto`, llaves foráneas e integridad referencial idéntica a producción).
  - **Datos Semilla:** Inicializados con `database/init/02-seed.sql` conteniendo un tenant ficticio (`TRAMA Servicios Demo`), zonas (`Bogotá D.C.`, `Chapinero`, `Usaquén`), categorías de servicio y usuarios de prueba.
* **Herramientas de Gestión:** Interfaz Web ligera **Adminer** en `http://localhost:8088`.
* **Aislamiento:**
  - El ambiente DEV **NO se conecta a la nube de Supabase**, protegiendo los límites de uso de proyectos en la capa gratuita (*REST-02*) y garantizando que los desarrolladores puedan trabajar de forma autónoma y offline sin riesgo de interferencias cruzadas.

### 2.2 Ambiente QA (Testing / Staging / Release)
* **Destinatarios:** Rol de QA (Santiago), Product Owner y automatizaciones de prueba (Newman, k6, suites de integración).
* **Infraestructura de Cómputo:** **Servidor Virtual Linux Dedicado (VM 2)** alojado en la intranet universitaria en la dirección IP **`10.43.100.141`**, sirviendo tráfico en el puerto HTTP estándar `80`.
* **Despliegue Contenerizado:** Contenedor Docker independiente nombrado `mani-flutter-qa`, ejecutando la imagen `ghcr.io/trama-as/mani-flutter:staging`.
* **Persistencia & Base de Datos:** **Proyecto Cloud Supabase dedicado exclusivamente a QA**:
  - Contiene exactamente el mismo DDL (17 tablas y migraciones versionadas) que producción.
  - Implementa el motor de políticas de seguridad por fila (**Row-Level Security - RLS**) para validar que el aislamiento multi-tenant opere correctamente antes de pasar a producción.
* **Datos:** Datos sintéticos, generados mediante suites de prueba de QA o seeds avanzados, reseteables bajo demanda sin impacto en operaciones reales.
* **Almacenamiento de Archivos:** Bucket de Supabase Storage segregado (`kyc-documents-staging`) para pruebas de carga de documentos KYC (*ADR-0013*).
* **Seguridad DevSecOps:** Pruebas dinámicas DAST y pruebas funcionales de integración (*ADR-0005*).

### 2.3 Ambiente PROD (Producción / Main)
* **Destinatarios:** Clientes finales, Aliados prestadores de servicios, Administradores de Tenant y Dirección de TRAMA.
* **Infraestructura de Cómputo:** **Servidor Virtual Linux Dedicado (VM 1)** alojado en la intranet universitaria en la dirección IP **`10.43.98.203`**, sirviendo tráfico en el puerto HTTP estándar `80`.
* **Despliegue Contenerizado:** Contenedor Docker inmutable nombrado `mani-flutter-prod`, ejecutando la imagen `ghcr.io/trama-as/mani-flutter:latest`.
* **Persistencia & Base de Datos:** **Proyecto Cloud Supabase dedicado exclusivamente a Producción**:
  - Acceso restringido por red y autenticación robusta mediante secretos inyectados exclusivamente en tiempo de ejecución.
  - Políticas de RLS estrictas y vinculantes (*ADR-0012*).
  - Backups diarios automatizados, retención de logs transaccionales y cifrado en tránsito (TLS 1.3) y en reposo (AES-256).
* **Almacenamiento de Archivos:** Bucket de Supabase Storage productivo (`kyc-documents-prod`) con aislamiento criptográfico por tenant y acceso temporal mediante URLs prefirmadas de corta duración (*ADR-0013*).
* **Control de Calidad:** Pipeline de CI/CD vinculado a **Quality Gate aprobatorio de SonarCloud** (*ADR-0005*).

---

## 3. Matriz Exhaustiva: ¿Qué se Comparte vs. Qué se Aísla?

La siguiente matriz documenta la totalidad de los componentes técnicos de la arquitectura, clasificando su estado de convivencia y trazando la justificación técnica a los requerimientos del proyecto:

| # | Capa / Componente | Estado | Detalle de Implementación | Justificación Técnica y Operativa | Requisito Trazable |
| :-: | :--- | :---: | :--- | :--- | :--- |
| **1** | **Infraestructura de Cómputo (Host)** | **Aislado** | • **DEV:** Localhost de cada máquina de desarrollo.<br>• **QA:** Linux VM dedicada (`10.43.100.141:80`).<br>• **PROD:** Linux VM dedicada (`10.43.98.203:80`). | Evita saturación mutua de CPU/RAM, asegura aislamiento de fallos a nivel de sistema operativo y previene colisiones de puertos y nombres de contenedor. | **RNF-07** (Disponibilidad)<br>**PROY-08** (Contenerización) |
| **2** | **Motor de Base de Datos** | **Aislado** | • **DEV:** Docker PostgreSQL 16 Alpine en máquina local.<br>• **QA:** Proyecto Supabase Cloud (QA Instance).<br>• **PROD:** Proyecto Supabase Cloud (PROD Instance). | Evita contención de recursos, previene caídas accidentales de producción por pruebas de carga o spikes en DEV/QA, y garantiza que incidentes en desarrollo no afecten la disponibilidad. | **RNF-07** (Disponibilidad)<br>**REST-02** (Control de costos cloud)<br>**ADR-0023** |
| **3** | **Esquema DDL (Tablas y Tipos)** | **Compartido** (Homogéneo) | Exactamente el mismo script DDL (17 tablas, `pgcrypto`, llaves foráneas, índices) se aplica en los 3 ambientes de manera versionada (`database/init/` y migraciones numeradas). | Principio de *Paridad de Ambientes* (Twelve-Factor App). Garantiza que una funcionalidad probada en DEV o QA no falle en PROD por discrepancias estructurales de esquema. | **RNF-09** (Integridad referencial)<br>**ADR-0004** (Build Once, Deploy Anywhere)<br>**Gobierno §2.8** |
| **4** | **Datos y Registros (Persistencia)** | **Aislado** | • **DEV:** Datos semilla mock (`02-seed.sql`).<br>• **QA:** Datos sintéticos de prueba y fixtures de QA.<br>• **PROD:** Datos reales de empresas (tenants), clientes y aliados. | Prohibición legal y de seguridad de exponer información real de clientes/aliados en entornos no productivos. Protege la confidencialidad de la información. | **RNF-01** (Aislamiento de datos)<br>**ADR-0012** (Multi-tenant)<br>**ADR-0015** (Estrategia pruebas) |
| **5** | **Autenticación e Identidad (Auth)** | **Aislado** | • **DEV:** Mock/Bypass local o JWT estático para desarrollo ágil.<br>• **QA:** Supabase GoTrue (Auth) de la instancia de QA con usuarios dummy.<br>• **PROD:** Supabase GoTrue productivo con verificación real de correo, hashing bcrypt y emisión de JWT firmados. | Previene la contaminación de directorios de usuarios. Las credenciales creadas para tests nunca deben coexistir con usuarios reales en producción. | **RNF-01** (Seguridad e identidad)<br>**ADR-0018** (Identificación de tenant no falsificable)<br>**ADR-0022** |
| **6** | **Almacenamiento de Archivos (KYC)** | **Aislado** | • **DEV:** Almacenamiento local o mock en filesystem.<br>• **QA:** Bucket `kyc-documents-staging` en Supabase QA Storage.<br>• **PROD:** Bucket `kyc-documents-prod` en Supabase PROD Storage con políticas de acceso cifrado. | Cumplimiento estricto de la política de aislamiento de documentos de identidad y soporte de aliados. Los documentos sensibles de personas reales solo existen en PROD. | **ADR-0013** (Almacenamiento KYC)<br>**RF-05 / RF-06** (Aislamiento KYC)<br>**RNF-01** |
| **7** | **Registro de Contenedores (GHCR)** | **Compartido** (con Tags Segregados) | Se utiliza el mismo registro `ghcr.io/trama-as/mani-flutter` pero con etiquetas mutuamente excluyentes:<br>• DEV: `develop`, `dev`, `dev-<sha>`<br>• QA: `staging`, `testing`, `release`<br>• PROD: `latest`, `vX.Y.Z` | Centraliza el repositorio de artefactos bajo la misma gobernanza institucional en GitHub, pero aísla estrictamente las versiones promovibles mediante inmutabilidad de tags. | **ADR-0004** (Pipeline CI/CD)<br>**PROY-08** (Contenerización)<br>**Gobierno §2.1** |
| **8** | **Autenticación en GHCR** | **Compartido** (Mecanismo) / **Aislado** (Token) | Ambas VMs autentican contra `ghcr.io` mediante GitHub Personal Access Tokens (PAT) con alcance mínimo `read:packages`. | Protege las imágenes contra accesos anónimos sin exponer credenciales de escritura en los servidores de despliegue. | **ADR-0005** (DevSecOps)<br>**Gobierno §2.4** |
| **9** | **Variables de Entorno y Secretos** | **Aislado** | • **DEV:** Archivo `.env` local (ignorado en Git).<br>• **QA:** GitHub Secrets de rama `release` e inyección en VM QA.<br>• **PROD:** GitHub Environment Secrets con protección de ambiente `production`. | *Zero Trust*: Las credenciales de base de datos y llaves de servicio de producción nunca son visibles ni accesibles para ramas o servidores de pruebas. | **ADR-0005** (Gestión de Secretos)<br>**Gobierno §2.4** |
| **10** | **Políticas de Row-Level Security (RLS)** | **Compartido** (Reglas) / **Aislado** (Ejecución) | La definición de las políticas de RLS es idéntica en código (DDL), pero su ejecución se evalúa contra los datos aislados de cada base de datos (QA y PROD). | Asegura que el comportamiento de seguridad multi-tenant sea auditado y validado en QA con el mismo rigor que operará en producción. | **ADR-0012** (Aislamiento Multi-Tenant)<br>**ADR-0018** (Propagación de Tenant)<br>**RNF-01** |
| **11** | **Red y Direccionamiento IP** | **Aislado** | • **DEV:** `http://localhost:8080`, `localhost:5432`.<br>• **QA:** `http://10.43.100.141/` (Intranet Universitaria).<br>• **PROD:** `http://10.43.98.203/` (Intranet Universitaria). | Segmentación de red dentro del espacio universitario. Permite evaluar de forma independiente ambos ambientes sin interferencias de cache o nombres de host. | **RNF-07** (Confiabilidad y disponibilidad) |
| **12** | **Frecuencia de Despliegue Automatizado** | **Diferenciado** | • **DEV:** Bajo demanda de cada desarrollador.<br>• **QA:** Sincronización automática **cada 30 minutos** (`*/30 * * * *`).<br>• **PROD:** Sincronización automática **cada 1 hora** (`0 * * * *`). | Equilibra la agilidad en la entrega continua para QA sin saturar el canal de red ni causar interrupciones innecesarias en el servidor productivo. | **RNF-07** (Disponibilidad)<br>**ADR-0004** |
| **13** | **Pipeline y Quality Gates (CI/CD)** | **Aislado** (Diferenciado por Rama) | • **DEV:** Linter (`analyze`), formato (`format`), tests unitarios/widget con cobertura, build check.<br>• **QA:** Mismo CI + empaquetado de artefacto staging + push a GHCR con tag `staging`.<br>• **PROD:** Mismo CI + **SonarCloud SAST & Quality Gate vinculante** + push a GHCR `latest` + Release oficial. | Adaptado a las restricciones de licenciamiento de herramientas (plan gratuito de SonarCloud para ramas no principales) sin comprometer el estándar de producción. | **ADR-0004** (Promoción de Ambientes)<br>**ADR-0005** (SAST en CI/CD)<br>**REST-02** |

---

## 4. Infraestructura de Cómputo en Servidores Virtuales (Linux VMs)

Para los ambientes de **QA** y **Producción**, la plataforma opera sobre dos máquinas virtuales Linux (Ubuntu Server) dedicadas, ubicadas dentro del segmento de red institucional de la universidad.

```
       +-------------------------------------------------------------+
       |                  Red Universitaria (Intranet)               |
       |                                                             |
       |   +-----------------------+     +-----------------------+   |
       |   |      VM 1 - PROD      |     |       VM 2 - QA       |   |
       |   |     10.43.98.203      |     |     10.43.100.141     |   |
       |   |       Puerto 80       |     |       Puerto 80       |   |
       |   |  mani-flutter-prod    |     |    mani-flutter-qa    |   |
       |   |  Cron: Cada 1 hora    |     |  Cron: Cada 30 mins   |   |
       |   +-----------^-----------+     +-----------^-----------+   |
       +---------------|-----------------------------|---------------+
                       |  docker pull                |  docker pull
                       |  (read:packages PAT)        |  (read:packages PAT)
       +---------------v-----------------------------v---------------+
       |             GitHub Container Registry (ghcr.io)             |
       |               ghcr.io/trama-as/mani-flutter                 |
       |                Tags: latest / staging                       |
       +-------------------------------------------------------------+
```

### 4.1 Especificaciones de los Servidores Virtuales

| Parámetro | VM 1 — Producción (PROD) | VM 2 — Calidad (QA / Testing) |
| :--- | :--- | :--- |
| **Dirección IP** | `10.43.98.203` | `10.43.100.141` |
| **Puerto Expuesto** | `80:80` (HTTP Estándar) | `80:80` (HTTP Estándar) |
| **Nombre Contenedor** | `mani-flutter-prod` | `mani-flutter-qa` |
| **Imagen GHCR** | `ghcr.io/trama-as/mani-flutter:latest` | `ghcr.io/trama-as/mani-flutter:staging` |
| **Directorio de Operación** | `/opt/mani` | `/opt/mani` |
| **Script de Despliegue** | `/opt/mani/deploy-prod.sh` | `/opt/mani/deploy-qa.sh` |
| **Frecuencia Cron** | Cada 1 hora (`0 * * * *`) | Cada 30 minutos (`*/30 * * * *`) |
| **Log de Despliegue** | `/var/log/mani-deploy.log` | `/var/log/mani-deploy.log` |
| **Persistencia Asociada** | Supabase Cloud (PROD) | Supabase Cloud (QA) |

---

### 4.2 Proceso de Aprovisionamiento Base (Paso a Paso en las VMs)

Ambas máquinas virtuales se aprovisionan de manera homogénea y determinista utilizando comandos atómicos de una sola línea, eliminando bloques interactivos que puedan causar bloqueos en terminales SSH remotas:

#### 1. Instalación del Motor Docker Oficial
```bash
sudo apt-get update -y
sudo apt-get install -y curl
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm -f get-docker.sh
```

#### 2. Habilitación del Servicio y Permisos de Usuario
```bash
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```
*(Nota: Requiere cerrar sesión y volver a entrar vía SSH o ejecutar `newgrp docker` para aplicar los permisos).*

#### 3. Estructura de Directorios del Proyecto
```bash
sudo mkdir -p /opt/mani
sudo chown -R $USER:$USER /opt/mani
```

#### 4. Autenticación contra GitHub Container Registry (GHCR)
Debido a que las imágenes se publican bajo la organización `trama-as`, la descarga requiere autenticación mediante un Personal Access Token (PAT) de GitHub con el permiso `read:packages`:
```bash
echo "<GITHUB_PERSONAL_ACCESS_TOKEN>" | docker login ghcr.io -u <TU_USUARIO_GITHUB> --password-stdin
```
> [!NOTE]
> El usuario debe ser el nombre de usuario de la cuenta de GitHub (ej. `santi-avila` o nombre de usuario en minúsculas), no el correo electrónico completo.

---

### 4.3 Scripts de Despliegue Automatizado

Cada máquina cuenta con su script de actualización atómica en `/opt/mani/`.

#### A. Script de Despliegue para Producción (`/opt/mani/deploy-prod.sh`)
```bash
#!/usr/bin/env bash
set -euo pipefail

# 1. Descarga la versión más reciente aprobada en main
docker pull ghcr.io/trama-as/mani-flutter:latest

# 2. Detiene y elimina el contenedor anterior de forma segura
docker stop mani-flutter-prod 2>/dev/null || true
docker rm mani-flutter-prod 2>/dev/null || true

# 3. Lanza el nuevo contenedor con reinicio automático
docker run -d --name mani-flutter-prod --restart unless-stopped -p 80:80 ghcr.io/trama-as/mani-flutter:latest

# 4. Limpia capas de imágenes huérfanas para optimizar disco
docker image prune -f
```

#### B. Script de Despliegue para QA (`/opt/mani/deploy-qa.sh`)
```bash
#!/usr/bin/env bash
set -euo pipefail

# 1. Descarga la versión más reciente promovida a release
docker pull ghcr.io/trama-as/mani-flutter:staging

# 2. Detiene y elimina el contenedor anterior de forma segura
docker stop mani-flutter-qa 2>/dev/null || true
docker rm mani-flutter-qa 2>/dev/null || true

# 3. Lanza el nuevo contenedor con reinicio automático
docker run -d --name mani-flutter-qa --restart unless-stopped -p 80:80 ghcr.io/trama-as/mani-flutter:staging

# 4. Limpia capas de imágenes huérfanas para optimizar disco
docker image prune -f
```

Ambos scripts se configuran con permisos de ejecución:
```bash
chmod +x /opt/mani/deploy-prod.sh   # En VM 1
chmod +x /opt/mani/deploy-qa.sh     # En VM 2
```

---

### 4.4 Configuración del Despliegue Periódico (Cron Jobs)

Para garantizar que los ambientes reflejen continuamente las nuevas versiones liberadas sin requerir intervención manual vía SSH en cada release:

* **En VM 1 (PROD — Cada 1 hora):**
  ```bash
  (crontab -l 2>/dev/null | grep -v "deploy-prod.sh"; echo "0 * * * * /opt/mani/deploy-prod.sh >> /var/log/mani-deploy.log 2>&1") | crontab -
  ```

* **En VM 2 (QA — Cada 30 minutos):**
  ```bash
  (crontab -l 2>/dev/null | grep -v "deploy-qa.sh"; echo "*/30 * * * * /opt/mani/deploy-qa.sh >> /var/log/mani-deploy.log 2>&1") | crontab -
  ```

Los logs de cada ejecución se registran con trazabilidad horaria en `/var/log/mani-deploy.log`.

---

## 5. Observabilidad y Monitoreo de Healthchecks (Red Universitaria)

Cualquier máquina conectada a la red universitaria (sea una estación de trabajo de desarrollo, una terminal de auditoría o un servidor de monitoreo) puede validar en tiempo real la disponibilidad y latencia de los ambientes mediante scripts de sondeo continuo cada 15 segundos.

### 5.1 Script de Monitoreo Continuo para PRODUCCIÓN (`10.43.98.203`)

Guarda este script en cualquier máquina Linux/macOS o ejecútalo en consola:

```bash
#!/usr/bin/env bash
TARGET_IP="10.43.98.203"
INTERVAL=15

echo "======================================================="
echo "   MONITOREO DE HEALTHCHECK - MANI PRODUCCION (VM 1)"
echo "   Destino: http://${TARGET_IP}/ | Intervalo: ${INTERVAL}s"
echo "======================================================="

while true; do
  TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
  
  # Consulta código HTTP y tiempo de respuesta total
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code} %{time_total}" --connect-timeout 5 "http://${TARGET_IP}/" 2>/dev/null || echo "000 0.000")
  HTTP_CODE=$(echo "$RESPONSE" | awk '{print $1}')
  TIME_TOTAL=$(echo "$RESPONSE" | awk '{print $2}')
  
  if [ "$HTTP_CODE" = "200" ]; then
    echo -e "[$TIMESTAMP] [PROD] [10.43.98.203] \033[0;32m[STATUS: $HTTP_CODE OK]\033[0m Latencia: ${TIME_TOTAL}s"
  else
    echo -e "[$TIMESTAMP] [PROD] [10.43.98.203] \033[0;31m[STATUS: $HTTP_CODE ALERTA]\033[0m Latencia: ${TIME_TOTAL}s"
  fi
  
  sleep $INTERVAL
done
```

### 5.2 Script de Monitoreo Continuo para QA / TESTING (`10.43.100.141`)

```bash
#!/usr/bin/env bash
TARGET_IP="10.43.100.141"
INTERVAL=15

echo "======================================================="
echo "   MONITOREO DE HEALTHCHECK - MANI QA / TESTING (VM 2)"
echo "   Destino: http://${TARGET_IP}/ | Intervalo: ${INTERVAL}s"
echo "======================================================="

while true; do
  TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
  
  # Consulta código HTTP y tiempo de respuesta total
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code} %{time_total}" --connect-timeout 5 "http://${TARGET_IP}/" 2>/dev/null || echo "000 0.000")
  HTTP_CODE=$(echo "$RESPONSE" | awk '{print $1}')
  TIME_TOTAL=$(echo "$RESPONSE" | awk '{print $2}')
  
  if [ "$HTTP_CODE" = "200" ]; then
    echo -e "[$TIMESTAMP] [QA]   [10.43.100.141] \033[0;32m[STATUS: $HTTP_CODE OK]\033[0m Latencia: ${TIME_TOTAL}s"
  else
    echo -e "[$TIMESTAMP] [QA]   [10.43.100.141] \033[0;31m[STATUS: $HTTP_CODE ALERTA]\033[0m Latencia: ${TIME_TOTAL}s"
  fi
  
  sleep $INTERVAL
done
```

---

## 6. Diagramas Oficiales del Flujo Gitflow y Mapeo a Ambientes

De acuerdo con el estándar definido en la **Wiki del repositorio `MANI-Flutter`** ([`Gitflow-Workflow.md`](file:///C:/Users/santi/OneDrive/Documentos/MANI-Flutter-Wiki/Gitflow-Workflow.md)), el proyecto adopta formalmente el modelo estricto de Gitflow (Vincent Driessen / Atlassian). A continuación se presentan los diagramas oficiales de la Wiki y su correspondencia con la topología de ambientes:

### 6.1 Estructura de Ramas Principales (`main` y `develop`)

Las dos ramas históricas gobiernan el estado base de los ambientes de **Desarrollo (DEV)** y **Producción (PROD)**:

![Estructura general de ramas historicas main y develop](https://dam-cdn.atl.orangelogic.com/AssetLink/3we6dfk04vp4y2f0f2188t6j13n4424h.svg)

* **`develop` ➔ Ambiente DEV:** Rama de integración continua donde convergen las características. Gobierna las pruebas en el entorno local de desarrollo respaldado por **Docker** (`postgres:16-alpine` + Adminer).
* **`main` ➔ Ambiente PROD:** Rama de código productivo oficial. Cada commit en `main` representa una versión liberada respaldada por **Supabase Cloud (PROD)** y desplegada en **VM 1 (`10.43.98.203`)** con tag semántico (`vX.Y.Z`).

---

### 6.2 Ramas de Característica (`feature/*`)

Cada nueva funcionalidad nace y muere en `develop`, aislada del resto del equipo hasta su integración:

![Diagrama de ramas Feature](https://dam-cdn.atl.orangelogic.com/AssetLink/7yu4h3oai315s158nq6t313p25e82o32.svg)

* **Mapeo a Ambiente:** Se ejecutan y validan exclusivamente en el **Ambiente DEV** del desarrollador usando su base de datos local contenerizada.
* **Integración:** Ingresan a `develop` únicamente mediante Pull Request con validación de CI en verde (`dart format`, `flutter analyze`, `flutter test`).

---

### 6.3 Ramas de Estabilización y Testing (`release/*`)

Cuando `develop` acumula suficientes características para un lanzamiento planificado, se corta la rama `release`:

![Diagrama de ramas Release](https://dam-cdn.atl.orangelogic.com/AssetLink/le16ot34d0e862mba18e7j7i502585eb.svg)

* **Mapeo a Ambiente:** Alimenta directamente el **Ambiente QA (Testing / Staging)** en **VM 2 (`10.43.100.141`)**.
* **Persistencia:** Se conecta a la instancia dedicada de **Supabase Cloud (QA)**.
* **Artefactos:** Dispara la compilación y publicación de la imagen en GHCR con tags `staging`, `testing`, `release` y empaqueta el artefacto `flutter-web-staging.zip` para auditoría de QA.
* **Cierre:** Al ser aprobada por QA y PO, se mezcla hacia `main` (con tag de versión `vX.Y.Z`) y de regreso a `develop`.

---

### 6.4 Ramas de Mantenimiento Urgente (`hotfix/*`)

Permiten solucionar defectos críticos detectados en producción sin arrastrar trabajo en curso de `develop`:

![Diagrama de ramas Hotfix](https://dam-cdn.atl.orangelogic.com/AssetLink/t8b1bnptx6bn40wc43g83j02u5b61064.svg)

* **Flujo:** Nace de `main`, se valida en el entorno de **QA**, se promueve directamente a `main` (emitiendo tag de corrección `vX.Y.Z+1`) y se sincroniza inmediatamente de regreso hacia `develop`.

---

## 7. Políticas Operativas de Gestión y Promoción

### 7.1 Principio *Schema-First* y Versionamiento de Migraciones
1. **Evolución Controlada:** Ninguna modificación al esquema DDL de la base de datos se realiza manualmente en Supabase Cloud.
2. **Versionamiento:** Todo cambio en tablas, columnas, restricciones, RPCs o extensiones debe plasmarse en un script SQL versionado y secuencial en la carpeta `database/migrations/` (ej. `001_initial_schema.sql`, `002_rls_policies.sql`, `003_audit_triggers.sql`, `004_aliado_categorias.sql`).
3. **Flujo de Despliegue de Esquema:**
   $$\text{Script SQL en Git} \longrightarrow \text{Verificación en Docker DEV} \longrightarrow \text{Ejecución en Supabase QA} \longrightarrow \text{Ejecución en Supabase PROD}$$

### 7.2 Criterios de Paso entre Ambientes (Gates de Calidad)

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

### 7.3 Gestión de Secretos y Control de Acceso por Roles
* **Desarrolladores:** Acceso total a su contenedor Docker local (`postgres:postgres`). Sin acceso a credenciales de la base de datos de producción.
* **QA (Santiago):** Acceso al dashboard de Supabase QA para inspección de datos de prueba, depuración de RLS y reseteo de fixtures.
* **DevOps Titular (Daniel Ávila):** Custodia de las credenciales maestras (`service_role_key`, strings de conexión) de los proyectos Supabase QA y PROD en los repositorios de GitHub Secrets correspondientes, así como administración de acceso a las VMs.

---

## 8. Matriz de Trazabilidad Cruzada de Requisitos

La siguiente tabla sintetiza la correspondencia directa entre los requisitos y decisiones del proyecto y las directrices topológicas de este documento:

| Código de Requisito / Decisión | Descripción del Requisito | Directriz Topológica Adoptada en DOC-08 |
| :--- | :--- | :--- |
| **RNF-01** | Aislamiento lógico estricto multi-tenant de datos y archivos. | Segregación total de bases de datos y buckets de storage entre QA y PROD; ejecución de políticas RLS en Supabase; datos reales confinados a PROD. |
| **RNF-07** | Disponibilidad y confiabilidad operacional en producción. | Host PROD (`10.43.98.203`) y base de datos PROD totalmente aislados e inmunes a pruebas de carga o errores de desarrollo generados en DEV o QA. |
| **RNF-09** | Integridad referencial y consistencia de datos. | Esquema DDL compartido e idéntico (17 tablas con llaves foráneas y tipos comunes) en los tres ambientes. |
| **REST-02** | Restricción financiera y control de costos de infraestructura cloud. | Uso de Docker local para DEV (evitando consumir límites de proyectos cloud) y optimización de tiers en Supabase; uso de servidores virtuales universitarios para alojamiento web. |
| **PROY-07** | Arquitectura multi-servicio distribuida y heterogénea. | Soporte de conexión simultánea para clientes Flutter y backends contenerizados hacia la capa de persistencia. |
| **PROY-08** | Requisito de contenerización y portabilidad. | Empaquetado Docker con tags diferenciados en GHCR (`develop`, `staging`, `latest`) y despliegue en contenedores autónomos con reinicio automático (`--restart unless-stopped`). |
| **ADR-0004** | Promoción formal de ambientes (`develop` ➔ `release` ➔ `main`). | Homologación unívoca de ramas Gitflow con los ambientes DEV, QA (`10.43.100.141`) y PROD (`10.43.98.203`). |
| **ADR-0005** | DevSecOps, SAST, DAST y Quality Gates. | Análisis estático SonarCloud obligatorio en PROD; pruebas dinámicas y funcionales ejecutadas sobre QA; pipelines adaptados a las cuotas de escaneo. |
| **ADR-0012** | Persistencia sobre Supabase/PostgreSQL con RLS. | Selección de Supabase Cloud como motor gestionado para QA y PROD, y PostgreSQL 16 local para DEV. |
| **ADR-0013** | Almacenamiento seguro de documentos KYC. | Buckets de Supabase Storage segregados e independientes entre Staging y Producción. |
| **ADR-0015** | Estrategia de pruebas de aislamiento multi-tenant. | Entorno QA habilitado con datos sintéticos para verificación exhaustiva de RLS sin riesgo de fuga de datos. |
| **ADR-0018** | Identificación criptográfica de tenant vía JWT. | Emisión de tokens independientes por proyecto de Supabase (GoTrue QA vs GoTrue PROD). |
| **ADR-0023** | Consolidación de stack y eliminación de Azure. | Persistencia centrada en Supabase y contenedores Docker desplegados en Linux VMs sin dependencia de infraestructura Azure. |
| **Gobierno §2.2** | Definición de los tres ambientes y resolución de inconsistencias. | Cierre formal de la nomenclatura DEV / QA / PROD y definición de sus fronteras operativas. |
| **Gobierno §2.4** | Gestión de secretos y seguridad. | Aislamiento estricto de credenciales por ramas mediante GitHub Secrets y autenticación GHCR vía PAT. |
| **Gobierno §2.5** | Paso obligatorio por ambientes DEV y QA antes de PROD. | Prohibición técnica de despliegues directos a producción sin pasar por la validación previa en DEV y QA. |

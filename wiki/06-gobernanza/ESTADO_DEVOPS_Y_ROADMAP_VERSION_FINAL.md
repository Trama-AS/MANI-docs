# TRAMA · MANI — Informe de Estado DevOps y Roadmap hacia Versión Final

| Metadato | Detalle |
|---|---|
| **Proyecto** | MANI — Plataforma SaaS Multi-Tenant de Servicios del Hogar y Mantenimiento |
| **Rol / Responsable** | Daniel Ávila — DevOps Lead |
| **Destinatario** | Sara Albarracín — Scrum Master / Equipo de Ingeniería |
| **Fecha de Corte** | Noviembre, 2026 |
| **Estado del Incremento Sprint 5 / MVP** | **100% COMPLETADO Y OPERATIVO EN PRODUCCIÓN** |
| **Release Tag Oficial** | `v1.0.4` (Desplegado en DEV, QA y PROD) |

---

## 1. Resumen Ejecutivo (Postura Oficial de DevOps)

> [!IMPORTANT]
> **Para el alcance contractual y académico del Sprint 5 (Cierre de MVP), NO EXISTE NINGÚN PENDIENTE ni deuda operativa por parte del rol de DevOps.** 
> 
> Toda la infraestructura, base de datos, seguridad RLS, mensajería de eventos, pipelines de CI, imágenes OCI y los 3 ambientes de despliegue (**DEV**, **QA** y **PROD**) se encuentran **100% desplegados, configurados, probados y estables con código HTTP 200 OK**.

Cualquier elemento adicional discutido en este documento corresponde a **optimizaciones de nivel empresarial (*Day-2 Operations*)** recomendadas para una **versión final comercial post-MVP**, las cuales exceden los criterios de aceptación del sprint actual y forman parte del roadmap de escalabilidad futura.

---

## 2. Matriz de Cumplimiento: Alcance Actual vs. Optimizaciones Futuras

| Área | Estado en Sprint 5 / MVP (Actual - 100% Listo) | Optimización para Versión Final (Post-MVP) | Prioridad Futura |
|---|---|---|:---:|
| **Despliegue PROD** | VM `10.43.98.203` operativa con 6 microservicios Docker (`:latest`, tag `v1.0.4`), healthcheck 200 OK. | Orquestación en clúster Kubernetes / Docker Swarm con balanceo de carga. | Media |
| **Red y Puertos** | Tráfico canalizado por Gateway NGINX en puerto `80` (interno) y Flutter Web en puerto `8080` con reverse proxy `/api/` (SCRUM-1361). | Nombre de dominio público DNS con terminación SSL/TLS (HTTPS puerto 443) vía Cloudflare / Let's Encrypt. | **Alta** |
| **Base de Datos** | Supabase PROD y QA sincronizados con las **39 migraciones** de `MANI-Node/db/migrations` (ADR-0030). | Replicación de lectura (Read-Replicas) y particionamiento de tablas transaccionales por año/tenant. | Baja |
| **Seguridad RLS** | Roles de servicio `mani_core_svc` y `mani_dispatch_svc` con `LOGIN` y sin `BYPASSRLS` (SCRUM-1468 / TEC-21). | Rotación automática de credenciales de servicio con HashiCorp Vault / AWS Secrets Manager. | Media |
| **Mensajería Kafka** | Apache Kafka 3.8.0 KRaft desplegado en DEV y QA con topics canónicos, particiones y retención (ARQ-05). | Clúster multi-broker tolerante a fallos con mTLS/SASL y despliegue en ambiente PROD. | Media |
| **CI/CD** | Integración continua en GitHub Actions con Sonar Quality Gate, Docker Publish a GHCR y tags semánticos. | Despliegue Continuo (CD) 100% desatendido mediante runners auto-alojados o webhooks GitOps (Watchtower/ArgoCD). | Media |
| **Observabilidad** | Endpoints `/health` y `/metrics` en microservicios, scripts de diagnóstico `check-prod.sh` / `check-qa.sh`. | Stack unificado APM (Prometheus + Grafana + Loki / ELK) con alertas automáticas a Slack/Teams. | Media |
| **Backups** | Procedimientos documentados y scripts de volcado `pg_dump` para PostgreSQL Supabase. | Snapshots automáticos diarios programados con subida cifrada a bucket S3 y pruebas de restauración (RTO/RPO). | **Alta** |

---

## 3. Estado Detallado de lo Implementado y Certificado en DEV, QA y PROD

### 3.1 Infraestructura de Servidores y Ambientes
Los tres entornos cuentan con sus pilas completas en ejecución continua bajo Docker Compose:

1. **Ambiente de Desarrollo (DEV - `10.43.98.232`):**
   - Rama: `develop`. Imágenes: `:develop`.
   - Servicios: NGINX Gateway (`:80`), Core Node.js, Dispatch .NET, Rules Java, Flutter Web (`:8080`), Landing Web (`:3001`), Kafka KRaft (`:9092`).
2. **Ambiente de Calidad (QA - `10.43.100.141`):**
   - Rama: `release`. Imágenes: `:staging`.
   - Servicios: NGINX Gateway (`:80`, `:443`), Core Node.js, Dispatch .NET, Rules Java, Flutter Web (`:8080`), Landing Web (`:3001`), Kafka KRaft (`:9092`).
   - Servidor de Calidad independiente (`10.43.98.196`): SonarQube Community Edition, runners de Newman y Playwright headless.
3. **Ambiente de Producción (PROD - `10.43.98.203`):**
   - Rama: `main`. Imágenes: `:latest`. Tag de versión: `v1.0.4`.
   - Servicios: NGINX Gateway (`:80`), Core Node.js, Dispatch .NET, Rules Java, Flutter Web (`:8080`), Landing Web (`:3001`).
   - Todos los endpoints verificados respondiendo `HTTP 200 OK` vía `/opt/mani/check-prod.sh`.

### 3.2 Base de Datos y Seguridad RLS (Single Source of Truth)
- Siguiendo **ADR-0030**, el repositorio canónico de migraciones es `MANI-Node/db/migrations/`.
- Se aplicaron secuencialmente las **39 migraciones** sobre la base de producción (`tjxueukivwxsgipltqwb`), incorporando los esquemas de:
  - Fondos en garantía y retención (`0029`)
  - Tarifario de referencia y extensión `btree_gist` (`0030`)
  - Reglas de configuración por tenant (`0031`)
  - Sistema de quejas y mediación (`0032`)
  - Auditoría de estados de tenant (`0033`)
  - Jerarquía territorial por barrio/localidad (`0034`)
  - Transactional Outbox de eventos (`0035`)
  - Límites territoriales GeoJSON (`0036`)
  - Retiro de políticas públicas y hardening RLS (`0037`, `0038`, `0039`)
- **Hardening de Seguridad RLS (SCRUM-1468 / TEC-21):**
  - Los microservicios Core y Dispatch conectan a PostgreSQL mediante usuarios dedicados `mani_core_svc` y `mani_dispatch_svc`.
  - Ambos roles tienen `rolcanlogin = true`, `rolsuper = false` y `rolbypassrls = false`, obligando a que cada consulta evalúe estrictamente las políticas de aislamiento por `tenant_id` fijadas en `app.set_context()`.
  - Secretos protegidos en `/opt/mani/secrets/` con permisos `chmod 600`.

### 3.3 Solución Perimetral Flutter Web (SCRUM-1361)
- Ante el bloqueo del puerto 80/443 por parte del firewall de red externa de la universidad hacia las VMs:
  - Se configuró la variable de runtime `API_GATEWAY_URL=http://10.43.98.203:8080` en `docker-compose.prod.yml` y `.env.prod`.
  - El contenedor NGINX de Flutter Web enruta el prefijo `/api/` directamente hacia `http://mani-api-gateway:80` dentro de la red privada Docker `mani-network`.
  - Se probó el registro de nuevos usuarios (`HTTP 201 Created`) y el inicio de sesión (`HTTP 200 OK`) con emisión de tokens seguros ES256.
  - Se sembraron los usuarios de prueba estándar en Producción bajo el tenant `acme-servicios` (`cliente.t1@qa.mani.test`, `aliado.t1@qa.mani.test`, `admin.t1@qa.mani.test` con clave `QaSeed2026!`).

---

## 4. Roadmap de Optimizaciones para una Versión Final Comercial (Post-MVP)

Si el proyecto avanzara a una fase de comercialización o paso a producción real abierta a Internet, se recomiendan las siguientes **6 iniciativas de optimización técnica**:

### 4.1 Dominio DNS y Certificados SSL/TLS Gestionados (HTTPS)
* **Situación actual:** Acceso por IP privada universitaria (`10.43.98.203:8080`) debido al bloqueo perimetral de los puertos 80 y 443 en la red institucional.
* **Propuesta de optimización:**
  1. Adquirir y delegar un nombre de dominio corporativo (ej. `app.mani.com.co` o `serviciosmani.co`).
  2. Implementar un Reverse Proxy perimetral o túnel seguro (Cloudflare Tunnel o NGINX con Certbot Let's Encrypt) que publique el tráfico directamente sobre el puerto estándar **HTTPS 443** con certificado TLS 1.3 válido.
  3. Redirección forzosa de HTTP a HTTPS y configuración de encabezados HSTS, CSP y X-Frame-Options en el Gateway.
* **Beneficio:** Elimina el uso de puertos no estándar como `:8080`, garantiza cifrado de extremo a extremo sin alertas de certificado en navegadores móviles y permite el acceso sin VPN institucional.

### 4.2 Automatización del Despliegue Continuo (CD Desatendido / GitOps)
* **Situación actual:** El pipeline de CI en GitHub Actions construye, pasa pruebas, audita calidad en SonarQube y sube las imágenes a GHCR (`:latest`, `:staging`, `:develop`). El despliegue en las VMs se efectúa mediante scripts de shell (`deploy-prod.sh`) ejecutados por SSH.
* **Propuesta de optimización:**
  1. Instalar un **GitHub Actions Self-Hosted Runner** en cada VM o configurar un agente GitOps ligero (como Watchtower o Webhook seguro con firma HMAC).
  2. Al completar con éxito el workflow de build en `main` o `release`, el runner o webhook actualiza automáticamente los contenedores sin necesidad de sesiones interactivas SSH.
  3. Incorporar validación automática de *Smoke Tests* posdespliegue con rollback automático si los endpoints no responden HTTP 200 en los primeros 60 segundos.
* **Beneficio:** Trazabilidad 100% desatendida, cero intervención manual de credenciales SSH y reducción del tiempo de despliegue a menos de 90 segundos.

### 4.3 Centralización de Observabilidad y Monitoreo Proactivo (APM)
* **Situación actual:** Los microservicios exponen `/health` y `/metrics`. El monitoreo se realiza mediante comandos de Docker y scripts bajo demanda (`check-prod.sh`).
* **Propuesta de optimización:**
  1. Levantar un stack centralizado de métricas y logs en el servidor de soporte o nube: **Prometheus + Grafana + Promtail/Loki**.
  2. Correlación de trazas distribuidas aprovechando el encabezado `X-Correlation-ID` que ya inyecta el API Gateway hacia Node, Java y .NET.
  3. Configurar alertas proactivas (Alertmanager) hacia un canal de Discord/Slack o correo cuando el uso de CPU/RAM supere el 85% o se detecte un incremento anormal de respuestas 5xx.
* **Beneficio:** Visibilidad en tiempo real de la salud del sistema, detección temprana de cuellos de botella y diagnósticos inmediatos ante incidencias.

### 4.4 Clúster Kafka Redundante y Extensión a Producción
* **Situación actual:** Kafka 3.8.0 KRaft opera de forma aislada en contenedores individuales en DEV y QA con 5 tópicos canónicos, sin broker en Producción (la arquitectura actual desacopla Producción mediante almacenamiento de eventos en `outbox_evento` en PostgreSQL).
* **Propuesta de optimización:**
  1. Desplegar un clúster Kafka redundante de 3 nodos (Quorum KRaft) para alta disponibilidad sin punto único de falla.
  2. Implementar autenticación segura entre microservicios mediante SASL/SCRAM o mTLS con ACLs estrictas por topic (productor `Core`, consumidor `Dispatch`).
  3. Habilitar Kafka en Producción conectando el relay de outbox de Core Node para propagación de eventos en tiempo real.
* **Beneficio:** Tolerancia a caídas de nodos de mensajería, rendimiento superior a 10.000 eventos/segundo y trazabilidad asíncrona robusta.

### 4.5 Gestión Criptográfica de Secretos y Política de Respaldo RTO/RPO
* **Situación actual:** Los secretos y cadenas de conexión residen en archivos `.env` y `/opt/mani/secrets/` con permisos de sistema `600`. Los respaldos de base de datos se generan mediante volcados lógicos manuales.
* **Propuesta de optimización:**
  1. Integrar un almacén centralizado de secretos (HashiCorp Vault o Doppler) donde las claves de API, JWT secrets y credenciales de PostgreSQL se inyecten dinámicamente en memoria durante el arranque del contenedor.
  2. Configurar un cron job automatizado en la VM de producción que ejecute un volcado `pg_dump` diario de Supabase, lo comprima y lo suba cifrado con GPG hacia un almacenamiento de objetos externo (AWS S3 Glacier o Cloudflare R2).
  3. Definir y certificar simulacros de recuperación ante desastres con métricas formales: **RPO** (Recovery Point Objective) < 24 horas y **RTO** (Recovery Time Objective) < 2 horas.
* **Beneficio:** Eliminación total de secretos en disco plano y garantía de recuperación de datos ante fallos catastróficos del proveedor cloud.

### 4.6 Despliegue Zero-Downtime (Blue/Green o Rolling Updates)
* **Situación actual:** `deploy-prod.sh` detiene los contenedores viejos y levanta los nuevos con una ventana de corte típica de entre 15 y 30 segundos.
* **Propuesta de optimización:**
  1. Configurar despliegues de tipo **Blue/Green** en NGINX: levantar la nueva versión de los contenedores en puertos internos alternos, validar su healthcheck, y conmutar el `proxy_pass` en caliente mediante `nginx -s reload` sin interrumpir las conexiones activas.
  2. Como alternativa a mediano plazo, migrar la orquestación a Kubernetes o Docker Swarm con políticas de *Rolling Update* (`maxSurge: 1`, `maxUnavailable: 0`).
* **Beneficio:** Actualizaciones transparentes para los usuarios finales sin cortes de servicio.

---

## 5. Conclusión y Recomendación para la Scrum Master

1. **Estado del Sprint 5:** El objetivo de infraestructura, despliegue y calidad para el cierre de MVP está **100% cumplido** y listo para demostración, sustentación o auditoría. No hay bloqueos ni tareas pendientes en el tablero para DevOps.
2. **Priorización de Roadmap:** Si en una siguiente iteración o fase comercial se desea priorizar optimizaciones, el orden técnico recomendado es:
   - **P1:** Dominio público con certificado HTTPS en puerto 443 (resuelve dependencias de firewall de red).
   - **P2:** Respaldos automáticos programados hacia almacenamiento externo S3.
   - **P3:** CD desatendido vía GitHub Actions Runners y Observabilidad centralizada Grafana.

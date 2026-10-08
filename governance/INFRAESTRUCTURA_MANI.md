# TRAMA · MANI — Infraestructura

**Proyecto:** MANI — Plataforma Multi-Tenant de Formalización de Operaciones de Servicio  
**Documento:** Infraestructura y Topología de Ambientes  
**Responsable principal:** DevOps  
**Estado:** Línea base consolidada con decisiones abiertas explícitas  

---

# 1. Propósito

Este documento describe **dónde y cómo se ejecutan los componentes de MANI**, qué se comparte, qué se aísla entre ambientes y qué decisiones de infraestructura permanecen abiertas.

No redefine:

- arquitectura funcional → SAD;
- diseño interno → SDD;
- políticas CI/CD → Políticas DevOps;
- DDL → Modelo de Datos;
- decisiones históricas → ADR.

---

# 2. Principios de infraestructura

1. Tres ambientes oficiales: **DEV → TEST/QA → PROD**.
2. Datos y secretos aislados por ambiente.
3. Artefactos OCI versionados e inmutables.
4. Registro centralizado en GHCR.
5. Configuración externa a las imágenes.
6. Misma definición de esquema y RLS entre ambientes.
7. Supabase como plataforma administrada de datos.
8. PostgreSQL como motor de base de datos.
9. Kubernetes obligatorio como arquitectura objetivo.
10. Proveedor del clúster todavía pendiente.
11. Docker Compose permitido como mecanismo operativo actual/transitorio en máquinas virtuales.
12. Ningún dato real de PROD se copia a DEV o TEST/QA.

---

# 3. Vista general

```text
Usuarios
   │
   ▼
Flutter Web / Mobile
   │
   ▼
NGINX API Gateway
   │
   ├── Rules Service ........ Java
   ├── Dispatch Service ..... .NET
   ├── Core Services ........ Node.js
   └── Availability Service . Node.js
             │
             ▼
        Supabase
        ├── PostgreSQL
        ├── Auth
        ├── Storage
        └── Realtime
```

Servicios externos:

- FCM / APNs;
- operador de pagos en segundo incremento;
- Prometheus;
- Grafana;
- Datadog;
- Data Warehouse.

---

# 4. Ambientes oficiales

```text
DEV → TEST/QA → PROD
```

`TEST/QA` es un único ambiente. `Staging` no constituye un cuarto ambiente oficial.

---

# 5. Ambiente DEV

## 5.1 Objetivo

DEV se utiliza para:

- desarrollo;
- integración temprana;
- pruebas locales;
- validación de esquema;
- pruebas funcionales antes de TEST/QA.

## 5.2 Supabase DEV compartido

Existe un ambiente de **Supabase para DEV**, administrado por el equipo, equivalente conceptualmente a los proyectos utilizados para TEST/QA y PROD.

Debe conservar:

- PostgreSQL;
- esquema versionado;
- Auth;
- Storage;
- Realtime;
- RLS;
- datos exclusivamente de desarrollo.

La administración actual del ambiente DEV corresponde a Nicolás León.

## 5.3 Desarrollo local con Docker

El ambiente DEV compartido **no excluye** ejecución local.

Cada desarrollador puede trabajar con Docker local utilizando el mismo esquema versionado.

La variante local puede incluir:

- PostgreSQL;
- servicios necesarios para desarrollo;
- datos seed;
- herramientas de inspección;
- mocks o servicios locales cuando corresponda.

Cuando una funcionalidad dependa específicamente de Auth, Storage, Realtime o RLS de Supabase, debe probarse también contra un entorno que reproduzca esas capacidades antes de considerarse validada.

El Docker Compose local y el esquema versionado viven en `MANI-APIGateway` (perfil `db` para PostgreSQL y Adminer; perfil `web` para el cliente Flutter Web, cuya imagen `mani-web:local` se construye en `MANI-Flutter`). Ver §15.

## 5.4 Datos

Solo:

- seeds;
- fixtures;
- usuarios ficticios;
- datos sintéticos.

Nunca información real de PROD.

---

# 6. Ambiente TEST/QA

## 6.1 Objetivo

TEST/QA sirve para:

- integración multi-servicio;
- pruebas funcionales;
- pruebas de regresión;
- aislamiento multi-tenant;
- pruebas de carga;
- DAST;
- aceptación QA.

## 6.2 Supabase TEST/QA

Proyecto dedicado e independiente.

Debe disponer de:

- PostgreSQL;
- Auth;
- Storage;
- Realtime;
- RLS;
- esquema equivalente a PROD;
- datos sintéticos y reseteables.

## 6.3 Aplicaciones y servicios

Las imágenes se descargan desde GHCR hacia las máquinas virtuales o nodos definidos para el ambiente.

Mientras no se despliegue la topología definitiva de Kubernetes, los servicios pueden levantarse mediante Docker Compose.

---

# 7. Ambiente PROD

## 7.1 Objetivo

PROD es el ambiente productivo oficial.

Contiene:

- usuarios reales;
- datos reales;
- documentos reales;
- secretos productivos;
- releases versionados.

## 7.2 Supabase PROD

Proyecto dedicado y aislado.

Debe contener:

- PostgreSQL;
- Auth;
- Storage;
- Realtime;
- políticas RLS productivas;
- backups;
- controles de acceso;
- cifrado en tránsito y en reposo según capacidades del proveedor.

## 7.3 Servicios

PROD utiliza únicamente imágenes promovidas y validadas previamente.

No se construye código directamente en PROD.

---

# 8. Registro de contenedores

El registro oficial es:

```text
GitHub Container Registry — GHCR
```

Convención:

```text
ghcr.io/trama-as/<servicio>:<tag>
```

Repositorios desplegables previstos:

```text
MANI-Flutter
MANI-Gateway
MANI-Rules-Java
MANI-Dispatch-DotNet
MANI-Core-Node
MANI-Availability
```

La infraestructura obtiene las imágenes desde GHCR.

---

# 9. Docker Compose en máquinas virtuales

La operación actual/transitoria permite:

```text
GHCR
  ↓
pull de imágenes
  ↓
VM del ambiente
  ↓
docker compose up
```

Compose se utiliza para levantar los contenedores requeridos por cada máquina virtual.

La definición debe:

- fijar imágenes por tag o digest;
- inyectar configuración por ambiente;
- no contener secretos;
- declarar redes;
- declarar volúmenes cuando aplique;
- incluir health checks cuando sea posible;
- permitir rollback a una imagen anterior.

---

# 10. Kubernetes

Kubernetes es **obligatorio por requisito del proyecto** y constituye la plataforma objetivo de orquestación.

## 10.1 Decisión cerrada

- Kubernetes se adopta.
- Azure/AKS no se adopta como proveedor obligatorio.
- Las imágenes siguen siendo OCI y se obtienen desde GHCR.

## 10.2 Decisión abierta

Todavía no se ha definido:

- proveedor de cómputo;
- número de nodos;
- tamaño de nodos;
- topología física;
- distribución por ambiente;
- ingress definitivo;
- estrategia de almacenamiento persistente del clúster.

Estas decisiones requieren ADR antes de declararse definitivas.

## 10.3 Relación con Docker Compose

Docker Compose es un mecanismo operativo de despliegue en VMs y **no equivale a Kubernetes**.

Por ello se documentan dos estados:

### Estado operativo actual/transitorio
GHCR + VMs + Docker Compose.

### Estado objetivo obligatorio
GHCR + Kubernetes.

La migración no debe requerir reconstruir las imágenes de aplicación.

---

# 11. API Gateway

NGINX funciona como API Gateway.

Responsabilidades:

- TLS termination o integración con la capa que lo gestione;
- routing;
- CORS;
- rate limiting cuando se configure;
- validación inicial de JWT;
- propagación de `correlation_id`;
- controles transversales.

---

# 12. Servicios desplegables

| Servicio | Runtime | Responsabilidad |
|---|---|---|
| MANI-Flutter | Flutter | cliente |
| MANI-Gateway | NGINX | API Gateway |
| MANI-Rules-Java | Java | reglas por tenant |
| MANI-Dispatch-DotNet | .NET | despacho y concurrencia |
| MANI-Core-Node | Node.js | dominio core |
| MANI-Availability | Node.js | disponibilidad/cobertura |

No se utiliza Serverpod como backend principal.

---

# 13. Supabase

Supabase se modela como plataforma administrada.

## 13.1 PostgreSQL

Motor relacional operacional.

Contiene:

- tablas;
- llaves;
- restricciones;
- índices;
- RLS.

El DDL oficial vive en el documento/modelo de datos y scripts versionados.

## 13.2 Auth

Responsable de:

- autenticación;
- gestión de credenciales;
- sesiones;
- emisión de JWT.

Cada ambiente utiliza identidades aisladas.

## 13.3 Storage

Documentos KYC en almacenamiento privado.

Convención lógica:

```text
tenant_id/aliado_id/documento
```

## 13.4 Realtime

Utilizado para eventos y mensajería casi en tiempo real.

Realtime no contiene reglas de negocio.

---

# 14. Multi-tenancy

La seguridad se aplica en capas:

```text
JWT firmado
   ↓
NGINX Gateway
   ↓
Servicio
   ↓
RLS PostgreSQL
```

Reglas:

- `tenant_id` autenticado proviene del token;
- no se confía en headers arbitrarios como fuente de autorización;
- cada servicio valida acceso;
- RLS refuerza aislamiento;
- Storage aplica controles equivalentes.

---

# 15. Esquema y migraciones

Principio **schema-first**:

1. el cambio se crea como migración/script versionado;
2. se valida en DEV/local;
3. se valida en TEST/QA;
4. se aplica en PROD.

Queda prohibido modificar manualmente el esquema productivo como procedimiento ordinario.

Los tres ambientes deben conservar compatibilidad estructural.

## 15.1 Dónde viven las migraciones

Las migraciones versionadas (`database/migrations/NNN_descripcion.sql`, idempotentes e inmutables una vez fusionadas), los scripts de `database/init/` y las verificaciones de `database/verify/` viven en el repositorio **`MANI-APIGateway`** (ADR-0004, enmienda del 2026-10-07). Ya no están en `MANI-Flutter`.

Todo cambio de esquema se propone por PR a `MANI-APIGateway`, con su referencia Jira.

## 15.2 Responsable por ambiente

| Ambiente | Responsable | Cómo |
|---|---|---|
| DEV local | Cada desarrollador | `scripts/migrate-local.*` contra el contenedor `mani-postgres` (perfil `db` del Compose) |
| DEV / TEST-QA (Supabase) | DevOps | Aplica `database/migrations/` en orden, después de fusionar el PR. Automatizarlo en el pipeline de `MANI-APIGateway` queda en CFG-29 |
| PROD | DevOps, con aprobación del PR de release | Solo migraciones ya validadas en TEST/QA. Nunca cambios manuales al esquema |

---

# 16. Qué se comparte y qué se aísla

| Componente | Política |
|---|---|
| Código fuente | Compartido por repositorio/versionado |
| Imagen OCI | Compartida/promovida |
| DDL/migraciones | Compartidas |
| Definición de RLS | Compartida |
| Datos | Aislados |
| Usuarios/Auth | Aislados |
| Storage | Aislado |
| Secretos | Aislados |
| Dominios/URLs | Aislados |
| Logs | Aislados por ambiente |
| Configuración | Aislada |
| Supabase | Proyecto/entorno segregado |
| Registro GHCR | Compartido, tags/digests segregados |

---

# 17. Secretos

## DEV
Variables de desarrollo, nunca productivas.

## TEST/QA
Secretos propios del ambiente.

## PROD
Secretos exclusivos, acceso restringido.

Prohibiciones:

- credenciales en repositorio;
- secrets dentro de imágenes;
- reutilizar claves productivas en ambientes inferiores.

## Secretos de CI

Los secretos que usan los pipelines se guardan como GitHub Actions secrets del repositorio o del environment, nunca en archivos versionados.

| Repositorio | Secreto | Uso | Estado al 7 oct 2026 |
|---|---|---|---|
| MANI-Node | `SONAR_TOKEN` | análisis de SonarCloud del workflow `Quality Gate` (CFG-41) | **pendiente de crear** por DevOps |

---

# 18. Red y TLS

Cada ambiente debe mantener su propia configuración de red y endpoint.

Ejemplos conceptuales:

```text
DEV      → local / dominio dev
TEST/QA  → dominio QA
PROD     → dominio productivo
```

Los nombres concretos se definen cuando exista infraestructura asignada.

Requisitos:

- HTTPS para tráfico externo;
- secretos fuera del código;
- CORS por ambiente;
- reglas de red con mínimo privilegio.

---

# 19. Persistencia y archivos por ambiente

| Capacidad | DEV | TEST/QA | PROD |
|---|---|---|---|
| PostgreSQL | Supabase DEV y/o local | Supabase dedicado | Supabase dedicado |
| Auth | DEV | QA | PROD |
| Storage | datos ficticios | datos sintéticos | documentos reales |
| Realtime | desarrollo | pruebas | productivo |
| Datos | ficticios | sintéticos | reales |
| RLS | misma definición | misma definición | misma definición |

---

# 20. Observabilidad

Los componentes deben integrarse con:

- Prometheus;
- Grafana;
- Datadog.

Telemetría mínima:

- latencia;
- requests;
- errores;
- CPU;
- memoria;
- estado de servicios;
- logs estructurados;
- trazas;
- correlation ID.

Los ambientes deben poder distinguirse en etiquetas y dashboards.

---

# 21. Backups y recuperación

Para PROD se requiere:

- backups periódicos de la persistencia;
- verificación de restauración;
- retención acorde al proveedor y necesidades del proyecto;
- registro de incidentes;
- procedimiento de rollback de aplicación.

Los valores exactos de RPO/RTO deben mantenerse sincronizados con SAD/SDD cuando hayan sido ratificados.

No se fija aquí una cifra no aprobada.

---

# 22. Escalabilidad

## Estado Compose

El escalado se realiza de acuerdo con capacidad de las VMs y servicios levantados.

## Estado Kubernetes

Cuando se implemente el clúster objetivo podrá habilitar:

- réplicas;
- health checks;
- self-healing;
- rolling updates;
- balanceo;
- autoscaling cuando exista métrica y capacidad justificadas.

El número de réplicas no se fija hasta tener datos de carga.

---

# 23. Data Warehouse

El DW se mantiene separado del OLTP.

Flujo conceptual:

```text
Supabase / PostgreSQL OLTP
        ↓
      CDC / ELT
        ↓
      Staging
        ↓
 Transformación / Calidad
        ↓
   Data Warehouse
        ↓
      BI / Métricas
```

El DW no escribe hacia el OLTP.

---

# 24. Promoción entre ambientes

La infraestructura recibe artefactos según la política DevOps:

```text
DEV → TEST/QA → PROD
```

Infraestructura no redefine los Quality Gates.

La fuente de verdad para gates es `POLITICAS_DEVOPS_HERRAMIENTAS.md`.

## 24.1 Estado del análisis SonarCloud por repositorio

Esta tabla registra solo el estado de la configuración, no los umbrales: los umbrales viven en `POLITICAS_DEVOPS_HERRAMIENTAS.md` §14.1 y ADR-0005.

Un gate se considera **vinculante** solo cuando su check es obligatorio en un ruleset activo de GitHub y existe evidencia de un PR bloqueado. Mientras eso no ocurra, el estado es *preparado* o *activo sin bloqueo* (Políticas §6.2).

| Repositorio | Proyecto SonarCloud | Configuración versionada | Check obligatorio en ruleset | Estado al 7 oct 2026 |
|---|---|---|---|---|
| MANI-Node | `Trama-AS_MANI-Node` (organización `trama-as`), **por crear** | `sonar-project.properties` y script `test:coverage` (etapa 1, en revisión en [MANI-Node#16](https://github.com/Trama-AS/MANI-Node/pull/16), sin fusionar); workflow `quality-gate.yml` preparado sin PR (etapa 2) | no; `develop` y `main` sin ruleset ni protección | **preparado, no activo** (CFG-41, SCRUM-1116) |

Para MANI-Node, la activación requiere, en orden: crear el proyecto con el análisis automático desactivado, asociar el Quality Gate y fijar el *new code baseline*, crear `SONAR_TOKEN`, fusionar el workflow, obtener un primer análisis en `develop` y agregar `Sonar Quality Gate` como check obligatorio en el ruleset de `develop` y `main`.

---

# 25. Decisiones abiertas

A la fecha quedan explícitamente abiertas:

## INFRA-01 — Hosting de Kubernetes
Pendiente elegir proveedor y dimensionamiento.

## INFRA-02 — Topología final del clúster
Pendiente definir nodos, namespaces o clusters por ambiente y networking.

No están abiertas:

- GHCR como registro: **definido**.
- Supabase DEV compartido: **definido**.
- Docker local como alternativa de desarrollo: **permitido**.
- Docker Compose sobre VMs: **mecanismo operativo actual/transitorio**.
- Kubernetes: **obligatorio como objetivo**.

---

# 26. Trazabilidad

Este documento debe mantenerse alineado con:

- ADR-0004 — CI/CD y ambientes;
- ADR-0005 — DevSecOps;
- ADR-0006 — observabilidad;
- ADR-0012 — Supabase/PostgreSQL + RLS;
- ADR-0013 — documentos KYC;
- ADR-0015 — pruebas multi-tenant;
- ADR-0018 — identidad de tenant;
- ADR-0019 — SOA + Gateway + arquitectura políglota;
- SRS — RNF y restricciones;
- SAD;
- SDD;
- Modelo de Datos.

Cuando exista una nueva decisión de hosting/clúster, este documento se actualiza después del ADR correspondiente.

# TRAMA · MANI — Políticas DevOps, Calidad y Herramientas

**Proyecto:** MANI  
**Responsable técnico principal:** Daniel Ávila — DevOps titular  
**Apoyo:** Nicolás León — DevOps secundario  
**Ámbito:** desarrollo, repositorios, CI/CD, pruebas, seguridad, observabilidad y herramientas  
**Estado:** Línea base consolidada conforme a los ADR vigentes  

---

# 1. Propósito

Este documento establece **cómo se desarrolla, integra, prueba, asegura y entrega MANI**.

No redefine:

- requerimientos → SRS;
- arquitectura → SAD;
- diseño → SDD;
- infraestructura física/lógica → `INFRAESTRUCTURA_MANI.md`;
- decisiones estructurales → ADR;
- tecnologías vigentes de forma histórica → `TECH_RADAR.md`.

---

# 2. Principios

1. **Multi-repo:** cada unidad desplegable mantiene ciclo técnico independiente.
2. **Build once, deploy many:** el artefacto promovido no se recompila por ambiente.
3. **Automatización primero:** build, test y gates deben ejecutarse en CI.
4. **Seguridad desde CI:** SAST, DAST y pruebas de aislamiento forman parte del ciclo.
5. **Sin secretos en repositorio.**
6. **Ambientes segregados:** DEV → TEST/QA → PROD.
7. **Misma definición de esquema y políticas de seguridad entre ambientes.**
8. **Observabilidad integrada.**
9. **Decisiones estructurales mediante ADR.**
10. **No se implementan diferencias por tenant mediante forks del producto.**

---

# 3. Referencia tecnológica

La fuente viva de tecnologías adoptadas, en evaluación o descartadas es `TECH_RADAR.md`.

Stack vigente relevante para DevOps:

- Flutter / Dart
- NGINX
- Java
- .NET
- Node.js
- Supabase
- PostgreSQL
- Docker / OCI
- Kubernetes
- GitHub Actions
- GHCR
- Postman / Newman
- k6
- SonarQube
- OWASP ZAP
- Prometheus
- Grafana
- Datadog
- Jira

No forman parte de la línea base actual:

- Azure / ACR como proveedor obligatorio;
- Serverpod como backend principal;
- Feature Toggles como requisito arquitectónico obligatorio;
- Repo A / Repo B / Repo C como modelo de organización.

---

# 4. Estrategia multi-repositorio

Repositorios objetivo:

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

Cada repositorio desplegable debe mantener:

- código;
- dependencias;
- pruebas;
- `Dockerfile`;
- pipeline;
- configuración de build;
- versionamiento;
- artefactos;
- documentación técnica inmediata.

---

# 5. Control de versiones y ramas

## 5.1 Ramas principales

### `main`
Representa la versión productiva.

- protegida contra push directo;
- solo recibe cambios aprobados;
- releases etiquetados semánticamente.

### `develop`
Rama de integración para el siguiente incremento.

## 5.2 Ramas temporales

### Feature

```text
feature/US-XX-descripcion
```

Nace de `develop` y retorna por Pull Request.

### Fix

```text
fix/BUG-XX-descripcion
```

### Release

```text
release/*
```

Se utiliza para estabilización y promoción hacia TEST/QA.

### Hotfix

```text
hotfix/*
```

Nace de `main`; tras corrección debe sincronizarse nuevamente con la línea de desarrollo.

### Spike

```text
spike/*
```

Se utiliza para experimentación técnica. Un spike no se convierte automáticamente en decisión arquitectónica.

---

# 6. Pull Requests

Todo cambio hacia ramas compartidas debe entrar mediante PR.

Un PR debe incluir:

- referencia Jira;
- propósito;
- cambios principales;
- pruebas ejecutadas;
- impacto técnico;
- evidencia relevante;
- actualización documental si aplica.

## 6.1 Revisión

- mínimo un revisor técnico distinto del autor cuando la configuración de GitHub lo permita;
- cambios de arquitectura requieren trazabilidad hacia ADR;
- cambios en datos requieren revisar migraciones, RLS y compatibilidad.

## 6.2 Protección

Los rulesets deben evolucionar para cubrir como mínimo las ramas de integración, release y producción.

Ningún documento debe asumir que una regla está forzada por GitHub si el ruleset todavía no existe. La política puede ser obligatoria aunque su enforcement automático esté pendiente.

---

# 7. Ambientes y promoción

Secuencia oficial:

```text
DEV → TEST/QA → PROD
```

`TEST/QA` es un único ambiente. El término `staging` puede aparecer como etiqueta técnica histórica, pero no representa un cuarto entorno oficial.

## 7.1 DEV

Objetivos:

- desarrollo;
- integración temprana;
- pruebas locales;
- validación previa al release.

## 7.2 TEST/QA

Objetivos:

- pruebas funcionales;
- integración multi-servicio;
- pruebas de contrato;
- pruebas de aislamiento;
- carga;
- DAST;
- aceptación QA.

## 7.3 PROD

Objetivos:

- operación con usuarios reales;
- releases versionados;
- datos reales;
- secretos exclusivos;
- controles de acceso productivos.

---

# 8. Pipeline CI/CD

Flujo lógico:

```text
Push / Pull Request
        ↓
Lint / Format
        ↓
Pruebas unitarias
        ↓
Pruebas de integración
        ↓
SonarQube / Quality Gate
        ↓
Build Docker/OCI
        ↓
Escaneo de dependencias e imagen
        ↓
Publicación en GHCR
        ↓
Promoción a TEST/QA
        ↓
Newman / contratos / aislamiento
        ↓
k6 cuando corresponda
        ↓
OWASP ZAP
        ↓
Aprobación
        ↓
Promoción a PROD
```

GitHub Actions es el motor oficial de CI/CD.

---

# 9. Build Once, Deploy Many

La imagen se construye una sola vez.

La misma imagen validada debe promoverse entre ambientes mediante:

- digest;
- tag inmutable;
- release versionado.

Queda prohibido reconstruir código específicamente para PROD como mecanismo ordinario de promoción.

Las diferencias de ambiente se inyectan en tiempo de ejecución.

---

# 10. Registro de imágenes

El registro oficial es **GitHub Container Registry (GHCR)**.

Convención base:

```text
ghcr.io/trama-as/<repositorio>:<tag>
```

Las máquinas virtuales o nodos del ambiente obtienen las imágenes desde GHCR.

Los tags deben permitir distinguir:

- desarrollo;
- release/QA;
- producción;
- versión semántica;
- commit SHA cuando se requiera trazabilidad.

Ejemplos:

```text
dev-<sha>
qa-<sha>
v1.2.0
```

`latest` puede existir como conveniencia, pero no sustituye el tag inmutable usado para trazabilidad.

---

# 11. Contenedores y Compose

Docker/OCI es el estándar de empaquetado.

En la operación actual o de transición, las imágenes pueden descargarse desde GHCR en las máquinas virtuales de cada ambiente y levantarse mediante Docker Compose.

La configuración de Compose debe:

- declarar servicios;
- utilizar variables externas;
- evitar secretos embebidos;
- fijar imágenes por tag/digest;
- separar redes cuando aplique;
- declarar health checks cuando aplique.

> Docker Compose no sustituye el requisito de Kubernetes. La infraestructura vigente puede usar Compose mientras se define el proveedor y despliegue concreto del clúster requerido por el proyecto.

---

# 12. Kubernetes

Kubernetes es un requisito obligatorio del proyecto.

Está definido como **arquitectura objetivo de orquestación**, pero el proveedor de cómputo y la distribución concreta del clúster continúan pendientes de decisión.

No se asume AKS ni Azure.

Hasta que exista decisión:

- no se inventan nodos;
- no se fija proveedor;
- no se documenta capacidad como definitiva;
- Compose puede continuar como mecanismo operativo de despliegue en VMs.

La transición a Kubernetes debe conservar los mismos artefactos OCI publicados en GHCR.

---

# 13. Testing

## 13.1 Unitarias

Cada repositorio ejecuta pruebas unitarias correspondientes a su runtime.

## 13.2 Integración

Se validan interacciones entre:

- Gateway;
- servicios;
- persistencia;
- integraciones externas simuladas o controladas.

## 13.3 API y contratos

Postman / Newman se utilizan para:

- pruebas funcionales;
- contratos;
- regresión;
- aislamiento multi-tenant.

## 13.4 Aislamiento multi-tenant

Los cambios relacionados con:

- autenticación;
- tenant;
- RLS;
- endpoints de datos;
- Storage;

deben cubrir casos cross-tenant.

Como mínimo:

1. lectura de otro tenant;
2. listado de recursos ajenos;
3. escritura en otro tenant;
4. borrado ajeno;
5. token expirado o alterado;
6. documentos KYC de otro tenant/aliado.

El resultado esperado es rechazo o ausencia de datos no autorizados.

## 13.5 Rendimiento

k6 se utiliza cuando el escenario lo requiera para:

- concurrencia;
- aceptación simultánea;
- endpoints críticos;
- mensajería;
- consultas de disponibilidad.

Los umbrales funcionales deben provenir del SRS/SAD/SDD, no inventarse en este documento.

---

# 14. DevSecOps

## 14.1 SAST — SonarQube

SonarQube analiza:

- vulnerabilidades;
- bugs;
- code smells;
- duplicación;
- cobertura.

Ningún cambio con vulnerabilidades `Blocker` o `Critical` puede promoverse.

Los umbrales adicionales se mantienen sincronizados con SDD y ADR-0005.

## 14.2 DAST — OWASP ZAP

OWASP ZAP se ejecuta sobre TEST/QA.

Debe cubrir, según exposición:

- autenticación;
- headers;
- inyección;
- XSS;
- configuración HTTP;
- endpoints publicados.

Las APIs deben exponer contratos OpenAPI actualizados cuando ello facilite el escaneo automatizado.

## 14.3 Dependencias e imágenes

Antes de promoción se ejecuta análisis automatizado de:

- dependencias;
- vulnerabilidades conocidas;
- imagen OCI.

La herramienta concreta puede cambiar sin modificar esta política, salvo que su elección constituya una decisión arquitectónica.

---

# 15. Gestión de secretos

Prohibido:

- commit de `.env`;
- contraseñas en repositorio;
- tokens en código;
- claves productivas en imágenes.

## 15.1 DEV

- variables locales fuera de Git;
- credenciales exclusivamente de desarrollo.

## 15.2 TEST/QA

- secretos propios del ambiente;
- sin acceso a credenciales productivas.

## 15.3 PROD

- secretos exclusivos;
- acceso restringido;
- aprobación de despliegue;
- rotación según necesidad.

Cuando se migre a Kubernetes, se utilizarán Secrets/ConfigMaps o un gestor equivalente aprobado.

---

# 16. Identidad de tenant

Para peticiones autenticadas:

- el `tenant_id` del JWT firmado es la fuente canónica;
- el Gateway valida inicialmente;
- cada servicio valida autorización;
- PostgreSQL RLS refuerza aislamiento.

`X-Tenant-Slug` puede utilizarse antes de autenticación para resolución contextual, pero no autoriza acceso a datos.

---

# 17. Observabilidad

## 17.1 Métricas

**Prometheus** recopila:

- disponibilidad;
- latencia;
- throughput;
- errores;
- CPU;
- memoria;
- métricas de runtime.

## 17.2 Dashboards

**Grafana** visualiza métricas operativas.

## 17.3 APM, logs y trazas

**Datadog** se utiliza para:

- APM;
- logs centralizados;
- trazas;
- alertas.

Los servicios deben emitir logs estructurados y propagar `correlation_id`.

## 17.4 Incidentes

Las alertas críticas pueden generar o alimentar Issues/Incidentes en Jira.

---

# 18. Política de uso de IA

Se permite IA para:

- apoyo de código;
- pruebas;
- documentación;
- diagramas;
- exploración técnica.

Reglas:

1. todo resultado debe ser revisado por una persona;
2. no se introducen credenciales;
3. no se introducen datos reales sensibles;
4. no se introduce información confidencial en herramientas externas no autorizadas;
5. una respuesta de IA no constituye una decisión arquitectónica;
6. una decisión relevante debe pasar por el proceso de gobierno correspondiente.

---

# 19. Herramientas por etapa

| Etapa | Herramienta principal |
|---|---|
| Plan | Jira |
| Code | GitHub |
| Build | GitHub Actions + Docker |
| Registry | GHCR |
| Test API | Postman / Newman |
| Performance | k6 |
| SAST | SonarQube |
| DAST | OWASP ZAP |
| Orquestación objetivo | Kubernetes |
| Despliegue operativo actual/transición | Docker Compose sobre VMs |
| Métricas | Prometheus |
| Dashboards | Grafana |
| APM / logs | Datadog |
| Diseño | Figma |
| Documentación técnica | Markdown / Mermaid / Structurizr DSL |

---

# 20. Excepciones

Toda excepción a estas políticas debe indicar:

- política afectada;
- razón;
- alcance;
- responsable;
- riesgo;
- fecha;
- duración;
- plan de reversión cuando corresponda.

Una excepción temporal no modifica automáticamente la línea base arquitectónica.

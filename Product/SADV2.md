# SAD V2 — Sección de Infraestructura (DOC-15 / SCRUM-946)


> La infraestructura de MANI se organiza en tres ambientes — DEV, QA y PROD — según la topología ratificada en DOC-08 (Aprobada, 2026-09-21), que reemplaza la vista de despliegue previa de DD-MANI §9 en todo lo relativo a segregación de ambientes. DEV opera con Docker local autocontenido; QA y PROD son proyectos independientes de Supabase Cloud con cómputo en Railway (QA) y en una plataforma de hosting oficial aún no nombrada por DOC-08 (PROD). El esquema DDL y las políticas RLS son homogéneos entre ambientes; datos, identidad, almacenamiento KYC, secretos y red están estrictamente aislados. **Queda abierta y sin resolver la ubicación de Kubernetes (PROY-08, obligatorio) dentro de esta topología** — DOC-08 no lo menciona pese a ser posterior a la resolución que lo confirma como requisito innegociable. El SAD (KI-03) ya da por resuelto el "sí" de Kubernetes y remite el "cómo" (proveedor de cómputo, nodos) al spike SP-TO-11 (DOC-14), aún no ejecutado; esta sección de infraestructura debe actualizarse en cuanto ese spike produzca resultado, y hasta entonces se remite a la Mesa de Arquitectura antes de considerar cerrada esta sección.
## 1. Topología de ambientes (DEV / QA / PROD)

| Ambiente | Rama Gitflow | Cómputo backend | Persistencia | Registro de imágenes | Observabilidad/Gate |
|---|---|---|---|---|---|
| **DEV** | `develop` | Docker local del desarrollador (Docker Compose) | PostgreSQL 16 Alpine local + Adminer | GHCR `ghcr.io/trama-as/mani-flutter`, tags `dev`, `dev-<sha>` | Linter, formato, tests con cobertura (sin SonarCloud) |
| **QA (Testing/Staging)** | `release` | Railway, contenedores GHCR tag `staging`/`testing`/`release` | Proyecto dedicado Supabase Cloud (QA) | Mismo GHCR, tags de staging | CI + DAST (OWASP ZAP) + Newman/Postman (aislamiento multi-tenant, ADR-0015) |
| **PROD** | `main` | Plataforma de hosting oficial (DOC-08 no nombra el proveedor — ver §4.1), contenedores GHCR tag `latest`/`vX.Y.Z` | Proyecto dedicado Supabase Cloud (PROD), aislado de QA | Mismo GHCR, tags inmutables | CI + **SonarCloud SAST/Quality Gate vinculante** (ADR-0005) + Release oficial |

Promoción: `develop → release → main`, sin saltos — ningún despliegue a PROD sin pasar por DEV y QA con CI en verde (Gobierno del Equipo §2.5).

## 2. Qué se comparte vs. qué se aísla (resumen — matriz completa en DOC-08 §3)

- **Compartido y homogéneo:** esquema DDL (17 tablas, mismo script versionado en los 3 ambientes — paridad de ambientes); definición de políticas RLS (idénticas en código, ejecución aislada por ambiente); registro de contenedores GHCR (mismo repo, tags mutuamente excluyentes).
- **Aislado:** motor de base de datos (Docker local en DEV vs. proyectos Supabase Cloud distintos en QA/PROD), datos y registros, autenticación/identidad (mock/bypass en DEV, Supabase GoTrue con usuarios dummy en QA, GoTrue productivo en PROD), almacenamiento KYC (buckets `kyc-documents-staging` vs. `kyc-documents-prod`), variables de entorno/secretos (`.env` local → GitHub Secrets `release` → GitHub Environment Secrets `production` con aprobación), red y dominios (`localhost` → dominio de staging → dominio productivo, con aislamiento DNS/TLS).

## 3. Backend distribuido sobre esta topología

La topología de DOC-08 es agnóstica del reparto de módulos backend (Serverpod/Dart, Java/Repo B, .NET/Repo C — ADR-0012, ADR-0004, PROY-07): los tres coexisten (ADR-0021/despacho no aplica aquí; ver ADR-0023 para consolidación de stack) y cada uno se empaqueta y promueve bajo el mismo esquema de tags GHCR por ambiente descrito en §1. DOC-08 no detalla el mecanismo de contenerización específico de Serverpod (Dart) — mismo vacío documental que ya señalaba el diagrama de despliegue anterior; se mantiene como pendiente en §4.2, no se asume.


> La infraestructura de MANI se organiza en tres ambientes — DEV, QA y PROD — según la topología ratificada en DOC-08 (Aprobada, 2026-09-21), que reemplaza la vista de despliegue previa de DD-MANI §9 en todo lo relativo a segregación de ambientes. DEV opera con Docker local autocontenido; QA y PROD son proyectos independientes de Supabase Cloud con cómputo en Railway (QA) y en una plataforma de hosting oficial aún no nombrada por DOC-08 (PROD). El esquema DDL y las políticas RLS son homogéneos entre ambientes; datos, identidad, almacenamiento KYC, secretos y red están estrictamente aislados. **Queda abierta y sin resolver la ubicación de Kubernetes (PROY-08, obligatorio) dentro de esta topología** — DOC-08 no lo menciona pese a ser posterior a la resolución que lo confirma como requisito innegociable. El SAD (KI-03) ya da por resuelto el "sí" de Kubernetes y remite el "cómo" (proveedor de cómputo, nodos) al spike SP-TO-11 (DOC-14), aún no ejecutado; esta sección de infraestructura debe actualizarse en cuanto ese spike produzca resultado, y hasta entonces se remite a la Mesa de Arquitectura antes de considerar cerrada esta sección.

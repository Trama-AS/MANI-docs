# 02 · Accesos y Gestión de Secretos

[← Volver a `08-infraestructura`](README.md)

> **Fuente:** [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md) §10 y §22, [`DOCUMENTO_INFRAESTRUCTURA_V4.md`](../06-gobernanza/DOCUMENTO_INFRAESTRUCTURA_V4.md), [SCRUM-1639](https://maniservices.atlassian.net/browse/SCRUM-1639) y [SCRUM-1712](https://maniservices.atlassian.net/browse/SCRUM-1712).
> **Finalidad:** Establecer cómo solicitar accesos operativos a las VMs y servicios externos sin almacenar contraseñas ni tokens en `MANI-docs` ni en `MANI-APIGateway`, y documentar las variables de entorno requeridas por ambiente.
> **Mantiene:** Daniel Ávila (DevOps) · **Consume:** DevOps, Desarrollo, QA · **Frecuencia:** Ante cambio de integrantes, rotación o nuevas variables · **Versión:** 1.0 (`2026-11-14`)

---

## 1. Regla estricta sobre credenciales

- **Cero secretos en Git (`HEAD`):** Ni la wiki, ni `Entregas/`, ni `docker-compose.*.yml` deben incluir contraseñas SSH, tokens de SonarQube (`sqa_...`), llaves `anon`/`service_role` de Supabase ni `SUPABASE_JWT_SECRET`.
- **Reemplazo aplicado en `DOCUMENTO_INFRAESTRUCTURA_V3.md` y `GUIA_OPERATIVA_CALIDAD_QA_CFG4-03.md`:** Las credenciales previamente documentadas fueron redactadas en `main` (`2c7671a`, [SCRUM-1639](https://maniservices.atlassian.net/browse/SCRUM-1639), [SCRUM-1712](https://maniservices.atlassian.net/browse/SCRUM-1712)) con la referencia `<redactado — solicitar al DevOps Lead por canal privado>`.
- **Alcance de redacción en Sprint 6:** Por decisión operativa registrada en Jira (`SCRUM-1639`, `SCRUM-1712`), se retiraron los secretos de los archivos activos en `HEAD` sin reescribir el historial git (`no force-push`) y sin rotar claves activas de VMs/SonarQube para no interrumpir accesos ni pruebas de QA.

## 2. Cómo solicitar acceso operativo

| Recurso | Requisitos previos | Canal y aprobador |
|---|---|---|
| **SSH a VMs (`DEV`, `QA`, `Calidad`, `Backups`)** | Conexión activa a la VPN universitaria Javeriana | Solicitar usuario `estudiante` y credencial privada al **DevOps Lead (Daniel Ávila)** o suplente (**Nicolás León**) por canal directo cifrado |
| **SSH a `PROD` (`10.43.98.203`)** | VPN universitaria + justificación de despliegue o incidente | Aprobación del DevOps Lead y registro en Jira del cambio realizado |
| **Grafana / Prometheus (`10.43.98.196`)** | Túnel SSH hacia `10.43.98.196` (puertos ligados a `127.0.0.1`) | Credencial almacenada en `/home/estudiante/monitoreo/.env` (`chmod 600`) en Calidad; solicitar al DevOps Lead |
| **SonarQube (`Calidad`)** | Token personal / CI en GitHub Actions secrets (`SONAR_TOKEN`) | Gestionado por QA / DevOps Lead en secretos de repositorio |
| **Supabase (`DEV` / `QA` / `PROD`)** | Rol de proyecto en organización | Administrado fuera de Git; llaves inyectadas vía GitHub Environments y `.env.*` en VMs |

## 3. Variables de entorno por ambiente (sin valores)

Los Compose versionados referencian únicamente variables (`${VAR}`) cuya plantilla sin secretos vive en:
- `MANI-APIGateway/infra/qa/.env.qa.example`
- `MANI-APIGateway/monitoring/.env.example`

| Variable | Uso | Dónde vive el valor real |
|---|---|---|
| `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` | Autenticación y acceso de Core / Flutter / Dispatch | `/opt/mani/.env.qa` (QA), `/opt/mani/.env.prod` (PROD), permisos `600` |
| `SUPABASE_JWT_SECRET` | Validación perimetral HS256 / firma en pruebas Newman QA (`CFG4-04`) | `.env.qa` / `.env.prod` y GitHub Environment `qa-regresion` (`QA_JWT_SECRET`) |
| `DATABASE_URL`, `DISPATCH_DB_CONNECTION` | Conexión PostgreSQL de Core y Dispatch | `.env.qa` / `.env.prod` |
| `GF_SECURITY_ADMIN_USER`, `GF_SECURITY_ADMIN_PASSWORD` | Acceso administrador de Grafana en Calidad | `/home/estudiante/monitoreo/.env` (`chmod 600`) |

## 4. Cuentas de prueba en PROD (`SCRUM-1640`)

El cambio o desactivación de las cuentas seed (`@mani.local`) en PROD ([SCRUM-1640](https://maniservices.atlassian.net/browse/SCRUM-1640)) queda condicionado al cierre de la validación del PO sobre las 18 rutas en PROD ([SCRUM-1638](https://maniservices.atlassian.net/browse/SCRUM-1638)) para no bloquear las pruebas de aceptación en curso.

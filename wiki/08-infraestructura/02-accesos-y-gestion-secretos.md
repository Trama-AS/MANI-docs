# 02 · Accesos y Gestión de Secretos

[← Volver a `08-infraestructura`](README.md)

> **Fuente:** [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md) §10 y §22, [`DOCUMENTO_INFRAESTRUCTURA_V4.md`](../06-gobernanza/DOCUMENTO_INFRAESTRUCTURA_V4.md), [SCRUM-1639](https://maniservices.atlassian.net/browse/SCRUM-1639) y [SCRUM-1712](https://maniservices.atlassian.net/browse/SCRUM-1712).
> **Finalidad:** Establecer cómo solicitar accesos operativos a las VMs y servicios externos sin almacenar contraseñas ni tokens en `MANI-docs` ni en `MANI-APIGateway`, y documentar las variables de entorno requeridas por ambiente.
> **Mantiene:** Daniel Ávila (DevOps) · **Consume:** DevOps, Desarrollo, QA · **Frecuencia:** Ante cambio de integrantes, rotación o nuevas variables · **Versión:** 1.0 (`2026-11-14`)

---

## 1. Regla estricta sobre credenciales

- **Cero secretos en Git (`HEAD`):** Ni la wiki, ni `Entregas/`, ni `docker-compose.*.yml` deben incluir contraseñas SSH, tokens de SonarQube (`sqa_...`), llaves `anon`/`service_role` de Supabase ni `SUPABASE_JWT_SECRET`.
- **Reemplazo aplicado en `DOCUMENTO_INFRAESTRUCTURA_V3.md` y `GUIA_OPERATIVA_CALIDAD_QA_CFG4-03.md`:** Las credenciales previamente documentadas fueron redactadas en `main` (`2c7671a`, [SCRUM-1639](https://maniservices.atlassian.net/browse/SCRUM-1639), [SCRUM-1712](https://maniservices.atlassian.net/browse/SCRUM-1712)) con la referencia `<redactado — solicitar al DevOps Lead por canal privado>`.
> ### Riesgo aceptado, decidido el 2026-11-19
>
> **No se rotaron ni el token de SonarQube ni las credenciales de las máquinas virtuales.** Es una **decisión registrada del equipo con riesgo aceptado**, no un asunto resuelto, y conviene que la diferencia quede escrita.
>
> **Quién y cuándo.** Propuesto por Daniel Ávila (DevOps Lead) el 2026-11-16 y aceptado por Sara Albarracín (SM) el 2026-11-19, tras el escalamiento registrado en [`../06-gobernanza/REGISTRO_BLOQUEOS.md`](../06-gobernanza/REGISTRO_BLOQUEOS.md) §3.1.
>
> **Justificación de DevOps.** El token de SonarQube tiene como objetivo el propio proyecto, de modo que el daño aprovechable por un tercero es limitado. Las máquinas virtuales están todas tras la VPN de la universidad. Y rotar las credenciales de las VMs obligaría a los siete integrantes a cambiar la suya con la entrega encima, lo que sería un cuello de botella real.
>
> **Lo que sigue siendo cierto, y por eso esto es riesgo y no cierre.** Retirar una credencial de `HEAD` **no la invalida**: el repositorio es público y el valor sigue en el historial de git, accesible con un comando. Mientras no se rote, la credencial es válida.
>
> **Qué queda pendiente después de la entrega**, por orden de coste: rotar el token de SonarQube, que lo hace una sola persona en minutos y solo exige actualizar el secreto `SONAR_TOKEN` de GitHub Actions sin afectar a nadie más; y rotar las credenciales de las VMs, que sí requiere coordinar a los siete integrantes.

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

Los Compose y scripts versionados referencian únicamente variables (`${VAR}`) cuya plantilla sin secretos vive en:
- `MANI-APIGateway/infra/qa/.env.qa.example`
- `MANI-APIGateway/infra/backups/.env.backups.example`
- `MANI-APIGateway/monitoring/.env.example`

| Variable | Uso | Dónde vive el valor real |
|---|---|---|
| `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` | Autenticación y acceso de Core / Flutter / Dispatch | `/opt/mani/.env.qa` (QA), `/opt/mani/.env.prod` (PROD), permisos `600` |
| `SUPABASE_JWT_SECRET` | Validación perimetral HS256 / firma en pruebas Newman QA (`CFG4-04`) | `.env.qa` / `.env.prod` y GitHub Environment `qa-regresion` (`QA_JWT_SECRET`) |
| `DATABASE_URL`, `DATABASE_URL_ADMIN`, `DISPATCH_DB_CONNECTION` | Conexión PostgreSQL de servicios y respaldos | `.env.qa` / `.env.prod` y `/etc/mani-backups/.env.backups` (`chmod 600` en `10.43.98.197`) |
| `BACKUP_ENCRYPTION_KEY_FILE` (`backup.passphrase`) | Llave simétrica OpenSSL `AES-256-CBC` para cifrar/descifrar dumps (`SCRUM-1666`) | `/etc/mani-backups/backup.passphrase` (`chmod 400` en `10.43.98.197`) + custodia privada del DevOps Lead (separada de la réplica en `10.43.98.196`) |
| `GF_SECURITY_ADMIN_USER`, `GF_SECURITY_ADMIN_PASSWORD` | Acceso administrador de Grafana en Calidad | `/home/estudiante/monitoreo/.env` (`chmod 600`) |

## 4. Cuentas operativas y retiro de semilla en PROD (`SCRUM-1640`)

- Las cuentas semilla heredadas (`@qa.mani.test`) en Supabase PROD fueron **rotadas y desactivadas** (`banned_until` + `public.usuario.estado = 'INACTIVO'`), verificando rechazo `HTTP 400` con la contraseña de semilla previa (`0` ocurrencias en `MANI-docs`).
- En su lugar se crearon tres cuentas operativas equivalentes (`admin.t1@prod.mani.app`, `cliente.t1@prod.mani.app` y `aliado.t1@prod.mani.app`) con contraseñas únicas y distintas de alta entropía, custodiadas exclusivamente fuera de Git en `/opt/mani/.prod_accounts.env` (`chmod 600` en la VM PROD `10.43.98.203`).

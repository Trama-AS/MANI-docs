# CI/CD y calidad

[← 03 · Entrega](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §8, §13 y §14 · [`architecture/SAD.md`](../../architecture/SAD.md) §18 · [`architecture/SDD.md`](../../architecture/SDD.md) §11 · [`adr/ADR-0005`](../../adr/ADR-0005-devsecops.md), [`ADR-0015`](../../adr/ADR-0015-pruebas-aislamiento-multitenant.md).

GitHub Actions es el motor oficial de CI/CD.

## Pipeline

```text
Push / Pull Request
  → Lint / Format
  → Pruebas unitarias
  → Pruebas de integración
  → SonarQube / Quality Gate
  → Build Docker/OCI
  → Escaneo de dependencias e imagen
  → Publicación en GHCR
  → Promoción a QA
  → Newman: contratos y aislamiento
  → k6 cuando corresponda
  → OWASP ZAP
  → Aprobación
  → Promoción a PROD
```

## Pruebas exigidas

| Tipo | Herramienta / alcance |
|---|---|
| Unitarias | Las del runtime de cada repositorio |
| Integración | Gateway, servicios, persistencia e integraciones externas simuladas o controladas |
| API y contratos | Postman / Newman: funcionales, contratos, regresión |
| **Aislamiento multi-tenant** | Newman, obligatorio en todo cambio de autenticación, tenant, RLS, endpoints de datos o Storage — los seis casos de [Multi-tenancy y seguridad](../02-arquitectura/multitenancy-y-seguridad.md) |
| Rendimiento | k6 cuando el escenario lo requiera: concurrencia, aceptación simultánea, endpoints críticos, mensajería, disponibilidad |

Los umbrales funcionales provienen del SRS/SAD/SDD y **no se inventan** en el pipeline ni en la documentación de DevOps (Políticas §13.5). Están en [Atributos de calidad](../02-arquitectura/atributos-de-calidad.md).

## Gates de seguridad

**SAST — SonarQube.** Analiza vulnerabilidades, bugs, code smells, duplicación y cobertura. **Ningún cambio con vulnerabilidades `Blocker` o `Critical` puede promoverse.**

**DAST — OWASP ZAP.** Se ejecuta sobre QA y debe cubrir, según exposición: autenticación, headers, inyección, XSS, configuración HTTP y endpoints publicados. Las APIs deben exponer contratos OpenAPI actualizados cuando facilite el escaneo automatizado.

**Dependencias e imágenes.** Antes de promover se analizan dependencias, vulnerabilidades conocidas e imagen OCI. La herramienta concreta puede cambiar sin modificar la política, salvo que su elección sea una decisión arquitectónica.

## Protección de ramas

Los rulesets deben cubrir, como mínimo, las ramas de integración, release y producción (Políticas §6.2).

> **Regla explícita del documento:** ninguna documentación debe asumir que una regla está forzada por GitHub si el ruleset todavía no existe. **La política es obligatoria aunque su enforcement automático esté pendiente.**

Un fallo de CI en rama compartida es de atención prioritaria del autor o responsable (`GOBIERNO_DEL_EQUIPO.md` §6.1).

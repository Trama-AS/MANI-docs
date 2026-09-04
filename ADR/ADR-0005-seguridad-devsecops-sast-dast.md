# ADR-0005: Integración DevSecOps con Análisis Estático (SAST con SonarQube) y Dinámico (DAST con OWASP ZAP)

- Fecha: 2026-08-19
- Sprint: 1
- Autor: Daniel Avila (DevOps)
- Origen: Mesa de Arquitectura
- Revisor: Santiago (QA/Product Owner)

## Contexto

El Gobierno del Equipo (sección 2.4) y la Matriz de Herramientas establecen que el proyecto MANI debe operar bajo un enfoque **DevSecOps**, integrando verificaciones continuas de seguridad dentro del ciclo de desarrollo y aseguramiento de calidad (QA). Sin embargo, existía un vacío operativo al no haber seleccionado las herramientas de seguridad específicas para:

1. **SAST (Static Application Security Testing):** Análisis del código fuente de Flutter, Java y .NET en etapas tempranas para detectar vulnerabilidades comunes (OWASP Top 10), *code smells* y fallos de diseño antes de integrar a ramas principales.
2. **DAST (Dynamic Application Security Testing):** Análisis de vulnerabilidades en tiempo de ejecución sobre los servicios web y APIs desplegados en los ambientes de prueba (**Testing / Test**) antes de autorizar su paso a producción (**Production / Prod**).
3. Establecer *Quality Gates* automatizados en GitHub Actions que bloqueen de forma vinculante la mezcla de código (*pull requests*) o el despliegue a ambientes superiores si se detectan vulnerabilidades críticas.

## Alternativas evaluadas

1. **Revisiones y auditorías de seguridad manuales previas al release.** Descartada porque introduce cuellos de botella severos, carece de repetibilidad sistemática, incrementa el tiempo de ciclo (*cycle time*) y no se alinea con el principio de automatización continua de DevSecOps.
2. **Plataformas comerciales de seguridad unificadas (Veracode / Checkmarx / Snyk Enterprise).** Descartada debido a los altos costos de licenciamiento corporativo incompatibles con el presupuesto del proyecto académico y una mayor sobrecarga de configuración frente al stack actual.
3. **SonarQube para SAST en los flujos de CI de GitHub Actions + OWASP ZAP para DAST automatizado en el ambiente de Testing.** Elegida.

## Decisión

Usaremos SonarQube para análisis estático de seguridad (SAST) en los flujos de integración continua y OWASP ZAP para análisis dinámico de seguridad (DAST) automatizado sobre los servicios desplegados en el ambiente de Testing.

## Trade-off asumido

El equipo asume el tiempo adicional de cómputo en la ejecución de los pipelines de GitHub Actions durante el análisis de SonarQube, así como la inversión de tiempo de QA y DevOps en calibrar reglas, excluir falsos positivos y mantener scripts de escaneo dinámico con OWASP ZAP sobre endpoints autenticados sin afectar la estabilidad del ambiente de pruebas.

## Estado

Aceptado — última actualización: 2026-08-19

**Nota de alcance (2026-09-03, ADR-0021):** esta decisión es independiente del proveedor de
infraestructura y del lenguaje de cada repositorio — SonarQube y OWASP ZAP se aplican por
igual sobre Flutter (Repo A), Java (Repo B), .NET (Repo C) y el backend Serverpod en Dart
(persistencia, ADR-0012). No compite con ADR-0012: ese ADR fija el motor de persistencia y
el lenguaje del backend principal; este ADR fija las herramientas de seguridad que se
ejecutan sobre todos los repos por igual, sin importar cuántos backends coexistan. Ver
ADR-0021 para la aclaración formal de que Java, .NET y Serverpod/Dart coexisten como
componentes de módulos distintos, ninguno reemplaza a otro.

## Consecuencias

- Positivas:
  - Detección temprana y automática de vulnerabilidades de seguridad (*shift-left security*) en el código de Flutter, Java y .NET antes del *merge* a la rama `develop`.
  - Validación dinámica de la postura de seguridad de las APIs e interfaces en ejecución (inyección SQL, XSS, headers HTTP inseguros, configuraciones erróneas) en el ambiente de Testing antes de la promoción a Producción.
  - Cierre formal de la brecha y pregunta pendiente de DevSecOps registrada en la Matriz de Herramientas y en el Gobierno del Equipo (§2.4).
  - Integración directa del reporte de fallos de seguridad con las políticas de rechazo del Definition of Done (DoD).
- Negativas:
  - Requiere aprovisionar y mantener la conectividad hacia la instancia/servicio de SonarQube y ejecutar contenedores con OWASP ZAP en los runners de GitHub Actions.
  - Bloqueo de Pull Requests cuando el Quality Gate de SonarQube falle, exigiendo refactorización inmediata por parte de los desarrolladores.
- Neutras:
  - Se define un Quality Gate estándar: vulnerabilidades de severidad *Blocker* o *Critical* detienen el pipeline de inmediato; fallos menores se registran como deuda técnica técnica en el backlog.
  - Los endpoints de las APIs de Java y .NET deben exponer documentación OpenAPI/Swagger para facilitar el escaneo automatizado con OWASP ZAP.


# ADR-0005 — DevSecOps con SAST, DAST y pruebas de API

- **Estado:** Aceptado
- **Decisión de:** seguridad del ciclo de entrega
- **Relacionado con:** ADR-0004, ADR-0015

## Contexto

MANI requiere controles automáticos de seguridad antes de promover cambios hacia producción.

## Alternativas

1. **Revisión manual previa al release.** Descartada por baja repetibilidad.
2. **Suite comercial integral.** Descartada por costo.
3. **SonarQube + OWASP ZAP + Newman en GitHub Actions.** Elegida.

## Decisión

Se utiliza:
- **SonarQube** para SAST y Quality Gate;
- **Newman** para pruebas automatizadas de API y contratos;
- **OWASP ZAP** para DAST en TEST/QA;
- escaneo de dependencias e imágenes antes de promoción.

Aplica a Flutter, NGINX/API Gateway, Java, .NET y Node.js.

Quality Gates mínimos para release:
- 0 vulnerabilidades Blocker/Critical;
- 0 vulnerabilidades High conocidas abiertas en producción;
- cobertura de código nuevo >= 80%;
- cobertura de casos críticos >= 90%;
- duplicación de código nuevo < 3%.

## Justificación

Implementa seguridad repetible y temprana sin depender de revisiones manuales tardías.

## Consecuencias

### Positivas
- Fallos detectados antes de PROD.
- Gates homogéneos para el stack políglota.

### Negativas
- Incrementa tiempo de pipeline y requiere calibración de falsos positivos.

## Condición de revisión

Revisar si cambian las herramientas de seguridad o los umbrales definidos por el SDD.

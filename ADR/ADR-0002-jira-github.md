# ADR-0002 — Jira para gestión y GitHub para desarrollo técnico

- **Estado:** Aceptado
- **Decisión de:** herramientas de gestión
- **Relacionado con:** ADR-0001, ADR-0004

## Contexto

El proyecto requiere separar la gestión del trabajo de la gestión técnica del código para evitar duplicidad de tableros y responsabilidades.

## Alternativas

1. **GitHub Projects como gestor principal.** Descartada por mezclar gestión de proyecto con trabajo técnico.
2. **GitLab Issues.** Descartada por introducir una plataforma adicional sin necesidad.
3. **Jira para gestión y GitHub para desarrollo.** Elegida.

## Decisión

Jira es la herramienta oficial para backlog, épicas, historias, bugs y sprints. GitHub se utiliza para repositorios, Pull Requests, issues técnicos, CI/CD y documentación técnica versionada.

La integración entre ambas herramientas puede automatizar trazabilidad mediante webhooks.

## Justificación

Separa responsabilidades y mantiene el trabajo técnico cerca del código.

## Consecuencias

### Positivas
- Backlog único en Jira.
- Trazabilidad técnica en GitHub.

### Negativas
- Requiere integración y convenciones para relacionar tickets con ramas y PR.

## Condición de revisión

Revisar únicamente si una herramienta única cubre satisfactoriamente ambos ámbitos sin perder trazabilidad.

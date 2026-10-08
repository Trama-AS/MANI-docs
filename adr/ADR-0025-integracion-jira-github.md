# ADR-0025 — Integración Jira–GitHub con GitHub for Atlassian y convención `[SCRUM-<id>]`

- **Estado:** Propuesto
- **Decisión de:** herramientas de gestión y trazabilidad
- **Relacionado con:** ADR-0002, ADR-0003, ADR-0004, CFG-39 (SCRUM-1114)
- **Autor:** María Camila Beltrán Carreño
- **Revisor:** Nicolás León (implementó CFG-39)
- **Fecha:** 2026-10-07
- **Jira:** DOC-36 (SCRUM-1091)

## Contexto

ADR-0002 separó la gestión del trabajo (Jira) del desarrollo técnico (GitHub), pero dejó la integración entre ambas herramientas declarada como posible y no como decidida: indicó que la trazabilidad *puede* automatizarse y registró como consecuencia negativa que se requieren integración y convenciones para relacionar tickets con ramas y PR.

Sin integración, la trazabilidad Jira ↔ GitHub depende de pegar enlaces a mano en los comentarios: se omite con facilidad, se desactualiza y no muestra el estado real de una rama o de un PR. Esto afecta directamente la evidencia que exige el DoD y el seguimiento del Scrum Master (SM-02).

La tarea CFG-39 (SCRUM-1114) conectó GitHub con Jira en los cuatro repositorios del incremento: `MANI-Frontend`, `MANI-API-Gateway`, `MANI-Core-Service` y `MANI-docs`. Este ADR registra la decisión que esa implementación materializa.

## Alternativas

1. **Enlaces manuales.** Cada persona pega en Jira la URL de su rama o PR. Descartada: depende de la disciplina individual, no refleja el estado del PR y no escala a cuatro repositorios.
2. **Integración propia con webhooks o GitHub Actions contra la API de Jira.** Descartada: obliga a mantener código y un token de Jira como secreto en cada repositorio, y duplica lo que ya ofrece la aplicación oficial.
3. **Aplicación oficial GitHub for Atlassian (GitHub for Jira) instalada en la organización `Trama-AS`.** Elegida.

## Decisión

Se usa la aplicación **GitHub for Atlassian**, conectada al sitio `maniservices.atlassian.net` y a los repositorios `MANI-Frontend`, `MANI-API-Gateway`, `MANI-Core-Service` y `MANI-docs`, con *smart commits* habilitados.

La vinculación se basa en la **clave del ticket de Jira** (`SCRUM-<id>`), que es obligatoria en tres lugares:

| Elemento | Formato | Ejemplo real |
|---|---|---|
| Rama | `feature/SCRUM-<id>-descripcion` o `fix/SCRUM-<id>-descripcion` | `feature/SCRUM-1077-repriorizacion-backlog` |
| Commit | `[SCRUM-<id>] mensaje` | `[SCRUM-1093] Agrega los mockups de las historias migradas de EP-02` |
| Título del PR | `[SCRUM-<id>] descripción` | `[SCRUM-1077] Repriorizacion del backlog V4 y decision ADR-0022` |

Reglas complementarias:
- Se usa la clave de Jira (`SCRUM-<id>`) y no el código interno de la tarea (`US-XX`, `DOC-XX`, `CFG-XX`), porque la aplicación solo reconoce claves de Jira. El código interno puede ir en la descripción.
- La rama nace de `develop` en los repositorios de código y de `main` en `MANI-docs`, que no tiene `develop`.
- La descripción del PR usa la plantilla `.github/pull_request_template.md`.

### Qué queda automatizado

- **Panel "Desarrollo" del ticket en Jira:** muestra las ramas, los commits y los PR con su estado (abierto, aprobado, fusionado) en cuanto el nombre o el mensaje contienen la clave. Verificado: SCRUM-1077 muestra su PR #16 de `MANI-docs` sin que nadie lo enlazara.
- **Smart commits:** un commit puede comentar el ticket (`#comment`), registrar tiempo (`#time`) o moverlo de estado (`#<transición>`) desde el mensaje del commit.
- **Revisores:** el archivo `.github/CODEOWNERS` asigna los revisores del PR automáticamente en GitHub.

### Qué sigue siendo manual

- Crear el ticket en Jira **antes** de crear la rama.
- Mover el ticket de estado cuando no se usa un smart commit, y cerrarlo después del merge.
- Diligenciar la plantilla del PR y su lista de verificación del DoD.
- Enlazar artefactos que no viven en GitHub (Figma, documentos externos) como comentario en el ticket.

## Justificación

La aplicación oficial entrega la trazabilidad que ADR-0002 dejó pendiente con el menor costo de mantenimiento: no hay código propio ni secretos que custodiar en cada repositorio, y la evidencia queda visible en el ticket para revisores, Scrum Master y docentes. La convención basada en la clave de Jira es la única que la aplicación reconoce, por lo que es la condición para que la automatización funcione.

## Consecuencias

### Positivas
- Trazabilidad automática y verificable desde cada ticket hacia sus ramas, commits y PR.
- Menos trabajo manual para el equipo y evidencia confiable para el DoD.
- Convención única para los cuatro repositorios.

### Negativas
- Una rama, commit o PR sin la clave `SCRUM-<id>` no aparece en Jira. Mitigación: la plantilla del PR exige el identificador y la revisión lo verifica.
- La aplicación necesita acceso a los repositorios de la organización. Mitigación: se limita a los repositorios del proyecto.
- `CONTRIBUTING.md` todavía indica la convención anterior (`feature/US-XX-descripcion` desde `develop`). Debe actualizarse para reflejar este ADR.
- Cada repositorio nuevo (por ejemplo `MANI-Rules-Service`, `MANI-Dispatch-Service` o `MANI-Availability`) debe agregarse a la aplicación al crearse.

## Condición de revisión

Revisar si se reemplaza Jira o GitHub, si la aplicación deja de tener soporte o cambia su modelo de costo, o si el equipo adopta una herramienta única que cubra gestión y desarrollo (condición ya prevista en ADR-0002).

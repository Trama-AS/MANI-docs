# Trabajo con asistentes de IA

[← 05 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** [`governance/POLITICAS_DEVOPS_HERRAMIENTAS.md`](../../governance/POLITICAS_DEVOPS_HERRAMIENTAS.md) §18 · [`adr/ADR-0009`](../../adr/ADR-0009-politica-ia.md) (`Superseded`, conservado por trazabilidad) · [`governance/GOBIERNO_DEL_EQUIPO.md`](../../governance/GOBIERNO_DEL_EQUIPO.md) §1.

## Política vigente

Se permite IA para apoyo de código, pruebas, documentación, diagramas y exploración técnica. Reglas (Políticas §18):

1. **todo resultado debe ser revisado por una persona;**
2. no se introducen credenciales;
3. no se introducen datos reales sensibles;
4. no se introduce información confidencial en herramientas externas no autorizadas;
5. **una respuesta de IA no constituye una decisión arquitectónica;**
6. una decisión relevante debe pasar por el proceso de gobierno correspondiente.

La regla 3 se cruza con una prohibición de infraestructura: **no se copian datos KYC ni datos personales reales a DEV o TEST/QA** ([Ambientes y promoción](../03-entrega/ambientes-y-promocion.md)). Tampoco se pegan en una herramienta de IA.

## Cómo se aplica en este repositorio

Un asistente que trabaje aquí sigue **el mismo proceso que una persona**: no hay reglas paralelas.

1. Partir del trabajo registrado en Jira (`US-XX`, `BUG-XX`, `CFG-XX`, `DOC-XX`, `SP-XX`). Sin identificador, no hay trabajo que hacer.
2. Leer la fuente del tema antes de escribir: [Jerarquía de fuentes](../Home.md#2-jerarquía-de-fuentes) y la tabla «Qué leer según la tarea».
3. Rama `feature/US-XX-descripcion` o `fix/BUG-XX-descripcion` desde `develop` ([Git: ramas y commits](git-ramas-y-commits.md)).
4. PR con los siete elementos obligatorios ([Pull requests](pull-requests.md)), revisado por una persona distinta del autor.
5. Entregar la evidencia de lo ejecutado: comando y resultado, no afirmaciones.

## Lo que un asistente no hace

Derivado de las reglas anteriores y de la jerarquía de fuentes, no de preferencias:

- **no decide arquitectura** ni «cierra» un punto abierto: `SP-05`, `INFRA-01` e `INFRA-02` se resuelven en Mesa de Arquitectura y producen ADR;
- **no edita un documento fuente para que coincida con el código**: una contradicción se reporta en el PR o en el issue y se resuelve en el documento correspondiente;
- no inventa umbrales, rutas, credenciales, nombres de tabla, endpoints ni versiones: si el dato no está documentado, pregunta;
- no introduce dependencias prohibidas ([Reglas arquitectónicas](../02-arquitectura/reglas-arquitectonicas.md));
- no marca algo como terminado sin el [DoD](dor-y-dod.md) completo;
- no sustituye la revisión humana: el punto 1 de la política es explícito.

## Ante ambigüedad

1. Si afecta un contrato, un estado, el alcance o el aislamiento multi-tenant: **detenerse y preguntar**.
2. Si es una decisión local y reversible, elegir la opción más simple coherente con la arquitectura y dejarla anotada en el PR.
3. Nunca resolver una contradicción entre documentos en silencio: se reporta. Lo que no está documentado no se exige, y tampoco se supone.

## Trabajo pendiente relacionado

La tarea `DOC-25` del backlog pide actualizar el contexto que consumen las herramientas de IA, porque aún describe la arquitectura anterior. Hasta que se ejecute, la referencia válida son los documentos de este repositorio y esta wiki.

ADR-0007: Estructura y Gestión de Documentación en el Repositorio
Fecha: 2026-08-25
Sprint: 1
Autor: Camila Beltrán (Frontend)
Origen: Mesa de Arquitectura
Revisor: Sara Albarracín (Scrum Master)

Contexto
El proyecto MANI genera documentación técnica de distinta naturaleza (requisitos, 
decisiones de arquitectura, diagramas, lineamientos de herramientas) que hoy se 
encuentra dispersa entre Confluence, Google Drive y mensajes de Discord, sin 
control de versiones ni trazabilidad directa con el código fuente. Esto dificulta 
que cualquier integrante del equipo (o el evaluador del curso) encuentre la 
versión vigente de un documento o entienda el porqué de una decisión técnica.

Alternativas evaluadas
- Confluence como fuente única de documentación. Descartada como repositorio 
  central porque queda desacoplada del código y no tiene historial de versiones 
  ligado a los commits del proyecto.
- Google Drive compartido. Descartada por falta de control de versiones real y 
  riesgo de duplicidad de archivos entre integrantes.
- Carpeta /docs versionada dentro del repositorio de GitHub. Elegida.

Decisión
Se centraliza toda la documentación técnica del proyecto en la carpeta /docs del 
repositorio MANI-docs, en formato Markdown (.md), organizada en subcarpetas por 
tipo de contenido (ADR, Product, Project). Confluence y Drive quedan como apoyo 
puntual (por ejemplo, borradores previos), pero la versión oficial y vigente de 
cualquier documento vive únicamente en el repositorio.

Trade-off asumido
El equipo asume la disciplina adicional de mantener actualizada la documentación 
en Markdown dentro del repo, en lugar de editar directamente en herramientas más 
visuales como Confluence.

Estado
Aceptado — última actualización: 2026-08-25

Consecuencias
Positivas:
- Documentación versionada junto al código, con historial de cambios visible en Git.
- Cualquier integrante o evaluador externo encuentra la información vigente en un 
  solo lugar, sin depender de accesos a herramientas externas.
- Facilita la revisión de documentación dentro de Pull Requests.

Negativas:
- Requiere que todo el equipo se familiarice con edición en Markdown.
- Mayor esfuerzo inicial de migración de contenido ya existente en Confluence/Drive.

Neutras:
- Se debe definir una convención de nombres y estructura de carpetas dentro de /docs 
  (ver ADR-0008 para el caso específico de diagramas).

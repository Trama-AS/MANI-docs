ADR-0008: Organización de Diagramas de Arquitectura en el Repositorio
Fecha: 2026-08-25
Sprint: 1
Autor: Camila Beltrán (Frontend)
Origen: Mesa de Arquitectura
Revisor: Sara Albarracín (Scrum Master)

Contexto
El proyecto utiliza diagramas de arquitectura (modelo C4) y diagramas de flujo 
(ciclo del servicio, arquitectura DevSecOps) creados en distintas herramientas 
(Figma, Mermaid, draw.io). Actualmente no existe una carpeta fija ni una 
convención de nombres, lo que genera confusión sobre cuál es la versión vigente 
de cada diagrama y dificulta encontrarlos durante la sustentación o revisión 
del proyecto.

Alternativas evaluadas
- Mantener los diagramas únicamente en las herramientas de origen (Figma, Miro). 
  Descartada porque no queda un respaldo versionado junto al código y depende de 
  acceso a cuentas externas.
- Adjuntar diagramas como imágenes sueltas en Confluence. Descartada por la misma 
  razón que en el ADR-0007: desacopla la documentación del código.
- Carpeta /docs/diagramas dentro del repositorio, con subcarpetas por tipo. Elegida.

Decisión
Se crea la carpeta /docs/diagramas dentro del repositorio, con subcarpetas:
- /docs/diagramas/c4 → diagramas de contexto, contenedores y componentes.
- /docs/diagramas/flujos → diagramas de proceso (ciclo del servicio, pipeline CI/CD).

Convención de nombres: [nivel-o-tipo]_[nombre-descriptivo]_v[N].png 
(ejemplo: c4-contexto_sistema-mani_v1.png). Los diagramas generados en Mermaid se 
guardan además en su formato de texto (.mmd) para poder versionarlos como código.

Trade-off asumido
El equipo asume el trabajo manual de exportar y subir los diagramas desde Figma 
u otras herramientas de diseño hacia el repositorio, ya que estas no se 
sincronizan automáticamente.

Estado
Aceptado — última actualización: 2026-08-25

Consecuencias
Positivas:
- Cualquier integrante encuentra el diagrama vigente sin depender de accesos externos.
- Los diagramas en Mermaid permiten revisar cambios (diffs) directamente en Git.
- Facilita adjuntar diagramas actualizados en la sustentación del proyecto.

Negativas:
- Los diagramas de Figma requieren exportación y subida manual, generando 
  posible desfase si no se actualizan a tiempo.

Neutras:
- Se debe recordar actualizar la versión (v1, v2, ...) cada vez que un diagrama 
  cambie de forma relevante.

ADR-0009: Política de Uso de Inteligencia Artificial en el Proyecto
Fecha: 2026-08-25
Sprint: 1
Autor: Camila Beltrán (Frontend)
Origen: Mesa de Arquitectura
Revisor: Sara Albarracín (Scrum Master)

Contexto
Los integrantes del equipo utilizan herramientas de inteligencia artificial 
(Claude, ChatGPT, GitHub Copilot, entre otras) como apoyo para generación de 
código, documentación, diagramas y exploración de decisiones de arquitectura. 
Es necesario establecer lineamientos claros de uso para garantizar calidad, 
seguridad de la información y que el criterio técnico del equipo siga siendo 
el que valida cualquier decisión final.

Alternativas evaluadas
- Prohibir el uso de herramientas de IA en el proyecto. Descartada por ser poco 
  realista dado el contexto académico actual y por limitar innecesariamente la 
  productividad del equipo.
- Permitir uso libre sin ningún lineamiento. Descartada por el riesgo de 
  código no revisado, filtración de información sensible del proyecto, o 
  decisiones de arquitectura tomadas sin pasar por la Mesa de Arquitectura.
- Uso permitido bajo lineamientos definidos por el equipo. Elegida.

Decisión
Se permite el uso de herramientas de IA en el proyecto MANI bajo las 
siguientes reglas:
1. Se puede usar IA para: generación de código base, documentación, redacción 
   de ADRs, diagramas, y exploración de alternativas de arquitectura.
2. Todo código o documento generado con IA debe ser revisado y comprendido por 
   la persona que lo incorpora al repositorio antes de hacer commit.
3. No se debe ingresar información sensible real del proyecto (credenciales, 
   datos de usuarios, información confidencial del cliente) en herramientas de 
   IA externas.
4. Ninguna decisión de arquitectura se considera oficial por haber sido sugerida 
   por una IA: toda decisión debe pasar por la Mesa de Arquitectura y quedar 
   documentada en un ADR.

Trade-off asumido
El equipo asume la responsabilidad individual de revisar y validar todo 
contenido generado con IA antes de integrarlo al proyecto, en lugar de 
incorporarlo directamente sin supervisión.

Estado
Aceptado — última actualización: 2026-08-25

Consecuencias
Positivas:
- Mayor velocidad en tareas de documentación, código base y exploración de 
  alternativas técnicas.
- Se mantiene el control de calidad y seguridad de la información del proyecto.
- Las decisiones de arquitectura siguen centralizadas y trazables en la Mesa de 
  Arquitectura, independientemente de qué herramienta ayudó a explorarlas.

Negativas:
- Requiere disciplina individual para no adoptar sugerencias de IA sin revisión 
  crítica.

Neutras:
- Esta política puede revisarse y ajustarse en futuras Mesas de Arquitectura 
  conforme cambien las herramientas de IA disponibles.

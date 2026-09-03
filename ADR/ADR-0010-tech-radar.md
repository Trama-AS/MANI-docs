ADR-0010: Definición del Tech Radar del Proyecto
Fecha: 2026-08-25
Sprint: 1
Autor: Camila Beltrán (Frontend)
Origen: Mesa de Arquitectura
Revisor: Sara Albarracín (Scrum Master)

Contexto
El equipo ha ido tomando decisiones de tecnología de forma distribuida en 
distintos ADRs (lenguajes, plataformas, herramientas por rol), pero no existía 
hasta ahora una vista consolidada y visual que permita, de un vistazo, saber 
qué tecnologías están confirmadas, cuáles están en evaluación y cuáles se 
descartaron. Esto es necesario para evitar decisiones técnicas informales o 
inconsistentes entre integrantes, y para facilitar el onboarding de cualquier 
persona nueva al proyecto.

Alternativas evaluadas
- Mantener las decisiones tecnológicas dispersas únicamente en los ADRs 
  individuales (ADR-0001 a ADR-0006), sin una vista consolidada. Descartada 
  por dificultar tener una visión rápida y global del stack.
- Construir un Tech Radar (círculos concéntricos por nivel de confianza: 
  Sí o sí / Tal vez / Mejor no, y cuadrantes por categoría: Plataformas, 
  Técnicas, Lenguajes, Herramientas). Elegida.

Decisión
Se adopta el siguiente Tech Radar como referencia consolidada del proyecto, 
basado en las decisiones ya documentadas en los ADRs previos:

Sí o sí:
- Lenguajes: Dart, Flutter, .NET, Java
- Plataformas: GitHub, Railway (ADR-0021)
- Herramientas: Docker, Docker Hub, Kubernetes (PROY-08, obligatorio y sin costo de
  licencia — ver SRS_MANI.md §1.4), Jira, Figma, Postman/Newman, GitHub Actions,
  Prometheus, Grafana, Datadog (ver ADR-0006)

Tal vez:
- Herramientas: k6

Descartado:
- Plataformas: Azure / Azure Container Registry (ADR-0021)

Mejor no (por ahora):
- Técnicas: GitHub Projects como gestor de backlog (se prioriza Jira, 
  ver ADR-0002, para no duplicar la gestión de tareas)

Este Tech Radar debe revisarse en cada Mesa de Arquitectura relevante, 
actualizando su estado según nueva evidencia o necesidades del proyecto.

Trade-off asumido
El equipo asume mantener este documento actualizado manualmente cada vez que 
se apruebe un nuevo ADR relacionado con tecnología, en lugar de generarlo 
automáticamente.

Estado
Aceptado — última actualización: 2026-09-03 (Kubernetes movido a "Sí o sí"; Azure retirado)

Consecuencias
Positivas:
- El equipo cuenta con un criterio visual y compartido de qué tecnologías usar.
- Facilita el onboarding de nuevos integrantes o la revisión externa del proyecto.
- Sirve como índice rápido que remite a los ADRs específicos de cada decisión.

Negativas:
- Puede quedar desactualizado si no se revisa tras cada nuevo ADR de tecnología.

Neutras:
- 🔴 Actualización 2026-09-03 (ADR-0021): Azure pasa de "Tal vez" a "Descartado" (se retira
  como proveedor de infraestructura) y Kubernetes pasa de "Tal vez" a "Sí o sí" — es requisito
  curricular obligatorio (PROY-08) y no tiene costo de licencia; el costo que antes lo
  mantenía en "Tal vez" (~$450–650 USD/mes) correspondía al cómputo de Azure AKS, no al
  orquestador, y ya no aplica al no usarse Azure (ver aclaración en SRS_MANI.md §1.4). Sigue
  pendiente el ADR de dimensionamiento concreto del clúster (nodos/hosting).

# ADR-0020: Adopción de herramientas para documentación visual, diagramación técnica y presentaciones

- Fecha: 2026-09-03
- Sprint: 1
- Autor: Santiago Hernández (Desarrollador / Equipo de Arquitectura)
- Origen: Mesa Técnica de Arquitectura
- Revisor: Sara Gómez (Líder Técnica / Product Owner)

## Contexto

Durante la revisión del Tech Radar y el documento de herramientas del Sprint 1, el equipo identificó la necesidad de respaldar formalmente mediante un ADR las herramientas visuales empleadas en el proyecto, en cumplimiento de los lineamientos del docente y de gobernanza técnica. Existen fuerzas en tensión concurrentes: por un lado, las entregas académicas y presentaciones ejecutivas requieren una estética cuidada, profesional y de rápida iteración visual; por otro lado, el modelado del sistema exige precisión técnica y conformidad con estándares de arquitectura de software (diagramas C4 y de interacción). Adicionalmente, el diseño de la interfaz móvil demanda prototipado colaborativo en tiempo real, mientras que la discusión rápida en mesas técnicas necesita un espacio de bocetado informal (whiteboarding). La política de costos del proyecto es estricta y prohíbe el pago de licencias comerciales.

## Alternativas evaluadas

1. Unificar toda la diagramación y presentaciones en Lucidchart o draw.io — en evaluación porque la capa gratuita limita los documentos a un máximo de 60 objetos editables y restringe la colaboración simultánea en equipo, forzando un costo de licenciamiento incompatible con el presupuesto del proyecto.
2. Utilizar herramientas de generación automática por IA (como Gamma o asistentes basados en LLM) — descartada porque generan artefactos visuales rígidos, inconsistentes con la identidad gráfica del proyecto y con nula capacidad de edición manual fina sobre diagramas técnicos.
3. Elaborar los diagramas técnicos directamente dentro de Canva o Paint — en evaluación pero carecen de soporte nativo para convenciones formales de arquitectura de software (notación C4, UML), no permiten versionado vectorial limpio y producen artefactos de bajo rigor técnico que fueron observados negativamente en revisiones previas.

## Decisión

Usaremos Canva exclusivamente para presentaciones ejecutivas al docente, Figma para el diseño de interfaces de usuario (UI/UX), Excalidraw para bocetos conceptuales rápidos en mesas técnicas y Draw.io para la diagramación técnica formal de la arquitectura del sistema.

## Trade-off asumido

El equipo asume la fragmentación del ecosistema de documentación visual y la dispersión de artefactos en cuatro plataformas externas distintas, sacrificando centralización y asumiendo la sobrecarga operativa de exportar manualmente imágenes o documentos PDF al repositorio central en GitHub.

## Estado

Aceptado — última actualización: 2026-09-03

## Consecuencias

- Positivas: Permite utilizar la herramienta óptima para cada objetivo (estética rápida en Canva, precisión de diseño en Figma, agilidad en Excalidraw y rigor técnico exportable sin costo en Draw.io), acelerando la preparación de artefactos para las sustentaciones del Sprint 1.
- Negativas: Obliga al equipo a mantener enlaces y exportaciones manuales sincronizadas dentro del repositorio de documentación, ya que no existe interoperabilidad de formatos editables entre estas plataformas.
- Neutras: Todos los integrantes del equipo deben crear cuentas individuales en las plataformas seleccionadas y configurar permisos compartidos en las carpetas de trabajo del proyecto.

## Trazabilidad

- Issues: #14
- Pull requests: #28
- Componentes del modelo C4 afectados: Contenedor de Documentación Técnica y Diagramas de Arquitectura (Nivel 1, 2 y 3).
- Documentos que deben actualizarse: Documento de Herramientas, Tech Radar del proyecto y Guía de contribución del repositorio.

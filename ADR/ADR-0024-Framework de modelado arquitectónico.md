# ADR-0024: Framework de modelado arquitectónico

**Fecha:** 2026-07-14
**Sprint:** Sprint 2
**Autor:** Nicolás León
**Origen:** issue SCRUM-932
**Revisor:** 

## Contexto
El equipo necesita definir un estándar para documentar la arquitectura, los procesos de negocio y los datos del sistema. Intentar forzar toda la documentación en un único estándar (como UML puro o el modelo 4+1) resulta restrictivo, complejo de mantener y difícil de entender para los diferentes stakeholders (negocio, desarrolladores, bases de datos). Se requiere un enfoque pragmático que utilice la mejor herramienta gráfica para cada necesidad.

## Alternativas evaluadas
* **Modelo 4+1 / UML Estricto** — descartada porque produce diagramas monolíticos y es difícil de entender para los perfiles de negocio (Product Owner, stakeholders).
* **Usar únicamente C4 Model** — descartada porque, aunque es excelente para la arquitectura de software, se queda corto para modelar procesos operativos de negocio y bases de datos relacionales.

## Decisión
Adoptaremos un **Framework de Modelado Híbrido**, utilizando el estándar más adecuado según la vista o el dominio a documentar:
1. **C4 Model**: Para la arquitectura de software (Diagramas de Contexto, Contenedores y Componentes).
2. **UML**: Para diagramas técnicos de bajo nivel (ej. Diagramas de Secuencia para flujos complejos de API o Diagramas de Clases).
3. **BPMN (en Miro)**: Para el modelado visual de los procesos de negocio y flujos operativos (Business Process Modeling).
4. **MER (Modelo Entidad-Relación)**: Para el diseño estático y estructural de la base de datos relacional.

## Trade-off asumido
Sacrificamos la uniformidad de tener un único lenguaje de modelado (y potencialmente una única herramienta) a cambio de maximizar la claridad, usando la herramienta y notación óptima para cada audiencia.

## Estado
Aprobado — última actualización: 2026-09-16

## Consecuencias
* **Positivas**: Comunicación mucho más efectiva. Negocio entiende los procesos en BPMN, los desarrolladores ven la arquitectura clara en C4, y los datos están precisos en el MER.
* **Negativas**: La documentación estará fragmentada en distintas herramientas (ej. Miro para BPMN, otra herramienta para C4/UML), lo que exige disciplina para mantener todo actualizado y referenciado.
* **Neutras**: Se requerirá especificar en el SDD/SAD los enlaces directos a los tableros de Miro y repositorios de diagramas como código.

## Trazabilidad
Issues: #SCRUM-932
Pull requests: #
Componentes del modelo C4 afectados: N/A
Documentos que deben actualizarse: SDD V1, SAD V2

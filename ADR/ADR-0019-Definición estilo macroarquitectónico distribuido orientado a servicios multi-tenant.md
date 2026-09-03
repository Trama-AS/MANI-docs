# ADR-0019: Definición del estilo macroarquitectónico distribuido orientado a servicios multi-tenant

- Fecha: 2026-09-03
- Sprint: 1
- Autor: Santiago Hernández (Equipo de Arquitectura)
- Origen: Mesa Técnica de Arquitectura
- Revisor: Sara Gómez (Product Owner / Líder Técnica)

## Contexto

El equipo debe consolidar la línea base del Documento de Arquitectura de Software (SAD) y cerrar el Sprint 1 para habilitar la implementación de historias de usuario en el Sprint 2. Existen fuerzas en tensión críticas que condicionan el diseño del sistema:
1. Restricción no negociable (*killer* arquitectónico): El proyecto exige contractualmente una arquitectura distribuida, quedando vetada cualquier aproximación monolítica.
2. Modelo de negocio: La solución requiere soporte nativo multi-tenant con estricto aislamiento lógico de datos entre organizaciones.
3. Entorno políglota: El equipo cuenta con componentes especializados que deben convivir de forma autónoma (cliente móvil, base de datos relacional y servicios de backend en tecnologías diversas como .NET y Java).
4. Restricción financiera y de plazo académico: El presupuesto del proyecto no admite costos fijos de infraestructura en la nube (lo cual descarta orquestadores comerciales), y el tiempo de desarrollo exige minimizar la sobrecarga de configuración de despliegues antes del Sprint 2.

## Alternativas evaluadas

1. Arquitectura Monolítica Modular — descartada porque viola el *killer* arquitectónico fundamental exigido para la entrega, impide el despliegue independiente de módulos especializados (.NET y Java) y restringe la escalabilidad granular de los servicios con mayor demanda.
2. Arquitectura de Microservicios contenerizados sobre clúster gestionado de Kubernetes — descartada porque los costos operativos de facturación de nodos en la nube violan el límite presupuestal del proyecto (*killer* de costo financiero) y la complejidad de administración de la infraestructura excede los plazos académicos de entrega del Sprint 1.
3. Arquitectura Serverless pura (BaaS exclusivo sobre servicios administrados) — descartada porque genera un acoplamiento excesivo y dependencia crítica con un único proveedor de nube (*vendor lock-in*), limitando la ejecución de lógica de negocio personalizada en lenguajes de servidor estándar.

## Decisión

Usaremos un estilo macroarquitectónico distribuido orientado a servicios desacoplados, compuesto por un cliente móvil multiplataforma en Flutter, microservicios backend independientes y una capa de persistencia multi-tenant sobre Supabase y PostgreSQL.

## Trade-off asumido

El equipo asume la sobrecarga técnica de gestionar la comunicación de red distribuida, la consistencia de datos y el mantenimiento de múltiples repositorios y pipelines de integración continua independientes, sacrificando la simplicidad de depuración unificada y la velocidad de configuración local inmediata que ofrecía un enfoque monolítico.

## Estado

Aceptado — última actualización: 2026-09-03

## Consecuencias

- Positivas: Cumple rigurosamente con los *killers* arquitectónicos del curso, permite a los desarrolladores trabajar en paralelo sin colisiones de código en sus respectivos módulos (.NET, Java, Flutter y Base de Datos) y habilita la escalabilidad independiente de cada componente según los atributos de calidad definidos (ISO 25010).
- Negativas: Introduce latencia inherente a las comunicaciones HTTP/REST entre cliente y servicios, y exige implementar mecanismos rigurosos de trazabilidad distribuida y manejo de fallos en el frontend móvil.
- Neutras: Requiere estandarizar contratos de API estrictos mediante OpenAPI/Swagger y definir una convención compartida de variables de entorno (`.env`) para la interacción entre repositorios.

## Trazabilidad

- Issues: #01
- Pull requests: #10
- Componentes del modelo C4 afectados: Todos los Contenedores del Modelo C4 (Aplicación Móvil Flutter, APIs de Backend en .NET/Java, Capa de Autenticación y Base de Datos Multi-Tenant en Supabase).
- Documentos que deben actualizarse: Documento de Arquitectura de Software (SAD), Diagrama de Arquitectura de Alto Nivel, Matriz de Escenarios de Calidad (ISO 25010) y Documento de Políticas DevOps.

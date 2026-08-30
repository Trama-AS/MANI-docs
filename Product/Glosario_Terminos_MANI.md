# Glosario de Términos (MANI Services)

Este documento centraliza las definiciones de negocio y términos técnicos utilizados en la documentación, backlog y arquitectura del ecosistema MANI.

## 1. Términos de Negocio

* **Aliado:** Proveedor independiente o empresa registrada en la plataforma que ejecuta los servicios locativos (ej. plomeros, electricistas).
* **Cliente:** Usuario final (persona natural o jurídica) que solicita y paga por un servicio locativo a través de la plataforma.
* **Backoffice:** Interfaz o consola administrativa utilizada por el personal interno de la plataforma para gestionar la operación (aprobación de aliados, revisión de PQR, configuración de tarifas).
* **Ciclo del Servicio:** Flujo completo de una solicitud, que abarca desde la petición inicial del cliente, la cotización, la aceptación, la ejecución, hasta el pago y la calificación final.
* **Cobertura:** Delimitación geográfica (zonas o radio en kilómetros) dentro de la cual un Aliado específico ofrece sus servicios.
* **Tenant (Inquilino):** En el contexto de negocio, representa a una empresa, marca o franquicia que utiliza la plataforma como su propio sistema (Marca Blanca), operando de forma aislada de otros inquilinos.

## 2. Términos Técnicos y de Arquitectura

* **Multi-tenant (Multi-inquilino):** Arquitectura de software donde una única instancia de la aplicación se ejecuta en el servidor y sirve a múltiples Tenants. Los datos están centralizados pero estrictamente aislados por seguridad.
* **Microservicios:** Patrón de arquitectura donde el backend de la aplicación se divide en pequeños servicios independientes (ej. Servicio de Identidad, Servicio de Pagos), cada uno con su propia lógica y base de datos lógica.
* **API Gateway (Puerta de enlace API):** Componente que actúa como un único punto de entrada para el frontend (app móvil o web). Recibe las peticiones del usuario y las redirige al microservicio correspondiente.
* **RLS (Row-Level Security):** Política de seguridad implementada directamente en el motor de la base de datos (PostgreSQL). Asegura que cada fila de datos solo pueda ser consultada o modificada por el usuario o Tenant que tiene los permisos adecuados, previniendo fugas de datos.
* **JWT (JSON Web Token):** Estándar abierto utilizado para transmitir información de sesión de forma segura entre el frontend y el backend (Identity Provider).
* **Identity Provider / IdP (Proveedor de Identidad):** Servicio externalizado (como Supabase Auth) encargado exclusivamente de gestionar el registro, inicio de sesión y validación de usuarios.
* **BaaS (Backend as a Service):** Modelo en la nube que proporciona servicios backend listos para usar (como bases de datos, autenticación y almacenamiento). En MANI se utiliza Supabase.
* **Blob Storage / Object Storage:** Servicio de almacenamiento en la nube diseñado para guardar archivos no estructurados (fotos, documentos PDF).
* **PostGIS:** Extensión de la base de datos PostgreSQL que permite almacenar y realizar consultas geográficas complejas (ej. buscar aliados cercanos por GPS).

## 3. Términos de Metodología (Agile / Scrum)

* **Spike Técnico:** Historia de usuario orientada puramente a la investigación y experimentación. Se utiliza cuando el equipo necesita resolver una duda técnica compleja antes de poder estimar y desarrollar una funcionalidad.
* **MVP (Minimum Viable Product):** Producto Mínimo Viable. La versión inicial del sistema con las funcionalidades estrictamente necesarias (Core) para salir al mercado y aportar valor al usuario.
* **Mockup:** Representación visual estática y de alta fidelidad de la interfaz de usuario.
* **BDD (Behavior-Driven Development):** Metodología de desarrollo donde los criterios de aceptación se escriben en un lenguaje natural estructurado (Given / When / Then) para que sean comprensibles tanto por el negocio como por los programadores.
* **INVEST:** Acrónimo (Independiente, Negociable, Valiosa, Estimable, Pequeña, Testeable) utilizado como lista de verificación para garantizar la calidad en la redacción de las Historias de Usuario.

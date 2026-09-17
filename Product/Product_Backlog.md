# Product Backlog Maestro (MANI Services)

Este documento contiene **absolutamente todo el trabajo del proyecto**, ordenado lógicamente para ser subido a Jira.
Incluye tanto las tareas de configuración técnica inicial (Sprint 1) como las verdaderas Historias de Usuario de negocio (Sprint 2 en adelante) con formato **INVEST**.

---

## ÉPICA 1: Arquitectura y Configuración Base (Enablers)
*(Nota: Estas incidencias técnicas van en el Sprint 1 y se crean en Jira como "Task" o "Spike", **NO** como Historias de Usuario, ya que no usan el formato INVEST).*

### CFG-01.1 - Tarea: Inicialización de Repositorios
* **Tipo:** Task
* **Asignado típico:** DevOps / Líder Técnico
* **Descripción:** Crear los repositorios oficiales en GitHub para Frontend y Backend desde cero. Dar accesos al equipo y configurar las ramas principales (`main`, `dev`).

### CFG-01.2 - Tarea: Creación de Base de Datos en Supabase
* **Tipo:** Task
* **Asignado típico:** Backend / Base de Datos
* **Descripción:** Crear la cuenta y el proyecto en Supabase. Desplegar la instancia inicial de PostgreSQL en la nube y obtener las credenciales de conexión (URL, contraseñas).

### CFG-01.3 - Tarea: Configuración de tablas y esquema en Supabase
* **Tipo:** Task
* **Asignado típico:** Backend / Base de Datos
* **Descripción:** Diseñar y crear las tablas iniciales del proyecto en la consola de Supabase (ej. `tenants`, `users`, `profiles`). Configurar las políticas de RLS (Row-Level Security) básicas y habilitar las Edge Functions si el proyecto las requiere.

### CFG-01.4 - Tarea: Configuración inicial del Frontend (Flutter)
* **Tipo:** Task
* **Asignado típico:** Frontend
* **Descripción:** Crear el proyecto base en Flutter desde cero. Instalar el SDK de Supabase para Flutter (`supabase_flutter`), configurar la estructura de carpetas y validar la conexión haciendo una consulta simple a una tabla de prueba en Supabase.

### CFG-01.5 - Tarea: Setup de Autenticación (Supabase Auth)
* **Tipo:** Task
* **Asignado típico:** Backend / Frontend
* **Descripción:** Habilitar el módulo de Autenticación en Supabase. Configurar las llaves (API Keys) tanto en el backend como en el frontend para que la aplicación pueda generar tokens JWT válidos al registrarse.

### CFG-01.6 - Tarea: Configuración de CI/CD y Linters
* **Tipo:** Task
* **Asignado típico:** DevOps / QA
* **Descripción:** Configurar GitHub Actions para que cada vez que alguien haga un "Push", se corran automáticamente los linters y pruebas básicas, evitando que suban código roto a la rama principal.

### CFG-01.7 - Tarea: Redacción del Documento de Arquitectura (SAD)
* **Tipo:** Task
* **Asignado típico:** Arquitecto / PO
* **Descripción:** Ahora que todo el esqueleto está conectado, documentar en el SAD (Software Architecture Document) exactamente cómo quedó la infraestructura, qué BD se usa y cómo se comunican las partes.

---

## ÉPICA 2: Registro y Perfiles

### US-02.1.1 - Registro aliado persona natural
> **Como** Técnico Independiente (Persona Natural), **quiero** registrarme en la plataforma subiendo mis documentos personales, **para** que el Backoffice valide mi identidad y me permita empezar a ofrecer mis servicios.

### US-02.1.2 - Registro aliado empresa
> **Como** Empresa de Servicios Locativos, **quiero** registrar mi empresa adjuntando la Cámara de Comercio y datos del representante legal, **para** operar formalmente en la plataforma y recibir solicitudes empresariales.

### US-02.1.3 - Aprobar/rechazar registro de aliado
> **Como** Administrador del Tenant, **quiero** tener una bandeja de verificación para revisar los documentos de los nuevos aliados, **para** aprobar o rechazar su ingreso y garantizar la calidad y seguridad de los técnicos de mi franquicia.

### US-02.1.4 - Declarar zona de cobertura
> **Como** Aliado (Técnico/Empresa), **quiero** delimitar en un mapa las zonas o barrios donde estoy dispuesto a trabajar, **para** recibir únicamente solicitudes de clientes a los que realmente puedo atender.

### US-02.1.5 - Registrar empleado directo
> **Como** Administrador del Tenant, **quiero** crear cuentas para empleados directos de mi empresa (que no pasan por flujo de aprobación), **para** asignarles servicios de forma inmediata bajo nuestra propia nómina.

### US-02.2.1 - Registro cliente persona natural
> **Como** Usuario Final (Cliente), **quiero** crear una cuenta rápida en la plataforma, **para** poder solicitar mantenimientos locativos para mi hogar. 

### US-02.2.2 - Cliente empresa con múltiples sitios
> **Como** Cliente Corporativo, **quiero** registrar múltiples direcciones o sedes bajo mi cuenta, **para** solicitar servicios de mantenimiento en cualquiera de mis sucursales sin crear cuentas repetidas.

### US-02.2.3 - Reglas contextuales del sitio visibles al aliado
> **Como** Cliente Corporativo, **quiero** configurar reglas específicas de entrada para mis sedes (ej. "Traer botas de seguridad"), **para** que el aliado las lea y acepte antes de agendar la visita.

### US-02.3.1 - Editar perfil propio
> **Como** Usuario (Cliente o Aliado), **quiero** actualizar mis datos personales, foto y dirección, **para** mantener mi información vigente.

### US-02.1.6 - Aliado gestiona su disponibilidad
> **Como** Aliado, **quiero** marcarme como 'No disponible' temporalmente, **para** no recibir solicitudes cuando estoy enfermo o de vacaciones.

### US-02.3.2 - Aceptación de Términos y Condiciones
> **Como** Usuario Nuevo (Cliente o Aliado), **quiero** leer y aceptar los Términos y Condiciones y Política de Datos Personales durante mi registro, **para** que la plataforma cumpla con la ley de Habeas Data (Ley 1581).

---

## ÉPICA 3: Configuración de Categorías

### US-03.1.1 - Crear categoría con flujo operativo
> **Como** Administrador del Tenant, **quiero** crear nuevas categorías de servicio (ej. "Plomería", "Cerrajería"), **para** organizar el catálogo que los clientes ven en la aplicación.

### US-03.1.2 - Desactivar categoría sin afectar en curso
> **Como** Administrador del Tenant, **quiero** ocultar temporalmente una categoría del catálogo público, **para** no recibir más solicitudes de ese tipo sin cancelar los servicios que ya se están ejecutando.

### US-03.1.3 - Aliado declara categorías que atiende
> **Como** Aliado, **quiero** seleccionar en mi perfil cuáles de las categorías del Tenant sé hacer, **para** que el sistema solo me envíe notificaciones de trabajos en mi área de experiencia.

---

## ÉPICA 4: Flujo Core del Servicio

### US-04.1.1 - Crear solicitud
> **Como** Cliente, **quiero** publicar una solicitud detallando mi problema locativo (con fotos y descripción), **para** que los aliados disponibles me envíen sus cotizaciones de reparación.

### US-04.1.2 - Ver aliados válidos por cobertura y categoría
> **Como** Cliente, **quiero** que al publicar mi solicitud la plataforma me muestre solo aliados que cubren mi zona y atienden mi categoría, **para** no perder tiempo contactando técnicos que no pueden venir.

### US-04.1.3 - Filtrar por tipo de aliado
> **Como** Cliente, **quiero** poder filtrar las cotizaciones recibidas para ver solo las de "Empresas" o solo las de "Independientes", **para** elegir el perfil que más me genere confianza.

### US-04.1.4 - Aceptar/rechazar solicitud sin doble asignación
> **Como** Aliado, **quiero** aceptar o rechazar una solicitud enviada por un cliente, **para** asegurar el trabajo, garantizando que el sistema bloquee a otros aliados de tomar la misma solicitud al mismo tiempo.

### US-04.1.5 - Priorizar por comisión ofrecida
> **Como** Administrador del Tenant, **quiero** que los aliados con mayor comisión aparezcan primero en el listado que ve el cliente, **para** incentivar la rentabilidad de mi franquicia.

### US-04.2.1 - Cotización con mano de obra y materiales separados
> **Como** Aliado, **quiero** enviar una cotización estructurada dividiendo el costo de mi trabajo y el costo de los materiales, **para** que el cliente tenga total transparencia del cobro.

### US-04.2.2 - Alerta de tarifa bidireccional
> **Como** Aliado, **quiero** recibir una alerta visual si mi cotización es extremadamente alta o baja comparada con el promedio del mercado, **para** ajustar mi precio antes de enviarla y no perder al cliente.

### US-04.2.3 - Cliente acepta/rechaza/ajusta cotización
> **Como** Cliente, **quiero** tener botones para aceptar, rechazar o devolver la cotización con comentarios (ej. "Está muy caro"), **para** negociar el precio final antes de que el aliado venga a mi casa.

### US-04.3.1 - Marcar inicio/fin de ejecución
> **Como** Aliado, **quiero** reportar en la app el momento exacto en que llego a la casa del cliente y cuando termino el trabajo, **para** que el sistema calcule el tiempo de ejecución y cambie el estado del servicio.

### US-04.3.2 - Registrar eventos durante la ejecución
> **Como** Aliado, **quiero** poder subir fotos o comentarios de imprevistos durante la reparación, **para** tener un respaldo por si el cliente reclama después.

### US-04.3.3 - Cliente consulta el log del servicio
> **Como** Cliente, **quiero** ver un historial en vivo (Log) de los cambios de estado de mi reparación, **para** tener tranquilidad sobre el avance del trabajo.

### US-04.3.4 - Cliente rastrea ubicación del aliado en vivo
> **Como** Cliente, **quiero** ver en un mapa en tiempo real por dónde viene el técnico, **para** saber cuánto falta para que llegue.

### US-04.3.5 - Aliado solicita adición por imprevisto
> **Como** Aliado, **quiero** solicitar un cobro adicional si durante la reparación descubro un daño extra, **para** que el cliente apruebe o rechace antes de seguir.

### US-04.3.6 - Registrar evidencias sin conexión (Offline)
> **Como** Aliado, **quiero** que la app guarde mis fotos y notas localmente si estoy sin internet, **para** que se sincronicen automáticamente cuando recupere señal.

### US-04.4.1 - Cliente califica al aliado
> **Como** Cliente, **quiero** calificar de 1 a 5 estrellas al aliado al finalizar el trabajo y dejar una reseña, **para** advertir o recomendar a futuros clientes.

### US-04.4.2 - Aliado califica al cliente
> **Como** Aliado, **quiero** calificar el comportamiento y trato del cliente, **para** proteger a otros técnicos de clientes problemáticos o morosos.

### US-04.4.3 - Calificación agregada visible en el listado
> **Como** Cliente, **quiero** ver el promedio de estrellas de un Aliado junto a su nombre antes de aceptarlo, **para** tomar una decisión informada basada en su reputación.

### US-04.5.1 - Cancelar solicitud antes de la ejecución
> **Como** Cliente, **quiero** cancelar una solicitud aceptada antes de que el aliado marque inicio de ejecución, **para** no quedar atrapado si surgió un imprevisto personal.

### US-04.5.2 - Penalización por cancelación tardía
> **Como** Aliado, **quiero** recibir una compensación económica parcial si el cliente cancela cuando yo ya estoy en camino, **para** que mi tiempo y gasolina no sean una pérdida total.

### US-04.6.1 - Consultar historial de servicios
> **Como** Cliente, **quiero** ver una lista de todos los servicios que he solicitado con su estado y calificación, **para** volver a contactar al mismo aliado o tener referencia de costos.

### US-04.6.2 - Aliado consulta historial de trabajos
> **Como** Aliado, **quiero** ver una lista de mis servicios completados y cancelados históricamente, **para** llevar un control personal de mi rendimiento y ganancias acumuladas.

---

## ÉPICA 5: Comunicación

### US-05.1.1 - Mensajería cliente-aliado por servicio
> **Como** Cliente o Aliado, **quiero** tener un chat interno privado asociado únicamente a la solicitud actual, **para** poder comunicarnos (ej. "Ya voy en camino") sin tener que darnos nuestros números de WhatsApp personales.

### US-05.1.2 - Notificaciones de mensajes nuevos
> **Como** Usuario, **quiero** recibir notificaciones push en mi celular cuando la otra persona me escribe en el chat, **para** no perder tiempo manteniendo la app abierta todo el día.

### US-05.1.3 - Consultar conversación para atender queja
> **Como** Administrador del Tenant (Soporte), **quiero** poder leer el historial del chat entre un Cliente y un Aliado, **para** tener pruebas objetivas en caso de que abran un reclamo legal o PQR.

### US-05.1.4 - Notificaciones push del ciclo del servicio
> **Como** Usuario (Cliente o Aliado), **quiero** recibir notificaciones automáticas cuando ocurren eventos clave (ej. "Cotización recibida", "Aliado en camino"), **para** poder reaccionar inmediatamente sin tener la app abierta.

---

## ÉPICA 6: Tarifas

### US-06.1.1 - Cargar tabla de tarifas por categoría
> **Como** Administrador del Tenant, **quiero** subir un archivo con los precios base y máximos sugeridos para cada servicio, **para** estandarizar los costos en mi plataforma.

### US-06.1.2 - Ver tarifa de referencia al cotizar
> **Como** Aliado, **quiero** ver una sugerencia de "Tarifa Típica" en pantalla mientras redacto mi cotización, **para** no cobrar menos de lo justo ni espantar al cliente por cobrar demasiado.

### US-06.1.3 - Reporte de cotizaciones fuera de rango
> **Como** Administrador del Tenant, **quiero** descargar un reporte mensual de todas las cotizaciones que se hicieron por encima del precio máximo establecido, **para** identificar posibles fraudes o aliados abusivos.

---

## ÉPICA 7: Pagos

### US-07.1.1 - Pago en línea al aceptar cotización
> **Como** Cliente, **quiero** pagar el valor total del servicio con mi tarjeta de crédito o PSE directamente en la plataforma, **para** evitar manejar efectivo con desconocidos.

### US-07.1.2 - Registro de transacciones (Audit Log inmutable)
> **Como** Administrador del Tenant, **quiero** que todas las transferencias de dinero queden guardadas en un registro histórico inmodificable, **para** cumplir con auditorías financieras y evitar desfalcos.

### US-07.1.3 - Descargar soporte de pago
> **Como** Cliente, **quiero** descargar un PDF con el recibo de mi pago al finalizar el servicio, **para** llevar mi propia contabilidad o pasarlo como gasto en mi empresa.

### US-07.1.4 - Retención de fondos en garantía (Escrow)
> **Como** Cliente, **quiero** que mi dinero quede retenido en garantía (Escrow) al aceptar la cotización sin que se le transfiera al aliado de inmediato, **para** estar protegido si el trabajo sale mal.

### US-07.1.5 - Liberación automática de fondos
> **Como** Aliado, **quiero** que los fondos retenidos se liberen automáticamente a mi billetera tras 24 horas sin disputas, **para** recibir mi pago justo sin tener que reclamarlo manualmente.

### US-07.2.1 - Liquidación al aliado (Comisión configurable)
> **Como** Administrador del Tenant, **quiero** que el sistema descuente automáticamente la comisión de la plataforma antes de transferirle el dinero al técnico, **para** garantizar la rentabilidad del negocio sin hacer cálculos manuales.

### US-07.2.2 - Aliado consulta detalle de pagos
> **Como** Aliado, **quiero** ver un tablero con el dinero que he ganado esta semana y las comisiones descontadas, **para** tener control total sobre mis finanzas y verificar que me paguen lo correcto.

---

## ÉPICA 8: Soporte y Métricas

### US-08.1.1 - Cliente registra queja
> **Como** Cliente, **quiero** tener un botón para reportar un problema grave con el servicio (ej. "El técnico dañó una tubería extra"), **para** exigir una compensación o mediación de la plataforma.

### US-08.1.2 - Tenant gestiona estado de quejas
> **Como** Administrador del Tenant, **quiero** ver una bandeja de Quejas y Reclamos donde pueda cambiar su estado (Abierto, En Revisión, Resuelto), **para** asegurar que ningún cliente se quede sin respuesta legal.

### US-08.1.3 - Resolución de disputa financiera
> **Como** Administrador del Tenant (Finanzas/Soporte), **quiero** poder emitir un fallo sobre una disputa (reembolsar al cliente parcial/totalmente, o pagar al técnico), **para** desbloquear los fondos retenidos en Escrow y cerrar el caso.

### US-08.2.1 - Publicar contenido en redes conectadas
> **Como** Administrador del Tenant (Marketing), **quiero** conectar mis redes sociales para publicar promociones masivas, **para** atraer nuevos clientes a la plataforma.

### US-08.2.2 - Registrar campañas y ver desempeño
> **Como** Administrador del Tenant, **quiero** crear códigos de descuento (Campañas) y ver cuántos usuarios los canjearon, **para** medir el retorno de inversión (ROI) de mis esfuerzos de marketing.

### US-08.3.1 - Métricas operativas por tenant
> **Como** Administrador del Tenant, **quiero** un Dashboard estadístico (Servicios completados, Ingresos mensuales, Aliados activos), **para** analizar la salud y el crecimiento de mi franquicia.

### US-08.3.2 - Administrar estado de tenants
> **Como** Superadministrador de la Plataforma, **quiero** poder suspender o bloquear a un Tenant entero (empresa), **para** detener su operación si no han pagado la suscripción del software.
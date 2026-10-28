/*
 * MANI — Modelo C4 en Structurizr DSL
 *
 * Fuente del modelo: SAD.md (§5 contexto, §6 contenedores, §7 responsabilidad de servicios,
 * §8 multi-tenancy, §15 analítica) y SDD.md (§4 vistas C4, §9 despliegue, §10 ambientes).
 *
 * Este archivo es la fuente de los diagramas C4 del proyecto. El SDD referencia sus vistas.
 * Los diagramas de alto nivel (DHL) e infraestructura ilustrativa viven en diagrams/HLD/
 * y los referencia el SAD.
 *
 * Vistas definidas:
 *   1. panorama      — System Landscape: el panorama de sistemas alrededor de MANI
 *   2. contexto      — C4 Nivel 1, System Context
 *   3. contenedores  — C4 Nivel 2, Containers
 *   4. componentes   — C4 Nivel 3, un diagrama por servicio desplegable
 *   5. dinamico      — Vistas dinámicas: los flujos que la estructura estática no explica
 *   6. despliegue    — Vista de despliegue de producción
 *
 * Con esto el modelo cubre las cuatro vistas que Structurizr sí puede describir —panorama,
 * estática (contexto, contenedores, componentes), dinámica y de despliegue— y ninguna de ellas
 * queda solo en texto.
 *
 * El Nivel 4 (Code) no se modela aquí: Structurizr no describe clases. Se mantiene en SDD §4.4.
 * La landing comercial (MANI-Landing) está en el modelo y en las vistas panorama, contexto y
 * contenedores, pero no en la de despliegue: esa vista describe la topología objetivo de
 * Kubernetes y la landing hoy corre como contenedor Docker en cada host (DOCUMENTO_INFRAESTRUCTURA_V3
 * §3). Agregarla ahí sería documentar un despliegue que no existe.
 *
 * Tampoco se modela un nodo por ambiente: Local, DEV y TEST/QA comparten la topología de
 * producción y solo cambian escalado, secretos y datos (SDD §10).
 *
 * Decisiones abiertas que este modelo NO fija: proveedor y topología del clúster Kubernetes
 * (INFRA-01 e INFRA-02 de INFRAESTRUCTURA_MANI.md §25). Los nodos de despliegue se nombran
 * sin proveedor deliberadamente.
 *
 * Regla de la vista de despliegue: toda relación del ambiente conecta elementos hoja
 * —instancias de contenedor o nodos de infraestructura—, nunca un nodo de despliegue que
 * contiene otros. Structurizr posiciona solo las hojas y dibuja el padre como la caja que las
 * encierra; una relación que apunta al padre lo obliga a tener posición propia y a encerrar a
 * sus hijos a la vez, y el resultado son cajas superpuestas y fuera de lienzo.
 */

workspace "MANI" "Plataforma SaaS multi-tenant de formalización y gestión de operaciones de servicio — TRAMA · Ingeniería de Software" {

    model {

        // ---------- Actores (SRS §2.3) ----------

        cliente = person "Cliente" "Solicita servicios, gestiona cotizaciones, participa en mensajería y califica al aliado."
        aliado = person "Aliado" "Presta el servicio: carga KYC, declara categorías y cobertura, acepta, cotiza, ejecuta y califica."
        adminTenant = person "Administrador de tenant" "Configura reglas, categorías, tarifarios y documentos requeridos; aprueba o rechaza aliados."
        adminPlataforma = person "Administrador de plataforma" "Registra tenants y administra su estado."
        visitante = person "Visitante" "Persona sin sesión que conoce los servicios y estima un precio de referencia antes de registrarse (SCRUM-1335)."

        // ---------- Sistemas externos (SRS §5, SAD §5) ----------

        push = softwareSystem "FCM / APNs" "Entrega notificaciones push cuando el destinatario no está conectado." "Externo"
        pagos = softwareSystem "Operador de pagos certificado" "Procesa cobros y liquidaciones. Segundo incremento. El cumplimiento PCI DSS recae en el operador (RNF-06)." "Externo"
        observabilidad = softwareSystem "Plataforma de observabilidad" "Prometheus, Grafana y Datadog: métricas, dashboards, logs, trazas y alertas." "Externo"
        dwh = softwareSystem "Data Warehouse / BI" "Analítica desacoplada del OLTP. Recibe datos por CDC/ELT y no escribe en operacional." "Externo"

        // ---------- Sistema MANI ----------

        mani = softwareSystem "MANI" "Formaliza el ciclo Solicitud → Cotización → Ejecución → Calificación → Cierre con aislamiento estricto por tenant." {

            group "Cliente y entrada" {

                landing = container "Landing comercial" "Página pública: catálogo de categorías con tarifas base de referencia, estimador de rango que no es una cotización y redirección al login de la aplicación cliente. No accede a datos, no llama al Gateway ni a los servicios (ADR-0028, SAD §7.4)." "React 19 + Vite 8, servida por NGINX"

                flutter = container "Aplicación cliente" "Presentación y lógica de interacción. Una sola base de código para web y móvil. No contiene reglas de negocio centrales (SAD §4.1)." "Flutter / Dart — Web y móvil"

                gateway = container "API Gateway" "Entrada única de toda API operacional: enrutamiento, terminación TLS, control de acceso, validación del token y rate limiting. La aplicación no necesita saber dónde vive cada servicio. No implementa reglas de dominio." "NGINX"
            }

            // Java decide. El motor de reglas es lo único que vive aquí: no es un backend general.
            group "MANI-Rules-Java — decide" {

                rules = container "Rules Service" "Reglas configurables por tenant, ranking de aliados, requisitos KYC y validación contra tarifario (RF-02, RF-13, RF-16, RF-22). La elegibilidad la resuelve Core; Rules aporta el orden (SAD §4.2.1). Lee la configuración de persistencia, no del código." "Java" {
                    rulesApi = component "Rules REST Controller" "Expone la evaluación de reglas y el ranking." "Java"
                    rulesApp = component "Rules Application Service" "Orquesta evaluación y ranking." "Java"
                    rulesFactory = component "Rule Strategy Factory" "Resuelve la estrategia según el tipo de regla." "Java"
                    rulesRanking = component "Ranking Strategy" "Ordena aliados según la regla del tenant (RF-13)." "Java"
                    rulesTariff = component "Tariff Validation Strategy" "Valida la cotización contra el tarifario de referencia (RF-16, RF-22)." "Java"
                    rulesKyc = component "KYC Policy Strategy" "Evalúa los documentos requeridos por el tenant." "Java"
                    rulesPort = component "Rule Repository Port" "Contrato de acceso a reglas." "Java — interfaz"
                    rulesAdapter = component "Supabase Adapter" "Implementa el puerto contra PostgreSQL." "Java"
                }
            }

            // .NET asigna. Despacho y exclusión concurrente, nada más.
            group "MANI-Dispatch-DotNet — asigna" {

                dispatch = container "Dispatch Service" "Coordinación operacional de solicitudes, selección de aliados válidos, aceptación/rechazo, estados de asignación, idempotencia y exclusión concurrente (RF-12, RF-14, RNF-03, RNF-05). Consume Rules antes de asignar." ".NET" {
                    dispatchApi = component "Dispatch API" "Expone creación de solicitud y aceptación/rechazo." ".NET"
                    dispatchApp = component "Dispatch Application Service" "Casos de uso de despacho." ".NET"
                    dispatchSelector = component "Candidate Selector" "Obtiene candidatos válidos para la solicitud." ".NET"
                    dispatchCoordinator = component "Assignment Coordinator" "Coordina la asignación de la solicitud." ".NET"
                    dispatchGuard = component "Concurrency Guard" "Actualización condicional atómica: la primera aceptación válida gana; las siguientes reciben 409 Conflict." ".NET"
                    dispatchAudit = component "Audit Component" "Audita cambios de estado del despacho (RNF-04)." ".NET"
                    dispatchPort = component "Dispatch Repository Port" "Contrato de persistencia del despacho." ".NET — interfaz"
                    dispatchAdapter = component "PostgreSQL Adapter" "Implementa el puerto contra PostgreSQL." ".NET"
                }
            }

            // Node opera. Núcleo funcional de la plataforma: lo transversal y lo operativo.
            group "MANI-Core-Node — opera" {

                core = container "Core Services" "Núcleo funcional: usuarios y tenants, identidad y acceso, aliados y KYC, clientes y sitios, categorías, solicitudes, cotizaciones, documentos y multimedia, notificaciones, ubicación, disponibilidad y reportes. Se divide internamente por dominios sin convertir cada CRUD en un servicio desplegable (SAD §7.3)." "Node.js" {
                    coreApi = component "Core API" "Expone los casos de uso de los dominios de Core." "Node.js"
                    coreUsers = component "Users / Tenants Component" "Tenants, usuarios, roles y acceso (RF-01, RF-03, RF-04)." "Node.js"
                    coreKyc = component "KYC Orchestrator" "Registro y verificación de aliados y documentos (RF-05, RF-06)." "Node.js"
                    coreCatalog = component "Catalog Component" "Categorías, clientes, sitios y asociaciones (RF-08..RF-11)." "Node.js"
                    coreAvailability = component "Availability Component" "Cobertura del aliado, horarios y solapamientos, zonas y elegibilidad por categoría y zona (RF-07, RF-12, RNF-07). La lógica pertenece al servicio, no al cliente Flutter." "Node.js"
                    coreNotif = component "Notification Component" "Mensajería del servicio y notificaciones (RF-20, RF-21)." "Node.js"
                    coreReport = component "Operational Reporting" "Reportes operativos y de tarifario (RF-23)." "Node.js"
                    coreAdapters = component "External Adapters" "Encapsula proveedores externos: push, Storage, pagos. Durante el desarrollo pueden ser implementaciones mock sin tocar la lógica de negocio." "Node.js"
                    corePort = component "Repositories" "Contratos de persistencia de los dominios de Core." "Node.js — interfaces"
                }
            }

            // Persistencia por contexto funcional: cada servicio es dueño de sus datos y ningún
            // servicio lee las tablas de otro (ADR-0012, ADR-0030 §2).
            //
            // ESTADO OBJETIVO, NO PRESENTE. Hoy hay UNA base PostgreSQL por ambiente y los tres
            // almacenes de abajo son contextos lógicos dentro de ella, no instancias separadas.
            // La propiedad se ejerce por la serie única de migraciones, propiedad de Core Service
            // (ADR-0030 §1): Rules y Dispatch no versionan DDL, abren PR contra esa serie. La
            // frontera la impone además el motor, con un rol por servicio sin BYPASSRLS y GRANT
            // solo sobre su dominio (ADR-0032, ModeloDatos §6.3). Separar físicamente las bases
            // exige un ADR nuevo que revise ADR-0012.
            group "Supabase — datos y servicios administrados" {

                auth = container "Supabase Auth" "Autenticación de usuarios y emisión del JWT firmado del que se obtiene el tenant_id (ADR-0018)." "Supabase"

                dbRules = container "Supabase Rules" "Reglas por tenant, tarifarios, criterios de ranking y configuración KYC. RLS por tenant." "Supabase — PostgreSQL + RLS" "Database"
                dbDispatch = container "Supabase Dispatch" "Rechazos de ofertas (solicitud_rechazo), exclusiones y auditoría de despacho. No guarda el estado de la solicitud: desde la decisión 6A lo escribe Core, y el evento AliadoAsignado pasa a servicio.outbox (ADR-0035, propuesto). RLS por tenant." "Supabase — PostgreSQL + RLS" "Database"
                dbCore = container "Supabase Core" "Usuarios, tenants, aliados, KYC, clientes y sitios, categorías, solicitudes, cotizaciones, cobertura y disponibilidad, comunicación y reportes. Core crea la solicitud (SAD §7.4, decisión del 17 oct) y es el único que escribe su estado, también la asignación (decisión 6A). Incluye servicio.outbox para SolicitudCreada, AliadoAsignado y CotizacionAceptada (ADR-0029 §3, ADR-0035 propuesto). RLS por tenant." "Supabase — PostgreSQL + RLS" "Database"

                storage = container "Supabase Storage" "Documentos KYC y multimedia en bucket privado con la convención tenant_id/aliado_id/documento (ADR-0013)." "Supabase"
                realtime = container "Supabase Realtime" "Transporta eventos de mensajería mientras los participantes están conectados. No ejecuta reglas de negocio." "Supabase"
            }

            // ADR-0029: el bus se adopta como decisión y su implementación se difiere al Sprint 5.
            // Se modela para que la vista no sugiera que la integración asíncrona ya existe: hoy
            // NO hay broker desplegado y ninguna capacidad depende de consumo asíncrono.
            group "Mensajería entre servicios — diferida al Sprint 5" {

                bus = container "Bus de eventos" "Apache Kafka. Transporta los eventos de negocio entre servicios: SolicitudCreada y CotizacionAceptada (produce Core), AliadoAsignado (produce Dispatch). Un solo productor por evento, sobre común con tenant_id y correlation_id, publicación con transactional outbox y consumo idempotente por event_id (ADR-0029). NO DESPLEGADO: alcance Sprint 5, ARQ-05." "Apache Kafka" "Diferido"
            }

            group "Analítica" {

                etl = container "CDC / ELT" "Carga incremental del OLTP hacia el Data Warehouse. No participa en transacciones operacionales." "Proceso desacoplado"
            }
        }

        // ---------- Relaciones de contexto (SAD §5) ----------

        cliente -> mani "Crea solicitudes, gestiona cotizaciones y califica"
        aliado -> mani "Carga KYC, declara cobertura, acepta, cotiza, ejecuta y califica"
        adminTenant -> mani "Configura reglas, categorías y tarifarios; verifica aliados"
        adminPlataforma -> mani "Registra y administra tenants"

        mani -> push "Solicita el envío de notificaciones"
        mani -> pagos "Cobros y liquidaciones (2.º incremento)"
        mani -> observabilidad "Métricas, logs y trazas con correlation_id"
        mani -> dwh "Datos operacionales para análisis, por CDC/ELT"

        // ---------- Relaciones de contenedores (SAD §6, SDD §4.2) ----------

        cliente -> flutter "Usa"
        aliado -> flutter "Usa"
        adminTenant -> flutter "Usa"
        adminPlataforma -> flutter "Usa"

        // La landing no consume API: su única relación es la navegación del navegador hacia el
        // login del cliente web, con la categoría o el aliado elegidos como consulta.
        visitante -> landing "Conoce los servicios y estima un precio de referencia"
        landing -> flutter "Redirige el navegador a /login con el contexto elegido" "HTTPS — navegación del navegador"

        flutter -> gateway "Consume la API operacional" "HTTPS / JSON"
        flutter -> auth "Autentica y obtiene el JWT" "HTTPS"

        gateway -> rules "Enruta tras validar el token" "HTTPS / JSON"
        gateway -> dispatch "Enruta tras validar el token" "HTTPS / JSON"
        gateway -> core "Enruta tras validar el token" "HTTPS / JSON"

        core -> auth "Integra identidad y acceso"

        // Frontera entre servicios: HTTP por la red interna y NUNCA SQL contra tablas ajenas
        // (ADR-0030 §2, SDD §4.2). Patrón obligatorio: puerto en el dominio, cliente en
        // infraestructura, timeout, reintento solo si la operación es idempotente y falla
        // cerrado — 503 al llamador, sin degradar a lógica local ni a un valor por omisión.
        core -> rules "Evalúa las reglas de la categoría del tenant. Implementado en RulesServiceHttpClient: timeout 3 s, un reintento, 503 si Rules no responde" "HTTPS / JSON"
        dispatch -> core "Consulta la elegibilidad de aliados por categoría y zona (RF-12), el contexto de la solicitud y la bandeja del aliado, pide las ofertas y entrega el comando de asignación (decisión 6A). Rutas internas de core-internal.yaml, bloqueadas en el Gateway" "HTTPS / JSON"
        dispatch -> rules "Consulta el orden del listado de candidatos (ranking)" "HTTPS / JSON"

        // Producción de eventos hacia el bus diferido: el servicio escribe en su outbox dentro de
        // la transacción de negocio y un relay publica desde ahí (ADR-0029 §3).
        core -> bus "Publica SolicitudCreada y CotizacionAceptada vía outbox (Sprint 5)" "Kafka"
        dispatch -> bus "Publica AliadoAsignado vía outbox (Sprint 5)" "Kafka"
        rules -> dbRules "Lee reglas, tarifarios y criterios de elegibilidad del tenant" "SQL"
        dispatch -> dbDispatch "Persiste los rechazos y la auditoría del despacho; no escribe solicitud (decisión 6A, migración 0019)" "SQL"
        core -> dbCore "Persiste tenants, aliados, clientes, catálogo, cotización, cobertura y comunicación" "SQL"

        core -> storage "Almacena y sirve documentos KYC aislados por tenant y aliado"
        core -> realtime "Publica eventos de mensajería del servicio"
        core -> push "Envía notificaciones cuando el destinatario no está conectado"
        core -> pagos "Cobros y liquidaciones (2.º incremento)"

        flutter -> realtime "Recibe mensajes en tiempo real mientras está conectado"

        dbRules -> etl "Entrega carga incremental"
        dbDispatch -> etl "Entrega carga incremental"
        dbCore -> etl "Entrega carga incremental"
        etl -> dwh "Alimenta el Data Warehouse"

        gateway -> observabilidad "Métricas, logs y trazas"
        rules -> observabilidad "Métricas, logs y trazas"
        dispatch -> observabilidad "Métricas, logs y trazas"
        core -> observabilidad "Métricas, logs y trazas"

        // ---------- Relaciones de componentes (SDD §4.3) ----------

        gateway -> rulesApi "Enruta"
        rulesApi -> rulesApp "Invoca"
        rulesApp -> rulesFactory "Resuelve la estrategia"
        rulesFactory -> rulesRanking "Instancia"
        rulesFactory -> rulesTariff "Instancia"
        rulesFactory -> rulesKyc "Instancia"
        rulesApp -> rulesPort "Consulta reglas del tenant"
        rulesPort -> rulesAdapter "Implementado por"
        rulesAdapter -> dbRules "Lee" "SQL"

        gateway -> dispatchApi "Enruta"
        dispatchApi -> dispatchApp "Invoca"
        dispatchApp -> dispatchSelector "Obtiene candidatos"
        dispatchApp -> dispatchCoordinator "Coordina la asignación"
        dispatchCoordinator -> dispatchGuard "Delega la exclusión concurrente"
        dispatchApp -> dispatchAudit "Registra cambios de estado"
        dispatchApp -> dispatchPort "Persiste"
        dispatchGuard -> dispatchPort "Actualización condicional atómica del estado de la asignación"
        dispatchPort -> dispatchAdapter "Implementado por"
        dispatchAdapter -> dbDispatch "Lee y escribe" "SQL"
        dispatchSelector -> coreApi "Consulta elegibilidad por categoría y zona" "HTTPS / JSON"
        dispatchApp -> rulesApi "Pide el orden del listado de aliados" "HTTPS / JSON"

        gateway -> coreApi "Enruta"
        coreApi -> coreUsers "Invoca"
        coreApi -> coreKyc "Invoca"
        coreApi -> coreCatalog "Invoca"
        coreApi -> coreAvailability "Invoca"
        coreApi -> coreNotif "Invoca"
        coreApi -> coreReport "Invoca"
        coreKyc -> coreAdapters "Usa para Storage"
        coreNotif -> coreAdapters "Usa para push y Realtime"
        coreUsers -> corePort "Persiste"
        coreKyc -> corePort "Persiste"
        coreCatalog -> corePort "Persiste"
        coreAvailability -> corePort "Persiste y consulta"
        coreNotif -> corePort "Persiste"
        coreReport -> corePort "Consulta"
        corePort -> dbCore "Lee y escribe" "SQL"
        coreAdapters -> storage "Lee y escribe documentos KYC"
        coreAdapters -> realtime "Publica eventos"
        coreAdapters -> push "Envía notificaciones"
        coreUsers -> auth "Integra identidad"
        coreApi -> rulesApi "Valida la cotización contra el tarifario de referencia" "HTTPS / JSON"

        // ---------- Llamadas entre servicios ----------
        //
        // Dispatch -> Core y Core -> Rules se declaran una sola vez,
        // entre componentes (arriba). Structurizr las propaga solas al nivel de contenedor:
        // declararlas también aquí es una relación duplicada y el modelo no valida.
        // Las vistas dinámicas de nivel 2 referencian esas relaciones derivadas.

        // ---------- Despliegue de producción (SDD §9.1, §10 y §11) ----------
        //
        // Se modela un solo ambiente. Local, DEV y TEST/QA comparten esta topología y cambian
        // únicamente escalado, secretos y datos (SDD §10): un nodo por ambiente repetiría la
        // misma información sin añadir ninguna decisión arquitectónica.
        //
        // La vista muestra además de dónde sale lo que se ejecuta —el pipeline promueve la
        // misma imagen validada— y quién lo vigila, porque ambas cosas son parte del despliegue
        // y no de la estructura lógica.

        produccion = deploymentEnvironment "PROD" {

            internet = deploymentNode "Internet" "Acceso de usuarios web y móvil." {
                dispositivo = deploymentNode "Dispositivo del usuario" "" "Navegador / app móvil" {
                    flutterProd = containerInstance flutter
                }
            }

            borde = deploymentNode "Borde — DNS, TLS y balanceo" "Resolución de nombres, terminación TLS y reparto del tráfico externo." {
                dns = infrastructureNode "DNS" "Resuelve el nombre público de la plataforma hacia el balanceador." "DNS"
                balanceador = infrastructureNode "Balanceador" "Reparte el tráfico HTTPS entre las réplicas del Gateway. TLS 1.3 obligatorio (INFRA §7)." "Balanceador de carga"

                nodoGateway = deploymentNode "NGINX Ingress / API Gateway" "Entrada única: enrutamiento, control de acceso, validación del token y rate limiting." "NGINX" 2 {
                    gatewayProd = containerInstance gateway
                }

                dns -> balanceador "Resuelve el nombre público"
                balanceador -> gatewayProd "Reparte el tráfico entrante" "HTTPS"
            }

            cluster = deploymentNode "Clúster Kubernetes — producción" "Orquestador requerido por el proyecto (PROY-08). Proveedor y topología pendientes: INFRA-01 e INFRA-02." "Kubernetes" {

                namespaceServicios = deploymentNode "Namespace de servicios" "Contenedores inmutables, readiness y liveness probes, requests/limits y HPA para servicios sensibles a carga." "" {

                    deploymentNode "Rules Service — decide" "Motor de reglas. Mínimo 2 réplicas; HPA hasta 6." "Pod — Java" 2 {
                        rulesProd = containerInstance rules
                    }
                    deploymentNode "Dispatch Service — asigna" "Despacho y exclusión concurrente. Mínimo 2 réplicas; HPA hasta 6. La garantía de no doble asignación es de la base, no del número de réplicas." "Pod — .NET" 2 {
                        dispatchProd = containerInstance dispatch
                    }
                    deploymentNode "Core Services — opera" "Núcleo funcional de la plataforma. Mínimo 2 réplicas; HPA hasta 6." "Pod — Node.js" 2 {
                        coreProd = containerInstance core
                    }
                }

                gitops = infrastructureNode "Despliegue del clúster" "Punto de entrada del despliegue: recibe la imagen promovida y actualiza los Deployments. kubectl o GitOps según INFRA-02." "kubectl / GitOps"
                secretos = infrastructureNode "Secrets del clúster" "Credenciales y configuración viven fuera de la imagen: el pipeline los crea, no se hornean en el contenedor ni se versionan en Git (INFRA §8). service_role solo se monta en Core." "Kubernetes Secret"

                // Una relación por pod: apuntar al namespace —que es un nodo con hijos— rompe
                // el autolayout. Ver la regla al inicio del archivo.
                secretos -> rulesProd "Inyecta credenciales en el arranque"
                secretos -> dispatchProd "Inyecta credenciales en el arranque"
                secretos -> coreProd "Inyecta credenciales en el arranque"
            }

            plataformaDatos = deploymentNode "Supabase — proyecto productivo" "Plataforma administrada. Bases no accesibles desde Internet pública salvo controles explícitos; acceso administrativo con privilegio mínimo." "Supabase" {

                deploymentNode "PostgreSQL — reglas" "Datos del motor de reglas. RLS por tenant." "PostgreSQL + RLS" {
                    containerInstance dbRules
                }
                deploymentNode "PostgreSQL — despacho" "Datos de asignación y auditoría. RLS por tenant." "PostgreSQL + RLS" {
                    containerInstance dbDispatch
                }
                deploymentNode "PostgreSQL — core" "Datos funcionales de la plataforma, disponibilidad incluida. RLS por tenant." "PostgreSQL + RLS" {
                    containerInstance dbCore
                }
                deploymentNode "Auth" "Emisión y validación del JWT del que se obtiene el tenant_id." "Supabase Auth" {
                    containerInstance auth
                }
                deploymentNode "Storage" "Bucket privado de documentos KYC y multimedia." "Supabase Storage" {
                    containerInstance storage
                }
                deploymentNode "Realtime" "Transporte de eventos de mensajería." "Supabase Realtime" {
                    containerInstance realtime
                }
            }

            cicd = deploymentNode "GitHub Actions — CI/CD" "De dónde sale lo que corre en el clúster." "GitHub Actions" {
                pipeline = infrastructureNode "Pipeline de calidad y seguridad" "Pruebas unitarias, de integración y de contrato, SonarQube (SAST), build, escaneo de dependencias e imagen, Newman y OWASP ZAP. Un artefacto que no pasa los gates no se reconstruye para producción." "GitHub Actions"
                registro = infrastructureNode "Registro de imágenes" "Imágenes inmutables versionadas. A producción se promueve exactamente la imagen ya verificada en TEST/QA (SDD §11)." "Container registry"

                pipeline -> registro "Publica la imagen validada"
            }

            registro -> gitops "Entrega la imagen promovida; el clúster la descarga con imagePullSecret" "kubectl / GitOps"
            pipeline -> secretos "Crea los Secret del clúster desde GitHub Environments; nunca viven en Git (INFRA §8)"

            observabilidadProd = deploymentNode "Plataforma de observabilidad" "Supervisa disponibilidad, tiempos de respuesta, errores y consumo de recursos." "" {
                prometheus = infrastructureNode "Prometheus" "Recolecta métricas del Gateway y de los servicios." "Prometheus"
                grafana = infrastructureNode "Grafana" "Dashboards y alertas sobre las métricas recolectadas." "Grafana"

                prometheus -> grafana "Alimenta dashboards y alertas"
            }

            // Igual que con los secretos: el scrape se declara contra cada instancia, no contra
            // el namespace ni contra el nodo del Gateway.
            prometheus -> gatewayProd "Recolecta métricas" "HTTP /metrics"
            prometheus -> rulesProd "Recolecta métricas" "HTTP /metrics"
            prometheus -> dispatchProd "Recolecta métricas" "HTTP /metrics"
            prometheus -> coreProd "Recolecta métricas" "HTTP /metrics"

            analitica = deploymentNode "Plataforma analítica" "Desacoplada del OLTP; no participa en transacciones operacionales." "" {
                deploymentNode "Proceso CDC / ELT" "Carga incremental hacia el Data Warehouse." "" {
                    containerInstance etl
                }
            }
        }
    }

    views {

        // ---------- Vista 1 — System Landscape: panorama ----------
        //
        // Responde a una pregunta distinta de la de contexto: no "qué rodea a MANI", sino qué
        // sistemas existen en el mapa y a cuáles toca cada actor. MANI es el único sistema
        // propio; los demás son proveedores o plataformas de destino. Fuente: SAD §5, SRS §2.3.
        systemLandscape "panorama" "Panorama de sistemas: MANI, los actores que lo usan y las plataformas externas de las que depende. Fuente: SAD §5, SRS §2.3." {
            include *
            autolayout lr
        }

        // ---------- Vista 2 — C4 Nivel 1: Contexto ----------
        systemContext mani "contexto" "C4 Nivel 1 — MANI, sus actores y los sistemas externos. Fuente: SAD §5, SDD §4.1." {
            include *
            autolayout lr
        }

        // ---------- Vista 3 — C4 Nivel 2: Contenedores ----------
        container mani "contenedores" "C4 Nivel 2 — unidades desplegables y almacenes. Toda API operacional entra por el Gateway. Fuente: SAD §6, SDD §4.2." {
            include *
            autolayout lr
        }

        // ---------- Vista 4 — C4 Nivel 3: Componentes, uno por servicio ----------
        component rules "componentes-rules" "C4 Nivel 3 — Rules Service (Java). Fuente: SDD §4.3.1." {
            include *
            autolayout lr
        }

        component dispatch "componentes-dispatch" "C4 Nivel 3 — Dispatch Service (.NET). La exclusión concurrente vive en Concurrency Guard. Fuente: SDD §4.3.2." {
            include *
            autolayout lr
        }

        component core "componentes-core" "C4 Nivel 3 — Core Services (Node.js), disponibilidad incluida. Fuente: SDD §4.3.3." {
            include *
            autolayout lr
        }

        // ---------- Vista 5 — Dinámicas: los flujos que la estructura no explica ----------
        //
        // Las vistas estáticas muestran qué existe; estas muestran el orden en que ocurre.
        // Cada paso corresponde a una relación ya declarada en el modelo: una vista dinámica
        // no puede inventar colaboraciones que la estructura no permita.

        dynamic mani "dinamico-solicitud" "Solicitud y conformación del listado de aliados (RF-12, RF-13). Core crea la solicitud; Dispatch orquesta: pide elegibilidad a Core, el orden a Reglas y le pide a Core una oferta por aliado. Fuente: SAD §7.4 (decisión 6A), SECUENCIAS §1." {
            cliente -> flutter "Registra la solicitud de servicio"
            flutter -> gateway "POST de la solicitud con el JWT del tenant y la clave de idempotencia"
            gateway -> core "Enruta tras validar el token"
            core -> dbCore "Persiste la solicitud PENDIENTE (409K si la clave se usó con otros datos)"
            gateway -> dispatch "Orquesta el reparto de la solicitud creada"
            dispatch -> dbDispatch "Lee qué aliados la rechazaron"
            dispatch -> core "Pide los aliados elegibles por categoría y zona, sin los que rechazaron (RF-12)"
            dispatch -> rules "Pide el orden del listado según la regla del tenant (RF-13)"
            dispatch -> core "Pide una oferta por aliado elegible; Core la guarda una sola vez"
            properties {
                "plantuml.sequenceDiagram" "true"
            }
        }

        dynamic mani "dinamico-aceptacion" "Exclusión concurrente en la aceptación (RF-14, RNF-05), decisión 6A. Dispatch decide quién acepta y Core escribe: con dos aliados a la vez, el UPDATE condicional sobre la fila bloqueada deja pasar la primera y la segunda recibe 409 Conflict. Fuente: SAD §7.4, ADR-0016, ADR-0035 (propuesto)." {
            gateway -> dispatch "Aceptación del aliado, con clave de idempotencia (RNF-03)"
            dispatch -> core "Comprueba que el aliado esté verificado"
            dispatch -> dbDispatch "Comprueba que el aliado no la haya rechazado (409R)"
            dispatch -> core "Comando interno de asignación con el JWT del aliado"
            core -> dbCore "UPDATE condicional sobre la fila bloqueada; la segunda aceptación recibe 409 sin el ganador"
            properties {
                "plantuml.sequenceDiagram" "true"
            }
        }

        dynamic mani "dinamico-cotizacion" "Cotización del aliado y alerta contra el tarifario de referencia (RF-15, RF-16, RF-22). Core es dueño de la cotización; Reglas es dueño del tarifario. Fuente: SAD §7.1 y §7.3." {
            aliado -> flutter "Elabora la cotización separando mano de obra y materiales (RF-15)"
            flutter -> gateway "Envía la cotización"
            gateway -> core "Enruta tras validar el token"
            core -> rules "Pide validar el valor contra el rango del tarifario (RF-16)"
            rules -> dbRules "Lee los rangos mínimo, típico y máximo del tenant (RF-22)"
            core -> dbCore "Persiste la cotización con el resultado de la validación"
            properties {
                "plantuml.sequenceDiagram" "true"
            }
        }

        dynamic mani "dinamico-kyc" "Carga y verificación de documentos KYC (RF-05, RF-06). Los documentos viven en bucket privado bajo tenant_id/aliado_id/documento; la aprobación es del administrador del tenant. Fuente: ADR-0013, SAD §7.3." {
            aliado -> flutter "Carga los documentos requeridos por el tenant"
            flutter -> gateway "Envía los documentos"
            gateway -> core "Enruta tras validar el token"
            core -> rules "Consulta qué documentos exige este tenant (RF-02, RNF-10). DISEÑO: la configuración de requisitos KYC no está implementada"
            core -> storage "Guarda el documento en el bucket privado, aislado por tenant y aliado"
            core -> dbCore "Registra el documento y deja al aliado en verificación"
            adminTenant -> flutter "Revisa la documentación y aprueba o rechaza al aliado (RF-06)"
            properties {
                "plantuml.sequenceDiagram" "true"
            }
        }

        dynamic mani "dinamico-mensajeria" "Mensajería del servicio con notificación de respaldo (RF-20, RF-21). Realtime transporta mientras el destinatario está conectado; si no lo está, se entrega por push. Fuente: ADR-0017, SAD §7.3." {
            cliente -> flutter "Escribe un mensaje asociado al servicio"
            flutter -> gateway "Envía el mensaje"
            gateway -> core "Enruta tras validar el token"
            core -> dbCore "Persiste el mensaje: la conversación no vive solo en el transporte"
            core -> realtime "Publica el evento de mensajería"
            flutter -> realtime "El destinatario conectado lo recibe casi en tiempo real"
            core -> push "Si el destinatario no está conectado, lo notifica por push (RF-21)"
            properties {
                "plantuml.sequenceDiagram" "true"
            }
        }

        // ---------- Vista 6 — Despliegue ----------
        deployment mani "PROD" "despliegue-prod" "Vista de despliegue de producción: borde con DNS y balanceo, clúster Kubernetes con réplicas y Secrets creados por el pipeline, Supabase por dominio, el pipeline que promueve la imagen y la observabilidad que la vigila. Fuente: SDD §9.1, §10 y §11." {
            include *
            autolayout tb 400 400
        }

        styles {
            element "Person" {
                shape person
                background #0b5394
                color #ffffff
            }
            element "Software System" {
                background #1155cc
                color #ffffff
            }
            element "Externo" {
                background #6c757d
                color #ffffff
            }
            element "Container" {
                background #3d85c6
                color #ffffff
            }
            element "Database" {
                shape cylinder
            }
            element "Diferido" {
                background #ffffff
                color #6c757d
                stroke #6c757d
                border dashed
            }
            element "Component" {
                background #6fa8dc
                color #000000
            }
            element "Deployment Node" {
                background #ffffff
                color #000000
            }
            element "Infrastructure Node" {
                background #e8eef7
                color #000000
            }
        }
    }
}

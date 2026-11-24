/*
 * MANI — Modelo C4 en Structurizr DSL
 *
 * Fuente de los diagramas C4 del proyecto: el SDD documenta cada vista (§4 y §9).
 *
 * Vistas: panorama · contexto · contenedores · componentes-rules · componentes-dispatch ·
 * componentes-core · dinamico-solicitud · dinamico-aceptacion · dinamico-cotizacion ·
 * dinamico-kyc · dinamico-mensajeria · despliegue-prod.
 *
 * El modelo es deliberadamente simple: cada vista muestra solo lo que explica y las
 * descripciones y etiquetas son cortas. El detalle vive en el SAD, el SDD y ModeloDatos.
 * El nivel 4 (código) no se modela aquí: está en diagrams/c4/codigo/.
 */

workspace "MANI" "Plataforma SaaS multi-tenant de formalización de operaciones de servicio" {

    model {

        // ---------- Actores ----------
        cliente = person "Cliente" "Solicita servicios y los aprueba."
        aliado = person "Aliado" "Cotiza, acepta y ejecuta servicios."
        admin = person "Administrador" "Administra su tenant o la plataforma."
        visitante = person "Visitante" "Conoce los servicios antes de registrarse."

        // ---------- Sistemas externos ----------
        push = softwareSystem "FCM / APNs" "Notificaciones push." "Externo"
        pagos = softwareSystem "Operador de pagos" "Cobros y liquidaciones." "Externo"
        dwh = softwareSystem "Data Warehouse / BI" "Analítica fuera del OLTP." "Externo"
        observabilidad = softwareSystem "Observabilidad" "Métricas, tableros, alertas y logs." "Externo"

        // ---------- MANI ----------
        mani = softwareSystem "MANI" "Gestiona el ciclo solicitud, cotización, ejecución, calificación y cierre." {

            landing = container "Landing" "Página pública con catálogo y estimador de precio." "React + NGINX"
            flutter = container "Aplicación cliente" "Interfaz web y móvil." "Flutter"
            gateway = container "API Gateway" "Entrada única: TLS, validación del token y enrutamiento." "NGINX"

            rules = container "Rules Service" "Decide: reglas por tenant, ranking y tarifa." "Java" {
                rulesApi = component "Rules API" "Expone la evaluación." "Java"
                rulesApp = component "Application Service" "Orquesta la evaluación." "Java"
                rulesFactory = component "Strategy Factory" "Elige la estrategia por tipo de regla." "Java"
                rulesRanking = component "Ranking" "Ordena aliados." "Java"
                rulesTariff = component "Tariff Validation" "Valida contra la tarifa." "Java"
                rulesKyc = component "KYC Policy" "Documentos requeridos." "Java"
                rulesPort = component "Rule Repository" "Puerto de reglas." "Interfaz"
                rulesAdapter = component "Adapter" "Implementa el puerto." "Java"
            }

            dispatch = container "Dispatch Service" "Asigna: ofertas, aceptación y exclusión concurrente." ".NET" {
                dispatchApi = component "Dispatch API" "Orquestación y aceptación." ".NET"
                dispatchApp = component "Application Service" "Casos de uso de despacho." ".NET"
                dispatchSelector = component "Candidate Selector" "Obtiene candidatos." ".NET"
                dispatchCoordinator = component "Assignment Coordinator" "Coordina la asignación." ".NET"
                dispatchGuard = component "Concurrency Guard" "Entrega a Core el comando de asignación." ".NET"
                dispatchAudit = component "Audit" "Audita el despacho." ".NET"
                dispatchPort = component "Dispatch Repository" "Puerto de rechazos." "Interfaz"
                dispatchAdapter = component "PostgreSQL Adapter" "Implementa el puerto." ".NET"
            }

            core = container "Core Service" "Opera: identidad, aliados, solicitud, cotización, ejecución y mensajería." "Node.js" {
                coreApi = component "Core API" "Expone los casos de uso." "Node.js"
                coreUsers = component "Identidad" "Tenants, usuarios y roles." "Node.js"
                coreKyc = component "KYC" "Registro y verificación de aliados." "Node.js"
                coreCatalog = component "Catálogo" "Categorías, clientes y sitios." "Node.js"
                coreAvailability = component "Disponibilidad" "Cobertura y elegibilidad." "Node.js"
                coreService = component "Ciclo del servicio" "Solicitud, cotización y ejecución." "Node.js"
                coreNotif = component "Mensajería" "Mensajes y notificaciones." "Node.js"
                coreAdapters = component "Adaptadores externos" "Storage, push y pagos." "Node.js"
                corePort = component "Repositorios" "Persistencia de los dominios." "Interfaces"
            }

            bus = container "Bus de eventos" "Eventos de negocio, producidos por Core." "Kafka"

            db = container "PostgreSQL" "Datos con RLS por tenant." "Supabase" "Database"
            auth = container "Auth" "Identidad y emisión del JWT." "Supabase"
            storage = container "Storage" "Documentos KYC y fotos." "Supabase"
            realtime = container "Realtime" "Mensajes en vivo." "Supabase"
        }

        // ---------- Contexto ----------
        cliente -> mani "Usa"
        aliado -> mani "Usa"
        admin -> mani "Usa"
        mani -> push "Notifica"
        mani -> pagos "Cobra"
        mani -> dwh "Entrega datos"
        mani -> observabilidad "Emite métricas y logs"

        // ---------- Contenedores ----------
        visitante -> landing ""
        landing -> flutter "Redirige al login"
        cliente -> flutter ""
        aliado -> flutter ""
        admin -> flutter ""

        flutter -> gateway ""
        flutter -> auth "Inicia sesión"
        flutter -> realtime ""

        gateway -> rules ""
        gateway -> dispatch ""
        gateway -> core ""

        dispatch -> core "Elegibilidad y asignación"
        dispatch -> rules "Orden del listado"
        core -> rules "Valida tarifa"

        core -> db ""
        dispatch -> db ""
        core -> storage ""
        core -> realtime ""
        core -> bus ""
        core -> push ""
        core -> pagos ""
        db -> dwh "CDC / ELT"

        // ---------- Componentes: Rules ----------
        gateway -> rulesApi ""
        rulesApi -> rulesApp ""
        rulesApp -> rulesFactory ""
        rulesFactory -> rulesRanking ""
        rulesFactory -> rulesTariff ""
        rulesFactory -> rulesKyc ""
        rulesApp -> rulesPort ""
        rulesPort -> rulesAdapter ""

        // ---------- Componentes: Dispatch ----------
        gateway -> dispatchApi ""
        dispatchApi -> dispatchApp ""
        dispatchApp -> dispatchSelector "Candidatos"
        dispatchApp -> dispatchCoordinator "Asigna"
        dispatchCoordinator -> dispatchGuard ""
        dispatchApp -> dispatchAudit ""
        dispatchApp -> dispatchPort ""
        dispatchPort -> dispatchAdapter ""
        dispatchAdapter -> db "Rechazos"
        dispatchSelector -> core "Elegibilidad"
        dispatchGuard -> core "Asignación"
        dispatchApp -> rules "Orden del listado"

        // ---------- Componentes: Core ----------
        gateway -> coreApi ""
        coreApi -> coreUsers ""
        coreApi -> coreKyc ""
        coreApi -> coreCatalog ""
        coreApi -> coreAvailability ""
        coreApi -> coreService ""
        coreApi -> coreNotif ""
        coreUsers -> corePort ""
        coreKyc -> corePort ""
        coreCatalog -> corePort ""
        coreAvailability -> corePort ""
        coreService -> corePort ""
        coreNotif -> corePort ""
        corePort -> db "Lee y escribe"
        coreKyc -> coreAdapters "Storage"
        coreNotif -> coreAdapters "Push"
        coreAdapters -> storage "Documentos"
        coreAdapters -> push "Notifica"
        coreService -> rules "Valida tarifa"

        // ---------- Despliegue ----------
        produccion = deploymentEnvironment "PROD" {

            dispositivo = deploymentNode "Dispositivo del usuario" "Navegador o app móvil" {
                flutterProd = containerInstance flutter
            }

            borde = deploymentNode "Borde" "DNS, TLS y balanceo" {
                gatewayProd = containerInstance gateway
            }

            servidores = deploymentNode "Servicios" "Docker Compose hoy; Kubernetes es el objetivo" {
                rulesProd = containerInstance rules
                dispatchProd = containerInstance dispatch
                coreProd = containerInstance core
                busProd = containerInstance bus
                orquestador = infrastructureNode "Orquestador" "Recibe la imagen validada y la despliega." "Compose / Kubernetes"
            }

            supabase = deploymentNode "Supabase" "Plataforma administrada" {
                dbProd = containerInstance db
                authProd = containerInstance auth
                storageProd = containerInstance storage
                realtimeProd = containerInstance realtime
            }

            cicd = deploymentNode "CI/CD" "GitHub Actions y GHCR" {
                pipeline = infrastructureNode "Pipeline" "Pruebas, análisis, build y registro de imágenes." "GitHub Actions"
            }

            obs = deploymentNode "Observabilidad" "Vigila los tres ambientes" {
                stack = infrastructureNode "Prometheus, Grafana y Loki" "Métricas, tableros, alertas y logs." "Grafana"
            }

            pipeline -> orquestador "Publica la imagen"
            stack -> orquestador "Recolecta"
        }
    }

    views {

        systemLandscape "panorama" "Panorama: MANI, sus usuarios y los sistemas externos." {
            include *
            autolayout lr 300 200
        }

        systemContext mani "contexto" "Contexto: quién usa MANI y de qué depende." {
            include *
            autolayout lr 300 200
        }

        container mani "contenedores" "Contenedores de MANI." {
            include *
            exclude observabilidad
            exclude "visitante"
            exclude flutter->realtime
            autolayout tb 150 120
        }

        component rules "componentes-rules" "Componentes del Rules Service." {
            include *
            autolayout lr 200 100
        }

        component dispatch "componentes-dispatch" "Componentes del Dispatch Service." {
            include *
            autolayout lr 200 100
        }

        component core "componentes-core" "Componentes del Core Service." {
            include *
            autolayout lr 200 100
        }

        dynamic mani "dinamico-solicitud" "Solicitud y listado de aliados. Core crea la solicitud; Dispatch orquesta el reparto." {
            cliente -> flutter "Registra la solicitud"
            flutter -> gateway "POST con JWT e idempotencia"
            gateway -> core "Enruta"
            core -> db "Guarda la solicitud PENDIENTE"
            gateway -> dispatch "Orquesta el reparto"
            dispatch -> core "Pide aliados elegibles"
            dispatch -> rules "Pide el orden del listado"
            dispatch -> core "Pide una oferta por aliado"
            properties {
                "plantuml.sequenceDiagram" "true"
            }
        }

        dynamic mani "dinamico-aceptacion" "Aceptación concurrente. Dispatch decide, Core escribe; la segunda aceptación recibe 409." {
            gateway -> dispatch "Aceptación del aliado"
            dispatch -> core "Verifica al aliado"
            dispatch -> db "Revisa rechazos previos"
            dispatch -> core "Comando de asignación"
            core -> db "UPDATE condicional; el segundo recibe 409"
            properties {
                "plantuml.sequenceDiagram" "true"
            }
        }

        dynamic mani "dinamico-cotizacion" "Cotización y alerta contra la tarifa de referencia." {
            aliado -> flutter "Elabora la cotización"
            flutter -> gateway "Envía la cotización"
            gateway -> core "Enruta"
            core -> rules "Valida contra la tarifa"
            core -> db "Guarda la cotización y el resultado"
            properties {
                "plantuml.sequenceDiagram" "true"
            }
        }

        dynamic mani "dinamico-kyc" "Carga y verificación de documentos KYC." {
            aliado -> flutter "Carga los documentos"
            flutter -> gateway "Envía los documentos"
            gateway -> core "Enruta"
            core -> storage "Guarda en bucket privado"
            core -> db "Registra el documento"
            admin -> flutter "Aprueba o rechaza al aliado"
            properties {
                "plantuml.sequenceDiagram" "true"
            }
        }

        dynamic mani "dinamico-mensajeria" "Mensajería con notificación de respaldo." {
            cliente -> flutter "Escribe un mensaje"
            flutter -> gateway "Envía el mensaje"
            gateway -> core "Enruta"
            core -> db "Guarda el mensaje"
            core -> realtime "Publica el evento"
            flutter -> realtime "El destinatario conectado lo recibe"
            core -> push "Si no está conectado, push"
            properties {
                "plantuml.sequenceDiagram" "true"
            }
        }

        deployment mani "PROD" "despliegue-prod" "Despliegue de producción." {
            include *
            autolayout lr 250 150
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

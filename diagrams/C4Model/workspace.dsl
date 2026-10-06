/*
 * MANI — Modelo C4 en Structurizr DSL
 *
 * Fuente del modelo: SAD.md (§5 contexto, §6 contenedores, §7 responsabilidad de servicios,
 * §8 multi-tenancy, §15 analítica) y SDD.md (§4 vistas C4, §9 despliegue, §10 ambientes).
 *
 * Este archivo es la fuente de los diagramas C4 del proyecto. El SDD referencia sus vistas.
 * Los diagramas de alto nivel (DHL) e infraestructura ilustrativa viven en diagrams/ALTO_NIVEL/
 * y los referencia el SAD.
 *
 * Vistas definidas:
 *   1. contexto      — C4 Nivel 1, System Context
 *   2. contenedores  — C4 Nivel 2, Containers
 *   3. componentes   — C4 Nivel 3, un diagrama por servicio de negocio
 *   4. despliegue    — Vista de despliegue de producción
 *
 * El Nivel 4 (Code) no se modela aquí: Structurizr no describe clases. Se mantiene en SDD §4.4.
 *
 * Decisiones abiertas que este modelo NO fija: proveedor y topología del clúster Kubernetes
 * (INFRA-01 e INFRA-02 de INFRAESTRUCTURA_MANI.md §25). Los nodos de despliegue se nombran
 * sin proveedor deliberadamente.
 */

workspace "MANI" "Plataforma SaaS multi-tenant de formalización y gestión de operaciones de servicio — TRAMA · Ingeniería de Software" {

    model {

        // ---------- Actores (SRS §2.3) ----------

        cliente = person "Cliente" "Solicita servicios, gestiona cotizaciones, participa en mensajería y califica al aliado."
        aliado = person "Aliado" "Presta el servicio: carga KYC, declara categorías y cobertura, acepta, cotiza, ejecuta y califica."
        adminTenant = person "Administrador de tenant" "Configura reglas, categorías, tarifarios y documentos requeridos; aprueba o rechaza aliados."
        adminPlataforma = person "Administrador de plataforma" "Registra tenants y administra su estado."

        // ---------- Sistemas externos (SRS §5, SAD §5) ----------

        push = softwareSystem "FCM / APNs" "Entrega notificaciones push cuando el destinatario no está conectado." "Externo"
        pagos = softwareSystem "Operador de pagos certificado" "Procesa cobros y liquidaciones. Segundo incremento. El cumplimiento PCI DSS recae en el operador (RNF-06)." "Externo"
        observabilidad = softwareSystem "Plataforma de observabilidad" "Prometheus, Grafana y Datadog: métricas, dashboards, logs, trazas y alertas." "Externo"
        dwh = softwareSystem "Data Warehouse / BI" "Analítica desacoplada del OLTP. Recibe datos por CDC/ELT y no escribe en operacional." "Externo"

        // ---------- Sistema MANI ----------

        mani = softwareSystem "MANI" "Formaliza el ciclo Solicitud → Cotización → Ejecución → Calificación → Cierre con aislamiento estricto por tenant." {

            flutter = container "Aplicación cliente" "Presentación y lógica de interacción. No contiene reglas de negocio centrales (SAD §4.1)." "Flutter / Dart — Web y móvil"

            gateway = container "API Gateway" "Entrada única de toda API operacional. Routing, TLS y políticas transversales; valida el token. No implementa reglas de dominio." "NGINX"

            rules = container "Rules Service" "Reglas configurables por tenant, ranking de aliados y validación contra tarifario (RF-02, RF-13, RF-16, RF-22). Lee la configuración de persistencia, no del código." "Java" {
                rulesApi = component "Rules REST Controller" "Expone la evaluación de reglas y el ranking." "Java"
                rulesApp = component "Rules Application Service" "Orquesta evaluación y ranking." "Java"
                rulesFactory = component "Rule Strategy Factory" "Resuelve la estrategia según el tipo de regla." "Java"
                rulesRanking = component "Ranking Strategy" "Ordena aliados según la regla del tenant (RF-13)." "Java"
                rulesTariff = component "Tariff Validation Strategy" "Valida la cotización contra el tarifario de referencia (RF-16, RF-22)." "Java"
                rulesKyc = component "KYC Policy Strategy" "Evalúa los documentos requeridos por el tenant." "Java"
                rulesPort = component "Rule Repository Port" "Contrato de acceso a reglas." "Java — interfaz"
                rulesAdapter = component "Supabase Adapter" "Implementa el puerto contra PostgreSQL." "Java"
            }

            dispatch = container "Dispatch Service" "Coordinación operacional de solicitudes, aceptación/rechazo, idempotencia y exclusión concurrente (RF-12, RF-14, RNF-03, RNF-05)." ".NET" {
                dispatchApi = component "Dispatch API" "Expone creación de solicitud y aceptación/rechazo." ".NET"
                dispatchApp = component "Dispatch Application Service" "Casos de uso de despacho." ".NET"
                dispatchSelector = component "Candidate Selector" "Obtiene candidatos válidos para la solicitud." ".NET"
                dispatchCoordinator = component "Assignment Coordinator" "Coordina la asignación de la solicitud." ".NET"
                dispatchGuard = component "Concurrency Guard" "Actualización condicional atómica: la primera aceptación válida gana; las siguientes reciben 409 Conflict." ".NET"
                dispatchAudit = component "Audit Component" "Audita cambios de estado del despacho (RNF-04)." ".NET"
                dispatchPort = component "Dispatch Repository Port" "Contrato de persistencia del despacho." ".NET — interfaz"
                dispatchAdapter = component "PostgreSQL Adapter" "Implementa el puerto contra PostgreSQL." ".NET"
            }

            core = container "Core Services" "Tenants, identidad, aliados y KYC, clientes y sitios, categorías, cotización, ejecución, calificación, comunicación y reportes. Puede dividirse internamente por dominios sin convertir cada CRUD en un servicio (SAD §7.3)." "Node.js" {
                coreApi = component "Core API" "Expone los casos de uso de los dominios de Core." "Node.js"
                coreUsers = component "Users / Tenants Component" "Tenants, usuarios, roles y acceso (RF-01, RF-03, RF-04)." "Node.js"
                coreKyc = component "KYC Orchestrator" "Registro y verificación de aliados y documentos (RF-05, RF-06)." "Node.js"
                coreCatalog = component "Catalog Component" "Categorías, clientes, sitios y asociaciones (RF-08..RF-11)." "Node.js"
                coreNotif = component "Notification Component" "Mensajería del servicio y notificaciones (RF-20, RF-21)." "Node.js"
                coreReport = component "Operational Reporting" "Reportes operativos y de tarifario (RF-23)." "Node.js"
                coreAdapters = component "External Adapters" "Encapsula proveedores externos: push, Storage, pagos." "Node.js"
                corePort = component "Repositories" "Contratos de persistencia de los dominios de Core." "Node.js — interfaces"
            }

            availability = container "Availability Service" "Cobertura del aliado, disponibilidad, horarios, zonas y elegibilidad por categoría y zona (RF-07, RF-12, RNF-07)." "Node.js" {
                availApi = component "Availability API" "Expone consulta de cobertura y elegibilidad." "Node.js"
                availApp = component "Availability Application Service" "Casos de uso de disponibilidad." "Node.js"
                availSchedule = component "Schedule Rules" "Horarios y solapamientos. La lógica pertenece al servicio, no al cliente." "Node.js"
                availQuery = component "Availability Query" "Elegibilidad por categoría y coincidencia exacta de zona (REST-01)." "Node.js"
                availPort = component "Availability Repository" "Contrato de persistencia de disponibilidad." "Node.js — interfaz"
            }

            auth = container "Supabase Auth" "Autenticación de usuarios y emisión del JWT firmado del que se obtiene el tenant_id (ADR-0018)." "Supabase"
            db = container "PostgreSQL" "Persistencia operacional separada por esquemas de dominio, con Row-Level Security por tenant (ADR-0012)." "Supabase — PostgreSQL + RLS" "Database"
            storage = container "Supabase Storage" "Documentos KYC en bucket privado con la convención tenant_id/aliado_id/documento (ADR-0013)." "Supabase"
            realtime = container "Supabase Realtime" "Transporta eventos de mensajería mientras los participantes están conectados. No ejecuta reglas de negocio." "Supabase"
            etl = container "CDC / ELT" "Carga incremental del OLTP hacia el Data Warehouse. No participa en transacciones operacionales." "Proceso desacoplado"
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

        flutter -> gateway "Consume la API operacional" "HTTPS / JSON"
        flutter -> auth "Autentica y obtiene el JWT" "HTTPS"

        gateway -> rules "Enruta tras validar el token" "HTTPS / JSON"
        gateway -> dispatch "Enruta tras validar el token" "HTTPS / JSON"
        gateway -> core "Enruta tras validar el token" "HTTPS / JSON"
        gateway -> availability "Enruta tras validar el token" "HTTPS / JSON"

        core -> auth "Integra identidad y acceso"
        rules -> db "Lee reglas y tarifarios del tenant" "SQL"
        dispatch -> db "Persiste solicitudes, asignaciones y auditoría" "SQL"
        core -> db "Persiste tenants, aliados, clientes, catálogo, cotización y comunicación" "SQL"
        availability -> db "Lee y persiste cobertura y disponibilidad" "SQL"

        core -> storage "Almacena y sirve documentos KYC aislados por tenant y aliado"
        core -> realtime "Publica eventos de mensajería del servicio"
        core -> push "Envía notificaciones cuando el destinatario no está conectado"
        core -> pagos "Cobros y liquidaciones (2.º incremento)"

        flutter -> realtime "Recibe mensajes en tiempo real mientras está conectado"

        db -> etl "Entrega carga incremental"
        etl -> dwh "Alimenta el Data Warehouse"

        gateway -> observabilidad "Métricas, logs y trazas"
        rules -> observabilidad "Métricas, logs y trazas"
        dispatch -> observabilidad "Métricas, logs y trazas"
        core -> observabilidad "Métricas, logs y trazas"
        availability -> observabilidad "Métricas, logs y trazas"

        // ---------- Relaciones de componentes (SDD §4.3) ----------

        gateway -> rulesApi "Enruta"
        rulesApi -> rulesApp "Invoca"
        rulesApp -> rulesFactory "Resuelve la estrategia"
        rulesFactory -> rulesRanking "Instancia"
        rulesFactory -> rulesTariff "Instancia"
        rulesFactory -> rulesKyc "Instancia"
        rulesApp -> rulesPort "Consulta reglas del tenant"
        rulesPort -> rulesAdapter "Implementado por"
        rulesAdapter -> db "Lee" "SQL"

        gateway -> dispatchApi "Enruta"
        dispatchApi -> dispatchApp "Invoca"
        dispatchApp -> dispatchSelector "Obtiene candidatos"
        dispatchApp -> dispatchCoordinator "Coordina la asignación"
        dispatchCoordinator -> dispatchGuard "Delega la exclusión concurrente"
        dispatchApp -> dispatchAudit "Registra cambios de estado"
        dispatchApp -> dispatchPort "Persiste"
        dispatchPort -> dispatchAdapter "Implementado por"
        dispatchAdapter -> db "Lee y escribe" "SQL"
        dispatchSelector -> availApi "Consulta elegibilidad por categoría y zona" "HTTPS / JSON"
        dispatchApp -> rulesApi "Pide el orden del listado de aliados" "HTTPS / JSON"

        gateway -> coreApi "Enruta"
        coreApi -> coreUsers "Invoca"
        coreApi -> coreKyc "Invoca"
        coreApi -> coreCatalog "Invoca"
        coreApi -> coreNotif "Invoca"
        coreApi -> coreReport "Invoca"
        coreKyc -> coreAdapters "Usa para Storage"
        coreNotif -> coreAdapters "Usa para push y Realtime"
        coreUsers -> corePort "Persiste"
        coreKyc -> corePort "Persiste"
        coreCatalog -> corePort "Persiste"
        coreNotif -> corePort "Persiste"
        coreReport -> corePort "Consulta"
        corePort -> db "Lee y escribe" "SQL"
        coreAdapters -> storage "Lee y escribe documentos KYC"
        coreAdapters -> realtime "Publica eventos"
        coreAdapters -> push "Envía notificaciones"
        coreUsers -> auth "Integra identidad"

        gateway -> availApi "Enruta"
        availApi -> availApp "Invoca"
        availApp -> availSchedule "Evalúa horarios y solapamientos"
        availApp -> availQuery "Resuelve elegibilidad"
        availApp -> availPort "Persiste y consulta"
        availPort -> db "Lee y escribe" "SQL"

        // ---------- Despliegue (SDD §9.1 y §10) ----------

        produccion = deploymentEnvironment "PROD" {

            internet = deploymentNode "Internet" "Acceso de usuarios web y móvil." {
                deploymentNode "Dispositivo del usuario" "" "Navegador / app móvil" {
                    containerInstance flutter
                }
            }

            borde = deploymentNode "DNS + TLS" "Resolución y terminación TLS del tráfico externo." {
                deploymentNode "NGINX Ingress / API Gateway" "Entrada única de la plataforma." "NGINX" {
                    containerInstance gateway
                }
            }

            cluster = deploymentNode "Clúster Kubernetes — producción" "Orquestador requerido por el proyecto (PROY-08). Proveedor y topología pendientes: INFRA-01 e INFRA-02." "Kubernetes" {
                deploymentNode "Namespace de servicios" "Contenedores inmutables, readiness y liveness probes, requests/limits y HPA para servicios sensibles a carga." "" {
                    deploymentNode "Rules Service" "Mínimo 2 réplicas en producción." "Pod — 2..6 réplicas" {
                        containerInstance rules
                    }
                    deploymentNode "Dispatch Service" "Mínimo 2 réplicas en producción." "Pod — 2..6 réplicas" {
                        containerInstance dispatch
                    }
                    deploymentNode "Core Services" "Mínimo 2 réplicas en producción." "Pod — 2..6 réplicas" {
                        containerInstance core
                    }
                    deploymentNode "Availability Service" "Mínimo 2 réplicas en producción." "Pod — 2..6 réplicas" {
                        containerInstance availability
                    }
                }
            }

            plataformaDatos = deploymentNode "Supabase — proyecto productivo" "Plataforma administrada. Bases no accesibles desde Internet pública salvo controles explícitos; acceso administrativo con privilegio mínimo." "Supabase" {
                deploymentNode "PostgreSQL" "Esquemas por dominio con RLS por tenant." "PostgreSQL" {
                    containerInstance db
                }
                deploymentNode "Auth" "" "Supabase Auth" {
                    containerInstance auth
                }
                deploymentNode "Storage" "Bucket privado de documentos KYC." "Supabase Storage" {
                    containerInstance storage
                }
                deploymentNode "Realtime" "" "Supabase Realtime" {
                    containerInstance realtime
                }
            }

            analitica = deploymentNode "Plataforma analítica" "Desacoplada del OLTP; no participa en transacciones operacionales." "" {
                deploymentNode "Proceso CDC / ELT" "Carga incremental." "" {
                    containerInstance etl
                }
            }
        }
    }

    views {

        // ---------- Vista 1 — C4 Nivel 1: Contexto ----------
        systemContext mani "contexto" "C4 Nivel 1 — MANI, sus actores y los sistemas externos. Fuente: SAD §5, SDD §4.1." {
            include *
            autolayout lr
        }

        // ---------- Vista 2 — C4 Nivel 2: Contenedores ----------
        container mani "contenedores" "C4 Nivel 2 — unidades desplegables y almacenes. Toda API operacional entra por el Gateway. Fuente: SAD §6, SDD §4.2." {
            include *
            autolayout lr
        }

        // ---------- Vista 3 — C4 Nivel 3: Componentes, uno por servicio ----------
        component rules "componentes-rules" "C4 Nivel 3 — Rules Service (Java). Fuente: SDD §4.3.1." {
            include *
            autolayout lr
        }

        component dispatch "componentes-dispatch" "C4 Nivel 3 — Dispatch Service (.NET). La exclusión concurrente vive en Concurrency Guard. Fuente: SDD §4.3.2." {
            include *
            autolayout lr
        }

        component core "componentes-core" "C4 Nivel 3 — Core Services (Node.js). Fuente: SDD §4.3.3." {
            include *
            autolayout lr
        }

        component availability "componentes-availability" "C4 Nivel 3 — Availability Service (Node.js). Fuente: SDD §4.3.4." {
            include *
            autolayout lr
        }

        // ---------- Vista 4 — Despliegue ----------
        deployment mani "PROD" "despliegue-prod" "Vista de despliegue de producción. Fuente: SDD §9.1 y §10." {
            include *
            autolayout tb
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
        }
    }
}

/*
 * MANI — Modelo C4 en Structurizr DSL
 *
 * Fuente del modelo: SAD.md (§5 contexto, §6 contenedores, §7 responsabilidad de servicios,
 * §8 multi-tenancy, §15 analítica) y SDD.md (§4 vistas, §9 despliegue, §10 ambientes).
 *
 * Este archivo es la fuente de los diagramas del proyecto. El inventario completo de vistas,
 * con el archivo exportado que corresponde a cada una, está en SDD.md §4.0.
 *
 * Convención de carpetas:
 *   diagrams/HLD/           vistas de alto nivel (landscape, infraestructura, tech radar)
 *   diagrams/LLD/           este modelo
 *   diagrams/LLD/Software/  vistas exportadas desde este modelo
 *
 * Vistas definidas:
 *   1. landscape              System Landscape
 *   2. contexto               C4 Nivel 1, System Context
 *   3. contenedores           C4 Nivel 2, Containers
 *   4. componentes-rules      C4 Nivel 3, Rules Service
 *   5. componentes-dispatch   C4 Nivel 3, Dispatch Service
 *   6. componentes-core       C4 Nivel 3, Core Service — dominios de negocio
 *   7. componentes-availability  C4 Nivel 3, Core Service — módulo de disponibilidades
 *   8. secuencia-despacho     dinámica, RF-14 y RNF-05
 *   9. secuencia-cotizacion   dinámica, RF-15 a RF-17
 *  10. secuencia-mensajeria   dinámica, RF-20 y RF-21
 *  11. despliegue-qa          despliegue de QA
 *  12. despliegue-prod        despliegue de producción
 *
 * El Nivel 4 (Code) no se modela aquí: Structurizr no describe clases. Se mantiene en SDD §4.5.
 *
 * Tres servicios de negocio, no cuatro: las disponibilidades son un módulo del Core Service
 * (SAD §7.4, SDD §3.1), construido y desplegado desde MANI-Core-Service.
 *
 * Decisión abierta que este modelo NO fija: la plataforma de orquestación. Kubernetes es el
 * objetivo exigido por PROY-08, pero no es el estado actual (INFRA-01 e INFRA-02 de
 * INFRAESTRUCTURA_MANI.md §25). Los nodos de despliegue modelan lo que existe hoy: una máquina
 * virtual con Docker por ambiente.
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

            flutter = container "Aplicación cliente" "Presentación y lógica de interacción. No contiene reglas de negocio centrales (SAD §4.1). Alcanza Supabase solo por Auth y Realtime (SAD §8.3)." "Flutter / Dart — Web y móvil"

            gateway = container "API Gateway" "Entrada única de toda API operacional. Routing, TLS, rate limiting y políticas transversales; valida el token y propaga correlation_id. No implementa reglas de dominio." "NGINX"

            rules = container "Rules Service" "Reglas configurables por tenant, ranking de aliados y validación contra tarifario (RF-02, RF-13, RF-16, RF-22). Lee la configuración de persistencia, no del código. Emite el veredicto tarifario; no escribe la cotización." "Java" {
                rulesApi = component "Rules REST Controller" "Expone la evaluación de reglas y el ranking." "Java"
                rulesApp = component "Rules Application Service" "Orquesta evaluación y ranking." "Java"
                rulesFactory = component "Rule Strategy Factory" "Resuelve la estrategia según el tipo de regla." "Java"
                rulesRanking = component "Ranking Strategy" "Ordena aliados según la regla del tenant (RF-13)." "Java"
                rulesTariff = component "Tariff Validation Strategy" "Valida la cotización contra el tarifario de referencia (RF-16, RF-22)." "Java"
                rulesKyc = component "KYC Policy Strategy" "Evalúa los documentos requeridos por el tenant." "Java"
                rulesPort = component "Rule Repository Port" "Contrato de acceso a reglas y tarifario." "Java — interfaz"
                rulesAdapter = component "Supabase Adapter" "Implementa el puerto contra PostgreSQL." "Java"
            }

            dispatch = container "Dispatch Service" "Solicitudes, despacho, asignación, idempotencia y exclusión concurrente (RF-12, RF-14, RNF-03, RNF-05). Dueño del esquema despacho." ".NET" {
                dispatchApi = component "Dispatch API" "Expone creación de solicitud y aceptación/rechazo." ".NET"
                dispatchApp = component "Dispatch Application Service" "Casos de uso de despacho." ".NET"
                dispatchSelector = component "Candidate Selector" "Obtiene candidatos válidos consultando la API del Core Service." ".NET"
                dispatchCoordinator = component "Assignment Coordinator" "Coordina la asignación de la solicitud." ".NET"
                dispatchGuard = component "Concurrency Guard" "Actualización condicional atómica: la primera aceptación válida gana; las siguientes reciben 409 Conflict." ".NET"
                dispatchAudit = component "Audit Component" "Audita cambios de estado del despacho (RNF-04)." ".NET"
                dispatchPort = component "Dispatch Repository Port" "Contrato de persistencia del despacho." ".NET — interfaz"
                dispatchAdapter = component "PostgreSQL Adapter" "Implementa el puerto contra PostgreSQL." ".NET"
            }

            core = container "Core Service" "Tenants, identidad, clientes y sitios, aliados y KYC, catálogo, cotización, ejecución, calificación, comunicaciones, reportes y el módulo de disponibilidades. Dueño de los esquemas core, servicio, comunicaciones, disponibilidad y pagos." "Node.js" {
                coreApi = component "Core API" "Expone los casos de uso de todos los dominios del Core, incluido el de disponibilidades." "Node.js"
                coreUsers = component "Users / Tenants Component" "Tenants, usuarios, roles y acceso (RF-01, RF-03, RF-04)." "Node.js"
                coreKyc = component "KYC Orchestrator" "Registro y verificación de aliados y documentos (RF-05, RF-06)." "Node.js"
                coreCatalog = component "Catalog Component" "Categorías, clientes, sitios de servicio y asociaciones aliado-categoría (RF-08..RF-11)." "Node.js"
                coreService = component "Service Cycle Component" "Cotización, ejecución y calificación bidireccional (RF-15, RF-17, RF-18, RF-19). Escribe el veredicto tarifario que emite Rules." "Node.js"
                coreNotif = component "Notification Component" "Conversaciones, mensajes y notificaciones del servicio (RF-20, RF-21)." "Node.js"
                coreReport = component "Operational Reporting" "Reportes operativos y de tarifario (RF-23)." "Node.js"
                coreAdapters = component "External Adapters" "Encapsula proveedores externos: push, Storage, Realtime y pagos." "Node.js"
                corePort = component "Repositories" "Contratos de persistencia de los dominios del Core." "Node.js — interfaces"

                availApp = component "Availability Application Service" "Casos de uso del módulo de disponibilidades (RF-07, RF-12, RNF-07)." "Node.js"
                availSchedule = component "Schedule Rules" "Horarios y solapamientos. La lógica pertenece al módulo, no al cliente." "Node.js"
                availQuery = component "Availability Query" "Elegibilidad: categoría declarada + zona de cobertura con coincidencia exacta + agenda disponible (REST-01)." "Node.js"
                availPort = component "Availability Repository" "Contrato de persistencia del esquema disponibilidad." "Node.js — interfaz"
            }

            auth = container "Supabase Auth" "Autenticación de usuarios y emisión del JWT firmado del que se obtiene el tenant_id (ADR-0018)." "Supabase"
            db = container "PostgreSQL" "Persistencia operacional separada por esquemas de dominio, con Row-Level Security por tenant (ADR-0012)." "Supabase — PostgreSQL + RLS" "Database"
            storage = container "Supabase Storage" "Documentos KYC en bucket privado con la convención tenant_id/aliado_id/documento (ADR-0013). El cliente no lo alcanza directamente." "Supabase"
            realtime = container "Supabase Realtime" "Transporta eventos de mensajería hacia los participantes conectados. No lee tablas de negocio ni ejecuta reglas." "Supabase"
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

        // ---------- Relaciones de contenedores (SAD §6, SDD §4.3) ----------

        cliente -> flutter "Usa"
        aliado -> flutter "Usa"
        adminTenant -> flutter "Usa"
        adminPlataforma -> flutter "Usa"

        flutter -> gateway "Consume la API operacional" "HTTPS / JSON"
        flutter -> auth "Autentica y obtiene el JWT" "HTTPS"
        realtime -> flutter "Entrega eventos de mensajería al participante conectado" "WebSocket"

        gateway -> rules "Enruta tras validar el token" "HTTPS / JSON"
        gateway -> dispatch "Enruta tras validar el token" "HTTPS / JSON"
        gateway -> core "Enruta tras validar el token" "HTTPS / JSON"

        dispatch -> core "Consulta elegibilidad por categoría y zona; nunca lee su esquema" "HTTPS / JSON"
        dispatch -> rules "Pide el orden del listado de aliados" "HTTPS / JSON"
        core -> rules "Pide el veredicto de validación tarifaria" "HTTPS / JSON"

        core -> auth "Integra identidad y acceso"
        rules -> db "Lee reglas y tarifarios del tenant" "SQL"
        dispatch -> db "Persiste solicitudes, asignaciones y auditoría" "SQL"
        core -> db "Persiste tenants, clientes, aliados, catálogo, disponibilidad, ciclo del servicio y comunicaciones" "SQL"

        core -> storage "Almacena y sirve documentos KYC aislados por tenant y aliado"
        core -> realtime "Publica eventos de mensajería, después de persistir el mensaje"
        core -> push "Envía notificaciones cuando el destinatario no está conectado"
        core -> pagos "Cobros y liquidaciones (2.º incremento)"

        db -> etl "Entrega carga incremental"
        etl -> dwh "Alimenta el Data Warehouse"

        gateway -> observabilidad "Métricas, logs y trazas"
        rules -> observabilidad "Métricas, logs y trazas"
        dispatch -> observabilidad "Métricas, logs y trazas"
        core -> observabilidad "Métricas, logs y trazas"

        // ---------- Relaciones de componentes (SDD §4.4) ----------

        gateway -> rulesApi "Enruta"
        rulesApi -> rulesApp "Invoca"
        rulesApp -> rulesFactory "Resuelve la estrategia"
        rulesFactory -> rulesRanking "Instancia"
        rulesFactory -> rulesTariff "Instancia"
        rulesFactory -> rulesKyc "Instancia"
        rulesApp -> rulesPort "Consulta reglas y tarifario del tenant"
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
        dispatchSelector -> coreApi "Consulta elegibilidad por categoría y zona" "HTTPS / JSON"
        dispatchApp -> rulesApi "Pide el orden del listado de aliados" "HTTPS / JSON"

        gateway -> coreApi "Enruta"
        coreApi -> coreUsers "Invoca"
        coreApi -> coreKyc "Invoca"
        coreApi -> coreCatalog "Invoca"
        coreApi -> coreService "Invoca"
        coreApi -> coreNotif "Invoca"
        coreApi -> coreReport "Invoca"
        coreApi -> availApp "Invoca los casos de uso de disponibilidad"
        coreKyc -> coreAdapters "Usa para Storage"
        coreNotif -> coreAdapters "Usa para push y Realtime"
        coreService -> rulesApi "Pide el veredicto tarifario" "HTTPS / JSON"
        coreUsers -> corePort "Persiste"
        coreKyc -> corePort "Persiste"
        coreCatalog -> corePort "Persiste"
        coreService -> corePort "Persiste"
        coreNotif -> corePort "Persiste"
        coreReport -> corePort "Consulta"
        corePort -> db "Lee y escribe" "SQL"
        coreAdapters -> storage "Lee y escribe documentos KYC"
        coreAdapters -> realtime "Publica eventos"
        coreAdapters -> push "Envía notificaciones"
        coreUsers -> auth "Integra identidad"

        availApp -> availSchedule "Evalúa horarios y solapamientos"
        availApp -> availQuery "Resuelve elegibilidad"
        availApp -> availPort "Persiste y consulta"
        availPort -> db "Lee y escribe el esquema disponibilidad" "SQL"

        // ---------- Despliegue — QA (SDD §9.1) ----------

        qa = deploymentEnvironment "QA" {

            dispositivoQa = deploymentNode "Equipo de QA" "Navegador y dispositivo móvil de prueba." {
                containerInstance flutter
            }

            vmQa = deploymentNode "VM de QA" "Máquina virtual del ambiente de QA. La orquestación definitiva está abierta (INFRA-01, INFRA-02)." "Linux + Docker Engine" {

                deploymentNode "Contenedor del Gateway" "Expone el ambiente a las pruebas." "NGINX" {
                    containerInstance gateway
                }
                deploymentNode "Contenedor Rules" "Health check y límites de CPU y memoria declarados." "Docker" {
                    containerInstance rules
                }
                deploymentNode "Contenedor Dispatch" "Health check y límites de CPU y memoria declarados." "Docker" {
                    containerInstance dispatch
                }
                deploymentNode "Contenedor Core" "Incluye el módulo de disponibilidades." "Docker" {
                    containerInstance core
                }
            }

            supabaseQa = deploymentNode "Supabase — proyecto de QA" "Separado de producción. Dataset controlado y anonimizado; nunca datos reales de KYC." "Supabase" {
                deploymentNode "PostgreSQL" "Esquemas por dominio con RLS por tenant." "PostgreSQL" {
                    containerInstance db
                }
                deploymentNode "Auth" "" "Supabase Auth" {
                    containerInstance auth
                }
                deploymentNode "Storage" "Bucket privado de documentos sintéticos." "Supabase Storage" {
                    containerInstance storage
                }
                deploymentNode "Realtime" "" "Supabase Realtime" {
                    containerInstance realtime
                }
            }
        }

        // ---------- Despliegue — PROD (SDD §9.2) ----------

        produccion = deploymentEnvironment "PROD" {

            internet = deploymentNode "Internet" "Acceso de usuarios web y móvil." {
                deploymentNode "Dispositivo del usuario" "" "Navegador / app móvil" {
                    containerInstance flutter
                }
            }

            borde = deploymentNode "DNS + TLS" "Resolución y terminación TLS del tráfico externo." {

                vmProd = deploymentNode "VM productiva" "Máquina virtual de producción con Docker. Imágenes inmutables fijadas por tag y digest; rollback por imagen anterior. La orquestación definitiva está abierta (INFRA-01, INFRA-02)." "Linux + Docker Engine" {

                    deploymentNode "Contenedor del Gateway" "Entrada única de la plataforma." "NGINX" {
                        containerInstance gateway
                    }
                    deploymentNode "Contenedor Rules" "restart unless-stopped, health check y límites de recursos." "Docker" {
                        containerInstance rules
                    }
                    deploymentNode "Contenedor Dispatch" "restart unless-stopped, health check y límites de recursos." "Docker" {
                        containerInstance dispatch
                    }
                    deploymentNode "Contenedor Core" "Incluye el módulo de disponibilidades." "Docker" {
                        containerInstance core
                    }
                }
            }

            plataformaDatos = deploymentNode "Supabase — proyecto productivo" "Plataforma administrada. Base no accesible desde Internet pública salvo controles explícitos; acceso administrativo con privilegio mínimo." "Supabase" {
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

        // ---------- Vista 1 — Landscape ----------
        systemLandscape "landscape" "Panorama de MANI: actores, la plataforma y los sistemas con los que convive. Fuente: SAD §5, SDD §4.1." {
            include *
            autolayout lr
        }

        // ---------- Vista 2 — C4 Nivel 1: Contexto ----------
        systemContext mani "contexto" "C4 Nivel 1 — MANI, sus actores y los sistemas externos. Fuente: SAD §5, SDD §4.2." {
            include *
            autolayout lr
        }

        // ---------- Vista 3 — C4 Nivel 2: Contenedores ----------
        container mani "contenedores" "C4 Nivel 2 — unidades desplegables y almacenes. Tres servicios de negocio; disponibilidades es un módulo del Core. Fuente: SAD §6, SDD §4.3." {
            include *
            autolayout lr
        }

        // ---------- Vistas 4 a 7 — C4 Nivel 3: Componentes ----------
        component rules "componentes-rules" "C4 Nivel 3 — Rules Service (Java). Fuente: SDD §4.4.1." {
            include *
            autolayout lr
        }

        component dispatch "componentes-dispatch" "C4 Nivel 3 — Dispatch Service (.NET). La exclusión concurrente vive en Concurrency Guard. Fuente: SDD §4.4.2." {
            include *
            autolayout lr
        }

        component core "componentes-core" "C4 Nivel 3 — Core Service (Node.js), dominios de negocio. El módulo de disponibilidades tiene su propia vista. Fuente: SDD §4.4.3." {
            include gateway coreApi coreUsers coreKyc coreCatalog coreService coreNotif coreReport coreAdapters corePort db storage realtime push auth rulesApi
            autolayout lr
        }

        component core "componentes-availability" "C4 Nivel 3 — Core Service (Node.js), módulo de disponibilidades. Fuente: SDD §4.4.4." {
            include coreApi availApp availSchedule availQuery availPort db dispatchSelector
            autolayout lr
        }

        // ---------- Vistas 8 a 10 — Dinámicas / secuencias ----------
        dynamic mani "secuencia-despacho" "Despacho y aceptación concurrente: RF-12, RF-13, RF-14 y RNF-05. La primera aceptación gana; la segunda recibe 409. Fuente: SDD §4.6.1." {
            cliente -> flutter "Crea la solicitud de servicio"
            flutter -> gateway "POST de la solicitud"
            gateway -> dispatch "Enruta tras validar el token"
            dispatch -> core "Pide los aliados elegibles por categoría y zona"
            dispatch -> rules "Pide el orden del listado"
            dispatch -> db "Persiste la solicitud y los candidatos"
            dispatch -> core "Pide notificar el broadcast a los aliados"
            core -> push "Notifica a los aliados candidatos"
            aliado -> flutter "Acepta la solicitud"
            flutter -> gateway "POST de aceptación"
            gateway -> dispatch "Enruta la aceptación"
            dispatch -> db "UPDATE condicional atómico de la asignación"
            dispatch -> core "Registra el cambio de estado en el historial"
            autolayout lr
        }

        dynamic mani "secuencia-cotizacion" "Cotización y validación tarifaria: RF-15, RF-16 y RF-17. Rules emite el veredicto, Core escribe. Fuente: SDD §4.6.2." {
            aliado -> flutter "Arma la cotización con mano de obra y materiales"
            flutter -> gateway "POST de la cotización"
            gateway -> core "Enruta tras validar el token"
            core -> rules "Pide validar el total contra el tarifario del tenant"
            rules -> db "Lee el tarifario vigente de la categoría"
            core -> db "Persiste la cotización con el indicador fuera_de_rango"
            core -> push "Alerta al aliado si quedó fuera de rango y notifica al cliente"
            cliente -> flutter "Acepta, rechaza o solicita ajuste"
            flutter -> gateway "PATCH del estado de la cotización"
            gateway -> core "Enruta la decisión del cliente"
            core -> db "Actualiza el estado de la cotización"
            autolayout lr
        }

        dynamic mani "secuencia-mensajeria" "Mensajería del servicio: RF-20 y RF-21. El mensaje se persiste antes de publicarse; Realtime es transporte, no almacén. Fuente: SDD §4.6.3." {
            cliente -> flutter "Escribe un mensaje en el servicio"
            flutter -> gateway "POST del mensaje"
            gateway -> core "Enruta tras validar el token"
            core -> db "Persiste el mensaje en comunicaciones.mensaje"
            core -> realtime "Publica el evento del mensaje"
            realtime -> flutter "Entrega el mensaje al aliado conectado"
            core -> push "Envía push si el destinatario no está conectado"
            autolayout lr
        }

        // ---------- Vistas 11 y 12 — Despliegue ----------
        deployment mani "QA" "despliegue-qa" "Despliegue de QA: una VM con Docker y el proyecto Supabase de QA. Fuente: SDD §9.1." {
            include *
            autolayout tb
        }

        deployment mani "PROD" "despliegue-prod" "Despliegue de producción: una VM con Docker, Supabase productivo y la plataforma analítica. Fuente: SDD §9.2." {
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

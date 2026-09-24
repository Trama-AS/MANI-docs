/*
 * MANI - Modelo C4 (arquitectura objetivo según ADR + estado real según código)
 * ----------------------------------------------------------------------------
 * Fuentes:
 *   - ADR-0004..0024, SAD-MANI.md (§7 Contenedores), DD-MANI.md (§3 componentes, §5 API, §8 seguridad, §9 despliegue),
 *     DOC-08 (topología de ambientes).
 *   - Código MANI-Flutter: rama develop (lib/, database/, docker-compose.yml, Dockerfile, nginx.conf, .github/)
 *     y rama release (supabase/poc-cfg09|10|12|13, qa/). main = plantilla Flutter Demo.
 * Revisado: 2026-09-22.
 *
 * Tags de estado (según código):
 *   "Implementado" existe y funciona en develop/release.
 *   "Parcial"      existe parcialmente (simulado, sin UI, solo PoC en release o SQL no versionado).
 *   "Planeado"     decidido en ADR/DD, sin código todavía.
 * Propiedades de cada elemento: "ADR" (decisión que lo justifica) y "Estado ADR" (Aceptado / Propuesto).
 *
 * Vistas:
 *   C1  C1-Contexto, C1-Panorama (MANI + Supabase + sistemas de soporte)
 *   C2  C2-Contenedores (objetivo), C2-Implementado (solo lo que ya existe), C2-Supabase (plataforma externa)
 *   Supabase es un sistema externo: MANI se conecta a él; la BD multi-tenant vive dentro de Supabase.
 *   C3  C3-App-Flutter, C3-Backend-Serverpod, C3-Servicio-Reglas, C3-Servicio-Transaccional, C3-PostgreSQL
 *   C4  C4-Codigo-Auth, C4-Codigo-Cobertura, C4-Codigo-Asignacion (clases modeladas como componentes con tag "Code").
 */
workspace "MANI" "Plataforma SaaS multi-tenant de formalización de servicios entre clientes, aliados y empresas tenant." {

    !identifiers hierarchical

    model {
        properties {
            "structurizr.groupSeparator" "/"
        }

        # =================================================================
        # Personas (DD §8.3: cuatro roles)
        # =================================================================
        cliente = person "Cliente" "Crea solicitudes, aprueba cotizaciones, califica y conversa con el aliado."
        aliado = person "Aliado" "Técnico o empresa prestadora. Se registra con KYC, declara categorías y cobertura, acepta solicitudes, cotiza y ejecuta."
        adminTenant = person "Administrador del tenant" "Verifica aliados (KYC), gestiona categorías, tarifas de referencia y reportes de su empresa."
        adminPlataforma = person "Administrador de plataforma" "Crea y activa/desactiva tenants (RF-01)." "Planeado"

        # =================================================================
        # Sistemas externos
        # =================================================================
        push = softwareSystem "FCM / APNs" "Notificaciones push con la app en background o cerrada. [ADR-0017]" "External,Planeado"
        observabilidad = softwareSystem "Observabilidad" "Prometheus (métricas), Grafana (tableros) y Datadog (APM, logs, alertas). [ADR-0006]" "External,Planeado"
        jira = softwareSystem "Jira" "Backlog; recibe alertas automáticas de Datadog. [ADR-0002, ADR-0006]" "External"
        github = softwareSystem "GitHub Actions" "CI/CD Gitflow develop → release → main: format, analyze, tests, build, imágenes y releases. [ADR-0004]" "External,Implementado"
        registry = softwareSystem "Registro de contenedores" "GHCR ghcr.io/trama-as/mani-flutter (en código) y Docker Hub para los servicios backend. [ADR-0023]" "External,Implementado"
        sonar = softwareSystem "SonarCloud" "SAST y Quality Gate (main). [ADR-0005]" "External,Implementado"
        zap = softwareSystem "OWASP ZAP" "DAST contra QA. [ADR-0005]" "External,Planeado"
        qa = softwareSystem "Suite QA automatizada" "k6 (concurrencia, latencia), Newman (aislamiento, claims), cargas KYC. Rama release. [ADR-0015]" "External,Parcial"

        # =================================================================
        # Sistema MANI
        # =================================================================
        mani = softwareSystem "MANI" "Estilo distribuido orientado a servicios multi-tenant. [ADR-0019]" {

            # -------------------------------------------------------------
            # Cliente
            # -------------------------------------------------------------
            app = container "App Web MANI" "Front web para cliente, aliado y admin de tenant, servido por Nginx (Docker, GHCR). Clean Architecture por feature, get_it, go_router, flutter_bloc." "Flutter Web / Dart, Nginx" "App,Parcial" {
                properties {
                    "ADR" "ADR-0019 (cliente Flutter), ADR-0022 (SDK Supabase para sesión), ADR-0018 (Bearer JWT)"
                    "Estado ADR" "Aceptado"
                }

                group "Core" {
                    bootstrap = component "Bootstrap" "main.dart / app.dart: dotenv, Supabase.initialize, di.init, MaterialApp.router." "Dart" "Core,Implementado"
                    router = component "AppRouter" "GoRouter con guard de sesión (onAuthStateChange). Rutas /login y /register-*." "go_router" "Core,Implementado"
                    di = component "InjectionContainer" "Service locator: SupabaseClient, AuthCubit, casos de uso, repos y datasources." "get_it" "Core,Implementado"
                    logger = component "StructuredLogger" "Log JSON (timestamp, level, service_id, trace_id, tenant_id, message)." "Dart" "Core,Implementado"
                    ui = component "Design System" "AppTheme, ManiButton, ManiCard, ManiSnackbar, ManiTextField." "Material 3" "Core,Implementado"
                    apiClient = component "Cliente HTTP Backend" "Interceptor que inyecta Authorization: Bearer <JWT> y X-Tenant-Slug en pre-auth; token en flutter_secure_storage. [ADR-0018]" "Dart http/dio" "Core,Planeado"
                    toggles = component "Feature Toggles" "Activa funcionalidades sin redeploy. [ADR-0014]" "Dart" "Core,Planeado"
                    rtClient = component "Suscriptor Realtime" "Canales Broadcast por tenant/solicitud con la app en primer plano. [ADR-0017]" "supabase_flutter realtime" "Core,Planeado"
                    pushHandler = component "Receptor Push" "Registra token FCM/APNs y maneja notificaciones. [ADR-0017]" "firebase_messaging" "Core,Planeado"
                }

                group "Feature Auth (M-01, M-02, M-03)" {
                    authPages = component "Páginas de Auth" "LoginPage, RegistroClientePage, RegistroAliadoPage, RegistroAliadoEmpresaPage (file_picker para KYC)." "Flutter" "Presentation,Implementado"
                    authCubit = component "Estado de Auth" "AuthInitial / Loading / Authenticated / RegistrationSuccess / Error." "flutter_bloc" "Presentation,Implementado"
                    authUseCases = component "Casos de uso Auth" "LoginUseCase, RegisterClienteUseCase, RegisterAliadoUseCase, RegisterEmpresaUseCase, IAuthRepository, UserEntity." "Dart" "Domain,Implementado"
                    authData = component "Datos Auth" "AuthRepositoryImpl + AuthRemoteDataSource (signIn/signUp, rpc registrar_*). Aún no sube KYC a Storage." "supabase_flutter" "Data,Implementado"
                }

                group "Feature Verificación de aliados (M-02)" {
                    verifFeature = component "Bandeja de verificación" "BandejaVerificacionPage, BandejaVerificacionCubit, VerificacionAliadosRepositoryImpl (US-02.1.3). Existe el test de integración; el código de lib/ no está en el repo." "Flutter" "Presentation,Parcial"
                }

                group "Feature Cobertura (M-04)" {
                    cobPage = component "Pantalla de cobertura" "Árbol de zonas, búsqueda con debounce y resumen." "Flutter" "Presentation,Implementado"
                    cobController = component "Controlador de cobertura" "Carga, selección, búsqueda y guardado." "ChangeNotifier" "Presentation,Implementado"
                    cobUseCases = component "Casos de uso Cobertura" "DeclararCobertura, ObtenerMiCobertura, ConsultarCatalogoZonas, Zona, SeleccionCobertura." "Dart" "Domain,Implementado"
                    cobData = component "Datos Cobertura" "CoberturaRepositoryImpl + SupabaseCoberturaDataSource (rpc listar_zonas, buscar_zonas, obtener_mi_cobertura, declarar_cobertura)." "supabase_flutter" "Data,Implementado"
                }

                group "Feature Ciclo del servicio (M-05..M-08)" {
                    asigPage = component "Aceptar solicitud" "AceptarSolicitudPage + IAsignacionRepository; implementación EN MEMORIA hasta conectar POST /solicitudes/:id/aceptar. [ADR-0016, ADR-0021]" "Flutter" "Presentation,Parcial"
                    solicitudUi = component "Solicitudes" "Crear solicitud, ver aliados válidos y estado." "Flutter" "Presentation,Planeado"
                    cotizacionUi = component "Cotizaciones" "Cotizar, aceptar, rechazar y solicitar ajuste." "Flutter" "Presentation,Planeado"
                    seguimientoUi = component "Seguimiento y calificación" "Timeline de EventoServicio y calificación bidireccional." "Flutter" "Presentation,Planeado"
                }

                group "Feature Comunicación (M-09)" {
                    chatUi = component "Mensajería" "Conversación cliente-aliado por solicitud. [ADR-0017]" "Flutter" "Presentation,Planeado"
                }

                group "Feature Administración (M-01, M-04, M-11)" {
                    adminUi = component "Administración del tenant" "Categorías, tarifas de referencia, reportes fuera de rango; gestión de tenants para admin de plataforma." "Flutter" "Presentation,Planeado"
                }

                # ---------------------------------------------------------
                # Nivel 4 (código): clases reales de lib/ en develop.
                # Tag "Code" -> se excluyen de las vistas C3.
                # ---------------------------------------------------------
                group "Código Auth/presentation" {
                    cLoginPage = component "LoginPage" "Formulario email/contraseña; crea AuthCubit con sl<AuthCubit>()." "StatelessWidget" "Code,Code-Auth"
                    cRegClientePage = component "RegistroClientePage" "Registro de cliente persona natural (US-02.2.1)." "StatelessWidget" "Code,Code-Auth"
                    cRegAliadoPage = component "RegistroAliadoPage" "Registro de aliado técnico con cédula y RUT (US-02.1.1)." "StatelessWidget" "Code,Code-Auth"
                    cRegEmpresaPage = component "RegistroAliadoEmpresaPage" "Registro de aliado empresa con cámara de comercio, RUT y representante (US-02.1.2)." "StatelessWidget" "Code,Code-Auth"
                    cAuthCubit = component "AuthCubit" "login(), registerCliente(), registerAliado(), registerEmpresa()." "Cubit<AuthState>" "Code,Code-Auth"
                    cAuthState = component "AuthState" "AuthInitial, AuthLoading, AuthAuthenticated(user), AuthRegistrationSuccess(result), AuthError(message)." "abstract class, Equatable" "Code,Code-Auth"
                }
                group "Código Auth/domain" {
                    cLoginUC = component "LoginUseCase" "call(email, password) → UserEntity." "class" "Code,Code-Auth"
                    cRegClienteUC = component "RegisterClienteUseCase" "call(...) → Map resultado." "class" "Code,Code-Auth"
                    cRegAliadoUC = component "RegisterAliadoUseCase" "call(...) → Map resultado." "class" "Code,Code-Auth"
                    cRegEmpresaUC = component "RegisterEmpresaUseCase" "call(...) → Map resultado." "class" "Code,Code-Auth"
                    cIAuthRepo = component "IAuthRepository" "signInWithEmail, registrarClientePersonaNatural, registrarAliadoPersonaNatural, registrarAliadoEmpresa, signOut." "abstract class" "Code,Code-Auth,Interfaz"
                    cUserEntity = component "UserEntity" "id, email." "Equatable" "Code,Code-Auth"
                    cAuthFailure = component "AuthFailure" "message." "Exception" "Code,Code-Auth"
                }
                group "Código Auth/data" {
                    cAuthRepoImpl = component "AuthRepositoryImpl" "Implementa IAuthRepository; _mapAuthError traduce errores de Supabase." "class" "Code,Code-Auth"
                    cIAuthDs = component "IAuthRemoteDataSource" "Contrato de acceso remoto de Auth." "abstract class" "Code,Code-Auth,Interfaz"
                    cAuthDs = component "AuthRemoteDataSource" "signInWithPassword, signUp(data: rol, tenant_id...), rpc registrar_cliente_persona_natural con fallback upsert." "SupabaseClient" "Code,Code-Auth"
                    cUserModel = component "UserModel" "Mapea User de Supabase a UserEntity." "extends UserEntity" "Code,Code-Auth"
                }

                group "Código Cobertura/presentation" {
                    cCobPage = component "DeclararCoberturaPage" "Árbol de zonas, búsqueda con debounce." "StatefulWidget" "Code,Code-Cobertura"
                    cZonaTiles = component "ZonaCheckTile / ZonaGrupoTile" "Filas seleccionables del árbol de zonas." "StatelessWidget" "Code,Code-Cobertura"
                    cResumenBar = component "ResumenCoberturaBar" "Resumen de la selección y botón guardar." "StatelessWidget" "Code,Code-Cobertura"
                    cCobController = component "CoberturaController" "iniciar, seleccionarCiudad, cargarHijas, buscar, alternar, guardar; EstadoCarga." "ChangeNotifier" "Code,Code-Cobertura"
                }
                group "Código Cobertura/domain" {
                    cDeclararUC = component "DeclararCobertura" "Valida selección vacía, límite de zonas y zonas desactivadas." "class" "Code,Code-Cobertura"
                    cObtenerUC = component "ObtenerMiCobertura" "→ SeleccionCobertura." "class" "Code,Code-Cobertura"
                    cCatalogoUC = component "ConsultarCatalogoZonas" "ciudades(), hijas(padreId), buscar(ciudadId, texto)." "class" "Code,Code-Cobertura"
                    cCobRepo = component "CoberturaRepository" "listarZonas, buscarZonas, obtenerMiCobertura, declararCobertura." "abstract interface class" "Code,Code-Cobertura,Interfaz"
                    cZona = component "Zona" "id, nombre, nivel (NivelZona), padreId, ancestros, tieneHijas, activa." "class" "Code,Code-Cobertura"
                    cSeleccion = component "SeleccionCobertura" "Selección con reglas de ancestros (cubre, absorbe, descendientes)." "class" "Code,Code-Cobertura"
                    cCobFailure = component "CoberturaFailure" "CoberturaErrorTipo: seleccionVacia, limiteExcedido, zonaInvalida..." "Exception" "Code,Code-Cobertura"
                }
                group "Código Cobertura/data" {
                    cCobRepoImpl = component "CoberturaRepositoryImpl" "Implementa CoberturaRepository; _guard mapea errores y registra logs." "class" "Code,Code-Cobertura"
                    cCobDs = component "CoberturaRemoteDataSource" "Contrato de RPCs de cobertura." "abstract interface class" "Code,Code-Cobertura,Interfaz"
                    cSupaCobDs = component "SupabaseCoberturaDataSource" "rpc listar_zonas, buscar_zonas, obtener_mi_cobertura, declarar_cobertura." "SupabaseClient" "Code,Code-Cobertura"
                    cZonaModel = component "ZonaModel" "Mapea filas JSON a Zona." "extends Zona" "Code,Code-Cobertura"
                }

                group "Código Asignacion/presentation" {
                    cAceptarPage = component "AceptarSolicitudPage" "Botón aceptar; muestra ya no disponible (409) o no encontrada (404)." "StatefulWidget" "Code,Code-Asignacion"
                }
                group "Código Asignacion/domain" {
                    cIAsigRepo = component "IAsignacionRepository" "obtener(solicitudId), aceptar(solicitudId, aliadoId)." "abstract class" "Code,Code-Asignacion,Interfaz"
                    cSolicitud = component "SolicitudEntity" "id, estado (EstadoSolicitud: pendiente, asignada), aliadoId; asignadaA()." "Equatable" "Code,Code-Asignacion"
                    cNoDisponible = component "SolicitudNoDisponible" "Equivale a 409 ya_no_disponible." "Exception" "Code,Code-Asignacion"
                    cNoEncontrada = component "SolicitudNoEncontrada" "Equivale a 404." "Exception" "Code,Code-Asignacion"
                }
                group "Código Asignacion/data" {
                    cAsigRepoImpl = component "AsignacionRepositoryImpl" "En memoria: imita UPDATE condicional; reintento idempotente." "class" "Code,Code-Asignacion,Parcial"
                }
            }

            # -------------------------------------------------------------
            # Backend principal (DD §3, §5)
            # -------------------------------------------------------------
            backend = container "Backend MANI" "API /api/v1: casos de uso por módulo, validación JWT + rol, despacho broadcast con asignación atómica, rutas KYC y notificaciones. Expone /health y /metrics." "Dart / Serverpod, Docker en Railway" "Service,Planeado" {
                properties {
                    "ADR" "ADR-0012 (Serverpod + Supabase/RLS), ADR-0023 (Docker Hub + Railway)"
                    "Estado ADR" "Aceptado"
                }

                group "Transversal" {
                    authMw = component "Middleware JWT y rol" "Valida firma contra JWKS de Supabase, extrae tenant_id de app_metadata y autoriza por rol. Nunca acepta tenant_id del cliente. [ADR-0018, DD §8.3]" "Serverpod" "Planeado"
                    kycPath = component "Utilidad de rutas KYC" "Única función que construye tenant_id/aliado_id/archivo. [ADR-0013, DD §8.2]" "Dart" "Planeado"
                    notificador = component "Notificador" "Publica Broadcast en Realtime y envía push. [ADR-0017]" "Dart" "Planeado"
                    health = component "Health y métricas" "/health y /metrics para Prometheus. [ADR-0006]" "Serverpod" "Planeado"
                }

                group "Módulos" {
                    m01 = component "M-01 Plataforma y acceso" "POST /tenants, PATCH /tenants/:id/estado, POST /auth/login (X-Tenant-Slug), /auth/password-reset." "Serverpod endpoint" "Planeado"
                    m02 = component "M-02/M-03 Directorio" "POST /aliados, /aliados/:id/documentos, PATCH /aliados/:id/verificacion, POST /clientes, /clientes/:id/sitios." "Serverpod endpoint" "Planeado"
                    m04 = component "M-04 Catálogo y cobertura" "Categorías, /aliados/:id/categorias, /aliados/:id/cobertura, tarifas. Catálogo de zonas global. [ADR-0011]" "Serverpod endpoint" "Planeado"
                    m05 = component "M-05 Despacho y asignación" "POST /solicitudes (resuelve aliados válidos + broadcast), POST /solicitudes/:id/aceptar (UPDATE condicional, 409 idempotente). [ADR-0016, ADR-0021]" "Serverpod endpoint" "Planeado"
                    m06 = component "M-06..M-08 Cotización, ejecución y calificación" "Cotizaciones con bucle de ajuste, EventoServicio append-only, calificaciones únicas por autor." "Serverpod endpoint" "Planeado"
                    m09 = component "M-09 Comunicación" "POST/GET /solicitudes/:id/mensajes." "Serverpod endpoint" "Planeado"
                    m11 = component "M-11 Tarifario y reportes" "GET /reportes/cotizaciones-fuera-de-rango." "Serverpod endpoint" "Planeado"
                }
            }

            # -------------------------------------------------------------
            # Módulos adicionales PROY-07 (ADR-0019, ADR-0023)
            # -------------------------------------------------------------
            reglas = container "Servicio de reglas de negocio" "Reglas de negocio empresariales (Repo B). Módulo exigido por PROY-07; los ADR no detallan qué reglas implementa. Sin base de datos propia: consume datos del backend Serverpod con token relay." "Java / Spring Boot, Docker en Railway" "Service,Planeado" {
                properties {
                    "ADR" "ADR-0019, ADR-0023"
                    "Estado ADR" "Aceptado"
                }
                reglasJwt = component "Filtro JWT" "Valida JWT (JJWT/Nimbus) y pone tenant_id en SecurityContext. [ADR-0018]" "Spring Security" "Planeado"
                reglasApi = component "API de reglas" "Evalúa reglas de negocio del tenant." "Spring Web" "Planeado"
                reglasRepo = component "Cliente API Backend" "Llama al backend Serverpod reenviando el JWT (token relay). [ADR-0018]" "Java" "Planeado"
            }

            transaccional = container "Servicio transaccional" "Transaccional de alta concurrencia (Repo C). Módulo exigido por PROY-07; los ADR no detallan qué operaciones. Sin base de datos propia: consume datos del backend Serverpod con token relay." ".NET / ASP.NET Core, Docker en Railway" "Service,Planeado" {
                properties {
                    "ADR" "ADR-0019, ADR-0023"
                    "Estado ADR" "Aceptado"
                }
                txJwt = component "Middleware JwtBearer" "Valida JWT y pone TenantId en HttpContext.Items. [ADR-0018]" "Microsoft.AspNetCore.Authentication.JwtBearer" "Planeado"
                txApi = component "API transaccional" "Operaciones transaccionales." "ASP.NET Core" "Planeado"
                txRepo = component "Cliente API Backend" "Llama al backend Serverpod reenviando el JWT (token relay). [ADR-0018]" ".NET" "Planeado"
            }

        }

        # =================================================================
        # Supabase: plataforma BaaS externa. Aloja la BD multi-tenant de MANI,
        # la identidad, el storage KYC y el tiempo real. [ADR-0012, ADR-0022]
        # =================================================================
        supabase = softwareSystem "Supabase" "Plataforma BaaS gestionada (proyectos QA y PROD). Aloja la base de datos multi-tenant de MANI, identidad, storage y tiempo real." "Supabase" {

            auth = container "Supabase Auth" "IdP: autentica y emite JWT con app_metadata.tenant_id y user_role (fuente única del tenant)." "Supabase Auth (GoTrue), JWT" "Auth,Implementado" {
                properties {
                    "ADR" "ADR-0022 (IdP), ADR-0018 (tenant en claims)"
                    "Estado ADR" "Aceptado"
                }
            }

            api = container "Supabase Data API" "REST sobre tablas y RPC de Postgres con el JWT del usuario. Es el camino que usa hoy la app; el objetivo es que la lógica pase por el backend." "PostgREST" "Api,Implementado" {
                properties {
                    "ADR" "Sin ADR propio: uso actual del SDK supabase_flutter"
                    "Estado ADR" "N/A"
                }
            }

            db = container "Base de datos multi-tenant" "17 tablas con tenant_id y RLS; exclusión concurrente por UPDATE condicional." "PostgreSQL gestionado por Supabase" "Database,Implementado" {
                properties {
                    "ADR" "ADR-0012 (PostgreSQL + RLS), ADR-0021 (UPDATE condicional), ADR-0011 (modelo de cobertura)"
                    "Estado ADR" "Aceptado / Propuesto (0021)"
                }
                group "Esquema" {
                    esquema = component "Esquema multi-tenant" "tenant, usuario, cliente, aliado, categoria_servicio, aliado_categoria, documento_kyc, zona, cobertura_aliado, sitio, solicitud, cotizacion, evento_servicio, calificacion, mensaje, notificacion, tarifa_referencia." "SQL DDL" "Table,Implementado"
                    rls = component "Políticas RLS" "Objetivo: tenant_isolation_* con auth.jwt()->app_metadata->tenant_id en cada tabla (DD §8.1). Hoy: políticas por auth.uid() en develop y tenant_isolation en PoC." "PostgreSQL RLS" "Policy,Parcial"
                }
                group "Funciones" {
                    hook = component "custom_access_token_hook" "Inyecta tenant_id, rol y user_role en app_metadata; fail-closed. [ADR-0018]" "PL/pgSQL" "Function,Parcial"
                    trgNewUser = component "Trigger handle_new_user" "Al crear auth.users inserta usuario y, si es aliado, aliado + categoría + documento_kyc." "PL/pgSQL" "Function,Implementado"
                    rpcRegistro = component "RPC de registro" "registrar_cliente_persona_natural, registrar_aliado_persona_natural, registrar_aliado_empresa." "PL/pgSQL" "Function,Implementado"
                    rpcVerif = component "RPC de verificación" "listar_aliados_verificacion, obtener_aliado_verificacion, resolver_verificacion_aliado." "PL/pgSQL SECURITY DEFINER" "Function,Implementado"
                    rpcCobertura = component "RPC de cobertura" "listar_zonas, buscar_zonas, obtener_mi_cobertura, declarar_cobertura (la app las llama; SQL no versionado)." "PL/pgSQL" "Function,Parcial"
                    rpcAceptar = component "RPC aceptar_solicitud" "UPDATE condicional atómico validado en PoC-001. [ADR-0021]" "PL/pgSQL" "Function,Parcial"
                }
            }

            storage = container "Storage de documentos KYC" "Bucket privado kyc-documentos; ruta tenant_id/aliado_id/documento; política kyc_isolation; URLs firmadas." "Supabase Storage" "Storage,Parcial" {
                properties {
                    "ADR" "ADR-0013"
                    "Estado ADR" "Propuesto"
                }
            }

            realtime = container "Canal de tiempo real" "Broadcast de despacho, estado y mensajes a apps en primer plano." "Supabase Realtime (Broadcast)" "Realtime,Planeado" {
                properties {
                    "ADR" "ADR-0017"
                    "Estado ADR" "Propuesto"
                }
            }
        }

        # =================================================================
        # Relaciones: personas
        # =================================================================
        cliente -> mani.app.authPages "Inicia sesión y se registra"
        cliente -> mani.app.solicitudUi "Crea solicitudes" "" "Planeado"
        cliente -> mani.app.cotizacionUi "Aprueba o pide ajuste de cotizaciones" "" "Planeado"
        cliente -> mani.app.seguimientoUi "Sigue y califica el servicio" "" "Planeado"
        cliente -> mani.app.chatUi "Conversa con el aliado" "" "Planeado"
        aliado -> mani.app.authPages "Se registra con KYC"
        aliado -> mani.app.cobPage "Declara cobertura"
        aliado -> mani.app.asigPage "Acepta solicitudes"
        aliado -> mani.app.cotizacionUi "Cotiza" "" "Planeado"
        aliado -> mani.app.chatUi "Conversa con el cliente" "" "Planeado"
        adminTenant -> mani.app.verifFeature "Aprueba o rechaza aliados"
        adminTenant -> mani.app.adminUi "Gestiona categorías, tarifas y reportes" "" "Planeado"
        adminPlataforma -> mani.app.adminUi "Crea y gestiona tenants" "" "Planeado"

        # =================================================================
        # App: relaciones internas
        # =================================================================
        mani.app.bootstrap -> mani.app.di "Inicializa"
        mani.app.bootstrap -> mani.app.router "Usa como routerConfig"
        mani.app.bootstrap -> mani.app.ui "Aplica tema"
        mani.app.router -> mani.app.authPages "Construye"
        mani.app.di -> mani.app.authCubit "Provee"
        mani.app.authPages -> mani.app.authCubit "Dispara login/registro"
        mani.app.authCubit -> mani.app.authUseCases "Invoca"
        mani.app.authUseCases -> mani.app.authData "IAuthRepository"
        mani.app.cobPage -> mani.app.cobController "Observa y dispara"
        mani.app.cobController -> mani.app.cobUseCases "Invoca"
        mani.app.cobUseCases -> mani.app.cobData "CoberturaRepository"
        mani.app.cobData -> mani.app.logger "Logs estructurados"
        mani.app.verifFeature -> mani.app.logger "Logs estructurados"
        mani.app.asigPage -> mani.app.apiClient "Llamará POST /solicitudes/:id/aceptar" "" "Planeado"
        mani.app.solicitudUi -> mani.app.apiClient "Usa" "" "Planeado"
        mani.app.cotizacionUi -> mani.app.apiClient "Usa" "" "Planeado"
        mani.app.seguimientoUi -> mani.app.apiClient "Usa" "" "Planeado"
        mani.app.chatUi -> mani.app.apiClient "Usa" "" "Planeado"
        mani.app.adminUi -> mani.app.apiClient "Usa" "" "Planeado"
        mani.app.solicitudUi -> mani.app.rtClient "Recibe cambios de estado" "" "Planeado"
        mani.app.chatUi -> mani.app.rtClient "Recibe mensajes" "" "Planeado"
        mani.app.solicitudUi -> mani.app.toggles "Consulta flags" "" "Planeado"

        # =================================================================
        # Nivel 4: relaciones entre clases
        # =================================================================
        mani.app.cLoginPage -> mani.app.cAuthCubit "login()"
        mani.app.cRegClientePage -> mani.app.cAuthCubit "registerCliente()"
        mani.app.cRegAliadoPage -> mani.app.cAuthCubit "registerAliado()"
        mani.app.cRegEmpresaPage -> mani.app.cAuthCubit "registerEmpresa()"
        mani.app.cAuthCubit -> mani.app.cAuthState "Emite"
        mani.app.cAuthCubit -> mani.app.cLoginUC "Invoca"
        mani.app.cAuthCubit -> mani.app.cRegClienteUC "Invoca"
        mani.app.cAuthCubit -> mani.app.cRegAliadoUC "Invoca"
        mani.app.cAuthCubit -> mani.app.cRegEmpresaUC "Invoca"
        mani.app.cLoginUC -> mani.app.cIAuthRepo "Usa"
        mani.app.cRegClienteUC -> mani.app.cIAuthRepo "Usa"
        mani.app.cRegAliadoUC -> mani.app.cIAuthRepo "Usa"
        mani.app.cRegEmpresaUC -> mani.app.cIAuthRepo "Usa"
        mani.app.cIAuthRepo -> mani.app.cUserEntity "Devuelve"
        mani.app.cAuthRepoImpl -> mani.app.cIAuthRepo "Implementa"
        mani.app.cAuthRepoImpl -> mani.app.cIAuthDs "Usa"
        mani.app.cAuthRepoImpl -> mani.app.cUserModel "Construye"
        mani.app.cAuthRepoImpl -> mani.app.cAuthFailure "Lanza"
        mani.app.cUserModel -> mani.app.cUserEntity "Extiende"
        mani.app.cAuthDs -> mani.app.cIAuthDs "Implementa"
        mani.app.cAuthDs -> supabase.auth "signInWithPassword / signUp / signOut" "HTTPS / REST"
        mani.app.cAuthDs -> supabase.api "rpc registrar_cliente_persona_natural" "HTTPS / REST + JWT"

        mani.app.cCobPage -> mani.app.cCobController "Escucha y dispara acciones"
        mani.app.cCobPage -> mani.app.cZonaTiles "Renderiza"
        mani.app.cCobPage -> mani.app.cResumenBar "Renderiza"
        mani.app.cCobController -> mani.app.cDeclararUC "guardar()"
        mani.app.cCobController -> mani.app.cObtenerUC "iniciar()"
        mani.app.cCobController -> mani.app.cCatalogoUC "cargarHijas() / buscar()"
        mani.app.cCobController -> mani.app.cSeleccion "Mantiene"
        mani.app.cDeclararUC -> mani.app.cCobRepo "Usa"
        mani.app.cDeclararUC -> mani.app.cCobFailure "Lanza"
        mani.app.cObtenerUC -> mani.app.cCobRepo "Usa"
        mani.app.cCatalogoUC -> mani.app.cCobRepo "Usa"
        mani.app.cSeleccion -> mani.app.cZona "Agrupa"
        mani.app.cCobRepo -> mani.app.cZona "Devuelve"
        mani.app.cCobRepoImpl -> mani.app.cCobRepo "Implementa"
        mani.app.cCobRepoImpl -> mani.app.cCobDs "Usa"
        mani.app.cCobRepoImpl -> mani.app.cZonaModel "Construye"
        mani.app.cCobRepoImpl -> mani.app.logger "Registra logs"
        mani.app.cZonaModel -> mani.app.cZona "Extiende"
        mani.app.cSupaCobDs -> mani.app.cCobDs "Implementa"
        mani.app.cSupaCobDs -> supabase.api "rpc de cobertura" "HTTPS / REST + JWT"

        mani.app.cAceptarPage -> mani.app.cIAsigRepo "aceptar()"
        mani.app.cIAsigRepo -> mani.app.cSolicitud "Devuelve"
        mani.app.cIAsigRepo -> mani.app.cNoDisponible "Lanza"
        mani.app.cIAsigRepo -> mani.app.cNoEncontrada "Lanza"
        mani.app.cAsigRepoImpl -> mani.app.cIAsigRepo "Implementa"

        # =================================================================
        # App -> plataforma (actual)
        # =================================================================
        mani.app.router -> supabase.auth "Lee sesión y onAuthStateChange" "supabase_flutter"
        mani.app.authData -> supabase.auth "signInWithPassword / signUp / signOut" "HTTPS / REST"
        mani.app.authData -> supabase.api "rpc registrar_* (fallback upsert usuario/cliente)" "HTTPS / REST + JWT"
        mani.app.cobData -> supabase.api "rpc de cobertura" "HTTPS / REST + JWT"
        mani.app.verifFeature -> supabase.api "rpc de verificación" "HTTPS / REST + JWT" "Parcial"

        # =================================================================
        # App -> plataforma (objetivo)
        # =================================================================
        mani.app.apiClient -> mani.backend.authMw "Llama /api/v1 con Authorization: Bearer <JWT>" "HTTPS / JSON (Serverpod RPC)" "Planeado"
        mani.app.apiClient -> mani.backend.m01 "Login con X-Tenant-Slug (pre-auth)" "HTTPS / JSON" "Planeado"
        mani.app.rtClient -> supabase.realtime "Se suscribe a canales del tenant" "WSS" "Planeado"
        mani.app.verifFeature -> supabase.storage "Visualiza KYC con URL firmada" "HTTPS" "Planeado"
        mani.app.authData -> mani.backend.m02 "Sube documentos KYC" "HTTPS multipart" "Planeado"
        push -> mani.app.pushHandler "Entrega notificaciones" "FCM / APNs" "Planeado"

        # =================================================================
        # Backend (objetivo)
        # =================================================================
        mani.backend.authMw -> supabase.auth "Valida firma del JWT (JWKS)" "HTTPS" "Planeado"
        mani.backend.authMw -> mani.backend.m01 "Enruta autorizado" "" "Planeado"
        mani.backend.authMw -> mani.backend.m02 "Enruta autorizado" "" "Planeado"
        mani.backend.authMw -> mani.backend.m04 "Enruta autorizado" "" "Planeado"
        mani.backend.authMw -> mani.backend.m05 "Enruta autorizado" "" "Planeado"
        mani.backend.authMw -> mani.backend.m06 "Enruta autorizado" "" "Planeado"
        mani.backend.authMw -> mani.backend.m09 "Enruta autorizado" "" "Planeado"
        mani.backend.authMw -> mani.backend.m11 "Enruta autorizado" "" "Planeado"
        mani.backend.m01 -> supabase.auth "Delega login y reset de contraseña" "HTTPS" "Planeado"
        mani.backend.m01 -> supabase.db.esquema "Crea tenants" "SQL" "Planeado"
        mani.backend.m02 -> mani.backend.kycPath "Construye ruta KYC" "" "Planeado"
        mani.backend.kycPath -> supabase.storage "Sube/lee documentos y emite URLs firmadas" "HTTPS (Storage API)" "Planeado"
        mani.backend.m02 -> supabase.db.rpcVerif "Resuelve verificación" "SQL" "Planeado"
        mani.backend.m02 -> supabase.db.esquema "Aliados, clientes, sitios" "SQL" "Planeado"
        mani.backend.m04 -> supabase.db.esquema "Categorías, cobertura, tarifas" "SQL" "Planeado"
        mani.backend.m04 -> mani.reglas.reglasApi "Consulta reglas (token relay)" "HTTPS / REST + JWT" "Planeado"
        mani.backend.m05 -> supabase.db.rpcAceptar "UPDATE condicional atómico" "SQL" "Planeado"
        mani.backend.m05 -> mani.backend.notificador "Broadcast a aliados válidos" "" "Planeado"
        mani.backend.m05 -> mani.transaccional.txApi "Operaciones transaccionales (token relay)" "HTTPS / REST + JWT" "Planeado"
        mani.backend.m06 -> supabase.db.esquema "Cotizaciones, eventos, calificaciones" "SQL" "Planeado"
        mani.backend.m06 -> mani.backend.notificador "Notifica cambios de estado" "" "Planeado"
        mani.backend.m09 -> supabase.db.esquema "Persiste mensajes" "SQL" "Planeado"
        mani.backend.m09 -> mani.backend.notificador "Distribuye mensajes" "" "Planeado"
        mani.backend.m11 -> supabase.db.esquema "Cotización vs tarifa de referencia" "SQL" "Planeado"
        mani.backend.notificador -> supabase.realtime "POST /api/broadcast" "HTTPS / REST" "Planeado"
        mani.backend.notificador -> push "Envía push" "FCM HTTP v1 / APNs" "Planeado"
        mani.backend.health -> observabilidad "Métricas, trazas y logs" "HTTP /metrics, agente Datadog" "Planeado"

        # =================================================================
        # Microservicios (objetivo)
        # =================================================================
        mani.reglas.reglasJwt -> supabase.auth "Valida JWT (JWKS)" "HTTPS" "Planeado"
        mani.reglas.reglasJwt -> mani.reglas.reglasApi "Pasa tenant en SecurityContext" "" "Planeado"
        mani.reglas.reglasApi -> mani.reglas.reglasRepo "Usa" "" "Planeado"
        mani.reglas.reglasRepo -> mani.backend.authMw "Consume datos (token relay)" "HTTPS / REST + JWT" "Planeado"
        mani.transaccional.txJwt -> supabase.auth "Valida JWT (JWKS)" "HTTPS" "Planeado"
        mani.transaccional.txJwt -> mani.transaccional.txApi "Pasa TenantId en HttpContext" "" "Planeado"
        mani.transaccional.txApi -> mani.transaccional.txRepo "Usa" "" "Planeado"
        mani.transaccional.txRepo -> mani.backend.authMw "Consume datos (token relay)" "HTTPS / REST + JWT" "Planeado"
        mani.reglas -> observabilidad "Métricas, trazas y logs" "HTTP / agente Datadog" "Planeado"
        mani.transaccional -> observabilidad "Métricas, trazas y logs" "HTTP / agente Datadog" "Planeado"

        # =================================================================
        # Supabase interno
        # =================================================================
        supabase.auth -> supabase.db.hook "Invoca al emitir el token" "Auth Hook" "Parcial"
        supabase.auth -> supabase.db.trgNewUser "INSERT en auth.users dispara" "SQL interno"
        supabase.api -> supabase.db.rpcRegistro "Ejecuta" "SQL"
        supabase.api -> supabase.db.rpcVerif "Ejecuta" "SQL"
        supabase.api -> supabase.db.rpcCobertura "Ejecuta" "SQL"
        supabase.api -> supabase.db.rpcAceptar "Ejecuta" "SQL" "Parcial"
        supabase.api -> supabase.db.esquema "SELECT/UPSERT bajo RLS" "SQL"
        supabase.db.hook -> supabase.db.esquema "Lee usuario.tenant_id y rol"
        supabase.db.trgNewUser -> supabase.db.esquema "Inserta usuario/aliado/documento_kyc"
        supabase.db.rpcRegistro -> supabase.db.esquema "Inserta usuario/cliente/aliado"
        supabase.db.rpcVerif -> supabase.db.esquema "Actualiza estado_verificacion"
        supabase.db.rpcCobertura -> supabase.db.esquema "Reemplaza cobertura_aliado"
        supabase.db.rpcAceptar -> supabase.db.esquema "UPDATE solicitud WHERE estado = pendiente"
        supabase.db.rls -> supabase.db.esquema "Filtra filas por tenant"
        supabase.storage -> supabase.db.rls "Evalúa kyc_isolation sobre storage.objects" "SQL interno" "Parcial"
        supabase.realtime -> supabase.auth "Autoriza canal con el JWT" "JWT" "Planeado"

        # =================================================================
        # CI/CD, calidad y observabilidad
        # =================================================================
        github -> sonar "Análisis estático y cobertura LCOV" "sonarqube-scan-action"
        github -> registry "Publica imágenes" "docker/build-push-action"
        github -> zap "Dispara escaneo DAST sobre QA" "" "Planeado"
        observabilidad -> jira "Crea incidencias por alerta" "API" "Planeado"
        qa -> supabase.api "Pruebas de concurrencia, latencia y aislamiento" "HTTPS / REST + JWT"
        qa -> supabase.auth "Obtiene tokens de usuarios semilla" "HTTPS"
        qa -> supabase.storage "Carga y lectura cruzada de KYC" "HTTPS"
        zap -> mani.backend "Escanea endpoints" "HTTPS" "Planeado"

    }

    views {
        # ---------------- C1 ----------------
        systemContext mani "C1-Contexto" "Nivel 1: MANI, sus usuarios y sistemas externos." {
            include *
            autolayout lr
        }

        systemLandscape "C1-Panorama" "Nivel 1: panorama de MANI, Supabase y sistemas de soporte." {
            include *
            autolayout lr 400 200
        }

        # ---------------- C2 ----------------
        container mani "C2-Contenedores" "Nivel 2: arquitectura objetivo (ADR). Borde punteado = planeado; discontinuo naranja = parcial." {
            include *
            autolayout lr 400 200
        }

        container mani "C2-Implementado" "Nivel 2: solo lo que ya existe en código." {
            include *
            exclude "element.tag==Planeado"
            exclude "relationship.tag==Planeado"
            autolayout lr 400 200
        }

        container supabase "C2-Supabase" "Nivel 2: servicios de Supabase que usa MANI y quién los consume." {
            include *
            autolayout lr 400 200
        }

        # ---------------- C3 ----------------
        component mani.app "C3-App-Flutter" "Nivel 3: componentes de la app Flutter." {
            include *
            exclude "element.tag==Code"
            autolayout tb 300 150
        }

        component mani.app "C3-App-Flutter-Implementado" "Nivel 3: componentes de la app ya en código." {
            include *
            exclude "element.tag==Code"
            exclude "element.tag==Planeado"
            exclude "relationship.tag==Planeado"
            autolayout tb 300 150
        }

        component mani.backend "C3-Backend-Serverpod" "Nivel 3: módulos del backend según DD §5." {
            include *
            autolayout lr 250 120
        }

        component mani.reglas "C3-Servicio-Reglas" "Nivel 3: microservicio Java (Repo B)." {
            include *
            autolayout lr
        }

        component mani.transaccional "C3-Servicio-Transaccional" "Nivel 3: microservicio .NET (Repo C)." {
            include *
            autolayout lr
        }

        component supabase.db "C3-PostgreSQL" "Nivel 3: lógica en la base de datos." {
            include *
            autolayout lr 250 120
        }

        # ---------------- C4 (código) ----------------
        component mani.app "C4-Codigo-Auth" "Nivel 4: clases de la feature Auth (lib/features/auth)." {
            include "element.tag==Code-Auth"
            include supabase.auth supabase.api
            autolayout tb 200 120
        }

        component mani.app "C4-Codigo-Cobertura" "Nivel 4: clases de la feature Cobertura (lib/features/profiles/coverage)." {
            include "element.tag==Code-Cobertura"
            include mani.app.logger supabase.api
            autolayout tb 200 120
        }

        component mani.app "C4-Codigo-Asignacion" "Nivel 4: clases de la feature Asignación (lib/features/asignacion)." {
            include "element.tag==Code-Asignacion"
            autolayout tb 200 120
        }

        styles {
            element "Element" {
                color #ffffff
            }
            element "Person" {
                background #08427b
                shape Person
            }
            element "Software System" {
                background #1168bd
            }
            element "Supabase" {
                background #1b5e20
            }
            element "External" {
                background #8a8a8a
            }
            element "Container" {
                background #438dd5
            }
            element "Component" {
                background #85bbf0
                color #000000
            }
            element "App" {
                shape WebBrowser
            }
            element "Auth" {
                background #2e7d32
            }
            element "Api" {
                background #3f8f5f
            }
            element "Database" {
                shape Cylinder
            }
            element "Table" {
                shape Cylinder
            }
            element "Storage" {
                shape Folder
            }
            element "Realtime" {
                shape Pipe
            }
            element "Function" {
                shape Hexagon
            }
            element "Domain" {
                background #fff2b3
            }
            element "Data" {
                background #c8e6c9
            }
            element "Code" {
                background #ede7f6
                color #000000
                shape RoundedBox
            }
            element "Interfaz" {
                background #d1c4e9
                color #000000
                border dashed
            }
            element "Core" {
                background #b3d4f5
            }
            element "Parcial" {
                border dashed
                stroke #e65100
                strokeWidth 4
            }
            element "Planeado" {
                border dotted
                opacity 60
            }
            relationship "Relationship" {
                dashed false
            }
            relationship "Parcial" {
                color #e65100
                dashed true
            }
            relationship "Planeado" {
                color #9e9e9e
                dashed true
            }
        }
    }
}

-- =====================================================================
-- MANI — DDL del modelo de datos del MVP (PostgreSQL / Supabase)
-- =====================================================================
-- Documento: Product/DDL_MANI.sql — DDL V1
-- Autosuficiente: este archivo se puede leer y aplicar sin abrir ningún otro
-- documento del repositorio. Cada tabla trae su propósito, sus reglas de
-- negocio/diseño y su trazabilidad (RF/ADR) como comentario inmediatamente
-- encima. Referencias a otros documentos son solo para quien quiera el
-- detalle narrativo completo, nunca un prerrequisito para entender este
-- archivo.
--
-- Qué es MANI: plataforma SaaS multi-tenant que formaliza un ciclo de
-- servicio hoy informal (coordinación por WhatsApp/llamadas) — un cliente
-- solicita un servicio, un aliado lo cotiza y ejecuta, y la operación queda
-- registrada de extremo a extremo hasta su cierre y calificación. Una misma
-- instancia sirve a múltiples empresas (tenants) con datos, configuración y
-- usuarios estrictamente aislados entre ellas.
--
-- Estrategia de aislamiento multi-tenant (aplicada tabla por tabla abajo):
--   * Cada tabla que representa un dato operativo de un tenant lleva una
--     columna `tenant_id` y una política Row-Level Security (RLS) nativa de
--     PostgreSQL/Supabase que compara esa columna contra el tenant del JWT
--     verificado:
--         (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid
--     El `tenant_id` NUNCA se acepta desde el cliente (body/header editable):
--     siempre sale del token firmado por Supabase Auth. Esto es lo que
--     impide que un usuario del tenant A vea u opere sobre filas del tenant B
--     con solo cambiar un valor en la petición (ataque de "tenant spoofing").
--   * `tenant` (la empresa suscrita) y `zona` (catálogo geográfico global de
--     la plataforma) son las únicas dos tablas SIN `tenant_id` y SIN RLS —
--     son globales por diseño, no datos de un tenant.
--   * Esta es la MISMA estrategia y el MISMO archivo que se aplica en los
--     ambientes `dev` y `qa`/`staging`: no existe una versión "de referencia"
--     distinta de la que corre. Este DDL se GENERA a partir del diseño de
--     `Product/Modelo_Datos_MANI.md` — un cambio de esquema se decide y se
--     edita primero ahí, nunca al revés (nunca se edita este archivo para
--     luego "actualizar" el diseño con lo que quedó aquí).
--
-- Convenciones físicas:
--   * PK: `id uuid` en todas las entidades, generada con gen_random_uuid().
--   * FK: `<entidad>_id`.
--   * `tenant_id` es la primera columna tras `id` en toda entidad tenant-scoped.
--   * Fechas en UTC (`timestamptz`).
--   * Enumerados: se materializan como `text` + `CHECK` cuando el valor ya
--     está fijado por una regla de negocio conocida; el resto queda como
--     `text` libre, marcado `-- valor abierto`, para no inventar una regla
--     que ningún requerimiento pidió todavía.
--
-- Trazabilidad (para quien la necesite; no hace falta para aplicar este DDL):
--   SRS_MANI.md (RF-01..RF-23) → Modelo_Datos_MANI.md (modelo lógico) → este
--   archivo (modelo físico) → ADR-0011/0012/0013/0016/0017/0018.
-- Fuera de alcance: Pago, Liquidación, Queja y el resto del 2º incremento
-- (RF-24..RF-28) — no se modelan aquí.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =====================================================================
-- 1. Plataforma y acceso
-- =====================================================================

-- TENANT: la empresa suscrita a MANI. Es la raíz del modelo — todo dato
-- operativo de una empresa cuelga de aquí a través de su tenant_id.
-- <<global>>: sin tenant_id, sin RLS (no pertenece a ningún tenant, es el
-- tenant). `slug` es el identificador legible que el cliente envía en la
-- fase de pre-autenticación (header X-Tenant-Slug), antes de tener un JWT.
CREATE TABLE tenant (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre      text NOT NULL,
    slug        text NOT NULL UNIQUE,
    estado      text NOT NULL, -- valor abierto: activo/inactivo, lo mueve el admin. de plataforma
    fecha_alta  timestamptz NOT NULL DEFAULT now()
);

-- USUARIO: identidad y rol de login, 1:1 con el usuario de Supabase Auth.
-- Separado de Aliado/Cliente porque un mismo login concentra identidad+rol,
-- mientras Aliado/Cliente concentran los datos propios de cada perfil de
-- negocio (un usuario tiene como máximo un perfil de cada uno, nunca ambos
-- en el MVP). `tenant_id` es nulo solo para admin_plataforma, que opera
-- fuera de cualquier tenant. El rol viaja también en el JWT
-- (app_metadata.rol) junto al tenant_id, y es lo que el middleware de
-- autorización usa para filtrar por rol dentro del tenant (dos capas:
-- RLS filtra por tenant, el middleware filtra por rol).
CREATE TABLE usuario (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id   uuid NULL REFERENCES tenant(id),
    email       text NOT NULL,
    rol         text NOT NULL CHECK (rol IN ('admin_plataforma', 'admin_tenant', 'aliado', 'cliente')),
    estado      text NOT NULL, -- valor abierto
    created_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_usuario_tenant_id ON usuario(tenant_id);
ALTER TABLE usuario ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_usuario ON usuario
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- =====================================================================
-- 2. Directorio de aliados y clientes
-- =====================================================================

-- ALIADO: quien presta el servicio. `tipo` distingue persona natural,
-- empresa o empleado directo. `estado_verificacion` lo mueve la bandeja de
-- verificación del admin. de tenant (aprueba/rechaza tras revisar los
-- documentos KYC de abajo) — un aliado en 'pendiente' o 'rechazado' no
-- debería poder operar en el ciclo del servicio (regla de aplicación, no
-- de este DDL).
CREATE TABLE aliado (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id             uuid NOT NULL REFERENCES tenant(id),
    usuario_id            uuid NOT NULL REFERENCES usuario(id),
    tipo                  text NOT NULL CHECK (tipo IN ('persona_natural', 'empresa', 'empleado_directo')),
    nombre_razon_social   text NOT NULL,
    estado_verificacion   text NOT NULL CHECK (estado_verificacion IN ('pendiente', 'aprobado', 'rechazado')),
    created_at            timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_aliado_tenant_id ON aliado(tenant_id);
ALTER TABLE aliado ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_aliado ON aliado
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- DOCUMENTO_KYC: documentos que el aliado adjunta para verificación. El tipo
-- de documento exigido es configurable por tenant (no es un enum fijo aquí
-- a propósito). `ruta_storage` sigue el patrón fijo tenant_id/aliado_id/
-- archivo.ext en el bucket de Storage — un documento de un aliado nunca debe
-- ser visible para otro aliado del mismo tenant ni para otro tenant; esa
-- regla se aplica con una política RLS sobre storage.objects (ver el bloque
-- final de este archivo), no sobre esta tabla.
CREATE TABLE documento_kyc (
    id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id       uuid NOT NULL REFERENCES tenant(id),
    aliado_id       uuid NOT NULL REFERENCES aliado(id),
    tipo_documento  text NOT NULL, -- configurable por tenant, no es enum fijo
    ruta_storage    text NOT NULL, -- patrón tenant_id/aliado_id/documento.ext
    estado          text NOT NULL, -- valor abierto
    fecha_carga     timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_documento_kyc_tenant_id ON documento_kyc(tenant_id);
ALTER TABLE documento_kyc ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_documento_kyc ON documento_kyc
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- CLIENTE: quien solicita el servicio. Un cliente empresa administra 0..*
-- sitios (ver tabla `sitio`); un cliente persona natural típicamente uno.
CREATE TABLE cliente (
    id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id             uuid NOT NULL REFERENCES tenant(id),
    usuario_id            uuid NOT NULL REFERENCES usuario(id),
    tipo                  text NOT NULL CHECK (tipo IN ('persona_natural', 'empresa'))
);
CREATE INDEX idx_cliente_tenant_id ON cliente(tenant_id);
ALTER TABLE cliente ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_cliente ON cliente
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- =====================================================================
-- 3. Catálogo y cobertura
-- (zona se crea antes de sitio: FK obligatoria de sitio → zona, ADR-0011 §2.3)
-- =====================================================================

-- ZONA: catálogo jerárquico de cobertura (ciudad → localidad/comuna →
-- barrio), NUNCA por radio geográfico ni coordenadas — decisión deliberada
-- para no depender de cálculo geoespacial. Es global de la plataforma
-- (compartido por todos los tenants) y de solo lectura para ellos. Una zona
-- nunca se elimina, solo se desactiva (por eso `estado`, no un DELETE).
-- <<global>>: sin tenant_id, sin RLS.
CREATE TABLE zona (
    id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    nivel          text NOT NULL, -- ciudad | localidad/comuna | barrio, valor abierto
    nombre         text NOT NULL,
    zona_padre_id  uuid NULL REFERENCES zona(id), -- autorreferencia: jerarquía de 3 niveles
    estado         text NOT NULL CHECK (estado IN ('activa', 'desactivada'))
);

-- SITIO: dirección de servicio de un cliente. `zona_id` es obligatoria — sin
-- zona, un sitio no puede originar una solicitud, porque el despacho hace
-- match de cobertura por zona (ver `cobertura_aliado` y `solicitud`).
-- `reglas` es JSON libre para condiciones propias del sitio (p. ej. horario
-- de acceso) que el aliado debe ver antes de aceptar una solicitud de ahí.
CREATE TABLE sitio (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id   uuid NOT NULL REFERENCES tenant(id),
    cliente_id  uuid NOT NULL REFERENCES cliente(id),
    zona_id     uuid NOT NULL REFERENCES zona(id),
    direccion   text NOT NULL,
    reglas      jsonb NULL,
    created_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_sitio_tenant_id ON sitio(tenant_id);
ALTER TABLE sitio ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_sitio ON sitio
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- COBERTURA_ALIADO: tabla puente aliado↔zona — existe como tabla propia
-- (no una simple relación N:M) porque lleva su propio dato (fecha de
-- declaración). Lleva `tenant_id` propio aunque `aliado` ya lo tenga: es
-- una denormalización deliberada para que la política RLS de esta tabla se
-- evalúe sin un JOIN extra contra `aliado` en la ruta más caliente del
-- producto (búsqueda de aliados válidos al crear una solicitud).
CREATE TABLE cobertura_aliado (
    id                 uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id          uuid NOT NULL REFERENCES tenant(id),
    aliado_id          uuid NOT NULL REFERENCES aliado(id),
    zona_id            uuid NOT NULL REFERENCES zona(id),
    fecha_declaracion  timestamptz NOT NULL DEFAULT now(),
    UNIQUE (aliado_id, zona_id)
);
CREATE INDEX idx_cobertura_aliado_tenant_id ON cobertura_aliado(tenant_id);
ALTER TABLE cobertura_aliado ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_cobertura_aliado ON cobertura_aliado
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- CATEGORIA_SERVICIO: tipo de servicio ofrecido, configurable por tenant.
-- Se activa/desactiva sin desplegar código nuevo — el toggle de `estado` es
-- justamente lo que permite eso.
CREATE TABLE categoria_servicio (
    id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id        uuid NOT NULL REFERENCES tenant(id),
    nombre           text NOT NULL,
    estado           text NOT NULL, -- activable/desactivable por tenant, valor abierto
    flujo_operativo  text NULL
);
CREATE INDEX idx_categoria_servicio_tenant_id ON categoria_servicio(tenant_id);
ALTER TABLE categoria_servicio ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_categoria_servicio ON categoria_servicio
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- ALIADO_CATEGORIA: tabla puente aliado↔categoría atendida. Mismo criterio
-- de tenant_id denormalizado que cobertura_aliado y por la misma razón.
CREATE TABLE aliado_categoria (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id     uuid NOT NULL REFERENCES tenant(id),
    aliado_id     uuid NOT NULL REFERENCES aliado(id),
    categoria_id  uuid NOT NULL REFERENCES categoria_servicio(id),
    UNIQUE (aliado_id, categoria_id)
);
CREATE INDEX idx_aliado_categoria_tenant_id ON aliado_categoria(tenant_id);
ALTER TABLE aliado_categoria ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_aliado_categoria ON aliado_categoria
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- TARIFA_REFERENCIA: rango de precio esperado (mín/típico/máx) por
-- categoría y tenant. Alimenta la alerta que se le muestra al aliado cuando
-- su cotización se sale de rango, y el reporte de desviaciones del admin.
CREATE TABLE tarifa_referencia (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id     uuid NOT NULL REFERENCES tenant(id),
    categoria_id  uuid NOT NULL REFERENCES categoria_servicio(id),
    valor_min     numeric(12,2) NOT NULL,
    valor_tipico  numeric(12,2) NOT NULL,
    valor_max     numeric(12,2) NOT NULL,
    CHECK (valor_min <= valor_tipico AND valor_tipico <= valor_max)
);
CREATE INDEX idx_tarifa_referencia_tenant_id ON tarifa_referencia(tenant_id);
ALTER TABLE tarifa_referencia ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_tarifa_referencia ON tarifa_referencia
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- =====================================================================
-- 4. Ciclo del servicio
-- =====================================================================

-- SOLICITUD: entidad núcleo del ciclo del servicio. `zona_id` es un
-- SNAPSHOT de sitio.zona_id tomado al crear la solicitud (no una FK viva) —
-- así, si alguien desactiva esa zona después, el histórico de la solicitud
-- no se corrompe. `aliado_id` nace nulo y se llena con un único UPDATE
-- condicional atómico cuando el despacho resuelve la asignación: la
-- solicitud se ofrece por broadcast a TODOS los aliados válidos a la vez, y
-- el primero en aceptar gana — nunca hay orden secuencial de ofertas, y la
-- decisión siempre la toma el servidor (nunca el cliente). `estado` recorre
-- pending → assigned → in_progress → closed, con cancelled como salida
-- alterna en cualquier punto antes del cierre.
CREATE TABLE solicitud (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id   uuid NOT NULL REFERENCES tenant(id),
    cliente_id  uuid NOT NULL REFERENCES cliente(id),
    sitio_id    uuid NOT NULL REFERENCES sitio(id),
    categoria_id uuid NOT NULL REFERENCES categoria_servicio(id),
    zona_id     uuid NOT NULL REFERENCES zona(id),
    aliado_id   uuid NULL REFERENCES aliado(id),
    estado      text NOT NULL DEFAULT 'pending'
                  CHECK (estado IN ('pending', 'assigned', 'in_progress', 'closed', 'cancelled')),
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_solicitud_tenant_id ON solicitud(tenant_id);
ALTER TABLE solicitud ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_solicitud ON solicitud
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- COTIZACION: mano de obra y materiales SIEMPRE separados (nunca un solo
-- monto). Cada ajuste que pide el cliente crea una NUEVA versión de la
-- cotización en vez de mutar la existente — así el historial completo de
-- la negociación queda disponible para auditoría, sin lógica adicional.
-- `estado` recorre pendiente → aceptada/rechazada/ajuste_solicitado; un
-- ajuste_solicitado habilita una nueva fila con version+1 para la misma
-- solicitud, no un UPDATE de esta.
CREATE TABLE cotizacion (
    id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id         uuid NOT NULL REFERENCES tenant(id),
    solicitud_id      uuid NOT NULL REFERENCES solicitud(id),
    aliado_id         uuid NOT NULL REFERENCES aliado(id),
    valor_mano_obra   numeric(12,2) NOT NULL,
    valor_materiales  numeric(12,2) NOT NULL,
    estado            text NOT NULL DEFAULT 'pendiente'
                        CHECK (estado IN ('pendiente', 'aceptada', 'rechazada', 'ajuste_solicitado')),
    version           int NOT NULL DEFAULT 1,
    created_at        timestamptz NOT NULL DEFAULT now(),
    UNIQUE (solicitud_id, version)
);
CREATE INDEX idx_cotizacion_tenant_id ON cotizacion(tenant_id);
ALTER TABLE cotizacion ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_cotizacion ON cotizacion
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- EVENTO_SERVICIO: log cronológico e inmutable de todo lo que pasa durante
-- la ejecución del servicio (cambios de estado, mensajes, cotizaciones).
-- `actor_id` referencia usuario (no aliado/cliente directo) porque
-- cualquier rol autenticado puede generar un evento, incluido admin_tenant.
-- Es append-only por diseño: nunca se actualiza ni se borra una fila, por
-- eso se revocan UPDATE/DELETE a nivel de motor más abajo, no solo por
-- convención de código de la aplicación.
CREATE TABLE evento_servicio (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id     uuid NOT NULL REFERENCES tenant(id),
    solicitud_id  uuid NOT NULL REFERENCES solicitud(id),
    actor_id      uuid NOT NULL REFERENCES usuario(id),
    tipo_evento   text NOT NULL,
    descripcion   text NULL,
    "timestamp"   timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX idx_evento_servicio_tenant_id ON evento_servicio(tenant_id);
ALTER TABLE evento_servicio ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_evento_servicio ON evento_servicio
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);
REVOKE UPDATE, DELETE ON evento_servicio FROM PUBLIC; -- log inmutable: solo INSERT

-- CALIFICACION: calificación bidireccional al cierre del servicio — hasta 2
-- filas por solicitud (una por parte: cliente y aliado). La restricción
-- UNIQUE de abajo es lo que garantiza "máximo 1 calificación por autor y
-- solicitud" a nivel de motor, no solo por regla de aplicación: así, si el
-- botón de calificar se toca dos veces (doble tap, reintento de red), la
-- segunda escritura choca contra la restricción en vez de duplicar la fila.
CREATE TABLE calificacion (
    id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id        uuid NOT NULL REFERENCES tenant(id),
    solicitud_id     uuid NOT NULL REFERENCES solicitud(id),
    autor_id         uuid NOT NULL REFERENCES usuario(id),
    destinatario_id  uuid NOT NULL REFERENCES usuario(id),
    puntaje          int NOT NULL, -- rango numérico: fase de implementación, aún no fijado en ningún documento
    comentario       text NULL,
    created_at       timestamptz NOT NULL DEFAULT now(),
    UNIQUE (solicitud_id, autor_id)
);
CREATE INDEX idx_calificacion_tenant_id ON calificacion(tenant_id);
ALTER TABLE calificacion ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_calificacion ON calificacion
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- =====================================================================
-- 5. Comunicación
-- =====================================================================

-- MENSAJE: chat asociado siempre a una solicitud — nunca una mensajería
-- genérica fuera de un servicio. Se distribuye en vivo por Supabase
-- Realtime; esta tabla es la persistencia, no el mecanismo de entrega.
CREATE TABLE mensaje (
    id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id     uuid NOT NULL REFERENCES tenant(id),
    solicitud_id  uuid NOT NULL REFERENCES solicitud(id),
    remitente_id  uuid NOT NULL REFERENCES usuario(id),
    contenido     text NOT NULL,
    created_at    timestamptz NOT NULL DEFAULT now(),
    leido_at      timestamptz NULL
);
CREATE INDEX idx_mensaje_tenant_id ON mensaje(tenant_id);
ALTER TABLE mensaje ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_mensaje ON mensaje
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- NOTIFICACION: registro de auditoría de que algo se envió, no el mecanismo
-- de entrega en sí (el mecanismo real es Supabase Realtime o FCM/APNs,
-- fuera de este modelo de datos). `canal` distingue si se entregó por
-- WebSocket (usuario conectado) o por push (usuario desconectado).
CREATE TABLE notificacion (
    id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id   uuid NOT NULL REFERENCES tenant(id),
    usuario_id  uuid NOT NULL REFERENCES usuario(id),
    tipo        text NOT NULL,
    canal       text NOT NULL CHECK (canal IN ('push', 'realtime')),
    payload     jsonb NULL,
    enviado_at  timestamptz NOT NULL DEFAULT now(),
    leido_at    timestamptz NULL
);
CREATE INDEX idx_notificacion_tenant_id ON notificacion(tenant_id);
ALTER TABLE notificacion ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_notificacion ON notificacion
  USING (tenant_id = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid);

-- =====================================================================
-- 6. Storage — política sobre el bucket de documentos KYC
-- =====================================================================
-- No es una tabla de este esquema (storage.objects es de Supabase), pero es
-- la misma estrategia de aislamiento aplicada a archivos en vez de filas:
-- un aliado solo puede leer su propia carpeta tenant_id/aliado_id/… dentro
-- del bucket 'kyc-documentos'; admin_tenant puede leer cualquier carpeta de
-- SU tenant (para aprobar/rechazar verificación), nunca de otro tenant.

CREATE POLICY kyc_isolation ON storage.objects
  USING (
    bucket_id = 'kyc-documentos'
    AND (storage.foldername(name))[1] = (auth.jwt() -> 'app_metadata' ->> 'tenant_id')
    AND (
      (storage.foldername(name))[2] = auth.uid()::text
      OR (auth.jwt() -> 'app_metadata' ->> 'user_role') = 'admin_tenant'
    )
  );

-- Fin DDL V1. Fuera de alcance: Pago, Liquidacion, Queja y demás entidades
-- del 2º incremento (RF-24..RF-28) — no se modelan en este archivo.

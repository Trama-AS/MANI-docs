# Visión y alcance

[← 01 · Producto](README.md) · [Índice](../Home.md)

**Fuente:** [`product/SRS.md`](../../product/SRS.md) §1 y §2 · [`README.md`](../../README.md) §1–§3.

## Problema

La operación objetivo se gestiona hoy de forma informal (llamadas, mensajería, contactos directos), lo que impide trazabilidad de los servicios, verificación de aliados, tarifas estandarizadas, control de solicitudes y asignaciones, auditoría y escalamiento a varias empresas.

MANI centraliza ese proceso en una plataforma configurable por empresa, con aislamiento estricto entre tenants.

## Alcance

### MVP

Plataforma multi-tenant · autenticación y control de acceso · directorio de aliados y clientes · documentos KYC · catálogo de categorías · cobertura por zonas · creación y despacho de solicitudes · cotizaciones · ejecución · calificación bidireccional · mensajería y notificaciones · tarifario de referencia · reportes asociados al tarifario.

### Segundo incremento

Pagos y liquidaciones (RF-24, RF-25) · gestión de quejas (RF-26) · comercialización (RF-27) · administración avanzada y métricas operativas por tenant (RF-28).

### Fuera de alcance del MVP

Según SRS §1.2, el MVP **no** incluye:

- pasarela de pago;
- facturación electrónica;
- consola de comercialización;
- geolocalización en tiempo real del aliado;
- cálculo de proximidad o distancia entre aliado y sitio.

Una historia que pida alguno de estos puntos no se implementa en el MVP: se registra su disposición según el [backlog de transición](../06-backlog/transicion-v4.md).

## Principios del producto

Del [`README.md`](../../README.md) §3 y los RNF del SRS:

| Principio | Requisito que lo sostiene |
|---|---|
| Multi-tenancy con datos, usuarios y configuración aislados | RNF-01, REST-04 |
| Configurabilidad por tenant sin despliegue propio | RF-02, RNF-02, RNF-10, REST-05 |
| Trazabilidad reconstruible del ciclo del servicio | RNF-04, RF-18 |
| Idempotencia de operaciones críticas | RNF-03 |
| Concurrencia controlada: exactamente una asignación válida | RNF-05, RF-14 |
| Cobertura por zonas, sin geolocalización en vivo ni radio | RNF-09, REST-01 |
| Seguridad en profundidad en más de una capa | RNF-01 |

## Definiciones

- **Tenant:** empresa suscrita a la plataforma.
- **Aliado:** prestador del servicio.
- **Cliente:** quien solicita el servicio.
- **Administrador de plataforma:** administra la plataforma SaaS y los tenants.
- **Administrador de tenant:** administra configuración y operación de su empresa.
- **RF / RNF / REST / PROY:** requerimiento funcional / no funcional / restricción de producto / restricción de proyecto.

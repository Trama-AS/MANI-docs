# Actores y ciclo del servicio

[← 01 · Producto](README.md) · [Índice](../Home.md)

**Fuente:** [`product/SRS.md`](../../product/SRS.md) §2.3 · [`architecture/SAD.md`](../../architecture/SAD.md) §11.

## Actores

| Actor | Hace |
|---|---|
| **Administrador de plataforma** | Registra tenants, administra su estado, supervisa lo administrativo de la plataforma |
| **Administrador de tenant** | Configura reglas del tenant, categorías, tarifarios y documentos requeridos; aprueba o rechaza aliados; gestiona parámetros operativos |
| **Aliado** | Se registra, carga documentos KYC, declara categorías y cobertura, acepta o rechaza solicitudes, cotiza, ejecuta, participa en mensajería y califica al cliente |
| **Cliente** | Se registra, administra sitios de servicio cuando corresponde, crea solicitudes, consulta aliados, gestiona cotizaciones, participa en mensajería y califica al aliado |

## Ciclo del servicio

```text
Solicitud
  → Selección de aliados válidos (categoría + zona)
  → Broadcast a aliados elegibles
  → Aceptación atómica (exactamente una)
  → Cotización
  → Aceptación / ajuste por el cliente
  → Ejecución (eventos y observaciones cronológicas)
  → Calificación del cliente  +  Calificación del aliado
  → Cierre
```

Reglas del ciclo que no son negociables en implementación:

- El **cierre sólo ocurre con ambas calificaciones** presentes (RF-19, SAD §11).
- La aceptación concurrente se resuelve de forma determinista: la primera aceptación válida se confirma con actualización condicional atómica y las posteriores reciben `409 Conflict` (SAD §7.2, RNF-05).
- La elegibilidad es por **categoría y coincidencia exacta de zona**, sin proximidad ni radio (REST-01, RNF-09, [ADR-0011](../../adr/ADR-0011-cobertura-geografica.md)).
- El orden del listado de aliados lo define la **regla configurada por el tenant** (RF-13), evaluada por el Rules Service.

## Interfaces externas

| Sistema externo | Propósito | Dirección | Restricción |
|---|---|---|---|
| Operador de pagos certificado | Cobros y liquidaciones (2.º incremento) | Bidireccional | PCI DSS recae en el operador (RNF-06) |
| Proveedor de identidad | Autenticar usuarios y gestionar credenciales | Bidireccional | Debe respetar el aislamiento multi-tenant |
| Notificaciones push (FCM / APNs) | Entregar aviso cuando el usuario no está conectado | Saliente | Complementa la mensajería del sistema |

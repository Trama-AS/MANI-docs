# ADR-0019 — Arquitectura SOA distribuida, multi-tenant y políglota

- **Estado:** Aceptado
- **Decisión de:** macroarquitectura
- **Relacionado con:** PROY-07, PROY-08, RNF-01, RNF-02, RNF-05

## Contexto

MANI debe soportar una solución distribuida, multi-tenant y utilizar Java y .NET en módulos de backend. Además requiere independencia funcional entre capacidades con diferentes cargas y responsabilidades.

## Alternativas

1. **Monolito modular.** Descartada porque no satisface la restricción de arquitectura distribuida del proyecto.
2. **BaaS puro con lógica en cliente/base.** Descartada porque concentra lógica de negocio fuera de servicios mantenibles.
3. **SOA distribuida con API Gateway y servicios políglotas.** Elegida.

## Decisión

MANI adopta una **arquitectura SOA distribuida y multi-tenant**, con **NGINX API Gateway** como punto único de entrada y servicios políglotas:

- Flutter: cliente web/móvil;
- Java: reglas por tenant;
- .NET: despacho y asignación;
- Node.js: servicios core y disponibilidad;
- Supabase: plataforma administrada de datos, con PostgreSQL como motor.

La solución mantiene estrategia **multi-repo**, usa Docker/OCI para empaquetado y Kubernetes como orquestador.

## Justificación

Separa capacidades de negocio, cumple PROY-07/PROY-08 y favorece modificabilidad, seguridad, interoperabilidad y escalabilidad independiente.

## Consecuencias

### Positivas
- Límites claros de responsabilidad.
- Evolución y despliegue independientes.

### Negativas
- Mayor complejidad de operación, contratos y observabilidad.

## Condición de revisión

Revisar si cambian restricciones curriculares, límites de dominio o costos operativos de la distribución.

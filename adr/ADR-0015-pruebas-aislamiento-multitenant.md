# ADR-0015 — Pruebas automatizadas de aislamiento multi-tenant

- **Estado:** Propuesto
- **Decisión de:** QA y seguridad
- **Relacionado con:** RNF-01, ADR-0005, ADR-0012, ADR-0018

## Contexto

El aislamiento multi-tenant debe probarse de forma repetible en cada cambio que afecte autenticación, autorización, RLS o esquema.

## Alternativas

1. **Revisión manual de RLS.** Descartada por no ser repetible.
2. **Usar solo DAST genérico.** Descartada porque no valida reglas funcionales cross-tenant.
3. **Postman/Newman en CI con tenants de prueba.** Elegida.

## Decisión

Se mantiene una suite Postman ejecutada con Newman en GitHub Actions para validar acceso cruzado entre al menos dos tenants.

La suite debe cubrir:
- autenticación;
- API Gateway;
- autorización en servicios;
- lectura;
- listado;
- escritura;
- borrado;
- RLS.

**Criterio:** 100% de los accesos cross-tenant no autorizados deben ser rechazados.

## Justificación

Convierte RNF-01 en una verificación automática de regresión.

## Consecuencias

### Positivas
- Detecta fugas antes del merge/promoción.

### Negativas
- Requiere datos semilla y usuarios de prueba mantenidos.

## Condición de revisión

Revisar si se adopta una herramienta especializada que cubra el mismo escenario con mejor trazabilidad.

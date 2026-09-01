# ADR-0016: Estrategia de despacho de solicitudes

> ⚠️ Confirmar el número real de ADR antes de commitear (revisar el último ADR en
> `/docs/adr` del repositorio para no duplicar numeración).

**Estado:** Propuesto — pendiente de confirmación de quórum y decisión final de la Mesa
**Fecha:** 2026-09-01
**Proponente:** Jose Nicolas Alvarez Mesa (Frontend)
**Redactor:** [completar — confirmar con Sara si es rotativo o el proponente]
**Spike relacionado:** SP-04.1.1 (SCRUM-504)
**Relacionado con:** RNF-05, RF-12, RF-14, SP-04.1.2 (condicional)

## Contexto

Cuando un cliente crea una solicitud de servicio (RF-12), el sistema debe presentar la
solicitud a los aliados válidos por cobertura y categoría, y decidir cómo se asigna esa
solicitud a un aliado. RNF-05 exige que el despacho resuelva de forma determinista las
aceptaciones concurrentes, dejando exactamente una asignación válida por solicitud.

## Alternativas evaluadas

### Opción 1: Despacho secuencial (uno a la vez)
Se ofrece la solicitud a un aliado según el orden configurado (RF-13: cobertura,
calificación o comisión). Si el aliado rechaza o no responde en un tiempo definido, se
ofrece al siguiente de la lista.

- **Ventajas:** simple de implementar; respeta estrictamente el orden de prioridad
  configurado por el tenant; no existe riesgo de doble asignación porque solo un aliado
  la ve a la vez.
- **Desventajas:** puede ser lento si varios aliados rechazan en cadena, afectando
  negativamente la experiencia del cliente.

### Opción 2: Despacho simultáneo (broadcast) con asignación atómica — PROPUESTA
Se ofrece la solicitud a todos los aliados válidos al mismo tiempo. Gana el primero en
aceptar, resuelto mediante una actualización condicional en base de datos:

```sql
UPDATE solicitudes
SET status = 'assigned', aliado_id = :aliado_actual
WHERE id = :solicitud_id
  AND status = 'pending'
  AND aliado_id IS NULL;
```

Si la sentencia afecta 1 fila, ese aliado gana la asignación. Si afecta 0 filas, la
solicitud ya fue tomada por otro aliado.

- **Ventajas:** respuesta más rápida para el cliente; mejor tasa de aceptación; la
  concurrencia se resuelve a nivel de base de datos (MVCC de Postgres), sin necesidad de
  lógica de bloqueo adicional en la aplicación.
- **Desventajas:** requiere resolver concurrencia explícitamente (activa SP-04.1.2 como
  spike condicional); mayor complejidad de implementación que el despacho secuencial.

## Decisión propuesta

Despacho **simultáneo (broadcast)** con asignación atómica vía actualización condicional
en base de datos. RNF-05 ya asume explícitamente que pueden existir aceptaciones
concurrentes, lo que sugiere que este es el escenario que el equipo anticipó desde el
Análisis de Requerimientos.

## Trade-offs y consecuencias

- Se activa formalmente **SP-04.1.2** (exclusión concurrente), previamente marcado como
  condicional en el Product Backlog.
- La resolución de la asignación queda del lado del servidor: el cliente (app del aliado)
  siempre debe esperar confirmación del backend antes de mostrar "asignado a ti" — no se
  puede decidir del lado del cliente.
- Refuerza indirectamente RNF-03 (idempotencia): un reintento de aceptación por parte del
  mismo aliado simplemente afecta 0 filas la segunda vez, sin generar duplicados.

## Disenso

[Completar con lo registrado en la Mesa: quién argumentó en contra y cuál fue el
argumento, según exige el Gobierno del Equipo sección 1.3.3.]

## Quórum y asistentes

[Completar: confirmar que se alcanzó el quórum de 5 de 7 integrantes exigido para validar
la decisión.]

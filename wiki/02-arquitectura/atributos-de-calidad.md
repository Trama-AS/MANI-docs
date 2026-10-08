# Atributos de calidad

[← 02 · Arquitectura](README.md) · [Índice](../Home.md)

**Fuente:** [`architecture/SDD.md`](../../architecture/SDD.md) §7 y §8 (ISO/IEC 25010:2023) · [`architecture/SAD.md`](../../architecture/SAD.md) §20.

> **Esta página no contiene umbrales.** Los umbrales de calidad del proyecto viven en **un solo
> lugar**: [`SDD.md`](../../architecture/SDD.md) §7, y los escenarios con los que QA los verifica en
> §8. Antes esta página los repetía, y la copia se desincronizó: llegó a decir `p95 ≤ 1 s` mientras
> el SDD decía `p95 ≤ 500 ms`.
>
> Si necesitas un número, ve al SDD. Si un número aparece en otro documento, está desactualizado.

## Qué decide cada documento

| Pregunta | Dónde se responde |
|---|---|
| ¿Qué atributo es prioritario y por qué? | [`SAD.md`](../../architecture/SAD.md) §20 |
| ¿Qué decisión de arquitectura obliga esa prioridad? | [`SAD.md`](../../architecture/SAD.md) §20.1 |
| ¿Con qué umbral se verifica? | [`SDD.md`](../../architecture/SDD.md) §7 |
| ¿Con qué escenario lo comprueba QA? | [`SDD.md`](../../architecture/SDD.md) §8 |

## Prioridades

| Prioridad | Atributos |
|---|---|
| **P1 — crítico** | seguridad · fiabilidad · eficiencia de desempeño · mantenibilidad · flexibilidad |
| **P2 — alto** | compatibilidad · adecuación funcional · capacidad de interacción |
| **P3 — controlado** | protección / safety |

P1 condiciona decisiones estructurales y la aceptación del sistema. P2 debe cumplirse antes de
producción. P3 se verifica, pero su impacto arquitectónico es menor para el alcance actual.

## Escenarios de calidad

[`SDD.md`](../../architecture/SDD.md) §8 define **nueve** escenarios, uno por característica de
ISO/IEC 25010:2023, cada uno con fuente, estímulo, entorno, respuesta esperada, umbral y cómo lo
mide QA:

| ID | Característica | Qué comprueba |
|---|---|---|
| `QAS-01` | Seguridad | que un usuario de un tenant no alcance datos de otro |
| `QAS-02` | Fiabilidad | que un fallo del proveedor de notificaciones no revierta una operación confirmada |
| `QAS-03` | Eficiencia de desempeño | la latencia de la consulta de elegibilidad por categoría y zona |
| `QAS-04` | Mantenibilidad | que un cambio interno compatible no obligue a tocar consumidores |
| `QAS-05` | Flexibilidad | que se añada capacidad sin cambiar código ni reconstruir la imagen |
| `QAS-06` | Compatibilidad | que productor y consumidor respeten el contrato OpenAPI |
| `QAS-07` | Adecuación funcional | ranking, tarifa, asignación y conflicto |
| `QAS-08` | Capacidad de interacción | protección ante acciones irreversibles y entradas inválidas |
| `QAS-09` | Protección / safety | que una falla de terceros no deje transacciones ambiguas |

Una historia que toque uno de esos temas debe demostrar su escenario, no solo sus criterios
funcionales ([DoR y DoD](../05-proceso/dor-y-dod.md)).

Cuando un escenario y un criterio de la sección §7 del SDD difieran, **prevalece el más
restrictivo** (SDD §8).

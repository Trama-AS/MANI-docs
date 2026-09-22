# ADR-0026: Modelo de custodia de pagos para EP-07 (decisión confirmada por el cliente)

* Fecha: 2026-09-21
* Sprint: Sprint 2
* Autor: Camila Beltrán
* Origen: Definición del Product Owner (Nicolás Redes) tras ADR-0025
* Revisor:

## Contexto

ADR-0025 documentó un riesgo regulatorio abierto sobre el modelo de custodia de pagos de EP-07, dado que la retención directa de fondos por parte de MANI podría constituir captación masiva y habitual de dineros (Art. 316, Código Penal) sin autorización de la Superintendencia Financiera. El Product Owner (Nicolás) confirmó que MANI retendrá el pago a nivel de estado de la transacción, pero utilizando una pasarela de pagos regulada como custodio real de los fondos — aclarando que las dos alternativas planteadas en ADR-0025 no eran excluyentes sino complementarias.

## Alternativas evaluadas

1. MANI retiene los fondos directamente en cuentas propias, sin intermediario regulado — descartada porque mantiene el riesgo de captación no autorizada señalado en ADR-0025.
2. MANI delega por completo el control del estado de la transacción a la pasarela de pagos, sin gestionar ese estado en su propio sistema — descartada porque el modelo de datos (DD-MANI) ya requiere que MANI conozca y controle el estado retenido/liberado/reembolsado para su lógica de negocio (ej. el mecanismo CAS de aceptación concurrente).

## Decisión

Usaremos un modelo híbrido: MANI gestionará el estado de la transacción (retenido, liberado, reembolsado) a nivel de aplicación, mientras que la custodia real del dinero quedará a cargo de una pasarela de pagos regulada (PSP), como PayU o Wompi.

## Trade-off asumido

Aceptamos el costo y la complejidad de integrar con un PSP externo (comisiones por transacción, dependencia de su disponibilidad y de su API) a cambio de eliminar el riesgo de captación masiva y habitual de dineros identificado en ADR-0025.

## Estado

Aceptado — última actualización: 2026-09-21

## Consecuencias

* Positivas: se elimina el riesgo regulatorio principal señalado en KI-12; el equipo puede retomar el desarrollo de las historias de pagos que estaban bloqueadas por esta definición.
* Negativas: se introduce una dependencia externa (el PSP que se elija) que deberá seleccionarse e integrarse, con impacto en cronograma y en costos por comisiones de transacción.
* Neutras: el modelo de datos de transacciones (retenido/liberado/reembolsado) definido en DD-MANI se mantiene sin cambios de estructura, pero ahora representa el estado lógico de una operación cuya custodia física del dinero reside en el PSP, no en las cuentas de MANI.

## Trazabilidad

* Issues: SCRUM-948 (DOC-19), SCRUM-1026
* Pull requests:
* Componentes del modelo C4 afectados: Módulo de Pagos y Transacciones (EP-07)
* Documentos que deben actualizarse: DD-MANI.md, SAD-MANI.md (actualizar estado de KI-12)

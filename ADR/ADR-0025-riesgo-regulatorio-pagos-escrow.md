# ADR-0025: Riesgo regulatorio pendiente sobre custodia de pagos (escrow) en EP-07

* Fecha: 2026-09-20
* Sprint: Sprint 2
* Autor: Camila Beltrán
* Origen: Sprint 2 Planning - hoja '1. Doc y Arquitectura'
* Revisor:

## Contexto

EP-07 requiere que la plataforma retenga dinero de clientes en garantía (escrow) hasta liberar el pago al aliado o reembolsarlo, según el estado de la transacción (retenido, liberado, reembolsado), ya definido en el modelo de datos (DD-MANI).

En Colombia, recibir dinero del público de forma masiva y habitual sin autorización previa de la autoridad competente constituye el delito de "captación masiva y habitual de dineros" (Artículo 316, Código Penal, Ley 599 de 2000), con pena de prisión de ciento veinte (120) a doscientos cuarenta (240) meses. Se considera masiva y habitual cuando el pasivo con el público supera veinte (20) personas o cincuenta (50) obligaciones — umbral que MANI superaría fácilmente en operación normal.

Adicionalmente, el tratamiento de los datos personales asociados a estas transacciones debe cumplir la Ley 1581 de 2012 (Habeas Data), que exige trazabilidad demostrable ante la Superintendencia de Industria y Comercio, con multas de hasta 2.000 salarios mínimos legales mensuales vigentes en caso de incumplimiento.

No existe en Colombia una ley que exija explícitamente un "audit log inmutable" para transacciones financieras entre particulares, pero la trazabilidad exigida por la Ley 1581 implica en la práctica que el registro de quién movió el dinero, cuándo y bajo qué estado (retenido/liberado/reembolsado) debe poder demostrarse sin alteraciones posteriores — de lo contrario, la plataforma no podría defenderse ante un reclamo de un cliente o una auditoría de la SIC.

El equipo no cuenta con la información de negocio necesaria para determinar si MANI retendrá los fondos directamente o si operará únicamente como intermediario tecnológico sobre una pasarela de pagos (PSP) ya regulada, ni el nivel de inmutabilidad que debe exigirse al log de transacciones.

## Alternativas evaluadas

1. Continuar la implementación de la lógica de custodia directa de fondos (retener el dinero del cliente en una cuenta propia de MANI) — descartada porque expone al proyecto y al cliente a responsabilidad penal bajo el Art. 316 si no se cuenta con autorización de la Superintendencia Financiera.
2. Implementar el escrow usando un modelo simplificado sin definir la estructura legal subyacente, asumiendo que "ya se resolverá después" — descartada porque oculta el riesgo en vez de resolverlo, y puede forzar un rediseño costoso del modelo de transacciones más adelante.

## Decisión

Registramos esta decisión como pendiente y detenemos la implementación de la lógica de custodia (retención y liberación de fondos) del escrow hasta que el cliente confirme el modelo de custodia de pagos a utilizar.

## Trade-off asumido

Aceptamos retrasar el desarrollo de las historias relacionadas con la liberación y reembolso de pagos dentro de EP-07, priorizando evitar la implementación de una funcionalidad que podría requerir rediseño legal y técnico costoso si se construye sobre un modelo de custodia incorrecto.

## Estado

Propuesto — última actualización: 2026-09-20

## Consecuencias

* Positivas: se evita construir una funcionalidad de custodia de dinero que podría requerir reestructuración legal posterior; el equipo puede seguir avanzando en otras historias de EP-07 no relacionadas con el manejo directo de dinero.
* Negativas: las historias que dependen del modelo de custodia (liberación y reembolso de pagos) quedan bloqueadas hasta obtener respuesta del cliente, lo que puede impactar el cronograma de EP-07.
* Neutras: si el cliente define usar un PSP regulado, el modelo de datos de transacciones (estado retenido/liberado/reembolsado, ya definido en el DD) deberá revisarse para reflejar la integración con ese proveedor.

## Trazabilidad

* Issues: SCRUM-948 (DOC-19)
* Pull requests:
* Componentes del modelo C4 afectados: Módulo de Pagos y Transacciones (EP-07)
* Documentos que deben actualizarse: DD-MANI.md (modelo de datos de transacciones), documento de Riesgo del proyecto
* Subtareas de investigación asociadas: SCRUM-1022 (pagos/escrow), SCRUM-1023 (audit log inmutable)

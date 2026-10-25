# ADR-0024 — Modelo de custodia de pagos: el dinero lo custodia un operador de pagos regulado y MANI gestiona el estado

- **Estado:** Aceptado
- **Decisión de:** arquitectura de integración / cumplimiento regulatorio
- **Origen:** Definición del Product Owner anterior (Nicolás Redes) el 2026-09-21, tras el ADR-0023 que este absorbe. Rehecho el 2026-10-07 sobre la documentación vigente; reemplaza el PR #5.
- **Autor:** María Camila Beltrán Carreño
- **Revisor:** Sara Albarracín Niño
- **Fecha:** 2026-09-21
- **Jira:** DOC-19 (SCRUM-948)
- **Absorbe:** ADR-0023, «Riesgo regulatorio en la custodia de pagos (escrow) de EP-07» (2026-09-20, misma autora y revisora, DOC-19 / SCRUM-948), que registró el riesgo y detuvo la custodia hasta definir el modelo. Su análisis regulatorio se conserva íntegro en el contexto de abajo; el archivo se retiró el 2026-10-23 al consolidar el registro de decisiones.
- **Relacionado con:** ADR-0019, ADR-0022, SRS RF-24, RF-25, RNF-04, RNF-06, RNF-11, SAD §13, §23 y §24.2

## Contexto

### Riesgo regulatorio que originó la decisión

EP-07 (Pagos y facturación, SCRUM-450) incluye historias que suponen retener el dinero del cliente en garantía hasta liberarlo al aliado o reembolsarlo: US-07.1.4 Retención de fondos en garantía (SCRUM-891) y US-07.1.5 Liberación automática de fondos (SCRUM-892).

En Colombia, captar dinero del público en forma masiva y habitual sin autorización previa de la autoridad competente es delito (art. 316 del Código Penal, Ley 599 de 2000, modificado por la Ley 1357 de 2009), con prisión de 120 a 240 meses y multa de hasta 50.000 SMLMV. El Decreto 1981 de 1988 define cuándo la captación es masiva y habitual; uno de sus supuestos es que el pasivo con el público supere 20 personas o 50 obligaciones. **Si MANI retuviera los fondos en cuentas propias, en operación normal podría superar ese umbral.**

Además, los datos personales asociados a las transacciones están sujetos a la Ley 1581 de 2012 (Habeas Data), cuyo incumplimiento puede sancionarse por la Superintendencia de Industria y Comercio con multas de hasta 2.000 SMLMV. El equipo no identificó una norma que exija explícitamente un «audit log inmutable» para pagos entre particulares, pero sí necesita poder demostrar quién movió el dinero, cuándo y en qué estado, sin alteraciones posteriores. Esto coincide con lo que ya pide el SAD §13: en el segundo incremento las operaciones financieras requieren registro inmutable (US-07.1.2, SCRUM-889).

Ante ese riesgo, el 2026-09-20 se decidió **no implementar ni comprometer como alcance la lógica de custodia** (retención, liberación y reembolso) hasta que el Product Owner confirmara el modelo, y registrar el riesgo en el SAD §23 como «Custodia de pagos del segundo incremento». Las alternativas descartadas entonces fueron implementar la custodia directa —que expone al proyecto a la conducta del art. 316 sin autorización de la Superintendencia Financiera— e implementar un escrow simplificado definiendo la estructura legal después, que oculta el riesgo en vez de resolverlo.

### Lo que decidió el Product Owner

El Product Owner confirmó que MANI debe conocer el estado de cada pago, pero que la custodia real del dinero debe estar en una pasarela de pagos regulada. Las dos opciones que quedaron abiertas (intermediario tecnológico o control del estado) no eran excluyentes sino complementarias.

La documentación vigente ya apunta en esa dirección: el SRS exige que el modelo de pagos use un operador certificado (RNF-11) y que la responsabilidad PCI DSS recaiga en ese operador y no en MANI (RNF-06); el SAD §24.2 resuelve RF-24 con un "Adapter a operador de pagos" en el segundo incremento, y la wiki asigna RF-24..RF-28 a Core Service.

## Alternativas

1. **MANI custodia los fondos en cuentas propias, sin intermediario regulado.** Descartada: mantiene el riesgo de captación no autorizada del contexto y traslada a MANI la responsabilidad PCI DSS, contra RNF-06.
2. **MANI delega por completo el pago a la pasarela y no gestiona el estado del pago en su sistema.** Descartada: MANI necesita conocer el estado del pago para vincularlo a la solicitud, mostrar el detalle al aliado (US-07.2.2, SCRUM-894), liquidar con comisión (RF-25) y cumplir la auditabilidad del SAD §13 (RNF-04).
3. **Modelo híbrido: el operador de pagos regulado custodia el dinero y MANI gestiona el estado del pago.** Elegida.

## Decisión

**Usaremos un modelo híbrido: la custodia real del dinero queda a cargo de un operador de pagos regulado (por ejemplo, PayU o Wompi) y MANI gestiona el estado lógico del pago en su propio sistema. MANI nunca recibe ni retiene fondos de clientes en cuentas propias.**

Reglas que se derivan:
- La integración con el operador se hace mediante el Adapter a operador de pagos previsto en el SAD §24.2, dentro de Core Service.
- El operador concreto (PayU, Wompi u otro) no se elige en este ADR; se elige al refinar EP-07 en el segundo incremento.
- Cada cambio de estado de un pago se registra de forma inmutable, como exige el SAD §13 (US-07.1.2, SCRUM-889).
- Este ADR define **quién custodia el dinero**, no si MANI ofrecerá retención en garantía (escrow) ni liberación automática. Esas funciones (SCRUM-891, SCRUM-892) siguen sujetas a la decisión de alcance del segundo incremento, como indica `05-backlog/BACKLOG_MANI.md` §10.4. Si se aprueban, deben implementarse con los mecanismos de retención del operador, nunca con cuentas de MANI.

## Justificación

La alternativa 3 elimina el riesgo regulatorio principal sin perder el control que MANI necesita sobre el ciclo del servicio. Es coherente con los requisitos ya aprobados (RNF-06, RNF-11), con la arquitectura vigente (Adapter a operador de pagos, ADR-0019) y con ADR-0022, porque la lógica del estado del pago vive en un servicio y no en el cliente ni en la base de datos.

## Consecuencias

### Positivas
- Se controla el riesgo "Custodia de pagos del segundo incremento" (SAD §23): MANI no capta dinero del público.
- La responsabilidad PCI DSS queda en el operador certificado (RNF-06).
- Las historias de pagos del segundo incremento pueden refinarse con un modelo de custodia definido.

### Negativas
- **Dependencia externa:** costo por comisiones de transacción y dependencia de la disponibilidad y la API del operador. Mitigación: el Adapter aísla al dominio del proveedor concreto.
- **Ajuste del modelo de datos si se aprueba escrow:** hoy `pagos.pago` (`architecture/ModeloDatos.md`) admite los estados PENDIENTE, APROBADO, RECHAZADO y REVERSADO, y no tiene estados de retención o liberación. Si el escrow entra al alcance, `ModeloDatos.md` y `SDD.md` deben actualizarse en la historia correspondiente del segundo incremento.
- **Doble fuente de estado:** el estado del pago existe en MANI y en el operador. Mitigación: el estado en MANI se actualiza a partir de las respuestas del operador y se concilia con su referencia externa (`referencia_externa`).

## Condición de revisión

Revisar si:
- ningún operador regulado disponible en Colombia ofrece los mecanismos de retención que requiera el alcance aprobado del segundo incremento;
- MANI decide obtener una autorización regulatoria propia para custodiar fondos;
- cambia el marco regulatorio colombiano sobre captación o pagos electrónicos (art. 316 del Código Penal, Decreto 1981 de 1988 o Ley 1581 de 2012).

## Trazabilidad

| Elemento | Referencia |
|---|---|
| ADR relacionados | ADR-0019, ADR-0022 · absorbe ADR-0023 |
| Épica | EP-07 (SCRUM-450), postergada al incremento 2 en PO-02 (SCRUM-1077) |
| Historias afectadas | SCRUM-888, SCRUM-889, SCRUM-891, SCRUM-892, SCRUM-893, SCRUM-894 |
| Tarea relacionada | SCRUM-1026 |
| Subtareas de investigación | SCRUM-1022 (pagos y escrow), SCRUM-1023 (audit log inmutable) |
| Riesgo | SAD §23, "Custodia de pagos del segundo incremento" |
| Requisitos | RF-24, RF-25, RNF-04, RNF-06, RNF-11 |
| Documentos | `architecture/SAD.md` §13, §23 y §24.2; `architecture/ModeloDatos.md` §4.7; `architecture/SDD.md` |

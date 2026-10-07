# ADR-0023 — Riesgo regulatorio en la custodia de pagos (escrow) de EP-07

- **Estado:** Superseded
- **Sustituido por:** ADR-0024 (define el modelo de custodia que este ADR dejó pendiente)
- **Decisión de:** alcance funcional / cumplimiento regulatorio
- **Origen:** Sprint 2 Planning, hoja "1. Doc y Arquitectura" (2026-09-20). Rehecho el 2026-10-07 sobre la documentación vigente; reemplaza el PR #5.
- **Autor:** María Camila Beltrán Carreño
- **Revisor:** Sara Albarracín Niño
- **Fecha:** 2026-09-20
- **Jira:** DOC-19 (SCRUM-948)
- **Relacionado con:** ADR-0024, ADR-0019, SRS RF-24, RF-25, RNF-04, RNF-06, RNF-11, SAD §13 y §23

## Contexto

EP-07 (Pagos y facturación, SCRUM-450) incluye historias que suponen retener el dinero del cliente en garantía hasta liberarlo al aliado o reembolsarlo: US-07.1.4 Retención de fondos en garantía (SCRUM-891) y US-07.1.5 Liberación automática de fondos (SCRUM-892).

En Colombia, captar dinero del público en forma masiva y habitual sin autorización previa de la autoridad competente es delito (art. 316 del Código Penal, Ley 599 de 2000, modificado por la Ley 1357 de 2009), con prisión de 120 a 240 meses y multa de hasta 50.000 SMLMV. El Decreto 1981 de 1988 define cuándo la captación es masiva y habitual; uno de sus supuestos es que el pasivo con el público supere 20 personas o 50 obligaciones. Si MANI retuviera los fondos en cuentas propias, en operación normal podría superar ese umbral.

Además, los datos personales asociados a las transacciones están sujetos a la Ley 1581 de 2012 (Habeas Data), cuyo incumplimiento puede sancionarse por la Superintendencia de Industria y Comercio con multas de hasta 2.000 SMLMV. El equipo no identificó una norma que exija explícitamente un "audit log inmutable" para pagos entre particulares, pero sí necesita poder demostrar quién movió el dinero, cuándo y en qué estado, sin alteraciones posteriores. Esto coincide con lo que ya pide el SAD §13: en el segundo incremento las operaciones financieras requieren registro inmutable (historia US-07.1.2, SCRUM-889).

Al momento de este ADR, el equipo no sabía si MANI retendría los fondos directamente o si operaría solo como intermediario tecnológico sobre un operador de pagos regulado.

## Alternativas

1. **Implementar la custodia directa de fondos (el dinero del cliente queda en una cuenta propia de MANI).** Descartada: expone al proyecto a la conducta del art. 316 si no se cuenta con autorización de la Superintendencia Financiera.
2. **Implementar el escrow con un modelo simplificado y definir la estructura legal después.** Descartada: oculta el riesgo en vez de resolverlo y puede obligar a rediseñar el modelo de pagos más adelante.
3. **Registrar el riesgo y no implementar ni comprometer la lógica de custodia hasta que se defina el modelo.** Elegida.

## Decisión

**MANI no implementa ni compromete como alcance la lógica de custodia de fondos (retención, liberación y reembolso) hasta que el Product Owner confirme el modelo de custodia de pagos.** El riesgo se registra en el SAD §23 como "Custodia de pagos del segundo incremento".

## Justificación

Detener solo la parte de custodia evita construir una funcionalidad que podría requerir reestructuración legal y técnica, y permite que el resto del trabajo siga avanzando. La decisión es coherente con la documentación vigente: el SRS asigna los pagos a un operador certificado (RNF-06, RNF-11) y la wiki de transición del backlog (`wiki/06-backlog/transicion-v4.md`) establece que el escrow y la liberación automática no se asumen como alcance aprobado sin decisión funcional o regulatoria.

## Consecuencias

### Positivas
- Se evita construir custodia de dinero que podría requerir reestructuración legal.
- El riesgo queda visible en el SAD y trazable a las historias afectadas.

### Negativas
- Las historias que dependen del modelo de custodia (SCRUM-891, SCRUM-892) no pueden refinarse hasta tener la decisión.

## Condición de revisión

Este ADR queda sustituido por ADR-0024, que define el modelo de custodia. Se reabre si ADR-0024 se revierte o si cambia el marco regulatorio colombiano sobre captación o pagos.

## Trazabilidad

| Elemento | Referencia |
|---|---|
| ADR relacionados | ADR-0024, ADR-0019 |
| Épica | EP-07 (SCRUM-450), postergada al incremento 2 en PO-02 (SCRUM-1077) |
| Historias afectadas | SCRUM-889, SCRUM-891, SCRUM-892 |
| Subtareas de investigación | SCRUM-1022 (pagos/escrow), SCRUM-1023 (audit log inmutable) |
| Riesgo | SAD §23, "Custodia de pagos del segundo incremento" |
| Requisitos | RF-24, RF-25, RNF-04, RNF-06, RNF-11 |
| Documentos | `architecture/SAD.md` §13 y §23 |

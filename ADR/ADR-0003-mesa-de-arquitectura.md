# ADR-0003 · Mesa de Arquitectura: terminología única, Arquitecto transversal y rotación de ADR

- **Estado:** Aceptado
- **Fecha:** 2026-08-17 (Mesa de Arquitectura)
- **Redactor asignado:** Nicolás León (rol secundario DevOps) — 🔴 ver PREGUNTA en README
- **Decisión de:** proceso / gobierno técnico

## Contexto

El mismo espacio de decisión aparecía con nombres distintos ("Comité de Arquitectura" en la
presentación, "Mesa Técnica" en el Marco de Decisiones). La responsabilidad de los ADR estaba
concentrada en una sola persona (el Scrum Master), lo que es un error de rol: el SM no debe
ser dueño del contenido de las decisiones técnicas.

## Decisión

1. **Terminología única: "Mesa de Arquitectura".** Se eliminan "Comité de Arquitectura",
   "Comité Técnico", "Mesa Técnica de Arquitectura" y equivalentes.
2. **El rol de Arquitecto es transversal:** todos los integrantes técnicos son Arquitectos y
   forman parte de la Mesa de Arquitectura, independientemente de su rol principal o secundario.
   No es responsabilidad exclusiva de una persona.
3. **La autoría del ADR rota** entre los integrantes en cada Mesa. La persona asignada:
   redacta el ADR, lo guarda en `.md`, lo ubica en `/docs/adr/` (GitHub) y verifica que lo
   registrado corresponda a lo aprobado.
4. Reglas de operación de la Mesa (heredadas de la presentación TRAMA, ratificadas):
   preparación con ficha 24 h antes y mínimo dos alternativas reales; quórum de 5 de 7;
   un integrante argumenta en contra; el disenso queda documentado; ningún acuerdo se
   aprueba sin alternativas ni sin el requisito que lo justifica.

## Alternativas evaluadas

1. **Un único responsable permanente de ADR (SM).** Descartada: concentra autoridad técnica
   en un rol que no la debe tener y crea un cuello de botella.
2. **Sin reglamento formal de la Mesa.** Descartada: sin quórum ni contradictor, las
   decisiones no son defendibles ante el cliente-auditor.
3. **Mesa de Arquitectura con Arquitecto transversal y rotación de ADR.** **Elegida.**

## Trade-off asumido

La rotación exige que todos aprendan a redactar ADR con calidad homogénea; se acepta una
curva de aprendizaje a cambio de repartir el conocimiento arquitectónico en el equipo.

## Consecuencias

- El Gobierno del Equipo usa solo "Mesa de Arquitectura".
- La tabla de roles marca "Arquitecto" como responsabilidad transversal de todo el equipo técnico.
- Después de cada Mesa técnica se produce el/los ADR correspondientes.

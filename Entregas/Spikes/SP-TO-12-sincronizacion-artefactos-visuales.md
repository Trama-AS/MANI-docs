# SP-TO-12 — Sincronización de artefactos visuales y de modelado

- **Trade-off que resuelve:** TO-12 (nuevo) — QS-18 (Analizabilidad de la documentación)
  vs. DR-11 (gestión documental centralizada)
- **Decisiones afectadas:** ADR-0020 (Canva + Figma + Excalidraw + Draw.io), ADR-0024
  (framework de modelado híbrido C4 + UML + BPMN en Miro + MER), ADR-0008 (carpeta de
  diagramas), ADR-0007 (documentación en el repositorio)
- **Evidencia hoy:** ninguna. Ambos ADR asumen el mismo trade-off por separado —ADR-0020
  "fragmentación del ecosistema de documentación visual en cuatro plataformas", ADR-0024
  "documentación fragmentada en distintas herramientas, exige disciplina"— y ninguno mide
  cuántos artefactos quedan efectivamente desincronizados. Suman **seis** herramientas
  externas, Miro incluida, que ADR-0020 ni siquiera menciona.
- **Ticket Jira:** pendiente de creación (Sprint 2)
- **Timebox:** 3 h
- **Responsable propuesto:** Scrum Master con Frontend Lead
- **Sprint destino:** 2

## 1. Pregunta que responde

¿Cuántos artefactos visuales del repositorio están desactualizados respecto de su fuente
editable, y cuánto tarda el equipo en detectar que uno lo está?

## 2. Hipótesis que se pone a prueba

La disciplina de exportación manual que ambos ADR asumen no se sostiene sin un control
automático, y la fracción de artefactos desincronizados es medible hoy mismo.

## 3. Métrica y criterio de decisión

| Métrica | Umbral | Cómo se mide |
| --- | --- | --- |
| Artefactos en `/Diagramas` con fuente editable enlazada | 100 % | Inventario de la carpeta contra los ADR |
| Artefactos desactualizados respecto de su fuente | Se registra | Comparación con la última versión en la herramienta de origen |
| Herramientas externas efectivamente en uso | Se registra | Inventario real (ADR-0020 declara 4; ADR-0024 añade Miro) |
| Artefactos versionados como texto (`.mmd`, `.drawio`) | Se registra | ADR-0008 exige Mermaid versionado como texto |

Criterio de decisión: si más del 20 % de los artefactos está desincronizado, la disciplina
manual no basta y hace falta un ADR que fije una única fuente de verdad por tipo de diagrama
con verificación en CI.

## 4. Alcance

**Incluye:** `Diagramas/` completo y los enlaces a fuentes externas declarados en los ADR.

**No incluye:** reemplazar herramientas (ADR-0020 y ADR-0024 ya decidieron cuáles).

## 5. Método

1. Inventariar `Diagramas/` y marcar cada archivo con su herramienta de origen y su enlace.
2. Marcar los que no tienen enlace: esos ya son deuda, sin necesidad de comparar.
3. Para los que sí lo tienen, comparar fechas de última modificación.

## 6. Qué desbloquea

- Unifica en un solo trade-off (TO-12) lo que hoy está declarado por separado y sin medir en
  ADR-0020 y ADR-0024.
- ADR destino: ADR de fuente única por tipo de diagrama, solo si el inventario lo justifica.

## 7. Riesgo si no se ejecuta

ADR-0024 declara que el SAD debe enlazar los tableros de Miro y los repositorios de
diagramas. Sin inventario, ese enlace se escribe una vez y nadie sabe cuándo deja de ser
cierto.

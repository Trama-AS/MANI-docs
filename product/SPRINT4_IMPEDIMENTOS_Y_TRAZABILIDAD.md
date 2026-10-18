# Sprint 4 — Impedimentos, capacidad y trazabilidad Jira ↔ GitHub ↔ pruebas

**Entregable:** SM4-02 (SCRUM-1243) · **Corte de datos:** 2026-10-18

Todo lo que sigue sale de Jira y del repositorio `MANI-Docs`. Donde Jira no registra la causa de un
bloqueo, este documento lo dice así en lugar de inferirla: una causa inventada convierte el
seguimiento de impedimentos en ficción.

---

## 1. Impedimentos vigentes

**Fuente:** Jira, estado `blocked` dentro del sprint abierto. Son 6 de 53 ítems (11%).

| Ítem | Responsable | Qué está detenido | Causa registrada en Jira |
|---|---|---|---|
| SCRUM-862 | José Nicolás Álvarez | US-04.1.3 — Filtrar por tipo de aliado | **no registrada** |
| SCRUM-1060 | José Nicolás Álvarez | US-02.1.2-M3 — Migración del datasource de registro | **no registrada** |
| SCRUM-1104 | Juan Sebastián Álvarez | CFG-23b — Versionar y aplicar políticas RLS | **no registrada** |
| SCRUM-1251 | José Nicolás Álvarez | DOC4-08 — Presentación del Sprint 4 | **no registrada** |
| SCRUM-1252 | Daniel Ávila | DOC4-09 — Demo técnico del incremento | **no registrada** |
| SCRUM-1257 | María Camila Beltrán | PO4-02 — Criterios de aceptación y DoD | **no registrada** |

### Lo que esto significa

**Ningún impedimento tiene causa registrada.** Seis ítems están en `blocked` sin que Jira diga
quién o qué los desbloquea. Un estado `blocked` sin bloqueador anotado no es gestionable: no se
puede escalar, no se puede fechar y no aparece en ninguna métrica de espera.

**Dos de los seis son la Review misma.** DOC4-08 (presentación) y DOC4-09 (demo) están bloqueados.
Si no se liberan, el sprint no tiene cierre demostrable, con independencia de cuánto código esté
terminado. Son los dos que hay que atender primero.

**Un tercero bloquea evidencia de seguridad.** CFG-23b aplica las políticas RLS del nuevo modelo de
identidad. Mientras no entre, la acreditación de aislamiento multi-tenant de ADR-0015 queda
apoyada en el modelo anterior.

### Acción propuesta

Que cada responsable anote en su ítem, antes de la próxima daily: **qué espera, de quién y desde
cuándo**. Sin eso, el seguimiento de impedimentos del Sprint 5 arranca igual de ciego.

---

## 2. Capacidad y distribución

**Fuente:** Jira, mismo corte. El detalle por estado está en SM4-01 (SCRUM-1242) §2.

| Persona | Ítems asignados | En curso | Bloqueados | Terminados |
|---|---|---|---|---|
| nicolas leon | 12 | 11 | 0 | 0 |
| Juan Sebastián Álvarez | 10 | 1 | 1 | 4 |
| Sara Albarracín | 8 | 5 | 0 | 2 |
| Daniel Ávila | 7 | 1 | 1 | 5 |
| Santiago | 6 | 5 | 0 | 1 |
| José Nicolás Álvarez | 6 | 1 | 3 | 2 |
| María Camila Beltrán | 4 | 1 | 1 | 2 |

**Riesgo de concentración.** Nicolás León tiene 11 ítems abiertos a la vez y ninguno cerrado: es el
44% de todo el trabajo en curso del equipo. Es el patrón típico de trabajo que no termina porque se
empieza más rápido de lo que se cierra, y conviene tratarlo en la retrospectiva como límite de
trabajo en curso, no como asunto de desempeño individual.

---

## 3. Trazabilidad Jira ↔ GitHub

**Convención vigente:** ADR-0025 exige `[SCRUM-<id>]` en el título del PR.

| Indicador | Valor |
|---|---|
| PR totales | 42 |
| Con clave `[SCRUM-<id>]` | 30 — **71%** |
| Sin clave | 12 — **29%** |

### PR sin clave

| PR | Estado | Título |
|---|---|---|
| #33 | abierto | Documenta columnas y restricciones de cliente, sitio.reglas… |
| #31 | fusionado | Reorganiza diagramas a la estructura de ADR-0008 |
| #30 | fusionado | Arregla la legibilidad y el referenciado de las figuras |
| #25 | fusionado | Consolida la documentación y elimina contradicciones |
| #24 | fusionado | C4: panorama, vistas dinámicas y secuencias |
| #20 | fusionado | La fase 9 citaba CFG-31 y CFG-32, que no existen |
| #19 | fusionado | Historias de regresión de EP-02 |
| #18 | fusionado | Retirar la numeración KI y alinear la wiki |
| #10 | fusionado | Informe Inf_test-002 de la promoción develop a release |
| #2 | fusionado | Diagrama de secuencia de exclusión mutua |
| #5 | cerrado | ADR-0025 on regulatory risks for escrow payments |
| #1 | cerrado | Add files via upload |

**Corrección propuesta, en dos tiempos.** Lo fusionado no se reescribe: el historial de Git es
evidencia y renombrar commits fusionados rompe referencias. Lo que sí se puede hacer:

1. **#33, que está abierto**, se renombra antes de fusionar. Es el único caso corregible sin costo.
2. Para lo ya fusionado, enlazar el PR desde el ítem de Jira correspondiente cuando exista, y
   aceptar como deuda registrada los que nacieron sin ítem.
3. Hacer la convención verificable: la plantilla de PR y CODEOWNERS ya existen (SCRUM-1114, PR #12);
   falta un control que falle el PR sin clave, que es trabajo de CI y no de disciplina.

---

## 4. Trazabilidad hacia pruebas

**Fuente:** artefactos de QA fusionados en `MANI-Docs`.

| Evidencia | Artefacto | Ítem |
|---|---|---|
| Matriz de pruebas del Sprint 4 | `product/MANI_Matriz_Pruebas_Sprint4.xlsx` | SCRUM-1264, PR #32 |
| Cadena de calidad operativa (Sonar, Newman, Playwright) | `product/GUIA_OPERATIVA_CALIDAD_QA_CFG4-03.md` | CFG4-03 |
| Auditoría y aceptación de DEV y QA | `product/ACTA_AUDITORIA_DEV_QA_CFG4-01.md` | CFG4-01 |
| Aislamiento cross-tenant | `product/REPORTE_QA_CFG-23c.md` | SCRUM-1105, PR #28 |
| Paridad de las historias migradas de EP-02 | `product/PLAN_PRUEBAS_EP-02_MIGRACION.md` | SCRUM-1094, PR #15 |
| Estado de Sonar del Core | `governance/INFRAESTRUCTURA_MANI.md` | SCRUM-1116, PR #29 |

**Hueco de trazabilidad.** Las tareas de QA del sprint —QA4-02 (SCRUM-1265), QA4-03 (SCRUM-1266) y
QA4-04 (SCRUM-1267)— no tienen todavía un artefacto de resultados en el repositorio. La matriz de
pruebas existe; los resultados de su ejecución, no. Hasta que existan, el Quality Gate del Sprint 4
no es verificable desde la documentación.

---

## 5. Qué falta para cerrar este entregable

1. Que los seis impedimentos tengan causa, bloqueador y fecha en Jira (§1).
2. Renombrar #33 antes de fusionar y decidir si se añade el control de CI de la convención (§3).
3. Publicar los resultados de QA4-02, QA4-03 y QA4-04 para cerrar el hueco de §4.

# DOC-14 — Mesa de Arquitectura del 2026-09-22

**Qué cierra DOC-14:** los trade-offs del SAD actualizados con la evidencia que los
respalda, y los ADR nuevos del Sprint 2 consolidados en la sección 3.

**Qué trae esta sesión a la Mesa:** siete decisiones que requieren acuerdo colegiado, y la
priorización de once spikes abiertos que suman 57 h de timebox.

**Preparado por:** Sara Albarracín (Scrum Master) · **Insumos:** `Product/SAD-MANI.md` §3 y
§6, `Entregas/Spikes/`, `Entregas/PoC/PoC-001-exclusion-concurrente-aceptacion.md`

---

## 1. El hallazgo de fondo

El SAD declaraba ocho trade-offs, cada uno con una decisión tomada. **Solo uno de ellos
estaba respaldado por una medición.** Los demás se sostenían en razonamiento —legítimo,
pero no verificable— o en nada.

Al revisar los ADR del Sprint 2 aparecieron además cuatro tensiones que ya estaban
declaradas en prosa dentro de los ADR y que la sección 6 nunca recogió. Con esas, el SAD
pasa de 8 a 12 trade-offs.

| Nivel de evidencia | Cuántos | Cuáles |
| --- | --- | --- |
| **Empírica** (medición con umbral y control) | 1 | TO-03 |
| **Adversa** (la evidencia contradice la decisión vigente) | 1 | TO-06 |
| **Documental** (trazada a un ADR, sin medición) | 4 | TO-09, TO-10, TO-11, TO-12 |
| **Ninguna** | 6 | TO-01, TO-02, TO-04, TO-05, TO-07, TO-08 |

El único trade-off con evidencia empírica es TO-03, y lo es porque PoC-001 se ejecutó la
semana pasada. El patrón es claro: el equipo decide bien y mide poco.

---

## 2. Decisiones que la Mesa debe tomar hoy

### D-01 — Ratificar la numeración de ADR

Hay dos documentos que han sido llamados "ADR-0021": la exclusión concurrente
(`ADR-0021-exclusion-concurrente-despacho.md`) y el stack sin Azure, cuyo archivo es
`ADR-0023-...` pero cuyo título interno dice "ADR-002". El README usa "ADR-0021" para el
segundo.

**Propuesta:** adoptar la numeración de los nombres de archivo — 0021 = exclusión
concurrente, 0023 = stack sin Azure. El SAD ya quedó corregido bajo esa lectura (doce
referencias). Falta corregir el título interno de ADR-0023 y el README.

**Qué se pide:** un sí o un no. Si es no, hay que renumerar el archivo y rehacer las doce
referencias.

### D-02 — Pasar ADR-0021 de Propuesto a Aceptado

PoC-001 midió el mecanismo: 1 asignación de 50 aceptaciones simultáneas, 0 dobles, contra
un control negativo que bajo idéntica carga produjo 10 asignaciones en 136 ms. Cumple
RNF-05 y refuerza RNF-03.

**Bloqueantes de gobernanza, no de evidencia:** el ADR no tiene revisor asignado y la
autoría no rotó (ADR-0003 lo exige).

**Propuesta:** aceptarlo hoy, asignando revisor en la sesión, con el residual declarado
(SP-TO-03: comportamiento por encima del pool de PostgREST y caída de base sin cola).

### D-03 — Qué hacer con TO-06, que tiene evidencia adversa

El hallazgo H-02 de PoC-001 demostró que `tenant_isolation_solicitud` tiene
`roles = {public}`: aísla por tenant pero no restringe el rol. Un usuario con rol `cliente`
puede autoasignarse cualquier solicitud de su tenant. `DD-MANI.md` §5.4 dice que ese
endpoint es solo del rol `aliado`.

TO-06 acepta deliberadamente concentrar la autorización en RLS "a cambio de no duplicar
lógica". Aceptar un riesgo concentrado es legítimo; aceptarlo sin saber que el mecanismo no
expresa el rol, no.

**Qué se pide:** abrir el ticket de H-02 con responsable y priorizar SP-TO-06 (¿ocurre lo
mismo en los canales de Realtime?). La decisión de TO-06 no se revierte hoy: se condiciona.

### D-04 — TO-07 no tiene dueño

Es el único trade-off del SAD sin ADR y sin decisión: "se deja como tensión abierta para que
la Mesa la resuelva junto con el diseño de UX". Lleva así desde la V1.

**Propuesta:** asignar dueño (Frontend Lead + PO) y ejecutar SP-TO-07, que termina en un ADR
de configuración por defecto. Si la Mesa prefiere cerrarlo por criterio sin medir, que quede
como decisión fechada y no como tensión abierta indefinida.

### D-05 — Revisores faltantes (Gobierno del Equipo §2.6, punto 7)

ADR-0022 (`<Pendiente por asignar>`) y ADR-0024 (campo vacío) están en estado
Aceptado/Aprobado sin revisor. ADR-0021 tampoco lo tiene.

**Qué se pide:** asignar los tres en la sesión. Es el checklist de cierre que el propio
Gobierno exige y que KI-10 ya registra como abierto para ADR-0016/0017.

### D-06 — Priorización de los spikes

Once spikes, 57 h. No caben en el Sprint 2. Propuesta de corte por riesgo, no por costo:

| Orden | Spike | h | Por qué primero |
| --- | --- | --- | --- |
| 1 | SP-TO-06 | 6 | Único con evidencia adversa ya en mano; toca seguridad (DR-01) |
| 2 | SP-TO-03 | 8 | Cierra el residual de la única decisión que hoy puede pasar a Aceptado |
| 3 | SP-TO-01 | 6 | Tensiona el driver innegociable (DR-01) contra un atributo de prioridad Alta (QS-08) |
| 4 | SP-TO-05 | 4 | 4 h y cierra dos trade-offs (TO-05 y TO-08) |
| — | Resto (SP-TO-02, 04, 07, 09, 10, 11, 12) | 33 | Sprint 3 |

Corte propuesto para Sprint 2: **24 h**.

### D-07 — Huecos de cobertura que quedan declarados

- **AC-12 (Modularidad) y AC-14 (Portabilidad) no tienen escenario de calidad propio en §5**,
  y TO-09 y TO-10 se tensionan contra ellos. O se escriben los escenarios, o se acepta que
  esos dos trade-offs no son verificables contra un umbral.
- El README marca ADR-0014 y ADR-0015 como "Aceptado"; los archivos dicen "Propuesto".
- El SAD tiene **dos secciones numeradas "7"** (Arquitectura de Negocio y Vista de
  Contenedores). Defecto de edición anterior a DOC-14; se corrige al renumerar.

---

## 3. Del spike al ADR — qué produce cada uno

| Spike | ADR destino |
| --- | --- |
| SP-TO-01 | Nota de alcance sobre ADR-0012 (plan de indexación) si el delta supera el 20 % |
| SP-TO-02 | ADR nuevo solo si aparece una configuración dentro de un predicado RLS |
| SP-TO-03 | Cierra el residual de ADR-0021; ADR de cola de reintento solo si la corrida lo justifica |
| SP-TO-04 | Nota de alcance sobre ADR-0006 si hay que recortar instrumentación |
| SP-TO-05 | ADR de ejecución selectiva en CI si la proyección supera 10 min |
| SP-TO-06 | ADR de autorización de canal separada de RLS si aparece suscripción con rol incorrecto |
| SP-TO-07 | **ADR nuevo** de configuración por defecto (hoy no existe ninguno) |
| SP-TO-09 | ADR de trazabilidad distribuida (`correlation-id`) como complemento de ADR-0018 |
| SP-TO-10 | Indirección sobre `auth.jwt()`; cierra además el revisor de ADR-0022 |
| SP-TO-11 | Aporta el dato que falta a KI-03 para cerrar el "cómo" del hosting |
| SP-TO-12 | ADR de fuente única por tipo de diagrama si >20 % está desincronizado |

Ningún spike produce un ADR por obligación: cada uno declara el umbral a partir del cual la
decisión vigente deja de sostenerse. Si el umbral no se cruza, el resultado se anexa al
trade-off y el ADR actual queda respaldado — que es exactamente lo que pide DOC-14.

---

## 4. Estado de DOC-14 al abrir la sesión

| Entregable | Estado |
| --- | --- |
| SAD §6 con nivel de evidencia por trade-off (Tabla D) | ✅ Hecho |
| TO-09 a TO-12 incorporados desde los ADR del Sprint 2 | ✅ Hecho |
| SAD §3 con los 24 ADR consolidados | ✅ Hecho |
| Numeración ADR-0021/0023 corregida en el SAD | ✅ Hecho — pendiente de ratificar (D-01) |
| Once spikes definidos con métrica y umbral | ✅ Hecho — ninguno ejecutado |
| README y título interno de ADR-0023 corregidos | ⏳ Depende de D-01 |
| Tickets Jira de los spikes | ⏳ Se crean tras la priorización (D-06) |

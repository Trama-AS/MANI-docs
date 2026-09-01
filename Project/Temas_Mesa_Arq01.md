# Temas para Mesa de Arquitectura y Planning Sprint 1

- **Fecha de elaboración:** 2026-08-23
- **Origen:** revisión de consistencia de toda la documentación (Perfil de Proyecto, ADR-0001..0006,
  Análisis de Requerimientos, SRS, Product Backlog, Gobierno del Equipo, Matriz de Herramientas).
- **Uso:** insumo de agenda, no reemplaza la ficha de 24h que exige ADR-0003/Gobierno §1.3.3 para
  cada punto que vaya a Mesa.

> 🔴 = decisión abierta que ningún documento resuelve todavía.

---

## 1. Bloqueante mayor — alcance de Java+.NET (requerimiento de proyecto) sin ratificar

Java y .NET **no son una alternativa a evaluar** — son requerimiento de proyecto (constraint
externo) confirmado por el equipo: el proyecto exige usarlos en algún módulo del backend. Ya
quedó registrado como **PROY-07** en Análisis de Requerimientos. Lo que sigue abierto no es
"cuál stack", sino el **alcance exacto**: Matriz_de_Herramientas.md todavía lista **NestJS**
en "Evaluar", ligado al spike **SP-01.1.1** (aislamiento multi-tenant, crítico, bloquea
Sprint 1), sin que ningún documento diga si NestJS sigue vigente para algún módulo adicional
o si el backend completo queda cubierto por Java+.NET.

**Por qué es fundamental para el diseño del sistema:** el modelo de aislamiento multi-tenant
(RNF-01, driver arquitectónico crítico) y la estrategia de persistencia (MongoDB vs. Supabase,
incompatibilidad #1 de la Matriz) dependen de en qué runtime(s) se implementan. No se puede
empezar SAD/DD (entregable de Sprint 1) sin saber si hay dos backends, tres, o si NestJS queda
fuera.

**Por qué es fundamental para Planning Sprint 1:** US-01.1.1 y US-01.2.1 (candidatas a Sprint 1)
dependen de SP-01.1.1 y SP-01.2.1. Si esos spikes siguen apuntando a NestJS sin ajustarse a
Java+.NET, hay que re-dirigirlos antes de estimar.

**Decisión que la Mesa debe tomar:**
- ¿Qué módulo(s) del backend van en Java y cuáles en .NET (confirma el reparto de ADR-0004:
  Repo B Java, Repo C .NET)?
- ¿NestJS sigue vigente para algún módulo, o se retira del Tech Radar?
- Redirigir SP-01.1.1 y SP-01.2.1 al stack confirmado antes de que alimenten SAD/DD.
- Verificar que el equipo (2 personas con rol Backend: Alviz principal, Daniel Ávila secundario)
  alcanza para mantener dos stacks backend en paralelo.

---

## 2. Observabilidad — sigue pendiente, no cerrada

Aunque el texto de ADR-0006 propone Prometheus + Grafana + Datadog, el equipo confirma que la
decisión de observabilidad **sigue pendiente en la práctica**. No tratarla como cerrada en
ningún documento ni en Planning hasta que la Mesa la ratifique explícitamente. OpenTelemetry se
mantiene en "Evaluar" mientras tanto.

**Para Mesa:** ratificar (o reabrir con alternativas reales, si hay objeción de fondo) la
elección de herramienta de observabilidad — con spike si hace falta, dado que ninguno se
asignó todavía.

**Para Sprint 1:** no comprometer trabajo de instrumentación (Prometheus/Datadog u otra) en el
Planning hasta que esto se cierre; si se cierra a tiempo, convertirlo en historia/task técnica
antes de estimar.

---

## 3. Terminología de ambientes: DEV/QA/PROD vs. Devs/Test/Prod

Gobierno del Equipo usa **DEV, QA, PROD**; ADR-0004/0005/0006 usan **Development (Devs), Testing
(Test), Production (Prod)** — misma secuencia de tres ambientes, nombres distintos en cada
artefacto (mismo tipo de ambigüedad que ADR-0003 ya resolvió una vez para "Mesa de
Arquitectura").

**Ya asignado (2026-08-23):** Daniel Ávila (DevOps titular) prepara la propuesta de nomenclatura
única.

**Para Mesa:** ratificar la propuesta de Daniel antes de que el instructivo de configuración y
los workflows de GitHub Actions queden escritos con nombres que no calzan entre sí.

---

## 4. Kubernetes — confirmado obligatorio; falta el ADR de configuración concreta

**Resuelto (2026-08-23):** Kubernetes es requisito del profesor (curricular) — registrado como
**PROY-08**. Ya no depende de un driver de atributo de calidad del producto; la incompatibilidad
#4 de la Matriz de Herramientas queda cerrada en el "¿si?".

**Lo que sigue abierto es el "¿cómo?":** ADR-0004 promueve contenedores a Azure sin decir cómo
se orquestan en Prod. Con Azure ya fijado, el candidato natural es **AKS**, pero falta el ADR
formal que fije distribución, tamaño/número de nodos y estrategia de escalado — dimensionamiento
que depende a su vez de RNF-07 (punto 6).

**Para Mesa:** producir el ADR de configuración de Kubernetes/AKS antes de que DevOps despliegue
a Prod.

---

## 5. Titularidad DevOps — cerrada

**Resuelto (2026-08-23):** Daniel Ávila es DevOps **titular** para toda decisión de
repositorio/CI-CD/release; Nicolás León (DevOps secundario) apoya sin ser titular. Gobierno del
Equipo §1.1.1 ya no tiene esta pregunta abierta — queda alineado con lo que ADR-0004/0006 ya
asumían.

---

## 6. RNF-07 — explicado y aclarado, sigue sin umbral numérico

RNF-07 no es un simple "requisito de rendimiento menor" pese a su prioridad de backlog **Media**:
cubre tres cosas concretas — (a) múltiples clientes creando solicitudes y consultando aliados
válidos a la vez (RF-12/RF-13); (b) múltiples aliados intentando aceptar la misma solicitud en la
misma ventana (RF-14, acoplado directo a RNF-05: el despacho debe resolver eso en exactamente una
asignación); y (c) mensajería/notificaciones concurrentes por servicio en curso (RF-20). La
prioridad **Media** mide orden de atención en el backlog, no severidad de riesgo de diseño — por
eso el Análisis de Requerimientos ya lo señala aparte como candidato a **riesgo crítico de
diseño**: si el modelo de datos no soporta bien esta concurrencia desde el inicio, RNF-05 se
vuelve imposible de cumplir sin rediseñar. El detalle completo ya quedó documentado en Análisis
de Requerimientos §5.

**Lo que sigue sin resolver:** no hay umbral numérico (cuántos tenants, cuántas solicitudes/usuarios
concurrentes esperados al lanzamiento). Sin ese dato no se puede dimensionar ni el modelo de
concurrencia ni el tamaño real del clúster de Kubernetes/AKS (punto 4) ni el tier de base de
datos — y con ADR-0004/0005/0006 ya construyendo infraestructura real en Azure, seguir sin este
dato encarece cada sprint que pasa sin resolverlo.

**Para Mesa:** (a) decidir si RNF-07 se eleva a prioridad Alta para diseñarse junto con
RNF-01/02/03/05 desde Sprint 1; (b) definir con quién y cómo se obtiene el umbral real del cliente
(¿lo tiene el PO? ¿requiere spike de negocio, no solo técnico?) — no siga como vacío indefinido.

---

## 7. Presupuesto de producto — actualizado

**Hecho (2026-08-23):** Perfil_de_Proyecto_MANI.md §7 ya incorpora Azure, SonarQube, OWASP ZAP,
Kubernetes/AKS, Azure Container Registry, Prometheus, Grafana y Datadog, con fuentes citadas.
Persisten dos rangos abiertos porque dependen de decisiones aún no tomadas: **persistencia**
(MongoDB vs. Supabase, SP-01.1.1) y **observabilidad** (punto 2). La cifra de Azure Container
Registry es una estimación sin confirmar en calculadora Azure — DevOps debe validarla antes de
comprometer presupuesto en firme.

---

## 8. Estructura de los ADR y sección de Trazabilidad — llevar a Mesa como punto de agenda

Ningún ADR (0001–0006) incluye la sección **Trazabilidad** que exige la plantilla
(ADR-NNN-titulo.md) y el checklist de Gobierno §2.6 (issues, PRs, componentes C4, documentos a
actualizar). Por regla propia del equipo ("un ADR no se borra ni se edita"), esto no se corrige
retroactivamente en los ADR existentes.

**Para Mesa — decisión explícita a tomar (no solo un recordatorio):**
- ¿La sección Trazabilidad se mantiene obligatoria en la plantilla, o se ajusta la plantilla
  para reflejar lo que el equipo realmente puede sostener cada Mesa?
- Si se mantiene: ¿aplica solo hacia adelante (próximos ADR desde Sprint 1) o se documenta
  también la trazabilidad de los ADR 0001–0006 en un artefacto aparte (sin editar los ADR
  mismos)?

Adicional — higiene editorial menor, no requiere ADR nuevo, corregir la próxima vez que se
toque cada archivo:
- ADR-0002: falta espacio en el título (`ADR-0002·` → `ADR-0002 ·`).
- ADR-0005: "Daniel Avila" sin tilde (inconsistente con "Daniel Ávila" en el resto de ADR).

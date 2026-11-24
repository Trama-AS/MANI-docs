# Acta de Cierre — Proyecto MANI

[← 06 · Gobernanza](README.md) · [Entrega final](ENTREGA_FINAL.md) · [Índice de la wiki](../Home.md)

| | |
|---|---|
| **Proyecto** | MANI: plataforma SaaS multi-tenant para formalizar operaciones de servicio |
| **Equipo** | TRAMA, Ingeniería de Software |
| **Fecha de la sesión** | [completar en la sesión] · entrega final: martes 25 de noviembre de 2026 |
| **Medio** | [completar en la sesión] |
| **Facilita y redacta** | Sara Albarracín (Scrum Master) |
| **Acepta y firma** | Camila Beltrán (Product Owner) |
| **Corte de las cifras** | 24 de noviembre de 2026. Se actualizan el día de la firma con las consultas de la §4 |

> **Cómo se usa este documento.** La redacción y las cifras están completas. Lo que está entre corchetes lo llena la sesión de cierre: fecha, medio, asistencia, las decisiones que se tomen y las firmas. Nada de lo que se afirma aquí se inventa: cada cifra tiene su fuente en la §4.

## 1. Objeto

Dejar constancia de que el proyecto MANI se cierra, de qué se entrega, de qué **no** se entrega y de los riesgos que el equipo y la PO aceptan al cerrar. Con esta acta la PO acepta el incremento final y el equipo da por terminado el desarrollo.

## 2. Asistentes

| Integrante | Rol en el proyecto | Asistió |
|---|---|---|
| Camila Beltrán | Product Owner | [ ] |
| Sara Albarracín | Scrum Master | [ ] |
| Santiago Hernández | QA | [ ] |
| Daniel Ávila | DevOps | [ ] |
| Juan Sebastián Álvarez | Backend | [ ] |
| Nicolás Álvarez | Frontend | [ ] |
| Nicolás León | DevOps secundario | [ ] |

## 3. Qué se entrega

Los ocho entregables de la entrega final están indexados en [`ENTREGA_FINAL.md`](ENTREGA_FINAL.md):

1. Despliegue de componentes en QA.
2. Informe de pruebas.
3. Actualización de documento y arquitectura.
4. Incremento de valor.
5. Acta de Cierre (este documento).
6. [Informe de proyecto](INFORME_DE_PROYECTO.md).
7. Presentación de la Entrega.
8. Versión final de los documentos y productos.

**Producto desplegado.** PROD sirve `v1.0.4` de Flutter Web con un digest que coincide con el tag, y las 18 rutas de la lista de SCRUM-1638 responden. La evidencia está en [`01-mapa-ambientes-y-versiones.md`](../08-infraestructura/01-mapa-ambientes-y-versiones.md).

## 4. Resultados al cierre

| Medida | Resultado | Fuente |
|---|---|---|
| Ítems del proyecto en Jira | **728 de 764** en estado Done | `project = SCRUM`, consultada el 2026-11-24 |
| Historias | **133 de 135** en Done | `project = SCRUM AND issuetype = Historia` |
| Sprint 6 (6 al 25 de noviembre) | 82 de 103 ítems en Done al 24-nov | `project = SCRUM AND sprint in openSprints()` |
| Escenarios de calidad (45) | **33 cumplen**, 5 en parte, 6 no cumplen y 1 sin medir | [`QAS_45_ESTADO_METODO_EVIDENCIA.md`](../07-calidad/QAS_45_ESTADO_METODO_EVIDENCIA.md), corte 2026-11-24 |
| Discrepancias entre documentos (HU-VAL-01) | **15 de 15** cerradas con evidencia o decisión | [`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md) |
| Decisiones de arquitectura | 30 ADR: 29 aceptados y 1 rechazado (ADR-0014) | [`SAD.md`](../02-arquitectura/SAD.md) §24 |
| Acta A/B de escenarios de calidad | Firmada por la PO el 2026-11-21 | [`ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md`](ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md) |

## 5. Lo que no se entrega

El detalle, la causa y lo que pasó en el proceso están en [`INFORME_CIERRE_SPRINT_6.md`](INFORME_CIERRE_SPRINT_6.md) §4 (corte 2026-11-23). Los escenarios de calidad se toman del corte más reciente, el del 24-nov.

**Escenarios que no cumplen (6):** 03 comportamiento temporal, 19 capacidad, 24 adaptabilidad, 33 involucración, 34 inclusividad y 35 asistencia al usuario.

**Escenarios que cumplen en parte (5):** 02 tolerancia a fallos, 06 interoperabilidad, 12 accountability, 21 reusabilidad y 43 confidencialidad en tránsito.

**Escenario sin medir (1):** 05 escalabilidad, porque escalar en QA altera un ambiente compartido.

**Funcionalidades:** las nueve que el informe de cierre lista en su §4.4 (entre ellas la foto de perfil, los aliados de una solicitud y los mensajes de error con código), según su estado en Jira el día de la firma.

**Fuera del producto:** Kafka no corre en PROD (épica post-MVP SCRUM-1677).

## 6. Riesgos que se aceptan al cerrar

| Riesgo | Responsable | Estado |
|---|---|---|
| El token de SonarQube que estuvo expuesto en un repositorio público se retiró de los archivos pero **no se rotó** | DevOps | Riesgo aceptado, no resuelto ([`02-accesos-y-gestion-secretos.md`](../08-infraestructura/02-accesos-y-gestion-secretos.md)) |
| PROD tiene menos migraciones aplicadas que QA hasta la ventana del 25 de noviembre (SCRUM-1726) | DevOps | Se verifica antes de firmar; si no se aplican, PROD queda con un esquema más viejo que el probado en QA |
| Las políticas `TO public` de lectura de `tenant` y `zona` | Core | La migración `0044` las retira en `develop`; **verificar que esté aplicada en PROD** antes de firmar ([`VALIDACION_HU-VAL-01.md`](VALIDACION_HU-VAL-01.md)) |
| ADR-0034 a ADR-0038 y la enmienda de ADR-0006 se ratificaron por la Scrum Master, sin sesión de la Mesa de Arquitectura | Mesa de Arquitectura | La Mesa puede confirmarlos o revertirlos; cada ficha lo declara |
| RNF-13 y QAS-46 (cifrado en reposo), base de ADR-0037, no están aprobados por la PO | PO | Pendiente |
| Cierres en Jira con la evidencia de QA pero sin el video con visto bueno de la PO que exige el *definition of done* | QA y PO | Si la PO exige el video, se reabren (informe de cierre, §4.5) |
| Cuatro tareas cerradas cuyo escenario sigue sin cumplir: SCRUM-1665, 1671, 1675 y 1357 | DevOps y QA | Se declaran como no resueltas |

## 7. Compromisos posteriores al cierre

Propuestos para aprobación en la sesión; solo valen los que la PO acepte.

1. Priorizar la épica post-MVP SCRUM-1677: Kafka en PROD, clúster de tres nodos, gestor de secretos y despliegue blue/green.
2. Rotar el token de SonarQube.
3. Corregir los escenarios que no cumplen empezando por rendimiento del Core (03 y 19) y accesibilidad (34).
4. Convocar la Mesa de Arquitectura para confirmar o revertir los ADR ratificados sin sesión.
5. Tratar el segundo incremento (pagos reales, liquidación, quejas, comercialización y métricas por tenant: RF-24 a RF-28) como un proyecto nuevo con su propia priorización.

## 8. Decisiones tomadas en la sesión

[completar en la sesión: una línea por decisión, con quién la toma]

## 9. Aceptación

La Product Owner declara que recibe el incremento y los entregables de la §3 con el alcance, las excepciones y los riesgos de las §5 y §6.

| Nombre | Rol | Fecha | Firma |
|---|---|---|---|
| Camila Beltrán | Product Owner | | |
| Sara Albarracín | Scrum Master | | |
| Santiago Hernández | QA | | |
| Daniel Ávila | DevOps | | |

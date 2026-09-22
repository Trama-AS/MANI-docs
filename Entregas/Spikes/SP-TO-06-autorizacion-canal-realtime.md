# SP-TO-06 — Reutilización de RLS como autorización de canal en tiempo real

- **Trade-off que resuelve:** TO-06 — QS-02 (Confidencialidad) vs. QS-14 (Interoperabilidad, mensajería)
- **Decisiones afectadas:** ADR-0017 (Supabase Realtime), ADR-0012 (RLS)
- **Evidencia hoy:** **evidencia adversa.** El hallazgo H-02 de PoC-001 demostró que la
  política `tenant_isolation_solicitud` tiene `roles = {public}` y aísla por tenant pero no
  restringe el rol: cualquier usuario autenticado del tenant —incluido uno con rol
  `cliente`— puede hacer `UPDATE` sobre cualquier `solicitud`. TO-06 acepta concentrar la
  autorización en RLS "a cambio de no duplicar lógica"; la PoC muestra que la política
  vigente no expresa la granularidad que `DD-MANI.md` §5.4 exige. El riesgo concentrado ya
  se materializó una vez, en datos. Falta saber si se materializa igual en el canal.
- **Ticket Jira:** pendiente de creación (Sprint 2) — relacionado con el ticket de H-02
- **Timebox:** 6 h
- **Responsable propuesto:** QA & Security Testing Lead con Backend
- **Sprint destino:** 2

## 1. Pregunta que responde

¿La autorización de canal de Supabase Realtime evalúa las mismas políticas RLS que protegen
los datos, y con la política actual puede un usuario de rol `cliente` suscribirse a un canal
que `DD-MANI.md` §5.4 reserva al rol `aliado`?

## 2. Hipótesis que se pone a prueba

RLS es suficiente como mecanismo único de autorización de canal. La hipótesis está ya
debilitada por H-02: si la política no distingue rol en la tabla, es improbable que lo
distinga en el canal.

## 3. Métrica y criterio de decisión

| Métrica | Umbral | Cómo se mide |
| --- | --- | --- |
| Suscripciones cruzadas entre tenants | = 0 | Cliente del tenant A intenta suscribirse a canal del tenant B |
| Suscripciones con rol incorrecto dentro del tenant | = 0 | Usuario con rol `cliente` intenta el canal de aliado |
| Mensajes entregados tras revocar membresía | = 0 | Revocar y medir la ventana hasta el corte efectivo |
| Latencia de entrega en cliente conectado | < 2 s (QS-14) | Medición extremo a extremo |

Criterio de decisión: cualquier suscripción con rol incorrecto obliga a separar la
autorización de canal de la política de datos — y eso contradice la decisión vigente de
TO-06, por lo que exige ADR nuevo.

## 4. Alcance

**Incluye:** canales de Realtime del ciclo de servicio (RF-20, RF-21) sobre QA, con JWT
reales de tres perfiles: aliado del tenant, cliente del tenant y usuario de otro tenant.

**No incluye:** las push notifications (FCM/APNs) ni el rediseño de la política de
`solicitud`, que tiene ticket propio derivado de H-02.

## 5. Método

1. Reutilizar los tenants y usuarios ya sembrados para PoC-001.
2. Intentar las tres suscripciones descritas y registrar qué acepta el servidor.
3. Revocar membresía en caliente y cronometrar hasta el corte efectivo del canal.

## 6. Qué desbloquea

- Cierra TO-06 con evidencia y determina si ADR-0017 puede pasar de "Propuesto,
  condicionado" a Aceptado.
- Cierra parcialmente KI-10 (ADR-0016/0017 incompletos).

## 7. Riesgo si no se ejecuta

El SAD acepta deliberadamente concentrar el riesgo de autorización en un solo mecanismo del
que ya se sabe —por H-02— que no expresa el rol. Aceptar un riesgo concentrado es legítimo;
aceptarlo sin saber que el mecanismo no cubre el caso, no.

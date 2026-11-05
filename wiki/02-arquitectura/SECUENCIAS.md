# Diagramas de secuencia — MANI

**Proyecto:** MANI — TRAMA · Ingeniería de Software
**Alcance:** los flujos críticos del ciclo Solicitud → Cotización → Ejecución → Calificación → Cierre, en notación de secuencia UML.
**Fuente del modelo:** [`workspace.dsl`](diagrams/c4/workspace.dsl) — las mismas colaboraciones están declaradas allí como vistas dinámicas (`dinamico-*`), descritas en [`SDD.md`](SDD.md) §4.6.

---

## Por qué este documento existe aparte

Las vistas dinámicas del DSL sirven para mantener el modelo C4 coherente: cada paso tiene que corresponder a una relación declarada, así que el diagrama no puede inventar una colaboración que la arquitectura no permita.

Este documento es la otra mitad: **PlantUML suelto**, editable y pegable en cualquier visor, sin depender de Structurizr. Aquí sí caben cosas que el modelo C4 no expresa —dos actores compitiendo, una rama `alt`, una condición de error— y que son justamente las que hay que mostrar al sustentar.

Cuando un flujo cambie, cambian los dos: el DSL manda sobre la estructura, este documento sobre el detalle de la interacción.

### Cómo renderizar

```bash
# cualquiera de los bloques de abajo, guardado como .puml
java -jar plantuml.jar -tpng -Playout=smetana seq-solicitud.puml
```

También sirve pegar el bloque en <https://www.plantuml.com/plantuml> o en la extensión de PlantUML del IDE.

---

## 1. Solicitud y conformación del listado de aliados

**Requisitos:** RF-12 (creación y coordinación de la solicitud), RF-13 (orden del listado según la regla del tenant), RNF-03 (idempotencia).

Lo que el diagrama debe dejar claro: **Core crea la solicitud y Dispatch orquesta el reparto** (SAD §7.4, decisión del 17 oct y decisión 6A del 26 oct de 2026). Dispatch pregunta la elegibilidad a Core y el orden a Reglas, y le pide a Core que guarde una oferta por aliado. Ni el cliente Flutter ni el Gateway deciden nada.

```plantuml
@startuml seq-solicitud
title Solicitud y conformación del listado de aliados — RF-12, RF-13

skinparam backgroundColor #ffffff
skinparam shadowing false
skinparam sequence {
  ArrowColor #444444
  LifeLineBorderColor #999999
  ParticipantBorderColor #1155cc
  ParticipantBackgroundColor #3d85c6
  ParticipantFontColor #ffffff
  ActorBorderColor #0b5394
  ActorBackgroundColor #0b5394
}

actor "Cliente" as Cliente
participant "Aplicación cliente\n[Flutter]" as App
participant "API Gateway\n[NGINX]" as GW
participant "Core Service\n[Node.js] — opera" as Core
participant "Dispatch Service\n[.NET] — asigna" as Dispatch
participant "Rules Service\n[Java] — decide" as Rules
database "Supabase\n[PostgreSQL + RLS]" as Db

Cliente -> App: registra la solicitud de servicio
App -> GW: POST /api/v1/core/solicitudes\nIdempotency-Key: k-1
activate GW
GW -> GW: valida el token y aplica rate limiting
GW -> Core: enruta la solicitud
deactivate GW
activate Core
Core -> Db: INSERT solicitud (PENDIENTE)\nla misma clave con otros datos: 409 MANI-SOL-409K
Core --> App: 201 Created — solicitud guardada
deactivate Core

App -> GW: POST /api/v1/dispatch/requests/orchestrate\n{ requestId }
GW -> Dispatch: enruta tras validar el token
activate Dispatch
Dispatch -> Core: contexto de la solicitud (interna)
Dispatch -> Db: lee quién la rechazó (solicitud_rechazo)
Dispatch -> Core: aliados elegibles por categoría y zona,\nexcluyendo a los que rechazaron (excludeAllyIds, interna)
activate Core
Core --> Dispatch: candidatos elegibles
deactivate Core

Dispatch -> Rules: ordena el listado según la regla del tenant (RF-13)
activate Rules
Rules --> Dispatch: candidatos ordenados, o sin orden (NO_DISPONIBLE)
deactivate Rules

Dispatch -> Core: POST /notifications por aliado (interna)
activate Core
Core -> Db: una oferta OFERTA_DESPACHO por aliado y solicitud\n(índice único, migración 0019)
Core --> Dispatch: oferta guardada (o ya existía)
deactivate Core
Dispatch --> App: 200 — DISPATCHED
deactivate Dispatch
App --> Cliente: solicitud publicada; si el aviso falla,\nse ofrece «Avisar a los aliados»

note over Core, Dispatch
  El tenant_id sale del JWT (ADR-0018): ningún
  paso lo recibe como parámetro del cliente.
  Solo se orquesta una solicitud PENDIENTE (409 MANI-DSP-409E).
end note

@enduml
```

---

## 2. Aceptación concurrente — dos aliados compiten

**Requisitos:** RF-14 (aceptar o rechazar sin dobles asignaciones), RNF-03 (idempotencia), RNF-05 (exclusión concurrente).

Este es el flujo que hay que saber defender. La garantía **no** está en la aplicación ni en el número de réplicas: está en una actualización condicional atómica sobre el estado de la solicitud. **Dispatch decide quién acepta y Core escribe** (decisión 6A, SAD §7.4): Dispatch comprueba al aliado y le entrega a Core un comando idempotente; Core bloquea la fila y la primera aceptación gana. La segunda recibe `409 Conflict` sin saber quién ganó.

```plantuml
@startuml seq-aceptacion
title Aceptación concurrente — RF-14, RNF-03, RNF-05 (decisión 6A)

skinparam backgroundColor #ffffff
skinparam shadowing false
skinparam sequence {
  ArrowColor #444444
  LifeLineBorderColor #999999
  ParticipantBorderColor #1155cc
  ParticipantBackgroundColor #3d85c6
  ParticipantFontColor #ffffff
  ActorBorderColor #0b5394
  ActorBackgroundColor #0b5394
}

actor "Aliado A" as A
actor "Aliado B" as B
participant "API Gateway\n[NGINX]" as GW
participant "Dispatch Service\n[.NET] — decide" as Dispatch
participant "Core Service\n[Node.js] — escribe" as Core
database "Supabase\n[PostgreSQL + RLS]" as Db

== Las dos aceptaciones entran a la vez ==

A -> GW: POST /api/v1/dispatch/requests/{id}/accept\nIdempotency-Key: k-A
B -> GW: POST /api/v1/dispatch/requests/{id}/accept\nIdempotency-Key: k-B
GW -> Dispatch: aceptación de A
GW -> Dispatch: aceptación de B

Dispatch -> Core: ¿el aliado está verificado? (GET /allies/me, interna)\nsi no: 403 MANI-SOL-403V
Dispatch -> Db: ¿ya la rechazó? (solicitud_rechazo)\nsi la rechazó: 409 MANI-DSP-409R, sin pedir la asignación
Dispatch -> Core: POST /solicitudes/{id}/asignacion (interna)\nJWT de A, Idempotency-Key, X-Correlation-ID
Dispatch -> Core: POST /solicitudes/{id}/asignacion (interna)\nJWT de B, Idempotency-Key, X-Correlation-ID

== La base decide, no la aplicación ==

Core -> Db: SELECT … FOR UPDATE (A toma el bloqueo)
Core -> Db: UPDATE solicitud SET aliado_id = A, estado = 'ASIGNADA'\nWHERE id = :id AND estado = 'PENDIENTE' AND aliado_id IS NULL
activate Db
Db --> Core: 1 fila afectada
deactivate Db
Core -> Db: evento SOLICITUD_ASIGNADA y aviso al cliente,\nen la misma transacción

Core -> Db: SELECT … FOR UPDATE (B espera y lee la fila ya asignada)
Db --> Core: aliado_id = A

alt gana A
    Core --> Dispatch: 200, asignada: true
    Dispatch --> GW: 200 — ASSIGNED
    GW --> A: servicio asignado
else B llegó tarde
    Core --> Dispatch: 409 MANI-SOL-409, sin el id del ganador
    Dispatch --> GW: 409
    GW --> B: la solicitud ya fue aceptada por otro aliado
end

note over Core, Db
  El bloqueo de fila más el predicado sobre estado y aliado_id
  son la garantía (ADR-0016). Si A repite el comando, Core
  responde 200 con asignada: false y no repite el evento (RNF-03).
  Dispatch no puede escribir solicitud: la migración 0019
  le revoca el UPDATE (ADR-0035, propuesto).
end note

@enduml
```

---

## 3. Cotización y validación contra el tarifario

**Requisitos:** RF-15 (cotización separando mano de obra y materiales), RF-16 (alerta fuera de rango), RF-22 (tarifario por categoría y tenant).

Reparto de responsabilidades: **Core es dueño de la cotización, Reglas es dueño del tarifario.** La validación es una llamada entre servicios, no lógica duplicada en Core. La cotización fuera de rango **se guarda igual**: RF-16 pide alertar, no bloquear, y RF-23 después reporta esas cotizaciones.

```plantuml
@startuml seq-cotizacion
title Cotización y validación contra el tarifario — RF-15, RF-16, RF-22

skinparam backgroundColor #ffffff
skinparam shadowing false
skinparam sequence {
  ArrowColor #444444
  LifeLineBorderColor #999999
  ParticipantBorderColor #1155cc
  ParticipantBackgroundColor #3d85c6
  ParticipantFontColor #ffffff
  ActorBorderColor #0b5394
  ActorBackgroundColor #0b5394
}

actor "Aliado" as Aliado
participant "Aplicación cliente\n[Flutter]" as App
participant "API Gateway\n[NGINX]" as GW
participant "Core Service\n[Node.js] — opera" as Core
participant "Rules Service\n[Java] — decide" as Rules
database "Supabase Rules\n[PostgreSQL + RLS]" as DbRules
database "Supabase Core\n[PostgreSQL + RLS]" as DbCore

Aliado -> App: elabora la cotización\n(mano de obra + materiales)
App -> GW: POST /api/v1/core/cotizaciones
GW -> Core: enruta tras validar el token
activate Core

Core -> Rules: valida el valor contra el rango del tarifario (RF-16)
activate Rules
Rules -> DbRules: lee mínimo, típico y máximo\nde la categoría y el tenant (RF-22)
DbRules --> Rules: rango de referencia
Rules --> Core: dentro / por encima / por debajo del rango
deactivate Rules

Core -> DbCore: persiste la cotización con el resultado de la validación

alt valor dentro del rango
    Core --> App: 201 Created
    App --> Aliado: cotización enviada
else valor fuera del rango
    Core --> App: 201 Created + alerta de desviación
    App --> Aliado: advertencia: la cotización está fuera\ndel tarifario de referencia
end
deactivate Core

note over Core, DbCore
  La cotización fuera de rango se guarda y queda marcada:
  RF-16 alerta, no bloquea, y RF-23 la reporta después.
end note

@enduml
```

---

## 4. Carga y verificación de documentos KYC

**Requisitos:** RF-05 (registro de aliados y documentos), RF-06 (verificación y aprobación).

Dos puntos a sostener: los documentos viven en un bucket privado bajo la convención `tenant_id/aliado_id/documento` (ADR-0013), y la aprobación es una **decisión humana del administrador del tenant**, no un efecto automático de la carga.

```plantuml
@startuml seq-kyc
title Carga y verificación de documentos KYC — RF-05, RF-06

skinparam backgroundColor #ffffff
skinparam shadowing false
skinparam sequence {
  ArrowColor #444444
  LifeLineBorderColor #999999
  ParticipantBorderColor #1155cc
  ParticipantBackgroundColor #3d85c6
  ParticipantFontColor #ffffff
  ActorBorderColor #0b5394
  ActorBackgroundColor #0b5394
}

actor "Aliado" as Aliado
actor "Administrador\ndel tenant" as Admin
participant "Aplicación cliente\n[Flutter]" as App
participant "API Gateway\n[NGINX]" as GW
participant "Core Service\n[Node.js] — opera" as Core
participant "Rules Service\n[Java] — decide" as Rules
participant "Supabase Storage\n[bucket privado]" as Storage
database "Supabase Core\n[PostgreSQL + RLS]" as DbCore

== Carga ==

Aliado -> App: carga los documentos requeridos
App -> GW: POST /api/v1/core/aliados/{id}/documentos
GW -> Core: enruta tras validar el token
activate Core

Core -> Rules: ¿qué documentos exige este tenant?
Rules --> Core: lista de documentos requeridos

Core -> Storage: guarda el archivo en\ntenant_id/aliado_id/documento (ADR-0013)
Core -> DbCore: registra el documento\ny deja al aliado en estado "en verificación"
Core --> App: 201 Created
deactivate Core
App --> Aliado: documentación recibida

== Verificación ==

Admin -> App: revisa la documentación del aliado
App -> GW: GET /api/v1/core/aliados/{id}/documentos
GW -> Core: enruta
Core -> Storage: URL firmada y temporal del documento
Core --> App: documentos para revisión

alt documentación completa y válida
    Admin -> App: aprueba al aliado (RF-06)
    App -> GW: PATCH /api/v1/core/aliados/{id}\nestado = "aprobado"
    GW -> Core: enruta
    Core -> DbCore: marca al aliado como habilitado
    note right of Core: solo desde aquí el aliado\nentra en los listados de despacho
else documentación incompleta o ilegible
    Admin -> App: rechaza indicando el motivo
    App -> GW: PATCH /api/v1/core/aliados/{id}\nestado = "rechazado"
    GW -> Core: enruta
    Core -> DbCore: registra el rechazo y el motivo
end

@enduml
```

---

## 5. Mensajería del servicio con notificación de respaldo

**Requisitos:** RF-20 (mensajería casi en tiempo real entre cliente y aliado), RF-21 (notificación cuando el destinatario no está conectado).

El mensaje **se persiste antes de transportarse**: la conversación no vive en el canal de tiempo real. Realtime transporta, no decide; si el destinatario no está conectado, el mismo mensaje sale por push.

```plantuml
@startuml seq-mensajeria
title Mensajería del servicio con notificación de respaldo — RF-20, RF-21

skinparam backgroundColor #ffffff
skinparam shadowing false
skinparam sequence {
  ArrowColor #444444
  LifeLineBorderColor #999999
  ParticipantBorderColor #1155cc
  ParticipantBackgroundColor #3d85c6
  ParticipantFontColor #ffffff
  ActorBorderColor #0b5394
  ActorBackgroundColor #0b5394
}

actor "Cliente" as Cliente
actor "Aliado\n(destinatario)" as Aliado
participant "Aplicación cliente\n[Flutter]" as App
participant "API Gateway\n[NGINX]" as GW
participant "Core Service\n[Node.js] — opera" as Core
database "Supabase Core\n[PostgreSQL + RLS]" as DbCore
participant "Supabase Realtime" as RT
participant "FCM / APNs" as Push

Cliente -> App: escribe un mensaje del servicio
App -> GW: POST /api/v1/core/servicios/{id}/mensajes
GW -> Core: enruta tras validar el token
activate Core

Core -> DbCore: persiste el mensaje
note right of Core
  Primero se persiste. El transporte puede fallar;
  la conversación no puede perderse.
end note

Core -> RT: publica el evento de mensajería

alt destinatario conectado
    RT -> App: entrega casi en tiempo real (RF-20)
    App --> Aliado: mensaje en pantalla
else destinatario no conectado
    Core -> Push: solicita la notificación push (RF-21)
    Push --> Aliado: notificación en el dispositivo
    Aliado -> App: abre la aplicación
    App -> GW: GET /api/v1/core/servicios/{id}/mensajes
    GW -> Core: enruta
    Core -> DbCore: lee la conversación
    Core --> App: historial de mensajes
end

Core --> App: 201 Created
deactivate Core

@enduml
```

---

## Trazabilidad

| Secuencia | Vista dinámica en el DSL | Servicios | Requisitos |
|---|---|---|---|
| 1. Solicitud | `dinamico-solicitud` | Core · Dispatch · Rules | RF-12, RF-13, RNF-03 |
| 2. Aceptación concurrente | `dinamico-aceptacion` | Dispatch · Core | RF-14, RNF-03, RNF-05 |
| 3. Cotización | `dinamico-cotizacion` | Core · Rules | RF-15, RF-16, RF-22 |
| 4. KYC | `dinamico-kyc` | Core · Rules · Storage | RF-05, RF-06 |
| 5. Mensajería | `dinamico-mensajeria` | Core · Realtime · FCM/APNs | RF-20, RF-21 |

Documentos relacionados: [`SDD.md`](SDD.md) §4.6 (las mismas vistas en el modelo C4), [`SAD.md`](SAD.md) §7 (responsabilidad de cada servicio), [`COMUNICACION_SERVICIOS_GATEWAY.md`](COMUNICACION_SERVICIOS_GATEWAY.md) (rutas y puertos del Gateway).

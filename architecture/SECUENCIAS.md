# Diagramas de secuencia — MANI

**Proyecto:** MANI — TRAMA · Ingeniería de Software
**Alcance:** los flujos críticos del ciclo Solicitud → Cotización → Ejecución → Calificación → Cierre, en notación de secuencia UML.
**Fuente del modelo:** [`workspace.dsl`](../diagrams/LLD/workspace.dsl) — las mismas colaboraciones están declaradas allí como vistas dinámicas (`dinamico-*`), descritas en [`SDD.md`](./SDD.md) §4.6.

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

**Requisitos:** RF-12 (creación y coordinación de la solicitud), RF-13 (orden del listado según la regla del tenant).

Lo que el diagrama debe dejar claro: **quien orquesta es Despacho**. Pregunta elegibilidad al dominio de disponibilidad en Core y el orden a Reglas. Ni el cliente Flutter ni el Gateway deciden nada.

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
participant "Dispatch Service\n[.NET] — asigna" as Dispatch
participant "Core Service\n[Node.js] — opera" as Core
participant "Rules Service\n[Java] — decide" as Rules
database "Supabase Dispatch\n[PostgreSQL + RLS]" as DbDispatch

Cliente -> App: registra la solicitud de servicio
App -> GW: POST /api/v1/dispatch/solicitudes\nAuthorization: Bearer <JWT>
activate GW
GW -> GW: valida el token y aplica rate limiting
GW -> Dispatch: enruta la solicitud
deactivate GW
activate Dispatch

Dispatch -> Core: aliados elegibles por categoría y zona (RF-12)\n(Availability Component)
activate Core
Core --> Dispatch: candidatos elegibles
deactivate Core

Dispatch -> Rules: ordena el listado según la regla del tenant (RF-13)
activate Rules
Rules --> Dispatch: candidatos ordenados
deactivate Rules

Dispatch -> DbDispatch: persiste la solicitud y los candidatos notificados
Dispatch --> App: 201 Created — solicitud en difusión
deactivate Dispatch
App --> Cliente: confirmación

note over Dispatch, Rules
  El tenant_id sale del JWT (ADR-0018): ningún
  paso lo recibe como parámetro del cliente.
end note

@enduml
```

---

## 2. Aceptación concurrente — dos aliados compiten

**Requisitos:** RF-14 (aceptar o rechazar sin dobles asignaciones), RNF-03 (idempotencia), RNF-05 (exclusión concurrente).

Este es el flujo que hay que saber defender. La garantía **no** está en la aplicación ni en el número de réplicas: está en una actualización condicional atómica sobre el estado de la asignación. La primera aceptación afecta una fila y gana; la segunda no afecta ninguna y recibe `409 Conflict`.

```plantuml
@startuml seq-aceptacion
title Aceptación concurrente — RF-14, RNF-03, RNF-05

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
participant "Dispatch Application Service\n[.NET]" as App
participant "Assignment Coordinator\n[.NET]" as Coord
participant "Concurrency Guard\n[.NET]" as Guard
participant "Audit Component\n[.NET]" as Audit
database "Supabase Dispatch\n[PostgreSQL + RLS]" as Db

== Las dos aceptaciones entran a la vez ==

A -> GW: POST /aceptar\nIdempotency-Key: k-A
B -> GW: POST /aceptar\nIdempotency-Key: k-B
GW -> App: aceptación de A
GW -> App: aceptación de B

App -> Coord: coordina la asignación
Coord -> Guard: delega la exclusión concurrente

== La base decide, no la aplicación ==

Guard -> Db: UPDATE asignacion\nSET aliado = A, estado = 'asignada'\nWHERE id = :id AND estado = 'pendiente'
activate Db
Db --> Guard: 1 fila afectada
deactivate Db

Guard -> Db: UPDATE asignacion\nSET aliado = B, estado = 'asignada'\nWHERE id = :id AND estado = 'pendiente'
activate Db
Db --> Guard: 0 filas afectadas
deactivate Db

alt filas afectadas = 1  →  gana A
    Guard --> App: asignación confirmada
    App -> Audit: registra el cambio de estado (RNF-04)
    App --> GW: 200 OK
    GW --> A: servicio asignado
else filas afectadas = 0  →  B llegó tarde
    Guard --> App: la asignación ya estaba tomada
    App -> Audit: registra el intento rechazado (RNF-04)
    App --> GW: 409 Conflict
    GW --> B: la solicitud ya fue aceptada por otro aliado
end

note over Guard, Db
  El predicado "estado = 'pendiente'" es la garantía.
  Reintentar con la misma Idempotency-Key devuelve el
  mismo resultado y no crea una segunda asignación (RNF-03).
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
App -> GW: POST /api/v1/cotizaciones
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
App -> GW: POST /api/v1/aliados/{id}/documentos
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
App -> GW: GET /api/v1/aliados/{id}/documentos
GW -> Core: enruta
Core -> Storage: URL firmada y temporal del documento
Core --> App: documentos para revisión

alt documentación completa y válida
    Admin -> App: aprueba al aliado (RF-06)
    App -> GW: PATCH /api/v1/aliados/{id}\nestado = "aprobado"
    GW -> Core: enruta
    Core -> DbCore: marca al aliado como habilitado
    note right of Core: solo desde aquí el aliado\nentra en los listados de despacho
else documentación incompleta o ilegible
    Admin -> App: rechaza indicando el motivo
    App -> GW: PATCH /api/v1/aliados/{id}\nestado = "rechazado"
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
App -> GW: POST /api/v1/servicios/{id}/mensajes
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
    App -> GW: GET /api/v1/servicios/{id}/mensajes
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
| 1. Solicitud | `dinamico-solicitud` | Dispatch · Core · Rules | RF-12, RF-13 |
| 2. Aceptación concurrente | `dinamico-aceptacion` | Dispatch | RF-14, RNF-03, RNF-05 |
| 3. Cotización | `dinamico-cotizacion` | Core · Rules | RF-15, RF-16, RF-22 |
| 4. KYC | `dinamico-kyc` | Core · Rules · Storage | RF-05, RF-06 |
| 5. Mensajería | `dinamico-mensajeria` | Core · Realtime · FCM/APNs | RF-20, RF-21 |

Documentos relacionados: [`SDD.md`](./SDD.md) §4.6 (las mismas vistas en el modelo C4), [`SAD.md`](./SAD.md) §7 (responsabilidad de cada servicio), [`COMUNICACION_SERVICIOS_GATEWAY.md`](./COMUNICACION_SERVICIOS_GATEWAY.md) (rutas y puertos del Gateway).

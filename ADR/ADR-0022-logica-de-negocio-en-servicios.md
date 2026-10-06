# ADR-0022 — La lógica de negocio vive en los servicios y se retira de Flutter y de las funciones PL/pgSQL

- **Estado:** Propuesto
- **Decisión de:** arquitectura de servicios / transición arquitectónica
- **Origen:** Spike SP-05, revisado en la daily del 2026-10-05
- **Autor:** María Camila Beltrán Carreño
- **Revisor:** Sara Albarracín Niño
- **Fecha:** 2026-10-05
- **Jira:** DOC-26 (SCRUM-1075)
- **Relacionado con:** ADR-0003, ADR-0012, ADR-0015, ADR-0016, ADR-0019

## Contexto

En las entregas 1, 2 y 3 el cliente Flutter invocaba Supabase directamente (`.rpc()`, `.from()`, `.storage.from()`), y la lógica de negocio quedó repartida entre el propio cliente Flutter y funciones PL/pgSQL en Supabase (por ejemplo `registrar_aliado_persona_natural`, `handle_new_user` y el upsert a `usuario`).

La arquitectura vigente (ADR-0019) cambia el camino a **Flutter → NGINX API Gateway → servicios (Core Node, Rules Java, Dispatch .NET, Availability Node) → Supabase/PostgreSQL**, con Supabase Auth emitiendo el token y el tenant viajando como claim.

Las historias cerradas con la arquitectura anterior se rehacen como subtareas de migración `-M2`. Para estimarlas había que resolver: **cuando un servicio atiende un caso de uso, ¿invoca la lógica que ya existe en la base de datos o la lógica pasa a vivir en el servicio?**

## Alternativas

1. **Invocar las funciones PL/pgSQL existentes desde los servicios.** Fue la propuesta inicial de SP-05. Descartada: mantiene la lógica de negocio en la base de datos, contradice el principio del SAD según el cual la lógica de dominio vive en servicios (§4.1) y el patrón Ports and Adapters (§21.4), no resuelve la lógica que quedó en Flutter y deja a Rules y Dispatch sin la lógica de su propio dominio.
2. **La lógica de negocio vive en los servicios, cada uno con la de su dominio, y Supabase queda como persistencia.** Elegida.

## Decisión

**La lógica de negocio vive en los servicios. La lógica que hoy está en el cliente Flutter y en las funciones PL/pgSQL de Supabase se migra al servicio dueño de cada capacidad. Supabase queda como plataforma de persistencia.**

Reglas que se derivan:
- Cada servicio implementa la lógica de su dominio según la responsabilidad asignada en el SAD (§7): Core Node (tenants, identidad, aliados y KYC, clientes, categorías, cotización, ejecución, calificación, mensajería), Rules Java (reglas por tenant, ranking, tarifario), Dispatch .NET (solicitudes, aceptación, idempotencia y exclusión concurrente) y Availability Node (cobertura y elegibilidad).
- Flutter conserva solo presentación e interacción y se comunica únicamente con el Gateway; no vuelve a llamar a Supabase directamente, salvo Supabase Auth para obtener el token.
- Supabase aporta PostgreSQL, Auth, Storage y Realtime. RLS se mantiene como defensa adicional, no como sustituto de la autorización de los servicios (ADR-0012).
- Las funciones PL/pgSQL existentes dejan de ser invocadas a medida que su lógica se migra. No se editan: se retiran con una migración nueva una vez la regresión en QA confirme el reemplazo.
- La exclusión concurrente del despacho se sigue resolviendo con una actualización condicional atómica en PostgreSQL (ADR-0016), emitida por Dispatch, no por una función PL/pgSQL.

## Justificación

La alternativa 2 cumple los principios del SAD sin excepciones: la lógica de dominio vive en servicios, cada servicio es responsable de su capacidad y el dominio no depende directamente de Supabase. Elimina a la vez la lógica que quedó en Flutter (KI-01) y el acceso directo a Supabase (KI-02), permite probar las reglas de negocio con pruebas unitarias en cada servicio (requisito de cobertura mayor al 80 %) y deja preparada la evolución hacia bases de datos propias por servicio sin volver a mover la lógica.

## Disenso registrado

La propuesta inicial de SP-05 (alternativa 1) se revisó en la daily del 2026-10-05. Tras la discusión, el equipo acordó la alternativa 2 y no quedó registrado disenso.

## Impacto en KI-01 y KI-02 (SAD §23)

**KI-01 — Lógica de negocio en Flutter.** El riesgo estaba parcialmente materializado: parte de la lógica vive en el cliente. Con esta decisión esa lógica se migra al servicio correspondiente y Flutter queda solo con presentación e interacción. Se cierra cuando la última historia `-M2`/`-M3` retire la lógica del cliente.

**KI-02 — Acceso directo indiscriminado a Supabase.** El riesgo estaba materializado. Con esta decisión los servicios son la única frontera de acceso a los datos y RLS queda como defensa adicional, que es el control previsto. Se cierra cuando CFG-35 confirme que el cliente ya no usa `.rpc()`, `.from()` ni `.storage.from()`.

El registro formal en SAD/SDD lo hace DOC-28 (SCRUM-1079).

## Consecuencias

### Positivas
- Cumplimiento pleno de los principios del SAD (§4.1 y §21.4).
- Reglas de negocio con pruebas unitarias directas en cada servicio; la cobertura mayor al 80 % mide lógica real.
- Rules y Dispatch quedan con la lógica de su propio dominio desde el inicio.
- La evolución hacia bases de datos propias por servicio no exige volver a mover la lógica.

### Negativas
- **Mayor esfuerzo de migración:** las historias `-M2` dejan de ser "cambiar el llamador" y pasan a reimplementar la lógica en el servicio. Deben reestimarse.
- **Riesgo de regresión:** reglas ya validadas en las entregas 1 a 3 se reescriben. Mitigación: cada historia `-M2` conserva el comportamiento validado como criterio de aceptación y pasa la regresión en QA (US-02.1.1-M4, SCRUM-1062) antes de retirar la función PL/pgSQL correspondiente.
- **Aislamiento con llamador privilegiado (KI-05):** si un servicio se conecta como service-role, `auth.uid()` deja de filtrar. Mitigación: los servicios aplican la autorización por tenant tomando el tenant del claim del JWT, RLS se mantiene como defensa adicional y el aislamiento se acredita con los casos cross-tenant de CFG-23c (ADR-0015).
- **Convivencia temporal:** mientras dura la migración coexisten funciones PL/pgSQL aún no retiradas y lógica ya migrada. Mitigación: ninguna lógica nueva se escribe en PL/pgSQL.

## Condición de revisión

Revisar si:
- la capacidad del sprint no permite reimplementar la lógica de una historia `-M2` y es necesario un paso intermedio;
- se decide que Rules o Dispatch tengan base de datos propia (requiere un ADR nuevo sobre persistencia por servicio, que revisa ADR-0012);
- la medición de k6 (QA-04, SCRUM-1121) muestra un p95 mayor a 3 s atribuible a la nueva lógica en servicios.

## Trazabilidad

| Elemento | Referencia |
|---|---|
| ADR relacionados | ADR-0003, ADR-0012, ADR-0015, ADR-0016, ADR-0019 |
| Historias afectadas (reestimar) | SCRUM-1063, 1064, 1065, 1066, 1069, 1071, 1072 |
| Regresión en QA | SCRUM-1062 |
| Actualización SAD/SDD | DOC-28 (SCRUM-1079) |
| Contratos entre repositorios | CFG-43 (SCRUM-1125), CFG-16 |
| Riesgos | KI-01, KI-02, KI-05 |
| Requisitos | RF-05, RF-06, RF-08, RF-10, RF-11, RF-12, RNF-01 |

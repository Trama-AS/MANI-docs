# ADR-0022 — Los servicios invocan las funciones PL/pgSQL existentes y no reescriben la lógica

- **Estado:** Propuesto
- **Decisión de:** arquitectura de servicios / transición arquitectónica
- **Origen:** Spike SP-05
- **Autor:** María Camila Beltrán Carreño
- **Revisor:** Sara Albarracín Niño
- **Fecha:** 2026-10-05
- **Jira:** DOC-26 (SCRUM-1075)

## Contexto

En las entregas 1, 2 y 3 el cliente Flutter invocaba Supabase directamente (`.rpc()`, `.from()`, `.storage.from()`). La arquitectura vigente (ADR-0019) cambia el camino a **Flutter → NGINX API Gateway → Core Node → funciones PL/pgSQL**, con Supabase Auth emitiendo el token y el tenant viajando como claim.

Las historias cerradas con la arquitectura anterior se rehacen como subtareas de migración `-M2` (US-02.1.1-M2, US-02.1.2-M2, US-02.2.1-M2, US-02.1.3-M2, US-03.1.1-M2, US-03.1.3-M2, US-04.1.1-M2). Para estimarlas había que resolver primero: **cuando Core Node atiende un caso de uso, ¿llama a la lógica que ya existe en la base de datos o la reescribe en el servicio?**

SP-05 confirmó que la lógica de negocio de los casos de uso cerrados vive en funciones PL/pgSQL (por ejemplo `registrar_aliado_persona_natural`, `handle_new_user` y el upsert a `usuario`), no en Flutter. Mientras la pregunta no estuviera resuelta, ninguna subtarea `-M2` podía estimarse.

## Alternativas

1. **Reescribir la lógica de negocio en cada servicio** (TypeScript en Core, Java en Rules, .NET en Dispatch), dejando la base de datos solo como persistencia. Descartada para el Incremento 1: reabre funcionalidad ya validada en las entregas 1 a 3, multiplica el esfuerzo de cada `-M2`, no cabe en el Sprint 3 y traslada el aislamiento multi-tenant de RLS a código nuevo en cada servicio.
2. **Invocar las funciones PL/pgSQL existentes desde los servicios.** Elegida.

## Decisión

**Los servicios invocan las funciones PL/pgSQL existentes y no reescriben la lógica de negocio.**

Reglas que se derivan:
- Core Node es el único componente que invoca funciones PL/pgSQL (frontera documentada en CFG-43). Flutter no vuelve a llamar a Supabase directamente, salvo Supabase Auth para obtener el token.
- El servicio valida el contrato OpenAPI (CFG-16), propaga identidad y tenant hacia la base de datos, traduce errores y registra trazas. No duplica reglas de negocio.
- Las funciones existentes no se editan para adaptarlas al nuevo llamador; cualquier ajuste se hace con una migración nueva.
- La lógica que el Incremento 2 asigna a Rules, Dispatch o Availability se migra en las historias `-M6`, no en las `-M2`.

## Justificación

El criterio de decisión fue: **completar y validar en QA el camino vertical dentro del Sprint 3 con el menor riesgo de regresión y sin debilitar el aislamiento multi-tenant (RNF-01)**. La alternativa 2 entrega el mismo valor funcional con una fracción del esfuerzo, no reabre reglas validadas, mantiene transacciones y RLS donde ya funcionan y desbloquea de inmediato la estimación de las `-M2`. Los beneficios de la alternativa 1 son reales, pero pertenecen al Incremento 2 y pueden obtenerse de forma incremental.

## Disenso registrado

No hubo disenso: la decisión fue aceptada por todo el equipo. Los argumentos a favor de la alternativa 1 (dominio explícito en cada servicio, pruebas unitarias directas de las reglas y menor acoplamiento al motor) se reconocen como válidos a largo plazo y quedan diferidos al Incremento 2, como se explica en la sección siguiente.

## Relación con los principios del SAD

Esta decisión se aparta de forma consciente y temporal de dos principios del SAD:
- **§4.1, principio 3:** "La lógica de dominio vive en servicios."
- **§21.4, Ports and Adapters:** la lógica del dominio no depende directamente de Supabase/PostgreSQL.

Mientras la lógica permanezca en PL/pgSQL, Core Node actúa como frontera de acceso y orquestador, no como dueño de las reglas. La desviación se acepta para el Incremento 1 y se reduce con cada historia `-M6` que mueva lógica a su servicio.

## Impacto en KI-01 y KI-02 (SAD §23)

**KI-01 — Lógica de negocio en Flutter.** El riesgo no se materializó: la lógica estaba en PL/pgSQL, que ya es backend. Flutter solo cambia su capa `data/datasources`. Se cierra con su control cumplido para el Incremento 1.

**KI-02 — Acceso directo indiscriminado a Supabase.** El riesgo sí estaba materializado. Con esta decisión Core Node pasa a ser el único llamador y RLS queda como defensa adicional, que es el control previsto. Se mitiga con las historias `-M2` y `-M3` y se cierra cuando CFG-35 confirme que el cliente ya no usa `.rpc()`, `.from()` ni `.storage.from()`.

El registro formal en SAD/SDD lo hace DOC-28 (SCRUM-1079).

## Consecuencias

### Positivas
- Todas las subtareas `-M2` quedan estimables; se cierra el bloqueo de estimación.
- US-02.1.1-M2 (SCRUM-1065) y US-02.1.2-M2 (SCRUM-1063) se reducen a exponer e invocar funciones existentes.
- La capa de dominio de Flutter (usecases, BLoC, UI) no se toca.

### Negativas
- **Aislamiento con llamador privilegiado (KI-05):** si Core se conecta como service-role, `auth.uid()` deja de filtrar. Mitigación: Core propaga la identidad del usuario y el claim de tenant a la sesión de base de datos, y el aislamiento se acredita con los seis casos cross-tenant de CFG-23c (ADR-0015).
- **Cobertura de pruebas:** el 80 % en Core mide orquestación, no reglas. Mitigación: pruebas de integración contra la base de datos y regresión en QA (US-02.1.1-M4, SCRUM-1062).
- **Acoplamiento a PostgreSQL:** aceptado para el Incremento 1 (ver Relación con los principios del SAD).

## Condición de revisión

Revisar si:
- una historia del Incremento 2 necesita modificar la lógica de una función que pertenece a otro servicio;
- la medición de k6 (QA-04, SCRUM-1121) muestra un p95 mayor a 3 s atribuible a las funciones PL/pgSQL;
- los casos cross-tenant de CFG-23c no pueden acreditarse con Core como llamador.

## Trazabilidad

| Elemento | Referencia |
|---|---|
| ADR relacionados | ADR-0003, ADR-0012, ADR-0015, ADR-0019, ADR-0021 |
| Historias desbloqueadas | SCRUM-1063, 1064, 1065, 1066, 1069, 1071, 1072 |
| Regresión en QA | SCRUM-1062 |
| Actualización SAD/SDD | DOC-28 (SCRUM-1079) |
| Contratos entre repositorios | CFG-43 (SCRUM-1125), CFG-16 |
| Riesgos | KI-01, KI-02, KI-05 |
| Requisitos | RF-05, RF-06, RF-08, RF-10, RF-11, RF-12, RNF-01 |

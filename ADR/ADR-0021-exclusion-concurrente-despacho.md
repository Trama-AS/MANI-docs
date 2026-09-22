> 🔴 **PARA LA MESA — colisión de numeración detectada (2026-09-21).** El `README.md` del
> repositorio usa "ADR-0021" para referirse al stack de CI/CD sin Azure (línea 88), que es
> el tema de `ADR-0023-consolidacion-stack-backend-sin-azure.md`. Además este ADR no
> aparece en la tabla de ADR del README, que se corta en ADR-0018. La carpeta ya llega a
> ADR-0024. La Mesa debe decidir si este documento conserva el número 0021 o se renumera, y
> corregir la referencia del README en cualquiera de los dos casos.

# ADR-0021: Mecanismo de exclusión concurrente en el despacho de solicitudes (SP-04.1.2)

- Fecha: 2026-09-03
- Sprint: 1
- Autor: Santiago (QA Tester) — 🔴 confirmar si corresponde rotar la autoría según ADR-0003
- Origen: Spike SP-04.1.2 (SCRUM-507), activado formalmente por ADR-0016
- Revisor: 🔴 integrante distinto al autor que aprueba el pull request

## Contexto

ADR-0016 decidió el despacho simultáneo (broadcast) con asignación atómica vía una
actualización condicional en base de datos (`UPDATE ... WHERE status = 'pending' AND
aliado_id IS NULL`), y activó formalmente **SP-04.1.2** (exclusión concurrente), que en el
Product Backlog estaba marcado como spike condicional — condicionado a que el despacho fuera
simultáneo. Ese spike nunca produjo su propio ADR: la decisión de exclusión concurrente quedó
implícita dentro de ADR-0016, sin un documento propio que la formalice, la evalúe con
alternativas y la cierre como resuelto.

RNF-05 exige que el despacho resuelva de forma determinista las aceptaciones concurrentes,
dejando exactamente una asignación válida por solicitud. RNF-03 exige que las operaciones
críticas —incluida aceptar una solicitud— sean resistentes a reintentos sin generar
duplicados.

La matriz de tensiones entre escenarios de calidad (TO-03) documenta una tensión abierta
sobre este mismo mecanismo: QS-09 (Tolerancia a fallos, despacho) vs. QS-16
(Disponibilidad). El `UPDATE` atómico exige que la base de datos esté disponible en el
instante exacto del despacho; si la base cae en ese momento, el despacho completo se
detiene. La tabla registra esto como "Aceptado — no hay cola de reintento diseñada todavía;
queda como deuda técnica declarada (ver KI-06)", pero esa aceptación no está formalizada en
ningún ADR aprobado, solo en una hoja de seguimiento aparte.

## Alternativas evaluadas

1. **Bloqueo pesimista explícito (`SELECT ... FOR UPDATE`) sobre la fila de la solicitud
   antes de asignar** — descartada porque mantiene una transacción abierta mientras se
   resuelve la asignación, introduciendo contención y tiempos de espera bajo múltiples
   aceptaciones simultáneas; ADR-0016 ya adoptó un mecanismo optimista que no requiere
   mantener bloqueos activos durante el tiempo de respuesta del aliado.
2. **Cola de mensajes con reintento automático (retry queue)** para reencolar el despacho
   cuando la base de datos no esté disponible en el momento del broadcast — descartada para
   este incremento porque introduce un componente de infraestructura adicional (cola,
   worker) no contemplado en el stack ya aprobado (ADR-0012, ADR-0019), y porque no existe
   todavía un volumen de fallas de disponibilidad confirmado que la justifique frente al
   costo de construirla y mantenerla.
3. **Formalizar el `UPDATE` condicional ya propuesto en ADR-0016 como el mecanismo único de
   exclusión concurrente de SP-04.1.2, sin agregar infraestructura nueva.** Elegida.

## Decisión

Usaremos el `UPDATE` condicional sobre la fila de la solicitud (`status = 'pending' AND
aliado_id IS NULL`) como único mecanismo de exclusión concurrente para el despacho de
solicitudes, sin bloqueo pesimista ni cola de reintento adicional en este incremento.

## Trade-off asumido

Se acepta que, si la base de datos no está disponible en el instante exacto del despacho, la
operación de asignación falla sin ningún mecanismo de reintento automático, trasladando el
fallo directamente al cliente (app del aliado) en lugar de absorberlo con una cola de
resiliencia. Esta limitación queda declarada como deuda técnica explícita, trazada en KI-06,
y se revisará únicamente si el volumen de fallas de disponibilidad observado en producción
la justifica.

## Estado

Propuesto — última actualización: 2026-09-21

Pendiente de revisión en la Mesa de Arquitectura. La decisión cuenta ahora con validación
empírica (ver sección siguiente); lo que falta es la aprobación colegiada, la rotación de
autoría según ADR-0003 y el revisor.

## Validación empírica

**PoC-001** (CFG-09, SCRUM-926) midió este mecanismo contra el proyecto QA el 2026-09-21:
**exactamente 1 asignación** bajo 50 aceptaciones simultáneas sobre la misma solicitud, con
**0 dobles asignaciones**, 49 respuestas `409 ya_no_disponible` y ninguna respuesta
inesperada.

El resultado se apoya en un control negativo que, bajo idéntica carga y alineación, produjo
**10 asignaciones de 10 transacciones distintas en una ventana de 136 ms**. Sin esa corrida
el "1" no distinguiría exclusión concurrente de ausencia de carrera.

Se verificaron además los cuatro escenarios de `DD-MANI.md` §7.1 sobre HTTP real, incluido
el reintento idempotente del ganador, que refuerza RNF-03 tal como anticipa este ADR.

Informe: `Entregas/PoC/PoC-001-exclusion-concurrente-aceptacion.md`.

**Salvedades que la PoC deja declaradas:**

- La concurrencia efectiva la acota el pool de PostgREST, no `max_connections`: de 50
  peticiones enviadas, solo 10 llegaron a solaparse. El mecanismo es correcto hasta esa
  concurrencia; el comportamiento bajo saturación sostenida no se midió.
- `solicitud.estado` no tiene `CHECK` ni `DEFAULT` en QA, pese a que `Product/DDL_MANI.sql`
  los declara. La exclusión depende de que el código escriba el vocabulario correcto.
- La política RLS de `solicitud` aísla por tenant pero no restringe el rol que acepta, en
  contra de `DD-MANI.md` §5.4. Fuera del alcance de esta decisión, pero afecta al mismo
  endpoint.

## Consecuencias

- Positivas: no se introduce infraestructura adicional (cola, worker) sin un driver que lo
  justifique hoy; el mecanismo reutiliza el motor Postgres/Supabase ya decidido en ADR-0012;
  refuerza RNF-03, porque un reintento del mismo aliado sobre una solicitud ya asignada
  afecta 0 filas y no genera duplicados.
- Negativas: una caída de la base de datos durante el despacho detiene la asignación sin
  mecanismo de recuperación automática; el cliente debe manejar explícitamente ese caso de
  error (por ejemplo, reintento manual o mensaje de "solicitud no disponible").
- Neutras: SP-04.1.2 queda formalmente resuelto y cerrado como spike del Sprint 0/1; la
  deuda técnica de la cola de reintento queda registrada para revisión posterior y no
  bloquea el MVP.

## Trazabilidad

- Issues: SCRUM-507 (spike SP-04.1.2) · SCRUM-723 (subtarea de redacción de este ADR) ·
  SCRUM-926 (CFG-09, PoC que lo valida)
- Pull requests: `Trama-AS/MANI-Flutter` #6 (implementación de la RPC, harness y evidencia) ·
  `Trama-AS/MANI-docs` commit `1448499` (informe PoC-001)
- Componentes del modelo C4 afectados: componente de despacho de solicitudes (EP-04, RF-14),
  capa de persistencia multi-tenant (Supabase/PostgreSQL, ADR-0012)
- Documentos que deben actualizarse: Product_Backlog_MANI.md (cerrar SP-04.1.2 como
  resuelto, ya no condicional), SRS_MANI.md (RNF-03, RNF-05), hoja de tensiones de
  escenarios de calidad (actualizar TO-03 con referencia a este ADR en vez de a KI-06 suelto)

---

<Antes de abrir el pull request, verificar la sección 2.6 del Gobierno del Equipo (ADR y
documentación técnica):
1. Los siete campos están presentes y sin marcadores <...> sin reemplazar.
2. La decisión cabe en una frase y no admite dos lecturas.
3. Hay al menos dos alternativas descartadas con motivo verificable.
4. Hay al menos una consecuencia negativa o neutra.
5. El estado es único, fechado y enlazado si corresponde.
6. Está enlazado al issue y al pull request de implementación.
7. Lo revisó un integrante distinto del autor.
Este bloque se elimina antes de fusionar.>

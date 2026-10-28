# ADR-0034 — Contrato y política comunes para proveedores externos de pagos y notificaciones

- **Estado:** Propuesto
- **Decisión de:** integración con terceros y resiliencia
- **Autor:** Jose Nicolas Alvarez Mesa
- **Fecha:** 2026-10-27
- **Jira:** [SCRUM-1240](https://maniservices.atlassian.net/browse/SCRUM-1240) (ARQ-09)
- **Relacionado con:** ADR-0024 (modelo de custodia de pagos), ADR-0030 §2 (Core habla con los proveedores), ADR-0018 (tenant desde el JWT), SCRUM-1428 (proveedor push simulado), SCRUM-1432 (sandbox de pagos)
- **Implementación de referencia:** MANI-Node#82 y `docs/arquitectura/PROVEEDORES_EXTERNOS.md` de MANI-Node

---

## Contexto

Core habla con dos proveedores externos: la pasarela de pagos (RF-24, HU-M11-01) y el proveedor de notificaciones push
(RF-20, HU-M09-06). En el Sprint 5 los dos son simulados: SCRUM-1432 construyó el sandbox de pagos y SCRUM-1428 el
proveedor push simulado. Ambos tienen puerto, adaptador y fábrica por variable de ambiente, pero cada uno resolvió por su
cuenta lo que debería ser común. En `develop` (ae79f93, 27-oct-2026):

- **Ninguna llamada tiene tiempo máximo.** Un proveedor real que no responde deja la petición colgada.
- **El fallo no se trata igual.** Pagos tiene `PaymentProviderError` con causa; push no tiene error tipado y su caso de
  uso atrapa cualquier excepción.
- **«Simulado» se declara distinto.** Pagos expone `simulated`; push no, y dos casos de uso lo deducen con
  `name === 'mock'`, que deja de ser cierto en cuanto exista otro adaptador de prueba.
- **No viaja la idempotencia.** Ningún puerto recibe una clave para que el proveedor no repita un cobro o una entrega,
  y push tampoco recibe el `correlationId`.
- **No hay política de reintentos.** No está escrito qué se puede repetir y qué no.

Cuando entren el operador de pagos certificado (ADR-0024) y FCM/APNs, cada brecha se convierte en un riesgo: un cobro
duplicado por un reintento, un éxito falso o una petición colgada.

## Alternativas

**A. Dejar que cada módulo defina su integración** (como hoy). Sin trabajo adicional, pero cada proveedor real
repetiría las decisiones y nada garantiza que el siguiente adaptador cumpla lo mismo que el mock.

**B. Un cliente HTTP común para todos los proveedores** (timeouts y reintentos en la capa HTTP). Resuelve el tiempo
máximo, pero los proveedores reales se integran con SDK (FCM) o con APIs propias del operador, no siempre con un HTTP
plano; y la capa HTTP no sabe si una operación es idempotente, que es lo que decide si se puede reintentar.

**C. Contrato común en los puertos y una política única en la capa de aplicación** (preferida). Los puertos declaran
lo mismo y una función de política aplica timeout, cancelación y reintento según la operación. Las pruebas de contrato
corren contra todo adaptador registrado.

Argumento en contra de C: agrega una capa y obliga a tocar los dos mocks. Se acepta porque los cambios en los mocks son
de alineación (idempotencia y `simulated`), no de comportamiento, y porque el costo de no tenerla aparece justo al
integrar el proveedor real.

## Decisión

Se adopta la alternativa **C**.

1. **Contrato de los puertos** `IPaymentProvider` e `IPushProvider`: `name`, `simulated`, `idempotencyKey`,
   `correlationId` y `signal` (cancelación). Un adaptador:
   - nunca devuelve un éxito falso: si no conoce el desenlace, lanza el error del contrato;
   - es idempotente por `idempotencyKey`;
   - nunca presenta como real algo simulado;
   - deja de esperar cuando se aborta la señal.
2. **Error común** `ProviderError` con tres causas: `TIMEOUT`, `UNAVAILABLE` e `INVALID_RESPONSE`. Las dos primeras
   son pasajeras. Un pago rechazado no es un error: es un desenlace válido.
3. **Política única** (`callProvider`):
   - timeout obligatorio por proveedor, configurable por ambiente;
   - una excepción sin tipo se informa como `UNAVAILABLE` sin exponer el detalle interno;
   - reintento exponencial solo de fallos pasajeros y solo en operaciones idempotentes.
4. **Pagos: Core no reintenta un cobro.** El cliente reintenta con su `claveIdempotencia`, que llega al proveedor. La
   clave es la del cliente y no la cotización, para que un pago rechazado se pueda volver a intentar. Sin desenlace no
   se registra pago y el fallo se audita con tenant, usuario y `correlation_id`.
5. **Push: hasta dos reintentos** con el id de la notificación como clave. La notificación ya está persistida, así que
   una entrega fallida se informa como `FALLIDA` y el usuario la ve en su bandeja.
6. **Credenciales** de los proveedores reales solo por variables de ambiente leídas en `config/`, exigidas en el
   ambiente que las use; nunca en logs, respuestas ni en el repositorio.
7. **Pruebas de contrato obligatorias:** todo adaptador registrado en la fábrica de su proveedor pasa las mismas
   pruebas de contrato. Agregar el proveedor real lo somete a ellas sin escribir pruebas nuevas.

Límites: esta decisión no crea proveedores ni reemplaza los mocks. SCRUM-1432 sigue siendo dueño del sandbox de pagos y
SCRUM-1428 del proveedor push simulado.

## Consecuencias

- Un proveedor que no responde ya no deja peticiones colgadas: pagos responde 504 (`MANI-PAG-504`) dentro del timeout
  y push informa `FALLIDA`.
- El operador de pagos y FCM/APNs se integran implementando el puerto y registrándolo en la fábrica, con un
  comportamiento ante fallos ya decidido y probado.
- La garantía de no duplicar cobros depende de que el operador certificado acepte una clave de idempotencia. Si no la
  acepta, su adaptador debe implementarla (por ejemplo, consultando la referencia antes de cobrar) para cumplir el
  contrato.
- La alerta de tarifa (SCRUM-866) no depende de esta decisión.

## Verificación

- MANI-Node#82: `npm test` con 1210 pruebas, 0 fallos; 25 nuevas en `tests/unit/providers/` (contrato, política y
  casos de uso ante fallos). Matriz de pruebas por criterio en `docs/arquitectura/PROVEEDORES_EXTERNOS.md` §5.
- La prueba de timeout encontró un defecto antes de publicar: un timeout se informaba como `UNAVAILABLE` (502) porque
  el rechazo del adaptador ganaba la carrera al abortar. Se corrigió en el mismo PR.

## Pendiente para aprobar

Sesión de Mesa de Arquitectura según ADR-0003 §2 y `GOBIERNO_DEL_EQUIPO.md` §5. Hasta entonces este ADR queda en
`Propuesto`.

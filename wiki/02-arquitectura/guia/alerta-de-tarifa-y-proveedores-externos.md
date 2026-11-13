# Alerta de tarifa y proveedores externos

[← 02 · Arquitectura](../README.md) · [Índice](../../Home.md) · [Módulo M-04: cotización y ejecución](modulo-m04-cotizacion-y-ejecucion.md)

**Fuente:** contrato [`core.yaml`](https://github.com/Trama-AS/MANI-APIGateway/blob/develop/docs/openapi/core.yaml) 0.32.0, operación `getQuoteRateEvaluation` y esquema `QuoteRateEvaluation` · MANI-Node `src/application/useCases/tariffs/TariffsUseCase.js` (`evaluarCotizacion`) y `src/infrastructure/clients/RulesServiceHttpClient.js` · MANI-Flutter `lib/features/tariffs/presentation/alerta_tarifa_cotizacion.dart` · [ADR-0034](../adr/ADR-0034-contrato-comun-proveedores-externos.md) y `docs/arquitectura/PROVEEDORES_EXTERNOS.md` de MANI-Node.

Esta página es de la capa **guía**: explica lo que ya está construido y no decide nada. Si contradice al contrato o al código, mandan ellos y esta página se corrige.

| Campo | Valor |
|---|---|
| **Finalidad** | Explicar la evaluación de una cotización contra el tarifario (866), con ejemplos de petición y respuesta, y ubicar el contrato común con los proveedores externos (1240) |
| **Mantiene** | Nicolás Álvarez (desarrollo de M-04) |
| **Consume** | Desarrollo (front, Core y Rules), QA, PO |
| **Cada cuánto se actualiza** | Cuando cambia la operación, el esquema `QuoteRateEvaluation` o el contrato de proveedores |
| **Versión y fecha** | 1.0 · 2026-11-13 |
| **Corte del código** | MANI-APIGateway `develop` `229ba4d` (core.yaml 0.32.0) · MANI-Node `develop` `24fdc94` · MANI-Flutter `develop` `dceebca`, del 2026-11-12 |
| **Historias** | Funcionalidad: [SCRUM-866](https://maniservices.atlassian.net/browse/SCRUM-866) (HU-M06-02 / US-04.2.2, RF-16) y [SCRUM-1240](https://maniservices.atlassian.net/browse/SCRUM-1240) (ARQ-09) · Esta página: [SCRUM-1703](https://maniservices.atlassian.net/browse/SCRUM-1703) (T-58) |

## 1. Alerta de tarifa (866)

### 1.1 Qué hace

Cuando hay una cotización, el cliente y el aliado ven bajo la versión vigente si su total está **dentro del rango de referencia** del tarifario o **por debajo o por encima** de él. Es un aviso, no un bloqueo: la cotización se puede aceptar igual.

- **Contra qué tarifa.** La que regía cuando se emitió la cotización, no la de hoy. Core guarda esa versión al emitir, y es la misma que usa el reporte de cotizaciones fuera de rango (SCRUM-887).
- **Quién decide si está en rango.** Rules (`POST /api/v1/rules/rates/evaluate`). Core no calcula el resultado: le pasa a Rules el total y los valores mínimo, típico y máximo de la tarifa, y devuelve su respuesta.
- **Tolerancia.** Rules marca `POR_DEBAJO` o `POR_ENCIMA` solo si el total sale del rango ampliado por `mani.rules.rates.tolerance-percent`, que hoy vale **0 %** (`application.properties` de MANI-Java). La desviación se mide siempre contra el mínimo o el máximo de la tarifa, sin la tolerancia: (total − máximo) / máximo, o (mínimo − total) / mínimo, en porcentaje con dos decimales.
- **Solo lee.** Nunca modifica la cotización ni su total.
- **Quién la ve.** El cliente dueño, el aliado asignado y el administrador del tenant. Para cualquier otro la cotización no existe (404).

### 1.2 Endpoint

`GET /api/v1/core/cotizaciones/{id}/evaluacion-tarifa`, por el Gateway, con `Authorization: Bearer <JWT>` y `X-Correlation-ID`. `{id}` es el UUID de la cotización.

| Campo de la respuesta | Qué es |
|---|---|
| `cotizacionId`, `solicitudId`, `version` | La cotización evaluada y su versión |
| `total` | Mano de obra + materiales, sin modificar |
| `resultado` | `DENTRO_DE_RANGO`, `POR_DEBAJO`, `POR_ENCIMA` o `SIN_TARIFA` |
| `alerta` | `true` solo con `POR_DEBAJO` o `POR_ENCIMA` |
| `desviacionPorcentaje` | Cuánto se sale del límite que cruzó, en porcentaje; `0` dentro de banda; `null` sin tarifa |
| `tarifa` | `id`, `version`, `valorMin`, `valorTipico`, `valorMax` y `moneda` de la tarifa usada; `null` sin tarifa |
| `reglasVersion` | Versión de las reglas de Rules que evaluaron (p. ej. `rates-v1`); `null` sin tarifa |
| `correlationId` | El de la petición, para rastrearla |

La respuesta va con `Cache-Control: no-store`.

### 1.3 Ejemplos

Los identificadores y los importes son ilustrativos.

**Petición**

```http
GET /api/v1/core/cotizaciones/5b0e2c1a-7f3d-4c9e-9a51-2d8b6f4e1c07/evaluacion-tarifa HTTP/1.1
Authorization: Bearer <JWT del cliente o del aliado>
X-Correlation-ID: 9f6d3a2e-1b4c-4e8f-a7d0-3c5b2e9f8a14
```

**Respuesta 200: por encima del rango** (tarifa de 80 000 a 120 000; total 150 000, un 25 % sobre el máximo)

```json
{
  "cotizacionId": "5b0e2c1a-7f3d-4c9e-9a51-2d8b6f4e1c07",
  "solicitudId": "c2a7e9d4-3f1b-4a6c-8e0d-7b5f9a2c4e18",
  "version": 2,
  "total": 150000,
  "resultado": "POR_ENCIMA",
  "alerta": true,
  "desviacionPorcentaje": 25,
  "tarifa": {
    "id": "e4d1b7c9-2a6f-4e3b-9c8d-1f5a7b3e9d20",
    "version": 3,
    "valorMin": 80000,
    "valorTipico": 100000,
    "valorMax": 120000,
    "moneda": "COP"
  },
  "reglasVersion": "rates-v1",
  "correlationId": "9f6d3a2e-1b4c-4e8f-a7d0-3c5b2e9f8a14"
}
```

**Respuesta 200: `SIN_TARIFA`**

```json
{
  "cotizacionId": "5b0e2c1a-7f3d-4c9e-9a51-2d8b6f4e1c07",
  "solicitudId": "c2a7e9d4-3f1b-4a6c-8e0d-7b5f9a2c4e18",
  "version": 1,
  "total": 95000,
  "resultado": "SIN_TARIFA",
  "alerta": false,
  "desviacionPorcentaje": null,
  "tarifa": null,
  "reglasVersion": null,
  "correlationId": "9f6d3a2e-1b4c-4e8f-a7d0-3c5b2e9f8a14"
}
```

### 1.4 El caso `SIN_TARIFA`

Sale cuando la categoría **no tenía una tarifa vigente** en el momento en que se emitió la cotización. Entonces:

- Core responde **200** con `resultado: SIN_TARIFA`, `alerta: false` y `tarifa`, `desviacionPorcentaje` y `reglasVersion` en `null`.
- **No llama a Rules**: no hay contra qué evaluar. Por eso este caso sigue funcionando aunque Rules esté caído.
- No es un error ni una alerta. La app muestra «Sin tarifa de referencia para comparar» y explica que la categoría no tenía una tarifa vigente cuando se emitió la cotización.
- Publicar después una tarifa no cambia el resultado de esa cotización, porque se evalúa contra la que regía al emitirla. Una versión nueva de la cotización sí se evalúa con la tarifa vigente al emitirla.

### 1.5 Errores

| HTTP | Código | Cuándo |
|---|---|---|
| 400 | `MANI-TAR-400` | El id no es un UUID |
| 401 | — | Sin token, token inválido o expirado |
| 403 | `MANI-TAR-403` | El rol no consulta la evaluación de cotizaciones |
| 404 | `MANI-TAR-404Q` | La cotización no existe o la sesión no la puede ver |
| 502 | `RULES_SERVICE_ERROR` | Rules respondió fuera de contrato |
| 503 | `RULES_SERVICE_UNAVAILABLE` o `MANI-SRV-503` | Rules o la base de datos no están disponibles. Core **no** calcula un resultado propio para reemplazar el de Rules (criterio T2) |

Ante un error, la app muestra «No se pudo comparar la cotización con la tarifa de referencia», sin bloquear la cotización.

### 1.6 En la app

`AlertaTarifaCotizacion` (`lib/features/tariffs/presentation/alerta_tarifa_cotizacion.dart`) va bajo la cotización vigente de la pantalla del servicio, para el cliente y para el aliado. Dentro de banda dice «Dentro del rango de referencia» con el rango. Fuera de banda muestra el motivo, por ejemplo «El total ($ 150.000,00) supera el máximo de referencia ($ 120.000,00) en 25 %», y un consejo distinto para cada lado:

- **Aliado:** «El cliente también ve este aviso. Si te pide un ajuste, puedes enviar una nueva versión.»
- **Cliente:** «El aliado también ve este aviso. Puedes aceptarla, pedir un ajuste o rechazarla.»

## 2. Contratos con proveedores externos (1240)

La decisión completa está en [ADR-0034](../adr/ADR-0034-contrato-comun-proveedores-externos.md) (`Propuesto`) y su implementación de referencia en `docs/arquitectura/PROVEEDORES_EXTERNOS.md` de MANI-Node. Aquí solo va el resumen para ubicarla:

- **Qué cubre.** Los puertos de los proveedores de **pagos** (`IPaymentProvider`) y de **notificaciones push** (`IPushProvider`) del Core. Hoy los dos son simulados. La llamada de Core a Rules de la §1 es entre servicios internos y no es parte de este contrato.
- **Contrato de cada adaptador.** Declara `name` y `simulated`, recibe `idempotencyKey`, `correlationId` y una señal de cancelación, nunca devuelve un éxito falso y nunca presenta como real algo simulado.
- **Error común `ProviderError`** con tres causas: `TIMEOUT`, `UNAVAILABLE` (las dos son pasajeras) e `INVALID_RESPONSE`. Un pago rechazado no es un error, sino un desenlace válido.
- **Política única de llamada (`callProvider`).** Tiempo máximo obligatorio por proveedor. Reintento exponencial solo de fallos pasajeros y solo en operaciones idempotentes. `INVALID_RESPONSE` nunca se reintenta.
- **Pagos.** Core no reintenta un cobro: lo reintenta el cliente con su `claveIdempotencia`. **Push:** hasta dos reintentos, con el id de la notificación como clave.
- **Credenciales** de los proveedores reales solo por variables de ambiente, nunca en logs, respuestas ni en el repositorio.
- **Pruebas de contrato obligatorias.** Todo adaptador registrado pasa las mismas pruebas, así que agregar el proveedor real lo somete a ellas sin escribir pruebas nuevas.

## 3. Pruebas

| Tema | Repositorio | Archivos |
|---|---|---|
| Evaluación de tarifa | MANI-Node | `tests/unit/useCases/moduloM10.useCases.test.js` · `tests/integration/pg/moduloM10Master.pg.test.js` (PostgreSQL real, solo en CI) |
| Evaluación de tarifa | MANI-Java (Rules) | `src/test/java/com/trama/mani/rules/service/RateEvaluatorTest.java` · `src/test/java/com/trama/mani/rules/controller/RatesControllerTest.java` |
| Alerta en la app | MANI-Flutter | `test/features/tariffs/tarifas_gateway_test.dart` · `test/integration/modulo_m10_tarifario_master_test.dart` |
| Proveedores externos | MANI-Node | `tests/unit/providers/{callProvider,providers.contract,providerPolicyUseCases}.test.js` y `providerContracts.js` · `tests/unit/payments/paymentProvider.test.js` · `tests/unit/push/{pushProvider,falibleMockPushProvider}.test.js` |

## 4. Puntos abiertos

- **[ADR-0034](../adr/ADR-0034-contrato-comun-proveedores-externos.md) sigue `Propuesto`.** Falta ratificarlo en la Mesa (ADR-0003 §2).
- **Proveedores reales.** Pagos y push siguen simulados. El contrato está listo para recibirlos, pero conectarlos no está en una historia de este sprint.

## 5. Historial

| Versión | Fecha | Cambio |
|---|---|---|
| 1.0 | 2026-11-13 | Versión inicial, contrastada con core.yaml 0.32.0 y con MANI-Node y MANI-Flutter en `develop` al 2026-11-12 ([SCRUM-1703](https://maniservices.atlassian.net/browse/SCRUM-1703)) |

# ADR-0027 — Alcance de supabase_flutter en el cliente (Retiro de PostgREST y Storage)

- **Estado:** Aceptado
- **Decisión de:** arquitectura de integración frontend y seguridad
- **Relacionado con:** CFG-34, CFG-35, CFG-36, ADR-0012, ADR-0018, ADR-0019, SAD §4.1, RNF-01, RNF-02, REST-02, PROY-07

---

## Contexto

En las etapas tempranas del proyecto, el cliente móvil y web `MANI-Frontend` interactuaba de forma directa con Supabase mediante el SDK `supabase_flutter`, consumiendo tablas vía PostgREST (`.from()`), invocando funciones almacenadas (`.rpc()`) y subiendo documentos directamente a Supabase Storage (`.storage.from()`).

Con la adopción formal de la arquitectura orientada a servicios (SOA) distribuida y políglota (**ADR-0019**), se incorporó el **API Gateway NGINX** como punto único de entrada perimetral y se asignaron responsabilidades operativas a microservicios independientes (`MANI-Core-Service`, `MANI-Rules-Service`, `MANI-Dispatch-Service`).

Mantener llamadas directas desde Flutter a PostgREST/Storage vulnera la frontera del Gateway, desacopla la gobernanza de seguridad, acopla la interfaz gráfica al esquema relacional de la base de datos y expone claves (`SUPABASE_ANON_KEY`) en el bundle del cliente Web.

---

## Alternativas Evaluadas

1. **BaaS Directo Total (Mantener `supabase_flutter` completo).**
   - *Descripción:* Flutter continúa ejecutando consultas directas a tablas con `.from()`, lógica de negocio mediante `.rpc()` y carga de archivos con `.storage.from()`.
   - *Descarte:* Viola el principio de punto único de entrada del SAD §4.1, elude la inspección y enrutamiento del API Gateway, acopla la UI a la estructura SQL e impide centralizar políticas transversales (rate limiting, observabilidad distribuida con `X-Correlation-ID`).

2. **Retiro Total de `supabase_flutter` (Eliminar incluso Auth).**
   - *Descripción:* Retirar completamente la dependencia del cliente Flutter y construir endpoints propios de inicio de sesión, registro y refresco de tokens en el backend.
   - *Descarte:* Reimplementar la gestión criptográfica de sesiones, refresh tokens y rotación de credenciales añade sobrecosto innecesario, descartando la solución de identidad ya validada en **ADR-0018** con Supabase GoTrue.

3. **Consumo Híbrido Delimitado: Conservar únicamente Auth y retirar PostgREST/Storage/RPC (Elegida).**
   - *Descripción:* Se conserva `supabase_flutter` **estrictamente para la gestión de identidad y sesión** (`Auth`). Se retira cualquier consumo de datos operacionales vía PostgREST (`.from()`), procedimientos almacenados (`.rpc()`) y almacenamiento de archivos (`.storage.from()`). Todo el intercambio de datos y operaciones de negocio se canaliza a través del API Gateway hacia los microservicios backend.

---

## Decisión

Se aprueba la delimitación estricta de `supabase_flutter` en el cliente `MANI-Frontend`:

1. **Se conserva únicamente `supabase.auth`:**
   - Inicio de sesión (`signInWithPassword`).
   - Registro de usuarios (`signUp`).
   - Cierre de sesión y refresco automático de tokens JWT.
2. **Se prohíbe y retira todo acceso directo a datos:**
   - **Ningún acceso PostgREST:** Se eliminan todas las invocaciones a `.from()`.
   - **Ningún acceso RPC directo:** Se eliminan todas las invocaciones a `.rpc()`.
   - **Ningún acceso directo a Storage:** Se eliminan todas las invocaciones a `.storage.from()`.
3. **Canalización exclusiva vía API Gateway:**
   - La capa de red de Flutter (`CFG-34`) reemplaza las llamadas a la base de datos por peticiones HTTP REST dirigidas al **`MANI-API-Gateway`** en el puerto `80`.
   - El cliente adjunta el JWT emitido por Auth en el encabezado `Authorization: Bearer <JWT>` y un identificador único en `X-Correlation-ID`.

---

## Criterios de Aceptación (DoR / DoD)

### Definición de Listo (DoR)
* Diseño en Figma aprobado y listo para los flujos afectados.
* Contratos OpenAPI de los endpoints del Gateway/Backend (`/api/v1/core/*`, `/api/v1/rules/*`, `/api/v1/dispatch/*`) disponibles o mockeados.

### Definición de Terminado (DoD)
* Implementación en Flutter fiel al diseño aprobado.
* Lógica de presentación y cubits conectada al Gateway/Backend exitosamente sin dependencias de PostgREST ni Storage.
* Pruebas unitarias, de cubit y de widgets pasando en verde.
* Código integrado y validado en la rama `develop`.

---

## Justificación

* **Alineación con ADR-0019:** Consolida el API Gateway como la única frontera externa del sistema.
* **Seguridad y Menor Superficie de Ataque:** Facilita la posterior rotación y retiro de `SUPABASE_ANON_KEY` del cliente (`CFG-36`).
* **Desacoplamiento:** Los cambios en las tablas o procedimientos SQL no impactan directamente al cliente Flutter, ya que la comunicación se rige por contratos REST estables.
* **Observabilidad:** Todas las transacciones de negocio atraviesan NGINX, garantizando correlación distribuida y métricas de latencia unificadas.

---

## Consecuencias

### Positivas
* Desacoplamiento definitivo entre la interfaz de usuario y el motor de base de datos relacional.
* Centralización de validaciones de negocio en los microservicios (`MANI-Core-Service`, `MANI-Rules-Service`, `MANI-Dispatch-Service`).
* Cumplimiento estricto de las directrices de seguridad multi-tenant (RNF-01).

### Negativas / Costo de Migración
* Requiere refactorizar los datasources existentes en `MANI-Frontend` para sustituir `SupabaseClient` por clientes HTTP (`Dio`/`http`) que consuman el Gateway (`CFG-34`).
* La carga de documentos KYC deberá realizarse mediante endpoints intermediarios o URLs prefirmadas gestionadas por el backend Core.

---

## Condición de Revisión

Revisar si se adopta un proveedor de identidad (IdP) externo unificado que reemplace Supabase GoTrue, o si se migra la autenticación a un flujo OAuth2/OIDC centralizado en el Gateway.

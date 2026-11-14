# Plantillas de historia, tarea, defecto y criterio de aceptación

[← 05 · Backlog](README.md) · [Índice](../Home.md)

| | |
|---|---|
| **Versión** | 1.0 |
| **Fecha** | 2026-11-10 |
| **Finalidad** | Fijar la forma en que se escribe un ítem para que cualquiera pueda aceptarlo y QA pueda cerrarlo |
| **Lo mantiene** | Nicolás León (suplente: Nicolás Álvarez); la forma de los criterios la decide la Product Owner |
| **Lo consumen** | Quien redacta ítems (PO, SM, Desarrollo) y QA, que los verifica |
| **Se actualiza** | Al cambiar el DoR o el DoD; revisar en cada retrospectiva |
| **Origen** | Los ítems reales de Jira del Sprint 5 y del 9-nov (por ejemplo SCRUM-892, SCRUM-1378, SCRUM-1633 y SCRUM-1651) y [DoR y DoD](../04-proceso/dor-y-dod.md) |
| **Destino** | Cada historia, tarea y defecto nuevo de Jira, y la subtarea `QA-…` que lo cierra |
| **Historia en Jira** | [SCRUM-1695](https://maniservices.atlassian.net/browse/SCRUM-1695) (HU-WIKI-07) |

## 1. Historia de usuario

**Título:** `HU-Mxx-nn - Nombre en lenguaje del usuario`, donde `Mxx` es el módulo del libro y `nn` la funcionalidad dentro de él.

**Descripción**

```text
HU-Mxx-nn · funcionalidad M-xx.n del módulo M-xx. Requisito: RF-nn.
Tipo de trabajo: Construcción desde 0 | Validación de lo implementado | Corrección + validación | Front contra mock | Terminar + validación.
Estado antes del sprint: <estado>. Responsable: <persona>.
```

**Criterios transversales.** Aplican a toda historia los T1 a T10 de la hoja 18 del libro de módulos:

| | Criterio |
|---|---|
| T1 | Sin consultas a tablas de otro dominio |
| T2 | 503 sin sustituir por lógica local |
| T3 | `tenant_id` y RLS en la misma migración |
| T4 | Tenant y rol desde el claim |
| T5 | Formato único de error |
| T6 | Solo `supabase.auth` en el cliente |
| T7 | 401 en el borde |
| T8 | Contrato OpenAPI |
| T9 | Fallo cerrado sin secreto |
| T10 | Auditoría de las operaciones administrativas |

**Criterios específicos.** Tres como mínimo, con identificador y verificables:

| | Qué comprueba |
|---|---|
| **C1, positivo** | El camino feliz produce el resultado pedido |
| **C2, negativo** | Lo que no debe ocurrir no ocurre y no se simula un éxito |
| **C3, seguridad o regla crítica** | La operación es auditable y está aislada por tenant, o la regla crítica de la historia se cumple |

**Cómo se acredita.** Video desde el front, no desde Postman ni consola, en QA y a través del Gateway, con token real ES256 emitido por GoTrue de MANI-QA. Un video con `dev-token` no acredita la historia. Se ve el usuario y el rol con el que entra, la acción completa y el resultado persistido al recargar. Máximo 4 minutos, sin cortes en el tramo que demuestra la persistencia. Incluye el caso negativo de aislamiento de C3. La evidencia enlaza el SHA desplegado y la fecha.

**Cierre.** No pasa a Done por sí misma: la cierra QA con la subtarea `QA-HU-Mxx-nn`, que es quien decide el DoD ([`GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §2.3).

## 2. Tarea técnica

**Título:** `ÁREA - Qué se hace (T-nn)`, con área `BACK`, `FRONT`, `SEC`, `OPS`, `UX`, `WIKI`, `QA`, `SM` o `PO`.

```text
Fuente: <QAS-nn, hallazgo, propuesta o decisión de origen>. Esfuerzo: Bajo | Medio | Alto. Responsable: <persona>.
Alcance: <qué entra y qué no, con el ítem que cubre lo que queda fuera>.

Criterios de aceptación
* <criterio verificable>
* ...
* Video de validación: <mismo párrafo de «Cómo se acredita»>.
```

## 3. Defecto

```text
Origen: <prueba, corte o persona que lo encontró>. Relacionado con: <claves>.
Ambiente: <ambiente> y el SHA de cada servicio probado.
Pasos: 1. ... 2. ... 3. ...
Esperado: ...
Obtenido: ...
Evidencia: <archivo o salida, con fecha y hora>.
Lectura sin confirmar: <hipótesis, marcada como tal>.
```

Un defecto que contradice un ítem ya finalizado se abre como **bug aparte** y se relaciona con él: no se reabre la historia para esconder el hallazgo (regla principal del [README](README.md)).

## 4. Criterio de aceptación

Un criterio bien escrito cumple las cuatro cosas siguientes:

1. **Es observable:** dice qué se ve, qué responde la API o qué queda en la base, no qué «debería funcionar».
2. **Tiene un negativo:** por cada «hace X» hay un «y no hace Y».
3. **Nombra su evidencia:** prueba automatizada, consulta o video.
4. **No depende de una decisión pendiente:** si depende, se enlaza la decisión o se separa en otro ítem.

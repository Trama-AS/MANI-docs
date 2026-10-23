# ADR-0028 — Nombres de los repositorios y de los ambientes

- **Estado:** Propuesto
- **Decisión de:** estructura de repositorios y nomenclatura de ambientes
- **Supersede parcialmente:** ADR-0004 y su enmienda del 2026-10-07, en la lista de repositorios
- **Relacionado con:** ADR-0004, ADR-0019, ADR-0023, PROY-07, PROY-08

---

## Contexto

La documentación nombraba los mismos repositorios de varias formas a la vez. En el mismo árbol
convivían `MANI-Flutter` y `MANI-Frontend`; `MANI-Gateway`, `MANI-APIGateway` y `MANI-API-Gateway`;
`MANI-Core-Node`, `MANI-Node` y `MANI-Core-Service`. La enmienda del 2026-10-07 (SCRUM-1110) fijó
una lista, pero lo hizo conservando los sufijos de tecnología —`-Java`, `-DotNet`, `-Node`— y la
grafía `MANI-APIGateway`, y dejó constancia de que `SAD`, `SDD`, `README` y
`POLITICAS_DEVOPS_HERRAMIENTAS` seguían nombrando `MANI-Infra` y se actualizarían aparte.

Dos problemas concretos, no estéticos:

1. **Una búsqueda no encuentra.** Con tres grafías para el Gateway, `grep` sobre la documentación
   devuelve resultados parciales y dos personas pueden creer que hablan del mismo repositorio sin
   estarlo.
2. **El sufijo de tecnología envejece.** `MANI-Rules-Java` obliga a renombrar el repositorio si el
   servicio cambia de runtime, y el runtime es precisamente lo que el enfoque políglota de ADR-0019
   permite revisar. El nombre del repositorio debería decir *qué capacidad* contiene, no *con qué*
   está escrita.

Además, `MANI-Availability` seguía en la lista de repositorios aunque la disponibilidad ya se había
convertido en un dominio interno del Core, con lo que el inventario prometía un desplegable que el
modelo ya no tenía.

En paralelo, el ambiente de pruebas aparecía como `TEST/QA`, `TEST-QA`, `TEST` y `QA` según el
documento, y el SDD listaba un ambiente `Local` que convertía «tres ambientes» en una tabla de
cuatro filas.

---

## Alternativas

1. **Conservar la lista de la enmienda del 2026-10-07.** Es la opción de menor fricción: ya está
   aceptada y los repositorios existen con esos nombres. Descartada porque mantiene los sufijos de
   tecnología y la grafía `MANI-APIGateway`, deja `MANI-Availability` en el inventario y no resuelve
   que los documentos vivos sigan nombrando `MANI-Infra`.

2. **Renombrar solo lo contradictorio y dejar el resto.** Descartada: medio renombrado es el estado
   del que venimos. La ambigüedad no se reduce a la mitad, se mantiene.

3. **Fijar un único juego de nombres por capacidad, con guiones consistentes, y un único nombre por
   ambiente.** Elegida.

---

## Decisión

### 1. Siete repositorios, con estos nombres exactos

| Repositorio | Tecnología | Responsabilidad principal |
|---|---|---|
| `MANI-Frontend` | Flutter / Dart | Cliente web y móvil |
| `MANI-API-Gateway` | NGINX | Punto de entrada y enrutamiento de APIs |
| `MANI-Rules-Service` | Java | Reglas de negocio por tenant |
| `MANI-Dispatch-Service` | .NET | Solicitudes, despacho y asignación |
| `MANI-Core-Service` | Node.js | Servicios core y disponibilidades |
| `MANI-Landing` | React 19 + Vite 8, servida por NGINX | Página comercial pública: entrada a la plataforma |
| `MANI-Docs` | Markdown / diagramas / ADR | Documentación arquitectónica y técnica |

Seis son desplegables; `MANI-Docs` no se despliega. **No existe otro nombre válido** para estos
repositorios en ningún documento, diagrama, pipeline o tarea.

Tres reglas de nomenclatura, para que la lista no vuelva a divergir:

1. **Todo servicio termina en `-Service`.** `MANI-Core-Service`, `MANI-Rules-Service`,
   `MANI-Dispatch-Service`. No se admiten formas cortas como `MANI-Core`, `MANI-Node` o
   `MANI-Java`, ni en prosa ni en diagramas: en texto corrido se escribe «Core Service», «Rules
   Service» y «Dispatch Service».
2. **El nombre dice la capacidad, no el runtime:** `-Service`, no `-Java` ni `-DotNet`. El runtime
   se documenta en la tabla, no en el nombre del repositorio.
3. **Las palabras se separan con guion:** `MANI-API-Gateway`, no `MANI-APIGateway`.

`MANI-Frontend`, `MANI-Landing` y `MANI-Docs` no llevan `-Service` porque no son servicios: el
primero es el cliente, el segundo la página comercial y el tercero documentación.

#### `MANI-Landing` (incorporado el 2026-10-19, SCRUM-1343)

Este ADR es la fuente única del registro del repositorio; los demás documentos lo referencian.

- **Propósito.** Página pública para quien todavía no tiene sesión: catálogo de categorías con
  tarifas base de referencia, estimador de rango que se declara como no-cotización y redirección
  al login de `MANI-Frontend` Web (SCRUM-1335). No accede a datos, no llama al Gateway ni a los
  servicios y no comparte código con otro repositorio, así que queda fuera del alcance de
  ADR-0027 y ADR-0030.
- **Artefacto.** Imagen `ghcr.io/trama-as/mani-landing`, construida por el workflow propio del
  repositorio (`.github/workflows/docker-publish.yml`) desde su `Dockerfile` y su `nginx.conf`.
- **Ambientes.** Los tres de la sección 3, con los tags que publica ese workflow: `:develop`
  (rama `develop`) en DEV, `:staging` (rama `release`) en QA y `:latest` (rama `main`) en PROD.
  `staging` es solo el nombre del tag de imagen, no un ambiente. En cada host corre como el
  contenedor `mani-landing-web`, publicado en el puerto 3001
  ([`DOCUMENTO_INFRAESTRUCTURA_V3.md`](../../06-gobernanza/DOCUMENTO_INFRAESTRUCTURA_V3.md) §3).
- **Detalle técnico.** Vive en el propio repositorio: `MANI-Landing/docs/ARQUITECTURA_E_INTEGRACION.md`.
- **Nombre.** Cumple las tres reglas: dice la capacidad, no el runtime, y no es un servicio.

### 2. Se retiran `MANI-Availability` y `MANI-Infra` del inventario

- **`MANI-Availability`** no se crea. La cobertura y la disponibilidad son un dominio del
  `MANI-Core-Service`, decisión ya reflejada en el modelo de vistas.
- **`MANI-Infra`** no existe: DevOps lo borró el 6 de octubre de 2026 y la enmienda de ADR-0004 ya
  trasladó la infraestructura de datos y el stack local al repositorio del Gateway. Esta decisión
  solo termina de sacarlo del inventario de `SAD`, `SDD`, `README` y las políticas, que era el
  pendiente que esa enmienda dejó anotado.

Queda abierto, como ya decía esa enmienda: dónde vivirán los manifests de orquestación, la
configuración transversal y la observabilidad. Se resuelve con INFRA-01 e INFRA-02.

### 3. Tres ambientes, con un solo nombre cada uno

| Ambiente | Nombre único |
|---|---|
| Desarrollo | **DEV** |
| Pruebas | **QA** |
| Producción | **PROD** |

Se retiran como designaciones de ambiente: `TEST`, `TEST/QA`, `TEST-QA`, `Local` y `Staging`. El
flujo es `DEV → QA → PROD` y son exactamente tres: el entorno de la máquina de cada desarrollador
**es** DEV, no un cuarto ambiente.

---

## Justificación

El costo de esta decisión es un renombrado mecánico que hay que hacer una sola vez. El costo de no
tomarla es permanente: cada documento nuevo elige una grafía, cada búsqueda devuelve resultados
parciales y cada revisión de PR gasta tiempo decidiendo si dos nombres son el mismo repositorio.

Sobre superseder una enmienda de ayer: la enmienda del 2026-10-07 resolvió **dónde vive la
infraestructura**, que era la pregunta urgente, y dejó explícitamente anotado que los documentos
vivos seguían desalineados. Esta decisión cierra ese pendiente y, al hacerlo, aprovecha para quitar
los sufijos de tecnología. No revierte nada de lo que esa enmienda decidió.

---

## Consecuencias

### Positivas

- Un solo juego de nombres, verificable con una búsqueda sobre el repositorio.
- El nombre del repositorio sobrevive a un cambio de runtime, que es una posibilidad real bajo
  ADR-0019.
- El inventario de repositorios deja de prometer dos desplegables que no existen.
- `QA` como nombre único hace que tags, pipelines y documentos coincidan.

### Negativas

- **Renombrar repositorios rompe referencias:** remotos de git, workflows, URLs de imágenes en GHCR,
  badges y enlaces en tareas de Jira. Es trabajo mecánico, pero hay que hacerlo de una vez y
  coordinado, no repositorio por repositorio.
- **Los títulos de historias en Jira quedan desalineados** mientras no se actualicen: varias dicen
  «Core Node».
- **ADR-0004 queda con dos capas de lectura** —su decisión original, su enmienda y esta
  superseción—. Es el costo de conservar el historial en lugar de reescribirlo.
- `MANI-Node` aparece en la tabla de secretos de CI de `INFRAESTRUCTURA_MANI.md` §17 y hay que
  corregirlo junto con el renombrado real del repositorio.

---

## Condición de revisión

Revisar si:

- el equipo decide no renombrar los repositorios reales, caso en el que manda el nombre real y esta
  decisión se revierte en lugar de dejar la documentación divergente otra vez;
- una capacidad se extrae del Core como desplegable propio, lo que añade un repositorio a la lista
  (como ocurrió, por otra vía, con `MANI-Landing`: no salió del Core, se agregó como pieza nueva);
- se cierra INFRA-01 o INFRA-02 y aparece un repositorio para los manifests de orquestación.

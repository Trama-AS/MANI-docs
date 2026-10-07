# ADR-0023 — Consolidación de repositorios, servicios desplegables y ambientes

- **Estado:** Propuesto
- **Decisión de:** estructura de repositorios, fronteras de servicio y topología de ambientes
- **Supersede parcialmente:** ADR-0004 (lista de repositorios y plataforma de ambientes)
- **Relacionado con:** ADR-0004, ADR-0019, ADR-0022, ADR-0027, PROY-07, PROY-08, RNF-07

---

## Contexto

La documentación del proyecto sostenía tres afirmaciones que ya no correspondían a la realidad del
equipo, y que entraban en conflicto entre documentos:

1. **Ocho repositorios.** ADR-0004 y el SDD listaban `MANI-Availability` y `MANI-Infra` como
   repositorios propios, además de nombres que nunca se usaron de forma consistente
   (`MANI-Flutter` frente a `MANI-Frontend`, `MANI-Gateway` frente a `MANI-APIGateway`,
   `MANI-Core-Node` frente a `MANI-Node`). Dos juegos de nombres convivían en el mismo repositorio
   de documentación.
2. **Cuatro servicios de negocio.** El Availability Service figuraba como contenedor y desplegable
   independiente, con su propio pipeline y versionamiento, aunque su único consumidor es Dispatch y
   su lógica es una consulta de elegibilidad.
3. **Kubernetes como estado actual.** El SAD, el SDD y las políticas describían clúster, réplicas y
   HPA como si estuvieran desplegados, mientras la infraestructura real son máquinas virtuales con
   Docker y las decisiones INFRA-01 e INFRA-02 siguen abiertas. El SDD llegó a declarar «tres
   ambientes» sobre una tabla de cuatro filas.

Mantener esa distancia entre lo documentado y lo real tiene un costo concreto: una historia se
estima contra una plataforma que no existe, y un umbral de escalabilidad se declara verificable
cuando no hay forma de medirlo.

---

## Alternativas

1. **Documentar la arquitectura objetivo y marcar la real como transitoria.** Es lo que se venía
   haciendo. Descartada: produjo cuatro valores distintos de p95, dos listas de repositorios y una
   «excepción transitoria» que nunca se cerró. Cuando todo lo real es «transitorio», el documento
   deja de servir para decidir.

2. **Separar cada capacidad en su propio repositorio y desplegable, y adoptar Kubernetes ya.**
   Descartada: multiplica pipelines, imágenes y secretos para un equipo de siete personas con roles
   dobles, y fija una plataforma cuyo proveedor y topología nadie ha decidido. Es el riesgo KI-03
   —servicios excesivamente pequeños— y el KI-08 —complejidad políglota— materializados a la vez.

3. **Consolidar: seis repositorios, tres servicios de negocio, y la orquestación como decisión
   explícitamente abierta.** Elegida.

---

## Decisión

### 1. Seis repositorios, con estos nombres exactos

| Repositorio | Tecnología | Responsabilidad principal |
|---|---|---|
| `MANI-Frontend` | Flutter / Dart | Cliente web y móvil |
| `MANI-API-Gateway` | NGINX | Punto de entrada y enrutamiento de APIs |
| `MANI-Rules-Service` | Java | Reglas de negocio por tenant |
| `MANI-Dispatch-Service` | .NET | Solicitudes, despacho y asignación |
| `MANI-Core-Service` | Node.js | Servicios core y disponibilidades |
| `MANI-Docs` | Markdown / diagramas / ADR | Documentación arquitectónica y técnica |

Cinco son desplegables; `MANI-Docs` no se despliega. No existe otro nombre válido para estos
repositorios en ningún documento, diagrama, pipeline o tarea.

### 2. Las disponibilidades son un módulo del Core Service

Se retira `MANI-Availability` como repositorio y el Availability Service como desplegable
independiente. Las disponibilidades conservan **frontera de capacidad**: su módulo, su esquema
`disponibilidad`, su propia vista de componentes y su API dentro del Core Service.

Dispatch las consume por la API del Core Service, nunca leyendo su esquema.

### 3. No existe repositorio de infraestructura

`MANI-API-Gateway` es la raíz de composición del despliegue: además de la configuración de NGINX
guarda el Compose por ambiente y la configuración de observabilidad.

### 4. Tres ambientes, y son exactamente tres

| Ambiente | Dónde corre | Plataforma |
|---|---|---|
| **DEV** | máquina personal de cada desarrollador | Docker local + Supabase de DEV |
| **QA** | máquina virtual de QA | Docker + Supabase de QA |
| **PROD** | máquina virtual productiva | Docker + Supabase productivo |

El ambiente de pruebas se llama **QA** en todo documento, pipeline y tag. Se retiran los nombres
«TEST», «TEST/QA», «Local» y «Staging» como designaciones de ambiente.

### 5. La orquestación es una decisión abierta

Kubernetes es la plataforma **objetivo** exigida por PROY-08. No es el estado actual, no está
adoptada y su proveedor y topología siguen abiertos como INFRA-01 e INFRA-02.

Hasta que un ADR los cierre, ningún documento ni diagrama declara un clúster, réplicas gestionadas
o autoescalado como estado actual, y no se asume AKS ni Azure.

La decisión se mantiene reversible por una restricción que sí es obligatoria: los artefactos son
imágenes OCI con configuración externa, de modo que cambiar de plataforma no exige reconstruirlas.

---

## Justificación

**Sobre el número de servicios.** La frontera de un servicio desplegable se paga en pipeline,
imagen, secretos, observabilidad y un salto de red en la ruta crítica. Disponibilidades tiene un
solo consumidor y ninguna razón de escalado independiente: separarla cobraba ese precio sin
comprarlo. Mantener su esquema y su módulo preserva lo que sí aporta —el límite de dominio— sin el
costo operativo.

**Sobre la orquestación.** Documentar como actual una plataforma no decidida produjo umbrales
inverificables: el SDD exigía «escalamiento de 2 a 6 réplicas» en una VM que no puede darlo. Declarar
la decisión abierta y enunciar el umbral como propiedad del artefacto —escala sin recompilar— deja
el criterio verificable hoy y válido después.

**Sobre los nombres.** Dos juegos de nombres para los mismos repositorios no es un problema
estético: hace que una búsqueda no encuentre, que un enlace no resuelva y que dos personas crean
estar hablando del mismo repositorio sin estarlo.

---

## Consecuencias

### Positivas

- Un solo juego de nombres, verificable por búsqueda en todo el repositorio.
- Tres desplegables de negocio en vez de cuatro: menos pipelines, imágenes y secretos.
- Los umbrales del SDD se pueden medir en la infraestructura que existe.
- La decisión de orquestación queda registrada como abierta en lugar de supuesta, y nadie la
  «resuelve» en un Pull Request.
- Desaparece la distancia entre el diagrama y el servidor.

### Negativas

- **Renombrar repositorios rompe referencias**: remotos de git, workflows, URLs de imágenes en GHCR
  y enlaces en tareas de Jira. Es trabajo mecánico pero hay que hacerlo de una vez.
- **El Core Service crece.** Concentra identidad, clientes, aliados, catálogo, ciclo del servicio,
  comunicaciones y disponibilidades. Mitigación: módulos internos con esquema propio por dominio y
  la regla de que ningún módulo escribe las tablas de otro. El riesgo a vigilar es que el Core se
  vuelva un monolito con tres runtimes alrededor.
- **Sin autoescalado ni réplicas gestionadas** mientras la orquestación esté abierta. El techo de
  capacidad es la VM. Es una limitación real del estado actual, no un supuesto de diseño.
- **La caída de la VM tumba el ambiente.** No hay recuperación a nivel de host. Debe estar en el
  registro de riesgos operativos hasta que se cierre INFRA-01.

---

## Condición de revisión

Revisar si:

- se cierra INFRA-01 o INFRA-02, lo que obliga a actualizar §5 de esta decisión;
- el módulo de disponibilidades adquiere un consumidor distinto de Dispatch o una necesidad de
  escalado propia, que es lo que justificaría separarlo en un desplegable;
- el Core Service alcanza un tamaño en el que el equipo no pueda razonar sobre sus límites internos,
  caso en el que la división se decide por capacidad de negocio y no por operación CRUD (KI-03);
- el equipo migra formalmente a monorepo, lo que revisa también ADR-0004.

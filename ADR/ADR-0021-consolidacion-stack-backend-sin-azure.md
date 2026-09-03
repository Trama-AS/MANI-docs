# ADR-0021: Consolidación del stack de backend distribuido y eliminación de Azure como proveedor de infraestructura (cierre de KI-02)

- Fecha: 2026-09-03
- Sprint: 1
- Autor: Sara Albarracín (Scrum Master / Frontend)
- Origen: Mesa de Arquitectura — cierre del hallazgo transversal KI-02 (SAD-MANI.md, sección 3)
- Revisor: Daniel Ávila Medina (DevOps)

## Contexto

SAD-MANI.md registra explícitamente el hallazgo KI-02: ADR-0004 (CI/CD sobre Azure), ADR-0005
(DevSecOps) y ADR-0006 (Observabilidad sobre Java Spring/.NET sobre Azure) están "Aceptados" a
la vez que ADR-0012 (backend en Dart/Serverpod sobre Supabase/PostgreSQL con RLS), y el propio
SAD señala que en su forma original son mutuamente excluyentes y que "ningún ADR posterior
declara `supersedes`" — violación directa de Gobierno del Equipo §2.6.

ADR-0019 (2026-09-03) y el README ya describen en la práctica una reconciliación no
formalizada: cliente Flutter/Dart (Repo A), microservicio de reglas de negocio en Java (Repo
B), microservicio transaccional en .NET (Repo C), y una capa BaaS común (Serverpod + Supabase
PostgreSQL con RLS) para persistencia y aislamiento multi-tenant. Es decir, Java y .NET no
fueron reemplazados por Dart/Serverpod: coexisten como microservicios independientes que
consumen la misma capa de persistencia que fija ADR-0012. La contradicción real no está en el
lenguaje de backend, sino en la infraestructura de despliegue: ADR-0004 y ADR-0006 fijan
Microsoft Azure (Azure Container Registry para .NET, hosting de los tres servicios) como
proveedor, mientras que ADR-0019 excluye explícitamente clústeres gestionados en la nube por
restricción financiera (killer de costo), y el Tech Radar (ADR-0010) nunca subió a Azure de
"Tal vez" a "Sí o sí".

KI-11 depende directamente de este cierre: si KI-02 se resolviera eliminando Java/.NET, la
instrumentación de observabilidad de ADR-0006 quedaría sin destinatario técnico.

## Alternativas evaluadas

1. **Mantener el estado actual sin declarar `supersedes`.** Descartada porque perpetúa el
   incumplimiento de Gobierno del Equipo §2.6 y deja bloqueado el plan de pruebas de QA y KI-11
   sobre una contradicción no trazada.
2. **Declarar ADR-0012 como reemplazo total de ADR-0004/0005/0006 (eliminar Java y .NET).**
   Descartada porque contradice ADR-0019 y el README, que fijan tres repositorios (Flutter,
   Java, .NET) como arquitectura vigente; invalidaría trabajo ya iniciado en Repo B/C sin
   decisión formal de la Mesa sobre esos equipos.
3. **Formalizar la coexistencia de stacks manteniendo Azure como proveedor de infraestructura.**
   Descartada porque Azure nunca superó el nivel "Tal vez" en el Tech Radar (ADR-0010) y su
   costo fijo de infraestructura entra en conflicto directo con el killer financiero ya usado en
   ADR-0019 para descartar Kubernetes gestionado en la nube.
4. **Formalizar la coexistencia de stacks (Java, .NET, Flutter/Serverpod/Supabase) y migrar el
   registro/despliegue de contenedores de Azure a Docker Hub + Railway.** Elegida.

## Decisión

Usaremos una arquitectura de backend consolidada donde los microservicios Java (Repo B) y .NET
(Repo C) de ADR-0004/0005/0006 coexisten con el backend Serverpod en Dart y la persistencia
Supabase/PostgreSQL con RLS de ADR-0012, containerizando los tres servicios con Docker,
publicándolos en Docker Hub como registro unificado y desplegándolos en Railway como plataforma
de hosting, eliminando a Microsoft Azure y Azure Container Registry como proveedor de
infraestructura.

## Trade-off asumido

El equipo abandona la integración con Azure Container Registry ya usada por el servicio .NET,
asumiendo el esfuerzo de migrar su registro a Docker Hub y reconfigurar secretos/variables de
entorno de los tres ambientes (develop/release/main) en GitHub Actions para apuntar a Railway.
Se sacrifica la madurez y las herramientas de nivel empresarial de Azure a cambio de eliminar
el costo fijo de infraestructura, y queda abierta —sin resolver en este ADR— la ubicación
concreta de Kubernetes fuera de Azure si esa exigencia curricular se mantiene vigente.

## Estado

Aceptado — última actualización: 2026-09-03

## Consecuencias

- Positivas:
  - Cierra formalmente KI-02 con trazabilidad `supersedes`, cumpliendo Gobierno del Equipo §2.6.
  - Elimina el riesgo declarado en KI-11: al preservarse Java y .NET, la instrumentación de
    ADR-0006 conserva destinatario técnico.
  - Consistencia entre SAD, ADR-0019, README y el Tech Radar: ningún documento vigente vuelve a
    listar a Azure como proveedor "Sí o sí".
  - El plan de pruebas de QA y el resto de ADR condicionados a la resolución de KI-02 quedan
    desbloqueados.
- Negativas:
  - Reconfiguración operativa no trivial de pipelines, secretos y registro de contenedores del
    servicio .NET, sin ganancia funcional inmediata para el producto.
  - Railway tiene menor techo de escala y menos garantías contractuales (SLA) que Azure.
- Neutras:
  - ADR-0005 (SonarQube/OWASP ZAP) no se modifica: su elección de herramientas es independiente
    del proveedor de infraestructura.
  - ADR-0012 no se modifica: este ADR aclara su alcance (backend/persistencia), no lo reemplaza.
  - Queda pendiente una decisión separada sobre dónde correr Kubernetes (requisito curricular
    señalado en Matriz de Herramientas, PROY-08) sin depender de Azure AKS.

## Trazabilidad

- Issues: 🔴 <completar al abrir el issue de cierre de KI-02>
- Pull requests: 🔴 <completar al abrir el PR>
- Componentes del modelo C4 afectados: Contenedores de despliegue de Repo B (Java) y Repo C
  (.NET) — registro de imágenes y ambientes Development/Testing/Production.
- Documentos que deben actualizarse: SAD-MANI.md (cerrar hallazgo transversal y fila KI-02),
  Matriz de Herramientas (mover Azure a "Descartado", confirmar Railway), Tech Radar (ADR-0010),
  README.md (sección de stack tecnológico y CI/CD).

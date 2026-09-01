# ADR-0011 · Modelo de cobertura geográfica del aliado

- **Estado:** Aceptado
- **Fecha de ratificación:** 2026-08-31
- **Redactor:** Mesa de Arquitectura — Nicolás Álvarez, Juan Sebastián Álvarez
- **Aprobado por:** Mesa de Arquitectura
- **Decisión de:** modelo de dominio y de datos
- **Origen:** spike SP-02.1.1
- **Relacionado con:** ADR-0005, ADR-0006 (persistencia). Este ADR no los condiciona
- **Sustituye a:** —

---

## 1. Contexto

MANI debe presentar al cliente los aliados válidos para atender una solicitud (RF-12,
prioridad Crítica). La validez depende de que el aliado atienda la categoría solicitada
(RF-11) y de que cubra la ubicación del servicio (RF-07).

El cliente estableció que la cobertura se declara **por zonas, no por radio geográfico**
(REST-01, origen C-08). La plataforma es multi-tenant (RF-01) y cada tenant configura sus
propias reglas (RF-02, RNF-02), operando potencialmente en geografías distintas.

El motor de persistencia no está decidido (ADR-0005 y ADR-0006 abiertos). El modelo de
cobertura debe ser implementable con cualquiera de los candidatos.

## 2. Decisión

**La cobertura de un aliado se modela como una relación entre el aliado y una o más zonas de
un catálogo administrativo. No se modela como geometría propia del aliado ni como radio.**

La decisión comprende seis definiciones, todas vinculantes:

1. **Catálogo de zonas.** Existe un catálogo jerárquico de zonas administrativas con tres
   niveles: ciudad → localidad/comuna → barrio.

2. **Granularidad operativa del MVP.** La cobertura se declara a nivel de
   **localidad/comuna**. Es el nivel con disponibilidad confiable de datos oficiales de
   división político-administrativa y suficiente para el despacho del MVP. El nivel barrio
   existe en el catálogo pero no se usa para declarar cobertura en este incremento.

3. **Zona obligatoria en el sitio de servicio.** Todo sitio de servicio registrado por un
   cliente tiene asignada una zona del mismo catálogo. La dirección libre no sustituye a la
   zona. Un sitio sin zona no puede originar una solicitud.

4. **Mecanismo de correspondencia.** Un aliado es válido para un sitio si y solo si la zona
   del sitio pertenece al conjunto de zonas declaradas por el aliado. El match es igualdad
   de identificador de zona, resuelto en la capa de consulta. No se ejecuta cálculo
   geoespacial en el MVP.

5. **Ciclo de vida de las zonas.** Las zonas no se eliminan: se desactivan. Una zona
   desactivada no admite nuevas declaraciones de cobertura ni nuevos sitios, pero conserva
   su integridad histórica. Cada servicio registra la zona vigente al momento de su creación.

6. **Propiedad del catálogo bajo multi-tenancy.** El catálogo de zonas es **global de la
   plataforma**, administrado por el administrador de plataforma y consumido en modo solo
   lectura por todos los tenants. La cobertura declarada, que sí es dato operativo del
   tenant, se aísla por `tenant_id` como cualquier otra entidad del tenant. Ningún tenant
   ve ni modifica la cobertura declarada por otro.

## 3. Opciones consideradas y descartadas

Se registran para trazabilidad de la decisión. Ninguna permanece abierta.

| Opción | Motivo del descarte |
| --- | --- |
| **Radio de cobertura** (punto de origen más distancia) | Incumple REST-01. Descartada sin evaluación adicional |
| **Polígonos dibujados por el aliado** (geometría libre, match punto-en-polígono) | Exige capacidad geoespacial del motor de persistencia, lo que habría cerrado ADR-0006 desde este ADR sin mandato para ello. Exige además geocodificación de direcciones, dependencia externa no contemplada en el alcance ni en el presupuesto del MVP. Produce un match no explicable en lenguaje del cliente ante la pregunta operativa "¿por qué no apareció este aliado?" |
| **Catálogo de zonas con geometría asociada a cada zona** | Técnicamente compatible con la decisión adoptada, pero sin requisito que la justifique en el MVP: sería complejidad sin driver. Se descarta para este incremento y queda como evolución posible, aditiva y no bloqueante (ver §6) |

## 4. Justificación

- **Cumple REST-01 de forma literal**, no por interpretación. Frente a un competidor que
  proponga polígonos o radios, la defensa ante el cliente es directa.
- **No consume la decisión de persistencia.** Una relación N:M entre dos entidades es
  implementable tanto en un motor relacional como en uno documental. ADR-0006 conserva su
  espacio de decisión intacto.
- **El match es auditable y explicable.** La respuesta operativa a una exclusión es "el
  aliado no declaró esa zona", verificable por cualquier administrador sin herramientas
  técnicas.
- **Evita sobrearquitectura.** Ningún requisito ni atributo de calidad exige hoy precisión
  sub-zonal. Introducir capacidad geoespacial sin ese driver sería complejidad injustificada.
- **El costo de la consulta de despacho es bajo**, lo que favorece RNF-07 en la ruta más
  caliente del producto.

## 5. Consecuencias

**Asumidas y aceptadas**

- Aparece trabajo no contemplado en el backlog: cargar y administrar el catálogo de zonas.
  Requiere una historia nueva en EP-03, hoy inexistente.
- US-02.2.1 y US-02.2.2 deben ajustarse para capturar la zona del sitio. Sin ese dato RF-12
  no es resoluble.
- **No se soporta cobertura parcial de una localidad.** Un aliado que atiende una fracción de
  su localidad debe declararla completa o no declararla. Limitación conocida y aceptada del
  MVP.
- La operación depende de la existencia de datos oficiales de división administrativa para
  cada ciudad objetivo. Donde no existan al nivel de localidad/comuna, la cobertura se
  declara a nivel de ciudad.

**Habilitadas**

- US-02.1.4 y US-04.1.2 quedan estimables e implementables.
- El modelo entra al DD V1 con tres entidades: `Zona`, `CoberturaAliado`, `Sitio`.
- RF-13 puede calcular el orden "por cobertura" sobre este modelo sin extensiones.

## 6. Condiciones de revisión

Este ADR se reabre únicamente si ocurre alguna de estas condiciones:

1. El cliente confirma un requisito de cobertura con precisión inferior a la localidad.
2. Aparece un requisito de cálculo de distancia, proximidad o ruta.
3. Un tenant requiere operar en una geografía sin división administrativa utilizable.
4. La medición en QA demuestra que la consulta de despacho incumple RNF-07 con volúmenes
   confirmados por el cliente.

La evolución prevista en ese caso es aditiva: asociar geometría a la entidad `Zona` para
resolver automáticamente la zona de un sitio desde coordenadas, sin alterar la relación
aliado ↔ zona ni el mecanismo de match. La reversibilidad es parte de por qué se eligió este
modelo.

## 7. Trazabilidad

`C-08 → REST-01 → RF-07 y RF-12 → SP-02.1.1 → ADR-0011 → US-02.1.4, US-04.1.2 →
entidades del DD V1 → casos de prueba de cobertura en QA`

| Artefacto | Elemento afectado |
| --- | --- |
| SRS | RF-07, RF-12, RF-13, REST-01 |
| Backlog | US-02.1.4, US-04.1.2, US-02.2.1, US-02.2.2, historia nueva de catálogo de zonas |
| SAD | Arquitectura de datos; restricción de dominio |
| DD | `Zona`, `CoberturaAliado`, `Sitio` |
| Tech Radar | Sin cambios: la decisión no adopta ninguna tecnología |
| Plan de pruebas | Aliado fuera de cobertura; zona desactivada; sitio sin zona |

# ADR-15: Estrategia de pruebas para el aislamiento multi-tenant

- Fecha: 2026-08-31
- Sprint: 0
- Autor: Santiago — QA Tester
- Origen: Mesa de Arquitectura (SP-QA.1.1)
- Revisor: Por definir — integrante distinto al autor que apruebe el pull request

## Contexto

RNF-01 exige que los datos de un tenant estén estrictamente aislados de los
demás, y este requerimiento está identificado como driver arquitectónico
crítico del sistema (bug previsible B-01.2.1 ya registrado en el backlog).
Una vez que SP-01.1.1 define la estrategia de aislamiento (políticas RLS
sobre el esquema multi-tenant), es necesario validar en pruebas que ningún
usuario o token de un tenant puede leer, listar, modificar ni eliminar datos
de otro tenant, y que esa validación se repita en cada cambio que toque
autenticación, RLS o el esquema de datos, no solo en una revisión manual
puntual. El equipo ya tiene definidas Postman, Newman y GitHub Actions como
herramientas de QA (Matriz de Herramientas), y PROY-06 restringe incorporar
herramientas adicionales sin justificación.

## Alternativas evaluadas

1. Revisión manual periódica de las políticas RLS por parte de QA —
   descartada porque no es repetible ni queda ligada a cada cambio de
   código: deja una ventana de riesgo entre una revisión y la siguiente,
   en la que un cambio que rompa el aislamiento podría llegar a producción
   sin detectarse.
2. Usar k6 u OWASP ZAP para validar el aislamiento multi-tenant — descartada
   porque ambas herramientas están orientadas a otro propósito (k6 a pruebas
   de carga/concurrencia, OWASP ZAP a seguridad de aplicación web) y no a
   validar reglas funcionales de acceso cruzado entre tenants; el equipo ya
   usa Postman/Newman para pruebas funcionales de API, por lo que introducir
   una herramienta adicional para este caso no está justificado (PROY-06).

## Decisión

Usaremos una colección de Postman con seis casos de prueba de acceso
cruzado entre tenants (lectura, listado, escritura, borrado y control de
autenticación), automatizada con Newman y ejecutada dentro del pipeline de
GitHub Actions en cada Pull Request que toque autenticación, RLS o el
esquema de datos.

## Trade-off asumido

Se sacrifica tiempo de ejecución del pipeline de CI —cada PR que toque
autenticación, RLS o esquema pagará el costo adicional de correr esta
suite— y se asume el trabajo de mantener usuarios de prueba y datos
sembrados (seed data) de al menos dos tenants sincronizados con cada cambio
de esquema. La suite valida el comportamiento a través de la API/RLS, no
cubre una posible fuga de datos por consultas directas a la base de datos
que evadan ese camino.

## Estado

Propuesto — última actualización: 2026-08-31

## Consecuencias

- Positivas: un cambio que rompa el aislamiento entre tenants se detecta
  antes de fusionarse a la rama principal, en vez de descubrirse en
  producción; los seis casos definidos dejan trazabilidad explícita de qué
  verbo HTTP y qué operación (lectura, listado, escritura, borrado,
  autenticación) están cubiertos.
- Negativas: agrega tiempo a cada ejecución de CI que toque autenticación,
  RLS o esquema; el equipo debe mantener actualizados los usuarios y datos
  sembrados de al menos dos tenants a medida que el esquema evoluciona.
- Neutras: la suite valida el aislamiento a nivel de API/RLS; no sustituye
  una eventual verificación de accesos directos a la base de datos fuera
  del flujo normal de la aplicación.

## Trazabilidad

- Issues: #Por definir
- Pull requests: #Por definir
- Componentes del modelo C4 afectados: pipeline de CI/CD (GitHub Actions),
  suite de pruebas de aislamiento (Postman/Newman), componente de
  autenticación y RLS de la plataforma multi-tenant (EP-01).
- Documentos que deben actualizarse: estrategia de pruebas de QA
  (Spikes_QA.md), documentación del pipeline de CI/CD, Gobierno del Equipo.

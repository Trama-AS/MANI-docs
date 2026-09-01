# ADR-13: Almacenamiento de documentos KYC de aliados

- Fecha: 2026-08-31
- Sprint: 0
- Autor: Santiago — QA Tester
- Origen: Mesa de Arquitectura (SP-02.1.2)
- Revisor: Por definir — integrante distinto al autor que apruebe el pull request

## Contexto

MANI es una plataforma multi-tenant en la que los aliados cargan documentos de
verificación (KYC) durante su registro. RNF-01 exige aislamiento estricto de
datos entre tenants, y RNF-10 exige que los documentos de verificación sean
configurables por tenant y no estén fijados en el código. Adicionalmente, un
aliado no debe poder ver los documentos de otro aliado del mismo tenant (bug
previsible B-02.1.1 ya registrado en el backlog), y un administrador de tenant
solo debe poder ver los documentos de los aliados de su propio tenant.

El almacenamiento se resuelve sobre Supabase Storage, ya definido como parte
del stack del proyecto. El número de tenants crecerá a medida que se
incorporen nuevas empresas a la plataforma, y el equipo cuenta con capacidad
limitada para mantener infraestructura adicional por cada tenant nuevo.

## Alternativas evaluadas

1. Bucket privado de Supabase Storage por tenant, con una carpeta por aliado
   dentro de cada bucket — descartada porque no escala operativamente: cada
   tenant nuevo requiere crear y mantener un bucket adicional, lo que añade
   trabajo administrativo recurrente a medida que aumenta el número de
   tenants.
2. Validar el aislamiento únicamente en la capa de aplicación (backend),
   sin políticas RLS a nivel de storage — descartada porque hace depender el
   aislamiento de datos de que el código de aplicación nunca tenga un error,
   en lugar de aplicarlo como regla declarativa a nivel de base de datos;
   esto contradice el criterio de RNF-01 de que el aislamiento debe
   mantenerse en toda funcionalidad del sistema, no solo en el camino feliz
   del backend.

## Decisión

Usaremos un único bucket privado de Supabase Storage, en el que cada archivo
se guarda con una ruta que incluye el `tenant_id` y el `aliado_id`
(`tenant_id/aliado_id/documento.pdf`), y el control de acceso se aplica
mediante una política RLS sobre la tabla de objetos de Storage que compara
esos identificadores de la ruta con los del usuario autenticado.

## Trade-off asumido

Se sacrifica la simplicidad de un límite de aislamiento físico (un bucket
por tenant) a cambio de una política RLS más compleja, cuya corrección
depende de que la ruta se construya siempre con el `tenant_id` y `aliado_id`
correctos desde el backend. Un error en la construcción de esa ruta es más
difícil de detectar a simple vista que un error de configuración de un
bucket completo, por lo que esta política requiere cobertura de pruebas
automatizadas explícita (ver SP-QA.1.1 / ADR-15).

## Estado

Propuesto — última actualización: 2026-08-31

## Consecuencias

- Positivas: un tenant nuevo no requiere crear ni configurar infraestructura
  de storage adicional, ya que empieza a usar su propia ruta dentro del
  bucket existente; la política de acceso queda centralizada en un solo
  lugar, lo que facilita su auditoría.
- Negativas: la política RLS depende de la correcta construcción de la ruta
  (`tenant_id/aliado_id/...`) en cada operación de carga; un error en esa
  construcción podría bloquear acceso legítimo o, en el peor caso, exponer
  documentos entre aliados o tenants.
- Neutras: cambia la convención de nombres de archivo respecto a un enfoque
  por bucket: todo componente que suba o lea documentos debe incluir
  explícitamente `tenant_id` y `aliado_id` en la ruta, en vez de apoyarse en
  el bucket como límite implícito de aislamiento.

## Trazabilidad

- Issues: #Por definir
- Pull requests: #Por definir
- Componentes del modelo C4 afectados: componente de almacenamiento de
  documentos (Directorio de Aliados, EP-02), políticas RLS de Storage en
  Supabase.
- Documentos que deben actualizarse: estrategia de pruebas de permisos
  (Spikes_QA.md / suite de QA), SRS_MANI (sección 5.2 y 8 si aplica),
  Gobierno del Equipo.

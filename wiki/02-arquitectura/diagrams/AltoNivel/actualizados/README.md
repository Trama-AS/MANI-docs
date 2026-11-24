# Tres vistas actualizadas de MANI

Fecha de revisión documental: 24 de noviembre de 2026. Se conservan las imágenes originales de las demás carpetas.

| Vista | PNG | SVG editable | PDF |
|---|---|---|---|
| Contexto y alto nivel | [PNG](01-contexto-alto-nivel.png) | [SVG](01-contexto-alto-nivel.svg) | [PDF](01-contexto-alto-nivel.pdf) |
| Despliegue e infraestructura | [PNG](02-despliegue-infraestructura.png) | [SVG](02-despliegue-infraestructura.svg) | [PDF](02-despliegue-infraestructura.pdf) |
| Arquitectura de datos | [PNG](03-arquitectura-datos.png) | [SVG](03-arquitectura-datos.svg) | [PDF](03-arquitectura-datos.pdf) |

La primera vista combina contexto y contenedores para ofrecer el panorama solicitado; no pretende ser una vista C4 N1 estricta. La tercera presenta dominios y fronteras de acceso: el DER detallado permanece en [ModeloDatos.png](../../datos/ModeloDatos.png).

## Fuentes y criterios

- [SAD](../../../SAD.md), responsabilidades y acceso del cliente (§7–8).
- [Mapa de módulos](../../../../01-producto/mapa-de-modulos.md), módulos funcionales M-01 a M-13.
- [Modelo de datos](../../../ModeloDatos.md), dominios y privilegios físicos (§3 y §6).
- [ADR-0027](../../../adr/ADR-0027-alcance-supabase-cliente-flutter.md): Auth y Realtime como caminos directos delimitados del cliente, precisados en SAD §8.3.
- [ADR-0028](../../../adr/ADR-0028-nombres-repositorios-y-ambientes.md): nombres reales de los siete repositorios y Landing.
- [ADR-0030](../../../adr/ADR-0030-propiedad-esquema-y-frontera-de-datos.md) y [ADR-0035](../../../adr/ADR-0035-frontera-de-asignacion-6a.md): migraciones y asignación. Para permisos concretos prevalece el inventario físico de ModeloDatos §6: Rules sin SQL; Dispatch solo `solicitud_rechazo`.
- [Mapa operativo de ambientes](../../../../08-infraestructura/01-mapa-ambientes-y-versiones.md): VMs, Docker Compose, monitoreo y respaldos; corte de inspección 14 de noviembre, sin inspección nueva de servidores.
- [Despliegue y rollback](../../../../08-infraestructura/03-despliegue-y-rollback.md): scripts operativos; no se presenta el CD automático a PROD como terminado.
- [CI/CD y calidad](../../../../04-proceso/cicd-y-calidad.md): política de pruebas, SonarQube, escaneo de imágenes y OWASP ZAP contra QA. Mostrar la política no certifica su ejecución en cada pipeline.

El broker Kafka está inventariado en DEV/QA; eso no demuestra productores y consumidores de negocio operativos. No se representa Kafka como dependencia productiva. QA y PROD se muestran con Docker Compose sobre VM.

Los dominios de datos incluyen tablas del segundo incremento documentadas en el modelo; su presencia en el diagrama no acredita funcionalidad terminada. El inventario analítico/DW se identifica como diseño separado, sin afirmar un despliegue operativo.

## Regeneración

Editar [generar_diagramas.py](generar_diagramas.py) y ejecutar desde esta carpeta:

```sh
python3 generar_diagramas.py
```

Requiere Python 3 y `rsvg-convert` (librsvg). Genera SVG vectoriales, PNG de 2700 px de ancho y PDF vectoriales. Los SVG pueden abrirse en editores vectoriales sin ejecutar el script.

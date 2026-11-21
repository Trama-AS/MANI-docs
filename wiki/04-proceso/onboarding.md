# Onboarding de un desarrollador nuevo

[← 04 · Proceso](README.md) · [Índice](../Home.md)

**Fuente:** [`Home.md`](../Home.md) §2 y §3 · [`GOBIERNO_DEL_EQUIPO.md`](../06-gobernanza/GOBIERNO_DEL_EQUIPO.md) §2 a §4 · [`POLITICAS_DEVOPS_HERRAMIENTAS.md`](../06-gobernanza/POLITICAS_DEVOPS_HERRAMIENTAS.md) §4 a §6, §15 y §18 · [Multi-repo](../03-repositorios/multirepo.md) · [Accesos y gestión de secretos](../08-infraestructura/02-accesos-y-gestion-secretos.md) · el `README.md`, el `CONTRIBUTING.md` y el `AGENTS.md` de cada repositorio.

| Campo | Valor |
|---|---|
| **Finalidad** | Que una persona nueva pueda entregar su primer cambio sin depender de que alguien le cuente cómo se trabaja |
| **Mantiene** | La página: Nicolás Álvarez (responsable de la carpeta). Las fuentes: Scrum Master y DevOps |
| **Consume** | Quien entra al equipo y quien lo acompaña |
| **Cada cuánto se actualiza** | Cuando cambia un acceso, un repositorio o una regla de las páginas enlazadas |
| **Versión y fecha** | 1.0 · 2026-11-16 ([SCRUM-1694](https://maniservices.atlassian.net/browse/SCRUM-1694)) |
| **Origen y destino** | Reglas de gobierno y políticas → esta lista → primer PR integrado |

Esta página no trae reglas nuevas: es el orden en que conviene leer y hacer lo que ya dicen las demás.

## 1. Ficha del proceso

| Campo | Valor |
|---|---|
| **Responsable** | La Scrum Master asigna a quien acompaña. DevOps entrega los accesos. La persona nueva recorre la lista |
| **Entradas** | Cuenta de GitHub y de Jira; un ítem de Jira asignado |
| **Salidas** | Accesos funcionando, un repositorio corriendo en local con sus pruebas en verde y un primer PR integrado |

## 2. Antes de escribir código

| # | Qué hacer | Dónde |
|---|---|---|
| 1 | Entender el producto en cinco minutos | [Visión y alcance](../01-producto/vision-y-alcance.md) y [Actores y ciclo del servicio](../01-producto/actores-y-ciclo-del-servicio.md) |
| 2 | Saber qué fuente manda cuando dos se contradicen | [Jerarquía de fuentes](../Home.md#2-jerarquía-de-fuentes) |
| 3 | Saber quién decide qué | [Roles y decisiones](roles-y-decisiones.md) |
| 4 | Conocer las reglas que no se negocian | [Reglas arquitectónicas](../02-arquitectura/guia/reglas-arquitectonicas.md) y [Multi-tenancy y seguridad](../02-arquitectura/guia/multitenancy-y-seguridad.md) |
| 5 | Conocer los repositorios y cuál es dueño de qué | [Multi-repo](../03-repositorios/multirepo.md) |
| 6 | Leer las reglas de trabajo, en el [orden de lectura](README.md#1-orden-de-lectura) de esta carpeta | Esta carpeta |

## 3. Accesos

| Acceso | Quién lo da | Regla |
|---|---|---|
| Organización `Trama-AS` en GitHub | DevOps | Las ramas compartidas están protegidas: todo entra por PR |
| Tablero `SCRUM` en Jira | Scrum Master | Sin ítem de Jira no hay trabajo que hacer |
| Canales del equipo | Scrum Master | Lista en [Ceremonias y tiempos](ceremonias-y-tiempos.md) |
| Variables de entorno de DEV y cuentas de prueba de QA | DevOps | Se piden como dice [Accesos y gestión de secretos](../08-infraestructura/02-accesos-y-gestion-secretos.md). Nunca se pegan en un chat, un commit ni un documento ([Secretos](secretos.md)) |

## 4. Dejar un repositorio corriendo

Los nombres de la documentación y los de GitHub no coinciden del todo:

| En la documentación | En GitHub (`Trama-AS/…`) |
|---|---|
| MANI-Frontend | `MANI-Flutter` |
| MANI-API-Gateway | `MANI-APIGateway` |
| MANI-Core-Service | `MANI-Node` |
| MANI-Dispatch-Service | `MANI-.NET` |
| MANI-Rules-Service | `MANI-Java` |
| MANI-Docs | `MANI-docs` |

En el repositorio que toque:

1. Leer su `README.md`, su `CONTRIBUTING.md` y, si existe, su `AGENTS.md`. Ahí están los comandos exactos de instalación, pruebas y formato; esta wiki no los repite.
2. Crear el archivo de variables local a partir de la plantilla del repositorio (por ejemplo `.env.example`). El archivo real no se sube.
3. Correr las pruebas **antes de cambiar nada**. Si fallan en limpio, se avisa: no se «arreglan» de paso.

## 5. El primer cambio

1. Tomar el ítem de Jira y pasarlo a «En curso» ([Jira y trazabilidad](jira-y-trazabilidad.md#estados-y-transiciones)).
2. Crear la rama desde la rama de integración del repositorio ([Git: ramas y commits](git-ramas-y-commits.md)).
3. Hacer el cambio con sus pruebas y correr lo que corre el CI: formato, análisis y pruebas ([CI/CD y calidad](cicd-y-calidad.md)).
4. Abrir el PR con la plantilla del repositorio y los siete elementos obligatorios ([Pull requests](pull-requests.md)).
5. Atender la revisión. Con el PR integrado, dejar el enlace y la evidencia en Jira y pasar el ítem a «En revisión».
6. Cuando esté desplegado en QA, grabar el [video de validación](videos-de-validacion.md) si el ítem lo pide.

Si se trabaja con un asistente de IA, aplican las mismas reglas y además las de [Trabajo con asistentes de IA](trabajo-con-ia.md): una persona revisa todo y no se añaden atribuciones a la herramienta.

## 6. Ejemplo real del Sprint 5

[SCRUM-871](https://maniservices.atlassian.net/browse/SCRUM-871) (el cliente consulta sus solicitudes) recorrió el camino completo:

- Rama de *feature* con la clave de Jira y PR [MANI-Flutter#67](https://github.com/Trama-AS/MANI-Flutter/pull/67), con su par de Core y de contrato en el Gateway.
- El 27 de octubre QA pidió un cambio: una respuesta 200 mal formada se mostraba como «sin solicitudes». Se corrigió con su prueba, se integró `develop` y QA aprobó 40 minutos después, tras comprobar que la prueba nueva fallaba con el código anterior.
- El PR se integró y la historia siguió a «En revisión» hasta su validación en QA.

Lo que enseña: el revisor no aprueba «porque el CI pasa», y un cambio pedido se responde con una prueba que lo demuestra.

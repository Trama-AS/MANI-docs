# Matriz historia ↔ repositorios del Sprint 4

| Campo | Valor |
|---|---|
| Tarea | SCRUM-1256 (PO4-01), subtareas SCRUM-1284 y SCRUM-1285 |
| Autora | Camila Beltrán (PO) |
| Estado | Aceptada el 17 de octubre de 2026 a las 5:00 p. m., sin correcciones de desarrollo ni de QA (acuerdo PO/SM) |
| Alimenta a | SCRUM-1257 (criterios de aceptación) y SCRUM-1245 (Backlog V5) |

## 1. Propósito

Indica qué repositorios toca cada historia priorizada del Sprint 4 y quién es su responsable técnico. Se construyó con `architecture/SAD.md` §7 y `wiki/03-repositorios/multirepo.md`, y se publicó primero en SCRUM-1256 para la validación del equipo.

Repositorios: **Front** = MANI-Frontend · **GW** = MANI-API-Gateway (incluye `database/`) · **Core** = MANI-Core-Service · **Rules** = MANI-Rules-Service · **Disp** = MANI-Dispatch-Service.

## 2. Matriz

| Historia | Responsable | Repo principal | Otros repos |
|---|---|---|---|
| SCRUM-850 · Registrar empleado directo | Nicolás León | Core | Front, GW |
| SCRUM-852 · Cliente empresa con varios sitios | Nicolás León | Core | Front, GW |
| SCRUM-853 · Reglas del sitio visibles al aliado | Nicolás León | Core | Front, GW |
| SCRUM-854 · Editar perfil propio | Nicolás León | Core | Front, GW |
| SCRUM-855 · Aliado gestiona su disponibilidad | José Nicolás Álvarez | Core | Front, GW |
| SCRUM-856 · Aceptar términos y condiciones | Nicolás León | Core | Front, GW |
| SCRUM-858 · Desactivar categoría sin afectar servicios en curso | Juan Sebastián Álvarez | Core | Front, GW, posible Disp |
| SCRUM-861 · Ver aliados válidos por cobertura y categoría | Nicolás León | Disp | Core, Rules, Front, GW |
| SCRUM-862 · Filtrar por tipo de aliado | José Nicolás Álvarez | Core | Front, GW, posible Rules |
| SCRUM-1060 · Registro de empresa en la app vía Gateway | José Nicolás Álvarez | Front | GW |
| SCRUM-1063 · Registro de aliado empresa en Core | Nicolás León | Core | GW |
| SCRUM-1066 · Aprobar o rechazar registro de aliado | Nicolás León | Core | GW, posible Front |
| SCRUM-1068 · Zona de cobertura | Nicolás León | Core | GW |
| SCRUM-1070 · Reglas de categoría en Rules | Juan Sebastián Álvarez | Rules | Core, GW |
| SCRUM-1072 · Creación de solicitud | Nicolás León | Core | GW |
| SCRUM-1073 · Orquestación del despacho | Nicolás León | Disp | Core, Rules, GW |
| SCRUM-1074 · Aceptar o rechazar sin doble asignación | Nicolás León | Disp | Front, GW |

## 3. Notas

1. **SCRUM-1072** queda en Core por la decisión D1 de SCRUM-1232: Core crea la solicitud y Dispatch la orquesta (SAD §7.4).
2. **SCRUM-1068**: el título menciona «Availability Service», que ya no existe; la cobertura y la disponibilidad son dominio de Core (ADR-0028).
3. **SCRUM-858, 862 y 1066**: los repositorios marcados como «posible» no se confirmaron; se precisan al implementar.
4. **ADR-0030**: los PRs de SCRUM-856, 861, 1073 y 1074 debían corregirse para no cruzar la frontera de datos por SQL ni crear tablas sin RLS. Su seguimiento está en `backlog/CRITERIOS_ACEPTACION_SPRINT4.md` §5.
5. **Carga:** Nicolás León es responsable de 12 de las 17 historias.

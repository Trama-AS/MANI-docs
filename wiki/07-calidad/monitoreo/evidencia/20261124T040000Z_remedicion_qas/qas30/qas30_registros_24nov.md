# QAS-30: botón de envío de los registros y de reglas, 24 de noviembre de 2026

> Evidencia de QA (Santiago Hernández). Resultado en el [SDD §8](../../../../../02-arquitectura/SDD.md). Jira: SCRUM-1717 (en Reabierta), comentario 11400.

**Método.** Chrome contra MANI-QA (`https://10.43.100.141:8080`), sin sesión. Se activa el árbol de accesibilidad de Flutter Web (`flt-semantics-placeholder`) y se mide, con `getBoundingClientRect`, el borde inferior del botón de envío (`flt-semantics[role=button]`) contra la altura de la ventana. Ventanas: 1710x931 y 800x600 (viewport útil de 457). No se midió 390x844.

| Ruta | Botón de envío | 1710x931 | 800x600 | Resultado |
|---|---|---|---|---|
| `/register-cliente` | CREAR MI CUENTA DE CLIENTE | 852–901, visible | 376–425, visible | Cumple (barra fija al pie) |
| `/register-aliado` | ENVIAR REGISTRO A REVISIÓN | 852–901, visible | 376–425, visible | Cumple (barra fija al pie) |
| `/register-empresa` (empresa aliada) | ENVIAR REGISTRO DE EMPRESA A REVISIÓN | 852–901, visible | 376–425, visible | Cumple (barra fija al pie) |
| `/register-cliente-empresa` | CREAR LA CUENTA DE MI EMPRESA | 1008–1060, **fuera de pantalla** | 1008–1060, **fuera de pantalla** | **No cumple**: no usa la barra fija; hay que desplazarse |
| Reglas operativas del tenant | Guardar | visible | — | Cumple (`BarraAccionPrincipal`), medido antes con sesión de administrador |

**Lectura.** El PR MANI-Flutter#163 (SCRUM-1717) declara la barra fija en cliente, aliado y empresa aliada, y en reglas; el registro de cliente empresa quedó fuera. Ese registro no estaba entre los 14 flujos de T-45. Falta aplicar la misma barra de envío en `/register-cliente-empresa` y medir de nuevo, también a 390x844.

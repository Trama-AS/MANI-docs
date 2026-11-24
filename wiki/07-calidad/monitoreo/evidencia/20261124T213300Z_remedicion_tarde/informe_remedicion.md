# Remedición de QA, 24 de noviembre de 2026 (tarde)

**Versión en QA:** Core `b7e0217`, Rules `51081c4`, Dispatch `93cafde`, Gateway `3c27b81`, Landing `73bf7cf`, Flutter `21ffe92` (desplegada a las 21:23Z). **Ejecuta:** QA (Santiago Hernández).

| QAS | Antes | Ahora | Resultado | Evidencia |
|---|---|---|---|---|
| 02 | Parcial | **Cumple** | 44 PASA, 0 FALLA en cuatro casos (control, caída, error con reintento y push sin respuesta) con 2 elegibles. 0 operaciones revertidas. Sin respuesta, la orquestación responde 200 en 9,00 s con 2 de 2 ofertas (antes 503 en 11,96 s y 1 de 2). Core registra la falla con correlation ID (4 de 4) y sin payload. | [corrida](qas02/qas02_tarde_real_24nov_2133z.txt) |
| 24 | No cumple | **Cumple** | Core, Rules, Dispatch y Gateway tienen el mismo digest en QA, en PROD y en `:staging` y `:latest` de GHCR. | [tabla](qas24/tabla_digests.md), [QA](qas24/digests_qa_24nov_2123z.txt), [PROD](qas24/digests_prod_24nov_2152z.txt) |
| 30 | Cumple | Cumple | Solo se repitió el registro de cliente empresa: el botón se ve completo a 1710x931, 800x600 y 390x844. | [capturas](qas30/) |
| 34 | No cumple | No cumple | Corregido: idioma `es-CO`, contraste de la Landing (0 bajo el mínimo de 342 y 337 textos; 22 sin medir por degradado o imagen) y movimiento reducido. El zoom se probó en Chrome emulando un celular (1,0 a 2,0). No se repitió la revisión completa. | [Landing](qas34/landing_qa.txt), [app](qas34/app_qa.txt) |

**Conteo:** Cumple 35 · Parcial 4 (06, 12, 21, 43) · No cumple 5 (03, 19, 33, 34, 35) · No medido 1 (05).

## Límites

- QAS-02: Dispatch ofrece en serie y cada elegible suma unos 3,5 s si el push no responde. Con muchos elegibles no se midió.
- QAS-02: para tener 2 elegibles se agregó Suba a la cobertura de `aliado.t1` por API y después se restauró; las filas quedaron idénticas. Una corrida anterior (21:25Z) se descartó porque ese aliado no cubría la zona.
- QAS-34: la app se midió contra el contenedor de QA por túnel SSH (HTTP interno), no por el Gateway. Falta un celular real.
- QAS-24: medido entre QA y PROD; SCRUM-1723 deja fuera DEV. La lectura en PROD la ejecutó DevOps. Flutter corre otro commit en PROD, con el mismo contenido.

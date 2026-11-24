# QAS-24: tabla servicio ↔ digest (SCRUM-1723, 24 nov 2026)

| Servicio | Imagen | Commit | Digest en QA (21:23Z) | Digest en PROD (21:52Z) | `:staging` y `:latest` en GHCR | Resultado |
|---|---|---|---|---|---|---|
| Core | mani-node | `b7e0217` | `sha256:a19d87701e633bf1b789e58f9432d20f6e5ddfa1096591c90915970d60be97d0` | igual | iguales | Cumple |
| Rules | mani-java | `51081c4` | `sha256:72254656d35e255166a30afd08a41de9c14881e50bb00edc57f4e602d43a77ac` | igual | iguales | Cumple |
| Dispatch | mani-dotnet | `93cafde` | `sha256:94fbedb6f7432101f87bcc55edaefd77006d6fd1b41804508e806783c4b36bfb` | igual | iguales | Cumple |
| Dispatch | mani-net | `93cafde` | no se despliega | no se despliega | iguales, con el digest de mani-dotnet | Cumple |
| Gateway | mani-apigateway | `3c27b81` | `sha256:9870ef40465bb1b27eff04c55874fc2756e375b756dfc98d22901a6a0a554c88` | igual | iguales | Cumple |
| Flutter | mani-flutter | QA `21ffe92`, PROD `220c2c9` | `sha256:db230a40c0c3a6753187a302746f82492da90aa8d80ded28ec93b7343d889b6b` | `sha256:3c3b49f1b0adde2f5bd6841e7af1670a33c548671c1a8fc02e4709eeed2d3fb2` | no aplica | Una imagen por ambiente; mismo contenido, otro commit (ver límites) |

**Fuentes.** QA: [`docker inspect` en la VM de QA](digests_qa_24nov_2123z.txt). PROD y GHCR: [salida de la VM de PROD](digests_prod_24nov_2152z.txt), ejecutada por DevOps y adjunta en SCRUM-1723 (se quitaron los retornos de carro; el contenido no cambia). QA la comparó con los registros de `promote-latest.yml` en `main`, que fijaron los mismos digests en `:latest`: [Core](https://github.com/Trama-AS/MANI-Node/actions/runs/45492875980), [Rules](https://github.com/Trama-AS/MANI-Java/actions/runs/45492884796), [Dispatch](https://github.com/Trama-AS/MANI-.NET/actions/runs/45492880696) y [Gateway](https://github.com/Trama-AS/MANI-APIGateway/actions/runs/45492870321). El digest y el commit de Flutter coinciden con su [publicación desde `main`](https://github.com/Trama-AS/MANI-Flutter/actions/runs/45492070433).

## Límites

- **DEV no se midió.** SCRUM-1723 lo deja fuera porque siempre lleva código más nuevo que QA. El escenario del SDD no se cambió.
- **Flutter.** `220c2c9` es el merge a `main` de `21ffe92`: los dos tienen el mismo árbol de Git (`302b130`), pero no el mismo commit. En PROD, `/assets/.env` tiene su propia URL del Gateway. El cambio de configuración al arrancar se probó en QA el 23 de noviembre.
- **La lectura en PROD la ejecutó DevOps**, no QA.
- Landing no está en el umbral de QAS-24. PROD corre `61d42ae` (`1.0.5`), con el mismo árbol que `73bf7cf` de QA.

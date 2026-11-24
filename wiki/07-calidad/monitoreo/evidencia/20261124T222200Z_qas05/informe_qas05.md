# QAS-05, 24 de noviembre de 2026 (22:22Z a 22:31Z)

**Resultado: Parcial.** Core escala de 2 a 6 réplicas y cumple el umbral B. Rules y Dispatch no se midieron. **Ejecuta:** QA (Santiago Hernández). **Ventana:** autorizada por DevOps. **Tarea:** SCRUM-1716.

Se levantaron copias de Core, Rules (1) y Gateway en un proyecto Compose aparte (`qas05`) de la VM de QA, con las imágenes que corrían en QA (Core `a19d8770…`). Core se escaló con `docker compose --scale` mientras k6 enviaba 10 peticiones/s de solo lectura.

| Réplicas | Peticiones por réplica (ventana de 42 s) | No 200 en el paso | Reintentos del Gateway | Misma imagen |
|---|---|---|---|---|
| 2 | 209 · 212 | 0 de 770 | 0 | sí |
| 3 | 157 · 139 · 124 | 0 de 829 | 0 | sí |
| 4 | 103 · 121 · 94 · 103 | 0 de 831 | 0 | sí |
| 5 | 87 · 89 · 97 · 81 · 75 | 0 de 849 | 0 | sí |
| 6 | 81 · 57 · 70 · 71 · 65 · 76 | 0 de 851 | 0 | sí |

La réplica nueva quedó lista en 5 a 6 s (2 a 6). k6: 4.282 peticiones, 0 distintas de 200, 0 descartadas. El reparto se cuenta desde 35 s después de que la réplica queda lista, porque NGINX resuelve el nombre cada 30 s.

Las copias se borraron (0 contenedores, 0 redes) y los contenedores de QA quedaron iguales (imagen, arranque y reinicios).

Evidencia: [corrida](qas05_24nov_2222z.txt), [resumen de k6](k6_core.json), [log del Gateway por réplica](gateway_qas05.csv), [scripts](scripts/).

## Límites

- **Rules no se escaló** por la memoria de la VM (DevOps). **Dispatch no se levantó**: DevOps pidió entrar por el pooler (6543) y su conexión en QA usa 5432.
- Son copias, no los contenedores de QA, que tienen nombre fijo. Cada réplica tuvo 0,5 CPU, 256 MB y un pool de 5; QA usa 1 CPU, 512 MB y 30. Kafka se quitó de las copias.
- El Gateway de las copias solo cambió el formato de su log, para registrar la réplica.
- 10 peticiones/s no superan la capacidad: se midió el reparto y los errores del cambio, no el rendimiento. Kubernetes con HPA sigue como objetivo.
- Una primera corrida (22:09Z) se descartó porque se cayó la conexión SSH por la que iba la carga. Los 5 estados 499 del log son de la parada de k6, después del último paso.

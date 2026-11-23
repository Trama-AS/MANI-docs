# QAS-24 y QAS-33 con el umbral B del acta A/B

> Evidencia de QA del Sprint 6. Resultado en el [SDD §8](../../../../02-arquitectura/SDD.md). Umbrales: [acta A/B](../../../../06-gobernanza/ACTA_DECISION_AB_ESCENARIOS_CALIDAD.md). Mantiene: QA (Santiago Hernández).

22 de noviembre de 2026, 18:10Z. Pedido de la SM: el barrido del 22 nov evaluó el 33 con el umbral anterior (adopción global del sistema de diseño) y el 24 mezclando los dos umbrales.

## QAS-33 Involucración: Cumple

**Umbral B:** ManiButton y ManiTextField obligatorios en pantallas nuevas o modificadas. **Cómo se mide:** en cada PR de Flutter que cree o modifique una pantalla no aparecen botones ni campos nativos nuevos.

**Método.** Diff de cada PR de MANI-Flutter desde la regla (SCRUM-1648, decidida el 17 nov y escrita en el README con #149) contra su base en `develop`, solo `lib/`. Se cuentan las líneas agregadas con `ElevatedButton`, `TextButton`, `OutlinedButton`, `FilledButton`, `TextField`, `TextFormField` o sus equivalentes de Cupertino.

| PR | Estado | Pantallas tocadas | Nativos agregados | ManiButton/ManiTextField agregados |
|---|---|---|---|---|
| #148 | Fusionado | 0 | 0 | 0 |
| #149 | Fusionado | 2 | 0 | 4 |
| #150 | Fusionado | 0 | 0 | 0 |
| #142 a #147 | Abiertos | 1 a 35 | 0 | 3 a 33 |
| #152 | Abierto | 40 | 20 | 7 |

**Resultado.** Lo fusionado en `develop` desde la regla cumple: el único PR que tocó pantallas (#149) agregó 4 componentes Mani y ningún nativo. Los seis PR de migración abiertos también cumplen.

**Hallazgo H-33-1.** MANI-Flutter#152 (abierto, rediseño visual de SCRUM-1646) no cumple la regla: 20 líneas con botones o campos nativos en pantallas que modifica (login, auditoría, conversación de queja, reglas operativas, avisos, cobros, política de cancelación y el widget `mani_estado`). La mayoría son líneas existentes que reescribe sin migrarlas; en `login_page` y `mani_estado` hay nativos nuevos. Si se fusiona así, QAS-33 pasa a No cumple. Responsable: equipo de Flutter.

**Límite.** Desde la regla solo hay un PR fusionado que toque pantallas; la muestra es pequeña.

## QAS-24 Adaptabilidad: No cumple (corrección del texto)

**Umbral B:** backend y Gateway, la misma imagen en DEV, QA y PROD con configuración externa. Flutter web, una imagen por ambiente construida desde el mismo commit, con la configuración ajustable al arrancar.

| Parte | Medición | Cumple con B |
|---|---|---|
| Backend (Core, Dispatch, Rules) y Gateway | `docker-publish.yml` construye una imagen nueva en cada push a `develop`, `release` y `main`, con las etiquetas `develop`, `staging` y `latest`. No hay paso que promueva un digest. QA corre `:staging` y PROD `:latest`, con digests distintos | No |
| Flutter web | Una imagen por ambiente está permitida. La configuración al arrancar (MANI-Flutter#150) está en `develop`; `release` y `main` siguen escribiendo el `.env` en el CI, así que QA y PROD no la tienen | No verificable hasta promoverla |

**Resultado.** Sigue en No cumple por el backend y el Gateway. El barrido anterior contaba a Flutter como incumplimiento; con B no lo es.

**Posible solución.** Construir una vez por commit, etiquetar por SHA y promover ese digest a `staging` y `latest` (por ejemplo con `docker buildx imagetools create`). Promover #150 a `release` y probar el arranque de Flutter con otro `.env`. Responsable: DevOps.

## Evidencia

- `qas33_prs_flutter_22nov.txt`: conteo por PR y detalle de #152.
- `qas24_ci_imagenes_22nov.txt`: disparadores y etiquetas del CI de imágenes de los cinco repositorios.
- Digests de QA: [`vm_qa_22nov_0257z.txt`](../20261122T025500Z_barrido_qas/vm_qa_22nov_0257z.txt). Digests de PROD: [mapa de ambientes](../../../../08-infraestructura/01-mapa-ambientes-y-versiones.md).

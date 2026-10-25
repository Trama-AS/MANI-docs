# Monitoreo verificable de QA y escenarios QAS-01 a QAS-09 (SCRUM-1266)

Scripts, configuración y evidencia de la tarea SCRUM-1266 (QA4-03) y sus subtareas SCRUM-1274
(QA-MON-01), SCRUM-1275 (QA-MON-02) y SCRUM-1276 (QA-MON-03). Los umbrales provienen del
[SDD §8](../../02-arquitectura/SDD.md) y no se modifican aquí. El resultado consolidado está en
[`qa/REPORTE_QA_SPRINT4.md` §7](../REPORTE_QA_SPRINT4.md#7-monitoreo-de-qa-y-escenarios-qas-01-a-qas-09-scrum-1266).

## Dónde corre cada herramienta

Las herramientas corren en la VM de Calidad (10.43.98.196) y apuntan al Gateway de QA
(10.43.100.141:80), igual que SonarQube, Newman y Playwright según la
[Guía CFG4-03](../REPORTE_QA_SPRINT4.md#3-cadena-de-calidad-en-qa-cfg4-03). En la VM de QA solo se lee el
estado de los contenedores, porque no hay una plataforma de métricas ni de logs centralizada. Correr
k6 en la VM de QA le quitaría CPU a los servicios medidos y alteraría el p95.

| Archivo | Para qué | Dónde corre |
|---|---|---|
| `obtener_token.sh` | Obtiene el JWT de prueba y lo guarda fuera del repositorio con permisos 600 | Calidad |
| `verificar_monitoreo.sh calidad` | QA-MON-01: healthchecks, 401 perimetral, propagación de `X-Correlation-ID`, puertos de Kafka y observabilidad | Calidad |
| `verificar_monitoreo.sh vm_qa` | QA-MON-01: contenedores, revisión de imagen, healthchecks declarados, Kafka u observabilidad en ejecución, variables del Core (sin valores), log del Gateway por correlation id, latencia `request_time`, `docker stats` | VM de QA (solo lectura) |
| `newman/qas01_perimetro.postman_collection.json` | Healthchecks, QAS-01 caso 5 (token ausente, mal formado, alterado o vencido) y exposición de `dev-token` | Calidad |
| `k6/qas03_latencia.js` | QAS-03: p95 bajo 300 sesiones y 50 req/s; umbral declarado en `thresholds` | Calidad |
| `k6/qas07_aceptacion_concurrente.js` | QAS-07: N aceptaciones simultáneas sobre una solicitud (arnés o evidencia) | Calidad |
| `k6/qas07_verificar_asignacion.sql` | QAS-07: lectura en base del estado final y del ganador | Supabase MANI-QA |
| `ejecutar_calidad.sh` | Orquesta todo lo anterior en Calidad e instala k6 si falta | Calidad |
| `confirmar_d02.sh` | H-02: inicio de sesión real en `MANI-QA` y llamada por el Gateway; pide anon key, correo y contraseña con entrada oculta e imprime solo códigos y el algoritmo del token | Calidad (`ssh -t`) |
| `redactar_evidencia.mjs` | Reemplaza JWT y valores `Bearer` por `<REDACTADO>` antes de versionar | Calidad o local |
| `plantilla_evidencia.md` | Registro por escenario: fecha, ambiente, carga, medido, umbral, estado, defectos | — |
| `qas06_api_vs_contrato.md` | QAS-06: tabla API publicada en QA contra contrato OpenAPI | — |
| `evidencia/` | Salidas redactadas, una carpeta por corrida | — |

## Fuente del token

`FUENTE_TOKEN` es obligatoria y queda registrada en cada resumen:

- `supabase`: password grant contra el proyecto Supabase `MANI-QA`. Requiere `SUPABASE_URL`,
  `SUPABASE_ANON_KEY`, `QA_EMAIL` y `QA_PASSWORD` como variables de entorno. Al 20 oct 2026 este
  camino no sirve: `MANI-QA` firma con ES256 y el Gateway rechaza esos tokens con 401 (comprobado
  con `confirmar_d02.sh`; hallazgo H-02 del informe).
- `dev_token`: `POST /api/v1/core/auth/dev-token` del Gateway de QA. Usa el defecto H-01 del
  informe. Toda corrida con esta fuente se declara así.

Cambiar de fuente solo exige cambiar `FUENTE_TOKEN` y volver a correr `obtener_token.sh`. Ningún
script incluye tokens, contraseñas ni llaves: todo entra por variables de entorno.

## Cómo se ejecuta

Desde un equipo con acceso a la red 10.43.x.x (campus o VPN):

```bash
# 1. Monitoreo en la VM de QA durante la carga (unos 12 min de muestreo)
ssh estudiante@10.43.100.141 'MUESTRAS=60 INTERVALO=10 DESDE=2h bash -s vm_qa' \
  < qa/monitoreo_qas/verificar_monitoreo.sh > salida_vm_qa.txt

# 2. En otra terminal, la corrida completa en Calidad, con la evidencia de vuelta por stdout
tar -czf - -C qa --exclude='evidencia/*' monitoreo_qas | ssh estudiante@10.43.98.196 \
  'rm -rf ~/scrum_1266 && mkdir -p ~/scrum_1266 && tar -xzf - -C ~/scrum_1266 &&
   FUENTE_TOKEN=dev_token EMPAQUETAR=1 bash ~/scrum_1266/monitoreo_qas/ejecutar_calidad.sh' \
  > salida_calidad.txt
```

La evidencia viaja entre las marcas `==INICIO_EVIDENCIA==` y `==FIN_EVIDENCIA==` como tar.gz en
base64. Antes de versionarla se pasa por `redactar_evidencia.mjs`.

Para correr un solo escenario en Calidad:

```bash
FUENTE_TOKEN=dev_token bash obtener_token.sh
k6 run -e ARCHIVO_TOKEN=$HOME/.mani_qa/token.txt k6/qas03_latencia.js
k6 run -e ARCHIVO_TOKEN=$HOME/.mani_qa/token.txt -e N=50 -e MODO=arnes k6/qas07_aceptacion_concurrente.js
```

## Reglas

- Un escenario medido sobre un stub o sobre una ruta distinta a la del SDD se reporta como línea
  base o como validación del arnés, nunca como cumplido.
- La evidencia de Newman guarda cabeceras completas: se redacta siempre antes de guardarla.
- En el contenedor del Gateway, `/var/log/nginx/access.log` es un enlace a stdout: el log se lee con
  `docker logs`, no con `tail` dentro del contenedor (se queda bloqueado).

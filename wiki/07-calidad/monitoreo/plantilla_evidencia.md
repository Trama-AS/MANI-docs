# Plantilla de evidencia por escenario (SCRUM-1266)

Se copia una vez por escenario y corrida. Ningún campo se llena con un valor que no salga de una
ejecución o de un archivo enlazado. Si el escenario no se pudo medir, el estado es `bloqueado`,
`no medible` o `no aplica`, con la razón; nunca `cumplido`.

| Campo | Valor |
|---|---|
| Escenario | QAS-0X: nombre (SDD §8) |
| Ticket | SCRUM-1275 |
| Fecha y hora (UTC) | AAAA-MM-DDTHH:MM:SSZ |
| Ambiente | QA (10.43.100.141); revisión de cada imagen según `verificar_monitoreo.sh vm_qa` |
| Origen de la carga | VM de Calidad (10.43.98.196) u otro, declarado |
| Ruta o artefacto medido | Método y ruta exactos, o PR y diff |
| Ruta del SDD | La que exige el escenario; si difiere de la medida, se dice |
| Fuente del token | `dev_token` o `supabase` |
| Carga | VUs, req/s, rampa, duración o número de casos |
| Herramienta y versión | k6, Newman, SQL, revisión manual |
| Resultado medido | Valor numérico o conteo, copiado del resumen |
| Umbral vigente | Texto literal del SDD §8 |
| Comparación | Dentro / fuera del umbral, con el número |
| Validez de la corrida | Tasa de status 200, tasa alcanzada, errores; si no es válida, por qué |
| Estado | `ejecutado`, `no cumple`, `bloqueado`, `no medible`, `no aplica` |
| Justificación | Enlace a ticket, archivo del repositorio o salida de comando |
| Evidencia | Rutas dentro de `qa/monitoreo_qas/evidencia/` |
| Defectos | Clave Jira o "borrador D-0X" |
| Limitaciones | Lo que la corrida no prueba |

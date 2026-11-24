# QAS-28: historias críticas ↔ casos de prueba

Corte 2026-11-21.

**Historia crítica (definición usada):** issue tipo Historia de Jira, funcional (clave US- o HU-), con prioridad Highest o High. JQL: `project = SCRUM AND issuetype = Historia AND priority in (Highest, High)` devuelve 61; se excluyen 10 que no son funcionales (FRONT T-06 y T-07, OPS T-28, T-29 y T-32, WIKI 01, 02, 03 y 04, VAL-01). Quedan **51**.

**Fuentes de casos:** `07-calidad/regresion/MANI_Matriz_Pruebas_Sprint4.xlsx`, `MANI_Matriz_Ejecucion_Sprint4.xlsx`, `REPORTE_QA_SPRINT5.md` (matriz por historia), `monitoreo/REPORTE_QA_SPRINT4.md` y `MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md`. Una historia cuenta si alguna fuente la cita por clave de Jira o por código US/HU. Se buscó además en toda `07-calidad`, `01-producto/TD.md` y las guías de prueba manual.

**Resultado:** 45 de 51 historias críticas tenían al menos un caso en las fuentes (88.2 %). Las 6 que faltaban tienen ahora sus casos definidos en [`qas28_casos_faltantes.md`](qas28_casos_faltantes.md): **51 de 51 (100 %)**.

## Sin caso

| Historia | Código |
|---|---|
| SCRUM-871 | HU-M07-04 |
| SCRUM-872 | US-04.3.5 |
| SCRUM-876 | US-04.4.3 |
| SCRUM-881 | US-05.1.1 |
| SCRUM-1061 | US-02.1.1-M3 |
| SCRUM-1071 | US-03.1.3-M2 |

## Con caso

| Historia | Código | Fuentes |
|---|---|---|
| SCRUM-846 | US-02.1.1 | REPORTE_QA_SPRINT4.md |
| SCRUM-849 | US-02.1.4 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md |
| SCRUM-850 | US-02.1.5 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-851 | US-02.2.1 | REPORTE_QA_SPRINT4.md |
| SCRUM-852 | US-02.2.2 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-853 | US-02.2.3 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-854 | US-02.3.1 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-855 | US-02.1.6 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-856 | US-02.3.2 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-857 | US-03.1.1 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md |
| SCRUM-858 | US-03.1.2 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-860 | US-04.1.1 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md |
| SCRUM-861 | US-04.1.2 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-862 | US-04.1.3 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-863 | US-04.1.4 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md |
| SCRUM-865 | US-04.2.1 | MANI_Matriz_Ejecucion_Sprint4.xlsx, REPORTE_QA_SPRINT4.md |
| SCRUM-867 | US-04.2.3 | MANI_Matriz_Ejecucion_Sprint4.xlsx |
| SCRUM-868 | US-04.3.1 | MANI_Matriz_Ejecucion_Sprint4.xlsx |
| SCRUM-869 | US-04.3.2 | MANI_Matriz_Ejecucion_Sprint4.xlsx |
| SCRUM-870 | US-04.3.3 | MANI_Matriz_Ejecucion_Sprint4.xlsx |
| SCRUM-873 | US-04.3.6 | REPORTE_QA_SPRINT5.md |
| SCRUM-877 | US-04.5.1 | REPORTE_QA_SPRINT5.md |
| SCRUM-878 | US-04.5.2 | REPORTE_QA_SPRINT5.md |
| SCRUM-880 | US-04.6.2 | REPORTE_QA_SPRINT5.md |
| SCRUM-883 | US-05.1.3 | REPORTE_QA_SPRINT5.md |
| SCRUM-885 | US-06.1.1 | REPORTE_QA_SPRINT5.md |
| SCRUM-888 | US-07.1.1 | REPORTE_QA_SPRINT5.md |
| SCRUM-889 | US-07.1.2 | REPORTE_QA_SPRINT5.md |
| SCRUM-890 | US-07.1.3 | REPORTE_QA_SPRINT5.md |
| SCRUM-894 | US-07.2.2 | REPORTE_QA_SPRINT5.md |
| SCRUM-895 | US-08.1.1 | REPORTE_QA_SPRINT5.md |
| SCRUM-896 | US-08.1.2 | REPORTE_QA_SPRINT5.md |
| SCRUM-900 | US-08.3.1 | REPORTE_QA_SPRINT5.md |
| SCRUM-901 | US-08.3.2 | REPORTE_QA_SPRINT5.md |
| SCRUM-1060 | US-02.1.2-M3 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-1063 | US-02.1.2-M2 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-1064 | US-02.2.1-M2 | REPORTE_QA_SPRINT4.md |
| SCRUM-1065 | US-02.1.1-M2 | REPORTE_QA_SPRINT4.md |
| SCRUM-1066 | US-02.1.3-M2 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-1068 | HU-M03 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT5.md, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-1069 | US-03.1.1-M2 | MANI_Matriz_Ejecucion_Sprint4.xlsx |
| SCRUM-1070 | US-03.1.1-M6 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-1072 | US-04.1.1-M2 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-1073 | US-04.1.1-M6 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |
| SCRUM-1074 | US-04.1.4-M6 | MANI_Matriz_Ejecucion_Sprint4.xlsx, MANI_Matriz_Pruebas_Sprint4.xlsx, REPORTE_QA_SPRINT4.md, MATRIZ_HISTORIAS_REPOSITORIOS_SPRINT4.md |

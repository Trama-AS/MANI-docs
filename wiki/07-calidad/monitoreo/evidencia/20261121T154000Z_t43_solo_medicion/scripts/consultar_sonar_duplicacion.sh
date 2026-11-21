#!/usr/bin/env bash
# SCRUM-1680 (T-43), QAS-21. Duplicacion que reporta el SonarQube de la VM de Calidad para los 5 repos.
# Solo lectura. La API anonima responde 401 desde el 5 nov, asi que pide un token de usuario de SonarQube
# (lo escribe la persona, no se muestra ni se guarda; viaja por la entrada del ssh, no como argumento).
# Despues pide la contrasena de la VM de Calidad.
# Uso: bash qa_t43/consultar_sonar_duplicacion.sh
set -u
cd "$(dirname "$0")/.."
CALIDAD=estudiante@10.43.98.196
MARCA=$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z')
mkdir -p qa_t43/evidencia
SAL="qa_t43/evidencia/qas21_sonar_${MARCA}.txt"
read -rsp "Token de usuario de SonarQube (no se muestra): " ST; echo
[ -n "$ST" ] || { echo "Sin token no hay consulta."; exit 1; }
echo "Se pide la contrasena de la VM de Calidad (10.43.98.196):"
{ printf 'ST=%q\n' "$ST"; cat <<'REMOTO'
H=http://localhost:9000
c() { curl -s -m 20 -K <(printf 'user = "%s:"\n' "$ST") "$H$1"; }
echo "== SonarQube $(curl -s -m 10 $H/api/server/version) $(date -u +%FT%TZ)"
echo "== autenticacion: $(c /api/authentication/validate)"
claves="mani-node mani-java mani-dotnet mani-apigateway mani-landing"
echo "== proyectos: $claves"
for k in $claves; do
  c "/api/measures/component?component=$k&metricKeys=duplicated_lines_density,duplicated_blocks,duplicated_files,duplicated_lines,ncloc" | python3 -c 'import json,sys
t = sys.stdin.read()
try:
    d = json.loads(t).get("component", {})
except ValueError:
    print("  respuesta no JSON:", t[:200]); sys.exit()
m = {x["metric"]: x.get("value") for x in d.get("measures", [])}
print("%s: densidad=%s %% bloques=%s archivos=%s lineas_dup=%s ncloc=%s" % (d.get("key"), m.get("duplicated_lines_density"), m.get("duplicated_blocks"), m.get("duplicated_files"), m.get("duplicated_lines"), m.get("ncloc")))'
  c "/api/project_analyses/search?project=$k&ps=1" | python3 -c 'import json,sys
t = sys.stdin.read()
try:
    a = json.loads(t).get("analyses", [])
except ValueError:
    print("   analisis: respuesta no JSON:", t[:200]); sys.exit()
print("   ultimo analisis:", a[0]["date"] if a else "ninguno", a[0].get("revision", "")[:7] if a else "")'
done
REMOTO
} | ssh -o ConnectTimeout=15 "$CALIDAD" 'bash -s' > "$SAL" 2>&1
unset ST
cat "$SAL"
echo "== salida guardada en $SAL"

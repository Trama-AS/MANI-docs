#!/usr/bin/env bash
# QAS-18/27: CPU y memoria por contenedor de QA (cAdvisor en Prometheus de la VM de Calidad) en las cargas de T-42. Solo lectura.
set -u
cd "$(dirname "$0")/.."
SAL="qa_barrido/evidencia/qas18_cpu_contenedores_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
ssh -o ConnectTimeout=15 estudiante@10.43.98.196 'python3 -' <<'PY' | tee "$SAL"
import json, urllib.request, urllib.parse
P = "http://127.0.0.1:9090/api/v1/"
def get(path, **a): return json.load(urllib.request.urlopen(P + path + "?" + urllib.parse.urlencode(a), timeout=120))["data"]
s = get("series", **{"match[]": 'container_cpu_usage_seconds_total{job="mani_qa_cadvisor"}', "start": "2026-11-20T19:30:00Z", "end": "2026-11-20T19:31:00Z"})
claves = sorted({k for x in s for k in x})
print("== etiquetas de container_cpu_usage_seconds_total:", claves, "series:", len(s))
etq = next((k for k in ("name", "container_label_com_docker_compose_service", "container", "id") if any(k in x and "mani" in x[k] for x in s)), None)
print("== etiqueta usada:", etq)
if etq:
    for nombre, ini, fin in (("carga 20 nov, 300 VU", "2026-11-20T19:25:00Z", "2026-11-20T19:45:00Z"), ("carga corta 21 nov", "2026-11-21T22:43:00Z", "2026-11-21T22:51:00Z")):
        print(f"-- {nombre} ({ini} a {fin})")
        cpu = get("query_range", query=f'sum by ({etq}) (rate(container_cpu_usage_seconds_total{{job="mani_qa_cadvisor",{etq}=~".*mani.*"}}[1m]))', start=ini, end=fin, step="30s")["result"]
        lim = {r["metric"].get(etq): float(r["value"][1]) for r in get("query", query=f'max by ({etq}) (container_spec_cpu_quota{{job="mani_qa_cadvisor",{etq}=~".*mani.*"}} / container_spec_cpu_period{{job="mani_qa_cadvisor",{etq}=~".*mani.*"}})', time=fin)["result"]}
        mem = {r["metric"].get(etq): float(r["value"][1]) for r in get("query", query=f'max by ({etq}) (max_over_time(container_memory_working_set_bytes{{job="mani_qa_cadvisor",{etq}=~".*mani.*"}}[20m]))', time=fin)["result"]}
        for r in sorted(cpu, key=lambda x: x["metric"].get(etq, "")):
            n = r["metric"].get(etq); v = sorted(float(x[1]) for x in r["values"])
            if not v or not any(k in n for k in ("core", "dispatch", "rules", "gateway")): continue
            med, p90, mx, l = v[len(v)//2], v[max(0, int(len(v)*0.9)-1)], v[-1], lim.get(n)
            f = lambda x: f"{x/l*100:.0f} % del limite" if l else "sin limite"
            print(f"   {n}: CPU mediana {med:.2f} nucleos ({f(med)}), p90 {p90:.2f} ({f(p90)}), max {mx:.2f}; limite {l} | memoria max {mem.get(n,0)/2**20:.0f} MiB")
PY
echo "== salida guardada en $SAL"

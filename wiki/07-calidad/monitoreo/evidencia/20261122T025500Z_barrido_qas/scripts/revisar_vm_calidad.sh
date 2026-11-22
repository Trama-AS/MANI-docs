#!/usr/bin/env bash
# Barrido de QAS viejos, VM de Calidad (10.43.98.196): consultas de solo lectura a Prometheus (127.0.0.1:9090).
# QAS-16 disponibilidad por sonda; QAS-18/27 CPU y memoria por contenedor de QA durante las cargas de T-42.
set -u
cd "$(dirname "$0")/.."
SAL="qa_barrido/evidencia/vm_calidad_prometheus_$(date -u +%d%b_%H%Mz | tr 'A-Z' 'a-z').txt"
ssh -o ConnectTimeout=15 estudiante@10.43.98.196 'python3 -' <<'PY' | tee "$SAL"
import json, urllib.request, urllib.parse, datetime
P = "http://127.0.0.1:9090/api/v1/"
def q(expr, t=None):
    a = {"query": expr}
    if t: a["time"] = t
    return json.load(urllib.request.urlopen(P + "query?" + urllib.parse.urlencode(a), timeout=60))["data"]["result"]
def qr(expr, ini, fin, paso="30s"):
    a = {"query": expr, "start": ini, "end": fin, "step": paso}
    return json.load(urllib.request.urlopen(P + "query_range?" + urllib.parse.urlencode(a), timeout=120))["data"]["result"]
print("== Fecha", datetime.datetime.utcnow().isoformat() + "Z")
try:
    print("== Targets:", ", ".join(sorted({f"{t['labels'].get('job')}:{t['health']}" for t in json.load(urllib.request.urlopen(P + "targets", timeout=30))["data"]["activeTargets"]})))
except Exception as e: print("targets:", e)
print("\n== QAS-16: disponibilidad por sonda (probe_success del blackbox)")
for v in ("7d", "14d"):
    try:
        prom = {r["metric"].get("instance"): float(r["value"][1]) for r in q(f"avg_over_time(probe_success[{v}])")}
        n = {r["metric"].get("instance"): int(float(r["value"][1])) for r in q(f"count_over_time(probe_success[{v}])")}
        mn = {r["metric"].get("instance"): float(r["value"][1]) for r in q(f"min_over_time(timestamp(probe_success)[{v}:5m])")}
        print(f"-- ventana {v}")
        for i in sorted(prom):
            ini = datetime.datetime.utcfromtimestamp(mn.get(i, 0)).strftime("%Y-%m-%d %H:%MZ") if mn.get(i) else "?"
            print(f"   {i}: {prom[i]*100:.3f} %  ({n.get(i)} muestras, primera {ini})")
    except Exception as e: print(f"-- {v}: ERROR {e}")
print("\n== QAS-18/27: CPU (nucleos) y memoria por contenedor de QA en las cargas de T-42")
for nombre, ini, fin in (("carga 20 nov", "2026-11-20T19:24:00Z", "2026-11-20T19:46:00Z"), ("carga corta 21 nov", "2026-11-21T22:42:00Z", "2026-11-21T22:52:00Z")):
    print(f"-- {nombre} ({ini} a {fin})")
    try:
        cpu = qr('sum by (name) (rate(container_cpu_usage_seconds_total{name=~"mani-.*"}[1m]))', ini, fin)
        lim = {r["metric"]["name"]: float(r["value"][1]) for r in q('max by (name) (container_spec_cpu_quota{name=~"mani-.*"} / container_spec_cpu_period{name=~"mani-.*"})', fin)}
        mem = {r["metric"]["name"]: float(r["value"][1]) for r in q('max by (name) (max_over_time(container_memory_working_set_bytes{name=~"mani-.*"}[25m]))', fin)}
        meml = {r["metric"]["name"]: float(r["value"][1]) for r in q('max by (name) (container_spec_memory_limit_bytes{name=~"mani-.*"})', fin)}
        for r in sorted(cpu, key=lambda x: x["metric"]["name"]):
            n = r["metric"]["name"]; vals = sorted(float(v[1]) for v in r["values"])
            if not vals: continue
            med = vals[len(vals)//2]; p90 = vals[int(len(vals)*0.9)-1]; mx = vals[-1]; l = lim.get(n)
            pct = lambda x: f"{x/l*100:.0f} %" if l else "sin limite"
            print(f"   {n}: CPU mediana {med:.2f} ({pct(med)}), p90 {p90:.2f} ({pct(p90)}), max {mx:.2f}; limite {l if l else '-'} | memoria max {mem.get(n,0)/2**20:.0f} MiB de {meml.get(n,0)/2**20:.0f} MiB")
    except Exception as e: print("   ERROR", e)
PY
echo "== salida guardada en $SAL"

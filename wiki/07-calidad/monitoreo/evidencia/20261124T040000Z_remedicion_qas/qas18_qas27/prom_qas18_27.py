# Corre en Calidad. Lee Prometheus (127.0.0.1:9090). Argumentos: etiqueta inicio fin (epoch). Solo lectura.
import json, sys, urllib.parse, urllib.request
et, ini, fin = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
cpu = 'sum by (name) (rate(container_cpu_usage_seconds_total{name=~"mani-.*",ambiente="qa"}[2m])) / on (name) max by (name) (container_spec_cpu_quota{name=~"mani-.*",ambiente="qa"} / container_spec_cpu_period{name=~"mani-.*",ambiente="qa"}) * 100'
mem = 'max by (name) (container_memory_working_set_bytes{name=~"mani-.*",ambiente="qa"}) / max by (name) (container_spec_memory_limit_bytes{name=~"mani-.*",ambiente="qa"} > 0) * 100'
vm = '(1 - avg(rate(node_cpu_seconds_total{mode="idle",ambiente="qa"}[2m]))) * 100'
def rango(q):
    u = 'http://127.0.0.1:9090/api/v1/query_range?' + urllib.parse.urlencode({'query': q, 'start': ini, 'end': fin, 'step': 30})
    return json.load(urllib.request.urlopen(u, timeout=20))['data']['result']
print('== Prometheus %s, %d a %d' % (et, ini, fin))
m = {r['metric'].get('name'): [float(v[1]) for v in r['values']] for r in rango(mem)}
filas = rango(cpu)
if not filas:
    print('SIN SERIES por contenedor'); sys.exit(1)
for r in sorted(filas, key=lambda r: -max(float(v[1]) for v in r['values'])):
    v = [float(x[1]) for x in r['values']]; n = r['metric'].get('name')
    mm = m.get(n)
    print('  %-28s CPU media %5.1f%%  max %5.1f%%  mem max %s  n=%d' % (n, sum(v) / len(v), max(v), '%.0f%%' % max(mm) if mm else 'sin limite', len(v)))
for r in rango(vm):
    v = [float(x[1]) for x in r['values']]
    print('  CPU de la VM media %.1f%% max %.1f%%' % (sum(v) / len(v), max(v)))

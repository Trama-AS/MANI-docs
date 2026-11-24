# QAS-27, 24 nov. Corre en la VM de QA. Solo GET por la red interna (localhost:80); no escribe en la base ni toca contenedores.
# Por objetivo: base (solo sondas), saturado (procesos que piden sin pausa), recuperacion. CPU y memoria salen de cAdvisor (localhost:8081).
# Argumentos: segundos_base segundos_saturado segundos_recuperacion procesos objetivo...   Modo ensayo: "ensayo" solo comprueba rutas y series.
import http.client, json, multiprocessing, os, re, statistics, subprocess, sys, threading, time, urllib.request
CRITICOS = ['mani-api-gateway', 'mani-core-service', 'mani-rules-service', 'mani-dispatch-service']
SATURAR = {'rules': '/api/v1/rules/metrics', 'core': '/api/v1/core/metrics'}
SONDAS = {'gateway': '/health', 'core': '/api/v1/core/metrics', 'rules': '/api/v1/rules/health', 'dispatch': '/api/v1/dispatch/health'}
UMBRAL_MS = 500

def pedir(con, ruta, t=10):
    con.request('GET', ruta, headers={'X-Correlation-ID': 'qas-27'})
    r = con.getresponse(); r.read(); return r.status

def nueva():
    return http.client.HTTPConnection('127.0.0.1', 80, timeout=10)

def ahora():
    return time.strftime('%H:%M:%SZ', time.gmtime())

def cadvisor():
    txt = urllib.request.urlopen('http://127.0.0.1:8081/metrics', timeout=20).read().decode()
    d = {}
    for l in txt.splitlines():
        m = re.match(r'(container_(?:cpu_usage_seconds_total|memory_working_set_bytes|spec_cpu_quota|spec_cpu_period|spec_memory_limit_bytes|cpu_cfs_throttled_periods_total|cpu_cfs_periods_total))\{(.*)\} (\S+)(?: (\d+))?$', l)
        if not m or 'name="mani-' not in m[2]:
            continue
        n = re.search(r'name="([^"]+)"', m[2])[1]
        k = m[1]
        a = d.setdefault(n, {})
        v = float(m[3])
        if k == 'container_cpu_usage_seconds_total' and k in a:
            a[k] = (a[k][0] + v, a[k][1])
        else:
            a[k] = (v, int(m[4]) / 1000 if m[4] else time.time())
    return d

def martillo(ruta, fin, parar, cuenta):
    os.nice(10)
    con = nueva(); n = 0
    while time.time() < fin.value and not parar.is_set():
        try:
            pedir(con, ruta); n += 1
        except Exception:
            con.close(); con = nueva(); time.sleep(0.2)
    with cuenta.get_lock():
        cuenta.value += n

class Sondas(threading.Thread):
    def __init__(self):
        super().__init__(daemon=True); self.fase = ''; self.datos = []; self.vivo = True
    def run(self):
        while self.vivo:
            for nombre, ruta in SONDAS.items():
                t = time.time()
                try:
                    c = nueva(); s = pedir(c, ruta); c.close()
                except Exception:
                    s = 0
                self.datos.append((self.fase, nombre, (time.time() - t) * 1000, s))
            time.sleep(0.5)

def p95(x):
    x = sorted(x); return x[max(0, int(round(0.95 * len(x) + 0.5)) - 1)] if x else float('nan')

def muestrear(seg, muestras):
    fin = time.time() + seg
    while time.time() < fin:
        try:
            muestras.append(cadvisor())
        except Exception as e:
            print('  cadvisor no respondio:', type(e).__name__)
        time.sleep(min(10, max(0, fin - time.time())))

def resumen_cpu(muestras, n):
    s = [(m[n]['container_cpu_usage_seconds_total'][1], m[n]['container_cpu_usage_seconds_total'][0]) for m in muestras if n in m and 'container_cpu_usage_seconds_total' in m[n]]
    s = sorted(set(s))
    if len(s) < 2 or s[-1][0] == s[0][0]:
        return None, None
    lim = muestras[-1][n]
    q = lim.get('container_spec_cpu_quota', (0,))[0] / max(1, lim.get('container_spec_cpu_period', (100000,))[0])
    if not q:
        return None, None
    media = (s[-1][1] - s[0][1]) / (s[-1][0] - s[0][0]) / q * 100
    tramos = [(b[1] - a[1]) / (b[0] - a[0]) / q * 100 for a, b in zip(s, s[1:]) if b[0] - a[0] >= 5]
    return media, max(tramos) if tramos else media

def estado():
    r = {}
    for n in CRITICOS:
        o = subprocess.run(['docker', 'inspect', '-f', '{{.RestartCount}} {{.State.OOMKilled}} {{.State.StartedAt}} {{.HostConfig.NanoCpus}} {{.HostConfig.Memory}}', n], capture_output=True, text=True).stdout.strip()
        r[n] = o
    return r

def ensayo():
    print('nucleos', os.cpu_count(), '| carga', os.getloadavg())
    ok = True
    for n, r in list(SONDAS.items()) + [('satura ' + k, v) for k, v in SATURAR.items()]:
        t = time.time()
        try:
            c = nueva(); c.request('GET', r); x = c.getresponse(); b = x.read(); s = x.status
        except Exception as e:
            s, b = type(e).__name__, b''
        ok &= s == 200
        print('  %-16s %-28s %s %d bytes %.0f ms' % (n, r, s, len(b), (time.time() - t) * 1000))
    d = cadvisor()
    print('contenedores en cAdvisor:', len(d))
    for n in sorted(d):
        a = d[n]
        print('  %-26s cpu=%s cuota=%s mem_limite=%s' % (n, 'si' if 'container_cpu_usage_seconds_total' in a else 'NO', a.get('container_spec_cpu_quota', ('-',))[0], a.get('container_spec_memory_limit_bytes', ('-',))[0]))
    falta = [n for n in CRITICOS if 'container_cpu_usage_seconds_total' not in d.get(n, {})]
    print('faltan criticos:', falta or 'ninguno')
    return 0 if ok and not falta else 1

def main():
    if sys.argv[1] == 'ensayo':
        return ensayo()
    base, sat, rec, procesos = map(int, sys.argv[1:5])
    ant = estado()
    so = Sondas(); so.fase = 'inicio'; so.start()
    for obj in sys.argv[5:]:
        cont = {'rules': 'mani-rules-service', 'core': 'mani-core-service'}[obj]
        print('== Objetivo %s, %s' % (obj, ahora()))
        ms = {}
        so.fase = obj + ':base'; print('base desde', ahora(), 'epoch', int(time.time())); ms['base'] = []; muestrear(base, ms['base'])
        parar = multiprocessing.Event(); cuenta = multiprocessing.Value('i', 0); fin = multiprocessing.Value('d', time.time() + sat)
        ps = [multiprocessing.Process(target=martillo, args=(SATURAR[obj], fin, parar, cuenta)) for _ in range(procesos)]
        so.fase = obj + ':saturado'; print('saturado desde', ahora(), 'epoch', int(time.time()), 'procesos', procesos)
        for p in ps: p.start()
        ms['saturado'] = []
        t_fin = time.time() + sat
        while time.time() < t_fin:
            muestrear(min(15, t_fin - time.time()), ms['saturado'])
            u = [d for d in so.datos[-40:] if d[0] == so.fase and d[1] not in (obj,)]
            if len(u) >= 20 and sum(d[3] != 200 for d in u) > len(u) / 2:
                print('CORTE: mas de la mitad de las sondas de los vecinos falla'); parar.set(); break
        parar.set()
        for p in ps:
            p.join(15)
            if p.is_alive(): p.terminate()
        so.fase = obj + ':recuperacion'; print('recuperacion desde', ahora(), 'epoch', int(time.time())); ms['rec'] = []; muestrear(rec, ms['rec'])
        print('peticiones de saturacion: %d (%.0f/s)' % (cuenta.value, cuenta.value / sat))
        print('CPU % del limite (media / maximo por tramo)')
        for n in CRITICOS:
            f = []
            for k in ('base', 'saturado', 'rec'):
                a, b = resumen_cpu(ms[k], n)
                f.append('sin serie' if a is None else '%.1f / %.1f' % (a, b))
            mem = [m[n]['container_memory_working_set_bytes'][0] / m[n]['container_spec_memory_limit_bytes'][0] * 100 for m in ms['saturado'] if n in m and m[n].get('container_spec_memory_limit_bytes', (0,))[0]]
            x = [m[n] for m in ms['saturado'] if n in m and 'container_cpu_cfs_periods_total' in m[n]]
            th = ''
            if len(x) > 1:
                dp = x[-1]['container_cpu_cfs_periods_total'][0] - x[0]['container_cpu_cfs_periods_total'][0]
                dt = x[-1].get('container_cpu_cfs_throttled_periods_total', (0,))[0] - x[0].get('container_cpu_cfs_throttled_periods_total', (0,))[0]
                th = 'frenado %.0f%%' % (dt / dp * 100) if dp else ''
            print('  %-24s base %-14s saturado %-14s recup %-14s mem max %.0f%% %s' % (n, f[0], f[1], f[2], max(mem) if mem else -1, th))
        print('Sondas (ms): p50 / p95 / n / fallos')
        peor = []
        for s in SONDAS:
            f = []
            for k in ('base', 'saturado', 'recuperacion'):
                d = [x for x in so.datos if x[0] == obj + ':' + k and x[1] == s]
                v = [x[2] for x in d]
                f.append('%.0f / %.0f / %d / %d' % (statistics.median(v) if v else -1, p95(v), len(v), sum(x[3] != 200 for x in d)))
                if k == 'saturado' and s != obj:
                    peor.append((s, p95(v), sum(x[3] != 200 for x in d)))
            print('  %-9s base %-22s saturado %-22s recup %s' % (s, f[0], f[1], f[2]))
        a, b = resumen_cpu(ms['saturado'], cont)
        print('El objetivo llego a su limite (media >= 90%%): %s' % ('sin serie' if a is None else 'SI' if a >= 90 else 'NO, %.0f%%' % a))
        print('Vecinos sobre %d ms o con fallos: %s' % (UMBRAL_MS, [(s, round(p)) for s, p, e in peor if p > UMBRAL_MS or e] or 'ninguno'))
    so.vivo = False
    des = estado()
    print('== Contenedores (reinicios, OOM, arranque, cpus, memoria)')
    for n in CRITICOS:
        print('  %-24s %s %s' % (n, des[n], 'IGUAL' if ant[n] == des[n] else 'CAMBIO, antes ' + ant[n]))
    return 0

sys.exit(main())

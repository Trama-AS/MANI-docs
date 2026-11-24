# QAS-05. Cruza los pasos (salida de la corrida) con el log del Gateway aislado y los resumenes de k6.
# Uso: python3 analizar_qas05.py salida.txt gateway.jsonl carpeta_k6
import collections, json, os, sys
salida, registro, carpeta = sys.argv[1:4]
pasos, replicas, vistos = [], collections.defaultdict(dict), []
inicio = {}
for l in open(salida, encoding='utf8', errors='replace'):
    c = l.split()
    if not c:
        continue
    if c[0] == 'ESCALAR':
        inicio[(c[1], int(c[2]))] = int(c[3])
    elif c[0] == 'PASO':
        pasos.append([c[1], int(c[2]), int(c[3]), None])
    elif c[0] == 'FIN_PASO':
        for p in pasos:
            if p[0] == c[1] and p[1] == int(c[2]) and p[3] is None:
                p[3] = int(c[3])
    elif c[0] == 'REPLICA':
        replicas[(c[1], int(c[2]))][c[3]] = (c[4].lstrip('/'), c[5])
filas = [json.loads(l) for l in open(registro, encoding='utf8') if l.startswith('{')]
veredictos = {}
for servicio in ('core-service', 'rules-service', 'dispatch-service'):
    corto = servicio.split('-')[0]
    propias = [f for f in filas if f['x_correlation_id'].startswith(f'qas-05-{corto}-')]
    mis = [p for p in pasos if p[0] == servicio]
    if not mis:
        print(f'== {servicio}: SIN MEDIR'); veredictos[servicio] = None; continue
    print(f'== {servicio}')
    ok = [p[1] for p in mis] == [2, 3, 4, 5, 6] and all(p[3] for p in mis)
    if not ok:
        print('  pasos incompletos:', [p[1] for p in mis])
    for s, n, a, b in mis:
        if not b:
            continue
        mapa = replicas[(s, n)]
        # NGINX resuelve cada 30 s: se cuenta desde 35 s despues de que la replica nueva quedo lista.
        ventana = [f for f in propias if a + 35 <= float(f['msec']) <= b]
        tramo = [f for f in propias if inicio[(s, n)] <= float(f['msec']) <= b]
        cuenta = collections.Counter(f['upstream_addr'].split(', ')[-1].split(':')[0] for f in ventana)
        atienden = [i for i in mapa if cuenta.get(i)]
        reparto = ' '.join(str(cuenta.get(i, 0)) for i in sorted(mapa))
        imagen = all(m[1] == 'misma_imagen' for m in mapa.values()) and len(mapa) == n
        malas = [f for f in tramo if f['status'] != '200']
        reintentos = sum(',' in f['upstream_addr'] for f in tramo)
        ajenas = sum(v for i, v in cuenta.items() if i not in mapa)
        bien = len(atienden) == n and imagen and not malas and not ajenas
        ok = ok and bien
        print(f'  {n} replicas: atienden {len(atienden)} de {n}; reparto {reparto}; misma imagen {"si" if imagen else "NO"}; no 200 en el tramo {len(malas)} de {len(tramo)}; reintentos del Gateway {reintentos}; fuera del mapa {ajenas} -> {"PASA" if bien else "FALLA"}')
    j = os.path.join(carpeta, f'k6_{corto}.json')
    k = json.load(open(j)) if os.path.exists(j) else None
    if not k:
        print('  sin resumen de k6'); ok = False
    else:
        print(f'  k6: {k["peticiones"]} peticiones a {k["rps"]}/s; no 200 {k["no_200"]}; 5xx o sin respuesta {k["fallas_5xx"]}; descartadas {k["descartadas"]}; ' + '; '.join(f'{r} p95 {x["p95_ms"]:.0f} ms' for r, x in k['por_ruta'].items()))
        ok = ok and k['no_200'] == 0 and k['peticiones'] > 0
    veredictos[servicio] = ok
    print(f'  {servicio}: {"PASA" if ok else "FALLA"}')
medidos = [v for v in veredictos.values() if v is not None]
print('== QAS-05 (umbral B):', 'SIN DATOS' if not medidos else ('CUMPLE' if len(medidos) == 3 and all(medidos) else ('NO CUMPLE' if not all(medidos) else 'PARCIAL')), {k: v for k, v in veredictos.items()})
sys.exit(0 if len(medidos) == 3 and all(medidos) else 1)

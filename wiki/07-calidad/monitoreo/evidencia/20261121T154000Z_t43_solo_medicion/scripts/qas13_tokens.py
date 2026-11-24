#!/usr/bin/env python3
"""SCRUM-1680 (T-43), QAS-13. Tokens por el Gateway de QA sobre cada ruta protegida de los contratos de release.

Casos por operacion: ausente, firma alterada (token real con la firma cambiada), vencido real (token de Supabase
emitido por el login real y ya expirado) y de otro emisor (JWT ES256 bien firmado con una llave propia, iss ajeno).
Se espera 401 o 403 en todos. No imprime tokens ni claves.

Uso: python3 qa_t43/qas13_tokens.py <archivo_token_json>
El archivo lo deja qa_t43/correr_qas13.sh obtener; debe estar vencido (exp < ahora).
"""
import base64
import collections
import concurrent.futures as cf
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request
import uuid

GW = 'http://10.43.100.141:8080'
RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PREFIJO = {'core': '/api/v1/core', 'dispatch': '/api/v1/dispatch', 'rules': '/api/v1/rules'}
EXCLUIDAS = re.compile(r'/auth/|^/health|/metrics|/catalog$|/legal/documents/active')


def git(repo, *args):
    return subprocess.run(['git', '-C', os.path.join(RAIZ, repo), *args], capture_output=True, text=True).stdout


def contratos():
    salida = {}
    for nombre in PREFIJO:
        ruta, metodo, ops = None, None, []
        for linea in git('MANI-API', 'show', f'origin/release:docs/openapi/{nombre}.yaml').splitlines():
            m = re.match(r'^  (/\S*):\s*$', linea)
            if m:
                ruta, metodo = m.group(1), None
                continue
            if re.match(r'^\S', linea):
                ruta, metodo = None, None
                continue
            m = re.match(r'^    (get|post|put|patch|delete):\s*$', linea)
            if m and ruta:
                metodo = m.group(1).upper()
                ops.append([metodo, ruta, False])
                continue
            if metodo and re.match(r'^      security:\s*\[\s*\]', linea):
                ops[-1][2] = True
        salida[nombre] = ops
    return salida


def peticion(metodo, url, cabeceras=None, cuerpo=None):
    datos = json.dumps(cuerpo).encode() if cuerpo is not None else None
    req = urllib.request.Request(url, data=datos, method=metodo, headers={'Content-Type': 'application/json', **(cabeceras or {})})
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            return r.status, r.read()[:200]
    except urllib.error.HTTPError as e:
        return e.code, e.read()[:200]
    except Exception as e:
        return 0, str(e)[:80].encode()


def b64(obj):
    return base64.urlsafe_b64encode(json.dumps(obj, separators=(',', ':')).encode()).rstrip(b'=').decode()


def dec(parte):
    return json.loads(base64.urlsafe_b64decode(parte + '=' * (-len(parte) % 4)))


def firmar_es256_propio(claims):
    """JWT ES256 valido en forma, firmado con una llave P-256 generada aqui (no la de Supabase)."""
    cab = b64({'alg': 'ES256', 'typ': 'JWT', 'kid': 'qa-otro-emisor'})
    cuerpo = b64(claims)
    js = ("const c=require('crypto');const {privateKey}=c.generateKeyPairSync('ec',{namedCurve:'P-256'});"
          "const d=process.argv[1];const s=c.sign('sha256',Buffer.from(d),{key:privateKey,dsaEncoding:'ieee-p1363'});"
          "process.stdout.write(s.toString('base64url'));")
    firma = subprocess.run(['node', '-e', js, f'{cab}.{cuerpo}'], capture_output=True, text=True, check=True).stdout
    return f'{cab}.{cuerpo}.{firma}'


def main():
    datos = json.load(open(sys.argv[1]))
    real = datos['access_token']
    partes = real.split('.')
    cab, claims = dec(partes[0]), dec(partes[1])
    ahora = int(time.time())
    print(f"== QAS-13 {time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}")
    print(f"  token real: alg={cab.get('alg')}; emitido={time.strftime('%H:%M:%SZ', time.gmtime(claims['iat']))}; "
          f"vence={time.strftime('%H:%M:%SZ', time.gmtime(claims['exp']))}; vencido hace {ahora - claims['exp']} s")
    casos_pedidos = os.environ.get('QAS13_CASOS', 'ausente,firma_alterada,vencido_real,otro_emisor_es256').split(',')
    if 'vencido_real' in casos_pedidos and claims['exp'] >= ahora:
        sys.exit('ABORTA: el token real todavia no vence; se corre despues de la hora de vencimiento')
    ajeno = {**claims, 'iss': 'https://otro-emisor.qa.invalid/auth/v1', 'iat': ahora, 'exp': ahora + 3600}
    tokens = {
        'ausente': None,
        'firma_alterada': partes[0] + '.' + partes[1] + '.' + partes[2][:-6] + ('AAAAAA' if not partes[2].endswith('AAAAAA') else 'BBBBBB'),
        'vencido_real': real,
        'otro_emisor_es256': firmar_es256_propio(ajeno),
    }
    tokens = {k: v for k, v in tokens.items() if k in casos_pedidos}
    print(f"  casos: {', '.join(tokens)}")
    print(f"  otro emisor: alg=ES256, firma P-256 propia, iss={ajeno['iss']}, mismos sub/tenant/rol, exp +1 h")

    casos = []
    for servicio, lista in contratos().items():
        for metodo, ruta, publica in lista:
            if publica or EXCLUIDAS.search(ruta):
                continue
            url = GW + PREFIJO[servicio] + re.sub(r'\{[^}]+\}', str(uuid.uuid4()), ruta)
            casos.append((servicio, metodo, ruta, url))
    resultado, malos, fugas = collections.Counter(), [], []

    def probar(caso):
        servicio, metodo, ruta, url = caso
        filas = []
        for nombre, token in tokens.items():
            cab_h = {'X-Correlation-ID': f'qas13-t43-{uuid.uuid4().hex[:8]}'}
            if token:
                cab_h['Authorization'] = f'Bearer {token}'
            codigo, cuerpo = peticion(metodo, url, cab_h, {} if metodo != 'GET' else None)
            filas.append((nombre, codigo, servicio, metodo, ruta, cuerpo))
        return filas

    # Las escrituras pasan por el limite write_limit del Gateway (60/min por IP, burst 40, antes de auth_request).
    # Se envian en serie a 1 cada 1,1 s para que el 429 no tape la validacion del token. Las lecturas no tienen limite.
    lecturas = [c for c in casos if c[1] == 'GET']
    escrituras = [c for c in casos if c[1] != 'GET']

    def probar_pausado(caso):
        servicio, metodo, ruta, url = caso
        filas = []
        for nombre, token in tokens.items():
            time.sleep(1.1)
            cab_h = {'X-Correlation-ID': f'qas13-t43-{uuid.uuid4().hex[:8]}'}
            if token:
                cab_h['Authorization'] = f'Bearer {token}'
            codigo, cuerpo = peticion(metodo, url, cab_h, {})
            filas.append((nombre, codigo, servicio, metodo, ruta, cuerpo))
        return filas

    print(f"  lecturas {len(lecturas)} en paralelo; escrituras {len(escrituras)} en serie (~{len(escrituras) * len(tokens) * 1.1 / 60:.1f} min)", flush=True)
    time.sleep(65)  # deja vaciar el balde del limite antes de empezar
    with cf.ThreadPoolExecutor(6) as ex:
        todas = list(ex.map(probar, lecturas)) + [probar_pausado(c) for c in escrituras]
    for filas in todas:
            for nombre, codigo, servicio, metodo, ruta, cuerpo in filas:
                resultado[f'{nombre}:{codigo}'] += 1
                if codigo not in (401, 403):
                    malos.append(f'{nombre} {codigo} {metodo} {PREFIJO[servicio]}{ruta}')
                elif re.search(rb'"(id|tenant_?[iI]d|email|nombre)"\s*:', cuerpo):
                    fugas.append(f'{nombre} {codigo} {metodo} {PREFIJO[servicio]}{ruta}')
    total = len(casos) * len(tokens)
    por_servicio = collections.Counter(c[0] for c in casos)
    print(f'  operaciones protegidas probadas: {len(casos)} {dict(por_servicio)}; intentos: {total}')
    for k in sorted(resultado):
        print(f'    {k}: {resultado[k]}')
    etiqueta = 'PASA ' if not malos else 'FALLA'
    print(f'{etiqueta} | QAS-13 | intento sin token valido rechazado con 401/403 | esperado {total} de {total} | obtenido {total - len(malos)} de {total}')
    print(f'  aceptados (2xx): {sum(1 for m in malos if m.split()[1].startswith("2"))}; limitados (429): {sum(1 for m in malos if m.split()[1] == "429")}')
    for m in malos[:60]:
        print(f'  no rechazado: {m}')
    print(f"{'PASA ' if not fugas else 'FALLA'} | QAS-13 | rechazos sin datos de negocio en el cuerpo | {len(fugas)} con datos")
    for m in fugas[:20]:
        print(f'  cuerpo con datos: {m}')
    sys.exit(1 if malos or fugas else 0)


if __name__ == '__main__':
    main()

"""SCRUM-1664 (T-27). Genera la coleccion Newman de negativos de las operaciones criticas (QAS-10 Integridad).

Cada operacion critica tiene al menos un negativo de rol, uno de payload invalido y uno de reintento duplicado.
Cada request comprueba el codigo HTTP y el codigo MANI del cuerpo (es decir, que respondio la validacion esperada).
El estado persistido lo compara t27_qa.py en el motor, antes y despues de correr la coleccion.

Uso local: python3 qa_t27/generar_coleccion_t27.py  ->  qa_t27/coleccion_t27_negativos.json
En la VM, t27_qa.py importa CASOS y arma la coleccion filtrando los casos que no aplican al estado de los datos.
"""
import json
import os

CORE = '{{gw}}/api/v1/core'
DSP = '{{gw}}/api/v1/dispatch'
PLOMERIA_T1 = '60000000-0000-4000-8000-000000000011'
SITIO_T1 = '70000000-0000-4000-8000-000000000011'
TARIFA_OK = {'categoriaId': PLOMERIA_T1, 'valorMin': '{{t_min}}', 'valorTipico': '{{t_tip}}', 'valorMax': '{{t_max}}'}

# operacion, id, tipo, metodo, url, token, cuerpo, cabeceras, http esperado, regex del codigo MANI, guarda (si aplica)
CASOS = [
    # 1. Crear solicitud (SCRUM-1072)
    ('crear_solicitud', 'C-ROL', 'rol', 'POST', f'{CORE}/solicitudes', 'aliado_t1',
     {'categoriaId': PLOMERIA_T1, 'sitioId': SITIO_T1, 'descripcion': 'SCRUM-1664 T-27 {{corrida}} intento de aliado publicando'},
     None, [403], r'^MANI-SOL-403', None),
    ('crear_solicitud', 'C-PAY', 'payload', 'POST', f'{CORE}/solicitudes', 'cliente_t1',
     {'categoriaId': PLOMERIA_T1, 'sitioId': SITIO_T1, 'descripcion': 'corta', 'claveIdempotencia': '{{clave_nueva_1}}'},
     None, [400, 422], r'^MANI-SOL-422D', None),
    ('crear_solicitud', 'C-DUP', 'duplicado', 'POST', f'{CORE}/solicitudes', 'cliente_t1',
     {'categoriaId': PLOMERIA_T1, 'sitioId': SITIO_T1, 'descripcion': '{{desc_s_pend}}', 'claveIdempotencia': '{{clave_s_pend}}'},
     None, [200, 201], None, None),
    ('crear_solicitud', 'C-DUP2', 'duplicado', 'POST', f'{CORE}/solicitudes', 'cliente_t1',
     {'categoriaId': PLOMERIA_T1, 'sitioId': SITIO_T1, 'descripcion': '{{desc_s_pend}} con otros datos', 'claveIdempotencia': '{{clave_s_pend}}'},
     None, [409], r'^MANI-SOL-409K', None),

    # 2. Aceptar solicitud (Dispatch, SCRUM-1074)
    ('aceptar_solicitud', 'A-ROL', 'rol', 'POST', f'{DSP}/requests/{{{{s_pend}}}}/accept', 'cliente_t1', None,
     {'Idempotency-Key': '{{clave_nueva_2}}'}, [403], r'^MANI-DSP-403', None),
    ('aceptar_solicitud', 'A-TEN', 'tenant', 'POST', f'{DSP}/requests/{{{{s_pend}}}}/accept', 'aliado_t2', None,
     {'Idempotency-Key': '{{clave_nueva_3}}'}, [403, 404], r'^MANI-(DSP|SOL)-40[34]', None),  # Dispatch propaga el codigo de Core (decision 6A)
    ('aceptar_solicitud', 'A-PAY', 'payload', 'POST', f'{DSP}/requests/no-es-uuid/accept', 'aliado_t1', None,
     {'Idempotency-Key': '{{clave_nueva_4}}'}, [400, 404], r'^MANI-DSP-40[04]', None),
    ('aceptar_solicitud', 'A-DUP', 'duplicado', 'POST', f'{DSP}/requests/{{{{s_full}}}}/accept', 'aliado_t1', None,
     {'Idempotency-Key': '{{clave_nueva_5}}'}, [200, 409], r'^(MANI-DSP-409|$)', None),
    ('aceptar_solicitud', 'A-EST', 'estado', 'POST', f'{DSP}/requests/{{{{s_cancel}}}}/accept', 'aliado_t1', None,
     {'Idempotency-Key': '{{clave_nueva_11}}'}, [404, 409], r'^MANI-(DSP|SOL)-40[49]', None),  # idem

    # 3. Aceptar cotizacion (SCRUM-1076)
    ('aceptar_cotizacion', 'Q-ROL', 'rol', 'POST', f'{CORE}/cotizaciones/{{{{cot}}}}/aceptar', 'aliado_t1', {},
     None, [403], r'^MANI-COT-403', None),
    ('aceptar_cotizacion', 'Q-TEN', 'tenant', 'POST', f'{CORE}/cotizaciones/{{{{cot}}}}/aceptar', 'cliente_t2', {},
     None, [403, 404], r'^MANI-COT-40[34]', None),
    ('aceptar_cotizacion', 'Q-PAY', 'payload', 'POST', f'{CORE}/cotizaciones/no-es-uuid/aceptar', 'cliente_t1', {},
     None, [400], r'^MANI-COT-400', None),
    ('aceptar_cotizacion', 'Q-DUP', 'duplicado', 'POST', f'{CORE}/cotizaciones/{{{{cot}}}}/aceptar', 'cliente_t1', {},
     None, [200, 409], r'^(MANI-COT-409|$)', None),

    # 4. Cancelar solicitud (SCRUM-877)
    ('cancelar_solicitud', 'X-ROL', 'rol', 'PATCH', f'{CORE}/solicitudes/me/{{{{s_pend}}}}/cancelar', 'aliado_t1',
     {'motivo': 'SCRUM-1664 T-27'}, None, [403], r'^MANI-SOL-403', None),
    ('cancelar_solicitud', 'X-TEN', 'tenant', 'PATCH', f'{CORE}/solicitudes/me/{{{{s_pend}}}}/cancelar', 'cliente_t2',
     {'motivo': 'SCRUM-1664 T-27'}, None, [403, 404], r'^MANI-SOL-40[34]', None),
    ('cancelar_solicitud', 'X-PAY', 'payload', 'PATCH', f'{CORE}/solicitudes/me/{{{{s_pend}}}}/cancelar', 'cliente_t1',
     {'motivo': 'x' * 600}, None, [400, 422], r'^MANI-SOL-422M', None),
    # Cancelar es idempotente: sobre una solicitud ya CANCELADA responde 200 sin tocarla (PgServiceRequestRepository).
    ('cancelar_solicitud', 'X-DUP', 'duplicado', 'PATCH', f'{CORE}/solicitudes/me/{{{{s_cancel}}}}/cancelar', 'cliente_t1',
     {'motivo': 'SCRUM-1664 T-27 segunda vez'}, None, [200, 409], r'^(MANI-SOL-409C|$)', None),

    # 5. Pagar (SCRUM-1432)
    ('pagar', 'P-ROL', 'rol', 'POST', f'{CORE}/pagos', 'aliado_t1',
     {'cotizacionId': '{{cot}}', 'claveIdempotencia': '{{clave_nueva_6}}'}, None, [403], r'^MANI-PAG-403', None),
    ('pagar', 'P-TEN', 'tenant', 'POST', f'{CORE}/pagos', 'cliente_t2',
     {'cotizacionId': '{{cot}}', 'claveIdempotencia': '{{clave_nueva_7}}'}, None, [403, 404], r'^MANI-PAG-40[34]', None),
    ('pagar', 'P-PAY', 'payload', 'POST', f'{CORE}/pagos', 'cliente_t1',
     {'cotizacionId': 'no-es-uuid', 'claveIdempotencia': '{{clave_nueva_8}}'}, None, [400], r'^MANI-PAG-400', None),
    ('pagar', 'P-PAY2', 'payload', 'POST', f'{CORE}/pagos', 'cliente_t1',
     {'cotizacionId': '{{cot}}', 'claveIdempotencia': '{{clave_nueva_9}}', 'numeroTarjeta': '4111111111111111'},
     None, [400], r'^MANI-PAG-400', None),
    ('pagar', 'P-DUP', 'duplicado', 'POST', f'{CORE}/pagos', 'cliente_t1',
     {'cotizacionId': '{{cot}}', 'claveIdempotencia': '{{clave_pago}}'}, None, [200], None, None),
    ('pagar', 'P-DUP2', 'duplicado', 'POST', f'{CORE}/pagos', 'cliente_t1',
     {'cotizacionId': '{{cot}}', 'claveIdempotencia': '{{clave_nueva_10}}'}, None, [409], r'^MANI-PAG-409A', None),

    # 6. Aprobar aliado (KYC, SCRUM-1066)
    ('aprobar_aliado', 'V-ROL', 'rol', 'PATCH', f'{CORE}/aliados/{{{{aliado}}}}/verificacion', 'aliado_t1',
     {'decision': 'APROBADO'}, None, [403], r'^MANI-VER-403', None),
    ('aprobar_aliado', 'V-TEN', 'tenant', 'PATCH', f'{CORE}/aliados/{{{{aliado}}}}/verificacion', 'admin_t2',
     {'decision': 'APROBADO'}, None, [403, 404], r'^MANI-VER-40[34]', 'aliado_resuelto'),
    ('aprobar_aliado', 'V-PAY', 'payload', 'PATCH', f'{CORE}/aliados/{{{{aliado}}}}/verificacion', 'admin_t1',
     {'decision': 'QUIZAS'}, None, [400, 422], r'^MANI-VER-422D', None),
    ('aprobar_aliado', 'V-PAY2', 'payload', 'PATCH', f'{CORE}/aliados/{{{{aliado}}}}/verificacion', 'admin_t1',
     {'decision': 'RECHAZADO', 'motivo': 'no'}, None, [400, 422], r'^MANI-VER-422M', 'aliado_resuelto'),
    ('aprobar_aliado', 'V-DUP', 'duplicado', 'PATCH', f'{CORE}/aliados/{{{{aliado}}}}/verificacion', 'admin_t1',
     {'decision': 'APROBADO'}, None, [409], r'^MANI-VER-409', 'aliado_resuelto'),

    # 7. Cambiar tarifa (SCRUM-885)
    ('cambiar_tarifa', 'T-ROL', 'rol', 'PUT', f'{CORE}/tarifas/{{{{tarifa}}}}', 'cliente_t1',
     TARIFA_OK, None, [403], r'^MANI-TAR-403', None),
    ('cambiar_tarifa', 'T-TEN', 'tenant', 'PUT', f'{CORE}/tarifas/{{{{tarifa}}}}', 'admin_t2',
     TARIFA_OK, None, [403, 404], r'^MANI-TAR-404', None),
    ('cambiar_tarifa', 'T-PAY', 'payload', 'PUT', f'{CORE}/tarifas/{{{{tarifa}}}}', 'admin_t1',
     {**TARIFA_OK, 'valorMin': 500000, 'valorTipico': 300000, 'valorMax': 100000}, None, [400, 422], r'^MANI-TAR-400', None),
    ('cambiar_tarifa', 'T-DUP', 'duplicado', 'POST', f'{CORE}/tarifas', 'admin_t1',
     TARIFA_OK, None, [409], r'^MANI-TAR-409V', 'tarifa_abierta'),
    ('cambiar_tarifa', 'T-VER', 'duplicado', 'PUT', f'{CORE}/tarifas/{{{{tarifa_vieja}}}}', 'admin_t1',
     TARIFA_OK, None, [409], r'^MANI-TAR-409R', 'tarifa_vieja'),
]

PRUEBA = """const esperado = %s;
const regex = %s;
let cuerpo = {};
try { cuerpo = pm.response.json(); } catch (e) { cuerpo = {}; }
const err = cuerpo && cuerpo.error;
const codigo = (err && typeof err === 'object' ? err.code : null) || cuerpo.code || '';
pm.test('%s http ' + esperado.join('/'), () => pm.expect(esperado).to.include(pm.response.code));
if (regex) {
  pm.test('%s codigo ' + regex, () => pm.expect(String(codigo)).to.match(new RegExp(regex)));
}
console.log('T27 | %s | http=' + pm.response.code + ' | codigo=' + (codigo || '-'));
"""


def item(caso):
    op, cid, tipo, metodo, url, token, cuerpo, cab, http, regex, _ = caso
    cabeceras = [{'key': 'Authorization', 'value': f'Bearer {{{{tk_{token}}}}}'},
                 {'key': 'X-Correlation-ID', 'value': f't27-{{{{corrida}}}}-{cid}'},
                 {'key': 'Content-Type', 'value': 'application/json'}]
    cabeceras += [{'key': k, 'value': v} for k, v in (cab or {}).items()]
    req = {'method': metodo, 'header': cabeceras, 'url': url}
    if cuerpo is not None:
        texto = json.dumps(cuerpo, ensure_ascii=False)
        for k in ('t_min', 't_tip', 't_max'):  # los importes van como numero, no como texto
            texto = texto.replace(f'"{{{{{k}}}}}"', f'{{{{{k}}}}}')
        req['body'] = {'mode': 'raw', 'raw': texto}
    prueba = PRUEBA % (json.dumps(http), json.dumps(regex), cid, cid, cid)
    return {'name': f'{cid} | {op} | {tipo}', 'request': req,
            'event': [{'listen': 'test', 'script': {'type': 'text/javascript', 'exec': prueba.splitlines()}}]}


def coleccion(omitir=()):
    carpetas = {}
    for caso in CASOS:
        if caso[10] and caso[10] in omitir:
            continue
        carpetas.setdefault(caso[0], []).append(item(caso))
    return {'info': {'name': 'SCRUM-1664 T-27 negativos de operaciones criticas (QAS-10)',
                     'schema': 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json'},
            'item': [{'name': op, 'item': items} for op, items in carpetas.items()]}


if __name__ == '__main__':
    destino = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'coleccion_t27_negativos.json')
    with open(destino, 'w', encoding='utf8') as f:
        json.dump(coleccion(), f, ensure_ascii=False, indent=2)
    ops = sorted({c[0] for c in CASOS})
    print(f'{destino}: {len(CASOS)} casos en {len(ops)} operaciones')
    for op in ops:
        tipos = sorted({c[2] for c in CASOS if c[0] == op})
        print(f'  {op}: {", ".join(tipos)}')

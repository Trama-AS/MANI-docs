"""Tres vistas de MANI, dibujadas como SVG exactos y exportadas con librsvg.

Regenerar: python3 generar_diagramas.py
Fuentes documentales y alcance: README.md en esta carpeta.
"""
from pathlib import Path
from html import escape
import subprocess

ROOT = Path(__file__).resolve().parent
NAVY = '#10254b'
INK = '#243650'
BLUE = '#2373bd'
GREEN = '#168163'
PURPLE = '#7353b5'
GRAY = '#68778b'


class Diagram:
    def __init__(self, title, subtitle, height=1200):
        self.height = height
        self.parts = [f'''<svg xmlns="http://www.w3.org/2000/svg" width="1800" height="{height}" viewBox="0 0 1800 {height}">
<defs><marker id="arrow" markerWidth="9" markerHeight="9" refX="8" refY="4.5" orient="auto"><path d="M0,0 L9,4.5 L0,9 Z" fill="{GRAY}"/></marker></defs>
<rect width="1800" height="{height}" fill="#f7f9fc"/>
<style>text{{font-family:Arial,Helvetica,sans-serif;fill:{INK}}}.title{{font-size:36px;font-weight:700;fill:{NAVY}}}.subtitle{{font-size:19px;fill:{GRAY}}}.head{{font-size:22px;font-weight:700;fill:{NAVY}}}.body{{font-size:18px}}.small{{font-size:15px;fill:{GRAY}}}.edge{{fill:none;stroke:{GRAY};stroke-width:2;marker-end:url(#arrow)}}</style>''']
        self.text(40, 58, title, 'title')
        self.text(40, 92, subtitle, 'subtitle')

    def text(self, x, y, text, cls='body', color=None):
        style = f' style="fill:{color}"' if color else ''
        self.parts.append(f'<text x="{x}" y="{y}" class="{cls}"{style}>{escape(text)}</text>')

    def box(self, x, y, w, h, title, lines=(), color=BLUE, fill='#ffffff', size=18):
        self.parts.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="13" fill="{fill}" stroke="{color}" stroke-width="1.6"/>')
        self.parts.append(f'<rect x="{x}" y="{y+15}" width="5" height="28" rx="2" fill="{color}"/>')
        self.text(x+19, y+34, title, 'head')
        for i, line in enumerate(lines):
            self.parts.append(f'<text x="{x+19}" y="{y+65+i*26}" style="font-size:{size}px">{escape(line)}</text>')

    def group(self, x, y, w, h, title, fill='#eef4fb', color='#ccd9e9'):
        self.parts.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="17" fill="{fill}" stroke="{color}"/>')
        self.text(x+18, y+33, title, 'head')

    def arrow(self, points, label=None, pos=None, dashed=False):
        pts = ' '.join(f'{x},{y}' for x,y in points)
        style = ' stroke-dasharray="7 6"' if dashed else ''
        self.parts.append(f'<polyline points="{pts}" class="edge"{style}/>')
        if label:
            x,y = pos
            self.text(x,y,label,'small')

    def footer(self, sources):
        self.parts.append(f'<rect x="0" y="{self.height-66}" width="1800" height="66" fill="{NAVY}"/>')
        self.text(40,self.height-38,'MANI · Vista documental actualizada · 24 nov 2026','small','#ffffff')
        self.text(40,self.height-15,sources,'small','#d6e5f5')

    def save(self, name):
        svg = ROOT / f'{name}.svg'
        svg.write_text('\n'.join(self.parts) + '\n</svg>\n', encoding='utf-8')
        subprocess.run(['rsvg-convert','-w','2700','-o',str(ROOT/f'{name}.png'),str(svg)],check=True)
        subprocess.run(['rsvg-convert','-f','pdf','-o',str(ROOT/f'{name}.pdf'),str(svg)],check=True)


def contexto():
    d=Diagram('01 · Contexto y arquitectura de alto nivel',
              'SOA distribuida y políglota · Tres servicios de negocio · Dominios internos, no servicios por CRUD',1320)
    d.group(35,130,265,720,'Personas')
    d.box(50,190,235,145,'Cliente',['Solicita servicios,','aprueba cotizaciones','y califica.'])
    d.box(50,360,235,170,'Aliado',['Registra KYC, cotiza,','acepta ofertas y','ejecuta el servicio.'])
    d.box(50,555,235,175,'Administrador',['Gestiona el tenant,','usuarios, aliados y','verificación KYC.'])
    d.box(50,755,235,75,'Visitante',[],GRAY)

    d.box(345,310,235,160,'MANI-Flutter',['Flutter / Dart','Aplicación web y móvil','Interfaz del usuario'],PURPLE,'#f5f1fc')
    d.box(345,650,235,160,'MANI-Landing',['React + Vite / NGINX','Página pública estática','Redirige al login'],PURPLE,'#f5f1fc')
    d.box(635,310,225,190,'API Gateway',['MANI-APIGateway','NGINX · TLS','Enrutamiento y límites','X-Correlation-ID'],BLUE,'#eef6ff')
    d.group(910,130,430,720,'Servicios de negocio')
    d.box(930,185,390,255,'Core · MANI-Node',[
        'Node.js · Un único desplegable',
        'Tenants, identidad, perfiles y KYC',
        'Catálogo, cobertura y disponibilidad',
        'Clientes, sitios y solicitudes',
        'Cotización, ejecución y cierre',
        'Mensajería, reportes y pagos sandbox',
        'Persiste asignación y estado canónico'],GREEN,'#effaf5',17)
    d.box(930,465,390,150,'Rules · MANI-Java',[
        'Java · Reglas configurables por tenant',
        'Ranking y validación tarifaria',
        'Obtiene reglas y tarifas desde Core'],PURPLE,'#f5f1fc',17)
    d.box(930,640,390,185,'Dispatch · MANI-.NET',[
        '.NET · Despacho y ofertas',
        'Consulta elegibilidad a Core',
        'Consulta ranking a Rules',
        'Decide aceptación; Core la persiste'],BLUE,'#eef6ff',17)

    d.group(1390,130,375,720,'Supabase · por ambiente','#eefaf6')
    d.box(1410,190,335,135,'PostgreSQL',['Una base compartida','tenant_id + RLS','Core y Dispatch: permisos por tabla'],GREEN,size=16)
    d.box(1410,365,335,110,'Auth',['Identidad, sesión y emisión de JWT'],GREEN,size=16)
    d.box(1410,515,335,110,'Storage',['Documentos KYC y fotografías'],GREEN,size=16)
    d.box(1410,665,335,110,'Realtime',['Transporte de eventos de mensajería'],GREEN,size=16)

    # Las tres personas usan el cliente; la landing solo redirige al login.
    for y in [260,435,635]:
        d.arrow([(285,y),(315,y),(315,380),(345,380)])
    d.arrow([(285,790),(345,790)])
    d.arrow([(460,650),(460,470)],'Login',(474,570))
    d.arrow([(580,390),(635,390)],'HTTPS + JWT',(585,295))
    for y in [280,540,730]:
        d.arrow([(860,415),(890,415),(890,y),(930,y)])
    d.arrow([(1320,270),(1410,270)],'SQL',(1349,255))
    d.arrow([(1320,730),(1360,730),(1360,310),(1410,310)],dashed=True)
    d.text(1348,838,'Dispatch: solo rechazos','small')
    d.arrow([(1320,340),(1375,340),(1375,565),(1410,565)])
    # Caminos directos del cliente: exclusivamente Auth y Realtime.
    d.arrow([(460,310),(460,115),(1780,115),(1780,420),(1745,420)],dashed=True)
    d.text(790,110,'Flutter ↔ Auth: sesión y JWT','small')
    d.arrow([(1410,725),(1380,725),(1380,885),(610,885),(610,445),(580,445)],dashed=True)
    d.text(590,878,'Realtime → Flutter: eventos, sin consultas a tablas de negocio','small')
    d.group(35,925,1730,270,'Límites, módulos e integraciones','#ffffff')
    d.box(55,980,530,190,'Comunicación interna',[
        'HTTP con contratos, timeout e idempotencia.',
        'Dispatch → Core: elegibilidad y asignación.',
        'Dispatch → Rules: ranking.',
        'Core ↔ Rules: evaluación y configuración.'],BLUE,size=17)
    d.box(615,980,550,190,'Módulos funcionales M-01 a M-13',[
        'Multi-tenant · Identidad · Directorio/KYC · Catálogo',
        'Solicitud/asignación · Cotización · Ejecución',
        'Calificación/cierre · Comunicación · Tarifario/reportes',
        'Pagos simulados · Operación · Shell/navegación'],PURPLE,size=16)
    d.box(1195,980,550,190,'Fronteras externas',[
        'Core integra Storage, Realtime y notificaciones.',
        'FCM/APNs y pagos según alcance simulado.',
        'Landing no llama al Gateway ni consulta datos.',
        'Flutter no consulta PostgreSQL ni Storage.'],GREEN,size=17)
    d.footer('Fuentes: SAD §7–8 · Mapa de módulos · ADR-0027 / 0028 / 0030 / 0035 · ModeloDatos §6')
    d.save('01-contexto-alto-nivel')


def infraestructura():
    d=Diagram('02 · Despliegue e infraestructura',
              'QA y PROD sobre máquinas virtuales con Docker Compose · Inventario operativo documentado al 14 nov 2026',1400)
    d.group(35,125,1730,240,'Repositorios, CI y validación de calidad')
    d.box(55,180,395,160,'GitHub · Siete repositorios',[
        'Flutter · APIGateway · Node · Java · .NET',
        'Landing · docs (solo documentación)',
        'Todos con prefijo MANI- · Jira: trazabilidad'],BLUE,size=16)
    d.box(490,180,445,160,'GitHub Actions · CI',[
        'Lint, unitarias e integración → SonarQube',
        'Build OCI → escaneo dependencias/imagen',
        'Publicación en GHCR · SAST: SonarQube'],BLUE,size=17)
    d.box(975,180,330,160,'GHCR · Imágenes OCI',[
        'release → :staging (QA)',
        'main → :latest / SemVer (PROD)',
        'Registrar digest para rollback'],PURPLE,size=16)
    d.box(1345,180,400,160,'Validación sobre QA',[
        'Newman: contratos y aislamiento tenant',
        'k6 según escenario · OWASP ZAP: DAST',
        'Gates y aprobación QA / PO antes de PROD'],GREEN,size=16)
    d.arrow([(450,260),(490,260)])
    d.arrow([(935,260),(975,260)])
    d.group(35,405,825,470,'QA · NBIG01 · 10.43.100.141','#fff9e9','#e4cf8d')
    d.group(940,405,825,470,'PROD · NBIG05 · 10.43.98.203','#eff9f3','#9dcab0')
    for x,env in [(55,'qa'),(960,'prod')]:
        d.box(x,465,385,120,'Frontend y acceso',[
            'Flutter Web :8080 · Landing :3001',
            'API Gateway NGINX · :80'],BLUE,size=17)
        d.box(x+405,465,380,120,'Servicios · red interna',[
            'Core Node.js :3000 · Rules Java :8080',
            'Dispatch .NET :5000'],GREEN,size=17)
        d.box(x,610,785,110,'Docker Compose · /opt/mani',[
            f'docker-compose.{env}.yml · red bridge interna',
            'Variables y secretos por ambiente · Health checks · Rollback por digest'],PURPLE,size=17)
        d.arrow([(x+385,525),(x+405,525)])
    d.box(55,745,785,105,'Específico de QA',[
        'TLS :443 · Límites CPU/RAM · Exporters y Promtail',
        'Kafka 3.8: broker presente; no acredita integración asíncrona de negocio'],BLUE,size=17)
    d.box(960,745,785,105,'Específico de PROD',[
        'Seis contenedores de aplicación · Redis y cloudflared documentados',
        'Kafka no desplegado · Integración de negocio entre servicios: HTTP'],GREEN,size=17)
    d.arrow([(1080,340),(1080,385),(455,385),(455,405)],'Descarga imagen QA',(575,378))
    d.arrow([(1260,340),(1260,385),(1330,385),(1330,405)],'Imagen PROD aprobada',(1360,384))
    d.arrow([(1540,340),(1540,365),(1780,365),(1780,895),(455,895),(455,875)],dashed=True)
    d.text(580,920,'ZAP se ejecuta contra QA desplegado; el escaneo de imágenes ocurre antes, en CI.','small')
    d.group(35,950,1730,290,'Plataformas de datos y operación')
    d.box(55,1005,530,200,'Supabase · separado por ambiente',[
        'PostgreSQL compartido por ambiente + RLS',
        'Auth · Storage · Realtime',
        'Core: persistencia y adaptadores externos',
        'Rules sin SQL · Dispatch solo solicitud_rechazo'],GREEN,size=17)
    d.box(615,1005,550,200,'VM Calidad · 10.43.98.196',[
        'Prometheus · Grafana · Loki',
        'Alertmanager · Mailpit · Blackbox',
        'Métricas, logs y disponibilidad de QA/PROD',
        'SonarQube · Promtail en los hosts emisores'],BLUE,size=17)
    d.box(1195,1005,550,200,'VM Backups · 10.43.98.197',[
        'systemd + herramientas PostgreSQL',
        'Respaldo diario cifrado y réplica en Calidad',
        'Restauración y simulacro documentados',
        'DEV: integración previa (:develop), fuera de esta vista'],PURPLE,size=17)
    d.text(55,1280,'Operación: scripts de despliegue y verificación de salud; CD automatizado a PROD aún documentado como pendiente.','body')
    d.footer('Fuentes: Mapa de ambientes §1 y §5 · Runbooks de despliegue y rollback · CI/CD y calidad · ADR-0028')
    d.save('02-despliegue-infraestructura')


def datos():
    d=Diagram('03 · Arquitectura de datos',
              'Una base PostgreSQL por ambiente · Propiedad y permisos por tabla · Vista de dominios, no DER completo',1450)
    d.box(40,145,500,190,'Core · MANI-Node',[
        'mani_core_svc · Datos de negocio y estado canónico',
        'Único dueño de migraciones: db/migrations/',
        'Persiste reglas, tarifas y asignación',
        'Integra Storage y publica eventos de mensajería'],GREEN,size=17)
    d.box(650,145,500,190,'Rules · MANI-Java',[
        'Motor de evaluación, ranking y validación',
        'Sin conexión directa a PostgreSQL',
        'Consulta configuración y tarifas a Core',
        'No versiona DDL'],PURPLE,size=17)
    d.box(1260,145,500,190,'Dispatch · MANI-.NET',[
        'mani_dispatch_svc',
        'INSERT / SELECT solo en solicitud_rechazo',
        'Decide la aceptación y la entrega a Core',
        'Sin escritura directa sobre solicitud'],BLUE,size=17)
    d.arrow([(650,240),(540,240)],'HTTP',(570,225))
    d.group(40,420,1720,640,'Supabase / PostgreSQL · Una base por ambiente (QA y PROD aislados)','#eef8f5','#9ac9b9')
    d.text(65,480,'public: 37 tablas · app: funciones de contexto de identidad y outbox · Propiedad por tabla, no por esquema','body')
    d.box(65,510,515,220,'Identidad y acceso',[
        'tenant · usuario · aliado · cliente · sitio',
        'documento_kyc · documento_legal',
        'consentimiento_usuario · tenant_estado_cambio',
        'Escritura: Core (según privilegios por tabla)',
        'Auth gestiona la identidad y emite el JWT'],GREEN,size=16)
    d.box(605,510,540,220,'Catálogo, cobertura y reglas',[
        'zona · geometria_territorial · categoria_servicio',
        'aliado_categoria · cobertura_aliado · aliado_ausencia',
        'tarifa_referencia · regla_tenant',
        'politica_cancelacion_tenant',
        'Propiedad: Core · Rules evalúa mediante HTTP'],GREEN,size=16)
    d.box(1170,510,565,220,'Ciclo del servicio',[
        'solicitud · solicitud_foto · cotizacion',
        'adicion_servicio · evento_servicio · calificacion',
        'solicitud_rechazo: exclusiva de Dispatch',
        'solicitud: Core es el único escritor',
        'Asignación atómica: un ganador; resto 409'],BLUE,size=16)
    d.box(65,755,515,190,'Comunicaciones',[
        'mensaje · consulta_conversacion · notificacion',
        'queja · queja_transicion',
        'Propiedad: Core',
        'Quejas: alcance del segundo incremento'],GREEN,size=16)
    d.box(605,755,540,190,'Pagos',[
        'pago · transaccion_evento · retencion_fondos',
        'comision_tenant · liquidacion',
        'Propiedad: Core',
        'Pagos sandbox / simulados, sin dinero real'],GREEN,size=16)
    d.box(1170,755,565,190,'Integración y control',[
        'outbox_evento · schema_migrations',
        'Serie única de migraciones: Core',
        'Outbox no equivale a Kafka operativo en PROD',
        'Rules y Dispatch no mantienen DDL propio'],PURPLE,size=16)
    d.text(65,995,'Contexto transaccional: JWT verificado → app.set_context → app.tenant_id() → políticas RLS','body')
    d.text(65,1026,'Roles NOBYPASSRLS · UUID · timestamptz · RLS y FORCE con excepciones documentadas por tabla','small')
    d.arrow([(290,335),(290,420)],'SQL con contexto tenant',(310,380))
    d.arrow([(1510,335),(1510,420)],'SQL: solo rechazos',(1530,380))
    d.group(40,1100,1720,240,'Servicios de plataforma y acceso del cliente','#ffffff')
    d.box(65,1150,515,165,'Auth y Realtime',[
        'Flutter ↔ Auth: registro, sesión y JWT',
        'Core → Realtime → Flutter: eventos',
        'Sin lecturas directas de tablas desde Flutter'],GREEN,size=17)
    d.box(605,1150,540,165,'Storage',[
        'Archivos KYC, fotografías y evidencias',
        'Acceso gestionado por Core vía backend',
        'Metadatos y referencias en PostgreSQL'],BLUE,size=17)
    d.box(1170,1150,565,165,'Protección y recuperación',[
        'TLS · Credenciales por servicio y ambiente',
        'Respaldos cifrados + réplica + restauración',
        'Analítica / DW: diseño separado del OLTP'],PURPLE,size=17)
    d.footer('Fuentes: ModeloDatos §3 y §6 · ADR-0012 / 0027 / 0030 / 0032 / 0035 · Runbook de respaldos')
    d.save('03-arquitectura-datos')


if __name__ == '__main__':
    contexto()
    infraestructura()
    datos()
    print('Generados tres diagramas: SVG editable, PNG y PDF.')

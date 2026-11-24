# QAS-05. Agrega al log del Gateway la replica que atendio. No cambia el enrutamiento. Entrada: nginx.conf de la imagen.
import sys
conf = sys.stdin.read()
viejo = "'\"x_correlation_id\": \"$correlation_id\"'"
if conf.count(viejo) != 1:
    sys.exit('El formato de log del Gateway no es el esperado: no se sigue.')
nuevo = "'\"x_correlation_id\": \"$correlation_id\",'\n        '\"msec\": \"$msec\",'\n        '\"upstream_addr\": \"$upstream_addr\",'\n        '\"upstream_status\": \"$upstream_status\"'"
sys.stdout.write(conf.replace(viejo, nuevo))

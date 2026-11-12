#!/usr/bin/env bash
# Comprueba la salud mecánica de wiki/: enlaces internos que no resuelven y
# marcadores de conflicto de git commiteados. No juzga el contenido.
#
#   ./scripts/verificar-wiki.sh            # todo wiki/
#   ./scripts/verificar-wiki.sh wiki/02-arquitectura
#
# Devuelve 0 si está limpio y 1 si encuentra algo. Pensado para correrlo antes
# de commitear y para usarlo como paso de CI.
set -uo pipefail

raiz="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
objetivo="${1:-wiki}"
cd "$raiz" || exit 2
[ -d "$objetivo" ] || { echo "No existe el directorio: $objetivo" >&2; exit 2; }

rotos=0
marcadores=0

# --- 1. enlaces internos -----------------------------------------------------
# Solo rutas relativas. Se ignoran http(s), mailto y los anclajes (#...), que
# requieren interpretar los títulos y no son fallos de ruta.
while IFS= read -r archivo; do
  dir="$(dirname "$archivo")"
  while IFS= read -r destino; do
    case "$destino" in
      http*|mailto:*|"#"*|"") continue ;;
    esac
    ruta="${destino%%#*}"
    [ -n "$ruta" ] || continue
    if [ ! -e "$dir/$ruta" ]; then
      printf 'ENLACE ROTO  %s -> %s\n' "$archivo" "$ruta"
      rotos=$((rotos + 1))
    fi
  done < <(grep -oE '\]\([^)]+\)' "$archivo" 2>/dev/null \
            | sed -E 's/^\]\(//; s/\)$//' | sort -u)
done < <(find "$objetivo" -name '*.md' | sort)

# --- 2. marcadores de conflicto ----------------------------------------------
while IFS= read -r linea; do
  printf 'MARCADOR     %s\n' "$linea"
  marcadores=$((marcadores + 1))
done < <(grep -rnE '^(<<<<<<<|>>>>>>>|=======)$' "$objetivo" 2>/dev/null)

# --- resumen -----------------------------------------------------------------
printf '\n%s: %d enlaces rotos, %d marcadores de conflicto\n' \
  "$objetivo" "$rotos" "$marcadores"

if [ "$rotos" -eq 0 ] && [ "$marcadores" -eq 0 ]; then
  echo "Limpio."
  exit 0
fi
exit 1

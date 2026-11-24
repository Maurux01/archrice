#!/usr/bin/env bash
# =============================================================================
#  check-packages.sh — valida contra los repos reales de Arch que todos los
#  paquetes oficiales de install.sh existen. Los paquetes AUR se omiten.
#  Requiere ejecutarse dentro del contenedor Arch con `pacman -Sy` previo.
# =============================================================================
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LIST="$(mktemp)"

python3 - "$REPO_DIR/install.sh" > "$LIST" <<'PY'
import re, pathlib, sys
src = pathlib.Path(sys.argv[1]).read_text(encoding='utf-8')
block = re.search(r'^PACMAN_PKGS=\((.*?)^\)', src, re.M | re.S).group(1)
block = re.sub(r'#.*', '', block)          # quita comentarios
print('\n'.join(re.findall(r'[A-Za-z0-9][A-Za-z0-9._+-]*', block)))
PY

total=0
missing=0
while IFS= read -r pkg; do
  [ -z "$pkg" ] && continue
  total=$((total + 1))
  if ! pacman -Si "$pkg" >/dev/null 2>&1; then
    echo "MISSING: $pkg"
    missing=$((missing + 1))
  fi
done < "$LIST"
rm -f "$LIST"

echo "Paquetes oficiales comprobados: $total"
echo "No encontrados: $missing"
[ "$missing" -eq 0 ]

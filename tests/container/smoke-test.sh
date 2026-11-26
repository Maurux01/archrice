#!/usr/bin/env bash
# =============================================================================
#  smoke-test.sh — prueba aislada de install.sh / uninstall.sh
#  Pensado para ejecutarse dentro de un contenedor Arch Linux (Docker o WSL).
#
#  No instala los ~84 paquetes reales: interpola pacman/sudo/systemctl para
#  poder verificar despliegue, permisos y limpieza en segundos.
# =============================================================================
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TEST=/tmp/archrice-smoke
LOG="$TEST/commands.log"
DB="$TEST/packages.db"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }
section() { echo ""; echo "== $* =="; }

rm -rf "$TEST"
mkdir -p "$TEST/home" "$TEST/root/etc" "$TEST/root/usr/share/backgrounds" \
         "$TEST/root/usr/share/sddm/themes/sugar-candy" "$TEST/bin"
: > "$LOG"
: > "$DB"

# ---------------------------------------------------------------- stubs ---
cat > "$TEST/bin/pacman" <<'STUB'
#!/usr/bin/env bash
echo "pacman $*" >> "$COMMANDS_LOG"
case "${1:-}" in
  -S*)
    shift
    for a in "$@"; do
      case "$a" in
        --noconfirm|--needed|-Syu|-S|-y|-u) ;;
        *) grep -Fxq "$a" "$PACKAGES_DB" 2>/dev/null || echo "$a" >> "$PACKAGES_DB" ;;
      esac
    done
    exit 0 ;;
  -Q)
    if [ $# -ge 2 ]; then
      grep -Fxq "$2" "$PACKAGES_DB" 2>/dev/null && exit 0 || exit 1
    fi
    cat "$PACKAGES_DB"; exit 0 ;;
  -R*)
    shift
    for a in "$@"; do
      case "$a" in --noconfirm|-R|-s|-n) ;; *) sed -i "/^${a}$/d" "$PACKAGES_DB" ;; esac
    done
    exit 0 ;;
  *) exit 0 ;;
esac
STUB

cat > "$TEST/bin/yay" <<'STUB'
#!/usr/bin/env bash
echo "yay $*" >> "$COMMANDS_LOG"
exec "$STUB_BIN/pacman" "$@"
STUB

cat > "$TEST/bin/sudo" <<'STUB'
#!/usr/bin/env bash
echo "sudo $*" >> "$COMMANDS_LOG"
# Redirige las rutas del sistema al fake root; deja intactas las de $HOME/$TEST.
args=()
for a in "$@"; do
  case "$a" in
    /etc/*|/usr/*|/var/*) args+=("$FAKE_ROOT$a") ;;
    *) args+=("$a") ;;
  esac
done
exec "${args[@]}"
STUB

cat > "$TEST/bin/systemctl" <<'STUB'
#!/usr/bin/env bash
echo "systemctl $*" >> "$COMMANDS_LOG"
exit 0
STUB

for stub in fc-cache xdg-user-dirs-update; do
  cat > "$TEST/bin/$stub" <<'STUB'
#!/usr/bin/env bash
echo "$(basename "$0") $*" >> "$COMMANDS_LOG"
exit 0
STUB
done
chmod +x "$TEST/bin/"*

export COMMANDS_LOG="$LOG"
export PACKAGES_DB="$DB"
export STUB_BIN="$TEST/bin"
export FAKE_ROOT="$TEST/root"
export HOME="$TEST/home"
export PATH="$TEST/bin:$PATH"

cd "$REPO_DIR" || fail "no se puede entrar en $REPO_DIR"

# ------------------------------------------------------- 1. sintaxis ---
section "Sintaxis bash"
while IFS= read -r -d '' f; do
  bash -n "$f" || fail "bash -n $f"
done < <(find . -name '*.sh' -type f -print0)
pass "todos los .sh pasan bash -n"

# ----------------------------------------------------------- 2. JSON ---
section "JSON"
if command -v python3 >/dev/null 2>&1; then
  python3 - <<'PY' || exit 1
import json, pathlib
for p in ['dotfiles/waybar/config', 'dotfiles/swaync/config.json',
          'dotfiles/nvim/lazy-lock.json', 'dotfiles/nvim/lazyvim.json']:
    json.loads(pathlib.Path(p).read_text(encoding='utf-8'))
    print('  ok', p)
layout = pathlib.Path('dotfiles/wlogout/layout').read_text(encoding='utf-8')
json.loads('[' + layout.replace('}\n{', '},\n{') + ']')
print('  ok dotfiles/wlogout/layout')
PY
  pass "JSON válido"
else
  echo "SKIP: python3 no disponible"
fi

# ------------------------------------------------------- 3. saltos ---
section "Saltos de línea"
if grep -rl $'\r' install.sh uninstall.sh README.md dotfiles/hypr dotfiles/waybar \
   dotfiles/wofi dotfiles/rofi dotfiles/swaync dotfiles/wlogout 2>/dev/null | grep -q .; then
  fail "quedaron CRLF en archivos de texto"
fi
pass "sin CRLF"

# ---------------------------------------------------- 4. install.sh ---
section "install.sh"
# Config previa de HyDE con waybar duplicado: install.sh debe desactivarla
mkdir -p "$HOME/.config/hypr/workflows"
printf 'exec-once = waybar\n' > "$HOME/.config/hypr/workflows/default.conf"
bash install.sh > "$TEST/install.out" 2>&1 || { tail -40 "$TEST/install.out"; fail "install.sh falló"; }
grep -q '^exec-once = waybar' "$HOME/.config/hypr/workflows/default.conf" && \
  fail "quedó un exec-once = waybar duplicado en workflows/default.conf"

for f in hyprland.conf keybindings.conf windowrules.conf monitors.conf hyprlock.conf hypridle.conf; do
  [ -f "$HOME/.config/hypr/$f" ] || fail "falta ~/.config/hypr/$f"
done
for d in waybar swaync wofi rofi nvim wlogout; do
  [ -d "$HOME/.config/$d" ] || fail "falta ~/.config/$d"
done
for h in screenshot.sh obs-toggle.sh set-wallpaper.sh wofi-wifi.sh wallpaper-wipe.sh save_wallpaper.sh restart-waybar.sh; do
  [ -x "$HOME/.local/bin/$h" ] || fail "falta o no es ejecutable ~/.local/bin/$h"
done
[ -f "$HOME/Pictures/Wallpapers/gruvbox.png" ] || fail "falta wallpaper de usuario"
[ -f "$FAKE_ROOT/usr/share/backgrounds/gruvbox.png" ] || fail "falta wallpaper de SDDM"
[ -f "$FAKE_ROOT/etc/sddm.conf" ] || fail "falta /etc/sddm.conf"
grep -q 'hypridle' "$HOME/.config/hypr/hyprland.conf" || fail "hypridle no está en autostart"
grep -q 'set-wallpaper.sh' "$HOME/.config/hypr/hyprland.conf" || fail "wallpaper no está en autostart"
[ "$(grep -c '^exec-once = waybar' "$HOME/.config/hypr/hyprland.conf")" -eq 1 ] || \
  fail "waybar debe tener un único exec-once en hyprland.conf"
grep -q 'restart-waybar.sh' "$HOME/.config/hypr/keybindings.conf" || \
  fail "falta el atajo para reiniciar waybar"
[ -f "$HOME/.config/wlogout/layout" ] && [ -f "$HOME/.config/wlogout/style.css" ] || fail "wlogout no desplegado"
for h in screenshot.sh obs-toggle.sh set-wallpaper.sh wofi-wifi.sh; do
  bash -n "$HOME/.local/bin/$h" || fail "bash -n ~/.local/bin/$h"
done
pkg_count=$(wc -l < "$DB")
[ "$pkg_count" -ge 84 ] || fail "solo $pkg_count paquetes registrados"
pass "install.sh desplegó todo ($pkg_count paquetes registrados)"

# -------------------------------------------------- 5. uninstall.sh ---
section "uninstall.sh"
printf 'SI\n' | bash uninstall.sh > "$TEST/uninstall.out" 2>&1 || { tail -40 "$TEST/uninstall.out"; fail "uninstall.sh falló"; }
for d in waybar swaync wofi rofi nvim wlogout; do
  [ ! -d "$HOME/.config/$d" ] || fail "quedó ~/.config/$d"
done
for h in screenshot.sh obs-toggle.sh set-wallpaper.sh wofi-wifi.sh restart-waybar.sh; do
  [ ! -e "$HOME/.local/bin/$h" ] || fail "quedó ~/.local/bin/$h"
done
[ ! -e "$FAKE_ROOT/usr/share/backgrounds/gruvbox.png" ] || fail "quedó el wallpaper del sistema"
grep -q 'sddm.conf restaurado' "$TEST/uninstall.out" || fail "sddm.conf no se restauró"
grep -q 'Desinstalación verificada' "$TEST/uninstall.out" || fail "verificación de uninstall falló"
backup=$(grep -o "$HOME/.archrice-backup-[0-9-]*" "$TEST/uninstall.out" | head -1)
[ -n "$backup" ] && [ -d "$backup" ] || fail "no se creó el backup"
pass "uninstall.sh limpió todo y creó backup"

echo ""
echo "TODO OK ✅ — prueba ejecutada dentro de un contenedor Arch Linux"

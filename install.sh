#!/usr/bin/env bash
# =============================================================================
#  install.sh — FASE 1: Daily Driver Gruvbox + Wayland + Hyprland (SOLO ARCH)
# =============================================================================
#  Objetivo: instalar TODAS las dependencias del stack en Arch Linux.
#  Reglas de oro:
#   1. ESTRICTAMENTE WAYLAND (nada de picom, xrandr, rofi-x11, feh, maim, xclip)
#   2. TEMA EXCLUSIVO: GRUVBOX DARK
#   3. RENDIMIENTO: base ligera, sin blur pesado / sin daemons extra
#
#  Stack:
#   - WM: Hyprland + portales + hyprlock + hypridle + swww
#   - DM: SDDM + sugar-candy (Gruvbox en FASE 4)
#   - Bar: Waybar
#   - Launcher: wofi + rofi-wayland (ambos nativos Wayland)
#   - Terminal: kitty (binario) · shell: bash + starship (configs en tu otro repo)
#   - Notificaciones: swaync + libnotify
#   - Audio: PipeWire + WirePlumber + pavucontrol + pamixer + playerctl + wpctl
#   - Red/BT: NetworkManager + nm-applet + blueman + bluez
#   - Screenshots: grim + slurp + wl-clipboard + cliphist + swappy
#   - Video: OBS Studio
#   - Files: Thunar (+gvfs/tumbler) + yazi
#   - Polkit: polkit-gnome (necesario para nm/blueman)
#   - Brillo: brightnessctl
#   - Fuentes: JetBrainsMono Nerd + Noto · Iconos Gruvbox-Material · Cursor Bibata
#
#  Paleta Gruvbox Dark (referencia):
#   bg #282828  bg_h #1d2021  bg1 #3c3836  bg2 #504945
#   fg #ebdbb2  gray #a89984
#   red #cc241d  green #98971a  yellow #d79921
#   blue #458588  purple #b16286  aqua #689d6a  orange #d65d0e
# =============================================================================

set -euo pipefail

# --- Colores ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

log()  { echo -e "${CYAN}› $1${NC}"; }
ok()   { echo -e "${GREEN}  ✓ $1${NC}"; }
warn() { echo -e "${YELLOW}  ⚠ $1${NC}"; }
err()  { echo -e "${RED}  ✗ $1${NC}" >&2; }
die()  { err "$1"; exit 1; }

# --- Pre-chequeos (SOLO ARCH, sin Kali/Debian/apt) ---
[ "$EUID" -eq 0 ] && die "No ejecutes como root. Usa un usuario con sudo."
command -v pacman >/dev/null 2>&1 || die "pacman no encontrado. Este script es solo para Arch Linux."
command -v sudo >/dev/null 2>&1 || die "sudo no encontrado. Instala sudo primero."
command -v git >/dev/null 2>&1 || {
  log "Instalando git + base-devel..."
  sudo pacman -Sy --noconfirm --needed git base-devel
}

# Detectar AUR helper: yay preferred, paru fallback
AUR_HELPER=""
if command -v yay >/dev/null 2>&1; then
  AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
  AUR_HELPER="paru"
fi

install_yay() {
  if [ -n "$AUR_HELPER" ]; then
    ok "$AUR_HELPER ya instalado."
    return
  fi
  log "Instalando yay (AUR helper)..."
  sudo pacman -Sy --noconfirm --needed base-devel git
  TMPDIR_YAY="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/yay.git "$TMPDIR_YAY/yay"
  (cd "$TMPDIR_YAY/yay" && makepkg -si --noconfirm)
  rm -rf "$TMPDIR_YAY"
  AUR_HELPER="yay"
  ok "yay instalado."
}

# --- Listas de paquetes ---
# Todo lo de aquí es Wayland-nativo. PROHIBIDO añadir picom/xorg-xrandr/feh/maim/xclip/rofi (x11).
PACMAN_PKGS=(
  # Hyprland + Wayland core
  hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-utils
  xdg-user-dirs wayland-protocols qt5-wayland qt6-wayland
  # Sesión / lock / idle / wallpaper
  sddm swww hyprlock hypridle
  # Bar + launcher + notificaciones
  waybar wofi rofi-wayland swaync libnotify
  # Terminal + prompt (bash config en tu otro repo)
  kitty starship
  # Audio (PipeWire nativo, wpctl viene en wireplumber)
  pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
  pavucontrol pamixer playerctl
  # Red + Bluetooth
  networkmanager network-manager-applet blueman bluez bluez-utils
  # Screenshots / clipboard (Wayland)
  grim slurp wl-clipboard cliphist swappy
  # Video
  obs-studio
  # Archivos
  thunar thunar-archive-plugin tumbler gvfs file-roller
  yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide imagemagick ueberzugpp
  # Polkit + keyring (para permisos nm/blueman)
  polkit polkit-gnome gnome-keyring
  # Brillo + utilidades Wayland
  brightnessctl wev wl-screenrec
  # Navegador + monitor sistema
  firefox btop fastfetch
  # Herramientas CLI daily-driver
  eza bat htop curl unzip zip ttf-bitstream-vera
  # Fuentes + iconos + cursor (Gruvbox-friendly)
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
  bibata-cursor-theme
  # SDDM deps para sugar-candy
  qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
)

# Solo Wayland/Gruvbox desde AUR. Nada de X11 aquí.
AUR_PKGS=(
  sddm-sugar-candy-git          # tema SDDM (lo adaptamos a Gruvbox en FASE 4)
  gruvbox-material-gtk-theme-git # GTK Gruvbox Dark
  gruvbox-material-icon-theme-git # iconos Gruvbox (paquete único)
  grimblast-git                 # wrapper grim+slurp (Wayland nativo)
  hyprpicker-git                # color picker Wayland (útil para Gruvbox)
  wlogout                       # menú apagado Wayland (se themea en FASE 2/3)
)

# --- Despliegue del rice (instalador único: cada carpeta a su ruta del sistema) ---
# ~/.config/<app> · ~/.local/bin · ~/.local/share/fonts · /etc/sddm.conf,
# todo con backup previo. No hay scripts sueltos: los 2 helpers se generan aquí.
deploy_dotfiles() {
  local repo="$1"
  local dot="$repo/dotfiles"
  local bk="$HOME/.archrice-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$bk"

  # hypr: solo archivos del rice (el resto legacy no se copia)
  mkdir -p "$HOME/.config/hypr"
  for f in hyprland.conf keybindings.conf windowrules.conf monitors.conf hyprlock.conf; do
    [ -f "$HOME/.config/hypr/$f" ] && cp "$HOME/.config/hypr/$f" "$bk/" 2>/dev/null || true
    if [ -f "$dot/hypr/$f" ]; then
      cp "$dot/hypr/$f" "$HOME/.config/hypr/$f" && ok "hypr/$f desplegado."
    fi
  done

  # waybar / swaync / wofi / rofi / nvim: dirs completos a ~/.config
  for d in waybar swaync wofi rofi nvim; do
    [ -d "$dot/$d" ] || continue
    [ -d "$HOME/.config/$d" ] && cp -r "$HOME/.config/$d" "$bk/$d" 2>/dev/null || true
    mkdir -p "$HOME/.config/$d"
    cp -r "$dot/$d/"* "$HOME/.config/$d/" 2>/dev/null || warn "Sin archivos en dotfiles/$d"
    rm -f "$HOME/.config/$d/"*.sh 2>/dev/null || true   # instaladores sueltos no se despliegan
    ok "$d desplegado en ~/.config/$d."
  done

  # helpers sueltos del repo -> ~/.local/bin
  mkdir -p "$HOME/.local/bin"
  for s in "$dot/hypr/script/save_wallpaper.sh" "$dot/swww/wallpaper-wipe.sh" "$dot/wofi/woif-wifi.sh"; do
    if [ -f "$s" ]; then
      cp "$s" "$HOME/.local/bin/" && chmod +x "$HOME/.local/bin/$(basename "$s")" && ok "$(basename "$s") -> ~/.local/bin."
    fi
  done

  # helpers generados (antes vivían en dotfiles/scripts/, carpeta eliminada)
  cat > "$HOME/.local/bin/screenshot.sh" << 'HELPER'
#!/usr/bin/env bash
# archrice · screenshots Wayland (grimblast: archivo + portapapeles)
# Uso: screenshot.sh [area|output|screen|active] [--jpeg]  (defecto: area)
set -euo pipefail
MODE="area"; JPEG=0
for a in "$@"; do case "$a" in
  area|output|screen|active|s|m|p|w) MODE="$a" ;;
  --jpeg|-j) JPEG=1 ;;
  -h|--help) echo "Uso: $0 [area|output|screen|active] [--jpeg]"; exit 0 ;;
esac; done
DIR="$HOME/Pictures/Screenshots"; mkdir -p "$DIR"
case "$MODE" in s) MODE="area" ;; m) MODE="output" ;; p) MODE="screen" ;; w) MODE="active" ;; esac
FILE="$(grimblast copysave "$MODE")"
if [ "$JPEG" = "1" ] && command -v convert >/dev/null 2>&1; then
  convert "$FILE" "${FILE%.png}.jpg" && rm "$FILE" && FILE="${FILE%.png}.jpg"
fi
notify-send --app-name="screenshot" "Screenshot" "Guardada: $FILE"
HELPER
  cat > "$HOME/.local/bin/obs-toggle.sh" << 'HELPER'
#!/usr/bin/env bash
# archrice · toggle grabación OBS en segundo plano (SUPER+Shift+O)
set -euo pipefail
if pgrep -x obs >/dev/null 2>&1; then
  pkill -x obs
  notify-send --app-name="obs-toggle" "OBS" "Grabación detenida"
else
  obs --startrecording --minimize-to-tray >/dev/null 2>&1 &
  disown
  notify-send --app-name="obs-toggle" "OBS" "Grabando en segundo plano — SUPER+Shift+O para detener"
fi
HELPER
  chmod +x "$HOME/.local/bin/screenshot.sh" "$HOME/.local/bin/obs-toggle.sh"
  ok "Helpers screenshot.sh + obs-toggle.sh generados en ~/.local/bin."

  # SDDM (root)
  if [ -f "$dot/sddm/sddm.conf" ]; then
    sudo cp /etc/sddm.conf "$bk/sddm.conf" 2>/dev/null || true
    sudo cp "$dot/sddm/sddm.conf" /etc/sddm.conf && ok "sddm.conf desplegado."
  fi
  if [ -d /usr/share/sddm/themes/sugar-candy ] && [ -f "$dot/sddm/themes/sugar-candy/theme.conf.user" ]; then
    sudo cp /usr/share/sddm/themes/sugar-candy/theme.conf.user "$bk/" 2>/dev/null || true
    sudo cp "$dot/sddm/themes/sugar-candy/theme.conf.user" /usr/share/sddm/themes/sugar-candy/theme.conf.user
    ok "sugar-candy Gruvbox desplegado."
  else
    warn "Tema sugar-candy aún no instalado; su config se aplicará al instalarse (AUR)."
  fi

  ok "Backup previo en: $bk"
}

main() {
  echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}  install.sh · Gruvbox Wayland Rice (Arch) — instalador único  ${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"

  log "Paso 1/7: Actualizando sistema (pacman -Syu)..."
  sudo pacman -Syu --noconfirm

  log "Paso 2/7: AUR helper..."
  install_yay
  ok "Helper activo: $AUR_HELPER"

  log "Paso 3/7: Instalando paquetes oficiales (${#PACMAN_PKGS[@]})..."
  sudo pacman -S --noconfirm --needed "${PACMAN_PKGS[@]}"
  ok "Paquetes pacman instalados."

  log "Paso 4/7: Instalando paquetes AUR (${#AUR_PKGS[@]})..."
  "$AUR_HELPER" -S --noconfirm --needed "${AUR_PKGS[@]}" || {
    warn "Algún paquete AUR falló. Reintenta manualmente:"
    warn "  $AUR_HELPER -S ${AUR_PKGS[*]}"
  }
  ok "Paquetes AUR procesados."

  log "Paso 5/7: Habilitando servicios..."
  sudo systemctl enable NetworkManager.service || warn "No se pudo habilitar NetworkManager"
  sudo systemctl enable bluetooth.service || warn "No se pudo habilitar bluetooth"
  sudo systemctl enable sddm.service || warn "No se pudo habilitar sddm"
  # PipeWire a nivel usuario (no sudo):
  systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service 2>/dev/null || warn "Servicios user pipewire se activarán al reiniciar"
  ok "Servicios habilitados."

  log "Paso 6/7: Directorios base..."
  mkdir -p "$HOME/.config" "$HOME/Pictures/Wallpapers" "$HOME/.local/bin" "$HOME/.local/share/fonts"
  xdg-user-dirs-update 2>/dev/null || true
  # Shell: bash (tu config vive en otro repo; no se toca chsh)
  fc-cache -fv >/dev/null 2>&1 || true
  ok "Directorios listos."

  log "Paso 7/7: Desplegando dotfiles del rice..."
  REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  deploy_dotfiles "$REPO_DIR"
  ok "Dotfiles desplegados."

  echo ""
  echo -e "${GREEN}════════ INSTALACIÓN COMPLETA ════════${NC}"
  echo -e "Verificación rápida:"
  echo -e "  Hyprland : $(command -v Hyprland >/dev/null && echo OK || echo FALTA)"
  echo -e "  waybar   : $(command -v waybar >/dev/null && echo OK || echo FALTA)"
  echo -e "  wofi     : $(command -v wofi >/dev/null && echo OK || echo FALTA)"
  echo -e "  kitty    : $(command -v kitty >/dev/null && echo OK || echo FALTA)"
  echo -e "  swaync   : $(command -v swaync >/dev/null && echo OK || echo FALTA)"
  echo -e "  wpctl    : $(command -v wpctl >/dev/null && echo OK || echo FALTA)"
  echo -e "  grim/slurp: $(command -v grim >/dev/null && command -v slurp >/dev/null && echo OK || echo FALTA)"
  echo -e "  sddm     : $(command -v sddm >/dev/null && echo OK || echo FALTA)"
  echo -e "  starship : $(command -v starship >/dev/null && echo OK || echo FALTA)"
  echo ""
  echo -e "${YELLOW}Listo: reinicia y entra en la sesión Hyprland (SDDM).${NC}"
  echo -e "Si algo falló, revisa arriba y re-ejecuta: ./install.sh"
}

main "$@"

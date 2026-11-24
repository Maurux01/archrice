#!/usr/bin/env bash
# =============================================================================
#  install.sh — instalador único de archrice (Arch Linux, Wayland, Gruvbox Dark)
# =============================================================================
#  Reglas de oro:
#   1. ESTRICTAMENTE WAYLAND (nada de picom, xrandr, rofi-x11, feh, maim, xclip)
#   2. TEMA EXCLUSIVO: GRUVBOX DARK
#   3. RENDIMIENTO: animaciones cortas, sin blur pesado ni daemons extra
#   4. SOLO ARCH: pacman + yay/paru
#
#  Fases incluidas: 1 (paquetes) · 2 (Hyprland/Waybar) · 3 (wofi/rofi/swaync)
#                   4 (SDDM + wlogout) · 5 (polkit + wallpaper + hypridle)
# =============================================================================

set -euo pipefail

# --- Colores / logging ---
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

log()  { echo -e "${CYAN}› $1${NC}"; }
ok()   { echo -e "${GREEN}  ✓ $1${NC}"; }
warn() { echo -e "${YELLOW}  ⚠ $1${NC}"; }
err()  { echo -e "${RED}  ✗ $1${NC}" >&2; }
die()  { err "$1"; exit 1; }

# --- Pre-chequeos (solo Arch, sin rutas Debian/Kali/apt) ---
[ "$EUID" -eq 0 ] && die "No ejecutes como root. Usa un usuario con sudo."
command -v pacman >/dev/null 2>&1 || die "pacman no encontrado. Este script es solo para Arch Linux."
command -v sudo   >/dev/null 2>&1 || die "sudo no encontrado. Instala sudo primero."
if ! command -v git >/dev/null 2>&1; then
  log "Instalando git + base-devel..."
  sudo pacman -Syu --noconfirm --needed git base-devel
fi

# --- Helper AUR: yay preferido, paru como alternativa ---
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
  sudo pacman -Syu --noconfirm --needed base-devel git
  local tmp
  tmp="$(mktemp -d)"
  git clone --depth 1 https://aur.archlinux.org/yay.git "$tmp/yay"
  ( cd "$tmp/yay" && makepkg -si --noconfirm )
  rm -rf "$tmp"
  AUR_HELPER="yay"
  ok "yay instalado."
}

# --- Paquetes oficiales (todo Wayland-nativo) ---
PACMAN_PKGS=(
  # Hyprland + Wayland core
  hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-utils
  xdg-user-dirs wayland-protocols qt5-wayland qt6-wayland
  # Sesión / lock / idle / wallpaper
  sddm awww hyprlock hypridle          # awww proporciona el binario swww
  # Bar + launcher + notificaciones
  waybar wofi rofi swaync libnotify     # rofi proporciona rofi-wayland
  # Terminal + editor + prompt
  kitty neovim starship
  # Audio (PipeWire; wpctl viene con wireplumber)
  pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
  pavucontrol pamixer playerctl
  # Red + Bluetooth
  networkmanager network-manager-applet blueman bluez bluez-utils
  # Screenshots / clipboard (Wayland)
  grim slurp wl-clipboard cliphist swappy
  # Vídeo
  obs-studio
  # Archivos
  thunar thunar-archive-plugin tumbler gvfs file-roller
  yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide imagemagick ueberzugpp
  # Polkit + keyring (permisos para nm/blueman)
  polkit polkit-gnome gnome-keyring
  # Brillo + utilidades Wayland
  brightnessctl wev
  # Navegador + monitor del sistema
  firefox btop fastfetch
  # Herramientas CLI
  eza bat htop curl unzip zip ttf-bitstream-vera
  # Fuentes + iconos (el cursor Bibata se instala desde AUR más abajo)
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
  # Dependencias Qt de sugar-candy
  qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
)

# Solo Wayland/Gruvbox desde AUR
AUR_PKGS=(
  sddm-sugar-candy-git           # tema SDDM (themea Gruvbox mas abajo)
  gruvbox-material-gtk-theme-git # GTK Gruvbox Dark
  gruvbox-material-icon-theme-git
  grimblast-git                  # grim + slurp con copia al portapapeles
  hyprpicker-git                 # color picker Wayland
  wlogout                        # menú de apagado Wayland
  wl-screenrec                   # grabación Wayland eficiente (AUR)
  bibata-cursor-theme-bin        # cursor Gruvbox/Bibata (AUR, binario)
)

# --- Despliegue del rice ---
deploy_dotfiles() {
  local repo="$1"
  local dot="$repo/dotfiles"
  local bk="$HOME/.archrice-backup-$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$bk"
  log "Backup de configuración previa en: $bk"

  # ~/.config/hypr: solo los archivos del rice
  mkdir -p "$HOME/.config/hypr"
  local f
  for f in hyprland.conf keybindings.conf windowrules.conf monitors.conf \
           hyprlock.conf hypridle.conf; do
    [ -f "$HOME/.config/hypr/$f" ] && cp "$HOME/.config/hypr/$f" "$bk/" 2>/dev/null || true
    if [ -f "$dot/hypr/$f" ]; then
      cp "$dot/hypr/$f" "$HOME/.config/hypr/$f"
      ok "hypr/$f"
    else
      warn "Falta dotfiles/hypr/$f en el repo"
    fi
  done

  # Configuraciones completas: waybar, swaync, wofi, rofi, nvim, wlogout
  local d
  for d in waybar swaync wofi rofi nvim wlogout; do
    [ -d "$dot/$d" ] || { warn "Sin dotfiles/$d (se omite)"; continue; }
    [ -d "$HOME/.config/$d" ] && cp -r "$HOME/.config/$d" "$bk/$d" 2>/dev/null || true
    mkdir -p "$HOME/.config/$d"
    cp -r "$dot/$d/"* "$HOME/.config/$d/" 2>/dev/null || warn "Sin archivos en dotfiles/$d"
    ok "$d -> ~/.config/$d"
  done

  # Scripts sueltos del repo -> ~/.local/bin
  mkdir -p "$HOME/.local/bin"
  local s target
  for s in "$dot/hypr/script/save_wallpaper.sh" \
           "$dot/swww/wallpaper-wipe.sh" \
           "$dot/wofi/wofi-wifi.sh"; do
    if [ -f "$s" ]; then
      target="$HOME/.local/bin/$(basename "$s")"
      cp "$s" "$target"
      chmod +x "$target"
      ok "$(basename "$s") -> ~/.local/bin"
    fi
  done

  # Helper: screenshot (grimblast guarda en ~/Pictures/Screenshots y copia al clipboard)
  cat > "$HOME/.local/bin/screenshot.sh" << 'HELPER'
#!/usr/bin/env bash
# archrice · screenshots Wayland (grimblast: archivo + portapapeles)
# Uso: screenshot.sh [area|output|screen|active] [--jpeg]  (por defecto: area)
set -euo pipefail
MODE="area"; JPEG=0
for a in "$@"; do
  case "$a" in
    area|output|screen|active|s|m|p|w) MODE="$a" ;;
    --jpeg|-j) JPEG=1 ;;
    -h|--help) echo "Uso: $0 [area|output|screen|active] [--jpeg]"; exit 0 ;;
    *) echo "Opción desconocida: $a" >&2; exit 1 ;;
  esac
done
case "$MODE" in s) MODE=area ;; m) MODE=output ;; p) MODE=screen ;; w) MODE=active ;; esac
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"
OUT="$(grimblast copysave "$MODE" "$FILE")" || exit 1
FILE="${OUT:-$FILE}"
if [ "$JPEG" = "1" ]; then
  if command -v magick >/dev/null 2>&1; then
    magick "$FILE" "${FILE%.png}.jpg" && rm -f "$FILE" && FILE="${FILE%.png}.jpg"
  elif command -v convert >/dev/null 2>&1; then
    convert "$FILE" "${FILE%.png}.jpg" && rm -f "$FILE" && FILE="${FILE%.png}.jpg"
  fi
fi
notify-send --app-name="screenshot" --icon="$FILE" "Screenshot" "Guardada: $FILE"
HELPER

  # Helper: toggle de grabación con OBS (SUPER+Shift+O)
  cat > "$HOME/.local/bin/obs-toggle.sh" << 'HELPER'
#!/usr/bin/env bash
# archrice · iniciar/detener grabación de OBS en segundo plano
set -euo pipefail
if pgrep -x obs >/dev/null 2>&1; then
  pkill -TERM -x obs || true
  notify-send --app-name="obs-toggle" "OBS" "Grabación detenida"
else
  obs --startrecording --minimize-to-tray >/dev/null 2>&1 &
  disown
  notify-send --app-name="obs-toggle" "OBS" "Grabando — SUPER+Shift+O para detener"
fi
HELPER

  # Helper: aplicar el wallpaper cuando swww-daemon ya esté listo
  cat > "$HOME/.local/bin/set-wallpaper.sh" << 'HELPER'
#!/usr/bin/env bash
# archrice · aplica el wallpaper Gruvbox esperando a swww-daemon
set -euo pipefail
WALLPAPER="${1:-$HOME/Pictures/Wallpapers/gruvbox.png}"
[ -f "$WALLPAPER" ] || exit 0
command -v swww >/dev/null 2>&1 || exit 0
for _ in $(seq 1 40); do
  swww query >/dev/null 2>&1 && break
  sleep 0.25
done
swww img "$WALLPAPER" --transition-type fade --transition-duration 1 --transition-fps 60
HELPER

  chmod +x "$HOME/.local/bin/screenshot.sh" \
           "$HOME/.local/bin/obs-toggle.sh" \
           "$HOME/.local/bin/set-wallpaper.sh"
  ok "Helpers en ~/.local/bin: screenshot.sh, obs-toggle.sh, set-wallpaper.sh"

  # Wallpaper Gruvbox (usuario + SDDM)
  if [ -f "$dot/wallpapers/gruvbox.png" ]; then
    mkdir -p "$HOME/Pictures/Wallpapers"
    cp "$dot/wallpapers/gruvbox.png" "$HOME/Pictures/Wallpapers/gruvbox.png"
    sudo mkdir -p /usr/share/backgrounds
    sudo cp "$dot/wallpapers/gruvbox.png" /usr/share/backgrounds/gruvbox.png
    ok "Wallpaper Gruvbox instalado (usuario + SDDM)"
  else
    warn "Falta dotfiles/wallpapers/gruvbox.png"
  fi

  # SDDM
  if [ -f "$dot/sddm/sddm.conf" ]; then
    sudo cp /etc/sddm.conf "$bk/sddm.conf" 2>/dev/null || true
    sudo cp "$dot/sddm/sddm.conf" /etc/sddm.conf
    ok "sddm.conf desplegado"
  fi
  if [ -d /usr/share/sddm/themes/sugar-candy ] && \
     [ -f "$dot/sddm/themes/sugar-candy/theme.conf.user" ]; then
    sudo cp /usr/share/sddm/themes/sugar-candy/theme.conf.user "$bk/" 2>/dev/null || true
    sudo cp "$dot/sddm/themes/sugar-candy/theme.conf.user" \
            /usr/share/sddm/themes/sugar-candy/theme.conf.user
    ok "sugar-candy Gruvbox desplegado"
  else
    warn "Tema sugar-candy no encontrado; vuelve a ejecutar install.sh tras instalar los AUR."
  fi

  ok "Backup disponible en: $bk"
}

main() {
  echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}  archrice · Gruvbox Wayland Rice (Arch) — instalador único  ${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"

  log "Paso 1/7: Actualizando sistema (pacman -Syu)..."
  sudo pacman -Syu --noconfirm

  log "Paso 2/7: AUR helper..."
  install_yay
  ok "Helper activo: $AUR_HELPER"

  log "Paso 3/7: Instalando paquetes oficiales (${#PACMAN_PKGS[@]})..."
  sudo pacman -S --noconfirm --needed "${PACMAN_PKGS[@]}"
  ok "Paquetes pacman instalados"

  log "Paso 4/7: Instalando paquetes AUR (${#AUR_PKGS[@]})..."
  if ! "$AUR_HELPER" -S --noconfirm --needed "${AUR_PKGS[@]}"; then
    warn "Algún paquete AUR falló. Reintenta con:"
    warn "  $AUR_HELPER -S ${AUR_PKGS[*]}"
    warn "y vuelve a ejecutar ./install.sh (es seguro: usa --needed)."
  else
    ok "Paquetes AUR instalados"
  fi

  log "Paso 5/7: Habilitando servicios..."
  sudo systemctl enable NetworkManager.service 2>/dev/null || warn "No se pudo habilitar NetworkManager"
  sudo systemctl enable bluetooth.service      2>/dev/null || warn "No se pudo habilitar bluetooth"
  sudo systemctl enable sddm.service           2>/dev/null || warn "No se pudo habilitar sddm"
  # PipeWire se gestiona a nivel usuario; si no hay bus de usuario, se activará al iniciar sesión.
  systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service 2>/dev/null \
    || warn "Servicios PipeWire de usuario se activarán al iniciar sesión"
  ok "Servicios habilitados"

  log "Paso 6/7: Directorios base..."
  mkdir -p "$HOME/.config" "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Screenshots" \
           "$HOME/.local/bin" "$HOME/.local/share/fonts"
  xdg-user-dirs-update 2>/dev/null || true
  # El shell (bash) y su config viven en otro repo: no se toca chsh.
  fc-cache -fv >/dev/null 2>&1 || true
  ok "Directorios listos"

  log "Paso 7/7: Desplegando dotfiles del rice..."
  REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  deploy_dotfiles "$REPO_DIR"
  ok "Dotfiles desplegados"

  echo ""
  echo -e "${GREEN}════════ INSTALACIÓN COMPLETA ════════${NC}"
  echo "Verificación rápida:"
  local cmd
  for cmd in Hyprland waybar wofi kitty swaync wpctl grim slurp sddm starship \
             hyprlock hypridle wlogout swww nvim; do
    if command -v "$cmd" >/dev/null 2>&1; then
      echo -e "  $(printf '%-12s' "$cmd") ${GREEN}OK${NC}"
    else
      echo -e "  $(printf '%-12s' "$cmd") ${RED}FALTA${NC}"
    fi
  done
  echo ""
  echo -e "${YELLOW}Listo: reinicia y entra en la sesión Hyprland desde SDDM.${NC}"
  echo -e "Si algo falló, revisa el output y vuelve a ejecutar: ./install.sh"
}

main "$@"

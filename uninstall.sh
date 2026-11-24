#!/usr/bin/env bash
# =============================================================================
#  uninstall.sh — desinstalador de archrice (solo lo que install.sh desplegó)
# =============================================================================
#  Crea un backup con timestamp, elimina únicamente los paquetes/configs de
#  este rice y NO toca tu shell, GRUB, docker, node, navegadores, etc.
# =============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

log()     { echo -e "${CYAN}› $1${NC}"; }
ok()      { echo -e "${GREEN}  ✓ $1${NC}"; }
warn()    { echo -e "${YELLOW}  ⚠ $1${NC}"; }
err()     { echo -e "${RED}  ✗ $1${NC}" >&2; }
die()     { err "$1"; exit 1; }
section() { echo ""; echo -e "${BLUE}▸ $1${NC}"; }

# --- Solo Arch, usuario normal ---
[ "$EUID" -eq 0 ] && die "No ejecutes como root. Usa tu usuario con sudo."
command -v pacman >/dev/null 2>&1 || die "pacman no encontrado: este script es solo para Arch Linux."

BACKUP="$HOME/.archrice-backup-$(date +%Y%m%d-%H%M%S)"

# Paquetes instalados por install.sh (oficiales + AUR; todos están en pacman -Q)
PACKAGES=(
  hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-utils
  xdg-user-dirs wayland-protocols qt5-wayland qt6-wayland
  sddm awww hyprlock hypridle waybar wofi rofi swaync libnotify
  kitty neovim starship
  pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber
  pavucontrol pamixer playerctl
  networkmanager network-manager-applet blueman bluez bluez-utils
  grim slurp wl-clipboard cliphist swappy obs-studio
  thunar thunar-archive-plugin tumbler gvfs file-roller
  yazi ffmpeg 7zip jq poppler fd ripgrep fzf zoxide imagemagick ueberzugpp
  polkit polkit-gnome gnome-keyring brightnessctl wev
  firefox btop fastfetch eza bat htop curl unzip zip ttf-bitstream-vera
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
  qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
  sddm-sugar-candy-git gruvbox-material-gtk-theme-git
  gruvbox-material-icon-theme-git grimblast-git hyprpicker-git wlogout
  wl-screenrec bibata-cursor-theme-bin
)

CONFIG_DIRS=(waybar swaync wofi rofi nvim wlogout)
HYPR_FILES=(hyprland.conf keybindings.conf windowrules.conf monitors.conf hyprlock.conf hypridle.conf)
HELPERS=(save_wallpaper.sh wallpaper-wipe.sh wofi-wifi.sh screenshot.sh obs-toggle.sh set-wallpaper.sh)

confirm() {
  echo -e "${RED}⚠  Esto desinstalará los paquetes y configuraciones de archrice.${NC}"
  echo -e "${YELLOW}   Se creará un backup en: $BACKUP${NC}"
  echo ""

  local answer="" src="${BASH_SOURCE[0]:-$0}"
  if [ -f "$src" ]; then
    # Ejecutado desde un archivo: stdin normal (también en los tests).
    read -r -p "Escribe SI para confirmar: " answer || answer=""
  elif [ -e /dev/tty ]; then
    # Ejecutado con `curl ... | bash`: stdin es el propio script, así que
    # la confirmación se lee desde la terminal.
    printf 'Escribe SI para confirmar: ' > /dev/tty
    read -r answer < /dev/tty || answer=""
    printf '\n' > /dev/tty
  else
    # Sin terminal (CI): ARCHRICE_YES=SI permite confirmar de forma no interactiva.
    answer="${ARCHRICE_YES:-}"
    [ "$answer" = "SI" ] || die "Sin TTY. Usa ARCHRICE_YES=SI con el comando curl."
  fi
  [ "$answer" = "SI" ] || { echo "Desinstalación cancelada."; exit 0; }
}

create_backup() {
  section "Creando backup..."
  mkdir -p "$BACKUP"
  for d in "${CONFIG_DIRS[@]}"; do
    [ -d "$HOME/.config/$d" ] && cp -r "$HOME/.config/$d" "$BACKUP/$d" 2>/dev/null || true
  done
  mkdir -p "$BACKUP/hypr"
  for f in "${HYPR_FILES[@]}"; do
    [ -f "$HOME/.config/hypr/$f" ] && cp "$HOME/.config/hypr/$f" "$BACKUP/hypr/$f" || true
  done
  mkdir -p "$BACKUP/bin"
  for h in "${HELPERS[@]}"; do
    [ -f "$HOME/.local/bin/$h" ] && cp "$HOME/.local/bin/$h" "$BACKUP/bin/$h" || true
  done
  [ -f "$HOME/Pictures/Wallpapers/gruvbox.png" ] && \
    cp "$HOME/Pictures/Wallpapers/gruvbox.png" "$BACKUP/" || true
  sudo cp /etc/sddm.conf "$BACKUP/sddm.conf" 2>/dev/null || true
  sudo cp /usr/share/sddm/themes/sugar-candy/theme.conf.user \
       "$BACKUP/theme.conf.user" 2>/dev/null || true
  ok "Backup en $BACKUP"
}

remove_packages() {
  section "Eliminando paquetes del rice..."
  local pkg
  for pkg in "${PACKAGES[@]}"; do
    if pacman -Q "$pkg" >/dev/null 2>&1; then
      sudo pacman -R --noconfirm "$pkg" >/dev/null 2>&1 \
        && ok "$pkg" \
        || warn "No se pudo eliminar $pkg (lo tiene otro paquete como dependencia)"
    fi
  done
}

disable_services() {
  section "Deshabilitando servicios..."
  sudo systemctl disable NetworkManager.service bluetooth.service sddm.service 2>/dev/null \
    && ok "Servicios del sistema deshabilitados" \
    || warn "Revisa los servicios del sistema manualmente"
  systemctl --user disable pipewire.service pipewire-pulse.service wireplumber.service 2>/dev/null \
    || true
}

remove_configs() {
  section "Eliminando configuraciones desplegadas..."
  local d f h
  for d in "${CONFIG_DIRS[@]}"; do
    rm -rf "$HOME/.config/$d"
  done
  for f in "${HYPR_FILES[@]}"; do
    rm -f "$HOME/.config/hypr/$f"
  done
  rmdir "$HOME/.config/hypr" 2>/dev/null || true
  for h in "${HELPERS[@]}"; do
    rm -f "$HOME/.local/bin/$h"
  done
  rm -f "$HOME/Pictures/Wallpapers/gruvbox.png"
  rm -f "$HOME/.cache/wallpaper"
  sudo rm -f /usr/share/backgrounds/gruvbox.png 2>/dev/null || true

  # SDDM: restaurar la config previa si existe; si no, quitar la nuestra.
  if [ -f "$BACKUP/sddm.conf" ]; then
    sudo cp "$BACKUP/sddm.conf" /etc/sddm.conf && ok "sddm.conf restaurado"
  else
    sudo rm -f /etc/sddm.conf && ok "sddm.conf eliminado"
  fi
  if [ -d /usr/share/sddm/themes/sugar-candy ]; then
    if [ -f "$BACKUP/theme.conf.user" ]; then
      sudo cp "$BACKUP/theme.conf.user" /usr/share/sddm/themes/sugar-candy/theme.conf.user
      ok "theme.conf.user restaurado"
    else
      sudo rm -f /usr/share/sddm/themes/sugar-candy/theme.conf.user
      ok "theme.conf.user eliminado"
    fi
  fi
  ok "Configuraciones eliminadas"
}

verify() {
  section "Verificando..."
  local errors=0
  local d h
  for d in "${CONFIG_DIRS[@]}"; do
    if [ -d "$HOME/.config/$d" ]; then
      err "$HOME/.config/$d sigue existiendo"
      errors=$((errors + 1))
    fi
  done
  for h in "${HELPERS[@]}"; do
    if [ -f "$HOME/.local/bin/$h" ]; then
      err "$h sigue existiendo"
      errors=$((errors + 1))
    fi
  done
  if pacman -Q hyprland >/dev/null 2>&1; then
    err "hyprland sigue instalado"
    errors=$((errors + 1))
  fi
  if [ "$errors" -eq 0 ]; then
    ok "Desinstalación verificada"
  else
    warn "Se encontraron $errors incidencias; revisa el output."
  fi
}

main() {
  echo -e "${RED}═══════════════════════════════════════════════════${NC}"
  echo -e "${RED}  archrice · desinstalador (solo lo que install.sh puso)  ${NC}"
  echo -e "${RED}═══════════════════════════════════════════════════${NC}"
  echo ""
  confirm
  create_backup
  remove_packages
  disable_services
  remove_configs
  verify
  echo ""
  echo -e "${GREEN}════════ DESINSTALACIÓN COMPLETADA ════════${NC}"
  echo "Backup disponible en: $BACKUP"
  echo "Para volver a instalar: curl -fsSL https://raw.githubusercontent.com/Maurux01/archrice/main/install.sh | bash"
}

main "$@"

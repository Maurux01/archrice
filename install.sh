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
#   - Fuentes: JetBrainsMono Nerd + Noto + Papirus + Bibata
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
  ttf-jetbrains-mono-nerd ttf-hack-nerd noto-fonts noto-fonts-emoji
  papirus-icon-theme bibata-cursor-theme
  # SDDM deps para sugar-candy
  qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
)

# Solo Wayland/Gruvbox desde AUR. Nada de X11 aquí.
AUR_PKGS=(
  sddm-sugar-candy-git          # tema SDDM (lo adaptamos a Gruvbox en FASE 4)
  gruvbox-material-gtk-theme-git # GTK Gruvbox Dark
  gruvbox-material-icon-theme-git # iconos a juego (fallback: papirus)
  grimblast-git                 # wrapper grim+slurp (Wayland nativo)
  hyprpicker-git                # color picker Wayland (útil para Gruvbox)
  wlogout                       # menú apagado Wayland (se themea en FASE 2/3)
)

main() {
  echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}  install.sh — FASE 1 · Gruvbox Wayland Rice (Arch) ${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"

  log "Paso 1/6: Actualizando sistema (pacman -Syu)..."
  sudo pacman -Syu --noconfirm

  log "Paso 2/6: AUR helper..."
  install_yay
  ok "Helper activo: $AUR_HELPER"

  log "Paso 3/6: Instalando paquetes oficiales (${#PACMAN_PKGS[@]})..."
  sudo pacman -S --noconfirm --needed "${PACMAN_PKGS[@]}"
  ok "Paquetes pacman instalados."

  log "Paso 4/6: Instalando paquetes AUR (${#AUR_PKGS[@]})..."
  "$AUR_HELPER" -S --noconfirm --needed "${AUR_PKGS[@]}" || {
    warn "Algún paquete AUR falló. Reintenta manualmente:"
    warn "  $AUR_HELPER -S ${AUR_PKGS[*]}"
  }
  ok "Paquetes AUR procesados."

  log "Paso 5/6: Habilitando servicios..."
  sudo systemctl enable NetworkManager.service || warn "No se pudo habilitar NetworkManager"
  sudo systemctl enable bluetooth.service || warn "No se pudo habilitar bluetooth"
  sudo systemctl enable sddm.service || warn "No se pudo habilitar sddm"
  # PipeWire a nivel usuario (no sudo):
  systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service 2>/dev/null || warn "Servicios user pipewire se activarán al reiniciar"
  ok "Servicios habilitados."

  log "Paso 6/6: Directorios base..."
  mkdir -p "$HOME/.config" "$HOME/Pictures/Wallpapers" "$HOME/.local/bin" "$HOME/.local/share/fonts"
  xdg-user-dirs-update 2>/dev/null || true
  # Shell: bash (tu config vive en otro repo; no se toca chsh)
  fc-cache -fv >/dev/null 2>&1 || true
  ok "Directorios listos."

  echo ""
  echo -e "${GREEN}════════ FASE 1 COMPLETA ════════${NC}"
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
  echo -e "${YELLOW}Siguiente: reinicia, entra en Hyprland y avísame para pasar a FASE 2 (hyprland.conf + waybar Gruvbox).${NC}"
  echo -e "Si algo falló, revisa arriba y re-ejecuta: ./install.sh"
}

main "$@"

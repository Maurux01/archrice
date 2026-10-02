#!/bin/bash

# =============================================================================
#                           🗑️ ARCH DOTS UNINSTALLER
# =============================================================================
# Script de desinstalación unificado y completo para Arch Dots
# Desinstala todo automáticamente con backup de seguridad
# =============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables globales
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.archriced-backup-$(date +%Y%m%d-%H%M%S)"
UNINSTALL_LOG="$HOME/.archriced-uninstall.log"

# Función para logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$UNINSTALL_LOG"
}

print_header() {
    echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                  🗑️ ARCH DOTS UNINSTALLER                   ║${NC}"
    echo -e "${RED}║                  Desinstalación completa automática          ║${NC}"
    echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo -e "${CYAN}▸ $1${NC}"
    log "SECCIÓN: $1"
}

print_step() {
    echo -e "${YELLOW}  → $1${NC}"
    log "PASO: $1"
}

print_success() {
    echo -e "${GREEN}  ✓ $1${NC}"
    log "ÉXITO: $1"
}

print_error() {
    echo -e "${RED}  ✗ $1${NC}"
    log "ERROR: $1"
}

print_warning() {
    echo -e "${YELLOW}  ⚠ $1${NC}"
    log "ADVERTENCIA: $1"
}

print_info() {
    echo -e "${BLUE}  ℹ $1${NC}"
    log "INFO: $1"
}

# =============================================================================
#                           🔍 FUNCIONES DE VERIFICACIÓN
# =============================================================================

check_system() {
    print_section "Verificando sistema..."
    
    if [ ! -f "/etc/arch-release" ]; then
        print_error "Este script está diseñado solo para Arch Linux."
        exit 1
    fi
    
    if [ "$EUID" -eq 0 ]; then
        print_error "No ejecutes este script como root."
        exit 1
    fi
    
    print_success "Sistema verificado."
}

# =============================================================================
#                           ⚠️ FUNCIONES DE CONFIRMACIÓN
# =============================================================================

confirm_uninstall() {
    echo -e "${RED}⚠️  ADVERTENCIA: Esta acción desinstalará completamente Arch Dots${NC}"
    echo -e "${RED}Esto incluye:${NC}"
    echo "• Eliminar todos los paquetes instalados"
    echo "• Restaurar configuraciones originales"
    echo "• Eliminar dotfiles personalizados"
    echo "• Limpiar configuraciones del sistema"
    echo ""
    echo -e "${YELLOW}Se creará un backup en: $BACKUP_DIR${NC}"
    echo ""
    
    read -p "¿Estás seguro de que quieres continuar? (escribe 'SI' para confirmar): " confirm
    
    if [ "$confirm" != "SI" ]; then
        echo "Desinstalación cancelada"
        exit 0
    fi
    
    echo ""
}

# =============================================================================
#                           💾 FUNCIONES DE BACKUP
# =============================================================================

create_backup() {
    print_section "Creando backup de configuraciones..."
    
    print_step "Creando directorio de backup..."
    mkdir -p "$BACKUP_DIR"
    
    print_step "Backup de dotfiles..."
    if [ -d "$HOME/.config" ]; then
        cp -r "$HOME/.config" "$BACKUP_DIR/"
    fi
    
    print_step "Backup de archivos de configuración..."
    local config_files=(
        "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile"
        "$HOME/.local/share/applications" "$HOME/.local/bin"
        "$HOME/.tmux.conf" "$HOME/.tmux"
    )
    
    for file in "${config_files[@]}"; do
        if [ -e "$file" ]; then
            cp -r "$file" "$BACKUP_DIR/"
        fi
    done
    
    print_step "Backup de configuración del sistema..."
    sudo cp -r /etc/hypr "$BACKUP_DIR/etc-hypr" 2>/dev/null || true
    sudo cp /etc/mkinitcpio.conf "$BACKUP_DIR/" 2>/dev/null || true
    sudo cp /etc/modprobe.d/nvidia.conf "$BACKUP_DIR/" 2>/dev/null || true
    sudo cp /etc/default/grub "$BACKUP_DIR/" 2>/dev/null || true
    
    print_step "Backup de wallpapers..."
    if [ -d "$HOME/Pictures/wallpapers" ]; then
        cp -r "$HOME/Pictures/wallpapers" "$BACKUP_DIR/"
    fi
    
    print_step "Backup de fuentes personalizadas..."
    if [ -d "$HOME/.local/share/fonts" ]; then
        cp -r "$HOME/.local/share/fonts" "$BACKUP_DIR/"
    fi
    
    print_success "Backup creado en $BACKUP_DIR"
}

# =============================================================================
#                           📦 FUNCIONES DE DESINSTALACIÓN
# =============================================================================

uninstall_packages() {
    print_section "Desinstalando paquetes..."
    
    print_step "Desinstalando paquetes de Hyprland..."
    local hyprland_packages=(
        "hyprland" "waybar" "eww" "swww" "wofi" "mako" "swaylock"
        "swayidle" "grim" "slurp" "wl-clipboard" "xdg-desktop-portal-hyprland"
        "xdg-desktop-portal-gtk" "kitty" "neovim" "starship"
        "zoxide" "tmux"
    )
    
    for pkg in "${hyprland_packages[@]}"; do
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            print_step "Desinstalando $pkg..."
            sudo pacman -R "$pkg" --noconfirm
        fi
    done
    
    print_step "Desinstalando utilidades del sistema..."
    local util_packages=(
        "bat" "fd" "ripgrep" "fzf" "lazygit" "yazi" "btop" "htop"
        "neofetch" "fastfetch" "cava" "pavucontrol" "blueman"
        "mpv" "vlc" "steam" "lutris" "wine" "gamemode" "mangohud"
        "flameshot" "spectacle" "maim" "xclip" "imagemagick"
        "ffmpeg" "v4l-utils" "pulseaudio-alsa"
        
        # Herramientas de seguridad y red
        "ufw" "wireguard-tools" "openvpn" "networkmanager-openvpn"
        "networkmanager-vpnc" "networkmanager-pptp" "networkmanager-l2tp"
        "nmap" "wireshark-qt" "tcpdump" "netcat" "nethogs" "iftop"
        "fail2ban" "rkhunter" "clamav" "clamav-unofficial-sigs"
    )
    
    for pkg in "${util_packages[@]}"; do
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            print_step "Desinstalando $pkg..."
            sudo pacman -R "$pkg" --noconfirm
        fi
    done
    
    print_step "Desinstalando herramientas de desarrollo..."
    local dev_packages=(
        "nodejs" "npm" "python" "python-pip" "rust" "go" "jdk-openjdk"
        "gcc" "cmake" "ninja" "meson" "valgrind" "gdb"
        "docker" "docker-compose" "podman" "buildah" "skopeo"
    )
    
    for pkg in "${dev_packages[@]}"; do
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            print_step "Desinstalando $pkg..."
            sudo pacman -R "$pkg" --noconfirm
        fi
    done
    
    print_step "Desinstalando herramientas multimedia..."
    local multimedia_packages=(
        "lmms" "obs" "obs-studio" "krita" "gimp" "inkscape"
        "spotify" "discord" "telegram-desktop"
    )
    
    for pkg in "${multimedia_packages[@]}"; do
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            print_step "Desinstalando $pkg..."
            sudo pacman -R "$pkg" --noconfirm
        fi
    done
    
    print_step "Desinstalando fuentes y temas..."
    local theme_packages=(
        "catppuccin-gtk-theme" "papirus-icon-theme" "bibata-cursor-theme"
        "adwaita-icon-theme" "gnome-themes-extra" "nerd-fonts-complete"
        "noto-fonts" "noto-fonts-emoji" "ttf-dejavu" "ttf-liberation"
        "ttf-jetbrains-mono"
    )
    
    for pkg in "${theme_packages[@]}"; do
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            print_step "Desinstalando $pkg..."
            sudo pacman -R "$pkg" --noconfirm
        fi
    done
    
    print_step "Desinstalando paquetes AUR..."
    local aur_packages=(
        "hyperlock" "oss" "heroic-games-launcher" "pixelorama" 
        "upscayl" "citra-git"
    )
    
    for pkg in "${aur_packages[@]}"; do
        if yay -Q "$pkg" >/dev/null 2>&1; then
            print_step "Desinstalando $pkg..."
            yay -R "$pkg" --noconfirm
        fi
    done
    
    print_success "Paquetes desinstalados"
}

# =============================================================================
#                           🗂️ FUNCIONES DE LIMPIEZA
# =============================================================================

clean_config_files() {
    print_section "Limpiando archivos de configuración..."
    
    print_step "Eliminando configuraciones de Hyprland..."
    rm -rf "$HOME/.config/hypr" 2>/dev/null || true
    rm -rf "$HOME/.config/hyprlock" 2>/dev/null || true
    
    print_step "Eliminando configuraciones de terminal..."
    rm -rf "$HOME/.config/kitty" 2>/dev/null || true
    rm -rf "$HOME/.config/tmux" 2>/dev/null || true
    rm -f "$HOME/.tmux.conf" 2>/dev/null || true
    rm -rf "$HOME/.tmux" 2>/dev/null || true
    
    print_step "Eliminando configuraciones de editores..."
    rm -rf "$HOME/.config/nvim" 2>/dev/null || true
    rm -rf "$HOME/.config/geany" 2>/dev/null || true
    rm -rf "$HOME/.config/code" 2>/dev/null || true
    
    print_step "Eliminando configuraciones de widgets..."
    rm -rf "$HOME/.config/eww" 2>/dev/null || true
    rm -rf "$HOME/.config/waybar" 2>/dev/null || true
    rm -rf "$HOME/.config/wofi" 2>/dev/null || true
    rm -rf "$HOME/.config/mako" 2>/dev/null || true
    rm -rf "$HOME/.config/swww" 2>/dev/null || true
    
    print_step "Eliminando configuraciones de portapapeles..."
    rm -rf "$HOME/.config/cliphist" 2>/dev/null || true
    rm -rf "$HOME/.config/copyq" 2>/dev/null || true
    
    print_step "Eliminando configuraciones de utilidades..."
    rm -rf "$HOME/.config/neofetch" 2>/dev/null || true
    rm -f "$HOME/.config/fastfetch.jsonc" 2>/dev/null || true
    rm -rf "$HOME/.config/scripts" 2>/dev/null || true
    
    print_step "Eliminando configuraciones de aplicaciones..."
    rm -rf "$HOME/.config/obs" 2>/dev/null || true
    rm -rf "$HOME/.config/krita" 2>/dev/null || true
    rm -rf "$HOME/.config/gimp" 2>/dev/null || true
    rm -rf "$HOME/.config/inkscape" 2>/dev/null || true
    
    print_step "Eliminando configuraciones de seguridad..."
    sudo rm -rf /etc/wireguard 2>/dev/null || true
    sudo rm -rf /etc/fail2ban 2>/dev/null || true
    sudo rm -rf /etc/clamav 2>/dev/null || true
    sudo rm -f /usr/local/bin/network-monitor.sh 2>/dev/null || true
    sudo rm -rf /var/log/network 2>/dev/null || true
    
    print_success "Archivos de configuración limpiados"
}

clean_system_config() {
    print_section "Limpiando configuraciones del sistema..."
    
    print_step "Restaurando configuración GRUB..."
    if [ -f "$BACKUP_DIR/grub" ]; then
        sudo cp "$BACKUP_DIR/grub" /etc/default/grub
        sudo grub-mkconfig -o /boot/grub/grub.cfg
        print_success "Configuración GRUB restaurada"
    else
        print_step "Eliminando tema GRUB Catppuccin..."
        sudo rm -rf /usr/share/grub/themes/catppuccin-grub-theme 2>/dev/null || true
        sudo sed -i 's/GRUB_THEME=.*/GRUB_THEME=""/' /etc/default/grub 2>/dev/null || true
        sudo grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null || true
    fi
    
    print_step "Restaurando configuración SDDM..."
    if [ -d "$BACKUP_DIR/sddm" ]; then
        sudo cp -r "$BACKUP_DIR/sddm"/* /etc/sddm.conf.d/ 2>/dev/null || true
    else
        sudo rm -rf /etc/sddm.conf.d/* 2>/dev/null || true
    fi
    
    print_step "Eliminando sesión Hyprland de GDM..."
    sudo rm -f /usr/share/wayland-sessions/hyprland.desktop 2>/dev/null || true
    
    print_step "Restaurando shell por defecto..."
    if command -v bash >/dev/null 2>&1; then
        sudo chsh -s /bin/bash "$USER"
        print_success "Shell restaurado a bash"
    fi
    
    print_success "Configuraciones del sistema limpiadas"
}

clean_fonts() {
    print_section "Limpiando fuentes personalizadas..."
    
    print_step "Eliminando fuentes de usuario..."
    rm -rf "$HOME/.local/share/fonts" 2>/dev/null || true
    
    print_step "Eliminando fuentes del sistema..."
    sudo rm -rf /usr/share/fonts/custom 2>/dev/null || true
    
    print_step "Actualizando caché de fuentes..."
    fc-cache -fv 2>/dev/null || true
    sudo fc-cache -fv 2>/dev/null || true
    
    print_success "Fuentes limpiadas"
}

clean_wallpapers() {
    print_section "Limpiando wallpapers..."
    
    print_step "Eliminando wallpapers..."
    rm -rf "$HOME/Pictures/wallpapers" 2>/dev/null || true
    rm -f "$HOME/.local/share/wallpapers" 2>/dev/null || true
    
    print_step "Eliminando configuraciones de wallpaper..."
    rm -rf "$HOME/.config/waypaper" 2>/dev/null || true
    rm -f "$HOME/.config/autostart/waypaper.desktop" 2>/dev/null || true
    
    print_success "Wallpapers limpiados"
}

clean_autostart() {
    print_section "Limpiando aplicaciones de inicio automático..."
    
    print_step "Eliminando aplicaciones de inicio automático..."
    rm -f "$HOME/.config/autostart/waypaper.desktop" 2>/dev/null || true
    rm -f "$HOME/.config/autostart/copyq.desktop" 2>/dev/null || true
    
    print_success "Aplicaciones de inicio automático limpiadas"
}

# =============================================================================
#                           🔧 FUNCIONES DE RESTAURACIÓN
# =============================================================================

restore_default_configs() {
    print_section "Restaurando configuraciones por defecto..."
    
    print_step "Creando configuraciones básicas..."

    # Bash config básico
    cat > "$HOME/.bashrc" << 'EOF'
# ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"
EOF

    print_success "Configuraciones por defecto restauradas"
}

# =============================================================================
#                           ✅ FUNCIONES DE VERIFICACIÓN
# =============================================================================

verify_uninstall() {
    print_section "Verificando desinstalación..."
    
    local errors=0
    
    # Verificar que los directorios principales fueron eliminados
    local dirs_to_check=(
        "$HOME/.config/hypr"
        "$HOME/.config/eww"
        "$HOME/.config/waybar"
        "$HOME/.config/wofi"
        "$HOME/.config/mako"
        "$HOME/.config/swww"
        "$HOME/.config/hyprlock"
    )
    
    for dir in "${dirs_to_check[@]}"; do
        if [ -d "$dir" ]; then
            print_error "✗ $dir aún existe"
            ((errors++))
        else
            print_success "✓ $dir eliminado"
        fi
    done
    
    # Verificar que los paquetes principales fueron desinstalados
    local packages_to_check=(
        "hyprland" "waybar" "eww" "kitty" "neovim"
    )
    
    for pkg in "${packages_to_check[@]}"; do
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            print_error "✗ $pkg aún está instalado"
            ((errors++))
        else
            print_success "✓ $pkg desinstalado"
        fi
    done
    
    if [ $errors -eq 0 ]; then
        print_success "Desinstalación verificada exitosamente"
    else
        print_error "Se encontraron $errors error(es) en la desinstalación"
    fi
}

# =============================================================================
#                           🛠️ RESTAURAR GRUB
# =============================================================================
restore_grub() {
    print_section "Restaurando configuración original de GRUB..."
    local restored=false
    # Restaurar /etc/default/grub
    if [ -f "$BACKUP_DIR/grub.backup" ]; then
        print_step "Restaurando /etc/default/grub..."
        sudo cp "$BACKUP_DIR/grub.backup" /etc/default/grub
        restored=true
    fi
    # Restaurar temas de GRUB
    if [ -d "$BACKUP_DIR/grub-themes.backup" ]; then
        print_step "Restaurando temas de GRUB..."
        sudo cp -r "$BACKUP_DIR/grub-themes.backup" /boot/grub/themes
        restored=true
    fi
    # Restaurar grub.cfg
    if [ -f "$BACKUP_DIR/grub.cfg.backup" ]; then
        print_step "Restaurando /boot/grub/grub.cfg..."
        sudo cp "$BACKUP_DIR/grub.cfg.backup" /boot/grub/grub.cfg
        restored=true
    fi
    if [ "$restored" = true ]; then
        print_success "Configuración de GRUB restaurada."
    else
        print_warning "No se encontró backup de GRUB para restaurar."
    fi
}

# =============================================================================
#                           📋 FUNCIÓN PRINCIPAL
# =============================================================================

show_final_info() {
    echo -e "${GREEN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}║                    DESINSTALACIÓN COMPLETADA                               ║${NC}"
    echo -e "${GREEN}══════════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    echo "Información importante:"
    echo "• Se creó un backup en: $BACKUP_DIR"
    echo "• Las configuraciones originales fueron respaldadas"
    echo "• Los paquetes fueron desinstalados"
    echo ""
    
    echo "Para restaurar desde el backup:"
    echo "• Copia los archivos desde $BACKUP_DIR a sus ubicaciones originales"
    echo "• Reinstala los paquetes necesarios con pacman/yay"
    echo ""
    
    echo "Para reinstalar Arch Dots:"
    echo "• Ejecuta ./install.sh desde el directorio del proyecto"
    echo ""
    
    echo "Próximos pasos:"
    echo "1. Reinicia tu sistema"
    echo "2. Instala un entorno de escritorio alternativo si es necesario"
    echo "3. Configura tu sistema según tus preferencias"
    echo ""
}

main() {
    print_header
    check_system
    confirm_uninstall
    create_backup
    uninstall_packages
    clean_config_files
    clean_system_config
    clean_fonts
    clean_wallpapers
    clean_autostart
    restore_default_configs
    verify_uninstall
    restore_grub
    show_final_info
}

# Ejecutar función principal
main "$@" 
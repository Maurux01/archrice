#!/bin/bash

set -e

# Colores para mensajes
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Detectar gestor de paquetes
if command -v pacman >/dev/null; then
    PKG_INSTALL="sudo pacman -S --noconfirm"
elif command -v apt >/dev/null; then
    PKG_INSTALL="sudo apt update && sudo apt install -y"
elif command -v dnf >/dev/null; then
    PKG_INSTALL="sudo dnf install -y"
else
    echo -e "${YELLOW}No se detectó un gestor de paquetes soportado (pacman, apt, dnf).${NC}"
    exit 1
fi

# Instalar fastfetch y neofetch si no están
for pkg in fastfetch neofetch; do
    if ! command -v $pkg >/dev/null; then
        echo -e "${GREEN}Instalando $pkg...${NC}"
        eval "$PKG_INSTALL $pkg"
    else
        echo -e "${GREEN}$pkg ya está instalado.${NC}"
    fi
done

# Copiar configuraciones
mkdir -p ~/.config/fastfetch ~/.config/neofetch
cp fastfetch-config.jsonc ~/.config/fastfetch/config.jsonc
cp neofetch-config.conf ~/.config/neofetch/config.conf

echo -e "${GREEN}Configuraciones copiadas a ~/.config/fastfetch y ~/.config/neofetch${NC}"

# Crear carpeta de imágenes y subcarpeta iconos
PICTURES="$HOME/Pictures"
ICONOS="$PICTURES/iconos"
mkdir -p "$PICTURES" "$ICONOS"

# Copiar todos los archivos de imagen del repositorio a la carpeta iconos
echo -e "${GREEN}Copiando iconos del repositorio a $ICONOS...${NC}"
find . -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.svg" -o -iname "*.gif" \) -exec cp {} "$ICONOS/" \;

# Si no hay iconos en el repositorio, descargar uno de ejemplo
if [ ! "$(ls -A $ICONOS)" ]; then
    echo -e "${YELLOW}No se encontraron iconos en el repositorio. Descargando uno de ejemplo...${NC}"
    wget -O "$ICONOS/arch-icon.png" https://upload.wikimedia.org/wikipedia/commons/a/a7/Archlinux-icon-crystal-64.svg || true
fi

echo -e "${GREEN}¡Listo!${NC}"
echo -e "\nPara usar una imagen aleatoria con neofetch o fastfetch, ejecuta:\n"
echo -e "${YELLOW}bash -c 'RANDOM_IMG=\"$(find \"$ICONOS\" -type f \( -iname \"*.png\" -o -iname \"*.jpg\" -o -iname \"*.jpeg\" -o -iname \"*.svg\" -o -iname \"*.gif\" \) | shuf -n 1)\"; cp \"$RANDOM_IMG\" \"$HOME/Pictures/random.png\"; neofetch'${NC}"
echo -e "\no\n"
echo -e "${YELLOW}bash -c 'RANDOM_IMG=\"$(find \"$ICONOS\" -type f \( -iname \"*.png\" -o -iname \"*.jpg\" -o -iname \"*.jpeg\" -o -iname \"*.svg\" -o -iname \"*.gif\" \) | shuf -n 1)\"; cp \"$RANDOM_IMG\" \"$HOME/Pictures/random.png\"; fastfetch'${NC}"
echo -e "\nPuedes agregar tus propios iconos a $ICONOS para personalizar aún más tu fetch.\n" 
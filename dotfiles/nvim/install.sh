#!/bin/bash
# Instalador de Neovim Modern IDE + dependencias para desarrollo web
set -e

# Instalar dependencias del sistema
sudo pacman -S --needed --noconfirm neovim nodejs npm git ripgrep fd python-pip curl unzip lazygit lazydocker

# Instalar dependencias npm globales
sudo npm install -g prettier eslint_d typescript typescript-language-server live-server

# Mensaje final
cat << EOF

✅ Neovim y todas las dependencias para desarrollo web han sido instaladas.

- Usa :Lazy sync en Neovim para instalar los plugins.
- Usa <leader>ls para Live Server, <leader>rr para peticiones HTTP.
- Usa <leader>gg para LazyGit y <leader>dd para LazyDocker en terminal flotante.
- Disfruta de autocompletado y formateo moderno.

EOF

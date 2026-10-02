# fst-neofetch

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform: Linux](https://img.shields.io/badge/platform-linux-blue.svg)](https://www.linux.org/)

Config vibrante para [Fastfetch](https://github.com/fastfetch-cli/fastfetch) y [Neofetch](https://github.com/dylanaraps/neofetch) con bloques de color, iconos Nerd Font y soporte para mostrar una imagen aleatoria.

---

## Instalación rápida en Linux

1. **Clona este repositorio y entra a la carpeta:**
   ```sh
   git clone https://github.com/tuusuario/fst-neofetch.git
   cd fst-neofetch
   ```
2. **Ejecuta el instalador:**
   ```sh
   bash install-fst-neofetch.sh
   ```
   Esto instalará fastfetch y neofetch (si no los tienes), copiará las configuraciones y creará la carpeta `~/Pictures/iconos` con los iconos del repositorio.

---

## ¿Cómo usarlo?

1. **Agrega tus iconos favoritos (PNG, JPG, JPEG, SVG, GIF) a `~/Pictures/iconos`** para que se muestren aleatoriamente.
2. **Para mostrar una imagen aleatoria con neofetch:**
   ```sh
   bash -c 'RANDOM_IMG="$(find "$HOME/Pictures/iconos" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.svg" -o -iname "*.gif" \) | shuf -n 1)"; cp "$RANDOM_IMG" "$HOME/Pictures/random.png"; neofetch'
   ```
3. **Para mostrar una imagen aleatoria con fastfetch:**
   ```sh
   bash -c 'RANDOM_IMG="$(find "$HOME/Pictures/iconos" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.svg" -o -iname "*.gif" \) | shuf -n 1)"; cp "$RANDOM_IMG" "$HOME/Pictures/random.png"; fastfetch'
   ```

Puedes poner estos comandos en un alias o script para mayor comodidad.

---

## Preview

Así se verá tu terminal (ver `screenshot.png` si está disponible):

> ¡Asegúrate de usar una Nerd Font y un terminal con soporte de color verdadero para el mejor resultado!

---

## Créditos

- Inspirado en Arch Linux y TokyoNight.
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch)
- [Neofetch](https://github.com/dylanaraps/neofetch)
- [Nerd Fonts](https://www.nerdfonts.com/)

---

## Licencia

Este proyecto está bajo la [Licencia MIT](LICENSE).
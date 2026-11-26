#!/usr/bin/env bash
# archrice · reiniciar waybar sin reiniciar Hyprland
# Se usa desde el atajo SUPER + CTRL + B (ver keybindings.conf).
set -euo pipefail

pkill -x waybar 2>/dev/null || true

# Dar tiempo a que se libere la layer surface antes de relanzar
sleep 0.3

nohup waybar >/dev/null 2>&1 &

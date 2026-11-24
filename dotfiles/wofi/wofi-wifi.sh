#!/usr/bin/env bash
# archrice · selector de Wi-Fi con wofi + NetworkManager (Wayland nativo)
# Basado en el script de knightfall01 (Knightfall01/Hyprland-config).
# Uso: se lanza con SUPER+W desde keybindings.conf.
set -uo pipefail

command -v nmcli >/dev/null 2>&1 || { notify-send "archrice" "NetworkManager (nmcli) no está disponible" 2>/dev/null || true; exit 1; }
command -v wofi  >/dev/null 2>&1 || { echo "wofi no encontrado" >&2; exit 1; }

radio="$(nmcli -t -f WIFI general 2>/dev/null || true)"

if [ "$radio" = "enabled" ]; then
  toggle_label="Desactivar Wi-Fi"
  toggle_cmd="nmcli radio wifi off"
elif [ "$radio" = "disabled" ]; then
  toggle_label="Activar Wi-Fi"
  toggle_cmd="nmcli radio wifi on"
else
  toggle_label="Activar/Desactivar Wi-Fi"
  toggle_cmd="nmcli radio wifi toggle"
fi

# nmcli -t separa con ':'; con --escape yes un ':' dentro del SSID llega como '\:'.
# Reconstruimos el SSID uniendo todos los campos intermedios hasta SIGNAL (penúltimo).
networks="$(nmcli --escape yes -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list 2>/dev/null | awk -F: '
  NF < 4 { next }
  {
    signal = $(NF-1)
    ssid = ""
    for (i = 2; i <= NF-2; i++) ssid = ssid (i > 2 ? ":" : "") $i
    gsub(/\\:/, ":", ssid)
    if (ssid == "") next
    printf "%s\t%s\t%s%%\n", ($1 == "*" ? "*" : " "), ssid, signal
  }
')"

menu_items="$(printf '%s\n%s\n%s\n' "$toggle_label" "Introducir red manualmente" "$networks")"
choice="$(printf '%s\n' "$menu_items" | wofi --dmenu --cache-file /dev/null \
  --prompt "Wi-Fi" --width 420 --lines 12 2>/dev/null)" || exit 0

[ -z "$choice" ] && exit 0

case "$choice" in
  "$toggle_label")
    $toggle_cmd
    ;;
  "Introducir red manualmente")
    ssid="$(printf '' | wofi --dmenu --cache-file /dev/null --prompt "SSID" 2>/dev/null)" || exit 0
    [ -z "$ssid" ] && exit 0
    pass="$(printf '' | wofi --dmenu --cache-file /dev/null --prompt "Contraseña (dejar vacío si es abierta)" 2>/dev/null)" || exit 0
    if [ -n "$pass" ]; then
      nmcli device wifi connect "$ssid" password "$pass" || notify-send "archrice" "No se pudo conectar a $ssid"
    else
      nmcli device wifi connect "$ssid" || notify-send "archrice" "No se pudo conectar a $ssid"
    fi
    ;;
  *)
    ssid="$(printf '%s\n' "$choice" | awk -F'\t' '{print $2}')"
    [ -z "$ssid" ] && exit 0
    if nmcli -t -f NAME connection show 2>/dev/null | grep -Fxq "$ssid"; then
      nmcli connection up "$ssid" || notify-send "archrice" "No se pudo conectar a $ssid"
    else
      nmcli device wifi connect "$ssid" || notify-send "archrice" "No se pudo conectar a $ssid"
    fi
    ;;
esac

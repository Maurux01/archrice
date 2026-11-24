# archrice — Gruvbox Hyprland Daily Driver (Arch Linux, Wayland-only)

Rice minimalista y rápido para Arch Linux con Hyprland. Estrictamente Wayland,
exclusivamente Gruvbox Dark y ajustado para rendimiento. `install.sh` instala
**todo** el stack y despliega **todas** las configuraciones; `uninstall.sh`
revierte solo lo que este rice instaló.

## Golden rules

1. **Wayland only.** No X11 (no picom, xrandr, feh, maim, xclip ni rofi X11).
2. **Gruvbox Dark everywhere.** Barra, launcher, terminal, notificaciones, SDDM y lockscreen comparten paleta.
3. **Performance first.** Animaciones `bezier` cortas, sin bounce, blur pequeño, sin sombras.
4. **Arch Linux only.** `pacman` + `yay`/`paru`. Sin rutas Debian/Kali/apt.

### Gruvbox Dark (referencia)

| Nombre | Hex |
|---|---|
| bg / bg_h / bg1 / bg2 | `#282828` / `#1d2021` / `#3c3836` / `#504945` |
| fg / gray | `#ebdbb2` / `#a89984` |
| red / green / yellow | `#cc241d` / `#98971a` / `#d79921` |
| blue / purple / aqua / orange | `#458588` / `#b16286` / `#689d6a` / `#d65d0e` |

## Stack

| Componente | Elección |
|---|---|
| Compositor | Hyprland + `xdg-desktop-portal-hyprland/gtk`, `awww` (binario `swww`), `hyprlock`, `hypridle` |
| Display manager | SDDM + tema sugar-candy adaptado a Gruvbox |
| Barra | Waybar (solo info esencial) |
| Launcher | wofi + `rofi` (paquete oficial que proporciona `rofi-wayland`) |
| Terminal / editor | kitty, neovim (LazyVim) · `starship` (bash/config en tu otro repo) |
| Notificaciones | swaync + libnotify |
| Audio | PipeWire + WirePlumber (`wpctl`) + pavucontrol + pamixer + playerctl |
| Red / Bluetooth | NetworkManager + nm-applet + blueman + bluez |
| Capturas | grim + slurp + wl-clipboard + cliphist + swappy + grimblast |
| Grabación | OBS Studio (+ `wl-screenrec` desde AUR para capturas rápidas por CLI) |
| Gestores de archivos | Thunar (+ gvfs/tumbler) e yazi |
| Agente de autenticación | polkit-gnome + gnome-keyring |
| Brillo | brightnessctl |
| Fuentes / iconos / cursor | JetBrainsMono Nerd + Noto (+emoji) · Gruvbox-Material-Dark · Bibata |

## Requisitos

- Arch Linux (o derivada con `pacman`).
- Usuario no root con `sudo`.
- Conexión a Internet.

## Inicio rápido

```bash
git clone https://github.com/Maurux01/archrice.git
cd archrice
chmod +x install.sh uninstall.sh
./install.sh
reboot
```

`install.sh` es idempotente: usa `pacman -S --needed` y el AUR helper con
`--needed`, y hace backup de cualquier config previa en
`~/.archrice-backup-<timestamp>`.

### Qué instala y despliega

1. Actualiza el sistema (`pacman -Syu`) e instala `yay` si no hay helper AUR.
2. Instala 76 paquetes oficiales + 8 paquetes AUR (todos Wayland/Gruvbox).
3. Habilita `NetworkManager`, `bluetooth` y `sddm`; habilita PipeWire a nivel usuario.
4. Crea `~/.config`, `~/Pictures/Wallpapers`, `~/Pictures/Screenshots` y `~/.local/bin`.
5. Despliega las configuraciones en `~/.config/{hypr,waybar,wofi,rofi,swaync,nvim,wlogout}`.
6. Genera en `~/.local/bin`: `screenshot.sh`, `obs-toggle.sh`, `set-wallpaper.sh`.
7. Copia los scripts sueltos (`wofi-wifi.sh`, `wallpaper-wipe.sh`, `save_wallpaper.sh`).
8. Instala el wallpaper Gruvbox en `~/Pictures/Wallpapers/gruvbox.png` y en
   `/usr/share/backgrounds/gruvbox.png` (lo usa también el greeter de SDDM).
9. Aplica `/etc/sddm.conf` y `theme.conf.user` de sugar-candy.

Verificación rápida tras reiniciar:

```bash
Hyprland --version; waybar --version; wofi --version; wpctl status
systemctl status NetworkManager bluetooth sddm
```

## Atajos principales (SUPER = tecla Windows)

| Atajo | Acción |
|---|---|
| `SUPER + Return` | kitty |
| `SUPER + D` / `SUPER + Space` | launcher (wofi / rofi) |
| `SUPER + B` / `SUPER + Shift + B` | Firefox / ventana privada |
| `SUPER + E` / `SUPER + Y` | Thunar / yazi en terminal |
| `SUPER + W` | selector de Wi-Fi (wofi + nmcli) |
| `SUPER + Escape` / `SUPER + X` | hyprlock / menú de apagado (wlogout) |
| `SUPER + Shift + O` | iniciar/detener grabación OBS |
| `SUPER + N` / `SUPER + Shift + N` | panel de notificaciones / No molestar |
| `Print` / `SUPER + Print` / `SUPER + Shift + Print` | captura de área / monitor / pantalla (archivo + clipboard) |
| `SUPER + C` | selector de color (copia al clipboard) |
| `SUPER + R` / `SUPER + Q` / `SUPER + Shift + Q` | recargar Hyprland / cerrar ventana / salir |

El equipo bloquea la sesión a los 5 minutos de inactividad y apaga la pantalla
a los 7 minutos (configurable en `~/.config/hypr/hypridle.conf`).

## Desinstalación

```bash
chmod +x uninstall.sh
./uninstall.sh
# escribe SI cuando te lo pida
```

Crea un backup con timestamp, elimina solo los paquetes y configuraciones que
install.sh desplegó (incluido `/etc/sddm.conf` y el wallpaper del sistema) y
**no toca** tu shell, GRUB, Docker, Node, navegadores ni otros paquetes.

## Roadmap

- [x] Fase 1 — `install.sh`: dependencias (Arch-only, Wayland-only, Gruvbox).
- [x] Fase 2 — `hyprland.conf` (animaciones suaves, keybinds) + Waybar Gruvbox.
- [x] Fase 3 — swaync + wofi/rofi en Gruvbox (kitty/starship/bash viven en tu otro repo).
- [x] Fase 4 — helpers de captura/OBS en `~/.local/bin`, SDDM sugar-candy + wlogout Gruvbox.
- [x] Fase 5 — polkit-gnome autostart, wallpaper Gruvbox, hypridle + hyprlock.

## Estructura

```text
.
├── .gitattributes      # fuerza LF en los scripts (bash en Linux)
├── install.sh          # instalador único
├── uninstall.sh        # desinstalador con backup
├── dotfiles/
│   ├── hypr/           # hyprland, keybinds, windowrules, monitores, hyprlock, hypridle… (+ temas/shaders de referencia)
│   ├── waybar/         # config + style.css
│   ├── wofi/           # config + estilos + wofi-wifi.sh
│   ├── rofi/           # config.rasi
│   ├── swaync/         # config.json + style.css
│   ├── wlogout/        # layout + style.css (Gruvbox)
│   ├── wallpapers/     # gruvbox.png (usuario + SDDM)
│   ├── sddm/           # sddm.conf + tema sugar-candy
│   ├── nvim/           # config LazyVim
│   └── (eww/, mako/, hyprlock/, grub-themes/)  # referencias legacy, NO se despliegan
├── tests/container/    # Dockerfile + smoke-test.sh + check-packages.sh
├── LICENSE
└── README.md
```

Los helpers `screenshot.sh` y `obs-toggle.sh` no están como archivos sueltos:
`install.sh` los genera directamente en `~/.local/bin`.

## Pruebas

`tests/container/` contiene un contenedor Arch Linux para verificar el rice sin
necesitar una sesión gráfica: valida sintaxis, JSON, despliegue/desinstalación
y los nombres de paquetes contra los repos reales. Ver
[`tests/container/README.md`](tests/container/README.md).

## Troubleshooting

| Síntoma | Solución |
|---|---|
| `bash: $'\r': command not found` | Estás en Windows con `core.autocrlf=true`. Usa `.gitattributes` (incluido) o ejecuta `dos2unix install.sh uninstall.sh`. |
| `pacman not found` | No estás en Arch. Este rice es Arch-only por diseño. |
| Falló un paquete AUR | Reintenta `yay -S <pkg>` y vuelve a ejecutar `./install.sh` (usa `--needed`). |
| Sin audio | `wpctl status`, `systemctl --user restart pipewire pipewire-pulse wireplumber`. |
| Sin applet de red / diálogo polkit | Comprueba `exec-once` de polkit-gnome en `hyprland.conf` y `systemctl status NetworkManager bluetooth`. |
| Fuentes con cuadros | `fc-cache -fv` y `fc-list | grep -i nerd`. |
| Pantalla negra tras login | Entra por TTY y ejecuta `Hyprland` para ver logs; revisa `~/.config/hypr/hyprland.conf`. |
| El lock sale en otro monitor | El `hyprlock.conf` usa `monitor =` vacío (todos los monitores); no hardcodees `eDP-1`. |

## Contributing

Fork, rama, commit, push y PR. Respeta las reglas de oro: Wayland-only,
Gruvbox Dark, Arch-only y rápido.

## License

MIT — ver `LICENSE`. Úsalo como quieras.

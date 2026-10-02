# archrice — Gruvbox Hyprland Daily Driver (Arch Linux, Wayland-only)

A minimal, fast and aesthetically consistent Hyprland setup for Arch Linux.
Strictly Wayland-native, exclusively Gruvbox Dark, tuned for smooth performance.

## Golden rules

1. **Wayland only.** No X11 tools (no picom, xrandr, feh, maim, xclip, non-Wayland rofi).
2. **Gruvbox Dark everywhere.** Bar, launcher, terminal, notifications, SDDM, GTK — one palette.
3. **Performance first.** Lightweight `bezier` animations, no exaggerated bounce, no heavy blur.
4. **Arch Linux only.** `pacman` + `yay`/`paru`. No Debian/Kali/apt code paths.

### Gruvbox Dark reference palette

| Name | Hex |
|---|---|
| bg / bg_h / bg1 / bg2 | `#282828` / `#1d2021` / `#3c3836` / `#504945` |
| fg / gray | `#ebdbb2` / `#a89984` |
| red / green / yellow | `#cc241d` / `#98971a` / `#d79921` |
| blue / purple / aqua / orange | `#458588` / `#b16286` / `#689d6a` / `#d65d0e` |

## Stack

| Component | Choice |
|---|---|
| Compositor | Hyprland + `xdg-desktop-portal-hyprland/gtk`, `swww`, `hyprlock`, `hypridle` |
| Display manager | SDDM + sugar-candy theme adapted to Gruvbox |
| Bar | Waybar (minimal, essential info only) |
| Launcher | wofi + rofi-wayland (both Wayland-native) |
| Terminal | kitty (binary) · shell `bash` + `starship` (configs in your other repo) |
| Notifications | swaync + libnotify |
| Audio | PipeWire + WirePlumber (`wpctl`) + pavucontrol + pamixer + playerctl |
| Network / Bluetooth | NetworkManager + nm-applet + blueman + bluez |
| Screenshots | grim + slurp + wl-clipboard + cliphist + swappy (+ `grimblast`) |
| Screen recording | OBS Studio (+ `wl-screenrec` for quick CLI captures) |
| File managers | Thunar (+ gvfs/tumbler) and yazi (terminal) |
| Auth agent | polkit-gnome + gnome-keyring (required for nm-applet/blueman) |
| Brightness | brightnessctl |
| Fonts / icons / cursor | JetBrainsMono Nerd + Noto (+emoji) · Gruvbox-Material-Dark icons · Bibata cursor |
| GTK / icons (AUR) | gruvbox-material-gtk-theme, gruvbox-material-icon-theme |

## Requirements

- Arch Linux (or Arch-based distro with `pacman`) installed.
- A non-root user with `sudo` access.
- Internet connection.

## Quick start

```bash
git clone https://github.com/mauruxu01/archriced.git
cd archriced
chmod +x install.sh
./install.sh
reboot
```

### What `install.sh` does (Phase 1)

1. Full system upgrade (`pacman -Syu`).
2. Installs `yay` if no AUR helper (`yay`/`paru`) is present.
3. Installs all official packages (`pacman -S --needed`, ~90 packages, all Wayland-native).
4. Installs AUR packages: sugar-candy SDDM theme, Gruvbox GTK/icon themes, `grimblast`, `hyprpicker`, `wlogout`.
5. Enables services: `NetworkManager`, `bluetooth`, `sddm` (system) and `pipewire`/`wireplumber` (user).
6. Creates base dirs (`~/.config`, `~/Pictures/Wallpapers`, `~/.local/bin`), refreshes font cache (shell untouched: bash lives in your other repo), then prints a verification checklist.

Verify after install:

```bash
Hyprland --version; waybar --version; wofi --version; wpctl status
systemctl status NetworkManager bluetooth sddm
```

## Uninstall

```bash
chmod +x uninstall.sh
./uninstall.sh
# type SI to confirm when asked
```

It creates a timestamped backup (`~/.archriced-backup-*`), removes packages and configs, cleans SDDM/GRUB hooks, restores basic shell configs, and verifies the removal. Re-install anytime with `./install.sh`.

## Roadmap

- [x] Phase 1 — `install.sh`: all dependencies (Arch-only, Wayland-only, Gruvbox).
- [ ] Phase 2 — `hyprland.conf` (smooth basic animations, full SUPER keybinds) + Waybar Gruvbox config.
- [ ] Phase 3 — swaync + wofi/rofi-wayland in exact Gruvbox (kitty/starship/bash configs live in your other repo).
- [ ] Phase 4 — screenshot/OBS helper scripts in `~/.local/bin`, SDDM sugar-candy adapted to Gruvbox.
- [ ] Phase 5 — polkit agent autostart + minimal Gruvbox wallpaper.

## Project structure

```text
.
├── install.sh      # sole installer (Arch-only, Wayland-only, Gruvbox)
├── uninstall.sh    # sole uninstaller with automatic backup
├── dotfiles/       # per-app configs (hypr, waybar, wofi, kitty, swaync, sddm, ...)
├── LICENSE
└── README.md       # this file (single source of documentation)
```

Utility scripts are gone from the repo: `install.sh` generates `screenshot.sh` +
`obs-toggle.sh` directly into `~/.local/bin` during deploy. No separate scripts folder.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `pacman not found` | You are not on Arch. This rice is Arch-only by design. |
| AUR package fails | Re-run: `yay -S <pkg>`, then re-run `./install.sh` (it uses `--needed`, safe to repeat). |
| No audio | `wpctl status`, `systemctl --user restart pipewire pipewire-pulse wireplumber`. |
| No network applet / BT permission popup | Ensure `polkit-gnome` autostart (Phase 5) and `systemctl enable NetworkManager bluetooth`. |
| Fonts show boxes | `fc-cache -fv`, then `fc-list \| grep -i nerd`. |
| Black screen after login | `Hyprland` from TTY to see logs; check `~/.config/hypr/hyprland.conf` (Phase 2). |

## Contributing

Fork, branch, commit, push, open a PR. Keep the golden rules: Wayland-only, Gruvbox Dark, Arch-only, fast.

## License

MIT — see `LICENSE`. Use it however you want.

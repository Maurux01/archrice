# 🚀 Arch Dots - Complete Hyprland Configuration

A complete and modern Hyprland configuration for Arch Linux with dynamic login system, development tools, gaming optimization, and comprehensive multimedia support.

## ✨ Features

### 🖥️ **Desktop Environment**
- **Hyprland** - Modern and fast Wayland compositor
- **Dynamic login** - Lock screen theme that adapts to your wallpaper
- **EWW widgets** - Customizable desktop widgets with weather, music, battery
- **Waybar** - Minimalist status bar with system monitoring
- **Kitty** - GPU-accelerated terminal with image support
- **Fish Shell** - Interactive shell with autocompletion and modern tools
- **Hyperlock** - Native Hyprland screen locker with dynamic themes

### 🎨 **Themes & Appearance**
- **Dynamic wallpaper system** - Automatic wallpaper rotation and analysis
- **Multiple Neovim themes** - Tokyo Night, Catppuccin, Gruvbox, Dracula, Habamax
- **Custom fonts** - Nerd Fonts Adwaita Mono throughout the system
- **Icon themes** - Papirus icon theme with Bibata cursor
- **Color schemes** - Consistent theming across all applications

### 💻 **Development Environment**
- **Neovim** - Fully configured editor with LSP, and plugins for fullstack
- **Multiple languages** - Node.js, Python, Rust, Go, Java, C/C++
- **Docker support** - Docker, Docker Compose, Podman, Buildah
- **Git tools** - LazyGit, Git signs, blame, conflict resolution
- **Terminal tools** - fzf, zoxide, atuin, bat, fd, ripgrep, btop

### 🎮 **Gaming & Multimedia**
- **Gaming tools** - Steam, Lutris, Wine, GameMode, MangoHud
- **Multimedia** - MPV, VLC, Spotify, Discord, Telegram
- **Content creation** - LMMS, Pixelorama, Upscayl, OBS Studio
- **Image editing** - GIMP, Krita, Inkscape with SVG support

### 🔒 **Security & System**
- **Firewall** - UFW with automatic configuration
- **VPN support** - WireGuard, OpenVPN, PPTP, L2TP
- **Security tools** - Fail2ban, ClamAV, rkhunter
- **Network tools** - NetworkManager, nmap, Wireshark

## 📦 Installation

### Quick Install

1. **Clone the repository:**
   ```sh
   git clone https://github.com/mauruxu01/archriced.git
   cd archriced
   ```

2. **Give execution permissions:**
   ```sh
   chmod +x install.sh
   ```

3. **Run the unified installer:**
   ```sh
   ./install.sh
   ```

The unified installation script includes:
- ✅ Updates the system and installs AUR helper (yay)
- ✅ Installs all dependencies (core + AUR packages)
- ✅ Configures Hyprland and all components
- ✅ Installs development tools and languages
- ✅ Configures Neovim with all plugins and themes
- ✅ Installs multimedia tools (Spotify, Discord, etc.)
- ✅ Configures Fish shell with modern tools
- ✅ Installs fonts and themes
- ✅ Configures Hyperlock with dynamic themes
- ✅ Sets up security tools and firewall
- ✅ Copies all dotfiles to correct system locations

## 🗑️ Uninstallation

### Complete Uninstallation

```bash
# Uninstall everything with backup
./uninstall.sh
```

The unified uninstallation script:
- ✅ Creates a complete backup of your current setup
- ✅ Uninstalls all packages (core + AUR)
- ✅ Removes all configurations
- ✅ Restores default system configurations
- ✅ Cleans the system completely

## 🔧 Maintenance & Repair

### System Repair

```bash
# Full system repair and maintenance
./repair.sh

# Only diagnose problems
./repair.sh --diagnose

# Only repair found issues
./repair.sh --repair

# Only clean system
./repair.sh --clean

# Only update system and dotfiles
./repair.sh --update

# Show system information
./repair.sh --info
```

The unified repair script includes:
- ✅ **Diagnosis** - Detects missing packages, configs, and permissions
- ✅ **Package Repair** - Fixes broken packages and AUR
- ✅ **Config Repair** - Restores missing configurations
- ✅ **Font Repair** - Reinstalls custom fonts
- ✅ **Permission Repair** - Fixes file permissions
- ✅ **System Cleaning** - Cleans cache and temporary files
- ✅ **Neovim Cleaning** - Cleans and reinstalls Neovim plugins
- ✅ **System Updates** - Updates system and dotfiles

## 🎨 Dynamic Login System

The dynamic login system automatically analyzes your wallpaper and generates a lock screen theme that adapts to the dominant colors.

### Features:
- **Wallpaper analysis** - Extracts dominant colors automatically
- **Theme generation** - Creates swaylock themes dynamically
- **Automatic rotation** - Changes wallpapers automatically
- **Control widget** - EWW widget to manage wallpapers

### Commands:
```bash
# Lock screen with dynamic theme
./utils.sh lock

# Change wallpaper manually
./utils.sh wallpaper

# Start automatic rotation daemon
./utils.sh wallpaper-daemon

# Analyze current wallpaper
./utils.sh analyze-wallpaper
```

## 🖥️ Neovim Configuration

### ✨ Features
- **Modern UI** - Clean interface with statusline and notifications
- **Theme Switching** - 5 themes with easy switching
- **LSP Support** - Full language server protocol support
- **AI Assistants** - Codeium, Tabnine, ChatGPT.nvim
- **Git Integration** - LazyGit, Git signs, blame, conflict resolution
- **Docker Integration** - LazyDocker for container management
- **Web Development** - Specialized tools for HTML, CSS, JavaScript, TypeScript
- **Image Support** - View images and SVG directly in Neovim

### 🎨 Themes
- Tokyo Night (default)
- Catppuccin
- Gruvbox
- Dracula
- Habamax

### ⌨️ Key Bindings

#### **Navigation & File Management**
- `<leader>ff` - Find files (Telescope)
- `<leader>fg` - Live grep
- `<leader>e` - Oil explorer
- `<C-l/h>` - Next/Previous buffer
- `<leader>1-9` - Go to buffer 1-9

#### **LSP & Development**
- `gd` - Go to definition
- `gr` - References
- `K` - Hover
- `<leader>ca` - Code actions
- `<leader>rn` - Rename
- `<leader>f` - Format

#### **AI Assistants**
- `<Tab>` - Accept AI suggestion
- `<C-]>` - Dismiss suggestion
- `<leader>ai` - Open ChatGPT
- `<leader>ae` - Edit with ChatGPT
- `<leader>at` - Explain code
- `<leader>af` - Fix bug

#### **Git & Docker**
- `<leader>gg` - Open LazyGit
- `<leader>dd` - Open LazyDocker
- `]c/[c` - Next/Previous Git hunk
- `<leader>tb` - Toggle Git blame

#### **Theme Controls**
- `<leader>ut` - Toggle theme
- `<leader>uN` - Next theme
- `<leader>up` - Previous theme
- `<leader>u1-5` - Quick theme selection

## 🐟 Fish Shell Configuration

### 🌟 Features
- **Oh My Fish** with **bobthefish** theme
- **Modern tools** - fzf, zoxide, atuin, bat, fd, ripgrep, btop
- **Git integration** - Enhanced Git commands and aliases
- **Development support** - Node.js, Python, Rust, Go, Java
- **Useful aliases** - Shortcuts for common commands

### 🚀 Modern Tools Included
- **fzf** - Intelligent fuzzy search
- **zoxide** - Smart directory navigation
- **atuin** - Enhanced history with search
- **bat** - Cat with syntax highlighting
- **fd** - Modern and fast find
- **btop** - Modern system monitor
- **yazi** - Terminal file manager
- **lazygit** - Incredible Git TUI

### 💻 Useful Aliases
```bash
# Git shortcuts
gs    # git status
ga    # git add
gc    # git commit
gp    # git push
gl    # git pull
gco   # git checkout
gcb   # git checkout -b

# System shortcuts
ll    # ls -la
la    # ls -A
..    # cd ..
...   # cd ../..
....  # cd ../../..

# Development shortcuts
nv    # neovim
lg    # lazygit
cat   # bat
find  # fd
grep  # rg
top   # btop
```

## 🎮 Gaming Features

### Gaming Tools
- **Steam** - Game distribution platform
- **Lutris** - Game manager and launcher
- **Wine** - Windows compatibility layer
- **GameMode** - Performance optimization
- **MangoHud** - Performance overlay
- **Heroic Games Launcher** - Epic Games launcher

### Gaming Configuration
```bash
# Enable GameMode for a game
gamemoderun ./game

# Check GameMode status
gamemoded -t

# Configure MangoHud
nano ~/.config/MangoHud/MangoHud.conf
```

## 🛠️ Utility Scripts

### `utils.sh` - Main Utility Script
```bash
# See all options
./utils.sh

# Wallpaper management
./utils.sh wallpaper [command]
./utils.sh wallpaper-daemon [start|stop|status]

# Screen lock
./utils.sh lock

# System maintenance
./utils.sh maintenance

# System information
./utils.sh info

# Wallpaper analysis
./utils.sh analyze-wallpaper [path]
```

### Enhanced Notifications
Notification system with animations, colors and intelligent handling:

```bash
# Test volume notifications
~/.config/scripts/notification-enhancer.sh volume 75 false

# Test brightness notifications
~/.config/scripts/notification-enhancer.sh brightness 60

# Test music notifications
~/.config/notification-enhancer.sh music "Song Title" "Artist" play

# Test system notifications
~/.config/scripts/notification-enhancer.sh system "Test message" normal
```

**Features:**
- **Colors by application** - Discord (blue), Spotify (green), Firefox (orange)
- **Visual progress bars** - For volume and brightness
- **Multiple notification handling** - Intelligent queue
- **Smooth animations** - Fluid transitions
- **Specific icons** - By application type

### Clipboard and History
Complete clipboard system with history:

```bash
# Open CopyQ history
SUPER + V

# Open cliphist history
SUPER + SHIFT + V

# Alternative for cliphist
SUPER + CTRL + V

# Screenshot to clipboard
```

## 🎨 EWW Widgets

### Available Widgets
- **Clock** - Current time and date
- **Battery** - Battery status and percentage
- **Volume** - Audio volume control
- **Weather** - Current weather information
- **Music** - Music player controls
- **Notifications** - System notifications
- **Calendar** - Calendar widget
- **ASCII Art** - Custom ASCII art display

### Widget Controls
```bash
# Restart EWW
eww kill && eww daemon && eww open bar

# Reload widgets
eww reload

# Check EWW status
eww daemon --status
```

## 🔒 Security Features

### Firewall & Network
- **UFW** - Uncomplicated Firewall with automatic configuration
- **WireGuard** - Modern VPN protocol
- **OpenVPN** - Traditional VPN support
- **NetworkManager** - Network management with GUI

### Security Tools
- **Fail2ban** - Intrusion prevention
- **ClamAV** - Antivirus scanning
- **rkhunter** - Rootkit detection
- **nmap** - Network scanning
- **Wireshark** - Network analysis

### Security Commands
```bash
# Check firewall status
sudo ufw status

# Enable/disable firewall
sudo ufw enable
sudo ufw disable

# Scan for rootkits
sudo rkhunter --check

# Update virus definitions
sudo freshclam
```

## 🎵 Multimedia Support

### Audio & Video
- **MPV** - Lightweight video player
- **VLC** - Full-featured media player
- **Spotify** - Music streaming
- **Cava** - Audio visualizer
- **OSS** - Open Sound System

### Content Creation
- **LMMS** - Digital audio workstation
- **Pixelorama** - Pixel art editor
- **Upscayl** - AI image upscaling
- **OBS Studio** - Screen recording and streaming
- **GIMP** - Image editing
- **Krita** - Digital painting
- **Inkscape** - Vector graphics

### Image Support
- **Neovim** - View images directly in editor
- **Kitty** - Display images in terminal
- **SWWW** - Wallpaper management
- **ImageMagick** - Image processing tools

## 🚀 Development Tools

### Languages & Runtimes
- **Node.js** - JavaScript runtime
- **Python** - Python with pip and virtualenv
- **Rust** - Rust programming language
- **Go** - Go programming language
- **Java** - OpenJDK
- **C/C++** - GCC, CMake, Ninja, Meson

### Development Tools
- **Docker** - Container platform
- **Git** - Version control with enhanced tools
- **LazyGit** - Git TUI
- **LazyDocker** - Docker TUI
- **Valgrind** - Memory debugging
- **GDB** - GNU debugger

### IDE Features
- **LSP Support** - Language Server Protocol
- **Code completion** - AI-powered suggestions
- **Debugging** - Integrated debugging
- **Testing** - Test runners and frameworks
- **Formatting** - Code formatting and linting

## 📱 Applications Included

### System Tools
- **Kitty** - GPU-accelerated terminal
- **Fish** - Interactive shell
- **Tmux** - Terminal multiplexer
- **Starship** - Cross-shell prompt
- **Zoxide** - Smart cd replacement

### File Management
- **Nautilus** - GNOME file manager
- **Thunar** - XFCE file manager
- **Yazi** - Terminal file manager
- **Ranger** - Terminal file manager

### Web Browsers
- **Firefox** - Mozilla browser
- **Brave** - Privacy-focused browser

### Office & Productivity
- **LibreOffice** - Office suite
- **Obsidian** - Note-taking app
- **Geany** - Lightweight IDE
- **VS Code** - Code editor

## 🎯 Quick Reference

### Essential Commands
```bash
# System
./install.sh          # Install everything
./uninstall.sh        # Uninstall everything
./repair.sh           # Repair system
./utils.sh            # Utility functions

# Neovim
nvim                  # Open Neovim
nvim --headless       # Headless mode

# Fish Shell
fish                  # Open Fish shell
fish_config           # Configure Fish

# Hyprland
hyprctl               # Hyprland control
hyprctl dispatch      # Send commands

# Lock Screen
hyperlock             # Lock screen
swaylock              # Alternative lock

# Wallpaper
swww img [path]       # Set wallpaper
swww kill             # Kill wallpaper daemon
```

### Key Bindings
```bash
# Hyprland
SUPER + Q             # Close window
SUPER + M             # Maximize window
SUPER + F             # Fullscreen
SUPER + D             # Application launcher
SUPER + R             # Command runner

# Neovim
<leader>ff            # Find files
<leader>gg            # LazyGit
<leader>t             # Terminal
<leader>ut            # Toggle theme

# Fish Shell
Ctrl + R              # Search history
Ctrl + F              # Fuzzy finder
Alt + C               # Change directory
```

## 🔧 Troubleshooting

### Common Issues

#### **Neovim Issues**
```bash
# Check Neovim plugins
nvim --headless -c "Lazy! sync" -c "qa"

# Reset Neovim
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim

# Check LSP
nvim --headless -c "LspInfo" -c "qa"
```

#### **Hyprland Issues**
```bash
# Check Hyprland logs
journalctl --user -u hyprland

# Reset Hyprland config
cp ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland.conf.backup

# Check Wayland session
echo $XDG_SESSION_TYPE
```

#### **Font Issues**
```bash
# Refresh font cache
fc-cache -fv

# Check font installation
fc-list | grep -i "nerd"

# Reinstall fonts
sudo pacman -S nerd-fonts-complete
```

#### **Audio Issues**
```bash
# Check audio devices
pactl list short sinks
pactl list short sources

# Restart PulseAudio
pulseaudio --kill
pulseaudio --start

# Check ALSA
alsamixer
```

### Diagnostic Commands
```bash
# System information
./repair.sh --info

# Check missing packages
./repair.sh --diagnose

# Verify installation
./repair.sh --verify

# Check permissions
./repair.sh --permissions
```

## 📚 Additional Resources

### Documentation
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Neovim Documentation](https://neovim.io/doc/)
- [Fish Shell Documentation](https://fishshell.com/docs/)
- [Arch Linux Wiki](https://wiki.archlinux.org/)

### Useful Links
- [Nerd Fonts](https://www.nerdfonts.com/)
- [LazyVim](https://www.lazyvim.org/)
- [Oh My Fish](https://github.com/oh-my-fish/oh-my-fish)
- [EWW Widgets](https://elkowar.github.io/eww/)

## 🤝 Contributing

Contributions are welcome! If you have ideas to improve the configuration:

1. Fork the repository
2. Create a branch for your feature
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 License

MIT License - Use this configuration however you want!

---

**Enjoy your complete Arch Linux setup! 🚀✨** 

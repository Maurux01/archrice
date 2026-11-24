# Contenedor de prueba

`smoke-test.sh` ejecuta `install.sh` y `uninstall.sh` dentro de un **Arch Linux
real**, con `pacman`/`sudo`/`systemctl` interpolados para no descargar los ~84
paquetes. Verifica sintaxis bash, JSON, despliegue de configs/helpers/wallpaper
y limpieza con backup.

## Con Docker

Desde la raíz del repo:

```bash
docker build -t archrice-test -f tests/container/Dockerfile .
docker run --rm archrice-test
```

Debe terminar con `TODO OK ✅ — prueba ejecutada dentro de un contenedor Arch Linux`.

Además, `check-packages.sh` valida los 76 paquetes oficiales contra los repos
reales de Arch (detecta renombrados como `swww`→`awww` o `rofi-wayland`→`rofi`):

```bash
docker run --rm archrice-test bash -c 'pacman -Sy --noconfirm >/dev/null && bash tests/container/check-packages.sh'
```

## Sin Docker (WSL)

En este entorno no hay Docker ni privilegios para instalarlo, pero el mismo
contenedor se puede importar como distro WSL desde una imagen LXC de Arch:

```powershell
curl.exe -L -o $env:TEMP\arch-rootfs.tar.xz `
  https://images.linuxcontainers.org/images/archlinux/current/amd64/default/20261118_04:18/rootfs.tar.xz
wsl --import archrice-test C:\WSL\archrice-test $env:TEMP\arch-rootfs.tar.xz
wsl -d archrice-test -- bash -c 'useradd -m -s /bin/bash tester'
wsl -d archrice-test -u tester -- bash /archrice/tests/container/smoke-test.sh
```

> Una sesión gráfica real de Hyprland no se puede probar en un contenedor
> (necesita DRM/Wayland/logind de un sistema anfitrión). Esta prueba cubre
> instalación, despliegue y desinstalación.

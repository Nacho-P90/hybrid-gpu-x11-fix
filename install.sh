#!/usr/bin/env bash
set -euo pipefail

# Files expected in same folder:
#  - 10-monitor.conf
#  - 10-nvidia-primary.conf
#  - hybridGPU-toggle
#  - set-refresh.service

SCRIPT_DIR="$(dirname "$0")"
USR_HOME="${SUDO_USER:-$USER}"
USR_HOME_DIR="$(getent passwd "$USR_HOME" | cut -d: -f6)"

echo "[1/7] Checking permissions..."
if [[ $EUID -ne 0 ]]; then
	echo "ERR: Need to run as sudo"
	exit 1
fi

echo "This script will copy ~16 KiB of files into system folders:"
echo "  /etc/X11/xorg.conf.d/"
echo "  /usr/local/bin/"
echo "This script will sync packages:"
echo "  xorg-server"
echo "  xorg-xrandr"
read -p "Proceed with installation? (y/n): " ans
[[ $ans == y* ]] || { echo "Abort"; exit 1; }

echo "[2/7] Installing dependencies (Arch-based)..."
if command -v pacman &>/dev/null; then
	pacman -Sy --noconfirm xorg-server xorg-xrandr || true
else
	echo "Skipping dep install (not pacman system)"
fi

echo "[3/7] Creating ~/.igpud for user: $USR_HOME"
mkdir -p "$USR_HOME_DIR/.igpud"
chown "$USR_HOME":"$USR_HOME" "$USR_HOME_DIR/.igpud"

echo "[4/7] Copying Xorg config files..."
/usr/bin/install -m 644 "$SCRIPT_DIR/10-monitor.conf" /etc/X11/xorg.conf.d/
/usr/bin/install -m 644 "$SCRIPT_DIR/10-nvidia-primary.conf" /etc/X11/xorg.conf.d/

echo "[5/7] Installing hybridGPU-toggle..."
/usr/bin/install -m 755 "$SCRIPT_DIR/hybridGPU-toggle" /usr/local/bin/

echo "[6/7] Installing set-refresh.service..."
cp "$SCRIPT_DIR/set-refresh.service" "$USR_HOME_DIR/.config/systemd/user/set-refresh.service"

echo "[7/7] Reloading systemd..."
systemctl daemon-reload

echo
echo "==============================================================="
echo " OPTIONAL STEP: enable user refresh service"
echo " Run to install it for the current user:"
echo
echo "   systemctl --user enable set-refresh.service"
echo "   (In the service file make sure --output --mode --rate"
echo "   match your setup, you can check by using xrandr"
echo "==============================================================="

echo "Install complete!"
echo "Reboot to apply changes then run hybridGPU"

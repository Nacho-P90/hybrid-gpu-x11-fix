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

echo "[1/6] Checking permissions..."
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
read -p "Proceed with install? (y/n): " ans
[[ $ans == y* ]] || { echo "Abort"; exit 1; }

echo "[2/6] Installing dependencies (Arch-based)..."
if command -v pacman &>/dev/null; then
	pacman -Sy --noconfirm xorg-server xorg-xrandr || true
else
	echo "Skipping dep install (not pacman system)"
fi

echo "[3/6] Creating ~/.igpud for user: $USR_HOME"
mkdir -p "$USR_HOME_DIR/.igpud"
chown "$USR_HOME":"$USR_HOME" "$USR_HOME_DIR/.igpud"

echo "[4/6] Copying Xorg config files..."
/usr/bin/install -m 644 "$SCRIPT_DIR/10-monitor.conf" /etc/X11/xorg.conf.d/
/usr/bin/install -m 644 "$SCRIPT_DIR/10-nvidia-primary.conf" /etc/X11/xorg.conf.d/

echo "[5/6] Installing hybridGPU-toggle..."
/usr/bin/install -m 755 "$SCRIPT_DIR/hybridGPU-toggle" /usr/local/bin/

echo "[6/6] Reloading systemd..."
systemctl daemon-reload

echo
echo "==============================================================="
echo " OPTIONAL STEP: enable user refresh service"
echo " Run to install it for the current user:"
echo
echo "   systemctl --user daemon-reload"
echo "   systemctl --user enable set-refresh.service"
echo "==============================================================="

echo "Install complete!"
echo "Reboot to apply changes then run hybridGPU"

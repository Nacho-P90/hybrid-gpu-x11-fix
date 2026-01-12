#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Checking permissions..."
if [[ $EUID -ne 0 ]]; then
	echo "ERR: Need to run as sudo"
	exit 1
fi

read -p "This will remove all installed hybrid GPU config files. Continue? (y/N) " ans
[[ $ans == y* ]] || { echo "Abort"; exit 1; }

echo "[2/5] Removing Xorg configuration files..."
rm -f /etc/X11/xorg.conf.d/10-monitor.conf
rm -f /etc/X11/xorg.conf.d/10-nvidia-primary.conf

echo "[3/5] Removing hybridGPU-toggle script..."
rm -f /usr/local/bin/hybridGPU-toggle

echo "[4/5] Reloading systemd..."
systemctl daemon-reload || true

echo "[5/5] Removing config folder..."
rm -rf ~/.igpud/

echo 
echo "================================================================"
echo "OPTIONAL STEPS: remove system service:"
echo "Run to remove for the current user:"
echo
echo "        systemctl --user disable set-refresh.service"
echo "        rm -f ~/.config/systemd/user/set-refresh.service"
echo "================================================================"
echo
echo "Uninstall complete."
echo "Reboot to restore normal hybrid behavior."

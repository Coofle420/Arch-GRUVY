#!/usr/bin/env bash
# Fix niri not starting (seatd vs logind) and switch LightDM → SDDM with a gruvbox look.
# Run as your user:  bash ~/fix-login.sh   then reboot.
set -euo pipefail
c() { printf '\n\033[1;38;2;254;128;25m==> %s\033[0m\n' "$*"; }
[[ $EUID -eq 0 ]] && { echo "Run as your user, not root."; exit 1; }
sudo -v

c "Disabling seatd (it fights logind for the GPU, which stopped niri getting the display)"
sudo systemctl disable seatd.service
# Make sure libseat never picks seatd for display-manager sessions, even if it gets re-enabled.
sudo mkdir -p /etc/environment.d
echo 'LIBSEAT_BACKEND=logind' | sudo tee /etc/environment.d/90-libseat-logind.conf >/dev/null

c "Installing SDDM"
sudo pacman -S --needed --noconfirm sddm qt6-svg qt6-declarative

c "Switching display manager: LightDM → SDDM"
sudo systemctl disable lightdm.service
sudo systemctl enable sddm.service

c "Gruvbox SDDM theme"
sudo install -Dm644 "$HOME/Pictures/Wallpapers/gruvbox.png" /usr/share/backgrounds/gruvbox.png
sudo mkdir -p /etc/sddm.conf.d
sudo tee /etc/sddm.conf.d/10-gaming-niri.conf >/dev/null <<'EOF'
[General]
Numlock=on

[Theme]
Current=breeze
CursorTheme=capitaine-cursors-light
CursorSize=24
Font=Noto Sans,11
EOF
sudo tee /usr/share/sddm/themes/breeze/theme.conf.user >/dev/null <<'EOF'
[General]
type=image
background=/usr/share/backgrounds/gruvbox.png
EOF

# Pre-select niri as the session for the first login (SDDM remembers your choice after that).
sudo mkdir -p /var/lib/sddm
sudo tee /var/lib/sddm/state.conf >/dev/null <<EOF
[Last]
Session=/usr/share/wayland-sessions/niri.desktop
User=$USER
EOF
sudo chown -R sddm:sddm /var/lib/sddm 2>/dev/null || true

c "Done"
systemctl is-enabled sddm seatd lightdm 2>/dev/null | paste -sd' ' | sed 's/^/sddm, seatd, lightdm: /'
echo
echo "  Reboot now:  systemctl reboot"
echo "  At the SDDM screen, check the session (bottom-left) says Niri, then log in."

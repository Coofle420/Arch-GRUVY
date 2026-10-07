#!/usr/bin/env bash
# Gruvbox gaming niri setup — installs packages and themes.
# Configs are already written to ~/.config; this installs what they use.
# Run as your normal user (NOT root):  bash ~/setup-gaming-niri.sh
set -euo pipefail

c() { printf '\n\033[1;38;2;254;128;25m==> %s\033[0m\n' "$*"; }
[[ $EUID -eq 0 ]] && { echo "Run as your user, not root (sudo is used where needed)."; exit 1; }
sudo -v

c "Enabling multilib + pacman eye candy"
sudo sed -i '/^#\[multilib\]/{s/^#//;n;s/^#Include/Include/}' /etc/pacman.conf
grep -q '^ILoveCandy' /etc/pacman.conf || sudo sed -i '/^Color/a ILoveCandy' /etc/pacman.conf
sudo sed -i 's/^#VerbosePkgLists/VerbosePkgLists/; s/^ParallelDownloads = .*/ParallelDownloads = 10/' /etc/pacman.conf
grep -A1 '^\[multilib\]' /etc/pacman.conf

c "Full system update"
sudo pacman -Syu --noconfirm

c "Installing gaming + desktop packages (incl. Noctalia shell)"
# lib32-vulkan-radeon is listed explicitly so pacman never picks an NVIDIA/other Vulkan provider for Steam.
sudo pacman -S --needed --noconfirm \
  base-devel git \
  steam lib32-mesa lib32-vulkan-radeon vulkan-radeon vulkan-tools mesa-utils lib32-pipewire \
  gamescope gamemode lib32-gamemode mangohud lib32-mangohud lact \
  noctalia xwayland-satellite wl-clipboard pavucontrol brightnessctl gnome-keyring \
  ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji ttf-liberation capitaine-cursors \
  starship eza bat btop fastfetch

c "Installing yay"
if ! command -v yay >/dev/null; then
  tmp=$(mktemp -d)
  git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$tmp/yay-bin"
  (cd "$tmp/yay-bin" && makepkg -si --noconfirm)
  rm -rf "$tmp"
fi

c "Installing AUR packages: Helium, gruvbox GTK + icons, ProtonPlus"
yay -S --needed --noconfirm --answerdiff None --answerclean None \
  helium-browser-bin gruvbox-gtk-theme-git gruvbox-plus-icon-theme-git protonplus

c "Applying GTK / dark mode theme"
GTK_THEME=$(find /usr/share/themes -maxdepth 1 -iname 'gruvbox*dark*' -printf '%f\n' | sort | head -1)
GTK_THEME=${GTK_THEME:-Adwaita-dark}
ICONS=$(find /usr/share/icons -maxdepth 1 -iname 'gruvbox-plus-dark' -printf '%f\n' | head -1)
ICONS=${ICONS:-Adwaita}
echo "GTK theme: $GTK_THEME   icons: $ICONS"
sed -i "s/^gtk-theme-name=.*/gtk-theme-name=$GTK_THEME/; s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=$ICONS/" \
  ~/.config/gtk-3.0/settings.ini ~/.config/gtk-4.0/settings.ini

# libadwaita (GTK4) apps ignore gtk-theme-name; link the theme's gtk-4.0 files so they go gruvbox too.
if [[ -d /usr/share/themes/$GTK_THEME/gtk-4.0 ]]; then
  for f in gtk.css gtk-dark.css assets; do
    [[ -e /usr/share/themes/$GTK_THEME/gtk-4.0/$f ]] && ln -sfn "/usr/share/themes/$GTK_THEME/gtk-4.0/$f" ~/.config/gtk-4.0/$f
  done
fi
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface icon-theme "$ICONS"
gsettings set org.gnome.desktop.interface cursor-theme 'capitaine-cursors-light'
gsettings set org.gnome.desktop.interface font-name 'Noto Sans 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'

c "Gaming tweaks"
sudo groupadd -f gamemode
sudo usermod -aG gamemode "$USER"
sudo systemctl enable --now lactd || true
mkdir -p ~/Pictures/Screenshots

c "Default browser → Helium"
xdg-settings set default-web-browser helium.desktop || true
xdg-mime default helium.desktop x-scheme-handler/http x-scheme-handler/https text/html

c "Checking niri config"
niri validate

cat <<'EOF'

  ✔ Done. Log out, choose "niri" on the LightDM login screen, and log in.

  Steam → Settings → Compatibility → enable Steam Play for all titles.
  Per-game launch options (pick one):
     gamemoderun mangohud %command%
     gamescope -W 2560 -H 1440 -r 200 -f --mangoapp -- gamemoderun %command%
  MangoHud toggle in-game: Right Shift + F12
EOF

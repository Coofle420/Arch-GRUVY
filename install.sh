#!/usr/bin/env bash
# Copies these dotfiles into place. Existing files are backed up to ~/.dotfiles-backup-<date>.
# Usage: bash install.sh
set -euo pipefail
cd "$(dirname "$0")"
B=~/.dotfiles-backup-$(date +%Y%m%d-%H%M%S); mkdir -p "$B"
put() { # put <repo file> <destination>
  local src=$1 dst=$2
  mkdir -p "$(dirname "$dst")"
  [[ -e $dst ]] && { mkdir -p "$B/$(dirname "${dst#$HOME/}")"; cp -a "$dst" "$B/${dst#$HOME/}"; }
  if [[ $src == *.png ]]; then cp "$src" "$dst"
  else sed "s|/home/USER|$HOME|g" "$src" > "$dst"; fi
  echo "  ✔ $dst"
}
C=~/.config
put niri/config.kdl               $C/niri/config.kdl
put noctalia/config.toml          $C/noctalia/config.toml
put kitty/kitty.conf              $C/kitty/kitty.conf
put alacritty/alacritty.toml      $C/alacritty/alacritty.toml
put starship/starship.toml        $C/starship.toml
put fastfetch/config.jsonc        $C/fastfetch/config.jsonc
put mangohud/MangoHud.conf        $C/MangoHud/MangoHud.conf
put gtk/settings-gtk3.ini         $C/gtk-3.0/settings.ini
put gtk/settings-gtk4.ini         $C/gtk-4.0/settings.ini
put helium/helium-browser-flags.conf $C/helium-browser-flags.conf
put zsh/zshrc                     ~/.zshrc
put zsh/zshenv                    ~/.zshenv
put wallpapers/gruvbox.png        ~/Pictures/Wallpapers/gruvbox.png
put wallpapers/gruvbox.svg        ~/Pictures/Wallpapers/gruvbox.svg
echo; echo "Backups of anything replaced: $B"
echo "Packages / system setup: scripts/setup-gaming-niri.sh, scripts/setup-zsh.sh, scripts/fix-login.sh"

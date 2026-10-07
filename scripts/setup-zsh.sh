#!/usr/bin/env bash
# Install zsh + plugins and make it your login shell.  Run: bash ~/setup-zsh.sh
set -euo pipefail
[[ $EUID -eq 0 ]] && { echo "Run as your user, not root."; exit 1; }
sudo pacman -S --needed --noconfirm zsh zsh-completions zsh-autosuggestions \
  zsh-syntax-highlighting zsh-history-substring-search fzf zoxide lm_sensors
echo; echo "Changing login shell to zsh (asks for your password)…"
chsh -s /usr/bin/zsh
zsh -n ~/.zshrc && echo "✔ ~/.zshrc syntax OK"
echo "✔ Done — close and reopen kitty (log out/in so every app picks up zsh)."

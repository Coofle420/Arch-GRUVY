# gruvbox gaming niri

A dark **gruvbox** [niri](https://github.com/YaLTeR/niri) desktop for gaming on Arch / CachyOS:
high refresh rate on every monitor, [Noctalia](https://noctalia.dev) shell, kitty + zsh + starship, Steam with multilib.

- **Compositor:** niri — 2560×1440 @ 200 Hz + 1080p @ 144 Hz, workspaces 1–5 on monitor 1, 6–10 on monitor 2
- **Shell:** Noctalia (bar, dock, launcher, notifications, lock screen) in gruvbox, all-orange widgets
- **Terminal:** kitty (also Alacritty), starship two-line prompt, zsh with autosuggestions / syntax highlighting / fzf / zoxide
- **Gaming:** Steam, gamescope, gamemode, MangoHud, LACT, ProtonPlus, `LIBSEAT_BACKEND=logind`
- **Browser:** [Helium](https://github.com/imputnet/helium-linux), native Wayland + dark mode

## Install

```bash
git clone <this repo> ~/dotfiles && cd ~/dotfiles
bash scripts/setup-gaming-niri.sh   # multilib, Steam, yay, Noctalia, themes
bash scripts/setup-zsh.sh           # zsh + plugins, sets login shell
bash install.sh                     # copy configs into place (backs up what it replaces)
```

`/home/USER` in the configs is replaced with your home directory by `install.sh`.

## Make it yours

- **Monitors:** run `niri msg outputs`, then edit the `output "..."` blocks in `niri/config.kdl` (connector name, mode, position).
- **Keybinds:** `Super+Shift+/` shows them in niri. `Super+[` / `Super+]` shrink / grow a window.
- **Noctalia:** edit `noctalia/config.toml`. Changes made in its settings window are saved separately and override the file — see `~/.local/state/noctalia/settings.toml`.

## Notes

- Tested on CachyOS with an AMD RX 7800 XT. `scripts/fix-login.sh` disables `seatd` (it fought logind for the GPU) and switches the display manager to SDDM.
- Review scripts before running them — they use `sudo`.

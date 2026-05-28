# dotfiles

Portable dev environment: zsh + tmux + neovim + tmux-sessionizer.
Works on any Arch-family box (Arch, CachyOS, EndeavourOS, …). No desktop
assumptions — clone this on servers, work laptops, and headless boxes too.

For the desktop side (Hyprland, Quickshell, kitty, alacritty, GTK theming),
see [`dotfiles-desktop`](https://github.com/Asteromorph/dotfiles-desktop).

## Quick install

```bash
git clone https://github.com/Asteromorph/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` is idempotent — safe to re-run.

## Modules

| Module  | Target                                  | Purpose                              |
|---------|-----------------------------------------|--------------------------------------|
| `shell` | `~/.zshrc`, `~/.zsh_profile`, `~/.gitconfig` | zsh + oh-my-zsh + git config (identity-stripped) |
| `tmux`  | `~/.tmux.conf`                          | tmux config (`C-a` prefix, vi mode)  |
| `bin`   | `~/.local/bin/tmux-sessionizer`         | ThePrimeagen-style project switcher  |
| `nvim`  | `~/.config/nvim/`                       | kickstart.nvim-based single-file config |

## Per-machine customization

- **Git identity** lives in `~/.gitconfig.local` (gitignored). `install.sh`
  prompts for `user.name` / `user.email` on first run; `shell/.gitconfig`
  includes it via `[include] path = ~/.gitconfig.local`.
- **Secrets / per-machine env exports** go into any file under
  `~/.config/personal/env/`. `~/.zsh_profile` auto-sources every file in
  that directory on shell start.
- **NPM rc swaps**: the `goWork` / `goPersonal` functions in `~/.zsh_profile`
  swap `~/.npm_work_rc` ↔ `~/.npm_personal_rc` into `~/.npmrc`. Drop those
  two files in `$HOME` yourself per-machine.

## Manual stow

If you'd rather skip `install.sh` and run things by hand:

```bash
cd ~/dotfiles
stow -t ~ shell tmux bin nvim
```

`-D` to unstow, `-R` to re-stow.

## Bootstrap order on a fresh machine

1. **This repo first** (`dotfiles`) — gives you a working shell + editor.
2. **Then `dotfiles-desktop`** (only on graphical workstations) — Hyprland rice.

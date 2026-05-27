#!/usr/bin/env bash
# ~/dotfiles/install.sh — portable dev environment bootstrap
#
# Idempotent: safe to re-run on the same machine.
# Pairs with: ~/dotfiles-desktop/install.sh (the Hyprland rice).

set -euo pipefail

# ── logging ──────────────────────────────────────────────────────────────
RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; BLUE=$'\033[34m'; RESET=$'\033[0m'
step() { printf '\n%s▶ %s%s\n' "$BLUE" "$1" "$RESET"; }
ok()   { printf '%s✓ %s%s\n'   "$GREEN" "$1" "$RESET"; }
warn() { printf '%s! %s%s\n'   "$YELLOW" "$1" "$RESET"; }
die()  { printf '%s✗ %s%s\n'   "$RED" "$1" "$RESET" >&2; exit 1; }

# ── 1. preflight ─────────────────────────────────────────────────────────
step "preflight"
[[ $(id -u) -ne 0 ]] || die "run as your user, not root"
command -v pacman >/dev/null || die "requires an Arch-family distro (pacman not found)"
REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
[[ -d "$REPO_DIR/shell" && -d "$REPO_DIR/nvim" ]] || die "run this from inside the dotfiles repo (REPO_DIR=$REPO_DIR)"
cd "$REPO_DIR"
ok "running from $REPO_DIR"

# ── 2. back up pre-existing real files stow would refuse to overwrite ────
step "back up any conflicting real files"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date -u +%Y%m%dT%H%M%SZ)"
backed_up=0
backup_if_real() {
    local target=$1
    if [[ -e $target && ! -L $target ]]; then
        mkdir -p "$BACKUP_DIR/$(dirname "${target#$HOME/}")"
        mv "$target" "$BACKUP_DIR/${target#$HOME/}"
        backed_up=1
        warn "backed up $target → $BACKUP_DIR/${target#$HOME/}"
    fi
}
backup_if_real "$HOME/.zshrc"
backup_if_real "$HOME/.zsh_profile"
backup_if_real "$HOME/.gitconfig"
backup_if_real "$HOME/.tmux.conf"
backup_if_real "$HOME/.local/bin/tmux-sessionizer"
backup_if_real "$HOME/.config/nvim"
[[ $backed_up -eq 0 ]] && ok "nothing to back up"

# ── 3. base packages (pacman) ────────────────────────────────────────────
step "installing pacman packages"
sudo pacman -S --needed --noconfirm \
    zsh tmux neovim git stow gh \
    fzf ripgrep fd gcc make curl base-devel

# ── 4. oh-my-zsh ─────────────────────────────────────────────────────────
step "oh-my-zsh"
if [[ -d $HOME/.oh-my-zsh ]]; then
    ok "already installed"
else
    # --keep-zshrc: don't overwrite the .zshrc that stow will install in step 8
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
    ok "installed"
fi

# ── 5. nvm ───────────────────────────────────────────────────────────────
step "nvm"
if [[ -d $HOME/.nvm ]]; then
    ok "already installed"
else
    # PROFILE=/dev/null keeps the installer from editing .zshrc;
    # ~/.zsh_profile already sources nvm itself.
    if PROFILE=/dev/null bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh)"; then
        ok "installed"
    else
        warn "nvm install failed — continuing (NVM lines in .zsh_profile will no-op)"
    fi
fi

# ── 6. default shell ─────────────────────────────────────────────────────
step "default shell"
zsh_bin=$(command -v zsh)
if [[ ${SHELL:-} == "$zsh_bin" ]]; then
    ok "zsh already default"
else
    if chsh -s "$zsh_bin"; then
        ok "set zsh as default (takes effect on next login)"
    else
        warn "chsh failed — run 'chsh -s $zsh_bin' manually"
    fi
fi

# ── 7. personal/env stub ─────────────────────────────────────────────────
step "personal env auto-loader directory"
mkdir -p "$HOME/.config/personal/env"
ok "$HOME/.config/personal/env ready (drop machine-local exports here)"

# ── 8. stow dev modules ──────────────────────────────────────────────────
step "stow dev modules"
for m in shell tmux bin nvim; do
    stow -t "$HOME" -R "$m"
    ok "stowed $m"
done

# ── 9. ~/.gitconfig.local ────────────────────────────────────────────────
step "git identity"
if [[ -f $HOME/.gitconfig.local ]]; then
    ok "$HOME/.gitconfig.local already exists — leaving untouched"
else
    printf "  enter your git user.name:  " ; read -r git_name
    printf "  enter your git user.email: " ; read -r git_email
    cat > "$HOME/.gitconfig.local" <<EOF
[user]
	name = $git_name
	email = $git_email
EOF
    ok "wrote $HOME/.gitconfig.local"
fi

# ── 10. nvim plugin sync ─────────────────────────────────────────────────
step "nvim plugin sync (lazy.nvim)"
if command -v nvim >/dev/null; then
    if nvim --headless "+Lazy! sync" +qa 2>/dev/null; then
        ok "plugins synced"
    else
        warn "lazy sync failed — open nvim and run :Lazy sync manually"
    fi
fi

# ── done ────────────────────────────────────────────────────────────────
printf '\n%s━━━━ done ━━━━%s\n' "$GREEN" "$RESET"
cat <<'EOF'
Next steps:
  • Open a NEW terminal so the new $SHELL takes effect.
  • Hit Ctrl+F to launch tmux-sessionizer.
  • For the Hyprland rice, install dotfiles-desktop alongside:
        git clone https://github.com/<your-username>/dotfiles-desktop ~/dotfiles-desktop
        ~/dotfiles-desktop/install.sh
EOF
[[ $backed_up -eq 1 ]] && printf '  • Pre-existing files backed up to: %s\n' "$BACKUP_DIR"

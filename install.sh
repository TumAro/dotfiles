#!/usr/bin/env bash
set -uo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES

source "$DOTFILES/.scripts/utils.sh"

printf '\n'
printf "  ${_B}Dotfiles Installer${_X}\n"
printf "  Log → %s\n" "$LOG_FILE"
printf '\n'

log "=== Install started $(date) ==="

bash "$DOTFILES/.scripts/deps.sh"
bash "$DOTFILES/.scripts/migrate.sh"

# ── Stow all packages ─────────────────────────────────────────
phase_header "Phase 2: Stow"
STEP_TOTAL=7
PKGS=(zsh git kitty i3 yazi polybar starship)
for pkg in "${PKGS[@]}"; do
  step_start "$pkg"
  if stow --dir="$DOTFILES" --target="$HOME" "$pkg" >> "$LOG_FILE" 2>&1; then
    step_done
  else
    step_fail
  fi
done
phase_bar

# ── Post-stow steps ───────────────────────────────────────────
chmod +x "$HOME/.config/polybar/launch.sh" >> "$LOG_FILE" 2>&1 || true
chmod +x "$HOME/.config/polybar/forest/launch.sh" >> "$LOG_FILE" 2>&1 || true

[[ -f ~/.zshrc.local ]] || printf '# Machine-specific secrets and aliases — not tracked by git\n' > ~/.zshrc.local

if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  printf "  Setting zsh as default shell...\n"
  chsh -s "$(command -v zsh)" || true
  log "chsh zsh"
fi

# ── Verify ────────────────────────────────────────────────────
bash "$DOTFILES/.scripts/verify.sh"

# ── Cleanup temp files ────────────────────────────────────────
rm -f /tmp/delta.deb /tmp/yazi.deb /tmp/JetBrainsMono.zip /tmp/vesktop.deb /tmp/eza.tar.gz
log "Cleanup done"

log "=== Install finished $(date) ==="

printf "  ${_G}Done.${_X}\n"
printf "  Next: secrets → ~/.zshrc.local  ·  log out → select i3\n\n"

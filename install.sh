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

# Verify stow is available before proceeding (deps.sh installs it, but guard against partial failures)
if ! command -v stow &>/dev/null; then
  printf "  ${_R}stow not found — deps.sh may have failed. Run: sudo apt install stow${_X}\n"
  exit 1
fi

bash "$DOTFILES/.scripts/migrate.sh"

# ── Stow all packages ─────────────────────────────────────────
phase_header "Phase 2: Stow"
PKGS=(zsh git kitty i3 yazi polybar starship)
STEP_TOTAL=${#PKGS[@]}
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
chmod +x "$HOME/.config/polybar/launch.sh" 2>/dev/null || true
chmod +x "$HOME/.config/polybar/forest/launch.sh" 2>/dev/null || true

[[ -f ~/.zshrc.local ]] || printf '# Machine-specific secrets and aliases — not tracked by git\n' > ~/.zshrc.local

if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  printf "  Setting zsh as default shell...\n"
  chsh -s "$(command -v zsh)" || true
  log "chsh zsh"
fi

# ── Verify ────────────────────────────────────────────────────
if bash "$DOTFILES/.scripts/verify.sh"; then
  # Clean up migrate backups only after successful verify
  printf "  Cleaning up migration backups...\n"
  rm -rf \
    "$HOME/.config/yazi.bak" "$HOME/.config/yazi.bak."* \
    "$HOME/.config/polybar.bak" "$HOME/.config/polybar.bak."* \
    2>/dev/null || true
  log "Migration backups cleaned"
fi

# ── Cleanup temp files ────────────────────────────────────────
rm -f /tmp/delta.deb /tmp/yazi.deb /tmp/JetBrainsMono.zip /tmp/vesktop.deb /tmp/eza.tar.gz /tmp/helix.tar.xz
rm -rf /tmp/helix-*-linux 2>/dev/null || true
log "Cleanup done"

log "=== Install finished $(date) ==="

printf "  ${_G}Done.${_X}\n"
printf "  Next: secrets → ~/.zshrc.local  ·  log out → select i3\n\n"

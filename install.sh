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
bash "$DOTFILES/.scripts/link.sh"

# ── set default shell ─────────────────────────────────────────
printf '\n'
if [[ "$SHELL" != "$(which zsh)" ]]; then
  printf "  Setting zsh as default shell...\n"
  chsh -s "$(which zsh)" || true
  log "chsh zsh"
fi

# ── cleanup temp files ────────────────────────────────────────
printf "  Cleaning temp files...\n"
rm -f /tmp/delta.deb /tmp/yazi.deb /tmp/JetBrainsMono.zip /tmp/vesktop.deb
log "Cleanup done"

log "=== Install finished $(date) ==="

printf '\n'
printf "  ${_G}Done.${_X}\n"
printf "  Next: secrets → ~/.zshrc.local  ·  log out → select i3\n\n"

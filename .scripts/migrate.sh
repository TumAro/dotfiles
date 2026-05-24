#!/usr/bin/env bash
# One-time cleanup: removes old link.sh symlinks and tangle artifacts so stow can take over.
# Safe to re-run — skips anything not present, backs up real files/dirs before removing.
set -uo pipefail
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES/.scripts/utils.sh"

STEP_TOTAL=12

phase_header "Migration: Clean up for stow"

_remove_symlink() {
  local dst="$1" label="$2"
  step_start "$label"
  if [[ -L "$dst" ]]; then
    rm "$dst" && step_done || step_fail
  else
    step_skip
  fi
}

_backup_real() {
  local dst="$1" label="$2"
  step_start "backup $label"
  if [[ ! -L "$dst" && -e "$dst" ]]; then
    local bak="${dst}.bak"
    [[ -e "$bak" ]] && bak="${dst}.bak.$(date +%s)"
    if mv "$dst" "$bak"; then
      log "BACKUP $dst -> $bak"
      step_done
    else
      step_fail
    fi
  else
    step_skip
  fi
}

# Remove tangle artifacts first (nested symlinks caused by the dir-symlink bug)
_remove_symlink "$HOME/.config/yazi/yazi"       "yazi tangle artifact"
_remove_symlink "$HOME/.config/polybar/polybar" "polybar tangle artifact"

# Backup real dirs that may contain user files before stow takes over
_backup_real "$HOME/.config/yazi"    "yazi dir"
_backup_real "$HOME/.config/polybar" "polybar dir"

# Remove all file-level symlinks managed by the old link.sh
_remove_symlink "$HOME/.zshrc"                   ".zshrc"
_remove_symlink "$HOME/.gitconfig"               ".gitconfig"
_remove_symlink "$HOME/.config/kitty/kitty.conf" "kitty.conf"
_remove_symlink "$HOME/.config/kitty/colors.conf" "kitty colors.conf"
_remove_symlink "$HOME/.config/i3/config"        "i3 config"
_remove_symlink "$HOME/.config/starship.toml"    "starship.toml"

# Remove empty dirs so stow can fold them into clean symlinks
step_start "clean empty dirs"
_cleaned=0
for d in "$HOME/.config/kitty" "$HOME/.config/i3"; do
  if [[ -d "$d" && ! -L "$d" ]]; then
    rmdir "$d" 2>/dev/null && _cleaned=$(( _cleaned + 1 )) || true
  fi
done
step_done

phase_bar

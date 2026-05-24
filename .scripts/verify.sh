#!/usr/bin/env bash
set -uo pipefail
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES/.scripts/utils.sh"

STEP_TOTAL=7
_PASS=0
_FAIL=0

phase_header "Phase 3: Verify symlinks"

_check() {
  local label="$1" src="$2" dst="$3"
  STEP_N=$(( STEP_N + 1 ))
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$src" ]]; then
    printf "  ${_G}ok${_X}  %s\n" "$label"
    log "VERIFY ok $dst"
    _PASS=$(( _PASS + 1 ))
  elif [[ -L "$dst" ]]; then
    printf "  ${_R}BROKEN${_X}  %s  (resolves to %s)\n" "$label" "$(readlink -f "$dst")"
    log "VERIFY BROKEN $dst -> $(readlink -f "$dst") (expected $src)"
    _FAIL=$(( _FAIL + 1 ))
  else
    printf "  ${_R}MISSING${_X} %s\n" "$label"
    log "VERIFY MISSING $dst"
    _FAIL=$(( _FAIL + 1 ))
  fi
}

# Stow folds single-owner dirs into dir-level symlinks.
# These src paths are exactly what stow writes as the symlink target.
_check ".zshrc"        "$DOTFILES/zsh/.zshrc"                    "$HOME/.zshrc"
_check ".gitconfig"    "$DOTFILES/git/.gitconfig"                 "$HOME/.gitconfig"
_check "kitty"         "$DOTFILES/kitty/.config/kitty"            "$HOME/.config/kitty"
_check "i3"            "$DOTFILES/i3/.config/i3"                  "$HOME/.config/i3"
_check "yazi"          "$DOTFILES/yazi/.config/yazi"              "$HOME/.config/yazi"
_check "polybar"       "$DOTFILES/polybar/.config/polybar"        "$HOME/.config/polybar"
_check "starship.toml" "$DOTFILES/starship/.config/starship.toml" "$HOME/.config/starship.toml"

printf "\n  ${_G}%d ok${_X}  ${_R}%d fail${_X}\n\n" "$_PASS" "$_FAIL"
log "VERIFY summary: $_PASS ok, $_FAIL fail"

[[ $_FAIL -eq 0 ]] || exit 1

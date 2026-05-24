#!/usr/bin/env bash
set -uo pipefail
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES/.scripts/utils.sh"

STEP_TOTAL=10

_sym() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  ln -sf "$src" "$dst" >> "$LOG_FILE" 2>&1
}

phase_header "Phase 2: Symlinks"

step_start ".zshrc"
if _sym "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"; then step_done; else step_fail; fi

step_start ".gitconfig"
if _sym "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"; then step_done; else step_fail; fi

step_start "kitty.conf"
if _sym "$DOTFILES/kitty/.config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"; then step_done; else step_fail; fi

step_start "kitty colors.conf"
if _sym "$DOTFILES/kitty/.config/kitty/colors.conf" "$HOME/.config/kitty/colors.conf"; then step_done; else step_fail; fi

step_start "i3 config"
mkdir -p "$HOME/.config/i3"
if _sym "$DOTFILES/i3/.config/i3/config" "$HOME/.config/i3/config"; then step_done; else step_fail; fi

step_start "yazi config"
if _sym "$DOTFILES/yazi/.config/yazi" "$HOME/.config/yazi"; then step_done; else step_fail; fi

step_start "polybar config"
if _sym "$DOTFILES/polybar/.config/polybar" "$HOME/.config/polybar"; then step_done; else step_fail; fi

step_start "starship.toml"
if _sym "$DOTFILES/starship/.config/starship.toml" "$HOME/.config/starship.toml"; then step_done; else step_fail; fi

step_start "polybar executable"
if chmod +x "$DOTFILES/polybar/.config/polybar/launch.sh" >> "$LOG_FILE" 2>&1; then step_done; else step_fail; fi

step_start ".zshrc.local"
if [[ -f ~/.zshrc.local ]]; then
  step_skip
else
  printf '# Machine-specific secrets and aliases — not tracked by git\n' > ~/.zshrc.local
  step_done
fi

phase_bar

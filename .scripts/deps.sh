#!/usr/bin/env bash
set -uo pipefail
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES/.scripts/utils.sh"

STEP_TOTAL=11

phase_header "Phase 1: Dependencies"

# ── apt packages ──────────────────────────────────────────────
step_start "apt packages"
if sudo apt update -qq >> "$LOG_FILE" 2>&1 && \
   sudo apt install -y \
     zsh git curl wget fzf ripgrep fd-find bat \
     i3 i3status rofi picom xclip polybar \
     build-essential cmake python3 python3-pip \
     fontconfig wmctrl \
     gvfs gvfs-backends thunar >> "$LOG_FILE" 2>&1; then
  step_done
else
  step_fail "apt install failed"
fi

# ── kitty ─────────────────────────────────────────────────────
step_start "kitty"
if [[ -f ~/.local/kitty.app/bin/kitty ]]; then
  step_skip
else
  if curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin >> "$LOG_FILE" 2>&1; then
    mkdir -p ~/.local/bin
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty >> "$LOG_FILE" 2>&1 || true
    step_done
  else
    step_fail
  fi
fi

# ── delta ─────────────────────────────────────────────────────
step_start "delta"
if which delta &>/dev/null; then
  step_skip
else
  if wget -qO /tmp/delta.deb \
       https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_amd64.deb \
       >> "$LOG_FILE" 2>&1 && \
     sudo dpkg -i /tmp/delta.deb >> "$LOG_FILE" 2>&1; then
    step_done
  else
    step_fail
  fi
fi

# ── yazi ──────────────────────────────────────────────────────
step_start "yazi"
if which yazi &>/dev/null; then
  step_skip
else
  YAZI_VER=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)
  if wget -qO /tmp/yazi.deb \
       "https://github.com/sxyazi/yazi/releases/download/${YAZI_VER}/yazi-x86_64-unknown-linux-gnu.deb" \
       >> "$LOG_FILE" 2>&1 && \
     sudo apt install -f /tmp/yazi.deb -y >> "$LOG_FILE" 2>&1; then
    step_done
  else
    step_fail
  fi
fi

# ── starship ──────────────────────────────────────────────────
step_start "starship"
if which starship &>/dev/null; then
  step_skip
else
  if curl -sS https://starship.rs/install.sh | sh -s -- --yes >> "$LOG_FILE" 2>&1; then
    step_done
  else
    step_fail
  fi
fi

# ── zoxide ────────────────────────────────────────────────────
step_start "zoxide"
if which zoxide &>/dev/null; then
  step_skip
else
  if curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh >> "$LOG_FILE" 2>&1; then
    step_done
  else
    step_fail
  fi
fi

# ── zinit ─────────────────────────────────────────────────────
step_start "zinit"
if [[ -d ~/.local/share/zinit/zinit.git ]]; then
  step_skip
else
  if bash -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)" \
       >> "$LOG_FILE" 2>&1; then
    step_done
  else
    step_fail
  fi
fi

# ── JetBrainsMono Nerd Font ───────────────────────────────────
step_start "JetBrainsMono font"
if [[ -d ~/.local/share/fonts/JetBrainsMono ]]; then
  step_skip
else
  mkdir -p ~/.local/share/fonts
  if wget -qO /tmp/JetBrainsMono.zip \
       https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
       >> "$LOG_FILE" 2>&1 && \
     unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono/ '*.ttf' \
       >> "$LOG_FILE" 2>&1; then
    fc-cache -fv ~/.local/share/fonts >> "$LOG_FILE" 2>&1 || true
    step_done
  else
    step_fail
  fi
fi

# ── local dotfiles fonts ──────────────────────────────────────
step_start "local fonts"
if cp -r "$DOTFILES/fonts/"* ~/.local/share/fonts/ >> "$LOG_FILE" 2>&1; then
  fc-cache -fv ~/.local/share/fonts >> "$LOG_FILE" 2>&1 || true
  step_done
else
  step_fail
fi

# ── vesktop ───────────────────────────────────────────────────
step_start "vesktop"
if which vesktop &>/dev/null; then
  step_skip
else
  VESKTOP_URL=$(curl -s https://api.github.com/repos/Vencord/Vesktop/releases/latest \
    | grep "browser_download_url.*amd64\.deb" | cut -d'"' -f4)
  if wget -qO /tmp/vesktop.deb "$VESKTOP_URL" >> "$LOG_FILE" 2>&1 && \
     sudo dpkg -i /tmp/vesktop.deb >> "$LOG_FILE" 2>&1; then
    step_done
  else
    step_fail
  fi
fi

# ── bat symlink ───────────────────────────────────────────────
step_start "bat symlink"
mkdir -p ~/.local/bin
if ln -sf /usr/bin/batcat ~/.local/bin/bat >> "$LOG_FILE" 2>&1; then
  step_done
else
  step_fail
fi

phase_bar

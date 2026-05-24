#!/usr/bin/env bash
set -uo pipefail
DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
source "$DOTFILES/.scripts/utils.sh"

STEP_TOTAL=13

# ── Architecture detection ─────────────────────────────────────
_ARCH="$(uname -m)"
case "$_ARCH" in
  x86_64)        DEB_ARCH="amd64";  RUST_ARCH="x86_64-unknown-linux-gnu" ;;
  aarch64|arm64) DEB_ARCH="arm64";  RUST_ARCH="aarch64-unknown-linux-gnu" ;;
  armv7l)        DEB_ARCH="armhf";  RUST_ARCH="armv7-unknown-linux-gnueabihf" ;;
  *)             DEB_ARCH="amd64";  RUST_ARCH="x86_64-unknown-linux-gnu"
                 log "WARN: unknown arch $_ARCH, defaulting to amd64" ;;
esac

phase_header "Phase 1: Dependencies"

# ── apt packages ──────────────────────────────────────────────
step_start "apt packages"
PICOM_PKG="picom"
apt-cache show picom &>/dev/null 2>&1 || PICOM_PKG="compton"
if sudo apt update -qq >> "$LOG_FILE" 2>&1 && \
   sudo apt install -y \
     zsh git curl wget fzf ripgrep fd-find bat \
     i3 i3status rofi "$PICOM_PKG" xclip polybar redshift \
     build-essential cmake python3 python3-pip \
     fontconfig wmctrl stow unzip \
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
if command -v delta &>/dev/null; then
  step_skip
else
  if wget -qO /tmp/delta.deb \
       "https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_${DEB_ARCH}.deb" \
       >> "$LOG_FILE" 2>&1 && \
     sudo dpkg -i /tmp/delta.deb >> "$LOG_FILE" 2>&1; then
    step_done
  else
    step_fail
  fi
fi

# ── yazi ──────────────────────────────────────────────────────
step_start "yazi"
if command -v yazi &>/dev/null; then
  step_skip
else
  YAZI_VER=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)
  if wget -qO /tmp/yazi.deb \
       "https://github.com/sxyazi/yazi/releases/download/${YAZI_VER}/yazi-${RUST_ARCH}.deb" \
       >> "$LOG_FILE" 2>&1 && \
     sudo apt install -f /tmp/yazi.deb -y >> "$LOG_FILE" 2>&1; then
    step_done
  else
    step_fail
  fi
fi

# ── starship ──────────────────────────────────────────────────
step_start "starship"
if command -v starship &>/dev/null; then
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
if command -v zoxide &>/dev/null; then
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
if command -v vesktop &>/dev/null; then
  step_skip
else
  VESKTOP_URL=$(curl -s https://api.github.com/repos/Vencord/Vesktop/releases/latest \
    | grep "browser_download_url.*${DEB_ARCH}\.deb" | cut -d'"' -f4)
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
BAT_BIN="$(command -v batcat 2>/dev/null || command -v bat 2>/dev/null || true)"
if [[ -n "$BAT_BIN" ]]; then
  if ln -sf "$BAT_BIN" ~/.local/bin/bat >> "$LOG_FILE" 2>&1; then
    step_done
  else
    step_fail
  fi
else
  step_fail "bat/batcat not found after apt install"
fi

# ── eza ───────────────────────────────────────────────────────
step_start "eza"
if command -v eza &>/dev/null; then
  step_skip
else
  if apt-cache show eza &>/dev/null 2>&1; then
    if sudo apt install -y eza >> "$LOG_FILE" 2>&1; then
      step_done
    else
      step_fail
    fi
  else
    EZA_VER=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest \
      | grep '"tag_name"' | cut -d'"' -f4)
    if wget -qO /tmp/eza.tar.gz \
         "https://github.com/eza-community/eza/releases/download/${EZA_VER}/eza_${RUST_ARCH}.tar.gz" \
         >> "$LOG_FILE" 2>&1 && \
       tar -xzf /tmp/eza.tar.gz -C ~/.local/bin/ eza >> "$LOG_FILE" 2>&1; then
      step_done
    else
      step_fail
    fi
  fi
fi

# ── helix ─────────────────────────────────────────────────────
step_start "helix"
if command -v hx &>/dev/null; then
  step_skip
else
  if apt-cache show helix &>/dev/null 2>&1; then
    if sudo apt install -y helix >> "$LOG_FILE" 2>&1; then
      step_done
    else
      step_fail
    fi
  else
    HX_VER=$(curl -s https://api.github.com/repos/helix-editor/helix/releases/latest \
      | grep '"tag_name"' | cut -d'"' -f4)
    case "$_ARCH" in
      x86_64)        HX_ARCH="x86_64" ;;
      aarch64|arm64) HX_ARCH="aarch64" ;;
      *)             HX_ARCH="x86_64" ;;
    esac
    HX_DIR="/tmp/helix-${HX_VER}-${HX_ARCH}-linux"
    mkdir -p ~/.local/bin ~/.config/helix
    if wget -qO /tmp/helix.tar.xz \
         "https://github.com/helix-editor/helix/releases/download/${HX_VER}/helix-${HX_VER}-${HX_ARCH}-linux.tar.xz" \
         >> "$LOG_FILE" 2>&1 && \
       tar -xJf /tmp/helix.tar.xz -C /tmp/ >> "$LOG_FILE" 2>&1 && \
       mv "${HX_DIR}/hx" ~/.local/bin/hx && \
       rm -rf ~/.config/helix/runtime && \
       mv "${HX_DIR}/runtime" ~/.config/helix/runtime; then
      step_done
    else
      step_fail
    fi
  fi
fi

phase_bar

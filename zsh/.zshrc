# ── Zinit bootstrap ───────────────────────────────────────────────────────────
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

# ── Plugins ───────────────────────────────────────────────────────────────────
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# Useful snippets from Oh My Zsh (just the good parts, no OMZ needed)
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# ── Completion ────────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit -u

zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups

# ── Keybinds ──────────────────────────────────────────────────────────────────
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# ── Tools ─────────────────────────────────────────────────────────────────────
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# ── Aliases ───────────────────────────────────────────────────────────────────

# yazi — with cwd tracking
function y() {
  local tmp="$(mktemp -t yazi-cwd.XXXXXX)" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# Navigation
alias ..='cd ..'
alias ...='cd ../..'

# eza — better ls
alias ls='eza --icons=always'
alias l='eza -al --icons=always'
alias ll='eza -lg --icons=always'
alias la='eza -lag --icons=always'
alias lt='eza -lT --icons=always --level=2'

# bat — better cat
alias cat='bat --pager=never'

# fd — binary name differs across distros
command -v fdfind &>/dev/null && alias find='fdfind' || command -v fd &>/dev/null && alias find='fd' || true

# ripgrep — better grep
alias grep='rg'

# Editor
alias v='hx'
alias vi='hx'
alias vim='hx'
export EDITOR='hx'
export VISUAL='hx'

# Git shortcuts
alias g='git'
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

# Python
alias py='python3'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias activate='source .venv/bin/activate'

# Safety nets
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Quick config edits
alias ezsh='hx ~/dotfiles/zsh/.zshrc && source ~/.zshrc'
alias ei3='hx ~/dotfiles/i3/.config/i3/config'
alias ekitty='hx ~/dotfiles/kitty/.config/kitty/kitty.conf'

# Misc
alias peek='peek -b ffmpeg'
alias ssh='TERM=xterm-256color ssh'

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/gems/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
[[ -n "${OPENCODE_PATH:-}" ]] && export PATH="$OPENCODE_PATH:$PATH"

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Ruby gems
export GEM_HOME="$HOME/gems"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# ── Machine-local overrides (secrets, machine-specific aliases) ───────────────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

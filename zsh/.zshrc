# ── Zinit bootstrap ───────────────────────────────────────────────────────────
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"

# ── Plugins ───────────────────────────────────────────────────────────────────
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
# zinit light Aloxaf/fzf-tab

# Useful snippets from Oh My Zsh (just the good parts, no OMZ needed)
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::command-not-found

# ── Completion ────────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit

zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# zstyle ':completion:*' menu no
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

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
eval "$(fzf --zsh)"
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# ── Aliases ───────────────────────────────────────────────────────────────────

# yazi
function y () {
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

# eza — better ls (shows icons, git status, colours)
alias ls='eza --icons=always'
alias l='eza -al --icons=always'
alias ll='eza -lg --icons=always'
alias la='eza -lag --icons=always'
alias lt='eza -lT --icons=always --level=2'

# bat — better cat (syntax highlighting, line numbers)
alias cat='bat --pager=never'

# fd — better find
alias find='fdfind'

# ripgrep — better grep
alias grep='rg'

# Editor
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Git shortcuts
alias g='git'
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

# File manager
alias f='yazi'

# Python
alias py='python3'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias activate='source .venv/bin/activate'

# Safety nets
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Quick config edits
alias ezsh='nvim ~/dotfiles/zsh/.zshrc && source ~/.zshrc'
alias envim='nvim ~/dotfiles/nvim/.config/nvim/'
alias ei3='nvim ~/dotfiles/i3/.config/i3/config'
alias ekitty='nvim ~/dotfiles/kitty/.config/kitty/kitty.conf'

# Misc
alias venv-activate='source ./.venv/bin/activate'
alias peek='peek -b ffmpeg'
alias ssh='TERM=xterm-256color ssh'

# ── PATH ──────────────────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/gems/bin:$PATH"
export PATH="/usr/local/bin:$PATH"          # picks up our nvim AppImage
export PATH="$OPENCODE_PATH:$PATH"

export EDITOR='nvim'
export VISUAL='nvim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Ruby gems
export GEM_HOME="$HOME/gems"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}'"


# ── Machine-local overrides (secrets, machine-specific aliases) ───────────────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

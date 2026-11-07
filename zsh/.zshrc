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
autoload -Uz compinit
# full security check only if the dump is older than a day, otherwise trust the cache
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then compinit -u; else compinit -u -C; fi

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
unalias zi 2>/dev/null  # zinit's `zi` alias breaks zoxide's `zi()` function def below
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

# Steam client stays on iGPU (~/.local/bin/steam). Per game, set launch option: prime-run %command%
alias steam-show='steam steam://open/main'

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
alias cat='bat --style=plain --paging=never'

# fd — Debian/Ubuntu name the binary fdfind; `fd` alias only, `find` stays the real find
(( $+commands[fdfind] && ! $+commands[fd] )) && alias fd=fdfind

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
alias ehx='hx ~/dotfiles/helix/.config/helix/config.toml'

# Zellij sessions are named after the repo (folder), never random.
#   ws        start or resume this repo's workspace (repo layout or the global "work" layout)
#   ws -n     start another session for the same repo: repo-2, repo-3, ...
#   zellij    (no args) plain session, same naming, resumes if it already exists
_zj_name() {  # $1 = base name, $2 = "new" to force the next free number
  local base=$1 name=$1 i=2
  if [[ $2 == new ]]; then
    while command zellij list-sessions -ns 2>/dev/null | grep -qx -- "$name"; do name=$base-$i; (( i++ )); done
  fi
  print -r -- $name
}
_zj_root() { git rev-parse --show-toplevel 2>/dev/null || pwd }

ws() {
  [[ -n "$ZELLIJ" ]] && { echo "already inside zellij"; return 1; }
  local root=$(_zj_root) layout=work
  [[ -f $root/.zellij/work.kdl ]] && layout=$root/.zellij/work.kdl
  local name=$(_zj_name ${root:t} ${${1:#-n}:+x}${${(M)1:#-n}:+new})
  (cd "$root" && command zellij attach --create "$name" options --default-layout "$layout")
}

# typ file.typ   Typst writing: helix in zellij (left) + live PDF in zathura (right, i3 tiles it). Needs a running i3.
typ() {
  [[ -n "$ZELLIJ" ]] && { echo "already inside zellij"; return 1; }
  local f=${1:-main.typ}
  [[ -f $f ]] || print -r -- '= Title' > $f
  typst compile $f || return 1
  (zathura ${f:r}.pdf &>/dev/null &)
  sleep 0.4; i3-msg -q focus left
  TYP_FILE=$f command zellij attach --create "typ-${PWD:t}-${f:t:r}" options --default-layout typst
}

zellij() {
  if (( $# == 0 )) && [[ -z "$ZELLIJ" ]]; then
    local root=$(_zj_root)
    (cd "$root" && command zellij attach --create "$(_zj_name ${root:t})")
  else
    command zellij "$@"
  fi
}

# Misc
alias peek='peek -b ffmpeg'
alias ssh='TERM=xterm-256color ssh'
alias buds='bt-buds'

# ── Environment ───────────────────────────────────────────────────────────────
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export GEM_HOME="$HOME/gems"
export BUN_INSTALL="$HOME/.bun"
export NVM_DIR="$HOME/.nvm"

# ── PATH (one block; typeset -U drops duplicates) ─────────────────────────────
typeset -U path
_node=($NVM_DIR/versions/node/*(N[-1]))   # newest installed node; nvm itself is lazy
path=(
  $HOME/bin
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/gems/bin
  $BUN_INSTALL/bin
  $HOME/.opencode/bin
  /usr/local/bin
  ${OPENCODE_PATH:+$OPENCODE_PATH}
  ${_node:+$_node/bin}
  $path
)
unset _node

# nvm: only load it when `nvm` is called (saves ~0.9s per shell)
nvm() {
  unset -f nvm
  source "$NVM_DIR/nvm.sh"
  nvm "$@"
}

# bun completions
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# ── Machine-local overrides (secrets, machine-specific aliases): keep LAST ────
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# docker on demand (daemon disabled at boot to save RAM)
alias docker-start='sudo systemctl start docker'
alias docker-stop='sudo systemctl stop docker.service docker.socket containerd.service'

# usage: vpn [jp|nl|us]  (default jp); configs live in ~/.config/vpn, not in dotfiles
vpn() { sudo openvpn --config ~/.config/vpn/${1:-jp}-*.ovpn --auth-user-pass /dev/stdin <<< "$(pass vpn/proton)"; }

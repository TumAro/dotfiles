#!/usr/bin/env bash
# Shared utilities: logging, step progress display

LOG_FILE="${LOG_FILE:-$HOME/.dotfiles-install.log}"
export LOG_FILE

STEP_N=0
STEP_TOTAL=0
_STEP_NAME=""

# Colors (disabled if not a tty or NO_COLOR set)
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  _G='\033[0;32m'   # green
  _Y='\033[0;33m'   # yellow
  _R='\033[0;31m'   # red
  _C='\033[0;36m'   # cyan
  _B='\033[1m'      # bold
  _X='\033[0m'      # reset
else
  _G='' _Y='' _R='' _C='' _B='' _X=''
fi

log() {
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" >> "$LOG_FILE"
}

# Latest release tag for a github repo, e.g. gh_tag sxyazi/yazi
gh_tag() {
  curl -s "https://api.github.com/repos/$1/releases/latest" | grep '"tag_name"' | cut -d'"' -f4
}

step_start() {
  _STEP_NAME="$1"
  STEP_N=$(( STEP_N + 1 ))
  printf "  ${_B}[%d/%d]${_X} %-32s" "$STEP_N" "$STEP_TOTAL" "$_STEP_NAME..."
  log "START [$STEP_N/$STEP_TOTAL] $_STEP_NAME"
}

step_done() {
  printf "\r  ${_B}[%d/%d]${_X} ${_G}✓${_X}  %-30s\n" "$STEP_N" "$STEP_TOTAL" "$_STEP_NAME"
  log "DONE  [$STEP_N/$STEP_TOTAL] $_STEP_NAME"
}

step_skip() {
  printf "\r  ${_B}[%d/%d]${_X} ${_Y}~${_X}  %-24s skip\n" "$STEP_N" "$STEP_TOTAL" "$_STEP_NAME"
  log "SKIP  [$STEP_N/$STEP_TOTAL] $_STEP_NAME"
}

step_fail() {
  printf "\r  ${_B}[%d/%d]${_X} ${_R}✗${_X}  %-22s FAIL\n" "$STEP_N" "$STEP_TOTAL" "$_STEP_NAME"
  log "FAIL  [$STEP_N/$STEP_TOTAL] $_STEP_NAME — ${*:-}"
}

phase_header() {
  printf "\n  ${_C}${_B}%s${_X}\n" "$1"
  printf "  %s\n" "$(printf '─%.0s' {1..40})"
}

phase_bar() {
  local done="${1:-$STEP_N}" total="${2:-$STEP_TOTAL}"
  [[ $total -eq 0 ]] && return
  local pct=$(( done * 100 / total ))
  local filled=$(( done * 24 / total ))
  local bar=""
  local i
  for (( i=0; i<filled; i++ ));    do bar="${bar}█"; done
  for (( i=filled; i<24; i++ ));   do bar="${bar}░"; done
  printf "\n  ${_G}%s${_X} %3d%%  %d/%d done\n" "$bar" "$pct" "$done" "$total"
}

#!/usr/bin/env bash
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# gyrobook is the laptop (battery/gpu-offload modules); other hosts (desktop) skip those.
[[ "$(hostname)" != "gyrobook" ]] && export BAR_MODULES_RIGHT="cpu temperature gpu sep alsa sep sysmenu"

polybar main -c "$HOME/.config/polybar/forest/config.ini" &

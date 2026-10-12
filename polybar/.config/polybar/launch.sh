#!/usr/bin/env bash
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# No battery (desktop): drop the battery module.
compgen -G "/sys/class/power_supply/BAT*" >/dev/null || export BAR_MODULES_RIGHT="temp-alert alsa"

polybar main -c "$HOME/.config/polybar/forest/config.ini" &

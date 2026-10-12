#!/usr/bin/env bash
# Battery; prints only below 50% (any state) so the bar stays quiet otherwise.
b=/sys/class/power_supply/BAT1
[[ -r $b/capacity ]] || exit 0
c=$(<"$b/capacity"); s=$(<"$b/status")
[[ "$c" -lt 50 ]] || exit 0
col='#e6b450'; [[ "$c" -lt 20 ]] && col='#ff3333'
[[ "$s" == Charging ]] && icon="" || icon=""
echo "%{F$col}$icon ${c}%%{F-}"
exit 0

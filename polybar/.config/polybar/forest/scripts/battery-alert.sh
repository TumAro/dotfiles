#!/usr/bin/env bash
# Battery. Quiet by default:
#   discharging below 50%  -> yellow (red below 20%)
#   charging below 80%     -> green "charging" indicator, so you can see the charger took
b=$(compgen -G '/sys/class/power_supply/BAT*' | head -1)
[[ -n $b ]] || exit 0
[[ -r $b/capacity ]] || exit 0
c=$(<"$b/capacity"); s=$(<"$b/status")
if [[ "$s" == Charging && "$c" -lt 80 ]]; then
  echo "%{F#c2d94c}charging ${c}% %{F-}"
elif [[ "$s" != Charging && "$c" -lt 50 ]]; then
  col='#e6b450'; [[ "$c" -lt 20 ]] && col='#ff3333'
  echo "%{F$col}battery ${c}% %{F-}"
fi
exit 0

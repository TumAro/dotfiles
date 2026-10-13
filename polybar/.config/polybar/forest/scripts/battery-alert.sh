#!/usr/bin/env bash
# Battery. Quiet by default:
#   discharging below 50%  -> plain yellow number (red below 20%), no bolt
#   charging below 80%     -> green thunder-bolt indicator, so you can see the charger took
b=$(compgen -G '/sys/class/power_supply/BAT*' | head -1)
[[ -n $b ]] || exit 0
[[ -r $b/capacity ]] || exit 0
c=$(<"$b/capacity"); s=$(<"$b/status")
if [[ "$s" == Charging && "$c" -lt 80 ]]; then
  printf '%%{F#c2d94c}\uf0e7 %s%% %%{F-}\n' "$c"
elif [[ "$s" != Charging && "$c" -lt 50 ]]; then
  col='#e6b450'; [[ "$c" -lt 20 ]] && col='#ff3333'
  echo "%{F$col}${c}% %{F-}"
fi
exit 0

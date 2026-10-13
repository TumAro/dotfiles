#!/usr/bin/env bash
# Battery. Quiet by default:
#   charger plugged in (not full) -> green bolt + %   (no notification daemon: it cost RAM)
#   on battery below 50%          -> plain yellow number (red below 20%)
b=$(compgen -G '/sys/class/power_supply/BAT*' | head -1)
[[ -n $b && -r $b/capacity ]] || exit 0
ac=$(compgen -G '/sys/class/power_supply/A[CD]*/online' | head -1)
plugged=0; [[ -n $ac && "$(<"$ac")" == 1 ]] && plugged=1
c=$(<"$b/capacity"); s=$(<"$b/status")

if (( plugged )) && [[ "$s" != Full ]]; then
  printf '%%{F#c2d94c} %s%% %%{F-}\n' "$c"
elif (( ! plugged )) && [[ "$c" -lt 50 ]]; then
  col='#e6b450'; [[ "$c" -lt 20 ]] && col='#ff3333'
  echo "%{F$col}${c}% %{F-}"
fi
exit 0

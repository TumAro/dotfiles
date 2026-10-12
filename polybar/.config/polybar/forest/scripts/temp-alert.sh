#!/usr/bin/env bash
# CPU package temp; prints only above 50C so the bar stays quiet otherwise.
for z in /sys/class/thermal/thermal_zone*; do
  [[ "$(<"$z/type")" == x86_pkg_temp ]] && t=$(( $(<"$z/temp") / 1000 )) && break
done
[[ -n "$t" && "$t" -gt 50 ]] && echo "%{F#ff8f40} ${t}°C%{F-}"
exit 0

#!/usr/bin/env bash
# CPU temp; prints only above 50C so the bar stays quiet otherwise.
# Intel pkg thermal zone first, then hwmon coretemp (Intel) / k10temp (AMD).
t=""
for z in /sys/class/thermal/thermal_zone*; do
  [[ "$(<"$z/type")" == x86_pkg_temp ]] && t=$(( $(<"$z/temp") / 1000 )) && break
done
if [[ -z "$t" ]]; then
  for h in /sys/class/hwmon/hwmon*; do
    case "$(<"$h/name")" in coretemp|k10temp) t=$(( $(<"$h/temp1_input") / 1000 )); break ;; esac
  done
fi
[[ -n "$t" && "$t" -gt 50 ]] && echo "%{F#ff8f40} ${t}°C%{F-}"
exit 0

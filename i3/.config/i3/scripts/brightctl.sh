#!/bin/sh
dev=/sys/class/backlight/intel_backlight
[ -d "$dev" ] || exit 0
max=$(cat "$dev/max_brightness")
cur=$(cat "$dev/brightness")
step=$((max / 20))

case "$1" in
  up)   new=$((cur + step)); [ "$new" -gt "$max" ] && new=$max ;;
  down) new=$((cur - step)); [ "$new" -lt 0 ] && new=0 ;;
esac

echo "$new" > "$dev/brightness"

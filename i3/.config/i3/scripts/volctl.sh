#!/bin/sh
status=$(wpctl status)
sink=$(echo "$status" | awk '/Sinks:/{f=1} f&&/\*/{for(i=1;i<=NF;i++) if ($i ~ /^[0-9]+\.$/) {print $i; exit}}' | tr -d '.')
cur=$(echo "$status" | awk -v s="$sink." '$0~/\*/ && $0~s {gsub(/[^0-9.]/,"",$NF); print $NF; exit}')

case "$1" in
  up)   new=$(echo "$cur 0.05" | awk '{v=$1+$2; if(v>1)v=1; print v}'); wpctl set-volume "$sink" "$new" ;;
  down) new=$(echo "$cur 0.05" | awk '{v=$1-$2; if(v<0)v=0; print v}'); wpctl set-volume "$sink" "$new" ;;
  mute) wpctl set-mute "$sink" toggle ;;
esac

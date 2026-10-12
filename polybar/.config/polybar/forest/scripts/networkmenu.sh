#!/usr/bin/env bash
# Wi-Fi menu: pick a network in rofi; asks for a password only for new secured networks.
theme="$HOME/.config/polybar/forest/scripts/rofi/networkmenu.rasi"
menu() { rofi -no-config -dmenu -i -theme "$theme" "$@"; }
note() { command -v notify-send >/dev/null && notify-send -t 3000 "Wi-Fi" "$1"; }

nmcli radio wifi | grep -q enabled || nmcli radio wifi on

active=$(nmcli -t --escape no -f ACTIVE,SSID device wifi | awk -F: '$1=="yes"{sub(/^yes:/,""); print; exit}')
networks=$(nmcli -t --escape no -f SIGNAL,SECURITY,SSID device wifi list --rescan auto |
  awk -F: -v act="$active" '{ssid=$0; sub(/^[^:]*:[^:]*:/,"",ssid); if (ssid!="" && !seen[ssid]++) printf "%s%3s%%  %-10s │ %s\n", (ssid==act?"● ":"  "), $1, ($2==""?"open":$2), ssid}')

choice=$(printf '%s\n%s\n%s\n' "$networks" "  Disconnect" "  Wi-Fi off" | sed '/^$/d' |
  menu -p "Wi-Fi${active:+ ($active)}")
[[ -z "$choice" ]] && exit 0

case "$choice" in
  *"Disconnect") nmcli device disconnect "$(nmcli -t -f DEVICE,TYPE device | awk -F: '$2=="wifi"{print $1; exit}')" && note "Disconnected"; exit ;;
  *"Wi-Fi off")  nmcli radio wifi off && note "Wi-Fi off"; exit ;;
esac

ssid="${choice#*│ }"
if nmcli -t -f NAME connection show | grep -Fxq "$ssid"; then
  nmcli connection up id "$ssid" && note "Connected to $ssid" || note "Could not connect to $ssid"
elif [[ "$choice" == *" open "* ]]; then
  nmcli device wifi connect "$ssid" && note "Connected to $ssid" || note "Could not connect to $ssid"
else
  pw=$(menu -password -p "Password for $ssid" -lines 0 </dev/null)
  [[ -z "$pw" ]] && exit 0
  nmcli device wifi connect "$ssid" password "$pw" && note "Connected to $ssid" || note "Could not connect to $ssid"
fi

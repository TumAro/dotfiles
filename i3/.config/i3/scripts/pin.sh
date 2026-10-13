#!/usr/bin/env bash
# Toggle: pin the focused window's app to the current workspace.
# Pinned apps open there and jump you to it. Rules live in ~/.config/i3/pinned.conf.
f="$HOME/.config/i3/pinned.conf"; touch "$f"
IFS=$'\t' read -r class ws < <(i3-msg -t get_tree | python3 -c '
import json,sys
def walk(n,ws=None):
    if n.get("type")=="workspace": ws=n["name"]
    if n.get("focused") and n.get("window_properties"):
        print(n["window_properties"].get("class","")+"\t"+(ws or "")); sys.exit()
    for c in n.get("nodes",[])+n.get("floating_nodes",[]): walk(c,ws)
walk(json.load(sys.stdin))')
[[ -z "$class" ]] && exit 0
# unnamed workspace (just a number): name it after the app so the bar shows what lives there
if [[ "$ws" =~ ^[0-9]+$ ]]; then
  new="$ws:${class,,}"
  i3-msg "rename workspace \"$ws\" to \"$new\"" >/dev/null
  ws="$new"
fi
rule="for_window [class=\"^${class}\$\"] move container to workspace \"$ws\", workspace \"$ws\""
if grep -qF "[class=\"^${class}\$\"]" "$f"; then
  grep -vF "[class=\"^${class}\$\"]" "$f" > "$f.tmp"; mv "$f.tmp" "$f"; msg="Unpinned $class"
else
  echo "$rule" >> "$f"; msg="Pinned $class to $ws"
fi
i3-msg reload >/dev/null
command -v notify-send >/dev/null && notify-send "$msg"
exit 0

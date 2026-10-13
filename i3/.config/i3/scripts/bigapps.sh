#!/usr/bin/env bash
# Move big apps (see ~/.config/i3/bigapps.conf) to their own workspace, named "N:app", and jump there.
# Runs in the background from i3; reconnects after an i3 restart.
conf="$HOME/.config/i3/bigapps.conf"
while true; do
  i3-msg -t subscribe -m '["window"]' 2>/dev/null | python3 -c '
import json,re,subprocess,sys,os
pats=[l.strip() for l in open(sys.argv[1]) if l.strip() and not l.startswith("#")]
rx=re.compile("^(?:%s)$"%"|".join(pats),re.I)
def i3(cmd): subprocess.run(["i3-msg",cmd],capture_output=True)
for line in sys.stdin:
    try: ev=json.loads(line)
    except ValueError: continue
    if ev.get("change")!="new": continue
    c=ev["container"]; cls=(c.get("window_properties") or {}).get("class","")
    if not rx.match(cls): continue
    app="game" if cls.lower().startswith("steam_app_") else cls.lower()
    ws=json.loads(subprocess.run(["i3-msg","-t","get_workspaces"],capture_output=True,text=True).stdout)
    names=[w["name"] for w in ws]
    hit=[n for n in names if n.split(":",1)[-1]==app]
    if hit: target=hit[0]
    else:
        used={int(re.match(r"\d+",n).group()) for n in names if re.match(r"\d+",n)}
        k=4
        while k in used: k+=1
        target="%d:%s"%(k,app)
    i3("[con_id=%d] move container to workspace \"%s\", workspace \"%s\""%(c["id"],target,target))
' "$conf"
  sleep 2
done

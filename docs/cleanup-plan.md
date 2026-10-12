# Dotfiles cleanup plan

Status: PLAN ONLY. Written 2026-10-13 against HEAD `99c5494`. Nothing has been changed yet.
`P=polybar/.config/polybar/forest`. All commands run from the repo root.

## 1. Evidence table (candidate removals)

Bar uses only `workspaces date temp-alert battery-alert alsa` (`grep -n modules- $P/config.ini`, lines 33-35; `launch.sh` sets `BAR_MODULES_RIGHT="temp-alert alsa"` on hosts other than gyrobook).

| Candidate | Proof command | Result | Verdict |
|---|---|---|---|
| 27 polybar modules: backlight battery cpu filesystem memory mpd wired-network wireless-network network pulseaudio temperature keyboard title discord obsidian browser gpu updates launcher sysmenu color-switch apps term files settings powermenu menu | `for m in ...; do grep -rnE "(^\|[ \"=])$m([ \"]\|$)" $P/*.ini \| grep -v '\[module/'; done` | Hits are comments only (e.g. `; Seconds to sleep between updates`), `battery = BAT1` (a key, not a module ref), `click-left = obsidian &` (a command) | DEAD |
| `apps` (base module) | `grep -n inherit $P/*.ini` | inherited only by `term`, `files`, `settings` (user_modules.ini:127,135,142), all dead | DEAD with its children |
| `sep` | same grep | only `sep = #4D5566` in colors.ini (a colour, not a module ref) | module DEAD; **keep the colour** unless grep shows `${color.sep}` unused |
| `scripts/styles.sh` | `grep -rn styles.sh .` | only `style-switch.sh` | DEAD (transitive) |
| `scripts/style-switch.sh` | `grep -rn style-switch.sh .` | only modules `launcher`/`color-switch` (user_modules.ini:87,111), both dead | DEAD |
| `scripts/rofi/styles.rasi` | `grep -rn styles.rasi .` | only `style-switch.sh` | DEAD |
| `scripts/updates.sh` | `grep -rn updates.sh .` | only module `updates` (user_modules.ini:29), dead | DEAD |
| `scripts/checkupdates` | `grep -rn checkupdates .` | only `updates.sh` | DEAD |
| `scripts/rofi/networkmenu.rasi` | `grep -rn networkmenu .` | no hits, but owner wants a network menu (see section 5) | **KEEP** (reused by the new nmcli menu) |
| `forest/launch.sh` | `grep -rn forest/launch.sh .` | only `install.sh:41` (`chmod +x`); i3 runs `~/.config/polybar/launch.sh` (i3 config:14) | DEAD (drop the install.sh line too) |
| `launcher.sh`, `powermenu.sh` | `grep -rn 'launcher.sh\|powermenu.sh' i3/` | i3 config:22, :102 | **KEEP** |
| `rofi/colors.rasi` | `grep -rn colors.rasi .` | imported by powermenu.rasi, confirm.rasi (live) | **KEEP** |
| `rofi/launcher.rasi`, `powermenu.rasi`, `confirm.rasi`, `message.rasi` | `grep -rn '<name>.rasi' .` | used by launcher.sh / powermenu.sh | **KEEP** |
| `temp-alert.sh`, `battery-alert.sh` | `grep -rn 'temp-alert\|battery-alert' .` | bar modules | **KEEP** |
| i3 `bindsym $mod+Tab exec rofi -show window` (i3 config:127) | `grep -n 'rofi\|mod+Tab' i3/.config/i3/config`; `grep -rn -- '-show window' .` | only line 127. The owner confirmed it is unused. The keep set is launcher.sh, powermenu.sh, colors/confirm/launcher/message/powermenu.rasi | REMOVE (owner-confirmed) |
| commented random-accent block in `launcher.sh` (lines 3-11) | read file | `FILE=` only used by commented `sed` | DEAD (cosmetic) |

Nothing marked UNVERIFIED for deletion. Not checked: whether `colors.ini` keys other than `sep` become unused after module removal. Do that as part of step 1.2 and leave any unclear key in place.

## 2. Phases

### Phase 0: safety baseline (risk: none)
1. `git status --short` is empty, then `git tag pre-cleanup`. Verify: `git tag -l pre-cleanup`.
2. Baseline captures, kept outside the repo:
   `polybar -c ~/.config/polybar/forest/config.ini main --dump=modules-right 2>&1 | tee /tmp/bar.before`;
   `i3 -C -c ~/.config/i3/config`; `for i in 1 2 3 4 5; do /usr/bin/time -f %e zsh -i -c exit; done 2>&1 | tee /tmp/zsh.before`;
   `bash -n install.sh .scripts/*.sh`; `bash .scripts/verify.sh`.
Rollback: n/a. Approval: none.

### Phase 1: dead code removal (risk: low; polybar diffs shown to the owner first)
1. Remove the 27 dead module blocks from modules.ini and user_modules.ini. Commit `polybar: drop unused modules`. Verify: restart the bar with `~/.config/polybar/launch.sh`, run `polybar --log=warning ... 2>&1 | grep -i error` (no output expected) and check the bar visually.
2. Remove `styles.sh style-switch.sh updates.sh checkupdates rofi/styles.rasi` (keep `rofi/networkmenu.rasi`, see section 5). Commit `polybar: drop unused scripts`. Verify: rerun the same `grep -rn` commands from section 1. Every hit should be gone.
3. Remove `forest/launch.sh` and `install.sh:41`. Commit `polybar: single launch.sh`. Verify: `bash -n install.sh`, then `i3-msg restart` and the bar comes back.
4. Remove the commented block in launcher.sh. Commit `rofi: tidy launcher`. Verify: press Super+space.
5. Fix `powermenu.sh:8` `dir="~/..."` to `dir="$HOME/.config/polybar/forest/scripts/rofi"` and quote `"$dir"` in line 11. Commit `rofi: fix tilde in powermenu path`. Verify: press Super+Escape; the menu and the confirm dialog both render. (Unverified whether it currently fails: rofi may expand `~` itself. The fix is safe either way.)
6. Remove the i3 binding at config:127 (`bindsym $mod+Tab exec rofi -show window`). Commit `i3: drop rofi window switcher`. Verify: `i3 -C -c ~/.config/i3/config`, then `i3-msg reload`; Super+Tab does nothing, and Super+space and Super+Escape still work. Check that Super+Tab is not bound anywhere else: `grep -n 'mod+Tab' i3/.config/i3/config` is empty.
Rollback: `git revert <sha>` per step, or `git reset --hard pre-cleanup`. Approval: the owner sees the polybar diff before step 1 is applied and the i3 diff before step 6.

### Phase 2: zsh cleanup (risk: medium; a typo breaks the shell. Keep one terminal open while testing)
1. **Bug fix (verified):** `.zshrc:75` `A && B || C && D || true` evaluates as `((A&&B)||C)&&D`, so when `fdfind` exists it still runs `alias find='fd'`. Reproduced with `zsh -fc '<line>; alias find'`, which prints `find=fd`, and `fd` is not on this machine. Replace with `(( $+commands[fdfind] )) && alias find=fdfind`. Commit `zsh: fix find alias`. Verify: `zsh -ic 'alias find'` prints `fdfind`.
2. Consolidate PATH into one block (lines 124-126, 137, 152-157) using `typeset -U path`, `$HOME` instead of `/home/tumaro` (lines 149 and 157), and drop the installer-appended comments. Move `.zshrc.local` sourcing to the **last** line (it currently runs before the bun/opencode lines, so local overrides get clobbered). Move `alias buds` into the aliases section. Commit `zsh: single PATH block, local overrides last`. Verify: `zsh -ic 'print -l $path' | sort | uniq -d` is empty, and `zsh -ic 'command -v bun opencode hx cargo'` finds all four.
3. Optional, owner decision (Q2): lazy-load zinit with `zinit ice wait lucid`. Verify: average of 5 timed runs against `/tmp/zsh.before`.
Rollback: `git revert`; emergency shell `zsh -f`. Approval: Q1 and Q2.

### Phase 3: install script hardening (risk: medium; it is not run on this machine. Run it in Phase 5's container)
1. Fix STEP_TOTAL. Counting call sites gives 22 steps, not 24 (14 single `step_start` + 2 fonts + 4 cargo + 2 uv). Recount by hand before changing it. Commit `deps: correct step count`. Verify: the Phase 5 run shows `n/n`.
2. Pin the unpinned downloads: kitty, starship, zoxide, zinit (`HEAD`), rustup, nerd-fonts (`latest`), vesktop (`latest` via the API), tinymist (`--git` with no `--tag`). Prefer apt where 22.04 has the package (zoxide is in jammy, though old). Otherwise download a versioned release asset plus `sha256sum -c` against a checksum hard-coded in deps.sh. tdx publishes no checksums, so record a sha256 locally on first download (trust-on-first-use) and say so in a comment. One commit per tool. Verify: `grep -nE 'latest|HEAD|install.sh \| sh' .scripts/deps.sh` is empty.
3. Handle `uv`: deps.sh never installs it, so ruff and basedpyright fail on a fresh machine (verified by grep: `uv` appears only in the check). Either install it with a pinned release (same pattern as step 2) or drop those two tools. Commit `deps: install uv` (needs Q4).
4. Sync verify.sh with install.sh PKGS. Verified: verify.sh has no check for `vesktop` and no check for `tdx`. Add both. Commit `verify: cover vesktop, tdx`. Verify: `bash .scripts/verify.sh`.
Rollback: `git revert`. Approval: the owner runs anything that needs sudo. Agents only edit the scripts.

### Phase 4: appearance finish (risk: low)
1. kitty.conf:24-27: the comments describe `tall/stack/fat/grid`, but `enabled_layouts splits,tall,stack`. Rewrite the comments for the three enabled layouts. If zellij owns splits (Q3), reduce to `enabled_layouts stack`, drop the split keys (lines 45-46) and keep ctrl+t/q/tab. Commit `kitty: layouts match comments`. Verify: `kitty +runpy 'from kitty.config import load_config; load_config()'`, or open a new kitty window.
2. Add `picom/.config/picom/picom.conf` (blur with `glx`/`dual_kawase` and an opacity rule for kitty only) as a new stow package and add it to PKGS. i3 already runs `picom --daemon` (config:9). Commit `picom: config`. Verify: `picom --config ... --diagnostics`.
3. Vesktop: the owner enables `minimal.styles.css` in the app. No code change.
4. Ayu audit: `grep -rhoiE '#[0-9a-f]{6}' kitty i3 polybar zellij vesktop | sort | uniq -c` checked against theme/ayu-dark.md. Fix stray hex values by hand (the owner declined a generator). One commit.
Rollback: `git revert`. Approval: i3 diff if touched; picom blur strength (taste).

### Phase 5: clean-env verification + docs (risk: low)
1. Run `docker run --rm -it -v $PWD:/d ubuntu:22.04` → `apt install sudo git` → `bash /d/install.sh` (as a non-root user with sudo). The owner runs this because it needs root inside the container; that is not host sudo, but it is still the owner's call. Then check `verify.sh` passes and the log shows no `step_fail`.
2. Rewrite README: package list, zellij, tdx, typst/tinymist, theme/ayu-dark.md, the picom and Vesktop manual step, and keybinds in one table. Commit `docs: refresh README`.
3. `git tag post-cleanup`.

## 3. Other findings

| Sev | Finding | Status |
|---|---|---|
| High | `find` alias resolves to the missing `fd` (Phase 2.1) | verified |
| Med | `.zshrc.local` is sourced before the bun/opencode PATH lines, so overrides are lost | verified (line order 145 vs 149-157) |
| Med | `uv` is never installed by deps.sh, so ruff and basedpyright fail on a fresh box | verified by grep |
| Med | STEP_TOTAL=24 vs 22 counted call sites | counted, recheck |
| Med | Nerd fonts, Vesktop and tinymist pull `latest`/HEAD (not reproducible) | verified |
| Low | verify.sh is missing vesktop and tdx | verified |
| Low | `alias grep=rg` / `cat=bat` break pasted scripts that use grep or cat flags (`grep -P`, `cat -A`) | guess about impact; the alias exists |
| Low | `alias rm='rm -i'` plus `cp/mv -i` are fine interactively; scripts are unaffected | info |
| Low | yazi uses `apt install -f /tmp/yazi.deb` while delta and vesktop use `dpkg -i`. Inconsistent but works | verified, cosmetic |

## 4. Open questions (with recommended default)

1. Keep `grep/cat/find` aliased to rg/bat/fd? **Default: keep `cat`, drop the `grep` alias** (rg flags differ and will surprise you). Use `rg` directly.
2. Lazy-load zinit plugins? The gain is about 0.1-0.2s (estimated, not measured). **Default: skip.** 0.7s is acceptable, and lazy loading is "clever".
3. Do splits live in zellij only? **Default: yes.** kitty keeps tabs (ctrl+t/q/tab) and the `stack` layout.
4. uv: install it, or drop ruff and basedpyright from deps? **Default: install uv from a pinned release with a sha256.**
5. tdx has no upstream checksums. **Default: hard-code the sha256 of the current v0.14.0 binary (trust-on-first-use).**
6. Keep `sep` colour and the old forest palette keys in colors.ini? **Default: keep any key still referenced; delete the rest in Phase 4.4.**

## 5. Owner requests added after review

- Q3 changed: kitty keeps its own split keys for plain terminals; zellij is for repos only. So do NOT reduce `enabled_layouts` or drop kitty split keys in step 4.1; only fix the stale comments.
- **Network menu (new, Phase 4):** no network menu exists today. `networkmenu.rasi` is an orphan theme and nothing calls it; `nm-applet` is started by i3 but is not installed and the bar has no tray. Write a short `scripts/networkmenu.sh` using `nmcli` and `rofi -dmenu -theme networkmenu.rasi` (list Wi-Fi, connect, ask for a password with `rofi -password`, show active connection), bind it in i3 (default `Super+n`, after checking the key is free) and drop the `nm-applet` line if it stays unused. `nmcli` and `nmtui` are already installed; `networkmanager-dmenu` has no apt candidate on 22.04. Verify by hand on the laptop.
- **Desktop vs laptop (new, Phase 4):** `polybar/launch.sh` decides by `hostname == gyrobook`. Replace with hardware detection: laptop iff `ls /sys/class/power_supply/BAT*` succeeds. `battery-alert.sh` already exits silently with no `BAT1` (harden to glob `BAT*`). `temp-alert.sh` reads the Intel `x86_pkg_temp` zone only, so on an AMD desktop it prints nothing: add a fallback to `hwmon` `k10temp`/`coretemp`. The dGPU module is dead code and read-only; nothing ever powers the GPU off, so no desktop conditional is needed. `prime-run` and the steam wrappers in `zsh/.local/bin` are laptop-only (Optimus): keep them but make them no-ops when no NVIDIA/PRIME is present.

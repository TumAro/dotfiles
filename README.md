# dotfiles

Ubuntu 22.04, i3. Run `./install.sh` (needs sudo for apt; cargo builds take a while).
Theme: Ayu Dark everywhere, palette in `theme/ayu-dark.md`.

## What's included (stow packages)

| package | what |
| --- | --- |
| i3 | window manager, named workspaces (term, zen, notes) |
| polybar | thin bar: workspaces, date, volume; temp >50°C and battery <50% only when needed |
| picom | compositor, blur behind kitty and vesktop |
| kitty | terminal |
| zsh | zinit + starship + zoxide, `ws` workspace function |
| helix | editor, LSPs: basedpyright, ruff, tinymist, harper-ls |
| zellij | multiplexer, used on purpose via `ws` |
| yazi | file manager |
| vesktop | Discord theme (enable it in Vesktop settings) |
| git | delta pager, aliases |

`deps.sh` also installs: rustup, zellij, typst, tinymist, harper-ls (cargo), ruff and
basedpyright (uv), uv and tdx (pinned releases).

## Keys

| key | does |
| --- | --- |
| Super+t | terminal (plain kitty) |
| Super+z | Zen: focus it, or launch it |
| Super+space | app launcher (rofi) |
| Super+Escape | power menu (rofi) |
| Super+n | Wi-Fi menu (rofi + nmcli) |
| Super+1/2/3 | workspaces term / zen / notes |
| ws (in a repo) | zellij session named after the repo; run again to resume |

Inside zellij: `Alt+s` pane right, `Alt+d` pane down, `Alt+t` new tab, `Alt+[` / `Alt+]` switch tab,
`Alt+arrows` move focus, `Alt+m` todo (tdx), `Alt+y` yazi, `Alt+q` detach, `Ctrl+g` lock/unlock.

## Layouts

`ws` uses `.zellij/work.kdl` in the repo if present, otherwise `zellij/.config/zellij/layouts/work.kdl`
(claude + shell on the left 30%, helix on the right).

## Do manually after install

- enable the theme in Vesktop (Settings, Themes)
- put secrets and machine aliases in `~/.zshrc.local` (not tracked)
- ssh keys (not tracked), pdf viewer, audio stack, clipboard manager
- laptop vs desktop: polybar drops the battery module when there is no `/sys/class/power_supply/BAT*`

## Notes

- `install.sh` has not been run end to end on a clean machine yet. Test it in an Ubuntu 22.04
  container before trusting it on a new one.
- kitty, starship, zoxide, zinit and rustup still use their upstream install scripts, unpinned.
- cleanup history and reasoning: `docs/cleanup-plan.md`

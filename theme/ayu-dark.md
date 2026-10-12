# Theme: Ayu Dark

Single reference for every app. Edit the app config by hand when changing a value here.

| name | hex | use |
| --- | --- | --- |
| bg0 | `#0a0e14` | terminal / editor background |
| bg1 | `#0f131a` | panels |
| bg2 | `#151a22` | raised surfaces |
| bg3 | `#1c222c` | hover |
| bg4 | `#252c38` | selection |
| bg5 | `#2d3542` | borders |
| fg | `#b3b1ad` | text |
| grey0 | `#4d5566` | comments, dim |
| grey1 | `#6c7380` | muted text |
| grey2 | `#8a919e` | secondary text |
| red | `#ff3333` | error |
| orange | `#ff8f40` | warning |
| yellow | `#e6b450` | accent, cursor |
| green | `#c2d94c` | success |
| aqua | `#95e6cb` | |
| blue | `#59c2ff` | links, info |
| purple | `#d2a6ff` | |

Bases (bg0, fg, yellow, ANSI colours) come from the existing kitty `colors.conf` (Gogh Ayu Dark).
bg1-bg5, grey1-grey2 and purple are my own steps between bg0 and fg and are not from an upstream ayu file.

## Where each is set

- kitty: `kitty/.config/kitty/colors.conf`
- helix: `theme = "ayu_dark"` in `helix/.config/helix/config.toml`
- vesktop: `vesktop/.config/vesktop/themes/minimal.styles.css` (adapted from timothee's minimal.styles.css, Everforest values replaced)

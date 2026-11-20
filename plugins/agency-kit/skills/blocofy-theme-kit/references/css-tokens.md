# CSS token system (design-dna.json → :root)

The first block of `asset/theme.css` is the only place brand values appear.
Map from the design DNA contract:

| design-dna field | Token | Notes |
|---|---|---|
| `color.primary` | `--xy-ink` or `--xy-brand` | role decided by DNA `role` field |
| `color.accent` | `--xy-accent` | **record the on-accent text color too** (`--xy-on-accent`) — contrast is a DNA-level decision, not per-component improvisation |
| `color.neutral.scale` | `--xy-bg`, `--xy-surface`, `--xy-line`, `--xy-mut` … | name by role, not by shade |
| `color.dark_sections` | `--xy-dark`, `--xy-dark-ink` | avoid pure #000 unless DNA says so |
| `typography.display/body/mono` | `--xy-font-display`, `--xy-font-body`, `--xy-font-mono` | load via Google Fonts `<link>` in layout |
| `shape.radius` | `--xy-r-card`, `--xy-r-btn` | |
| `layout.container` | `--xy-max`, `--xy-gutter` | use `clamp()` gutters |

Rules:

- Components consume **only tokens**. A literal hex outside `:root` fails review.
- Accent-on-dark vs text-on-accent: define both directions as tokens up front;
  WCAG AA for body text is a hard gate.
- Support the platform token hook: keep `:root{ {{ theme_css }} }` in the
  layout so panel-side appearance settings can inject values.
- Signature texture/utility classes (rulers, tags, display headings) live next
  to tokens as a small utility layer, prefixed like everything else.

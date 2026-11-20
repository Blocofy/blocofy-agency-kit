# CSS token system (design-dna.json → :root)

The first block of `asset/theme.css` is the only place brand values appear.
Map from the design DNA contract (v2 field names, exactly as in
`blocofy-orchestrator` `references/contracts/design-dna.md`):

| design-dna field | Token | Notes |
|---|---|---|
| `color.primary.hex` | `--xy-brand` | used as `color.primary.role` says |
| `color.accent.hex` | `--xy-accent` | |
| `color.accent.on_accent` | `--xy-on-accent` | text on accent, AA; contrast is a DNA-level decision, not per-component improvisation |
| `color.neutrals.{bg,surface,line,muted,ink}` | `--xy-bg`, `--xy-surface`, `--xy-line`, `--xy-mut`, `--xy-ink` | named by role, not by shade |
| `color.dark.{bg,ink}` | `--xy-dark`, `--xy-dark-ink` | avoid pure #000 unless `color.notes` says so |
| `typography.display` | `--xy-font-display` | `family` + `weights` decide the `@font-face` rules (§ Fonts) |
| `typography.body` | `--xy-font-body` | same |
| `typography.mono_or_accent_face` | `--xy-font-mono` | add the token only when the DNA names a face; apply it as `usage` says |
| `shape.radius_card` | `--xy-r-card` | |
| `shape.radius_button` | `--xy-r-btn` | |
| `layout.container` | `--xy-max` | |
| `layout.gutters` | `--xy-gutter` | use `clamp()` |

Rules:

- Components consume **only tokens**. A literal hex outside `:root` fails review.
- Accent-on-dark vs text-on-accent: define both directions as tokens up front;
  WCAG AA for body text is a hard gate.
- Support the platform token hook: keep `:root{ {{ theme_css }} }` in the
  layout so panel-side appearance settings can inject values.
- Signature texture/utility classes (rulers, tags, display headings) live next
  to tokens as a small utility layer, prefixed like everything else.

## Fonts

Self-hosted woff2 is the default. No `<link>` or `@import` to Google Fonts or
any other font host: it sends every visitor's IP address to a third party
before consent.

- Upload each woff2 file to the site's media library (upload recipe: platform
  `references/media.md`; state the type, `type=font/woff2`) and use the returned CDN URL in an
  `@font-face` rule at the top of `asset/theme.css`, one rule per weight and
  style in the DNA's `weights`, with `font-display: swap`.
- The subset must cover every letter of the site's languages (Turkish needs
  ç ğ ı İ ö ş ü and their capitals). Check before uploading; a missing glyph
  falls back to another face in the middle of a word.
- In the layout head, `preload` only the one or two faces used above the
  fold: `<link rel="preload" as="font" type="font/woff2" href="…" crossorigin>`.
- Set the site's appearance fonts (`font_heading`, `font_body`) to `theme`.
  With that value the platform writes no font variable and loads nothing from
  Google Fonts; a `system-*` key also loads nothing; any other key makes the
  platform load that face from Google Fonts.

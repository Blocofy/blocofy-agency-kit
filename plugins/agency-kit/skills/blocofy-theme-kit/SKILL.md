---
name: blocofy-theme-kit
description: Conventions for writing Blocofy themes that turn a design-dna.json into valid, accessible Liquid sections - section anatomy with {% schema %}, CSS token system, chrome header/footer pattern, legacy alias sections, GSAP/Lenis motion adapter and per-section closing checklist. Use when building or editing Blocofy theme files (layout, section, asset). TR triggers - tema yaz, section olustur, tema iskeleti, chrome, header footer.
---

# Blocofy Theme Kit

How to write Blocofy themes with this kit. Input: `.blocofy-build/design-dna.json`
(contract owned by blocofy-orchestrator). Output: a theme directory pushed to a
draft instance via `blocofy-platform` recipes.

## Non-negotiables

1. **Original code only.** Reference sites inform structure and rhythm; every
   line of Liquid/CSS/JS is written fresh. No copied markup, no copied copy.
2. **Tokens first.** All colors/type/radii come from CSS custom properties in
   `asset/theme.css` `:root`, mapped from design-dna (`references/css-tokens.md`).
   No literal brand hex outside the token block.
3. **Prefix discipline.** Pick a 2-3 letter theme prefix (e.g. `xy-`) and use it
   for every class. New themes share **zero** section names with older themes
   on the same site, except deliberate alias sections.
4. **Sections are content-agnostic.** All copy/media arrive via `{% schema %}`
   settings/blocks with sensible presets — never hardcode client facts.
5. **Every section closes the checklist** (`references/section-checklist.md`):
   schema valid, empty-state safe, responsive, a11y, reduced-motion, no-JS.

## Standard stack (declared in `layout/theme.liquid`)

- GSAP 3.13 + ScrollTrigger (CDN) · Lenis 1.3.x (CDN + official bridge)
- Google Fonts, per-project pairing chosen in the concept phase — never
  default to the "AI default" look; the design DNA names the faces.
- Styling: plain CSS custom properties by default; **Tailwind is allowed** when
  the project prefers it. Blocofy serves static assets, so compile locally
  (`tailwindcss` CLI → one built CSS pushed as `asset/theme.css`; the Play CDN
  is for prototyping only, never production). Either way, brand values still
  live as CSS custom properties / `@theme` tokens mapped from design-dna
  (`references/css-tokens.md`) — utilities consume tokens, never literals.
- Vanilla JS in `asset/app.js`; Alpine only if state genuinely demands it.

## Native UI first, and who wins on conflict

- **Interactive UI uses the platform primitive before custom JS**: `<dialog>`
  for modals, the Popover API for menus/drawers/tooltips, `<details>` for
  disclosure, native constraint validation for forms
  (`references/a11y-nojs.md` § Native UI primitives).
- **Browser support policy (default).** Baseline Widely available features
  are used freely. Newly available features are allowed only when they
  degrade gracefully or the fallback is ≤ 20 lines with no extra dependency;
  otherwise pick the older pattern. A tenant `CLAUDE.md` line starting
  `**Browser Support:**` overrides this default.
- **Optional companion: the `modern-web-guidance` skill.** When it is
  installed, search it while writing dialogs, popovers, menus, form
  validation/autofill, tables and image priority. It never overrides this
  kit. Precedence, highest first: this skill's non-negotiables and token
  system → the motion adapter (**all scroll, reveal, parallax and pin motion
  stays GSAP + Lenis**; do not replace it with CSS scroll-driven animations
  or View Transitions because a guide suggests it) → the a11y/no-JS gates →
  Modern Web Guidance for everything those leave open. If it is not
  installed, proceed without it.

## Build order for a new theme

0. Confirm the orchestrator's provenance decision (`themeOrigin` in STATE.md):
   greenfield = skeleton below; existing = pull OUR instance and skip step 1.
   Never base new design work on a pulled platform-default theme.
1. Copy `assets/skeleton/` → tenant `theme/` dir; set prefix, fonts, tokens.
2. Write the section vocabulary from the design DNA's section list — one
   Liquid file per section, presets filled with neutral placeholder copy.
3. Chrome: header + footer sections (`areas`) + alias/legacy handling
   (`references/chrome-pattern.md`).
4. Motion pass last, over working static sections
   (`references/motion-adapter.md`; consult `gsap-skills` modules for depth:
   `gsap-scrolltrigger` for pin/scrub, `gsap-performance` before shipping).
5. Push draft (`blocofy theme push <dir> --draft --name "…"`), then iterate
   with `blocofy theme dev` (local render + sync) and check the draft through
   per-page preview links (platform SKILL §3).

## References

| File | Content |
|---|---|
| `references/section-anatomy.md` | Liquid + `{% schema %}` patterns, settings/blocks/presets, bindable fields, alias sections |
| `references/css-tokens.md` | design-dna.json → `:root` token mapping table |
| `references/chrome-pattern.md` | header/footer groups, position:0 prepend, PATCH/DELETE, `partial/header\|footer` fallback, JS dedupe, legacy alias strategy |
| `references/motion-adapter.md` | Lenis↔ScrollTrigger bridge, CDN integrity rule, entrance/scrub/pin/counter/marquee recipes, video autoplay policy |
| `references/a11y-nojs.md` | reduced-motion contract, no-JS fallbacks, native UI primitives (dialog/popover/forms), contrast and focus rules |
| `references/section-checklist.md` | per-section definition of done |
| `assets/skeleton/` | minimal valid theme to copy as a starting point |

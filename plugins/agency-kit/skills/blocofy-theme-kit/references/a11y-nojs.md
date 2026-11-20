# Accessibility, reduced motion, no-JS

Hard gates — a section that fails any of these is not done.

## Reduced motion

- Single source of truth: `prefers-reduced-motion`. Handle it twice:
  - CSS: `@media (prefers-reduced-motion: reduce)` neutralizes decorative
    transforms/animations.
  - JS: under reduced motion the head script never arms motion, so nothing is
    hidden and counters keep their server-rendered final text; a
    `gsap.matchMedia()` branch handles a switch while the page is open
    (see motion-adapter).
- Smooth scroll (Lenis) is not initialized under reduced motion.
- Test with Playwright `page.emulateMedia({ reducedMotion: 'reduce' })`:
  zero hidden `[data-reveal]`, all counters final, no console errors.

## No-JS

- An inline `<head>` script adds `.xy-motion` to `<html>`; all "hidden until
  animated" styles are scoped under it, so content is fully visible without
  JS. The same script removes the class after 2.5 s if `app.js` has not
  signalled (motion-adapter.md § Hidden-state failsafe).
- Accordions prefer native `<details>/<summary>`; custom toggles need a
  sensible default-open state without JS.
- Forms must be plain HTML `method="post" action=…` capable — fetch submit is
  an enhancement.

## Native UI primitives

Reach for the element that already ships focus handling, `Esc` and top-layer
stacking; hand-written equivalents are a review finding unless the reason is
noted next to the code.

- **Modal** (lightbox, confirm, full-screen mobile menu): `<dialog>` opened
  with `showModal()`. Always a visible close button and an accessible name
  (`aria-labelledby`). Backdrop-click close via `closedby="any"` is not yet in
  every browser, so pair it with the feature-detected click fallback.
- **Non-modal overlay** (dropdown, mega menu, drawer, tooltip): the Popover
  API (`popover` + `popovertarget`) instead of class toggles plus
  outside-click and `Esc` listeners.
- **Disclosure**: `<details>/<summary>` (as above).
- **Forms**: keep native validation — no blanket `novalidate`. Style errors
  with `:user-invalid` (shows only after the visitor has interacted), set
  `autocomplete` and the right `type`/`inputmode` on every personal-data
  field, and tie each message to its input with `aria-describedby`.
- No-JS still holds: a `<dialog>` or popover that needs script to open must
  have its content reachable another way (inline section or a plain link).

Under the default browser support policy (theme-kit SKILL), anything here
that is not Baseline Widely available needs its documented fallback.

## Baseline a11y

- Skip link to `#main`, its text in the site's language: the skeleton prints
  the theme setting `settings.skip_link_label` (declare it as a `text` field
  in `config/settings_schema.json`; on a multilingual site the platform
  resolves a theme setting to the active language) with an English default.
  Semantic landmarks (`header/main/footer/nav[aria-label]`).
- One `h1` per page; heading levels don't skip.
- Body text contrast AA (4.5:1). Accent-colored text only at large sizes, and
  the on-accent text color is a token (css-tokens.md).
- Every interactive element keyboard-reachable; `aria-expanded` on accordions,
  `aria-live="polite"` on form status, `alt` on informative images
  (empty `alt` + `aria-hidden` for decorative).
- Videos: muted, no autoplaying audio ever; controls or clearly decorative.

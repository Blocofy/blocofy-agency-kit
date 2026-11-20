# Playwright traps on Blocofy + Lenis sites

## Loader pattern

Resolve playwright via `createRequire` with a bare `"playwright"` candidate so
scripts work wherever `npm i playwright` happened (workspace or shared dir).
Launch headless; fall back to `channel: "chrome"` on failure.

## Trap list

1. **Stale preview link** → page silently serves LIVE content; selectors from
   the draft theme return 0 matches. Check `expires_at` FIRST
   (`list_preview_links` or the cached create response in
   `.blocofy-build/session/`). Links pin theme files + settings at creation:
   regenerate after a push or settings change.
2. **Lenis vs synthetic scroll** — `window.scrollTo` gets re-lerped;
   `scrollIntoViewIfNeeded` can hang until timeout. Use `mouse.wheel` loops
   (real wheel events feed Lenis) or instant scroll + ≥1.2s settle + re-read
   `window.scrollY` before asserting.
3. **Mid-animation screenshots** — GSAP entrances run ~0.6-1s; a screenshot
   right after scroll catches `autoAlpha` mid-flight (looks "blank"). Wait
   1200ms+ after reaching a section.
4. **Scrub effects read as "broken" at rest** — a scale/parallax scrub target
   measured before its trigger range shows the *from* state; measured after,
   the *to* state. Assert progress-dependent values via
   `ScrollTrigger.getAll().find(...)` progress, not raw transforms.
5. **Headless video autoplay** — `paused: true` at load is normal; assert
   playback after calling `v.play()` or after the ScrollTrigger enter handler
   fires. Real browsers with `muted playsinline` behave better than headless.
6. **One link = one page** — `goto` each route's own preview link;
   navigating by path from a link shows live content.
7. **Console noise policy** — collect `console.error` only; treat any error as
   a failure; log first 3 messages in the report.

## Verify-page sweep

```bash
node scripts/verify-page.mjs "<link for />" "<link for /about>" "<link for /contact>"
```

Reports per link: HTTP status, console errors, unknown-section count, and
writes screenshots to `./qa-shots/`.

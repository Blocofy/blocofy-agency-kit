---
name: blocofy-qa
description: Verification and publish gate for Blocofy sites - Playwright recipes against per-page draft preview links (expiry, settings pinning, Lenis-vs-scrollTo traps, wheel simulation, reduced-motion emulation), console/error sweeps, and the site_readiness pre-publish checklist. Use before publishing and whenever verifying a change end-to-end. TR triggers - dogrula, kontrol et, yayina hazir mi, test et, onizleme.
---

# Blocofy QA

Nothing ships on "should work". Every claim of done is backed by a rendered
page, a console count and a screenshot.

## The three verdict sources (in order of trust)

1. **DOM queries via Playwright** — element presence, class states, computed
   styles, video `paused/currentTime`, ScrollTrigger progress.
2. **Playwright screenshots** — full-size, inspected visually.
3. In-app browser panes — convenience only; their screenshot pipeline can
   return blank frames on light-toned sections. Never fail a build on pane
   screenshots alone; re-verify with Playwright.

## Preview access (the #1 source of false alarms)

- The `theme dev` signed Preview URL is **retired on the server**
  (2026-10-31). Use per-page links:
  `POST /api/v1/themes/<theme handle>/preview-links {"page": "<page handle>"}` (MCP
  `create_preview_link`). One link per route under test, ~24h, the `url` is
  returned once — save it under `.blocofy-build/session/`.
- A link shows the draft **only on its own page**; clicking through to another
  route shows live content. Sweep routes by opening each route's own link, not
  by navigating within one.
- **Expired or revoked link silently renders live content** — before debugging
  any "my changes vanished" report, check the link's age / `list_preview_links`.
- The link **pins the draft's theme files and theme settings at creation**.
  After any `theme push` or theme-settings change (logo, colors, contact),
  generate fresh links before re-verifying, or you'll see the old state and
  misdiagnose. Collection lists on a link show published entries only.
- Revoke sweep links when done (`DELETE /api/v1/preview-links/{id}`).
- Draft-instance pages are only visible through preview links / the editor —
  the local dev server renders live-instance pages with local theme files.

## Motion-aware testing rules

- With Lenis active, `window.scrollTo` fights the smooth-scroll loop and
  `scrollIntoViewIfNeeded` can time out. For user-realistic checks use
  `page.mouse.wheel(0, Δ)` loops; for teleporting use
  `scrollTo({top, behavior:'instant'})` **then wait ≥1.2s** and re-assert.
- Entrance animations take ~1s — screenshot after `waitForTimeout(1200+)` or
  you'll capture half-faded frames and misdiagnose.
- Scroll-driven pins/snaps: verify by wheel-walking through the section and
  recording state transitions, not by jumping to computed offsets.
- Reduced-motion pass is mandatory:
  `page.emulateMedia({reducedMotion:'reduce'})` → all `[data-reveal]` visible,
  counters final, zero console errors.

## Standard sweeps

- **Page sweep**: for each route — HTTP 200, `console.error` count 0,
  "unknown section" marker count 0, one screenshot.
- **Interaction sweep**: accordions, pinned tabs, forms (fill + submit to a
  test form key or assert fetch wiring), video play/pause on enter/leave.
- **Responsive sweep**: 390 / 768 / 1440 screenshots; no horizontal page scroll.
- `scripts/verify-page.mjs` runs the page sweep for a list of per-page preview links.
- `scripts/reference-recon.mjs` records a reference site's structure, type,
  colour and tech signals with screenshots (orchestrator Phase 1,
  `reference-recon.md`). It is a study aid, not a QA gate.
- **Legacy-pattern sweep (optional, needs network)**:
  `scripts/legacy-scan-liquid.sh <theme-dir> --json` runs the
  `modern-web-guidance` scanner over the theme, Liquid included (the scanner
  skips `.liquid`, so the script scans a renamed temp copy). It covers only
  ~20% of that catalog, so zero findings is not a clean bill. Check every
  finding against its `keepWhen`/`dropWhen` rubric before acting — row
  dividers flagged as fake underlines are a known false positive. A missing
  `integrity` on a CDN tag is always a real finding. Findings that would
  replace GSAP/Lenis motion are dropped (theme-kit precedence rule).

## Publish gate (Phase 7 prerequisite)

Run `site_readiness` (MCP) + `references/readiness-checklist.md`. Publishing a
theme or writing to the live instance always requires explicit human approval.

## References

- `references/playwright-traps.md` — full trap list with code snippets
- `references/readiness-checklist.md` — pre-publish human checklist

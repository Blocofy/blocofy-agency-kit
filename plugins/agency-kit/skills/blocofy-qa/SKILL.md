---
name: blocofy-qa
description: Use when a change to a Blocofy site has to be verified in a rendered page or before asking for publish approval (TR - doğrula, kontrol et, yayına hazır mı, test et, önizleme; ASCII - dogrula, yayina hazir mi, onizleme), when a draft preview shows old or unexpected content, or when a Playwright check on a draft is flaky (smooth scroll, entrance animations, reduced motion).
compatibility: Needs Node 22.20+ with Playwright and a browser installed in the site folder, a Blocofy site and its keys, network access; the blocofy MCP server or CLI. The optional legacy scan needs bash, Node 22.20+ and npx. Written for any Agent Skills client; tested in Claude Code.
---

# Blocofy QA

Nothing ships on "should work". Every claim of done is backed by a rendered
page, a console count and a screenshot.

## Terms

- **Site folder**: the one folder that holds this site's `.env.local`,
  `.blocofy-build/` and theme. Run every command from there; Playwright is
  installed there (`npm i playwright && npx playwright install chromium`)
  and the scripts resolve it from there.
- **`<skill-dir>`**: the folder this SKILL.md was loaded from. Your agent shows
  it when it loads the skill; if it does not, find it with
  `find ~ . -maxdepth 6 -type d -name blocofy-qa -path '*skills*' 2>/dev/null | head -1`.
  Scripts are always run through the interpreter:
  `node <skill-dir>/scripts/….mjs`, `bash <skill-dir>/scripts/….sh`.
- **Other skills** are named plainly ("load the `blocofy-platform` skill");
  some agents show a prefix, for example `agency-kit:blocofy-platform` in
  Claude Code.
- **MCP tools**: "`site_readiness` (MCP)" means that tool of the MCP server
  registered as `blocofy`; agents prefix tool names differently.

## The three verdict sources (in order of trust)

1. **DOM queries via Playwright** — element presence, class states, computed
   styles, video `paused/currentTime`, ScrollTrigger progress.
2. **Playwright screenshots** — full-size, inspected visually.
3. The agent's built-in browser pane or preview, where it has one —
   convenience only; its screenshot pipeline can
   return blank frames on light-toned sections. Never fail a build on pane
   screenshots alone; re-verify with Playwright.

## Preview access (the #1 source of false alarms)

Two ways to see a draft; pick by route type.

- **Local view (`blocofy theme dev`, `http://127.0.0.1:<port>`)**: renders
  your local theme files with the draft's saved content, and you can move
  between pages, collection detail (dynamic template) pages included. It
  never shows the live site. Forms are not submitted from it, and scripts'
  fetch/XHR calls to the live site or third parties are blocked there. It
  prints no shareable remote link. **Dynamic template routes are verified
  here**: no preview link exists for them.
- **Per-page preview links** for static pages and for showing a page to
  someone else:
  for a theme work `POST /api/v1/theme-work/<wk handle>/preview-links`, for a
  draft theme outside a work
  `POST /api/v1/themes/<theme handle>/preview-links {"page": "<page handle>"}`
  (MCP `create_preview_link`). One link per route under test, ~24h, the `url` is
  returned once — save it under `.blocofy-build/session/`.
- A link shows the draft **only on its own page**; clicking through to another
  route shows live content. Sweep routes by opening each route's own link, not
  by navigating within one.
- **Expired or revoked link silently renders live content**, so a sweep can
  come back green on the wrong page. Pass `--expect "<text>"` to
  `verify-page.mjs` with a string that exists only in the draft; a page
  whose HTML lacks it fails. Before debugging any "my changes vanished"
  report, check the link's age / `list_preview_links`.
- A link shows the theme **as saved when a link was last created**, not your
  latest push. After any `theme push` or theme-settings change (logo, colors,
  contact), create a new link before re-verifying, or you'll see the old
  state and misdiagnose. Collection lists on a link show published entries only.
- Revoke sweep links when done (`DELETE /api/v1/preview-links/{id}`).

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

## Expectations from the design DNA

Read `.blocofy-build/design-dna.json` before the sweeps; it says what
"correct" is for this site.

- `motion.reduced_motion` is the fallback the reduced-motion pass asserts.
- `visual_language.vocabulary[].quota`: count each mark per page against its
  quota, and check its `never`.
- `motion.smooth_scroll: false` → no Lenis on the page;
  `motion.intensity: low` → entrance reveals only, no scrub or pin.

## Standard sweeps

- **Page sweep**: for each route, HTTP 200, 0 console errors, 0 uncaught
  exceptions, 0 failed page-resource requests, "unknown section" marker
  count 0, the `--expect` text present, one full-page screenshot.
- **Interaction sweep**: accordions, pinned tabs, forms (fill, then intercept
  the request and assert its fields: `references/playwright-traps.md`; a real
  submission stores a record and sends an e-mail, so it needs the human's
  yes), video play/pause on enter/leave.
- **Responsive sweep**: 390 / 768 / 1440 screenshots; no horizontal page scroll.
- `node <skill-dir>/scripts/verify-page.mjs [--expect "<text>"] <url>…` runs
  the page sweep
  for a list of per-page preview links or `theme dev` local URLs. A URL that
  times out or errors is reported as failed and the sweep goes on; the exit
  code is non-zero when any URL failed.
- `node <skill-dir>/scripts/reference-recon.mjs "<url>"…` records a reference
  site's structure, type,
  colour and tech signals with screenshots (orchestrator Phase 1,
  `reference-recon.md`). It is a study aid, not a QA gate.
- **Legacy-pattern sweep (optional, needs network)**:
  `bash <skill-dir>/scripts/legacy-scan-liquid.sh <theme-dir> --json` runs the
  scanner of the `modern-web-guidance` npm package (fetched by `npx`; no
  skill has to be installed) over the theme, Liquid included (the scanner
  skips `.liquid`, so the script scans a renamed temp copy). It covers only
  ~20% of that catalog, so zero findings is not a clean bill. Check every
  finding against its `keepWhen`/`dropWhen` rubric before acting — row
  dividers flagged as fake underlines are a known false positive. A missing
  `integrity` on a CDN tag is always a real finding. Findings that would
  replace GSAP/Lenis motion are dropped (theme-kit precedence rule). The
  scanner is pinned to an exact version and runs without the `BLOCOFY_*`
  variables in its environment.

## Publish gate (Phase 7 prerequisite)

Run `site_readiness` (MCP) + `references/readiness-checklist.md`. Publishing a
theme or writing to the live instance always requires explicit human approval.

## References

- `references/playwright-traps.md` — full trap list with code snippets
- `references/readiness-checklist.md` — pre-publish human checklist

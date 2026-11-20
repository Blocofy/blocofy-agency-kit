# Motion adapter (GSAP on Blocofy, Lenis when the DNA asks)

For correct GSAP usage depth, consult the official GSAP skills when they are
installed (`gsap-scrolltrigger`, `gsap-performance`, `gsap-timeline`, from
greensock/gsap-skills); otherwise GSAP's own documentation. They are
optional. This file covers only the Blocofy/theme-specific glue.

## What the design DNA switches on

GSAP + ScrollTrigger is the kit's default stack. The DNA's `motion` block
decides how much of it a theme uses:

- `motion.smooth_scroll: true` → load Lenis (script + `lenis.css`) and run
  the bridge below. `false` → no Lenis tag at all; the skeleton ships the two
  Lenis tags inside a Liquid comment for this reason.
- `motion.intensity: low` → entrance reveals only (hero entrance timeline and
  reveal-on-scroll). No scrub, parallax, pin, marquee or counter: at `low`
  the sections do not carry those attributes (`data-count`, `data-parallax`
  …), so the code that reads them finds nothing to run.
  `medium` / `high` → the recipes named in `motion.recipes`.
- `motion.reduced_motion` → the fallback every recipe must provide
  (a11y-nojs.md).

## Loading order (layout/theme.liquid, end of body)

```html
<!-- dedupe guard script (chrome-pattern.md) -->
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/gsap.min.js" integrity="sha384-HOvlOYPIs/zjoIkWUGXkVmXsjr8GuZLV+Q+rcPwmJOVZVpvTSXQChiN4t9Euv9Vc" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/ScrollTrigger.min.js" integrity="sha384-P8VzCVnT9NBUkMrpcIZrJbA7EBjJvh/fJS6PmP+4nLIM284DtsImIv8D0fFjIkeh" crossorigin="anonymous"></script>
<!-- only when motion.smooth_scroll is true: -->
<script src="https://cdn.jsdelivr.net/npm/lenis@1.3.25/dist/lenis.min.js" integrity="sha384-ClD7pCgIUz5M81HT8aZmMxCsWmfsycmBiwL5gy1pUbdWHvICIbea22N9sTtAFotA" crossorigin="anonymous"></script>
<script>{% render 'asset/app.js' %}</script>
```

With Lenis, also `lenis.css` in the head (same rule; the skeleton carries its hash).

## CDN integrity

Every third-party `<script>` / `<link rel="stylesheet">` is pinned to an exact
version and carries `integrity` + `crossorigin="anonymous"`. A tag without
both is a review failure. The hash belongs to one exact file: changing the
version (or adding Alpine, a GSAP plugin, …) means recomputing it —

```bash
curl -s https://cdn.jsdelivr.net/npm/<pkg>@<version>/<path> | openssl dgst -sha384 -binary | openssl base64 -A
```

— and writing it as `integrity="sha384-<output>"`. Never use a version range
or `@latest`: the file changes, the hash stops matching and the browser
blocks the script. Fonts need no exception: they are self-hosted
(css-tokens.md § Fonts), so no font tag points at a third party.

## Hidden-state failsafe

Reveal targets start hidden, so a CDN script that hangs must not leave the
page blank. The skeleton layout and `app.js` implement this contract:

- Hidden start states exist only under `.xy-motion` on `<html>`. An inline
  head script adds the class; without JS it is never there.
- Under `prefers-reduced-motion: reduce` the head script does not add it.
- The head script removes the class after 2.5 s unless `app.js` has set
  `data-motion="on"` on `<html>`, which it does only once GSAP is present.
- `app.js` that arrives after the class was removed leaves the page as it is
  and starts no reveal animation.

## app.js frame

```js
(function () {
  "use strict";
  var root = document.documentElement;
  var hasGsap = typeof gsap !== "undefined" && typeof ScrollTrigger !== "undefined";
  var armed = root.classList.contains("xy-motion"); // false: reduced motion, or failsafe fired
  // 1) always-on vanilla bits first (clocks, accordions, menu): motion-independent
  if (!hasGsap || !armed) { root.classList.remove("xy-motion"); return; }
  root.setAttribute("data-motion", "on"); // signal to the head failsafe
  gsap.registerPlugin(ScrollTrigger);

  // 2) Lenis ↔ ScrollTrigger bridge (official pattern); Lenis exists only when the layout loads it
  var lenis = null;
  if (window.Lenis) {
    lenis = new Lenis();
    lenis.on("scroll", ScrollTrigger.update);
    gsap.ticker.add(function (t) { if (lenis) lenis.raf(t * 1000); });
    gsap.ticker.lagSmoothing(0);
  }

  var mm = gsap.matchMedia();
  mm.add("(prefers-reduced-motion: reduce)", function () { // switched while the page is open
    if (lenis) { lenis.destroy(); lenis = null; }
    root.classList.remove("xy-motion");
    gsap.set("[data-reveal]", { autoAlpha: 1, clearProps: "filter,transform" });
  });
  mm.add("(prefers-reduced-motion: no-preference)", function () { /* recipes */ });
})();
```

CSS side: `.xy-motion [data-reveal] { opacity: 0; visibility: hidden; }` only,
**no CSS transition** on reveal targets (GSAP owns the animation; a leftover
transition double-animates and fights `fromTo`).

## Recipe index

- **Entrance timeline (hero):** one `gsap.timeline` at load; word-level
  stagger needs `display:inline-block` on the animated inline spans.
- **Reveal-on-scroll:** `ScrollTrigger.batch("[data-reveal]", {start:"top 82%",
  once:true, onEnter: els => gsap.fromTo(els, {autoAlpha:0,y:30},
  {autoAlpha:1,y:0,stagger:.12})})`.
- **Parallax (scrub):** `gsap.fromTo(img, {yPercent:-8,scale:1.12},
  {yPercent:8, ease:"none", scrollTrigger:{trigger:panel, scrub:true}})` —
  parent needs `overflow: clip`.
- **Scale-into-place text:** per line `fromTo scale 2.1→1, autoAlpha .25→1,
  ease:"none", scrub, end:"top 42%"`.
- **Counters:** the number and its formatting are separate. Markup:
  `<span data-count="1250" data-count-locale="tr-TR">1.250</span>`.
  `data-count` is the plain number (dot as decimal mark, no grouping);
  `data-count-locale` (default: page language) and `data-count-decimals`
  (default 0) format each frame with `Intl.NumberFormat`; the element's own
  text is the final value, shown as is to no-JS and reduced-motion visitors
  and restored when the tween ends. Never parse the visible text: "1.250"
  would count to 1. Tween a plain object with a `once` trigger; no
  innerText-based rAF loops alongside GSAP.
- **Pinned tab section:** `ScrollTrigger.create({pin:true, start:"top top+=<header>",
  end: () => "+=" + rows*innerHeight*0.75, snap:1/(n-1), onUpdate: set active row})`.
  Desktop-only (`matchMedia("(min-width: 900px)")`), click fallback always works.
- **Background videos:** `autoplay muted loop playsinline` + poster; drive
  play/pause from a ScrollTrigger (enter=play, leave=pause) and call
  `v.play().catch(()=>{})` — autoplay is not guaranteed anywhere.
- **Infinite marquee:** duplicate the track once (`aria-hidden` copy),
  `gsap.to(track,{x:-half,repeat:-1,ease:"none"})`, pause on hover.

## Hard rules

- Animate transforms and opacity only. One exception: at `motion.intensity:
  high`, a short one-off entrance may also tween `filter` (blur) on a few
  elements, never in a scrub, always with `clearProps:"filter"`.
- `ScrollTrigger.refresh()` on window load.
- Scrub XOR toggleActions, never both. Top-level ScrollTriggers only.
- Every effect must degrade: reduced-motion path shows full content instantly.

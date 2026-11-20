# Motion adapter (GSAP + Lenis on Blocofy)

For correct GSAP usage depth, invoke the official `gsap-skills` modules
(`gsap-scrolltrigger`, `gsap-performance`, `gsap-timeline`). This file covers
only the Blocofy/theme-specific glue.

## Loading order (layout/theme.liquid, end of body)

```html
<!-- dedupe guard script (chrome-pattern.md) -->
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/gsap.min.js" integrity="sha384-HOvlOYPIs/zjoIkWUGXkVmXsjr8GuZLV+Q+rcPwmJOVZVpvTSXQChiN4t9Euv9Vc" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/gsap@3.13.0/dist/ScrollTrigger.min.js" integrity="sha384-P8VzCVnT9NBUkMrpcIZrJbA7EBjJvh/fJS6PmP+4nLIM284DtsImIv8D0fFjIkeh" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/lenis@1.3.25/dist/lenis.min.js" integrity="sha384-ClD7pCgIUz5M81HT8aZmMxCsWmfsycmBiwL5gy1pUbdWHvICIbea22N9sTtAFotA" crossorigin="anonymous"></script>
<script>{% render 'asset/app.js' %}</script>
```

Plus `lenis.css` in the head (same rule; the skeleton carries its hash).

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
blocks the script. Google Fonts CSS is the one exception (its response varies
per browser, so it cannot be hashed).

## app.js frame

```js
(function () {
  "use strict";
  var hasGsap = typeof gsap !== "undefined" && typeof ScrollTrigger !== "undefined";
  // 1) always-on vanilla bits first (clocks, accordions, menu) — motion-independent
  if (!hasGsap) { /* reveal everything, set counters to final values */ return; }
  gsap.registerPlugin(ScrollTrigger);

  // 2) Lenis ↔ ScrollTrigger bridge (official pattern)
  var lenis = null;
  if (window.Lenis && !matchMedia("(prefers-reduced-motion: reduce)").matches) {
    lenis = new Lenis();
    lenis.on("scroll", ScrollTrigger.update);
    gsap.ticker.add(function (t) { lenis.raf(t * 1000); });
    gsap.ticker.lagSmoothing(0);
  }

  var mm = gsap.matchMedia();
  mm.add("(prefers-reduced-motion: reduce)", function () {
    gsap.set("[data-reveal]", { autoAlpha: 1, clearProps: "filter,transform" });
    document.querySelectorAll("[data-count]").forEach(function (el) {
      el.textContent = el.getAttribute("data-count");
    });
  });
  mm.add("(prefers-reduced-motion: no-preference)", function () { /* recipes */ });
})();
```

CSS side: `.js [data-reveal] { opacity: 0; visibility: hidden; }` only —
**no CSS transition** on reveal targets (GSAP owns the animation; a leftover
transition double-animates and fights `fromTo`).

## Recipe index

- **Entrance timeline (hero):** one `gsap.timeline` at load; word-level
  stagger needs `display:inline-block` on the animated inline spans.
- **Reveal-on-scroll:** `ScrollTrigger.batch("[data-reveal]", {start:"top 82%",
  once:true, onEnter: els => gsap.fromTo(els, {autoAlpha:0,y:30,filter:"blur(14px)"},
  {autoAlpha:1,y:0,filter:"blur(0px)",stagger:.12, clearProps:"filter"})})`.
- **Parallax (scrub):** `gsap.fromTo(img, {yPercent:-8,scale:1.12},
  {yPercent:8, ease:"none", scrollTrigger:{trigger:panel, scrub:true}})` —
  parent needs `overflow: clip`.
- **Scale-into-place text:** per line `fromTo scale 2.1→1, autoAlpha .25→1,
  ease:"none", scrub, end:"top 42%"`.
- **Counters:** tween a plain object with `snap:{v:1}` + `once` trigger —
  never innerText-based rAF loops alongside GSAP.
- **Pinned tab section:** `ScrollTrigger.create({pin:true, start:"top top+=<header>",
  end: () => "+=" + rows*innerHeight*0.75, snap:1/(n-1), onUpdate: set active row})`.
  Desktop-only (`matchMedia("(min-width: 900px)")`), click fallback always works.
- **Background videos:** `autoplay muted loop playsinline` + poster; drive
  play/pause from a ScrollTrigger (enter=play, leave=pause) and call
  `v.play().catch(()=>{})` — autoplay is not guaranteed anywhere.
- **Infinite marquee:** duplicate the track once (`aria-hidden` copy),
  `gsap.to(track,{x:-half,repeat:-1,ease:"none"})`, pause on hover.

## Hard rules

- Animate transforms/opacity only; `ScrollTrigger.refresh()` on window load.
- Scrub XOR toggleActions, never both. Top-level ScrollTriggers only.
- Every effect must degrade: reduced-motion path shows full content instantly.

# Playwright traps on Blocofy + Lenis sites

## Loader pattern

Resolve playwright via `createRequire` with a bare `"playwright"` candidate so
scripts work wherever `npm i playwright` happened (workspace or shared dir).
Launch headless; fall back to `channel: "chrome"` on failure.

## Trap list

1. **Stale preview link** → page silently serves LIVE content; selectors from
   the draft theme return 0 matches. Check `expires_at` FIRST
   (`list_preview_links` or the cached create response in
   `.blocofy-build/session/`). After a push or a settings change create one
   new link for the theme (older links of that theme then show the new
   state too). Run the sweep with
   `--expect "<text only the draft has>"` so a stale link fails instead of
   passing on live content.
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
6. **One link = one page**: `goto` each route's own preview link;
   navigating by path from a link shows live content. Dynamic template
   routes have no link: open them in the `blocofy theme dev` local view
   (`127.0.0.1`), which renders the draft.
7. **Console noise policy**: collect `console.error`, uncaught exceptions
   (`pageerror`) and failed requests; treat any console error or exception
   as a failure; log the first 3 messages in the report. A failed document,
   script, stylesheet, font or image request fails the page; failed
   fetch/XHR/media requests are only counted, because the local view blocks
   scripts' calls to the live site by design.

## Verify-page sweep

```bash
node scripts/verify-page.mjs --expect "<text only the draft has>" \
  "<link for />" "<link for /about>" "http://127.0.0.1:<port>/<a detail route>"
```

Reports per URL: HTTP status, console errors, uncaught exceptions, failed
requests, unknown-section count and the `--expect` result, and writes
full-page screenshots to `./qa-shots/`. Exit code 1 when any URL failed.

## Testing a form without submitting it

A real submission stores a record and sends the client a notification. Test
the wiring by catching the request before it leaves the browser:

```js
let sent = null;
await page.route("**/*", (route) => {
  const req = route.request();
  if (req.method() === "POST" && req.resourceType() !== "document") {
    sent = { url: req.url(), body: req.postData() };
    return route.abort();            // nothing reaches the server
  }
  return route.continue();
});
// fill the fields, click submit, then:
await page.waitForTimeout(500);
// assert on sent.url and sent.body: every field present, multi-selects complete
```

If the form posts as a full page navigation, match `resourceType() ===
"document"` with `method() === "POST"` instead. Submit for real only after the
human's yes (`blocofy-platform` `references/live-writes.md`), and tell them
which record to delete afterwards.

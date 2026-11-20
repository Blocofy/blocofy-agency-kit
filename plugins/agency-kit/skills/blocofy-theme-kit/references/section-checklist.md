# Section definition of done

Run per section before it counts as complete:

- [ ] Schema valid (name, category, settings labeled, sensible preset with
      neutral placeholder copy — no client facts)
- [ ] Every optional setting guarded (`!= blank`); renders cleanly when empty
- [ ] Every output goes through its filter: `escape` for text, `safe_url`
      for anything in `href`/`src`, `sanitize_html` for rich text
      (section-anatomy.md); link settings are `url` fields
- [ ] Listing sections render a designed empty state (no bare hole)
- [ ] Images through `image_url` with explicit width/format; `loading="lazy"`
      below the fold; hero media `fetchpriority="high"`
- [ ] Class names prefixed; zero collisions with other themes on the site
- [ ] Tokens only — no literal colors/fonts in the section CSS
- [ ] Responsive at 390 / 768 / 1440 (wide media may scroll inside itself,
      the page never scrolls horizontally)
- [ ] Reduced-motion + no-JS paths verified (a11y-nojs.md)
- [ ] Keyboard pass: focus visible, controls reachable, aria states correct
- [ ] Modals, menus, popovers and form validation use the native primitive
      (a11y-nojs.md § Native UI primitives); if `modern-web-guidance` is
      installed, the matching guide was searched before writing custom JS
- [ ] Any third-party `<script>`/`<link>` the section adds is version-pinned
      with `integrity` + `crossorigin` (motion-adapter.md § CDN integrity)
- [ ] Console clean when rendered with preset data
- [ ] If bindable: `$bind` fields verified on a dynamic route with a real
      entry, in the `blocofy theme dev` local view (`127.0.0.1`; it renders
      the draft, collection detail pages included). Preview links do not
      exist for dynamic template pages

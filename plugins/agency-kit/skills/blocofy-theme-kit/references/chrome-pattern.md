# Chrome pattern (site-wide header/footer)

Chrome groups belong to the theme instance and are shared by every page.
The platform offers add, read, update and delete (`PATCH` / `DELETE
/themes/{id}/chrome/{group}/{sectionId}`, per docs; see platform
`themes-instances.md`). Older instances may still carry prepended duplicates,
and add can fail outright for some sections, so keep the dedupe guard and the
partial fallback below.

## Standard flow for a new theme

1. Write `XyHeader.liquid` (`areas: ["header"]`) and `XyFooter.liquid`
   (`areas: ["footer"]`) with full presets.
2. New drafts inherit the previous theme's chrome entries (by type name).
   Ship **silent alias sections** for those legacy type names so nothing
   renders as an error (see section-anatomy).
3. Add your real chrome via REST with `position: 0` (prepend):
   `POST /themes/{id}/chrome {area, type, settings, blocks, position: 0}`
   (the MCP tool appends — order is not guaranteed; prefer REST).
   To change it later, `PATCH …/chrome/{group}/{sectionId}` instead of
   prepending a copy.
4. **Dedupe guard in the layout** (inherited entries and older prepend-to-update
   habits leave duplicates; keep it harmless):

```html
<script>
(function () {
  ['.xy-header', '.xy-footer'].forEach(function (sel) {
    document.querySelectorAll(sel).forEach(function (el, i) { if (i > 0) el.remove(); });
  });
})();
</script>
```

The first matching element wins, so a stray duplicate never shows twice.
The selectors must match the markup: the root element of the header body
carries the class `xy-header`, the footer's `xy-footer` (with your prefix).
If you name them differently, change the guard too.

## Fallback: empty group → `partial/header` / `partial/footer`

When a group is empty, the platform renders `partial/header` /
`partial/footer` (if present) into `header_html` / `footer_html`. Use it when
chrome add fails (seen 2026-10-31: blockless section, 422 without `blocks`,
500 with `blocks: []`) or as a safety net for any theme:

```
partial/xy-header-body.liquid   ← the actual markup, takes explicit params
partial/header.liquid           ← {% render 'partial/xy-header-body', menu_handle: settings.header_menu %}
section/XyHeader.liquid         ← {% render 'partial/xy-header-body', menu_handle: props.menu %} + {% schema %}
```

- Fallback and chrome section render the same body partial, so the output is
  identical whichever path runs; adding the section to chrome later is a
  no-visual-change switch that just makes it editor-manageable.
- The body partial takes explicit params: `partial/header` passes
  `settings.*` (theme settings, since the fallback has no section settings of
  its own), the section passes `props.*` with defaults matching those theme
  settings. Don't make the section read theme settings — its editor fields
  would then do nothing.
- The fallback renders only for an **empty** group: delete inherited legacy
  entries first, or the alias sections keep the group non-empty.

## Layout contract

`layout/theme.liquid` must render `{{ header_html }}`, `{{ content_html }}`,
`{{ footer_html }}`, include the skip-link, the font preload, token block
(`:root{ {{ theme_css }} }`), CSS via `{% render 'asset/theme.css' %}` and the
dedupe guard before vendor scripts.

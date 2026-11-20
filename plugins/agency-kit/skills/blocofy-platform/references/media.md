# Media uploads

## Upload recipe

```bash
curl -s -X POST "https://app.blocofy.com/api/v1/media" \
  -H "Authorization: Bearer $BLOCOFY_API_TOKEN" \
  -F "file=@hero.png;type=image/png" \
  -F "title=Descriptive title"
```

- **Always pass `;type=<mime>`** in `-F`. curl defaults to
  `application/octet-stream` and the server rejects it
  ("this file type cannot be uploaded"), most often on video/mp4.
- Allowed: images, video, audio, PDF, office docs. Max 50 MB.
- **SVG upload is gated per site** (docs: staged rollout, `403
  svg_upload_disabled` until enabled). Site logo / favicon / `og_image` never
  accept SVG (`422 svg_not_supported_for_field`). Rasterize logos/marks to PNG
  (2× the largest display size; separate light/dark variants if needed).
- **Never retry `POST /media` after a 502 or network error** — not
  idempotent, you get a duplicate file (docs).
- Response contains `file.id` + `file.filename`.

## CDN URL pattern

```
$BLOCOFY_URL/cdn/<file.id>/<filename>
```

Use these self-hosted URLs in section settings and page documents — never
hotlink external/generation-service URLs in anything that could ship (they
expire and leak provenance).

## In Liquid

Image settings pass through the `image_url` filter, which accepts both media
IDs and full CDN URLs:

```liquid
{{ props.image | image_url: 'width=2200&format=webp' }}
```

Entry image fields come back as media ids even if a URL was written (see
`binding.md`); `image_url` handles both.

## CDN first-resize 502

The first request for a new size/format variant can return **502 once**
while the CDN generates it; the next request succeeds (2026-10-31). This
is about CDN GETs only (see the upload rule above). Two guards:

- **Theme side:** one delayed retry per image, never a loop. A capture-phase
  listener in `app.js` covers every `<img>`, including lazy ones:

```js
document.addEventListener('error', function (e) {
  var img = e.target;
  if (!img || img.tagName !== 'IMG' || img.dataset.retried || !img.currentSrc) return;
  img.dataset.retried = '1';
  setTimeout(function () {
    var bust = (img.currentSrc.indexOf('?') === -1 ? '?' : '&') + 'r=1';
    img.removeAttribute('srcset');           // else the browser re-picks the failed candidate
    img.src = img.currentSrc + bust;
  }, 1200);
}, true);
```

- **After publish:** cache-warm pass — fetch each rendered page, collect every
  `src`, `srcset` candidate and `data-img`-style lazy URL, GET each once and
  report non-200s. Re-run until zero failures before calling the launch done.

## MIME quick table

| Ext | type= |
|---|---|
| .png | image/png |
| .jpg/.jpeg | image/jpeg |
| .webp | image/webp |
| .svg | image/svg+xml (gated per site; never for logo/favicon/og) |
| .mp4 | video/mp4 |

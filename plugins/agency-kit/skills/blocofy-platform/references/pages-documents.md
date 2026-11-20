# Pages and PageDocuments

## PageDocument v2 shape

```json
{ "version": 2, "sections": [
  { "id": "unique-id", "type": "SectionType", "settings": { … },
    "blocks": [ { "type": "block-type", "settings": { … } } ],
    "hidden": false }
] }
```

- `type` must match a section filename in the target theme instance
  (`section/SectionType.liquid`). Unknown type renders an error box for
  visitors ("unknown section") — see theme-kit alias pattern for migrations.
- Dynamic template pages (`/blog/[slug]`) bind entry fields:
  `"heading": {"$bind": "entry.title"}`, `"image": {"$bind": "entry.data.cover"}`.

## The document-PATCH-alone rule

`PATCH /pages/{id}` with `{"document": …}` **and nothing else**. Observed
failure: bundling `document` with `seo_title`/`seo_description` in one PATCH
returned 200 but did **not** create a draft revision (`draft_revision_id`
stayed null). Send metadata and document as separate PATCHes. Verify the
response: `draft_revision_id` must be non-null before publishing.

## Why MCP can't write documents

MCP `create_page`/`update_page` declare `document` without a schema; MCP
clients serialize it to a string; the server rejects it ("invalid page
content"). REST is unaffected. (Re-test occasionally; remove this rule if the
platform fixes the tool schema.)

## Lifecycle

- Create: `POST /pages {title, slug, document?}` → starts as `draft`.
- Publish: `POST /pages/{id}/publish` — optional body `published_at`
  (future = scheduled/hidden), `unpublish_at` (auto-hide; useful as a safety
  net for temporary pages). Bodyless publish keeps existing scheduling.
- A page created while a draft theme is live-pointer'ed elsewhere binds to the
  **live** instance by default — for build work, edit the *draft instance's own
  page copies* instead of creating new pages (see themes-instances.md).
- Delete = trash (restorable ~30 days), not permanent.
- `GET /pages/{id}?include=document` (published) / `?document=draft` (draft).

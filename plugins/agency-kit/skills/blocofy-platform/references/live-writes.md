# Writes that reach visitors or cannot be undone

A theme work shows the human a preview and waits for their approval. The
writes below have no preview and no approval step on the platform: they take
effect when the request returns. The agent supplies the stop.

## The stop

Before any write in the table, send the human one message with these four
lines, then wait for a yes in the conversation:

1. **What** changes (the record, field or file, by its name).
2. **Where** it shows (which live pages, or "nowhere visible, but stored").
3. **When**: "the moment I save; there is no preview".
4. **Undo**: how it is reversed, or "cannot be undone".

A yes covers the writes named in that message and nothing else. An earlier
"go ahead with the content" or "do the whole site" is not a yes for a delete
or for anything the message did not name. After the write, read the record
back and tell the human what is now live.

## Table

| Write | Why it needs the stop |
|---|---|
| Create, update or delete a **published collection entry** | Entries are not bound to a theme. A published entry the live theme reads changes on the live site at once |
| Add entries to a **new collection that has its own page route** | The route answers publicly as soon as the entry is published, even if the live theme has no template for it (an empty page). Keep entries in draft, or set them to noindex, until the theme that renders them is live |
| Change an **existing collection's field schema** | Site-wide, and replace-on-save: a field left out of the request is dropped together with its data |
| **Menus** | Shared by every theme on the site. For a new theme, create a separate menu handle; do not edit the one the live theme uses |
| **Site settings** (site name, contact e-mail, favicon, share image, meta description, legal page links) | Site-wide, read by the live theme |
| Title, slug, SEO fields or robots of a **page in the live theme** | Live at once; a slug change breaks inbound links |
| **Publish or unpublish a page in the live theme**; create a page without naming a draft theme | A page created without a draft target binds to the live theme (`pages-documents.md`) |
| **Robots / indexing** on any published page or entry (index ↔ noindex) | Changes what search engines keep; slow to reverse |
| **Forms**: recipients, fields, deletion | Site-wide; a wrong recipient sends visitors' data to the wrong person |
| A **real form submission** as a test | Sends a notification e-mail and stores a record. Intercept the request instead (`blocofy-qa` `references/playwright-traps.md`); submit for real only on a yes, and say which record to delete afterwards |
| **Server Site DNA** when it is not empty | Overwrites the brand record the client or another session wrote. Show the difference first |
| **Delete**: media, pages, entries, collections, forms, theme copies in the library | Media and theme copies cannot be restored. Before deleting media, check that no live theme setting or entry still points at it |

## Not in the table (no stop needed)

- Files, settings and pages written into a **theme work** or a draft theme:
  the approval flow in `SKILL.md` is their stop.
- Publishing a page that belongs to a draft theme (visitors only see pages of
  the live theme). Confirm the page's theme first; `api.sh` asks for
  `LIVE_WRITE_OK=1` on every publish call because the path does not show it.
- Revoking a preview link (it only ends a link you created).
- Uploading to the media library (additive, not shown anywhere until wired).
- Draft or unpublished entries; new collections with no page route.
- Reads.

## When unsure

Platform behaviour changes. If you cannot tell from the response or the docs
(`read_docs`) whether a write is live on save, treat it as live: use the stop.

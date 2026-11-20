---
name: blocofy-platform
description: How to operate the Blocofy CMS platform safely — auth/env conventions, the operation→channel matrix (MCP vs blocofy CLI vs curl REST), page/document/theme/media API recipes, the theme-work approval flow for theme changes and known traps. Use whenever touching a Blocofy tenant (tema push, tema çalışması, sayfa belgesi, medya yükleme, taslak/canlı tema, preview, publish, koleksiyon/kayıt CRUD). TR triggers - Blocofy, tema, taslak, yayınla, sayfa belgesi, medya yükle.
---

# Blocofy Platform Operations

Single source of truth for **how to touch Blocofy**. Other skills link here;
never re-derive these mechanics.

## Theme changes: drafts are free, live goes through one door

An agent never changes what visitors see on its own. A person approves after
seeing a preview. This applies to every theme change (files, settings,
appearance, sections), small fixes included.

| Situation | Do |
|---|---|
| Any theme change | 1. `list_theme_works` (MCP). 2. Resume a matching open work (`resume_theme_work`) or start one (`start_theme_work` with an idempotency key); never pick a work by name. 3. Write into the work: MCP write tools, or `blocofy theme push <dir> --draft --work <wk_…>`. 4. Give the user the work's preview link (`POST /api/v1/theme-work/{handle}/preview-links`). 5. `request_publish_approval` (MCP) or `blocofy theme work request-approval <wk_…> --open --wait`; give the user the approval link. 6. Say "live" only after the work is `published`. |
| Small fix (one file, one setting) | Same flow. There is no shortcut. |
| `work_stale` | Start a new work and re-apply the change. Never force the old one. |
| User, after seeing the preview, says to put it live | `request_publish_approval` (or `blocofy theme work request-approval <wk_…> --open --wait`) and give them the approval link; one click puts the work live. Never use the direct-live tools for this. |
| `publish_theme`, `deploy_theme`, `apply_release`, live `update_appearance`, `update_theme_settings` with `allow_live`, `blocofy theme push --live`, `blocofy theme publish` | Never on your own initiative, even if the credential allows it. They belong to a person in the panel or an owner-named CI key. |

## 0. Environment contract (read this first, every session)

All tenant values come from the workspace — never hardcode them:

```bash
# tenants/<domain>/.env.local  (gitignored)
BLOCOFY_URL=…            # tenant site URL
BLOCOFY_CLI_TOKEN=…      # bcf_… (CLI dev token)
BLOCOFY_API_TOKEN=…      # blcf_… (Admin REST bearer)
```

- CLI needs `export BLOCOFY_URL=… BLOCOFY_TOKEN=$BLOCOFY_CLI_TOKEN` — otherwise
  it uses `~/.blocofy/credentials.json`, which may point at a **different tenant**.
  Always confirm the target with `blocofy status` before writing anything.
- Admin REST base: `https://app.blocofy.com/api/v1`, `Authorization: Bearer $BLOCOFY_API_TOKEN`.
- `.mcp.json` must use `"Bearer ${BLOCOFY_API_TOKEN}"` env expansion — never a literal token.
- Run `scripts/doctor.sh` at the start of a build (Phase 0 gate).

## 1. Operation → channel matrix

Channels: **MCP** (`mcp__blocofy__*`), **CLI** (`blocofy`), **REST** (curl).
Pick per operation; verify dates show when a row was last confirmed.

| Operation | Channel | Why / trap | Verified |
|---|---|---|---|
| Read docs, site DNA, status, readiness | MCP | read-only, reliable | 2026-07 |
| Theme files push/pull/dev | CLI | draft-safe by default; `--instance <handle>` targets a specific draft; write into a theme work with `--draft --work <wk_…>` (see the table above); going live is the approval flow, not `theme publish`. `theme rename <handle> <name>` renames | 2026-11 |
| Draft preview link | REST / MCP | `POST /themes/<theme handle>/preview-links {"page": "<page handle>"}` (MCP `create_preview_link`: `instance`, `page`, `ttl_seconds`); CLI signed preview is retired → §3 | 2026-10-31 |
| Page **document** create/update | **REST only** | MCP `document` param is schema-less → client stringifies → server rejects. PATCH `{"document": …}` **alone**; bundling other fields can silently skip the draft revision | 2026-07 |
| Page publish / delete(trash) | REST | `POST /pages/{id}/publish`; body optional (`published_at`, `unpublish_at`) | 2026-07 |
| Chrome (header/footer) add/update/delete | REST | `POST /themes/{id}/chrome` with `position: 0` prepends; MCP appends at the end. `PATCH`/`DELETE …/chrome/{group}/{sectionId}` per docs (2026-09-23), not yet exercised. POST failed for a blockless section (422 no `blocks`, 500 `blocks: []`, REST+MCP) → `partial/header|footer` fallback, see theme-kit chrome pattern | 2026-10-31 |
| Media upload | REST | `curl -F "file=@f;type=video/mp4"` — **explicit MIME required**, curl defaults to octet-stream and the server rejects it. SVG upload gated per site, never for logo/favicon/og → PNG; never retry `POST /media` after 502; CDN first resize can 502 once → `references/media.md` | 2026-10-31 |
| Collections / entries CRUD | REST (MCP read ok) | `update_collection` field_schema and entry `data` are **replace-on-save**: always GET, merge, send the FULL object. Media-library URLs in `data` come back as media ids → `references/binding.md` | 2026-10-31 |
| Theme asset write (fallback) | REST | `PUT /themes/{id}/assets {path,kind,content}` when CLI is unavailable | 2026-07 |

Transport trap: python `urllib` hits Cloudflare 1010 on `app.blocofy.com` —
**use curl** (or drive curl from python via subprocess). Fetching *tenant site*
pages with urllib is fine.

## 2. Core model (why drafts are safe)

- A site has one **live** theme instance and up to 5 **drafts**. Creating a
  draft also clones the page set; **pages are bound to a theme instance**
  (`theme_instance` on the page, not PATCHable).
- Renderer serves only pages whose instance == live pointer. So: publishing
  pages *inside a draft instance* is invisible to visitors — build freely there.
- Publishing a theme swaps the live pointer atomically (files + pages + settings).
  The server refuses to publish an instance with no pages.
- Editing the LIVE instance (chrome, assets) requires explicit `allow_live` —
  an agent does not do this; it goes through a theme work and a person's
  approval (table at the top).

## 3. Preview

The CLI signed preview (`theme dev` Preview URL, `?preview=<jwt>`) is
**retired on the server** (verified 2026-10-31). Draft preview is now a
per-page link:

```bash
api.sh POST /themes/<theme handle>/preview-links '{"page": "<page handle>"}' | jq -r .preview_link.url
# MCP: create_preview_link · list_preview_links · revoke_preview_link
```

- **One page per link**, ~24h by default (`ttl_seconds` up to 7 days). The
  `url` is returned **once** — store it under `.blocofy-build/session/`
  (gitignored). Navigating to another route from it shows live content.
- After expiry or revoke the link **silently serves live content** — check
  link age before debugging "my changes vanished".
- The link **pins the draft's theme files (docs) and theme settings
  (observed 2026-10-31) at creation**: after any `theme push` or theme-settings
  change (logo, colors, contact info), generate a new link; the old one keeps
  showing the old state.
- Key needs `themes:write` + `pages:read`. No link for a theme with files still
  in draft state, or for dynamic template pages; max 50 active links per site.
- Collection lists on a link show only **published** entries (draft/scheduled
  entries appear only in the editor preview). While the site itself is in
  draft or maintenance status, links don't show the draft.

## 4. References (load on demand)

| File | Content |
|---|---|
| `references/auth-tokens.md` | env layering, CLI credentials, token rotation, preview-token lifecycle |
| `references/api-transport.md` | curl conventions, Cloudflare notes, `scripts/api.sh` usage |
| `references/pages-documents.md` | PageDocument v2 shape, document-PATCH-alone rule, publish/trash lifecycle |
| `references/themes-instances.md` | draft/live model, instance-page binding, chrome endpoints, publish flow |
| `references/media.md` | upload recipe, MIME table, CDN URL pattern, first-resize 502 retry + cache warm |
| `references/binding.md` | `{"$bind": "entry.data.x"}`, `entries[key]` in Liquid, relation `where` filter, bindable schema types |

## 5. Scripts

- `scripts/doctor.sh` — validates env vars, CLI presence and API reachability; run as Phase 0 gate.
- `scripts/api.sh` — thin curl wrapper: `api.sh GET /pages?limit=5`, `api.sh PATCH /pages/<id> @doc.json`.

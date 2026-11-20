---
name: blocofy-platform
description: Use when touching a Blocofy site through its MCP tools, CLI or REST API (TR - Blocofy, tema, taslak, yayınla, sayfa belgesi, medya yükle) - before any write, when choosing between them, when a call is refused, and when deciding whether a change needs a person's approval (tema push, tema çalışması, sayfa belgesi, medya yükleme, taslak/canlı tema, preview, publish, koleksiyon/kayıt CRUD).
compatibility: Needs a Blocofy site and its keys in the site folder's .env.local, bash, curl, jq and network access; the blocofy MCP server or the blocofy CLI (Node 22.20+). Written for any Agent Skills client; tested in Claude Code.
---

# Blocofy Platform Operations

Single source of truth for **how to touch Blocofy**. Other skills link here;
never re-derive these mechanics.

## Terms

- **Site folder**: the one folder that holds this site's `.env.local`, the
  agent's MCP config, `AGENTS.md` (or `CLAUDE.md`), `.blocofy-build/` and the
  theme. The agent is started there and every command is run from there.
- **`<skill-dir>`**: the folder this SKILL.md was loaded from. Your agent shows
  it when it loads the skill; if it does not, find it with
  `find ~ . -maxdepth 6 -type d -name blocofy-platform -path '*skills*' 2>/dev/null | head -1`.
  Scripts are always run through the interpreter:
  `bash <skill-dir>/scripts/…`.
- **Other skills** are named plainly ("load the `blocofy-qa` skill"); some
  agents show a prefix, for example `agency-kit:blocofy-qa` in Claude Code.
- **MCP tools**: "`site_status` (MCP)" means the `site_status` tool of the
  MCP server registered as `blocofy`. Agents prefix tool names differently,
  so match on the bare tool name.

## Theme changes: drafts are free, live goes through one door

An agent never changes what visitors see on its own. A person approves after
seeing a preview. This applies to every theme change (files, settings,
appearance, sections), small fixes included.

| Situation | Do |
|---|---|
| Any theme change | 1. `list_theme_works` (MCP). 2. Resume a matching open work (`resume_theme_work`) or start one (`start_theme_work` with an idempotency key, or `blocofy theme work start` when the files will be pushed with the CLI: the work belongs to the credential that starts it); never pick a work by name. 3. Write into the work: MCP write tools, or `blocofy theme push <dir> --draft --work <wk_…>`. 4. Give the user the work's preview link (`POST /api/v1/theme-work/{handle}/preview-links`). 5. `request_publish_approval` (MCP) or `blocofy theme work request-approval <wk_…> --open --wait`; give the user the approval link. 6. Say "live" only after the work is `published`. |
| Small fix (one file, one setting) | Same flow. There is no shortcut. |
| `work_stale` | Start a new work and re-apply the change. Never force the old one. |
| User, after seeing the preview, says to put it live | `request_publish_approval` (or `blocofy theme work request-approval <wk_…> --open --wait`) and give them the approval link; one click puts the work live. Never use the direct-live tools for this. |
| `publish_theme`, `deploy_theme`, `apply_release`, live `update_appearance`, `update_theme_settings` with `allow_live`, `blocofy theme push --live`, `blocofy theme publish` | Never on your own initiative, even if the credential allows it. They belong to a person in the panel or an owner-named CI key. |

## Writes outside a theme work: the agent is the stop

Collection entries, collection schemas, menus, site settings, forms, the SEO
fields and publish state of pages in the live theme, and every delete take
effect when the request returns. The platform shows no preview and asks no
one. Before any of them: tell the human what changes, where it shows, that it
is live on save, and how it is undone; then wait for a yes that names that
write. Table and wording: `references/live-writes.md`.

## 0. Environment contract (read this first, every session)

All site values come from the site folder — never hardcode them:

```bash
# <site folder>/.env.local  (gitignored)
# the person fills in three values:
BLOCOFY_URL=…                          # the site's URL
BLOCOFY_API_TOKEN=…                    # blcf_… (API key; used by MCP, api.sh, doctor.sh)
BLOCOFY_CLI_TOKEN=…                    # bcf_… / bcf2_… (CLI token)
# three more are derived in the same file, for the names the CLI reads:
BLOCOFY_TOKEN="$BLOCOFY_CLI_TOKEN"     # theme files
BLOCOFY_API_KEY="$BLOCOFY_API_TOKEN"   # theme works
BLOCOFY_API_URL=https://app.blocofy.com
```

The file is loaded by a shell (`set -a; . ./.env.local; set +a`) before the
agent starts, so all six are in the agent's environment. If they are not
there, do not read the file yourself and do not ask for the values: ask the
person to load it and restart you from that terminal. One terminal holds one
site's keys; when the person says they changed site or terminal, run the
doctor again and read back the site name.

- CLI needs `export BLOCOFY_URL=… BLOCOFY_TOKEN=$BLOCOFY_CLI_TOKEN` — otherwise
  it uses `~/.blocofy/credentials.json`, which may point at a **different site**.
  Always confirm the target with `blocofy status` before writing anything.
- A theme work belongs to the credential that started it. Start it and write
  to it through the same key: a work started over MCP is written over MCP
  (or by the CLI holding that same API key in `BLOCOFY_API_KEY`); a CLI push
  into a work needs both the CLI token and the API key of the same site.
- Admin REST base: `https://app.blocofy.com/api/v1`, `Authorization: Bearer $BLOCOFY_API_TOKEN`.
- The agent's MCP config in the site folder must read the key from the
  `BLOCOFY_API_TOKEN` environment variable, never a literal token. File and
  syntax differ per agent: kit README, "Connect a site".
- Run `bash <skill-dir>/scripts/doctor.sh` from the site folder at the start
  of a build (Phase 0 gate).

## 1. Operation → channel matrix

Channels: **MCP** (tools of the server registered as `blocofy`; see Terms),
**CLI** (`blocofy`), **REST** (curl).
Pick per operation; verify dates show when a row was last confirmed.

| Operation | Channel | Why / trap | Verified |
|---|---|---|---|
| Read docs, site DNA, status, readiness | MCP | read-only, reliable | 2026-07 |
| Site DNA update | MCP | `update_site_dna`. A record that is not empty is a write with no preview → `references/live-writes.md` | 2026-11 |
| Theme files push/pull/dev | CLI | draft-safe by default; `--instance <handle>` targets a specific draft; write into a theme work with `--draft --work <wk_…>` (see the table above); going live is the approval flow, not `theme publish`. `theme rename <handle> <name>` renames | 2026-11 |
| Draft preview link | REST / MCP | for a theme work `POST /theme-work/<wk handle>/preview-links`; for a draft theme outside a work `POST /themes/<theme handle>/preview-links {"page": "<page handle>"}` (MCP `create_preview_link`: `instance`, `page`, `ttl_seconds`); CLI signed preview is retired → §3 | 2026-10-31 |
| Page **document** create/update | **REST only** | MCP `document` param is schema-less → client stringifies → server rejects. PATCH `{"document": …}` **alone**; bundling other fields can silently skip the draft revision | 2026-07 |
| Page publish / delete(trash) | REST | `POST /pages/{id}/publish`; body optional (`published_at`, `unpublish_at`). In the live theme this is a live write → `references/live-writes.md` | 2026-07 |
| Chrome (header/footer) add/update/delete | REST | `POST /themes/{id}/chrome` with `position: 0` prepends; MCP appends at the end. `PATCH`/`DELETE …/chrome/{group}/{sectionId}` per docs (2026-09-23), not yet exercised. POST failed for a blockless section (422 no `blocks`, 500 `blocks: []`, REST+MCP) → `partial/header|footer` fallback, see theme-kit chrome pattern | 2026-10-31 |
| Media upload | REST | `curl -F "file=@f;type=video/mp4"` — **explicit MIME required**, curl defaults to octet-stream and the server rejects it. SVG upload gated per site, never for logo/favicon/og → PNG; never retry `POST /media` after 502; CDN first resize can 502 once → `references/media.md` | 2026-10-31 |
| Collections / entries CRUD | REST (MCP read ok) | `update_collection` field_schema and entry `data` are **replace-on-save**: always GET, merge, send the FULL object. Media-library URLs in `data` come back as media ids → `references/binding.md`. Published entries and schema changes are live on save → `references/live-writes.md` | 2026-10-31 |
| Theme asset write (fallback) | REST | `PUT /themes/{id}/assets {path,kind,content}` when CLI is unavailable | 2026-07 |

Transport trap: python `urllib` hits Cloudflare 1010 on `app.blocofy.com` —
**use curl** (or drive curl from python via subprocess). Fetching the *site's
own public* pages with urllib is fine.

## 2. Core model (why drafts are safe)

- A site has one **live** theme instance and a limited number of drafts (a
  count on some sites, a storage allowance on others; the refusal names the
  limit, for example `quota_exceeded`. Do not retry it: tell the human, who
  decides what to delete). Creating a
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
bash <skill-dir>/scripts/api.sh POST /themes/<theme handle>/preview-links '{"page": "<page handle>"}' | jq -r .preview_link.url
# MCP: create_preview_link · list_preview_links · revoke_preview_link
```

- **One page per link**, ~24h by default (`ttl_seconds` up to 7 days). The
  `url` is returned **once** — store it under `.blocofy-build/session/`
  (gitignored). Navigating to another route from it shows live content.
- After expiry or revoke the link **silently serves live content** — check
  link age before debugging "my changes vanished".
- A link shows the theme files and theme settings as they were when a link
  for that theme was last created. After any `theme push` or theme-settings
  change, create one new link: per the platform docs that also brings the
  theme's older links up to date. Page content is read fresh on every open.
- Key needs `themes:write` + `pages:read`. No link for a theme with files still
  in draft state, or for dynamic template pages; max 50 active links per site.
- A theme work has its own preview links
  (`POST /theme-work/<wk handle>/preview-links`); the `/themes/<handle>/…`
  form above is for a draft theme outside a work.
- **Dynamic template pages** (collection detail routes): run
  `blocofy theme dev <dir>`. It serves your local files with the draft's
  saved content on `127.0.0.1`, collection detail pages included. It never
  shows the live site and forms are not submitted from it.
- Collection lists on a link show only **published** entries (draft/scheduled
  entries appear only in the editor preview). While the site itself is in
  draft or maintenance status, links don't show the draft.

## 4. References (load on demand)

| File | Content |
|---|---|
| `references/auth-tokens.md` | env layering, CLI credentials, token rotation, preview-link lifecycle |
| `references/api-transport.md` | curl conventions, Cloudflare notes, `api.sh` usage |
| `references/pages-documents.md` | PageDocument v2 shape, document-PATCH-alone rule, publish/trash lifecycle |
| `references/themes-instances.md` | draft/live model, instance-page binding, chrome endpoints, publish flow |
| `references/media.md` | upload recipe, MIME table, CDN URL pattern, first-resize 502 retry + cache warm |
| `references/live-writes.md` | writes with no preview: what they are, the four-line stop, what needs no stop |
| `references/binding.md` | `{"$bind": "entry.data.x"}`, `entries[key]` in Liquid, relation `where` filter, bindable schema types |

## 5. Scripts

Run both from the site folder.

- `bash <skill-dir>/scripts/doctor.sh` — validates env vars, CLI presence and API reachability, names the site the key belongs to, and warns when an agent config file holds a literal token; run as Phase 0 gate.
- `bash <skill-dir>/scripts/api.sh` — thin curl wrapper: `bash <skill-dir>/scripts/api.sh GET "/pages?limit=5"`, `bash <skill-dir>/scripts/api.sh PATCH "/pages/<id>" @doc.json`. It refuses DELETE, page publish, site-settings and menu writes unless `LIVE_WRITE_OK=1` is set for that one call; set it only after the human's yes, or for the two cases `references/live-writes.md` lists as needing no stop (publishing a page of a draft theme, revoking a preview link).

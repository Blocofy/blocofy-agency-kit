# Themes, instances and the draft→live flow

## Model

- One **live** instance + a limited number of drafts per site (see SKILL.md §2). Theme settings, chrome
  layouts and the page set are all **per instance**.
- Creating a draft clones the current pages into draft-owned copies. The
  renderer resolves `theme_instance == live_theme_instance` — so anything you
  publish *inside a draft instance* stays invisible to visitors.
- A page's `theme_instance` is not writable via PATCH. To stage content for a
  new theme, edit the draft instance's own page copies (list pages and match by
  `theme_instance` handle), never the live instance's pages.

## The default-theme trap

New sites ship with a platform default theme. `theme pull` exists to sync a
theme **we already own** — pulling the default and iterating on it anchors the
design to the default's structure and is the most common recurring mistake.
For any new creative build, start from the theme-kit skeleton and push it
into a theme work; the orchestrator's provenance gate
(continue / takeover / greenfield) decides which mode applies.

## Build flow (safe default)

```bash
blocofy theme work start <dir> --intent "<what this work is for>"   # prints wk_…; saved in .blocofy/local.json
blocofy theme push <dir> --draft --work <wk_…> --dry-run          # what would change, nothing written
blocofy theme push <dir> --draft --work <wk_…>                    # write into the work
blocofy theme dev <dir> --port 3030                               # local view of the draft, saves sync to it
blocofy theme work request-approval <wk_…> --open --wait          # a person approves; exit 0 = published
```

A work is a private copy of the current live theme, so a brand-new theme and
a one-line fix use the same five lines. The work belongs to the login or key
that started it: start it and push to it with the same credentials (pushing
needs both the theme-file and the API access of that site). Going live is the
person's approval, never a CLI step by the agent; see the decision table in
`SKILL.md`.

`blocofy theme push <dir> --draft --name "…"` without a work creates a "CLI
draft" that only a person can publish from the panel. It has no approval
link, so the kit does not use it.

- `theme dev` (CLI 0.18+) renders a **draft** theme locally: your local files
  plus that draft's saved pages, entries and settings, on `127.0.0.1` only.
  It never renders the live theme. Its old remote Preview URL is retired; to
  show a draft page to someone else, create a preview link (platform SKILL
  §3). Older CLI versions behave differently: check `blocofy --version`.
- For the person who does run it: `theme publish` has **no `--yes` flag**
  (only `push --live` / `push --instance <live handle>` take it). An agent
  runs neither — it requests approval on the theme work.
- CLI syncs `layout/ section/ block/ partial/ asset/ template/` +
  `config/settings_schema.json`. Pages and other config are cloud-side.

## Chrome (site-wide header/footer groups)

- Read: `GET /themes/{id}/chrome`. Add: `POST /themes/{id}/chrome`
  `{area: "header"|"footer", type, settings, blocks, position}`.
- `position: 0` prepends (REST only; the MCP tool appends and has no position
  guarantee).
- Update / delete (per docs, 2026-09-23; not yet exercised): `PATCH` / `DELETE
  /themes/{id}/chrome/{group}/{sectionId}` (MCP `update_chrome_section` /
  `remove_chrome_section`). PATCH merges `settings` (a `null` key deletes it),
  replaces `blocks`, moves with `position`; pass `expected_version` to reject
  stale writes. Section ids come from `GET …/chrome` (`list_chrome_sections`).
- **Add can fail for a blockless section** (2026-10-31, REST and MCP alike):
  `POST` without `blocks` → 422, with `blocks: []` → 500. Don't block the build
  on it — use the platform fallback below.
- **Fallback:** an empty header/footer group renders `partial/header` /
  `partial/footer` (if the theme ships them) into `header_html` /
  `footer_html`. Keep the markup in one body partial rendered by both the
  chrome section and the fallback partial, so moving to chrome later changes
  nothing visible (theme-kit chrome pattern).
- The fallback renders only when the group is **empty**. Inherited legacy
  entries (rendered by silent alias sections) keep it non-empty and the header
  disappears → remove them (`DELETE …/chrome/{group}/{sectionId}`) first.
- New drafts inherit the live theme's chrome entries **by type name**. If your
  theme lacks those legacy types, visitors of a published theme would see
  "unknown section" boxes → ship silent alias sections (theme-kit).

## Publish gates

- Server refuses to publish an instance with no pages.
- Live-instance writes need `allow_live: true` and go site-wide instantly —
  an agent never sends them; use a theme work and request approval.
- Atomic multi-part release: `POST /releases` (theme+pages+navigation,
  validate-first) when a coordinated cutover is needed. Applying it
  (`apply_release`) is a person's step, not an agent's.

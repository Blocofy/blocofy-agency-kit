# Themes, instances and the draft→live flow

## Model

- One **live** instance + up to 5 **drafts** per site. Theme settings, chrome
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
For any new creative build, start from the theme-kit skeleton and create a
fresh named draft; the orchestrator's provenance gate
(continue / takeover / greenfield) decides which mode applies.

## Build flow (safe default)

```bash
blocofy theme push <dir> --draft --name "Theme Name"   # first push creates the draft
blocofy theme push <dir> --instance <handle>           # subsequent targeted pushes
blocofy theme dev <dir> --port 3030                    # local render + auto-sync (no preview URL)
blocofy theme rename <handle> "Display Name"           # rename an instance
```

Going live is not a direct CLI step for an agent. Changes to a site's existing theme
go into a theme work and a person approves them after a preview
(`blocofy theme push <dir> --draft --work <wk_…>`, then
`blocofy theme work request-approval <wk_…> --open --wait`); see the decision
table in `SKILL.md`. `blocofy theme publish` belongs to a person or an
owner-named CI key.

- `theme dev` local server renders **live-instance pages** with your local
  files. Its signed Preview URL is **retired server-side** ("CLI remote
  preview … retired", verified 2026-10-31). To see the **draft instance** (its own
  pages) use the editor or a per-page preview link
  (`POST /themes/{id}/preview-links`, see platform SKILL §3).
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

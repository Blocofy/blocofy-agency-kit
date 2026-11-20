# Phase details

Common frame per phase: read input artifacts fresh from disk → invoke the
named skill(s) → capture step → verify exit gate → update STATE.md →
one-paragraph report to the human.

## Phase 0 — Bootstrap

- `cd` tenant workspace; run platform `scripts/doctor.sh` (env, CLI, API).
- MCP: `read_site_dna` (brand truth), `site_status` (instances, page split).
- Check prerequisite skills are installed (gsap-skills). Missing → tell the
  human the install line. Phases 1 and 2 have no skill prerequisite.
- Create `.blocofy-build/` (+ `session/` under gitignore) and STATE.md.
- **Theme provenance gate** (SKILL.md): decide continue / takeover /
  greenfield from STATE.md + `blocofy status`; write `themeOrigin` into
  STATE.md. Greenfield explicitly means: skeleton copy, NOT a pull of the
  platform default.
- Flag hygiene problems found on the way (e.g. literal token in `.mcp.json`).

## Phase 1 — Brief & discovery

Two routes:
- **Reference route** (user supplied site URL(s)): run the recon in
  `reference-recon.md` (structure, tech signals, section rhythm, type,
  colour, screenshots). The output feeds analysis — the build is original
  code, copy and assets, and paid templates/themes must be flagged for
  licensing before anything ships. No external skill is required.
- **Greenfield route**: guided brief — business lines, audience, competitors,
  page inventory, tone, constraints. Real facts only; unknowns become
  questions, not assumptions.
Write `brief.md`: sitemap, per-page purpose, references, known real content
sources (existing site to migrate? client assets?).

## Phase 2 — Concept / design DNA

Full procedure, tables and gate: `concept-process.md`. In short:

- Dispatch specialist subagents (art direction always) with the brief. The
  art-direction specialist returns the design read and the three dials. Their
  output is input to the board, not the concept itself. No external design
  skill is required.
- **Direction board:** 2–3 directions the client can see (first screen at
  real size, signature element drawn, one cheap sample asset each). The
  client picks in words. A written description is never shown for approval
  on its own.
- **Coverage matrix:** how the picked concept shows on every surface (header,
  inner page heads, hover, forms, footer, 404, share image, covers).
- **Capture step (orchestrator's own duty):** translate into
  `design-dna.json` per the v2 contract — palette with roles + on-accent
  color, type trio, shape/layout, signature element, motion policy,
  `visual_language` (concept, vocabulary, families), first `decisions[]`
  entries, section vocabulary sketch.
- **Family boards** per asset family (`blocofy-media` `asset-system.md`);
  each client pick becomes that family's `style_ref`.
- **Independent review** by a subagent that did not work on the concept.
- Sync a human-readable summary into the server Site DNA (platform channel
  matrix: `update_site_dna` or REST PATCH) so the concept survives machines.
  If the server record is not empty, show the human what would be replaced
  and wait for a yes (`blocofy-platform` `references/live-writes.md`).
- Gate: `concept-process.md` → Gate.

**Revision:** when the client changes direction later (any phase), reopen
Phase 2 for the affected fields only: `decisions[]` entry with their words,
DNA fields updated, `meta.revision` raised, in the same turn. A new area that
should be "like" an approved one follows `concept-process.md` → New area.

## Phase 3 — Content model

- From brief + DNA section sketch, decide each section's data source:
  static settings, a collection (with `field_schema`), a form, or globals.
- Design collections editor-first (labels, field types, content_page routes).
- Write `content-model.json`; create/patch collections via platform recipes
  (full-schema replace rule!). A new collection is safe to create. Changing
  an existing collection's schema, a menu the live theme uses, a form or a
  site setting is a write with no preview: use the stop in `blocofy-platform`
  `references/live-writes.md`. Gate: no section left with "TBD" data source.

## Phase 4 — Theme build

- Honor `themeOrigin` from STATE.md:
  - `skeleton` → fresh dir from theme-kit skeleton; first push creates the
    named draft; record the new handle in STATE.md.
  - `existing:<handle>` → work in the recorded theme dir (pull that instance
    if missing locally); push targeted with `--instance <handle>`.
- Invoke `blocofy-theme-kit`: tokens from DNA → section vocabulary → chrome +
  aliases → motion pass (consult `gsap-skills`).
- Push to a **draft** instance; verify through per-page preview links
  (platform SKILL §3), regenerated after each push or settings change
  (`theme dev` is local-only).
- Gate: per-section checklist green on preview; zero unknown sections on the
  draft's page routes.

## Phase 5 — Content & media

- Page documents for the draft instance's own page copies (platform
  pages-documents.md; document-PATCH-alone rule).
- Real copy from brief sources; migrate existing client content where owned.
- `blocofy-media` set list per family (from content, `asset-system.md`) →
  generate → register in `media-registry.json` → upload → wire CDN URLs.
- Gate: grep for placeholder markers returns nothing; every media URL is
  tenant CDN.

## Phase 6 — QA

- Invoke `blocofy-qa`: page sweep (all routes), interaction sweep, responsive
  sweep, reduced-motion pass. Fix-and-rerun until green.
- Write the QA report section into `.blocofy-build/NOTES.md`.

## Phase 7 — Publish & retro

- Present the readiness checklist result and the preview link.
- Go live through the platform approval flow (`blocofy-platform`, theme works):
  request approval and give the user the approval link; a person approves.
  The agent never runs `theme publish`, `publish_theme` or `apply_release`
  itself. Smoke the live domain only after the work is `published`.
- Retro: append lessons to tenant NOTES.md; ask which lessons should be
  promoted to the kit repo (PR) — client-specific details stay behind.

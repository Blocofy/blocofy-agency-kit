---
name: blocofy-orchestrator
description: Use when starting a new website on Blocofy CMS, resuming a site build that has a .blocofy-build/STATE.md, choosing or revising a site's concept and design direction, or when unsure which Blocofy skill applies to a request. TR triggers - yeni site kur, sıfırdan site, siteyi kurmaya devam, hangi adımdayız, konsept seç, tasarım yönü (yeni site kur, sifirdan site, hangi adimdayiz).
---

# Blocofy Site Orchestrator

Conducts a full site build. Owns **routing, state and contracts** — carries no
platform or design knowledge itself (that lives in the specialist skills).

## Step 0 — Resume protocol (always)

1. Read `.blocofy-build/STATE.md` in the tenant workspace.
   - Missing → this is a new build: create `.blocofy-build/`, write STATE.md
     from `references/contracts/build-state.md`, start Phase 0.
   - Present → resume at the first phase whose exit gate is unmet. Re-read the
     phase's input artifacts from disk — **never trust conversation memory
     over the artifact files.**
2. Check `contractVersion` in artifacts against `references/contracts/`;
   on mismatch, stop and reconcile before proceeding.

## Single-task mode (bypass)

If the request is a bounded maintenance task, **skip the phase machine** and
route directly — do not bootstrap state for one-off work:

| Request smells like | Route to |
|---|---|
| API/CLI mechanics, tokens, publish, pages | `blocofy-platform` |
| a section/theme change | `blocofy-theme-kit` |
| an image/video | `blocofy-media` |
| "verify / test / is it ready" | `blocofy-qa` |
| scroll/motion depth | `gsap-skills` modules |
| "analyze this reference site", "make it like this site" | `references/reference-recon.md` (study, never copy) |
| the human asks for the agency process around the build (static prototype first, written sign-off, prelaunch checklist, handover) | `site-build-method`. It runs its own phases 0–12 and calls this orchestrator for the Blocofy part (its phases 8–11 = phases 0–7 here). A plain "build this site on Blocofy" stays here |

## Theme provenance gate (before any theme work)

New client sites ship with a **platform default theme**. Never pull it and
design "on top of" it — that habit makes every site look like the default.
Decide the mode from evidence, in this order:

1. `.blocofy-build/STATE.md` names a theme instance we built → **continue mode**:
   work in the recorded theme dir (pull that instance if the dir is missing).
2. No STATE.md, but `blocofy status` shows an agency-built theme (agency
   naming convention / prefixed sections) → **takeover mode**: pull THAT
   instance, retrofit STATE.md, then continue.
3. Only the platform default exists → **greenfield mode**: build the theme
   from theme-kit `assets/skeleton/` in a fresh local directory and push it
   into a theme work (Phase 4). The default theme's files are never used as
   the design base.

Record the decision in STATE.md as `themeOrigin: skeleton | existing:<handle>`.

## Phase machine (full build)

Details per phase: `references/phases.md`. Every phase: read inputs from disk →
invoke the named skill(s) → **capture step** (translate outputs into the
contract artifact) → verify exit gate → update STATE.md → report.

| # | Phase | Invokes | Artifact | Exit gate |
|---|---|---|---|---|
| 0 | Bootstrap | `blocofy-platform` `scripts/doctor.sh`; MCP `read_site_dna`, `site_status`; prerequisite-skill check | STATE.md | doctor OK; DNA read; deps installed |
| 1 | Brief & discovery | reference URL given → reference recon (`references/reference-recon.md`); else guided brief + research | `brief.md` | sitemap, audience, business lines, references written |
| 2 | Concept / design DNA | specialist subagents → direction board → client pick → coverage matrix → capture step (`references/concept-process.md`) | `concept/directions.html`, `concept/coverage.md`, `design-dna.json` v2 (+ sync summary to server Site DNA) | client picked a direction they saw; coverage matrix complete; contract fields non-empty incl. signature element, `visual_language`, first `decisions[]` |
| 3 | Content model | `blocofy-platform` (binding.md) | `content-model.json` | every planned section's data source resolved (collection/static/global) |
| 4 | Theme build | `blocofy-theme-kit` (+`gsap-skills` for motion depth) | theme dir pushed into a **theme work** | per-section checklist green; draft renders in preview |
| 5 | Content & media | `blocofy-media` + `blocofy-platform` (pages-documents.md) | draft-instance pages + entries + media | zero placeholders; all media on tenant CDN |
| 6 | QA | `blocofy-qa` | QA report in NOTES.md | page/responsive/reduced-motion sweeps green |
| 7 | Publish & retro | `blocofy-platform` theme-work approval flow — **a person approves; the agent never publishes** | live site; retro notes | work `published`; post-publish smoke green; lessons promoted |

## Routing rules

- Invoke skills **by exact name** listed above — never "a design skill";
  tenant workspaces may carry look-alike skills with overlapping triggers.
- External skills (`gsap-skills`) don't know our contracts.
  After each external invocation the orchestrator runs the **capture step**:
  map their output into the contract file, then continue from the file.
- Phase 2 needs no external design skill. The concept, the design read and
  the dials come from the specialist brief (`references/concept-process.md`).
  If a design-direction skill is installed in the workspace, its output may
  be handed to the art-direction specialist as one more input; a missing one
  is never a blocker and is never asked for.
- One writer per artifact: STATE.md → orchestrator only; each artifact → its
  producing phase only. Later phases read, never edit.
- Three stops need a yes from the human in the conversation, each time:
  1. Going live with a theme: the approval flow (`blocofy-platform`).
  2. Any write that has no preview (published entries, collection schemas,
     menus, site settings, forms, live-page SEO and publish state, deletes):
     `blocofy-platform` `references/live-writes.md`.
  3. Any spend on generation, and any upload of the client's material to a
     generation service: the spend gate in `blocofy-media`, which also says
     what one yes covers (a listed round; a kind of client material).
  A general go-ahead given earlier does not replace these.
- A visitor-facing experience (a section, a flow, a form, a new area) is
  shown as scenario + visual draft and picked by the client before it is
  coded. Approval of a written plan is not approval of how it looks.
- The client changes direction → Phase 2 revision in the same turn
  (`references/concept-process.md` → Revision). The DNA never lags the site.

## Contracts

`references/contracts/design-dna.md` (`contractVersion: 2`) ·
`content-model.md` · `build-state.md` (both `contractVersion: 1`).

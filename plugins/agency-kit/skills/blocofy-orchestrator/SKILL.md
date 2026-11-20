---
name: blocofy-orchestrator
description: Use when starting a new website on Blocofy CMS or resuming a site build that has a .blocofy-build/STATE.md (TR - yeni site kur, sıfırdan site, siteyi kurmaya devam, hangi adımdayız, konsept seç, tasarım yönü; ASCII - sifirdan site, hangi adimdayiz, konsept sec), choosing or revising a site's concept and design direction, or when unsure which Blocofy skill applies to a request.
compatibility: Needs the other five kit skills installed beside it, a Blocofy site and its keys, bash, curl, jq, Node 22.20+, network access; the blocofy MCP server and the blocofy CLI. Uses separate agents (subagents) where the agent has them. Written for any Agent Skills client; tested in Claude Code.
---

# Blocofy Site Orchestrator

Conducts a full site build. Owns **routing, state and contracts** — carries no
platform or design knowledge itself (that lives in the specialist skills).

## Terms

- **Site folder**: the one folder that holds this site's `.env.local`, the
  agent's MCP config, `AGENTS.md` (or `CLAUDE.md`), `.blocofy-build/` and the
  theme. The agent is started there and every command is run from there.
- **`<skill-dir>`**: the folder this SKILL.md was loaded from. Your agent shows
  it when it loads the skill; if it does not, find it with
  `find ~ . -maxdepth 6 -type d -name blocofy-orchestrator -path '*skills*' 2>/dev/null | head -1`.
  The other kit skills are sibling folders and their scripts are run through
  the interpreter: `bash <skill-dir>/../blocofy-platform/scripts/…`,
  `node <skill-dir>/../blocofy-qa/scripts/…`. If that folder is missing, the
  kit was installed partially: stop and ask the person to install all six.
- **Skill names**: "load the `blocofy-platform` skill" means the skill with
  exactly that name; some agents show a prefix, for example
  `agency-kit:blocofy-platform` in Claude Code.
- **MCP tools**: "`site_status` (MCP)" means that tool of the MCP server
  registered as `blocofy`; agents prefix tool names differently.
- **Separate agent**: a step marked this way is handed to a separate agent
  that starts with a clean context and receives only the files named in the
  step (a subagent, in agents that have them; some start one only when asked
  directly). If your agent cannot start one, do the step yourself in a
  separate pass: re-read only those files from disk, write the result to the
  named file, record in STATE.md that the step was not independent, and
  offer the person to run it in a new session.

## Step 0 — Resume protocol (always)

1. Read `.blocofy-build/STATE.md` in the site folder.
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
| scroll/motion depth | the GSAP skills (`gsap-scrolltrigger`, `gsap-performance`, `gsap-timeline`, from greensock/gsap-skills) when installed; otherwise GSAP's own documentation |
| "analyze this reference site", "make it like this site" | `references/reference-recon.md` (study, never copy) |
| the human asks for the agency process around the build (static prototype first, written sign-off, prelaunch checklist, handover) | `site-build-method`. It runs its own phases 0–12 and calls this orchestrator for the Blocofy part (its phases 8–11 = phases 0–7 here). A plain "build this site on Blocofy" stays here |

## Theme provenance gate (before any theme work)

New client sites ship with a **platform default theme**. Never pull it and
design "on top of" it — that habit makes every site look like the default.
Decide the mode from evidence, in this order:

1. `.blocofy-build/STATE.md` names a theme instance we built → **continue mode**:
   work in the recorded theme dir (pull that instance if the dir is missing).
2. No STATE.md, but `blocofy status` shows a theme that is not the platform
   default (a custom theme the person or someone before them built; ask if
   unsure) → **takeover mode**: pull THAT theme, write STATE.md from what is
   there, then continue.
3. Only the platform default exists → **greenfield mode**: build the theme
   from theme-kit `assets/skeleton/` in a fresh local directory and push it
   into a theme work (Phase 4). The default theme's files are never used as
   the design base.

Record the decision in STATE.md as `themeOrigin: skeleton | existing:<handle>`.

## Phase machine (full build)

Details per phase: `references/phases.md`. Every phase: read inputs from disk →
load the named skill(s) → **capture step** (translate outputs into the
contract artifact) → verify exit gate → update STATE.md → report.

| # | Phase | Loads / runs | Artifact | Exit gate |
|---|---|---|---|---|
| 0 | Bootstrap | `bash <skill-dir>/../blocofy-platform/scripts/doctor.sh`; `read_site_dna`, `site_status` (MCP); kit-skill check | STATE.md | doctor OK; DNA read; all six kit skills present |
| 1 | Brief & discovery | reference URL given → reference recon (`references/reference-recon.md`); else guided brief + research | `brief.md` | sitemap, audience, business lines, references written |
| 2 | Concept / design DNA | specialist briefs (separate agents, see Terms) → direction board → client pick → coverage matrix → capture step (`references/concept-process.md`) | `concept/directions.html`, `concept/coverage.md`, `design-dna.json` v2 (+ sync summary to server Site DNA) | client picked a direction they saw; coverage matrix complete; contract fields non-empty incl. signature element, `visual_language`, first `decisions[]` |
| 3 | Content model | `blocofy-platform` (binding.md) | `content-model.json` | every planned section's data source resolved (collection/static/global) |
| 4 | Theme build | `blocofy-theme-kit` (+ the GSAP skills for motion depth, when installed) | theme dir pushed into a **theme work** | per-section checklist green; draft renders in preview |
| 5 | Content & media | `blocofy-media` + `blocofy-platform` (pages-documents.md) | draft-instance pages + entries + media | zero placeholders; all media on the site's CDN |
| 6 | QA | `blocofy-qa` | QA report in NOTES.md | page/responsive/reduced-motion sweeps green |
| 7 | Publish & retro | `blocofy-platform` theme-work approval flow — **a person approves; the agent never publishes** | live site; retro notes | work `published`; post-publish smoke green; lessons promoted |

## Routing rules

- Load skills **by exact name** listed above (a prefix some agents add is
  fine, see Terms) — never "a design skill"; a site folder or the machine may
  carry look-alike skills with overlapping triggers.
- External skills (the GSAP skills) are optional and don't know our
  contracts. After each use of one the orchestrator runs the **capture step**:
  map their output into the contract file, then continue from the file.
- Phase 2 needs no external design skill. The concept, the design read and
  the dials come from the specialist brief (`references/concept-process.md`).
  If a design-direction skill is installed, its output may
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

# Reference recon (Phase 1, reference route)

When the client points at a site ("like this one"), study it; do not copy it.
The build is original code, original copy and original assets that reach a
similar effect. Nothing outside this kit is needed for the recon.

## Run

Run it first, before the brief questions, so the questions can be specific.
From the tenant's `.blocofy-build/` directory (Playwright installed in the
workspace):

```bash
node <blocofy-qa dir>/scripts/reference-recon.mjs "<url>" "<inner-page-url>"
```

`<blocofy-qa dir>` is the base directory Claude Code shows when it loads the
`blocofy-qa` skill.

Give it the home page and one or two inner pages the client named. It writes
`reference/recon.json` and full-page screenshots at 1440 and 390 into
`.blocofy-build/reference/`. Then look at the
screenshots yourself: the numbers do not tell you why the page works.

## What to write down

`.blocofy-build/reference-recon.md`, one block per reference site:

| Item | Source | Note |
|---|---|---|
| Page inventory | `nav` + the site's sitemap | which pages exist, which the client's site also needs |
| Section rhythm | `sections` + screenshots | order, height in viewports, where the background changes, what each section does |
| Type | `fonts`, `sizes` | families, heading and body size at both widths; the faces are licensed to that site, not to yours |
| Colour | `text_colors`, `background_colors` | roles (ground, ink, accent), not hex values to reuse |
| Layout | screenshots, `container_max_width` (approximate) | container, column count, how it collapses at 390 |
| Motion | watch the live page | what moves, on what trigger, whether content is readable without it |
| Tech signals | `signals` | generator, framework, theme or template markers |
| What the client likes | ask them | one sentence per reference, in their words |

`signals.markers` naming a marketplace or a page-builder theme means the look
may be a paid template. Say so to the human before the concept phase: the
template's code, demo images and demo copy are never reused.

## What never crosses over

- Source code, CSS files, scripts, markup structure copied as is.
- Images, video, icons, illustrations, fonts. No hotlinks, no downloads into
  the project.
- Copy, slogans, product names, logos, trade dress that identifies the other
  brand.

The screenshots stay in `.blocofy-build/reference/` as working notes and are
never uploaded to the client's media library.

## Hand-off

The recon feeds `brief.md` (references section) and the Phase 2 specialist
brief as one input among others. Each concept direction still has to be its
own idea: a direction that is the reference with new colours fails the
direction-board rule that directions differ in idea.

A tool that locates and clones a site's real source code is a different job
and is outside this kit.

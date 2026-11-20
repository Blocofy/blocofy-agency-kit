# Concept process (Phase 2)

Phase 2 is a loop with the client, not one skill call. A concept the client
has only read about is not approved: approval means they saw it and picked it.

## Steps

| # | Step | Output | Client says |
|---|---|---|---|
| 1 | Specialist brief | one page per specialist | nothing yet |
| 2 | Direction board | `concept/directions.html`, 2–3 directions | picks one, in words |
| 3 | Coverage matrix | `concept/coverage.md` | confirms or corrects |
| 4 | Capture | `design-dna.json` v2 | nothing |
| 5 | Family boards | one board per asset family (`blocofy-media` `asset-system.md`) | picks per family |
| 6 | Independent review | `concept/review.md` | sees the findings |

### 1. Specialist brief

Dispatch subagents before drawing anything: art direction always; motion,
copy and UX when the brief touches them. Each reads `brief.md` and returns a
concept sentence, what it changes on the page, and what it rules out. The
orchestrator merges; it does not invent the concept alone.

The art-direction specialist also returns, per direction:

- **Design read:** one line naming page kind, audience, vibe and aesthetic
  family ("B2B services site for procurement managers; calm, exact;
  editorial print").
- **Dials**, each 1–10 with one sentence of reason:
  `variance` (1 strict grid and symmetry, 10 broken grid and asymmetry),
  `motion` (1 static, 10 cinematic and scroll-driven),
  `density` (1 airy gallery, 10 packed dashboard).

These go into `design-dna.json` (`design_read`, `dials`) for the picked
direction; the reasons stay in the specialist's brief. Nothing outside this kit is needed to produce them. An installed
design-direction skill may be given to the specialist as extra input; its
absence changes nothing.

### 2. Direction board

One static HTML page, opened in a browser and screenshotted for the client.
Each direction shows the same five things so they can be compared:

1. The concept in one sentence (the site's metaphor or story).
2. Palette and type, rendered, with the site language's special letters and
   an uppercase sample (a display face can fail on dotted/dotless capitals).
3. The signature element, drawn, not described.
4. The first screen at 1440×900 and 390×844 with real copy at real size.
5. One sample asset per direction, made with the cheapest model, after the
   spend gate in `blocofy-media`.

Directions differ in idea, not in colour. Three palettes on one layout is one
direction.

### 3. Coverage matrix

The chosen concept must reach every surface, or the site reads as a default
theme with a decorated hero. Fill one row per surface:

| Surface | How the concept shows here | Asset family | Status |
|---|---|---|---|
| header and menu | | | |
| first screen | | | |
| inner page heads | | | |
| cards, lists, FAQ | | | |
| buttons, links, hover and focus | | | |
| forms and their success state | | | |
| footer and closing call | | | |
| 404, cookie banner | | | |
| favicon, share image | | | |
| blog or case covers | | | |

A row that says "standard" or is empty fails the gate. A surface that
deliberately stays plain says so and why.

### 4. Capture

Write `design-dna.json` per the v2 contract: `visual_language.concept`,
`vocabulary`, one `families[]` entry per row group of the matrix, and the
first `decisions[]` entries (what the client picked and what they rejected,
in their words).

### 5. Family boards

Each asset family gets its own small board and its own client pick. A family
can use a different medium from the others (drawn objects, photographic
covers). Process and series rule: `blocofy-media` `references/asset-system.md`.

### 6. Independent review

A subagent that did not work on the concept reviews board, matrix and DNA
against the brief. Run it again after any revision that changes a family or
the first screen, and before publish.

## New area on an approved concept

When the client asks for "something like X, but different" for another area:

1. Take the idea only (what made X work).
2. Dispatch a specialist to plan the new area: its own scene or device,
   layout, interaction, mobile behaviour, and at least two discarded
   alternatives with the reason.
3. Show the plan with a rough schematic drawing (boxes and lines, no
   generated image needed). Ask for a yes on the concept itself. A layout
   note from the client is a layout note, not approval.
4. After the yes, build the section with that schematic as placeholder and
   measure it (ratio, empty area for text, horizon or vanishing point).
5. Generate the asset to the measured spec, cheapest model first, then
   measure the real file again.

The approved asset is never mirrored, recropped or varied to fill the new
area, not even as a temporary placeholder in a preview.

Family and references: if the new asset belongs to an existing family, it
uses that family's entry and needs no new board. The whole approved frame is
not passed to the generator as a reference, because the model repeats its
composition. Pass the family's `style_ref`, and when a character or object
must recur, a crop of only that character or object.

## Revision

The client's word overrides the DNA. In the same turn:

1. Append to `decisions[]`: date, what changed, the client's words, the rule
   it produces.
2. Change the affected DNA fields and raise `meta.revision`.
3. Re-run the coverage matrix rows the change touches.

Gate: no ban in the DNA is contradicted by what is live.

## Gate (Phase 2 exit)

- Client picked a direction on a board they saw; the pick is quoted in
  `decisions[0]`. A client who says "you choose" still gets the board, with
  one direction marked as recommended, and answers yes or names another.
- Coverage matrix has no empty or "standard" row. The client is shown the
  matrix and the review findings; they need no separate sign-off.
- Every family in the matrix has a `families[]` entry with `style_ref` set or
  marked `pending board`. Phase 2 writes the picked `style_ref` into the DNA
  after each family board; a family still `pending board` blocks generating
  that family's assets, not Phase 3.
- Independent review has no open critical finding.
- Contract fields non-empty; `on_accent` passes AA.
- Summary synced to the server Site DNA.

## Signals that the concept is not landing

| Client says something like | It means | Do |
|---|---|---|
| "ordinary", "like every site" | chrome and inner pages are default | coverage matrix, rows 1, 3, 7 |
| "don't just restyle it" | CSS changed, layout and content did not | specialist brief again, change structure |
| "too artificial" / "too shabby" | photo family has no setting class or liveliness rule | fill `families[].setting`, new board |
| "you reused the same image" | approved sample treated as a template | new-area steps above; series rule |
| "it works but it's still a form" | function approved, experience never shown | direction board for the experience |
| "it looks like a <wrong place>" | scene does not read as the business | add the setting test to the acceptance list |

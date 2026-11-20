# Asset system: families, style references, registry

A site's visuals are a small number of **families** (objects, scenes, covers,
icons, video). Each family is defined once in `design-dna.json`
`visual_language.families[]` and every asset is produced from that entry.
Without it, each session re-invents the look and the set drifts.

## Per-family process

1. **Board.** 2–3 directions, one sample each, cheapest model and lowest
   resolution. For photographic families the directions must differ in
   setting class and liveliness, not only in subject.
2. **Client pick.** The picked sample is saved as the family's `style_ref`
   (the generation tool's identifier). Rejected directions go to
   `decisions[]` with the client's words.
3. **Set list from content.** One line per asset, derived from what the page,
   service, step or article says. Never from the picked sample.
4. **Layout first, when text sits in the scene.** Build the section with a
   schematic placeholder, measure ratio, empty text area (in percent) and
   horizon or vanishing point; put those numbers in the prompt and the
   acceptance list. Mobile gets its own crop or its own composition.
5. **Generate.** `style_ref` + `prompt_core` + the asset's own subject. In
   parallel, `count=1`. Final resolution only for the chosen frame.
6. **Inspect at full size.** Zoom into every surface that can carry lettering
   (screens, papers, signs, labels, calculators). Fix a flaw with a
   reference-guided edit that keeps the rest of the image; do not regenerate
   a frame the client already picked.
7. **Acceptance.** Check the family's list: palette ratio, background, people
   policy, setting test (below), text area empty, no readable AI lettering.
8. **Post-process** per `post_process` (white balance, alpha, crop, format).
9. **Register** in `.blocofy-build/media-registry.json`, then wire into the
   site.
10. **Ledger.** Append credits spent this round to `.blocofy-build/credits.md`
    (date, family, items, model, credits). The round started with the spend
    gate in `SKILL.md`; a board is a round.

## Series rule

A series is a set of constraints, not a template. The picked sample proves
the style; it is not a composition to repeat. Each asset's scene, angle and
subject come from its own content. Only the family constraints are shared.

Producing the next asset by varying, mirroring or recropping an approved one
is a defect, also when it is meant as a placeholder.

## Setting test (photographic and scene families)

Two questions, answered by looking at the frame, before showing the client:

- Would a stranger name the place as the kind of business this site is for?
- Does it look like a moment that happened (people or traces of them,
  reflections, wear in the right amount), or like an empty set?

`families[].setting` records the answer the client accepted (place class,
liveliness, what was rejected), and the first prompt of every later asset
states both.

## People

Read `families[].people`. The default is generic figures or
silhouettes, no identifiable people. Generated
images never stand in for the client's real team, premises or customers,
whatever the family says.

## media-registry.json

One file per project, single source for what exists and where it is used:

```json
{
  "<key>": {
    "media_id": "", "family": "", "source_creation": "", "style_ref": "",
    "model": "", "prompt": "", "ratio": "", "frame2": null,
    "used_in": ["section / page / collection field"],
    "status": "live | draft | unused"
  }
}
```

Before deleting media, read `used_in` and the live theme settings: a setting
can still point at a file the template no longer renders.

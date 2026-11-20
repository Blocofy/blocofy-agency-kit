# Prompt rules

## DNA → prompt mapping

Pull from `design-dna.json` into every prompt of a set. Field names are the
contract's (v2):

| DNA field | Prompt fragment |
|---|---|
| `visual_language.families[id].prompt_core` | the unchanging core, verbatim |
| `visual_language.families[id].style_ref` | passed as the style reference, not described in words |
| `visual_language.families[id].setting` | place class + liveliness, stated in the first prompt |
| `visual_language.families[id].people` | people clause (see Truthfulness limits) |
| `color.accent` + `color.dark` | "deep <dark-tone> palette with warm <accent-family> highlights" |
| `visual_language.families[id].palette_ratio` | how much accent is allowed in the frame |
| `style.art_direction` | fallback mood sentence when no family entry applies yet |
| `motion.intensity` | haze/particles/lighting drama level |
| placement | empty area for text, in percent, measured from the built layout |

Series coherence: shared constraints (family entry), different content. One
lighting family + one accent color across the set; each item's scene, angle
and subject come from its own content (`asset-system.md` → Series rule).

## The no-text clause (mandatory on photographic prompts)

End with: **"Absolutely no text, no letters, no words, no logos, no watermarks
anywhere in the image."** Then still inspect at full size — models sneak
lettering onto billboards, screens, stationery. Regenerate on any gibberish.

Exception: screens showing a *reference* website are allowed to carry that
site's UI (that's the point) — small AI distortions in menus are acceptable at
panel scale; offer a pixel-perfect composite (real screenshot on mockup) if
the client needs closeups.

## Truthfulness limits

- No invented awards, metrics, client names or certifications in imagery.
- Case-study visuals may be *stylized representations* of real work; label
  copy stays factual.
- People: read `visual_language.families[id].people`. Default is generic
  figures/silhouettes. Realistic generated people only where the client
  approved it for that family, and never as a stand-in for the client's real
  team, premises or customers.

## Video prompts

- State: subject, motion quality ("gentle continuous motion"), camera
  ("camera static"), loop intent ("seamless calm loop"), palette, "no text".
- Moderation false positives: rephrase abstractly once (droplets → translucent
  circles) before assuming the concept is blocked.

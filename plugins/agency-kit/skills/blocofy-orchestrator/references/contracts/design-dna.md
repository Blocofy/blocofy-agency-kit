# Contract: design-dna.json (contractVersion 2)

Written by Phase 2; read by theme-kit (tokens), media (prompts, families), qa
(expectations). Later phases never edit it. Changes go through a Phase 2
revision (`concept-process.md` → Revision), which raises `meta.revision`.

v1 → v2: adds `meta.revision`, `visual_language`, `decisions`. A v1 file is
upgraded by adding the three blocks; no v1 field changes meaning.
`style.art_direction` stays as the one-line summary; per-family direction
lives in `visual_language.families[]`.

```json
{
  "contractVersion": 2,
  "meta": { "name": "", "sources": [""], "created_at": "YYYY-MM-DD", "revision": 1 },
  "design_read": "one line: page kind, audience, vibe, aesthetic family (from the art-direction specialist)",
  "dials": { "variance": 1, "motion": 1, "density": 1 },
  "color": {
    "primary":   { "hex": "", "role": "" },
    "accent":    { "hex": "", "role": "", "on_accent": "#hex (AA text on accent)" },
    "neutrals":  { "bg": "", "surface": "", "line": "", "muted": "", "ink": "" },
    "dark":      { "bg": "", "ink": "" },
    "notes": "bans and cautions (e.g. no pure black, no default-AI palettes)"
  },
  "typography": {
    "display": { "family": "", "weights": [], "scale_note": "max size at 1440 and at 390" },
    "body":    { "family": "", "weights": [] },
    "mono_or_accent_face": { "family": "", "usage": "" }
  },
  "shape":  { "radius_card": "", "radius_button": "", "notes": "" },
  "layout": { "container": "", "gutters": "", "grid_character": "" },
  "style": {
    "keywords": [],
    "art_direction": "one-line summary of the whole",
    "signature_element": "the one memorable device — REQUIRED, specific",
    "second_read_details": []
  },
  "visual_language": {
    "concept": "one sentence: the site's metaphor or story",
    "vocabulary": [
      { "mark": "", "meaning": "", "quota": "e.g. one per page", "never": "" }
    ],
    "families": [
      {
        "id": "objects | scenes | covers | icons | textures | video",
        "purpose": "where and why it is used",
        "medium": "drawing | photograph | 3D | collage | …",
        "style_ref": "generation-tool identifier of the client-picked sample, or 'pending board'",
        "model": "short name + date verified",
        "prompt_core": "the part of the prompt that never changes",
        "palette_ratio": "e.g. accent ≤ 4%",
        "background": "transparent | page colour | scene",
        "ratio_and_size": "16:9 1600×900 | 1:1 …",
        "states": "second frame / hover frame needed?",
        "setting": "place class + liveliness the client accepted; what was rejected",
        "people": "none | silhouette | from behind | realistic (client approved)",
        "series_rule": "what is fixed across the set; everything else comes from each item's content",
        "post_process": "white balance, alpha, crop, format"
      }
    ]
  },
  "motion": {
    "intensity": "low|medium|high",
    "smooth_scroll": true,
    "recipes": ["entrance-timeline", "reveal-batch", "parallax", "…"],
    "reduced_motion": "always full-content fallback"
  },
  "sections_sketch": [ { "name": "", "purpose": "", "data": "static|collection:<key>|form:<key>|globals" } ],
  "decisions": [
    {
      "date": "YYYY-MM-DD",
      "what": "picked direction B | rejected framed cards | allowed people in covers",
      "client_words": "short quote",
      "rule": "what this fixes from now on",
      "fields_changed": ["visual_language.families[covers].people"]
    }
  ]
}
```

Gate check: no empty string in required fields; `signature_element` concrete;
`on_accent` present (contrast is a DNA decision, not per-component
improvisation); `visual_language.concept` set; at least one family; every
family has `style_ref` or `pending board`; `decisions[0]` quotes the client's
direction pick; no `decisions[].rule` is contradicted by another field.

`dials` are 1–10 (`concept-process.md` step 1 defines each end). They and
`design_read` are written by Phase 2 from the specialist brief; no external
skill produces them.

Client-specific values (colours, banned words, object lists) live only in the
project's own `design-dna.json`, never in the kit.

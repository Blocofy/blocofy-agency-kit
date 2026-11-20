---
name: blocofy-media
description: Use when generating, replacing or extending images or video for a Blocofy site, planning an image set or series (objects, scenes, covers), choosing an image or video model, or uploading generated media to the Blocofy media library. TR triggers - görsel üret, video üret, medya, kapak görseli, arka plan, görsel seti (gorsel uret, video uret, kapak gorseli).
---

# Blocofy Media Pipeline

Every visual on a client site is either (a) the client's own asset or
(b) generated fresh for them. Never hotlink third-party or demo media into
anything that could ship; never leave generation-service URLs in documents.

## Ground rules

1. **Read `.blocofy-build/design-dna.json` first.** Find the asset's family in
   `visual_language.families[]` and build the prompt from that entry
   (`style_ref`, `prompt_core`, `setting`, `people`, `palette_ratio`). No
   family entry for what you are about to make → stop and run a family board
   (`references/asset-system.md`); do not improvise a look.
   A series is constraints, not a template: never produce the next asset by
   varying, mirroring or recropping an approved one.
2. **Spend gate, before the first generation of every round.** Send the
   human: the balance (`account_balance`, and whether unlimited mode is
   active), the list of what you will generate (count, model, resolution),
   and the estimated cost (`simulate_cost` where the tool offers it). Wait
   for a yes. The yes covers that list. Cheap trials and final-resolution
   frames are separate lines on it; one yes can cover both when both are
   listed with their cost.
   Anything beyond the list, or a retry that would pass the approved total,
   goes back through the gate. After the round, append what was spent to
   `.blocofy-build/credits.md`. Batch the approved generations in parallel.
3. **Client material leaves the workspace only on a yes.** Before the first
   upload of client-supplied files, or of screenshots of the client's site,
   to a generation service, tell the human which files go to which service
   and wait for a yes. Record the answer in `.blocofy-build/NOTES.md`; it
   holds for that kind of material for the rest of the project.
4. **Self-host everything**: download the result, upload to Blocofy media
   (platform `references/media.md` — MIME flag mandatory), use the tenant CDN URL.
5. **Truthfulness**: a generated image never stands in for something that
   exists: the client's products or packaging, team, premises, certificates,
   logos, finished projects. Those are the client's own photographs or stay
   out. Generated imagery is for atmosphere, illustration and abstraction,
   and never carries invented metrics, awards or client names.

## Model matrix (a dated starting point)

Model names and rankings change. Before the first round of every project,
read the tool's own lists (`images_models_list`, `video_models_list`) and
prefer what they recommend; treat the table as what worked when it was
written (2026-07).

| Need | Model | Notes |
|---|---|---|
| Photoreal scene, no text | `recraft-v4-1` | Best pure TTI; append the no-text clause (below) |
| Reference-guided image (the client's screenshots or photos as references for a new scene) | `imagen-nano-banana-2-flash` | Fast, good composition; upload refs first |
| Highest-fidelity reference/brand work | `imagen-nano-banana-2` | When flash quality isn't enough |
| Diagrams/UI-like/typography-bearing images | `gpt-2` | Only model trusted with readable text |
| Video (background loops, product shots) | `bytedance-seedance-mini-2.0` | 720p/8s sweet spot; `pro` for finals; `cameraMotion: "static"` for textures |
| Isometric/minimal object sets | auto mode is fine | Auto model behaves on object arrangements |

**Auto-mode trap:** default/auto models routinely bake gibberish poster text
into photographic scenes. For any photographic prompt use `recraft-v4-1` and
end the prompt with: *"Absolutely no text, no letters, no words, no logos, no
watermarks anywhere in the image."* Inspect every result at full size before
using it — regenerate on any lettering.

**A harmless prompt is blocked (video):** describe the same harmless scene
once in plainer words. If it is blocked again, stop and tell the human. Never
reword a prompt to get content past a refusal the service makes on purpose.

## Reference-guided flow (the client's own material as references)

1. Capture references yourself (Playwright screenshot of the client's site,
   crop consent banners) or receive client assets. Ground rule 3 applies
   before step 2.
2. `creations_request_upload` → HTTP `PUT` the bytes (set `Content-Type`;
   never re-PUT the same URL) → `creations_finalize_upload` → use returned
   identifiers in `references: [{type:"image", identifier}]`.
3. Prompt describes the *new scene* and how the reference participates
   ("the colours and materials of the reference, in a new abstract scene…").
   The output is atmosphere; it is never shown as the client's actual product,
   place or people (ground rule 5).

## References

- `references/asset-system.md` — families, family board, series rule, setting test, `media-registry.json`
- `references/model-matrix.md` — extended matrix + aspect-ratio notes
- `references/prompt-rules.md` — DNA→prompt mapping, no-text clause, series coherence
- `references/pipeline.md` — end-to-end recipe: generate → wait → download → upload → wire into documents

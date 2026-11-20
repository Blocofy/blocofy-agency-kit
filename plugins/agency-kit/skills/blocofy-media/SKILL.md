---
name: blocofy-media
description: AI media discipline for Blocofy sites using the Freepik/Magnific MCP - model selection matrix, no-text prompt rule, reference-guided generation from client screenshots, video generation, cost checks and MIME-correct upload into the Blocofy media library. Use when generating or replacing site imagery/video. TR triggers - gorsel uret, video uret, medya, kapak gorseli, arka plan.
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
2. **Check credits before batch generation** (`account_balance`); tell the user
   when unlimited mode is inactive. Batch related generations in parallel.
3. **Self-host everything**: download the result, upload to Blocofy media
   (platform `references/media.md` — MIME flag mandatory), use the tenant CDN URL.
4. **Truthfulness**: portfolio/case imagery may be stylized, but never invent
   metrics, awards or client attributions inside images or captions.

## Model matrix (verified 2026-07; re-check `*_models_list` quarterly)

| Need | Model | Notes |
|---|---|---|
| Photoreal scene, no text | `recraft-v4-1` | Best pure TTI; append the no-text clause (below) |
| Reference-guided image (screenshots, product shots) | `imagen-nano-banana-2-flash` | Fast, good composition; upload refs first |
| Highest-fidelity reference/brand work | `imagen-nano-banana-2` | When flash quality isn't enough |
| Diagrams/UI-like/typography-bearing images | `gpt-2` | Only model trusted with readable text |
| Video (background loops, product shots) | `bytedance-seedance-mini-2.0` | 720p/8s sweet spot; `pro` for finals; `cameraMotion: "static"` for textures |
| Isometric/minimal object sets | auto mode is fine | Auto model behaves on object arrangements |

**Auto-mode trap:** default/auto models routinely bake gibberish poster text
into photographic scenes. For any photographic prompt use `recraft-v4-1` and
end the prompt with: *"Absolutely no text, no letters, no words, no logos, no
watermarks anywhere in the image."* Inspect every result at full size before
using it — regenerate on any lettering.

**Moderation false positives (video):** innocuous phrasings can be blocked
(e.g. droplet macro prompts). Rephrase with more abstract vocabulary
("translucent circles drifting over frosted surface") and retry once before
escalating.

## Reference-guided flow (client site/product shots as refs)

1. Capture references yourself (Playwright screenshot of the client's site,
   crop consent banners) or receive client assets.
2. `creations_request_upload` → HTTP `PUT` the bytes (set `Content-Type`;
   never re-PUT the same URL) → `creations_finalize_upload` → use returned
   identifiers in `references: [{type:"image", identifier}]`.
3. Prompt describes the *new scene* and how the reference participates
   ("the client's product, as in the reference, on the desk of the new scene…").

## References

- `references/asset-system.md` — families, family board, series rule, setting test, `media-registry.json`
- `references/model-matrix.md` — extended matrix + aspect-ratio notes
- `references/prompt-rules.md` — DNA→prompt mapping, no-text clause, series coherence
- `references/pipeline.md` — end-to-end recipe: generate → wait → download → upload → wire into documents

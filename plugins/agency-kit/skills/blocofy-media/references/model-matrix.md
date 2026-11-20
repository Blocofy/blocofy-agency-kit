# Extended model notes

Re-verify with `images_models_list` / `video_models_list` quarterly; prefer
entries with `agentRecommendation.tier: sota`, lowest rank.

## Images

- `recraft-v4-1` — pure text-to-image, photoreal or illustration, fastest
  iteration. No image references (style refs only). The workhorse for scene
  backgrounds. Aspect ratios include 16:9, 2:1, 4:3.
- `imagen-nano-banana-2-flash` ("Nano Banana Lite") — reference-guided
  composition: pass site screenshots/product photos as `type:"image"`
  references. Good for "their real website on a screen in a styled scene".
- `imagen-nano-banana-2` (Pro) — same family, higher fidelity, slower;
  brand-consistency finals.
- `gpt-2` — layout/typography-bearing images only (diagrams, mock posters);
  photographic realism is not its strength.
- Auto mode — acceptable for minimal isometric object sets; avoid for
  photographic scenes (gibberish-text risk).

## Video

- `bytedance-seedance-mini-2.0` — best value; 480/720p, 4-15s, multishot,
  `cameraMotion` list including `static`. Background textures: 8s, 720p, 16:9,
  static camera, "seamless calm loop" phrasing.
- `bytedance-seedance-pro-2.0` — final-quality, 4K capable, native audio.
- `kling-25` — good quality/price for silent 5-10s realistic motion.

## Aspect-ratio guidance

| Placement | Ratio |
|---|---|
| Full-bleed hero / work panel | 16:9 (generate ≥2K wide) |
| Ultra-wide texture band | 2:1 or 21:9 (model-dependent; auto snaps 21:9→2:1) |
| Card/service images | 4:3 |
| Portrait cards | 4:5 or 2:3 |

## Cost discipline

- `account_balance` before batches; `simulate_cost` for video when its
  argument schema cooperates — otherwise estimate: mini-video ≈ several
  thousand credits, images ≈ tens-to-hundreds each.
- Batch prompts in parallel tool calls; reuse rejects as style references
  instead of burning fresh generations.

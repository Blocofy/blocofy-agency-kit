# End-to-end media pipeline

1. **Plan the set list** per family (`asset-system.md`): one line per asset,
   derived from what its page, service or article says. Note family, ratio +
   model per item (model-matrix.md).
2. **Spend gate** (`SKILL.md` ground rule 2): balance, the list, estimated
   cost; wait for the human's yes before step 3.
3. **Generate** in parallel `images_generate` calls (count=1 each, distinct
   prompts). Reference-guided items first upload refs:
   `creations_request_upload(mimeType, count)` → `curl -X PUT -H "Content-Type: <mime>" --data-binary @file "<proxyUploadUrl>"` → `creations_finalize_upload(uploads:[{path}…])`.
4. **Wait**: `creations_wait` (≤8 ids per call; poll until terminal).
5. **Inspect every image at full size** (Read the downloaded file). Reject on:
   gibberish text, palette drift, wrong mood. Regenerate rejects with adjusted
   prompt/model — don't ship "close enough".
6. **Download** via the returned `url` (token-expiring — download immediately).
7. **Upload to Blocofy**: platform `references/media.md` recipe
   (`-F "file=@f;type=<mime>"`, descriptive titles in the site's language). Record
   `id`+`filename` pairs.
8. **Wire in**: tenant CDN URLs into section settings / page documents /
   collection entries. Never leave a generation-service URL in shipped content.
9. **Register** every asset in `.blocofy-build/media-registry.json`
   (`asset-system.md`) so a later session can regenerate or extend the set
   coherently, and append the round's credits to `.blocofy-build/credits.md`.

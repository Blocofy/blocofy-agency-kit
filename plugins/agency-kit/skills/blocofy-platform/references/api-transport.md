# API transport conventions

Base URL: `https://app.blocofy.com/api/v1` · Auth: `Authorization: Bearer $BLOCOFY_API_TOKEN`

## Use curl, not python urllib

`app.blocofy.com` sits behind Cloudflare; python `urllib`'s default signature
is blocked (403, error code 1010). Rules:

- Shell recipes: plain `curl`.
- Python tooling: shell out to curl (`subprocess.run(["curl", …])`) for
  app.blocofy.com; urllib is fine for fetching public tenant-site pages.
- JSON bodies with Turkish characters: write to a temp file and use
  `--data-binary @file.json` — avoids shell-quoting bugs (apostrophes in
  Turkish text break single-quoted inline JSON in zsh).

## `scripts/api.sh`

```bash
scripts/api.sh GET  "/pages?limit=5"
scripts/api.sh POST "/pages/<id>/publish"
scripts/api.sh PATCH "/pages/<id>" @document.json
```

Reads `$BLOCOFY_API_TOKEN`; prints raw JSON to stdout. Pipe to `python3 -m json.tool`
or `python3 -c …` for extraction.

## Error shape and common statuses

- Validation: `422 validation_failed` with `details[{field,label,message}]` —
  invalid field types are rejected loudly, never silently coerced.
- Conflicts: `409` (duplicate slug+locale, live-theme writes without
  `allow_live`, deleting non-empty collections).
- Intermittent `502/504` on create/publish under load — wrap batch operations
  in a retry (2–3 attempts, short backoff).

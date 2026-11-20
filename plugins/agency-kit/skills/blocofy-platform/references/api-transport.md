# API transport conventions

Base URL: `https://app.blocofy.com/api/v1` · Auth: `Authorization: Bearer $BLOCOFY_API_TOKEN`

## Use curl, not python urllib

`app.blocofy.com` sits behind Cloudflare; python `urllib`'s default signature
is blocked (403, error code 1010). Rules:

- Shell recipes: plain `curl`.
- Python tooling: shell out to curl (`subprocess.run(["curl", …])`) for
  app.blocofy.com; urllib is fine for fetching the site's own public pages.
- JSON bodies with Turkish characters: write to a temp file and use
  `--data-binary @file.json` — avoids shell-quoting bugs (apostrophes in
  Turkish text break single-quoted inline JSON in zsh).

## `api.sh`

Run from the site folder; `<skill-dir>` is this skill's folder (`SKILL.md`,
Terms).

```bash
bash <skill-dir>/scripts/api.sh GET  "/pages?limit=5"
bash <skill-dir>/scripts/api.sh POST "/pages/<id>/publish"
bash <skill-dir>/scripts/api.sh PATCH "/pages/<id>" @document.json
```

Reads `$BLOCOFY_API_TOKEN`; prints raw JSON to stdout. Pipe to `python3 -m json.tool`
or `python3 -c …` for extraction.

## Error shape and common statuses

- Validation: `422 validation_failed` with `details[{field,label,message}]` —
  invalid field types are rejected loudly, never silently coerced.
- Conflicts: `409` (duplicate slug+locale, live-theme writes without
  `allow_live`, deleting non-empty collections).
- Intermittent `502/504` under load: for requests that are safe to repeat
  (reads, updates of a known record), retry 2–3 times with a short backoff.
  A create is different: the first request may have succeeded. After a
  failed create, list or read first and repeat it only if nothing was
  created. `POST /media` is never retried blind (`media.md`).

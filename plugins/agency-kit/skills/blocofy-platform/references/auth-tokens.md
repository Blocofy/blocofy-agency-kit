# Auth, tokens and their lifecycles

## Layering (who owns which value)

| Layer | Lives in | Committed? | Examples |
|---|---|---|---|
| Secrets | `.env.local` | never | `BLOCOFY_URL`, `BLOCOFY_CLI_TOKEN`, `BLOCOFY_API_TOKEN` |
| Brand/voice | server-side Site DNA (`read_site_dna`) | server | name, palette, tone, address |
| Build artifacts | `.blocofy-build/*.json`, `NOTES.md` | yes | design-dna, content-model, state |
| Ephemeral | `.blocofy-build/session/` | never | preview-link URLs (bearer-like), cached handles |

## Token types

- `bcf_…` — **CLI dev token** (`BLOCOFY_CLI_TOKEN`). Used by `blocofy` CLI as
  `BLOCOFY_TOKEN`. Scope: theme dev/push/pull/publish for one site. Even when the token can
  publish, an agent does not: theme changes go through a theme work and a
  person's approval (`SKILL.md`).
- `blcf_live_…` — **Admin REST bearer** (`BLOCOFY_API_TOKEN`). Scoped per site
  (pages, content, media, themes…). Never commit; never paste into `.mcp.json`
  as a literal — use `${BLOCOFY_API_TOKEN}` expansion. If a literal ever lands
  in a committed file, rotate the token in the admin panel.

## CLI credential gotcha

`blocofy login` writes `~/.blocofy/credentials.json` (machine-global). In a
multi-tenant agency this WILL point at the wrong site eventually. Rule:

```bash
export BLOCOFY_URL=…            # from .env.local
export BLOCOFY_TOKEN=$BLOCOFY_CLI_TOKEN
blocofy status                  # ALWAYS verify tenant before any write
```

## Preview links

- The `theme dev` signed preview (`?preview=<jwt>`, ~7h) is **retired**.
  Draft preview = per-page link (platform SKILL §3).
- The `url` is returned **once** and works for anyone who has it → cache it
  in `.blocofy-build/session/` (never commit), revoke when done.
- Expired or revoked links **silently render live content** — no error.
  Symptom: "preview lost my changes". Check `expires_at`
  (`list_preview_links`) first.
- Links pin the draft's theme files and settings at creation → regenerate
  after a push or settings change.

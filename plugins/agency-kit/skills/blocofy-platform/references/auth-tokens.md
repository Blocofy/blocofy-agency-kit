# Auth, tokens and their lifecycles

## Layering (who owns which value)

| Layer | Lives in | Committed? | Examples |
|---|---|---|---|
| Secrets | `.env.local` | never | `BLOCOFY_URL`, `BLOCOFY_CLI_TOKEN`, `BLOCOFY_API_TOKEN` |
| Brand/voice | server-side Site DNA (`read_site_dna`) | server | name, palette, tone, address |
| Build artifacts | `.blocofy-build/*.json`, `NOTES.md` | yes | design-dna, content-model, state |
| Ephemeral | `.blocofy-build/session/` | never | preview-link URLs (bearer-like), cached handles |

## Token types

- `bcf_…` (older) or `bcf2_…` (current, needs CLI 0.16+): **CLI token**
  (`BLOCOFY_CLI_TOKEN`). Used by `blocofy` CLI as `BLOCOFY_TOKEN`. Scope: theme dev/push/pull/publish for one site. Even when the token can
  publish, an agent does not: theme changes go through a theme work and a
  person's approval (`SKILL.md`).
- `blcf_live_…` (older) or `blcf_k2_…` (current): **API key**
  (`BLOCOFY_API_TOKEN`; the CLI reads the same value as `BLOCOFY_API_KEY`
  with `BLOCOFY_API_URL` for theme-work commands). A new key is created with
  the "theme development" profile: it reads and works on drafts and cannot
  publish; that is the profile an agent should hold. Scoped per site
  (pages, content, media, themes…). Never commit; never paste into any agent
  config file as a literal (`.mcp.json`, `.codex/config.toml`,
  `.gemini/settings.json`, `.cursor/mcp.json`, `opencode.jsonc`, …): the
  config reads the `BLOCOFY_API_TOKEN` environment variable (syntax per agent:
  kit README, "Connect a site"). If a literal ever lands in a committed file,
  rotate the token in the admin panel.

## CLI credential gotcha

`blocofy login` writes `~/.blocofy/credentials.json` (machine-global). In an
agency with several sites this WILL point at the wrong site eventually. Rule:

```bash
export BLOCOFY_URL=…            # from .env.local
export BLOCOFY_TOKEN=$BLOCOFY_CLI_TOKEN
blocofy status                  # ALWAYS verify the site before any write
```

## Preview links

- The `theme dev` signed preview (`?preview=<jwt>`, ~7h) is **retired**.
  Draft preview = per-page link (platform SKILL §3).
- The `url` is returned **once** and works for anyone who has it → cache it
  in `.blocofy-build/session/` (never commit), revoke when done.
- Expired or revoked links **silently render live content** — no error.
  Symptom: "preview lost my changes". Check `expires_at`
  (`list_preview_links`) first.
- After a push or a theme-settings change, create one new link for that
  theme; per the platform docs the theme's older links then show the new
  state too (`SKILL.md` §3).

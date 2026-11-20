# Blocofy Agency Kit

Reusable Claude Code skill suite for building creative corporate websites on
**Blocofy CMS** from scratch. One plugin (`agency-kit`), six skills, one
orchestrator. Contains **no client or personal data** — every tenant-specific
value is read at runtime from the tenant workspace.

## Install

```bash
claude plugin marketplace add Blocofy/blocofy-agency-kit
claude plugin install agency-kit@blocofy
```

Update later with: `claude plugin update agency-kit@blocofy`

### Even easier options

**One-command bootstrap** (installs plugins + gsap-skills + direnv hook):

```bash
git clone https://github.com/Blocofy/blocofy-agency-kit && bash blocofy-agency-kit/setup.sh
```

**Zero-command for teammates** — commit this `.claude/settings.json` into any
shared workspace repo; whoever opens it in Claude Code gets prompted to
install the marketplace + plugin automatically:

```json
{
  "extraKnownMarketplaces": {
    "blocofy": {
      "source": { "source": "github", "repo": "Blocofy/blocofy-agency-kit" }
    }
  },
  "enabledPlugins": { "agency-kit@blocofy": true }
}
```

**Let Claude do it** — on a fresh machine, open Claude
Code anywhere and say: *"Blocofy/blocofy-agency-kit reposunu kur ve README'deki
kurulumu tamamla"*. The agent runs the same steps.

### No GitHub? Fully offline options

The plugin system installs from a **local directory** just as well:

1. **Copy the folder** (USB, AirDrop, network share, zip) to the machine, then:

   ```bash
   bash /path/to/blocofy-agency-kit/setup.sh     # auto-detects local mode
   # or manually:
   claude plugin marketplace add /path/to/blocofy-agency-kit
   claude plugin install agency-kit@blocofy
   ```

2. **Any git host works** — GitLab, Bitbucket, self-hosted Gitea, or a bare
   repo on a NAS: `git clone <any-remote> && bash blocofy-agency-kit/setup.sh`.

3. **Zero-command settings for a shared folder** — the `directory` source:

   ```json
   {
     "extraKnownMarketplaces": {
       "blocofy": {
         "source": { "source": "directory", "path": "/path/to/shared/blocofy-agency-kit" }
       }
     },
     "enabledPlugins": { "agency-kit@blocofy": true }
   }
   ```

   The path must exist on each machine — agree on a fixed location
   (e.g. a mounted share or `~/Blocofy/blocofy-agency-kit`).

Updates without GitHub: replace the folder with the new copy (or `git pull`
from your host), then `claude plugin update agency-kit@blocofy`.

### Prerequisites (installed separately, invoked by name — never copied)

| Dependency | Purpose | Install |
|---|---|---|
| `gsap-skills` plugin | Correct GSAP/ScrollTrigger usage | `claude plugin marketplace add greensock/gsap-skills && claude plugin install gsap-skills@gsap-skills` |
| `modern-web-guidance` skill (optional) | Native dialog/popover/form patterns and the QA legacy-pattern sweep; never overrides the theme kit (GSAP/Lenis motion stays) | `claude plugin marketplace add GoogleChrome/modern-web-guidance && claude plugin install modern-web-guidance@googlechrome` (Node ≥ 22; `setup.sh` prints this, does not run it) |
| `blocofy` CLI | theme dev / push / publish | provided by platform |
| Freepik/Magnific MCP | AI image & video generation | claude.ai connector / MCP config |
| Playwright (`npm i playwright`) | QA scripts | per workspace or shared |

## Skills

| Skill | One-line responsibility |
|---|---|
| `blocofy-orchestrator` | Runs the site-build phase machine from `.blocofy-build/STATE.md`; routes to the right skill by name; validates artifact contracts at phase exits. Owns the concept process (direction board, coverage matrix, client pick, revisions) and the `design-dna.json` v2 contract. |
| `blocofy-platform` | The single answer to "how do I touch Blocofy": operation→channel matrix (MCP → CLI → curl), auth/token rules, API trap recipes, `doctor.sh` / `api.sh`. |
| `blocofy-theme-kit` | Conventions that turn `design-dna.json` into a valid Blocofy theme: section anatomy, CSS tokens, chrome pattern, motion adapter, a11y gates. |
| `blocofy-media` | AI media discipline: asset families with client-picked style references, series rule, `media-registry.json`, model matrix, no-text prompt rule, reference-guided generation, cost checks, MIME-correct uploads. |
| `blocofy-qa` | Playwright verification recipes and the `site_readiness` publish gate. |
| `site-build-method` | Agency method above the phase machine (Turkish): prototype-first vs theme-direct decision, 13 gated phases from intake to handover, contract templates, roles, parity/quality gates, prelaunch checklist, change control, Blocofy adapter with retestable known issues, the mistakes each rule came from. |

## Tenant workspace convention (assumed, never embedded)

```
tenants/<domain>/
├── .env.local          # gitignored: BLOCOFY_URL, BLOCOFY_CLI_TOKEN, BLOCOFY_API_TOKEN
├── .mcp.json           # "Authorization": "Bearer ${BLOCOFY_API_TOKEN}" — never a literal token
├── .blocofy-build/     # STATE.md, design-dna.json, content-model.json, NOTES.md
│   └── session/        # gitignored: preview-token cache (short-lived)
├── theme/              # blocofy CLI push source
└── content/            # page documents, media briefs
```

## Rules of the house

- Skills never contain a literal site URL, token, brand name or client fact.
- Secrets live in `.env.local`; brand/voice lives in the server-side Site DNA;
  build artifacts live in `.blocofy-build/`; ephemeral tokens in `session/`.
- Site-specific lessons stay in the tenant `NOTES.md`; generalizable lessons
  get promoted into this repo via PR (the orchestrator's Phase 7 retro asks).
- Run `scripts/leak-lint.sh` before every push. Put your own client and
  tenant names in `scripts/leak-lint.local` (one regex per line, gitignored)
  so they are checked without being published.

## License

MIT, see `LICENSE`.

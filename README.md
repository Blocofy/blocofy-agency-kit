# Blocofy Agency Kit

Claude Code skills for building a client website on **Blocofy CMS** from brief
to launch. One plugin (`agency-kit`), six skills, one orchestrator. It holds no
client or personal data: every site-specific value is read at runtime from
your own workspace.

## What you need first

| Need | Why | Where |
|---|---|---|
| Claude Code | runs the skills | https://claude.com/claude-code |
| A Blocofy site, and its owner's help | the kit builds on it; only the site owner can create the keys below | https://blocofy.com |
| Node 18 or newer | Blocofy CLI and the QA scripts | https://nodejs.org |
| `curl`, `jq`, `bash` | the helper scripts | preinstalled or from your package manager (`brew`, `apt`, `winget`). On Windows use Git Bash or WSL: the commands in this file are bash |
| Playwright with a browser | page checks and reference recon | `npm i playwright && npx playwright install chromium` in the workspace |
| `gsap-skills` plugin | motion guidance the theme skill calls by name | installed in the next section |
| An image-generation connector (optional, paid) | only if you want generated images or video; the media skill is written for the Freepik/Magnific connector | your Claude connectors |
| `modern-web-guidance` plugin (optional) | the QA legacy-pattern sweep | `claude plugin marketplace add GoogleChrome/modern-web-guidance && claude plugin install modern-web-guidance@googlechrome` (Node 22+) |

Nothing else is required. The concept phase and the reference-site recon run
on the kit alone.

## Install the plugin

```bash
claude plugin marketplace add Blocofy/blocofy-agency-kit
claude plugin install agency-kit@blocofy
claude plugin marketplace add greensock/gsap-skills
claude plugin install gsap-skills@gsap-skills
```

These install for your user account (Claude Code's own configuration), so
the skills are available in every folder. Update later with `claude plugin update agency-kit@blocofy`, then restart
Claude Code.

A team can have Claude Code offer the plugin to everyone who opens a shared
workspace by committing this to the workspace's `.claude/settings.json`:

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

Or let the script do the same four commands and check the tools in the table:

```bash
git clone https://github.com/Blocofy/blocofy-agency-kit && bash blocofy-agency-kit/setup.sh
```

It installs the two plugins and nothing else: no packages, no edits to shell
or system files. It prints what is missing and where to get it, and ends with
`RESULT: ready.` or a list of what is still missing.

To install from a copy of this folder instead of GitHub:
`claude plugin marketplace add /path/to/blocofy-agency-kit`.

## Connect a site

Do this once per client site. Make an empty folder for the site (any name,
anywhere) and do every step below inside it; this folder is what the kit
calls the site's workspace. Blocofy's own guide
is in the panel under **Başlarken** (Getting started) and at
https://docs.blocofy.com (in Turkish).

1. **Install the Blocofy CLI.**

   ```bash
   npm i -g @blocofy/cli
   ```

2. **Create two credentials in the Blocofy panel**, under
   *Ayarlar → Bağlantılar ve anahtarlar* (Settings → Connections and keys).
   Only the site owner sees this screen.
   - *Yeni API anahtarı* (new API key). Keep the default profile, *Tema
     geliştirme* (Theme development): it reads the site and works on drafts and
     cannot publish. The key is shown once.
   - *Yeni CLI token'ı* (new CLI token).

3. **Put them in a file named `.env.local`** in the site folder. If the folder
   is a git repository, add `.env.local` to its `.gitignore` before the first
   commit. Quote a value that contains spaces or symbols.

   ```bash
   BLOCOFY_URL=https://your-site.example      # the site's address
   BLOCOFY_API_TOKEN=...                      # the API key
   BLOCOFY_CLI_TOKEN=...                      # the CLI token
   BLOCOFY_TOKEN=...                          # the CLI token again: the CLI itself reads this name
   ```

   With these in place the CLI needs no separate login. Load the file into
   your terminal, then start Claude Code **from that same terminal**:

   ```bash
   set -a; . ./.env.local; set +a
   claude
   ```

   Claude Code started from an app icon or an editor does not see these
   variables and the connection in step 4 will fail to authenticate. If that
   happens, start it from the terminal; do not paste the key into `.mcp.json`.

4. **Add the Blocofy connection for Claude Code** as `.mcp.json` in the site
   folder. The key is read from the environment and is never written into the
   file:

   ```json
   {
     "mcpServers": {
       "blocofy": {
         "type": "http",
         "url": "https://app.blocofy.com/api/v1/mcp",
         "headers": { "Authorization": "Bearer ${BLOCOFY_API_TOKEN}" }
       }
     }
   }
   ```

   The first time, Claude Code asks you to approve this project's `.mcp.json`.
   Inside Claude Code, `/mcp` should then list `blocofy` as connected.

5. **Check the key.** A working key answers with `"ok": true` and the name and
   address of the site it belongs to; confirm it is the site you mean.

   ```bash
   curl -s https://app.blocofy.com/api/v1/ping -H "Authorization: Bearer $BLOCOFY_API_TOKEN"
   ```

6. **Start.** Open Claude Code in the site folder and say what you want, for
   example "start a new Blocofy site for this client". The kit checks the
   connection first and tells you what is missing.

What the agent can and cannot do with these credentials: it works on drafts
and asks you before anything visitors can see changes. Going live with a theme
is always your click in the Blocofy panel.

## Language

The skill texts are in English, except `site-build-method` and its client
templates, which are in Turkish. The agent reads both and answers in the
language you write in. Blocofy's documentation is in Turkish.

## Skills

| Skill | One-line responsibility |
|---|---|
| `blocofy-orchestrator` | Runs the site-build phase machine from `.blocofy-build/STATE.md`; routes to the right skill by name; validates artifact contracts at phase exits. Owns the concept process (direction board, coverage matrix, client pick, revisions) and the `design-dna.json` v2 contract. |
| `blocofy-platform` | The single answer to "how do I touch Blocofy": operation→channel matrix (MCP → CLI → curl), auth/token rules, API trap recipes, `doctor.sh` / `api.sh`. |
| `blocofy-theme-kit` | Conventions that turn `design-dna.json` into a valid Blocofy theme: section anatomy, CSS tokens, chrome pattern, motion adapter, a11y gates. |
| `blocofy-media` | AI media discipline: asset families with client-picked style references, series rule, `media-registry.json`, model matrix, no-text prompt rule, reference-guided generation, cost checks, MIME-correct uploads. |
| `blocofy-qa` | Playwright verification recipes and the `site_readiness` publish gate. |
| `site-build-method` | Agency method above the phase machine (Turkish): prototype-first vs theme-direct decision, 13 gated phases from intake to handover, contract templates, roles, parity/quality gates, prelaunch checklist, change control, Blocofy adapter with retestable known issues, the mistakes each rule came from. |

## Site folder layout

The kit creates and expects these inside the site folder; you only make the
first two files yourself.

```
<site folder>/
├── .env.local          # gitignored: BLOCOFY_URL, BLOCOFY_API_TOKEN, BLOCOFY_CLI_TOKEN, BLOCOFY_TOKEN
├── .mcp.json           # "Authorization": "Bearer ${BLOCOFY_API_TOKEN}" — never a literal token
├── .blocofy-build/     # STATE.md, design-dna.json, content-model.json, NOTES.md
│   └── session/        # short-lived preview links; add .blocofy-build/session/ to .gitignore
├── theme/              # blocofy CLI push source
└── content/            # page documents, media briefs
```

## For contributors

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

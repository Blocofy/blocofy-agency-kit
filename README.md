# Blocofy Agency Kit

Agent skills for building a website on **Blocofy CMS** from brief to launch.
Six skills, one of which (the orchestrator) decides which of the others to use.
They follow the open [Agent Skills](https://agentskills.io) format, so any
agent that loads that format can read them: Claude Code, Codex CLI, Gemini CLI,
Copilot CLI, Cursor, OpenCode, Amp and others. The maintainers have built sites
with the kit only in Claude Code so far; the [install table](#install-the-skills)
says what is tested, what is partly checked and what is not.

The kit holds no client or personal data. Every site-specific value is read at
runtime from your own site folder.

## One site, one folder

One site is one folder, called the **site folder** in this file and in the
skills. It may be a project folder you already have or a new empty one, with
any name, anywhere. Always start your agent inside that folder, never in a
parent folder.

```
One site:
  my-site/          <- keys and agent files live here; start your agent here

Several sites:
  site-a/           <- start your agent here to work on site A
  site-b/           <- a separate terminal and a separate agent session for site B
```

- Everything that belongs to a site (keys, the agent's connection file,
  `AGENTS.md`, build files) stays in that site's folder. Put none of it in a
  parent folder: several agents read configuration from parent folders too and
  would apply it to every site below.
- With one site you may install the skills into the site folder. With several
  sites, install them once per machine and keep the site folders side by side.

## Türkçe hızlı başlangıç

Bu depo, yapay zekâ ajanınıza Blocofy CMS üzerinde briften yayına kadar site kurmayı öğreten altı
skill (beceri paketi) içerir. İçinde müşteri verisi yoktur. Her site tek bir klasördür ve ajan hep
o klasörün içinde başlatılır. Birden çok siteniz varsa her siteye ayrı klasör açın; anahtarlar ve
bağlantı dosyaları üst klasörde durmaz.

1. **Skill'leri kurun** (bilgisayar başına bir kez; Node 22.20 veya üstü gerekir). Claude Code'da
   eklenti (plugin) olarak: `claude plugin marketplace add Blocofy/blocofy-agency-kit`, ardından
   `claude plugin install agency-kit@blocofy`. Diğer ajanlarda:
   `npx skills add Blocofy/blocofy-agency-kit --skill '*' -g`.
2. **Blocofy CLI'yi kurun:** `npm i -g @blocofy/cli`.
3. **Site klasörünü hazırlayın.** Depoyu indirin ve betiği çalıştırın:
   `git clone https://github.com/Blocofy/blocofy-agency-kit`, ardından
   `bash blocofy-agency-kit/setup.sh --site-folder <site klasörü> --agent <ajanınız>`.
   Betik `AGENTS.md`, `.gitignore`, boş bir `.env.local` ve ajanınızın bağlantı dosyasını oluşturur;
   var olan hiçbir dosyaya dokunmaz. Sayfa denetimleri için aynı klasörde
   `npm i playwright && npx playwright install chromium` komutunu çalıştırın.
4. **İki anahtar oluşturun.** Blocofy panelinde *Ayarlar → Bağlantılar ve anahtarlar* ekranında
   *Yeni API anahtarı* (profil *Tema geliştirme* olarak kalsın) ve *Yeni CLI token'ı*. Bu ekranı
   yalnız site sahibi görür.
5. **`.env.local` dosyasında yalnız üç değeri doldurun:** `BLOCOFY_URL` (sitenin adresi),
   `BLOCOFY_API_TOKEN` (API anahtarı), `BLOCOFY_CLI_TOKEN` (CLI token'ı). Alttaki üç satıra dokunmayın.
6. **Anahtarları yükleyin ve sınayın.** Site klasöründe `set -a; . ./.env.local; set +a`, ardından
   `curl -s https://app.blocofy.com/api/v1/ping -H "Authorization: Bearer $BLOCOFY_API_TOKEN"`.
   Yanıtta `"ok": true` ve sitenizin adı görünmelidir.
7. **Ajanı AYNI terminalden başlatın** (`claude`, `codex`, `gemini` ya da `opencode`). Başka bir
   siteye geçerken yeni bir terminal açın; eski terminal ilk sitenin anahtarlarını taşır.
8. **İsteğinizi yazın:** örneğin "bu müşteri için yeni bir Blocofy sitesi kur".

Durum: paket Claude Code'da denendi; Codex, Gemini CLI ve OpenCode'da kurulum ve bağlantı dosyası
kısmen doğrulandı; diğerleri yalnız belgeye göre yazıldı. Ayrıntılı kılavuz aşağıda ve İngilizce:
[Install the skills](#install-the-skills) ve [Connect a site](#connect-a-site).

## What you need first

| Need | Why | Where |
|---|---|---|
| An agent that loads Agent Skills and can connect to an MCP server | it reads the skills and does the work | see the table in the next section |
| A Blocofy site, and its owner's help | the kit builds on it; only the site owner can create the keys | https://blocofy.com |
| Node 22.20 or newer | the universal installer needs it, and it also covers the Blocofy CLI and the QA scripts | https://nodejs.org |
| `curl`, `jq`, `bash` | the helper scripts | preinstalled or from your package manager (`brew`, `apt`, `winget`). On Windows use Git Bash or WSL: the commands in this file are bash |
| Playwright with a browser | page checks and reference recon | installed in the site folder, "Connect a site" step 6 |
| The GSAP skills (optional, recommended) | motion guidance the theme skill refers to | installed in the next section |
| An image-generation MCP server (optional, paid) | only if you want generated images or video. The media skill is written for the Freepik/Magnific server and has been used only from Claude Code | your agent's MCP or connector settings |

Nothing else is required. The concept phase and the reference-site recon run
on the kit alone. One optional QA check, the legacy-pattern sweep, downloads
the `modern-web-guidance` package through `npx` when it runs.

## Install the skills

This section was checked on 2026-11-20. Agents change quickly, so trust the
Status column:

- **tested**: the maintainers have built sites with the kit in this agent.
- **partly checked**: the maintainers installed the skills with the universal
  installer (version 1.7.4) and confirmed with the agent's own commands what
  the Status cell says. No agent session was run and nobody has built a site
  in it yet.
- **docs only**: the steps follow the agent's documentation as of 2026-11 and
  have not been run by the maintainers.

### Pick your agent

| Agent | Recommended install | Other route | Status |
|---|---|---|---|
| Claude Code | plugin | none | tested |
| Codex CLI | universal installer | plugin (not run) | partly checked: the installer places all six skills in `.agents/skills`, where the Codex documentation says it reads them, and Codex 0.162 accepts the connection settings; no session run |
| Gemini CLI | universal installer | none | partly checked: `gemini skills list` (0.30) lists all six skills; Gemini CLI loaded the connection file and tried to connect (it asked to authenticate, because a placeholder key was used); no session run |
| OpenCode | universal installer | none | partly checked: `opencode debug skill` (1.14) lists all six skills and `opencode debug config` resolves the older-shape connection file; no session run |
| Copilot CLI | universal installer | plugin (not run) | docs only |
| Cursor | universal installer | none | docs only |
| Amp | universal installer | none | docs only |
| Devin and Windsurf | universal installer | none | docs only; no Blocofy connection file, see "Connect a site" step 5 |
| Any other agent that loads Agent Skills | universal installer, if it lists your agent | none | docs only |

### Claude Code: the plugin

```bash
claude plugin marketplace add Blocofy/blocofy-agency-kit
claude plugin install agency-kit@blocofy
claude plugin marketplace add greensock/gsap-skills    # optional motion companion
claude plugin install gsap-skills@gsap-skills
```

The plugin installs for your user account, so the skills are available in
every site folder. Update with `claude plugin update agency-kit@blocofy`, then
restart Claude Code. To install from a copy of this folder instead of GitHub:
`claude plugin marketplace add /path/to/blocofy-agency-kit`.

A team can have Claude Code offer the plugin to everyone who opens a site
folder by committing this to that folder's `.claude/settings.json`:

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

### Every other agent: the universal installer

[`npx skills`](https://github.com/vercel-labs/skills) copies the skills into
the folder your agent reads. It needs **Node 22.20 or newer**.

```bash
# One site: run it inside the site folder. The skills go into that folder.
npx skills add Blocofy/blocofy-agency-kit --skill '*'

# Several sites: add -g to install once for your user account.
npx skills add Blocofy/blocofy-agency-kit --skill '*' -g

# Both forms ask which agents to install for. To skip the questions, name
# the agents with -a and add -y.
npx skills add Blocofy/blocofy-agency-kit --skill '*' -a codex -a gemini-cli -g -y

# Optional motion companion.
npx skills add greensock/gsap-skills -g

# Update later.
npx skills update -g
```

- **Install all six skills together** (`--skill '*'`). They call each other's
  scripts as neighbouring folders, so a partial install breaks.
- Agent names for `-a` include `codex`, `gemini-cli`, `github-copilot`,
  `cursor`, `opencode`, `amp` and `windsurf`. The installer's own list has
  more.
- By default the installer links each agent to one shared copy. Add `--copy`
  if you want plain copies.
- The installer sends usage data unless you set `DISABLE_TELEMETRY=1`.

### Codex CLI and Copilot CLI: the plugin route (not run)

Both agents document a plugin install, and this repository carries the
manifests for it. The maintainers have not run either. Use it instead of the
universal installer, not together with it.

```bash
# Codex CLI: then type /plugins in a Codex session, install agency-kit, start a new session.
codex plugin marketplace add Blocofy/blocofy-agency-kit

# Copilot CLI
copilot plugin marketplace add Blocofy/blocofy-agency-kit
copilot plugin install agency-kit@blocofy
```

### Duplicates: one install per agent

A duplicate matters only inside one agent: the same skill listed twice. So
give each agent one install. Do not combine an agent's plugin with an
installer copy for that same agent.

Different agents do not collide. According to their documentation, Claude
Code reads its plugins and `~/.claude/skills` and does not list
`~/.agents/skills`, while Codex CLI, Gemini CLI, Copilot CLI, Cursor, OpenCode
and Amp read `~/.agents/skills`, most of them next to a folder of their own. The Claude Code
plugin for one person and the installer for Gemini CLI or Codex CLI for
another, or both on the same machine, is fine.

Two documented overlaps: OpenCode and Amp also read `~/.claude/skills`, and
Amp also reads the Claude Code plugin cache. On a machine that already has the
Claude Code plugin, check whether Amp lists the skills before you install them
for Amp.

### The setup script

`setup.sh` checks the tools in the table above and helps with the install. It
needs a clone of this repository. It installs no packages and edits no shell
or system file.

```bash
git clone https://github.com/Blocofy/blocofy-agency-kit
bash blocofy-agency-kit/setup.sh --agent claude-code    # installs the two Claude Code plugins
bash blocofy-agency-kit/setup.sh --agent codex          # other agents: prints the installer commands
bash blocofy-agency-kit/setup.sh --agent codex --run    # ... and runs them
bash blocofy-agency-kit/setup.sh --help
```

If you leave out `--agent`, the script assumes `claude-code` and says so in
its first line. It prints what is missing and where to get it, and ends with a
`RESULT:` line. Exit code 0 means done, 1 a step failed, 2 a prerequisite is
missing. A second mode, `--site-folder`, prepares a site folder; step 2 below
uses it.

## Connect a site

Do steps 2 to 9 once per site. Blocofy's own guide is in the panel under
**Başlarken** (Getting started) and at https://docs.blocofy.com (in Turkish).
The script in step 2 prints this same list, with the same numbers, and marks
what it has already done.

1. **Install the Blocofy CLI** (once per machine).

   ```bash
   npm i -g @blocofy/cli
   ```

2. **Prepare the site folder.** The fast way is the setup script. It needs a
   clone of this repository; the folder may be new or an existing one.

   ```bash
   git clone https://github.com/Blocofy/blocofy-agency-kit    # skip if you already have it
   bash blocofy-agency-kit/setup.sh --site-folder /path/to/your-site --agent <your agent>
   ```

   Agent names: `claude-code`, `codex`, `gemini-cli`, `copilot`, `cursor`,
   `opencode`, `amp`. The script creates `AGENTS.md`, `.gitignore`, an empty
   `.env.local` (readable only by you) and the connection file from step 5.
   For `claude-code` it also creates `CLAUDE.md`. It never overwrites a file
   that is already there and it writes no key.

   By hand instead: copy the files from
   `plugins/agency-kit/skills/blocofy-platform/assets/site-template/` into the
   site folder. Copy `gitignore` as `.gitignore` and `env.local.example` as
   `.env.local`; they have no leading dot in the template. If you installed
   the skills without cloning, the same folder is inside the installed
   `blocofy-platform` skill under `assets/site-template/`. If the site folder
   is a git repository, make sure `.env.local` is in its `.gitignore` before
   the first commit.

3. **Create two keys in the Blocofy panel**, under
   *Ayarlar → Bağlantılar ve anahtarlar* (Settings → Connections and keys).
   Only the site owner sees this screen.
   - *Yeni API anahtarı* (New API key). Keep the default profile, *Tema
     geliştirme* (Theme development): it reads the site and works on drafts and
     cannot publish. The key is shown once.
   - *Yeni CLI token'ı* (New CLI token).

4. **Fill in three values in `.env.local`** in the site folder: the site's
   address, the API key and the CLI token. Leave the last three lines exactly
   as they are. Quote a value that contains spaces or symbols. The whole file:

   ```bash
   BLOCOFY_URL=
   BLOCOFY_API_TOKEN=
   BLOCOFY_CLI_TOKEN=
   BLOCOFY_TOKEN="$BLOCOFY_CLI_TOKEN"
   BLOCOFY_API_KEY="$BLOCOFY_API_TOKEN"
   BLOCOFY_API_URL=https://app.blocofy.com
   ```

   The two `$` lines give the Blocofy CLI the same keys under the names it
   reads, so you type each key once. With these in place the CLI needs no
   separate login. The file is meant to be loaded by a shell, as in step 7. A
   tool that reads it without a shell (for example direnv's `dotenv`) does not
   fill in the two `$` lines; use the shell line from step 7 or a loader that
   runs the file as shell (for example direnv's `source_env`).

5. **Tell your agent where the Blocofy connection is.** This is one small
   file in the site folder. The script in step 2 already created it for the
   agent you named; this step is the reference. The server is always named
   `blocofy`. The file holds the **name** of the variable,
   `BLOCOFY_API_TOKEN`, and never the key itself. Ready-made copies are in the
   template's `mcp/` folder.

   Claude Code and Copilot CLI, `.mcp.json`:

   ```json
   { "mcpServers": { "blocofy": {
     "type": "http",
     "url": "https://app.blocofy.com/api/v1/mcp",
     "headers": { "Authorization": "Bearer ${BLOCOFY_API_TOKEN}" } } } }
   ```

   Codex CLI, `.codex/config.toml`. Codex does not load this file until you
   have trusted the folder (checked on Codex 0.162), so trust the site folder
   when Codex asks:

   ```toml
   [mcp_servers.blocofy]
   url = "https://app.blocofy.com/api/v1/mcp"
   bearer_token_env_var = "BLOCOFY_API_TOKEN"
   ```

   `bearer_token_env_var` takes the name of the variable, exactly as written
   here. Never put the key itself in this field: it would not work, and
   `codex mcp list` would print it on screen.

   Gemini CLI, `.gemini/settings.json` (the `context` line makes Gemini CLI
   read `AGENTS.md`):

   ```json
   { "context": { "fileName": ["AGENTS.md", "GEMINI.md"] },
     "mcpServers": { "blocofy": {
       "httpUrl": "https://app.blocofy.com/api/v1/mcp",
       "headers": { "Authorization": "Bearer ${BLOCOFY_API_TOKEN}" } } } }
   ```

   Cursor, `.cursor/mcp.json`:

   ```json
   { "mcpServers": { "blocofy": {
     "url": "https://app.blocofy.com/api/v1/mcp",
     "headers": { "Authorization": "Bearer ${env:BLOCOFY_API_TOKEN}" } } } }
   ```

   OpenCode, `opencode.jsonc`, current shape. It is the shape in the current
   OpenCode documentation. It has not been run, and OpenCode 1.14 rejects it
   with "Invalid input mcp.servers". The script copies this one:

   ```json
   { "$schema": "https://opencode.ai/config.json",
     "mcp": { "servers": { "blocofy": {
       "type": "remote",
       "url": "https://app.blocofy.com/api/v1/mcp",
       "oauth": false,
       "headers": { "Authorization": "Bearer {env:BLOCOFY_API_TOKEN}" } } } } }
   ```

   OpenCode, `opencode.jsonc`, older shape. OpenCode 1.14 reads it correctly
   (checked with `opencode debug config`). Use it if you get the error above.
   The template has it as `mcp/opencode.older.jsonc`:

   ```json
   { "$schema": "https://opencode.ai/config.json",
     "mcp": { "blocofy": {
       "type": "remote",
       "url": "https://app.blocofy.com/api/v1/mcp",
       "oauth": false,
       "headers": { "Authorization": "Bearer {env:BLOCOFY_API_TOKEN}" } } } }
   ```

   Amp, `.amp/settings.json`:

   ```json
   { "amp.mcpServers": { "blocofy": {
     "url": "https://app.blocofy.com/api/v1/mcp",
     "headers": { "Authorization": "Bearer ${BLOCOFY_API_TOKEN}" } } } }
   ```

   Devin and Windsurf: not confirmed. Their documentation does not say whether
   a key can be read from an environment variable in this place, so the kit
   ships no file for them. Do not write the key into a config file as a
   workaround.

   Only the Claude Code file has been used against Blocofy by the maintainers.
   Codex and OpenCode were seen to accept their settings with a placeholder
   key. No real connection has been made from any agent other than Claude
   Code.

6. **Install Playwright in the site folder.** The page checks need it.

   ```bash
   npm i playwright && npx playwright install chromium
   ```

7. **Load the keys and check them.** In a terminal in the site folder:

   ```bash
   set -a; . ./.env.local; set +a
   curl -s https://app.blocofy.com/api/v1/ping -H "Authorization: Bearer $BLOCOFY_API_TOKEN"
   ```

   A working key answers with `"ok": true` and the name and address of the
   site it belongs to. Confirm it is the site you mean.

8. **Start your agent from that same terminal.**

   | Agent | Start command |
   |---|---|
   | Claude Code | `claude` |
   | Codex CLI | `codex` |
   | Gemini CLI | `gemini` |
   | OpenCode | `opencode` |
   | Any other | your agent's start command |

   An agent started from an app icon or an editor does not see the keys, and
   the Blocofy connection will fail to authenticate. If that happens, start it
   from the terminal. Do not paste the key into a config file.

   The first time, Claude Code asks you to approve the folder's `.mcp.json`.
   Codex CLI and Copilot CLI use their file only in a folder you have trusted.
   You can then check that `blocofy` is listed: type `/mcp` in Claude Code,
   Codex CLI or Copilot CLI, or `/mcps` in OpenCode.

   The skills run shell commands that need network access (the Blocofy API and
   the site itself) and that read the `BLOCOFY_*` variables. An agent that
   runs commands in a sandbox (Codex CLI does by default) must be allowed
   network access for this folder, or it will ask you to approve those
   commands.

   **Warning: one terminal per site.** The keys live in the terminal's
   environment. A terminal that you reuse for another site still holds the
   first site's keys, and the agent would then work on the wrong site. To
   switch sites, open a new terminal in the other site folder, load that
   folder's `.env.local` (step 7) and start the agent there.

9. **Say what you want**, for example "start a new Blocofy site for this
   client". The kit checks the connection first and tells you what is missing.

What the agent can and cannot do with these keys: it works on drafts and asks
you before anything visitors can see changes. Going live with a theme is
always your click in the Blocofy panel.

## Several people or several agents on one site

- **Connection files sit side by side.** Each agent reads only its own
  connection file (documented by each agent), so `.mcp.json`,
  `.gemini/settings.json`, `.codex/config.toml` and the others can all be in
  the same site folder.
- **Add an agent later** by running the script again with the other name:
  `bash blocofy-agency-kit/setup.sh --site-folder /path/to/your-site --agent <other agent>`.
  It adds the missing file and overwrites nothing. `CLAUDE.md` is created only
  for `claude-code`, so a teammate on Claude Code runs it once with
  `--agent claude-code` to get it.
- **`AGENTS.md` is shared.** Codex CLI, Copilot CLI, Cursor, OpenCode and Amp
  read it by their documentation. Gemini CLI reads it because of the `context`
  line in its connection file. Claude Code reads it through the one-line
  `CLAUDE.md`.
- **`.blocofy-build/STATE.md` is the handover** between people and between
  agents. This is how the kit is built: the orchestrator skill reads it at the
  start of every session and continues from there.

The rest is the maintainers' advice, not something an agent or Blocofy
enforces:

- One writer at a time. Do not run two agents in the same site folder at once.
- Create one API key and one CLI token per person in the Blocofy panel, so a
  single person's keys can be revoked. Each person keeps their own
  `.env.local`; it is never shared or committed.

## Language

The skill texts are in English, except `site-build-method` and its client
templates, which are in Turkish. The agent reads both and answers in the
language you write in. Blocofy's documentation is in Turkish.

## Skills

Some agents show plugin skills with a prefix, for example
`agency-kit:blocofy-platform` in Claude Code.

| Skill | What it does |
|---|---|
| `blocofy-orchestrator` | Runs the site build step by step, remembers where you are, and leads the choice of a design concept with you. |
| `blocofy-platform` | Knows how to read and change a Blocofy site safely, and when a change needs your yes. |
| `blocofy-theme-kit` | Holds the rules for writing a Blocofy theme: sections, styles, header and footer, motion and accessibility. |
| `blocofy-media` | Plans, generates and uploads images and video for the site as consistent sets, and checks the cost first. |
| `blocofy-qa` | Checks a change in a real browser page and tells you whether the site is ready to publish. |
| `site-build-method` | Describes the full agency process in Turkish, from an approved prototype to sign-off, launch checklist and handover. |

## Site folder layout

You make the first files with `setup.sh --site-folder` or by hand. The agent
creates the rest during a build.

```
<site folder>/
├── .env.local          # gitignored: three values you fill in, three fixed lines
├── AGENTS.md           # tells any agent what this folder is and the rules for it
├── CLAUDE.md           # only for Claude Code: one line, @AGENTS.md
├── .gitignore
├── .mcp.json           # or your agent's connection file from step 5; never a literal key
├── .blocofy-build/     # STATE.md, brief.md, design-dna.json, content-model.json,
│   │                   # media-registry.json, credits.md, NOTES.md
│   ├── concept/        # direction board, coverage matrix
│   └── session/        # short-lived preview links, gitignored
├── theme/              # blocofy CLI push source
└── content/            # page documents, media briefs
```

## For contributors

- Skills never contain a literal site URL, token, brand name or client fact.
- Secrets live in the site folder's `.env.local`; brand and voice live in the
  server-side Site DNA; build artifacts live in `.blocofy-build/`; short-lived
  tokens in `.blocofy-build/session/`.
- Site-specific lessons stay in the site folder's `.blocofy-build/NOTES.md`.
  Lessons that hold for every site get promoted into this repo by pull request
  (the orchestrator's Phase 7 retro asks).
- Run `scripts/leak-lint.sh` before every push. Put your own client and site
  names in `scripts/leak-lint.local` (one regex per line, gitignored) so they
  are checked without being published.
- The version is in two files: `plugins/agency-kit/.claude-plugin/plugin.json`
  (the source) and `plugins/agency-kit/plugin.json` (the portable manifest for
  other agents). Change both together; `scripts/leak-lint.sh` fails if they
  differ.
- The Codex marketplace file is `.agents/plugins/marketplace.json`; the Claude
  Code one is `.claude-plugin/marketplace.json`.
- Template files that start with a dot in a site folder (`.gitignore`,
  `.env.local`) are stored without the dot in the site template, because the
  universal installer does not copy dotfiles. `setup.sh` restores the names.
- Recheck "Install the skills" and step 5 of "Connect a site" against each
  agent's documentation at every release, and update the date and the Status
  cells.

## License

MIT, see `LICENSE`.

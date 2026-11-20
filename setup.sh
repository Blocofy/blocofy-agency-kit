#!/usr/bin/env bash
# Blocofy Agency Kit setup helper. Two modes:
#
#   bash setup.sh --agent <name> [--run] [--source <repo-or-folder>]
#       Checks the prerequisites and helps install the skills.
#       claude-code: installs the two Claude Code plugins.
#       Any other agent: prints the universal installer command (npx skills)
#       and runs it only if --run is also given.
#
#   bash setup.sh --site-folder <dir> --agent <name>
#       Prepares <dir> as the folder of one site: AGENTS.md, .gitignore, an
#       empty .env.local (mode 600) and the agent's Blocofy connection file.
#       Existing files are never overwritten. Run it again with another
#       --agent to add that agent's connection file. Does nothing else.
#
# Without --agent the script assumes claude-code and says so.
# It installs no packages and edits no shell or system file: for everything
# that is missing it prints where to get it.
# Safe to re-run. Needs bash (macOS, Linux, Git Bash or WSL on Windows).
#
# Exit codes: 0 done, nothing missing. 1 a step failed. 2 a prerequisite is
# missing. 64 wrong arguments.
set -uo pipefail

usage() {
  cat <<'TXT'
Usage:
  bash setup.sh --agent <name> [--run] [--source <repo-or-folder>]
  bash setup.sh --site-folder <dir> --agent <name>
  bash setup.sh --help

Options:
  --agent <name>       Your agent. If left out, claude-code is assumed.
                       Known names: claude-code, codex, gemini-cli, copilot,
                       cursor, opencode, amp, windsurf. Another name is passed
                       to the universal installer as it is.
  --run                For agents other than claude-code: run the printed
                       "npx skills add" commands instead of only printing them.
  --source <src>       Install from this GitHub repository or local folder.
                       Default: the folder this script is in.
  --site-folder <dir>  Prepare <dir> (created if missing) as one site's folder
                       and stop: AGENTS.md, .gitignore, an empty .env.local
                       (mode 600), the agent's Blocofy connection file, and
                       CLAUDE.md for claude-code. Existing files are kept.

Exit codes: 0 done, 1 a step failed, 2 a prerequisite is missing, 64 wrong arguments.
TXT
}

say()  { printf '\n%s\n' "$*"; }
ok()   { printf '  ok       %s\n' "$*"; }
miss() { printf '  MISSING  %s\n' "$*"; missing=$((missing + 1)); }
have() { command -v "$1" >/dev/null 2>&1; }
bad_args() { printf 'setup.sh: %s\n\n' "$*" >&2; usage >&2; exit 64; }
missing=0
failed=0

AGENT=""
AGENT_GIVEN=0
RUN=0
SOURCE_ARG=""
SITE_FOLDER=""
SITE_MODE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --agent)        [ $# -ge 2 ] || bad_args "--agent needs a name";          AGENT="$2"; AGENT_GIVEN=1; shift 2 ;;
    --agent=*)      AGENT="${1#*=}"; AGENT_GIVEN=1; shift ;;
    --source)       [ $# -ge 2 ] || bad_args "--source needs a value";        SOURCE_ARG="$2"; shift 2 ;;
    --source=*)     SOURCE_ARG="${1#*=}"; shift ;;
    --site-folder)  [ $# -ge 2 ] || bad_args "--site-folder needs a folder";  SITE_FOLDER="$2"; SITE_MODE=1; shift 2 ;;
    --site-folder=*) SITE_FOLDER="${1#*=}"; SITE_MODE=1; shift ;;
    --run)          RUN=1; shift ;;
    -h|--help)      usage; exit 0 ;;
    *)              bad_args "unknown argument: $1" ;;
  esac
done
if [ "$AGENT_GIVEN" -eq 1 ]; then
  [ -n "$AGENT" ] || bad_args "--agent needs a name"
  case "$AGENT" in -*) bad_args "--agent needs a name, got: $AGENT" ;; esac
else
  AGENT="claude-code"
fi

# One spelling per agent. The names on the right are the ones the universal
# installer (npx skills) uses.
case "$AGENT" in
  claude-code|claude)                 AGENT="claude-code" ;;
  codex|codex-cli)                    AGENT="codex" ;;
  gemini-cli|gemini)                  AGENT="gemini-cli" ;;
  copilot|copilot-cli|github-copilot) AGENT="github-copilot" ;;
  windsurf|devin)                     AGENT="windsurf" ;;
esac

if [ "$AGENT_GIVEN" -eq 1 ]; then
  printf 'Agent: %s\n' "$AGENT"
else
  printf 'No --agent given: assuming claude-code. For another agent add --agent <name> (see --help).\n'
fi

# A copy of the kit next to this script installs from that folder; otherwise
# the public GitHub repository is used.
KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -n "$SOURCE_ARG" ]; then SOURCE="$SOURCE_ARG"
elif [ -f "$KIT_DIR/.claude-plugin/marketplace.json" ]; then SOURCE="$KIT_DIR"
else SOURCE="Blocofy/blocofy-agency-kit"; fi
TEMPLATE_DIR="$KIT_DIR/plugins/agency-kit/skills/blocofy-platform/assets/site-template"

# The command that starts each agent, where the maintainers know it.
case "$AGENT" in
  claude-code) START_CMD="claude" ;;
  codex)       START_CMD="codex" ;;
  gemini-cli)  START_CMD="gemini" ;;
  opencode)    START_CMD="opencode" ;;
  *)           START_CMD="" ;;
esac

# One Node requirement for everything: the universal installer needs 22.20,
# and that also covers the Blocofy CLI and the QA scripts.
node_ok() {
  have node && node -e 'const [a,b]=process.versions.node.split(".").map(Number); process.exit(a>22||(a===22&&b>=20)?0:1)' 2>/dev/null
}

# ---------------------------------------------------------------- site folder
if [ "$SITE_MODE" -eq 1 ]; then
  [ -n "$SITE_FOLDER" ] || bad_args "--site-folder needs a folder"
  [ "$RUN" -eq 0 ] || bad_args "--run does not go with --site-folder"
  if [ ! -f "$TEMPLATE_DIR/AGENTS.md" ]; then
    printf 'setup.sh: site template not found at %s\n' "$TEMPLATE_DIR" >&2
    printf '          Run this script from a full copy (a clone) of the kit.\n' >&2
    exit 1
  fi
  if ! mkdir -p "$SITE_FOLDER"; then printf 'setup.sh: cannot create %s\n' "$SITE_FOLDER" >&2; exit 1; fi
  SITE_DIR="$(cd "$SITE_FOLDER" && pwd)" || { printf 'setup.sh: cannot open %s\n' "$SITE_FOLDER" >&2; exit 1; }

  mcp_src=""; mcp_dst=""
  case "$AGENT" in
    claude-code|github-copilot) mcp_src="mcp/claude-code--copilot.mcp.json"; mcp_dst=".mcp.json" ;;
    codex)       mcp_src="mcp/codex.config.toml";    mcp_dst=".codex/config.toml" ;;
    gemini-cli)  mcp_src="mcp/gemini.settings.json"; mcp_dst=".gemini/settings.json" ;;
    cursor)      mcp_src="mcp/cursor.mcp.json";      mcp_dst=".cursor/mcp.json" ;;
    opencode)    mcp_src="mcp/opencode.jsonc";       mcp_dst="opencode.jsonc" ;;
    amp)         mcp_src="mcp/amp.settings.json";    mcp_dst=".amp/settings.json" ;;
  esac

  kept_mcp=0; kept_gitignore=0; kept_env=0
  copy_one() { # template-relative source, site-relative destination, optional mode
    local src="$TEMPLATE_DIR/$1" dst="$SITE_DIR/$2" mode="${3:-}"
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      printf '  kept     %s (already there, not changed)\n' "$2"
      return 1
    fi
    if mkdir -p "$(dirname "$dst")" && ( [ -z "$mode" ] || umask 077; cp "$src" "$dst" ) && { [ -z "$mode" ] || chmod "$mode" "$dst"; }; then
      if [ -n "$mode" ]; then printf '  created  %s (mode %s, no values in it yet)\n' "$2" "$mode"
      else printf '  copied   %s\n' "$2"; fi
    else
      printf '  FAILED   %s\n' "$2"; failed=1
    fi
    return 0
  }

  say "Site folder: $SITE_DIR"
  copy_one AGENTS.md AGENTS.md
  if [ "$AGENT" = "claude-code" ]; then
    copy_one CLAUDE.md CLAUDE.md
  fi
  # The template keeps these two without the leading dot: skill installers do
  # not copy dotfiles, so the dotted names would be missing after an install.
  copy_one gitignore .gitignore || kept_gitignore=1
  # .env.local is created directly, so there is no example file to mix it up
  # with. It holds no values until the person fills them in.
  copy_one env.local.example .env.local 600 || kept_env=1
  if [ -n "$mcp_src" ]; then
    copy_one "$mcp_src" "$mcp_dst" || kept_mcp=1
  else
    printf '  skipped  connection file: no ready-made file for agent "%s"\n' "$AGENT"
  fi

  # Same steps, order and numbers as README.md, "Connect a site".
  say 'Steps of README.md, "Connect a site" (YOU = still to do by you)'
  if have blocofy; then
    printf '  1. done  Blocofy CLI is installed.\n'
  else
    printf '  1. YOU   Install the Blocofy CLI: npm i -g @blocofy/cli\n'
  fi
  if [ "$kept_gitignore" -eq 1 ] && ! grep -qxF '.env.local' "$SITE_DIR/.gitignore" 2>/dev/null; then
    printf '  2. YOU   The site folder is prepared, but your existing .gitignore does not\n'
    printf '           list .env.local. Add these lines to it before any commit:\n'
    printf '             .env.local\n             .env.local.*\n             .blocofy-build/session/\n             node_modules/\n'
  else
    printf '  2. done  The site folder is prepared.\n'
  fi
  printf '  3. YOU   Create the two keys in the Blocofy panel\n'
  printf '           (Ayarlar -> Bağlantılar ve anahtarlar): an API key and a CLI token.\n'
  if [ "$kept_env" -eq 1 ]; then
    printf '  4. YOU   .env.local was already there and was not changed. Check that it has\n'
    printf '           the three values and the three fixed lines. Compare with:\n'
    printf '           %s/env.local.example\n' "$TEMPLATE_DIR"
  else
    printf '  4. YOU   Open .env.local and fill in three values: BLOCOFY_URL,\n'
    printf '           BLOCOFY_API_TOKEN, BLOCOFY_CLI_TOKEN. Leave the last three lines as they are.\n'
  fi
  if [ -z "$mcp_src" ]; then
    printf '  5. YOU   Tell your agent where the Blocofy connection is. Files and destinations:\n'
    printf '           %s/mcp/README.md\n' "$TEMPLATE_DIR"
  elif [ "$kept_mcp" -eq 1 ]; then
    printf '  5. YOU   %s was already there. If it has no "blocofy" entry, add it by hand from:\n' "$mcp_dst"
    printf '           %s/%s\n' "$TEMPLATE_DIR" "$mcp_src"
  else
    printf '  5. done  Connection file for %s: %s\n' "$AGENT" "$mcp_dst"
  fi
  if [ "$AGENT" = "opencode" ]; then
    printf '           If OpenCode answers "Invalid input mcp.servers" (OpenCode 1.14 does), replace\n'
    printf '           opencode.jsonc with: %s/mcp/opencode.older.jsonc\n' "$TEMPLATE_DIR"
  fi
  if [ -d "$SITE_DIR/node_modules/playwright" ]; then
    printf '  6. done  Playwright is installed in the site folder.\n'
  else
    printf '  6. YOU   In the site folder: npm i playwright && npx playwright install chromium\n'
  fi
  printf '  7. YOU   In a terminal in the site folder, load the keys and check them:\n'
  printf '             set -a; . ./.env.local; set +a\n'
  printf '             curl -s https://app.blocofy.com/api/v1/ping -H "Authorization: Bearer $BLOCOFY_API_TOKEN"\n'
  if [ -n "$START_CMD" ]; then
    printf '  8. YOU   Start your agent from that same terminal: %s\n' "$START_CMD"
  else
    printf '  8. YOU   Start your agent from that same terminal with its start command.\n'
  fi
  printf '  9. YOU   Say what you want, for example "start a new Blocofy site for this client".\n'

  if [ "$failed" -ne 0 ]; then say "RESULT: a file could not be copied, see FAILED above."; exit 1; fi
  say "RESULT: site folder prepared. Nothing was overwritten. No key was written anywhere."
  exit 0
fi

# -------------------------------------------------------------------- install
if [ "$AGENT" = "claude-code" ]; then
  [ "$RUN" -eq 0 ] || printf '\nNote: --run has no effect for claude-code; the plugins are installed either way.\n'
  say "1/3  Claude Code plugins (source: $SOURCE)"
  if ! have claude; then
    miss "claude CLI: install Claude Code first, https://claude.com/claude-code"
    failed=1
  else
    plugin_step() { # label, command...
      local label="$1"; shift
      local out
      if out="$("$@" 2>&1)"; then ok "$label"
      elif printf '%s' "$out" | grep -qiE 'already (added|installed|on disk|at the latest)'; then ok "$label (already there)"
      else printf '  FAILED   %s\n%s\n' "$label" "$(printf '%s' "$out" | tail -3 | sed 's/^/           /')"; failed=1
      fi
    }
    plugin_step "marketplace blocofy"        claude plugin marketplace add "$SOURCE"
    plugin_step "plugin agency-kit@blocofy"  claude plugin install agency-kit@blocofy
    plugin_step "marketplace gsap-skills"    claude plugin marketplace add greensock/gsap-skills
    plugin_step "plugin gsap-skills"         claude plugin install gsap-skills@gsap-skills
  fi
else
  say "1/3  Skills for $AGENT through the universal installer (source: $SOURCE)"
  printf '  The six skills, for your user account:\n'
  printf "    npx skills add %s --skill '*' -a %s -g -y\n" "$SOURCE" "$AGENT"
  printf '  Motion companion (optional):\n'
  printf "    npx skills add greensock/gsap-skills --skill '*' -a %s -g -y\n" "$AGENT"

  if [ "$RUN" -eq 1 ]; then
    if ! have npx; then
      printf '  FAILED   npx not found (it comes with Node.js): https://nodejs.org\n'; failed=1
    elif ! node_ok; then
      printf '  FAILED   the installer needs node 22.20 or newer: https://nodejs.org\n'; failed=1
    else
      run_step() { # label, command...
        local label="$1"; shift
        printf '  running  %s\n' "$label"
        if "$@"; then ok "$label"; else printf '  FAILED   %s\n' "$label"; failed=1; fi
      }
      run_step "agency-kit skills for $AGENT" npx skills add "$SOURCE" --skill '*' -a "$AGENT" -g -y
      if [ "$failed" -eq 0 ]; then
        run_step "gsap-skills for $AGENT"     npx skills add greensock/gsap-skills --skill '*' -a "$AGENT" -g -y
      fi
    fi
  else
    printf '  Not run. Run the commands yourself, or run this script again with --run.\n'
  fi
fi

say "2/3  Tools the skills call"
if node_ok; then
  ok "node $(node --version)"
elif have node; then
  miss "node 22.20 or newer (found $(node --version)), for the universal installer, the Blocofy CLI and the QA scripts: https://nodejs.org"
else
  miss "node 22.20 or newer, for the universal installer, the Blocofy CLI and the QA scripts: https://nodejs.org"
fi
have curl && ok "curl" || miss "curl: your OS package manager"
have jq   && ok "jq"   || miss "jq: your OS package manager (brew install jq, apt install jq, winget install jqlang.jq)"
if have blocofy; then ok "blocofy CLI $(blocofy --version 2>/dev/null | head -1)"; else miss "Blocofy CLI: npm i -g @blocofy/cli"; fi

say "3/3  Per site (not done in this run)"
cat <<TXT
  One site is one folder. Prepare it with:
    bash "$KIT_DIR/setup.sh" --site-folder <folder> --agent $AGENT
  It creates AGENTS.md, .gitignore, an empty .env.local and the Blocofy
  connection file for your agent, overwrites nothing, and lists the steps
  that are left for you (keys, the three values in .env.local, Playwright).
  Full steps: README.md, "Connect a site".
  Optional: an image-generation MCP server.
TXT

if [ "$failed" -ne 0 ]; then say "RESULT: an install step failed, see FAILED and MISSING above."; exit 1; fi
if [ "$AGENT" != "claude-code" ] && [ "$RUN" -eq 0 ]; then
  if [ "$missing" -ne 0 ]; then say "RESULT: skills NOT installed by this script (commands printed under 1/3); $missing prerequisite(s) missing, see MISSING above."; exit 2; fi
  say "RESULT: tools ready. Skills NOT installed by this script: run the commands printed under 1/3, or add --run."
  exit 0
fi
if [ "$missing" -ne 0 ]; then say "RESULT: skills installed; $missing prerequisite(s) missing, see MISSING above."; exit 2; fi
say "RESULT: ready."

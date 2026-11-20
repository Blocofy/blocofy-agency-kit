#!/usr/bin/env bash
# Checks the prerequisites for the Blocofy Agency Kit and installs its two
# Claude Code plugins. It installs nothing else and edits no shell or system
# file: for everything that is missing it prints where to get it.
# Safe to re-run. Needs bash (macOS, Linux, Git Bash on Windows).
set -uo pipefail

say()  { printf '\n%s\n' "$*"; }
ok()   { printf '  ok       %s\n' "$*"; }
miss() { printf '  MISSING  %s\n' "$*"; missing=$((missing + 1)); }
have() { command -v "$1" >/dev/null 2>&1; }
missing=0
failed=0

# A copy of the kit next to this script installs from that folder; otherwise
# the public GitHub repository is used.
KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$KIT_DIR/.claude-plugin/marketplace.json" ]; then SOURCE="$KIT_DIR"; else SOURCE="Blocofy/blocofy-agency-kit"; fi

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

say "2/3  Tools the skills call"
if have node; then
  major="$(node -p 'process.versions.node.split(".")[0]' 2>/dev/null || echo 0)"
  if [ "$major" -ge 18 ]; then ok "node $(node --version)"; else miss "node 18 or newer (found $(node --version)): https://nodejs.org"; fi
else
  miss "node 18 or newer: https://nodejs.org"
fi
have curl && ok "curl" || miss "curl: your OS package manager"
have jq   && ok "jq"   || miss "jq: your OS package manager (brew install jq, apt install jq, winget install jqlang.jq)"
if have blocofy; then ok "blocofy CLI $(blocofy --version 2>/dev/null | head -1)"; else miss "Blocofy CLI: npm i -g @blocofy/cli"; fi

say "3/3  Per client site (not done by this script)"
cat <<'TXT'
  In the site's own folder:
    1. .env.local with BLOCOFY_URL, BLOCOFY_API_TOKEN, BLOCOFY_CLI_TOKEN, BLOCOFY_TOKEN
       (keys: Blocofy panel, Ayarlar -> Bağlantılar ve anahtarlar); keep it out of git
    2. .mcp.json pointing at https://app.blocofy.com/api/v1/mcp with
       "Authorization": "Bearer ${BLOCOFY_API_TOKEN}"
    3. npm i playwright && npx playwright install chromium
  Full steps: README.md, "Connect a site".
  Optional: modern-web-guidance plugin (Node 22+), an image-generation connector.
TXT

if [ "$failed" -ne 0 ]; then say "RESULT: a plugin step failed, see FAILED above."; exit 1; fi
if [ "$missing" -ne 0 ]; then say "RESULT: plugins installed; $missing prerequisite(s) missing, see MISSING above."; exit 2; fi
say "RESULT: ready."

#!/usr/bin/env bash
# One-command workstation bootstrap for the Blocofy Agency Kit.
#   curl -fsSL https://raw.githubusercontent.com/Blocofy/blocofy-agency-kit/main/setup.sh | bash
# Idempotent — safe to re-run.
set -uo pipefail

say() { printf '\n\033[1m%s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }

# If this script sits inside a kit copy (USB / shared folder / clone from any
# git host), install from that local path — no GitHub needed.
KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCAL_MODE=0
[ -f "$KIT_DIR/.claude-plugin/marketplace.json" ] && LOCAL_MODE=1

say "1/5 · Source"
if [ "$LOCAL_MODE" = 1 ]; then
  echo "✓ local kit copy detected: $KIT_DIR (GitHub not required)"
else
  echo "✓ no local kit copy next to this script: using the GitHub marketplace"
fi

say "2/5 · Claude Code plugins"
if ! have claude; then echo "✗ claude CLI not found — install Claude Code first"; exit 1; fi
if [ "$LOCAL_MODE" = 1 ]; then
  claude plugin marketplace add "$KIT_DIR" 2>/dev/null || echo "  (marketplace already added)"
else
  claude plugin marketplace add Blocofy/blocofy-agency-kit 2>/dev/null || echo "  (marketplace already added)"
fi
claude plugin install agency-kit@blocofy 2>/dev/null || claude plugin update agency-kit@blocofy
claude plugin marketplace add greensock/gsap-skills 2>/dev/null || echo "  (gsap marketplace already added)"
claude plugin install gsap-skills@gsap-skills 2>/dev/null || echo "  (gsap-skills already installed)"
echo "✓ plugins ready"
# Optional companion — not installed automatically: its skill triggers on every
# frontend task in every project, so each workstation opts in.
echo "  optional: modern-web-guidance (native dialog/popover/form guides + QA legacy sweep):"
echo "    claude plugin marketplace add GoogleChrome/modern-web-guidance && claude plugin install modern-web-guidance@googlechrome"

say "3/5 · direnv"
if ! have direnv; then
  if have brew; then brew install direnv; else echo "✗ install direnv manually (no brew)"; fi
fi
SHELL_RC="$HOME/.zshrc"
if ! grep -q 'direnv hook' "$SHELL_RC" 2>/dev/null; then
  printf '\neval "$(direnv hook zsh)"\n' >> "$SHELL_RC"
  echo "✓ direnv hook added to $SHELL_RC (open a new terminal or: source $SHELL_RC)"
else
  echo "✓ direnv hook present"
fi

say "4/5 · blocofy CLI"
have blocofy && echo "✓ blocofy CLI: $(blocofy --version 2>/dev/null | head -1)" \
  || echo "⚠ blocofy CLI not found — install it from the platform before theme work"

say "5/5 · Next steps (per tenant)"
cat <<'EOF'
  mkdir -p tenants/<domain> && cd tenants/<domain>
  # .env.local  → BLOCOFY_URL / BLOCOFY_CLI_TOKEN / BLOCOFY_API_TOKEN
  # .envrc      → dotenv .env.local   (then: direnv allow)
  # .mcp.json   → "Authorization": "Bearer ${BLOCOFY_API_TOKEN}"
  # then open claude in that folder and say: "yeni site kur"
EOF
echo "DONE"

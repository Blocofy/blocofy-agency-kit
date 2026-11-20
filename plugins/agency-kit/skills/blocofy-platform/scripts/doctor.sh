#!/usr/bin/env bash
# Phase 0 gate: validates the site's env, CLI presence and API reachability.
# Run from the site folder (where .env.local lives), through bash:
#   bash <skill-dir>/scripts/doctor.sh
set -uo pipefail

fail=0
say() { printf '%s\n' "$*"; }

if [ -f .env.local ]; then
  set -a; . ./.env.local; set +a
  say "✓ .env.local loaded"
else
  say "✗ .env.local not found in $(pwd)"; fail=1
fi

for v in BLOCOFY_URL BLOCOFY_CLI_TOKEN BLOCOFY_API_TOKEN; do
  if [ -z "${!v:-}" ]; then say "✗ $v missing"; fail=1; else say "✓ $v set"; fi
done
# The CLI reads these names for theme-work commands; without them a CLI push
# into a work is refused. MCP-only work does not need them.
for v in BLOCOFY_API_KEY BLOCOFY_API_URL; do
  [ -n "${!v:-}" ] && say "✓ $v set" || say "⚠ $v not set (needed for CLI theme-work commands; see the kit README)"
done

if command -v blocofy >/dev/null; then
  say "✓ blocofy CLI: $(blocofy --version 2>/dev/null | head -1 || echo present)"
else
  say "✗ blocofy CLI not on PATH"; fail=1
fi

if [ -n "${BLOCOFY_API_TOKEN:-}" ]; then
  body=$(curl -s -m 15 -w '\n%{http_code}' "https://app.blocofy.com/api/v1/ping" \
    -H "Authorization: Bearer $BLOCOFY_API_TOKEN") || body=$'\n000'
  code=${body##*$'\n'}; json=${body%$'\n'*}
  if [ "$code" = "200" ]; then
    if command -v jq >/dev/null; then
      say "✓ API key belongs to: $(printf '%s' "$json" | jq -r '"\(.site.name // "?") (\(.site.domain // .site.slug // "?")), profile: \(.profile.label // "unprofiled")"')"
      say "  Confirm this is the site you mean (BLOCOFY_URL=${BLOCOFY_URL:-unset})."
    else
      say "✓ Admin API reachable (ping 200); install jq to see which site the key belongs to"
    fi
  else
    say "✗ Admin API check failed (HTTP $code)"; fail=1
  fi
fi

# The CLI reads BLOCOFY_TOKEN. If it is unset or differs, the CLI falls back to
# its saved credentials, which may belong to another site.
if [ -n "${BLOCOFY_CLI_TOKEN:-}" ] && [ "${BLOCOFY_TOKEN:-}" != "${BLOCOFY_CLI_TOKEN}" ]; then
  say "✗ BLOCOFY_TOKEN is unset or differs from BLOCOFY_CLI_TOKEN (the CLI reads BLOCOFY_TOKEN)"; fail=1
fi

if [ -n "${BLOCOFY_URL:-}" ] && [ -n "${BLOCOFY_CLI_TOKEN:-}" ] && command -v blocofy >/dev/null; then
  if status_out=$(BLOCOFY_TOKEN=$BLOCOFY_CLI_TOKEN blocofy status 2>/dev/null); then
    printf '%s\n' "$status_out" | sed -n '1,2p'
  else
    say "✗ blocofy status failed"; fail=1
  fi
fi

# warn if an agent config file in the site folder carries a literal token
# (each agent keeps its MCP config in its own file; an unmatched glob is skipped)
for f in .mcp.json .github/mcp.json .codex/config.toml .gemini/settings.json \
         .cursor/mcp.json opencode.json opencode.jsonc .amp/settings.json \
         .devin/mcp_config*.json; do
  [ -f "$f" ] || continue
  if grep -qE '(blcf|bcf2?)_[A-Za-z0-9]' "$f"; then
    say "⚠ $f contains a LITERAL token — make it read the BLOCOFY_API_TOKEN environment variable (syntax per agent: kit README, \"Connect a site\") and rotate the token"
  fi
done

# The same mistake in an agent's user-level config exposes a key to every
# folder (and Codex prints the field in `codex mcp list`). Read-only check.
for f in "$HOME/.codex/config.toml" "$HOME/.gemini/settings.json" "$HOME/.cursor/mcp.json" \
         "$HOME/.config/opencode/opencode.json" "$HOME/.config/opencode/opencode.jsonc" \
         "$HOME/.copilot/mcp-config.json" "$HOME/.claude.json"; do
  [ -f "$f" ] || continue
  if grep -qE '(blcf_live|blcf_k2|bcf2?)_[A-Za-z0-9_-]{16,}' "$f"; then
    say "⚠ $f (your user-level agent config) contains what looks like a literal Blocofy key — replace it with the environment variable and rotate that key"
  fi
done

[ "$fail" = 0 ] && say "DOCTOR: OK" || { say "DOCTOR: FAILED"; exit 1; }

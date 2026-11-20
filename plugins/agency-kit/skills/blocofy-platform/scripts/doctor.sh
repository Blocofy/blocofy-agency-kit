#!/usr/bin/env bash
# Phase 0 gate: validates tenant env, CLI presence and API reachability.
# Run from the tenant workspace root (where .env.local lives).
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

# warn if .mcp.json carries a literal token
if [ -f .mcp.json ] && grep -qE 'Bearer (blcf_|bcf_)' .mcp.json; then
  say "⚠ .mcp.json contains a LITERAL token — switch to \"Bearer \${BLOCOFY_API_TOKEN}\" and rotate the token"
fi

[ "$fail" = 0 ] && say "DOCTOR: OK" || { say "DOCTOR: FAILED"; exit 1; }

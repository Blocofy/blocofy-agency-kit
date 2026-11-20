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

if command -v blocofy >/dev/null; then
  say "✓ blocofy CLI: $(blocofy --version 2>/dev/null | head -1 || echo present)"
else
  say "✗ blocofy CLI not on PATH"; fail=1
fi

if [ -n "${BLOCOFY_API_TOKEN:-}" ]; then
  code=$(curl -s -o /tmp/blocofy-doctor.json -w "%{http_code}" -m 15 \
    "https://app.blocofy.com/api/v1/pages?limit=1" \
    -H "Authorization: Bearer $BLOCOFY_API_TOKEN")
  if [ "$code" = "200" ]; then
    say "✓ Admin API reachable (pages endpoint 200)"
  else
    say "✗ Admin API check failed (HTTP $code)"; fail=1
  fi
fi

if [ -n "${BLOCOFY_URL:-}" ] && [ -n "${BLOCOFY_CLI_TOKEN:-}" ]; then
  BLOCOFY_TOKEN=$BLOCOFY_CLI_TOKEN blocofy status 2>/dev/null | head -2 || { say "✗ blocofy status failed"; fail=1; }
fi

# warn if .mcp.json carries a literal token
if [ -f .mcp.json ] && grep -qE 'Bearer (blcf_|bcf_)' .mcp.json; then
  say "⚠ .mcp.json contains a LITERAL token — switch to \"Bearer \${BLOCOFY_API_TOKEN}\" and rotate the token"
fi

[ "$fail" = 0 ] && say "DOCTOR: OK" || { say "DOCTOR: FAILED"; exit 1; }

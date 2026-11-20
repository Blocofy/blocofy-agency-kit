#!/usr/bin/env bash
# Fails if any tenant/client data or live token leaks into the kit.
# Tenant and client names go in scripts/leak-lint.local (one regex per line,
# gitignored) so the names themselves are never published.
set -euo pipefail
cd "$(dirname "$0")/.."

# Match REAL tokens (prefix + long body) and tenant leftovers — not doc mentions of prefixes.
PATTERNS='blcf_live_[A-Za-z0-9_-]{10,}|bcf_[A-Za-z0-9_-]{20,}|myblocofy\.com/cdn|pikaso\.cdnpk'
LOCAL="scripts/leak-lint.local"
if [ -f "$LOCAL" ]; then
  EXTRA="$(grep -vE '^\s*(#|$)' "$LOCAL" | paste -sd'|' - || true)"
  [ -n "$EXTRA" ] && PATTERNS="$PATTERNS|$EXTRA"
fi
if grep -rInE "$PATTERNS" --exclude-dir=.git --exclude=.git --exclude="leak-lint.sh" --exclude="leak-lint.local" .; then
  echo "✗ Leak lint FAILED: tenant/client data or token found above." >&2
  exit 1
fi
echo "✓ Leak lint clean."

# The version lives in two manifests. plugins/agency-kit/.claude-plugin/plugin.json
# is the source; the portable plugins/agency-kit/plugin.json must match it.
if ! command -v jq >/dev/null 2>&1; then
  echo "✗ Version check needs jq." >&2
  exit 1
fi
if ! jq -e --slurpfile a plugins/agency-kit/.claude-plugin/plugin.json '.version == $a[0].version' plugins/agency-kit/plugin.json >/dev/null; then
  echo "✗ plugin.json version drift: plugins/agency-kit/plugin.json and plugins/agency-kit/.claude-plugin/plugin.json differ." >&2
  exit 1
fi
echo "✓ Manifest versions match."

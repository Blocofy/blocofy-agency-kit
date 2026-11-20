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
  EXTRA="$(grep -vE '^\s*(#|$)' "$LOCAL" | paste -sd'|' -)"
  [ -n "$EXTRA" ] && PATTERNS="$PATTERNS|$EXTRA"
fi
if grep -rInE "$PATTERNS" --exclude-dir=.git --exclude=.git --exclude="leak-lint.sh" --exclude="leak-lint.local" .; then
  echo "✗ Leak lint FAILED: tenant/client data or token found above." >&2
  exit 1
fi
echo "✓ Leak lint clean."

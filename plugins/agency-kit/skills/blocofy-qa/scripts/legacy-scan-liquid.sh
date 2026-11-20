#!/usr/bin/env bash
# Legacy-pattern scan for a Blocofy theme, Liquid templates included.
#   Usage: legacy-scan-liquid.sh <theme-dir> [--json]
# `modern-web-guidance legacy-scan` reads .css/.js/.html but skips .liquid, so
# this copies the theme to a temp dir with every .liquid renamed to .html and
# scans the copy. The theme itself is never modified.
# Needs Node >= 22 and network access (npx fetches the scanner).
# Reported paths are relative to the theme; read "x.html" as "x.liquid" when
# no x.html exists in the theme.
set -euo pipefail

THEME="${1:-}"
if [ -z "$THEME" ] || [ ! -d "$THEME" ]; then
  echo "Usage: legacy-scan-liquid.sh <theme-dir> [--json]" >&2
  exit 2
fi
shift
command -v npx >/dev/null 2>&1 || { echo "✗ npx not found (Node >= 22 required)" >&2; exit 2; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

( cd "$THEME" && find . -type f \
    \( -name '*.liquid' -o -name '*.css' -o -name '*.js' -o -name '*.mjs' -o -name '*.ts' -o -name '*.html' \) \
    -not -path '*/node_modules/*' -not -path '*/.git/*' -print0 ) |
while IFS= read -r -d '' f; do
  dest="$TMP/${f#./}"
  case "$dest" in *.liquid) dest="${dest%.liquid}.html" ;; esac
  mkdir -p "$(dirname "$dest")"
  cp "$THEME/$f" "$dest"
done

cd "$TMP"
npx -y modern-web-guidance@latest legacy-scan . "$@"

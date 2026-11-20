#!/usr/bin/env bash
# Legacy-pattern scan for a Blocofy theme, Liquid templates included.
#   Usage: bash <skill-dir>/scripts/legacy-scan-liquid.sh <theme-dir> [--json]
# `modern-web-guidance legacy-scan` reads .css/.js/.html but skips .liquid, so
# this copies the theme to a temp dir with every .liquid renamed to .html and
# scans the copy. The theme itself is never modified.
# Needs Node >= 22 and network access (npx fetches the scanner, pinned to an
# exact version). The scanner runs without the BLOCOFY_* variables: it has no
# use for site tokens.
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

UNSET=()
while IFS= read -r v; do UNSET+=(-u "$v"); done < <(compgen -v | grep '^BLOCOFY_' || true)

cd "$TMP"
env ${UNSET[@]+"${UNSET[@]}"} npx -y modern-web-guidance@1.0.1 legacy-scan . "$@"

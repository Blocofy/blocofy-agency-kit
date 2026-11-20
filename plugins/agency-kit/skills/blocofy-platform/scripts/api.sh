#!/usr/bin/env bash
# Thin Blocofy Admin REST wrapper.
#   api.sh GET  "/pages?limit=5"
#   api.sh POST "/pages/<id>/publish"
#   api.sh PATCH "/pages/<id>" @document.json
# Reads BLOCOFY_API_TOKEN from env (source .env.local first).
set -euo pipefail

: "${BLOCOFY_API_TOKEN:?BLOCOFY_API_TOKEN not set — source the tenant .env.local}"
METHOD=${1:?method}; PATHQ=${2:?path}; BODY=${3:-}

# Writes with no preview on the platform (references/live-writes.md). The path
# alone cannot tell a published entry from a draft one, so entry, schema,
# form, live-page field and release writes are covered by the rule in the
# skill, not by this guard. The guard is a reminder, not the protection.
guard=""
case "$METHOD" in
  DELETE)
    case "$PATHQ" in
      */preview-links/*) ;;            # ends a link this session created
      *) guard="a delete" ;;
    esac ;;
  POST|PUT|PATCH)
    case "$PATHQ" in
      */publish*|*/unpublish*) guard="a publish-state change" ;;
      /site|/site\?*|/site/*) guard="a site-settings write" ;;
      /menus*) guard="a menu write" ;;
    esac ;;
esac
if [ -n "$guard" ] && [ "${LIVE_WRITE_OK:-}" != "1" ]; then
  echo "api.sh: $METHOD $PATHQ is $guard: it takes effect at once and has no preview." >&2
  echo "Tell the human what changes, where it shows and how it is undone; after their yes," >&2
  echo "re-run this one call with LIVE_WRITE_OK=1." >&2
  echo "Exception: publishing a page that belongs to a DRAFT theme is not visible to visitors;" >&2
  echo "for that case set LIVE_WRITE_OK=1 without asking, after confirming the page's theme is a draft." >&2
  exit 3
fi

# -sS: quiet but show transport errors. --fail-with-body: a 4xx/5xx still prints
# the error JSON and makes the script exit non-zero.
args=(-sS --fail-with-body -X "$METHOD" "https://app.blocofy.com/api/v1${PATHQ}"
      -H "Authorization: Bearer $BLOCOFY_API_TOKEN")
if [ -n "$BODY" ]; then
  args+=(-H "Content-Type: application/json" --data-binary "$BODY")
fi
curl "${args[@]}"

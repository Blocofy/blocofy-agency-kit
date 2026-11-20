#!/usr/bin/env bash
# Thin Blocofy Admin REST wrapper.
#   api.sh GET  "/pages?limit=5"
#   api.sh POST "/pages/<id>/publish"
#   api.sh PATCH "/pages/<id>" @document.json
# Reads BLOCOFY_API_TOKEN from env (source .env.local first).
set -euo pipefail

: "${BLOCOFY_API_TOKEN:?BLOCOFY_API_TOKEN not set — source the tenant .env.local}"
METHOD=${1:?method}; PATHQ=${2:?path}; BODY=${3:-}

args=(-s -X "$METHOD" "https://app.blocofy.com/api/v1${PATHQ}"
      -H "Authorization: Bearer $BLOCOFY_API_TOKEN")
if [ -n "$BODY" ]; then
  args+=(-H "Content-Type: application/json" --data-binary "$BODY")
fi
curl "${args[@]}"

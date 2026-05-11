#!/usr/bin/env bash
# Deploy this folder to Vercel as a static site. Requires VERCEL_TOKEN in env and
# outbound access to api.vercel.com (BLOCKED in the Designer Agent's container).
set -euo pipefail
: "${VERCEL_TOKEN:?Set VERCEL_TOKEN}"
command -v vercel >/dev/null || npm install -g vercel
vercel --prod --yes --token "$VERCEL_TOKEN"

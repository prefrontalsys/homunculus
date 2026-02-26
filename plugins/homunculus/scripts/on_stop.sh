#!/bin/bash
# Homunculus v2 Stop Hook
# Updates session count

set -e

# Resolve homunculus directory (treewalk up from CWD, fallback to ~/.claude/homunculus/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/resolve.sh" 2>/dev/null || HOMUNCULUS_DIR=".claude/homunculus"

STATE="$HOMUNCULUS_DIR/identity.json"
PENDING_DIR="$HOMUNCULUS_DIR/instincts/pending"

# Ensure directories exist
mkdir -p "$(dirname "$STATE")"
mkdir -p "$PENDING_DIR"

# Update session count
if [ -f "$STATE" ] && command -v jq >/dev/null 2>&1; then
  COUNT=$(jq -r ".journey.sessionCount // 0" "$STATE")
  TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  TMP=$(mktemp)

  jq --arg c "$((COUNT+1))" --arg t "$TIMESTAMP" \
    '.journey.sessionCount = ($c|tonumber) | .journey.lastSession = $t' \
    "$STATE" > "$TMP" && mv "$TMP" "$STATE"
fi

exit 0

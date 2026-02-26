#!/bin/bash
# Homunculus Directory Resolution
# Walks up from CWD looking for .claude/homunculus/identity.json,
# falls back to ~/.claude/homunculus/ (user-level).
#
# Usage: source this file, then use $HOMUNCULUS_DIR
#   source "$(dirname "$0")/resolve.sh"
#   echo "$HOMUNCULUS_DIR"
#
# Resolution order:
#   1. Walk up from CWD → first .claude/homunculus/identity.json wins
#   2. ~/.claude/homunculus/ (user-level fallback)
#   3. .claude/homunculus/ (project-local, for fresh init)

_resolve_homunculus_dir() {
  local dir="$PWD"

  # Walk up looking for identity.json (the birth marker)
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.claude/homunculus/identity.json" ]; then
      echo "$dir/.claude/homunculus"
      return 0
    fi
    dir="$(dirname "$dir")"
  done

  # Fallback: user-level
  if [ -f "$HOME/.claude/homunculus/identity.json" ]; then
    echo "$HOME/.claude/homunculus"
    return 0
  fi

  # Not born yet — default to project-local (init will create it)
  echo ".claude/homunculus"
  return 1
}

HOMUNCULUS_DIR="$(_resolve_homunculus_dir)"
export HOMUNCULUS_DIR

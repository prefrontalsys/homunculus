---
description: Export instincts for sharing
---

# Export Instincts

Package your learned instincts for sharing with others.

## What Gets Exported

- Personal instincts (`$HOMUNCULUS_DIR/instincts/personal/`)
- Optionally: inherited instincts

Does NOT export:
- Observations (too personal, too large)
- Identity (bound to you)
- Pending instincts (not yet approved)

## Create Export

```bash
# Resolve homunculus directory (treewalk)
_dir="$PWD"
HOMUNCULUS_DIR=""
while [ "$_dir" != "/" ]; do
  if [ -f "$_dir/.claude/homunculus/identity.json" ]; then
    HOMUNCULUS_DIR="$_dir/.claude/homunculus"
    break
  fi
  _dir="$(dirname "$_dir")"
done
[ -z "$HOMUNCULUS_DIR" ] && [ -f "$HOME/.claude/homunculus/identity.json" ] && HOMUNCULUS_DIR="$HOME/.claude/homunculus"
[ -z "$HOMUNCULUS_DIR" ] && HOMUNCULUS_DIR=".claude/homunculus"

# Create exports directory
mkdir -p "$HOMUNCULUS_DIR/exports"

# Export personal instincts
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
EXPORT_FILE="$HOMUNCULUS_DIR/exports/instincts-$TIMESTAMP.tar.gz"

tar -czf "$EXPORT_FILE" \
  -C "$HOMUNCULUS_DIR/instincts" personal

echo "Exported to: $EXPORT_FILE"
ls -la "$EXPORT_FILE"
```

## Export with Metadata

For richer exports, create a manifest:

```bash
# Count instincts
PERSONAL_COUNT=$(ls "$HOMUNCULUS_DIR/instincts/personal/" 2>/dev/null | wc -l | tr -d ' ')

# Get domains
DOMAINS=$(grep -h "^domain:" "$HOMUNCULUS_DIR/instincts/personal/"*.md 2>/dev/null | \
  sed 's/domain: "//' | sed 's/"//' | sort | uniq | tr '\n' ',' | sed 's/,$//')

# Create manifest
cat > "$HOMUNCULUS_DIR/exports/manifest.json" << EOF
{
  "exported": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "version": "2.0.0",
  "instincts": {
    "personal": $PERSONAL_COUNT
  },
  "domains": "$DOMAINS"
}
EOF

# Include manifest in export
tar -czf "$EXPORT_FILE" \
  -C "$HOMUNCULUS_DIR/exports" manifest.json \
  -C "$HOMUNCULUS_DIR/instincts" personal

rm "$HOMUNCULUS_DIR/exports/manifest.json"
```

## Voice

```
Exported [N] instincts to [FILE].

Domains covered: [LIST]

Share the file. Others can import with /homunculus:import.
```

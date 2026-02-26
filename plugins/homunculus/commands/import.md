---
description: Import instincts from others
---

# Import Instincts

Adopt instincts shared by others.

## How It Works

Imported instincts go to `inherited/`, not `personal/`.

This keeps clear separation:
- `personal/` = learned from YOUR behavior
- `inherited/` = adopted from others

## Import From File

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

# User provides path to export file
IMPORT_FILE="$ARGUMENTS"

if [ ! -f "$IMPORT_FILE" ]; then
  echo "File not found: $IMPORT_FILE"
  exit 1
fi

# Extract to temp directory first
TEMP_DIR=$(mktemp -d)
tar -xzf "$IMPORT_FILE" -C "$TEMP_DIR"

# Show what we're importing
echo "=== Importing ==="
ls -la "$TEMP_DIR/personal/" 2>/dev/null

# Count
COUNT=$(ls "$TEMP_DIR/personal/" 2>/dev/null | wc -l | tr -d ' ')
echo ""
echo "Found $COUNT instincts to import."
```

Wait for confirmation before proceeding.

## On Confirmation

```bash
# Move to inherited (rename to avoid conflicts)
mkdir -p "$HOMUNCULUS_DIR/instincts/inherited"

for f in "$TEMP_DIR/personal/"*.md; do
  if [ -f "$f" ]; then
    BASENAME=$(basename "$f")
    # Add prefix to avoid conflicts
    DEST="$HOMUNCULUS_DIR/instincts/inherited/imported-$BASENAME"
    cp "$f" "$DEST"
  fi
done

# Cleanup
rm -rf "$TEMP_DIR"

# Count inherited
INHERITED=$(ls "$HOMUNCULUS_DIR/instincts/inherited/" 2>/dev/null | wc -l | tr -d ' ')
echo "Imported. You now have $INHERITED inherited instincts."
```

## Update Identity

```bash
# Update counts
STATE="$HOMUNCULUS_DIR/identity.json"
INHERITED=$(ls "$HOMUNCULUS_DIR/instincts/inherited/" 2>/dev/null | wc -l | tr -d ' ')

jq --arg i "$INHERITED" '.instincts.inherited = ($i|tonumber)' "$STATE" > tmp.json && mv tmp.json "$STATE"
```

## Voice

```
Importing [N] instincts from [FILE].

These will go to inherited/, not personal/.
You can review them anytime.

Proceed? (yes/no)
```

After import:
```
Done. [N] instincts inherited.

They'll apply alongside your personal instincts.
```

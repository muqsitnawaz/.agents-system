#!/bin/bash
# Build default.yaml from group files
# Groups are processed in alphabetical order (00-, 01-, etc.)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GROUPS_DIR="$SCRIPT_DIR/groups"
OUTPUT="$SCRIPT_DIR/default.yaml"

if [ ! -d "$GROUPS_DIR" ]; then
  echo "Error: groups directory not found at $GROUPS_DIR"
  exit 1
fi

# Concatenate all group files in order, excluding gitignored local overrides.
# 00-local.yaml is a per-machine layer; its contents must never end up in the
# built default.yaml that gets committed to the public repo.
> "$OUTPUT"
for f in "$GROUPS_DIR"/*.yaml; do
  case "$(basename "$f" .yaml)" in
    00-local) continue ;;
  esac
  cat "$f" >> "$OUTPUT"
done

# Count entries
ALLOW_COUNT=$(grep -c '^\s*-\s*"' "$OUTPUT" 2>/dev/null || echo 0)
echo "Built $OUTPUT with $ALLOW_COUNT permission entries"

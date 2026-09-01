#!/usr/bin/env bash
set -euo pipefail

DATA_FILE="contributions.json"
README_FILE="README.md"
START_MARKER="<!-- OSS-CONTRIBUTIONS:START -->"
END_MARKER="<!-- OSS-CONTRIBUTIONS:END -->"
MAX_ITEMS=10

[ -f "$DATA_FILE" ] || exit 0
[ -f "$README_FILE" ] || exit 0

# Build the markdown list — top N most recent (file is already newest-first)
LIST=$(jq -r --arg max "$MAX_ITEMS" \
  '.[0:($max|tonumber)][] | "- [\(.repo)#\(.number)](\(.url)) — \(.title)"' \
  "$DATA_FILE")

# Replace everything between the markers with that list, leave the rest of the README alone
awk -v start="$START_MARKER" -v end="$END_MARKER" -v list="$LIST" '
  $0 ~ start { print; print list; skip=1; next }
  $0 ~ end   { skip=0 }
  skip != 1  { print }
' "$README_FILE" > tmp_readme.md && mv tmp_readme.md "$README_FILE"

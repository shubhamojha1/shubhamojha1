#!/usr/bin/env bash
set -euo pipefail

DATA_FILE="contributions.json"
BLOCKLIST_FILE="contribution_blocklist.json"
README_FILE="README.md"
START_MARKER="<!-- OSS-CONTRIBUTIONS:START -->"
END_MARKER="<!-- OSS-CONTRIBUTIONS:END -->"
MAX_ITEMS=10

[ -f "$DATA_FILE" ] || exit 0
[ -f "$README_FILE" ] || exit 0
[ -f "$BLOCKLIST_FILE" ] || echo '[]' > "$BLOCKLIST_FILE"

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
bash "$SCRIPT_DIR/validate-oss-data.sh"

# Select the top N eligible contributions, then group organizations by the
# repository owner. Groups are ordered by their most recent contribution.
LIST=$(jq -r --arg max "$MAX_ITEMS" --slurpfile blocked "$BLOCKLIST_FILE" '
  ($blocked[0] | map(.id)) as $blocked_ids
  | map(select(.id as $id | ($blocked_ids | index($id)) == null))
  | sort_by(.merged_at)
  | reverse
  | .[0:($max | tonumber)]
  | map(. + {organization: (.repo | split("/")[0])})
  | group_by(.organization)
  | map({
      organization: .[0].organization,
      latest: (map(.merged_at) | max),
      items: (sort_by(.merged_at) | reverse)
    })
  | sort_by(.latest)
  | reverse
  | map(
      "### [\(.organization)](https://github.com/\(.organization))\n\n"
      + (.items | map("- [\(.repo)#\(.number)](\(.url)) — \(.title)") | join("\n"))
    )
  | join("\n\n")
' \
  "$DATA_FILE")

# Replace everything between the markers with that list, leave the rest of the README alone
awk -v start="$START_MARKER" -v end="$END_MARKER" -v list="$LIST" '
  $0 ~ start { print; print list; skip=1; next }
  $0 ~ end   { skip=0 }
  skip != 1  { print }
' "$README_FILE" > tmp_readme.md && mv tmp_readme.md "$README_FILE"

#!/usr/bin/env bash
set -euo pipefail

: "${GH_USERNAME:?GH_USERNAME must be set}"

STATE_FILE="known_prs.json"       # ids already recorded, so we only act on new ones
DATA_FILE="contributions.json"    # full records — feeds the README + site later

[ -f "$STATE_FILE" ] || echo '[]' > "$STATE_FILE"
[ -f "$DATA_FILE" ]  || echo '[]' > "$DATA_FILE"

# Merged PRs authored by GH_USERNAME, excluding repos GH_USERNAME owns —
# so this only picks up contributions to *other* people's repos.
gh api "search/issues?q=is:pr+author:${GH_USERNAME}+is:merged+-user:${GH_USERNAME}&per_page=100" \
  --jq '[.items[] | {
    id: ((.repository_url | split("/")[-2:] | join("/")) + "#" + (.number|tostring)),
    repo: (.repository_url | split("/")[-2:] | join("/")),
    number: .number,
    title: .title,
    url: .html_url,
    merged_at: .pull_request.merged_at
  }]' > all_prs.json

jq --slurpfile known "$STATE_FILE" \
  '[.[] | select(.id as $i | ($known[0] | index($i)) == null)]' \
  all_prs.json > new_prs.json

NEW_COUNT=$(jq length new_prs.json)

if [ "$NEW_COUNT" -gt 0 ]; then
  jq -s '.[0] + .[1] | sort_by(.merged_at) | reverse' "$DATA_FILE" new_prs.json > tmp_data.json
  mv tmp_data.json "$DATA_FILE"

  jq -s '.[0] + [.[1][].id]' "$STATE_FILE" new_prs.json > tmp_state.json
  mv tmp_state.json "$STATE_FILE"

  echo "Found $NEW_COUNT new merged PR(s)."
else
  echo "No new merged PRs."
fi

rm -f all_prs.json new_prs.json

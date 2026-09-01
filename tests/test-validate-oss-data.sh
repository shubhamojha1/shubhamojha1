#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

write_valid_fixtures() {
  cat > "$TEST_DIR/contributions.json" <<'JSON'
[
  {
    "id": "example/project#42",
    "merged_at": "2026-08-01T12:30:00Z",
    "number": 42,
    "repo": "example/project",
    "title": "Add useful feature",
    "url": "https://github.com/example/project/pull/42"
  }
]
JSON

  cat > "$TEST_DIR/contribution_blocklist.json" <<'JSON'
[
  {
    "id": "docs/example#2",
    "reason": "Minor documentation-only fix"
  }
]
JSON

  cat > "$TEST_DIR/README.md" <<'MARKDOWN'
# Test profile

<!-- OSS-CONTRIBUTIONS:START -->
old content
<!-- OSS-CONTRIBUTIONS:END -->
MARKDOWN
}

expect_invalid() {
  local description=$1

  if (cd "$TEST_DIR" && bash "$REPO_ROOT/scripts/validate-oss-data.sh" > /dev/null 2>&1); then
    echo "Expected validation to reject $description." >&2
    exit 1
  fi
}

expect_render_failure() {
  if (cd "$TEST_DIR" && bash "$REPO_ROOT/scripts/render-readme.sh" > /dev/null 2>&1); then
    echo "Expected rendering to reject invalid contribution data." >&2
    exit 1
  fi
}

write_valid_fixtures
(cd "$TEST_DIR" && bash "$REPO_ROOT/scripts/validate-oss-data.sh")

jq '. + [.[0]]' "$TEST_DIR/contributions.json" > "$TEST_DIR/invalid.json"
mv "$TEST_DIR/invalid.json" "$TEST_DIR/contributions.json"
expect_invalid "duplicate contribution ids"

write_valid_fixtures
jq '.[0] |= del(.title)' "$TEST_DIR/contributions.json" > "$TEST_DIR/invalid.json"
mv "$TEST_DIR/invalid.json" "$TEST_DIR/contributions.json"
expect_invalid "a missing required field"
expect_render_failure

write_valid_fixtures
jq '.[0].id = "example/project#99"' "$TEST_DIR/contributions.json" > "$TEST_DIR/invalid.json"
mv "$TEST_DIR/invalid.json" "$TEST_DIR/contributions.json"
expect_invalid "an id that disagrees with repo and number"

write_valid_fixtures
jq '.[0].number = "42"' "$TEST_DIR/contributions.json" > "$TEST_DIR/invalid.json"
mv "$TEST_DIR/invalid.json" "$TEST_DIR/contributions.json"
expect_invalid "a field with the wrong type"

write_valid_fixtures
jq '.[0].merged_at = "2026-99-99T99:99:99Z"' "$TEST_DIR/contributions.json" > "$TEST_DIR/invalid.json"
mv "$TEST_DIR/invalid.json" "$TEST_DIR/contributions.json"
expect_invalid "an impossible merge timestamp"

write_valid_fixtures
jq '. + [.[0]]' "$TEST_DIR/contribution_blocklist.json" > "$TEST_DIR/invalid.json"
mv "$TEST_DIR/invalid.json" "$TEST_DIR/contribution_blocklist.json"
expect_invalid "duplicate blocklist ids"

write_valid_fixtures
jq '.[0].reason = "   "' "$TEST_DIR/contribution_blocklist.json" > "$TEST_DIR/invalid.json"
mv "$TEST_DIR/invalid.json" "$TEST_DIR/contribution_blocklist.json"
expect_invalid "a blocklist entry without a reason"

echo "OSS data validation tests passed."

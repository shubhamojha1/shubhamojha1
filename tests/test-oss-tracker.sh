#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

mkdir -p "$TEST_DIR/scripts" "$TEST_DIR/bin"
cp "$REPO_ROOT/scripts/track-contributions.sh" "$TEST_DIR/scripts/"
cp "$REPO_ROOT/scripts/render-readme.sh" "$TEST_DIR/scripts/"

cat > "$TEST_DIR/contribution_blocklist.json" <<'JSON'
[
  {
    "id": "InterviewReady/system-design-resources#33",
    "reason": "Minor documentation-only fix"
  },
  {
    "id": "docs/example#2",
    "reason": "Minor documentation-only fix"
  }
]
JSON

cat > "$TEST_DIR/contributions.json" <<'JSON'
[
  {
    "id": "istio/istio#1",
    "merged_at": "2026-08-01T00:00:00Z",
    "number": 1,
    "repo": "istio/istio",
    "title": "Existing contribution",
    "url": "https://github.com/istio/istio/pull/1"
  },
  {
    "id": "InterviewReady/system-design-resources#33",
    "merged_at": "2025-06-23T06:04:03Z",
    "number": 33,
    "repo": "InterviewReady/system-design-resources",
    "title": "Minor documentation fix",
    "url": "https://github.com/InterviewReady/system-design-resources/pull/33"
  }
]
JSON

cat > "$TEST_DIR/known_prs.json" <<'JSON'
[
  "istio/istio#1",
  "InterviewReady/system-design-resources#33"
]
JSON

cat > "$TEST_DIR/README.md" <<'MARKDOWN'
# Test profile

<!-- OSS-CONTRIBUTIONS:START -->
old content
<!-- OSS-CONTRIBUTIONS:END -->
MARKDOWN

cat > "$TEST_DIR/bin/gh" <<'MOCK'
#!/usr/bin/env bash
cat <<'JSON'
[
  {
    "id": "agentgateway/agentgateway#2",
    "merged_at": "2026-08-02T00:00:00Z",
    "number": 2,
    "repo": "agentgateway/agentgateway",
    "title": "New feature",
    "url": "https://github.com/agentgateway/agentgateway/pull/2"
  },
  {
    "id": "docs/example#2",
    "merged_at": "2026-08-03T00:00:00Z",
    "number": 2,
    "repo": "docs/example",
    "title": "Blocked documentation fix",
    "url": "https://github.com/docs/example/pull/2"
  }
]
JSON
MOCK
chmod +x "$TEST_DIR/bin/gh"

(
  cd "$TEST_DIR"
  PATH="$TEST_DIR/bin:$PATH" GH_USERNAME=test-user bash scripts/track-contributions.sh
  bash scripts/render-readme.sh
)

jq -e '
  length == 4
  and any(.[]; .id == "agentgateway/agentgateway#2")
  and any(.[]; .id == "istio/istio#1")
  and any(.[]; .id == "InterviewReady/system-design-resources#33")
  and any(.[]; .id == "docs/example#2")
' "$TEST_DIR/contributions.json" > /dev/null

jq -e '
  length == 4
  and index("agentgateway/agentgateway#2") != null
  and index("istio/istio#1") != null
  and index("InterviewReady/system-design-resources#33") != null
  and index("docs/example#2") != null
' "$TEST_DIR/known_prs.json" > /dev/null

grep -Fq '### [agentgateway](https://github.com/agentgateway)' "$TEST_DIR/README.md"
grep -Fq '### [istio](https://github.com/istio)' "$TEST_DIR/README.md"
grep -Fq 'agentgateway/agentgateway#2' "$TEST_DIR/README.md"
grep -Fq 'istio/istio#1' "$TEST_DIR/README.md"
! grep -Fq 'InterviewReady' "$TEST_DIR/README.md"
! grep -Fq 'docs/example#2' "$TEST_DIR/README.md"

agentgateway_line=$(grep -nF '### [agentgateway]' "$TEST_DIR/README.md" | cut -d: -f1)
istio_line=$(grep -nF '### [istio]' "$TEST_DIR/README.md" | cut -d: -f1)
test "$agentgateway_line" -lt "$istio_line"

echo "OSS tracker tests passed."

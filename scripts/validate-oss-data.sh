#!/usr/bin/env bash
set -euo pipefail

DATA_FILE="contributions.json"
BLOCKLIST_FILE="contribution_blocklist.json"

if [ ! -f "$DATA_FILE" ]; then
  echo "Missing $DATA_FILE." >&2
  exit 1
fi

if [ ! -f "$BLOCKLIST_FILE" ]; then
  echo "Missing $BLOCKLIST_FILE." >&2
  exit 1
fi

if ! jq -e '
  def nonempty_string: type == "string" and test("\\S");
  def positive_integer: type == "number" and . > 0 and floor == .;

  type == "array"
  and all(.[];
    type == "object"
    and (.id | nonempty_string)
    and (.repo | nonempty_string and test("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$"))
    and (.number | positive_integer)
    and (.title | nonempty_string)
    and (.url | nonempty_string)
    and (.merged_at |
      nonempty_string
      and test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$")
      and (try (fromdateiso8601 | type == "number") catch false)
    )
    and (.id == "\(.repo)#\(.number)")
    and (.url == "https://github.com/\(.repo)/pull/\(.number)")
  )
  and ((map(.id) | length) == (map(.id) | unique | length))
' "$DATA_FILE" > /dev/null; then
  echo "Invalid $DATA_FILE: expected complete, internally consistent records with unique ids." >&2
  exit 1
fi

if ! jq -e '
  def nonempty_string: type == "string" and test("\\S");

  type == "array"
  and all(.[];
    type == "object"
    and (.id |
      nonempty_string
      and test("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+#[1-9][0-9]*$")
    )
    and (.reason | nonempty_string)
  )
  and ((map(.id) | length) == (map(.id) | unique | length))
' "$BLOCKLIST_FILE" > /dev/null; then
  echo "Invalid $BLOCKLIST_FILE: expected unique ids with non-empty reasons." >&2
  exit 1
fi

echo "OSS contribution data is valid."

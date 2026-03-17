#!/usr/bin/env bash
set -euo pipefail

cd ~/PocketMux

WORKFLOW_NAME="${1:-PocketMux iOS CI}"
RUN_ID="${2:-}"
OUTFILE="${3:-/tmp/pocketmux-first-errors.log}"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: required command not found: $1" >&2
    exit 1
  }
}

require_cmd gh
require_cmd python3
require_cmd sed
require_cmd grep

if [[ -z "$RUN_ID" ]]; then
  RUN_ID="$(gh run list \
    --workflow "$WORKFLOW_NAME" \
    --limit 20 \
    --json databaseId,conclusion,status \
    --jq '.[] | select(.conclusion=="failure" or .status=="completed") | .databaseId' \
    | head -n 1)"
fi

if [[ -z "$RUN_ID" ]]; then
  echo "Error: could not determine a workflow run ID" >&2
  exit 1
fi

echo "Fetching full log for run ID: $RUN_ID"
gh run view "$RUN_ID" --log > "$OUTFILE"

python3 - "$OUTFILE" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
lines = path.read_text(errors="replace").splitlines()

error_patterns = [
    re.compile(r'\berror:'),
    re.compile(r'\bfatal error:'),
    re.compile(r'\bclang: error:'),
    re.compile(r'\bld: error:'),
]

matches = []
for i, line in enumerate(lines):
    if any(p.search(line) for p in error_patterns):
        matches.append(i)

if not matches:
    print("No explicit compiler/linker error lines found.")
    print()
    print("Last 120 lines of log:")
    for line in lines[-120:]:
        print(line)
    sys.exit(0)

print("===== FIRST REAL ERROR LINES WITH CONTEXT =====")
shown = set()

for idx in matches[:5]:
    start = max(0, idx - 10)
    end = min(len(lines), idx + 15)
    block_key = (start, end)
    if block_key in shown:
        continue
    shown.add(block_key)
    print()
    print(f"--- Context around line {idx + 1} ---")
    for j in range(start, end):
        print(f"{j+1}:{lines[j]}")
PY

echo
echo "Saved full log to: $OUTFILE"

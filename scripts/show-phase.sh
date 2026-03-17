#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE="$ROOT/PHASE_STATE.json"

if [[ ! -f "$STATE" ]]; then
  echo "Missing $STATE" >&2
  exit 1
fi

cat "$STATE"

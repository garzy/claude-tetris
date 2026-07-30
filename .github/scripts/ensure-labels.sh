#!/usr/bin/env bash
# Creates or updates the GitHub labels defined in .github/labels.txt.
# Idempotent: safe to run on every issue-triage workflow run.
# Requires GH_TOKEN and GH_REPO to be set in the environment.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABELS_FILE="${SCRIPT_DIR}/../labels.txt"

if [[ ! -f "$LABELS_FILE" ]]; then
  echo "Labels file not found: $LABELS_FILE" >&2
  exit 1
fi

while IFS='|' read -r name color description; do
  # Skip blank lines and comments.
  [[ -z "$name" || "$name" == \#* ]] && continue

  if gh label create "$name" --color "$color" --description "$description" >/dev/null 2>&1; then
    echo "Created label: $name"
  elif gh label edit "$name" --color "$color" --description "$description" >/dev/null 2>&1; then
    echo "Updated label: $name"
  else
    echo "Warning: could not create or update label: $name" >&2
  fi
done < "$LABELS_FILE"
